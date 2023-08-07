/**
 * Batchable job to cancel and rebill the invoices that have been flagged.
 *  Invoice.Cancel_and_Rebill__c = true Changed Reverted after raised : BK-9281
 */

global class CancelRebillInvoicesBatch implements Database.Batchable<sObject>, Database.Stateful {

    public static Integer BATCH_SIZE = 1;
    private Boolean doReschedule;
    private Integer runFrequency = 60;
    private String currencyCode = 'USD';
    global Set<Id> queueableJobIds = new Set<Id>();
    private final String QUERY = 'SELECT Id, Cancel_and_Rebill__c,  blng__InvoiceStatus__c ' +
            'FROM blng__Invoice__c WHERE Cancel_and_Rebill__c = true AND blng__InvoiceStatus__c != \'Cancelled\'';

    private CancelRebillInvoicesBatchDataInterface dataInterface;
    
    public CancelRebillInvoicesBatch(Boolean doReschedule,String currencyCode) {
        this.doReschedule = doReschedule;
        this.currencyCode = currencyCode;
        dataInterface = new CancelRebillInvoicesBatchDataDefaultImpl();
    }
    
    public CancelRebillInvoicesBatch(Boolean doReschedule, Integer syncFrequency, String currencyCode) {
        this.doReschedule = doReschedule;
        this.runFrequency = syncFrequency;
        this.currencyCode = currencyCode;
        dataInterface = new CancelRebillInvoicesBatchDataDefaultImpl();
    }

    public CancelRebillInvoicesBatch(Boolean doReschedule, Integer syncFrequency, String currencyCode, CancelRebillInvoicesBatchDataInterface altInterface) {
        this.doReschedule = doReschedule;
        this.runFrequency = syncFrequency;
        this.currencyCode = currencyCode;
        dataInterface = altInterface;
    }

    global Database.QueryLocator start(Database.BatchableContext batchableContext) {

        System.debug('CancelRebillInvoicesBatch start batch job ' + batchableContext.getJobId());
        return Database.getQueryLocator(QUERY + ' AND CurrencyIsoCode = \'' + this.currencyCode + '\'');
    }

    global void execute(Database.BatchableContext batchableContext, List<sObject> scope) {

        if(batchableContext != null) {
            System.debug('CancelRebillInvoicesBatch execute batch job ' + batchableContext.getChildJobId() + ' scope: ' + scope.size());
        }
        for(sObject customObject: scope) {
            blng__Invoice__c invoice = (blng__Invoice__c) customObject;
            dataInterface.performaCreditInvoice(invoice);
            //this.queueableJobIds.add(System.enqueueJob(new AsynchronousCancelRebill(invoice.Id)));
        }
    }


    /**
     * Executed when the batch job is completed.
     *
     * We are kicking off an Invoice Scheduler after we finish the cancel & rebill. 
     */
    global void finish(Database.BatchableContext batchableContext) {
        
        if(batchableContext != null) {
            System.debug('CancelRebillInvoicesBatch Finished ' + batchableContext.getJobId());
        }
        
        //  Getting No of days to add with Target date
        Integer noOfDaysToAdd = 700 ;
        Batch_Settings__c oExpocadCredential = Batch_Settings__c.getValues('CancelRebillInvoicesBatch');
        if(oExpocadCredential != NULL){
            noOfDaysToAdd = Integer.ValueOf(oExpocadCredential.No_of_Days_to_add_in_TargetDate__c) ;
        }

        // Need to run the invoice scheduler after finished cancel & rebilling the invoices
        blng__InvoiceScheduler__c invoiceScheduler = new blng__InvoiceScheduler__c();
        invoiceScheduler.Name = currencyCode + ' invoice generation ' + DateTime.now();
        invoiceScheduler.CurrencyIsoCode = currencyCode;
        invoiceScheduler.blng__TargetDate__c = Date.today().addDays(noOfDaysToAdd);
        invoiceScheduler.blng__Type__c = 'Once';
        invoiceScheduler.blng__StartDateTime__c = DateTime.now().addMinutes(2);

        if(Test.isRunningTest()) {
            return;
        }
        dataInterface.insertInvoiceScheduler(invoiceScheduler);

        if(this.doReschedule) {
            rescheduleThis();
        }
    }

    @TestVisible
    private void rescheduleThis() {
        CancelRebillInvoicesBatch batch = new CancelRebillInvoicesBatch(true, runFrequency, currencyCode);
        System.scheduleBatch(batch, 'CancelRebillInvoicesBatch' + currencyCode + ' ' + Datetime.now().addMinutes(runFrequency), runFrequency, BATCH_SIZE);
    }

    /**
     * Data & API interface for the cancel and rebill batch job.
     */
    public interface CancelRebillInvoicesBatchDataInterface {

        void performaCreditInvoice(blng__Invoice__c anInvoice);

        void insertInvoiceScheduler(blng__InvoiceScheduler__c anInvoiceScheduler);
    }

    /**
     * Default Implementation of the CancelRebillInvoicesBatchDataInterface
     */
    public class CancelRebillInvoicesBatchDataDefaultImpl implements CancelRebillInvoicesBatchDataInterface {

        public void performaCreditInvoice(blng__Invoice__c anInvoice) {
            blng.InvoiceAPI.creditInvoice(anInvoice.Id, 'Cancel and Re-bill');
        }

        public void insertInvoiceScheduler(blng__InvoiceScheduler__c anInvoiceScheduler) {
            insert anInvoiceScheduler;
        }
    }
}