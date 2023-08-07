/**
* Project:     Informa Markets
* Date:        Dec, 11 2019
* Created By:  Avinash Shukla
* Test Class For :  Opp_Handler_Opportunity(88%)
* *************************************************************************
* @description This is test class for Opp_Handler_Opportunity handler
* *************************************************************************
*/
@isTest
public with sharing class Opp_Handler_Opportunity_Test {
    /**
    * @description data Setup. 
	*/
    @testSetup static void testDataSetup() {
        Account oAccount1 = new Account(Name = 'Test Account 1', CurrencyIsoCode = 'USD', Brand__c = 'Expocad', BillingCountry = 'USA');
        Insert oAccount1;
        Account oAccount2 = new Account(Name = 'Girikon 300', CurrencyIsoCode = 'USD');
        Insert oAccount2;
        Contact oCon1 = new Contact(LastName = 'Test Contact 1', Email = 'test1@contact.com', AccountId = oAccount1.Id, MailingStreet = 'Test', MailingCity = 'Test', MailingState = '', MailingCountry = 'India', Contact_Type__c = 'Primary Contact');
        Insert oCon1;
        Contact oCon2 = new Contact(LastName = 'Test Contact 2', Email = 'test2@contact.com', AccountId = oAccount2.Id, MailingStreet = 'Test', MailingCity = 'Test', MailingState = '', MailingCountry = 'India', Contact_Type__c = 'Primary Contact');
        Insert oCon2;
        Brand__c oBrand = new Brand__c(Name = 'World Of Concrete', Business_Unit__c = 'Life Science');
        Insert oBrand;
        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', Brand__c = oBrand.Id , CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Event_Edition_Pool__c = 'WOC');
        Insert oEventseries;
        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017', Booth_Rent_Stage__c = 'On Payment', Tab7__c = 'Test', Tab1__c = 'Test', Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Edition_Code__c = 'Test321', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = 'Barter Shell Scheme', Start_Date__c = Date.today(), Part_of_Series__c = oEventseries.id);
        Insert oEvent;
        EventCurrecies__c ecr = new EventCurrecies__c(Name = 'Test', Event_Edition__c = oEvent.Id);
        insert ecr;
        Event_Edition__c oEvent2 = new Event_Edition__c(Name = 'World of Concrete 2018', Booth_Rent_Stage__c = 'On Payment', Tab7__c = 'Test', Tab1__c = 'Test', Event_Edition_Code__c = 'Test 123', Approval_Service_Now_ID__c = '1234', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB1,KDB3', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = 'Barter Shell Scheme', Start_Date__c = Date.today(), Part_of_Series__c = oEventseries.id);
        Insert oEvent2;
        Test.startTest();
        Opportunity oOpportunity = new Opportunity(Name = 'Test Opportunity',CurrencyIsoCode = 'ZAR',Payment_Status__c = 'Not Paid', Opportunity_Contact__c = oCon1.Id, CloseDate = Date.today(), StageName = 'Customize', EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id, AccountId = oAccount1.Id, Billing_Contact__c = oCon1.Id, Exhibitor_Paid_By__c = 'Exhibitor Paid by Exhibitor',Type ='New');
        Insert oOpportunity;
        Opportunity oOpportunityRej = new Opportunity(Name = 'Test Opportunity Rejected', Type = 'Existing Business',Payment_Status__c = 'Not Paid', Opportunity_Contact__c = oCon1.Id, CloseDate = Date.today(), StageName = 'Proposal Sent', EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id, AccountId = oAccount1.Id, Billing_Contact__c = oCon1.Id);
        Insert oOpportunityRej;
        Opportunity oOpportunityBarter = new Opportunity(Is_Barter_Opportunity__c = true, Name = 'Amendment for contract # 12345 Test Opportunity Bart', Payment_Status__c = 'Not Paid', Opportunity_Contact__c = oCon1.Id, CloseDate = Date.today(), StageName = 'Proposal Sent', EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id, AccountId = oAccount1.Id, Billing_Contact__c = oCon1.Id, Exhibitor_Paid_By__c = 'Exhibitor Paid by Exhibitor', Type ='New');
        Insert oOpportunityBarter;
        
        Opportunity oOpportunityRel = new Opportunity(Master_Opportunity__c = oOpportunity.Id, Name = 'Test Opportunity Rel', Type = 'Existing Business', Payment_Status__c = 'Not Paid', Opportunity_Contact__c = oCon1.Id, CloseDate = Date.today(), StageName = 'Customize', EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id, AccountId = oAccount1.Id, Billing_Contact__c = oCon1.Id, Exhibitor_Paid_By__c = 'Exhibitor Paid by Exhibitor', Parent_Opportunity__c = oOpportunity.Id);
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
        Product2 prd = new Product2(Name = 'Booth Package WOC', Family = 'Booth', Number_of_Corners__c = 0, Booth_Type__c = 'esc', Show_In_Show__c = 'Outdoor', Booth_Class__c = 'fsdf', Event_Edition_Pool__c = 'WOC', Product_Brand__c = 'World of Concrete 2017');
        insert prd;
        Pricebook2 customPB2 = new Pricebook2(Name = 'ICRE', isActive = true);
        insert customPB2;
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry stndrdPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prd.Id, UnitPrice = 100, IsActive = true);
        insert stndrdPrice;
        PricebookEntry iCREPrice = new PricebookEntry(Pricebook2Id = customPB2.Id, Product2Id = prd.Id, UnitPrice = 200, IsActive = true);
        insert iCREPrice;
        SBQQ__ProductOption__c oPrdOption = new SBQQ__ProductOption__c(SBQQ__Number__c = 5, SBQQ__ConfiguredSKU__c = prd.id);
        insert oPrdOption;
        SBQQ__QuoteLine__c qLine =   new SBQQ__QuoteLine__c();
        qLine.Booth_Number__c    = '1234';
        qLine.SBQQ__Quantity__c  = 15;
        qLine.SBQQ__Quote__c = oQuote.Id;
        qLine.SBQQ__Product__c = prd.Id;
        insert qLine;
        User_Type__c ut1 = new User_Type__c(Name = 'Agent');
        insert ut1;
        ExhibitorForUserType__c eFU = new ExhibitorForUserType__c();
        efu.Name = 'Exhibitor Paid by Exhibitor';
        insert efu;
        Currency_Master__c oCurrency = new Currency_Master__c(LocalCurrency__c = 'ZAR', ForeignCurrency__c = 'USD', ExchangeRate__c = 1.05);
        insert oCurrency;
    }
    /**
	* @description Update opportunity to Closed Won
	*/
    static testMethod void testOppCw1() {
        List<Opportunity> lstOppToUdt = new List<Opportunity>();
        Test.startTest();
        Event_Edition__c oEvent = [Select Id, Booth_Rent_Stage__c, Put_Booth_OnHold__c from Event_Edition__c WHERE NAME = 'World of Concrete 2018' LIMIT 1];
        Contact conPrimary = [Select Id from Contact WHERE LastName = 'Test Contact 2' LIMIT 1];
        Opportunity opp = [Select Id, AccountId from Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        Opportunity oppRel = [Select Id, AccountId from Opportunity WHERE Name = 'Test Opportunity Rel' LIMIT 1];
        opp.StageName = 'Closed Won';
        opp.Status__c = 'Proposal Sent';
        opp.Payment_Status__c = 'Not Paid';
        opp.EventEdition__c = oEvent.Id;
        opp.Payment_Schedules__c = false;
        opp.Payment_Schedule_2__c = true;
        opp.Custom_Payment__c = true;
        opp.Type = 'New';
      	opp.Billing_Contact__c = conPrimary.Id;
        /*opp.Agreement_Contact__c = conPrimary.Id;
        opp.Safety_Contact__c = conPrimary.Id;
        opp.Stand_Contractor__c = conPrimary.Id;
        opp.Operation_Contact_2__c = conPrimary.Id;
        opp.MarkitMkr_Contact__c = conPrimary.Id;
        opp.Local_Representative__c = conPrimary.Id;
        opp.Legal_Representative_2__c = conPrimary.Id;
        opp.Legal_Representative_1__c = conPrimary.Id;
        opp.Witness_Contact__c = conPrimary.Id;
        opp.Opportunity_Contact__c = conPrimary.Id;
        opp.Marketing_Contact__c = conPrimary.Id;
        opp.Operations_Contact__c = conPrimary.Id; */
        opp.Amount = 1000 ;
       // opp.CurrencyIsoCode = 'ZAR';
        opp.SBQQ__QuotePricebookId__c = NULL;
        lstOppToUdt.add(opp);
        lstOppToUdt.add(oppRel);
        If(!lstOppToUdt.isEmpty()) {Update lstOppToUdt;}
        Test.stopTest();
        Opportunity oppp = [Select Id, StageName from Opportunity WHERE Name = 'Test Opportunity'];
        System.assertEquals(oppp.StageName, 'Closed Won', 'Update Failed');
    }
    /**
	* @description Update opportunity to Closed Won 2
	*/
 	static testMethod void testOppCw2() {
        List<Opportunity> lstOppToUdt = new List<Opportunity>();
        Test.startTest();
        Opportunity opp = [Select Id, AccountId from Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        opp.StageName = 'Closed Won';
        opp.Status__c = 'Proposal Sent';
        opp.Custom_Payment__c = true;
        opp.SBQQ__QuotePricebookId__c = NULL;
        opp.Payment_Schedules__c = true;
        opp.Type = 'New';
		lstOppToUdt.add(opp);
        If(!lstOppToUdt.isEmpty()) {Update lstOppToUdt;}
        Test.stopTest();
        Opportunity oppp = [Select Id, StageName from Opportunity WHERE Name = 'Test Opportunity'];
        System.assertEquals(oppp.StageName, 'Closed Won', 'Update Failed');
    }
    /**
	* @description Update opportunity to Closed Lost
	*/
    static testMethod void testOppCl1() {
        List<Opportunity> lstOppToUdt = new List<Opportunity>();
        Test.startTest();
        Opportunity opp = [Select Id, AccountId from Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        opp.StageName = 'Closed Lost';
        opp.Cancel_Reason__c = 'Test';
        opp.Reason_Lost__c = 'AR Cancel / Re-bill';
        opp.Type = 'New';
        Opportunity oppRej = [Select Id, AccountId, StageName from Opportunity WHERE Name = 'Test Opportunity Rejected' LIMIT 1];
        oppRej.StageName = 'Closed Lost';
        oppRej.Reason_Lost__c = 'AR Cancel / Re-bill';
        oppRej.Is_Barter_Opportunity__c = true;
        lstOppToUdt.add(opp);
        lstOppToUdt.add(oppRej);
        If(!lstOppToUdt.isEmpty()) {Update lstOppToUdt;}
        Test.stopTest();
        Opportunity oppp = [Select Id, StageName from Opportunity WHERE Name = 'Test Opportunity'];
        System.assertEquals(oppp.StageName, 'Closed Lost', 'Update Failed');
    }
    /**
	* @description Update opportunity Do_not_activate_Billing__c to true
	*/
    static testMethod void testOppDoNotActivateBilling() {
        List<Opportunity> lstOppToUdt = new List<Opportunity>();
        Test.startTest();
        Opportunity opp = [Select Id, AccountId, Do_not_activate_Billing__c from Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        opp.Do_not_activate_Billing__c = true;
        opp.Forecast_Category__c = 'Low Confidence';
       // opp.Type = 'New';
        update opp;
        opp = [Select Id, AccountId, Status__c, Do_not_activate_Billing__c from Opportunity WHERE Id =: opp.Id LIMIT 1];
        System.assertEquals(opp.Status__c, 'Do Not Bill Status', 'Values must be same');
        opp.Do_not_activate_Billing__c = false;
        opp.StageName = 'Customize';
        opp.Status__c ='Recalled';
        update opp;
        opp = [Select Id, AccountId, StageName, Status__c, Forecast_Category__c from Opportunity WHERE Id =: opp.Id LIMIT 1];
        //System.assertEquals(opp.Forecast_Category__c, 'Low Confidence', 'Values must be same');
        Test.stopTest();
    } 
}