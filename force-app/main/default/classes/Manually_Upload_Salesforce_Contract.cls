/**
 * File:        Manually_Upload_Salesforce_Contract.cls
 * Project:     GAP
 * Date:        1/17/2017 5:52 AM
 * Test Class : Manually_Upload_Salesforce_Contract_test (85% Coverage)
 * Created By:  Rajesh Kumar
 * Modified By: Yash Gupta
 * *************************************************************************
 * @description Sales User Send contract using  Manual Contract from Quote object ,  Quote has primary true and after redirect to Contract page.
 *              And update Stage Contract sent , Manual Contract is true & Contracted check box is true and created Contract .
 * *************************************************************************
 * History: As per ticket GGCW-2681, I have correct the verbiage using the new custom label "Label_Billing_Contact_Missing".
 * Modified By : RaJesh Kumar 03/01/2019 on GGCW-2387
 * Modified By : RaJesh Kumar 21/01/2019 on GGCW-2927
 * Modified By : RaJesh Kumar 21/02/2019 on GGCW-GGCW-2997
 * Modified By : Akshi Arora on 05/15/2019 for GGCKB-20/BK-2905/BK-2871/BK-2973/74
 * Modified By : Shiv Raghav on 27/05/2019 for GGCKB-89
 * Modified By : Avinash Shukla BK-2871/BK-2973/74
 * Modified By : rajesh kumar yadav BK-3326////BK-6667, [BK-6385/6386 Aishwarya 27 July 2020],(BK-7568/BK-7081 Rajesh kumar yadav)
 * MOdified By Rajesh Kumar : BK-10316 After Change Attachment to Files object
 * Modified By Rajesh Kumar : BK-11940 - 20-01-2021 - 25-05-2021 on 16067
 */
 
