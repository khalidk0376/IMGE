/**
* Project:     Informa Markets
* Date:        Dec, 11 2019
* Created By:  Avinash Shukla
* Test Class For :  Opp_Handler_Quote(95%)
* *************************************************************************
* @description This is test class for Opp_Handler_Quote handler.
* *************************************************************************
*/
@isTest
public with sharing class Opp_Handler_Quote_Test {
    /**
     * @description data Setup. 
     */
    @testSetup static void testDataSetup() {
        Account oAccount1 = new Account(Name = 'Test Account 1', CurrencyIsoCode = 'USD', Brand__c = 'Expocad' );
        Insert oAccount1;
        Contact oCon1 = new Contact(LastName = 'Test Contact 1', Email = 'test1@contact.com', AccountId = oAccount1.Id, MailingStreet = 'Test', MailingCity = 'Test', MailingState = '', MailingCountry = 'India');
        Insert oCon1;
        Contact oCon2 = new Contact(LastName = 'Test Contact 2', Email = 'test2@contact.com', AccountId = oAccount1.Id, MailingStreet = 'Test', MailingCity = 'Test', MailingState = '', MailingCountry = 'India');
        Insert oCon2;
        Brand__c oBrand = new Brand__c(Name = 'World Of Concrete', Business_Unit__c = 'Life Science');
        Insert oBrand;
        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', Brand__c = oBrand.Id , CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Event_Edition_Pool__c = 'WOC', Status__c = 'Active');
        Insert oEventseries;
        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017', Booth_Rent_Stage__c = 'On Payment', Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = 'Barter Shell Scheme', Start_Date__c = Date.today(), Part_of_Series__c = oEventseries.id,Event_Edition_Status__c = 'Confirmed',No_Billing__c = false);
        Insert oEvent;
        Test.startTest();
        Opportunity oOpportunity = new Opportunity(Name = 'Test Opportunity', Payment_Status__c = 'Not Paid', Opportunity_Contact__c = oCon1.Id, CloseDate = Date.today(), StageName = 'Closed Won', EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id, AccountId = oAccount1.Id, Billing_Contact__c = oCon1.Id, Exhibitor_Paid_By__c = 'Exhibitor Paid by Exhibitor');
        Insert oOpportunity;
        SBQQ__Quote__c oQuote = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Quote Sent', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = oOpportunity.Id, SBQQ__Account__c = oAccount1.Id, SBQQ__Primary__c = true);
        Insert oQuote;
        Contract oContract = new Contract(AccountId = oAccount1.id, Status='Sent', StartDate = Date.today(), ContractTerm = 12, SBQQ__Opportunity__c = oOpportunity.id, SBQQ__Quote__c = oQuote.Id);
        insert oContract;
        
        Opportunity oOpportunity2 = new Opportunity(Name = 'Test Opportunity 1', Payment_Status__c = 'Not Paid', Opportunity_Contact__c = oCon1.Id, CloseDate = Date.today(), StageName = 'Customize', EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id, AccountId = oAccount1.Id, Billing_Contact__c = oCon1.Id, Exhibitor_Paid_By__c = 'Exhibitor Paid by Exhibitor');
        Insert oOpportunity2;
        
        SBQQ__Quote__c oQuote2 = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Quote Sent', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = oOpportunity2.Id, SBQQ__Account__c = oAccount1.Id, SBQQ__Primary__c = true, Manual__c = true);
        Insert oQuote2;
             
       
        dsfs__DocuSign_Status__c dSign = new dsfs__DocuSign_Status__c(Quote__c = oQuote.Id, dsfs__Envelope_Status__c = 'Test');
        insert dSign;
        
        Opportunity oOpportunity3 = new Opportunity(Name = 'Opportunity3', CloseDate = Date.today(), StageName = 'Closed Won', EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id, AccountId = oAccount1.Id, Billing_Contact__c = oCon1.Id, status__c = 'Discover');
        insert oOpportunity3;
        
        SBQQ__Quote__c oQuote3 = new SBQQ__Quote__c(SBQQ__Status__c = 'Quote', Billing_Contact__c = oCon1.Id ,SBQQ__Type__c = 'Quote',Alternate_Currency2__c='AED', SBQQ__Opportunity2__c = oOpportunity3.id , SBQQ__Primary__c = true);
        insert oQuote3;

        Test.stopTest();
    }
    /**
     * @description Update opportunity Closed Lost
     */
    static testMethod void testOppCl() {
        List<Opportunity> lstOppToCL = new List<Opportunity>();
        Test.startTest();
        Opportunity opp = [Select Id, AccountId from Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        Contact conPrimary = [Select Id from Contact WHERE LastName = 'Test Contact 2' LIMIT 1];
        opp.Billing_Contact__c = conPrimary.Id;
        opp.StageName = 'Closed Lost';
        opp.Reason_Lost__c = 'AR Cancel / Re-bill';
        lstOppToCL.add(opp);
        If(!lstOppToCL.isEmpty()) Update lstOppToCL;
        Test.stopTest();
        Opportunity oppp = [Select Id, StageName from Opportunity WHERE Name = 'Test Opportunity'];
        System.assertEquals(oppp.StageName, 'Closed Lost', 'Update Failed');
    }
    /**
     * @description Update opportunity Billing Contact
     */
    static testMethod void testOppBCChange() {
        List<Opportunity> lstOppToCw = new List<Opportunity>();
        Test.startTest();
        Opportunity opp = [Select Id, AccountId from Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];        
        Contact conPrimary = [Select Id from Contact WHERE LastName = 'Test Contact 2' LIMIT 1];
        opp.Billing_Contact__c = conPrimary.Id;
        opp.StageName = 'Closed Won';
        opp.isThroughDcousign__c = true;
        opp.Status__c = 'Awaiting Payment';
        lstOppToCw.add(opp);
        If(!lstOppToCw.isEmpty()) Update lstOppToCw;
        Test.stopTest();
        Opportunity oppp = [Select Id, StageName from Opportunity WHERE Name = 'Test Opportunity'];
        System.assertEquals(oppp.StageName, 'Closed Won', 'Update Failed');
    }
    /**
     * @description Update opportunity Billing Contact and CW
     */
    static testMethod void testOppBCChangeNCW() {
        List<Opportunity> lstOppToCw = new List<Opportunity>();
        Opportunity opp = [Select Id, AccountId from Opportunity WHERE Name = 'Test Opportunity 1' LIMIT 1];
        opp.StageName = 'Closed Won';
        opp.Status__c = 'Awaiting Payment';
        
        lstOppToCw.add(opp);
        Test.startTest();
        If(!lstOppToCw.isEmpty()) Update lstOppToCw;
        Test.stopTest();
        Opportunity oppp = [Select Id, StageName from Opportunity WHERE Name = 'Test Opportunity 1'];
        System.assertEquals(oppp.StageName, 'Closed Won', 'Update Failed');
    }
    
    //Bk-3713
    static testMethod void barteropptestmethod ()
    {
        Test.startTest();
        List<Opportunity> opportunitytoupdate = new List<Opportunity>();
        Opportunity oOpportunity = [Select Id, AccountId from Opportunity WHERE Name = 'Test Opportunity 1' LIMIT 1];      
        oOpportunity.StageName = 'Closed Booked';
        oOpportunity.Is_Barter_Opportunity__c = true;
        opportunitytoupdate.add(oOpportunity);
        
        Opportunity oOpportunity1 = [Select Id, name,StageName, AccountId from Opportunity WHERE Name = 'Opportunity3' LIMIT 1];
        oOpportunity1.Is_Barter_Opportunity__c = true;
        oOpportunity1.StageName = 'Customize';
        opportunitytoupdate.add(oOpportunity1);
        
        Opportunity oOpportunity2 = [Select Id, name,StageName, AccountId from Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        oOpportunity2.Is_Barter_Opportunity__c = false;
        oOpportunity2.StageName = 'Customize';
        opportunitytoupdate.add(oOpportunity2);
        
        if(opportunitytoupdate.size() > 0)
        {
         update opportunitytoupdate;  
        }
        System.assertEquals('Opportunity3' , oOpportunity1.name,'Eror');
        Test.stopTest();                   
    }
}