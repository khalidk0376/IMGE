/**
 * Integration point to call out to the tax service for the instance on an InvoiceLines
 * History :
 * 18/7/2018 : Modified by Kumar for Jira Ticket GGCW-2172
 * 31/10/2018 : Modified by Avinash for Jira Ticket GGCW-2736
 * 13/11/2018 : Modified by Avinash for Jira Ticket GGCW-2736
 * 25/02/2020 : Modified by Avinash for Jira Ticket BK-3269(Tax exempt to be made false in case we have Tax returned from SAP), Increased test class coverage to 86%
 * @param
 * @description
 * @description TEST Class ::: RemoteTaxInvoiceLineServiceTest(86%)
*/
public with sharing class RemoteTaxInvoiceLineService extends RemoteTaxAbstractService implements RemoteTaxService {
    private RemoteTaxInvoiceLineDatabaseInterface databaseInterface;
    public RemoteTaxInvoiceLineService() {databaseInterface = new RemoteTaxInvoiceLineDatabaseDefaultImpl();}
    public RemoteTaxInvoiceLineService(RemoteTaxInvoiceLineDatabaseInterface dbInterface) {databaseInterface = dbInterface;}
    public Map < Id, blng.TaxResults > getTax(List < String > listOfLegalEntityReferences) {
        List < blng__InvoiceLine__c > invoiceLines = new List < blng__InvoiceLine__c > ();
        List < Id > orderIds = new List < Id > ();
        String businessProcessNumber = '';
        if (listOfLegalEntityReferences != null) {
            invoiceLines = databaseInterface.queryInvoiceLinesByLegalEntityReference(listOfLegalEntityReferences);
            if (invoiceLines != null && invoiceLines.size() > 0) {
                Id accountId = invoiceLines.get(0).blng__Invoice__r.blng__Account__c;
                If(invoiceLines.get(0).blng__Invoice__r.Billing_Invoice_Account__c != Null) {accountId = invoiceLines.get(0).blng__Invoice__r.Billing_Invoice_Account__c;}
                Id legalEntityId = invoiceLines.get(0).blng__LegalEntity__c;
                List < Account_Legal_Entity__c > acctLegalEntities = databaseInterface.queryAccountLegalEntitiesByAccountIdAndLegalEntityId(accountId, new Set < Id > {legalEntityId});
                businessProcessNumber = acctLegalEntities != null && acctLegalEntities.size() > 0 ? acctLegalEntities.get(0).Business_Partner_Number__c : '';
            }
            for (blng__InvoiceLine__c invoiceLine : invoiceLines) {orderIds.add(invoiceLine.blng__Invoice__r.blng__Order__c);}
        }
        Map < Id, Contact > contactsByOrderIds = databaseInterface.queryBillingContactsByIds(orderIds);
        return calculateTax(invoiceLines, contactsByOrderIds, businessProcessNumber);
    }

    public Map < Id, blng.TaxResults > postTax(List < String > listOfLegalEntityReferences) {return new Map < Id, blng.TaxResults > ();}    public Map < Id, blng.TaxResults > cancelTax(List < String > listOfLegalEntityReferences) {return new Map < Id, blng.TaxResults > ();}
    public Map < Id, blng.TaxResults > calculateTax(List < blng__InvoiceLine__c > invoiceLines, Map < Id, Contact > contactsByOrderIds, String businessProcessNumber) {
        Map < Id, blng.TaxResults > taxResultsByIds = new Map < Id, blng.TaxResults > ();
        List < blng__InvoiceLine__c > lstUpdateinvoiceLines = new List < blng__InvoiceLine__c > ();
        Double dPrimaryTaxRate;
        Double dSecondaryTaxRate;
        if (invoiceLines != null && invoiceLines.size() > 0) {
            Integer counter = 0;
            while (counter < invoiceLines.size()) {
                if (invoiceLines.get(counter).blng__LegalEntity__c == null) {
                    blng.TaxResults taxResults = new blng.TaxResults();
                    taxResults.setIsSuccess(false);
                    taxResults.setSummary(MISSING_LEGAL_ENTITY);
                    taxResults.setId(invoiceLines.get(counter).Id);
                    taxResults.setTax(0.00);
                    taxResultsByIds.put(invoiceLines.get(counter).Id, taxResults);
                    invoiceLines.remove(counter);
                } else {
                    counter++;
                }
            }
            if (invoiceLines.size() > 0) {
                CalculateTaxRequest request = new CalculateTaxRequest(invoiceLines, contactsByOrderIds, contactsByOrderIds, businessProcessNumber);
                try {
                    CalculateTaxResponse response = makeOutboundCall(request);
                    if (response.Header != null && (String.isBlank(response.Header.Systems.MessageStatus) || response.Header.Systems.MessageStatus == 'OK' || response.Header.Systems.MessageStatus == 'UPDATED')) {
                        List < CalculateTaxResponse.CartItems > cartItems = response.Content.Transaction_x.CartItems;
                        for (CalculateTaxResponse.CartItems cartItem : cartItems) {
                            for (blng__InvoiceLine__c invoiceItem : invoiceLines) {
                                if (invoiceItem != null && cartItem.CartItem.LineNumber == invoiceItem.blng__OrderProduct__r.OrderItemNumber  && invoiceItem.blng__Subtotal__c != null && cartItem.CartItem.Price == Integer.valueOf(invoiceItem.blng__Subtotal__c * 100) && !taxResultsByIds.containsKey(invoiceItem.Id)) {
                                    blng.TaxResults taxResults = new blng.TaxResults();

                                    //Added By Rajesh Kumar - 03-09-2020 on Bk-6918
                                    invoiceItem.SAP_Tax_Country__c  = cartItem.CartItem.TAXCOUNTRY;
                                    invoiceItem.SAP_Tax_Code__c = cartItem.CartItem.TAXCODE;

                                    if (cartItem.CartItem.TaxRates.size() >= 1) {
                                        Decimal taxValue = cartItem.CartItem.TaxRates[0].TaxAmount != null ? Decimal.valueOf(cartItem.CartItem.TaxRates[0].TaxAmount) / 100 : cartItem.CartItem.TaxRates[0].TaxAmount;
                                        //Added By Rajesh Kumar - 30-11-2020 on Bk-11310
                                        if(cartItem.CartItem.TaxRates[0].TaxRate != null){
                                            invoiceItem.SAP_Primary_Tax_Rate__c = String.valueof(((Double)cartItem.CartItem.TaxRates[0].TaxRate) / 100 ) + '%';
                                            dPrimaryTaxRate = ((Double) cartItem.CartItem.TaxRates[0].TaxRate) /100 ;} else { dPrimaryTaxRate = cartItem.CartItem.TaxRates[0].TaxRate; }

                                        if (cartItem.CartItem.TaxRates.size() >= 2) {
                                            if (cartItem.CartItem.TaxRates[1].TaxRate > 0) {
                                                taxResults.setTax(Decimal.valueOf(cartItem.CartItem.Tax) / 100); 
                                                taxResults.setRate(Double.valueof(cartItem.CartItem.TaxRates[0].TaxRate) / 100); 
                                                taxResults.setId(invoiceItem.Id); taxResults.setIsSuccess(cartItem.CartItem.Tax != null); 
                                                taxResultsByIds.put(invoiceItem.Id, taxResults);
                                                //invoiceItem.Tax_Exempt_SAP__c = false;
                                                if(cartItem.CartItem.TaxRates[1].TaxRate != null){ invoiceItem.SAP_Secondary_Tax_Rate__c = String.valueof(((Double)cartItem.CartItem.TaxRates[1].TaxRate) / 100 ) + '%'; ////Added By Rajesh Kumar - 30-11-2020 on Bk-11310
                                                    dSecondaryTaxRate = ((Double)cartItem.CartItem.TaxRates[1].TaxRate)/100 ; } else { dSecondaryTaxRate = cartItem.CartItem.TaxRates[1].TaxRate; } lstUpdateinvoiceLines.add(invoiceItem);
                                            } else if (cartItem.CartItem.TaxRates[1].TaxRate < 0) {
                                                Decimal taxRefundValue = cartItem.CartItem.TaxRates[1].TaxAmount != null ? Decimal.valueOf(cartItem.CartItem.TaxRates[1].TaxAmount) / 100 : cartItem.CartItem.TaxRates[1].TaxAmount;
                                                Decimal taxRefundPercentage = cartItem.CartItem.TaxRates[1].TaxRate != null ? Decimal.valueOf(cartItem.CartItem.TaxRates[1].TaxRate) / 100 : cartItem.CartItem.TaxRates[1].TaxRate;
                                                invoiceItem.InvoiceLine_Tax_Refund_Amount__c = taxRefundValue;
                                                invoiceItem.Tax_Refund_Percentage_Applied__c = taxRefundPercentage;
                                                taxResults.setTax(taxValue);
                                                taxResults.setRate(Double.valueof(cartItem.CartItem.TaxRates[0].TaxRate) / 100);
                                                taxResults.setId(invoiceItem.Id);
                                                taxResults.setIsSuccess(cartItem.CartItem.TaxRates[0].TaxAmount != null);
                                                taxResultsByIds.put(invoiceItem.Id, taxResults);
                                                //invoiceItem.Tax_Exempt_SAP__c = false;
                                                if(cartItem.CartItem.TaxRates[1].TaxRate != null){
                                                    invoiceItem.SAP_Secondary_Tax_Rate__c = String.valueof (((Double)cartItem.CartItem.TaxRates[1].TaxRate)/100) + '%'; ////Added By Rajesh Kumar - 30-11-2020 on Bk-11310
                                                    dSecondaryTaxRate = ((Double)cartItem.CartItem.TaxRates[1].TaxRate)/100 ; } else {dSecondaryTaxRate = cartItem.CartItem.TaxRates[1].TaxRate;}

                                                lstUpdateinvoiceLines.add(invoiceItem);
                                            }
                                        } else {
                                            if (string.valueOf(taxValue) == null || string.valueOf(taxValue) == '') {
                                                taxResults.setTax(0.00);
                                                taxResults.setRate(0.00);
                                                taxResults.setId(invoiceItem.Id);
                                                taxResults.setIsSuccess(true);
                                                taxResultsByIds.put(invoiceItem.Id, taxResults);
                                                //invoiceItem.Tax_Exempt_SAP__c = true;
                                                lstUpdateinvoiceLines.add(invoiceItem);
                                            } else {
                                                taxResults.setTax(taxValue);
                                                taxResults.setRate(Double.valueof(cartItem.CartItem.TaxRates[0].TaxRate) / 100);
                                                taxResults.setId(invoiceItem.Id);
                                                taxResults.setIsSuccess(cartItem.CartItem.TaxRates[0].TaxAmount != null);
                                                taxResultsByIds.put(invoiceItem.Id, taxResults);
                                                //invoiceItem.Tax_Exempt_SAP__c = false;
                                                lstUpdateinvoiceLines.add(invoiceItem);
                                            }
                                        }
                                    }
                                    //Added Logic for Tax Exempt Functionality.. By Rajesh Kumar - 02-12-2020 - BK-11323
                                    // Modified by Palla Kishore for the ticket BK-19606
                                    invoiceItem.Tax_Exempt_SAP__c =  new TaxExemptSAP().TaxExempt(cartItem.cartItem.TAXCODE, cartItem.cartItem.TAXCOUNTRY,dPrimaryTaxRate, dSecondaryTaxRate);
                                    //new TaxExemptSAP().getLocalExchangeCurrency(cartItem.cartItem.TAXCODE, cartItem.cartItem.TAXCOUNTRY,dPrimaryTaxRate,invoiceItem.blng__Invoice__c );

                                }
                                //Modified by Avinash : GGCW-2736
                                /*else if ((invoiceItem.blng__Invoice__r.blng__Order__r.Opportunity.Parent_Opportunity__c != NULL && invoiceItem.blng__Invoice__r.blng__Order__r.Opportunity.Parent_Opportunity__r.Tax_Scenario__c == 'UK Exhibitor VAT Invoicing') || Test.isRunningTest()) {
                                    if (invoiceItem.SAP_Tax_Product__c || Test.isRunningTest()) {
                                        if (invoiceItem.blng__Invoice__r.Parent_Opp_Invoice__c != NULL  || Test.isRunningTest()) {
                                            if ((invoiceItem != null && cartItem.CartItem.LineNumber == invoiceItem.blng__OrderProduct__r.OrderItemNumber && invoiceItem.blng__Subtotal__c != null && !taxResultsByIds.containsKey(invoiceItem.Id))|| Test.isRunningTest()) {
                                                blng.TaxResults taxResults = new blng.TaxResults();

                                                //Added By Rajesh Kumar - 03-09-2020 on Bk-6918

                                                invoiceItem.SAP_Tax_Country__c  = cartItem.CartItem.TAXCOUNTRY;
                                                invoiceItem.SAP_Tax_Code__c = cartItem.CartItem.TAXCODE;
                                                if (cartItem.CartItem.TaxRates.size() >= 1) {
                                                    Decimal taxValue = cartItem.CartItem.TaxRates[0].TaxAmount != null ? Decimal.valueOf(cartItem.CartItem.TaxRates[0].TaxAmount) / 100 : cartItem.CartItem.TaxRates[0].TaxAmount;
                                                    //Added By Rajesh Kumar - 30-11-2020 on Bk-11310
                                                    if(cartItem.CartItem.TaxRates[0].TaxRate != null){
                                                        invoiceItem.SAP_Primary_Tax_Rate__c = String.valueof(((Double)cartItem.CartItem.TaxRates[0].TaxRate) / 100) + '%';
                                                        dPrimaryTaxRate = ((Double) cartItem.CartItem.TaxRates[0].TaxRate) /100 ; } else { dPrimaryTaxRate = cartItem.CartItem.TaxRates[0].TaxRate;}
                                                    if (cartItem.CartItem.TaxRates.size() >= 2) {
                                                        if (cartItem.CartItem.TaxRates[1].TaxRate > 0) {
                                                            taxResults.setTax(Decimal.valueOf(cartItem.CartItem.Tax) / 100);
                                                            taxResults.setRate(Double.valueof(cartItem.CartItem.TaxRates[0].TaxRate) / 100);
                                                            taxResults.setId(invoiceItem.Id);
                                                            taxResults.setIsSuccess(cartItem.CartItem.Tax != null);
                                                            taxResultsByIds.put(invoiceItem.Id, taxResults);
                                                            ////invoiceItem.Tax_Exempt_SAP__c = false;
                                                            if(cartItem.CartItem.TaxRates[1].TaxRate != null){
                                                                invoiceItem.SAP_Secondary_Tax_Rate__c = String.valueof(((Double)cartItem.CartItem.TaxRates[1].TaxRate) / 100) + '%'; //Added By Rajesh Kumar - 30-11-2020 on Bk-11310
                                                                dSecondaryTaxRate = ((Double)cartItem.CartItem.TaxRates[1].TaxRate)/100 ; } else { dSecondaryTaxRate = cartItem.CartItem.TaxRates[1].TaxRate; }

                                                            lstUpdateinvoiceLines.add(invoiceItem);
                                                        } else if (cartItem.CartItem.TaxRates[1].TaxRate < 0)   {
                                                            Decimal taxRefundValue = cartItem.CartItem.TaxRates[1].TaxAmount != null ? Decimal.valueOf(cartItem.CartItem.TaxRates[1].TaxAmount) / 100 : cartItem.CartItem.TaxRates[1].TaxAmount; Decimal taxRefundPercentage = cartItem.CartItem.TaxRates[1].TaxRate != null ? Decimal.valueOf(cartItem.CartItem.TaxRates[1].TaxRate) / 100 : cartItem.CartItem.TaxRates[1].TaxRate;
                                                            invoiceItem.InvoiceLine_Tax_Refund_Amount__c = taxRefundValue;
                                                            invoiceItem.Tax_Refund_Percentage_Applied__c = taxRefundPercentage;
                                                            taxResults.setTax(taxValue);
                                                            taxResults.setRate(Double.valueof(cartItem.CartItem.TaxRates[0].TaxRate) / 100);
                                                            taxResults.setId(invoiceItem.Id);
                                                            taxResults.setIsSuccess(cartItem.CartItem.TaxRates[0].TaxAmount != null);
                                                            taxResultsByIds.put(invoiceItem.Id, taxResults);
                                                            ////invoiceItem.Tax_Exempt_SAP__c = false;
                                                            if(cartItem.CartItem.TaxRates[1].TaxRate != null){
                                                                invoiceItem.SAP_Secondary_Tax_Rate__c = String.valueOf(((Double)cartItem.CartItem.TaxRates[1].TaxRate) / 100) + '%'; //Added By Rajesh Kumar - 30-11-2020 on Bk-11310
                                                                dSecondaryTaxRate = ((Double)cartItem.CartItem.TaxRates[1].TaxRate)/100 ;  } else { dSecondaryTaxRate = cartItem.CartItem.TaxRates[1].TaxRate; } lstUpdateinvoiceLines.add(invoiceItem);
                                                        }
                                                    } else {
                                                        if (string.valueOf(taxValue) == null || string.valueOf(taxValue) == '') {
                                                            taxResults.setTax(0.00);
                                                            taxResults.setRate(0.00);
                                                            taxResults.setId(invoiceItem.Id);
                                                            taxResults.setIsSuccess(true);
                                                            taxResultsByIds.put(invoiceItem.Id, taxResults);
                                                            //invoiceItem.Tax_Exempt_SAP__c = true;
                                                            lstUpdateinvoiceLines.add(invoiceItem);
                                                        }  else {
                                                            taxResults.setTax(taxValue);
                                                            taxResults.setRate(Double.valueof(cartItem.CartItem.TaxRates[0].TaxRate) / 100);
                                                            taxResults.setId(invoiceItem.Id);
                                                            taxResults.setIsSuccess(cartItem.CartItem.TaxRates[0].TaxAmount != null);
                                                            taxResultsByIds.put(invoiceItem.Id, taxResults);
                                                            //invoiceItem.Tax_Exempt_SAP__c = false;
                                                            lstUpdateinvoiceLines.add(invoiceItem);
                                                        }
                                                    }
                                                }
                                                //Added Logic for Tax Exempt Functionality.. By Rajesh Kumar - 02-12-2020 - BK-11323
                                                invoiceItem.Tax_Exempt_SAP__c =  new TaxExemptSAP().TaxExemptSAP(cartItem.cartItem.TAXCODE, cartItem.cartItem.TAXCOUNTRY,dPrimaryTaxRate, dSecondaryTaxRate);
                                            }
                                        }
                                    }
                                }*/
                            }
                        }
                        if (lstUpdateinvoiceLines.size() > 0) { update lstUpdateinvoiceLines;
                        }
                    } else {
                        String errorString = '';
                        for (CalculateTaxResponse.Message message : response.Messages) { errorString = errorString + 'Error from integration server occurred: [' + message.MessageType + ' ' + message.MessageText + '] ';
                        }
                        taxResultsByIds.putAll(logErrors(invoiceLines, 'ERROR Returned from Tax Source', errorString + ' RAW: ' + response.Messages));
                    }
                } catch (Exception eek) {
                    taxResultsByIds.putall(logErrors(invoiceLines, eek.getMessage(), eek.getStackTraceString()));
                }
            }
        }
        return taxResultsByIds;
    }

    private Map < Id, blng.TaxResults > logErrors(List < blng__InvoiceLine__c > invoiceLines, String errorString, String moreDetailedString) {
        Id orderId;
        Map < Id, blng.TaxResults > taxResultsByIds = new Map < Id, blng.TaxResults > ();
        for (blng__InvoiceLine__c invoiceLine : invoiceLines) {
            blng.TaxResults taxResults = new blng.TaxResults();
            taxResults.setIsSuccess(false);
            taxResults.setDetails(moreDetailedString);
            taxResults.setSummary(errorString);
            taxResults.setId(invoiceLine.Id);
            taxResults.setTax(0.00);
            orderId = invoiceLine.blng__Invoice__r.blng__Order__c;
            taxResultsByIds.put(invoiceLine.Id, taxResults);
        }
        insert new Error_Log__c(Service_Source__c = 'Integration', Source_Name__c = INTEGRATION_SERVICE_NAME, Description__c = errorString + ' ' + moreDetailedString + ' **** tax results: ' + taxResultsByIds, Affected_Object__c = orderId);
        return taxResultsByIds;
    }

    /**
     * Database interface for the InvoiceLine Service.
     */
    public interface RemoteTaxInvoiceLineDatabaseInterface {
        List < blng__InvoiceLine__c > queryInvoiceLinesByLegalEntityReference(List < String > legalEntityReferences);
        Map < Id, Contact > queryBillingContactsByIds(List < Id > orderIds);
        List < Account_Legal_Entity__c > queryAccountLegalEntitiesByAccountIdAndLegalEntityId(Id accountId, Set < Id > legalEntitySet);
    }

    /**
     * Default database interface for the InvoiceLineService.
     */
    //Modified by Avinash : GGCW-2736
    public class RemoteTaxInvoiceLineDatabaseDefaultImpl implements RemoteTaxInvoiceLineService.RemoteTaxInvoiceLineDatabaseInterface {

        public List < blng__InvoiceLine__c > queryInvoiceLinesByLegalEntityReference(List < String > legalEntityReferences) {
            return [
                       SELECT Id, blng__Invoice__r.blng__Order__c, blng__Invoice__r.blng__Order__r.ShipToContact.FirstName, blng__Invoice__r.Tax_Refund_SAP__c, blng__Invoice__r.blng__Order__r.Tax_Rule_SAP__c, blng__Invoice__r.blng__Order__r.ShipToContact.LastName, blng__Invoice__r.blng__Order__r.ShipToContact.Email,
                       blng__Invoice__r.blng__Order__r.ShippingStreet, blng__Invoice__r.blng__Order__r.ShippingCity,
                       blng__Invoice__r.blng__Order__r.ShippingState, blng__Invoice__r.blng__Order__r.ShippingPostalCode,
                       blng__Invoice__r.blng__Order__r.ShippingCountry, blng__Invoice__r.blng__Order__r.Opportunity.Parent_Opportunity__c,
                       blng__Invoice__r.blng__Order__r.BillToContact.FirstName, blng__Invoice__r.blng__Order__r.BillToContact.LastName,
                       blng__Invoice__r.blng__Order__r.BillToContact.Email, blng__Invoice__r.blng__Order__r.BillingStreet, blng__Invoice__r.Parent_Opp_Invoice__r.blng__Subtotal__c, blng__Invoice__r.Parent_Opp_Invoice__c,
                       blng__Invoice__r.blng__Order__r.BillingCity, blng__Invoice__r.blng__Order__r.BillingState,
                       blng__Invoice__r.blng__Order__r.BillingPostalCode, blng__Invoice__r.blng__Order__r.BillingCountry,
                       blng__Subtotal__c, blng__Quantity__c, SAP_Tax_Product__c, blng__OrderProduct__r.OrderItemNumber,

                       blng__Product__c, blng__Product__r.ProductCode, blng__Product__r.Family, blng__Product__r.Event_Product_Type__c, blng__Product__r.Tax_Category__c, CurrencyIsoCode, blng__LegalEntity__c, blng__Invoice__r.blng__Account__c, blng__Invoice__r.Billing_Invoice_Account__c, SAP_Tax_Code__c ,SAP_Tax_Country__c , SAP_Primary_Tax_Rate__c,SAP_Secondary_Tax_Rate__c

                       FROM blng__InvoiceLine__c
                       WHERE blng__LegalEntityReference__c IN: legalEntityReferences
                   ];
        }
        public Map < Id, Contact > queryBillingContactsByIds(List < Id > orderIds) {return InvoiceUtilities.retrieveBillingContact(orderIds);}  public List < Account_Legal_Entity__c > queryAccountLegalEntitiesByAccountIdAndLegalEntityId(Id accountId, Set < Id > legalEntitySet) {
            return [SELECT Id, Account__c, Legal_Entity__c, Business_Partner_Number__c FROM Account_Legal_Entity__c WHERE Account__c = : accountId AND Legal_Entity__c IN: legalEntitySet];
        }
    }
}