public without sharing class Manually_Upload_Salesforce_Contract {
    //Variables Declaration
    public String qouteId {get;set;}
    public boolean notPrimaryQuote {get;set;}
    public list < SBQQ__Quote__c > lstQuote {get;set;}
    public string sMessage {get;set;}
    public pageReference redirectToDocuSign;
    public Boolean hasPartner {get;set;}
    public List < Profile > lstprofile = new List < Profile > ();
    public Boolean hasQuoteLineItems {get;set;}
    public string sessionId;
    public string serverURL;
    public string conga;
    public Boolean isBillingContactNull {get;set;}
    public Boolean showConfirmMsg {get;set;}
    public String templatesContract {get;set;}
    public String templateQuote {get;set;}
    public SBQQ__Quote__c quoteObj {get;set;}
    public list < SBQQ__QuoteLine__c > objQLIList {get;set;}
    public String companyCountry {get;set;}
    public Map  <Id, SBQQ__QuoteLine__c > prodQuoteLineMap {get;set;}
    public List  <Account > inDirectAccount {get;set;}
    public String addressString {get;set;}
    public Account acct {get;set;}
    public String accountId {get;set;}
    public Application_Bypass__c appbypass {get;set;}
    public Boolean isWarningMsg {get;set;}
    public String sWarningMsg {get;set;}
    public string template {get;set;}
    public Boolean isWarningMsgHold {get;set;}
    public string congaAdditionalParams {get;set;}
    public string congaQueries {get;set;}
    public string congaQueriesOOQ;
    public boolean isShowAccountSection {get;set;}
    public boolean ishideQuoteCtdn {get;set;}
    //BK-6667
    public SBQQ__Quote__c oQuoteTCID {get;set;}
    //BK-13894 Shiv Raghav
    public String termAndCondition = '';
    
    public Manually_Upload_Salesforce_Contract() {
        system.debug('Constructor Being Called');
    }
    /**
     * [Manually_Upload_Salesforce_Contract Manually_Upload_Salesforce_Contract constructor]
     * @param  controller [StandardController]
     * @return            [null]
     */
    public Manually_Upload_Salesforce_Contract(ApexPages.StandardController controller) {
        isWarningMsg = false;
        quoteObj = new SBQQ__Quote__c();
        prodQuoteLineMap = new Map<Id, SBQQ__QuoteLine__c > ();
        sWarningMsg = '';
        hasPartner = false;
        String sAccountId = '';
        isWarningMsgHold = false;
        ishideQuoteCtdn = false;
        SBQQ__QuoteLine__c tempQLI;
        appbypass = Application_Bypass__c.getInstance();
        congaAdditionalParams = System.label.conga_Additional_Params;
        congaQueries = System.label.conga_queries;
        congaQueriesOOQ = System.label.conga_queries_Online_Opportunity_Quote;
        Set < Id > setPrdIds = new Set < Id > ();
        
        if (ApexPages.currentPage().getParameters().get('id') != null) {
            qouteId = ApexPages.currentPage().getParameters().get('id');
        } else {
            qouteId = ApexPages.currentPage().getParameters().get('quoteId');
        }
       if(String.isNotBlank(qouteId))
       {     
           // Modified by Palla Kishore for the ticket BK-19643
           quoteObj = [select id,Approval_Status__c,Maximum_Discount__c,Event_Edition_Name__c, Name,Is_delegate_Opportunity__c, SBQQ__Opportunity2__r.EventEdition__r.Part_of_Series__r.Event_Series_Code__c, SBQQ__Opportunity2__r.Event_Series__r.Legal_Entity__r.Supplier_License_Number__c,SBQQ__Opportunity2__r.Event_Series__r.Legal_Entity__r.blng__Country__c, SBQQ__Opportunity2__r.EventEdition__r.Part_of_Series__r.Legal_Entity__r.VAT_Declaration_Template__c,SBQQ__Opportunity2__r.EventEdition__r.Mix_Supply_Terms_and_Condition__c, SBQQ__Opportunity2__r.EventEdition__r.DS_Terms_Condition_Template__c, SBQQ__Type__c, SBQQ__Primary__c, Online_Opportunity_Quote_Check__c , Online_Opportunity_Quote__c, SBQQ__Opportunity2__r.Manual_Contract__c, Version__c, SBQQ__Opportunity2__r.Custom_Payment__c, Billing_Contact__c, Billing_Contact__r.Address_Verified__c, Show_Deliverables__c, Quote_Line_Deliverables__c, ISO_Code_Logo__c, Product_Attachments__c, SBQQ__PrimaryContact__c, Primary_Contact_Info__c, documentType__c, Next_Version__c, IsNotGeneralDocument__c, conga_quote_template_id__c, term_conditionIds__c, SBQQ__Opportunity2__r.EventEdition__r.Alternative_Terms_Condition_Template__c,SBQQ__Opportunity2__r.EventEdition__r.Terms_Condition_Template__c,conga_contract_template_id__c, Quote_Event_Edition__c, Is_a_Local_Company__c, Payment_Schedule_amount__c, Manual__c, Payment_Schedule_percent__c, Cutoff_Date__c, Cutoff_Date_1__c, Cutoff_Date_2__c, Cutoff_Date_3__c, SBQQ__NetAmount__c, ISO_Code__c, SBQQ__Opportunity2__c, SBQQ__Opportunity2__r.EventEdition__c, InvoicetoStartDate__c, Invoice_to_Start_Date_Cut_Off_Date1__c, Invoice_to_Start_Date_Cut_Off_Date2__c, Invoice_to_Start_Date_Cut_Off_Date3__c, Invoice_to_be_issued_before_in_Days__c, SBQQ__Opportunity2__r.stageName, SBQQ__Status__c, ES_Company_Country__c, Event_Series_Country__c, SBQQ__Account__c, SBQQ__Account__r.Accounting_Credit_Hold__c,SBQQ__Opportunity2__r.Is_Barter_Opportunity__c,SBQQ__Opportunity2__r.Total_FOC_Product_Count__c, Contract_Type__c, SBQQ__Opportunity2__r.EventEdition__r.Contract_Special_Conditions__c,SBQQ__Account__r.BillingCountry,SBQQ__Account__r.Simples_Nacional__c,SBQQ__Account__r.National_Classification__c,SBQQ__Account__r.BillingStreet,SBQQ__Account__r.BillingCity,SBQQ__PrimaryContact__r.FirstName,SBQQ__PrimaryContact__r.LastName,SBQQ__Opportunity2__r.Name,SBQQ__Opportunity2__r.Address_Validation_Bypass__c from SBQQ__Quote__c where id =: qouteId limit 1];
           quoteObj.documentType__c = '';
        if(quoteObj.Online_Opportunity_Quote_Check__c && String.isNotBlank(congaQueriesOOQ) ){
           congaQueries = congaQueries +','+congaQueriesOOQ+'='+quoteObj.Online_Opportunity_Quote__c;
        } 
        else{
           congaQueries = congaQueries;
        } 
        
         if(quoteObj.Is_delegate_Opportunity__c && quoteObj.SBQQ__Opportunity2__r.EventEdition__r.DS_Terms_Condition_Template__c != Null)
        {
            termAndCondition = quoteObj.SBQQ__Opportunity2__r.EventEdition__r.DS_Terms_Condition_Template__c;
        }
        //BK-13894 Shiv Raghav
        else
        {
            if(quoteObj.Online_Opportunity_Quote_Check__c && quoteObj.SBQQ__Opportunity2__r.EventEdition__r.Alternative_Terms_Condition_Template__c != null)
            {
                termAndCondition = quoteObj.SBQQ__Opportunity2__r.EventEdition__r.Alternative_Terms_Condition_Template__c;
            }
            else if(quoteObj.SBQQ__Opportunity2__r.EventEdition__r.Terms_Condition_Template__c != null)
            {
                termAndCondition = quoteObj.SBQQ__Opportunity2__r.EventEdition__r.Terms_Condition_Template__c;
            }
        }
        objQLIList = [select id, SBQQ__Quote__r.SBQQ__Opportunity2__c, SBQQ__Product__r.Delegate_Product__c,SBQQ__Product__c, SBQQ__Quote__c, SBQQ__Quote__r.SBQQ__Account__c, SBQQ__Product__r.id,SBQQ__Product__r.Name, SBQQ__Product__r.Description, SBQQ__Product__r.Description_in_Alt_Language__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: qouteId Order By SBQQ__Product__r.name Asc];
         
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
                            System.debug('countNonDelegate=='+quoteObj.SBQQ__Opportunity2__r.EventEdition__r.Mix_Supply_Terms_and_Condition__c);

            if(countDelegate>0 && countNonDelegate>0 && quoteObj.SBQQ__Opportunity2__r.EventEdition__r.Mix_Supply_Terms_and_Condition__c != Null){
                   termAndCondition=quoteObj.SBQQ__Opportunity2__r.EventEdition__r.Mix_Supply_Terms_and_Condition__c;
                   quoteObj.Mixed_Product_Term_Check__c=true;
                   System.debug('termAndCondition=='+termAndCondition);
                }
            else if(countDelegate>0 && countNonDelegate==0 && quoteObj.SBQQ__Opportunity2__r.EventEdition__r.DS_Terms_Condition_Template__c != Null){
                    termAndCondition = quoteObj.SBQQ__Opportunity2__r.EventEdition__r.DS_Terms_Condition_Template__c;
                    quoteObj.Mixed_Product_Term_Check__c=false;
                   
                }
            else if(countDelegate==0 && countNonDelegate>0 && quoteObj.SBQQ__Opportunity2__r.EventEdition__r.Terms_Condition_Template__c != null){
                    termAndCondition = quoteObj.SBQQ__Opportunity2__r.EventEdition__r.Terms_Condition_Template__c;
                    quoteObj.Mixed_Product_Term_Check__c=false;
                }
           else if(quoteObj.Online_Opportunity_Quote_Check__c && quoteObj.SBQQ__Opportunity2__r.EventEdition__r.Alternative_Terms_Condition_Template__c != null)
            {
                termAndCondition = quoteObj.SBQQ__Opportunity2__r.EventEdition__r.Alternative_Terms_Condition_Template__c;
                quoteObj.Mixed_Product_Term_Check__c=false;
            }
          
        }
           // Added by Palla Kishore for the ticket BK-27325
            Map<String,VAT_Declaration_Template__mdt> mapVatcmd = VAT_Declaration_Template__mdt.getAll();
           // Added by Palla Kishore for the ticket BK-20651
           if(quoteObj.SBQQ__Opportunity2__r.Event_Series__r.Legal_Entity__r.blng__Country__c == 'United Arab Emirates' && quoteObj.SBQQ__Account__r.BillingCountry != 'United Arab Emirates' && quoteObj.SBQQ__Opportunity2__r.EventEdition__r.Part_of_Series__r.Legal_Entity__r.VAT_Declaration_Template__c!= null)
            {
                if(mapVatcmd.containskey(quoteObj.SBQQ__Opportunity2__r.EventEdition__r.Part_of_Series__r.Event_Series_Code__c)){
                    system.debug('Event Series Code:::'+ quoteObj.SBQQ__Opportunity2__r.EventEdition__r.Part_of_Series__r.Event_Series_Code__c);
                if(String.isNotBlank(termAndCondition)){
                termAndCondition = quoteObj.SBQQ__Opportunity2__r.EventEdition__r.Part_of_Series__r.Legal_Entity__r.VAT_Declaration_Template__c+ ',' + termAndCondition;
                }else {
                   termAndCondition = quoteObj.SBQQ__Opportunity2__r.EventEdition__r.Part_of_Series__r.Legal_Entity__r.VAT_Declaration_Template__c; 
                }
              }
            } 
         /*BK-22779 Added this to check mixed product in quote Line*/

        
        if (objQLIList.isEmpty()) {
            hasQuoteLineItems = true;
            sMessage = 'There are no products available on the primary quote, please add products for the primary quote.';
            isWarningMsgHold = true;
        }
        if (quoteObj.SBQQ__Account__r.Accounting_Credit_Hold__c == 'Hold') {sMessage = System.Label.Account_Hold_Message_Label;hasQuoteLineItems = true;showConfirmMsg = false;isWarningMsgHold = true;
        }

        if (quoteObj.SBQQ__Account__c != null) {
            acct = [select Id, Name, BillingStreet, Billing_Address_Line_2__c, BillingCity, BillingState, Billingpostalcode, BillingCountry, type from Account where id =: quoteObj.SBQQ__Account__c];
            addressString = acct.BillingStreet != null ? acct.BillingStreet + '\n' + '' : '';
            addressString += acct.Billing_Address_Line_2__c != null ? acct.Billing_Address_Line_2__c + '\n' + '' : '';
            if (string.isBlank(acct.BillingState) && string.isBlank(acct.Billingpostalcode)) {addressString += acct.BillingCity != null ? acct.BillingCity : '';
            } else {addressString += acct.BillingCity != null ? acct.BillingCity + ', ' : '';
            }
            addressString += acct.BillingState != null ? acct.BillingState + ' ' : '';
            addressString += acct.Billingpostalcode != null ? acct.Billingpostalcode + '\n' : '\n';
            addressString += acct.BillingCountry != null ? acct.BillingCountry + '\n' : '';
            quoteObj.AddressOnTemplate__c = addressString;
            if (quoteObj.Billing_Contact__c != null) {
                inDirectAccount = new CongaUtilities().AddressSelection(quoteObj.Billing_Contact__c, quoteObj.SBQQ__Account__c);
            } else {
                inDirectAccount = new List <
                    Account > ();
                inDirectAccount.add(acct);
            }
        }
        for (SBQQ__QuoteLine__c qline: objQLIList) {
            prodQuoteLineMap.put(qline.SBQQ__Product__c, qline);
        }
        
       }
        sessionId = ApexPages.currentPage().getParameters().get('SessionId');
        serverURL = ApexPages.currentPage().getParameters().get('ServerUrl');
        conga = ApexPages.currentPage().getParameters().get('conga');
        redirectToDocuSign = null;
        isBillingContactNull = false;
        showConfirmMsg = false;
    }

    /**
     * @description This method will get the account id that is show on generated documents.
     * @param
     * @return pageReference
     */
    public pageReference addressOnTemplate() {
        addressString = '';
        if (accountId != null) {
            addressString = '';
            for (Account acc: inDirectAccount) {
                if (accountId == acc.Id) {
                    addressString = acc.BillingStreet != null ? acc.BillingStreet + '\n' : '';
                    addressString += acc.Billing_Address_Line_2__c != null ? acc.Billing_Address_Line_2__c + '\n' : '';
                    if (string.isBlank(acc.BillingState) && string.isBlank(acc.Billingpostalcode)) {addressString += acc.BillingCity != null ? acc.BillingCity : '';
                    } else {addressString += acc.BillingCity != null ? acc.BillingCity + ', ' : '';
                    }
                    addressString += acc.BillingState != null ? acc.BillingState + ' ' : '';
                    addressString += acc.Billingpostalcode != null ? acc.Billingpostalcode + '\n' : '\n';
                    addressString += acc.BillingCountry != null ? acc.BillingCountry + '\n' : '';
                }
            }
            if (acct.Id != accountId) {
                quoteObj.Is_From_Partner_Account__c = true;
            } else {
                quoteObj.Is_From_Partner_Account__c = false;
            }
        }
        if (addressString != null) {
            quoteObj.AddressOnTemplate__c = addressString;
            if (quoteObj.SBQQ__Opportunity2__r.stageName != 'Closed Won') {
                update quoteObj;
            }
        }
        showConfirmMsg = true;
        return null;
    }

    public PageReference autorun() {
        User sProfileName = [select Id, Profile.Name, UserRole.Name from User Where Id =: Userinfo.getUserId()]; // GGCKB-20
        if (qouteId != null) {
            if (quoteObj.SBQQ__Account__r.Accounting_Credit_Hold__c == 'Hold') {sMessage = System.Label.Account_Hold_Message_Label;
            }else if(quoteObj.Approval_Status__c=='In Progress' && quoteObj.Event_Edition_Name__c=='Hospitalar 2024'){sMessage = System.Label.Quote_Approval_Status_Message_Label;isBillingContactNull = true;
            }
            // Added by Danish for the ticket BK-27184
            else if((quoteObj.Approval_Status__c == 'Rejected' || quoteObj.Approval_Status__c==null) && quoteObj.Event_Edition_Name__c=='Hospitalar 2024' && quoteObj.Maximum_Discount__c>0){sMessage = System.Label.Quote_Approval_Status_Message_onDiscount;isBillingContactNull = true;
            }
            else if (!isWarningMsg) {
                string quoteStatus = label.QuoteStatusManualContract;
                CongaUtilities cUtilsObj = new CongaUtilities();
                if (quoteObj.SBQQ__Opportunity2__r.StageName != 'Closed Won') {cUtilsObj.cutoffDates(qouteId.escapeHtml4(), quoteObj.SBQQ__Opportunity2__r.Custom_Payment__c);
                } else if (quoteObj.SBQQ__Opportunity2__r.stageName == 'Closed Won' && appbypass.Bypass_Validation_Rules__c) {cUtilsObj.cutoffDates(qouteId.escapeHtml4(), quoteObj.SBQQ__Opportunity2__r.Custom_Payment__c);
                }
                if (quoteObj.Event_Series_Country__c != null) {     companyCountry = cUtilsObj.CountryLocale(quoteObj.Event_Series_Country__c).trim();
                    if (companyCountry.length() > 5) {sMessage = companyCountry;isBillingContactNull = true;return null;
                    }
                } else {
                    sMessage = System.Label.Event_Series_Country_can_not_be_blank;
                    isBillingContactNull = true;
                    isWarningMsgHold = true;
                    if (!test.isRunningTest()) {return null;
                    }
                }
                //Pulling local name of the products.
                if (prodQuoteLineMap.size() > 0) {
                    cUtilsObj.getProductLocalName(prodQuoteLineMap);
                }
                
                //update Rajesh kumar yadav BK-3326/3392
                //Brazil National Barter Contract
                //Brazil International Barter Contract
                //Brazil National FOC Contract
                //Brazil International FOC Contract
                string BrazilNationalBarterContract='';
                string BrazilInternationalBarterContract='';
                string NonBrazilInternationalBarterContract = ''; /*BK-21224*/
                string BrazilNationalFOCContract = '';
                string BrazilInternationalFOCContract = '';
                string NationalDigital ='';
                string InternationalDigital ='';
                if (!quoteObj.Is_a_Local_Company__c && quoteObj.SBQQ__Opportunity2__r.Is_Barter_Opportunity__c  && sProfileName.Profile.Name != 'Sales' && sProfileName.Profile.Name != 'Operations' && sProfileName.Profile.Name != 'GE BA Administrator' && sProfileName.Profile.Name != 'GE System Administrator' && sProfileName.Profile.Name != 'System Administrator') {
                    BrazilInternationalBarterContract = [select id from APXTConga4__Conga_Template__c where APXTConga4__Name__c = 'Brazil International Barter Contract' limit 1].Id;
                  System.debug('BrazilInternationalBarterContract >> '+BrazilInternationalBarterContract);
                }else if(!quoteObj.Is_a_Local_Company__c && quoteObj.SBQQ__Opportunity2__r.Is_Barter_Opportunity__c && (sProfileName.Profile.Name == 'Sales' || sProfileName.Profile.Name == 'Operations' || sProfileName.Profile.Name == 'GE BA Administrator'|| sProfileName.Profile.Name == 'GE System Administrator'|| sProfileName.Profile.Name == 'System Administrator')){
                    NonBrazilInternationalBarterContract = [select id from APXTConga4__Conga_Template__c where APXTConga4__Name__c = 'Non_Brazil_international_Barter_Contract' limit 1].Id;/*BK-21224*/
                    System.debug('NonBrazilInternationalBarterContract>> '+NonBrazilInternationalBarterContract);
                }
                else if (quoteObj.Is_a_Local_Company__c && quoteObj.SBQQ__Opportunity2__r.Is_Barter_Opportunity__c) {BrazilNationalBarterContract = [select id from APXTConga4__Conga_Template__c where APXTConga4__Name__c = 'Brazil National Barter Contract' limit 1].Id;
                }else if(!quoteObj.Is_a_Local_Company__c && quoteObj.SBQQ__Opportunity2__r.Total_FOC_Product_Count__c >= 1){BrazilInternationalFOCContract = [select id from APXTConga4__Conga_Template__c where APXTConga4__Name__c = 'Brazil International FOC Contract' limit 1].Id;}
                else if(quoteObj.Is_a_Local_Company__c && quoteObj.SBQQ__Opportunity2__r.Total_FOC_Product_Count__c >= 1){BrazilNationalFOCContract =[select id from APXTConga4__Conga_Template__c where APXTConga4__Name__c = 'Brazil National FOC Contract' limit 1].Id;}
                else if(quoteObj.Is_a_Local_Company__c && quoteObj.Contract_Type__c =='Digital'){NationalDigital =[select id from APXTConga4__Conga_Template__c where APXTConga4__Name__c = 'BRAZIL National Digital Only Contract' limit 1].Id;}
                else if(!quoteObj.Is_a_Local_Company__c && quoteObj.Contract_Type__c =='Digital'){InternationalDigital =[select id from APXTConga4__Conga_Template__c where APXTConga4__Name__c = 'BRAZIL International Digital Only Contract' limit 1].Id;}
                system.debug('BrazilNationalBarterContract ' +BrazilNationalBarterContract + 'BrazilInternationalBarterContract' + BrazilInternationalBarterContract + 'BrazilNationalFOCContract' + BrazilNationalFOCContract + 'BrazilInternationalFOCContract '+  BrazilInternationalFOCContract);
                //Rajesh kumar yadav BK-3326/3392
                
                String deliverables = '';
                if (quoteObj != null) {
                    if (!String.isEmpty(quoteObj.Quote_Line_Deliverables__c) && quoteObj.Show_Deliverables__c == true) {
                        deliverables = [select id from APXTConga4__Conga_Template__c where APXTConga4__Name__c = 'Deliverables'].Id;
                    }
                    //add template and term conditions...
                    if (!quoteObj.Is_a_Local_Company__c) {
                        //BK-6667
                        oQuoteTCID = [select id, term_conditionIds__c, conga_contract_template_id__c from SBQQ__Quote__c where id =: qouteId];
                        system.debug('oQuoteTCID.term_conditionIds__c 227' + oQuoteTCID.term_conditionIds__c);
                        system.debug('termAndCondition.termAndCondition 227' + termAndCondition+'local company'+quoteObj.Is_a_Local_Company__c);

                        //BK-6386 by Aishwarya Kumar

                        if(!quoteObj.Is_a_Local_Company__c && quoteObj.Contract_Type__c =='Digital'){             if(String.isNotBlank(InternationalDigital)) { templatesContract = InternationalDigital + ',' + deliverables; }

                        }
                        else if (String.isBlank(termAndCondition)) {
                            if (!quoteObj.Is_a_Local_Company__c && quoteObj.SBQQ__Opportunity2__r.Is_Barter_Opportunity__c) {
                                if (String.isNotBlank(BrazilInternationalBarterContract)) {templatesContract = BrazilInternationalBarterContract + ',' + deliverables;
                                }
                                if (String.isNotBlank(NonBrazilInternationalBarterContract)) {templatesContract = NonBrazilInternationalBarterContract + ',' + deliverables;
                                }
                            }else{
                                    system.debug('Inside else' + termAndCondition+'local company'+quoteObj.Is_a_Local_Company__c);

                                if (!String.isBlank(oQuoteTCID.term_conditionIds__c)) {templatesContract = quoteObj.conga_contract_template_id__c + ',' + deliverables + ',' + oQuoteTCID.term_conditionIds__c;
                                        system.debug('Inside else templatesContract'+templatesContract);

                                }else{ templatesContract = quoteObj.conga_contract_template_id__c + ',' + deliverables;}templateQuote = quoteObj.conga_quote_template_id__c + ',' + deliverables;
                            }
                        } else {
                            if (!quoteObj.Is_a_Local_Company__c && quoteObj.SBQQ__Opportunity2__r.Is_Barter_Opportunity__c) {
                                if (String.isNotBlank(BrazilInternationalBarterContract)) { 
                                    if (quoteObj.SBQQ__Type__c == 'Amendment' && (sProfileName.Profile.Name == 'Sales-Brasil' || (sProfileName.Profile.Name == 'SSC Finance-Accounting' && sProfileName.UserRole.Name == 'SSC-Brazil'))) {  
                                        templatesContract = BrazilInternationalBarterContract + ',' + deliverables;
                                    }
                                    else {
                                        templatesContract = BrazilInternationalBarterContract + ',' + deliverables;
                                    }
                                    templateQuote = quoteObj.conga_quote_template_id__c + ',' + deliverables;
                                }
                                /*BK-21224 : if condition for Non Brazil International Barter Contracts start*/
                                if(String.isNotBlank(NonBrazilInternationalBarterContract)){
                                    if(sProfileName.Profile.Name == 'Sales' || sProfileName.Profile.Name == 'Operations' || sProfileName.Profile.Name == 'GE BA Administrator'|| sProfileName.Profile.Name == 'GE System Administrator'|| sProfileName.Profile.Name == 'System Administrator'){
                                        templatesContract = NonBrazilInternationalBarterContract+ ',' + deliverables;
                                    }
                                    templateQuote = quoteObj.conga_quote_template_id__c + ',' + deliverables;
                                }
                                /*BK-21224 : if condition end*/
                            }
                            else if(!quoteObj.Is_a_Local_Company__c && quoteObj.SBQQ__Opportunity2__r.Total_FOC_Product_Count__c >= 1){
                                if (String.isNotBlank(BrazilInternationalFOCContract)) {        if (quoteObj.SBQQ__Type__c == 'Amendment' && (sProfileName.Profile.Name == 'Sales-Brasil' || (sProfileName.Profile.Name == 'SSC Finance-Accounting' && sProfileName.UserRole.Name == 'SSC-Brazil'))) { templatesContract = BrazilInternationalFOCContract + ',' + deliverables;
                                    } else {templatesContract = BrazilInternationalFOCContract + ',' + deliverables;}templateQuote = quoteObj.conga_quote_template_id__c + ',' + deliverables;
                                }
                            }
                            else{
                            //GGCKB-20//BK-7568/BK-7081 Rajesh kumar yadav
                                if (quoteObj.SBQQ__Type__c == 'Amendment' && (sProfileName.Profile.Name == 'Sales-Brasil' || (sProfileName.Profile.Name == 'SSC Finance-Accounting' && sProfileName.UserRole.Name == 'SSC-Brazil'))) {
                                    templatesContract = quoteObj.conga_contract_template_id__c + ',' + deliverables+ ',' + termAndCondition;
                                } else {templatesContract = quoteObj.conga_contract_template_id__c + ',' + deliverables + ',' + termAndCondition;}
                                templateQuote = quoteObj.conga_quote_template_id__c + ',' + deliverables;
                                system.debug('final termAndCondition' + termAndCondition);
                                system.debug('final deliverables' + deliverables);
                                system.debug('final templatesContract' + templatesContract);
                            }
                        }
                    } else {
                        //for local company (Contract) //BK-6385
                        Integer eeCount = [select count() from National_Contract_Template__c where Event_Edition__r.name =: quoteObj.Quote_Event_Edition__c and Type__c = 'Contract Template'];
                        if(quoteObj.Is_a_Local_Company__c && quoteObj.Contract_Type__c =='Digital'){ 
                            if(String.isNotBlank(NationalDigital)) { templatesContract = NationalDigital; }
                        }
                        else if (eeCount <= 0) {   isBillingContactNull = true;showConfirmMsg = false;
                            sMessage = 'It is not a Local Company , Please go to related opportunity and uncheck the \'is a local Company\' check box.';
                            isWarningMsgHold = true;
                        } else {
                            National_Contract_Template__c temp = [select id, name, Event_Edition__c, Conga_Template__c, Term_Conditions__c from National_Contract_Template__c where Event_Edition__r.name =: quoteObj.Quote_Event_Edition__c and Type__c = 'Contract Template'
                                limit 1 ];
                            if (quoteObj.Is_a_Local_Company__c && quoteObj.SBQQ__Opportunity2__r.Is_Barter_Opportunity__c) {
                                if (String.isNotBlank(BrazilNationalBarterContract)) {
                                    if (quoteObj.SBQQ__Type__c == 'Amendment' && (sProfileName.Profile.Name == 'Sales-Brasil' || (sProfileName.Profile.Name == 'SSC Finance-Accounting' && sProfileName.UserRole.Name == 'SSC-Brazil'))) {  templatesContract = BrazilNationalBarterContract;
                                    } else {templatesContract = BrazilNationalBarterContract;}
                                }
                            }else if(quoteObj.Is_a_Local_Company__c && quoteObj.SBQQ__Opportunity2__r.Total_FOC_Product_Count__c >= 1){
                                if (String.isNotBlank(BrazilNationalFOCContract)) {
                                    if (quoteObj.SBQQ__Type__c == 'Amendment' && (sProfileName.Profile.Name == 'Sales-Brasil' || (sProfileName.Profile.Name == 'SSC Finance-Accounting' && sProfileName.UserRole.Name == 'SSC-Brazil'))) {  templatesContract = BrazilNationalFOCContract;
                                    } else {templatesContract = BrazilNationalFOCContract;}
                                }
                            }
                            else{
                                //GGCKB-20//BK-7568/BK-7081 Rajesh kumar yadav
                                if (quoteObj.SBQQ__Type__c == 'Amendment' && (sProfileName.Profile.Name == 'Sales-Brasil' || (sProfileName.Profile.Name == 'SSC Finance-Accounting' && sProfileName.UserRole.Name == 'SSC-Brazil'))) {
                                    templatesContract = temp.Conga_Template__c + ',' + temp.Term_Conditions__c;
                                } else {
                                    templatesContract = temp.Conga_Template__c + ',' + temp.Term_Conditions__c;
                                }
                            }
                        }
                        //for local company (Quote)
                        Integer eeCount1 = [select count() from National_Contract_Template__c where Event_Edition__r.name =: quoteObj.Quote_Event_Edition__c and Type__c = 'Quote Template'];
                        system.debug('eeCount1' + [select count() from National_Contract_Template__c where Event_Edition__r.name =: quoteObj.Quote_Event_Edition__c and Type__c = 'Quote Template']);
                        if (eeCount1 <= 0) {
                            isBillingContactNull = true;
                            showConfirmMsg = false;
                            sMessage = 'It is not a Local Company , Please go to related opportunity and uncheck the \'is a local Company\' check box.369';
                            isWarningMsgHold = true;
                        } else {
                            National_Contract_Template__c tempquote = [select id, name, Event_Edition__c, Conga_Template__c, Term_Conditions__c from National_Contract_Template__c where Event_Edition__r.name =: quoteObj.Quote_Event_Edition__c and Type__c = 'Quote Template'
                                limit 1
                            ];
                            templatequote = tempquote.Conga_Template__c;
                        }
                    }
                    string errormsg = quoteLineValidation(objQLIList);
                    system.debug('errormsg123====> '+ errormsg);
                    // Validating Billing Contact\'s Account Address
                    // Modified By Palla Kishore for the ticket BK-24173
                    if (quoteObj.Billing_Contact__c != null && quoteObj.Billing_Contact__r.Address_Verified__c == false && quoteObj.SBQQ__Opportunity2__r.Address_Validation_Bypass__c == false) {
                        isBillingContactNull = true;
                        sMessage = 'Billing Contact\'s Account Address is not Valid, Please make required changes and try again.';
                        isWarningMsgHold = true;
                    } else if (quoteObj.SBQQ__Primary__c == false) {
                        sMessage = System.Label.Non_Primary_Quote;
                        notPrimaryQuote = true;
                    } else if (quoteObj.Billing_Contact__c != null && CongaUtilities.isBillingAddressNull(quoteObj.Billing_Contact__c)) {isBillingContactNull = true;showConfirmMsg = false;sMessage = 'Incomplete Address on the billing contact,  please fill the address and try again.';isWarningMsgHold = true;
                    } else if (quoteObj.Billing_Contact__c == null) {
                        isBillingContactNull = true;
                        showConfirmMsg = false;
                        /*
                            Modified By: Yash Gupta [As per ticket GGCW-2681]
                        */
                        sMessage = System.Label.Label_Billing_Contact_Missing;
                    }
                    // Added by Palla Kishore for the ticket BK-22140
                    else if (quoteObj.conga_quote_template_id__c == null) {
                        isBillingContactNull = true;
                        showConfirmMsg = false;
                        sMessage = System.Label.Label_Conga_Quote_Template_Id_Missing;
                    } 
                    else if (quoteObj.conga_contract_template_id__c == null) {
                        isBillingContactNull = true;
                        showConfirmMsg = false;
                        sMessage = System.Label.Label_Conga_Contract_Template_Id_Missing;
                    } 
                   else if (quoteObj.SBQQ__Account__c != null && quoteObj.SBQQ__Account__r.BillingStreet != null && quoteObj.SBQQ__Account__r.BillingStreet.contains('"')){ 
                            isBillingContactNull = true;
                            showConfirmMsg = false;
                            sMessage = 'Billing Street On Account Contains Double Quotes Please Remove.';
                        } 
                     else  if(quoteObj.SBQQ__Account__c != null && quoteObj.SBQQ__Account__r.BillingCity != null && quoteObj.SBQQ__Account__r.BillingCity.contains('"')) {
                            isBillingContactNull = true;
                            showConfirmMsg = false;
                            sMessage = 'Billing City On Account Contains Double Quotes Please Remove.';
                        }
                    
                   else if (quoteObj.SBQQ__PrimaryContact__c != null && quoteObj.SBQQ__PrimaryContact__r.FirstName != null && quoteObj.SBQQ__PrimaryContact__r.FirstName.contains('"')){ 
                            isBillingContactNull = true;
                            showConfirmMsg = false;
                            sMessage = 'First Name on Contact Contains Double Quotes Please Remove.';
                        }
                      else  if(quoteObj.SBQQ__PrimaryContact__c != null && quoteObj.SBQQ__PrimaryContact__r.LastName != null && quoteObj.SBQQ__PrimaryContact__r.LastName.contains('"') ) {
                            isBillingContactNull = true;
                            showConfirmMsg = false;
                            sMessage = 'Last Name on Contact Contains Double Quotes Please Remove.';
                        }
                    
                   else if (quoteObj.SBQQ__Opportunity2__c != null && quoteObj.SBQQ__Opportunity2__r.Name != null && quoteObj.SBQQ__Opportunity2__r.Name.contains('"') ) {
                           isBillingContactNull = true;
                           showConfirmMsg = false;
                           sMessage = 'Opportunity Name Contains Double quotes Please Remove.';
                         } 
                 // Product Double quotes field check
                    else if(string.isNotBlank(errormsg)){
                       system.debug('errormsg====> '+ errormsg);
                       isBillingContactNull = true;
                        showConfirmMsg = false;
                        sMessage = errormsg; 
                    }
                    // Added by Palla Kishore for the ticket BK-20651
                    if (quoteObj.SBQQ__Opportunity2__c != null && quoteObj.SBQQ__Opportunity2__r.Event_Series__c != null && quoteObj.SBQQ__Opportunity2__r.Event_Series__r.Legal_Entity__c != null && quoteObj.SBQQ__Opportunity2__r.Event_Series__r.Legal_Entity__r.Supplier_License_Number__c == null && quoteObj.SBQQ__Opportunity2__r.Event_Series__r.Legal_Entity__r.blng__Country__c == 'United Arab Emirates' && quoteObj.SBQQ__Account__r.BillingCountry != 'United Arab Emirates') {
                            isBillingContactNull = true;
                            showConfirmMsg = false;
                            sMessage = System.Label.Label_Supplier_License_Number_Missing;
       			    }
                    //Added by Palla Kishore for the ticket BK-19643 validating Simples Nacional/National Classification fields on the Account is blank or not.
                    else if ('Sales-Brasil'.equalsIgnoreCase(sProfileName.profile.name) && quoteObj.SBQQ__Account__c <>null && 'Brasil'.equalsIgnoreCase(quoteObj.SBQQ__Account__r.BillingCountry) && (string.isBlank(quoteObj.SBQQ__Account__r.Simples_Nacional__c) || string.isBlank(quoteObj.SBQQ__Account__r.National_Classification__c))){
                    isBillingContactNull = true;
                        showConfirmMsg = false;
                        sMessage = System.Label.Two_Account_Fields_Required_For_Brazil;
                    }
                    /*
                           Modified By: Shiv Raghav [As per ticket GGCKB-89]
                           Description :- I have made below changes into elseif condition
                           old Condition - (quoteObj.SBQQ_Statusc == 'Contract Sent' || quoteObj.SBQQStatusc == 'Contract Approved' && !quoteObj.Manual_c)
                           New Condition - ((quoteObj.SBQQ__Status__c == 'Contract Sent' || quoteObj.SBQQ__Status__c == 'Contract Approved') && quoteObj.Manual__c == False)
                    */
                    else if ((quoteObj.SBQQ__Status__c == 'Contract Sent' || quoteObj.SBQQ__Status__c == 'Contract Approved') && quoteObj.Manual__c == False) {
                        showConfirmMsg = false;isBillingContactNull = true;sMessage = 'A Docusign Quote has already been generated you cannot use the Manual feature.';isWarningMsgHold = true;
                    } else {
                        // Validating products are added to the quote or not.
                        pageReference pg = null;
                        if (!objQLIList.isEmpty()) {
                            hasQuoteLineItems = false;
                            quoteObj.IsNotGeneralDocument__c = true;
                            redirectToDocuSign = pg;
                            if (quoteObj.SBQQ__Opportunity2__c != null) {
                                if (!appbypass.Bypass_Validation_Rules__c && (quoteObj.SBQQ__Opportunity2__r.StageName == 'Closed Won' || quoteObj.SBQQ__Opportunity2__r.StageName == 'Closed Lost' || quoteObj.SBQQ__Opportunity2__r.StageName == 'Closed Booked')) {
                                    sMessage = System.Label.Sales_User_Alert2 + ' ' + quoteObj.SBQQ__Opportunity2__r.StageName;hasPartner = true;isWarningMsgHold = true;
                                } else {
                                    update quoteObj;
                                }
                            }
                        }
                    }
                }
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
        return null;
    }
    public pageReference continueCmd() {
        pageReference pg;
        if (template == 'Quote') {ishideQuoteCtdn = true;

        } else if (conga == 'conga') {
            if (inDirectAccount.size() > 1) {showConfirmMsg = false;
            } else {showConfirmMsg = true;
            }
        }
        if (inDirectAccount.size() > 1) { isShowAccountSection = true;showConfirmMsg = false;ishideQuoteCtdn = true;
        } else {
            showConfirmMsg = true;
            isShowAccountSection = false;
        }
        return pg;
    }

    /**
     * @description This method redirect to docusign page.
     * @param
     * @return pageReference
     */
    public PageReference redirectToDS() {
        return redirectToDocuSign;
    }

    /**
     * @description This method generate validate pre-contract conditions like quote must be primary and then generate conga contract.
     * @param
     * @return pageReference
     */
    public PageReference generateDoc() {
        pageReference pg;
        quoteObj.SBQQ__Primary__c = true;
        quoteObj.EE_Contract_Special_Conditions__c = quoteObj.SBQQ__Opportunity2__r.EventEdition__r.Contract_Special_Conditions__c;
        
        update quoteObj;
        System.debug('Akshi Debug: template' + template);
        if (template == 'Quote') {
            if (!objQLIList.isEmpty()) {
                hasQuoteLineItems = false;
                string retPathforQuote = '/apex/CongaPreviewPage?quoteId=' + qouteId.escapeHtml4() + '~ManualContract';
                //Add one conga param : currencyCulture for currency formatting.
                string url = '/apex/APXTConga4__Conga_Composer?SolMgr=1&sessionId=' + sessionId.escapeHtml4() + '&serverUrl=' + serverURL.escapeHtml4() + '&Id=' + qouteId.escapeHtml4() + '&TemplateId=' + templateQuote + '&QueryId=' + congaQueries + '&DS7=1&BML=Generating+Quote+for+' + quoteObj.Primary_Contact_Info__c + '&UF0=1&MFTS0=Version__c&MFTSValue0=' + quoteObj.Next_Version__c + '&MFTS1=Manual__c&MFTSValue1=true&OFN=Manual+Quote+for+' + quoteObj.Primary_Contact_Info__c + '-v' + quoteObj.Version__c + '&SC0=1&SC1=SalesforceFile&DefaultPDF=1&ReturnPath=' + retPathforQuote + '&Culture=' + companyCountry + '&CurrencyCulture=' + companyCountry + congaAdditionalParams;
                pg = new pageReference(url);
            }
        } else if (template == 'Contract') {
            if (!objQLIList.isEmpty()) {
                hasQuoteLineItems = false;
                //string congaQueries = System.label.conga_queries;
                //BK-2871 ::: Modified by Avinash
                string retPath = '/apex/CongaPreviewPage?quoteId=' + qouteId.escapeHtml4() + '~ManualContract';
                //Add one conga param : currencyCulture for currency formatting.
                string url = '/apex/APXTConga4__Conga_Composer?SolMgr=1&sessionId=' + sessionId.escapeHtml4() + '&serverUrl=' + serverURL.escapeHtml4() + '&Id=' + QouteId.escapeHtml4() + '&TemplateId=' + templatesContract + '&QueryId=' + congaQueries + '&DS7=1&BML=Generating+Contract+for+' + quoteObj.Primary_Contact_Info__c + '&UF0=1&MFTS0=Version__c&MFTSValue0=' + quoteObj.Next_Version__c + '&MFTS1=Manual__c&MFTSValue1=true&OFN=Manual+contract+for+' + quoteObj.Primary_Contact_Info__c + '-v' + quoteObj.Version__c + '&SC0=1&SC1=SalesforceFile&DefaultPDF=1&ReturnPath=' + retPath + '&Culture=' + CompanyCountry + '&CurrencyCulture=' + CompanyCountry + congaAdditionalParams;
                System.debug('url : '+url);
                pg = new pageReference(url);
            }
        }
        return pg;
    }
    /**
     * @description This method redirect to the currenct quote.
     * @param
     * @return pageReference
     */
    public PageReference returnToPT() {
        pageReference pg = new pageReference('/' + qouteId);
        return pg;
    }

    /**
     * @description Utility method to get pegerefernance parameters
     * @param pname
     * @return String
     */
    @TestVisible
    private String getURParameter(String pname) {
        PageReference pageRef = ApexPages.currentPage();
        Map < string, string > pageParameters = pageRef.getParameters();
        string p = pageParameters.get(pname);
        return p;
    }    
   // Added by Palla Kishore for ticket BK-22140
public static String quoteLineValidation(list<SBQQ__QuoteLine__c> lstQl){
        if(lstQl.isEmpty()){
            return '';
        }
        Boolean booleanValidatefailed = false;
        String errorMessage= '';
        for(SBQQ__QuoteLine__c ql : lstQl ){
            List<String> errorFields = new List<String>();
            if(ql.SBQQ__Product__r.Name != null && ql.SBQQ__Product__r.Name.contains('"')){
                errorFields.add('Name');
            }
            if(ql.SBQQ__Product__r.Description != null && ql.SBQQ__Product__r.Description.contains('"')){
                errorFields.add('Product Description');
            }
            if(ql.SBQQ__Product__r.Description_in_Alt_Language__c != null && ql.SBQQ__Product__r.Description_in_Alt_Language__c.contains('"')){
                errorFields.add('Description in Alt Language');
            }
            if (!errorFields.isEmpty()) {
                booleanValidateFailed = true;
                String error = 'Product Name - ' + ql.SBQQ__Product__r.Name + ' has double quotes in fields: ' + string.join(errorFields,',');
                errorMessage = error;
                break;
            }
        }
        return errorMessage;
    }

}