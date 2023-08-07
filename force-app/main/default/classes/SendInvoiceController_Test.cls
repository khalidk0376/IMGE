/**
* File:        SendInvoiceController_Test.cls
* Project:     GAP
* Date:        17/10/2017
* Test Class For:  SendInvoiceController
* Code Coverage:   76%
* Created By:  Abdul Kadir
* Modified By:  Yash Gupta [20/12/2018]
* *************************************************************************
* @description test class for SendInvoiceController.cls.
* *************************************************************************
* History: To Avoid violations coming from Autorabbit.
*/
@isTest
public class SendInvoiceController_Test {
    /**
     * [sendInvoiceTest sendInvoiceTest]
     * @return [sendInvoiceTest]
     */
    public static testmethod void sendInvoiceTest(){
        Folder instFolder = [Select Id From Folder Where Id='00l50000001GfAf' LIMIT 1];
        Document doc1 = new Document(name='EmailTemplateFooter_Logo',folderId=instFolder.Id);
        insert doc1;
        Document doc2 = new Document(name='EmailTemplateHeader_Logo',folderId=instFolder.Id);
        insert doc2;  
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
            List<Folder> lstFolder = [Select Id From Folder Where Name = 'Conga Email Staging Templates' ];
            if(lstFolder.size() > 0){
                EmailTemplate et=new EmailTemplate(Name='custom email template',developerName = 'testDev', FolderId = lstFolder.get(0).Id, TemplateType= 'Text',HtmlValue='{!emailBody}{!footerlogo}{!headerlogo}');
                insert et;
                EmailTemplate etOBC=new EmailTemplate(Name='Send OBC Link By Email',developerName = 'testDEVVvv', FolderId = lstFolder.get(0).Id, TemplateType= 'Text',HtmlValue='{!emailBody}{!footerlogo}{!headerlogo}');
                insert etOBC;
            }
        }
        
        contact con=new Contact();
        con.firstname='test';
        con.lastname='test2';
        con.email='test@test.com';
        con.MailingStreet = 'Test Street';
        con.MailingCity = 'Noida';
        con.MailingPostalCode = '201301';
        insert con;
        
        Account acct=new Account(Name='testAccount',CurrencyIsoCode='EUR');
        insert acct;
        System.assertEquals('testAccount', acct.Name , 'Account must be inserted');
        
        Pricebook2 pb=new Pricebook2(Name='TestPricebook');
        insert pb;
        
        Event_Edition__c ee=new Event_Edition__c();
        ee.Name='TestEvent';
        ee.Tab1__c='tab1';
        ee.Tab4__c='tab4';
        ee.Tab7__c='tab7';
        ee.Tab8__c='Tab8__c';
        ee.Start_Date__c=date.today();
        ee.End_Date__c =date.today().adddays(1);
        ee.Venue__c = 'test';
        ee.Event_Price_Book__c=pb.Id;
        insert ee;
        
        Opportunity oppty=new Opportunity(Name='testOpp',EventEdition__c=ee.Id);
        oppty.AccountId=acct.Id;
        oppty.StageName='Discover';
        oppty.CloseDate=date.today();
        oppty.Opportunity_Contact__c =con.Id;
        insert oppty;
        
        ContentVersion cVersion = new ContentVersion();
        cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
        cVersion.PathOnClient = 'test.txt';//File name with extention
        cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
        cVersion.OwnerId = Userinfo.getUserId();//Owner of the file
        cVersion.Title = 'test';//Name of the file
        cVersion.VersionData = EncodingUtil.base64Decode('This is version data');//File content
        insert cVersion;
        Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
        cDocLink.LinkedEntityId = acct.Id;//Add attachment parentId
        cDocLink.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
        cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
        insert cDocLink;
        list<string> tempAttchmentId = new list<String>();
        tempAttchmentId.add(conDocument);
        
       // SendInvoiceController obj = new SendInvoiceController();
       // obj.attachmentListName.add(attachment.Name);
        
        PageReference pRef = Page.sendInvoice;
        pRef.getParameters().put('id', acct.Id);
        pRef.getParameters().put('retUrl', oppty.Id);
        Test.setCurrentPage(pRef);
        
        Test.startTest();
        
