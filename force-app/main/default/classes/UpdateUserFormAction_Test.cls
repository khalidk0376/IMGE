/**
 * Created/Modified By: Girikon(Bappi)
 * Created On:          5/26/2017
 * Description/Purpose: This test class covers the apex class : UpdateUserFormAction
 * Methods:             UpdateUserFormActionDataInsert
 * Apex Class:          UpdateUserFormAction
**/
 
@isTest
private class UpdateUserFormAction_Test
{
    public static testMethod void UpdateUserFormActionDataInsert()
    {
        // Setup test data
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser11@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing11', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduserUsa1@testorg.com');

        System.runAs(u) {
            // The following code runs as user 'u' 
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId());
            Contact con = new Contact(LastName='User',FirstName ='Test');
            insert con;
            
            User_Type__c UType = new User_Type__c(Name ='Exhibitor');
            insert UType;
            User_Type__c UTypeAgent= new User_Type__c(Name ='Agent');
            insert UTypeAgent;
            System.assertEquals(UTypeAgent.Name,'Agent', 'User_Type : Agent'); 
            Event_Edition__c OEve = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today());
            insert OEve;
            System.assertEquals(OEve.Event_Code__c,'WOC17', 'Event Code');
            System.assertNotEquals(UType.Name,'Agent', 'User_Type : Exhibitor');            
            Form__c oForm = new Form__c(Doc_Type__c='Online',Form__c=1,Deadline__c=System.Today());
            insert oForm;
            Event_Edition_Form__c oEEForm = new Event_Edition_Form__c(Event_Edition__c = OEve.id,Forms__c =oForm.id,User_Type__c= 'Exhibitor');
            insert oEEForm;
            System.assertEquals(UType.Name,'Exhibitor', 'Checking User Type:Exhibitor');
            Forms_Permission__c  FPermission = new  Forms_Permission__c(User_Type__c=UTypeAgent.id,Event_Edition_Form__c=oEEForm.id);
            insert FPermission;
            System.assertNotEquals(FPermission.User_Type__c,UType.id, 'Checking User Type');
   
            UpdateUserFormAction.updateUserFormAction(FPermission.id,con.id,u.id) ;
            
        }
           
    }
}