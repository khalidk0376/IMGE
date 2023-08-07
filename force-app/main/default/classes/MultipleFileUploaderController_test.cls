/**********************************
Created By   :  Palla Kishore
Created Date :  22nd Aug 2022
Name         :  MultipleFileUploaderController
Description  :  Test Class to MultipleFileUploaderController  
Code Coverage:  93%

Modified by Faisal Khan 
/* BK-22967 By Faisal Khan on 01-09-2022 
 Code Coverage:  94%
**********************************/

@isTest
public class MultipleFileUploaderController_test {
    static testMethod void declarationDocAttachmentclMethodOne() {
        
        //@Description: Insert Account.
        Account acc = new Account();
        acc.Name = 'Testing Account'; 
        acc.CurrencyIsoCode = 'USD';
        insert acc;
        System.assertEquals('Testing Account',acc.name,'Error account is not created');
        
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
        //eventEdition.Event_Edition_Status__c = 'Active';
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
        Blob b3 = Blob.valueOf('Test Data record');
        ContentVersion cVersion = new ContentVersion();
        cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
        cVersion.PathOnClient = 'Completed Test Signed Attachment for Parent Manual.pdf';//File name with extention
        cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
        cVersion.OwnerId = userinfo.getUserId();//Owner of the file
        cVersion.Title ='Document_Test_20-08-2022';//Name of the file
        cVersion.VersionData = b3;//File content
        insert cVersion;
        Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
        cDocLink.LinkedEntityId = opp.Id;//Add attachment parentId
        cDocLink.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
        cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
        insert cDocLink;
        List<string> cdList = new List<string>();
        cdList.add(conDocument);
      	String jsonString = JSON.serialize(cdList);
        MultipleFileUploaderController.getAllFilesOnsObjectRecord(opp.Id);
        MultipleFileUploaderController.getCurrentUserName();
        MultipleFileUploaderController.getAccountName(opp.id);
        
        MultipleFileUploaderController.updateCurrentDoc(conDocument, 'Test');
        MultipleFileUploaderController.deleteFiles(jsonString);
    }
    
    
}