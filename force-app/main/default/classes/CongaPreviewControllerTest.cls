/**
* Project:     GAP
* Date:        Sep 01, 2016
* Test Class:  CongaPreviewControllerTest
* Created By:  Abdul Qadir
* Modified and created : Rajesh Kumar on 28/03/2019
* *************************************************************************
* @description This class used from quoteline item trigger QuotelineMerge to release booths if all QLI is deleted for Booths
from Opportunity.
* *************************************************************************
* We are replicated funcationality from both triggers, which is runing on Quote line trigger.
* Modified By : Avinash Shukla BK-2871/BK-2973/74
* Modified By : Rajesh kumar yadav BK-5865
*/
@isTest
public class CongaPreviewControllerTest {
    @isTest
    static void setUp() {
        Pricebook2 pb = new Pricebook2(Name = 'TestPricebook');
        insert pb;
        
        Application_Bypass__c appBypass = new Application_Bypass__c();
        appBypass.Docusign_Counter_Sign__c = true;
        insert appBypass;
        
        Event_Series__c es = new Event_Series__c(Name = 'Test');
        es.Local_Country__c = 'Brasil';
        es.Company_Country__c = 'Brasil';
        es.Not_By_pass_Local_Template__c = true;
        insert es;
        
        Event_Edition__c ee = new Event_Edition__c();
        ee.Name = 'TestEvent';
        ee.Tab1__c = 'tab1';
        ee.Tab4__c = 'tab4';
        ee.Tab7__c = 'tab7';
        ee.Tab8__c = 'Tab8__c';
        ee.Part_of_Series__c = es.Id;
        ee.Show_Deliverables__c = true;
        ee.Payment_Schedule__c = '25-25-25-25';
        ee.End_Date__c= date.today();
        ee.Event_Code__c ='BRA20FRM';
        ee.X50_Cutoff_Date__c = date.today();
        ee.Cutoff_Date_1__c = date.today().addDays(1);
        ee.Cutoff_Date_2__c = date.today().addDays(2);
        ee.Cutoff_Date_3__c = date.today().addDays(3);
        ee.Event_Price_Book__c = pb.Id;
        ee.Allow_Docusign_Counter_Sign__c = true;
        insert ee;
        
        APXTConga4__Conga_Template__c ct = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'test');
        insert ct;
        APXTConga4__Conga_Template__c ctDeli = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Deliverables');
        insert ctDeli;
        APXTConga4__Conga_Template__c ctDeli1 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Brazil International Barter Contract');
        insert ctDeli1;
        APXTConga4__Conga_Template__c ctDetails2 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Brazil National Barter Contract');
        insert ctDetails2;
         APXTConga4__Conga_Template__c ctDetails3 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Brazil National FOC Contract');
        insert ctDetails3;
       
     
        National_Contract_Template__c nct = new National_Contract_Template__c();
        nct.Event_Edition__c = ee.Id;
        nct.Conga_Template__c = ct.Id;
        nct.Term_Conditions__c = ct.Id;
        insert nct;
        
        National_Contract_Template__c nationalTemp = new National_Contract_Template__c();
        nationalTemp.Event_Edition__c = ee.Id;
        nationalTemp.Conga_Template__c = ct.Id;
        nationalTemp.Term_Conditions__c = ct.Id;
        nationalTemp.Type__c = 'Quote Template';
        insert nationalTemp;
        
        National_Contract_Template__c nationalTemp1 = new National_Contract_Template__c();
        nationalTemp1.Event_Edition__c = ee.Id;
        nationalTemp1.Conga_Template__c = ct.Id;
        nationalTemp1.Term_Conditions__c = ct.Id;
        nationalTemp1.Type__c = 'Contract Template';
        insert nationalTemp1;
        
        Account acct = new Account(Name = 'testAccount', CurrencyIsoCode = 'EUR', BillingCountry = 'Brasil');
        insert acct;
        
        Contact ocontact = new Contact();
        ocontact.Email = 'test.test@gmail.com';
        ocontact.Phone = '1234567890';
        ocontact.FirstName = 'TestFN';
        ocontact.LastName = 'testLN';
        ocontact.AccountId = acct.Id;
        ocontact.MailingStreet = 'TestStreet';
        ocontact.MailingCity = 'Delhi';
        ocontact.MailingPostalCode = '110025';
        ocontact.MailingState = 'Delhi';
        ocontact.MailingCountry = 'India';
        ocontact.Fax = '1234567890';
        ocontact.Address_Verified__c = false;
        insert ocontact;
        
