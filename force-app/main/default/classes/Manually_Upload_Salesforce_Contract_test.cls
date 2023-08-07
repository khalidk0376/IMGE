/**
 * File:        Manually_Upload_Salesforce_Contract_test.cls
 * Project:     GAP
 * Date:        2/20/2017 5:52 AM
 * Created By: Rajesh Kumar
 * Modified By: Yash Gupta [20/12/2018]/BK-6667 rajesh kumar yadav
 * History: To avoid autorabbit violations.
 */

@isTest
public class Manually_Upload_Salesforce_Contract_test {
    static testMethod void initialValidations() {
        Pricebook2 pb = new Pricebook2(Name = 'TestPricebook');
        insert pb;

        Event_Series__c es = new Event_Series__c(Name = 'Test');
        es.Local_Country__c = 'Brasil';
        es.Company_Country__c = 'Brasil';
        es.Not_By_pass_Local_Template__c = true;
        insert es;

        Product2 prodObj = new Product2(Name = 'testProd');
        insert prodObj;

        Product2 prodObj1 = new Product2(Name = 'testProd',Delegate_Product__c=true);
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
        APXTConga4__Conga_Template__c congaTemp = new APXTConga4__Conga_Template__c();
        congaTemp.APXTConga4__Name__c = 'Test Template';
        congaTemp.APXTConga4__Template_Type__c = 'Document';
        congaTemp.APXTConga4__Template_Group__c = 'Term&Condition';
        insert congaTemp;
        
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
         ee.Terms_Condition_Template__c=congaTemp.id;
        ee.Alternative_Terms_Condition_Template__c=congaTemp.id; 
        insert ee;

        APXTConga4__Conga_Template__c ct = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Deliverables');
        insert ct;
        APXTConga4__Conga_Template__c ctDeli1 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Brazil International Barter Contract');
        insert ctDeli1;
        APXTConga4__Conga_Template__c ctDetails2 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Brazil National Barter Contract');
        insert ctDetails2;
        APXTConga4__Conga_Template__c ctDetails3 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Non_Brazil_international_Barter_Contract');
        insert ctDetails3;
        
        National_Contract_Template__c nct = new National_Contract_Template__c();
        nct.Event_Edition__c = ee.Id;
        nct.Conga_Template__c = ct.Id;
        nct.Term_Conditions__c = ct.Id;
        nct.Type__c = 'Quote Template';
        insert nct;


        Account acct = new Account(Name = 'testAccount', CurrencyIsoCode = 'EUR', BillingCountry = 'USA', BillingStreet = 'New York"', BillingCity = 'New York"');
        insert acct;
        System.assertEquals('testAccount', acct.Name, 'Account Not Created');
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
        Test.startTest();

        Opportunity oppty = new Opportunity(Name = 'testOpp');
        oppty.AccountId = acct.Id;
        oppty.StageName = 'Customize';
        oppty.CloseDate = date.today();
        oppty.EventEdition__c = ee.Id;
        oppty.Event_Series__c = es.Id;
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
        qtObj.Manual__c = false;
        qtobj.IsNotGeneralDocument__c = true;

        insert qtObj;

        SBQQ__QuoteLine__c qlObj = new SBQQ__QuoteLine__c();
        qlObj.SBQQ__Quote__c = qtObj.Id;
        qlObj.SBQQ__Product__c = prodObj.Id;
        insert qlObj; 
        oppty.StageName = 'Closed Won';
        update oppty;
        test.stopTest();
        PageReference pageRef = Page.Manually_Upload_Salesforce_Contract;
        pageRef.getParameters().put('quoteId', qtObj.id);
        ApexPages.currentPage().getParameters().put('id', qtObj.id);
        ApexPages.currentPage().getParameters().put('conga', 'conga');
        pageRef.getParameters().put('SessionId', 'sesssionId');
        pageRef.getParameters().put('ServerUrl', 'ServerUrl');
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.StandardController(qtObj);
        Manually_Upload_Salesforce_Contract oManuallyUploadObj = new Manually_Upload_Salesforce_Contract(sc);
        oManuallyUploadObj.autorun();
        oManuallyUploadObj.redirectToDS();
        oManuallyUploadObj.returnToPT();
        oManuallyUploadObj.generateDoc();
        oManuallyUploadObj.isWarningMsg=false;
        cls_loadGeneralDocument clsGenDoc = new cls_loadGeneralDocument();
        clsGenDoc.pageLoadAction();
        String surl = 'test';
        oManuallyUploadObj.getURParameter(surl);
        
        ocontact.Address_Verified__c = true;
        update ocontact;
        qtObj.SBQQ__Status__c = 'Contract Sent';
        update qtObj;
        oManuallyUploadObj.autorun();
    }

    static testMethod void checkValidations() {

        String uniqueUserName = 'sales' + DateTime.now().getTime() + 'testing@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Sales'];
        User u = new User(Alias = 'standt', Email='Salesuser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
         UserName=uniqueUserName);
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
        insert ee;

        APXTConga4__Conga_Template__c ct = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Deliverables');
        insert ct;

        APXTConga4__Conga_Template__c ctDeli1 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Brazil International Barter Contract');
        insert ctDeli1;
        APXTConga4__Conga_Template__c ctDetails2 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Brazil National Barter Contract');
        insert ctDetails2;
        
        National_Contract_Template__c nct = new National_Contract_Template__c();
        nct.Event_Edition__c = ee.Id;
        nct.Conga_Template__c = ct.Id;
        nct.Term_Conditions__c = ct.Id;
        nct.Type__c = 'Quote Template';
        insert nct;
        nct.Type__c = 'Contract Template';
        update nct;


        Account acct = new Account(Name = 'testAccount', CurrencyIsoCode = 'EUR', BillingCountry = 'Brasil');
        insert acct;
        
        Account acctt = new Account(Name = 'ManuallyUploadTest', CurrencyIsoCode = 'EUR', BillingCountry = 'Brasil');
        insert acctt;
        System.assertEquals('ManuallyUploadTest', acctt.Name, 'Account Not Created');
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
        ocontact.Address_Verified__c = true;
        insert ocontact;
        
