/**
* Project:         GAP
* Date:            22/4/2018
* Created By:      Abdul Kadir
* Test class       InvoiceHandlerfromQuoteUtility_Test.cls
* Code Coverage:   100%
* *************************************************************************
* Description:     This Batch class use to call invoicehandlerfromQuoteUtility class to clone the invoices on the basis of payment schedule.
* *************************************************************************
* History: Modifing Access Modifier for class from GLOBAL to Public : Removing SCA violation priority 2 
           BK-2270 : 23/08/2019
*/

public class Invoice_InvoiceLineCreateBatchable implements Database.Batchable<sObject>, Schedulable{
    
    // Member Variables
    public final String Query;
    Integer iBatchSize = 1;
    Integer iInvoicePickuptime = 2 ;
    Integer iRescheduleTime = 2;
    DateTime dtInvoiceCreatedBefore;
    private String sQuery = NULL;
    
    // Default Constructor 
    public Invoice_InvoiceLineCreateBatchable(){
        Invoice_Batch_Config__c oConfig = Invoice_Batch_Config__c.getOrgDefaults();
        If(oConfig != NULL){
            If(oConfig.invoice_pickup_time__c != NULL && oConfig.invoice_pickup_time__c >= 1)
                iInvoicePickuptime = Integer.valueOf(oConfig.invoice_pickup_time__c);
        }
    }
    
    // Batch Start Method Overridden.
    public Database.QueryLocator start(Database.BatchableContext BC){
        dtInvoiceCreatedBefore = Datetime.now().addMinutes(-(iInvoicePickuptime));
        String sDynamicQueryFlds = this.dynamicQuery('blng__Invoice__c');
        sQuery = 'SELECT '+sDynamicQueryFlds+', blng__Order__r.SBQQ__Quote__c, blng__Order__r.SBQQ__Quote__r.SBQQ__Opportunity2__c, blng__Order__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.EventEdition__r.Payment_Schedule__c,blng__Order__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Event_Series__r.SSC_Details__r.Time_Zone_Difference__c,blng__Order__r.BillToContactId FROM blng__Invoice__c WHERE Invoice_Heirarchy__c = \'Parent Invoice\' AND blng__InvoiceStatus__c =\'Draft\' AND Createddate <=: dtInvoiceCreatedBefore AND OpportunityId__c != NULL AND blng__Order__c != NULL AND Enable_Invoice_Creation_Using_Batch__c = False AND Invoice_Line_Error__c = 0';
        System.debug('sQuery==>'+sQuery);
        return Database.getQueryLocator(sQuery);
    }
    
    // Chunks Execution Logic.
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        //System.debug('scope===='+scope);
        Map<Id,blng__Invoice__c> mapInvoicevsIds = new Map<Id,blng__Invoice__c>();
        for(sObject oScope : scope){
            blng__Invoice__c oInvoice = (blng__Invoice__c)oScope;
            mapInvoicevsIds.put(oInvoice.Id, oInvoice);
        }
        InvoiceHandlerfromQuoteUtility.createInvoice_InvoiceLines(mapInvoicevsIds);
    }
    
    // Batch finish Method Overridden. We started again this batch Once its been finished.
    public void finish(Database.BatchableContext BC){
        Invoice_Batch_Config__c oConfig = Invoice_Batch_Config__c.getOrgDefaults();
        If(oConfig != NULL){
            if(oConfig.batch_size_scope__c != NULL && oConfig.batch_size_scope__c != 0)
                iBatchSize = Integer.valueOf(oConfig.batch_size_scope__c);
            If(oConfig.schedule_time__c != NULL && oConfig.schedule_time__c >= 1)
                iRescheduleTime = Integer.valueOf(oConfig.schedule_time__c);
        }
        If(!Test.isRunningTest())
            System.scheduleBatch(new Invoice_InvoiceLineCreateBatchable(), 'InvoiceLineCreateBatchable '+String.ValueOf(Datetime.now()), iRescheduleTime, iBatchSize);
    }
    
    // Scheduled Method which will initiate this Batch Job
    public void execute(SchedulableContext ctx)
    {
        Database.executeBatch(new Invoice_InvoiceLineCreateBatchable(), 1);
    }
    
    // Getting All Fields for given Object.
    public string dynamicQuery(string SobjectApiName){
        String commaSepratedFields = '';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
        for(Schema.SObjectField field : fieldMap.values()){
            if(field.getDescribe().isAccessible()){
                //&& field.getDescribe().isUpdateable() && field.getDescribe().isCreateable()
                if(commaSepratedFields == null || commaSepratedFields == ''){
                    commaSepratedFields = field.getDescribe().getName();
                }else{
                    commaSepratedFields = commaSepratedFields + ', ' + field.getDescribe().getName();
                }
            }
        }
        return commaSepratedFields;
    }
}