/**
* Project:     GAP
* Date:        27/03/2019
* Created By:  Rajesh Kumar
* Test Class:  UpdateAlternateCurrency_Test(87%)
* *************************************************************************
* @Description Class to calculate Alternate Currency Tax Amount in invoice .
* History: Last Update By Rajesh Kumar Yadav for the Ticket Number GGCW-2807
Date:- 1/8/2019 - Last Update by Shiv Raghav Sharma for the ticket https://informa-ge-sfdc.atlassian.net/browse/BK-2048
@Description - Invoice Number SFDC on SFDC should be assign only if invoice status change from draft to posted.
Modified by Shiv Raghav Sharma : https://informa-ge-sfdc.atlassian.net/browse/BK-2751
Modified by Shiv Raghav Sharma : BK-2986 (Apply condition - Vat Claculation should be done for Posted invoices only)
Modified By - Rajesh Kr - BK-4341 - 08-05-2020
Mofified by - Shiv Raghav Sharma bk-6941 - 04/12/2020
Ticket No.-BK-14522 Updating API Version
*/
public without sharing class UpdateAlternateCurrency_Class {
    List<blng__Invoice__c> newInvoiceLst             { get; set; }
    Map<Id, blng__Invoice__c> oldInvoiceMap          { get; set; }
    Boolean isInsert                        { get; set; }
    Boolean isupdate                        { get; set; }
    Boolean isBefore                        { get; set; }
    Boolean isAfter                         { get; set; }
    List<Id> invoiceIds                     { get; set; }
    Set<String> setLegalEntityCode          { get; set; }
    List<Id> lstOrderAndInvIds              { get; set; }
    Set<Id> setInvoiceIds                   { get; set; }
    // Set<String> setEventExcludedCountries   { get; set; }
    public UpdateAlternateCurrency_Class( List<blng__Invoice__c> newInvoiceLst, Map<id, blng__Invoice__c> oldInvoiceMap, Boolean isInsert, Boolean isupdate, Boolean isBefore, Boolean isAfter ) {
        this.newInvoiceLst    = newInvoiceLst;
        this.oldInvoiceMap    = oldInvoiceMap;
        this.isInsert     = isInsert;
        this.isupdate     = isupdate;
        this.isBefore     = isBefore;
        this.isAfter      = isAfter;
        invoiceIds        = new List<Id>();
        setLegalEntityCode = new Set<String>();
        lstOrderAndInvIds = new List<Id>();
        setInvoiceIds = new Set<Id>();
    }
    public void beforeTaxCalMethod () {
        for (blng__Invoice__c oInvoice : newInvoiceLst) {
            if (oInvoice.blng__InvoiceStatus__c == 'Posted') {
                invoiceIds.add(oInvoice.id);
                if (!String.isBlank(oInvoice.LegalEntityCode__c) && String.isBlank(oInvoice.Invoice_Number_SFDC__c)) {                    setLegalEntityCode.add(oInvoice.LegalEntityCode__c);
                                                                                                                     
                                                                                                                     }
            }
            //if(!oInvoice.Excluded_from_Invoice_WF__c ){
            //  invoiceIds.add(oInvoice.id);
            // }
        }
        
        if (!invoiceIds.isEmpty() && CheckRecursive.runtaxCalculation()) {
            Map<String, Decimal> mapLocalForeignCurrency =  new Map<String, Decimal>();
            Map<Id, String> mapInvoicewithLegalCountry =  new Map<Id, String>();
            /*GGCW-2807*/Map<String, Decimal> mapLocalForeignCurrencyGBP =  new Map<String, Decimal>();
            /*GGCW-2807*/Map<Id, String> mapInvowithLegalCountryGBP =  new Map<Id, String>();
            String currencyMap;
            String sCurrency;
            /*GGCW-2807*/String currencyMapGBP ;
            /*GGCW-2807*/Decimal sCurrencyGBP;
            Map<String, blng__LegalEntity__c> mapLegalEntityByCode ;
            //Get latest currency conversion value from currency master object.
            
            for (Currency_Master__c oCurrency : [SELECT LocalCurrency__c, ForeignCurrency__c, ExchangeRate__c, ExchangeRateDate__c FROM Currency_Master__c ORDER BY ExchangeRateDate__c DESC NULLS LAST LIMIT 5000]) {
                if (!mapLocalForeignCurrency.containsKey(oCurrency.LocalCurrency__c + 'To' + oCurrency.ForeignCurrency__c)) {
                    mapLocalForeignCurrency.put(oCurrency.LocalCurrency__c + 'To' + oCurrency.ForeignCurrency__c, oCurrency.ExchangeRate__c);
                    /*GGCW-2807*/mapLocalForeignCurrencyGBP.put(oCurrency.LocalCurrency__c + 'To' + oCurrency.ForeignCurrency__c, oCurrency.ExchangeRate__c);
                }
            }
            
            Map<Id, blng__Invoice__c> invMap = new map<Id, blng__Invoice__c>([SELECT Id,Event_Series_Alternate_Currency__c, blng__Order__r.Opportunity.Event_Series__r.Active_VAT_Tax_Alt_Currency__c, blng__Order__r.Opportunity.Event_Series__r.VAT_Tax_Alt_Currency__c,Billing_Country__c FROM blng__Invoice__c WHERE Id IN:invoiceIds]);
            
            
            for (blng__Invoice__c oInvoice : invMap.Values()) {
                if (oInvoice.blng__Order__r.Opportunity.Event_Series__r.Active_VAT_Tax_Alt_Currency__c && !String.isBlank(oInvoice.blng__Order__r.Opportunity.Event_Series__r.VAT_Tax_Alt_Currency__c)) {
                    mapInvoicewithLegalCountry.put(oInvoice.Id, oInvoice.blng__Order__r.Opportunity.Event_Series__r.VAT_Tax_Alt_Currency__c);
                    /*GGCW-2807*/mapInvowithLegalCountryGBP.put(oInvoice.Id, 'GBP');
                }
                // if (isInsert){
                // setEventExcludedCountries = new Set<String>(oInvoice.blng__Order__r.Opportunity.EventEdition__r.Excluded_Countries_Invoice_WF__c.split(';'));
                //// if (setEventExcludedCountries.contains(oInvoice.Billing_Country__c)){
                // oInvoice.Excluded_from_Invoice_WF__c = true;
                // }
                //}
            }
            //Kumar : GGCW-2063
            if (!setLegalEntityCode.isEmpty()) {
                List<blng__LegalEntity__c> lstLegalEntity = [SELECT Id, Invoice_Number_Prefix__c, Latest_Invoice_Number__c, Legal_Entity_Code__c FROM blng__LegalEntity__c WHERE Legal_Entity_Code__c IN: setLegalEntityCode AND Invoice_Number_Prefix__c != NULL AND Latest_Invoice_Number__c != NULL FOR UPDATE];
                if (lstLegalEntity != NULL && lstLegalEntity.size() > 0) {                    mapLegalEntityByCode = new Map<String, blng__LegalEntity__c>();
                                                                          for (blng__LegalEntity__c oLegalEntity : lstLegalEntity) {                        mapLegalEntityByCode.put(oLegalEntity.Legal_Entity_Code__c, oLegalEntity);                    }
                                                                         }
            }
            //End GGCW-2063 //
            
            for (blng__Invoice__c oInvoice : newInvoiceLst) {
                
                if (!invMap.isEmpty() && invMap.containsKey(oInvoice.Id) && invMap.get(oInvoice.Id).blng__Order__r.Opportunity.Event_Series__r.Active_VAT_Tax_Alt_Currency__c && oInvoice.Event_Series_Alternate_Currency__c != NULL) {
                    currencyMap = sCurrency = null;
                    /*GGCW-2807*/currencyMapGBP = null;
                    currencyMap = oInvoice.Default_Currency__c + 'To' + oInvoice.Event_Series_Alternate_Currency__c;
                    //sCurrency = mapInvoicewithLegalCountry.get(oInvoice.Id);
                   // /*GGCW-2807*/currencyMapGBP = oInvoice.Default_Currency__c + 'To' + mapInvowithLegalCountryGBP.get(oInvoice.Id);
                    //sCurrencyGBP = mapLocalForeignCurrencyGBP.get(currencyMapGBP);
                    
                        if (currencyMap != NULL && mapLocalForeignCurrency.containsKey(currencyMap) && oInvoice.blng__InvoiceStatus__c == 'Posted' && oInvoice.VATTaxExchangeRate__c == null ) {
                            
                            oInvoice.VATTaxExchangeRate__c = mapLocalForeignCurrency.get(currencyMap);
                            
                            if (oInvoice.VATTaxExchangeRate__c != NULL && oInvoice.blng__TaxAmount__c != NULL) {
                                Decimal dTax = oInvoice.blng__TaxAmount__c * oInvoice.VATTaxExchangeRate__c;
                                String sTax = '';  
                                if (dTax == 0) { sTax = '0.00'; } 
                                else {
                                    sTax = Utility.currencyFormat(String.valueOf(dTax.setScale(2)));
                                    if (sTax.substringAfter('.').length() == 1) { sTax += '0';  }
                                }
                                //bk-6941
                                oInvoice.VAT_Tax_Alt_Country_Currency__c = oInvoice.Event_Series_Alternate_Currency__c + ' ' + sTax;
                            }
                            
                        }                   
                }
                /*
else {
currencyMap = oInvoice.Default_Currency__c+'To'+oInvoice.Alternate_Currency__c;
sCurrency = oInvoice.Alternate_Currency__c;
}*/
                /*GGCW-2807*/
                //Commentted code after discussion with my Team and we are making centralized and configurable behalf of BK-11323 on 03-12-2020

                /*if (mapLocalForeignCurrencyGBP.containsKey(currencyMapGBP) && oInvoice.blng__InvoiceStatus__c == 'Posted' && oInvoice.VAT_Tax_Exchange_Rate_GBP__c == null){
                    /*GGCW-2807*/
                    /*oInvoice.VAT_Tax_Exchange_Rate_GBP__c = sCurrencyGBP;if (oInvoice.VAT_Tax_Exchange_Rate_GBP__c != NULL && oInvoice.blng__TaxAmount__c != NULL) {
                        Decimal dGBPTax = oInvoice.blng__TaxAmount__c * sCurrencyGBP; String sGBPTax = ''; 
                        if (dGBPTax == 0) { sGBPTax = '0.00'; } else {
                            sGBPTax = Utility.currencyFormat(String.valueOf(dGBPTax.setScale(2)));                       if (sGBPTax.substringAfter('.').length() == 1) { sGBPTax += '0'; }
                        }
                        /*GGCW-2807*/
                        /*oInvoice.VAT_Tax_Alt_Country_Currency_In_GBP__c = 'GBP' + ' ' + sGBPTax;
                    }
                } */
                
                If(mapLegalEntityByCode != NULL && mapLegalEntityByCode.Size() > 0 && !String.isBlank(oInvoice.LegalEntityCode__c) && mapLegalEntityByCode.containsKey(oInvoice.LegalEntityCode__c)) {
                    /*Date:- 1/8/2019 - Last Update by Shiv Raghav Sharma for the ticket https://informa-ge-sfdc.atlassian.net/browse/BK-2048
@Description - Invoice Number SFDC on SFDC should be assign only if invoice status change from draft to posted.*/
                    if (oInvoice.blng__InvoiceStatus__c == 'Posted' &&  oldInvoiceMap.get(oInvoice.ID).blng__InvoiceStatus__c == 'Draft') {
                        blng__LegalEntity__c oTempLegalEntity = mapLegalEntityByCode.get(oInvoice.LegalEntityCode__c);                        System.debug('Legal Entity' + oTempLegalEntity);
                        String sPrefix = oTempLegalEntity.Invoice_Number_Prefix__c;                        String sLatestNo = oTempLegalEntity.Latest_Invoice_Number__c;
                        Integer iLatestNo = Integer.ValueOf(sLatestNo);                        String sPadedNo = String.ValueOf(iLatestNo + 1).leftPad(sLatestNo.length(), '0');
                        String sInvoiceNoSFDC = sPrefix + '-' + sPadedNo;                        oInvoice.Invoice_Number_SFDC__c = sInvoiceNoSFDC ;
                        oTempLegalEntity.Latest_Invoice_Number__c = sPadedNo;                        mapLegalEntityByCode.put(oInvoice.LegalEntityCode__c, oTempLegalEntity);
                    }
                }
            }
            If(mapLegalEntityByCode != NULL && mapLegalEntityByCode.Size() > 0) {                update mapLegalEntityByCode.Values() ;            }
        }
    }
    
    
    public void afterMethodforAsync () {
        //Posted Validation, CyberSource Payment Process on Posted Status.
        for (blng__Invoice__c oInvoice : newInvoiceLst) {
            //Commented By Rajesh Kumar - BK-3718
            /* if (oInvoice.blng__InvoiceStatus__c != oldInvoiceMap.get(oInvoice.Id).blng__InvoiceStatus__c && oInvoice.blng__InvoiceStatus__c == 'Posted' && !String.isBlank(oInvoice.Online_Booth_Capture_ID__c) && oInvoice.Online_Booth_Capture_Payment_Type__c == 'CreditCard' && String.isBlank(oInvoice.MCAS_ID__c)) {
if (checkRecursive.runOnceForInvoice()) {                    ChargeInvoiceByCS.AsyncChargeCyberSource(oInvoice.Id);                }
} */
            //GGCW-3306 Start RajeshKr
            if (oInvoice.blng__InvoiceStatus__c != oldInvoiceMap.get(oInvoice.Id).blng__InvoiceStatus__c && oInvoice.blng__InvoiceStatus__c == 'Posted') {
                setInvoiceIds.add(oInvoice.Id);
            }
        }
        if (!setInvoiceIds.isEmpty()) {
            Map<Id , blng__InvoiceLine__c> mapInvoicelines = new Map<Id , blng__InvoiceLine__c> ([Select id, blng__Invoice__c, blng__InvoiceLineStatus__c  from blng__InvoiceLine__c where blng__Invoice__c IN:setInvoiceIds]);
            if (!mapInvoicelines.isEmpty()) {
                for (blng__InvoiceLine__c oInvoiceLines : mapInvoicelines.values()) {
                    if (oInvoiceLines.blng__InvoiceLineStatus__c != 'Posted') {                        oInvoiceLines.blng__InvoiceLineStatus__c = 'Posted';                    }
                }
                update mapInvoicelines.values();
            }
        }//GGCW-3306 END
    }
    //I have merged code this class from invoice trigger.
    public void showValidMsgUpdateConga () {
        //Modified By Kumar : GGCW-1976
        if (isupdate) {
            for (blng__Invoice__c tempInv : newInvoiceLst) {
                if (isBefore) {
                    if (tempInv.Invoice_Heirarchy__c == 'Child Invoice') {
                        String sDateFormat = 'dd/MM/yyyy';
                        Country_Date_Format__c oDateFormat = Country_Date_Format__c.getValues(tempInv.Event_Series_Country_Informa__c);
                        if (oDateFormat != Null && !String.isBlank(oDateFormat.Date_Format__c)) {                            sDateFormat = oDateFormat.Date_Format__c ;
                                                                                                }
                        tempInv.conga_due_date__c = DateTime.newInstance( tempInv.blng__DueDate__c, Time.newInstance(0, 0, 0, 0)).format(sDateFormat);
                        tempInv.conga_invoice_date__c = DateTime.newInstance( tempInv.blng__InvoiceDate__c, Time.newInstance(0, 0, 0, 0)).format(sDateFormat);
                    }
                } else {
                    if (tempInv.blng__InvoiceStatus__c == 'Posted' && oldInvoiceMap.get(tempInv.Id).blng__InvoiceStatus__c != tempInv.blng__InvoiceStatus__c ) {
                        If(tempInv.Do_Not_Post_Invoice__c) { tempInv.addError(System.Label.Invoice_Posted_Error);}
                        else if (tempInv.blng__InvoiceDate__c != Date.Today() || tempInv.blng__DueDate__c < Date.Today()) {tempInv.addError(System.Label.Post_invoice_with_past_date_error_msg);}
                    } else if (tempInv.blng__InvoiceStatus__c == 'Posted' && oldInvoiceMap.get(tempInv.Id).blng__InvoiceStatus__c != tempInv.blng__InvoiceStatus__c && tempInv.BA_review_Required__c  && !tempInv.BA_approved__c) {                        tempInv.addError(System.Label.BA_Review);
                                                                                                                                                                                                                                  }
                    //Modified By Kumar : GGCW-1976
                    if (tempInv.blng__InvoiceStatus__c == 'Posted' && oldInvoiceMap.get(tempInv.Id).blng__InvoiceStatus__c != tempInv.blng__InvoiceStatus__c) {
                        lstOrderAndInvIds.add(tempInv.blng__Order__c);
                        lstOrderAndInvIds.add(tempInv.Id);
                    }
                }
            }
            //Modified By Kumar : GGCW-1976
            if (!lstOrderAndInvIds.isEmpty() && isAfter) {
                Map<Id, Decimal> mapOrderVsInviceSN = new Map<Id, Decimal>();
                List<blng__Invoice__c> lstInv = [SELECT Id, Schedule_Number__c, blng__Order__c FROM blng__Invoice__c WHERE blng__Order__c IN:lstOrderAndInvIds AND blng__InvoiceStatus__c = 'Posted' AND Id NOT IN :lstOrderAndInvIds ORDER BY Schedule_Number__c DESC];
                if (lstInv != NULL) {
                    for (blng__Invoice__c oInv : lstInv) {                        If(!mapOrderVsInviceSN.containsKey(oInv.blng__Order__c)) {                            mapOrderVsInviceSN.put(oInv.blng__Order__c, oInv.Schedule_Number__c);
                                                                                                                                           }
                                                         }
                }
                for (blng__Invoice__c oInv : newInvoiceLst ) {
                    if (oInv.Schedule_Number__c != 1 && (mapOrderVsInviceSN == Null || mapOrderVsInviceSN.get(oInv.blng__Order__c) == Null)) {                        oInv.addError(System.label.first_invoice_is_not_posted);
                                                                                                                                             }
                    if (mapOrderVsInviceSN != Null && mapOrderVsInviceSN.get(oInv.blng__Order__c) != Null && (mapOrderVsInviceSN.get(oInv.blng__Order__c) + 1) != oInv.Schedule_Number__c) {                        oInv.addError(System.label.Invoice_post_order_error);
                                                                                                                                                                                           }
                }
            }
        }
    }
    /*
Created By - Shiv Raghav Sharma
Date - 31/10/2019
Ticket No - BK-2751
Description - This method use to post a chatterfeed on parent opportunity of invoice with invoice cancellation reason.
*/
    public void invoiceCancelReasonAndChatterFeedPostOnOpportunity() {
        List<FeedItem> feeditemList = new List<FeedItem>();
        Application_Bypass__c appBypass = Application_Bypass__c.getInstance();
        for (blng__Invoice__c oInvoice : newInvoiceLst) {
            if (oInvoice.blng__InvoiceStatus__c == 'Rebilled' &&  oldInvoiceMap.get(oInvoice.ID).blng__InvoiceStatus__c == 'Posted' && !appBypass.Bypass_Validation_For_Cancel_Rebill__c ) {
                if (String.isBlank(oInvoice.Cancellation_Reason__c))
                 {                   
                
                 oInvoice.addError('Please fill value in cancellation reason');
                                                                     } 
                                                                     else {
                                                                         FeedItem fd = new FeedItem(); fd.ParentId = oInvoice.OpportunityId__c; fd.Body = oInvoice.Invoice_Number__c + ' - ' + oInvoice.Cancellation_Reason__c; feeditemList.add(fd);
                                                                     }
            }
        }
        if (!feeditemList.isEmpty()) {            insert feeditemList;
                                     }
    }

}