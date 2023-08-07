/**
 * Project     GAP
 * Date       3/2/2018
 * Created By  Abdul Kadir
 * Test class   InvoiceHandlerFromQuote_Test.cls [93%]
 * *************************************************************************
 * @description Class to handle the business logic that needs to happen from the InvoiceTrigger.
 * *************************************************************************
 * History: Modified By Sudip for Jira Ticket GGCW-2082 on 26/06/2018
 * Modified By Rajesh Yadav for Jira Ticket GGCW-2087 on 09/08/2018
 * Modified by Rajesh Kumar yadav ::: https://informa-ge-sfdc.atlassian.net/browse/BK-2006 on 8/8/19.
 * Modified by Akshi Arora for BK-3513
 * Modified by Avinash For BK-3429 08-03-2020
   modified by shiv raghav Bk-6941 04/12/2020
 * Modified by faisal Khan BK-BK-24822 12/1/2022
 */

public with sharing class InvoiceHandlerFromQuote {
    /**
     * @description Update the credit transfer information on the invoice.Update the VAT-Tax Footer Information.Stamp the Bill to contact on the invoice.
     * @param invoices invoices list
     * @return None
     */
    public static void updateFieldsOnInvoice(List<blng__Invoice__c> invoices)  {
        System.debug('InvoiceHandlerFromQuote.updateFieldsOnInvoice() ' + invoices);
        //List<blng__Invoice__c> updatedInvoices = new List<blng__Invoice__c>();
        List<Id> lstParentOrderIds =  new List<Id>();
        List<Decimal> taxVatString = new List<Decimal>();
        List<String> esCountry = new List<String>();
        List<Invoice_Tax_Rate__c> invoiceTaxSet = new List<Invoice_Tax_Rate__c>();
        Map<Id, Id> orderIdByInvoiceIdMap = new  Map<Id, Id>();
        for (blng__Invoice__c invoice : invoices) {
            orderIdByInvoiceIdMap.put(invoice.Id, invoice.blng__Order__c);
            taxVatString.add(invoice.TaxRate__c);
            esCountry.add(invoice.Event_Series_Country_Informa__c);
        }
        system.debug('taxVatString--- > :' + taxVatString);
        system.debug('esCountry--- > :' + esCountry);
        if (taxVatString.size() > 0) {
            invoiceTaxSet = Database.query('Select id,ES_Country__c,Exhibitor_Country__c,Tax_Rate__c,Tax_Text__c,Primary_Tax_Rate__c,Secondary_Tax_Rate__c from Invoice_Tax_Rate__c where Tax_Rate__c = : taxVatString AND ES_Country__c = : esCountry');
        } system.debug('invoiceTaxSet --- > :' + invoiceTaxSet );
        system.debug('invoiceTaxSet --- > :' + invoiceTaxSet.size());
        Map<Id, Order> orderByIdsMap = new Map<Id, Order> ([SELECT Id, BillToContactId, Billing_Invoice_Account__c, Billing_Invoice_Account__r.BillingCountryCode, TotalAmount, Quote_Type__c FROM Order WHERE Id IN :orderIdByInvoiceIdMap.values()]);

        List<Error_Log__c> erLogsToInsert = new List<Error_Log__c>();
        for (blng__Invoice__c invoice : invoices) {

            if ((invoice.UKEUorROW__c == 'UK' && invoice.CurrencyCode__c != 'GBP' && invoice.TaxRate__c == 20) || invoice.UKEUorROW__c == 'EU' && invoice.CurrencyCode__c != 'GBP' && invoice.TaxRate__c == 20 && String.isBlank(invoice.Customer_VAT_No__c)) { invoice.ShowUKEquivalent__c = true; invoice.ShowGBPExchange__c = true;
            } 
            else {
                invoice.ShowUKEquivalent__c = false;
                invoice.ShowGBPExchange__c = false;
            }

            // Update the bill to contact id,Contact's Account id and order amount.
            if (orderByIdsMap.containsKey(invoice.blng__Order__c)) {
                invoice.blng__BillToContact__c = orderByIdsMap.get(invoice.blng__Order__c).BillToContactId;
                invoice.Billing_Invoice_Account__c = orderByIdsMap.get(invoice.blng__Order__c).Billing_Invoice_Account__c;
                invoice.Order_Amount__c = orderByIdsMap.get(invoice.blng__Order__c).TotalAmount;
                invoice.Alt_Billing_Account_Country_Code__c  = orderByIdsMap.get(invoice.blng__Order__c).Billing_Invoice_Account__r.BillingCountryCode;
                // GGCW-2162
                invoice.Quote_Type__c = orderByIdsMap.get( invoice.blng__Order__c ).Quote_Type__c;
            }
            // Modified by Rajesh Kumar yadav : https://informa-ge-sfdc.atlassian.net/browse/BK-2006 on 8/8/19.
            // Modified by Akshi Arora : for BK-3513.

          
         // Modified by faisal khan : BK-25330
          
          if(invoice.Alternate_Bank_Address__c && (invoice.LegalEntityCode__c=='AE006' ||  invoice.LegalEntityCode__c=='AE09')){
             invoice.CreditTransferAlternate__c= TaxLanguageHelper.getLanguagealternateCreditTransfer(invoice.LegalEntityCode__c+'Bank');
          }
           // Modified by faisal khan : BK-25330
          
          String langTextCTI = TaxLanguageHelper.getLanguageTextForCreditTransferInfo(invoice.LegalEntityCode__c, invoice.CurrencyCode__c, invoice.Event_Series_Alternate_Currency__c);


            invoice.CreditTransferInfoLong__c = langTextCTI != 'NoTaxLang' ? langTextCTI : '';
            if (langTextCTI == 'NoTaxLang' && Schema.sObjectType.Error_Log__c.isCreateable() && Schema.sObjectType.Error_Log__c.fields.Service_Source__c.isCreateable() && Schema.sObjectType.Error_Log__c.fields.Source_Name__c.isCreateable() && Schema.sObjectType.Error_Log__c.fields.Description__c.isCreateable()) {
                erLogsToInsert.add(new Error_Log__c(Service_Source__c = 'Integration', Source_Name__c = 'TaxLanguageHelper', Description__c = 'The tax language code did not find a valid value in the Tax_language__c custom setting. Please rectify. Method name : TaxLanguageHelper.getLanguageTextForCreditTransferInfo, Record Affected : ' + invoice.Id));
            }
            if (invoice.TaxRate__c == 0) {
                String langTextVatFoot0 = TaxLanguageHelper.getLanguageTextForVatFooter(invoice.LegalEntityCode__c, 20);
                invoice.VAT_or_Tax_footer__c = langTextVatFoot0 != 'NoTaxLang' ? langTextVatFoot0 : '';
                if (langTextCTI == 'NoTaxLang' && Schema.sObjectType.Error_Log__c.isCreateable() && Schema.sObjectType.Error_Log__c.fields.Service_Source__c.isCreateable() && Schema.sObjectType.Error_Log__c.fields.Source_Name__c.isCreateable() && Schema.sObjectType.Error_Log__c.fields.Description__c.isCreateable()) {
                    erLogsToInsert.add(new Error_Log__c(Service_Source__c = 'Integration', Source_Name__c = 'TaxLanguageHelper', Description__c = 'The tax language code did not find a valid value in the Tax_language__c custom setting. Please rectify. Method name : TaxLanguageHelper.getLanguageTextForVatFooter(invoice.LegalEntityCode__c, 20), Record Affected : ' + invoice.Id));
                }
            } else if (invoice.TaxRate__c == 8) { String langTextVatFoot8 = TaxLanguageHelper.getLanguageTextForVatFooter(invoice.LegalEntityCode__c, 8); invoice.VAT_or_Tax_footer__c = langTextVatFoot8 != 'NoTaxLang' ? langTextVatFoot8 : ''; if (langTextCTI == 'NoTaxLang') { erLogsToInsert.add(new Error_Log__c(Service_Source__c = 'Integration', Source_Name__c = 'TaxLanguageHelper', Description__c = 'The tax language code did not find a valid value in the Tax_language__c custom setting. Please rectify. Method name : TaxLanguageHelper.getLanguageTextForVatFooter(invoice.LegalEntityCode__c, 8), Record Affected : ' + invoice.Id)); }
            } 
            else if (invoice.TaxRate__c == 5) { String langTextVatFoot5 = TaxLanguageHelper.getLanguageTextForVatFooter(invoice.LegalEntityCode__c, 5); invoice.VAT_or_Tax_footer__c = langTextVatFoot5 != 'NoTaxLang' ? langTextVatFoot5 : ''; if (langTextCTI == 'NoTaxLang') { erLogsToInsert.add(new Error_Log__c(Service_Source__c = 'Integration', Source_Name__c = 'TaxLanguageHelper', Description__c = 'The tax language code did not find a valid value in the Tax_language__c custom setting. Please rectify. Method name : TaxLanguageHelper.getLanguageTextForVatFooter(invoice.LegalEntityCode__c, 5), Record Affected : ' + invoice.Id)); }
            }
            else if (invoice.TaxRate__c == 3) { String langTextVatFoot3 = TaxLanguageHelper.getLanguageTextForVatFooter(invoice.LegalEntityCode__c, 3); invoice.VAT_or_Tax_footer__c = langTextVatFoot3 != 'NoTaxLang' ? langTextVatFoot3 : ''; if (langTextCTI == 'NoTaxLang' ) { erLogsToInsert.add(new Error_Log__c(Service_Source__c = 'Integration', Source_Name__c = 'TaxLanguageHelper', Description__c = 'The tax language code did not find a valid value in the Tax_language__c custom setting. Please rectify. Method name : TaxLanguageHelper.getLanguageTextForVatFooter(invoice.LegalEntityCode__c, 3), Record Affected : ' + invoice.Id)); }
            }
            else {   
                      /* BK-24822*/
                   if(invoice.VAT_Country_Conga__c=='Total Morocco VAT 20%' && invoice.CurrencyCode__c!='MAD'){String langTextVatFoot = TaxLanguageHelper.getLanguageTextForVatFooterForMAD(invoice.LegalEntityCode__c, 20);  invoice.VAT_or_Tax_footer__c = langTextVatFoot != 'NoTaxLang' ? langTextVatFoot : ''; if (langTextCTI == 'NoTaxLang' ) { erLogsToInsert.add(new Error_Log__c(Service_Source__c = 'Integration', Source_Name__c = 'TaxLanguageHelper', Description__c = 'The tax language code did not find a valid value in the Tax_language__c custom setting. Please rectify. Method name : TaxLanguageHelper.getLanguageTextForVatFooter(invoice.LegalEntityCode__c, 20), Record Affected : ' + invoice.Id)); }
                   }
                   /* BK-24822*/
                   else{
                    String langTextVatFoot = TaxLanguageHelper.getLanguageTextForVatFooter(invoice.LegalEntityCode__c, 20);  invoice.VAT_or_Tax_footer__c = langTextVatFoot != 'NoTaxLang' ? langTextVatFoot : ''; if (langTextCTI == 'NoTaxLang' ) { erLogsToInsert.add(new Error_Log__c(Service_Source__c = 'Integration', Source_Name__c = 'TaxLanguageHelper', Description__c = 'The tax language code did not find a valid value in the Tax_language__c custom setting. Please rectify. Method name : TaxLanguageHelper.getLanguageTextForVatFooter(invoice.LegalEntityCode__c, 20), Record Affected : ' + invoice.Id)); }
                   }
            }
  
            
        }
        //GGCW-2082
        if ( ! lstParentOrderIds.IsEmpty( ) ) {Map <String, String> orderScheduler = new Map <String, String> ( ); Map<Id, Id> mapChildVsParentInv = new Map<Id, Id>();
            for ( Order odr : [ SELECT id, Parent_Opp_Order__c FROM Order WHERE Id IN : lstParentOrderIds ] ) { if ( odr.Parent_Opp_Order__c != NULL ) { mapChildVsParentInv.put(odr.Id, odr.Parent_Opp_Order__c); } }
            if ( !mapChildVsParentInv.isEmpty( ) ) { for ( blng__Invoice__c invoice : [ SELECT Id, Schedule_Number__c, blng__Order__c FROM blng__Invoice__c WHERE blng__Order__c IN : mapChildVsParentInv.Values() AND blng__InvoiceStatus__c != 'Cancelled' AND blng__InvoiceStatus__c != 'Rebilled' ] ) { String key = invoice.blng__Order__c + ':' + invoice.Schedule_Number__c; orderScheduler.put( key, invoice.Id ); } }
            if (!orderScheduler.isEmpty()) { for ( blng__Invoice__c invoice : invoices ) { Id parentOrderId = mapChildVsParentInv.get(invoice.blng__Order__c); String sKey = parentOrderId + ':' + invoice.Schedule_Number__c ;  
        } 
    }
        }
        if(!erLogsToInsert.isEmpty()) insert erLogsToInsert;
    }

    /**
     * @description Duplicate the invoice so that there's an invoice for each payment date.
     * @param invoiceIdList invoice id list
     * @param invoiceLines  invoice line list
     */
    public static void applyPaymentScheduleToInvoice(List<Id> invoiceIdList, List<blng__InvoiceLine__c> invoiceLines) {
        // Only want to replicate those invoices that are first in the series or brand new.
        System.debug('InvoiceHandlerFromQuote.applyPaymentScheduleToInvoice() ' + invoiceIdList);
        Map<Id, blng__Invoice__c> idFirstInvoiceMap = new Map<Id, blng__Invoice__c>([SELECT Id, Name, blng__Account__c,
                blng__ARStatus__c, blng__BillToContact__c, blng__DueDate__c, blng__InvoiceDate__c, blng__Notes__c,
                blng__Order__c, blng__PaymentBatch__c, blng__PaymentMethod__c, blng__InvoiceStatus__c,
                blng__TargetDate__c, blng__TaxErrorMessage__c, blng__TaxStatus__c, blng__UniqueId__c,
                blng__Order__r.SBQQ__Quote__c, blng__Order__r.SBQQ__Quote__r.SBQQ__Opportunity2__c,
                blng__Order__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.EventEdition__r.Payment_Schedule__c,
                Schedule_Number__c, CurrencyIsoCode, blng__InvoiceRunCreatedBy__c, blng__Order__r.BillToContactId
                FROM blng__Invoice__c
                WHERE Id IN :invoiceIdList AND Schedule_Number__c = 1]);

        // Get the invoice lines related the each of the original invoices
        Map<Id, List<blng__InvoiceLine__c>> invoiceIdToInvoiceLinesMap = new Map<Id, List<blng__InvoiceLine__c>>();

        System.debug('InvoiceHandlerFromQuote.applyPaymentScheduleToInvoice() invoiceLines: ' + invoiceLines);

        List<Id> orderProducts = new List<Id>();
        List<blng__InvoiceLine__c> mapInvoiceLines;
        for (blng__InvoiceLine__c invoiceLine : invoiceLines) {
            if (invoiceIdToInvoiceLinesMap.containsKey(invoiceLine.blng__Invoice__c)) { mapInvoiceLines = invoiceIdToInvoiceLinesMap.get(invoiceLine.blng__Invoice__c);
            } else {
                mapInvoiceLines = new List<blng__InvoiceLine__c>();

            }
            mapInvoiceLines.add(invoiceLine);
            invoiceIdToInvoiceLinesMap.put(invoiceLine.blng__Invoice__c, mapInvoiceLines);
            orderProducts.add(invoiceLine.blng__OrderProduct__c);
        }

        System.debug('InvoiceHandlerFromQuote.applyPaymentScheduleToInvoice() idFirstInvoiceMap: ' + idFirstInvoiceMap.size() + ' keys: ' + idFirstInvoiceMap.keySet() + ' invoiceIdToInvoiceLinesMap: ' + invoiceIdToInvoiceLinesMap);
        if (idFirstInvoiceMap.size() > 0) {
            Map<Id, OrderItem> orderProductMap = new Map<Id, OrderItem>(
                [SELECT Id, OrderId, SBQQ__QuoteLine__r.SBQQ__Quote__c, SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.SBQQ__AmendedContract__c, Order.BillToContactId
                 FROM OrderItem WHERE Id IN :orderProducts]);

            Map<Id, Id> invoiceIdToQuoteIdMap = new Map<Id, Id>();
            Map<Id, Id> quoteToFirstInvoiceMap = new Map<Id, Id>();
            Map<Id, Id> invoiceIdToOrderIdMap = new Map<Id, Id>();
            Map<Id, Id> invoiceIdToContactIdMap = new Map<Id, Id>();

            for (blng__Invoice__c invoice : idFirstInvoiceMap.values()) {
                if (invoice.blng__Order__r.SBQQ__Quote__c != null) { invoiceIdToQuoteIdMap.put(invoice.Id, invoice.blng__Order__r.SBQQ__Quote__c); quoteToFirstInvoiceMap.put(invoice.blng__Order__r.SBQQ__Quote__c, invoice.Id); invoiceIdToOrderIdMap.put(invoice.Id, invoice.blng__Order__c); invoiceIdToContactIdMap.put(invoice.Id, invoice.blng__Order__r.BillToContactId);
                } else {
                    List<InvoiceLineWrapper> invoiceLinesWrapped = new List<InvoiceLineWrapper>();
                    for (blng__InvoiceLine__c invoiceLine : invoiceIdToInvoiceLinesMap.get(invoice.Id)) {
                        invoiceLinesWrapped.add(new InvoiceLineWrapper(invoiceLine));
                    }

                    invoiceLinesWrapped.sort();

                    for (InvoiceLineWrapper invoiceLine : invoiceLinesWrapped)  {
                        OrderItem item = orderProductMap.get(invoiceLine.inv.blng__OrderProduct__c);
                        //if(item.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.SBQQ__AmendedContract__c == null) {
                        invoiceIdToQuoteIdMap.put(invoice.Id, item.SBQQ__QuoteLine__r.SBQQ__Quote__c);
                        quoteToFirstInvoiceMap.put(item.SBQQ__QuoteLine__r.SBQQ__Quote__c, invoice.Id);
                        invoiceIdToOrderIdMap.put(invoice.Id, item.OrderId);
                        invoiceIdToContactIdMap.put(invoice.Id, item.Order.BillToContactId);
                        //}
                    }
                }
            }
            Map<Id, SBQQ__Quote__c> quoteMap = new Map<Id, SBQQ__Quote__c>([SELECT Id, Name, Payment_Schedule__c,
                    SBQQ__Opportunity2__r.EventEdition__r.Payment_Schedule__c, Invoice_to_be_issued_before_in_Days__c, SBQQ__Opportunity2__r.Custom_Payment__c,
                    InvoicetoStartDate__c, invoice_payment1__c, invoice_Percentage1__c
                    FROM SBQQ__Quote__c
                    WHERE Id IN :invoiceIdToQuoteIdMap.values()]);

            system.debug('invoiceIdToQuoteIdMap======' + invoiceIdToQuoteIdMap);
            // Create the new Invoices
            List<blng__Invoice__c> newInvoices = new List<blng__Invoice__c>();
            List<blng__Invoice__c> updateInvoices = new List<blng__Invoice__c>();
            for (blng__Invoice__c invoice : idFirstInvoiceMap.values()) {
                Id quoteId = invoiceIdToQuoteIdMap.get(invoice.Id);
                System.debug('InvoiceHandler.applyPaymentScheduleToInvoice() invoice quote id: ' + quoteId);

                // In case the order hasn't been set, we set it on the original invoice. Sometimes happens when the using the InvoiceScheduler.
                if (invoice.blng__Order__c == null) { invoice.blng__Order__c = invoiceIdToOrderIdMap.get(invoice.Id); invoice.blng__BillToContact__c = invoiceIdToContactIdMap.get(invoice.Id); }
                updateInvoices.add(invoice);
            }


            System.debug('InvoiceHandler.applyPaymentScheduleToInvoice() updateInvoices: ' + updateInvoices);
            if (updateInvoices.size() > 0) {
                if (Schema.sObjectType.blng__Invoice__c.isUpdateable()) {
                    update updateInvoices;
                }
            }

        }
    }
    /**
     * @description Wrapper class for Invoice line to sort the invoice lines on createddate.
     */
    public class InvoiceLineWrapper implements Comparable {
        public blng__InvoiceLine__c inv;
        /**
         * @description wrapper class
         * @param  anInvoiceLine Invoice line
         */
        public InvoiceLineWrapper(blng__InvoiceLine__c anInvoiceLine) {
            inv = anInvoiceLine;
        }
        /**
         * @description compareTo
         * @param  compareTo
         * @return
         */
        public Integer compareTo(Object compareTo) {
            InvoiceLineWrapper compareToInvoice = (InvoiceLineWrapper) compareTo;

            Integer returnValue = 0;
            if (inv.CreatedDate > compareToInvoice.inv.CreatedDate) { returnValue = 1;
            } else if (inv.CreatedDate < compareToInvoice.inv.CreatedDate) { returnValue = -1;
            }
            return returnValue;
        }
    }
}