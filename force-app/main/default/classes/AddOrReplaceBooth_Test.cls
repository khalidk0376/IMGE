/**
* Project:         GAP
* Date:            Jan 31, 2017
* Test Class For:  AddOrReplaceBooth.cls
* Code Coverage:   87%
* Created By:      Kumar Gaurav
* *************************************************************************
* @description     Test class for AddOrReplaceBooth.
* *************************************************************************
* History:
*/

@isTest(seeAlldata = false)
public class AddOrReplaceBooth_Test {
    
    //below test setup method will be invoked implicitly before every test methods
    @testsetup
    static void testSetUpData() {
        List<Booth_Product_Type_Configuration__c> boothProductList = new List<Booth_Product_Type_Configuration__c>();
        boothProductList.add(new Booth_Product_Type_Configuration__c(Matched_Product_Name__c = '', Booth_Product_Type__c = 'Shell Scheme Basic'));
        insert boothProductList;
        Application_Bypass__c oAB = new Application_Bypass__c(SetupOwnerId=UserInfo.getOrganizationId(), Bypass_Validation_Rules__c = True);
        Insert oAB ;
        Account oAccount = new Account(Name = 'Temp Account1', CurrencyIsoCode = 'USD', Phone = '2422122323');
        insert oAccount;
        
        Contact oCon = new Contact(LastName = 'ContTest11', Email = 'test1contact1@duptest.com', AccountId = oAccount.Id, MailingStreet = 'Test', MailingCity = 'Test', MailingState='', MailingCountry='India',Phone = '2423122323', AssistantPhone = '2423122323', HomePhone = '2121212121', MobilePhone = '2121212145', OtherPhone = '2154215421');
        insert oCon;
        
        User oUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        AccountTeamMember oAtm = new AccountTeamMember(AccountId = oAccount.id, userId = oUser.id);
        insert oAtm;
        
        Booth_Product_Type_Configuration__c bptc = new Booth_Product_Type_Configuration__c();
        bptc.Booth_Product_Type__c='Space Only';
        bptc.Matched_Product_Name__c = 'Artist Alley';
        insert bptc;
        
        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Event_Edition_Pool__c = 'WOC');
        insert oEventseries;
        
        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017', Approval_Service_Now_ID__c = '123',Expocad_API_Url__c='https://api2.expocad.com/edgewebapi/informaSB', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = 'Space Only',Tab1__c='Tetttt',Tab7__c='Tsttt');
        insert oEvent;
        User_Type__c uType  = new User_Type__c(Name = 'Exhibitor');
        insert uType;
        Opportunity oOpportunity = new Opportunity(Name = 'Expocad Opportunity Parent', CloseDate = Date.today(), StageName = 'Proposal', EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id, AccountId = oAccount.Id, Billing_Contact__c = oCon.Id, User_Type__c = uType.Id);
        insert oOpportunity;
        Opportunity oOpportunity1 = new Opportunity(Name = 'Expocad Opportunity Child', Parent_Opportunity__c = oOpportunity.Id, CloseDate = Date.today(), StageName = 'Proposal', EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id, AccountId = oAccount.Id, Billing_Contact__c = oCon.Id);
        insert oOpportunity1;
        
        SBQQ__Quote__c oQuote = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Quote Sent', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = oOpportunity1.Id, SBQQ__Account__c = oAccount.Id, SBQQ__Primary__c = true, IsNotGeneralDocument__c = true);
        insert oQuote;
        SBQQ__Quote__c oQuote1 = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Quote Sent', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = oOpportunity.Id, SBQQ__Account__c = oAccount.Id, SBQQ__Primary__c = true, IsNotGeneralDocument__c = true);
        insert oQuote1;
        oOpportunity.SBQQ__PrimaryQuote__c = oQuote1.Id;
        update oOpportunity;
        oOpportunity1.SBQQ__PrimaryQuote__c = oQuote.Id;
        update oOpportunity1;
        
