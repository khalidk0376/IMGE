/**
 * Created By: Girikon(Archit)
 * Created On:   07/14/2017 
 * Modified by :  
 * Modified On: 
 * Description/Purpose: This test class covers the apex class : ParsePlaceholders
 * Apex Class: ParsePlaceholders
**/

@isTest
public class ParsePlaceholders_Test {
    public static testMethod void ParsePlaceholders_DataInsert()
    {
        // Setup test data
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser11@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing11', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduserAbraham1@testorg.com');
            Event_Edition__c OEve;
            Account acc1;
        System.runAs(u) 
        {
            // The following code runs as user 'u' 
            
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId());
            
            
            acc1 = new Account();
            acc1.Name='acc1';
            acc1.BillingCountry='USA';
            acc1.BillingState='Texas';
            acc1.BillingStreet='water well street';              
            insert acc1;
            Contact con = new Contact(LastName='User',FirstName ='Test',AccountId=acc1.id);
            insert con;
            
            OEve = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today());
            insert OEve;
            System.assertEquals(OEve.Event_Code__c,'WOC17', 'Event Code');
            EventCurrecies__c eventCurrency = new EventCurrecies__c (Name='USD',Event_Edition__c=OEve.id);
            insert eventCurrency;
            System.assertEquals(eventCurrency.Name,'USD', 'Event Currency');
            OEve.EventCurrency__c = eventCurrency.id;
            update OEve;
            System.assert(OEve.EventCurrency__c != null, 'Event Currency');
            
        }
        Test.startTest();
        String content = 'Hello,  {user.Name}  {Event_Edition__c.Name}';
            ParsePlaceholders.renderTemplate(content,OEve.Id);
            ParsePlaceholders.renderTemplate(content,OEve.Id,OEve.Id);
        Test.stopTest();
    }
}