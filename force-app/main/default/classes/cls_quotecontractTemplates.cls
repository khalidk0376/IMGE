/**
 * File:        cls_quotecontractTemplates.cls
 * Project:     GAP
 * Date:        9/8/2017
 * Created By:  Abdul Kadir
 * Test Class : cls_quotecontractTemplates_Test(85%)
 * *************************************************************************
 * Description: This class validate primary quote,billing and Quote line  items(Products) added to this quote after that it generate conga template to show on the vf page for preview.
 * *************************************************************************
 * History: Modified by Rajesh Kumar on Jira Tickets : GGCW-3081
 * History: Modified by Akshi Arora on 05/15/2019 for Kanaban Ticket : GGCKB-20
 * Modified By : Avinash Shukla BK-2871/BK-2973/74
 * Modified By: Akshi Arora for BK-2871/BK-2973/74
 * Modified By : Rajesh Kumar - BK-10316 on 05-11-2020


 * Modified By : Rajesh Kumar - BK-11940 - 20-01-2021 - Notes & attachment


 */
public class cls_quotecontractTemplates {

    public List<National_Contract_Template__c> lstNationalctrtemplt {get; set;}
    public string quoteId {get; set;}
    public string sessionId;
    public string serverURL;
    public string ids {get; set;}
    public string template {get; set;}
    public SBQQ__Quote__c oQuote {get; set;}
    public string sMessage {get; set;}
    public boolean nullQuoteLines {get; set;}
    public string docName {get; set;}
    public String companyCountry {get; set;}
    public Map <Id, SBQQ__QuoteLine__c> prodQuoteLineMap {get; set;}
    public list < APXTConga4__Conga_Template__c > congaTemplates {get; set;}
    public List <Account> inDirectAccount {get; set;}
    public String addressString {get; set;}
    public Account acct {get; set;}
    public String accountId {get; set;}
    public  Application_Bypass__c appBypass {get; set;}
	//BK-13894 Shiv Raghav
	public String termAndCondition = '';
    public cls_quotecontractTemplates(ApexPages.StandardController controller) {

        quoteId = ApexPages.currentPage().getParameters().get('quoteId').escapeHtml4();
        sessionId = ApexPages.currentPage().getParameters().get('SessionId').escapeHtml4();
        serverURL = ApexPages.currentPage().getParameters().get('ServerUrl').escapeHtml4();
        appBypass = Application_Bypass__c.getInstance();
        lstNationalctrtemplt = new List    <National_Contract_Template__c>();

        oQuote = [select id, Online_Opportunity_Quote__c, Online_Opportunity_Quote_Check__c , National_contract_and_TC_Ids__c, Name, Product_Attachments__c, SBQQ__PrimaryContact__c, Primary_Contact_Info__c, documentType__c, Next_Version__c, SBQQ__Opportunity2__r.Custom_Payment__c, conga_quote_template_id__c, term_conditionIds__c, SBQQ__Opportunity2__r.EventEdition__r.Alternative_Terms_Condition_Template__c,SBQQ__Opportunity2__r.EventEdition__r.Terms_Condition_Template__c,conga_contract_template_id__c, Quote_Event_Edition__c, Is_a_Local_Company__c, ISO_Code_Logo__c, SBQQ__Opportunity2__r.stageName, Quote_Line_Deliverables__c, Show_Deliverables__c, ES_Company_Country__c, Event_Series_Country__c, SBQQ__Account__c, Billing_Contact__c, SBQQ__Type__c from SBQQ__Quote__c where id = : quoteId limit 1];
        oQuote.documentType__c = '';
		//BK-13894 Shiv Raghav
		if(oQuote.Online_Opportunity_Quote_Check__c && oQuote.SBQQ__Opportunity2__r.EventEdition__r.Alternative_Terms_Condition_Template__c != null)
		{
			termAndCondition = oQuote.SBQQ__Opportunity2__r.EventEdition__r.Alternative_Terms_Condition_Template__c;
		}
		else if(oQuote.SBQQ__Opportunity2__r.EventEdition__r.Terms_Condition_Template__c != null)
		{
			termAndCondition = oQuote.SBQQ__Opportunity2__r.EventEdition__r.Terms_Condition_Template__c;
		}
		
        list < SBQQ__QuoteLine__c > objQLIList = [select id, SBQQ__Quote__r.SBQQ__Opportunity2__c, SBQQ__Product__c, SBQQ__Quote__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = : ApexPages.currentPage().getParameters().get('quoteId')];
        string opptyId;
        if (oQuote.SBQQ__Account__c != null ) {
            acct = [select Id, Name, BillingStreet, Billing_Address_Line_2__c, BillingCity, BillingState, Billingpostalcode, BillingCountry, type from Account where id = : oQuote.SBQQ__Account__c];
            addressString = acct.BillingStreet != null ? acct.BillingStreet + '\n' + '' : '';
            addressString += acct.Billing_Address_Line_2__c != null ? acct.Billing_Address_Line_2__c + '\n' + '' : '';
            if (string.isBlank(acct.BillingState) && string.isBlank(acct.Billingpostalcode)) {
                addressString += acct.BillingCity != null ? acct.BillingCity : '';
            } else { addressString += acct.BillingCity != null ? acct.BillingCity + ', ' : '';
            }
            addressString += acct.BillingState != null ? acct.BillingState + ' ' : '';
            addressString += acct.Billingpostalcode != null ? acct.Billingpostalcode + '\n' : '\n';
            addressString += acct.BillingCountry != null ? acct.BillingCountry + '\n' : '';
            oQuote.AddressOnTemplate__c = addressString;
            if (oQuote.Billing_Contact__c != null) {
                inDirectAccount = new CongaUtilities().AddressSelection(oQuote.Billing_Contact__c, oQuote.SBQQ__Account__c);
            } else {
                inDirectAccount = new List
                <Account>();
                inDirectAccount.add(acct);
            }
        }
        prodQuoteLineMap = new Map <Id, SBQQ__QuoteLine__c>();
        for (SBQQ__QuoteLine__c qline : objQLIList) { prodQuoteLineMap.put(qline.SBQQ__Product__c, qline);
        }
        if (!objQLIList.isEmpty()) { opptyId = objQLIList[0].SBQQ__Quote__r.SBQQ__Opportunity2__c;
        }
        //Validating products are added to the quote or not.
        if (objQLIList.isEmpty()) {
            nullQuoteLines = true;
            sMessage = 'There are no products available on this quote, please add products for this quote.';
        } else { nullQuoteLines = false;
        }
        // Validating Billing Contact is not null.
        for (Opportunity opp : [select id, stageName, Opportunity_Contact__c, Billing_Contact__c from Opportunity where id = : opptyId]) {
            if (opp.Billing_Contact__c == null) {
                nullQuoteLines = true;
                sMessage = 'Billing/Invoice Contact is Missing on Quote. Please assign the Billing/Invoice contact on the opportunity in order to proceed.';
            }
        }
    }
    /**
     * @description This method will calculate the cut off date and amount.
     * @param
     * @return pageReference
    */
    public pageReference autorun() {
        CongaUtilities cUtilsObj = new CongaUtilities();
        if (oQuote.SBQQ__Opportunity2__r.StageName != 'Closed Won') {
            cUtilsObj.cutoffDates(quoteId.escapeHtml4(), oQuote.SBQQ__Opportunity2__r.Custom_Payment__c);
        } else if (oQuote.SBQQ__Opportunity2__r.stageName == 'Closed Won' && appBypass.Bypass_Validation_Rules__c) {
            cUtilsObj.cutoffDates(quoteId.escapeHtml4(), oQuote.SBQQ__Opportunity2__r.Custom_Payment__c);
        }
        if (oQuote.Event_Series_Country__c != null) {
            companyCountry = cUtilsObj.CountryLocale(oQuote.Event_Series_Country__c).trim();
            if (companyCountry.length() > 5) {
                sMessage = companyCountry;
                nullQuoteLines = true;
            }
        } else {
            sMessage = System.Label.Event_Series_Country_can_not_be_blank;
            nullQuoteLines = true;
        }
        //Pulling local name of the products.
        if (prodQuoteLineMap.size() > 0) { cUtilsObj.getProductLocalName(prodQuoteLineMap);
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
        if (accountId != null ) {
            addressString = '';
            for (Account acc : inDirectAccount) {
                if (accountId == acc.Id) {
                    addressString = acc.BillingStreet != null ? acc.BillingStreet + '\n' : '';
                    addressString += acc.Billing_Address_Line_2__c != null ? acc.Billing_Address_Line_2__c + '\n' : '';
                    if (string.isBlank(acc.BillingState) && string.isBlank(acc.Billingpostalcode)) {
                        addressString += acc.BillingCity != null ? acc.BillingCity : '';
                    } else { addressString += acc.BillingCity != null ? acc.BillingCity + ', ' : '';
                    }
                    addressString += acc.BillingState != null ? acc.BillingState + ' ' : '';
                    addressString += acc.Billingpostalcode != null ? acc.Billingpostalcode + '\n' : '\n';
                    addressString += acc.BillingCountry != null ? acc.BillingCountry + '\n' : '';
                }
            }
            if (acct.Id != accountId) { oQuote.Is_From_Partner_Account__c = true;
            } else { oQuote.Is_From_Partner_Account__c = false;
            }
        }
        if (addressString != null) {
            oQuote.AddressOnTemplate__c = addressString;
            if (oQuote.SBQQ__Opportunity2__r.stageName != 'Closed Won') {
                update oQuote;
            } else if (oQuote.SBQQ__Opportunity2__r.stageName == 'Closed Won' && appBypass.Bypass_Validation_Rules__c) { update oQuote;
            }

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
    public pageReference showQuoteAttachment() {
        return null;
    }
    String termCondi = '';
    /**
     * @description check for national and international template and generate the Quote/Contract as per the picklist value selected for preview.
     * @param
     * @return pageReference
    */
    public pageReference continueCmd() {

        String templateId = '';
        string congaQueries = System.label.conga_queries;
        string congaQueriesOOQ = System.label.conga_queries_Online_Opportunity_Quote ;
        if(oQuote.Online_Opportunity_Quote_Check__c && String.isNotBlank(congaQueriesOOQ) ) {
           congaQueries = congaQueries+','+congaQueriesOOQ+'='+oQuote.Online_Opportunity_Quote__c;
           }else{
               congaQueries = congaQueries;
           }
        string templateName;
        String deliverables = '';
        DateTime objDate = DateTime.now();
        User sProfileName = [select Id, Profile.Name, UserRole.Name from User Where Id = :UserInfo.getUserId()];
        if (oQuote.Quote_Line_Deliverables__c != null && oQuote.Show_Deliverables__c == true) {
            deliverables = [select id from APXTConga4__Conga_Template__c where APXTConga4__Name__c = 'Deliverables'].Id;
        }
        //SOQL Injection SCA Violation removal ::: MOdified by Avinash Shukla BK-2871/17/2973/74 ::: 22/811/2019
        //GGCW-3081
        if (template == 'Quote') {
            lstNationalctrtemplt = [Select id, name, Event_Edition__c, Conga_Template__c, Term_Conditions__c from National_Contract_Template__c where Event_Edition__r.name = : oQuote.Quote_Event_Edition__c AND Type__c = 'Quote Template'];
        } else if (template == 'Contract') {
            lstNationalctrtemplt = [Select id, name, Event_Edition__c, Conga_Template__c, Term_Conditions__c from National_Contract_Template__c where Event_Edition__r.name = : oQuote.Quote_Event_Edition__c AND Type__c = 'Contract Template'];
        }
        if (template == 'Quote') {
            docName = oQuote.Name + '-' + String.valueOf(objDate);
            if (!oQuote.Is_a_Local_Company__c) { templateId = oQuote.conga_quote_template_id__c + ',' + deliverables;
            } else {
                //for local company
                Integer eeCount = [select count() from National_Contract_Template__c where Event_Edition__r.name = : oQuote.Quote_Event_Edition__c and Type__c = 'Quote Template'];
                if (eeCount <= 0) {
                    nullQuoteLines = true;
                    sMessage = 'It is not a Local Company , Please go to related opportunity and uncheck the \'Is a Local Company\' check box.';
                    return null;
                } else {
                    if (lstNationalctrtemplt.size() > 0) {
                        templateId = lstNationalctrtemplt[0].Conga_Template__c;
                    }
                }
            }
        } else if (template == 'Contract') {
            docName = oQuote.Name + '-' + String.valueOf(objDate);
            if (!oQuote.Is_a_Local_Company__c) {
                if (String.isBlank(termAndCondition)) { templateId = oQuote.conga_contract_template_id__c + ',' + deliverables;
                } else {
                    //GGCKB-20
                    if (oQuote.SBQQ__Type__c == 'Amendment' && (sProfileName.Profile.Name == 'Sales-Brasil' || (sProfileName.Profile.Name == 'SSC Finance-Accounting' && sProfileName.UserRole.Name == 'SSC-Brazil'))) {
                        templateId = oQuote.conga_contract_template_id__c + ',' + deliverables;
                    } else { templateId = oQuote.conga_contract_template_id__c + ',' + deliverables + ',' + termAndCondition;
                    }
                }
            } else {
                //for local company
                Integer eeCount = [select count() from National_Contract_Template__c where Event_Edition__r.name = : oQuote.Quote_Event_Edition__c and Type__c = 'Contract Template'];
                if (eeCount <= 0) {
                    nullQuoteLines = true;
                    sMessage = 'It is not a local Company , Please go to related opportunity and uncheck the \'Is a Local Company\' check box.';
                    return null;
                } else {
                    if (lstNationalctrtemplt.size() > 0) {
                        //GGCKB-20
                        if (oQuote.SBQQ__Type__c == 'Amendment' && (sProfileName.Profile.Name == 'Sales-Brasil' || (sProfileName.Profile.Name == 'SSC Finance-Accounting' && sProfileName.UserRole.Name == 'SSC-Brazil'))) {
                            templateId = lstNationalctrtemplt[0].Conga_Template__c;
                        } else {
                            templateId = lstNationalctrtemplt[0].Conga_Template__c + ',' + lstNationalctrtemplt[0].Term_Conditions__c;
                            oQuote.National_contract_and_TC_Ids__c = templateId;
                        }
                    }
                }
            }
        }
        if (oQuote.SBQQ__Opportunity2__r.stageName != 'Closed Won') {
            update oQuote;
        } else if (oQuote.SBQQ__Opportunity2__r.stageName == 'Closed Won' && appBypass.Bypass_Validation_Rules__c) { update oQuote;
        }
        //Updated By Rajesh Yadav ticket number and GRQ BK-1345 and GRQ0322635
        //Added Value (&DV0=Preview Only)
        string congaAdditionalParams = System.label.conga_Additional_Params;
        String retpath = '/apex/CongaPreviewPage?quoteId=' + quoteId.escapeHtml4() + '~Preview';

        string url = '/apex/APXTConga4__Conga_Composer?sessionId=' + sessionId.escapeHtml4() + '&serverUrl=' + serverURL.escapeHtml4() + '&Id=' + quoteId.escapeHtml4() + '&TemplateId=' + templateId + '&QueryId=' + congaQueries + '&DS7=1&DV0=Preview Only&BML=Generating+Preview+Document+for+' + oQuote.Primary_Contact_Info__c + '&SC0=1&SC1=SalesforceFile&DefaultPDF=1&OFN=' + docName + '&ReturnPath=' + retpath + '&Culture=' + companyCountry + '&CurrencyCulture=' + companyCountry + congaAdditionalParams;

        pageReference pg = new pageReference(url);
        return pg;
    }
}