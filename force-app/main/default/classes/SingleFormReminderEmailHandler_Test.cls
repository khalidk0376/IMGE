/**
 * Created By: Palla Kishore(Girikon)
 * Created On:          06/06/2022
 * Description/Purpose: This test class covers the apex class : SingleFormReminderEmailHandler
 * Methods:             SingleFormReminderEmailHandler_DataInsert
 * Apex Class:          SingleFormReminderEmailHandler
**/
@isTest
public class SingleFormReminderEmailHandler_Test {
    @isTest
    public static void SingleFormReminderEmailHandler_DataInsert(){
        List<String> contList = new List<String>();
        Event_Edition__c eve;
        eve= new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today());
        insert eve; 
        Account acc = new account(Name='Test Account');
        insert acc;
        
        Contact cont = new Contact();
        cont.LastName='Sam';
        cont.Email='test@test.com';
        cont.Accountid=acc.Id;
        insert cont;
        contList.add(cont.Id);
        Contact cont2 = new Contact();
        cont2.LastName='Sam';
        cont2.Email='test@test.com';
        cont2.Accountid=acc.Id;
        insert cont2;
        contList.add(cont2.Id);
        
        Form__c f= new Form__c();
        f.Name='Form';
        f.Form__c=10;
        insert f;
        EventCurrecies__c eventCurrency = new EventCurrecies__c (Name='USD',Event_Edition__c=eve.id);
        insert eventCurrency;
        System.assertEquals(eventCurrency.Name,'USD', 'Event Currency');
        eve.EventCurrency__c = eventCurrency.id;
        eve.CurrencyIsoCode = eventCurrency.Name;
        update eve;
        System.assert(eve.EventCurrency__c != null, 'Event Currency');
        Email_Templates__c testET = new Email_Templates__c();
        testET.name = 'test email template';
        testET.Template_Code__c = 'FOSIRM';
        testET.Content__c = 'testContent';
        testET.Subject__c = 'Test Template';
        testET.CurrencyIsoCode = eventCurrency.Name;
        insert testET;
        
        Event_Edition_Email_Template__c testEEET = new Event_Edition_Email_Template__c();
        testEEET.Event_Edition__c = eve.id;
        testEEET.Subject__c = 'Test Template';
        testEEET.Email_Template__c = testET.id;
        testEEET.Email_Template_Code__c = 'FOSIRM';
        testEEET.Content__c = 'test email template';
        insert testEEET;
        
        
        Event_Edition_Form__c eForm= new Event_Edition_Form__c();
        eForm.Name='TestForm';
        eForm.Forms__c=f.id;
        insert eForm;
        
        string conId = JSON.serialize(contList);
        SingleFormReminderEmailHandler.SingleFormReminderEmail(eve.Id, conId, eForm.Id);
        
    }
}