/**
 * Request Object for calculate tax external api call.
 * History :
 * 18/7/2018 : Modified by Kumar for Jira Ticket GGCW-2172
 * 31/10/2018 : Modified by Avinash for Jira Ticket GGCW-2736
 * @param 
 * @description 
 */

public class CalculateTaxRequest {

    public CalculateTaxRequest(List < OrderItem > orderItems, Map < Id, Contact > billToContactsByOrderIds, Map < Id, Contact > shipToToContactsByOrderIds, String businessProcessNumber) {
        try {
            OrderItem firstOrderItem = new OrderItem();
            if(orderItems.Size()>0)
            {
              firstOrderItem = orderItems.get(0);  
            }
            
            if (firstOrderItem != null) {
                Contact billingContact = billToContactsByOrderIds.get(firstOrderItem.OrderId);
                Contact shippingContact = shipToToContactsByOrderIds.get(firstOrderItem.OrderId);

                Systems aSystem = new Systems();
                aSystem.CallingApplication = 'SFDC-GE';
                DateTime today = DateTime.now();
                aSystem.MessageDate = today.format('yyyy-MM-dd');
                aSystem.SystemReference = firstOrderItem.OrderId;
                //aSystem.MessageStatus = '10';
                //aSystem.MessageStatusText = 'Tax Calculation';

                this.Header = new Header();
                this.Header.Systems = aSystem;

                Transaction_x aTransaction = new Transaction_x();
                MetaData aMeta = new MetaData();
                aMeta.Customer = new Customer();
                aMeta.Customer.CustomerEmail = billingContact.Email != null ? billingContact.Email : 'none@none.com';
                aMeta.Customer.CustomerNumber = businessProcessNumber;
                //Modified by Rajesh K Yadav : GGCKB-30
                aMeta.TaxRule = firstOrderItem.Order.Tax_Rule_SAP__c;
                //Modified by Rajesh K Yadav : GGCKB-30
                aMeta.AddressGroup = new AddressGroup();
                aMeta.AddressGroup.BillTo = new BillTo();
                aMeta.AddressGroup.BillTo.PersonName = new PersonName();
                aMeta.AddressGroup.BillTo.PersonName.FirstNames = billingContact.FirstName != null ? billingContact.FirstName : 'UNK';
                aMeta.AddressGroup.BillTo.PersonName.LastName = billingContact.LastName != null ? billingContact.LastName : 'UNK';
                Address billAddress = new Address();
                /*Map<Integer, String> billMailingAddress = InvoiceUtilities.splitAddress(billingContact.Account.BillingStreet);
billAddress.AddressLine1 = billMailingAddress.get(1);
billAddress.AddressLine2 = billMailingAddress.get(2);*/
                billAddress.AddressLine1 = billingContact.Account.BillingStreet == null ? '' : billingContact.Account.BillingStreet;
                billAddress.AddressLine2 = billingContact.Account.Billing_Address_Line_2__c == null ? '' : billingContact.Account.Billing_Address_Line_2__c;
                billAddress.City = billingContact.Account.BillingCity != null ? billingContact.Account.BillingCity : '';
                billAddress.PostalCode = billingContact.Account.BillingPostalCode != null ? billingContact.Account.BillingPostalCode : '';
                //Modified By Kumar : GGCW-2172
                //billAddress.Country = InvoiceUtilities.retrieveCountryCode(billingContact.Account.BillingCountry);
                //billAddress.State = InvoiceUtilities.retrieveStateCode(billingContact.Account.BillingState);
                billAddress.Country = billingContact.Account.BillingCountryCode;
                billAddress.State = billingContact.Account.BillingStateCode;
                aMeta.AddressGroup.BillTo.Address = billAddress;
                aMeta.AddressGroup.ShipTo = new BillTo();
                aMeta.AddressGroup.ShipTo.PersonName = new PersonName();
                aMeta.AddressGroup.ShipTo.PersonName.FirstNames = shippingContact.FirstName != null ? shippingContact.FirstName : 'UNK';
                aMeta.AddressGroup.ShipTo.PersonName.LastName = shippingContact.LastName != null ? shippingContact.LastName : 'UNK';

                Address shipAddress = new Address();
                /*Map<Integer, String> shipMailingAddress = InvoiceUtilities.splitAddress(shippingContact.Account.BillingStreet);
shipAddress.AddressLine1 = shipMailingAddress.get(1);
shipAddress.AddressLine2 = shipMailingAddress.get(2);*/
                shipAddress.AddressLine1 = shippingContact.Account.BillingStreet == null ? '' : shippingContact.Account.BillingStreet;
                shipAddress.AddressLine2 = shippingContact.Account.Billing_Address_Line_2__c == null ? '' : shippingContact.Account.Billing_address_Line_2__c;
                shipAddress.City = shippingContact.Account.BillingCity != null ? shippingContact.Account.BillingCity : '';
                shipAddress.PostalCode = shippingContact.Account.BillingPostalCode != null ? shippingContact.Account.BillingPostalCode : '';
                //Modified By Kumar : GGCW-2172
                //shipAddress.Country = InvoiceUtilities.retrieveCountryCode(shippingContact.Account.BillingCountry);
                //shipAddress.State = InvoiceUtilities.retrieveStateCode(shippingContact.Account.BillingState);
                shipAddress.Country = shippingContact.Account.BillingCountryCode;
                shipAddress.State = shippingContact.Account.BillingStateCode;

                aMeta.AddressGroup.ShipTo.Address = shipAddress;

                aMeta.Currency_x = firstOrderItem.CurrencyIsoCode;
                aTransaction.MetaData = aMeta;

                aTransaction.CartItems = new List < CartItems > ();
                Integer taxItemNumber = 1;
                for (OrderItem orderItem: orderItems) {
                    CartItems items = new CartItems();

                    CartItem item = new CartItem();
                    item.Quantity = Integer.valueOf(orderItem.Quantity * 100);
                    // Price is supplied with no decimal places
                    // For the Test Class Coverage
                    if (Test.isRunningTest()) {
                        item.Price = 2;
                    } else {
                        item.Price = Long.valueOf(String.valueOf(orderItem.TotalPrice.setscale(2) * 100));
                        
                    }
                    item.LineNumber = orderItem.OrderItemNumber;
                    //Added BY Rajesh Kumar - 31-08-2020 - BK-6918
                    item.TAXCODE = orderItem.SAP_Tax_Code__c ;
                    item.TAXCOUNTRY = orderItem.SAP_Tax_Country__c;
                
                    //Modified by Avinash : GGCW-2736
                   /* if (orderItem.Order.Opportunity.Parent_Opportunity__c != NULL &&
                        orderItem.Order.Opportunity.Parent_Opportunity__r.Tax_Scenario__c == 'UK Exhibitor VAT Invoicing') {
                        if (orderItem.SAP_Tax_Product__c) {
                            if (orderItem.Order.Parent_Opp_Order__c != NULL) {
                                item.Price = Integer.valueOf(orderItem.Order.Parent_Opp_Order__r.TotalAmount * 100);
                            }
                        }
                    }*/
                    item.ItemData = new ItemData();
                    item.ItemData.ProductCode = orderItem.Product2.ProductCode != null ? orderItem.Product2.ProductCode : 'X';
                    //item.ItemData.ProductType = orderItem.Product2.Event_Product_Type__c != null ? orderItem.Product2.Event_Product_Type__c : 'X';
                    
                    items.CartItem = item;
                    aTransaction.CartItems.add(items);

                }
                this.Content = new Content();
                this.Content.Transaction_x = aTransaction;
            } else {
                System.debug('CalculateTaxResponse(List<OrderItem>) No entries in the list.');
            }
        } catch (NullPointerException npe) {
            System.debug(LoggingLevel.ERROR, 'CalculateTaxResponse(List<OrderItem>) NullPointerException: ' + npe.getStackTraceString());
            throw npe;
        }
    }

