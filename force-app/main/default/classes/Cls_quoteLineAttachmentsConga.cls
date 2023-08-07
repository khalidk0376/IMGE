/**
* File:        cls_quoteLineAttachmentsConga.cls
* Project:     GAP
* Date:        9/8/2017
* Test Class : cls_quoteLineAttachmentsConga_Test.cls(87%)
* Created By:  Abdul Kadir
* Modified By: Rajesh Kumar
* Modified Date: 2/6/2019
* *************************************************************************
* Description: This class validate primary quote,billing and Quote line items(Products) added to this quote after that it generate conga template and send it to primary contact's email through docusign.
* *************************************************************************
* History: As per ticket GGCW-2681, I have correct the verbiage using the new custom label "Label_Billing_Contact_Missing".
* Modified By : RaJesh Kumar 03/01/2019 on GGCW-2387
* Modified By : Akshi Arora on 05/15/2019 for GGCKB-20
* Modified By : Avinash Shukla BK-2871/BK-2973/74,Akshi Arora for BK-2871/BK-2973/74
* Modified By : Rajesh kumar yadav BK-3326/3392, [Aishwarya BK-4271,4362 May 28 2020], [Aishwarya BK-5009 June 2 2020],[Aishwarya BK-5477 30 June 2020],[BK-6385/6386 Aishwarya 27 July 2020]
* Modified By : [Aishwarya BK-7477 Aug 14 2020]
* Modified By : Rajesh kumar yadav BK-4270('&DocuSignR5ID=' + oQuote.ID) and congaAdditionalParamsBrazil

* Modified By : Rajesh Kumar - BK-10316 on 06-11-2020 
 
*/
public class Cls_quoteLineAttachmentsConga {
    