        Product2 prd = new Product2(Name = 'Booth Package WOC', Family = 'Booth', Number_of_Corners__c = 0, Event_Edition_Pool__c = 'WOC', Event_Edition__c = oEvent.Id);
        insert prd;
        Pricebook2 customPB2 = new Pricebook2(Name = 'ICRE', isActive = true);
        insert customPB2;
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pbStndrdPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prd.Id, UnitPrice = 100, IsActive = true);
        insert pbStndrdPrice;
        PricebookEntry pbICREPrice = new PricebookEntry(Pricebook2Id = customPB2.Id, Product2Id = prd.Id, UnitPrice = 200, IsActive = true);
        insert pbICREPrice;
        
        Product2 prd1 = new Product2(Name = 'Pre Draw Indoor Booth', Family = 'Booth', Number_of_Corners__c = 0, Event_Edition_Pool__c = 'WOC', Event_Edition__c = oEvent.Id);
        insert prd1;
        Pricebook2 customPB = new Pricebook2(Name = 'ICRE3', isActive = true);
        insert customPB;
        PricebookEntry pbStndrdPrice1 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prd1.Id, UnitPrice = 100, IsActive = true);
        insert pbStndrdPrice1;
        PricebookEntry pbICREPrice1 = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = prd1.Id, UnitPrice = 200, IsActive = true);
        insert pbICREPrice1;
        
        Product2 prd2 = new Product2(Name = 'Corner Booth Fee', Family = 'Booth', Number_of_Corners__c = 1, Event_Edition_Pool__c = 'WOC', Event_Edition__c = oEvent.Id);
        insert prd2;
        PricebookEntry pbStndrdPrice2 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prd2.Id, UnitPrice = 100, IsActive = true);
        insert pbStndrdPrice2;
        PricebookEntry pbICREPrice2 = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = prd2.Id, UnitPrice = 200, IsActive = true);
        insert pbICREPrice2;
        ExpocadCredential__c expCred =  new ExpocadCredential__c(Name = 'ExpocadApiCredential',Org_Id__c = UserInfo.getOrganizationId(),Expocad_Host_URL__c = 'test.com',Url__c = 'test.com');
        insert expCred;
        //List<ExpocadBooth__c> boothList = new List<ExpocadBooth__c>();
        
        
        //insert boothList;
        Test.StartTest();
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c oQuoteLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = oQuote.Id, SBQQ__Product__c = prd.Id, SBQQ__Quantity__c = 0, SBQQ__Number__c = 1, Line_Description__c = 'Test', Booth_Number__c = 'TESTBN3', Booth__c = True);
        quoteLineList.add(oQuoteLine);
        SBQQ__QuoteLine__c oQuoteLine2 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = oQuote.Id, SBQQ__Product__c = prd1.Id, SBQQ__Quantity__c = 100, SBQQ__Number__c = 2, Line_Description__c = 'Test', Booth_Number__c = 'TESTBN3', Booth__c = True, SBQQ__RequiredBy__c = oQuoteLine.Id);
        quoteLineList.add(oQuoteLine2);
        insert quoteLineList;
        //ExpocadBooth__c booth = new ExpocadBooth__c(Quote__c = oQuote.Id, Booth_Number__c = 'TESTBN3', Status__c = 'Rented');
        //insert booth;
        //SBQQ__QuoteLine__c oQuoteLine3 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = oQuote.Id, SBQQ__Product__c = prd2.Id, SBQQ__Quantity__c = 2, SBQQ__Number__c = 3, Line_Description__c = 'Test', Booth_Number__c = 'TESTBN3', Booth__c = True, SBQQ__RequiredBy__c = oQuoteLine.Id);
        //insert oQuoteLine3;
        Test.StopTest();
    }
    
    @isTest 
    static void callingAllMethod1() {
        Test.startTest();
        ExpocadClasses.Booth wrp1 = new  ExpocadClasses.Booth();
        Opportunity oOpportunity = [Select Id from Opportunity where Name = 'Expocad Opportunity Parent' LIMIT 1];
        SBQQ__Quote__c oQuote1= [SELECT Id FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c =: oOpportunity.Id];
        insert new ExpocadBooth__c(Quote__c = oQuote1.Id, Status__c = 'Rented', Booth_Number__c = 'TESTBN3');
        Opportunity oOpportunity1 = [Select Id from Opportunity where Name = 'Expocad Opportunity Child' LIMIT 1];
        SBQQ__QuoteLine__c oQuoteLine = [Select Id from SBQQ__QuoteLine__c where SBQQ__Product__r.Name = 'Booth Package WOC' LIMIT 1 ];
        ApexPages.StandardController sc = new ApexPages.StandardController(oOpportunity1);
        Apexpages.currentpage().getparameters().put('id', oOpportunity1.id);
        Apexpages.currentpage().getparameters().put('floorBoothId', 'TESTBN3');
        AddOrReplaceBooth oAddOrReplaceBooth = new AddOrReplaceBooth(sc);
        oAddOrReplaceBooth.CheckFloorBooth();
        oAddOrReplaceBooth.getBoothProductType();
        oAddOrReplaceBooth.getQuantity('1234');
        oAddOrReplaceBooth.QLIToAddBN = oQuoteLine.Id;
        oAddOrReplaceBooth.getEB(wrp1 ,'test' ,'test1');
        PageReference pg = oAddOrReplaceBooth.AddOrReplace();
        PageReference pg2 = oAddOrReplaceBooth.selectAnotherBooth();
        PageReference pg3 = oAddorReplaceBooth.returnToPT();
        cls_loadGeneralDocument objload = new cls_loadGeneralDocument();
        objload.pageLoadAction();
        objload.qouteId = 'test';
        Test.StopTest();
        System.assertEquals(null,oAddOrReplaceBooth.lstQLI, 'Error');
    }
    
    @isTest 
    static void callingAllMethod2() {
        Test.startTest();
        Opportunity oOpportunity1 = [Select Id from Opportunity where Name = 'Expocad Opportunity Child' LIMIT 1];
        SBQQ__QuoteLine__c oQuoteLine = [Select Id,SBQQ__Quote__c from SBQQ__QuoteLine__c where SBQQ__Product__r.Name = 'Booth Package WOC' LIMIT 1 ];
        ExpocadClasses.Booth wrp1 = new  ExpocadClasses.Booth();
        insert new ExpocadBooth__c(Quote__c = oQuoteLine.SBQQ__Quote__c, Status__c = 'Rented', Booth_Number__c = 'TESTBN3');
        ApexPages.StandardController sc = new ApexPages.StandardController(oOpportunity1);
        Apexpages.currentpage().getparameters().put('id', oOpportunity1.id);
        Apexpages.currentpage().getparameters().put('floorBoothId', 'TESTBN3');
        AddOrReplaceBooth oAddOrReplaceBooth = new AddOrReplaceBooth(sc);
        oAddOrReplaceBooth.CheckFloorBooth();
        oAddOrReplaceBooth.getBoothProductType();
        oAddOrReplaceBooth.getQuantity('1234');
        oAddOrReplaceBooth.QLIToAddBN = oQuoteLine.Id;
        oAddOrReplaceBooth.getEB(wrp1 ,'test' ,'test1');
        PageReference pg = oAddOrReplaceBooth.AddOrReplace();
        PageReference pg2 = oAddOrReplaceBooth.selectAnotherBooth();
        PageReference pg3 = oAddorReplaceBooth.returnToPT();
        cls_loadGeneralDocument objload = new cls_loadGeneralDocument();
        objload.pageLoadAction();
        objload.qouteId = 'test';
        Test.StopTest();
        System.assertEquals(null,oAddOrReplaceBooth.lstQLI, 'Error');
    }
    
    @isTest 
    static void callingAllMethod3() {
        Test.StartTest();
        Opportunity oOpportunity1 = [Select Id from Opportunity where Name = 'Expocad Opportunity Child' LIMIT 1];
        SBQQ__QuoteLine__c oQuoteLine = [Select Id,SBQQ__Quote__c from SBQQ__QuoteLine__c where SBQQ__Product__r.Name = 'Pre Draw Indoor Booth' LIMIT 1 ];
        ExpocadClasses.Booth wrp1 = new  ExpocadClasses.Booth();
        insert new ExpocadBooth__c(Quote__c = oQuoteLine.SBQQ__Quote__c, Status__c = 'Rented', Booth_Number__c = 'TESTBN3');
        ApexPages.StandardController sc = new ApexPages.StandardController(oOpportunity1);
        Apexpages.currentpage().getparameters().put('id', oOpportunity1.id);
        Apexpages.currentpage().getparameters().put('floorBoothId', 'TESTBN3');
        AddOrReplaceBooth oAddOrReplaceBooth = new AddOrReplaceBooth(sc);
        oAddOrReplaceBooth.CheckFloorBooth();
        oAddOrReplaceBooth.getBoothProductType();
        oAddOrReplaceBooth.getQuantity('1234');
        oAddOrReplaceBooth.QLIToAddBN = oQuoteLine.Id;
        oAddOrReplaceBooth.getEB(wrp1 ,'test' ,'test1');
        PageReference pg = oAddOrReplaceBooth.AddOrReplace();
        PageReference pg2 = oAddOrReplaceBooth.selectAnotherBooth();
        PageReference pg3 = oAddorReplaceBooth.returnToPT();
        cls_loadGeneralDocument objload = new cls_loadGeneralDocument();
        objload.pageLoadAction();
        objload.qouteId = 'test';
        
        Test.StopTest();
        System.assertEquals(null,oAddOrReplaceBooth.lstQLI, 'Error');
    }
    
    @isTest
    static void callingAllMethod4() {
        Test.StartTest();
        //Test.setMock(HttpCalloutMock.class, new ExpocadMock());
        Test.setMock(HttpCalloutMock.class, new ExpocadMock());
        ExpocadClasses.Booth wrp1 = new  ExpocadClasses.Booth();
        
        Opportunity oOpportunity = [Select Id from Opportunity where Name = 'Expocad Opportunity Parent' LIMIT 1];
        // Booth_Product_Type_Configuration__c bPTC = [select Id, Name from Booth_Product_Type_Configuration__c limit 1];
        
        SBQQ__QuoteLine__c oQuoteLine = [Select Id from SBQQ__QuoteLine__c where SBQQ__Product__r.Name = 'Booth Package WOC' LIMIT 1 ];
        
        ApexPages.StandardController sc = new ApexPages.StandardController(oOpportunity);
        Apexpages.currentpage().getparameters().put('id', oOpportunity.id);
        Apexpages.currentpage().getparameters().put('floorBoothId', 'TESTBN3');
        AddOrReplaceBooth oAddOrReplaceBooth = new AddOrReplaceBooth(sc);
        oAddOrReplaceBooth.CheckFloorBooth();
        oAddOrReplaceBooth.getBoothProductType();
        oAddOrReplaceBooth.getQuantity('1234');
        oAddOrReplaceBooth.QLIToAddBN = oQuoteLine.Id;
        oAddOrReplaceBooth.getEB(wrp1 ,'test' ,'test1');
        PageReference pg = oAddOrReplaceBooth.AddOrReplace();
        PageReference pg2 = oAddOrReplaceBooth.selectAnotherBooth();
        PageReference pg3 = oAddorReplaceBooth.returnToPT();
        cls_loadGeneralDocument objload = new cls_loadGeneralDocument();
        objload.pageLoadAction();
        objload.qouteId = 'test';
        Test.StopTest();
        System.assertEquals(null,oAddOrReplaceBooth.lstQLI, 'Error');
    }
}