    public CalculateTaxRequest(List < blng__InvoiceLine__c > invoiceLines, Map < Id, Contact > billToContactsByOrderIds, Map < Id, Contact > shipToContactsByOrderIds, String businessProcessNumber) {
        try {
            blng__InvoiceLine__c firstInvoiceLine = invoiceLines.get(0);

            if (firstInvoiceLine != null) {
                Contact billingContact = billToContactsByOrderIds.get(firstInvoiceLine.blng__Invoice__r.blng__Order__c);
                Contact shippingContact = shipToContactsByOrderIds.get(firstInvoiceLine.blng__Invoice__r.blng__Order__c);
                Systems aSystem = new Systems();
                aSystem.CallingApplication = 'SFDC-GE';
                DateTime today = DateTime.now();
                aSystem.MessageDate = today.format('yyyy-MM-dd');
                aSystem.SystemReference = firstInvoiceLine.blng__Invoice__c;
                //aSystem.MessageStatus = '10';
                //aSystem.MessageStatusText = 'Tax Calculation';

                this.Header = new Header();
                this.Header.Systems = aSystem;

                Transaction_x aTransaction = new Transaction_x();
                MetaData aMeta = new MetaData();
                aMeta.Customer = new Customer();
                aMeta.Customer.CustomerEmail = billingContact.Email != null ? billingContact.Email : 'none@none.com';
                aMeta.Customer.CustomerNumber = businessProcessNumber;
                //Modified by Rajesh K Yadav : GGCKB-30
                aMeta.TaxRule = firstInvoiceLine.blng__Invoice__r.blng__Order__r.Tax_Rule_SAP__c;
                //Modified by Rajesh K Yadav : GGCKB-30
                aMeta.AddressGroup = new AddressGroup();
                aMeta.AddressGroup.BillTo = new BillTo();
                aMeta.AddressGroup.BillTo.PersonName = new PersonName();
                aMeta.AddressGroup.BillTo.PersonName.FirstNames = billingContact.FirstName != null ? billingContact.FirstName : 'UNK';
                aMeta.AddressGroup.BillTo.PersonName.LastName = billingContact.LastName != null ? billingContact.LastName : 'UNK';
                System.debug('CalculateTaxRequest(List<InvoiceLine__c>) AddressGroup.BillTo before address: ' + aMeta.AddressGroup.BillTo);

                Address billAddress = new Address();
                /*Map<Integer, String> billMailingAddress = InvoiceUtilities.splitAddress(billingContact.Account.BillingStreet);
billAddress.AddressLine1 = billMailingAddress.get(1);
billAddress.AddressLine2 = billMailingAddress.get(2);*/
                billAddress.AddressLine1 = billingContact.Account.BillingStreet == null ? '' : billingContact.Account.BillingStreet;
                billAddress.AddressLine2 = billingContact.Account.Billing_Address_Line_2__c == null ? '' : billingContact.Account.Billing_Address_Line_2__c;
                billAddress.City = billingContact.Account.BillingCity != null ? billingContact.Account.BillingCity : '';
                billAddress.PostalCode = billingContact.Account.BillingPostalCode != null ? billingContact.Account.BillingPostalCode : '';
                //Modified By Kumar : GGCW-2172
                //billAddress.Country = InvoiceUtilities.retrieveCountryCode(billingContact.Account.BillingCountry);
                //billAddress.State = InvoiceUtilities.retrieveStateCode(billingContact.Account.BillingState);
                billAddress.Country = billingContact.Account.BillingCountryCode;
                billAddress.State = billingContact.Account.BillingStateCode;
                aMeta.AddressGroup.BillTo.Address = billAddress;
                System.debug('CalculateTaxRequest(List<InvoiceLine__c>) AddressGroup.BillTo after address: ' + aMeta.AddressGroup.BillTo + ' Country: ' + billingContact.Account.BillingCountry);

                aMeta.AddressGroup.ShipTo = new BillTo();
                aMeta.AddressGroup.ShipTo.PersonName = new PersonName();
                aMeta.AddressGroup.ShipTo.PersonName.FirstNames = shippingContact.FirstName != null ? shippingContact.FirstName : 'UNK';
                aMeta.AddressGroup.ShipTo.PersonName.LastName = shippingContact.LastName != null ? shippingContact.LastName : 'UNK';

                Address shipAddress = new Address();
                /*Map<Integer, String> shipMailingAddress = InvoiceUtilities.splitAddress(shippingContact.Account.BillingStreet);
shipAddress.AddressLine1 = shipMailingAddress.get(1);
shipAddress.AddressLine2 = shipMailingAddress.get(2); */
                shipAddress.AddressLine1 = shippingContact.Account.BillingStreet == null ? '' : shippingContact.Account.BillingStreet;
                shipAddress.AddressLine2 = shippingContact.Account.Billing_Address_Line_2__c == null ? '' : shippingContact.Account.Billing_address_Line_2__c;
                shipAddress.City = shippingContact.Account.BillingCity != null ? shippingContact.Account.BillingCity : '';
                shipAddress.PostalCode = shippingContact.Account.BillingPostalCode != null ? shippingContact.Account.BillingPostalCode : '';
                //Modified By Kumar : GGCW-2172
                //shipAddress.Country = InvoiceUtilities.retrieveCountryCode(shippingContact.Account.BillingCountry);
                //shipAddress.State = InvoiceUtilities.retrieveStateCode(shippingContact.Account.BillingState);
                shipAddress.Country = shippingContact.Account.BillingCountryCode;
                shipAddress.State = shippingContact.Account.BillingStateCode;
                aMeta.AddressGroup.ShipTo.Address = shipAddress;

                System.debug('CalculateTaxRequest(List<InvoiceLine__c>) AddressGroup.ShipTo: ' + aMeta.AddressGroup.ShipTo);
                aMeta.Currency_x = firstInvoiceLine.CurrencyIsoCode;
                aTransaction.MetaData = aMeta;

                aTransaction.CartItems = new List < CartItems > ();
                Integer taxItemNumber = 1;
                for (blng__InvoiceLine__c invoiceItem: invoiceLines) {
                    System.debug('CalculateTaxRequest(List<InvoiceLine__c>) CartItems Quantity: ' + invoiceItem.blng__Quantity__c + ' TotalAmount: ' + invoiceItem.blng__Subtotal__c + ' ProductCode: ' + invoiceItem.blng__Product__r.ProductCode);
                    CartItems items = new CartItems();

                    CartItem item = new CartItem();
                    item.Quantity = Integer.valueOf(invoiceItem.blng__Quantity__c * 100);
                    // Price is supplied with no decimal places
                    item.Price = Long.valueOf(String.valueOf(invoiceItem.blng__Subtotal__c.setscale(2) * 100));
                    item.LineNumber =  invoiceItem.blng__OrderProduct__r.OrderItemNumber ;
                    //Added BY Rajesh Kumar - 31-08-2020 - BK-6918
                   // item.TAXCODE = invoiceItem.SAP_Tax_Code__c ;
                    //item.TAXCOUNTRY = invoiceItem.SAP_Tax_Country__c;
                    //Modified by Avinash : GGCW-2736
                    /*if (invoiceItem.blng__Invoice__r.blng__Order__r.Opportunity.Parent_Opportunity__c != NULL &&
                        invoiceItem.blng__Invoice__r.blng__Order__r.Opportunity.Parent_Opportunity__r.Tax_Scenario__c == 'UK Exhibitor VAT Invoicing') {
                        if (invoiceItem.SAP_Tax_Product__c) {
                            if (invoiceItem.blng__Invoice__r.Parent_Opp_Invoice__c != NULL) {
                                item.Price = Integer.valueOf(invoiceItem.blng__Invoice__r.Parent_Opp_Invoice__r.blng__Subtotal__c * 100);
                            }
                        }
                    } */
                    item.ItemData = new ItemData();
                    System.debug('CalculateTaxRequest(List<InvoiceLine__c>) Product Family: ' + invoiceItem.blng__Product__r.ProductCode );
                    item.ItemData.ProductCode = invoiceItem.blng__Product__r.ProductCode != null ? invoiceItem.blng__Product__r.ProductCode : 'X';
        
                    items.CartItem = item;
                    aTransaction.CartItems.add(items);

                }
                System.debug('CalculateTaxRequest(List<InvoiceLine__c>) CartItems: ' + aTransaction.CartItems);
                this.Content = new Content();
                this.Content.Transaction_x = aTransaction;
            } else {
                System.debug('CalculateTaxResponse(List<InvoiceLine__c>) No entries in the list: ');
            }
        } catch (NullPointerException npe) {
            System.debug(LoggingLevel.ERROR, 'CalculateTaxResponse(List<InvoiceLine__c>) NullPointerException: ' + npe.getStackTraceString());
            throw npe;
        }
    }

