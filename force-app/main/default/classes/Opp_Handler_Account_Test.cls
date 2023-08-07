/**
* Project:     Informa Markets
* Date:        Dec, 11 2019
* Created By:  Avinash Shukla
* Test Class For :  Opp_Handler_Account(100%)
* *************************************************************************
* @description This is test class for Opp_Handler_Account.
* *************************************************************************
*/
@isTest
public with sharing class Opp_Handler_Account_Test {
    /**
     * @description data Setup. 
     */
    @testSetup static void testDataSetup() {
        /*Account oAccount1 = new Account(Name = 'Test Account 1', CurrencyIsoCode = 'USD', Brand__c = 'Expocad' );
        Insert oAccount1;

        Account oAccount2 = new Account(Name = 'Test Account 2');
        Insert oAccount2;*/

         Account account = new Account();
        account.Name = 'Test Account 2';
        account.BillingCity = 'Oxnard';
        account.BillingCountry = 'USA';
        account.BillingPostalCode = '93030';
        account.BillingState = 'California';
        account.BillingStreet = '121 North G Street';
        account.ShippingCity = 'Los Angeles';
        account.ShippingCountry = 'USA';
        account.ShippingPostalCode = '90033';
        account.ShippingState = 'California';
        account.ShippingStreet = '1600 Pennsylvania Avenue';
        account.Brand__c ='Africa Health';
        account.Business_Unit__c = 'Asia';
        insert account;
 
        Contact oCon1 = new Contact(LastName = 'Test Contact 1', Email = 'test1@contact.com', AccountId = account.Id, MailingStreet = 'Test', MailingCity = 'Test', MailingState = '', MailingCountry = 'India');
        Insert oCon1;

        Contact oCon2 = new Contact(LastName = 'Test Contact 2', Email = 'test2@contact.com', AccountId = account.Id, MailingStreet = 'Test', MailingCity = 'Test', MailingState = '', MailingCountry = 'India');
        Insert oCon2;

        Brand__c oBrand = new Brand__c(Name = 'World Of Concrete', Business_Unit__c = 'Life Science');
        Insert oBrand;

        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', Brand__c = oBrand.Id , CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Event_Edition_Pool__c = 'WOC');
        Insert oEventseries;

        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017', Tab7__c = 'Test', Tab1__c = 'Test', Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = 'Barter Shell Scheme', Start_Date__c = Date.today(), Part_of_Series__c = oEventseries.id);
        Insert oEvent;
		Test.startTest();
        
        Opportunity oOpportunity = new Opportunity(Name = 'Test Opportunity', CloseDate = Date.today(), StageName = 'Customize', EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id, AccountId = account.Id, Billing_Contact__c = oCon1.Id, Exhibitor_Paid_By__c = 'Exhibitor Paid by Exhibitor');
        Insert oOpportunity;
        Test.stopTest();
    }
    /**
     * @description Update opportunity Account
     * @return None
     */
    static testMethod void testUpdateAccount1() {
        Test.startTest();
        Opportunity opp = [Select Id, AccountId from Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        Account ac = [Select Id, Brand__c from Account WHERE Name = 'Test Account 2'];
        opp.AccountId = ac.Id;
        Update Opp;
        Test.stopTest();
        
        Account acget = [Select Id, Brand__c from Account WHERE Name = 'Test Account 2'];
        System.assertEquals(acget.Brand__c, 'Africa Health;World of Concrete', 'Update Failed');
    }
    
    /**
     * @description Update opportunity Account
     */
    static testMethod void testUpdateAccount2() {
        Test.startTest();
        Opportunity opp = [Select Id, AccountId from Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        Account ac = [Select Id, Brand__c from Account WHERE Name = 'Test Account 2'];
        ac.Brand__c = 'Expocad';
        ac.Business_Unit__c = 'Beauty';
        Update Ac;
        
        opp.AccountId = ac.Id;
        Update Opp;
        Test.stopTest();
        
        Account acget = [Select Id, Brand__c from Account WHERE Name = 'Test Account 2'];
        System.assertEquals(acget.Brand__c, 'Expocad', 'Update Failed');
    }
}