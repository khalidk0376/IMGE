/**
 * Project:     GAP
 * Date:        28/7/2017
 * Created By:  Margaret Persico
 * Test Class:  JournalBatchTest
 * *************************************************************************
 * @description Scheduled batch class to handle the uploading the invoices to SAP.
 * *************************************************************************
 * History:  Modified By Avinash for Jira Tickets GGCW-2783 on 27/12/2018
 *           Modified By Avinash for Jira Tickets GGCW-2783 on 26/02/2019, fixing SCA violations
 *           Modified By Avinash for Jira Tickets BK-1771 on 27/06/2019
 *           MOdified By Avinash for JIra Tickets BK-515 on 09/07/2019
 *           MOdified by Avinash for JIra Tickets BK-2398 -- PRB0040118: Journal Batch Added two custom fields in the query to get the SAP order Id and SAP Cancel Order Id.
 */

public class JournalBatch implements Database.Batchable<blng__Invoice__c>, Database.Stateful, Database.AllowsCallouts {
    //Modified by Avinash : BK-1771
    public static Integer batchSize = 100;
    //Modified by Avinash : GGCW-2783
    //MOdified by Avinash : BK-515
    //MOdified by Avinash : BK-2398 -- PRB0040118: Journal Batch, Modified Query : Making SAP calls only when there is no SAP order Id AND/OR SAPOrderIDCancel on invoice lines.
    private final String QUERY = 'SELECT Id, Schedule_Number__c, blng__InvoiceStatus__c, Invoice_Submissions__c, Invoice_Submitted_Processing__c FROM blng__Invoice__c WHERE blng__Order__c != null AND ((blng__InvoiceStatus__c IN (\'Posted\',\'Rebilled\') AND SAP_Order_Id_Exists__c	= 0 AND Invoice_Submitted_Processing__c = false AND Invoice_Submissions__c < :invoiceSubmissionLimit ) OR (blng__InvoiceStatus__c IN (\'Cancelled\', \'Rebilled\') AND Invoice_Cancelled_Processing__c = false AND Invoice_Submitted_Processing__c = true AND SAP_Order_Id_Exists__c > 0 AND SAPOrderIDCancel_Exists__c = 0 AND Invoice_Submissions__c < :invoiceSubmissionLimit)) AND blng__NumberOfInvoiceLines__c > 0 LIMIT 200';
    private String callVerb = 'POST';
    private String integrationServiceName = 'INVOICE';
    private Boolean manualReschedule = false;
    //MOdified by Avinash : BK-515
    private Integer runFrequency = 30;
    private final String BATCH_SERVICE_NAME = 'JOURNAL_INVOICE';
    private Integer invoiceSubmissionLimit = 3;
    private String integrationUrl = '';
    private String integrationUsername = '';
    private String integrationPassword = '';
    private JournalBatchDataInterface dataInterface;

    private final static String ERROR_SERVICE_SOURCE = 'Batch';

    /**
     * @description If need the journal batch to run every 60 minutes, then send true
     * otherwise the batch job will run only once.
     * @param  doReschedule  paramter
     * @param  syncFrequency paramter
     * @return               None
     */
    public JournalBatch(Boolean doReschedule, Integer syncFrequency) {
        manualReschedule = doReschedule;
        this.runFrequency = syncFrequency;
        initializeSettings();
        dataInterface = new JournalBatchDataDefaultImpl();
    }

