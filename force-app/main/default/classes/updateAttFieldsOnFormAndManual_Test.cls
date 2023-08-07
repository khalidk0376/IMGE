/**
 * Created/Modified By: Girikon(Bappi)
 * Created On:          6/6/2017
 * Description/Purpose: This test class covers the apex class : updateAttFieldsOnFormAndManual
 * Methods:             updateAttFieldsOnFormAndManual_DataInsert
 * Apex Class:          updateAttFieldsOnFormAndManual
**/

@isTest
private class updateAttFieldsOnFormAndManual_Test
{
    public static testMethod void updateAttFieldsOnFormAndManualDataInsert()
    {
        // Setup test data
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser11@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing11', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduserChris1@testorg.com');
            Event_Edition__c oEve;
            Manual__c oManual;
            Form__c oForm ;
            Id conDocument ;
            ContentVersion cVersion;
        System.runAs(u) {
            // The following code runs as user 'u' 
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId());
            Contact con = new Contact(LastName='User',FirstName ='Test');
            insert con;
            
            oEve = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today());
            insert oEve;
            System.assertEquals(oEve.Event_Code__c,'WOC17', 'Event Code');
            User_Type__c uType = new User_Type__c(Name ='Exhibitor');
            insert uType;
            
            
            oManual = new Manual__c(Section__c = 123, Name = 'Test Manual',Event_Edition__c=oEve.Id,User_Type__c='Exhibitor');
            insert oManual;
            System.assertEquals(oManual.Event_Edition__c,oEve.Id, 'Event Id');               
            Blob b3 = Blob.valueOf('Test Data record');
            cVersion = new ContentVersion();
            cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
            cVersion.PathOnClient = 'Unit Test files.pdf';//File name with extention
            cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
            cVersion.OwnerId = userinfo.getUserId();//Owner of the file
            cVersion.Title ='Unit Test files';//Name of the file
            cVersion.VersionData = b3;//File content
            insert cVersion;
            conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
            ContentDocumentLink cDocLink = new ContentDocumentLink();
            cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
            cDocLink.LinkedEntityId = oManual.id;//Add files parentId
            cDocLink.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
            cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
            insert cDocLink;
            System.assertEquals(cVersion.PathOnClient,'Unit Test files.pdf', 'checking pfd type');
   
            oForm = new Form__c(Doc_Type__c='Online',Form__c=1,Deadline__c=System.Today());
            insert oForm;
            ContentDocumentLink cDocLink1 = new ContentDocumentLink();
            cDocLink1.ContentDocumentId = conDocument;//Add ContentDocumentId
            cDocLink1.LinkedEntityId = oForm.id;//Add files parentId
            cDocLink1.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
            cDocLink1.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
            insert cDocLink1;
            //System.assertNotEquals(cVersion.PathOnClient,'Unit Test files.pdf', 'checking pfd Name');
        }
        
        
        updateAttFieldsOnFormAndManual.updateAttOnManual(oManual.id, conDocument, cVersion.PathOnClient);
        updateAttFieldsOnFormAndManual.updateAttOnForm(oForm.id, conDocument, cVersion.PathOnClient);
        updateAttFieldsOnFormAndManual.updateAndDeleteAttOnForm(oForm.id, conDocument, cVersion.PathOnClient );
        updateAttFieldsOnFormAndManual.updateAndDeleteAttOnManual(oManual.id, conDocument, cVersion.PathOnClient);
    }
    
}