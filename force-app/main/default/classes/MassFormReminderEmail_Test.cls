/**
 * Created/Modified By: Girikon(Archit)
 * Created On:          12/21/2017
 * Description/Purpose: This test class covers the apex class : MassFormReminderEmail
 * Methods:             MassFormReminderEmail_DataInsert
 * Apex Class:          MassFormReminderEmail, MassFormReminderEmailBatch, MassFormReminderEmailHandler
**/
//Ticket No. BK-14521 Updating API Version
@isTest
public class MassFormReminderEmail_Test
{
    public static testMethod void MassFormReminderEmail_DataInsert()
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
        
        User_Type__c uType = new User_Type__c(Name ='Agent');
        insert uType;
        
        Form__c f= new Form__c();
            f.Name='Form';
            f.Form__c=10;
        insert f;
        
        Event_Edition_Form__c eForm= new Event_Edition_Form__c();
            eForm.Name='TestForm';
            eForm.Forms__c=f.id;
            eForm.Event_Edition__c = eve.Id;
        insert eForm;
        
        Forms_Permission__c per = new Forms_Permission__c();
            per.Event_Edition_Form__c=eForm.id;
        insert per;
        
        User_Form_Action__c uAForm= new User_Form_Action__c();
            uAForm.Form_Permission__c= per.id;
            uAForm.User_Form_Contact__c =cont.id;
            uAForm.Account__c = acc.Id;
        insert uAForm;
        
        ContactEventEditionMapping__c cEEM = new ContactEventEditionMapping__c();
        cEEM.SFEventEditionID__c = eve.Id;
        cEEM.SFContactID__c = cont.Id; 
        cEEM.User_Type__c = uType.Id;
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
            testET.Template_Code__c = 'FOMSRM';
            testET.Content__c = 'testContent';
            testET.Subject__c = 'Test Template';
            testET.CurrencyIsoCode = eventCurrency.Name;
            insert testET;
        
        Event_Edition_Email_Template__c testEEET = new Event_Edition_Email_Template__c();
            testEEET.Event_Edition__c = eve.id;
            testEEET.Subject__c = 'Test Template';
            testEEET.Email_Template__c = testET.id;
            testEEET.Email_Template_Code__c = 'FOMSRM';
            testEEET.Content__c = 'test email template';
            insert testEEET;
            
        List<String> cList= new  List<String>();
        cList.Add(String.valueOf(uAForm.id));
        string contIDs=System.JSON.serialize(cList);
        //MassFormReminderEmail.MassFormReminderEmail(String.valueOf(eve.id),contIDs);
        MassFormReminderEmail.massFormEmailNotification(String.valueOf(eve.id));                       
    }
}