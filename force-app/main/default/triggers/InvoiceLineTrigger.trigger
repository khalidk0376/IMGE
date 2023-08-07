/**
 * Project:     GAP
 * Date:        3/2/2018
 * Created By:  Abdul Kadir
 * Test class   InvoiceHandlerfromQuoteUtility_Test.cls, InvoiceHandlerFromQuote_Test
 * *************************************************************************
 * Description: Trigger for the blng__InvoiceLine__c object
 * *************************************************************************
 * History: Modified By Rajesh Kumar - 21 -3 -2019 : Due to Vat Tax refund amount update in invoice line item : 
 * 
 */

trigger InvoiceLineTrigger on blng__InvoiceLine__c (before insert,before update,after insert, after update) {
    System.debug('==> INvLine Trigger Called !!');
    List<Id> invoiceIdList = new List<Id>();
    for(blng__InvoiceLine__c invoiceLine: Trigger.new) {
        invoiceIdList.add(invoiceLine.blng__Invoice__c);
    }

    if(Trigger.isBefore && Trigger.isInsert) {
        if(invoiceIdList.size() > 0) 
        {
            System.debug('Inside InvoiceLine applyPaymentScheduleToInvoice One Time == ');
         //  InvoiceHandlerV2.applyPaymentScheduleToInvoice(invoiceIdList, Trigger.New);
           InvoiceHandlerfromQuote.applyPaymentScheduleToInvoice(invoiceIdList, Trigger.New);           
        }
    }
    //Tax Refund amount update on Invoice line
    if(Trigger.isafter && Trigger.isUpdate) {
        set<Id> setInvoiceLineIds = new set<Id> ();
        for (blng__InvoiceLine__c invoiceLine : Trigger.New){
            blng__InvoiceLine__c oldInvoiceLine = Trigger.oldMap.get(invoiceLine.ID); 
            if (oldInvoiceLine.blng__TaxStatus__c != invoiceLine.blng__TaxStatus__c  && invoiceLine.blng__TaxStatus__c == 'Error' && (invoiceLine.blng__TaxErrorMessage__c == 'Please Check Errorlogs' || invoiceLine.blng__TaxErrorMessage__c =='You have uncommitted work pending. Please commit or rollback before calling out') &&  invoiceLine.blng__TaxErrorMessage__c != null && invoiceLine.blng__TaxStatus__c != 'Queued' ){
                setInvoiceLineIds.add(invoiceLine.id); 
            }
        }
        if (setInvoiceLineIds.size() > 0){
            TaxRefundInvoiceLine_Future.updateTaxRefundInvoiceLineStatus (setInvoiceLineIds);
        } 
    }

    //Added Rajesh for Updating Max Tax Code and Max Country COde. BK-6918 and Modified By Rajesh Kumar -BK-11310
    if ((Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) || ( Trigger.isBefore && Trigger.isUpdate) ){
        UpdateMaxTaxCodeCountryCode.maxrollupsummery(Trigger.new, Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate, Trigger.isAfter , Trigger.isBefore);


    }
}