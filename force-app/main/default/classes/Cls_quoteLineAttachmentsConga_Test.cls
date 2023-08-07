/**
* File:        cls_quoteLineAttachmentsConga_Test.cls
* Project:     GAP
* Date:        2/20/2017 5:52 AM
* Created By:  Abdul Kadir
* *************************************************************************
* @description cls_quoteLineAttachmentsConga.cls
* Code Coverage : 86%
* *************************************************************************
* History:To avoid autorabbit violations.
* Modified By: Rajesh Kumar [GGCW-3081]
* Modified By : Avinash Shukla BK-2871/BK-2973/74
* Modified By : Rajesh kumar yadav BK-3326/3392
*/

@isTest
public class Cls_quoteLineAttachmentsConga_Test {
    @isTest static void setup() {
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

     APXTConga4__Conga_Template__c ct = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'test');
        insert ct;
        APXTConga4__Conga_Template__c ctDeli = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Deliverables');
        insert ctDeli;
        APXTConga4__Conga_Template__c ctDetails = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'BRAZIL National Contract');
        insert ctDetails;
        
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
        ee.DS_Terms_Condition_Template__c = ct.id;
        ee.Allow_Docusign_Counter_Sign__c = true;
        insert ee;

       

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
        ocontact.Contact_Type__c = 'Primary Contact';
        ocontact.RecordTypeId =Schema.SObjectType.contact.getRecordTypeInfosByName().get('Contact Account is unhold').getRecordTypeId();
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
        oppty.Is_Barter_Opportunity__c = false;
        oppty.Exhibitor_Paid_By__c = 'Delegate Sales';
        oppty.Type = 'New';
        insert oppty;


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
    
    
    static testmethod void testMethodsWithoutCondition() {
        Setup();
        APXTConga4__Conga_Template__c ctDetails = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'BRAZIL National Contract');
        insert ctDetails;
        
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
    
    static testmethod void testMethodsWithCondition1() {
        Setup();
        APXTConga4__Conga_Template__c ctDetailsInterNational = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'BRAZIL InterNational Contract');
        insert ctDetailsInterNational;
       
        SBQQ__Quote__c quoteObj = [select id, SBQQ__Account__c from SBQQ__Quote__c  limit 1];
        // Data Setup.
        PageReference pageRef = Page.vf_quoteLineAttachmentsConga;
        pageRef.getParameters().put('quoteId', quoteObj.Id);
        pageRef.getParameters().put('SessionId', 'sesssionId');
        pageRef.getParameters().put('ServerUrl', 'ServerUrl');
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(quoteObj);
        Cls_quoteLineAttachmentsConga ref = new Cls_quoteLineAttachmentsConga(sc);
        ref.addressOnTemplate();
        ref.showQuoteAttachment();
        ref.cancel();
        ref.autorun();
        ref.template = 'Contract';
        ref.continueCmd();
        Event_Series__c ee = [Select Id, Name from Event_Series__c Limit 1];
        system.AssertEquals('Test' , ee.Name, 'Error ::: Event not created');
        //system.AssertEquals(true , testLi.isEmpty(), 'EmptyList');
        
    }
    static testmethod void testMethodsWithCondition2() {
        Setup();
        APXTConga4__Conga_Template__c ctDeli1 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Brazil International Barter Contract');
        insert ctDeli1;
        
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
        ref.addressOnTemplate();
        ref.showQuoteAttachment();
        ref.cancel();
        ref.template = 'Contract';
        ref.continueCmd();
        List<National_Contract_Template__c> testList = new List<National_Contract_Template__c>();
        testList = [Select Id from National_Contract_Template__c];
        system.AssertEquals(true , testList.isEmpty(), 'EmptyList');  
        Event_Edition__c evntEc = [select id , name from Event_Edition__c limit 1];
        evntEc.Allow_Docusign_Counter_Sign__c = false;
        update evntEc;
       
     }
    
    static testmethod void testMethodsWithCondition3() {
        Setup();
        APXTConga4__Conga_Template__c ctDetails2 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Brazil National Barter Contract');
        insert ctDetails2;
        SBQQ__Quote__c quoteObj = [select id, SBQQ__Account__c from SBQQ__Quote__c  limit 1];
        // Data Setup.
        PageReference pageRef = Page.vf_quoteLineAttachmentsConga;
        pageRef.getParameters().put('quoteId', quoteObj.Id);
        pageRef.getParameters().put('SessionId', 'sesssionId');
        pageRef.getParameters().put('ServerUrl', 'ServerUrl');
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(quoteObj);
        Cls_quoteLineAttachmentsConga ref = new Cls_quoteLineAttachmentsConga(sc);
        
        Delete [Select Id from National_Contract_Template__c];
        Delete [Select Id from SBQQ__QuoteLine__c];
        Opportunity oppty = [Select Id, Billing_Contact__c from Opportunity Limit 1];
        oppty.Billing_Contact__c = NULL;
        Update oppty;
        quoteObj.Manual__c = true;
        quoteObj.Billing_Contact__c = NULL;
        Update quoteObj;
        
        
        ref.template = 'Quote';
        ref.continueCmd();
        ref.addressOnTemplate();
        ref.showQuoteAttachment();
        ref.cancel();
        system.AssertEquals(quoteObj.Id , ApexPages.currentPage().getParameters().get('quoteId'), 'quoteId Match');
        
    }
    
    static testmethod void testMethodsWithCondition4() {
        Pricebook2 pb = new Pricebook2(Name = 'TestPricebook');
        insert pb;
        Product2 prod = new Product2(Name = 'Laptop X200', 
                                     Family = 'Hardware',Is_FOC_Product__c = true);
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        PricebookEntry customPrice = new PricebookEntry(
            Pricebook2Id = customPB.Id, Product2Id = prod.Id,
            UnitPrice = 12000, IsActive = true);
        insert customPrice;
        

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

        APXTConga4__Conga_Template__c ct = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'test');
        insert ct;
        APXTConga4__Conga_Template__c ctDeli = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Deliverables');
        insert ctDeli;
        APXTConga4__Conga_Template__c ctDetails = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'BRAZIL National Contract');
        insert ctDetails;
        
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
         ocontact.Contact_Type__c = 'Primary Contact';
        ocontact.RecordTypeId =Schema.SObjectType.contact.getRecordTypeInfosByName().get('Contact Account is unhold').getRecordTypeId();
        insert ocontact;

        Opportunity oppty = new Opportunity(Name = 'testOpp', EventEdition__c = ee.Id);
        oppty.AccountId = acct.Id;
        oppty.StageName = 'Discover';
        oppty.PriceBook2 = customPB;
        oppty.CloseDate = date.today();
        //oppty.Witness_Contact__c=ocontact.id;
        oppty.Legal_Representative_1__c=ocontact.id;
        oppty.Not_a_Brazilian_Company__c = true;
        oppty.Event_Series__c = es.Id;
        oppty.isThroughDcousign__c = true;
        oppty.Is_Barter_Opportunity__c = true;
        oppty.Type = 'New';
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
        //qtObj.Contract_Type__c = 'Digital';
        insert qtObj;
        es.Local_Country__c = 'Brasil';
        es.Company_Country__c = 'Brasil';
        es.Not_By_pass_Local_Template__c = true;
        update es;
       
        
        system.AssertEquals('TestEvent' , ee.Name, 'Error ::: Event not created');
        
        APXTConga4__Conga_Template__c ctDetailsBNC = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'BRAZIL National Contract');
        insert ctDetailsBNC;
        
        APXTConga4__Conga_Template__c ctDetailsInterNational = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'BRAZIL InterNational Contract');
        insert ctDetailsInterNational;
        
        APXTConga4__Conga_Template__c ctDeli1 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Brazil International Barter Contract');
        insert ctDeli1;

        APXTConga4__Conga_Template__c ctDetails2 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Brazil National Barter Contract');
        insert ctDetails2;
        
        APXTConga4__Conga_Template__c ctDelifoc = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Brazil International FOC Contract');
        insert ctDelifoc;
        APXTConga4__Conga_Template__c ctDetailsfoc = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Brazil National FOC Contract');
        insert ctDetailsfoc;
        
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
        ref.addressOnTemplate();
        ref.showQuoteAttachment();
        ref.cancel();
        ref.template = 'Contract';
        ref.continueCmd();
        List<National_Contract_Template__c> testList = new List<National_Contract_Template__c>();
        testList = [Select Id from National_Contract_Template__c];
        system.AssertEquals(true , testList.isEmpty(), 'EmptyList');  
        Event_Edition__c evntEc = [select id , name from Event_Edition__c limit 1];
        evntEc.Allow_Docusign_Counter_Sign__c = false;
        update evntEc;
        
     }
    
    static testmethod void testMethodsWithCondition5(){
         Pricebook2 pb = new Pricebook2(Name = 'TestPricebook');
        insert pb;
        Product2 prod = new Product2(Name = 'Laptop X200', 
                                     Family = 'Hardware',Is_FOC_Product__c = true);
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        PricebookEntry customPrice = new PricebookEntry(
            Pricebook2Id = customPB.Id, Product2Id = prod.Id,
            UnitPrice = 12000, IsActive = true);
        insert customPrice;
        

        Application_Bypass__c appBypass = new Application_Bypass__c();
        appBypass.Docusign_Counter_Sign__c = true;
        insert appBypass;
        
        Account acct = new Account(Name = 'testAccount', CurrencyIsoCode = 'EUR', BillingCountry = 'Australia');
        insert acct;

        Event_Series__c es = new Event_Series__c(Name = 'Test');
        es.Local_Country__c = 'Australia';
        es.Company_Country__c = 'Australia';
        es.Not_By_pass_Local_Template__c = true;
        insert es;

    APXTConga4__Conga_Template__c ct = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'test');
        insert ct;
        APXTConga4__Conga_Template__c ctDeli = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Deliverables');
        insert ctDeli;
        APXTConga4__Conga_Template__c ctDetails = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Non_Brazil_international_Barter_Contract');
        insert ctDetails;
        
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
        //ee.End_Date__c= date.today();
        ee.Event_Code__c ='BRA20FRM';
        ee.Allow_Docusign_Counter_Sign__c = true;
       // ee.Alternative_Terms_Condition_Template__c = ct.Id;
        insert ee;

        
        
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
         ocontact.Contact_Type__c = 'Primary Contact';
        ocontact.RecordTypeId =Schema.SObjectType.contact.getRecordTypeInfosByName().get('Contact Account is unhold').getRecordTypeId();
        insert ocontact;

        Opportunity oppty = new Opportunity(Name = 'testOpp', EventEdition__c = ee.Id);
        oppty.AccountId = acct.Id;
        oppty.StageName = 'Discover';
        oppty.PriceBook2 = customPB;
        oppty.CloseDate = date.today();
        //oppty.Witness_Contact__c=ocontact.id;
        oppty.Legal_Representative_1__c=ocontact.id;
        oppty.Not_a_Brazilian_Company__c = true;
        oppty.Event_Series__c = es.Id;
        oppty.isThroughDcousign__c = true;
        oppty.Is_Barter_Opportunity__c = true;
        oppty.Type = 'New';
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
      //  qtObj.Contract_Type__c = 'Digital';
        insert qtObj;
        es.Local_Country__c = 'Brasil';
        es.Company_Country__c = 'Brasil';
        es.Not_By_pass_Local_Template__c = true;
        update es;
      
        
        system.AssertEquals('TestEvent' , ee.Name, 'Error ::: Event not created');
        
        APXTConga4__Conga_Template__c ctDetailsBNC = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'BRAZIL National Contract');
        insert ctDetailsBNC;
        
        APXTConga4__Conga_Template__c ctDetailsInterNational = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'BRAZIL InterNational Contract');
        insert ctDetailsInterNational;
        
        APXTConga4__Conga_Template__c ctDeli1 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Brazil International Barter Contract');
        insert ctDeli1;

        APXTConga4__Conga_Template__c ctDetails2 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Brazil National Barter Contract');
        insert ctDetails2;
        
        APXTConga4__Conga_Template__c ctDelifoc = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Brazil International FOC Contract');
        insert ctDelifoc;
        APXTConga4__Conga_Template__c ctDetailsfoc = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Brazil National FOC Contract');
        insert ctDetailsfoc;
        
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
        ref.addressOnTemplate();
        ref.showQuoteAttachment();
        ref.cancel();
        ref.template = 'Contract';
        ref.continueCmd();
        List<National_Contract_Template__c> testList = new List<National_Contract_Template__c>();
        testList = [Select Id from National_Contract_Template__c];
        system.AssertEquals(true , testList.isEmpty(), 'EmptyList');  
        Event_Edition__c evntEc = [select id , name from Event_Edition__c limit 1];
        evntEc.Allow_Docusign_Counter_Sign__c = false;
        update evntEc;
       
    }
     static testmethod void testMethodsWithCondition6(){
         Pricebook2 pb = new Pricebook2(Name = 'TestPricebook');
        insert pb;
        Product2 prod = new Product2(Name = 'Laptop X200', 
                                     Family = 'Hardware',Is_FOC_Product__c = true);
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        PricebookEntry customPrice = new PricebookEntry(
            Pricebook2Id = customPB.Id, Product2Id = prod.Id,
            UnitPrice = 12000, IsActive = true);
        insert customPrice;
        

        Application_Bypass__c appBypass = new Application_Bypass__c();
        appBypass.Docusign_Counter_Sign__c = true;
        insert appBypass;
        
        

        Event_Series__c es = new Event_Series__c(Name = 'Test');
        es.Local_Country__c = 'Australia';
        es.Company_Country__c = 'Australia';
        es.Not_By_pass_Local_Template__c = true;
        insert es;

    APXTConga4__Conga_Template__c ct = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'test');
        insert ct;
        APXTConga4__Conga_Template__c ctDeli = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Deliverables');
        insert ctDeli;
        APXTConga4__Conga_Template__c ctDetails = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'BRAZIL National Contract');
        insert ctDetails;
        
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
        //ee.End_Date__c= date.today();
        ee.Event_Code__c ='BRA20FRM';
        ee.Allow_Docusign_Counter_Sign__c = true;
       // ee.Alternative_Terms_Condition_Template__c = ct.Id;
        insert ee;
        
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
         Account acct = new Account(Name = 'testAccount', CurrencyIsoCode = 'EUR', BillingCountry = 'Australia');
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
         ocontact.Contact_Type__c = 'Primary Contact';
        ocontact.RecordTypeId =Schema.SObjectType.contact.getRecordTypeInfosByName().get('Contact Account is unhold').getRecordTypeId();
        insert ocontact;

        Opportunity oppty = new Opportunity(Name = 'testOpp', EventEdition__c = ee.Id);
        oppty.AccountId = acct.Id;
        oppty.StageName = 'Discover';
        oppty.PriceBook2 = customPB;
        oppty.CloseDate = date.today();
        //oppty.Witness_Contact__c=ocontact.id;
        oppty.Legal_Representative_1__c=ocontact.id;
        oppty.Not_a_Brazilian_Company__c = true;
        oppty.Event_Series__c = es.Id;
        oppty.isThroughDcousign__c = true;
       // oppty.Is_Barter_Opportunity__c = true;
        oppty.Type = 'New';
        insert oppty;

        
        APXTConga4__Conga_Template__c ctDetailsBNC = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'BRAZIL National Contract');
        insert ctDetailsBNC;
        
        APXTConga4__Conga_Template__c ctDetailsInterNational = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'BRAZIL InterNational Contract');
        insert ctDetailsInterNational;
        
        APXTConga4__Conga_Template__c ctDeli1 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Brazil International Barter Contract');
        insert ctDeli1;

        APXTConga4__Conga_Template__c ctDetails2 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Brazil National Barter Contract');
        insert ctDetails2;
        
        APXTConga4__Conga_Template__c ctDelifoc = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Brazil International FOC Contract');
        insert ctDelifoc;
        APXTConga4__Conga_Template__c ctDetailsfoc = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Brazil National FOC Contract');
        insert ctDetailsfoc;
    
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
         qtObj.conga_contract_template_id__c = ctDeli1.Id;
        //qtObj.Contract_Type__c = 'Digital';
        insert qtObj;
        es.Local_Country__c = 'Brasil';
       /// es.Company_Country__c = 'Brasil';
        es.Not_By_pass_Local_Template__c = true;
        update es;
       
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
         quoteLine.SBQQ__Product__c = Prod.Id ;
         quoteLine.SBQQ__Quote__c = qtObj.Id;
         insert quoteLine;
         
         
        system.AssertEquals('TestEvent' , ee.Name, 'Error ::: Event not created');
       
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
        ref.addressOnTemplate();
        ref.showQuoteAttachment();
        ref.cancel();
        ref.template = 'Contract';
         
        ref.continueCmd();

        List<National_Contract_Template__c> testList = new List<National_Contract_Template__c>();
        testList = [Select Id from National_Contract_Template__c];
        system.AssertEquals(true , testList.isEmpty(), 'EmptyList');  
        Event_Edition__c evntEc = [select id , name from Event_Edition__c limit 1];
        evntEc.Allow_Docusign_Counter_Sign__c = false;
        update evntEc;
       
    }
     static testmethod void testMethodsWithCondition7(){
         Pricebook2 pb = new Pricebook2(Name = 'TestPricebook');
        insert pb;
        Product2 prod = new Product2(Name = 'Laptop X200', 
                                     Family = 'Hardware',Is_FOC_Product__c = true);
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        PricebookEntry customPrice = new PricebookEntry(
            Pricebook2Id = customPB.Id, Product2Id = prod.Id,
            UnitPrice = 12000, IsActive = true);
        insert customPrice;
        

        Application_Bypass__c appBypass = new Application_Bypass__c();
        appBypass.Docusign_Counter_Sign__c = false;
        insert appBypass;
        
        

        Event_Series__c es = new Event_Series__c(Name = 'Test');
        es.Local_Country__c = 'Australia';
        es.Company_Country__c = 'Australia';
        es.Not_By_pass_Local_Template__c = false;
        insert es;

    APXTConga4__Conga_Template__c ct = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'test');
        insert ct;
        APXTConga4__Conga_Template__c ctDeli = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Deliverables');
        insert ctDeli;
        APXTConga4__Conga_Template__c ctDetails = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Brazil International FOC Contract');
        insert ctDetails;
        
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
        //ee.End_Date__c= date.today();
        ee.Event_Code__c ='BRA20FRM';
        ee.Allow_Docusign_Counter_Sign__c = true;
       // ee.Alternative_Terms_Condition_Template__c = ct.Id;
        insert ee;
        
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
         Account acct = new Account(Name = 'testAccount', CurrencyIsoCode = 'EUR', BillingCountry = 'Australia', BillingStreet = 'Test Billing"', BillingCity = 'Test City"');
        insert acct;
        Contact ocontact = new Contact();
        ocontact.Email = 'test.test@gmail.com';
        ocontact.Phone = '1234567890';
        ocontact.FirstName = 'TestFN"';
        ocontact.LastName = 'testLN"';
        ocontact.AccountId = acct.Id;
        ocontact.MailingStreet = 'TestStreet';
        ocontact.MailingCity = 'Delhi';
        ocontact.MailingPostalCode = '110025';
        ocontact.MailingState = 'Delhi';
        ocontact.MailingCountry = 'India';
        ocontact.Fax = '1234567890';
        ocontact.Address_Verified__c = false;
         ocontact.Contact_Type__c = 'Primary Contact';
        ocontact.RecordTypeId =Schema.SObjectType.contact.getRecordTypeInfosByName().get('Contact Account is unhold').getRecordTypeId();
        insert ocontact;

        Opportunity oppty = new Opportunity(Name = 'testOpp', EventEdition__c = ee.Id);
        oppty.AccountId = acct.Id;
        oppty.StageName = 'Discover';
        oppty.PriceBook2 = customPB;
        oppty.CloseDate = date.today();
        //oppty.Witness_Contact__c=ocontact.id;
        oppty.Legal_Representative_1__c=ocontact.id;
        oppty.Not_a_Brazilian_Company__c = true;
        oppty.Event_Series__c = es.Id;
        oppty.isThroughDcousign__c = true;
       // oppty.Is_Barter_Opportunity__c = true;
        oppty.Type = 'New';
        insert oppty;

        APXTConga4__Conga_Template__c ctDetailsfoc = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Brazil International FOC Contract');
         
        insert ctDetailsfoc;
    
        SBQQ__Quote__c qtObj = new SBQQ__Quote__c();
        qtObj.SBQQ__Account__c = acct.Id;
        //qtObj.SBQQ__Status__c = 'Draft';
        qtObj.SBQQ__Type__c = 'Amendment';
        qtObj.SBQQ__StartDate__c = date.today();
        qtObj.Alternate_Currency2__c = 'EUR';
        qtObj.SBQQ__Opportunity2__c = oppty.Id;	
        qtObj.Billing_Contact__c = ocontact.Id;
        qtObj.Quote_Line_Deliverables__c = 'testing';
        qtObj.SBQQ__Primary__c = true;
        qtObj.Quote_Event_Edition__c = ee.Name;
         qtObj.conga_contract_template_id__c = ctDetailsfoc.Id;
         qtObj.SBQQ__PrimaryContact__c = ocontact.Id;
        //qtObj.Contract_Type__c = 'Digital';
        insert qtObj;
        es.Local_Country__c = 'Brasil';
       // es.Company_Country__c = 'Brasil';
        es.Not_By_pass_Local_Template__c = true;
        update es;
       
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
         quoteLine.SBQQ__Product__c = Prod.Id ;
         quoteLine.SBQQ__Quote__c = qtObj.Id;
         insert quoteLine;
         
         
        system.AssertEquals('TestEvent' , ee.Name, 'Error ::: Event not created');
       
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
        ref.addressOnTemplate();
        ref.showQuoteAttachment();
        ref.cancel();
        ref.template = 'Contract';
         
        ref.continueCmd();

        List<National_Contract_Template__c> testList = new List<National_Contract_Template__c>();
        testList = [Select Id from National_Contract_Template__c];
        system.AssertEquals(true , testList.isEmpty(), 'EmptyList');  
        Event_Edition__c evntEc = [select id , name from Event_Edition__c limit 1];
        evntEc.Allow_Docusign_Counter_Sign__c = true;
        update evntEc;
       
    }
    
    static testmethod void testMethodsWithCondition8(){
         Pricebook2 pb = new Pricebook2(Name = 'TestPricebook');
        insert pb;
        
        Product2 prod = new Product2(Name = 'Laptop X200', Delegate_Product__c = true);
        insert prod;
        Product2 prod1 = new Product2(Name = 'Laptop1 X200');
        insert prod1;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        PricebookEntry customPrice = new PricebookEntry(
            Pricebook2Id = customPB.Id, Product2Id = prod.Id,
            UnitPrice = 12000, IsActive = true);
        insert customPrice;
        

        Application_Bypass__c appBypass = new Application_Bypass__c();
        appBypass.Docusign_Counter_Sign__c = false;
        insert appBypass;
        
        

        Event_Series__c es = new Event_Series__c(Name = 'Test');
        es.Local_Country__c = 'Australia';
        es.Company_Country__c = 'Australia';
        es.Not_By_pass_Local_Template__c = false;
        insert es;

    APXTConga4__Conga_Template__c ct = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'test');
        insert ct;
        APXTConga4__Conga_Template__c ctDeli = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Deliverables');
        insert ctDeli;
        APXTConga4__Conga_Template__c ctDetails = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Brazil International FOC Contract');
        insert ctDetails;
        
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
        //ee.End_Date__c= date.today();
        ee.Event_Code__c ='BRA20FRM';
        ee.Allow_Docusign_Counter_Sign__c = true;
       // ee.Alternative_Terms_Condition_Template__c = ct.Id;
        ee.Mix_Supply_Terms_and_Condition__c = ct.Id;
        insert ee;
        
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
        Account acct = new Account(Name = 'testAccount', CurrencyIsoCode = 'EUR', BillingCountry = 'Australia');
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
        ocontact.Contact_Type__c = 'Primary Contact';
        ocontact.RecordTypeId =Schema.SObjectType.contact.getRecordTypeInfosByName().get('Contact Account is unhold').getRecordTypeId();
        insert ocontact;

        Opportunity oppty = new Opportunity(Name = 'testOpp', EventEdition__c = ee.Id);
        oppty.AccountId = acct.Id;
        oppty.StageName = 'Discover';
        oppty.PriceBook2 = customPB;
        oppty.CloseDate = date.today();
        //oppty.Witness_Contact__c=ocontact.id;
        oppty.Legal_Representative_1__c=ocontact.id;
        oppty.Not_a_Brazilian_Company__c = true;
        oppty.Event_Series__c = es.Id;
        oppty.isThroughDcousign__c = true;
        oppty.EventEdition__c = ee.Id;
       // oppty.Is_Barter_Opportunity__c = true;
        oppty.Type = 'New';
        insert oppty;
        APXTConga4__Conga_Template__c ctDetailsfoc = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Brazil International FOC Contract');  
        insert ctDetailsfoc;
        Test.startTest();
    
        SBQQ__Quote__c qtObj = new SBQQ__Quote__c();
        qtObj.SBQQ__Account__c = acct.Id;
        //qtObj.SBQQ__Status__c = 'Draft';
        qtObj.SBQQ__Type__c = 'Amendment';
        qtObj.SBQQ__StartDate__c = date.today();
        qtObj.Alternate_Currency2__c = 'EUR';
        qtObj.SBQQ__Opportunity2__c = oppty.Id;	
        qtObj.Billing_Contact__c = ocontact.Id;
        qtObj.Quote_Line_Deliverables__c = 'testing';
        qtObj.SBQQ__Primary__c = true;
        qtObj.Quote_Event_Edition__c = ee.Name;
         qtObj.conga_contract_template_id__c = ctDetailsfoc.Id;
        qtObj.SBQQ__PrimaryContact__c = ocontact.Id;
        //qtObj.Contract_Type__c = 'Digital';
        insert qtObj;

        es.Local_Country__c = 'Brasil';
       // es.Company_Country__c = 'Brasil';
        es.Not_By_pass_Local_Template__c = true;
        update es;
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
         quoteLine.SBQQ__Product__c = Prod.Id ;
         quoteLine.SBQQ__Quote__c = qtObj.Id;
         quoteLineList.add(quoteLine);
         
         SBQQ__QuoteLine__c quoteLine1 = new SBQQ__QuoteLine__c();
         quoteLine1.SBQQ__Product__c = prod1.Id ;
         quoteLine1.SBQQ__Quote__c = qtObj.Id;
         quoteLineList.add(quoteLine1);
         insert quoteLineList;
        system.AssertEquals('TestEvent' , ee.Name, 'Error ::: Event not created');
        
        SBQQ__Quote__c quoteObj = [select id, SBQQ__Account__c from SBQQ__Quote__c  limit 1];
        contact cons = [select id , name from contact limit 1];
        
        // Data Setup.
        PageReference pageRef = Page.vf_quoteLineAttachmentsConga;
        pageRef.getParameters().put('quoteId', quoteObj.Id);
        pageRef.getParameters().put('SessionId', 'sesssionId');
        pageRef.getParameters().put('ServerUrl', 'ServerUrl');
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(quoteObj);
        Test.stopTest();
        Cls_quoteLineAttachmentsConga ref = new Cls_quoteLineAttachmentsConga(sc);

       ref.template = 'Quote';
    
        ref.accountId=acct.id;
        ref.isWarningMsg=false;
       
    } 
    
    static testmethod void testMethodsWithCondition9(){
         Pricebook2 pb = new Pricebook2(Name = 'TestPricebook');
        insert pb;
        
        Product2 prod = new Product2(Name = 'Laptop X200', Delegate_Product__c = true);
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        PricebookEntry customPrice = new PricebookEntry(
            Pricebook2Id = customPB.Id, Product2Id = prod.Id,
            UnitPrice = 12000, IsActive = true);
        insert customPrice;
        

        Application_Bypass__c appBypass = new Application_Bypass__c();
        appBypass.Docusign_Counter_Sign__c = false;
        insert appBypass;
        
        

        Event_Series__c es = new Event_Series__c(Name = 'Test');
        es.Local_Country__c = 'Australia';
        es.Company_Country__c = 'Australia';
        es.Not_By_pass_Local_Template__c = false;
        insert es;

    APXTConga4__Conga_Template__c ct = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'test');
        insert ct;
        APXTConga4__Conga_Template__c ctDeli = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Deliverables');
        insert ctDeli;
        APXTConga4__Conga_Template__c ctDetails = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Brazil International FOC Contract');
        insert ctDetails;
        
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
        //ee.End_Date__c= date.today();
        ee.Event_Code__c ='BRA20FRM';
        ee.Allow_Docusign_Counter_Sign__c = true;
       // ee.Alternative_Terms_Condition_Template__c = ct.Id;
        ee.DS_Terms_Condition_Template__c=ct.Id;
        insert ee;
        
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
         Account acct = new Account(Name = 'testAccount', CurrencyIsoCode = 'EUR', BillingCountry = 'Australia');
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
         ocontact.Contact_Type__c = 'Primary Contact';
        ocontact.RecordTypeId =Schema.SObjectType.contact.getRecordTypeInfosByName().get('Contact Account is unhold').getRecordTypeId();
        insert ocontact;

        Opportunity oppty = new Opportunity(Name = 'testOpp', EventEdition__c = ee.Id);
        oppty.AccountId = acct.Id;
        oppty.StageName = 'Discover';
        oppty.PriceBook2 = customPB;
        oppty.CloseDate = date.today();
        //oppty.Witness_Contact__c=ocontact.id;
        oppty.Legal_Representative_1__c=ocontact.id;
        oppty.Not_a_Brazilian_Company__c = true;
        oppty.Event_Series__c = es.Id;
        oppty.isThroughDcousign__c = true;
        oppty.EventEdition__c = ee.Id;
       // oppty.Is_Barter_Opportunity__c = true;
        oppty.Type = 'New';
        insert oppty;

        APXTConga4__Conga_Template__c ctDetailsfoc = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Brazil International FOC Contract');
         
        insert ctDetailsfoc;
    
        SBQQ__Quote__c qtObj = new SBQQ__Quote__c();
        qtObj.SBQQ__Account__c = acct.Id;
        //qtObj.SBQQ__Status__c = 'Draft';
        qtObj.SBQQ__Type__c = 'Amendment';
        qtObj.SBQQ__StartDate__c = date.today();
        qtObj.Alternate_Currency2__c = 'EUR';
        qtObj.SBQQ__Opportunity2__c = oppty.Id;	
        qtObj.Billing_Contact__c = ocontact.Id;
        qtObj.Quote_Line_Deliverables__c = 'testing';
        qtObj.SBQQ__Primary__c = true;
        qtObj.Quote_Event_Edition__c = ee.Name;
         qtObj.conga_contract_template_id__c = ctDetailsfoc.Id;
        qtObj.SBQQ__PrimaryContact__c = ocontact.Id;
        //qtObj.Contract_Type__c = 'Digital';
        insert qtObj;
        es.Local_Country__c = 'Brasil';
       // es.Company_Country__c = 'Brasil';
        es.Not_By_pass_Local_Template__c = true;
        update es;
       
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
         quoteLine.SBQQ__Product__c = Prod.Id ;
         quoteLine.SBQQ__Quote__c = qtObj.Id;
         insert quoteLine;
         
        system.AssertEquals('TestEvent' , ee.Name, 'Error ::: Event not created');
       
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

       ref.template = 'Quote';
    
        ref.accountId=acct.id;
        ref.isWarningMsg=false;
       
    }
  
}