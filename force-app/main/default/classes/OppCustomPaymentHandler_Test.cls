/**
 * File:        OppCustomPaymentHandler_Test.cls
 * Project:     GE-IOM
 * Date:        7-Jan-2023
 * Created By:  Ansh (GECI-654)
 * Modified By: 
 * *************************************************************************
 * @description : Test class for OppCustomPaymentHandler
 * *************************************************************************
 */
@isTest
private class OppCustomPaymentHandler_Test {
	
    @isTest
    static void updateQuoteStatusTest2() {
        Account oacc = new Account (Name = 'testAccount');
        insert oacc ;
        Trigger__c trig = new Trigger__c(Name = 'UpdateQuoteStatus' , Trigger_Name_Unique__c = 'UpdateQuoteStatus', Enabled__c = true, Object__c = 'Opportunity', Run_for_Recordypes__c = 'All',  Description__c = 'my test', Execution_Order__c = 1, Before_Update__c = true, After_Update__c = true );
        Insert trig;
        Trigger_Recordtype__c rt = new Trigger_Recordtype__c(Enabled__c=true,Recordtype_Id__c=trig.Id,Trigger__c=trig.Id,Parameters__c='param=1;param=2');
        Insert rt;
        TriggerInterface_Opp obj = new TriggerInterface_Opp();
        System.debug(LoggingLevel.DEBUG, obj);
        Contact oCon = new Contact(LastName = 'ContTest1', Email = 'test1contact@duptest.com', AccountId = oacc.Id, MailingStreet = 'Test', MailingCity = 'Test', MailingState = '', MailingCountry = 'India');
        insert oCon;

        Brand__c oBrand = new Brand__c(Name = 'World of Concrete', SSC_Email_Distribution_ID__c = 'test@test.tst');
        insert oBrand;

        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Brand__c = oBrand.id, Event_Edition_Pool__c = 'WOC');
        insert oEventseries;

        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017',Enabled_for_IOM_Billing__c = true, Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information', Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = 'Space Only', Expocad_API_Url__c = 'test.com', Part_of_Series__c = oEventseries.id, Booth_Classes_on_Template__c = 'Temp', Corner_Configuration_Check__c = false, Product_Type_Order__c = 'BoothA;;BoothB');
        insert oEvent;

        Opportunity oOpportunity = new Opportunity(Name = 'Expocad Opportunity', CloseDate = Date.today(), StageName = 'Proposal', EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id, AccountId = oacc.Id, Billing_Contact__c = oCon.Id,Type = 'New');
        insert oOpportunity;

        SBQQ__Quote__c oQuote = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Quote Sent', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = oOpportunity.Id, SBQQ__Account__c = oacc.Id);
        insert oQuote;

        Test.startTest();
        string json = '[{"Date":"2023-01-24","Percent":"100.00","Amount":"10000.00","PaymentNumber":1}]';
		oOpportunity.IOM_Custom_Billing_Info__c = json;
        update oOpportunity;
        Test.stopTest();
        Opportunity opp = [Select Id,Milestone_1_Amount__c from Opportunity];
        system.assertEquals(decimal.valueOf('10000.00'), opp.Milestone_1_Amount__c, 'Amount is updated');
    }
}