/**
* Project:         GAP
* Date:            27/12/2018
* Test Class For Trigger:EmailMessagingContact   
* Code Coverage:   
* Created By:      Rajesh Kumarmar Yadav
* Modified Date:   27/12/2018
* Modified By:     Rajesh Kumar Yadav
* *************************************************************************
* @Description     This test class covers "EmailMessagingContact " trigger.
* *************************************************************************
* History: 
*/
@isTest
public class EmailMessagingContact_Test{
    @isTest static void emailMessagingContactMethodOne() { 
        /**
        * mapOfEmailMessageAttmntId
        * @description apex variable
        */
        Map<Id, Id> mapOfEmailMessageAttmntId = new Map<Id, Id>();
        
        /* Insert Account Object Test Data  */
        Account oAccount = new Account();
        oAccount.Name = 'Testing Account'; 
        oAccount.CurrencyIsoCode = 'USD';
        insert oAccount;
        System.assertEquals('Testing Account', oAccount.name , 'Account must not be null');
        
        /* Insert EmailMessage Contact Test Data  */
        Contact ocontact = new Contact();
        ocontact.FirstName = 'Testing First Name';
        ocontact.LastName = 'Testing Last Name';
        ocontact.Email = 'test.test@gmail.com';
        ocontact.AccountId = oAccount.Id;
        insert ocontact;
        
        /* Insert Case Object Test Data  */
        Case oCase = new Case();
        oCase.Subject= 'testsubject';
        oCase.AccountId=oAccount.id; 
        oCase.ContactId=ocontact.id;
        insert oCase;
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
        cDocLink.LinkedEntityId = oCase.id;//Add attachment parentId
        cDocLink.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
        cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
        insert cDocLink;
        
        /* Insert EmailMessage Object Test Data  */
        EmailMessage oEmailMessage = new EmailMessage();
        oEmailMessage.BccAddress ='TestData@gmail.com';
        oEmailMessage.CcAddress ='TestData@gmail.com';
        oEmailMessage.FromAddress = 'TestData@gmail.com';
        oEmailMessage.FromName ='Test';
        oEmailMessage.Subject = 'Hello Every One';
        oEmailMessage.TextBody ='Please Test';
        oEmailMessage.ToAddress ='TestData@gmail.com';
        oEmailMessage.attachmentId__c = conDocument;
        oEmailMessage.parentid = oCase.id;
        insert oEmailMessage;
        
        mapOfEmailMessageAttmntId.put(oEmailMessage.attachmentId__c,oEmailMessage.Id);
    }
}