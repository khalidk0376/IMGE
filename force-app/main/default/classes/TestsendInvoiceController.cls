/**
 * File:        TestsendInvoiceController .cls
 * Project:     GAP
 * Date:        17/10/2017
 * Created By:  Abdul Kadir
 * *************************************************************************
 * Description: test class for SendInvoiceController.cls.
 * *************************************************************************
 * History: Last Modified By :   [Aishwarya BK-3759 27 Aug 2020]
 */
@isTest
public class TestsendInvoiceController {
     public static testmethod void emailTest(){
         
        Folder insrtFldr = [Select Id From Folder where developername ='Conga_preview_Documents' LIMIT 1]; 
        Document doc1 = new Document(name='EmailTemplateFooter_Logo',folderId=insrtFldr.id);
        insert doc1;
        Document doc2 = new Document(name='EmailTemplateHeader_Logo',folderId=insrtFldr.id);
        insert doc2;        
       
      Account acct=new Account(Name='testAccount',CurrencyIsoCode='EUR');
        insert acct;
        System.assertEquals('testAccount',acct.name,'Account Not Created');
      Blob b3 = Blob.valueOf('Test Data record');
      ContentVersion cVersion = new ContentVersion();
      cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
      cVersion.PathOnClient = 'Completed Test Signed Attachment for Parent Manual.pdf';//File name with extention
      cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
      cVersion.OwnerId = userinfo.getUserId();//Owner of the file
      cVersion.Title ='Completed Test Signed Attachment for Parent Manual';//Name of the file
      cVersion.VersionData = b3;//File content
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
        oppty.StageName='Needs Assessment';
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
      Blob b4 = Blob.valueOf('Test Data record');
      ContentVersion cVersion1 = new ContentVersion();
      cVersion1.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
      cVersion1.PathOnClient = 'Completed Test Signed Attachment for Parent Manual.pdf';//File name with extention
      cVersion1.Origin = 'H';//C-Content Origin. H-Chatter Origin.
      cVersion1.OwnerId = userinfo.getUserId();//Owner of the file
      cVersion1.Title ='Completed Test Signed Attachment for Parent Manual';//Name of the file
      cVersion1.VersionData = b3;//File content
      insert cVersion1;
      Id conDocument1 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
      ContentDocumentLink cDocLink1 = new ContentDocumentLink();
      cDocLink1.ContentDocumentId = conDocument1;//Add ContentDocumentId
      cDocLink1.LinkedEntityId = qtObj.Id;//Add attachment parentId
      cDocLink1.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
      cDocLink1.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
      insert cDocLink1;
     
       PageReference pRef = Page.sendInvoice;
       pRef.getParameters().put('quoteId', qtObj.Id);
      
        Test.setCurrentPage(pRef);
         
        Test.startTest();
        SendInvoiceController pc = new SendInvoiceController();
        pc.toAddressesE='test@test.com';
        pc.ccAddressesE='test@test.com';
        pc.subject='testest';
        pc.emailBody='testbodysdfsdfsdfsd';
        pc.sendContractMethod();
        pc.sendInvoiceMethod();
         pc.cancel();
         pc.upload();
         pc.redirectToSSC();
         pc.sendOBCLinkMethod();
        Test.stopTest();
         
     }     
    
     public static testmethod void emailTest1(){
         
        Folder insrtFldr = [Select Id From Folder where developername ='Conga_preview_Documents' LIMIT 1];
        Document doc1 = new Document(name='EmailTemplateFooter_Logo',folderId=insrtFldr.id);
        insert doc1;
        Document doc2 = new Document(name='EmailTemplateHeader_Logo',folderId=insrtFldr.id);
        insert doc2;        
        
      Account acct=new Account(Name='testAccount',CurrencyIsoCode='EUR');
        insert acct;
        System.assertEquals('testAccount',acct.name,'Account Not Created');
        Blob b3 = Blob.valueOf('Test Data record');
        ContentVersion cVersion = new ContentVersion();
        cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
        cVersion.PathOnClient = 'Completed Test Signed Attachment for Parent Manual.pdf';//File name with extention
        cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
        cVersion.OwnerId = userinfo.getUserId();//Owner of the file
        cVersion.Title ='Completed Test Signed Attachment for Parent Manual';//Name of the file
        cVersion.VersionData = b3;//File content
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
        oppty.StageName='Needs Assessment';
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
        
        Blob b4 = Blob.valueOf('Test Data record');
        ContentVersion cVersion1 = new ContentVersion();
        cVersion1.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
        cVersion1.PathOnClient = 'Completed Test Signed Attachment for Parent Manual.pdf';//File name with extention
        cVersion1.Origin = 'H';//C-Content Origin. H-Chatter Origin.
        cVersion1.OwnerId = userinfo.getUserId();//Owner of the file
        cVersion1.Title ='Completed Test Signed Attachment for Parent Manual';//Name of the file
        cVersion1.VersionData = b3;//File content
        insert cVersion1;
        Id conDocument1 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion1.Id].ContentDocumentId;
        ContentDocumentLink cDocLink1 = new ContentDocumentLink();
        cDocLink1.ContentDocumentId = conDocument1;//Add ContentDocumentId
        cDocLink1.LinkedEntityId = qtObj.Id;//Add attachment parentId
        cDocLink1.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
        cDocLink1.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
        insert cDocLink1;
         