        Contact con = new Contact();
        con.Email = 'test.test@gmail.com';
        con.Phone = '1234567890';
        con.FirstName = 'TestFNN';
        con.LastName = 'testLNN';
        con.AccountId = acctt.Id;
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
        oppty.Type = 'New';
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
        qtObj.SBQQ__Type__c = 'Amendment';
        update qtObj;
        oppty.stageName = 'Closed Won';
        update oppty;
        SBQQ__QuoteLine__c qlObj = new SBQQ__QuoteLine__c();
        qlObj.SBQQ__Quote__c = qtObj.Id;
        qlObj.SBQQ__Product__c = prodObj.Id;
        insert qlObj;
        
        Test.stopTest();
       
        PageReference pageRef = Page.Manually_Upload_Salesforce_Contract;
        pageRef.getParameters().put('id', qtObj.id);
        ApexPages.currentPage().getParameters().put('quoteId', qtObj.id);
        ApexPages.currentPage().getParameters().put('conga', 'conga');
        pageRef.getParameters().put('SessionId', 'sesssionId');
        pageRef.getParameters().put('ServerUrl', 'ServerUrl');
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.StandardController(qtObj);
        Manually_Upload_Salesforce_Contract oManuallyUploadObj = new Manually_Upload_Salesforce_Contract(sc);
        oManuallyUploadObj.template = 'Quote';
        oManuallyUploadObj.autorun();
        oManuallyUploadObj.redirectToDS();
        oManuallyUploadObj.returnToPT();
        oManuallyUploadObj.generateDoc();
        oManuallyUploadObj.accountId=acctt.id;
        oManuallyUploadObj.AddressOnTemplate();
        oManuallyUploadObj.isWarningMsg=false;
        oManuallyUploadObj.showQuoteAttachment();
        oManuallyUploadObj.continueCmd();
        cls_loadGeneralDocument clsGenDoc = new cls_loadGeneralDocument();
        clsGenDoc.pageLoadAction();
        String surl = 'test';
        oManuallyUploadObj.getURParameter(surl);
         System.runAs(u) {
             oManuallyUploadObj.autorun();
        }


    }
   static testMethod void validateBillingContact() {
        
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
        insert ee;

        APXTConga4__Conga_Template__c ct = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Deliverables');
        insert ct;

        APXTConga4__Conga_Template__c ctDeli1 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Brazil International Barter Contract');
        insert ctDeli1;
        APXTConga4__Conga_Template__c ctDetails2 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Brazil National Barter Contract');
        insert ctDetails2;
        
        National_Contract_Template__c nct = new National_Contract_Template__c();
        nct.Event_Edition__c = ee.Id;
        nct.Conga_Template__c = ct.Id;
        nct.Term_Conditions__c = ct.Id;
        nct.Type__c = 'Contract Template';
        insert nct;


        Account acct = new Account(Name = 'testAccount', CurrencyIsoCode = 'EUR', BillingCountry = 'Brasil');
        insert acct;
        
        System.assertEquals('testAccount', acct.Name, 'Account Not Created.');
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
        ocontact.Address_Verified__c = true;
        insert ocontact;
        Test.startTest();

        Opportunity oppty = new Opportunity(Name = 'testOpp');
        oppty.AccountId = acct.Id;
        oppty.StageName = 'Need assessment';
        oppty.CloseDate = date.today();
        oppty.EventEdition__c = ee.Id;
        oppty.Event_Series__c = es.Id;
        oppty.Type = 'New';
        insert oppty;

        SBQQ__Quote__c qtObj = new SBQQ__Quote__c();
        qtObj.SBQQ__Account__c = acct.Id;
        qtObj.SBQQ__Status__c = 'Draft';
        qtObj.SBQQ__Type__c = 'Quote';
        qtObj.SBQQ__StartDate__c = date.today();
        qtObj.Alternate_Currency2__c = 'EUR';
        qtObj.SBQQ__Opportunity2__c = oppty.Id;
        // qtObj.Billing_Contact__c = ocontact.Id;
        qtObj.Quote_Line_Deliverables__c = 'testing';
        qtObj.SBQQ__Primary__c = true;
        qtObj.Manual__c = false;
        insert qtObj;

        SBQQ__Quote__c qtObj1 = new SBQQ__Quote__c();
        qtObj1.SBQQ__Account__c = acct.Id;
        qtObj1.SBQQ__Status__c = 'Draft';
        qtObj1.SBQQ__Type__c = 'Quote';
        qtObj1.SBQQ__StartDate__c = date.today();
        qtObj1.Alternate_Currency2__c = 'EUR';
        qtObj1.SBQQ__Opportunity2__c = oppty.Id;
        qtObj.Billing_Contact__c = ocontact.Id;
        qtObj1.Quote_Line_Deliverables__c = 'testing';
        qtObj1.SBQQ__Primary__c = true;
        qtObj1.Manual__c = false;
        insert qtObj1;

        Test.stopTest();
        PageReference pageRef = Page.Manually_Upload_Salesforce_Contract;
        pageRef.getParameters().put('quoteId', qtObj.id);
        ApexPages.currentPage().getParameters().put('id', qtObj.id);
        ApexPages.currentPage().getParameters().put('conga', 'conga');
        pageRef.getParameters().put('SessionId', 'sesssionId');
        pageRef.getParameters().put('ServerUrl', 'ServerUrl');
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.StandardController(qtObj);
        Manually_Upload_Salesforce_Contract oManuallyUploadObj = new Manually_Upload_Salesforce_Contract(sc);
        oManuallyUploadObj.template = 'Contract';
        oManuallyUploadObj.autorun();
        oManuallyUploadObj.redirectToDS();
        oManuallyUploadObj.returnToPT();
        oManuallyUploadObj.generateDoc();
        oManuallyUploadObj.AddressOnTemplate();
        oManuallyUploadObj.continueCmd();
        oManuallyUploadObj.isWarningMsg=false;
        oManuallyUploadObj.showQuoteAttachment();
        cls_loadGeneralDocument clsGenDoc = new cls_loadGeneralDocument();
        clsGenDoc.pageLoadAction();
        String surl = 'test';
        oManuallyUploadObj.getURParameter(surl);
        sc = new ApexPages.StandardController(qtObj1);
        oManuallyUploadObj = new Manually_Upload_Salesforce_Contract(sc);
        oManuallyUploadObj.autorun();
    } 
    static testMethod void validateBillingContactone() {
        Application_Bypass__c app = new Application_Bypass__c(SetupOwnerId = UserInfo.getOrganizationId(), Bypass_Validation_Rules__c = false);
        insert app;
        
        Product2 prodObj = new Product2(Name = 'testProd"', Description = 'Test Description"', Description_in_Alt_Language__c = 'Alt" Description');
        insert prodObj;
        
        Pricebook2 pb = new Pricebook2(Name = 'TestPricebook');
        insert pb;

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
        oppty.Is_Barter_Opportunity__c = false;
        oppty.isThroughDcousign__c = false;
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
        qtObj.conga_quote_template_id__c = 'test';
        
        insert qtObj;

        SBQQ__QuoteLine__c qlObj = new SBQQ__QuoteLine__c();
        qlObj.SBQQ__Quote__c = qtObj.Id;
        qlObj.SBQQ__Product__c = prodObj.Id;
        insert qlObj;

        Blob b3 = Blob.valueOf('Test Data record');
        ContentVersion cVersion = new ContentVersion();
        cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
        cVersion.PathOnClient = 'Complete.pdf';//File name with extention
        cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
        cVersion.OwnerId = userinfo.getUserId();//Owner of the file
        cVersion.Title ='Completed Test Signed Attachment for Parent Manual';//Name of the file
        cVersion.VersionData = b3;//File content
        insert cVersion;
        Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
        cDocLink.LinkedEntityId = qtObj.Id;//Add attachment parentId
        cDocLink.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
        cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
        insert cDocLink;
        
        System.assertEquals('testAccount', acct.Name, 'Account Not Created');
       
        PageReference pageRef = Page.Manually_Upload_Salesforce_Contract;
        pageRef.getParameters().put('quoteId', qtObj.id);
        ApexPages.currentPage().getParameters().put('id', qtObj.id);
        ApexPages.currentPage().getParameters().put('conga', 'conga');
        pageRef.getParameters().put('SessionId', 'sesssionId');
        pageRef.getParameters().put('ServerUrl', 'ServerUrl');
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.StandardController(qtObj);
        Manually_Upload_Salesforce_Contract oManuallyUploadObj = new Manually_Upload_Salesforce_Contract(sc);
        oManuallyUploadObj.template = 'Contract';
        oManuallyUploadObj.autorun();
        oManuallyUploadObj.redirectToDS();
        oManuallyUploadObj.returnToPT();
        oManuallyUploadObj.generateDoc();
		Test.startTest();
        oManuallyUploadObj.AddressOnTemplate();
        oManuallyUploadObj.continueCmd();
        oManuallyUploadObj.showQuoteAttachment();
        oManuallyUploadObj.isWarningMsg=false;
        cls_loadGeneralDocument clsGenDoc = new cls_loadGeneralDocument();
        clsGenDoc.pageLoadAction();
        String surl = 'test';
        oManuallyUploadObj.getURParameter(surl);
        qtObj.conga_contract_template_id__c = 'test';
        update qtObj;
        sc = new ApexPages.StandardController(qtObj);
        
        oManuallyUploadObj = new Manually_Upload_Salesforce_Contract(sc);
        oManuallyUploadObj.autorun();
        list<SBQQ__QuoteLine__c> lstQL = new list<SBQQ__QuoteLine__c>();
        lstQL.add(qlObj);
        Test.stopTest();
        Manually_Upload_Salesforce_Contract.quoteLineValidation(lstQL);
    }
    
    static testMethod void testMethod1(){
                String uniqueUserName = 'sales' + DateTime.now().getTime() + 'testing@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Sales'];
        User u = new User(Alias = 'standt', Email='Salesuser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
         UserName=uniqueUserName);
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
        insert ee;

        APXTConga4__Conga_Template__c ct = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Deliverables');
        insert ct;

        APXTConga4__Conga_Template__c ctDeli1 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Brazil International Barter Contract');
        insert ctDeli1;
        APXTConga4__Conga_Template__c ctDetails2 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Brazil National Barter Contract');
        insert ctDetails2;
        
        National_Contract_Template__c nct = new National_Contract_Template__c();
        nct.Event_Edition__c = ee.Id;
        nct.Conga_Template__c = ct.Id;
        nct.Term_Conditions__c = ct.Id;
        nct.Type__c = 'Quote Template';
        insert nct;
        nct.Type__c = 'Contract Template';
        update nct;


        Account acct = new Account(Name = 'testAccount', CurrencyIsoCode = 'EUR', BillingCountry = 'Brasil');
        insert acct;
        
        Account acctt = new Account(Name = 'ManuallyUploadTest', CurrencyIsoCode = 'EUR', BillingCountry = 'Brasil');
        insert acctt;
        System.assertEquals('ManuallyUploadTest', acctt.Name, 'Account Not Created');
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
        ocontact.Address_Verified__c = true;
        insert ocontact;
        
        Contact con = new Contact();
        con.Email = 'test.test@gmail.com';
        con.Phone = '1234567890';
        con.FirstName = 'Test"FNN';
        con.LastName = 'testLNN';
        con.AccountId = acctt.Id;
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
		oppty.Type = 'New';        
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
        qtObj.conga_quote_template_id__c = 'test';
    
        insert qtObj;
        qtObj.SBQQ__Type__c = 'Amendment';
        update qtObj;
        oppty.stageName = 'Closed Won';
        update oppty;
        SBQQ__QuoteLine__c qlObj = new SBQQ__QuoteLine__c();
        qlObj.SBQQ__Quote__c = qtObj.Id;
        qlObj.SBQQ__Product__c = prodObj.Id;
        insert qlObj;
        
        Test.stopTest();
       
        PageReference pageRef = Page.Manually_Upload_Salesforce_Contract;
        pageRef.getParameters().put('id', qtObj.id);
        ApexPages.currentPage().getParameters().put('quoteId', qtObj.id);
        ApexPages.currentPage().getParameters().put('conga', 'conga');
        pageRef.getParameters().put('SessionId', 'sesssionId');
        pageRef.getParameters().put('ServerUrl', 'ServerUrl');
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.StandardController(qtObj);
        Manually_Upload_Salesforce_Contract oManuallyUploadObj = new Manually_Upload_Salesforce_Contract(sc);
        oManuallyUploadObj.template = 'Quote';
        oManuallyUploadObj.autorun();
        oManuallyUploadObj.redirectToDS();
        oManuallyUploadObj.returnToPT();
        oManuallyUploadObj.generateDoc();
        oManuallyUploadObj.accountId=acctt.id;
        oManuallyUploadObj.AddressOnTemplate();
        oManuallyUploadObj.isWarningMsg=false;
        oManuallyUploadObj.showQuoteAttachment();
        oManuallyUploadObj.continueCmd();
        cls_loadGeneralDocument clsGenDoc = new cls_loadGeneralDocument();
        clsGenDoc.pageLoadAction();
        String surl = 'test';
        oManuallyUploadObj.getURParameter(surl);
         System.runAs(u) {
             oManuallyUploadObj.autorun();
        }
        acct.BillingStreet = 'street"e';
        update acct;
        qtObj.conga_contract_template_id__c = 'test';
        update qtObj;
        
        PageReference pageRef1 = Page.Manually_Upload_Salesforce_Contract;
        pageRef1.getParameters().put('id', qtObj.id);
        ApexPages.currentPage().getParameters().put('quoteId', qtObj.id);
        ApexPages.currentPage().getParameters().put('conga', 'conga');
        pageRef1.getParameters().put('SessionId', 'sesssionId');
        pageRef1.getParameters().put('ServerUrl', 'ServerUrl');
        Test.setCurrentPage(pageRef1);

        ApexPages.StandardController sc1 = new ApexPages.StandardController(qtObj);
        Manually_Upload_Salesforce_Contract oManuallyUploadObj1 = new Manually_Upload_Salesforce_Contract(sc1);
        oManuallyUploadObj1.template = 'Quote';
        oManuallyUploadObj1.autorun();
        oManuallyUploadObj1.redirectToDS();
        oManuallyUploadObj1.returnToPT();
        oManuallyUploadObj1.generateDoc();
        oManuallyUploadObj1.accountId=acctt.id;
        oManuallyUploadObj1.AddressOnTemplate();
        oManuallyUploadObj1.isWarningMsg=false;
        oManuallyUploadObj1.showQuoteAttachment();
        oManuallyUploadObj1.continueCmd();
        cls_loadGeneralDocument clsGenDoc1 = new cls_loadGeneralDocument();
        clsGenDoc1.pageLoadAction();
        String surl1 = 'test';
        oManuallyUploadObj1.getURParameter(surl1);
         System.runAs(u) {
             oManuallyUploadObj1.autorun();
        }
        acct.BillingStreet = 'streete';
        acct.BillingCity = 'city"e';
        update acct;
            
        PageReference pageRef2 = Page.Manually_Upload_Salesforce_Contract;
        pageRef2.getParameters().put('id', qtObj.id);
        ApexPages.currentPage().getParameters().put('quoteId', qtObj.id);
        ApexPages.currentPage().getParameters().put('conga', 'conga');
        pageRef2.getParameters().put('SessionId', 'sesssionId');
        pageRef2.getParameters().put('ServerUrl', 'ServerUrl');
        Test.setCurrentPage(pageRef2);

        ApexPages.StandardController sc2 = new ApexPages.StandardController(qtObj);
        Manually_Upload_Salesforce_Contract oManuallyUploadObj2 = new Manually_Upload_Salesforce_Contract(sc2);
        oManuallyUploadObj2.template = 'Quote';
        oManuallyUploadObj2.autorun();
        oManuallyUploadObj2.redirectToDS();
        oManuallyUploadObj2.returnToPT();
        oManuallyUploadObj2.generateDoc();
        oManuallyUploadObj2.accountId=acctt.id;
        oManuallyUploadObj2.AddressOnTemplate();
        oManuallyUploadObj2.isWarningMsg=false;
        oManuallyUploadObj2.showQuoteAttachment();
        oManuallyUploadObj2.continueCmd();
        cls_loadGeneralDocument clsGenDoc2 = new cls_loadGeneralDocument();
        clsGenDoc2.pageLoadAction();
        String surl2 = 'test';
        oManuallyUploadObj.getURParameter(surl2);
         System.runAs(u) {
             oManuallyUploadObj2.autorun();
        }
        acct.BillingStreet = 'streete';
        acct.BillingCity = 'citye';
        update acct;
        qtObj.SBQQ__PrimaryContact__c = con.id;
        update qtObj;
            
        PageReference pageRef3 = Page.Manually_Upload_Salesforce_Contract;
        pageRef3.getParameters().put('id', qtObj.id);
        ApexPages.currentPage().getParameters().put('quoteId', qtObj.id);
        ApexPages.currentPage().getParameters().put('conga', 'conga');
        pageRef3.getParameters().put('SessionId', 'sesssionId');
        pageRef3.getParameters().put('ServerUrl', 'ServerUrl');
        Test.setCurrentPage(pageRef3);

        ApexPages.StandardController sc3 = new ApexPages.StandardController(qtObj);
        Manually_Upload_Salesforce_Contract oManuallyUploadObj3 = new Manually_Upload_Salesforce_Contract(sc3);
        oManuallyUploadObj3.template = 'Quote';
        oManuallyUploadObj3.autorun();
        oManuallyUploadObj3.redirectToDS();
        oManuallyUploadObj3.returnToPT();
        oManuallyUploadObj3.generateDoc();
        oManuallyUploadObj3.accountId=acctt.id;
        oManuallyUploadObj3.AddressOnTemplate();
        oManuallyUploadObj3.isWarningMsg=false;
        oManuallyUploadObj3.showQuoteAttachment();
        oManuallyUploadObj3.continueCmd();
        cls_loadGeneralDocument clsGenDoc3 = new cls_loadGeneralDocument();
        clsGenDoc3.pageLoadAction();
        String surl3 = 'test';
        oManuallyUploadObj.getURParameter(surl3);
         System.runAs(u) {
             oManuallyUploadObj3.autorun();
         }     
    }
     static testMethod void testMethod2(){
                String uniqueUserName = 'sales' + DateTime.now().getTime() + 'testing@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Sales'];
        User u = new User(Alias = 'standt', Email='Salesuser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
         UserName=uniqueUserName);
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

         APXTConga4__Conga_Template__c ct = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Deliverables');
        insert ct;
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
        insert ee;

      

        APXTConga4__Conga_Template__c ctDeli1 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Brazil International Barter Contract');
        insert ctDeli1;
        APXTConga4__Conga_Template__c ctDetails2 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Brazil National Barter Contract');
        insert ctDetails2;
        
        National_Contract_Template__c nct = new National_Contract_Template__c();
        nct.Event_Edition__c = ee.Id;
        nct.Conga_Template__c = ct.Id;
        nct.Term_Conditions__c = ct.Id;
        nct.Type__c = 'Quote Template';
        insert nct;
        nct.Type__c = 'Contract Template';
        update nct;


        Account acct = new Account(Name = 'testAccount', CurrencyIsoCode = 'EUR', BillingCountry = 'Brasil');
        insert acct;
        
        Account acctt = new Account(Name = 'ManuallyUploadTest', CurrencyIsoCode = 'EUR', BillingCountry = 'Brasil');
        insert acctt;
        System.assertEquals('ManuallyUploadTest', acctt.Name, 'Account Not Created');
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
        ocontact.Address_Verified__c = true;
        insert ocontact;
        
        Contact con = new Contact();
        con.Email = 'test.test@gmail.com';
        con.Phone = '1234567890';
        con.FirstName = 'TestFNN';
        con.LastName = 'testLNN';
        con.AccountId = acctt.Id;
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
        oppty.Type = 'New';
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
        qtObj.conga_quote_template_id__c = 'test';
    
        insert qtObj;
        qtObj.SBQQ__Type__c = 'Amendment';
        update qtObj;
        oppty.stageName = 'Closed Won';
        update oppty;
        SBQQ__QuoteLine__c qlObj = new SBQQ__QuoteLine__c();
        qlObj.SBQQ__Quote__c = qtObj.Id;
        qlObj.SBQQ__Product__c = prodObj.Id;
        insert qlObj;
        
        Test.stopTest();
       
        PageReference pageRef = Page.Manually_Upload_Salesforce_Contract;
        pageRef.getParameters().put('id', qtObj.id);
        ApexPages.currentPage().getParameters().put('quoteId', qtObj.id);
        ApexPages.currentPage().getParameters().put('conga', 'conga');
        pageRef.getParameters().put('SessionId', 'sesssionId');
        pageRef.getParameters().put('ServerUrl', 'ServerUrl');
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.StandardController(qtObj);
        Manually_Upload_Salesforce_Contract oManuallyUploadObj = new Manually_Upload_Salesforce_Contract(sc);
        oManuallyUploadObj.template = 'Quote';
        oManuallyUploadObj.autorun();
        oManuallyUploadObj.redirectToDS();
        oManuallyUploadObj.returnToPT();
        oManuallyUploadObj.generateDoc();
        oManuallyUploadObj.accountId=acctt.id;
        oManuallyUploadObj.AddressOnTemplate();
        oManuallyUploadObj.isWarningMsg=false;
        oManuallyUploadObj.showQuoteAttachment();
        oManuallyUploadObj.continueCmd();
        cls_loadGeneralDocument clsGenDoc = new cls_loadGeneralDocument();
        clsGenDoc.pageLoadAction();
        String surl = 'test';
        oManuallyUploadObj.getURParameter(surl);
         System.runAs(u) {
             oManuallyUploadObj.autorun();
        }
        acct.BillingStreet = 'street"e';
        update acct;
        qtObj.conga_contract_template_id__c = 'test';
        update qtObj;
        
        PageReference pageRef1 = Page.Manually_Upload_Salesforce_Contract;
        pageRef1.getParameters().put('id', qtObj.id);
        ApexPages.currentPage().getParameters().put('quoteId', qtObj.id);
        ApexPages.currentPage().getParameters().put('conga', 'conga');
        pageRef1.getParameters().put('SessionId', 'sesssionId');
        pageRef1.getParameters().put('ServerUrl', 'ServerUrl');
        Test.setCurrentPage(pageRef1);

        ApexPages.StandardController sc1 = new ApexPages.StandardController(qtObj);
        Manually_Upload_Salesforce_Contract oManuallyUploadObj1 = new Manually_Upload_Salesforce_Contract(sc1);
        oManuallyUploadObj1.template = 'Quote';
        oManuallyUploadObj1.autorun();
        oManuallyUploadObj1.redirectToDS();
        oManuallyUploadObj1.returnToPT();
        oManuallyUploadObj1.generateDoc();
        oManuallyUploadObj1.accountId=acctt.id;
        oManuallyUploadObj1.AddressOnTemplate();
        oManuallyUploadObj1.isWarningMsg=false;
        oManuallyUploadObj1.showQuoteAttachment();
        oManuallyUploadObj1.continueCmd();
        cls_loadGeneralDocument clsGenDoc1 = new cls_loadGeneralDocument();
        clsGenDoc1.pageLoadAction();
        String surl1 = 'test';
        oManuallyUploadObj1.getURParameter(surl1);
         System.runAs(u) {
             oManuallyUploadObj1.autorun();
        }
        acct.BillingStreet = 'streete';
        acct.BillingCity = 'City';
        update acct;
        con.FirstName = 'TestFNN';
        con.LastName = 'testLNN"';
        update con;
        qtObj.SBQQ__PrimaryContact__c = con.id;
        update qtObj;
         PageReference pageRef2 = Page.Manually_Upload_Salesforce_Contract;
        pageRef2.getParameters().put('id', qtObj.id);
        ApexPages.currentPage().getParameters().put('quoteId', qtObj.id);
        ApexPages.currentPage().getParameters().put('conga', 'conga');
        pageRef2.getParameters().put('SessionId', 'sesssionId');
        pageRef2.getParameters().put('ServerUrl', 'ServerUrl');
        Test.setCurrentPage(pageRef2);

        ApexPages.StandardController sc2 = new ApexPages.StandardController(qtObj);
        Manually_Upload_Salesforce_Contract oManuallyUploadObj2 = new Manually_Upload_Salesforce_Contract(sc2);
        oManuallyUploadObj2.template = 'Quote';
        oManuallyUploadObj2.autorun();
        oManuallyUploadObj2.redirectToDS();
        oManuallyUploadObj2.returnToPT();
        oManuallyUploadObj2.generateDoc();
        oManuallyUploadObj2.accountId=acctt.id;
        oManuallyUploadObj2.AddressOnTemplate();
        oManuallyUploadObj2.isWarningMsg=false;
        oManuallyUploadObj2.showQuoteAttachment();
        oManuallyUploadObj2.continueCmd();
        cls_loadGeneralDocument clsGenDoc2 = new cls_loadGeneralDocument();
        clsGenDoc2.pageLoadAction();
        String surl2 = 'test';
        oManuallyUploadObj1.getURParameter(surl2);
         System.runAs(u) {
             oManuallyUploadObj2.autorun();
        }
        acct.BillingStreet = 'streete';
        acct.BillingCity = 'City';
        update acct;
        con.FirstName = 'TestFNN';
        con.LastName = 'testLNN';
        update con;
        oppty.Name = 'Test"Opp';
        update oppty;
        qtObj.SBQQ__PrimaryContact__c = con.id;
        update qtObj;
         PageReference pageRef3 = Page.Manually_Upload_Salesforce_Contract;
        pageRef3.getParameters().put('id', qtObj.id);
        ApexPages.currentPage().getParameters().put('quoteId', qtObj.id);
        ApexPages.currentPage().getParameters().put('conga', 'conga');
        pageRef3.getParameters().put('SessionId', 'sesssionId');
        pageRef3.getParameters().put('ServerUrl', 'ServerUrl');
        Test.setCurrentPage(pageRef3);

        ApexPages.StandardController sc3 = new ApexPages.StandardController(qtObj);
        Manually_Upload_Salesforce_Contract oManuallyUploadObj3 = new Manually_Upload_Salesforce_Contract(sc3);
        oManuallyUploadObj3.template = 'Quote';
        oManuallyUploadObj3.autorun();
        oManuallyUploadObj3.redirectToDS();
        oManuallyUploadObj3.returnToPT();
        oManuallyUploadObj3.generateDoc();
        oManuallyUploadObj3.accountId=acctt.id;
        oManuallyUploadObj3.AddressOnTemplate();
        oManuallyUploadObj3.isWarningMsg=false;
        oManuallyUploadObj3.showQuoteAttachment();
        oManuallyUploadObj3.continueCmd();
        cls_loadGeneralDocument clsGenDoc3 = new cls_loadGeneralDocument();
        clsGenDoc3.pageLoadAction();
        String surl3 = 'test';
        oManuallyUploadObj3.getURParameter(surl3);
         System.runAs(u) {
             oManuallyUploadObj3.autorun();
        }       
   }
    
      static testMethod void mixedProductCheck() {

        String uniqueUserName = 'sales' + DateTime.now().getTime() + 'testing@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Sales'];
        User u = new User(Alias = 'standt', Email='Salesuser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
         UserName=uniqueUserName);
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
        ee.Mix_Supply_Terms_and_Condition__c=ct.Id;
        insert ee;


        Account acct = new Account(Name = 'testAccount', CurrencyIsoCode = 'EUR', BillingCountry = 'Brasil');
        insert acct;
        
        Account acctt = new Account(Name = 'ManuallyUploadTest', CurrencyIsoCode = 'EUR', BillingCountry = 'Brasil');
        insert acctt;
        System.assertEquals('ManuallyUploadTest', acctt.Name, 'Account Not Created');
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
        ocontact.Address_Verified__c = true;
        insert ocontact;
        
        Contact con = new Contact();
        con.Email = 'test.test@gmail.com';
        con.Phone = '1234567890';
        con.FirstName = 'TestFNN';
        con.LastName = 'testLNN';
        con.AccountId = acctt.Id;
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
        oppty.Type = 'New';
        insert oppty;


        SBQQ__Quote__c qtObj1 = new SBQQ__Quote__c();
        qtObj1.SBQQ__Account__c = acct.Id;
        qtObj1.SBQQ__Status__c = 'Draft';
        qtObj1.SBQQ__Type__c = 'Quote';
        qtObj1.SBQQ__StartDate__c = date.today();
        qtObj1.Alternate_Currency2__c = 'EUR';
        qtObj1.SBQQ__Opportunity2__c = oppty.Id;
        qtObj1.Billing_Contact__c = con.Id;
        qtObj1.Quote_Line_Deliverables__c = 'testing';
        qtObj1.SBQQ__Primary__c = true;
        qtObj1.Manual__c = false;
         
        insert qtObj1;
       
       List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c qlObj = new SBQQ__QuoteLine__c();
        qlObj.SBQQ__Quote__c = qtObj1.Id;
        qlObj.SBQQ__Product__c = prodObj.Id;
        quoteLineList.add(qlObj);
        
        SBQQ__QuoteLine__c qlObj1 = new SBQQ__QuoteLine__c();
        qlObj1.SBQQ__Quote__c = qtObj1.Id;
        qlObj1.SBQQ__Product__c = prodObj1.Id;
        quoteLineList.add(qlObj1);
        insert quoteLineList;
        Test.stopTest();
       
        PageReference pageRef = Page.Manually_Upload_Salesforce_Contract;
        pageRef.getParameters().put('id', qtObj1.id);
        ApexPages.currentPage().getParameters().put('quoteId', qtObj1.id);
        ApexPages.currentPage().getParameters().put('conga', 'conga');
        pageRef.getParameters().put('SessionId', 'sesssionId');
        pageRef.getParameters().put('ServerUrl', 'ServerUrl');
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.StandardController(qtObj1);
        Manually_Upload_Salesforce_Contract oManuallyUploadObj = new Manually_Upload_Salesforce_Contract(sc);
        oManuallyUploadObj.template = 'Quote';
    
        oManuallyUploadObj.accountId=acctt.id;
        oManuallyUploadObj.isWarningMsg=false;
  


   }
     static testMethod void delegateProductCheck() {

        String uniqueUserName = 'sales' + DateTime.now().getTime() + 'testing@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Sales'];
        User u = new User(Alias = 'standt', Email='Salesuser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
         UserName=uniqueUserName);
        Pricebook2 pb = new Pricebook2(Name = 'TestPricebook');
        insert pb;

        Event_Series__c es = new Event_Series__c(Name = 'Test');
        es.Local_Country__c = 'Brasil';
        es.Company_Country__c = 'Brasil';
        es.Not_By_pass_Local_Template__c = true;
        insert es;

        Product2 prodObj = new Product2(Name = 'testProd',Delegate_Product__c=true);
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

        APXTConga4__Conga_Template__c ct = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Deliverables');
        insert ct;
          
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
        ee.DS_Terms_Condition_Template__c=ct.Id;
        insert ee;

