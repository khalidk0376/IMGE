/**
* Project:     Informa Markets
* Date:        Dec, 11 2019
* Created By:  Avinash Shukla
* Test Class For :  EventEditionJSButtonCtrl(88%)
* *************************************************************************
* @description This is test class for Opp_Handler_Opportunity handler
* *************************************************************************
*/
@isTest
public with sharing class EventEditionJSButtonCtrl_Test{
    /**
    * @description data Setup. 
    */
    static testMethod void testWebServiceMethodCall() {
        Account oAccount1 = new Account(Name = 'Test Account 1', CurrencyIsoCode = 'USD', Brand__c = 'Expocad' );
        Insert oAccount1;
        Contact oCon1 = new Contact(LastName = 'Test Contact 1', Email = 'test1@contact.com', AccountId = oAccount1.Id, MailingStreet = 'Test', MailingCity = 'Test', MailingState = '', MailingCountry = 'India');
        Insert oCon1;
        Brand__c oBrand = new Brand__c(Name = 'World Of Concrete', Business_Unit__c = 'Life Science');
        Insert oBrand;
        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', Brand__c = oBrand.Id , CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Event_Edition_Pool__c = 'WOC');
        Insert oEventseries;
        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017', Booth_Rent_Stage__c = 'On Payment', Tab7__c = 'Test', Tab1__c = 'Test', Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Edition_Code__c = 'Test321', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = 'Barter Shell Scheme', Start_Date__c = Date.today(), Part_of_Series__c = oEventseries.id);
        Insert oEvent;
        Opportunity oOpportunity = new Opportunity(Name = 'Test Opportunity', Payment_Status__c = 'Not Paid', Opportunity_Contact__c = oCon1.Id, CloseDate = Date.today(), StageName = 'Customize', EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id, AccountId = oAccount1.Id, Billing_Contact__c = oCon1.Id, Exhibitor_Paid_By__c = 'Exhibitor Paid by Exhibitor');
        Insert oOpportunity;
        Test.startTest();
        Integer countOpp = EventEditionJSButtonCtrl.fetchOppCount(oEvent.Id);
        Test.stopTest();
        System.assertEquals(countOpp, 1, 'Failed');
    }
}