    //Variables Declaration
    public string quoteId { get; set;}
    public string sessionId;
    public string serverURL;
    public string ids {get;set;}
    public string template {get;set;}
    public set < id > qliIdsSet = new set < id > ();
    public list <ContentDocumentLink> lstContentDocumentLinks {get;set;}
    public List <contentversion> lstcontentversion {get; set;}
    public list < String > attachmentIds {get;set;}
    public SBQQ__Quote__c oQuote {get;set;}
    public string docName {get;set;}
    public string sMessage {get;set;}
    public list < SBQQ__RelatedContent__c > additnlDoc {get;set;}
    public boolean nullQuoteLines {get;set;}
    public map < String, String > checkMandatory {get;set;}
    public String chkContains {get;set;}
    public boolean disabledContinue {get;set;}
    public String companyCountry {get;set;}
    public Map <Id, SBQQ__QuoteLine__c > prodQuoteLineMap {get;set;}
    public Account acct {get;set;}
    public String accountId {get;set;}
    public String addressString {get;set;}
    public List <Account > inDirectAccount {get;set;}
    public Boolean isWarningMsg {get; set;}
    public String sWarningMsg {get;set;}
    public List <Account > lstAccount {get;set;}
    //BK-6268
    public SBQQ__Quote__c oQuoteTCID {get;set;}
    //BK-13894 Shiv Raghav
    public String termAndCondition = '';
    //Constructor
    public Cls_quoteLineAttachmentsConga(ApexPages.StandardController controller) {

        quoteId = ApexPages.currentPage().getParameters().get('quoteId').escapeHtml4();
        sessionId = ApexPages.currentPage().getParameters().get('SessionId').escapeHtml4();
        serverURL = ApexPages.currentPage().getParameters().get('ServerUrl').escapeHtml4();
      // Added by Palla Kishore for the ticket BK-19643
       User u = [select Id, Profile.Name, UserRole.Name from User Where Id =: UserInfo.getUserId()];

        checkMandatory = new Map < String, String > ();
        attachmentIds = new list < String > ();
        disabledContinue = isWarningMsg = nullQuoteLines = false;
        chkContains = sWarningMsg = '';
        String sAccountId = '';
        SBQQ__QuoteLine__c tempQLI;
        template = 'null';
        String opptyId = '';
        Set < Id > setPrdIds = new Set < Id > ();
         // Modified by Palla Kishore for the ticket BK-19643
        oQuote = [select id,Approval_Status__c,Maximum_Discount__c,Event_Edition_Name__c,SBQQ__Opportunity2__r.EventEdition__r.Mix_Supply_Terms_and_Condition__c,SBQQ__Opportunity2__r.EventEdition__r.Part_of_Series__r.Event_Series_Code__c, SBQQ__Opportunity2__r.EventEdition__r.Part_of_Series__r.Legal_Entity__r.VAT_Declaration_Template__c,SBQQ__Opportunity2__r.Event_Series__r.Legal_Entity__r.Supplier_License_Number__c,SBQQ__Opportunity2__r.Event_Series__r.Legal_Entity__r.blng__Country__c,SBQQ__Type__c, Name,Is_delegate_Opportunity__c,SBQQ__Opportunity2__r.EventEdition__r.DS_Terms_Condition_Template__c,Witness_Contact__c, ISO_Code_Logo__c,Online_Opportunity_Quote_Check__c,Online_Opportunity_Quote__c, Event_Series_Country__c, SBQQ__Opportunity2__r.Total_FOC_Product_Count__c,SBQQ__Opportunity2__r.Is_Barter_Opportunity__c, SBQQ__Opportunity2__r.Witness_Contact__c, SBQQ__Opportunity2__r.Legal_Representative_1__c, Product_Attachments__c, SBQQ__Opportunity2__r.Custom_Payment__c, SBQQ__PrimaryContact__c, Primary_Contact_Info__c, documentType__c, Next_Version__c, conga_quote_template_id__c, term_conditionIds__c, SBQQ__Opportunity2__r.EventEdition__r.Alternative_Terms_Condition_Template__c,SBQQ__Opportunity2__r.EventEdition__r.Terms_Condition_Template__c,conga_contract_template_id__c, Quote_Event_Edition__c, Is_a_Local_Company__c, Payment_Schedule_amount__c, SBQQ__Opportunity2__r.EventEdition__r.Contract_Special_Conditions__c ,Payment_Schedule_percent__c, Cutoff_Date__c, Cutoff_Date_1__c, Cutoff_Date_2__c, Cutoff_Date_3__c, SBQQ__NetAmount__c, ISO_Code__c, SBQQ__Opportunity2__c, SBQQ__Opportunity2__r.EventEdition__c, InvoicetoStartDate__c, Invoice_to_Start_Date_Cut_Off_Date1__c, Invoice_to_Start_Date_Cut_Off_Date2__c, Invoice_to_Start_Date_Cut_Off_Date3__c, Invoice_to_be_issued_before_in_Days__c, SBQQ__Opportunity2__r.stageName, SBQQ__Status__c, Billing_Contact__c, Billing_Contact__r.Address_Verified__c, Manual__c, National_contract_and_TC_Ids__c, Quote_Line_Deliverables__c, Show_Deliverables__c, SBQQ__Account__c, Event_Director__c, Allow_Docusign_Counter_Sign__c, SBQQ__Account__r.Accounting_Credit_Hold__c, Contract_Type__c,SBQQ__Account__r.BillingCountry,SBQQ__Account__r.Simples_Nacional__c,SBQQ__Account__r.National_Classification__c,SBQQ__Account__r.BillingStreet,SBQQ__Account__r.BillingCity,SBQQ__PrimaryContact__r.FirstName,SBQQ__PrimaryContact__r.LastName,SBQQ__Opportunity2__r.Name,SBQQ__Opportunity2__r.Address_Validation_Bypass__c from SBQQ__Quote__c where id =: quoteId limit 1];
        system.debug('oQuote >>> ' + oQuote);
        oQuote.documentType__c = '';
        //BK-13894 Shiv Raghav
        
        if(oQuote.Is_delegate_Opportunity__c && oQuote.SBQQ__Opportunity2__r.EventEdition__r.DS_Terms_Condition_Template__c != Null)
        {
            termAndCondition = oQuote.SBQQ__Opportunity2__r.EventEdition__r.DS_Terms_Condition_Template__c;
        }
        else
        {      
            if(oQuote.Online_Opportunity_Quote_Check__c && oQuote.SBQQ__Opportunity2__r.EventEdition__r.Alternative_Terms_Condition_Template__c != null)
            {
                termAndCondition = oQuote.SBQQ__Opportunity2__r.EventEdition__r.Alternative_Terms_Condition_Template__c;
            }
            else if(oQuote.SBQQ__Opportunity2__r.EventEdition__r.Terms_Condition_Template__c != null)
            {
                termAndCondition = oQuote.SBQQ__Opportunity2__r.EventEdition__r.Terms_Condition_Template__c;
            }
        }
        
        list < SBQQ__QuoteLine__c > objQLIList = [select id, SBQQ__Quote__r.SBQQ__Opportunity2__c, SBQQ__Product__r.Delegate_Product__c,SBQQ__Product__c, SBQQ__Quote__c, SBQQ__Quote__r.SBQQ__Account__c, SBQQ__Product__r.id, SBQQ__Product__r.Name, SBQQ__Product__r.Description, SBQQ__Product__r.Description_in_Alt_Language__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteId Order By SBQQ__Product__r.name Asc];
        prodQuoteLineMap = new Map < Id, SBQQ__QuoteLine__c > ();
        lstAccount = new List < Account > ();
        if (oQuote.SBQQ__Account__c != null) {
            lstAccount = [select Id, Name, BillingStreet, Billing_Address_Line_2__c, BillingCity, BillingState,
                          Billingpostalcode, BillingCountry, type from Account where id =: oQuote.SBQQ__Account__c
                         ];
            if (lstAccount.size() > 0) {
                acct = lstAccount.get(0);
                addressString = acct.BillingStreet != null ? acct.BillingStreet + '\n' : '';
                addressString += acct.Billing_Address_Line_2__c != null ? acct.Billing_Address_Line_2__c + '\n' : '';
                if (string.isBlank(acct.BillingState) && string.isBlank(acct.Billingpostalcode)) {
                    addressString += acct.BillingCity != null ? acct.BillingCity : '';} else {addressString += acct.BillingCity != null ? acct.BillingCity + ', ' : '';}
                addressString += acct.BillingState != null ? acct.BillingState + ' ' : '';
                addressString += acct.Billingpostalcode != null ? acct.Billingpostalcode + '\n' : '\n';
                addressString += acct.BillingCountry != null ? acct.BillingCountry + '\n' : '';
                oQuote.AddressOnTemplate__c = AddressString;
                if (oQuote.Billing_Contact__c != null) {
                    inDirectAccount = new CongaUtilities().AddressSelection(oQuote.Billing_Contact__c, oQuote.SBQQ__Account__c);} else {inDirectAccount = new List <Account > ();inDirectAccount.add(acct);}
            }
        }
        for (SBQQ__QuoteLine__c qline: objQLIList) {prodQuoteLineMap.put(qline.SBQQ__Product__c, qline);             setPrdIds.add(qline.Id);
        }
        //Validating products are added to the quote or not.
        if (objQLIList.isEmpty()) {
            nullQuoteLines = true;
            sMessage = 'There are no product(s) available on this quote, please add products for this quote.';
        }
        
                 
      /*BK-22779 Added this to check mixed product in quote Line*/
        integer countDelegate=0;
        integer countNonDelegate=0;
       System.debug('test=='+objQLIList);
      if(!objQLIList.isEmpty()){
            for(SBQQ__QuoteLine__c sbquote:objQLIList){
                  
                   if(sbquote.SBQQ__Product__r.Delegate_Product__c){ 
                       countDelegate=countDelegate+1;         
                   }
                   else if(!sbquote.SBQQ__Product__r.Delegate_Product__c){
                       countNondelegate=countNonDelegate+1;
                   }          
            }
              System.debug('countDelegate=='+countDelegate);
              System.debug('countNonDelegate=='+countNonDelegate);
              System.debug('countNonDelegate=='+oQuote.SBQQ__Opportunity2__r.EventEdition__r.Mix_Supply_Terms_and_Condition__c);

            if(countDelegate>0 && countNonDelegate>0 && oQuote.SBQQ__Opportunity2__r.EventEdition__r.Mix_Supply_Terms_and_Condition__c != Null){
                   termAndCondition=oQuote.SBQQ__Opportunity2__r.EventEdition__r.Mix_Supply_Terms_and_Condition__c;
                   oQuote.Mixed_Product_Term_Check__c=true;
                   System.debug('termAndCondition=='+termAndCondition);
                }
            else if(countDelegate>0 && countNonDelegate==0 && oQuote.SBQQ__Opportunity2__r.EventEdition__r.DS_Terms_Condition_Template__c != Null){
                    termAndCondition = oQuote.SBQQ__Opportunity2__r.EventEdition__r.DS_Terms_Condition_Template__c;
                    oQuote.Mixed_Product_Term_Check__c=false;
                   
                }
            else if(countDelegate==0 && countNonDelegate>0 && oQuote.SBQQ__Opportunity2__r.EventEdition__r.Terms_Condition_Template__c != null){
                    termAndCondition = oQuote.SBQQ__Opportunity2__r.EventEdition__r.Terms_Condition_Template__c;
                    oQuote.Mixed_Product_Term_Check__c=false;
                }
            else if(oQuote.Online_Opportunity_Quote_Check__c && oQuote.SBQQ__Opportunity2__r.EventEdition__r.Alternative_Terms_Condition_Template__c != null)
            {
                termAndCondition = oQuote.SBQQ__Opportunity2__r.EventEdition__r.Alternative_Terms_Condition_Template__c;
                oQuote.Mixed_Product_Term_Check__c=false;

            }
         
        }  
         // Added by Palla Kishore for the ticket BK-27325
           Map<String,VAT_Declaration_Template__mdt> mapVatcmd = VAT_Declaration_Template__mdt.getAll();
         // Added by Palla Kishore for the ticket BK-20651
           if(oQuote.SBQQ__Opportunity2__r.Event_Series__r.Legal_Entity__r.blng__Country__c == 'United Arab Emirates' && oQuote.SBQQ__Account__r.BillingCountry != 'United Arab Emirates' && oQuote.SBQQ__Opportunity2__r.EventEdition__r.Part_of_Series__r.Legal_Entity__r.VAT_Declaration_Template__c != null)
            {
               if(mapVatcmd.containskey(oQuote.SBQQ__Opportunity2__r.EventEdition__r.Part_of_Series__r.Event_Series_Code__c)){
                if(String.isNotBlank(termAndCondition)){
                termAndCondition = oQuote.SBQQ__Opportunity2__r.EventEdition__r.Part_of_Series__r.Legal_Entity__r.VAT_Declaration_Template__c + ',' + termAndCondition;
                }else {
                  termAndCondition = oQuote.SBQQ__Opportunity2__r.EventEdition__r.Part_of_Series__r.Legal_Entity__r.VAT_Declaration_Template__c; 
                }
              }
            }
         /*BK-22779 Added this to check mixed product in quote Line*/


        // Validating Billing Contact is not null.
        for (Opportunity opp: [select id, Opportunity_Contact__c, Billing_Contact__c from Opportunity where id =: opptyId]) {if (opp.Billing_Contact__c == null) {nullQuoteLines = true;sMessage = 'Billing/Invoice Contact on the Opportunity is blank. Please select one.';
            }
        }
        try {
            if (!setPrdIds.isEmpty()){                lstContentDocumentLinks = new List<ContentDocumentLink>([SELECT Id, LinkedEntityId, ContentDocumentId, Visibility, ShareType FROM ContentDocumentLink  where LinkedEntityId IN : setPrdIds ]) ; 
                if (!lstContentDocumentLinks.isEmpty()){
                    for (ContentDocumentLink temp: lstContentDocumentLinks) {attachmentIds.add(temp.ContentDocumentId);
                    }
                    lstcontentversion = [SELECT Id, Title, PathOnClient, VersionData, OwnerId, ContentDocumentId FROM ContentVersion where ContentDocumentId IN: attachmentIds  Order By LastModifiedDate Desc LIMIT 1 ]; 
                }
            }
                                   
            additnlDoc = new list < SBQQ__RelatedContent__c > ([select id, external_Id_18__c from SBQQ__RelatedContent__c where external_Id_18__c in: attachmentIds]);
            for (SBQQ__RelatedContent__c temp: additnlDoc) {chkContains += temp.external_Id_18__c;
            }
        } 
        catch (exception ex) {
            //Added by Palla Kishore for the ticket BK-19603
             System.debug('The following exception has occurred: ' + ex);
            //Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'Constructor(@cls_quoteLineAttachmentsConga.Class)');
        }
        //Validate Billing Contact /Primary Contact's Account's Billing Address with SAP api.
        if (oQuote.Billing_Contact__c != null) {
            // Modified By Palla Kishore for the ticket BK-24173
            if (oQuote.Billing_Contact__r.Address_Verified__c == false && oQuote.SBQQ__Opportunity2__r.Address_Validation_Bypass__c == false) {
                nullQuoteLines = true;
                sMessage = 'Billing Contact\'s Account Address is not Valid, Please make required changes and try again.';
            }
        }
        // validating Billing/Invoice Contact on the Quote is blank or not.
        if (oQuote.Billing_Contact__c != null && CongaUtilities.isBillingAddressNull(oQuote.Billing_Contact__c)) {nullQuoteLines = true;sMessage = 'Incomplete Address on the billing contact,  please fill the address and try again.';
        }
        if (oQuote.Manual__c == true) {nullQuoteLines = true;sMessage = 'A Manual Contract has already been generated you cannot use the Docusign feature.';
        }
        Application_Bypass__c appBypass = Application_Bypass__c.getInstance();
        if ((oQuote.SBQQ__Opportunity2__r.stageName == 'Closed Won' || oQuote.SBQQ__Opportunity2__r.stageName == 'Closed Lost') && !appBypass.Bypass_Validation_Rules__c && !Utility.isAsync()) {nullQuoteLines = true; sMessage = 'You may not Create/update a Quote where the opportunity Stage is ' + oQuote.SBQQ__Opportunity2__r.stageName;
        }
        if (oQuote.Billing_Contact__c == null) {nullQuoteLines = true;sMessage = System.Label.Label_Billing_Contact_Missing;
        }
        // Added by Palla Kishore for the ticket BK-22140
        if (oQuote.conga_quote_template_id__c == null) {nullQuoteLines = true;sMessage = System.Label.Label_Conga_Quote_Template_Id_Missing;
        }
        if (oQuote.conga_contract_template_id__c == null) {nullQuoteLines = true;sMessage = System.Label.Label_Conga_Contract_Template_Id_Missing;
        }
        // Added by Palla Kishore for the ticket BK-20651
		if (oQuote.SBQQ__Opportunity2__c != null && oQuote.SBQQ__Opportunity2__r.Event_Series__c != null && oQuote.SBQQ__Opportunity2__r.Event_Series__r.Legal_Entity__c != null && oQuote.SBQQ__Opportunity2__r.Event_Series__r.Legal_Entity__r.Supplier_License_Number__c == null && oQuote.SBQQ__Opportunity2__r.Event_Series__r.Legal_Entity__r.blng__Country__c == 'United Arab Emirates' && oQuote.SBQQ__Account__r.BillingCountry != 'United Arab Emirates') {nullQuoteLines = true;sMessage = System.Label.Label_Supplier_License_Number_Missing;
        }
        if (oQuote.SBQQ__Account__c != null){ 
            if(oQuote.SBQQ__Account__r.BillingStreet != null && oQuote.SBQQ__Account__r.BillingStreet.contains('"')) {
                nullQuoteLines = true;sMessage = 'Billing Address Line 1 on Account contains Double quotes Please remove.';
            } 
            if(oQuote.SBQQ__Account__r.BillingCity != null && oQuote.SBQQ__Account__r.BillingCity.contains('"')) {
                nullQuoteLines = true;sMessage = 'Billing City on Account contains Double quotes Please remove.';
            }
        }
        if (oQuote.SBQQ__PrimaryContact__c != null){ 
            if(oQuote.SBQQ__PrimaryContact__r.FirstName != null && oQuote.SBQQ__PrimaryContact__r.FirstName.contains('"') ) {nullQuoteLines = true;sMessage = 'First Name on contact contains Double quotes Please remove.';
            }
            if(oQuote.SBQQ__PrimaryContact__r.LastName != null && oQuote.SBQQ__PrimaryContact__r.LastName.contains('"') ) {nullQuoteLines = true;sMessage = 'Last Name on contact contains Double quotes Please remove.';
            }
        }
        if (oQuote.SBQQ__Opportunity2__c != null && oQuote.SBQQ__Opportunity2__r.Name != null && oQuote.SBQQ__Opportunity2__r.Name.contains('"') ) {nullQuoteLines = true;sMessage = 'Opportunity Name contains Double quotes Please remove.';
        }
        string errormsg = Manually_Upload_Salesforce_Contract.quoteLineValidation(objQLIList);
        if(string.isNotBlank(errormsg)){nullQuoteLines = true;sMessage = errormsg;
        }
       // Added by Palla Kishore for the ticket BK-19643 validating Simples Nacional/National Classification fields on the Account is blank or not.
        if ('Sales-Brasil'.equalsIgnoreCase(u.profile.name) && oQuote.SBQQ__Account__c <>null && 'Brasil'.equalsIgnoreCase(oQuote.SBQQ__Account__r.BillingCountry) && (string.isBlank(oQuote.SBQQ__Account__r.Simples_Nacional__c) || string.isBlank(oQuote.SBQQ__Account__r.National_Classification__c))){ nullQuoteLines = true;sMessage = System.Label.Two_Account_Fields_Required_For_Brazil;
        }  
    }
    
