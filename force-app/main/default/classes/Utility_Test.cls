/**
* File:        Utility_Test
* Project:     GAP
* Date:        Dec 02, 2016
* Created By:  Kumar Gaurav
*
* *************************************************************************
* Description: Test class for Class Utility.
* *************************************************************************
* History:
*/

@isTest(seeAlldata = false)
public class Utility_Test {
    static testMethod void unitTest() {
        Integer x = 1;
        Boolean isUtilityActive = Utility.isRebookInProcess ;
        String sEncode = Utility.encode('Test');
        String sDecode = Utility.decode(sEncode);
        String scurrencyFormat = Utility.currencyFormat('10.23');
        Boolean bisLightning = Utility.isLightning ('url') ;
        Boolean bisAsync = Utility.isAsync();
        Account oAccount1 = new Account(Name = 'Test Account 1', CurrencyIsoCode = 'USD', Brand__c = 'Expocad' );
        Insert oAccount1;
        Contact oCon1 = new Contact(LastName = 'Test Contact 1', Email = 'test1@contact.com', AccountId = oAccount1.Id, MailingStreet = 'Test', MailingCity = 'Test', MailingState = '', MailingCountry = 'India');
        Insert oCon1;
        Brand__c oBrand = new Brand__c(Name = 'World Of Concrete', Business_Unit__c = 'Life Science');
        Insert oBrand;
        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', Brand__c = oBrand.Id , CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Event_Edition_Pool__c = 'WOC', Status__c = 'Active');
        Insert oEventseries;
        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017', Booth_Rent_Stage__c = 'On Payment', Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = 'Barter Shell Scheme', Start_Date__c = Date.today(), Part_of_Series__c = oEventseries.id,Event_Edition_Status__c = 'Confirmed',No_Billing__c = false);
        Insert oEvent;
        Opportunity oOpportunity = new Opportunity(Name = 'Test Opportunity', Payment_Status__c = 'Not Paid', Opportunity_Contact__c = oCon1.Id, CloseDate = Date.today(), StageName = 'Closed Won', EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id, AccountId = oAccount1.Id, Billing_Contact__c = oCon1.Id, Exhibitor_Paid_By__c = 'Exhibitor Paid by Exhibitor');
        Insert oOpportunity;
        Booth_Product_Type_Configuration__c bptc = new Booth_Product_Type_Configuration__c();
        bptc.Booth_Product_Type__c='Space Only';
        bptc.Matched_Product_Name__c = 'Artist Alley';
        insert bptc;
        
        Utility.mapBoothProductType();
        System.assertEquals(1, x, 'Error');
        set<Id> accId = new set<Id>();
        accId.add(oAccount1.Id);
        Utility.removeAccountTeammember(accId);
        try {
            Integer i = 100 / 0;
        } catch (exception ex) {
            Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber() , ex.getStackTraceString() , 'makeExpocadQuery');
            Utility.logsError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'AccountRelatedAccountValidationCtrl' , 'Integration');
        }
    }
}