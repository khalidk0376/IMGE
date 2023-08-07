/**
 * Created/Modified By: Girikon(Amish)
 * Created On:          10/11/2017
 * Description/Purpose: This test class covers the apex class : FormAcceptEmail
 * Methods:             FormAcceptEmail_DataInsert 
 * Apex Class:          FormAcceptEmail
**/

@isTest
public class FormAcceptEmail_Test
{
    public static testMethod void FormAcceptEmail_DataInsert()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='kumarusertskndskndsk@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Kumar', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id,//contactID=con.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='kumarusertskndsknds12k@testorg.com');
        insert u;
        
        System.runAs(u) {
        Event_Edition__c OEve;
        User_Type__c UType = new User_Type__c(Name ='Exhibitor');
        insert UType;
        System.AssertEquals(UType.Name, 'Exhibitor','Not a Valid Usertype');
        
        Event_Edition__c eve;
        eve= new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today());
        insert eve; 
        
        account acc = new account(Name='TestLName');
        insert acc;
        System.AssertNotEquals(acc, null,'account should not be null');
        
        Contact cont = new Contact();
        cont.LastName='Sam';
        cont.Email='test@gmail.com';
        cont.AccountId = acc.id;
        insert cont;  
        
        Form__c f= new Form__c();
        f.Name='Form';
        f.Form__c=10;
        insert f;
        
        Event_Edition_Form__c eForm= new Event_Edition_Form__c();
        eForm.Name='TestForm';
        eForm.Forms__c=f.id;
        insert eForm;
        
        Forms_Permission__c per = new Forms_Permission__c();
        per.Event_Edition_Form__c=eForm.id;
        insert per;
        
        User_Form_Action__c uAForm= new User_Form_Action__c();
        uAForm.User_Form_Contact__c=cont.id;
        uAForm.Form_Permission__c= per.id;
        uAForm.Account__c=acc.id;
        uAForm.User_Type__c=UType.Id;
        uAForm.Status__c = 'Approved';
        insert uAForm;
        
        
        EventCurrecies__c eventCurrency = new EventCurrecies__c (Name='USD',Event_Edition__c=eve.id);
        insert eventCurrency;
        System.assertEquals(eventCurrency.Name,'USD', 'Event Currency');
        eve.EventCurrency__c = eventCurrency.id;
        eve.CurrencyIsoCode = eventCurrency.Name;
        update eve;
        System.assertNotEquals(eve.EventCurrency__c ,null, 'Event Currency should not be null');
        
        Email_Templates__c testET = new Email_Templates__c();
        testET.name = 'test email template';
        testET.Template_Code__c = 'FOAPPR';
        testET.Content__c = 'testContent';
        testET.Subject__c = 'Test Template';
        testET.CurrencyIsoCode = eventCurrency.Name;
        insert testET;
        
        Event_Edition_Email_Template__c testEEET = new Event_Edition_Email_Template__c();
        testEEET.Event_Edition__c = eve.id;
        testEEET.Subject__c = 'Test Template';
        testEEET.Email_Template__c = testET.id;
        testEEET.Email_Template_Code__c = 'FOAPPR';
        testEEET.Content__c = 'test email template';
        insert testEEET;
        
        //ContactEventEditionMapping__c conevmap = new ContactEventEditionMapping__c(SFContactID__c=cont.id,SFEventEditionID__c=eve.id, User_Type__c=UType.Id);
        //insert conevmap;
                    
        Test.startTest();
            FormAcceptEmail.FormAcceptEmail(String.valueOf(eve.id),String.valueOf(uAForm.id),String.valueOf(eForm.id),'test');  
        Test.stopTest();
        }
    }
}