        SendInvoiceController pc = new SendInvoiceController();
        pc.toAddressesE='test@test.com';
        pc.ccAddressesE='test@test.com';
        pc.subject='testest';
        pc.emailBody='testbodysdfsdfsdfsd';
        pc.attachmentListID =tempAttchmentId;
        pc.sendInvoiceMethod();
        pc.SendOBCLinkMethod();
        pc.cancel();
        pc.upload();
        pc.reDirectToSSC(); 
        pc.fileName = 'testsnam';
        Test.stopTest();
    }
    /**
     * [sendContractTest testmethod]
     * @return [testmethod]
     */
    public static testmethod void sendContractTest(){
        Folder instFolder = [Select Id From Folder Where Id='00l50000001GfAf' LIMIT 1];
        Document doc1 = new Document(name='EmailTemplateFooter_Logo',folderId=instFolder.Id);
        insert doc1;
        Document doc2 = new Document(name='EmailTemplateHeader_Logo',folderId=instFolder.Id);
        insert doc2;
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
            List<Folder> lstFolder = [Select Id From Folder Where Name = 'Conga Email Staging Templates' ];
            if(lstFolder.size() > 0){
                EmailTemplate et=new EmailTemplate(Name='custom email template',developerName = 'testDEVV', FolderId = lstFolder.get(0).Id, TemplateType= 'Text',HtmlValue='{!emailBody}{!footerlogo}{!headerlogo}');
                insert et;
                EmailTemplate etOBC=new EmailTemplate(Name='Send OBC Link By Email',developerName = 'testDEVVvv', FolderId = lstFolder.get(0).Id, TemplateType= 'Text',HtmlValue='{!emailBody}{!footerlogo}{!headerlogo}');
                insert etOBC;
            }
        }
        Account acct=new Account(Name='testAccount',CurrencyIsoCode='EUR');
        insert acct;
        System.assertEquals('testAccount', acct.Name, 'Account must be inserted');
        ContentVersion cVersion = new ContentVersion();
        cVersion.PathOnClient = 'test.txt';//File name with extention
        cVersion.Title = 'test';//Name of the file
        cVersion.VersionData =EncodingUtil.base64Decode('This is version data');//File content
        insert cVersion;
        Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
        cDocLink.LinkedEntityId = acct.Id;//Add attachment parentId
        cDocLink.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
        cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
        insert cDocLink;
        contact con=new Contact();
        con.firstname='test';
        con.lastname='test2';
        con.email='test@test.com';
        con.MailingStreet = 'Test Street';
        con.MailingCity = 'Noida';
        con.MailingPostalCode = '201301';
        insert con;
        
        Pricebook2 pb=new Pricebook2(Name='TestPricebook');
        insert pb;
        
        Event_Edition__c ee=new Event_Edition__c();
        ee.Name='TestEvent';
        ee.Tab1__c='tab1';
        ee.Tab4__c='tab4';
        ee.Tab7__c='tab7';
        ee.Tab8__c='Tab8__c';
        ee.Event_Price_Book__c=pb.Id;
        insert ee;
        
        Opportunity oppty=new Opportunity(Name='testOpp',EventEdition__c=ee.Id);
        oppty.AccountId=acct.Id;
        oppty.StageName='Discover';
        oppty.CloseDate=date.today();
        oppty.Opportunity_Contact__c =con.Id;
        insert oppty;
        
        SBQQ__Quote__c qtObj=new SBQQ__Quote__c();
        qtObj.SBQQ__Account__c=acct.Id;
        qtObj.SBQQ__Status__c='Draft';
        qtObj.SBQQ__Type__c='Quote';
        qtObj.SBQQ__StartDate__c=date.today();
        qtObj.Alternate_Currency2__c='EUR';
        qtObj.SBQQ__Opportunity2__c =oppty.Id;
        insert qtObj;
        ContentDocumentLink cDocLinkQ = new ContentDocumentLink();
        cDocLinkQ.ContentDocumentId = conDocument;//Add ContentDocumentId
        cDocLinkQ.LinkedEntityId = qtObj.Id;//Add attachment parentId
        cDocLinkQ.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
        cDocLinkQ.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
        insert cDocLinkQ;
        PageReference pRef = Page.sendInvoice;
        pRef.getParameters().put('quoteId', qtObj.Id);
        Test.setCurrentPage(pRef);
        
        Test.startTest();
        SendInvoiceController pc = new SendInvoiceController();
        pc.sendObcLink ='1';
        pc.toAddressesE='test@test.com';
        pc.ccAddressesE='test@test.com';
        pc.subject='testest';
        pc.emailBody='testbodysdfsdfsdfsd';
        pc.sendContractMethod();
        pc.fileName = 'testsnam';
        pc.upload();
        pc.reDirectToSSC();
        Test.stopTest();
    }
}