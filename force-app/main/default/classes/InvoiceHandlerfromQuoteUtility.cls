/**
* Project:     GAP
* Date:        22/4/2018
* Created By:  Abdul Kadir
* Test class   InvoiceHandlerfromQuoteUtility_Test.cls
* *************************************************************************
* Description: This class use to clone the invoices and invoice lines on the basis of payment schedule.
* *************************************************************************
* History: 30/7/2019 :- Shiv Raghav Sharma for jira ticket https://informa-ge-sfdc.atlassian.net/browse/BK-29
  Description :- Invoice Date Based on the Time Zone of the SSC
*/

public class InvoiceHandlerfromQuoteUtility{
    // This is for tax calculation bypass.
    // Commented By Kumar : GGCW-2145
    //static Id taxExemptTreatmentId = Tax_Exempt_Treatment__c.getOrgDefaults().Treatment_ID__c;
    
    /**
    * @description This method will called from invoice_invoicelineCreateBatchable class.
    * @param idFirstInvoiceMap
    * @return 
    */
    public static void createInvoice_InvoiceLines(Map<Id,blng__Invoice__c> idFirstInvoiceMap){
        try {
            DeliveryDateUtilities deliveryDateUtilityObj = new DeliveryDateUtilities();
            // Get the invoice lines related the each of the original invoices
            Map<Id, List<blng__InvoiceLine__c>> invoiceIdToInvoiceLinesMap = new Map<Id, List<blng__InvoiceLine__c>>();
            List<blng__InvoiceLine__c> invoiceLines = [SELECT Id,Name,blng__UnitPrice__c,display_name__c,blng__Invoice__c,MDQ_Product__c,blng__Subtotal__c,Original_Subtotal__c,blng__OrderProduct__c,blng__OrderProduct__r.blng__BilledAmountwithouttax__c,blng__OrderProduct__r.Actual_Tax__c,blng__TotalAmount__c,blng__UniqueId__c,blng__TaxAmount__c,blng__Invoice__r.TaxRate__c,Product_Code__c,blng__Product__c,blng__Quantity__c,blng__StartDate__c,blng__ChargeType__c,blng__BillingFrequency__c,blng__ChargeDate__c,blng__EndDate__c,blng__LegalEntity__c,blng__BillingRule__c,blng__BillingTreatment__c,blng__TaxTreatment__c,blng__BillingGLRule__c,blng__BillingGLTreatment__c,blng__BillingFinanceBook__c,blng__BillingFinancePeriod__c,blng__InvoiceRun__c,blng__TaxStatus__c,blng__LegalEntityReference__c,CurrencyIsoCode,blng__ARStatus__c,Service_End_Date__c FROM blng__InvoiceLine__c WHERE blng__Invoice__c IN : idFirstInvoiceMap.keySet()];
            System.debug('All InvoiceLines ==>  ' + invoiceLines);
            
            List<Id> lstOrderProducts = new List<Id>();
            List<blng__InvoiceLine__c> lstInvoiceLines;
            List<blng__Invoice__c> lstCancelledInvoice = new List<blng__Invoice__c>();
            String sCancelSuccessMsg = System.Label.Invoice_Cancel_Success_Message;
            
            for (blng__InvoiceLine__c invoiceLine: invoiceLines) {
                if (invoiceIdToInvoiceLinesMap.containsKey(invoiceLine.blng__Invoice__c)) {
                    lstInvoiceLines = invoiceIdToInvoiceLinesMap.get(invoiceLine.blng__Invoice__c);
                } else {
                    lstInvoiceLines = new List<blng__InvoiceLine__c>();
                    
                }
                lstInvoiceLines.add(invoiceLine);  
                invoiceIdToInvoiceLinesMap.put(invoiceLine.blng__Invoice__c, lstInvoiceLines);
                lstOrderProducts.add(invoiceLine.blng__OrderProduct__c);
            }
            system.debug('lstOrderProducts ==> '+lstOrderProducts);
            system.debug('invoiceIdToInvoiceLinesMap ==> '+invoiceIdToInvoiceLinesMap);
            
            //Map of order product that is use to fetch the actual tax , that is going to distribute to the invoice lines as per the event edition payment % basis.
            // Commented By Kumar : GGCW-2145
            //Map<Id, OrderItem> orderProductMap = new Map<Id, OrderItem>([SELECT Id, OrderId, SBQQ__QuoteLine__r.SBQQ__Quote__c,Actual_Tax__c,TotalPrice, SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.SBQQ__AmendedContract__c, Order.BillToContactId, SAP_Tax_Rate__c FROM OrderItem WHERE Id IN :lstOrderProducts]);
            Map<Id, OrderItem> orderProductMap = new Map<Id, OrderItem>([SELECT Id, OrderId, SBQQ__QuoteLine__r.SBQQ__Quote__c,TotalPrice, SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.SBQQ__AmendedContract__c, Order.BillToContactId FROM OrderItem WHERE Id IN :lstOrderProducts]);
            Map<Id, Id> invoiceIdToQuoteIdMap = new Map<Id, Id>();
            Map<Id, Id> quoteToFirstInvoiceMap = new Map<Id, Id>();
            Map<Id, Id> invoiceIdToOrderIdMap = new Map<Id, Id>();
            //Commented By Kumar : Not Used 
            //Map<Id, Id> invoiceIdToContactIdMap = new Map<Id, Id>();
            
            for (blng__Invoice__c invoice: idFirstInvoiceMap.values()) {
                if(invoice.blng__Order__r.SBQQ__Quote__c != null) {
                    invoiceIdToQuoteIdMap.put(invoice.Id, invoice.blng__Order__r.SBQQ__Quote__c);
                    quoteToFirstInvoiceMap.put(invoice.blng__Order__r.SBQQ__Quote__c, invoice.Id);
                    invoiceIdToOrderIdMap.put(invoice.Id, invoice.blng__Order__c);
                    //Commented By Kumar : Not Used 
                    //invoiceIdToContactIdMap.put(invoice.Id, invoice.blng__Order__r.BillToContactId);
                    
                }
            }
            
            Map<Id, SBQQ__Quote__c> quoteMap = new Map<Id, SBQQ__Quote__c>([SELECT Id, Name, Payment_Schedule__c, 
                                                                            SBQQ__Opportunity2__r.EventEdition__r.Payment_Schedule__c,Invoice_to_be_issued_before_in_Days__c,SBQQ__Opportunity2__r.Custom_Payment__c,
                                                                            InvoicetoStartDate__c,invoice_payment1__c,invoice_Percentage1__c,
                                                                            Invoice_to_Start_Date_Cut_Off_Date1__c,invoice_payment2__c,invoice_Percentage2__c,
                                                                            Invoice_to_Start_Date_Cut_Off_Date2__c,invoice_payment3__c,invoice_Percentage3__c,
                                                                            Invoice_to_Start_Date_Cut_Off_Date3__c,invoice_payment4__c,invoice_Percentage4__c,
                                                                            Invoice_to_Start_Date_Cut_Off_Date4__c,invoice_payment5__c,invoice_Percentage5__c,
                                                                            Invoice_to_Start_Date_Cut_Off_Date5__c,invoice_payment6__c,invoice_Percentage6__c,
                                                                            Invoice_to_Start_Date_Cut_Off_Date6__c,invoice_payment7__c,invoice_Percentage7__c,
                                                                            Invoice_to_Start_Date_Cut_Off_Date7__c,invoice_payment8__c,invoice_Percentage8__c,
                                                                            Invoice_to_Start_Date_Cut_Off_Date8__c,invoice_payment9__c,invoice_Percentage9__c,
                                                                            Invoice_to_Start_Date_Cut_Off_Date9__c,invoice_payment10__c,invoice_Percentage10__c,
                                                                            Invoice_to_Start_Date_Cut_Off_Date10__c,invoice_payment11__c,invoice_Percentage11__c,
                                                                            Invoice_to_Start_Date_Cut_Off_Date11__c,invoice_payment12__c,invoice_Percentage12__c
                                                                            FROM SBQQ__Quote__c
                                                                            WHERE Id IN :invoiceIdToQuoteIdMap.values()]);
            
            //Getting the MileStoneEntry map which having all the milestone dates,percentage and amount from opportunity.
            Map<Id, Map<Integer, DeliveryDateUtilities.MileStoneEntry>> quoteIdToDeliveryDates = new Map<Id, Map<Integer, DeliveryDateUtilities.MileStoneEntry>>();
            List<blng__Invoice__c> lstNewInvoices = new List<blng__Invoice__c>();
            //List<blng__Invoice__c > updatedInvoices = new List<blng__Invoice__c >();
            Set<Id> setParentInvoiceClonedIds = new Set<Id>();
            
            /**
                Modified By: Yash Gupta
                @Description As per ticket no GGCKB-1, I have insert first invoice field as null and then update that id into rest of the invoices.
            */
            Integer hour = 0;
            Integer minunts = 0;
            DateTime timedifference = System.now();
            Boolean isFirstInvoice;
            List<blng__Invoice__c> lstFirstInvUpdate = new List<blng__Invoice__c>();
            List<blng__Invoice__c> lstRemainInvUpdate = new List<blng__Invoice__c>();
            
            // Creating the new Invoices by cloning first One.
            for (blng__Invoice__c invoice: idFirstInvoiceMap.values()) {
                List<blng__Invoice__c> lstClonedInvoices = new List<blng__Invoice__c>();
                Id quoteId = invoiceIdToQuoteIdMap.get(invoice.Id);
                System.debug('Invoice quote id ==> ' + quoteId);
                if(quoteId != null) {
                    SBQQ__Quote__c quote = quoteMap.get(quoteId);
                    Map<Integer, DeliveryDateUtilities.MileStoneEntry> deliveryDates = deliveryDateUtilityObj.deliveryDates(quote.Id,quote.SBQQ__Opportunity2__r.Custom_Payment__c);
                    System.debug('DeliveryDates ==> ' + deliveryDates);
                    quoteIdToDeliveryDates.put(quote.Id, deliveryDates);
                    if (deliveryDates.size() > 0) {
                        // Iterate over the rest of the payments starting with 1 as the first one should be the existing invoice
                        for (Integer scheduleNumber = 1; scheduleNumber <= deliveryDates.size(); scheduleNumber++) {
                            blng__Invoice__c cloneInvoice = invoice.clone(false, true);
                            cloneInvoice.Schedule_Number__c = scheduleNumber;
                           
                             /* History: 30/7/2019 :- Shiv Raghav Sharma for jira ticket https://informa-ge-sfdc.atlassian.net/browse/BK-29
                               Description :- Invoice Date Based on the Time Zone of the SSC */
                             if(invoice.blng__Order__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Event_Series__r.SSC_Details__r.Time_Zone_Difference__c != Null && scheduleNumber == 1)
                            {
                             Decimal timeDifferenceSSC = invoice.blng__Order__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Event_Series__r.SSC_Details__r.Time_Zone_Difference__c;                            
                             hour = timeDifferenceSSC.intValue();
                             minunts = (Integer)((timeDifferenceSSC - hour) * 60);
                             timedifference = System.now().addhours(hour).addMinutes(minunts);
                            }                           
                             //1. On the event Edition Create a checkbox "Post Invoice Immediately "Enhance the Invoice Handler Class, If yes, then all the invoices should be created with the invoice date of Today() //GGCW-1941
                            //-------------------------------------
                            if(invoice.Post_Invoice_Immediately__c){
                                  cloneInvoice.blng__InvoiceDate__c = timedifference.date();
                            }else{
                                 if(scheduleNumber == 1)
                                {                               
                                cloneInvoice.blng__InvoiceDate__c = timedifference.date();                                
                                }
                                else
                                {
                                cloneInvoice.blng__InvoiceDate__c = deliveryDates.get(scheduleNumber).milestoneDate;
                                }
                            }
                            //-------------------------------------
                            Date currentDate=System.today();
                            if(deliveryDates.get(scheduleNumber).milestoneDate==currentDate){
                                cloneInvoice.blng__DueDate__c=deliveryDates.get(scheduleNumber).milestoneDate;
                            }else{
                                cloneInvoice.blng__DueDate__c = (deliveryDates.get(scheduleNumber).milestoneDate).addDays((Integer) quote.Invoice_to_be_issued_before_in_Days__c);
                            }
                            cloneInvoice.blng__UniqueId__c = InvoiceUtilities.generateGUID();
                            cloneInvoice.blng__Order__c = invoiceIdToOrderIdMap.get(invoice.Id);
                            cloneInvoice.First_Invoice__c = invoice.Id;
                            cloneInvoice.Invoice_Heirarchy__c='Child Invoice';
                            cloneInvoice.invoice_percentage__c=(deliveryDates.get(scheduleNumber).milestonePercent);
                            cloneInvoice.blng__TaxStatus__c = 'Completed';
                            cloneInvoice.blng__TaxErrorMessage__c = '';
                            lstClonedInvoices.add(cloneInvoice);
                            //lstNewInvoices.add(cloneInvoice);
                            //setParentInvoiceClonedIds.add(invoice.Id);
                        }
                    }
                }
                //Canceling the first invoice and it's lines items.
                String sCancellAndRebillMsg = blng.InvoiceAPI.creditInvoice(invoice.Id, 'Cancel and Re-bill');
                System.debug('Is CancellAndRebill '+sCancellAndRebillMsg);
                If(sCancelSuccessMsg != NULL && sCancellAndRebillMsg.equalsIgnoreCase(sCancelSuccessMsg)){
                    lstNewInvoices.addAll(lstClonedInvoices);
                    setParentInvoiceClonedIds.add(invoice.Id);
                }
                //System.debug(blng.InvoiceAPI.creditInvoice(invoice.Id, 'Cancel and Re-bill'));
                //invoice.Invoice_Heirarchy__c = 'Child Created';
                //updatedInvoices.add(invoice);
            }
            // Insert new Invoices
            System.debug('NewInvoices ==> ' + lstNewInvoices);
            if(lstNewInvoices.size() > 0) {
                insert lstNewInvoices;
                 /**
                    Modified By: Yash Gupta
                    @Description As per ticket no GGCKB-1, I have insert first invoice field as null and then update that id into rest of the invoices.
                */
                isFirstInvoice = false;
                for(blng__Invoice__c iV : lstNewInvoices){
                    if(!isFirstInvoice){
                        iV.First_Invoice__c = Null;
                        lstFirstInvUpdate.add(iV);
                    } else {
                        iV.First_Invoice__c = lstFirstInvUpdate.get(0).Id;
                        lstRemainInvUpdate.add(iV);
                    }
                    isFirstInvoice = true;
                }
                if(lstFirstInvUpdate.size() > 0){ update lstFirstInvUpdate; }
                if(lstRemainInvUpdate.size() > 0){ update lstRemainInvUpdate; }
            }
            
            Map<Id, blng__Invoice__c> idLaterInvoiceMap = new Map<Id, blng__Invoice__c>([
                SELECT Id, Name, blng__Account__c, blng__ARStatus__c, blng__BillToContact__c, blng__DueDate__c, blng__InvoiceDate__c, blng__Notes__c,
                blng__Order__c, blng__PaymentBatch__c,TaxRate__c, blng__PaymentMethod__c, blng__InvoiceStatus__c,
                blng__TargetDate__c, blng__TaxErrorMessage__c, blng__TaxStatus__c, blng__UniqueId__c,
                blng__Order__r.SBQQ__Quote__c, blng__Order__r.SBQQ__Quote__r.SBQQ__Opportunity2__c,
                blng__Order__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.EventEdition__r.Payment_Schedule__c, Schedule_Number__c,blng__Order__r.Tax_Rate__c
                FROM blng__Invoice__c
                WHERE Id IN :lstNewInvoices AND Invoice_Heirarchy__c = 'Child Invoice' 
            ]);
            System.debug('idLaterInvoiceMap ==> ' + idLaterInvoiceMap.size() + ' keys: ' + idLaterInvoiceMap.keySet());
            
            Map<Id, List<Id>> quoteIdToInvoiceListMap = new Map<Id, List<Id>>();
            List<Id> mapInvoices;
            for (blng__Invoice__c invoice: idLaterInvoiceMap.values()) {
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
            System.debug('quoteIdToInvoiceListMap ==> ' + quoteIdToInvoiceListMap.size() + ' keys: ' + quoteIdToInvoiceListMap.keySet());
            
            List<blng__InvoiceLine__c> newInvoiceLines = new List<blng__InvoiceLine__c>();
            Map<Id,List<blng__InvoiceLine__c>> InvoiceLinesListByOrderItemId = new Map<Id,List<blng__InvoiceLine__c>>();
            Map<Id,Decimal> invoiceLinesTaxTotalByOrderItemId = new Map<Id,Decimal>();
            Map<Id,blng__InvoiceLine__c> lastInvoiceLinesByOrderItemId = new Map<Id,blng__InvoiceLine__c>();
            List<blng__InvoiceLine__c> finalNewInvoicelines = new List<blng__InvoiceLine__c> ();
            System.debug('quoteMap===>'+quoteMap);
            for (SBQQ__Quote__c quote: quoteMap.values()) {
                Id quoteId = quote.Id;
                Id firstInvoiceId = quoteToFirstInvoiceMap.get(quoteId);
                List<Id> lstClonedInvoiceIds = quoteIdToInvoiceListMap.get(quoteId);
                List<blng__InvoiceLine__c> lstParentInvLines = invoiceIdToInvoiceLinesMap.get(firstInvoiceId);
                
                Map<Integer, DeliveryDateUtilities.MileStoneEntry> deliveryDates = quoteIdToDeliveryDates.get(quoteId);
                System.debug('quote Name ==> '+quote.name);
                Map<Id,Decimal> OrderItemActualTaxTotal = new Map<Id,Decimal>();
                Map<Id,Decimal> OrderSubtotalTotal = new Map<Id,Decimal>();
                Map<Id,Decimal> TaxTotalSubscriptionBasedProducts = new Map<Id,Decimal>();
                Map<Id,Decimal> subTotalSubscriptionBasedProducts = new Map<Id,Decimal>();
                Decimal taxAdjusted = 0;
                Decimal subtotalAdjust = 0;
                Decimal subscriptionProductTaxAdjust = 0.00;
                Decimal subscriptionProductSubtotalAdjust = 0.00;
                // Clone new Invoice Lines
                if (lstParentInvLines != null && lstClonedInvoiceIds != null) {
                    system.debug('lstClonedInvoiceIds size ====>'+lstClonedInvoiceIds.size()+' == '+lstClonedInvoiceIds);
                    for (Id paymentInvoiceId: lstClonedInvoiceIds) {
                        blng__Invoice__c paymentInvoice = idLaterInvoiceMap.get(paymentInvoiceId);
                        DeliveryDateUtilities.MileStoneEntry milestoneEntry = deliveryDates.get(Integer.valueOf(paymentInvoice.Schedule_Number__c));
                        System.debug('Invoice No ==> '+paymentInvoice.Schedule_Number__c+' Percentage ==> '+milestoneEntry);
                        system.debug('lstParentInvLines.size====>'+lstParentInvLines.size()+'  == '+lstParentInvLines);
                        Decimal invoiceTotal=0.00;
                        //Decimal invoiceTaxTotal=0.00;
                        for (blng__InvoiceLine__c firstInvoiceLine: lstParentInvLines) {
                            OrderItem oitem = orderProductMap.get(firstInvoiceLine.blng__OrderProduct__c);
                            
                            blng__InvoiceLine__c newInvoiceLine = firstInvoiceLine.clone(false, true);
                            // Commented By Kumar : GGCW-2145
                            /*
                            Decimal dSAPTax ;
                            if(oitem.SAP_Tax_Rate__c != NULL){
                                dSAPTax = oitem.SAP_Tax_Rate__c ;
                            }else{
                                dSAPTax = paymentInvoice.blng__Order__r.Tax_Rate__c ;
                            }
                            */
                            
                            newInvoiceLine.blng__Invoice__c = paymentInvoiceId;
                            newInvoiceLine.blng__UniqueId__c = InvoiceUtilities.generateGUID();
                            newInvoiceLine.blng__TaxStatus__c = '';
                            newInvoiceLine.blng__TaxErrorMessage__c = '';
                            newInvoiceLine.blng__TaxAmount__c = 0.0;
                            // Commented By Kumar : GGCW-2145
                            //newInvoiceLine.blng__TaxTreatment__c = taxExemptTreatmentId;
                            if(deliveryDates.size() != paymentInvoice.Schedule_Number__c){
                                if(!newInvoiceLine.MDQ_Product__c){
                                    newInvoiceLine.blng__Subtotal__c = ((firstInvoiceLine.blng__Subtotal__c*milestoneEntry.milestonePercent)/100)+subtotalAdjust;
                                    Decimal subtotalActual = newInvoiceLine.blng__Subtotal__c ;
                                    newInvoiceLine.blng__Subtotal__c  = newInvoiceLine.blng__Subtotal__c.setscale(2);
                                    subtotalAdjust = (subtotalActual-newInvoiceLine.blng__Subtotal__c );
                                    System.debug('ABDUL SUBTOTAL NORMAL ==>  '+paymentInvoice.Schedule_Number__c +': Actual ==> '+subtotalActual+' Applied ==> '+newInvoiceLine.blng__Subtotal__c + ' Adjustment ==> '+subtotalAdjust);
                                    System.debug('PRDName '+paymentInvoice.Schedule_Number__c +':'+firstInvoiceLine.Name+' == SubTotal amount: ' + newInvoiceLine.blng__Subtotal__c);
                                    
                                    // Commented By Kumar : GGCW-2145
                                    /*
                                    newInvoiceLine.blng__TaxAmount__c = ((newInvoiceLine.blng__Subtotal__c*dSAPTax)/100)+taxAdjusted;
                                    Decimal taxActual = newInvoiceLine.blng__TaxAmount__c ;
                                    newInvoiceLine.blng__TaxAmount__c  = newInvoiceLine.blng__TaxAmount__c.setscale(2);
                                    taxAdjusted = (taxActual-newInvoiceLine.blng__TaxAmount__c );
                                    System.debug('ABDUL TAX NORMAL ==>  '+paymentInvoice.Schedule_Number__c +': Actual ==> '+taxActual+' Applied ==> '+newInvoiceLine.blng__TaxAmount__c + ' Adjustment ==> '+taxAdjusted);
                                    System.debug('PRDName '+paymentInvoice.Schedule_Number__c +':'+firstInvoiceLine.Name+' == Tax: ' + newInvoiceLine.blng__TaxAmount__c);
                                    */
                                }
                                else{
                                    newInvoiceLine.blng__Subtotal__c = ((firstInvoiceLine.blng__Subtotal__c*milestoneEntry.milestonePercent)/100)+subscriptionProductSubtotalAdjust;
                                    Decimal subtotalActual = newInvoiceLine.blng__Subtotal__c ;
                                    newInvoiceLine.blng__Subtotal__c  = newInvoiceLine.blng__Subtotal__c.setscale(2);
                                    subscriptionProductSubtotalAdjust = (subtotalActual-newInvoiceLine.blng__Subtotal__c );
                                    System.debug('ABDUL SUBTOTAL SUBS ==>  '+paymentInvoice.Schedule_Number__c +': Actual ==> '+subtotalActual+' Applied ==> '+newInvoiceLine.blng__Subtotal__c + ' Adjustment ==> '+subscriptionProductSubtotalAdjust);
                                    System.debug('PRDName '+paymentInvoice.Schedule_Number__c +':'+firstInvoiceLine.Name+' == SubTotal amount: ' + newInvoiceLine.blng__Subtotal__c);
                                    
                                    // Commented By Kumar : GGCW-2145
                                    /*
                                    newInvoiceLine.blng__TaxAmount__c = ((newInvoiceLine.blng__Subtotal__c*dSAPTax)/100)+subscriptionProductTaxAdjust;
                                    Decimal taxActual = newInvoiceLine.blng__TaxAmount__c ;
                                    newInvoiceLine.blng__TaxAmount__c  = newInvoiceLine.blng__TaxAmount__c.setscale(2);
                                    subscriptionProductTaxAdjust = (taxActual-newInvoiceLine.blng__TaxAmount__c );
                                    System.debug('ABDUL TAX SUBS ==>  '+paymentInvoice.Schedule_Number__c +': Actual ==> '+taxActual+' Applied ==> '+newInvoiceLine.blng__TaxAmount__c + ' Adjustment ==> '+subscriptionProductTaxAdjust);
                                    System.debug('PRDName '+paymentInvoice.Schedule_Number__c +':'+firstInvoiceLine.Name+' == Tax: ' + newInvoiceLine.blng__TaxAmount__c);
                                    */
                                }
                                
                                //================================================================================
                                if(OrderSubtotalTotal.containsKey(oitem.id))
                                {   
                                    // Commented By Kumar : GGCW-2145
                                    //Decimal tax = OrderItemActualTaxTotal.get(oitem.id)+newInvoiceLine.blng__TaxAmount__c;
                                    Decimal subtotal= OrderSubtotalTotal.get(oitem.id)+newInvoiceLine.blng__Subtotal__c;
                                    OrderSubtotalTotal.put(oitem.id,subtotal);
                                    //OrderItemActualTaxTotal.put(oitem.id,tax);
                                }
                                else{
                                    OrderSubtotalTotal.put(oitem.id,newInvoiceLine.blng__Subtotal__c);
                                    // Commented By Kumar : GGCW-2145
                                    //OrderItemActualTaxTotal.put(oitem.id,newInvoiceLine.blng__TaxAmount__c);
                                }
                                System.debug('Subtotal PRDName ==> '+paymentInvoice.Schedule_Number__c +':'+OrderSubtotalTotal);
                                System.debug('Tax PRDName ==> '+paymentInvoice.Schedule_Number__c +':'+OrderItemActualTaxTotal);
                                
                                //for subscription based products...
                                if(subTotalSubscriptionBasedProducts.containsKey(firstInvoiceLine.Id) && firstInvoiceLine.MDQ_Product__c){
                                    // Commented By Kumar : GGCW-2145
                                    //Decimal subscriptionproductTax = TaxTotalSubscriptionBasedProducts.get(firstInvoiceLine.Id)+newInvoiceLine.blng__TaxAmount__c;
                                    //TaxTotalSubscriptionBasedProducts.put(firstInvoiceLine.Id,subscriptionproductTax);
                                    Decimal subcriptionProductTotal = subTotalSubscriptionBasedProducts.get(firstInvoiceLine.Id)+newInvoiceLine.blng__Subtotal__c;
                                    subTotalSubscriptionBasedProducts.put(firstInvoiceLine.Id,subcriptionProductTotal);
                                }
                                else if(firstInvoiceLine.MDQ_Product__c){
                                    // Commented By Kumar : GGCW-2145
                                    //TaxTotalSubscriptionBasedProducts.put(firstInvoiceLine.Id,newInvoiceLine.blng__TaxAmount__c);
                                    subTotalSubscriptionBasedProducts.put(firstInvoiceLine.Id,newInvoiceLine.blng__Subtotal__c);
                                }
                            }
                            else{
                                //For subscription based products....
                                if(newInvoiceLine.MDQ_Product__c){
                                    newInvoiceLine.blng__Subtotal__c = firstInvoiceLine.blng__Subtotal__c - (subTotalSubscriptionBasedProducts.get(firstInvoiceLine.Id) !=null  ? subTotalSubscriptionBasedProducts.get(firstInvoiceLine.Id):0.00)+subtotalAdjust;
                                    Decimal subtotalActual = newInvoiceLine.blng__Subtotal__c ;
                                    newInvoiceLine.blng__Subtotal__c  = newInvoiceLine.blng__Subtotal__c.setscale(2);
                                    subtotalAdjust = (subtotalActual - newInvoiceLine.blng__Subtotal__c );
                                    //((firstInvoiceLine.blng__Subtotal__c*milestoneEntry.milestonePercent)/100).setScale(2);
                                    
                                    // Commented By Kumar : GGCW-2145
                                    //newInvoiceLine.blng__TaxAmount__c = (((firstInvoiceLine.blng__Subtotal__c*dSAPTax)/100))- (TaxTotalSubscriptionBasedProducts.get(firstInvoiceLine.Id) != null ?TaxTotalSubscriptionBasedProducts.get(firstInvoiceLine.Id):0.00)+taxAdjusted;
                                    //Decimal taxActual = newInvoiceLine.blng__TaxAmount__c ;
                                    //newInvoiceLine.blng__TaxAmount__c  = newInvoiceLine.blng__TaxAmount__c .setscale(2);
                                    //taxAdjusted = (taxActual-newInvoiceLine.blng__TaxAmount__c );
                                    
                                    //system.debug('Omnia PRDName map of tax : '+TaxTotalSubscriptionBasedProducts.get(firstInvoiceLine.Id));
                                    System.debug('omnia PRDName ==> '+paymentInvoice.Schedule_Number__c +':'+firstInvoiceLine.Name+' == SubTotal amount: ' + newInvoiceLine.blng__Subtotal__c);
                                    //System.debug('omnia PRDName ==> '+paymentInvoice.Schedule_Number__c +':'+firstInvoiceLine.Name+' == SubTotal with Tax: ' + newInvoiceLine.blng__TaxAmount__c);
                                }else{
                                    system.debug('oitem.TotalPrice==>'+oitem.TotalPrice);
                                    system.debug('OrderSubtotalTotal.get(oitem.id)==>'+OrderSubtotalTotal.get(oitem.id));
                                    newInvoiceLine.blng__Subtotal__c = oitem.TotalPrice - (OrderSubtotalTotal.get(oitem.id)!=null?OrderSubtotalTotal.get(oitem.id):0.00);
                                    System.debug('PRDName ==> '+paymentInvoice.Schedule_Number__c +':'+firstInvoiceLine.Name+' == SubTotal amount: ' + newInvoiceLine.blng__Subtotal__c);
                                    // Commented By Kumar : GGCW-2145
                                    /*
                                    newInvoiceLine.blng__TaxAmount__c = (oitem.Actual_Tax__c!=null?oitem.Actual_Tax__c:0.00) - (OrderItemActualTAxTotal.get(oitem.Id)!=null?OrderItemActualTAxTotal.get(oitem.Id):0.00);
                                    System.debug('PRDName ==> '+paymentInvoice.Schedule_Number__c +':'+firstInvoiceLine.Name+' == SubTotal with Tax: ' + newInvoiceLine.blng__TaxAmount__c);
                                    */
                                }
                            }
                            newInvoiceLines.add(newInvoiceLine);
                            invoiceTotal+= newInvoiceLine.blng__Subtotal__c;
                            //invoiceTaxTotal+=newInvoiceLine.blng__TaxAmount__c ;
                            //To adjust MDQ's Penny on equally...
                            // Commented By Kumar : GGCW-2145
                            /*
                            if(invoiceLinesTaxTotalByOrderItemId.containsKey(newInvoiceLine.blng__OrderProduct__c)){
                                invoiceLinesTaxTotalByOrderItemId.put(newInvoiceLine.blng__OrderProduct__c,invoiceLinesTaxTotalByOrderItemId.get(newInvoiceLine.blng__OrderProduct__c) + newInvoiceLine.blng__TaxAmount__c);
                                //lastInvoiceLinesByOrderItemId.put(newInvoiceLines.blng__OrderProduct__c,newInvoiceLines);
                                InvoiceLinesListByOrderItemId.get(newInvoiceLine.blng__OrderProduct__c).add(newInvoiceLine);
                            }else{
                                invoiceLinesTaxTotalByOrderItemId.put(newInvoiceLine.blng__OrderProduct__c,newInvoiceLine.blng__TaxAmount__c);
                                //lastInvoiceLinesByOrderItemId.put(newInvoiceLines.blng__OrderProduct__c,newInvoiceLines);
                                List<blng__InvoiceLine__c> lstNewILI = new List<blng__InvoiceLine__c>();
                                lstNewILI.add(newInvoiceLine);
                                InvoiceLinesListByOrderItemId.put(newInvoiceLine.blng__OrderProduct__c, lstNewILI);
                            }
                            */
                        }
                        //System.debug('PRDName ==> '+paymentInvoice.Schedule_Number__c +':'+'Invoice total'+invoiceTotal);
                        //System.debug('PRDName ==> '+paymentInvoice.Schedule_Number__c +':'+'Invoice Tax total'+invoiceTaxTotal);
                    }
                }
            }
            //System.debug('invoiceLinesTaxTotalByOrderItemIdSize ===> ' + invoiceLinesTaxTotalByOrderItemId.size()+' Values ==> '+invoiceLinesTaxTotalByOrderItemId.Values().Size()+' Valu==> '+invoiceLinesTaxTotalByOrderItemId);
            //System.debug('InvoiceLinesListByOrderItemIdSize ===> ' + InvoiceLinesListByOrderItemId.size()+' Values ==> '+InvoiceLinesListByOrderItemId.Values().Size()+' Valu==> '+InvoiceLinesListByOrderItemId);
            System.debug('Final newInvoiceLines ==> ' + newInvoiceLines);
            
            // Commented By Kumar : GGCW-2145
            /*
            if(invoiceLinesTaxTotalByOrderItemId != NULL && InvoiceLinesListByOrderItemId != NULL && invoiceLinesTaxTotalByOrderItemId.size() > 0 && InvoiceLinesListByOrderItemId.size() > 0){
                for(orderItem oitem : orderProductMap.values()){
                    Decimal difference = (oitem.Actual_Tax__c!=null?oitem.Actual_Tax__c:0.00) - invoiceLinesTaxTotalByOrderItemId.get(oitem.Id);
                    List<blng__InvoiceLine__c> lstTempILI = InvoiceLinesListByOrderItemId.get(oitem.Id) ;
                    if(difference != 0.00){
                        blng__InvoiceLine__c otemp = lstTempILI.get(lstTempILI.size()- 1) ;
                        //otemp.blng__TaxAmount__c+=difference;
                        lstTempILI.set(lstTempILI.size()- 1,otemp);
                        InvoiceLinesListByOrderItemId.put(oitem.Id, lstTempILI);
                    }
                    finalNewInvoicelines.addAll(lstTempILI);
                }
            }
            */
            System.debug('FinalNewInvoicelines ==> ' +finalNewInvoicelines.size()+' Val '+ finalNewInvoicelines);
           
            if (newInvoiceLines.size() > 0) {
                // We need to insert invoice lines separately for each invoice here.
                // This is because the create dates for invoice lines needs to be different across invoices
                //   in order for the Cancel & Rebill functionality to work correctly.
                // Cancel & Rebill will query order products and find the most recent invoices lines related to them.
                //   If the created dates match across invoices it will not necessarily be able to get invoice lines
                //   from a single invoice.  This was resulting in an error with a message: 'This invoice is not the latest invoice'.
                Set<Id> invoiceIds = new Set<Id>();
                Map<Id,List<blng__InvoiceLine__c>> invoiceLinesByInvoiceId = new Map<Id,List<blng__InvoiceLine__c>>();
                for (blng__InvoiceLine__c invoiceLine : newInvoiceLines) {
                //for (blng__InvoiceLine__c invoiceLine : finalNewInvoicelines) {
                    Id invoiceId = invoiceLine.blng__Invoice__c;
                    if (invoiceId != null) {
                        invoiceIds.add(invoiceId);
                        if (invoiceLinesByInvoiceId.containsKey(invoiceId)) {
                            invoiceLinesByInvoiceId.get(invoiceId).add(invoiceLine);
                        } else {
                            invoiceLinesByInvoiceId.put(invoiceId, new List<blng__InvoiceLine__c>{ invoiceLine });
                        }
                    }
                }
                System.debug('invoiceLinesByInvoiceId ==> ' +invoiceLinesByInvoiceId.size()+' Val '+ invoiceLinesByInvoiceId);
               
                List<blng__Invoice__c> invoicesOrderedByScheduleNumber = [SELECT Id FROM blng__Invoice__c WHERE Id IN :invoiceIds ORDER BY Schedule_Number__c DESC];
                System.debug('invoicesOrderedByScheduleNumber ' +invoicesOrderedByScheduleNumber.size()+' Val '+ invoicesOrderedByScheduleNumber);
                
                List<blng__InvoiceLine__c> lstNewInsertedILI = new List<blng__InvoiceLine__c>();
                for (blng__Invoice__c invoice : invoicesOrderedByScheduleNumber) {
                    List<blng__InvoiceLine__c> relatedInvoiceLines = invoiceLinesByInvoiceId.get(invoice.Id);
                    System.debug('relatedInvoiceLines ==> ' +relatedInvoiceLines.size()+' Val '+ relatedInvoiceLines);
                    insert relatedInvoiceLines;
                    lstNewInsertedILI.addAll(relatedInvoiceLines);
                }
                //Updating the first invoice status from 'Parent Invoice' to 'Invoice Created' and then Canceled the first invoices.
                /*if(!updatedInvoices.isEmpty() && updatedInvoices.size() > 0){
                    update updatedInvoices;
                    for(blng__Invoice__c invoice : updatedInvoices){
                        System.debug(blng.InvoiceAPI.creditInvoice(invoice.Id, 'Cancel and Re-bill'));
                    }
                }*/
                if(setParentInvoiceClonedIds.size() > 0){
                    List<blng__Invoice__c > updatedInvoices = new List<blng__Invoice__c >();
                    for(Id oId : setParentInvoiceClonedIds){
                        blng__Invoice__c oTempInvoice = new blng__Invoice__c();
                        oTempInvoice.Id = oId ;
                        oTempInvoice.Invoice_Heirarchy__c = 'Child Created';
                        updatedInvoices.add(oTempInvoice);
                    }
                    if(updatedInvoices.size() > 0){
                        update updatedInvoices;
                    }
                }
                if(!lstNewInsertedILI.isEmpty()){
                    List<blng__InvoiceLine__c> lstUpdateILIForTaxQueue = new List<blng__InvoiceLine__c>();
                    for(blng__InvoiceLine__c oTempILI : lstNewInsertedILI){
                        blng__InvoiceLine__c oILIToUpdate = new blng__InvoiceLine__c();
                        oILIToUpdate.Id = oTempILI.Id ;
                        oILIToUpdate.blng__TaxStatus__c = 'Queued';
                        lstUpdateILIForTaxQueue.add(oILIToUpdate);
                    }
                    if(!lstUpdateILIForTaxQueue.isEmpty()){
                        update lstUpdateILIForTaxQueue;
                    }
                }
            }
        }
        catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, 'InvoiceHandlerfromQuoteUtility ==> ' + ex.getMessage() + ' Stack: ' + ex.getStackTraceString());
            Expocad_Error__c ExError = new Expocad_Error__c();
            ExError.Parent_Id__c    = 'Invoice Id/s';
            ExError.Errors__c   = 'Message: '+ ex.getMessage() +   'Cause: ' +  ex.getCause() + '  Line number: ' + ex.getLineNumber() + ' Stack trace: ' +  ex.getStackTraceString() ;
            ExError.Description__c = '(InvoiceHandlerfromQuoteUtility Ex) Invoice Ids ==> ['+idFirstInvoiceMap.KeySet()+'], Values ==> [ '+idFirstInvoiceMap.Values()+' ]';
            Insert ExError ;
        }
    }
}