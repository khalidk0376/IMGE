/*
Created By		: Girikon(Sunil[STL-17])
Created On		: August 5 2019
@description 	: This class is the test class of CC_HeaderCtrl.
Test Class		: 

Modification log --
Modified By		: 
*/
@isTest
public class CC_HeaderCtrl_Test {

    @isTest static void ccHeaderData()
    {
        Profile pro = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User Custom'];
        
        Account acc = new account();
        acc.Name = 'Kevin & Co.';
        insert acc;
        System.assertNotEquals(null, acc.Name, 'Account Name must not be null');
        
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.FirstName = 'TestConFirst';
        con.LastName = 'TestConLast';
        con.Email='abc@test.com';
        insert con;
        System.assertNotEquals(null, con.LastName, 'Contact Name must not be null');
        
        User usr = new User();
        usr.FirstName = 'Kevin';
        usr.LastName = 'Doe';
        usr.Email = 'test@test.com';
        usr.Username = 'atest@test.com';
        usr.Alias = 'astest';
        usr.ContactId = con.Id;
        usr.ProfileId = pro.Id;
        usr.TimeZoneSidKey    = 'America/Denver';
        usr.LocaleSidKey      = 'en_US';
        usr.EmailEncodingKey  = 'UTF-8';
        usr.LanguageLocaleKey = 'en_US';
        insert usr;
        
        //Create event edition
        Event_Edition__c eventEdition = new Event_Edition__c(Name='Arab Health 2019',Event_Code__c='sbah19',End_Date__c=System.Today(),Start_Date__c=System.Today());
        insert eventEdition;
        
        Event_Settings__c eventSetting = new Event_Settings__c(Name = 'test eventSetting', Event_Edition__c = eventEdition.id,Is_Event_Edition_Live__c=true);
        insert eventSetting;
        
        ContactEventEditionMapping__c cEEM = new ContactEventEditionMapping__c();
        cEEM.SFContactID__c = con.Id;
        cEEM.SFEventEditionID__c = eventEdition.Id;
        cEEM.IsEmailSent__c= true;
        insert cEEM;
        
        System.runAs(usr){
            Test.startTest();
        	String evntCode ='sbah19';
        	CC_HeaderCtrl.fetchUserDetails(evntCode);
        	Test.stopTest();
        }
        
        
    }
}