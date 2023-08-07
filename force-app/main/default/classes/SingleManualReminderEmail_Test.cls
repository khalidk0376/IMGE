/**
 * Created/Modified By: Girikon(Amish)
 * Created On:          8/31/2017
 * Description/Purpose: This test class covers the apex class : SingleManualReminderEmail
 * Methods:             SingleManualReminderEmail_DataInsert
 * Apex Class:          SingleManualReminderEmail, SingleManualReminderEmailBatch, SingleManualReminderEmailHandler
**/
//Ticket No. BK-14521 Updating API Version
@isTest
public class SingleManualReminderEmail_Test
{
    public static testMethod void SingleManualReminderEmail_DataInsert()
    {
        Event_Edition__c eve;
            eve= new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today());
        insert eve; 
        Account acc = new account(Name='Test Account');
        insert acc;
        Contact cont = new Contact();
            cont .LastName='Sam';
            cont .Email='est@test.com';
        cont.AccountId=acc.Id;
        insert cont;  
        
        Manual__c m= new Manual__c();
            m.Name='Manual';
            m.Event_Edition__c=eve.id;        
        insert m;
             
        EventCurrecies__c eventCurrency = new EventCurrecies__c (Name='USD',Event_Edition__c=eve.id);
        insert eventCurrency;
        System.assertEquals(eventCurrency.Name,'USD', 'Event Currency');
        eve.EventCurrency__c = eventCurrency.id;
        eve.CurrencyIsoCode = eventCurrency.Name;
        update eve;
        System.assert(eve.EventCurrency__c != null, 'Event Currency');
        
        Email_Templates__c testET = new Email_Templates__c();
            testET.name = 'test email template';
            testET.Template_Code__c = 'MASIRM';
            testET.Content__c = 'testContent';
            testET.Subject__c = 'Test Template';
            testET.CurrencyIsoCode = eventCurrency.Name;
        insert testET;
        
        Event_Edition_Email_Template__c testEEET = new Event_Edition_Email_Template__c();
            testEEET.Event_Edition__c = eve.id;
            testEEET.Subject__c = 'Test Template';
            testEEET.Email_Template__c = testET.id;
            testEEET.Email_Template_Code__c = 'MASIRM';
            testEEET.Content__c = 'test email template';
        insert testEEET;
        
        List<String> cList= new  List<String>();
        cList.Add(String.valueOf(cont.Accountid));
        string accIDs=System.JSON.serialize(cList);
        
         ContactEventEditionMapping__c cEEM = new ContactEventEditionMapping__c(SFEventEditionID__c=eve.Id, SFContactID__c=cont.Id);
         insert cEEM;
        SingleManualReminderEmail.singleManualReminderNotification(String.valueOf(eve.id),accIDs,String.valueOf(m.id));                  
    }
}