Test.startTest();
        Account acct = new Account(Name = 'testAccount', CurrencyIsoCode = 'EUR', BillingCountry = 'Brasil');
        insert acct;
        
        Account acctt = new Account(Name = 'ManuallyUploadTest', CurrencyIsoCode = 'EUR', BillingCountry = 'Brasil');
        insert acctt;
        System.assertEquals('ManuallyUploadTest', acctt.Name, 'Account Not Created');
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
        ocontact.Address_Verified__c = true;
        insert ocontact;
        system.debug('limits queries 1 ' + Limits.getQueries());
        Contact con = new Contact();
        con.Email = 'test.test@gmail.com';
        con.Phone = '1234567890';
        con.FirstName = 'TestFNN';
        con.LastName = 'testLNN';
        con.AccountId = acctt.Id;
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
        oppty.Type = 'New';
        insert oppty;

        SBQQ__Quote__c qtObj1 = new SBQQ__Quote__c();
        qtObj1.SBQQ__Account__c = acct.Id;
        qtObj1.SBQQ__Status__c = 'Draft';
        qtObj1.SBQQ__Type__c = 'Quote';
        qtObj1.SBQQ__StartDate__c = date.today();
        qtObj1.Alternate_Currency2__c = 'EUR';
        qtObj1.SBQQ__Opportunity2__c = oppty.Id;
        qtObj1.Billing_Contact__c = con.Id;
        qtObj1.Quote_Line_Deliverables__c = 'testing';
        qtObj1.SBQQ__Primary__c = true;
        qtObj1.Manual__c = false;
         
        insert qtObj1;
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c qlObj = new SBQQ__QuoteLine__c();
        qlObj.SBQQ__Quote__c = qtObj1.Id;
        qlObj.SBQQ__Product__c = prodObj.Id;
        quoteLineList.add(qlObj);
        
        SBQQ__QuoteLine__c qlObj1 = new SBQQ__QuoteLine__c();
        qlObj1.SBQQ__Quote__c = qtObj1.Id;
        qlObj1.SBQQ__Product__c = prodObj.Id;
        quoteLineList.add(qlObj1);
        insert quoteLineList;
        
        Test.stopTest();
       
        PageReference pageRef = Page.Manually_Upload_Salesforce_Contract;
        pageRef.getParameters().put('id', qtObj1.id);
        ApexPages.currentPage().getParameters().put('quoteId', qtObj1.id);
        ApexPages.currentPage().getParameters().put('conga', 'conga');
        pageRef.getParameters().put('SessionId', 'sesssionId');
        pageRef.getParameters().put('ServerUrl', 'ServerUrl');
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.StandardController(qtObj1);
        Manually_Upload_Salesforce_Contract oManuallyUploadObj = new Manually_Upload_Salesforce_Contract(sc);
        oManuallyUploadObj.template = 'Quote';
    
        oManuallyUploadObj.accountId=acctt.id;
        oManuallyUploadObj.isWarningMsg=false;
  


   }
   
   static testMethod void nondelegateProductCheck() {

        String uniqueUserName = 'sales' + DateTime.now().getTime() + 'testing@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Sales'];
        User u = new User(Alias = 'standt', Email='Salesuser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
         UserName=uniqueUserName);
        Pricebook2 pb = new Pricebook2(Name = 'TestPricebook');
        insert pb;

        Event_Series__c es = new Event_Series__c(Name = 'Test');
        es.Local_Country__c = 'Brasil';
        es.Company_Country__c = 'Brasil';
        es.Not_By_pass_Local_Template__c = true;
        insert es;

        Product2 prodObj = new Product2(Name = 'testProd',Delegate_Product__c=true);
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
        ee.Alternative_Terms_Condition_Template__c=ct.Id;
        insert ee;


        Account acct = new Account(Name = 'testAccount', CurrencyIsoCode = 'EUR', BillingCountry = 'Brasil');
        insert acct;
        
        Account acctt = new Account(Name = 'ManuallyUploadTest', CurrencyIsoCode = 'EUR', BillingCountry = 'Brasil');
        insert acctt;
        System.assertEquals('ManuallyUploadTest', acctt.Name, 'Account Not Created');
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
        ocontact.Address_Verified__c = true;
        insert ocontact;
        
        Contact con = new Contact();
        con.Email = 'test.test@gmail.com';
        con.Phone = '1234567890';
        con.FirstName = 'TestFNN';
        con.LastName = 'testLNN';
        con.AccountId = acctt.Id;
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
        oppty.Type = 'New';
        insert oppty;


        SBQQ__Quote__c qtObj1 = new SBQQ__Quote__c();
        qtObj1.SBQQ__Account__c = acct.Id;
        qtObj1.SBQQ__Status__c = 'Draft';
        qtObj1.SBQQ__Type__c = 'Quote';
        qtObj1.SBQQ__StartDate__c = date.today();
        qtObj1.Alternate_Currency2__c = 'EUR';
        qtObj1.SBQQ__Opportunity2__c = oppty.Id;
        qtObj1.Billing_Contact__c = con.Id;
        qtObj1.Quote_Line_Deliverables__c = 'testing';
        qtObj1.SBQQ__Primary__c = true;
        qtObj1.Manual__c = false;
         
        insert qtObj1;
       
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c qlObj = new SBQQ__QuoteLine__c();
        qlObj.SBQQ__Quote__c = qtObj1.Id;
        qlObj.SBQQ__Product__c = prodObj.Id;
        quoteLineList.add(qlObj);
        
        SBQQ__QuoteLine__c qlObj1 = new SBQQ__QuoteLine__c();
        qlObj1.SBQQ__Quote__c = qtObj1.Id;
        qlObj1.SBQQ__Product__c = prodObj.Id;
        quoteLineList.add(qlObj1);
       insert quoteLineList;
        
        Test.stopTest();
       
        PageReference pageRef = Page.Manually_Upload_Salesforce_Contract;
        pageRef.getParameters().put('id', qtObj1.id);
        ApexPages.currentPage().getParameters().put('quoteId', qtObj1.id);
        ApexPages.currentPage().getParameters().put('conga', 'conga');
        pageRef.getParameters().put('SessionId', 'sesssionId');
        pageRef.getParameters().put('ServerUrl', 'ServerUrl');
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.StandardController(qtObj1);
        Manually_Upload_Salesforce_Contract oManuallyUploadObj = new Manually_Upload_Salesforce_Contract(sc);
        oManuallyUploadObj.template = 'Quote';
    
        oManuallyUploadObj.accountId=acctt.id;
        oManuallyUploadObj.isWarningMsg=false;
   }
    
   static testMethod void testMethod10(){
                String uniqueUserName = 'sales' + DateTime.now().getTime() + 'testing@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Sales-Brasil'];
        User u = new User(Alias = 'standt', Email='Salesuser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
         UserName=uniqueUserName);
        Pricebook2 pb = new Pricebook2(Name = 'TestPricebook');
        insert pb;

        Event_Series__c es = new Event_Series__c(Name = 'Test');
        es.Local_Country__c = 'Brasil';
        es.Company_Country__c = 'Brasil';
        es.Not_By_pass_Local_Template__c = true;
        insert es;

        Product2 prodObj = new Product2(Name = 'testProd"');
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
        insert ee;

        APXTConga4__Conga_Template__c ct = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Deliverables');
        insert ct;

        APXTConga4__Conga_Template__c ctDeli1 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Brazil International Barter Contract');
        insert ctDeli1;
        APXTConga4__Conga_Template__c ctDetails2 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Brazil National Barter Contract');
        insert ctDetails2;
        
        National_Contract_Template__c nct = new National_Contract_Template__c();
        nct.Event_Edition__c = ee.Id;
        nct.Conga_Template__c = ct.Id;
        nct.Term_Conditions__c = ct.Id;
        nct.Type__c = 'Quote Template';
        insert nct;
        nct.Type__c = 'Contract Template';
        update nct;


        Account acct = new Account(Name = 'testAccount', CurrencyIsoCode = 'EUR', BillingCountry = 'India');
        insert acct;
        
        Account acctt = new Account(Name = 'ManuallyUploadTest', CurrencyIsoCode = 'EUR', BillingCountry = 'Brasil');
        insert acctt;
        System.assertEquals('ManuallyUploadTest', acctt.Name, 'Account Not Created');
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
        ocontact.Address_Verified__c = true;
        insert ocontact;
        
        Contact con = new Contact();
        con.Email = 'test.test@gmail.com';
        con.Phone = '1234567890';
        con.FirstName = 'TestFNN';
        con.LastName = 'testLNN';
        con.AccountId = acctt.Id;
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
        oppty.Type = 'New';
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
        qtObj.conga_quote_template_id__c = 'test';
        qtObj.conga_contract_template_id__c = 'test2';
        insert qtObj;
        qtObj.SBQQ__Type__c = 'Amendment';
        update qtObj;
        oppty.stageName = 'Closed Won';
        update oppty;
        SBQQ__QuoteLine__c qlObj = new SBQQ__QuoteLine__c();
        qlObj.SBQQ__Quote__c = qtObj.Id;
        qlObj.SBQQ__Product__c = prodObj.Id;
        insert qlObj;
        
        Test.stopTest();
       
        PageReference pageRef = Page.Manually_Upload_Salesforce_Contract;
        pageRef.getParameters().put('id', qtObj.id);
        ApexPages.currentPage().getParameters().put('quoteId', qtObj.id);
        ApexPages.currentPage().getParameters().put('conga', 'conga');
        pageRef.getParameters().put('SessionId', 'sesssionId');
        pageRef.getParameters().put('ServerUrl', 'ServerUrl');
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.StandardController(qtObj);
        Manually_Upload_Salesforce_Contract oManuallyUploadObj = new Manually_Upload_Salesforce_Contract(sc);
        oManuallyUploadObj.template = 'Quote';
        oManuallyUploadObj.autorun();
        oManuallyUploadObj.redirectToDS();
        oManuallyUploadObj.returnToPT();
        oManuallyUploadObj.generateDoc();
        oManuallyUploadObj.accountId=acctt.id;
        oManuallyUploadObj.AddressOnTemplate();
        oManuallyUploadObj.isWarningMsg=false;
        oManuallyUploadObj.showQuoteAttachment();
        oManuallyUploadObj.continueCmd();
        cls_loadGeneralDocument clsGenDoc = new cls_loadGeneralDocument();
        clsGenDoc.pageLoadAction();
        String surl = 'test';
        oManuallyUploadObj.getURParameter(surl);
         System.runAs(u) {
             oManuallyUploadObj.autorun();
        } 
       prodObj.Name = 'testProd';
       update prodObj;
       acct.BillingCountry = 'Brasil';
       update acct;
       
        PageReference pageRef1 = Page.Manually_Upload_Salesforce_Contract;
        pageRef1.getParameters().put('id', qtObj.id);
        ApexPages.currentPage().getParameters().put('quoteId', qtObj.id);
        ApexPages.currentPage().getParameters().put('conga', 'conga');
        pageRef1.getParameters().put('SessionId', 'sesssionId');
        pageRef1.getParameters().put('ServerUrl', 'ServerUrl');
        Test.setCurrentPage(pageRef1);

        ApexPages.StandardController sc1 = new ApexPages.StandardController(qtObj);
        Manually_Upload_Salesforce_Contract oManuallyUploadObj1 = new Manually_Upload_Salesforce_Contract(sc1);
        oManuallyUploadObj1.template = 'Quote';
        oManuallyUploadObj1.autorun();
        oManuallyUploadObj1.redirectToDS();
        oManuallyUploadObj1.returnToPT();
        oManuallyUploadObj1.generateDoc();
        oManuallyUploadObj1.accountId=acctt.id;
        oManuallyUploadObj1.AddressOnTemplate();
        oManuallyUploadObj1.isWarningMsg=false;
        oManuallyUploadObj1.showQuoteAttachment();
        oManuallyUploadObj1.continueCmd();
        cls_loadGeneralDocument clsGenDoc1 = new cls_loadGeneralDocument();
        clsGenDoc1.pageLoadAction();
        String surl1 = 'test';
        oManuallyUploadObj1.getURParameter(surl1);
         System.runAs(u) {
             oManuallyUploadObj1.autorun();
        }       
   } 
}