    /**
     * @description If need the journal batch to run every 60 minutes, then send true
     * @param  doReschedule  Parameter
     * @param  syncFrequency Parameter
     * @param  altInterface  Parameter
     * @return               None
     */
    public JournalBatch(Boolean doReschedule, Integer syncFrequency, JournalBatchDataInterface altInterface) {
        manualReschedule = doReschedule;
        this.runFrequency = syncFrequency;
        initializeSettings();
        dataInterface = altInterface;
    }
    /**
     * @description query method
     * @param  batchableContext Parameter
     * @return                  Parameter
     */
    public Iterable<blng__Invoice__c> start(Database.BatchableContext batchableContext) {
        String fullQuery = QUERY;
        return (List<blng__Invoice__c>) Database.query(fullQuery);

    }
    /**
     * @description Execute Method
     * @param  batchableContext Parameter
     * @param  invoices         Parameter
     * @return                  None
     */
    public void execute(Database.BatchableContext batchableContext, List<blng__Invoice__c> invoices) {
        System.debug('JournalBatch.execute() ' + invoices.size());
        InvoiceJournalRequest request = new InvoiceJournalRequest(invoices);
        String invoiceJournalPayload = InvoiceJournalRequest.serializeToString(request);
        String response = '';
        system.debug('Invoice Request String : ' + invoiceJournalPayload);

        try {
            response = OutboundCallHelper.makeClientIdTypeHttpRequest(integrationUrl, callVerb, invoiceJournalPayload, integrationUsername, integrationPassword);
            System.debug('JournalBatch.execute() ' + response);
            InvoiceJournalResponse ijResponse = InvoiceJournalResponse.parse(response);
            System.debug('JournalBatch.execute()  response: ' + ijResponse);

            if (ijResponse.Header != null && (String.isBlank(ijResponse.Header.Systems.MessageStatus) || ijResponse.Header.Systems.MessageStatus == 'OK' || ijResponse.Header.Systems.MessageStatus == 'UPDATED')) {
                // Success so we update the invoices with the Invoice_Submitted_Processing__c
                logSuccess(invoices);
            } else {
                Map<Id, blng__Invoice__c> invoicesByIds = new Map<Id, blng__Invoice__c>(invoices);
                //Map<Id, String> errorMessageById = new Map<Id, String>();
                List<blng__Invoice__c> errorInvoices = new List<blng__Invoice__c>();
                List<blng__Invoice__c> successInvoices = new List<blng__Invoice__c>();

                String errorString = '';
                for (InvoiceJournalResponse.Message message : ijResponse.Messages) {
                    if (message.MessageType == 'Success') {
                        successInvoices.add(invoicesByIds.get(message.MessageReference));
                    } else {
                        errorInvoices.add(invoicesByIds.get(message.MessageReference));
                        //errorMessageById.put(message.MessageReference, message.MessageText);
                    }
                    errorString = errorString + 'Error from integration server occurred: [' + message.MessageType + ' ' + message.MessageText + ']';
                }

                logSuccess(successInvoices);
                logError(errorInvoices, errorString, '');
            }

        } catch (InformaExceptions.InformaHttpException eek) {
            logError(invoices, eek.getMessage(), eek.getStackTraceString());
        }

    }
    /**
     * @description finish method
     * @param  batchableContext Parameter
     * @return                  None
     */
    public void finish(Database.BatchableContext batchableContext) {
        if (manualReschedule) {
            rescheduleThis();
        }
    }
    /**
     * @description setting initialisation
     */
    private void initializeSettings() {
        invoiceSubmissionLimit = BatchSettingsHelper.getRetriesFromSettings(BATCH_SERVICE_NAME);
        integrationUrl = IntegrationSettingsHelper.getEndpointFromSettings(integrationServiceName);
        integrationUsername = IntegrationSettingsHelper.getUsernameFromSettings(integrationServiceName);
        integrationPassword = IntegrationSettingsHelper.getPasswordFromSettings(integrationServiceName);
    }
    /**
     * @description rescheduleThis
     */
    private void rescheduleThis() {
        JournalBatch batch = new JournalBatch(true, runFrequency);
        System.scheduleBatch(batch, 'Journal Batch Job ' + Datetime.now().addMinutes(runFrequency), runFrequency, batchSize);
    }
    /**
     * @description success logging
     * @param invoices Parameter
     */
    private void logSuccess(List<blng__Invoice__c> invoices) {
        System.debug(LoggingLevel.ERROR, 'JournalBatch.logSuccess() called ' + invoices.size());
        for (blng__Invoice__c invoice : invoices) {
            //Modified By Avinash : BK-1771, 26/06/2019
            if ((invoice.blng__InvoiceStatus__c == 'Posted' || invoice.blng__InvoiceStatus__c == 'Rebilled') && !invoice.Invoice_Submitted_Processing__c) {
                invoice.Invoice_Submitted_Processing__c = true; 
            } else if ((invoice.blng__InvoiceStatus__c == 'Cancelled' || invoice.blng__InvoiceStatus__c == 'Rebilled') && invoice.Invoice_Submitted_Processing__c) {
                invoice.Invoice_Cancelled_Processing__c = true;
            }
            invoice.Invoice_Submissions__c = 0;
        }

        if (invoices.size() > 0) {
            dataInterface.updateInvoices(invoices);
        }
    }
    /**
     * @description error logging
     * @param invoices         Parameter
     * @param message          Parameter
     * @param stackTraceString Parameter
     */
    private void logError(List<blng__Invoice__c> invoices, String message, String stackTraceString) {
        System.debug(LoggingLevel.ERROR, 'JournalBatch.logError() outbound call error ' + message);
        Map<Id, Decimal> invoiceRetries = new Map<Id, Decimal>();
        // Increment the retry attempts on each of the invoices.
        for (blng__Invoice__c invoice : invoices) {
            invoice.Invoice_Submissions__c = invoice.Invoice_Submissions__c + 1;
            invoiceRetries.put(invoice.Id, invoice.Invoice_Submissions__c);
        }

        if (invoices.size() > 0) {
            dataInterface.updateInvoices(invoices);
        }

        //Create new error log entry
        Error_Log__c errorLog = new Error_Log__c(Service_Source__c = ERROR_SERVICE_SOURCE, Source_Name__c = BATCH_SERVICE_NAME);
        errorLog.Description__c = message + ' ' + stackTraceString + ' \n ';
        errorLog.Affected_Object__c = 'blng__Invoice__c';
        errorLog.Affected_Object_Details__c = 'Invoice Id, Invoice Submissions' + invoiceRetries;

        insert errorLog;
    }
    /**
     * @description Interface method
     */
    public interface JournalBatchDataInterface {

        void updateInvoices(List<blng__Invoice__c> updatedInvoices);

    }
    /**
     * @descripiton Update invoices method.
     */
    public class JournalBatchDataDefaultImpl implements JournalBatchDataInterface {
        public void updateInvoices(List<blng__Invoice__c> updatedInvoices) {
            update updatedInvoices;
        }
    }

}