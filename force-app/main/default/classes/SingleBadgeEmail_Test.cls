/**
 * Created/Modified By: Girikon(Archit)
 * Created On:          8/1/2017
 * Description/Purpose: This test class covers the apex class : SingleBadgeEmail
 * Methods:             SingleBadgeEmail_DataInsert
 * Apex Class:          SingleBadgeEmail
**/

@isTest
public class SingleBadgeEmail_Test {
    public static testMethod void SingleBadgeEmail_DataInsert()
    {
        
         // Setup test data
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser11@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing11', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduserkavin1@testorg.com');
        insert u;
         System.runAs(u) 
        {
            Contact con = new Contact();
            con.LastName = 'testLastName';
            con.FirstName = 'testFirstName';
            con.Email = 'test@gmail.com';
            con.Phone = '2012012012';
            insert con;
            
            Event_Edition__c OEve = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today());
            insert OEve;
            System.assertEquals(OEve.Event_Code__c,'WOC17', 'Event Code');
            EventCurrecies__c eventCurrency = new EventCurrecies__c (Name='USD',Event_Edition__c=OEve.id);
            insert eventCurrency;
            System.assertEquals(eventCurrency.Name,'USD', 'Event Currency');
            OEve.EventCurrency__c = eventCurrency.id;
            oEve.CurrencyIsoCode = eventCurrency.Name;
            update OEve;
            System.assert(OEve.EventCurrency__c != null, 'Event Currency');
            
            Email_Templates__c testET = new Email_Templates__c();
            testET.name = 'test email template';
            testET.Template_Code__c = 'ORDINV';
            testET.Content__c = 'testContent';
            testET.Subject__c = 'Test Template';
            testET.CurrencyIsoCode = eventCurrency.Name;
            insert testET;
            
            Event_Edition_Email_Template__c testEEET = new Event_Edition_Email_Template__c();
            testEEET.Event_Edition__c = OEve.id;
            testEEET.Subject__c = 'Test Template';
            testEEET.Email_Template__c = testET.id;
            testEEET.Email_Template_Code__c = 'BDGAPR';
            testEEET.Content__c = 'test email template';
            insert testEEET;
            
            Event_Edition_Email_Template__c testEEET2 = new Event_Edition_Email_Template__c();
            testEEET2.Event_Edition__c = OEve.id;
            testEEET2.Subject__c = 'Test Template';
            testEEET2.Email_Template__c = testET.id;
            testEEET2.Email_Template_Code__c = 'BDGREJ';
            testEEET2.Content__c = 'test email template';
            insert testEEET2;
            
            ExpocadBooth__c testExpo = new ExpocadBooth__c();
            testExpo.User__c = u.id;
            insert testExpo;
            
            Test.startTest();
                SingleBadgeEmail.sendSingleBadgeEmail(OEve.id,con.id,testExpo.id,'Reject','test');
                SingleBadgeEmail.sendSingleBadgeEmail(OEve.id,con.id,testExpo.id,'Approve','test');
               /* boolean strJson = MassBadgeEmail.MassBadgeEmail(OEve.id,con.id,testExpo.id,'Reject','test');
                boolean strJson1 = MassBadgeEmail.MassBadgeEmail(OEve.id,con.id,testExpo.id,'Approve','test');*/
            Test.stopTest();
        }
    }
}