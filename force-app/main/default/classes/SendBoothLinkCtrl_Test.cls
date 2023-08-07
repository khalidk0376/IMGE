/**
 * File:                SendBootLinkCtrl_Test
 * Project:             GAP
 * Date:                May 15 2018
 * Test Class For:      SendBootLinkCtrl.cls
 * Code Coverage:       75%
 * Created By:          rajesh kumar yadav
 * *************************************************************************
 * Description:         Test class for SendBootLinkCtrl.
 * *************************************************************************
 * History:
 */

@isTest(seeAlldata = false)
private class SendBoothLinkCtrl_Test {

    // Common test setup Data
    @testSetup static void testSetupData() {
        //Test.StartTest();
        Utility.isRebookInProcess = True ;
        Account oAccount = new Account(Name = 'Expocad Account', CurrencyIsoCode = 'USD', Phone = '2423122323');
        insert oAccount;

        Contact oCon = new Contact(LastName = 'ContTest1', Email = 'test1contact@duptest.com', AccountId = oAccount.Id, MailingStreet = 'Test', MailingCity = 'Test', MailingState='', MailingCountry='India',Phone = '2423122323', AssistantPhone = '2423122323', HomePhone = '2121212121', MobilePhone = '2121212145', OtherPhone = '2154215421');
        insert oCon;
        
        User oUser = [SELECT Id FROM User WHERE Id = : UserInfo.getUserId()];
        AccountTeamMember oAtm =new AccountTeamMember(AccountId = oAccount.id, userId = oUser.id);
        insert oAtm;
        
        Brand__c oBrand = new Brand__c(Name='World of Concrete', SSC_Email_Distribution_ID__c = 'test@test.tst');
        insert oBrand;
        
        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Brand__c=oBrand.id, Event_Edition_Pool__c = 'WOC');
        insert oEventseries;
        
        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017',Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information',Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = 'Space Only', Expocad_API_Url__c = 'test.com', Part_of_Series__c = oEventseries.id, Event_Currency__c = 'USD');
        insert oEvent;

        Product2 prd = new Product2(Name = 'Booth Package WOC',Family = 'Booth',Number_of_Corners__c = 0,Booth_Type__c='esc', Show_In_Show__c='Indoor', Booth_Class__c='fsdf', Event_Edition_Pool__c = 'WOC', Product_Brand__c = 'World of Concrete 2017');
        insert prd;
        
        Pricebook2 customPB2 = new Pricebook2(Name='ICRE', isActive=true);
        insert customPB2;
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pbStndrdPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prd.Id,UnitPrice = 100, IsActive = true);
        insert pbStndrdPrice;
        PricebookEntry pbICREPrice = new PricebookEntry(Pricebook2Id = customPB2.Id, Product2Id = prd.Id,UnitPrice = 200, IsActive = true);
        insert pbICREPrice;

        Product2 prd1 = new Product2(Name = 'Post Draw Indoor Booth',Booth_Product_Type__c ='Space Only',Booth_Type__c='esc', Show_In_Show__c='Indoor', Booth_Class__c='fsdf',Family = 'Booth',Number_of_Corners__c = 0, Event_Edition_Pool__c = 'WOC', Product_Brand__c = 'World of Concrete 2017', Expiry_Date__c = Date.today());
        insert prd1;
        
        Pricebook2 customPB = new Pricebook2(Name='ICRE2', isActive=true);
        insert customPB;
        PricebookEntry pbStndrdPrice1 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prd1.Id,UnitPrice = 100, IsActive = true);
        insert pbStndrdPrice1;
        PricebookEntry pbICREPrice1 = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = prd1.Id,UnitPrice = 200, IsActive = true);
        insert pbICREPrice1;

        Product2 prd2 = new Product2(Name = 'Corner Booth Fee',Family = 'Booth',Booth_Type__c='esc', Show_In_Show__c='Indoor', Booth_Class__c='fsdf', Number_of_Corners__c = 1, Event_Edition_Pool__c = 'WOC', Product_Brand__c = 'World of Concrete 2017');
        insert prd2;
        
        PricebookEntry pbStndrdPrice2 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prd2.Id,UnitPrice = 100, IsActive = true);
        insert pbStndrdPrice2;
        PricebookEntry pbICREPrice2 = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = prd2.Id,UnitPrice = 200, IsActive = true);
        insert pbICREPrice2;
        SBQQ__ProductOption__c oPrdOption = new SBQQ__ProductOption__c(SBQQ__Number__c = 5,SBQQ__ConfiguredSKU__c = prd.id, SBQQ__OptionalSKU__c = prd1.id );
        insert oPrdOption;
        SBQQ__ProductOption__c oPrdOption2 = new SBQQ__ProductOption__c(SBQQ__Number__c = 7,SBQQ__ConfiguredSKU__c = prd1.id, SBQQ__OptionalSKU__c = prd2.id );
        insert oPrdOption2;
        Opportunity oOpportunity = new Opportunity(Name = 'Expocad Opportunity', CloseDate = Date.today(), StageName = 'Proposal', EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id, AccountId = oAccount.Id, Billing_Contact__c = oCon.Id);
        insert oOpportunity;
        SBQQ__Quote__c oQuote = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Quote Sent', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = oOpportunity.Id, SBQQ__Account__c = oAccount.Id, SBQQ__Primary__c = true);
        insert oQuote;
    }
    
    @isTest static void testSendEmailToPrimaryContact() {
        Test.StartTest();
        Utility.isRebookInProcess = True ;
        Opportunity oOpportunity = [SELECT ID, Name, CloseDate, StageName, EventEdition__c, Event_Series__c, AccountId, Billing_Contact__c FROM Opportunity LIMIT 1];
        
        SBQQ__Quote__c oQuote = [SELECT Id, CurrencyIsoCode, SBQQ__Status__c, SBQQ__Type__c, SBQQ__Opportunity2__c, SBQQ__Account__c, SBQQ__Primary__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Quote Sent' LIMIT 1];
        
        ExpocadBooth__c oEB = new ExpocadBooth__c( Booth_Number__c = 'TESTBN3',Quote__c = oQuote.Id, Opportunity__c = oOpportunity.Id, Account__c = oOpportunity.AccountId, Open_Corners__c = 4.5, Status__c = 'On Hold', Booth_Product_Type__c = 'Indoor');
        insert oEB;
        system.debug('oEB' + oEB);
        System.assert(oEB.Opportunity__c==oOpportunity.Id , 'test class failed');
        System.assert(oQuote.SBQQ__Primary__c , 'test class failed');
        ApexPages.StandardController sc = new ApexPages.StandardController(oOpportunity);
        Apexpages.currentpage().getparameters().put('id' , oOpportunity.id);
        
        SendBoothLinkCtrl oSendBoothLinkCtrl = new SendBoothLinkCtrl(sc);
        oSendBoothLinkCtrl.sendEmailToPrimaryContact();
        oSendBoothLinkCtrl.sRequiredMsg = 'Template "Send Booth Floorplan Info Template" is not found.';
        oSendBoothLinkCtrl.redirectOpportunity();
        
       
        Test.StopTest();
    }
    
}