    /**
* @description This method will calculate the cut off date and amount.
* @param
* @return pageReference
*/
    public pageReference autorun() {
        CongaUtilities cUtilsObj = new CongaUtilities();
        if (oQuote.SBQQ__Account__r.Accounting_Credit_Hold__c == 'Hold') {sMessage = System.Label.Account_Hold_Message_Label;nullQuoteLines = true; //'Account is on Hold, You can not create a Contract.';
        }else if(oQuote.Approval_Status__c=='In Progress' && oQuote.Event_Edition_Name__c=='Hospitalar 2024'){sMessage = System.Label.Quote_Approval_Status_Message_Label;nullQuoteLines = true;
            }
         // Added by Danish for the ticket BK-27184
        else if((oQuote.Approval_Status__c == 'Rejected' || oQuote.Approval_Status__c==null) && oQuote.Event_Edition_Name__c=='Hospitalar 2024' && oQuote.Maximum_Discount__c>0){sMessage = System.Label.Quote_Approval_Status_Message_onDiscount;nullQuoteLines = true;
        } 
        else {
            if (oQuote.SBQQ__Opportunity2__r.StageName != 'Closed Won') {
                cUtilsObj.cutoffDates(quoteId, oQuote.SBQQ__Opportunity2__r.Custom_Payment__c);
            }
            if (oQuote.Event_Series_Country__c != null) {companyCountry = cUtilsObj.CountryLocale(oQuote.Event_Series_Country__c).trim();if (companyCountry.length() > 5) {sMessage = companyCountry;nullQuoteLines = true;
                }
            } else {
                sMessage = System.Label.Event_Series_Country_can_not_be_blank;
                nullQuoteLines = true;
            }
            //Pulling local name of the products.
            if (prodQuoteLineMap.size() > 0) {                cUtilsObj.getProductLocalName(prodQuoteLineMap);
            }
        }
        return null;
    }
    
