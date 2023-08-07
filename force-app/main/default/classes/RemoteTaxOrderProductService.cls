/**
 * Integration point to call out to the tax service for the instance on an OrderProduct
 * History :
 * 31/10/2018 : Modified by Avinash for Jira Ticket GGCW-2736
 * 13/11/2018 : Modified by Avinash for Jira Ticket GGCW-2736
 * 13/11/2018 : Modified by Avinash for Jira Ticket GGCW-2431 -- GRQ0006244: Tax call should be made only if the Customer Create is Success.
 * 17/02/2020 : Modified by Avinash for Jira Ticket BK-3244(Tax exempt to be made false in case we have Tax returned from SAOP), Increased test class coverage to 94%
  * @param
 * @description TEST Class ::: RemoteTaxOrderProductServiceTest(94%)
*/

public with sharing class RemoteTaxOrderProductService extends RemoteTaxAbstractService implements RemoteTaxService {
    private RemoteTaxOrderProductServiceDatabaseInterface databaseInterface;
    public RemoteTaxOrderProductService() {databaseInterface = new RemoteTaxOrderProductDatabaseDefaultImpl();}
    public RemoteTaxOrderProductService(RemoteTaxOrderProductServiceDatabaseInterface altInterface) {
        databaseInterface = altInterface;
    }
    public Map < Id, blng.TaxResults > getTax(List < String > listOfLegalEntityReferences) {
        List < OrderItem > orderItems = new List < OrderItem > ();
        if (listOfLegalEntityReferences != null) {
            orderItems = databaseInterface.queryOrderItemsByLegalEntityReference(listOfLegalEntityReferences);
        }
        String businessProcessNumber = '';
        List < Id > orderIds = new List < Id > ();
        for (OrderItem orderItem : orderItems) {
            orderIds.add(orderItem.OrderId);
        }
        Map < Id, Contact > contactsByOrderIds = databaseInterface.queryBillingContactsByIds(orderIds);
        if (orderItems != null && orderItems.size() > 0) {
            Id accountId = contactsByOrderIds.get(orderItems.get(0).OrderId).AccountId;
            Id legalEntityId = orderItems.get(0).blng__LegalEntity__c;
            List < Account_Legal_Entity__c > acctLegalEntities = databaseInterface.queryAccountLegalEntitiesByAccountIdAndLegalEntityId(accountId, new Set < Id > { legalEntityId });
            businessProcessNumber = acctLegalEntities != null && acctLegalEntities.size() > 0 ? acctLegalEntities.get(0).Business_Partner_Number__c : '';
        }
        return calculateTax(orderItems, contactsByOrderIds, businessProcessNumber);
    }

    public Map < Id, blng.TaxResults > postTax(List < String > listOfLegalEntityReferences) {
        return new Map < Id, blng.TaxResults > ();
    }
    public Map < Id, blng.TaxResults > cancelTax(List < String > listOfLegalEntityReferences) {
        return new Map < Id, blng.TaxResults > ();
    }
    public Map < Id, blng.TaxResults > calculateTax(List < OrderItem > orderItems, Map < Id, Contact > contactsByOrderIds, String businessProcessNumber) {
        Map < Id, blng.TaxResults > taxResultsByIds = new Map < Id, blng.TaxResults > ();
        List < OrderItem > lstOrderItem = new List < OrderItem > ();
        Double dPrimaryTaxRate;
        Double dSecondaryTaxRate;
        if (orderItems != null && orderItems.size() > 0) {
            Integer counter = 0;
            while (counter < orderItems.size()) {
                if (orderItems.get(counter).blng__LegalEntity__c == null) {
                    blng.TaxResults taxResults = new blng.TaxResults();
                    taxResults.setIsSuccess(false);
                    taxResults.setSummary(MISSING_LEGAL_ENTITY);
                    taxResults.setId(orderItems.get(counter).Id);
                    taxResults.setTax(0.00);
                    taxResultsByIds.put(orderItems.get(counter).Id, taxResults);
                    orderItems.remove(counter);
                } else {
                    counter++;
                }
            }

            if (orderItems.size() > 0) {
                try {
                    CalculateTaxRequest request = new CalculateTaxRequest(orderItems, contactsByOrderIds, contactsByOrderIds, businessProcessNumber);
                    CalculateTaxResponse response = makeOutboundCall(request);
                    if (response.Header != null && (String.isBlank(response.Header.Systems.MessageStatus) || response.Header.Systems.MessageStatus == 'OK' || response.Header.Systems.MessageStatus == 'UPDATED')) {
                        List < CalculateTaxResponse.CartItems > cartItems = response.Content.Transaction_x.CartItems;
                        for (CalculateTaxResponse.CartItems cartItem : cartItems) {
                            for (OrderItem orderItem : orderItems) {
                                // 17/02/2020 : Modified by Avinash for Jira Ticket BK-3244, Comparing only the orderItemNumber from SAP to that of in Salesforce OLI
                                if (orderItem != null && cartItem.cartItem.LineNumber == orderItem.OrderItemNumber && orderItem.SBQQ__TotalAmount__c != null && !taxResultsByIds.containsKey(orderItem.Id)) {
                                    blng.TaxResults taxResults = new blng.TaxResults();
                                    //Added By Rajesh Kumar : 03-09-2020 on BK-6918
                                    orderItem.SAP_Tax_Code__c  = cartItem.cartItem.TAXCODE;
                                    orderItem.SAP_Tax_Country__c  = cartItem.cartItem.TAXCOUNTRY;
                                    
                                    //Updated for Tax Refund Amount
                                    //Modified 02/04/2019 : GRQ0279622
                                    if (cartItem.CartItem.TaxRates.size() >= 1) {
                                        Decimal taxValue = cartItem.CartItem.TaxRates[0].TaxAmount != null ? Decimal.valueOf(cartItem.CartItem.TaxRates[0].TaxAmount) / 100 : cartItem.CartItem.TaxRates[0].TaxAmount;
                                        //Added By Rajesh Kumar : 30-11-2020 on BK-11310
                                        if(cartItem.CartItem.TaxRates[0].TaxRate != null){
                                            orderItem.SAP_Primary_Tax_Rate__c = String.valueOf(((Double) cartItem.CartItem.TaxRates[0].TaxRate)/100) + '%';
                                            dPrimaryTaxRate = ((Double) cartItem.CartItem.TaxRates[0].TaxRate) /100 ;   } else {dPrimaryTaxRate = cartItem.CartItem.TaxRates[0].TaxRate; }

                                        if (cartItem.CartItem.TaxRates.size() >= 2) {
                                            if (cartItem.CartItem.TaxRates[1].TaxRate > 0) {
                                                taxResults.setTax(Decimal.valueOf(cartItem.CartItem.Tax) / 100);
                                                taxResults.setRate(Double.valueof(cartItem.CartItem.TaxRates[0].TaxRate) / 100);
                                                taxResults.setId(orderItem.Id);
                                                taxResults.setIsSuccess(cartItem.CartItem.Tax != null);
                                                taxResultsByIds.put(orderItem.Id, taxResults);
                                                //orderItem.Tax_Exempt_SAP__c = false;
                                                if(cartItem.CartItem.TaxRates[1].TaxRate != null){
                                                    orderItem.SAP_Secondary_Tax_Rate__c = String.valueOf(((Double)cartItem.CartItem.TaxRates[1].TaxRate)/100) + '%';  //Added By Rajesh Kumar : 30-11-2020 on BK-11310
                                                    dSecondaryTaxRate = ((Double)cartItem.CartItem.TaxRates[1].TaxRate)/100 ; } else { dSecondaryTaxRate = cartItem.CartItem.TaxRates[1].TaxRate; }
                                                lstOrderItem.add(orderItem);

                                            } else if (cartItem.CartItem.TaxRates[1].TaxRate < 0) {
                                                Decimal taxRefundValue = cartItem.CartItem.TaxRates[1].TaxAmount != null ? Decimal.valueOf(cartItem.CartItem.TaxRates[1].TaxAmount) / 100 : cartItem.CartItem.TaxRates[1].TaxAmount;
                                                Decimal taxRefundPercentage = cartItem.CartItem.TaxRates[1].TaxRate != null ? Decimal.valueOf(cartItem.CartItem.TaxRates[1].TaxRate) / 100 : cartItem.CartItem.TaxRates[1].TaxRate;
                                                orderItem.Tax_Refund_Amount__c = taxRefundValue;
                                                orderItem.Tax_Refund_Percentage_Applied__c = taxRefundPercentage;
                                                
                                                taxResults.setTax(taxValue);
                                                taxResults.setRate(Double.valueof(cartItem.CartItem.TaxRates[0].TaxRate) / 100);
                                                taxResults.setId(orderItem.Id);
                                                taxResults.setIsSuccess(cartItem.CartItem.TaxRates[0].TaxAmount != null);
                                                taxResultsByIds.put(orderItem.Id, taxResults);
                                                //orderItem.Tax_Exempt_SAP__c = false;
                                                if(cartItem.CartItem.TaxRates[1].TaxRate != null){
                                                    orderItem.SAP_Secondary_Tax_Rate__c = String.valueOf(((Double)cartItem.CartItem.TaxRates[1].TaxRate)/100) + '%';  //Added By Rajesh Kumar : 30-11-2020 on BK-11310
                                                    dSecondaryTaxRate = ((Double)cartItem.CartItem.TaxRates[1].TaxRate) /100 ; } else { dSecondaryTaxRate = cartItem.CartItem.TaxRates[1].TaxRate; }
                                                lstOrderItem.add(orderItem);
                                            }
                                        } else {
                                            if (string.valueOf(taxValue) == null || string.valueOf(taxValue) == '') {
                                                taxResults.setTax(0.00);
                                                taxResults.setRate(0.00);
                                                taxResults.setId(orderItem.Id);
                                                taxResults.setIsSuccess(true);
                                                taxResultsByIds.put(orderItem.Id, taxResults);
                                                //orderItem.Tax_Exempt_SAP__c = true;
                                                lstOrderItem.add(orderItem);
                                            } else {
                                                taxResults.setTax(taxValue);
                                                taxResults.setRate(Double.valueof(cartItem.CartItem.TaxRates[0].TaxRate) / 100);
                                                taxResults.setId(orderItem.Id);
                                                taxResults.setIsSuccess(cartItem.CartItem.TaxRates[0].TaxAmount != null);
                                                taxResultsByIds.put(orderItem.Id, taxResults);
                                                //orderItem.Tax_Exempt_SAP__c = false;
                                                lstOrderItem.add(orderItem);
                                            }
                                        }
                                    }
                                    //Added Logic for Tax Exempt Functionality.. By Rajesh Kumar - 02-12-2020 - BK-11323
                                    // Modified by Palla Kishore for the ticket BK-19606
                                    orderItem.Tax_Exempt_SAP__c =  new TaxExemptSAP().TaxExempt(cartItem.cartItem.TAXCODE, cartItem.cartItem.TAXCOUNTRY,dPrimaryTaxRate, dSecondaryTaxRate);
                                    //lstOrderItem.add(orderItem);
                                }
                                //Modified by Avinash : GGCW-2736
                                /*else if ((orderItem.Order.Opportunity.Parent_Opportunity__c != NULL && orderItem.Order.Opportunity.Parent_Opportunity__r.Tax_Scenario__c == 'UK Exhibitor VAT Invoicing') || Test.isRunningTest())  {
                                    if (orderItem.SAP_Tax_Product__c || Test.isRunningTest()) {
                                        if (orderItem.Order.Parent_Opp_Order__c != NULL || Test.isRunningTest()) {
                                            // 17/02/2020 : Modified by Avinash for Jira Ticket BK-3244, Comparing only the orderItemNumber from SAP to that of in Salesforce OLI
                                            // Also added condition for TAX Exempt to be unchecked If tax is returned by SAP for OLIs
                                            if ((orderItem != null && cartItem.cartItem.LineNumber == orderItem.OrderItemNumber && orderItem.SBQQ__TotalAmount__c != null && !taxResultsByIds.containsKey(orderItem.Id)) ||  Test.isRunningTest()) {
                                                blng.TaxResults taxResults = new blng.TaxResults();
                                                 //Added By Rajesh Kumar : 03-09-2020 on BK-6918
                                                orderItem.SAP_Tax_Code__c  = cartItem.cartItem.TAXCODE;
                                                orderItem.SAP_Tax_Country__c  = cartItem.cartItem.TAXCOUNTRY;
                                                
                                                if (cartItem.CartItem.TaxRates.size() >= 1) {
                                                    Decimal taxValue = cartItem.CartItem.TaxRates[0].TaxAmount != null ? Decimal.valueOf(cartItem.CartItem.TaxRates[0].TaxAmount) / 100 : cartItem.CartItem.TaxRates[0].TaxAmount;
                                                    if(cartItem.CartItem.TaxRates[0].TaxRate != null){
                                                        orderItem.SAP_Primary_Tax_Rate__c = String.valueOf(((Double)cartItem.CartItem.TaxRates[0].TaxRate)/100) + '%';  //Added By Rajesh Kumar : 30-11-2020 on BK-11310
                                                        dPrimaryTaxRate = ((Double) cartItem.CartItem.TaxRates[0].TaxRate) /100 ;
                                                    }
                                                    else {
                                                        dPrimaryTaxRate = cartItem.CartItem.TaxRates[0].TaxRate;
                                                    }
                                                    if (cartItem.CartItem.TaxRates.size() >= 2) {
                                                        if (cartItem.CartItem.TaxRates[1].TaxRate > 0) {
                                                            taxResults.setTax(Decimal.valueOf(cartItem.CartItem.Tax) / 100);
                                                            taxResults.setRate(Double.valueof(cartItem.CartItem.TaxRates[0].TaxRate) / 100);
                                                            taxResults.setId(orderItem.Id);
                                                            taxResults.setIsSuccess(cartItem.CartItem.Tax != null);
                                                            taxResultsByIds.put(orderItem.Id, taxResults);
                                                            //orderItem.Tax_Exempt_SAP__c = false;
                                                            if(cartItem.CartItem.TaxRates[1].TaxRate != null){
                                                                orderItem.SAP_Secondary_Tax_Rate__c = String.valueOf(((Double)cartItem.CartItem.TaxRates[1].TaxRate)/100) + '%';  //Added By Rajesh Kumar : 30-11-2020 on BK-11310
                                                                dSecondaryTaxRate = ((Double)cartItem.CartItem.TaxRates[1].TaxRate) /100 ;
                                                            }
                                                            else {
                                                                dSecondaryTaxRate = cartItem.CartItem.TaxRates[1].TaxRate;
                                                            }
                                                            lstOrderItem.add(orderItem);

                                                        } else if (cartItem.CartItem.TaxRates[1].TaxRate < 0) {
                                                            Decimal taxRefundValue = cartItem.CartItem.TaxRates[1].TaxAmount != null ? Decimal.valueOf(cartItem.CartItem.TaxRates[1].TaxAmount) / 100 : cartItem.CartItem.TaxRates[1].TaxAmount;
                                                            Decimal taxRefundPercentage = cartItem.CartItem.TaxRates[1].TaxRate != null ? Decimal.valueOf(cartItem.CartItem.TaxRates[1].TaxRate) / 100 : cartItem.CartItem.TaxRates[1].TaxRate;
                                                            orderItem.Tax_Refund_Amount__c = taxRefundValue;
                                                            orderItem.Tax_Refund_Percentage_Applied__c = taxRefundPercentage;
                                                            taxResults.setTax(taxValue);
                                                            taxResults.setRate(Double.valueof(cartItem.CartItem.TaxRates[0].TaxRate) / 100);
                                                            taxResults.setId(orderItem.Id);
                                                            taxResults.setIsSuccess(cartItem.CartItem.TaxRates[0].TaxAmount != null);
                                                            taxResultsByIds.put(orderItem.Id, taxResults);
                                                            //orderItem.Tax_Exempt_SAP__c = false;
                                                            if(cartItem.CartItem.TaxRates[1].TaxRate != null){
                                                                orderItem.SAP_Secondary_Tax_Rate__c = String.valueOf(((Double)cartItem.CartItem.TaxRates[1].TaxRate)/100) + '%';  //Added By Rajesh Kumar : 30-11-2020 on BK-11310
                                                                dSecondaryTaxRate = ((Double)cartItem.CartItem.TaxRates[1].TaxRate) /100 ;
                                                            }
                                                            else {
                                                                dSecondaryTaxRate = cartItem.CartItem.TaxRates[1].TaxRate;
                                                            }
                                                            lstOrderItem.add(orderItem);
                                                        }
                                                    } else {
                                                        if (string.valueOf(taxValue) == null || string.valueOf(taxValue) == '') {
                                                            taxResults.setTax(0.00);
                                                            taxResults.setRate(0.00);
                                                            taxResults.setId(orderItem.Id);
                                                            taxResults.setIsSuccess(true);
                                                            taxResultsByIds.put(orderItem.Id, taxResults);
                                                            //orderItem.Tax_Exempt_SAP__c = true;
                                                            lstOrderItem.add(orderItem);
                                                        } else {
                                                            taxResults.setTax(taxValue);
                                                            taxResults.setRate(Double.valueof(cartItem.CartItem.TaxRates[0].TaxRate) / 100);
                                                            taxResults.setId(orderItem.Id);
                                                            taxResults.setIsSuccess(cartItem.CartItem.TaxRates[0].TaxAmount != null);
                                                            taxResultsByIds.put(orderItem.Id, taxResults);
                                                            //orderItem.Tax_Exempt_SAP__c = false;
                                                            lstOrderItem.add(orderItem);
                                                        }
                                                    }
                                                }
                                                //Added Logic for Tax Exempt Functionality.. By Rajesh Kumar - 02-12-2020 - BK-11323
                                                orderItem.Tax_Exempt_SAP__c =  new TaxExemptSAP().TaxExemptSAP(cartItem.cartItem.TAXCODE, cartItem.cartItem.TAXCOUNTRY,dPrimaryTaxRate, dSecondaryTaxRate);
                                                //lstOrderItem.add(orderItem);
                                            }
                                        }
                                    }
                                } */

                            }
                        }
                        if (lstOrderItem.size() > 0) {
                            upsert lstOrderItem;
                        }
                    } else {
                        String errorString = '';
                        for (CalculateTaxResponse.Message message : response.Messages) {
                            errorString = errorString + 'Error from integration server occurred: [' + message.MessageType + ' ' + message.MessageText + '] ';
                        }
                        taxResultsByIds.putAll(logErrors(orderItems, 'ERROR Returned from Tax Source', errorString));
                    }
                } catch (Exception eek) {
                    System.debug('EXCEPTION ERROR ::: ' + eek);
                    taxResultsByIds.putAll(logErrors(orderItems, eek.getMessage(), eek.getStackTraceString()));
                }
            }
        }
        return taxResultsByIds;
    }
    private Map < Id, blng.TaxResults > logErrors(List < OrderItem > orderItems, String errorString, String moreDetailedString) {
        Map < Id, blng.TaxResults > taxResultsByIds = new Map < Id, blng.TaxResults > ();
        Id orderId;
        for (OrderItem orderItem : orderItems) {
            blng.TaxResults taxResults = new blng.TaxResults();
            taxResults.setIsSuccess(false);
            taxResults.setDetails(moreDetailedString);
            taxResults.setSummary(errorString);
            taxResults.setId(orderItem.Id);
            taxResults.setTax(0.00);
            orderId = orderItem.OrderId;
            taxResultsByIds.put(orderItem.Id, taxResults);
        }
        insert new Error_Log__c(Service_Source__c = 'Integration', Source_Name__c = INTEGRATION_SERVICE_NAME, Description__c = errorString + ' ' + moreDetailedString + ' **** tax results: ' + taxResultsByIds, Affected_Object__c = orderId);
        return taxResultsByIds;
    }

    /**
     * Interface for the database/system interactions.
     */
    public interface RemoteTaxOrderProductServiceDatabaseInterface {
        List < OrderItem > queryOrderItemsByLegalEntityReference(List < String > legalEntityReferences);
        Map < Id, Contact > queryBillingContactsByIds(List < Id > orderIds);
        List < Account_Legal_Entity__c > queryAccountLegalEntitiesByAccountIdAndLegalEntityId(Id accountId, Set < Id > legalEntitySet);
    }
    /**
     * Default database interface for the RemoteTaxOrderProductService.
     */
    //Modified by Avinash : GGCW-2736
    //Modified by Avinash : GGCW-2431 -- Adding conditon to make tax calls only when BP NUmber and Create Custom is success for Order.
    public class RemoteTaxOrderProductDatabaseDefaultImpl implements RemoteTaxOrderProductServiceDatabaseInterface {
        public List < OrderItem > queryOrderItemsByLegalEntityReference(List < String > legalEntityReferences) {
            System.debug('Getting Called');
            return [
                       SELECT Id, OrderId, Order.Tax_Rule_SAP__c, Order.ShipToContact.FirstName, Order.ShipToContact.LastName, Order.ShipToContact.Email,
                       Order.ShippingStreet, Order.ShippingCity, Order.ShippingState, Order.ShippingPostalCode, Order.ShippingCountry, Order.BillToContact.FirstName, Order.BillToContact.LastName, Order.BillToContact.Email,
                       Order.BillingStreet, Order.Opportunity.Parent_Opportunity__c,
                       Order.BillingCity, Order.BillingState, Order.BillingPostalCode, Order.BillingCountry,
                       Order.AccountId, SAP_Tax_Product__c, Order.Parent_Opp_Order__c, Order.Parent_Opp_Order__r.TotalAmount,
                       SBQQ__TotalAmount__c, Quantity, TotalPrice, blng__BilledAmountwithouttax__c,
                       Product2Id, Product2.ProductCode, OrderItemNumber, Product2.Family, Product2.Event_Product_Type__c,

                       Product2.Tax_Category__c, CurrencyIsoCode, blng__LegalEntity__c, blng__BillingAccount__c,SAP_Tax_Code__c ,SAP_Tax_Country__c,SAP_Primary_Tax_Rate__c,SAP_Secondary_Tax_Rate__c 

                       FROM OrderItem
                       WHERE blng__LegalEntityReference__c IN: legalEntityReferences AND Order.SAP_BP_Number__c != NULL AND Order.Create_Customer_Result__c = 'SUCCESS'
                   ];
        }

        public Map < Id, Contact > queryBillingContactsByIds(List < Id > orderIds) {
            return InvoiceUtilities.retrieveBillingContact(orderIds);
        }

        public List < Account_Legal_Entity__c > queryAccountLegalEntitiesByAccountIdAndLegalEntityId(Id accountId, Set < Id > legalEntitySet) {
            return [SELECT Id, Account__c, Legal_Entity__c, Business_Partner_Number__c FROM Account_Legal_Entity__c WHERE Account__c = : accountId AND Legal_Entity__c IN: legalEntitySet];
        }
    }
}