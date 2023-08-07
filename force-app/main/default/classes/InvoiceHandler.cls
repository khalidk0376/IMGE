/**
  * Class to handle the business logic that needs to happen from the InvoiceTrigger.
  * @description 
  * @param 
  * @return None
  * Modified by Rajesh Kumar yadav : https://informa-ge-sfdc.atlassian.net/browse/BK-2006 on 8/8/19.
 */

public with sharing class InvoiceHandler {


    /*public static void updateInvoiceTaxRateFields(List<blng__Invoice__c> invoices) {
        System.debug('InvoiceHandler.updateInvoiceTaxRateFields ' + invoices);
        for(blng__Invoice__c invoice: invoices) {
            if((invoice.UKEUorROW__c == 'UK' && invoice.CurrencyCode__c != 'GBP' && invoice.TaxRate__c == 20) ||
                    invoice.UKEUorROW__c == 'EU' && invoice.CurrencyCode__c != 'GBP' && invoice.TaxRate__c == 20 && String.isBlank(invoice.Customer_VAT_No__c)) {
                invoice.ShowUKEquivalent__c = true;  
                invoice.ShowGBPExchange__c = true;
            } else {
                invoice.ShowUKEquivalent__c = false;
                invoice.ShowGBPExchange__c = false;
            }
        }
    }*/

    /**
     * Update the credit transfer information on the invoice.
     * Update the VAT-Tax Footer Information
     * Stamp the Bill to contact on the invoice.
     *
     * @param invoices - a list of invoices
     *
     * @return
     */
    public static void updateFieldsOnInvoice(List<blng__Invoice__c> invoices)  {
        System.debug('InvoiceHandler.updateFieldsOnInvoice() ' + invoices);
        //List<blng__Invoice__c> updatedInvoices = new List<blng__Invoice__c>();

        Map<Id, Id> orderIdByInvoiceIdMap = new  Map<Id, Id>();
        for(blng__Invoice__c invoice: invoices) {
            orderIdByInvoiceIdMap.put(invoice.Id, invoice.blng__Order__c);
        }
        Map<Id, Order> orderByIdsMap = new Map<Id, Order> ([SELECT Id, BillToContactId FROM Order WHERE Id IN :orderIdByInvoiceIdMap.values()]);

        for(blng__Invoice__c invoice: invoices) {

            if((invoice.UKEUorROW__c == 'UK' && invoice.CurrencyCode__c != 'GBP' && invoice.TaxRate__c == 20) ||
                    invoice.UKEUorROW__c == 'EU' && invoice.CurrencyCode__c != 'GBP' && invoice.TaxRate__c == 20 && String.isBlank(invoice.Customer_VAT_No__c)) {invoice.ShowUKEquivalent__c = true;invoice.ShowGBPExchange__c = true;
            } else {
                invoice.ShowUKEquivalent__c = false;
                invoice.ShowGBPExchange__c = false;
            }

            // Update the bill to contact id
            if(orderByIdsMap.containsKey(invoice.blng__Order__c)) {invoice.blng__BillToContact__c = orderByIdsMap.get(invoice.blng__Order__c).BillToContactId;
            }
            // Modified by Rajesh Kumar yadav : https://informa-ge-sfdc.atlassian.net/browse/BK-2006 on 8/8/19.
            // Modified by Rajesh Kumar yadav : BK-3513.
          //  invoice.CreditTransferInfoLong__c = TaxLanguageHelper.getLanguageTextForCreditTransferInfo(invoice.LegalEntityCode__c, invoice.CurrencyCode__c, invoice.Event_Series_Alternate_Currency__c);
            if(invoice.TaxRate__c == 8) {invoice.VAT_or_Tax_footer__c = TaxLanguageHelper.getLanguageTextForVatFooter(invoice.LegalEntityCode__c, 8);
            } 
            else if(invoice.TaxRate__c == 5) {invoice.VAT_or_Tax_footer__c = TaxLanguageHelper.getLanguageTextForVatFooter(invoice.LegalEntityCode__c, 5);
            }
            else if(invoice.TaxRate__c == 3) {invoice.VAT_or_Tax_footer__c = TaxLanguageHelper.getLanguageTextForVatFooter(invoice.LegalEntityCode__c, 3);
            } 
            else {
                invoice.VAT_or_Tax_footer__c = TaxLanguageHelper.getLanguageTextForVatFooter(invoice.LegalEntityCode__c, 20/*invoice.TaxRate__c*/);
            }
        }
    }

    /**
     * Duplicate the invoice so that there's an invoice for each payment date.
     *
     * @param invoiceIdList
     * @param invoiceLines
     */
    public static void applyPaymentScheduleToInvoice(List<Id> invoiceIdList, List<blng__InvoiceLine__c> invoiceLines) {
        // Only want to replicate those invoices that are first in the series or brand new.
        System.debug('InvoiceHandler.applyPaymentScheduleToInvoice() ' + invoiceIdList);
        Map<Id, blng__Invoice__c> idFirstInvoiceMap = new Map<Id, blng__Invoice__c>([SELECT Id, Name, blng__Account__c,
                blng__ARStatus__c, blng__BillToContact__c, blng__DueDate__c, blng__InvoiceDate__c, blng__Notes__c,
                blng__Order__c, blng__PaymentBatch__c, blng__PaymentMethod__c, blng__InvoiceStatus__c,
                blng__TargetDate__c, blng__TaxErrorMessage__c, blng__TaxStatus__c, blng__UniqueId__c,
                blng__Order__r.SBQQ__Quote__c, blng__Order__r.SBQQ__Quote__r.SBQQ__Opportunity2__c,
                blng__Order__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.EventEdition__r.Payment_Schedule__c,
                Schedule_Number__c, CurrencyIsoCode, blng__InvoiceRunCreatedBy__c, blng__Order__r.BillToContactId
        FROM blng__Invoice__c
        WHERE Id IN :invoiceIdList AND Schedule_Number__c = 1]);

        //* @description Get the invoice lines related the each of the original invoices
        Map<Id, List<blng__InvoiceLine__c>> invoiceIdToInvoiceLinesMap = new Map<Id, List<blng__InvoiceLine__c>>();

        System.debug('InvoiceHandler.applyPaymentScheduleToInvoice() invoiceLines: ' + invoiceLines);

        List<Id> orderProducts = new List<Id>();
        List<blng__InvoiceLine__c> mapInvoiceLines;
        for (blng__InvoiceLine__c invoiceLine: invoiceLines) {
            if (invoiceIdToInvoiceLinesMap.containsKey(invoiceLine.blng__Invoice__c)) {mapInvoiceLines = invoiceIdToInvoiceLinesMap.get(invoiceLine.blng__Invoice__c);
            } else {
                mapInvoiceLines = new List<blng__InvoiceLine__c>();
            }
            mapInvoiceLines.add(invoiceLine);
            invoiceIdToInvoiceLinesMap.put(invoiceLine.blng__Invoice__c, mapInvoiceLines);
            orderProducts.add(invoiceLine.blng__OrderProduct__c);
        }

        System.debug('InvoiceHandler.applyPaymentScheduleToInvoice() idFirstInvoiceMap: ' + idFirstInvoiceMap.size() + ' keys: ' + idFirstInvoiceMap.keySet() + ' invoiceIdToInvoiceLinesMap: ' + invoiceIdToInvoiceLinesMap);
        if(idFirstInvoiceMap.size() > 0) {
            Map<Id, OrderItem> orderProductMap = new Map<Id, OrderItem>(
            [SELECT Id, OrderId, SBQQ__QuoteLine__r.SBQQ__Quote__c, SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.SBQQ__AmendedContract__c, Order.BillToContactId
            FROM OrderItem WHERE Id IN :orderProducts]);

            Map<Id, Id> invoiceIdToQuoteIdMap = new Map<Id, Id>();
            Map<Id, Id> quoteToFirstInvoiceMap = new Map<Id, Id>();
            Map<Id, Id> invoiceIdToOrderIdMap = new Map<Id, Id>();
            Map<Id, Id> invoiceIdToContactIdMap = new Map<Id, Id>();
            for (blng__Invoice__c invoice: idFirstInvoiceMap.values()) {
                if(invoice.blng__Order__r.SBQQ__Quote__c != null) {
                    invoiceIdToQuoteIdMap.put(invoice.Id, invoice.blng__Order__r.SBQQ__Quote__c);
                    quoteToFirstInvoiceMap.put(invoice.blng__Order__r.SBQQ__Quote__c, invoice.Id);
                    invoiceIdToOrderIdMap.put(invoice.Id, invoice.blng__Order__c);
                    invoiceIdToContactIdMap.put(invoice.Id, invoice.blng__Order__r.BillToContactId);

                } else {
                    List<InvoiceLineWrapper> invoiceLinesWrapped = new List<InvoiceLineWrapper>();
                    for(blng__InvoiceLine__c invoiceLine: invoiceIdToInvoiceLinesMap.get(invoice.Id)) {
                        invoiceLinesWrapped.add(new InvoiceLineWrapper(invoiceLine));
                    } invoiceLinesWrapped.sort();
                    for(InvoiceLineWrapper invoiceLine: invoiceLinesWrapped)  {
                        OrderItem item = orderProductMap.get(invoiceLine.inv.blng__OrderProduct__c);
                        //if(item.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.SBQQ__AmendedContract__c == null) {
                        invoiceIdToQuoteIdMap.put(invoice.Id, item.SBQQ__QuoteLine__r.SBQQ__Quote__c);quoteToFirstInvoiceMap.put(item.SBQQ__QuoteLine__r.SBQQ__Quote__c, invoice.Id);invoiceIdToOrderIdMap.put(invoice.Id, item.OrderId);invoiceIdToContactIdMap.put(invoice.Id, item.Order.BillToContactId);
                        //}
                    }
                }
            }
            System.debug('InvoiceHandler.applyPaymentScheduleToInvoice() invoiceIdToQuoteIdMap ' + invoiceIdToQuoteIdMap.size() + ' keys: ' + invoiceIdToQuoteIdMap.keySet() + ' quoteToFirstInvoiceMap: ' + quoteToFirstInvoiceMap.size() + ' keys: ' + quoteToFirstInvoiceMap.keySet());
            //* @description Related opportunities

            Map<Id, SBQQ__Quote__c> quoteMap = new Map<Id, SBQQ__Quote__c>([SELECT Id, Name, Payment_Schedule__c,
                    Cutoff_Date_1__c, Cutoff_Date_2__c, Cutoff_Date_3__c, SBQQ__Opportunity2__r.EventEdition__r.Payment_Schedule__c,
                    Invoice_to_Start_Date_Cut_Off_Date1__c, Invoice_to_Start_Date_Cut_Off_Date2__c, Invoice_to_Start_Date_Cut_Off_Date3__c,
                    Invoice_to_be_issued_before_in_Days__c,
                    SBQQ__Opportunity2__r.Milestone_1_Delivery_Date__c, SBQQ__Opportunity2__r.Milestone_1_Amount__c,
                    SBQQ__Opportunity2__r.Milestone_2_Delivery_Date__c, SBQQ__Opportunity2__r.Milestone_2_Amount__c,
                    SBQQ__Opportunity2__r.Milestone_3_Delivery_Date__c, SBQQ__Opportunity2__r.Milestone_3_Amount__c,
                    SBQQ__Opportunity2__r.Milestone_4_Delivery_Date__c, SBQQ__Opportunity2__r.Milestone_4_Amount__c,
                    SBQQ__Opportunity2__r.Milestone_5_Delivery_Date__c, SBQQ__Opportunity2__r.Milestone_5_Amount__c,
                    SBQQ__Opportunity2__r.Milestone_6_Delivery_Date__c, SBQQ__Opportunity2__r.Milestone_6_Amount__c,
                    SBQQ__Opportunity2__r.Milestone_7_Delivery_Date__c, SBQQ__Opportunity2__r.Milestone_7_Amount__c,
                    SBQQ__Opportunity2__r.Milestone_8_Delivery_Date__c, SBQQ__Opportunity2__r.Milestone_8_Amount__c,
                    SBQQ__Opportunity2__r.Milestone_9_Delivery_Date__c, SBQQ__Opportunity2__r.Milestone_9_Amount__c,
                    SBQQ__Opportunity2__r.Milestone_10_Delivery_Date__c, SBQQ__Opportunity2__r.Milestone_10_Amount__c,
                    SBQQ__Opportunity2__r.Milestone_11_Delivery_Date__c, SBQQ__Opportunity2__r.Milestone_11_Amount__c,
                    SBQQ__Opportunity2__r.Milestone_12_Delivery_Date__c, SBQQ__Opportunity2__r.Milestone_12_Amount__c
            FROM SBQQ__Quote__c
            WHERE Id IN :invoiceIdToQuoteIdMap.values()]);

            Map<Id, Map<Integer, InvoiceHandler.MileStoneEntry>> quoteIdToDeliveryDates = new Map<Id, Map<Integer, InvoiceHandler.MileStoneEntry>>();
            //* @description Create the new Invoices
            List<blng__Invoice__c> newInvoices = new List<blng__Invoice__c>();
            List<blng__Invoice__c> updateInvoices = new List<blng__Invoice__c>();
            for (blng__Invoice__c invoice: idFirstInvoiceMap.values()) {
                Id quoteId = invoiceIdToQuoteIdMap.get(invoice.Id);
                System.debug('InvoiceHandler.applyPaymentScheduleToInvoice() invoice quote id: ' + quoteId);

                if(quoteId != null) {
                    SBQQ__Quote__c quote = quoteMap.get(quoteId);
                    if (quote.SBQQ__Opportunity2__r.EventEdition__r.Payment_Schedule__c != null) {
                        Map<Integer, InvoiceHandler.MileStoneEntry> deliveryDates = deliveryDates(quote);
                        System.debug('InvoiceHandler.applyPaymentScheduleToInvoice() deliveryDates: ' + deliveryDates);
                        quoteIdToDeliveryDates.put(quote.Id, deliveryDates);
                        if (deliveryDates.size() > 0) {
                            // Iterate over the rest of the payments starting with 2 as the first one should be the existing invoice
                            for (Integer scheduleNumber = 2; scheduleNumber <= deliveryDates.size(); scheduleNumber++) {
                                blng__Invoice__c cloneInvoice = invoice.clone(false, true);
                                cloneInvoice.Schedule_Number__c = scheduleNumber;
                                cloneInvoice.blng__InvoiceDate__c = determineInvoiceDate(deliveryDates.get(scheduleNumber).milestoneDate, quote.Invoice_to_be_issued_before_in_Days__c);
                                cloneInvoice.blng__DueDate__c = deliveryDates.get(scheduleNumber).milestoneDate;
                                cloneInvoice.blng__UniqueId__c = InvoiceUtilities.generateGUID();
                                cloneInvoice.blng__Order__c = invoiceIdToOrderIdMap.get(invoice.Id);
                                cloneInvoice.First_Invoice__c = invoice.Id;
                                newInvoices.add(cloneInvoice);
                            }
                        }

                        System.debug('InvoiceHandler.applyPaymentScheduleToInvoice() initial invoice due date: ' + deliveryDates.get(1).milestoneDate);
                        invoice.blng__InvoiceDate__c = determineInvoiceDate(deliveryDates.get(1).milestoneDate, quote.Invoice_to_be_issued_before_in_Days__c);
                        invoice.blng__DueDate__c = deliveryDates.get(1).milestoneDate;

                    }
                } else {
                    System.debug('InvoiceHandler.applyPaymentScheduleToInvoice() *** quote id was null?  InvoiceId: ' + invoice.Id + '  Count of invoice lines: ' + invoiceIdToInvoiceLinesMap.get(invoice.Id) != null ? String.valueOf(invoiceIdToInvoiceLinesMap.get(invoice.Id).size()) : 'null');
                }
                // In case the order hasn't been set, we set it on the original invoice. Sometimes happens when the using the InvoiceScheduler.
                if (invoice.blng__Order__c == null) {invoice.blng__Order__c = invoiceIdToOrderIdMap.get(invoice.Id);invoice.blng__BillToContact__c = invoiceIdToContactIdMap.get(invoice.Id);
                }
                updateInvoices.add(invoice);
            }

            // Insert new Invoices
            System.debug('InvoiceHandler.applyPaymentScheduleToInvoice() newInvoices: ' + newInvoices);
            if(newInvoices.size() > 0) {
                insert newInvoices;
            }
            System.debug('InvoiceHandler.applyPaymentScheduleToInvoice() updateInvoices: ' + updateInvoices);
            if(updateInvoices.size() > 0) {
                update updateInvoices;
            }

            Map<Id, blng__Invoice__c> idLaterInvoiceMap =
                    new Map<Id, blng__Invoice__c>([
                            SELECT Id, Name, blng__Account__c, blng__ARStatus__c, blng__BillToContact__c, blng__DueDate__c, blng__InvoiceDate__c, blng__Notes__c,
                                    blng__Order__c, blng__PaymentBatch__c, blng__PaymentMethod__c, blng__InvoiceStatus__c,
                                    blng__TargetDate__c, blng__TaxErrorMessage__c, blng__TaxStatus__c, blng__UniqueId__c,
                                    blng__Order__r.SBQQ__Quote__c, blng__Order__r.SBQQ__Quote__r.SBQQ__Opportunity2__c,
                                    blng__Order__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.EventEdition__r.Payment_Schedule__c, Schedule_Number__c
                            FROM blng__Invoice__c
                            WHERE Id IN :newInvoices AND Schedule_Number__c != 1
                    ]);
            System.debug('InvoiceHandler.applyPaymentScheduleToInvoice() idLaterInvoiceMap: ' + idLaterInvoiceMap.size() + ' keys: ' + idLaterInvoiceMap.keySet());
            Map<Id, List<Id>> quoteIdToInvoiceListMap = new Map<Id, List<Id>>();
            List<Id> mapInvoices;
            for (blng__Invoice__c invoice: idLaterInvoiceMap.values()) {
                //Id opportunityId = invoice.blng__Order__r.SBQQ__Quote__r.SBQQ__Opportunity2__c;
                //invoiceIdToOpportunityIdMap.put(invoice.Id, opportunityId);
                Id quoteId = invoice.blng__Order__r.SBQQ__Quote__c;
                invoiceIdToQuoteIdMap.put(invoice.Id, quoteId);
                if (quoteIdToInvoiceListMap.containsKey(quoteId)) {
                    mapInvoices = quoteIdToInvoiceListMap.get(quoteId);
                } else {
                    mapInvoices = new List<Id>();
                }
                mapInvoices.add(invoice.Id);
                quoteIdToInvoiceListMap.put(quoteId, mapInvoices);
            }

            System.debug('InvoiceHandler.applyPaymentScheduleToInvoice() quoteIdToInvoiceListMap: ' + quoteIdToInvoiceListMap.size() + ' keys: ' + quoteIdToInvoiceListMap.keySet());


            // Clone new Invoice Lines
            List<blng__InvoiceLine__c> newInvoiceLines = new List<blng__InvoiceLine__c>();
            List<blng__InvoiceLine__c> updateInvoiceLines = new List<blng__InvoiceLine__c>();

            for (SBQQ__Quote__c quote: quoteMap.values()) {
                if(quote.SBQQ__Opportunity2__r.EventEdition__r.Payment_Schedule__c != null) {
                    Id quoteId = quote.Id;
                    Id firstInvoiceId = quoteToFirstInvoiceMap.get(quoteId);
                    List<Id> followingInvoiceIds = quoteIdToInvoiceListMap.get(quoteId);
                    List<blng__InvoiceLine__c> firstInvoiceLines = invoiceIdToInvoiceLinesMap.get(firstInvoiceId);
                    Map<Integer, InvoiceHandler.MileStoneEntry> deliveryDates = quoteIdToDeliveryDates.get(quoteId);
                    System.debug('InvoiceHandler.applyPaymentScheduleToInvoice() quoteId: ' + quoteId + ' followingInvoiceIds: ' + followingInvoiceIds + ' quoteIdToInvoiceListMap: ' +  quoteIdToInvoiceListMap + ' firstInvoiceLines: ' + firstInvoiceLines);
                    // System.debug('InvoiceHandler.applyPaymentScheduleToInvoice() quoteId: ' + quoteId + ' followingInvoiceIds: ' + quoteIdToInvoiceListMap + ' firstInvoiceLines: ' + firstInvoiceLines);
                    if (firstInvoiceLines != null) {
                        if ( followingInvoiceIds != null ) { 
                            for (Id paymentInvoiceId: followingInvoiceIds) {
                                if(paymentInvoiceId != null) {
                                   blng__Invoice__c paymentInvoice = idLaterInvoiceMap.get(paymentInvoiceId);
                                   InvoiceHandler.MileStoneEntry milestoneEntry = deliveryDates.get(Integer.valueOf(paymentInvoice.Schedule_Number__c));
                                   System.debug('InvoiceHandler.applyPaymentScheduleToInvoice() paymentInvoice ScheduleNumber: ' + paymentInvoice.Schedule_Number__c + ' milestoneEntry: ' + milestoneEntry);
                                   for (blng__InvoiceLine__c firstInvoiceLine: firstInvoiceLines) {
                                       blng__InvoiceLine__c newInvoiceLine = firstInvoiceLine.clone(false, true);
                                       newInvoiceLine.blng__Invoice__c = paymentInvoiceId;
                                       newInvoiceLine.blng__Subtotal__c = firstInvoiceLine.blng__Subtotal__c * milestoneEntry.milestonePercent;
                                       //newInvoiceLine.blng__TotalAmount__c = firstInvoiceLine.blng__TotalAmount__c * milestoneEntry.milestonePercent;
                                       newInvoiceLine.blng__StartDate__c = milestoneEntry.milestoneDate;
                                       System.debug('InvoiceHandler.applyPaymentScheduleToInvoice() amount: ' + newInvoiceLine.blng__Subtotal__c);
                                       newInvoiceLine.blng__UniqueId__c = InvoiceUtilities.generateGUID();
                                       newInvoiceLine.blng__TaxAmount__c = 0.0;
                                       //newInvoiceLine.blng__OrderProduct__c = firstInvoiceLine.blng__OrderProduct__c;
                                       newInvoiceLines.add(newInvoiceLine);
                                   }
                               }
                           }

                           // updated the later payment terms, now update the first one to the correct percentage
                           InvoiceHandler.MileStoneEntry milestoneEntry = deliveryDates.get(1);
                           for (blng__InvoiceLine__c invoiceLine: firstInvoiceLines) {
                               System.debug('InvoiceHandler.applyPaymentScheduleToInvoice() change the first invoice lines: ' + invoiceLine.blng__TotalAmount__c + ' Percent: ' + milestoneEntry.milestonePercent);
                               invoiceLine.blng__TotalAmount__c = invoiceLine.blng__TotalAmount__c * milestoneEntry.milestonePercent;
                               invoiceLine.blng__Subtotal__c = invoiceLine.blng__Subtotal__c * milestoneEntry.milestonePercent;
                               invoiceLine.blng__StartDate__c = milestoneEntry.milestoneDate;
                               updateInvoiceLines.add(invoiceLine);
                           }
                       }
                    }
                }
            }

            // Insert new Invoice Lines
            System.debug('InvoiceHandler.applyPaymentScheduleToInvoice() newInvoiceLines ' + newInvoiceLines);
            System.debug('InvoiceHandler.applyPaymentScheduleToInvoice() updateInvoiceLines ' + updateInvoiceLines);

            if (newInvoiceLines.size() > 0) {
                try {
                    insert newInvoiceLines; } catch (DmlException eek) {
                    System.debug(LoggingLevel.ERROR, 'InvoiceHandler.applyPaymentScheduleToInvoice new InvoiceLines dml exception occurred ' + eek.getMessage() + ' Stack: ' + eek.getStackTraceString());
                    throw eek;
                } catch (QueryException eek) {
                    System.debug(LoggingLevel.ERROR, 'InvoiceHandler.applyPaymentScheduleToInvoice new InvoiceLines query exception occurred ' + eek.getMessage() + ' Stack: ' + eek.getStackTraceString());
                    throw eek;
                }
            }

            /*if (updateInvoiceLines.size() > 0) {
                update updateInvoiceLines;
            }*/

        }
    }

    /*private static Map<Integer, InvoiceHandler.MileStoneEntry> deliveryDates(Opportunity opportunity) {
        Map<Integer, InvoiceHandler.MileStoneEntry> milestoneEntryMap = new Map<Integer, InvoiceHandler.MileStoneEntry>();
        if(opportunity.Milestone_1_Delivery_Date__c != null){
            milestoneEntryMap.put(1, new InvoiceHandler.MileStoneEntry(opportunity.Milestone_1_Delivery_Date__c, opportunity.Milestone_1_Amount__c, opportunity.Milestone_1_Percent__c));
        } else if(opportunity.Milestone_2_Delivery_Date__c != null){
            milestoneEntryMap.put(1, new InvoiceHandler.MileStoneEntry(opportunity.Milestone_2_Delivery_Date__c, opportunity.Milestone_2_Amount__c, opportunity.Milestone_2_Percent__c));
        } else if(opportunity.Milestone_3_Delivery_Date__c != null){
            milestoneEntryMap.put(1, new InvoiceHandler.MileStoneEntry(opportunity.Milestone_3_Delivery_Date__c, opportunity.Milestone_3_Amount__c, opportunity.Milestone_3_Percent__c));
        }
        return milestoneEntryMap;
    } */

    private static Map<Integer, InvoiceHandler.MileStoneEntry> deliveryDates(SBQQ__Quote__c quote) {
        System.debug('InvoiceHandler.deliveryDates() quote payment schedule: ' + quote.Payment_Schedule__c +  ' event schedule: ' + quote.SBQQ__Opportunity2__r.EventEdition__r.Payment_Schedule__c + ' ' + quote.SBQQ__Opportunity2__r.Milestone_1_Delivery_Date__c);
        Map<Integer, InvoiceHandler.MileStoneEntry> milestoneEntryMap = new Map<Integer, InvoiceHandler.MileStoneEntry>();

        if(quote.SBQQ__Opportunity2__r.Milestone_1_Delivery_Date__c != null && quote.SBQQ__Opportunity2__r.Milestone_1_Amount__c != null) {
            milestoneEntryMap = determineMileStoneEntry(milestoneEntryMap, quote.SBQQ__Opportunity2__r.Milestone_1_Delivery_Date__c, 0.0, quote.SBQQ__Opportunity2__r.Milestone_1_Amount__c, quote.Invoice_to_be_issued_before_in_Days__c);

            if(quote.SBQQ__Opportunity2__r.Milestone_2_Delivery_Date__c != null && quote.SBQQ__Opportunity2__r.Milestone_2_Amount__c != null) {
                milestoneEntryMap = determineMileStoneEntry(milestoneEntryMap, quote.SBQQ__Opportunity2__r.Milestone_2_Delivery_Date__c, quote.SBQQ__Opportunity2__r.Milestone_2_Amount__c, 0.0, quote.Invoice_to_be_issued_before_in_Days__c);
            }
            if(quote.SBQQ__Opportunity2__r.Milestone_3_Delivery_Date__c != null && quote.SBQQ__Opportunity2__r.Milestone_3_Amount__c != null) {
                milestoneEntryMap = determineMileStoneEntry(milestoneEntryMap, quote.SBQQ__Opportunity2__r.Milestone_3_Delivery_Date__c, quote.SBQQ__Opportunity2__r.Milestone_3_Amount__c, 0.0, quote.Invoice_to_be_issued_before_in_Days__c);
            }
            if(quote.SBQQ__Opportunity2__r.Milestone_4_Delivery_Date__c != null && quote.SBQQ__Opportunity2__r.Milestone_4_Amount__c != null) {
                milestoneEntryMap = determineMileStoneEntry(milestoneEntryMap, quote.SBQQ__Opportunity2__r.Milestone_4_Delivery_Date__c, quote.SBQQ__Opportunity2__r.Milestone_4_Amount__c, 0.0, quote.Invoice_to_be_issued_before_in_Days__c);
            }
            if(quote.SBQQ__Opportunity2__r.Milestone_5_Delivery_Date__c != null && quote.SBQQ__Opportunity2__r.Milestone_5_Amount__c != null) {
                milestoneEntryMap = determineMileStoneEntry(milestoneEntryMap, quote.SBQQ__Opportunity2__r.Milestone_5_Delivery_Date__c, quote.SBQQ__Opportunity2__r.Milestone_5_Amount__c, 0.0, quote.Invoice_to_be_issued_before_in_Days__c);
            }
            if(quote.SBQQ__Opportunity2__r.Milestone_6_Delivery_Date__c != null && quote.SBQQ__Opportunity2__r.Milestone_6_Amount__c != null) {
                milestoneEntryMap = determineMileStoneEntry(milestoneEntryMap, quote.SBQQ__Opportunity2__r.Milestone_6_Delivery_Date__c, quote.SBQQ__Opportunity2__r.Milestone_6_Amount__c, 0.0, quote.Invoice_to_be_issued_before_in_Days__c);
            }
            if(quote.SBQQ__Opportunity2__r.Milestone_7_Delivery_Date__c != null && quote.SBQQ__Opportunity2__r.Milestone_7_Amount__c != null) {
                milestoneEntryMap = determineMileStoneEntry(milestoneEntryMap, quote.SBQQ__Opportunity2__r.Milestone_7_Delivery_Date__c, quote.SBQQ__Opportunity2__r.Milestone_7_Amount__c, 0.0, quote.Invoice_to_be_issued_before_in_Days__c);
            }
            if(quote.SBQQ__Opportunity2__r.Milestone_8_Delivery_Date__c != null && quote.SBQQ__Opportunity2__r.Milestone_8_Amount__c != null) {
                milestoneEntryMap = determineMileStoneEntry(milestoneEntryMap, quote.SBQQ__Opportunity2__r.Milestone_8_Delivery_Date__c, quote.SBQQ__Opportunity2__r.Milestone_8_Amount__c, 0.0, quote.Invoice_to_be_issued_before_in_Days__c);
            }
            if(quote.SBQQ__Opportunity2__r.Milestone_9_Delivery_Date__c != null && quote.SBQQ__Opportunity2__r.Milestone_9_Amount__c != null) {
                milestoneEntryMap = determineMileStoneEntry(milestoneEntryMap, quote.SBQQ__Opportunity2__r.Milestone_9_Delivery_Date__c, quote.SBQQ__Opportunity2__r.Milestone_9_Amount__c, 0.0, quote.Invoice_to_be_issued_before_in_Days__c);
            }
            if(quote.SBQQ__Opportunity2__r.Milestone_10_Delivery_Date__c != null && quote.SBQQ__Opportunity2__r.Milestone_10_Amount__c != null) {
                milestoneEntryMap = determineMileStoneEntry(milestoneEntryMap, quote.SBQQ__Opportunity2__r.Milestone_10_Delivery_Date__c, quote.SBQQ__Opportunity2__r.Milestone_10_Amount__c, 0.0, quote.Invoice_to_be_issued_before_in_Days__c);
            }
            if(quote.SBQQ__Opportunity2__r.Milestone_11_Delivery_Date__c != null && quote.SBQQ__Opportunity2__r.Milestone_11_Amount__c != null) {
                milestoneEntryMap = determineMileStoneEntry(milestoneEntryMap, quote.SBQQ__Opportunity2__r.Milestone_11_Delivery_Date__c, quote.SBQQ__Opportunity2__r.Milestone_11_Amount__c, 0.0, quote.Invoice_to_be_issued_before_in_Days__c);
            }
            if(quote.SBQQ__Opportunity2__r.Milestone_12_Delivery_Date__c != null && quote.SBQQ__Opportunity2__r.Milestone_12_Amount__c != null) {
                milestoneEntryMap = determineMileStoneEntry(milestoneEntryMap, quote.SBQQ__Opportunity2__r.Milestone_12_Delivery_Date__c, quote.SBQQ__Opportunity2__r.Milestone_12_Amount__c, 0.0, quote.Invoice_to_be_issued_before_in_Days__c); } } else if(quote.SBQQ__Opportunity2__r.EventEdition__r.Payment_Schedule__c != null) {Date firstPayment = Date.today();
            /*if(quote.SBQQ__Opportunity2__r.EventEdition__r.Payment_Schedule__c == PAYMENT_SCHEDULE_50_50) {
                milestoneEntryMap.put(1, new InvoiceHandler.MileStoneEntry(firstPayment, 0, 0.50));
                milestoneEntryMap.put(2, new InvoiceHandler.MileStoneEntry(quote.Cutoff_Date_1__c, 0, 0.50));
            } else if(quote.SBQQ__Opportunity2__r.EventEdition__r.Payment_Schedule__c == PAYMENT_SCHEDULE_10_45_45) {
                milestoneEntryMap.put(1, new InvoiceHandler.MileStoneEntry(firstPayment, 0, 0.10));
                milestoneEntryMap.put(2, new InvoiceHandler.MileStoneEntry(quote.Cutoff_Date_1__c, 0, 0.45));
                milestoneEntryMap.put(3, new InvoiceHandler.MileStoneEntry(quote.Cutoff_Date_2__c, 0, 0.45));
            } else if(quote.SBQQ__Opportunity2__r.EventEdition__r.Payment_Schedule__c == PAYMENT_SCHEDULE_10_40_50) {
                milestoneEntryMap.put(1, new InvoiceHandler.MileStoneEntry(firstPayment, 0, 0.10));
                milestoneEntryMap.put(2, new InvoiceHandler.MileStoneEntry(quote.Cutoff_Date_1__c, 0, 0.40));
                milestoneEntryMap.put(3, new InvoiceHandler.MileStoneEntry(quote.Cutoff_Date_2__c, 0, 0.50));
            } else if(quote.SBQQ__Opportunity2__r.EventEdition__r.Payment_Schedule__c == PAYMENT_SCHEDULE_25_25_50) {
                milestoneEntryMap.put(1, new InvoiceHandler.MileStoneEntry(firstPayment, 0, 0.25));
                milestoneEntryMap.put(2, new InvoiceHandler.MileStoneEntry(quote.Cutoff_Date_1__c, 0, 0.25));
                milestoneEntryMap.put(3, new InvoiceHandler.MileStoneEntry(quote.Cutoff_Date_2__c, 0, 0.50));
            } else if(quote.SBQQ__Opportunity2__r.EventEdition__r.Payment_Schedule__c == PAYMENT_SCHEDULE_25_25_25_25) {
                milestoneEntryMap.put(1, new InvoiceHandler.MileStoneEntry(firstPayment, 0, 0.25));
                milestoneEntryMap.put(2, new InvoiceHandler.MileStoneEntry(quote.Cutoff_Date_1__c, 0, 0.25));
                milestoneEntryMap.put(3, new InvoiceHandler.MileStoneEntry(quote.Cutoff_Date_2__c, 0, 0.25));
                milestoneEntryMap.put(4, new InvoiceHandler.MileStoneEntry(quote.Cutoff_Date_3__c, 0, 0.25));
            } */
            if(quote.SBQQ__Opportunity2__r.EventEdition__r.Payment_Schedule__c == PAYMENT_SCHEDULE_50_50) {
                milestoneEntryMap = determineMileStoneEntry(milestoneEntryMap, firstPayment, 0, 0.50, quote.Invoice_to_be_issued_before_in_Days__c); milestoneEntryMap = determineMileStoneEntry(milestoneEntryMap, quote.Cutoff_Date_1__c, 0, 0.50, quote.Invoice_to_be_issued_before_in_Days__c);
            } else if(quote.SBQQ__Opportunity2__r.EventEdition__r.Payment_Schedule__c == PAYMENT_SCHEDULE_10_45_45) {
                milestoneEntryMap = determineMileStoneEntry(milestoneEntryMap, firstPayment, 0, 0.10, quote.Invoice_to_be_issued_before_in_Days__c); milestoneEntryMap = determineMileStoneEntry(milestoneEntryMap, quote.Cutoff_Date_1__c, 0, 0.45, quote.Invoice_to_be_issued_before_in_Days__c);milestoneEntryMap = determineMileStoneEntry(milestoneEntryMap, quote.Cutoff_Date_2__c, 0, 0.45, quote.Invoice_to_be_issued_before_in_Days__c);
            } else if(quote.SBQQ__Opportunity2__r.EventEdition__r.Payment_Schedule__c == PAYMENT_SCHEDULE_10_40_50) {
                milestoneEntryMap = determineMileStoneEntry(milestoneEntryMap, firstPayment, 0, 0.10, quote.Invoice_to_be_issued_before_in_Days__c); milestoneEntryMap = determineMileStoneEntry(milestoneEntryMap, quote.Cutoff_Date_1__c, 0, 0.40, quote.Invoice_to_be_issued_before_in_Days__c);milestoneEntryMap = determineMileStoneEntry(milestoneEntryMap, quote.Cutoff_Date_2__c, 0, 0.50, quote.Invoice_to_be_issued_before_in_Days__c);
            } else if(quote.SBQQ__Opportunity2__r.EventEdition__r.Payment_Schedule__c == PAYMENT_SCHEDULE_25_25_50) {
                milestoneEntryMap = determineMileStoneEntry(milestoneEntryMap, firstPayment, 0, 0.25, quote.Invoice_to_be_issued_before_in_Days__c);milestoneEntryMap = determineMileStoneEntry(milestoneEntryMap, quote.Cutoff_Date_1__c, 0, 0.25, quote.Invoice_to_be_issued_before_in_Days__c);milestoneEntryMap = determineMileStoneEntry(milestoneEntryMap, quote.Cutoff_Date_2__c, 0, 0.50, quote.Invoice_to_be_issued_before_in_Days__c);
            } else if(quote.SBQQ__Opportunity2__r.EventEdition__r.Payment_Schedule__c == PAYMENT_SCHEDULE_25_25_25_25) {
                milestoneEntryMap = determineMileStoneEntry(milestoneEntryMap, firstPayment, 0, 0.25, quote.Invoice_to_be_issued_before_in_Days__c); milestoneEntryMap = determineMileStoneEntry(milestoneEntryMap, quote.Cutoff_Date_1__c, 0, 0.25, quote.Invoice_to_be_issued_before_in_Days__c);milestoneEntryMap = determineMileStoneEntry(milestoneEntryMap, quote.Cutoff_Date_2__c, 0, 0.25, quote.Invoice_to_be_issued_before_in_Days__c);milestoneEntryMap = determineMileStoneEntry(milestoneEntryMap, quote.Cutoff_Date_3__c, 0, 0.25, quote.Invoice_to_be_issued_before_in_Days__c);
            }
            //milestoneEntryMap.put(1, new InvoiceHandler.MileStoneEntry(opportunity.Milestone_1_Delivery_Date__c, opportunity.Milestone_1_Amount__c, opportunity.Milestone_1_Percent__c));
        }
        return milestoneEntryMap;
    }

    public static Map<Integer, MileStoneEntry> determineMileStoneEntry(Map<Integer, MileStoneEntry> currentMap, Date cutoffDate, Decimal cutoffAmount, Decimal cutoffPercent, Decimal beforeDays) {
        if(currentMap.size() < 1) {
            MileStoneEntry entry = new InvoiceHandler.MileStoneEntry(Date.today(), cutoffAmount, cutoffPercent);
            currentMap.put(1, entry);
        } else if(cutoffDate.addDays(- (Integer) beforeDays) <= Date.today()) { MileStoneEntry entry = currentMap.get(1); entry.milestonePercent += cutoffPercent; entry.milestoneAmount += cutoffAmount;currentMap.put(1, entry);
        } else {
            MileStoneEntry entry = new InvoiceHandler.MileStoneEntry(cutoffDate, cutoffAmount, cutoffPercent);
            currentMap.put(currentMap.size() + 1, entry);
        }

        return currentMap;
    }

    public class MileStoneEntry {
        public Date milestoneDate {get; set;}
        public Decimal milestoneAmount {get; set;}
        public Decimal milestonePercent {get; set;}

        public MileStoneEntry(Date aDate, Decimal amount, Decimal percent) {
            milestoneDate = aDate;
            milestoneAmount = amount;
            milestonePercent = percent;
        }
    }

    private static Date determineInvoiceDate(Date dueDate, Decimal beforeDays) {
        System.debug('InvoiceHandler.determineInvoiceDate ' + dueDate);
        if(dueDate != null) {
            if(dueDate.addDays(- (Integer) beforeDays) < Date.today()) {
                //System.debug('InvoiceHandler.determineInvoiceDate today');
                return Date.today();
            } else {
                //System.debug('InvoiceHandler.determineInvoiceDate days -30' + dueDate.addDays(-30));
                return dueDate.addDays(- (Integer) beforeDays);
            }

        }
        return dueDate;
    }

    private class InvoiceLineWrapper implements Comparable {
        public blng__InvoiceLine__c inv;

        public InvoiceLineWrapper(blng__InvoiceLine__c anInvoiceLine) {
            inv = anInvoiceLine;
        }

        public Integer compareTo(Object compareTo) {
            InvoiceLineWrapper compareToInvoice = (InvoiceLineWrapper) compareTo;

            Integer returnValue = 0; if(inv.CreatedDate > compareToInvoice.inv.CreatedDate) { returnValue = 1; } else if (inv.CreatedDate < compareToInvoice.inv.CreatedDate) { returnValue = -1;  } return returnValue;
        }
    }

    public static String PAYMENT_SCHEDULE_50_50 = '50-50';
    public static String PAYMENT_SCHEDULE_10_45_45 = '10-45-45';
    public static String PAYMENT_SCHEDULE_10_40_50 = '10-40-50';
    public static String PAYMENT_SCHEDULE_25_25_50 = '25-25-50';
    public static String PAYMENT_SCHEDULE_25_25_25_25 = '25-25-25-25';
}