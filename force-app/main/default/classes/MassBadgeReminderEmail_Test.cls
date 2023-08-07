/**
 * Created/Modified By  : Girikon(Aishwarya)
 * Created On           : 09/26/2018
 * @description         : This test class covers the apex class : MassBadgeReminderEmail
 * Methods              : massBadgeReminderEmailDataInsert
 * Apex Class           : MassBadgeReminderEmail, MassBadgeReminderEmailBatch
**/

@isTest
public class MassBadgeReminderEmail_Test
{
    public static testMethod void massBadgeReminderEmailDataInsert()
    {
        Event_Edition__c eve;
        eve= new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today());
        insert eve; 
        
        Account acc = new account(Name='TestLName');
        insert acc;
        System.AssertNotEquals(acc, null,'Account should not be null');
        
        Contact cont = new Contact();
        cont.LastName='Sam';
        cont.Email='test@test.com';
        cont.AccountId = acc.Id;
        insert cont;  
        
        User_Type__c uType = new User_Type__c(Name ='Exhibitor');
        insert uType;
        
        ContactEventEditionMapping__c cEEM = new ContactEventEditionMapping__c();
        cEEM.SFEventEditionID__c = eve.Id;
        cEEM.SFContactID__c = cont.Id; 
        cEEM.User_Type__c = uType.Id;
        cEEM.IsEmailSent__c = True;
        
        Test.StartTest();
        insert cEEM;
        
            EventCurrecies__c eventCurrency = new EventCurrecies__c (Name='USD',Event_Edition__c=eve.id);
                insert eventCurrency;
                System.assertEquals(eventCurrency.Name,'USD', 'Event Currency');
                eve.EventCurrency__c = eventCurrency.id;
                eve.CurrencyIsoCode = eventCurrency.Name;
                update eve;
                //System.assert(eve.EventCurrency__c != null, 'Event Currency');
                System.assertNotEquals(eve.EventCurrency__c,null,'Event Currency not equal null');
            
             Email_Templates__c testET = new Email_Templates__c();
                testET.name = 'test email template';
                testET.Template_Code__c = 'BADGEMRM';
                testET.Content__c = 'testContent';
                testET.Subject__c = 'Test Template';
                testET.CurrencyIsoCode = eventCurrency.Name;
                insert testET;
            
            Event_Edition_Email_Template__c testEEET = new Event_Edition_Email_Template__c();
                testEEET.Event_Edition__c = eve.id;
                testEEET.Subject__c = 'Test Template';
                testEEET.Email_Template__c = testET.id;
                testEEET.Email_Template_Code__c = 'BADGEMRM';
                testEEET.Content__c = 'test email template';
                insert testEEET;
                
            List<String> accList= new  List<String>();
            accList.Add(String.valueOf(acc.id));
            string accntIDs=System.JSON.serialize(accList);
            MassBadgeReminderEmail.massBadgeReminderNotification(String.valueOf(eve.id), accntIDs);
        Test.StopTest();                       
    }
}