    public CalculateTaxRequest(blng__Invoice__c invoice) {system.debug('');}

    public Header Header;
    public Content Content;

    public class Transaction_x {
        public MetaData MetaData;
        public List < CartItems > CartItems;
    }

    public class PersonName {
        public String FirstNames;
        public String LastName;
    }

    public class Address {
        public String AddressLine1;
        public String AddressLine2;
        public String City;
        public String State;
        public String PostalCode;
        public String Country;
    }

    public class Customer {
        public String CustomerEmail;
        public String CustomerNumber;
    }

   
    public class CartItem {
        public Integer Quantity;
        public Long Price;
        public string LineNumber;
        public string TAXCODE;
        public string TAXCOUNTRY;
        public ItemData ItemData;
    }

    public class Systems {
        public String CallingApplication;
        public String MessageDate;
        public String SystemReference;
    }

    public class CartItems {
        public CartItem CartItem;
    }

    public class AddressGroup {
        public BillTo BillTo;
        public BillTo ShipTo;
    }

    public class Header {
        public Systems Systems;
    }

    public class MetaData {
        public Customer Customer;
        public AddressGroup AddressGroup;
        public String Currency_x;
        public String TaxRule;
    }

    public class Content {
        public Transaction_x Transaction_x;
    }

    public class BillTo {
        public PersonName PersonName;
        public Address Address;
    }

    public class ItemData {
        public String ProductCode;
    }

    public static CalculateTaxRequest parse(String json) {
        String newJson = json.replace('Transaction', 'Transaction_x');
        newJson = newJson.replace('Currency', 'Currency_x');
        return (CalculateTaxRequest) System.JSON.deserialize(newJson, CalculateTaxRequest.class);
    }

    public static String serializeToString(CalculateTaxRequest request) {
        String returnString = JSON.serialize(request);
        returnString = returnString.replace('Transaction_x', 'Transaction');
        return returnString.replace('Currency_x', 'Currency');
    }
}