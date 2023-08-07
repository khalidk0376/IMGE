/**
* Project:         GAP
* Date:            23th Nov 2018
* Created By:      Abdul Kadir
* Test class       InvoicelineUpdateBeforeInvoicePost_Test.cls
* Code Coverage:   100%
* *************************************************************************
* @Description     This Batch class use to update invoiceline status from Queued to Completed before invoice going to be posted.
* *************************************************************************
* Modified 02/04/2019 : GGCW-2754 rajesh k y
* @param 
*/
public class InvoicelineUpdateBeforeInvoicePost implements Database.Batchable<SObject>,Schedulable{
    private String sQuery = NULL;
    private Date todaysDate = Date.today();
    private Date tomorrow = todaysDate.addDays(1);
    public Set<blng__Invoice__c> invoiceNeedsUpdate = new Set<blng__Invoice__c>();
    
    public  Database.QueryLocator start(Database.BatchableContext bc){
         sQuery ='Select id,Invoice_lines_updated__c, blng__InvoiceStatus__c ,(SELECT Id,Name,blng__TaxStatus__c FROM blng__InvoiceInvoiceLines__r LIMIT 1) from blng__Invoice__c where Invoice_Heirarchy__c=\'Child Invoice\' AND  blng__InvoiceStatus__c=\'Draft\' AND blng__InvoiceDate__c  =: tomorrow AND Schedule_Number__c > 1 AND Invoice_lines_updated__c=false';
         return Database.getQueryLocator(sQuery);
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> scope){
        List<blng__InvoiceLine__c> invoiceLineList = new List<blng__InvoiceLine__c>();
        
        //Fitering the invoiceline on the basis of invoice.Only one invoiceline per invoice put in to the map and update it's status to Queued , so that it will update tax status of all the invoice lines related to that invoice.
         for(sObject oScope : scope){
            blng__Invoice__c invoiceRecord = (blng__Invoice__c)oScope;
            if(invoiceRecord.blng__InvoiceStatus__c != 'Posted'){
                if(invoiceRecord.blng__InvoiceInvoiceLines__r.size() > 0){
                    blng__InvoiceLine__c invoicelines = invoiceRecord.blng__InvoiceInvoiceLines__r[0];
                    invoicelines.blng__TaxStatus__c = 'Queued';
                    invoiceLineList.add(invoicelines);
                    invoiceRecord.Invoice_lines_updated__c = true;
                    invoiceNeedsUpdate.add(invoiceRecord);
                }
            }
            
        }
        if(!invoiceNeedsUpdate.isEmpty()){
            update invoiceLineList;
            update new List<blng__Invoice__c>(invoiceNeedsUpdate);
        }
    }
    
    public  void finish(Database.BatchableContext bc){
       AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =: bc.getJobId()];

       // Send an email to the Apex job's submitter notifying of job completion.
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       String[] toAddresses = new String[] {job.CreatedBy.Email};
       mail.setToAddresses(toAddresses);
       mail.setSubject('Invoice line status updated to Queued before Invoice Post ' + job.Status);
       mail.setPlainTextBody
       ('The batch Apex job named as InvoicelineUpdateBeforeInvoicePost processed ' + job.TotalJobItems +
       ' batches with '+ job.NumberOfErrors + ' failures.');
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    public void execute(SchedulableContext ctx) {
        //Use below line to execute this batch from developer console.
        Database.executeBatch(new InvoicelineUpdateBeforeInvoicePost(),1);
    }
   

}