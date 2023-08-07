/*
    Created By		: Girikon( Palla Kishore )
    Created On		: 03/13/2023
    @description 	: Test Class For FetchExpoCadBoothHistroy (100%)
    Modified By		: 
*/

@isTest
private class fetchExpoCadBoothHistroy_Test {
    @istest
    private static void boothHistory() {
        Test.startTest();
        Account oAccount = new Account(Name = 'Expocad Account', CurrencyIsoCode = 'USD');
        insert oAccount;
        
        Contact oCon = new Contact(LastName = 'ContTest1', Email = 'test1contact@duptest.com', AccountId = oAccount.Id, MailingState = '', MailingCountry = 'India');
        insert oCon;
        
        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017', Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information', Payment_Schedule__c = '50-50', cutoff_date_1__c = date.today(), Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt' , Expocad_API_URL__c = 'https://expocad.api.com');
        insert oEvent;
        oEvent.X3rd_Party_Relationship__c='3E Expocad';
        oEvent.X3E_Status__c='Active';
        oEvent.X3E_API_ID__c='22col';
        update oEvent;
        
        Opportunity oOpportunity = new Opportunity(Name = 'Expocad Opportunity',Exhibitor_Paid_By__c='Delegate Sales', CloseDate = Date.today(), StageName = 'Proposal', EventEdition__c = oEvent.Id, AccountId = oAccount.Id, Billing_Contact__c = oCon.Id , IsCreatedByReviewProcess__c = false, CurrencyIsoCode = 'USD', Type = 'New');
        insert oOpportunity;
        
        SBQQ__Quote__c oQuote2 = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = oOpportunity.Id, SBQQ__Account__c = oAccount.Id, SBQQ__Primary__c = true);
        insert oQuote2;
        
        ExpocadBooth__c oExpocadBooth = new ExpocadBooth__c(Status__c = 'On hold', Released__c = false, Booth_Number__c = 'TESTBN2', Quote__c = oQuote2.Id, Opportunity__c = oOpportunity.Id, Booth_Product_Type_EE__c = 'Space Only', Area__c = '18 m²');
        insert oExpocadBooth;
        oExpocadBooth.Booth_Number__c = 'B002';
        oExpocadBooth.Status__c = 'Rented';
        update oExpocadBooth;
        
        list<ExpocadBooth__history> actualHistoryCount = FetchExpoCadBoothHistroy.fetchhistory(oOpportunity.Id);
        system.assertEquals(0,actualHistoryCount.size(),' fetching history');
        Test.StopTest();
    }

}