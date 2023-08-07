/**
* Project:     Informa Markets
* Date:        Dec, 11 2019
* Created By:  Avinash Shukla
* Test Class For :  Opp_Handler_Expocad(100%)
* *************************************************************************
* @description This is test class for Opp_Handler_Expocad handler
* *************************************************************************
*/
@isTest
public with sharing class Opp_Handler_Expocad_Test {
    /**
     * @description data Setup. 
     */
    @testSetup static void testDataSetup() {
        Account oAccount1 = new Account(Name = 'Testing Expocad', CurrencyIsoCode = 'USD', Brand__c = 'Expocad' );
        Insert oAccount1;
		
        Account oAccount2 = new Account(Name = 'Test Account 2', CurrencyIsoCode = 'USD');
        Insert oAccount2;
        
        Contact oCon1 = new Contact(LastName = 'Test Contact 1', Email = 'test1@contact.com', AccountId = oAccount1.Id, MailingStreet = 'Test', MailingCity = 'Test', MailingState = '', MailingCountry = 'India');
        Insert oCon1;

        Contact oCon2 = new Contact(LastName = 'Test Contact 2', Email = 'test2@contact.com', AccountId = oAccount2.Id, MailingStreet = 'Test', MailingCity = 'Test', MailingState = '', MailingCountry = 'India');
        Insert oCon2;

        Brand__c oBrand = new Brand__c(Name = 'World Of Concrete', Business_Unit__c = 'Life Science');
        Insert oBrand;

        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', Brand__c = oBrand.Id , CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Event_Edition_Pool__c = 'WOC');
        Insert oEventseries;

        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017', Booth_Rent_Stage__c = 'On Payment', Tab7__c = 'Test', Tab1__c = 'Test', Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = 'Barter Shell Scheme', Start_Date__c = Date.today(), Part_of_Series__c = oEventseries.id);
        Insert oEvent;
		Test.startTest();
        Opportunity oOpportunity = new Opportunity(Name = 'Test Opportunity', Payment_Status__c = 'Not Paid', Opportunity_Contact__c = oCon1.Id, CloseDate = Date.today(), StageName = 'Customize', EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id, AccountId = oAccount1.Id, Billing_Contact__c = oCon1.Id, Exhibitor_Paid_By__c = 'Exhibitor Paid by Exhibitor');
        Insert oOpportunity;
        
        Opportunity oOpportunityRej = new Opportunity(Name = 'Test Opportunity Rejected', Payment_Status__c = 'Not Paid', Opportunity_Contact__c = oCon1.Id, CloseDate = Date.today(), StageName = 'Proposal Sent', EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id, AccountId = oAccount2.Id, Billing_Contact__c = oCon1.Id, Exhibitor_Paid_By__c = 'Exhibitor Paid by Exhibitor');
        Insert oOpportunityRej;
        
        Opportunity oOpportunityRel = new Opportunity(Name = 'Test Opportunity Rel', Payment_Status__c = 'Not Paid', Opportunity_Contact__c = oCon1.Id, CloseDate = Date.today(), StageName = 'Customize', EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id, AccountId = oAccount1.Id, Billing_Contact__c = oCon1.Id, Exhibitor_Paid_By__c = 'Exhibitor Paid by Exhibitor', Parent_Opportunity__c = oOpportunity.Id);
        Insert oOpportunityRel;
        
        SBQQ__Quote__c oQuote = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Quote Sent', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = oOpportunity.Id, SBQQ__Account__c = oAccount1.Id, SBQQ__Primary__c = true);
        Insert oQuote;
        
        ExpocadBooth__c oEB1 = new ExpocadBooth__c(Selected__c = true, Status__c = 'On Hold', Opportunity__c = oOpportunity.Id, Booth_Type__c = 'Corner', ShowInShow__c = 'TestShowInShow', Open_Corners__c = 23, Booth_Classes__c='tset2;test4', Booth_Product_Type_EE__c = 'Space Only', Area__c = '400 SqFt',Quote__c=oQuote.Id,Pavilion__c='test');
        insert oEB1;
        ExpocadBooth__c oEB2 = new ExpocadBooth__c(Selected__c = true, Status__c = 'Added To Quote/On Hold', Opportunity__c = oOpportunity.Id, Booth_Type__c = 'Corner', ShowInShow__c = 'TestShowInShow', Open_Corners__c = 23, Booth_Classes__c='tset2;test4', Booth_Product_Type_EE__c = 'Space Only', Area__c = '400 SqFt',Quote__c=oQuote.Id,Pavilion__c='test');
        insert oEB2;
        ExpocadBooth__c oEB3 = new ExpocadBooth__c(Selected__c = true, Status__c = 'Rented', Opportunity__c = oOpportunityRej.Id, Booth_Type__c = 'Corner', ShowInShow__c = 'TestShowInShow', Open_Corners__c = 23, Booth_Classes__c='tset2;test4', Booth_Product_Type_EE__c = 'Space Only', Area__c = '400 SqFt',Quote__c=oQuote.Id,Pavilion__c='test');
        insert oEB3;
        Opportunity_ExpoCAD_Booth_Mapping__c oEM = new Opportunity_ExpoCAD_Booth_Mapping__c(Opportunity__c = oOpportunityRel.Id);
        insert oEM;
        oOpportunityRej.StageName = 'Customize';
        Update oOpportunityRej;
        Test.stopTest();
    }
    /**
     * @description Update opportunity Account
     */
    static testMethod void testOppCw1() {
        List<Opportunity> lstOppToUdt = new List<Opportunity>();
        Test.startTest();
        Event_Edition__c oEvent = [Select Id, Booth_Rent_Stage__c, Put_Booth_OnHold__c from Event_Edition__c LIMIT 1];
        oEvent.Put_Booth_OnHold__c = true;
        Update oEvent;
        
        Opportunity opp = [Select Id, AccountId from Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        Opportunity oppRej = [Select Id, AccountId, StageName from Opportunity WHERE Name = 'Test Opportunity Rejected' LIMIT 1];
        oppRej.Status__c = 'Accounting Rejected';
        oppRej.StageName = 'Discover';
        lstOppToUdt.add(oppRej);
        
        Contact conPrimary = [Select Id from Contact WHERE LastName = 'Test Contact 2' LIMIT 1];
        opp.StageName = 'Closed Won';
        opp.Opportunity_Contact__c = conPrimary.Id;
        opp.Payment_Status__c = 'Partial Paid';
        lstOppToUdt.add(opp);
        If(!lstOppToUdt.isEmpty()) Update lstOppToUdt;
        Test.stopTest();
        Opportunity oppp = [Select Id, StageName from Opportunity WHERE Name = 'Test Opportunity'];
        System.assertEquals(oppp.StageName, 'Closed Won', 'Update Failed');
	}
    /**
     * @description Update opportunity Account
     */
    static testMethod void testOppCw2() {
        Test.startTest();
        Event_Edition__c oEvent = [Select Id, Booth_Rent_Stage__c from Event_Edition__c LIMIT 1];
        oEvent.Booth_Rent_Stage__c = 'On Contract';
        Update oEvent;
        
        Opportunity opp = [Select Id, AccountId from Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        Contact conPrimary = [Select Id from Contact WHERE LastName = 'Test Contact 2' LIMIT 1];
        opp.StageName = 'Closed Won';
        opp.Opportunity_Contact__c = conPrimary.Id;
        opp.Payment_Status__c = 'Partial Paid';
        Update opp;
        Test.stopTest();
		Opportunity oppp = [Select Id, StageName from Opportunity WHERE Name = 'Test Opportunity'];
        System.assertEquals(oppp.StageName, 'Closed Won', 'Update Failed');
    }
    /**
     * @description Update opportunity Closed Lost
     */
    static testMethod void testOppCl() {
        List<Opportunity> lstOppToCL = new List<Opportunity>();
        Test.startTest();
        Opportunity opp = [Select Id, AccountId from Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        Opportunity oppRel = [Select Id, AccountId from Opportunity WHERE Name = 'Test Opportunity Rel' LIMIT 1];
        opp.StageName = 'Closed Lost';
        opp.Reason_Lost__c = 'AR Cancel / Re-bill';
        oppRel.StageName = 'Closed Lost';
        oppRel.Reason_Lost__c = 'AR Cancel / Re-bill';
        
        lstOppToCL.add(opp);
        lstOppToCL.add(oppRel);
        If(!lstOppToCL.isEmpty()) Update lstOppToCL;
        Test.stopTest();
        Opportunity oppp = [Select Id, StageName from Opportunity WHERE Name = 'Test Opportunity'];
        System.assertEquals(oppp.StageName, 'Closed Lost', 'Update Failed');
    }
	
}