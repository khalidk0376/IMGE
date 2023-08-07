/**
* File:        BatchInvoiceUpdateForEmail 
* Project:     GAP
* Date:        13-09-2019
* Created By:  Rajesh Kr 
* Test Class : BatchInvoiceUpdateForEmail_Test
*************************************************************************
* Description: Batch Class for updating invoice for Email processing.
* ************************************************************************* 
*/

public class BatchInvoiceUpdateForEmail implements Database.Batchable<sObject> {
    final String sQuery;
    private List <blng__Invoice__c> lstInvoiceUpdate = new List <blng__Invoice__c>();
    public BatchInvoiceUpdateForEmail(){sQuery = 'SELECT Invoice_Emailed_Date__c ,blng__InvoiceStatus__c , EventEditionEndDate__c, Activate_Invoice_WF__c  ,(Select Id , RelatedToId FROM Emails LIMIT 1), Invoice_Processed__c FROM blng__Invoice__c WHERE blng__InvoiceStatus__c =\'Posted\' AND EventEditionEndDate__c > TODAY AND Invoice_Emailed_Date__c != NULL AND Activate_Invoice_WF__c = True AND Invoice_Processed__c = true';}public Database.QueryLocator start(Database.BatchableContext BC) {return Database.getQueryLocator(sQuery);}public void execute(Database.BatchableContext BC, List<blng__Invoice__c> lstInvoice) {       for (blng__Invoice__c oinvoices : lstInvoice){if (oinvoices.Emails.isEmpty()){oinvoices.Invoice_Processed__c = false;oinvoices.Invoice_Emailed_Date__c = null; lstInvoiceUpdate.add(oinvoices);}} if (!lstInvoiceUpdate.isEmpty()){ Database.Update(lstInvoiceUpdate , false); }}      public void finish(Database.BatchableContext BC) { System.debug('Invoice Successfully updated');}
}