    /**
* @description This method will get the account id that is show on generated documents.
* @param
* @return pageReference
*/
    public pageReference addressOnTemplate() {
        addressString = '';
        String sAccountName = '';
        Contact oCon = new Contact();
        if (accountId != null) {
            addressString = '';
            for (Account acc: inDirectAccount) {
                
                if (accountId == acc.Id) {
                    sAccountName = acc.Name;
                    addressString = acc.BillingStreet != null ? acc.BillingStreet + '\n' : '';
                    addressString += acc.Billing_Address_Line_2__c != null ? acc.Billing_Address_Line_2__c + '\n' : '';
                    if (string.isBlank(acc.BillingState) && string.isBlank(acc.Billingpostalcode)) {
                        addressString += acc.BillingCity != null ? acc.BillingCity : '';
                    } else {
                        addressString += acc.BillingCity != null ? acc.BillingCity + ', ' : '';
                    }
                    addressString += acc.BillingState != null ? acc.BillingState + ' ' : '';
                    addressString += acc.Billingpostalcode != null ? acc.Billingpostalcode + '\n' : '\n';
                    addressString += acc.BillingCountry != null ? acc.BillingCountry + '\n' : '';
                }
            }
            
            if (acct.Id != accountId) {                oQuote.Is_From_Partner_Account__c = true;
            } else {
                oQuote.Is_From_Partner_Account__c = false;
            }
        }
        if (addressString != null) {
            oQuote.AddressOnTemplate__c = addressString;
            oQuote.SBQQ__BillingName__c = sAccountName;
            if (oQuote.SBQQ__Opportunity2__r.stageName != 'Closed Won') {
                update oQuote;
            }
        }
        return null;
    }
    
    /**
* @description This method shows the attachments attached to quote line items .
* @param
* @return pageReference
*/
    public pageReference showQuoteAttachment() {
        DateTime objDate = DateTime.now();
        if (template == 'Quote') {
            docName = oQuote.Name + '-' + String.valueOf(objDate) + '-preview';
            accountId = '';
        } else {
            docName = oQuote.Name + '-' + String.valueOf(objDate) + '-preview';
            accountId = '';
        }
        return null;
    }
    
    /**
* @description This method redirect the page to the current Quote.
* @param
* @return pageReference
*/
    public pageReference cancel() {
        string headerdata = ApexPages.currentPage().getHeaders().get('Host');
        pageReference pg = new pageReference('/' + quoteId);
        return pg;
    }
    
