/**
 * Created By: Palla Kishore(Girikon)
 * Created On:          06/06/2022
 * Description/Purpose: This test class covers the apex class : MassManualReminderEmailHandler
 * Methods:             MassManualReminderEmailHandler_DataInsert
 * Apex Class:          MassManualReminderEmailHandler
**/
@isTest
public class MassManualReminderEmailHandler_Test {
	@isTest
    public static void MassManualReminderEmailHandler_DataInsert(){
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
                    
            Manual__c m= new Manual__c();
                m.Name='Manual';
                m.Event_Edition__c=eve.id;        
            insert m;
                    
            Manuals_Permission__c per = new Manuals_Permission__c();
                per.Manuals__c=m.id;
            insert per;
            
            User_Manual_Action__c uAManual= new User_Manual_Action__c();
                uAManual.Manual_Permission__c= per.id;
                uAManual.User_Manual_Contact__c =cont.id;
                uAManual.Account__c = acc.Id;
            insert uAManual;
            
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
                testET.Template_Code__c = 'MAMSRM';
                testET.Content__c = 'testContent';
                testET.Subject__c = 'Test Template';
                testET.CurrencyIsoCode = eventCurrency.Name;
                insert testET;
            
            Event_Edition_Email_Template__c testEEET = new Event_Edition_Email_Template__c();
                testEEET.Event_Edition__c = eve.id;
                testEEET.Subject__c = 'Test Template';
                testEEET.Email_Template__c = testET.id;
                testEEET.Email_Template_Code__c = 'MAMSRM';
                testEEET.Content__c = 'test email template';
                insert testEEET;
                
            List<String> cList= new  List<String>();
            cList.Add(String.valueOf(uAManual.id));
            string uMAList=System.JSON.serialize(cList);
           MassManualReminderEmailHandler.MassManualReminderEmail(eve.Id, uMAList);
    }
}