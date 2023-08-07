/**
* Project:         GAP
* Created Date:    14th March 2019
* Test Class For:  UploadDeclarationDocumentCtrl.cls
* Code Coverage:   
* Created By:      Yash Gupta
* *************************************************************************
* @Description     Test class for UploadDeclarationDocumentCtrl Class.
* *************************************************************************
* History:
*/
@isTest
public class UploadDeclarationDocumentCtrlTest {
    static testMethod void uploadDeclarationDocumentCtrlTestMethod() {
        //@Description: Insert Account.
        Account acc = new Account();
        acc.Name = 'Testing Account'; 
        acc.CurrencyIsoCode = 'USD';
        insert acc;
        System.assertEquals('Testing Account', acc.name,'Error Account is not created');
        
        //@Description: Insert Contact.
        Contact ocontact = new Contact();
        ocontact.FirstName = 'Testing First Name';
        ocontact.LastName = 'Testing Last Name';
        ocontact.Email = 'test.test@gmail.com';
        ocontact.AccountId = acc.Id;
        insert ocontact;
        
        //@Description: Insert Event Edition.
        Event_Edition__c eventEdition = new Event_Edition__c();
        eventEdition.Name = 'Testing Event Edition';
        eventEdition.Tab1__c = 'Tab1';
        eventEdition.Tab4__c = 'Tab4';
        eventEdition.Tab8__c = 'Tab8';
        insert eventEdition;
        
        //@Description: Insert Opportunity.
        Opportunity opp = new Opportunity();
        opp.Name = 'Testing Opportunity';
        opp.EventEdition__c = eventEdition.Id;
        opp.Opportunity_Contact__c = ocontact.Id;
        opp.AccountId = acc.Id;
        opp.CloseDate = Date.Today().addDays(1);
        opp.StageName = 'Customise';
        insert opp;
        
        Blob b = Blob.valueOf('Test Data');
        Attachment attachment = new Attachment();
        attachment.ParentId = opp.Id;
        attachment.Name = 'Test Attachment for Parent';
        attachment.Body = b;
        insert attachment;
        
        //opp.Tax_Rule_SAP__c = 'UAE VAT Refund';
        //update opp;  
        PageReference pg = Page.Upload_Declaration_Document;
        pg.getParameters( ).put( 'oppid', opp.Id);
        test.setCurrentPageReference( pg );
        
        UploadDeclarationDocumentCtrl updDec = new UploadDeclarationDocumentCtrl();
        updDec.oAtachment= attachment;
        updDec.fileName = attachment.Name;
        updDec.fileContentType = '.pdf';
        
        ContentVersion content=new ContentVersion(); 
        content.Title='Header_Picture1'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob;
        content.origin = 'H';
        insert content;
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId= opp.id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
        
        updDec.uploadDoc();
        updDec.cancel();
        
    }
}