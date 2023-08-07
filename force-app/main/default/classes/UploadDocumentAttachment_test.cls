@isTest
public class UploadDocumentAttachment_test {

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
        
        UploadDocumentAttachment_class.getAttachments(opp.Id,1,1);
        UploadDocumentAttachment_class.getAttachmentDel(conDocument);
        UploadDocumentAttachment_class.getAttachmentView('TestAttachment');
        UploadDocumentAttachment_class.getProfileName();
      //  UploadDocumentAttachment_class.getOppAttachments(opp.Id);
    }
    
    public static testMethod void getProfileNameTest(){
        
        AllowedProfilesToDeleteUploadedDocuments__c ap = new AllowedProfilesToDeleteUploadedDocuments__c(Name = 'Sales');
        insert ap;
        
        User u = new User(
            ProfileId = [SELECT Id FROM Profile where Name = 'Sales' LIMIT 1].Id,
            LastName = 'last',
            Email = 'testuser@DeclarationDocTest.com',
            Username = 'testuser@DeclarationDocTest.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert u;
        System.runAs(u){
            Map<String, Object> resultMap = UploadDocumentAttachment_class.getProfileName();
            System.assertEquals(True, resultMap.get('profile'),'Expected value is not matching the result');
        }
    }
}