       PageReference pRef = Page.sendInvoice;
       pRef.getParameters().put('retURL', oppty.Id);
       pRef.getParameters().put('sendObcLink','1');
       Test.setCurrentPage(pRef);
        Test.startTest();
        SendInvoiceController pc = new SendInvoiceController();
        pc.toAddressesE='test@test.com';
        pc.ccAddressesE='test@test.com';
        pc.subject='testest';
        pc.emailBody='testbodysdfsdfsdfsd';
        pc.sendContractMethod();
        pc.sendInvoiceMethod();
        pc.cancel();
        pc.upload();
        pc.redirectToSSC();
        pc.sendOBCLinkMethod();
        Test.stopTest();
         
     }
     
    public static testmethod void emailTest2(){
         
        Folder insrtFldr = [Select Id From Folder where developername ='Conga_preview_Documents' LIMIT 1];
          Document doc1 = new Document(name='EmailTemplateFooter_Logo',folderId=insrtFldr.id);
        insert doc1;
        Document doc2 = new Document(name='EmailTemplateHeader_Logo',folderId=insrtFldr.id);
        insert doc2;  

        Account acct=new Account(Name='testAccount',CurrencyIsoCode='EUR');
        insert acct; 
        System.assertEquals('testAccount',acct.name,'Account Not Created'); 

        Blob b5 = Blob.valueOf('Test Data record');
        ContentVersion cVersion1 = new ContentVersion();
        cVersion1.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
        cVersion1.PathOnClient = 'Completed Test Signed Attachment for Parent Manual.pdf';//File name with extention
        cVersion1.Origin = 'H';//C-Content Origin. H-Chatter Origin.
        cVersion1.OwnerId = userinfo.getUserId();//Owner of the file
        cVersion1.Title ='Completed Test Signed Attachment for Parent Manual';//Name of the file
        cVersion1.VersionData = b5;//File content
        insert cVersion1;
        Id conDocument1 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion1.Id].ContentDocumentId;
        ContentDocumentLink cDocLink1 = new ContentDocumentLink();
        cDocLink1.ContentDocumentId = conDocument1;//Add ContentDocumentId
        cDocLink1.LinkedEntityId = acct.Id;//Add attachment parentId
        cDocLink1.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
        cDocLink1.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
        insert cDocLink1;
        
        
        contact con=new Contact();
        con.firstname='test';
        con.lastname='test2';
        con.email='test@test.com';
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
        oppty.StageName='Needs Assessment';
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
        
        blng__Invoice__c objInvoice = new blng__Invoice__c();
        objInvoice.blng__Account__c = acct.Id;
        insert objInvoice;
        
        Blob b4 = Blob.valueOf('Test Data record');
        ContentVersion cVersion = new ContentVersion();
        cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
        cVersion.PathOnClient = 'Completed Test Signed Attachment for Parent Manual.pdf';//File name with extention
        cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
        cVersion.OwnerId = userinfo.getUserId();//Owner of the file
        cVersion.Title ='Completed Test Signed Attachment for Parent Manual';//Name of the file
        cVersion.VersionData = b4;//File content
        insert cVersion;
        Id conDocument12 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocument12;//Add ContentDocumentId
        cDocLink.LinkedEntityId = qtObj.Id;//Add attachment parentId
        cDocLink.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
        cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
        insert cDocLink;
        ContentDocumentLink cDocLink2 = new ContentDocumentLink();
        cDocLink2.ContentDocumentId = conDocument12;//Add ContentDocumentId
        cDocLink2.LinkedEntityId = objInvoice.Id;//Add attachment parentId
        cDocLink2.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
        cDocLink2.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
        insert cDocLink2;
    
       PageReference pRef = Page.sendInvoice;
       pRef.getParameters().put('id', objInvoice.Id);
       pRef.getParameters().put('sendObcLink','1');
       pRef.getParameters().put('retURL', con.Id);
     
        Test.setCurrentPage(pRef);
        Test.startTest();
        SendInvoiceController pc = new SendInvoiceController();
        pc.toAddressesE='test@test.com';
        pc.ccAddressesE='test@test.com';
        pc.subject='testest';
        pc.emailBody='testbodysdfsdfsdfsd';
        pc.sendContractMethod();
        pc.sendInvoiceMethod();
        pc.cancel();
        pc.upload();
        pc.redirectToSSC();
        pc.sendOBCLinkMethod();
        Test.stopTest();  
     }
}