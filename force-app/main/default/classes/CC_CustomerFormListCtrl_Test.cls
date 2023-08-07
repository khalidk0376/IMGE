/*
Created By		: Girikon(Himanshu[STL-19])
Created On		: August 3 2019
@description 	: This class is test Classs to test different test cases for CC_CustomerformListCtrl Class.
Code Coverage		: Coverage - 91% 
Modification log --
Modified By		: Girikon(Prashant[STL-282], Oct 16 2019)
*/


@isTest
public class CC_CustomerFormListCtrl_Test {

     @isTest
    static void dataSetUp() 
    {    
        //Create Account
        List<Account> accounts = new List<Account>();
        for(Integer i=0;i<3;i++){
            Account a = new Account(Name='TstAccFrst' + i, BillingStreet='testStreet',BillingCity='test', BillingState='Delhi', BillingPostalCode='13245', BillingCountry='India');
            accounts.add(a);    
        }
        insert accounts;
        
        //create some contacts
        List<Contact> contacts = new List<Contact>();
        for(Integer i=0;i<3;i++)
        {
            Contact con = new Contact(AccountId = accounts[i].Id, FirstName = 'TstConFrst'+i, LastName = 'TstConLst1'+i, Email='test@test.com');
            contacts.add(con);    
        }
        insert contacts;
        
        //Create user
        Profile pro = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User Custom'];
        User u = new User();
        u.FirstName = 'Garima';
        u.LastName = 'Gupta';
        u.Email = 'test@wexeurope.com';
        u.Username = 'test@wexeurope.com.fghgh';
        u.Alias = 'astest';
        u.ProfileId = pro.Id;
        u.ContactId = contacts[1].id;
        u.TimeZoneSidKey    = 'America/Denver';
        u.LocaleSidKey      = 'en_US';
        u.EmailEncodingKey  = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        insert u;
        
        User_Type__c oUT = new User_Type__c(Name='Exhibitor');
        insert oUT;
        
          
        //create Event_Edition__c
        List<Event_Edition__c> lstEE = new List<Event_Edition__c>();
        for(Integer i=0;i<3;i++)
        {
            Event_Edition__c ee = new Event_Edition__c(Name='Arab Health Exhibition and Congress 2019'+i,Event_Code__c='sbah19',End_Date__c=System.Today(),Start_Date__c=System.Today(),Payment_Schedule__c='50-50',X50_Cutoff_Date__c=System.Today(),Cutoff_Date_1__c=System.Today(),Cutoff_Date_2__c=System.Today(),Event_Currency__c='USD',Cutoff_Date_3__c=System.Today());
            lstEE.add(ee);  
        }
        insert lstEE;
        
        Form__c form = new Form__c(	Business_Unit__c='Asia');
        insert form;
        Event_Edition_Form__c evtedition = new Event_Edition_Form__c(Event_Edition__c = lstEE[0].id,Forms__c=form.id);
        insert evtedition;
        Forms_Permission__c manPerm = new Forms_Permission__c(Active__c=true,Event_Edition_Form__c=evtedition.id,User_Type__c=oUT.id);
        insert manPerm;
        
         User_Form_Action__c formAction = new User_Form_Action__c(Name='Test',Account__c=accounts[1].id,Is_Viewed__c=true,Form_Permission__c=manPerm.id);
        insert formAction;
         System.assertNotEquals(null, formAction.Name, 'formAction Name must not be null');
        //Create Event_Settings__c
        
        Event_Settings__c evntSttng = new Event_Settings__c(Name='Test',Forms_Title__c='test',Welcome_Text_Forms__c='test',About_Show__c='Test',Manuals_Title__c='Manuals',Welcome_Text_Manuals__c='Welcome Manuals',Show_Hide_Manual_Agreed__c=true,Deadline_Reached_Message_for_Manuals__c='Test',Event_Edition__c=lstEE[1].id);
        insert evntSttng;
        
        ContactEventEditionMapping__c contMap = new ContactEventEditionMapping__c(SFEventEditionID__c=lstEE[1].id,SFContactID__c=u.ContactId,User_Type__c=oUT.id);
        insert contMap;
        
 		System.assertNotEquals(contMap,null,'Test');
        
        test.startTest();
        System.runAs(u)
        {
           	CC_CustomerFormListCtrl.customerFormListWrpData(u.id,'sbah19');
            CC_CustomerFormListCtrl.updateUserFormAction(formAction.id,'true',true); //Added a parameter in this method[STL-282]
        }
        
        test.stopTest();
    }
    
}