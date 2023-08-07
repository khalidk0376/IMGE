/**
 * Project:   GAP
 * Date:      28/10/2017
 * Created By:Steve Lohrenz
 * Test class InvoiceHandlerfromQuoteUtility_Test.cls
 * *************************************************************************
 * Description: This Trigger update billing contact ,billing account on the invoice and also format the date on the basis of ES country.
 * *************************************************************************
 * History: Modified By Avinash for Jira Ticket GGCW-1830 on 17/01/2019
 * Modified by Rajesh Kumar : GGCW-3239 on 27/03/2019
 * Modified by Rajesh Kumar yadav : https://informa-ge-sfdc.atlassian.net/browse/BK-2006 on 8/8/19 active this trigger for the ticket.
 * Modified by Shiv Raghav Sharma : https://informa-ge-sfdc.atlassian.net/browse/BK-2751
 * ticket no.-BK-14522 Updating API Version
 */
trigger InvoiceTrigger on blng__Invoice__c ( before insert, before update, after insert, after update ) {

    //Rajesh Kumar : Created one apex handler class for merging code in "UpdateAlternateCurrency" class.
    if (Trigger.isUpdate){
        UpdateAlternateCurrency_Class objUpdateAlternateCurrency = new UpdateAlternateCurrency_Class(Trigger.new, Trigger.oldMap, Trigger.isInsert, Trigger.isupdate, Trigger.isBefore, Trigger.isAfter );
        if (Trigger.isBefore){
            objUpdateAlternateCurrency.beforeTaxCalMethod();
            if(Trigger.isupdate){
                //BK-2751(Shiv Raghav Sharma)   
                objUpdateAlternateCurrency.invoiceCancelReasonAndChatterFeedPostOnOpportunity();
            }
            
        }
        if (Trigger.isAfter){
            objUpdateAlternateCurrency.afterMethodforAsync();
               
        }
        objUpdateAlternateCurrency.showValidMsgUpdateConga();
    }

    if (Trigger.isBefore) {
        InvoiceHandlerFromQuote.updateFieldsOnInvoice(Trigger.new);
    }
}