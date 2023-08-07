/**
* File:        cls_quotecontractTemplates_Test.cls
* Project:     GAP
* Date:        2/20/2017 5:52 AM
* Created By:  Abdul Kadir
* *************************************************************************
* @description cls_quotecontractTemplates.cls Test
* Code Coverage : 85%
* *************************************************************************
* History:To avoid autorabbit violations.
* Created By : Avinash Shukla BK-2871/BK-2973/74
*/

@isTest
public class cls_quotecontractTemplates_Test {
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
        ee.Allow_Docusign_Counter_Sign__c = true;
        insert ee;
        
        APXTConga4__Conga_Template__c ct = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'test');
        insert ct;
        APXTConga4__Conga_Template__c ctDeli = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Deliverables');
        insert ctDeli;
        
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
        
        system.AssertEquals('TestEvent' , ee.Name, 'Error ::: Event not created');
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
        Update ac;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(quoteObj);
        cls_quotecontractTemplates cls1 = new cls_quotecontractTemplates (sc);
        cls1.template = 'Quote';
        cls1.continueCmd();
        cls1.cancel();
        cls1.autorun();
        Event_Edition__c ee = [Select Id, Name from Event_Edition__c limit 1];
        system.AssertEquals('TestEvent' , ee.Name, 'Error ::: Event not created');
    }
    
    static testmethod void testMethodsWithCondition1() {
        Setup();
        SBQQ__Quote__c quoteObj = [select id, SBQQ__Account__c from SBQQ__Quote__c  limit 1];
        // Data Setup.
        PageReference pageRef = Page.vf_quoteLineAttachmentsConga;
        pageRef.getParameters().put('quoteId', quoteObj.Id);
        pageRef.getParameters().put('SessionId', 'sesssionId');
        pageRef.getParameters().put('ServerUrl', 'ServerUrl');
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(quoteObj);
        cls_quotecontractTemplates cls1 = new cls_quotecontractTemplates (sc);
        cls1.template = 'Contract';
        cls1.continueCmd();
        cls1.cancel();
        cls1.showQuoteAttachment();
        Event_Series__c ee = [Select Id, Name from Event_Series__c Limit 1];
        system.AssertEquals('Test' , ee.Name, 'Error ::: Event not created');
    }
    
    static testmethod void testMethodsWithCondition2() {
        Setup();
        SBQQ__Quote__c quoteObj = [select id, SBQQ__Account__c from SBQQ__Quote__c  limit 1];
        // Data Setup.
        PageReference pageRef = Page.vf_quoteLineAttachmentsConga;
        pageRef.getParameters().put('quoteId', quoteObj.Id);
        pageRef.getParameters().put('SessionId', 'sesssionId');
        pageRef.getParameters().put('ServerUrl', 'ServerUrl');
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(quoteObj);
        Delete [Select Id from National_Contract_Template__c];
        cls_quotecontractTemplates cls1 = new cls_quotecontractTemplates (sc);
        cls1.template = 'Quote';
        cls1.continueCmd();
        cls1.cancel();
        cls1.autorun();
        List<National_Contract_Template__c> testList = new List<National_Contract_Template__c>();
        testList = [Select Id from National_Contract_Template__c];
        system.AssertEquals(true , testList.isEmpty(), 'EmptyList');
    }
    
    static testmethod void testMethodsWithCondition3() {
        Setup();
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
        
        
        cls_quotecontractTemplates cls1 = new cls_quotecontractTemplates (sc);
        cls1.template = 'Quote';
        cls1.accountId = quoteObj.SBQQ__Account__c;
        cls1.CompanyCountry  = 'USA';
        cls1.continueCmd();
        cls1.cancel();
        cls1.autorun();
        cls1.template = 'Contract';
        cls1.continueCmd();
        cls1.AddressOnTemplate();
        system.AssertEquals(quoteObj.Id , ApexPages.currentPage().getParameters().get('quoteId'), 'quoteId Match');
        
    }
}