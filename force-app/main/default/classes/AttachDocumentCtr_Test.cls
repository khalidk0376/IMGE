/**
* Created By:  Girikon (Divaker)
* Date :            6/11/2018
* Class :      AttachDocumentCtr, AttachDocumentCtr_Test
* *************************************************************************
*/
@isTest
public class AttachDocumentCtr_Test{
    static testMethod void attachmentTestMethod(){

        User_Type__c uType = new User_Type__c(Name ='Exhibitor');
        insert uType;
        System.AssertEquals(uType.Name, 'Exhibitor','User Type should be an Exhibitor');

        account acc = new account(Name='TestLName');
        insert acc;
        System.AssertNotEquals(acc, null,'account should not be null');

        Contact con = new Contact(LastName='User',FirstName ='Test',email='test1@test.com', Type__c=uType.Id,AccountId = acc.id);
        insert con;
        System.AssertNotEquals(con, null,'Contact should not be null');

        Contact conde = new Contact(LastName='Userde',FirstName ='Testde',email='testde1@test.com', Type__c=uType.Id,AccountId = acc.id);
        insert conde;
        System.AssertNotEquals(conde, null,'Contact should not be null');

        Event_Edition__c eventEditon = new Event_Edition__c(Name='TOC Europe 2018',Event_Code__c='18toce',End_Date__c=System.Today(),Start_Date__c=System.Today(),Event_Currency__c='INR');
        insert eventEditon;

        Event_Settings__c oEventSett = new Event_Settings__c(Co_Exhibitor_Badge_Limit__c='7', Agent_Badge_limit__c='10',Is_Event_Edition_Live__c=false,Send_Welcome_Email__c=true,Event_Edition__c=eventEditon.id);
        insert oEventSett;

        ContactEventEditionMapping__c conevmap = new ContactEventEditionMapping__c(SFContactID__c=con.id,SFEventEditionID__c=eventEditon.id, User_Type__c=uType.Id);
        insert conevmap;

        ContactEventEditionMapping__c conevmapde = new ContactEventEditionMapping__c(SFContactID__c=conde.id,SFEventEditionID__c=eventEditon.id, User_Type__c=uType.Id);
        insert conevmapde;
        
        attachment attach = new attachment();
        attach.Name='Unit Test Attachment.pdf';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.ContentType='application/pdf';
        attach.parentId=oEventSett.id;
        insert attach;
            System.assertEquals(attach.parentId, oEventSett.id,'Parent is Event Edition');
        
        test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='Customer Community Login User Custom']; 
        User u = new User(Alias = 'standt', Email='standarduserCust@testorgtest.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, ContactId=con.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='standardusertestCust@testorg.com');
        Insert u;

        User udeactive = new User(Alias = 'standtde', Email='standarduserCustde@testorgtest.com', 
            EmailEncodingKey='UTF-8', LastName='Testingde', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, ContactId=conde.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='standardusertestCustde@testorg.com');
        Insert udeactive;
        udeactive.isActive=true;
        //update udeactive;

        string folderId = [select id from folder where name = 'Images'].id;
        Blob b3 = Blob.valueOf('Test Data record');
        ContentVersion cVersion = new ContentVersion();
        cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
        cVersion.PathOnClient = 'Complete.pdf';//File name with extention
        cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
        cVersion.OwnerId = userinfo.getUserId();//Owner of the file
        cVersion.Title ='Completed Test Signed Files for Parent Manual';//Name of the file
        cVersion.VersionData = b3;//File content
        insert cVersion;
        Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
        cDocLink.LinkedEntityId =  oEventSett.Id;//Add Files parentId
        cDocLink.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
        cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
        insert cDocLink; 
        AttachDocumentCtr oAttach = new AttachDocumentCtr();
        AttachDocumentCtr.AttachDocumentCtr(attach.Id, folderId , oEventSett.Id);

        oEventSett.Is_Event_Edition_Live__c=true;
        oEventSett.Agent_Badge_limit__c = '14';
        oEventSett.Co_Exhibitor_Badge_Limit__c ='16';
        update oEventSett;
        test.stopTest();
    }
}