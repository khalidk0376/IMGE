/**
 * File:        TaxRefundInvoiceLine_Future.cls
 * Project:     GAP
 * Date:        19/3/2019
 * Created By:  Rajesh Kumar
 * Test Class : InvoiceHandlerFromQuote_Test
 * *************************************************************************
 * Description: TaxRefundInvoiceLine_Future calling from RemoteTaxInvoiceLineService apex class
 * *************************************************************************
 * History: 
 */
public class TaxRefundInvoiceLine_Future {    
    @future(callout=true)
    public static void updateTaxRefundInvoiceLineStatus(set<id> setUpdateinvoiceLines){
        Map <Id , blng__InvoiceLine__c> mapUpdateinvoiceLine = new Map <Id , blng__InvoiceLine__c>([Select Id , blng__TaxStatus__c,blng__TaxErrorMessage__c , InvoiceLine_Tax_Refund_Amount__c from blng__InvoiceLine__c where Id IN : setUpdateinvoiceLines]); 
        if (mapUpdateinvoiceLine.values().size() > 0){
            for (blng__InvoiceLine__c oInvoiceLine :  mapUpdateinvoiceLine.values()){ 
                if (oInvoiceLine.blng__TaxStatus__c == 'Error' && (oInvoiceLine.blng__TaxErrorMessage__c == 'Please Check Errorlogs' || oInvoiceLine.blng__TaxErrorMessage__c =='You have uncommitted work pending. Please commit or rollback before calling out') &&  oInvoiceLine.blng__TaxErrorMessage__c != null && oInvoiceLine.blng__TaxStatus__c != 'Queued' ){ 
                    oInvoiceLine.blng__TaxStatus__c = 'Queued';   oInvoiceLine.blng__TaxErrorMessage__c = '';
                } 
            }  
            update mapUpdateinvoiceLine.values();
        }
    }
}