/**
 * Created/Modified By: Girikon(Amish)
 * Created On:          8/31/2017 
 * Description/Purpose: This test class covers the apex class : SingleFormReminderEmail
 * Methods:             SingleFormReminderEmail_DataInsert
 * Apex Class:          SingleFormReminderEmail, SingleFormReminderEmailBatch, SingleFormReminderEmailHandler
**/
//Ticket No. BK-14521 Updating API Version
@isTest
public class SingleFormReminderEmail_Test
{
    public static testMethod void SingleFormReminderEmail_DataInsert()
    {
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
        
        Form__c f= new Form__c();
            f.Name='Form';
            f.Form__c=10;
        insert f;
        
        Event_Edition_Form__c eForm= new Event_Edition_Form__c();
            eForm.Name='TestForm';
            eForm.Forms__c=f.id;
        insert eForm;
        
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
            
        List<String> cList= new  List<String>();
        cList.Add(String.valueOf(cont.Accountid));
        string accIDs=System.JSON.serialize(cList);
        
         ContactEventEditionMapping__c cEEM = new ContactEventEditionMapping__c(SFEventEditionID__c=eve.Id, SFContactID__c=cont.Id);
         insert cEEM;
        
        SingleFormReminderEmail.reminderEmailNotification(String.valueOf(eve.id),accIDs,String.valueOf(eForm.id));
          
         // Setup test data
        // This code runs as the system user
       /* Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='usertest@test.com', 
            EmailEncodingKey='UTF-8', LastName='Kumar', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1@testorg.com');
            Event_Edition__c OEve;
        List <User_Form_Action__c> ufaList = new List<User_Form_Action__c >();
        System.runAs(u) 
        {
            // The following code runs as user 'u' 
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId());
           
            User_Type__c UType = new User_Type__c(Name ='Exhibitor');
            insert UType;
            User_Type__c UTypeAgent= new User_Type__c(Name ='Agent');
            insert UTypeAgent;
          
            Contact con = new Contact(LastName='User',FirstName ='Test', Type__c=UType.Id,Email='test@test.com' );
            insert con;
            
            OEve = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today());
            insert OEve;
            System.assertEquals(OEve.Event_Code__c,'WOC17', 'Event Code');
              
            skuid__Page__c skuidPage = new skuid__Page__c(Name ='Test',skuid__Type__c='Desktop',skuid__Module__c='Page Templates');
            insert skuidPage;
            System.assertEquals(skuidPage.skuid__Module__c,'Page Templates', 'Page Templates');
            Form__c oForm = new Form__c(SKUID_Template__c=skuidPage.id,Doc_Type__c='Online',Form__c=1,Deadline__c=System.Today());
            insert oForm;
            System.assertEquals(oForm.Doc_Type__c,'Online', 'Page Templates');
            Event_Edition_Form__c oEEForm = new Event_Edition_Form__c(Event_Edition__c = OEve.id,Forms__c =oForm.id);
            insert oEEForm;
            System.assertEquals(oEEForm.Event_Edition__c,OEve.id, 'Event Edition');
            Forms_Permission__c fPermission = new Forms_Permission__c(Event_Edition_Form__c = oEEForm.id, User_Type__c= UType.Id);
            insert fPermission;
            System.assert(fPermission != null, 'Forms_Permission successfully insert');
            Test.startTest();
            
                List <ContactEventEditionMapping__c> conList = new List<ContactEventEditionMapping__c >(); 
               
                ContactEventEditionMapping__c cEEM = new ContactEventEditionMapping__c(SFEventEditionID__c=OEve.Id, SFContactID__c=con.Id);
                conList.Add(cEEM);
                ContactEventEditionMapping__c cEEM2 = new ContactEventEditionMapping__c(SFEventEditionID__c=OEve.Id, SFContactID__c=con.Id);
                conList.Add(cEEM2);
                insert conList;
                system.debug('conList===='+conList);
                System.assert(conList != null, 'conList');
                
                
                for(Integer i=0;i<conList.size();i++){
                    system.debug('conList===='+conList);
                
                    User_Form_Action__c UFAction = new User_Form_Action__c(name='Test',Form_Permission__c =fPermission.id, User_Form_Contact__c =conList[i].SFContactID__c);
                    ufaList.Add(UFAction);
                }
                
                system.debug('ufaList===='+ufaList);
                insert ufaList;
                System.assert(ufaList!= null, 'conList');
            Test.stopTest();
          
        }
        System.assert(ufaList[0].Id != null, 'Successfully Insert User Form Action.');*/
       // BadgesReminderEmail.BadgesReminderEmail(ufaList[0].Id,'Exhibitor');
        
    }
}