/**
 * Created/Modified By: Girikon(Archit)
 * Created On:          9/1/2017
 * Description/Purpose: This test class covers the apex class : SendPDFAsInvoice
 * Methods:             SendPDFAsInvoice_DataInsert
 * Apex Class:          SendPDFAsInvoice
**/

@isTest
public class SendPDFAsInvoice_Test {
     public static testMethod void SendPDFAsInvoice_DataInsert()
    {
         // Setup test data
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser11@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing11', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduserjames1@testorg.com');
        insert u;
     System.runAs(u) 
        {
        Account acc = new Account();
            acc.Name = 'Test Account';
            insert acc;
            
        Contact con = new Contact();
        con.LastName = 'testLastName';
        con.FirstName = 'testFirstName';
        con.MailingStreet = '111';
        con.MailingCity = 'Dallas';
        con.MailingCountry = 'USA';
        con.MailingState = 'Texas';
        con.MailingPostalCode = '75068';
        con.Email = 'test@gmail.com';
        con.Phone = '2012012012';
        con.accountId = acc.Id;
        insert con;
    
        Event_Edition__c OEve = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today());
        insert OEve;
        System.assertEquals(OEve.Event_Code__c,'WOC17', 'Event Code');
        EventCurrecies__c eventCurrency = new EventCurrecies__c (Name='USD',Event_Edition__c=OEve.id);
        insert eventCurrency;
        System.assertEquals(eventCurrency.Name,'USD', 'Event Currency');
        OEve.EventCurrency__c = eventCurrency.id;
        update OEve;
        System.assert(OEve.EventCurrency__c != null, 'Event Currency');
    
        Customer_Center_Cart_Master__c testCCCM = new Customer_Center_Cart_Master__c();
        testCCCM.Event_Edition__c = OEve.id;
        testCCCM.Is_checked_out__c = false;
        testCCCM.Payment_Type__c='Invoice';
        insert testCCCM;
        
        Email_Templates__c testET = new Email_Templates__c();
        testET.name = 'test email template';
        testET.Template_Code__c = 'ORDINV';
        testET.Content__c = 'testContent';
        testET.Subject__c = 'Test Template';
        insert testET;
        
        Event_Edition_Email_Template__c testEEET = new Event_Edition_Email_Template__c();
        testEEET.Event_Edition__c = OEve.id;
        testEEET.Subject__c = 'Test Template';
        testEEET.Email_Template__c = testET.id;
        testEEET.Email_Template_Code__c = 'ORDINV';
        testEEET.Content__c = 'test email template';
        insert testEEET;
        
        ApexPages.currentPage().getParameters().put('mCartId',testCCCM.id);
        ApexPages.currentPage().getParameters().put('paymentType','Invoice');
        ApexPages.currentPage().getParameters().put('ContactId',con.id);
        ApexPages.currentPage().getParameters().put('UserId',u.id);
        ApexPages.currentPage().getParameters().put('eventCode','WOC17');
        
        Test.startTest();
            SendPDFAsInvoice obj = new SendPDFAsInvoice();
            obj.call();
            obj.sendPDFEmail('WOC17',con.id,u.id,testCCCM.id,testCCCM.Payment_Type__c);
        Test.stopTest();
        
    }
    }
}