        Opportunity oppty = new Opportunity(Name = 'testOpp', EventEdition__c = ee.Id);
        oppty.AccountId = acct.Id;
        oppty.StageName = 'Discover';
        oppty.CloseDate = date.today();
        oppty.Not_a_Brazilian_Company__c = true;
        oppty.Event_Series__c = es.Id;
        oppty.isThroughDcousign__c = true;
        oppty.Is_Barter_Opportunity__c = true;
        oppty.isThroughDcousign__c = true;
        insert oppty;
        oppty.Is_Barter_Opportunity__c = false;
        oppty.isThroughDcousign__c = false;
        update oppty;
        
        
        SBQQ__Quote__c qtObj = new SBQQ__Quote__c();
        qtObj.SBQQ__Account__c = acct.Id;
        qtObj.SBQQ__Status__c = 'Draft';
        qtObj.SBQQ__Type__c = 'Amendment';
        qtObj.SBQQ__StartDate__c = date.today();
        qtObj.Alternate_Currency2__c = 'EUR';
        qtObj.SBQQ__Opportunity2__c = oppty.Id;
        qtObj.Billing_Contact__c = ocontact.Id;
        qtObj.Quote_Line_Deliverables__c = 'testing';
        qtObj.SBQQ__Primary__c = true;
        qtObj.Quote_Event_Edition__c = ee.Name;
        //qtObj.Contract_Type__c = 'Digital';
        insert qtObj;
        system.AssertEquals('TestEvent' , ee.Name, 'Error ::: Event not created');
    }
    
    @isTest
    static void setUp2(){
        Pricebook2 pb = new Pricebook2(Name = 'TestPricebook');
        insert pb;
        
        Application_Bypass__c appBypass = new Application_Bypass__c();
        appBypass.Docusign_Counter_Sign__c = true;
        insert appBypass;
        
        Event_Series__c es = new Event_Series__c(Name = 'Tests');
        es.Local_Country__c = 'Brazil';
        es.Company_Country__c = 'Brazil';
        es.Not_By_pass_Local_Template__c = false;
        insert es;
        
        Event_Edition__c ee = new Event_Edition__c();
        ee.Name = 'TestEvents';
        ee.Tab1__c = 'tab1';
        ee.Tab4__c = 'tab4';
        ee.Tab7__c = 'tab7';
        ee.Tab8__c = 'Tab8__c';
        ee.Part_of_Series__c = es.Id;
        ee.Show_Deliverables__c = true;
        ee.Payment_Schedule__c = '25-25-25-25';
        ee.End_Date__c= date.today();
        ee.Event_Code__c ='BRA20FRM';
        ee.X50_Cutoff_Date__c = date.today();
        ee.Cutoff_Date_1__c = date.today().addDays(1);
        ee.Cutoff_Date_2__c = date.today().addDays(2);
        ee.Cutoff_Date_3__c = date.today().addDays(3);
        ee.Allow_Docusign_Counter_Sign__c = true;
        insert ee;
        APXTConga4__Conga_Template__c ctDetails1 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'test');
        insert ctDetails1;
        APXTConga4__Conga_Template__c ctDetails2 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Deliverables');
        insert ctDetails2;
        APXTConga4__Conga_Template__c ctDetails3 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Brazil International Barter Contract');
        insert ctDetails3;
        APXTConga4__Conga_Template__c ctDetails4 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'BRAZIL International Digital Only Contract');
        insert ctDetails4;
        APXTConga4__Conga_Template__c ctDetails5 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Non_Brazil_international_Barter_Contract');
        insert ctDetails5;
        APXTConga4__Conga_Template__c ctDetails6 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'BRAZIL National Digital Only Contract');
        insert ctDetails6;
        APXTConga4__Conga_Template__c ctDetails7 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Brazil National Barter Contract');
        insert ctDetails7;
         APXTConga4__Conga_Template__c ctDetails8 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Brazil National FOC Contract');
        insert ctDetails8;
        
        National_Contract_Template__c nationalTemp3 = new National_Contract_Template__c();
        nationalTemp3.Event_Edition__c = ee.Id;
        nationalTemp3.Conga_Template__c = ctDetails5.id;
        nationalTemp3.Term_Conditions__c = ctDetails1.Id;
        nationalTemp3.Type__c = 'Contract Template';
        insert nationalTemp3;
        
        /*For local country*/
        Account acctNonLocal = new Account(Name = 'testAccountNonLocal', CurrencyIsoCode = 'EUR', BillingCountry = 'India');
        insert acctNonLocal;
        
        Contact ocontactNonLocal = new Contact();
        ocontactNonLocal.Email = 'test.testNonLocal@gmail.com';
        ocontactNonLocal.Phone = '1234567890';
        ocontactNonLocal.FirstName = 'TestFNNonLocal';
        ocontactNonLocal.LastName = 'testLNNonLocal';
        ocontactNonLocal.AccountId = acctNonLocal.Id;
        ocontactNonLocal.MailingStreet = 'TestStreetNonLocal';
        ocontactNonLocal.MailingCity = 'Delhi';
        ocontactNonLocal.MailingPostalCode = '110025';
        ocontactNonLocal.MailingState = 'Delhi';
        ocontactNonLocal.MailingCountry = 'India';
        ocontactNonLocal.Fax = '1234567890';
        ocontactNonLocal.Address_Verified__c = false;
        insert ocontactNonLocal;
        
        Opportunity opptyNonLocal = new Opportunity(Name = 'testOpp', EventEdition__c = ee.Id);
        opptyNonLocal.AccountId = acctNonLocal.Id;
        opptyNonLocal.StageName = 'Discover';
        opptyNonLocal.CloseDate = date.today();
        opptyNonLocal.Not_a_Brazilian_Company__c = true;
        opptyNonLocal.Event_Series__c = es.Id;
        opptyNonLocal.Is_Barter_Opportunity__c = true;
        opptyNonLocal.isThroughDcousign__c = true;
        insert opptyNonLocal;
        
        SBQQ__Quote__c qtObjNonLocal = new SBQQ__Quote__c();
        qtObjNonLocal.SBQQ__Account__c = acctNonLocal.Id;
        qtObjNonLocal.SBQQ__Status__c = 'Draft';
        qtObjNonLocal.SBQQ__Type__c = 'Amendment';
        qtObjNonLocal.SBQQ__StartDate__c = date.today();
        qtObjNonLocal.Alternate_Currency2__c = 'EUR';
        qtObjNonLocal.SBQQ__Opportunity2__c = opptyNonLocal.Id;
        qtObjNonLocal.Billing_Contact__c = ocontactNonLocal.Id;
        qtObjNonLocal.Quote_Line_Deliverables__c = 'testing';
        qtObjNonLocal.SBQQ__Primary__c = true;
        qtObjNonLocal.Quote_Event_Edition__c = ee.Name;
        insert qtObjNonLocal;
        system.AssertEquals('TestEvents' , ee.Name, 'Error ::: Event not created');
    }
    
    static testmethod void testMethodsWithoutCondition() {
        Setup();
        SBQQ__Quote__c quoteObj = [select id, SBQQ__Account__c from SBQQ__Quote__c  limit 1];
        // Data Setup.
        PageReference pageRef = Page.vf_quoteLineAttachmentsConga;
        pageRef.getParameters().put('quoteId', quoteObj.Id);
        pageRef.getParameters().put('SessionId', 'sesssionId');
        pageRef.getParameters().put('ServerUrl', 'ServerUrl');
        Test.setCurrentPage(pageRef);
        
        
        Account ac = [Select Id, Accounting_Credit_Hold__c from Account WHERE ID =: quoteObj.SBQQ__Account__c LIMIT 1];
        ac.Accounting_Credit_Hold__c = 'Hold';
        //Update ac;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(quoteObj);
        Cls_quoteLineAttachmentsConga ref = new Cls_quoteLineAttachmentsConga(sc);
        ref.accountId = quoteObj.SBQQ__Account__c;
        ref.template = 'Quote';
        ref.autorun();
        ref.addressOnTemplate();
        ref.cancel();
        ref.showQuoteAttachment();
        ref.continueCmd();
        ref.template = 'Contract';
        ref.continueCmd();
        Event_Edition__c ee = [Select Id, Name from Event_Edition__c limit 1];
        system.AssertEquals('TestEvent' , ee.Name, 'Error ::: Event not created');
    }
    
    static testmethod void testMethodsWithCondition4() {
        Pricebook2 pb = new Pricebook2(Name = 'TestPricebook');
        insert pb;
        
        Application_Bypass__c appBypass = new Application_Bypass__c();
        appBypass.Docusign_Counter_Sign__c = true;
        insert appBypass;
        
        Event_Series__c es = new Event_Series__c(Name = 'Test');
        es.Local_Country__c = 'Australia';
        es.Company_Country__c = 'Australia';
        es.Not_By_pass_Local_Template__c = true;
        insert es;
        
        
        Event_Edition__c ee = new Event_Edition__c();
        ee.Name = 'TestEvent';
        ee.Tab1__c = 'tab1';
        ee.Tab4__c = 'tab4';
        ee.Tab7__c = 'tab7';
        ee.Tab8__c = 'Tab8__c';
        ee.Part_of_Series__c = es.Id;
        ee.Show_Deliverables__c = true;
        ee.Payment_Schedule__c = '25-25-25-25';
        ee.X50_Cutoff_Date__c = date.today();
        ee.Cutoff_Date_1__c = date.today().addDays(1);
        ee.Cutoff_Date_2__c = date.today().addDays(2);
        ee.Cutoff_Date_3__c = date.today().addDays(3);
        ee.Event_Price_Book__c = pb.Id;
        ee.End_Date__c= date.today();
        ee.Event_Code__c ='BRA20FRM';
        ee.Allow_Docusign_Counter_Sign__c = true;
        insert ee;
        ee.Enable_Additional_Documents_in_Docusign__c = true;
        update ee;
        APXTConga4__Conga_Template__c ct = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'test');
        insert ct;
        APXTConga4__Conga_Template__c ctDeli = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Deliverables');
        insert ctDeli;
        APXTConga4__Conga_Template__c ctDetails = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'BRAZIL National Contract');
        insert ctDetails;
        APXTConga4__Conga_Template__c ctDetails02 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Non_Brazil_international_Barter_Contract');
        insert ctDetails02;
        APXTConga4__Conga_Template__c ctDetails03 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Brazil National FOC Contract');
        insert ctDetails03;
        
        
        National_Contract_Template__c nct = new National_Contract_Template__c();
        nct.Event_Edition__c = ee.Id;
        nct.Conga_Template__c = ct.Id;
        nct.Term_Conditions__c = ct.Id;
        insert nct;
        
        National_Contract_Template__c nationalTemp = new National_Contract_Template__c();
        nationalTemp.Event_Edition__c = ee.Id;
        nationalTemp.Conga_Template__c = ct.Id;
        nationalTemp.Term_Conditions__c = ct.Id;
        nationalTemp.Type__c = 'Quote Template';
        insert nationalTemp;
        
        National_Contract_Template__c nationalTemp1 = new National_Contract_Template__c();
        nationalTemp1.Event_Edition__c = ee.Id;
        nationalTemp1.Conga_Template__c = ctDetails.id;
        nationalTemp1.Term_Conditions__c = ct.Id;
        nationalTemp1.Type__c = 'Contract Template';
        insert nationalTemp1;
        
        
        Account acct = new Account(Name = 'testAccount', CurrencyIsoCode = 'EUR', BillingCountry = 'Brasil');
        insert acct;
        
        Contact ocontact = new Contact();
        ocontact.Email = 'test.test@gmail.com';
        ocontact.Phone = '1234567890';
        ocontact.FirstName = 'TestFN';
        ocontact.LastName = 'testLN';
        ocontact.AccountId = acct.Id;
        ocontact.MailingStreet = 'TestStreet';
        ocontact.MailingCity = 'Delhi';
        ocontact.MailingPostalCode = '110025';
        ocontact.MailingState = 'Delhi';
        ocontact.MailingCountry = 'India';
        ocontact.Fax = '1234567890';
        ocontact.Address_Verified__c = false;
        insert ocontact;
        
        Opportunity oppty = new Opportunity(Name = 'testOpp', EventEdition__c = ee.Id);
        oppty.AccountId = acct.Id;
        oppty.StageName = 'Discover';
        oppty.CloseDate = date.today();
        //oppty.Witness_Contact__c=ocontact.id;
        oppty.Legal_Representative_1__c=ocontact.id;
        oppty.Not_a_Brazilian_Company__c = true;
        oppty.Event_Series__c = es.Id;
        oppty.isThroughDcousign__c = true;
        oppty.Is_Barter_Opportunity__c = true;
        insert oppty;
        
        
        SBQQ__Quote__c qtObj = new SBQQ__Quote__c();
        qtObj.SBQQ__Account__c = acct.Id;
        qtObj.SBQQ__Status__c = 'Draft';
        qtObj.SBQQ__Type__c = 'Quote';
        qtObj.SBQQ__StartDate__c = date.today();
        qtObj.Alternate_Currency2__c = 'EUR';
        qtObj.SBQQ__Opportunity2__c = oppty.Id;
        qtObj.Billing_Contact__c = ocontact.Id;
        qtObj.Quote_Line_Deliverables__c = 'testing';
        qtObj.SBQQ__Primary__c = true;
        qtObj.Quote_Event_Edition__c = ee.Name;
        
        insert qtObj;
        system.AssertEquals('TestEvent' , ee.Name, 'Error ::: Event not created');
        APXTConga4__Conga_Template__c ctDeli1 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Brazil International Barter Contract');
        insert ctDeli1;
        APXTConga4__Conga_Template__c ctDetails2 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Brazil National Barter Contract');
        insert ctDetails2;
        SBQQ__Quote__c quoteObj = [select id, SBQQ__Account__c from SBQQ__Quote__c  limit 1];
        contact cons = [select id , name from contact limit 1];
        // Data Setup.
        PageReference pageRef = Page.vf_quoteLineAttachmentsConga;
        pageRef.getParameters().put('quoteId', quoteObj.Id);
        pageRef.getParameters().put('SessionId', 'sesssionId');
        pageRef.getParameters().put('ServerUrl', 'ServerUrl');
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(quoteObj);
        Cls_quoteLineAttachmentsConga ref = new Cls_quoteLineAttachmentsConga(sc);
        
        Delete [Select Id from National_Contract_Template__c];
        ref.template = 'Contract';
        ref.continueCmd();
        List<National_Contract_Template__c> testList = new List<National_Contract_Template__c>();
        testList = [Select Id from National_Contract_Template__c];
        system.AssertEquals(true , testList.isEmpty(), 'EmptyList');  
        Event_Edition__c evntEc = [select id , name from Event_Edition__c limit 1];
        evntEc.Allow_Docusign_Counter_Sign__c = false;
        update evntEc;
        
    } 
    
    static testmethod void testAllMethodsWithoutCondition() {
        setUp();
        APXTConga4__Conga_Template__c ctDeli1 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Brazil International Barter Contract');
        insert ctDeli1;
        APXTConga4__Conga_Template__c ctDetails2 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Brazil National Barter Contract');
        insert ctDetails2;
        SBQQ__Quote__c quoteObj = [select id, SBQQ__Account__c from SBQQ__Quote__c  limit 1];
        
        //Set Page parameters.
        PageReference pageRef = Page.CongaPreviewPage;
        pageRef.getParameters().put('quoteId', quoteObj.Id + '~sD~template^Contract~productAttachments^test~serverUrl^sUrl~companyCountry^cc~TemplateId^test');
        Test.setCurrentPage(pageRef);
        
        Folder folder = [select id from Folder where name = 'Conga Preview Documents' LIMIT 1];
        Document docObj = new Document();
        docObj.Name = 'test';
        docObj.FolderId = folder.id;
        insert docObj;
        
        CongaPreviewController demo = new CongaPreviewController();
        demo.docPath = docObj.id;
        //Rajesh kumar yadav BK-5865
        demo.showDoc();
        demo.sendMail();
        demo.homePage();
        demo.returnOppPage();
        system.AssertEquals('sD' , demo.pageName, 'Error ::: Event not created');
    }
    
    static testmethod void testAllMethodsWithCondition1() {
        setUp();
        SBQQ__Quote__c quoteObj = [select id, SBQQ__Account__c from SBQQ__Quote__c  limit 1];
        
        //Set Page parameters.
        PageReference pageRef = Page.CongaPreviewPage;
        pageRef.getParameters().put('quoteId', quoteObj.Id + '~ManualContract~template^Quote~productAttachments^test~serverUrl^sUrl~companyCountry^cc~TemplateId^test');
        Test.setCurrentPage(pageRef);
        CongaPreviewController demo = new CongaPreviewController();
        //Rajesh kumar yadav BK-5865
        demo.showDoc();
        demo.sendDocusign();
        demo.sendMail();
        demo.homePage();
        demo.returnOppPage();
        system.AssertEquals(quoteObj.Id , demo.quoteId, 'Quote not found');
    }
    
    static testmethod void testAllMethodsWithCondition2() {
        setUp();
        SBQQ__Quote__c quoteObj = [select id, SBQQ__Account__c from SBQQ__Quote__c  limit 1];
        
        //Set Page parameters.
        PageReference pageRef = Page.CongaPreviewPage;
        pageRef.getParameters().put('quoteId', quoteObj.Id + '~sD~template^Quote~productAttachments^test~serverUrl^sUrl~companyCountry^cc~TemplateId^test');
        Test.setCurrentPage(pageRef);
        
        Folder folder = [select id from Folder where name = 'Conga Preview Documents' LIMIT 1];
        Document docObj = new Document();
        docObj.Name = 'test';
        docObj.FolderId = folder.id;
        insert docObj;
        
        CongaPreviewController demo = new CongaPreviewController();
        demo.docPath = docObj.id;
        demo.showDoc();
        //Rajesh kumar yadav BK-5865
        demo.sendDocusign();
        demo.sendMail();
        demo.homePage();
        demo.returnOppPage();
        system.AssertEquals('test' , demo.pDAs, 'Pdas Match');
    }
    
    static testmethod void testAllMethodsWithCondition3() {
        setUp();
        SBQQ__Quote__c quoteObj = [select id, SBQQ__Account__c from SBQQ__Quote__c  limit 1];
        
        //Set Page parameters.
        PageReference pageRef = Page.CongaPreviewPage;
        pageRef.getParameters().put('quoteId', quoteObj.Id + '~sD~template^Contract~productAttachments^test~serverUrl^sUrl~companyCountry^cc~TemplateId^test');
        Test.setCurrentPage(pageRef);
        CongaPreviewController demo = new CongaPreviewController();
        Test.startTest();
        demo.sendDocusign();
        Test.stopTest();
        system.AssertEquals('Contract' , demo.template, 'template Match');
    }
    
    //Rajesh kumar yadav BK-5865
    static testmethod void testAllmethoddata(){
        
        Event_Series__c es = new Event_Series__c(Name = 'Tests');
        es.Local_Country__c = 'India';
        es.Company_Country__c = 'India';
        es.Not_By_pass_Local_Template__c = true;
        insert es;
        
        Event_Edition__c ee = new Event_Edition__c();
        ee.Name = 'TestEvents';
        ee.Tab1__c = 'tab1';
        ee.Tab4__c = 'tab4';
        ee.Tab7__c = 'tab7';
        ee.Tab8__c = 'Tab8__c';
        ee.Part_of_Series__c = es.Id;
        ee.Show_Deliverables__c = true;
        ee.Payment_Schedule__c = '25-25-25-25';
        ee.End_Date__c= date.today();
        ee.Event_Code__c ='BRA20FRM';
        ee.X50_Cutoff_Date__c = date.today();
        ee.Cutoff_Date_1__c = date.today().addDays(1);
        ee.Cutoff_Date_2__c = date.today().addDays(2);
        ee.Cutoff_Date_3__c = date.today().addDays(3);
        ee.Allow_Docusign_Counter_Sign__c = true;
        insert ee;
        APXTConga4__Conga_Template__c ct = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'test');
        insert ct;
        APXTConga4__Conga_Template__c ctDetails02 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Brazil International Barter Contract');
        insert ctDetails02;
        
        National_Contract_Template__c nationalTemp3 = new National_Contract_Template__c();
        nationalTemp3.Event_Edition__c = ee.Id;
        nationalTemp3.Conga_Template__c = ctDetails02.id;
        nationalTemp3.Term_Conditions__c = ct.Id;
        nationalTemp3.Type__c = 'Contract Template';
        insert nationalTemp3;
        
        Account acct = new Account(Name = 'testAccount', CurrencyIsoCode = 'EUR', BillingCountry = 'India');
        insert acct;
        
        Contact ocontact = new Contact();
        ocontact.Email = 'test.test@gmail.com';
        ocontact.Phone = '1234567890';
        ocontact.FirstName = 'TestFN';
        ocontact.LastName = 'testLN';
        ocontact.AccountId = acct.Id;
        ocontact.MailingStreet = 'TestStreet';
        ocontact.MailingCity = 'Delhi';
        ocontact.MailingPostalCode = '110025';
        ocontact.MailingState = 'Delhi';
        ocontact.MailingCountry = 'India';
        ocontact.Fax = '1234567890';
        ocontact.Address_Verified__c = false;
        insert ocontact;
        
        Opportunity oppty = new Opportunity(Name = 'testOpp', EventEdition__c = ee.Id);
        oppty.AccountId = acct.Id;
        oppty.StageName = 'Discover';
        oppty.CloseDate = date.today();
        oppty.Not_a_Brazilian_Company__c = true;
        oppty.Event_Series__c = es.Id;
        oppty.Is_Barter_Opportunity__c = true;
        oppty.isThroughDcousign__c = true;
        insert oppty;
        
        SBQQ__Quote__c qtObj = new SBQQ__Quote__c();
        qtObj.SBQQ__Account__c = acct.Id;
        qtObj.SBQQ__Status__c = 'Draft';
        qtObj.SBQQ__Type__c = 'Quote';
        qtObj.SBQQ__StartDate__c = date.today();
        qtObj.Alternate_Currency2__c = 'EUR';
        qtObj.SBQQ__Opportunity2__c = oppty.Id;
        qtObj.Billing_Contact__c = ocontact.Id;
        qtObj.Quote_Line_Deliverables__c = 'testing';
        qtObj.SBQQ__Primary__c = true;
        qtObj.Quote_Event_Edition__c = ee.Name;
        insert qtObj;
        system.AssertEquals('TestEvents' , ee.Name, 'Error ::: Event not created');
    }
    
    static testmethod void testAllMethodsWithCondition5() {
        setUp2();
        SBQQ__Quote__c quoteObj = [select id, SBQQ__Account__c from SBQQ__Quote__c  limit 1];
        
        Contact contact = [Select Id, Name from Contact limit 1];
        //Set Page parameters.
        PageReference pageRef = Page.CongaPreviewPage;
        pageRef.getParameters().put('quoteId', quoteObj.Id + '~sD~template^Contract~productAttachments^test~serverUrl^sUrl~companyCountry^cc~TemplateId^test');
        Test.setCurrentPage(pageRef);
        CongaPreviewController demo = new CongaPreviewController();
        Test.startTest();
        demo.sendDocusign();
        Test.stopTest();
        
        system.AssertEquals('Contract' , demo.template, 'template Match');
    }
    
    static testmethod void testAllMethodsWithCondition6() {
        setUp2();
        SBQQ__Quote__c quoteObj = [select id, SBQQ__Account__c from SBQQ__Quote__c  limit 1];
        
        //Set Page parameters.
        PageReference pageRef = Page.CongaPreviewPage;
        pageRef.getParameters().put('quoteId', quoteObj.Id + '~sD~template^Contract~productAttachments^test~serverUrl^sUrl~companyCountry^cc~TemplateId^test');
        Test.setCurrentPage(pageRef);
        CongaPreviewController demo = new CongaPreviewController();
        
        User u;
        System.debug('Doing test run for User');
        try{
            u = [Select Id, Alias, Email, EmailEncodingKey, LastName, LanguageLocaleKey, LocaleSidKey, TimeZoneSidKey, userName From User where Profile.Name = 'Sales-Brasil' and IsActive = true LIMIT 1];
            System.debug('User Found >>>>'+u);
        }catch(exception e){
            Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales-Brasil' LIMIT 1];
            u = new User(Alias = 'standt', Email='standarduser811@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName='testingUser811@test.com'+string.valueof(system.now()));
            System.debug('User Not Found >>>>'+u);
        }
        System.debug('Doing test run for User = '+u.userName);       
        System.runAs(u) {
            Test.startTest();
            demo.sendDocusign();
            Test.stopTest();
        }
        system.AssertEquals('Contract' , demo.template, 'template Match');
        
    }
    
    static testmethod void testAllMethodsWithCondition7() {
        setUp2();
        
        SBQQ__Quote__c quoteObj = [select id, SBQQ__Account__c from SBQQ__Quote__c  limit 1];
        quoteObj.Contract_Type__c ='Digital';
        update quoteObj;
        Opportunity opp = [Select Id, Name from Opportunity];
        opp.Is_Barter_Opportunity__c = false;
        update opp;
        
        Contact contact = [Select Id, Name from Contact limit 1];
        //Set Page parameters.
        PageReference pageRef = Page.CongaPreviewPage;
        pageRef.getParameters().put('quoteId', quoteObj.Id + '~sD~template^Contract~productAttachments^test~serverUrl^sUrl~companyCountry^cc~TemplateId^test');
        Test.setCurrentPage(pageRef);
        CongaPreviewController demo = new CongaPreviewController();
        
        Test.startTest();
        demo.sendDocusign();
        Test.stopTest();
        
        system.AssertEquals('Contract' , demo.template, 'template Match');
        
        Boolean isStringNull = demo.isEmptyOrNull('Test');
        system.AssertEquals(false,isStringNull,'isStringNull ::: method not working properly.');

    }
    
    static testmethod void testAllMethodsWithCondition8() {
        setUp2();
        Event_Series__c es = [Select id, Name from Event_Series__c];
        es.Local_Country__c = 'India';
        es.Company_Country__c = 'India';
        es.Not_By_pass_Local_Template__c = true;
        update es;
        
        SBQQ__Quote__c quoteObj = [select id, SBQQ__Account__c from SBQQ__Quote__c  limit 1];
        
        Contact contact = [Select Id, Name from Contact limit 1];
        //Set Page parameters.
        PageReference pageRef = Page.CongaPreviewPage;
        pageRef.getParameters().put('quoteId', quoteObj.Id + '~sD~template^Contract~productAttachments^test~serverUrl^sUrl~companyCountry^cc~TemplateId^test');
        Test.setCurrentPage(pageRef);
        CongaPreviewController demo = new CongaPreviewController();
        
        Test.startTest();
        demo.sendDocusign();
        Test.stopTest();
        
        Opportunity opp = [Select Id, Name from Opportunity];
        opp.Is_Barter_Opportunity__c = false;
        update opp;
        demo.sendDocusign();       
        
        system.AssertEquals('Contract' , demo.template, 'template Match');
    }
    
    static testmethod void testAllMethodsWithCondition9() {
        setUp2();
        Event_Series__c es = [Select id, Name from Event_Series__c];
        es.Local_Country__c = 'India';
        es.Company_Country__c = 'India';
        es.Not_By_pass_Local_Template__c = true;
        update es;
        
        SBQQ__Quote__c quoteObj = [select id, SBQQ__Account__c from SBQQ__Quote__c  limit 1];
        quoteObj.Contract_Type__c ='Digital';
        update quoteObj;
        
        Opportunity opp = [Select Id, Name from Opportunity];
        opp.Is_Barter_Opportunity__c = false;
        update opp;  
        Contact contact = [Select Id, Name from Contact limit 1];
        //Set Page parameters.
        PageReference pageRef = Page.CongaPreviewPage;
        pageRef.getParameters().put('quoteId', quoteObj.Id + '~sD~template^Contract~productAttachments^test~serverUrl^sUrl~companyCountry^cc~TemplateId^test');
        Test.setCurrentPage(pageRef);
        CongaPreviewController demo = new CongaPreviewController();
        
        Test.startTest();
        demo.sendDocusign();
        Test.stopTest();
        
        system.AssertEquals('Contract' , demo.template, 'template Match');  
    }
    static testmethod void testAllMethodsWithCondition10() {
        setUp2();
        Opportunity opp = [Select Id, Name from Opportunity];
         
        Product2 prod = new Product2(Name = 'Laptop X200',Family = 'Event');
        insert prod;
        Product2 prod1 = new Product2(Name = 'Laptop X200',Family = 'Publishing');
        insert prod1;
        Product2 prod2 = new Product2(Name = 'Laptop X200',Family = 'Digital');
        insert prod2;
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id,UnitPrice = 10000, IsActive = true);
        INSERT standardPrice ;
        PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod1.Id,UnitPrice = 10000, IsActive = true);
        INSERT standardPrice1 ;
        PricebookEntry standardPrice2 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod2.Id,UnitPrice = 10000, IsActive = true);
        INSERT standardPrice2 ;
        OpportunityLineItem opppp=new OpportunityLineItem(Start_Date__c=system.today(),Is_FOC_Product2__c = true, Opportunity=opp,Quantity=1,Brand__c='Arab Health',UnitPrice=25.0,OpportunityId=opp.Id,PricebookEntryId=standardPrice.Id);
        insert opppp;
        OpportunityLineItem opppp1=new OpportunityLineItem(Start_Date__c=system.today(),Is_FOC_Product2__c = true,Opportunity=opp,Quantity=1,Brand__c='Arab Health',UnitPrice=25.0,OpportunityId=opp.Id,PricebookEntryId=standardPrice1.Id);
        insert opppp1;
        OpportunityLineItem opppp2=new OpportunityLineItem(Start_Date__c=system.today(),Is_FOC_Product2__c = true,Opportunity=opp,Quantity=1,Brand__c='Arab Health',UnitPrice=25.0,OpportunityId=opp.Id,PricebookEntryId=standardPrice2.Id);
        insert opppp2;
        
        opp.Is_Barter_Opportunity__c = false;
        update opp; 
        SBQQ__Quote__c quoteObj = [select id, SBQQ__Account__c from SBQQ__Quote__c  limit 1];
        APXTConga4__Conga_Template__c ct = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Brazil International FOC Contract');
        insert ct;

        //Set Page parameters.
        PageReference pageRef = Page.CongaPreviewPage;
        pageRef.getParameters().put('quoteId', quoteObj.Id + '~sD~template^Contract~productAttachments^test~serverUrl^sUrl~companyCountry^cc~TemplateId^test');
        Test.setCurrentPage(pageRef);
        CongaPreviewController demo = new CongaPreviewController();
        
        User u;
        System.debug('Doing test run for User');
        try{
            u = [Select Id, Alias, Email, EmailEncodingKey, LastName, LanguageLocaleKey, LocaleSidKey, TimeZoneSidKey, userName From User where Profile.Name = 'Sales-Brasil' and IsActive = true LIMIT 1];
            System.debug('User Found >>>>'+u);
        }catch(exception e){
            Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales-Brasil' LIMIT 1];
            u = new User(Alias = 'standt', Email='standarduser811@testorg.com',
                         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                         LocaleSidKey='en_US', ProfileId = p.Id,
                         TimeZoneSidKey='America/Los_Angeles',
                         UserName='testingUser811@test.com'+string.valueof(system.now()));
            System.debug('User Not Found >>>>'+u);
        }
        System.debug('Doing test run for User = '+u.userName);       
        System.runAs(u) {
            Test.startTest();
            demo.sendDocusign();
            Test.stopTest();
        }
        system.AssertEquals('Contract' , demo.template, 'template Match');
        
    }
    static testmethod void testmixedCondition() {
       // setUp2();
          Pricebook2 pb = new Pricebook2(Name = 'TestPricebook');
        insert pb;

        Event_Series__c es = new Event_Series__c(Name = 'Test');
        es.Local_Country__c = 'Brasil';
        es.Company_Country__c = 'Brasil';
        es.Not_By_pass_Local_Template__c = true;
        insert es;

        Product2 prodObj = new Product2(Name = 'testProd',Delegate_Product__c=true);
        insert prodObj;
          
          Product2 prodObj1 = new Product2(Name = 'testProd1');
        insert prodObj1;
       
        List < Country_locales__c > cl = new List < Country_locales__c > ();
        cl.add(new Country_locales__c(Name = 'Brasil', locale__c = 'pt-BR'));
        cl.add(new Country_locales__c(Name = 'USA', locale__c = 'en-US'));
        insert cl;

        List < Currency_Symbol__c > cs = new List < Currency_Symbol__c > ();
        cs.add(new Currency_Symbol__c(Name = 'BRL', symbol__c = '$'));
        cs.add(new Currency_Symbol__c(Name = 'USD', symbol__c = '$'));
        cs.add(new Currency_Symbol__c(Name = 'EUR', symbol__c = '$'));
        insert cs;

        Application_Bypass__c app = new Application_Bypass__c(SetupOwnerId = UserInfo.getOrganizationId(), Bypass_Validation_Rules__c = false);
        insert app;

        APXTConga4__Conga_Template__c ct = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Deliverables');
        insert ct;
          
        Event_Edition__c ee = new Event_Edition__c();
        ee.Name = 'TestEvent11';
        ee.Tab1__c = 'tab1';
        ee.Tab4__c = 'tab4';
        ee.Tab7__c = 'tab7';
        ee.Tab8__c = 'Tab8__c';
        ee.Part_of_Series__c = es.Id;
        ee.Show_Deliverables__c = true;
        ee.Payment_Schedule__c = '25-25-25-25';
        ee.X50_Cutoff_Date__c = date.today();
        ee.Cutoff_Date_1__c = date.today().addDays(1);
        ee.Cutoff_Date_2__c = date.today().addDays(2);
        ee.Cutoff_Date_3__c = date.today().addDays(3);
        ee.Event_Price_Book__c = pb.Id;
        ee.End_Date__c= date.today();
        ee.Event_Code__c ='BRA20FRM';
        ee.Mix_Supply_Terms_and_Condition__c=ct.Id;
        insert ee;
         Account acct = new Account(Name = 'testAccount', CurrencyIsoCode = 'EUR', BillingCountry = 'Brasil');
        insert acct;
        
        Contact con = new Contact();
        con.Email = 'test.test@gmail.com';
        con.Phone = '1234567890';
        con.FirstName = 'TestFNN';
        con.LastName = 'testLNN';
        con.AccountId = acct.Id;
        con.MailingStreet = 'TestStreet';
        con.MailingCity = 'Delhi';
        con.MailingPostalCode = '110025';
        con.MailingState = 'Delhi';
        con.MailingCountry = 'India';
        con.Fax = '1234567890';
        con.Address_Verified__c = true;
        insert con;
        
          Opportunity oppty = new Opportunity(Name = 'testOpp');
        oppty.AccountId = acct.Id;
        oppty.StageName = 'Customize';
        oppty.CloseDate = date.today();
        oppty.EventEdition__c = ee.Id;
        oppty.Event_Series__c = es.Id;        
        insert oppty;


        SBQQ__Quote__c qtObj = new SBQQ__Quote__c();
        qtObj.SBQQ__Account__c = acct.Id;
        qtObj.SBQQ__Status__c = 'Draft';
        qtObj.SBQQ__Type__c = 'Quote';
        qtObj.SBQQ__StartDate__c = date.today();
        qtObj.Alternate_Currency2__c = 'EUR';
        qtObj.SBQQ__Opportunity2__c = oppty.Id;
        qtObj.Billing_Contact__c = con.Id;
        qtObj.Quote_Line_Deliverables__c = 'testing';
        qtObj.SBQQ__Primary__c = true;
        qtObj.Manual__c = false;
         
        insert qtObj;
       
       
        SBQQ__QuoteLine__c qlObj = new SBQQ__QuoteLine__c();
        qlObj.SBQQ__Quote__c = qtObj.Id;
        qlObj.SBQQ__Product__c = prodObj.Id;
        insert qlObj;
        
        SBQQ__QuoteLine__c qlObj1 = new SBQQ__QuoteLine__c();
        qlObj1.SBQQ__Quote__c = qtObj.Id;
        qlObj1.SBQQ__Product__c = prodObj1.Id;
        insert qlObj1;
        
        //Set Page parameters.
        PageReference pageRef = Page.CongaPreviewPage;
        pageRef.getParameters().put('quoteId', qtObj.Id + '~sD~template^Contract~productAttachments^test~serverUrl^sUrl~companyCountry^cc~TemplateId^test');
        Test.setCurrentPage(pageRef);
        CongaPreviewController demo = new CongaPreviewController();
        
        Test.startTest();
        //demo.sendDocusign();
        Test.stopTest();
        
        system.AssertEquals('Contract' , demo.template, 'template Match');  
    }
    
        static testmethod void nondelegateCondition() {
       // setUp2();
          Pricebook2 pb = new Pricebook2(Name = 'TestPricebook');
        insert pb;

        Event_Series__c es = new Event_Series__c(Name = 'Test');
        es.Local_Country__c = 'Brasil';
        es.Company_Country__c = 'Brasil';
        es.Not_By_pass_Local_Template__c = true;
        insert es;

        Product2 prodObj = new Product2(Name = 'testProd');
        insert prodObj;
          

       
        List < Country_locales__c > cl = new List < Country_locales__c > ();
        cl.add(new Country_locales__c(Name = 'Brasil', locale__c = 'pt-BR'));
        cl.add(new Country_locales__c(Name = 'USA', locale__c = 'en-US'));
        insert cl;

        List < Currency_Symbol__c > cs = new List < Currency_Symbol__c > ();
        cs.add(new Currency_Symbol__c(Name = 'BRL', symbol__c = '$'));
        cs.add(new Currency_Symbol__c(Name = 'USD', symbol__c = '$'));
        cs.add(new Currency_Symbol__c(Name = 'EUR', symbol__c = '$'));
        insert cs;

        Application_Bypass__c app = new Application_Bypass__c(SetupOwnerId = UserInfo.getOrganizationId(), Bypass_Validation_Rules__c = false);
        insert app;

        APXTConga4__Conga_Template__c ct = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Term&Condition',APXTConga4__Template_Group__c='Term&Condition');
        insert ct;
          
        Event_Edition__c ee = new Event_Edition__c();
        ee.Name = 'TestEvent11';
        ee.Tab1__c = 'tab1';
        ee.Tab4__c = 'tab4';
        ee.Tab7__c = 'tab7';
        ee.Tab8__c = 'Tab8__c';
        ee.Part_of_Series__c = es.Id;
        ee.Show_Deliverables__c = true;
        ee.Payment_Schedule__c = '25-25-25-25';
        ee.X50_Cutoff_Date__c = date.today();
        ee.Cutoff_Date_1__c = date.today().addDays(1);
        ee.Cutoff_Date_2__c = date.today().addDays(2);
        ee.Cutoff_Date_3__c = date.today().addDays(3);
        ee.Event_Price_Book__c = pb.Id;
        ee.End_Date__c= date.today();
        ee.Event_Code__c ='BRA20FRM';
        ee.Terms_Condition_Template__c=ct.Id;
        insert ee;
         Account acct = new Account(Name = 'testAccount', CurrencyIsoCode = 'EUR', BillingCountry = 'Brasil');
        insert acct;
        
        Contact con = new Contact();
        con.Email = 'test.test@gmail.com';
        con.Phone = '1234567890';
        con.FirstName = 'TestFNN';
        con.LastName = 'testLNN';
        con.AccountId = acct.Id;
        con.MailingStreet = 'TestStreet';
        con.MailingCity = 'Delhi';
        con.MailingPostalCode = '110025';
        con.MailingState = 'Delhi';
        con.MailingCountry = 'India';
        con.Fax = '1234567890';
        con.Address_Verified__c = true;
        insert con;
        Test.startTest(); 
          Opportunity oppty = new Opportunity(Name = 'testOpp');
        oppty.AccountId = acct.Id;
        oppty.StageName = 'Customize';
        oppty.CloseDate = date.today();
        oppty.EventEdition__c = ee.Id;
        oppty.Event_Series__c = es.Id;        
        insert oppty;


        SBQQ__Quote__c qtObj = new SBQQ__Quote__c();
        qtObj.SBQQ__Account__c = acct.Id;
        qtObj.SBQQ__Status__c = 'Draft';
        qtObj.SBQQ__Type__c = 'Quote';
        qtObj.SBQQ__StartDate__c = date.today();
        qtObj.Alternate_Currency2__c = 'EUR';
        qtObj.SBQQ__Opportunity2__c = oppty.Id;
        qtObj.Billing_Contact__c = con.Id;
        qtObj.Quote_Line_Deliverables__c = 'testing';
        qtObj.SBQQ__Primary__c = true;
        qtObj.Manual__c = false;
         
        insert qtObj;
       
       
        SBQQ__QuoteLine__c qlObj = new SBQQ__QuoteLine__c();
        qlObj.SBQQ__Quote__c = qtObj.Id;
        qlObj.SBQQ__Product__c = prodObj.Id;
        insert qlObj;
        
     
        
        //Set Page parameters.
        PageReference pageRef = Page.CongaPreviewPage;
        pageRef.getParameters().put('quoteId', qtObj.Id + '~sD~template^Contract~productAttachments^test~serverUrl^sUrl~companyCountry^cc~TemplateId^test');
        Test.setCurrentPage(pageRef);
        CongaPreviewController demo = new CongaPreviewController();
        
       
        //demo.sendDocusign();
        Test.stopTest();
        
        system.AssertEquals('Contract' , demo.template, 'template Match');  
    }

         static testmethod void onlineOppCondition() {
      // setUp2();
          Pricebook2 pb = new Pricebook2(Name = 'TestPricebook');
        insert pb;

        Event_Series__c es = new Event_Series__c(Name = 'Test');
        es.Local_Country__c = 'Brasil';
        es.Company_Country__c = 'Brasil';
        es.Not_By_pass_Local_Template__c = true;
        insert es;

        Product2 prodObj = new Product2(Name = 'testProd');
        insert prodObj;
          

       
        List < Country_locales__c > cl = new List < Country_locales__c > ();
        cl.add(new Country_locales__c(Name = 'Brasil', locale__c = 'pt-BR'));
        cl.add(new Country_locales__c(Name = 'USA', locale__c = 'en-US'));
        insert cl;

        List < Currency_Symbol__c > cs = new List < Currency_Symbol__c > ();
        cs.add(new Currency_Symbol__c(Name = 'BRL', symbol__c = '$'));
        cs.add(new Currency_Symbol__c(Name = 'USD', symbol__c = '$'));
        cs.add(new Currency_Symbol__c(Name = 'EUR', symbol__c = '$'));
        insert cs;

        Application_Bypass__c app = new Application_Bypass__c(SetupOwnerId = UserInfo.getOrganizationId(),Docusign_Counter_Sign__c=false,Bypass_Validation_Rules__c = false);
        insert app;

        APXTConga4__Conga_Template__c ct = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Term&Condition',APXTConga4__Template_Group__c='Term&Condition');
        insert ct;
        
        
        APXTConga4__Conga_Template__c ct1 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Deliverables');
        insert ct1;
        
            
        Event_Edition__c ee1 = new Event_Edition__c();
        ee1.Name = 'TestEvent12';
        ee1.Tab1__c = 'tab1';
        ee1.Tab4__c = 'tab4';
        ee1.Tab7__c = 'tab7';
        ee1.Tab8__c = 'Tab8__c';
        ee1.Part_of_Series__c = es.Id;
        ee1.Show_Deliverables__c = true;
        ee1.Payment_Schedule__c = '25-25-25-25';
        ee1.X50_Cutoff_Date__c = date.today();
        ee1.Cutoff_Date_1__c = date.today().addDays(1);
        ee1.Cutoff_Date_2__c = date.today().addDays(2);
        ee1.Cutoff_Date_3__c = date.today().addDays(3);
        ee1.Event_Price_Book__c = pb.Id;
        ee1.End_Date__c= date.today();
        ee1.Event_Code__c ='BRA20FRM11';
        ee1.Terms_Condition_Template__c=ct.Id;
        ee1.Event_Edition_Code__c='event';

        insert ee1;
        
          
        Event_Edition__c ee = new Event_Edition__c();
        ee.Name = 'TestEvent11';
        ee.Tab1__c = 'tab1';
        ee.Tab4__c = 'tab4';
        ee.Tab7__c = 'tab7';
        ee.Tab8__c = 'Tab8__c';
        ee.Part_of_Series__c = es.Id;
        ee.Show_Deliverables__c = true;
        ee.Payment_Schedule__c = '25-25-25-25';
        ee.X50_Cutoff_Date__c = date.today();
        ee.Cutoff_Date_1__c = date.today().addDays(1);
        ee.Cutoff_Date_2__c = date.today().addDays(2);
        ee.Cutoff_Date_3__c = date.today().addDays(3);
        ee.Event_Price_Book__c = pb.Id;
        ee.End_Date__c= date.today();
        ee.Event_Code__c ='BRA20FRM';
        ee.Event_Edition_Code__c='test';
        ee.Alternative_Terms_Condition_Template__c=ct.Id;
        ee.Mapped_Online_Event__c=ee1.Id;
        insert ee;
         Account acct = new Account(Name = 'testAccount', CurrencyIsoCode = 'EUR', BillingCountry = 'Brasil');
        insert acct;
   
        National_Contract_Template__c nationalTemp1 = new National_Contract_Template__c();
        nationalTemp1.Event_Edition__c = ee.Id;
        nationalTemp1.Conga_Template__c = ct.Id;
        nationalTemp1.Term_Conditions__c = ct.Id;
        nationalTemp1.Type__c = 'Contract Template';
        insert nationalTemp1;
        Contact con = new Contact();
        con.Email = 'test.test@gmail.com';
        con.Phone = '1234567890';
        con.FirstName = 'TestFNN';
        con.LastName = 'testLNN';
        con.AccountId = acct.Id;
        con.MailingStreet = 'TestStreet';
        con.MailingCity = 'Delhi';
        con.MailingPostalCode = '110025';
        con.MailingState = 'Delhi';
        con.MailingCountry = 'India';
        con.Fax = '1234567890';
        con.Address_Verified__c = true;
        insert con;
             
         Test.startTest();     
        Opportunity oppty1 = new Opportunity(Name = 'onlinetestOpp');
        oppty1.AccountId = acct.Id;
        oppty1.StageName = 'Customize';
        oppty1.CloseDate = date.today();
        oppty1.EventEdition__c = ee1.Id;
        oppty1.Event_Series__c = es.Id;        
        insert oppty1;
             
             SBQQ__Quote__c primaryObj = new SBQQ__Quote__c();
        primaryObj.SBQQ__Account__c = acct.Id;
        primaryObj.SBQQ__Status__c = 'Draft';
        primaryObj.SBQQ__Type__c = 'Quote';
        primaryObj.SBQQ__StartDate__c = date.today();
        primaryObj.Alternate_Currency2__c = 'EUR';
        primaryObj.SBQQ__Opportunity2__c = oppty1.Id;
        primaryObj.Billing_Contact__c = con.Id;
        primaryObj.Quote_Line_Deliverables__c = 'testing';
        primaryObj.SBQQ__Primary__c = true;
        primaryObj.Manual__c = false;
         
        insert primaryObj;
            
        oppty1.SBQQ__PrimaryQuote__c=primaryObj.Id;
        update oppty1;
             
        
          Opportunity oppty = new Opportunity(Name = 'testOpp');
        oppty.AccountId = acct.Id;
        oppty.Online_Opportunity__c=oppty1.Id;
        oppty.StageName = 'Customize';
        oppty.CloseDate = date.today();
        oppty.EventEdition__c = ee.Id;
        oppty.Event_Series__c = es.Id;        
        insert oppty;
             
        


        SBQQ__Quote__c qtObj = new SBQQ__Quote__c();
        qtObj.SBQQ__Account__c = acct.Id;
        qtObj.SBQQ__Status__c = 'Draft';
        qtObj.SBQQ__Type__c = 'Quote';
        qtObj.SBQQ__StartDate__c = date.today();
        qtObj.Alternate_Currency2__c = 'EUR';
        qtObj.SBQQ__Opportunity2__c = oppty.Id;
        qtObj.Billing_Contact__c = con.Id;
        qtObj.Quote_Line_Deliverables__c = 'testing';
        qtObj.SBQQ__Primary__c = true;
        qtObj.Manual__c = false;
         
        insert qtObj;
       
       
        SBQQ__QuoteLine__c qlObj = new SBQQ__QuoteLine__c();
        qlObj.SBQQ__Quote__c = qtObj.Id;
        qlObj.SBQQ__Product__c = prodObj.Id;
        insert qlObj;
        
     
        
        //Set Page parameters.
        PageReference pageRef = Page.CongaPreviewPage;
        pageRef.getParameters().put('quoteId', qtObj.Id + '~sD~template^Contract~productAttachments^test~serverUrl^sUrl~companyCountry^cc~TemplateId^test');
        Test.setCurrentPage(pageRef);
        CongaPreviewController demo = new CongaPreviewController();
        
       
        demo.sendDocusign();
        Test.stopTest();
        
        system.AssertEquals('Contract' , demo.template, 'template Match');  
    }

      
   
}