    /**
* @description check for national and international template and generate the Quote/Contract as per the picklist value selected.
* @param
* @return pageReference
*/
    public pageReference continueCmd() {
        User sProfileName = [select Id, Profile.Name, UserRole.Name from User Where Id =: UserInfo.getUserId()]; // GGCKB-20
        
        String productAttachments;
        Application_Bypass__c appBypass = Application_Bypass__c.getInstance();
        if (ids != null) {            productAttachments = ids.removeEnd(',');
        }
        
        String deliverables = '';
        if (oQuote.Quote_Line_Deliverables__c != null && oQuote.Show_Deliverables__c == true) {deliverables = [select id from APXTConga4__Conga_Template__c where APXTConga4__Name__c = 'Deliverables'].Id;
        }
        //update Rajesh kumar yadav BK-3326/3392
        //Brazil National Barter Contract
        //Brazil International Barter Contract
        //Brazil National FOC Contract
        //Brazil International FOC Contract
        string BrazilNationalBarterContract = '';
        string BrazilInternationalBarterContract = '';
        string NonBrazilInternationalBarterContract = ''; /*BK-21224*/
        string BrazilNationalFOCContract = '';
        string BrazilInternationalFOCContract = '';
        string NationalDigital ='';
        string InternationalDigital ='';
        
        if( !oQuote.Is_a_Local_Company__c && oQuote.SBQQ__Opportunity2__r.Is_Barter_Opportunity__c && sProfileName.Profile.Name != 'Sales' && sProfileName.Profile.Name != 'Operations'  && sProfileName.Profile.Name != 'GE BA Administrator' && sProfileName.Profile.Name != 'GE System Administrator' && sProfileName.Profile.Name != 'System Administrator'){
            BrazilInternationalBarterContract = [select id from APXTConga4__Conga_Template__c where APXTConga4__Name__c = 'Brazil International Barter Contract' limit 1].Id;
            System.debug('BrazilInternationalBarterContract>> '+BrazilInternationalBarterContract);
        }else if(!oQuote.Is_a_Local_Company__c && oQuote.SBQQ__Opportunity2__r.Is_Barter_Opportunity__c && (sProfileName.Profile.Name == 'Sales' || sProfileName.Profile.Name == 'Operations' || sProfileName.Profile.Name == 'GE BA Administrator'|| sProfileName.Profile.Name == 'GE System Administrator'|| sProfileName.Profile.Name == 'System Administrator')){
            NonBrazilInternationalBarterContract = [select id from APXTConga4__Conga_Template__c where APXTConga4__Name__c = 'Non_Brazil_international_Barter_Contract' limit 1].Id;/*BK-21224*/
          System.debug('NonBrazilInternationalBarterContract>> '+NonBrazilInternationalBarterContract);
        }else if (oQuote.Is_a_Local_Company__c && oQuote.SBQQ__Opportunity2__r.Is_Barter_Opportunity__c) {BrazilNationalBarterContract = [select id from APXTConga4__Conga_Template__c where APXTConga4__Name__c = 'Brazil National Barter Contract' limit 1].Id;
        }else if(!oQuote.Is_a_Local_Company__c && oQuote.SBQQ__Opportunity2__r.Total_FOC_Product_Count__c >= 1){BrazilInternationalFOCContract = [select id from APXTConga4__Conga_Template__c where APXTConga4__Name__c = 'Brazil International FOC Contract' limit 1].Id;}
        else if(oQuote.Is_a_Local_Company__c && oQuote.SBQQ__Opportunity2__r.Total_FOC_Product_Count__c >= 1){BrazilNationalFOCContract =[select id from APXTConga4__Conga_Template__c where APXTConga4__Name__c = 'Brazil National FOC Contract' limit 1].Id;}
        else if(oQuote.Is_a_Local_Company__c && oQuote.Contract_Type__c =='Digital'){NationalDigital =[select id from APXTConga4__Conga_Template__c where APXTConga4__Name__c = 'BRAZIL National Digital Only Contract' limit 1].Id;}
        else if(!oQuote.Is_a_Local_Company__c && oQuote.Contract_Type__c =='Digital'){InternationalDigital =[select id from APXTConga4__Conga_Template__c where APXTConga4__Name__c = 'BRAZIL International Digital Only Contract' limit 1].Id;}
        system.debug('BrazilNationalBarterContract ' +BrazilNationalBarterContract + 'BrazilInternationalBarterContract' + BrazilInternationalBarterContract + 'BrazilNationalFOCContract' + BrazilNationalFOCContract + 'BrazilInternationalFOCContract '+  BrazilInternationalFOCContract);
        //Rajesh kumar yadav BK-3326/3392
        string url;
        String templates = '';
        String retpath;
        String templateId = '';
        string congaQueries = System.label.conga_queries;
        string congaQueriesOOQ = System.label.conga_queries_Online_Opportunity_Quote;
        string congaAdditionalParams = System.label.conga_Additional_Params;
        
        
        if(oQuote.Online_Opportunity_Quote_Check__c == true)    {          congaQueries = congaQueries +','+congaQueriesOOQ+'='+oQuote.Online_Opportunity_Quote__c;
           }else{
               congaQueries = congaQueries;
           } 
        //if (oQuote.SBQQ__Opportunity2__r.EventEdition__r.Contract_Special_Conditions__c != null ){            
            oQuote.EE_Contract_Special_Conditions__c = oQuote.SBQQ__Opportunity2__r.EventEdition__r.Contract_Special_Conditions__c;
       // }
        
        if (template == 'Quote') {
            if (!oQuote.Is_a_Local_Company__c) { templateId = oQuote.conga_quote_template_id__c + ',' + deliverables;
            } else {
                //for local/national company
                Integer eeCount = [select count() from National_Contract_Template__c where Event_Edition__r.name =: oQuote.Quote_Event_Edition__c and Type__c = 'Quote Template'];
                if (eeCount <= 0) {nullQuoteLines = true;sMessage = 'It is not a Local Company , Please go to related opportunity and uncheck the \'is a local Company\' check box.'; return null;
                } else {
                    National_Contract_Template__c temp = [select id, name, Event_Edition__c, Conga_Template__c, Term_Conditions__c from National_Contract_Template__c where Event_Edition__r.name =: oQuote.Quote_Event_Edition__c and Type__c = 'Quote Template'];
                    templateId = temp.Conga_Template__c;
                }
            }
            retpath = '/apex/CongaPreviewPage?quoteId=' + quoteId + '~sD~template^' + template + '~productAttachments^' + productAttachments + '~serverUrl^' + serverURL + '~companyCountry^' + companyCountry + '~TemplateId^' + TemplateId;
            retpath = retpath.trim().removeEnd(',');

            url = '/apex/APXTConga4__Conga_Composer?sessionId=' + sessionId + '&serverUrl=' + serverURL + '&Id=' + quoteId + '&TemplateId=' + templateId + '&QueryId=' + congaQueries + '&DS7=1&DV0=Preview Only&BML=Generating+Quote+Preview+Document+for+' + oQuote.Primary_Contact_Info__c + '&SC0=1&SC1=SalesforceFile&DefaultPDF=1&OFN=' + docName + '&ReturnPath=' + retpath + '&Culture=' + companyCountry + '&CurrencyCulture=' + companyCountry + congaAdditionalParams;

        } else if (template == 'Contract') {
            if (oQuote.Allow_Docusign_Counter_Sign__c && oQuote.SBQQ__Opportunity2__r.Legal_Representative_1__c == NULL) { nullQuoteLines = true; sMessage = 'Please assign the Legal Representative 1 contact on the opportunity in order to proceed.'; return null;
            }
            List < National_Contract_Template__c > objNationalCntctTemplt = [select id, name, Event_Edition__c, Conga_Template__c, Conga_Template__r.Name, Conga_Template__r.APXTConga4__Name__c, Term_Conditions__c from National_Contract_Template__c where Event_Edition__r.name =: oQuote.Quote_Event_Edition__c and Type__c = 'Contract Template'
                                                                             AND Conga_Template__r.APXTConga4__Name__c = 'BRAZIL National Contract'
                                                                             limit 1
                                                                            ];
            if (oQuote.Is_a_Local_Company__c && oQuote.Allow_Docusign_Counter_Sign__c && oQuote.SBQQ__Opportunity2__r.Witness_Contact__c == null && objNationalCntctTemplt.size() > 0) {
                sMessage = 'Please assign the Witness contact on the opportunity in order to proceed';
                nullQuoteLines = true;
                return null;
            }
            //for international company
            system.debug('oQuote.Is_a_Local_Company__c ' + oQuote.Is_a_Local_Company__c);
            system.debug('oQuote.Is_a_Local_Company__c ' + !oQuote.Is_a_Local_Company__c + 'oQuote.SBQQ__Opportunity2__r.Total_FOC_Product_Count__c' + oQuote.SBQQ__Opportunity2__r.Total_FOC_Product_Count__c);   
            if (!oQuote.Is_a_Local_Company__c) {
                //BK-6386 by Aishwarya Kumar
                if(!oQuote.Is_a_Local_Company__c && oQuote.Contract_Type__c =='Digital'){ 
                    if(String.isNotBlank(InternationalDigital)) { templates = InternationalDigital + ',' + deliverables; }
                }
                //update Rajesh kumar yadav BK-3326
                //system.debug('oQuote.Is_a_Local_Company__c ' + oQuote.Is_a_Local_Company__c + 'oQuote.SBQQ__Opportunity2__r.Is_Barter_Opportunity__c' + oQuote.SBQQ__Opportunity2__r.Is_Barter_Opportunity__c);
                else if (!oQuote.Is_a_Local_Company__c && oQuote.SBQQ__Opportunity2__r.Is_Barter_Opportunity__c && sProfileName.Profile.Name != 'Sales' && sProfileName.Profile.Name != 'Operations' && sProfileName.Profile.Name != 'GE BA Administrator' && sProfileName.Profile.Name != 'GE System Administrator'&& sProfileName.Profile.Name != 'System Administrator') {
                    if (String.isNotBlank(BrazilInternationalBarterContract)) {
                        if (oQuote.SBQQ__Type__c == 'Amendment' && (sProfileName.Profile.Name == 'Sales-Brasil' || (sProfileName.Profile.Name == 'SSC Finance-Accounting' && sProfileName.UserRole.Name == 'SSC-Brazil'))) {
                            templates = BrazilInternationalBarterContract + ',' + deliverables;} else {templates = BrazilInternationalBarterContract + ',' + deliverables;}
                    } else { sMessage = system.Label.Brazil_International_Barter_Contract; nullQuoteLines = true; return null;}
                }
                /*BK-21224 : if condition for Non Brazil International Barter Contracts start*/
                else if(String.isNotBlank(NonBrazilInternationalBarterContract)){
                        if(sProfileName.Profile.Name == 'Sales' || sProfileName.Profile.Name == 'Operations' || sProfileName.Profile.Name == 'GE BA Administrator'|| sProfileName.Profile.Name == 'GE System Administrator'|| sProfileName.Profile.Name == 'System Administrator'){
                            templates = NonBrazilInternationalBarterContract+ ',' + deliverables;
                        }
                    }
                    /*BK-21224 : if condition end*/
                
                else if(!oQuote.Is_a_Local_Company__c && oQuote.SBQQ__Opportunity2__r.Total_FOC_Product_Count__c >= 1){
                    if (String.isNotBlank(BrazilInternationalFOCContract)) {
                        if (oQuote.SBQQ__Type__c == 'Amendment' && (sProfileName.Profile.Name == 'Sales-Brasil' || (sProfileName.Profile.Name == 'SSC Finance-Accounting' && sProfileName.UserRole.Name == 'SSC-Brazil'))) {
                            templates = BrazilInternationalFOCContract + ',' + deliverables;
                        } else {templates = BrazilInternationalFOCContract + ',' + deliverables;}
                    } else { sMessage = system.Label.Brazil_International_FOC_Contract; nullQuoteLines = true;return null;}
                } 
                else {
                    //BK-6268
                    oQuoteTCID = [select id, term_conditionIds__c, conga_contract_template_id__c from SBQQ__Quote__c where id =: quoteId limit 1];
                    system.debug('oQuoteTCID.term_conditionIds__c 310' + oQuoteTCID.term_conditionIds__c);
                    if (String.isBlank(termAndCondition)) {
                        //BK-6268
                        if (!String.isBlank(oQuoteTCID.term_conditionIds__c)) {
                            templates = oQuote.conga_contract_template_id__c + ',' + deliverables+ ',' + oQuoteTCID.term_conditionIds__c;
                        }else{
                         oQuote.National_contract_and_TC_Ids__c = templates;
                         templates = oQuote.conga_contract_template_id__c + ',' + deliverables;}
                        system.debug('Quote::::'+oQuote.conga_contract_template_id__c);
                        system.debug('templates 310' + templates);
                    } else {
                        //GGCKB-20
                        /*
                        if (oQuote.SBQQ__Type__c == 'Amendment' && (sProfileName.Profile.Name == 'Sales-Brasil' || (sProfileName.Profile.Name == 'SSC Finance-Accounting' && sProfileName.UserRole.Name == 'SSC-Brazil'))) {
                            templates = oQuote.conga_contract_template_id__c + ',' + deliverables;
                        } else {templates = oQuote.conga_contract_template_id__c + ',' + deliverables + ',' + termAndCondition;}
                        */
                        templates = oQuote.conga_contract_template_id__c + ',' + deliverables + ',' + termAndCondition;
                    }
                }
            } else {
                if(oQuote.Is_a_Local_Company__c && oQuote.Contract_Type__c =='Digital'){                    
                    if(String.isNotBlank(NationalDigital)) { 
                        templates = NationalDigital; 
                    }
                }
                //update Rajesh kumar yadav BK-3326
                 //system.debug('oQuote.Is_a_Local_Company__c ' + oQuote.Is_a_Local_Company__c + 'oQuote.SBQQ__Opportunity2__r.Is_Barter_Opportunity__c' + oQuote.SBQQ__Opportunity2__r.Is_Barter_Opportunity__c);
                else if (oQuote.Is_a_Local_Company__c && oQuote.SBQQ__Opportunity2__r.Is_Barter_Opportunity__c) {
                    //for National company
                    if (String.isNotBlank(BrazilNationalBarterContract)) {
                        if (oQuote.SBQQ__Type__c == 'Amendment' && (sProfileName.Profile.Name == 'Sales-Brasil' || (sProfileName.Profile.Name == 'SSC Finance-Accounting' && sProfileName.UserRole.Name == 'SSC-Brazil'))) {
                            templates = BrazilNationalBarterContract;
                        } else {templates = BrazilNationalBarterContract;}
                    } else {sMessage = system.Label.Brazil_National_Barter_Contract; nullQuoteLines = true;return null; }
                }
                else if(oQuote.Is_a_Local_Company__c && oQuote.SBQQ__Opportunity2__r.Total_FOC_Product_Count__c >= 1){
                    //for National company
                    if (String.isNotBlank(BrazilNationalFOCContract)) {
                        if (oQuote.SBQQ__Type__c == 'Amendment' && (sProfileName.Profile.Name == 'Sales-Brasil' || (sProfileName.Profile.Name == 'SSC Finance-Accounting' && sProfileName.UserRole.Name == 'SSC-Brazil'))) {
                            templates = BrazilNationalFOCContract;
                        } else {templates = BrazilNationalFOCContract;}
                    } else {sMessage = system.Label.Brazil_National_FOC_Contract; nullQuoteLines = true;return null; }
                } 
                else {
                    //for National company
                    Integer eeCount = [select count() from National_Contract_Template__c where Event_Edition__r.name =: oQuote.Quote_Event_Edition__c and Type__c = 'Contract Template'];
                    if (eeCount <= 0) {
                        nullQuoteLines = true;
                        sMessage = 'It is not a Local Company , Please go to related opportunity and uncheck the \'is a local Company\' check box.';
                        return null;
                    } else {
                        system.debug('temp' + [select id, name, Event_Edition__c, Conga_Template__c, Term_Conditions__c from National_Contract_Template__c where Event_Edition__r.name =: oQuote.Quote_Event_Edition__c and Type__c = 'Contract Template']);
                        National_Contract_Template__c temp = [select id, name, Event_Edition__c, Conga_Template__c, Term_Conditions__c from National_Contract_Template__c where Event_Edition__r.name =: oQuote.Quote_Event_Edition__c and Type__c = 'Contract Template'];
                        //GGCKB-20
                        /*
                        if (oQuote.SBQQ__Type__c == 'Amendment' && (sProfileName.Profile.Name == 'Sales-Brasil' || (sProfileName.Profile.Name == 'SSC Finance-Accounting' && sProfileName.UserRole.Name == 'SSC-Brazil'))) {
                            templates = temp.Conga_Template__c;
                        } else {templates = temp.Conga_Template__c + ',' + temp.Term_Conditions__c;oQuote.National_contract_and_TC_Ids__c = templates;} */
                        templates = temp.Conga_Template__c + ',' + temp.Term_Conditions__c;oQuote.National_contract_and_TC_Ids__c = templates;
                    }
                }
            }
            system.debug('templates' + templates);
            //Updated by Abdul Kadir: 06 Nov 2018.
            //Add one conga param : currencyCulture for currency formatting (GGCW-1407).
            //Add Docusing counter functionality for contract document...
            //To allow docusign counter sign first give permission to the profile through application_bypass custom setting and check  'Allow_Docusign_Counter_Sign__c' field on Event editi  on.
            retpath = '/apex/CongaPreviewPage?quoteId=' + quoteId + '~sD~template^' + template + '~productAttachments^' + productAttachments + '~serverUrl^' + serverURL + '~companyCountry^' + companyCountry + '~TemplateId^' + templates;
            retpath = retpath.trim().removeEnd(',');
            if (appBypass.Docusign_Counter_Sign__c && oQuote.Allow_Docusign_Counter_Sign__c) {
                String docusignParams = System.label.Docusign_Counter_Sign;
                String docusignParamsFourSign = System.label.Docusign_Counter_Four_Sign;
                String templatesName = '';
                if (templates != null && templates != '') {
                    String tempname = '';
                    tempname = templates.substringBefore(',');
                    APXTConga4__Conga_Template__c accT = new APXTConga4__Conga_Template__c();
                    accT = [SELECT Id, Name, APXTConga4__Name__c FROM APXTConga4__Conga_Template__c where id =: tempname limit 1];
                    templatesName = accT != NULL ? accT.APXTConga4__Name__c : '';
                }

                if (templatesName != null && templatesName != '') {
                    //if(oQuote.SBQQ__Opportunity2__r.Is_Barter_Opportunity__c || oQuote.Contract_Type__c =='Digital')
                        //if (templatesName.contains('Brazil International Barter Contract') && !oQuote.Is_a_Local_Company__c && oQuote.SBQQ__Opportunity2__r.Is_Barter_Opportunity__c)
                        if(oQuote.Contract_Type__c =='Digital' && (templatesName.contains('InternationalDigital') || (templatesName.contains('NationalDigital'))) ){          
                             url = '/apex/APXTConga4__Conga_Composer?sessionId=' + sessionId + '&serverUrl=' + serverURL + '&Id=' + quoteId + '&TemplateId=' + templates + '&QueryId=' + congaQueries + '&DocuSignVisible=1&DocuSignR1ID=' + oQuote.SBQQ__Opportunity2__r.Legal_Representative_1__c + '&DocuSignR2ID=' + oQuote.Witness_Contact__c + '&DocuSignR3ID=' + oQuote.Event_Director__c + '&DocuSignR4ID=' + oQuote.Event_Director__c + '&DocuSignR5ID=' + oQuote.ID + '&SC0=1&SC1=SalesforceFile&DefaultPDF=1&OFN=' + docName + '&UF0=1&MFTS0=template__c&MFTSValue0=' + template + '&DS7=1&DV0=Preview Only&BML=Generating+Contract+for+' + oQuote.Primary_Contact_Info__c + '&MFTS1=Version__c&MFTSValue1=' + oQuote.Next_Version__c + '&DefaultPDF=1&Culture=' + companyCountry + '&CurrencyCulture=' + companyCountry + '&DocuSignBrandName=Informa GE&AWD=2' + docusignParamsFourSign + '&ReturnPath=' + retpath;
                        }
                        else if(oQuote.SBQQ__Opportunity2__r.Is_Barter_Opportunity__c){
                            if (templatesName.contains('Brazil International Barter Contract') && !oQuote.Is_a_Local_Company__c && oQuote.SBQQ__Opportunity2__r.Is_Barter_Opportunity__c ) {                            
                            url = '/apex/APXTConga4__Conga_Composer?sessionId=' + sessionId + '&serverUrl=' + serverURL + '&Id=' + quoteId + '&TemplateId=' + templates + '&QueryId=' + congaQueries + '&DocuSignVisible=1&DocuSignR1ID=' + oQuote.SBQQ__Opportunity2__r.Legal_Representative_1__c + '&DocuSignR2ID=' + oQuote.Event_Director__c + '&DocuSignR1Role=Signer+1&DocuSignR1Type=Signer&DocuSignR1RoutingOrder=1&SC0=1&SC1=SalesforceFile&DefaultPDF=1&OFN=' + docName + '&UF0=1&MFTS0=template__c&MFTSValue0=' + template + '&DS7=1&DV0=Preview Only&BML=Generating+Contract+for+' + oQuote.Primary_Contact_Info__c + '&MFTS1=Version__c&MFTSValue1=' + oQuote.Next_Version__c + '&DefaultPDF=1&Culture=' + companyCountry + '&CurrencyCulture=' + companyCountry + '&DocuSignBrandName=Informa GE&AWD=2' + docusignParams + '&ReturnPath=' + retpath;
                        } else{
                            url = '/apex/APXTConga4__Conga_Composer?sessionId=' + sessionId + '&serverUrl=' + serverURL + '&Id=' + quoteId + '&TemplateId=' + templates + '&QueryId=' + congaQueries + '&DocuSignVisible=1&DocuSignR1ID=' + oQuote.SBQQ__Opportunity2__r.Legal_Representative_1__c + '&DocuSignR2ID=' + oQuote.Witness_Contact__c + '&DocuSignR3ID=' + oQuote.Event_Director__c + '&DocuSignR4ID=' + oQuote.Event_Director__c + '&DocuSignR5ID=' + oQuote.ID +  '&SC0=1&SC1=SalesforceFile&DefaultPDF=1&OFN=' + docName + '&UF0=1&MFTS0=template__c&MFTSValue0=' + template + '&DS7=1&DV0=Preview Only&BML=Generating+Contract+for+' + oQuote.Primary_Contact_Info__c + '&MFTS1=Version__c&MFTSValue1=' + oQuote.Next_Version__c + '&DefaultPDF=1&Culture=' + companyCountry + '&CurrencyCulture=' + companyCountry + '&DocuSignBrandName=Informa GE&AWD=2' + docusignParamsFourSign + '&ReturnPath=' + retpath;
                        }
                            
                        if (templatesName.contains('Non_Brazil_international_Barter_Contract') && !oQuote.Is_a_Local_Company__c && oQuote.SBQQ__Opportunity2__r.Is_Barter_Opportunity__c ) {                            
                            url = '/apex/APXTConga4__Conga_Composer?sessionId=' + sessionId + '&serverUrl=' + serverURL + '&Id=' + quoteId + '&TemplateId=' + templates + '&QueryId=' + congaQueries + '&DocuSignVisible=1&DocuSignR1ID=' + oQuote.SBQQ__Opportunity2__r.Legal_Representative_1__c + '&DocuSignR2ID=' + oQuote.Event_Director__c + '&DocuSignR1Role=Signer+1&DocuSignR1Type=Signer&DocuSignR1RoutingOrder=1&SC0=1&SC1=SalesforceFile&DefaultPDF=1&OFN=' + docName + '&UF0=1&MFTS0=template__c&MFTSValue0=' + template + '&DS7=1&DV0=Preview Only&BML=Generating+Contract+for+' + oQuote.Primary_Contact_Info__c + '&MFTS1=Version__c&MFTSValue1=' + oQuote.Next_Version__c + '&DefaultPDF=1&Culture=' + companyCountry + '&CurrencyCulture=' + companyCountry + '&DocuSignBrandName=Informa GE&AWD=2' + docusignParams + '&ReturnPath=' + retpath;
                        }
                            
                    }else if(oQuote.SBQQ__Opportunity2__r.Total_FOC_Product_Count__c >= 1){    if (templatesName.contains('Brazil International FOC Contract') && !oQuote.Is_a_Local_Company__c && oQuote.SBQQ__Opportunity2__r.Total_FOC_Product_Count__c >= 1) {
                            url = '/apex/APXTConga4__Conga_Composer?sessionId=' + sessionId + '&serverUrl=' + serverURL + '&Id=' + quoteId + '&TemplateId=' + templates + '&QueryId=' + congaQueries + '&DocuSignVisible=1&DocuSignR1ID=' + oQuote.SBQQ__Opportunity2__r.Legal_Representative_1__c + '&DocuSignR2ID=' + oQuote.Event_Director__c + '&DocuSignR1Role=Signer+1&DocuSignR1Type=Signer&DocuSignR1RoutingOrder=1&SC0=1&SC1=SalesforceFile&DefaultPDF=1&OFN=' + docName + '&UF0=1&MFTS0=template__c&MFTSValue0=' + template + '&DS7=1&DV0=Preview Only&BML=Generating+Contract+for+' + oQuote.Primary_Contact_Info__c + '&MFTS1=Version__c&MFTSValue1=' + oQuote.Next_Version__c + '&DefaultPDF=1&Culture=' + companyCountry + '&CurrencyCulture=' + companyCountry + '&DocuSignBrandName=Informa GE&AWD=2' + docusignParams + '&ReturnPath=' + retpath;
                        } else{
                            url = '/apex/APXTConga4__Conga_Composer?sessionId=' + sessionId + '&serverUrl=' + serverURL + '&Id=' + quoteId + '&TemplateId=' + templates + '&QueryId=' + congaQueries + '&DocuSignVisible=1&DocuSignR1ID=' + oQuote.SBQQ__Opportunity2__r.Legal_Representative_1__c + '&DocuSignR2ID=' + oQuote.Witness_Contact__c + '&DocuSignR3ID=' + oQuote.Event_Director__c + '&DocuSignR4ID=' + oQuote.Event_Director__c + '&DocuSignR5ID=' + oQuote.ID +  '&SC0=1&SC1=SalesforceFile&DefaultPDF=1&OFN=' + docName + '&UF0=1&MFTS0=template__c&MFTSValue0=' + template + '&DS7=1&DV0=Preview Only&BML=Generating+Contract+for+' + oQuote.Primary_Contact_Info__c + '&MFTS1=Version__c&MFTSValue1=' + oQuote.Next_Version__c + '&DefaultPDF=1&Culture=' + companyCountry + '&CurrencyCulture=' + companyCountry + '&DocuSignBrandName=Informa GE&AWD=2' + docusignParamsFourSign + '&ReturnPath=' + retpath;
                        }
                    }
                    else{
                        if(templatesName.contains('BRAZIL InterNational Contract') && (oQuote.SBQQ__Type__c == 'Amendment' || oQuote.SBQQ__Type__c == 'Quote')){
                            url = '/apex/APXTConga4__Conga_Composer?sessionId=' + sessionId + '&serverUrl=' + serverURL + '&Id=' + quoteId + '&TemplateId=' + templates + '&QueryId=' + congaQueries + '&DocuSignVisible=1&DocuSignR1ID=' + oQuote.SBQQ__Opportunity2__r.Legal_Representative_1__c + '&DocuSignR2ID=' + oQuote.Witness_Contact__c + '&DocuSignR3ID=' + oQuote.Event_Director__c + '&DocuSignR4ID=' + oQuote.Event_Director__c + '&DocuSignR5ID=' + oQuote.ID +  '&SC0=1&SC1=SalesforceFile&DefaultPDF=1&OFN=' + docName + '&UF0=1&MFTS0=template__c&MFTSValue0=' + template + '&DS7=1&DV0=Preview Only&BML=Generating+Contract+for+' + oQuote.Primary_Contact_Info__c + '&MFTS1=Version__c&MFTSValue1=' + oQuote.Next_Version__c + '&DefaultPDF=1&Culture=' + companyCountry + '&CurrencyCulture=' + companyCountry + '&DocuSignBrandName=Informa GE&AWD=2' + docusignParamsFourSign + '&ReturnPath=' + retpath;
                        }else if(templatesName.contains('BRAZIL InterNational Contract')){
                            url = '/apex/APXTConga4__Conga_Composer?sessionId=' + sessionId + '&serverUrl=' + serverURL + '&Id=' + quoteId + '&TemplateId=' + templates + '&QueryId=' + congaQueries + '&DocuSignVisible=1&DocuSignR1ID=' + oQuote.SBQQ__Opportunity2__r.Legal_Representative_1__c + '&DocuSignR2ID=' + oQuote.Event_Director__c + '&DocuSignR1Role=Signer+1&DocuSignR1Type=Signer&DocuSignR1RoutingOrder=1&SC0=1&SC1=SalesforceFile&DefaultPDF=1&OFN=' + docName + '&UF0=1&MFTS0=template__c&MFTSValue0=' + template + '&DS7=1&DV0=Preview Only&BML=Generating+Contract+for+' + oQuote.Primary_Contact_Info__c + '&MFTS1=Version__c&MFTSValue1=' + oQuote.Next_Version__c + '&DefaultPDF=1&Culture=' + companyCountry + '&CurrencyCulture=' + companyCountry + '&DocuSignBrandName=Informa GE&AWD=2' + docusignParams + '&ReturnPath=' + retpath;
                        }else{ 
                            url = '/apex/APXTConga4__Conga_Composer?sessionId=' + sessionId + '&serverUrl=' + serverURL + '&Id=' + quoteId + '&TemplateId=' + templates + '&QueryId=' + congaQueries + '&DocuSignVisible=1&DocuSignR1ID=' + oQuote.SBQQ__Opportunity2__r.Legal_Representative_1__c + '&DocuSignR2ID=' + oQuote.Witness_Contact__c + '&DocuSignR3ID=' + oQuote.Event_Director__c + '&DocuSignR4ID=' + oQuote.Event_Director__c + '&DocuSignR5ID=' + oQuote.ID +  '&SC0=1&SC1=SalesforceFile&DefaultPDF=1&OFN=' + docName + '&UF0=1&MFTS0=template__c&MFTSValue0=' + template + '&DS7=1&DV0=Preview Only&BML=Generating+Contract+for+' + oQuote.Primary_Contact_Info__c + '&MFTS1=Version__c&MFTSValue1=' + oQuote.Next_Version__c + '&DefaultPDF=1&Culture=' + companyCountry + '&CurrencyCulture=' + companyCountry + '&DocuSignBrandName=Informa GE&AWD=2' + docusignParamsFourSign + '&ReturnPath=' + retpath;


                        }
                    }
                  }
                }

               else {
                   url = '/apex/APXTConga4__Conga_Composer?sessionId=' + sessionId + '&serverUrl=' + serverURL + '&Id=' + quoteId + '&TemplateId=' + templates + '&QueryId=' + congaQueries + '&DocuSignVisible=1&DocuSignR1ID=' + oQuote.SBQQ__PrimaryContact__c + '&DocuSignR1Role=Signer+1&DocuSignR1Type=Signer&DocuSignR1RoutingOrder=1&SC0=1&SC1=SalesforceFile&DefaultPDF=1&OFN=' + docName + '&APDF=0&UF0=1&MFTS0=template__c&MFTSValue0=' + template + '&DS7=1&DV0=Preview Only&BML=Generating+Quote+for+' + oQuote.Primary_Contact_Info__c + '&MFTS1=Version__c&MFTSValue1=' + oQuote.Next_Version__c + '&DefaultPDF=1&Culture=' + companyCountry + '&CurrencyCulture=' + companyCountry + congaAdditionalParams + '&ReturnPath=' + retpath;

            }
        }
        update oQuote;
        system.debug('url  >>> :409 ' + url);
        pageReference pg = new pageReference(url);
        return pg;
    }
}