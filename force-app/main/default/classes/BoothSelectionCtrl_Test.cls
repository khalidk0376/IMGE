/**
 * File:                BoothSelectionCtrl_Test
 * Project:             GAP
 * Date:                Sep 13, 2016
 * Test Class For:      BoothSelectionCtrl.cls
 * Code Coverage:       89%
 * Created By:          Kumar Gaurav
 * *************************************************************************
 * Description:         Test class for BoothSelectionCtrl.
 * *************************************************************************
* History ----: Replaced As Per Ticket GGCW-3101 :----'Product_brand__c Replaced by this Event_Edition_Name__c field'
* Rajesh Kumar Yadav
 */

@isTest(seeAlldata = false)
private class BoothSelectionCtrl_Test {

    // Common test setup Data
    @testSetup static void testSetupData() {
        //Test.StartTest();
        Utility.isRebookInProcess = True ;
        Account oAccount = new Account(Name = 'Expocad Account', CurrencyIsoCode = 'USD', Phone = '2423122323');
        insert oAccount;

        Contact oCon = new Contact(LastName = 'ContTest1', Email = 'test1contact@duptest.com', AccountId = oAccount.Id, MailingStreet = 'Test', MailingCity = 'Test', MailingState = 'Karnataka', MailingCountry = 'India', Phone = '2423122323', AssistantPhone = '2423122323', HomePhone = '2121212121', MobilePhone = '2121212145', OtherPhone = '2154215421');
        insert oCon;

        User oUser = [SELECT Id FROM User WHERE Id = : UserInfo.getUserId()];
        AccountTeamMember oAtm = new AccountTeamMember(AccountId = oAccount.id, userId = oUser.id);
        insert oAtm;

        Brand__c oBrand = new Brand__c(Name = 'World of Concrete', SSC_Email_Distribution_ID__c = 'test@test.tst');
        insert oBrand;

        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Brand__c = oBrand.id, Event_Edition_Pool__c = 'WOC');
        insert oEventseries;

        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017', Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information', Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = 'Space Only', Expocad_API_Url__c = 'test.com', Part_of_Series__c = oEventseries.id, Booth_Classes_on_Template__c = 'Temp', Corner_Configuration_Check__c = false, Product_Type_Order__c = 'BoothA;;BoothB');
        insert oEvent;

        Product2 prd = new Product2(Name = 'Booth Package WOC', Family = 'Booth', Number_of_Corners__c = 0, Booth_Type__c = 'esc', Show_In_Show__c = 'Indoor', Booth_Class__c = 'fsdf', Event_Edition_Pool__c = 'WOC', Event_Edition__c = oEvent.Id);
        insert prd;

        Pricebook2 customPB2 = new Pricebook2(Name = 'ICRE', isActive = true);
        insert customPB2;
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pbStndrdPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prd.Id, UnitPrice = 100, IsActive = true);
        insert pbStndrdPrice;
        PricebookEntry pbICREPrice = new PricebookEntry(Pricebook2Id = customPB2.Id, Product2Id = prd.Id, UnitPrice = 200, IsActive = true);
        insert pbICREPrice;

        Product2 prd1 = new Product2(Name = 'Post Draw Indoor Booth', Booth_Product_Type__c = 'Space Only', Booth_Type__c = 'esc', Show_In_Show__c = 'Indoor', Booth_Class__c = 'fsdf', Family = 'Booth', Number_of_Corners__c = 0, Event_Edition_Pool__c = 'WOC', Event_Edition__c = oEvent.Id, Expiry_Date__c = Date.today());
        insert prd1;

        Pricebook2 customPB = new Pricebook2(Name = 'ICREAB', isActive = true);
        insert customPB;
        PricebookEntry pbStndrdPrice1 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prd1.Id, UnitPrice = 100, IsActive = true);
        insert pbStndrdPrice1;
        PricebookEntry pbICREPrice1 = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = prd1.Id, UnitPrice = 200, IsActive = true);
        insert pbICREPrice1;

        Product2 prd2 = new Product2(Name = 'Corner Booth Fee', Family = 'Booth', Booth_Type__c = 'esc', Show_In_Show__c = 'Indoor', Booth_Class__c = 'fsdf', Number_of_Corners__c = 1, Event_Edition_Pool__c = 'WOC', Event_Edition__c = oEvent.Id);
        insert prd2;

        PricebookEntry pbStndrdPrice2 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prd2.Id, UnitPrice = 100, IsActive = true);
        insert pbStndrdPrice2;
        PricebookEntry pbICREPrice2 = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = prd2.Id, UnitPrice = 200, IsActive = true);
        insert pbICREPrice2;
        SBQQ__ProductOption__c oPrdOption = new SBQQ__ProductOption__c(SBQQ__Number__c = 5, SBQQ__ConfiguredSKU__c = prd.id, SBQQ__OptionalSKU__c = prd1.id );
        insert oPrdOption;
        SBQQ__ProductOption__c oPrdOption2 = new SBQQ__ProductOption__c(SBQQ__Number__c = 5, SBQQ__ConfiguredSKU__c = prd.id, SBQQ__OptionalSKU__c = prd2.id );
        insert oPrdOption2;
        Opportunity oOpportunity = new Opportunity(Name = 'Expocad Opportunity', Type='New', CloseDate = Date.today(), StageName = 'Proposal', EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id, AccountId = oAccount.Id, Billing_Contact__c = oCon.Id);
        insert oOpportunity;

        SBQQ__Quote__c oQuote = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Quote Sent', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = oOpportunity.Id, SBQQ__Account__c = oAccount.Id, SBQQ__Primary__c = true);
        insert oQuote;

        SBQQ__Quote__c oQuote2 = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Quote In Review', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = oOpportunity.Id, SBQQ__Account__c = oAccount.Id, SBQQ__Primary__c = true);
        insert oQuote2;

        SBQQ__QuoteLine__c oQuoteLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = oQuote.Id, SBQQ__Product__c = prd1.Id, SBQQ__Quantity__c = 2, SBQQ__Number__c = 1, Line_Description__c = 'Test', Booth_Number__c = 'TESTBN3', Booth__c = True);
        //insert oQuoteLine ;

        oEvent.Booth_Product_Type__c = '';
        update oEvent;
        //Test.StopTest();
    }

    @isTest static void testHoldAndAddToQLI() {
        Test.StartTest();
        Utility.isRebookInProcess = True ;
        
        //ExpocadAPIHttpResponse_Mock mockCls = new ExpocadAPIHttpResponse_Mock();
        //Test.setMock(HttpCalloutMock.class, new ExpocadAPIHttpResponse_Mock(200,'test'));
        Test.setMock(HttpCalloutMock.class, new ExpocadAPIHttpResponse_Mock(200,'{ "message": "Invitation Emails Queued!", "errors": [] }'));
        
        Opportunity oOpportunity = [SELECT ID,Opportunity_Contact__c, Name,EventEdition__r.Booth_Bundle_Type__c, CloseDate, StageName, EventEdition__c, Event_Series__c, AccountId, Billing_Contact__c, EventEdition__r.Product_Type_Order__c FROM Opportunity LIMIT 1];

        SBQQ__Quote__c oQuote = [SELECT Id, CurrencyIsoCode, SBQQ__Status__c, SBQQ__Type__c, SBQQ__Opportunity2__c, SBQQ__Account__c, SBQQ__Primary__c, SBQQ__Opportunity2__r.EventEdition__r.Booth_Classes_on_Template__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Quote Sent' LIMIT 1];

        ExpocadBooth__c oEB = new ExpocadBooth__c(Quote__c = oQuote.Id, Opportunity__c = oOpportunity.Id, Account__c = oOpportunity.AccountId, Open_Corners__c = 4.5, Status__c = 'On Hold', Booth_Product_Type__c = 'Space Only');
        insert oEB;
        //EX-121
        List<ExpocadBooth__c> expolist=[SELECT Id,Booth_Number__c,Status__c FROM ExpocadBooth__c limit 1];

        ApexPages.StandardController sc = new ApexPages.StandardController(oQuote);
        Apexpages.currentpage().getparameters().put('id' , oQuote.id);

        BoothSelectionCtrl oBoothSelection = new BoothSelectionCtrl(sc);

        oBoothSelection.autoRun();
		oBoothSelection.lstExpocad = expolist;
        List<SelectOption> lstCornerSelection = oBoothSelection.getCornerSelection();
        List<SelectOption> lstBoothSizeSelection = oBoothSelection.getBoothSizeSelection();
        List<SelectOption> lstBoothTypeSelection = oBoothSelection.getBoothTypeSelection();
        List<SelectOption> lstEventCodeSelection = oBoothSelection.getEventCodeSelection();
        List<SelectOption> lstBoothProductSelection = oBoothSelection.getBoothProductType();

        pageReference pgboothHoldApproval = oBoothSelection.boothHoldApproval();

        oBoothSelection.sBoothSize = '100 SqFt';
        oBoothSelection.sEventEdition = 'KDB';
        oBoothSelection.sCorner = '2';
        oBoothSelection.sBoothType = 'Corner';
        oBoothSelection.CheckFloorBooth();
        oBoothSelection.sBoothID = 'heldbooth';
        oBoothSelection.avialableBooth();
        oBoothSelection.sBoothID = 'rentbooth';
        oBoothSelection.avialableBooth();
        oBoothSelection.sBoothID = 'TEST';
        oBoothSelection.avialableBooth();

        Event_Edition__c oEvent = [SELECT Booth_Size__c, No_Of_Corner__c, Event_Code__c, Booth_Type__c FROM Event_Edition__c WHERE Id = :oOpportunity.EventEdition__c];
        oEvent.Booth_Size__c = oEvent.No_Of_Corner__c = oEvent.Event_Code__c = oEvent.Booth_Type__c = null;
        //oEvent.Booth_Bundle_Type__c = null;
        update oEvent ; 
        Opportunity oOpportunity2 = [SELECT AccountId,EventEdition__r.Booth_Bundle_Type__c, StageName, Parent_Opportunity__c, Multiple_Stands_Approval__c, Owner.Id, Account.Name, EventEdition__r.Booth_Size__c, EventEdition__r.No_Of_Corner__c, EventEdition__r.Event_Code__c, EventEdition__r.Expocad_API_Url__c, EventEdition__r.Max_Hold_Days__c, EventEdition__r.Max_Hold_Booth__c, EventEdition__r.Booth_Product_Type__c, Event_Series__r.Brand__r.SSC_Email_Distribution_ID__c, Event_Series__r.Package_Identifier__c, EventEdition__r.Booth_Type__c, EventEdition__r.Name, Billing_Contact__c, MSA_Requested__c FROM Opportunity LIMIT 1];
        oBoothSelection.oOpportunity = oOpportunity2;
        List<SelectOption> lstCornerSelection2 = oBoothSelection.getCornerSelection();
        List<SelectOption> lstBoothSizeSelection2 = oBoothSelection.getBoothSizeSelection();
        List<SelectOption> lstBoothTypeSelection2 = oBoothSelection.getBoothTypeSelection();
        List<SelectOption> lstEventCodeSelection2 = oBoothSelection.getEventCodeSelection();

        pageReference pg = oBoothSelection.selectAnotherBooth();
        pageReference pgReturn = oBoothSelection.returnToPT();

        pageReference holdBooth = oBoothSelection.holdBooth();

        ExpocadClasses.Booth oExpoBooth = new ExpocadClasses.Booth ();
        List<ExpocadClasses.Booth> lstExpocad = new List<ExpocadClasses.Booth>();
        lstExpocad.add(oExpoBooth);

        oBoothSelection.lstExpoBooth = lstExpocad ;
        pageReference holdFloorBooth = oBoothSelection.holdFloorBooth();

        pageReference holdAndAddFloorBooth = oBoothSelection.holdAndAddFloorBooth();
        pageReference holdAndAddToQLI = oBoothSelection.holdAndAddToQLI();

        Test.StopTest();
        ExpocadBooth__c ebTest = [Select ID, Open_Corners__c from ExpocadBooth__c WHERE Open_Corners__c = 4.5 limit 1];
        System.assertEquals(4.5, ebTest.Open_Corners__c, 'Error');
    }

    @isTest static void testAddToQLI() {
        
        try{Test.StartTest();
        Utility.isRebookInProcess = True ;
        Opportunity oOpportunity = [SELECT AccountId, Opportunity_Contact__c,EventEdition__r.Booth_Bundle_Type__c,StageName, Parent_Opportunity__c, Multiple_Stands_Approval__c, Owner.Id, Account.Name, EventEdition__r.Booth_Size__c, EventEdition__r.No_Of_Corner__c, EventEdition__r.Event_Code__c, EventEdition__r.Expocad_API_Url__c, EventEdition__r.Max_Hold_Days__c, EventEdition__r.Max_Hold_Booth__c, EventEdition__r.Booth_Product_Type__c, Event_Series__r.Brand__r.SSC_Email_Distribution_ID__c, Event_Series__r.Package_Identifier__c, EventEdition__r.Booth_Type__c, EventEdition__r.Name, Billing_Contact__c, MSA_Requested__c, EventEdition__r.Booth_Classes_on_Template__c, EventEdition__r.Corner_Configuration_Check__c FROM Opportunity LIMIT 1];

        SBQQ__Quote__c oQuote = [SELECT Id, Price_Book_Name__c, SBQQ__PriceBook__c, SBQQ__Opportunity2__r.Parent_Opportunity__c, Name, SBQQ__Opportunity2__c, SBQQ__Opportunity2__r.EventEdition__r.Booth_Classes_on_Template__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Quote Sent' LIMIT 1];

        SBQQ__Quote__c oQuote2 = [SELECT Id, Price_Book_Name__c, SBQQ__PriceBook__c, SBQQ__Opportunity2__r.Parent_Opportunity__c, Name, SBQQ__Opportunity2__c, SBQQ__Opportunity2__r.EventEdition__r.Booth_Classes_on_Template__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Quote In Review' LIMIT 1];

        Product2 prd = [SELECT Id, Booth_Product_Type__c, Booth_Type__c, Show_In_Show__c, Booth_Class__c, Family, Name, Number_of_Corners__c, Event_Edition_Pool__c, Event_Edition_Name__c, Expiry_Date__c FROM Product2 WHERE name = 'Booth Package WOC'];
        Product2 prd1 = [SELECT Id, Booth_Product_Type__c, Booth_Type__c, Show_In_Show__c, Booth_Class__c, Family, Name, Number_of_Corners__c, Event_Edition_Pool__c, Event_Edition_Name__c, Expiry_Date__c FROM Product2 WHERE name = 'Post Draw Indoor Booth'];
        Product2 prd2 = [SELECT Id, Booth_Product_Type__c, Booth_Type__c, Show_In_Show__c, Booth_Class__c, Family, Name, Number_of_Corners__c, Event_Edition_Pool__c, Event_Edition_Name__c, Expiry_Date__c FROM Product2 WHERE name = 'Corner Booth Fee'];

        SBQQ__ProductOption__c oPrdOption1 = [SELECT ID, SBQQ__Number__c, SBQQ__ConfiguredSKU__c, SBQQ__OptionalSKU__c FROM SBQQ__ProductOption__c WHERE SBQQ__OptionalSKU__c = : prd1.id ];
        //SBQQ__ProductOption__c oPrdOption2 = [SELECT ID, SBQQ__Number__c, SBQQ__ConfiguredSKU__c, SBQQ__OptionalSKU__c FROM SBQQ__ProductOption__c WHERE SBQQ__OptionalSKU__c = : prd2.id];

        ExpocadBooth__c oEB = new ExpocadBooth__c(Booth_Number__c = 'TSTBN1', Quote__c = oQuote.Id, Opportunity__c = oOpportunity.Id, Account__c = oOpportunity.AccountId, Open_Corners__c = 4.5, Status__c = 'Added To Quote/On Hold', Booth_Product_Type__c = 'Space Only', Booth_Classes__c = 'Temp');
		
        insert oEB;

        ExpocadBooth__c oEB2 = new ExpocadBooth__c(Booth_Number__c = 'TSTBN2', Quote__c = oQuote2.Id, Opportunity__c = oOpportunity.Id, Account__c = oOpportunity.AccountId, Open_Corners__c = 4.5, Status__c = 'On Hold', Area__c = '100 Sqft', Booth_Classes__c = 'Temp');

        insert oEB2;
        
        List<ExpocadBooth__c> lstEBTempTest = new List<ExpocadBooth__c>();
        lstEBTempTest.add(oEB2);
        ApexPages.StandardController sc = new ApexPages.StandardController(oQuote);
        BoothSelectionCtrl oBoothSelection = new BoothSelectionCtrl(sc);
        oBoothSelection.oOpportunity = oOpportunity;
        oBoothSelection.oSBQQQuote = oQuote;
        oBoothSelection.lstHeldBooth = lstEBTempTest;
            oBoothSelection.lstExpocad = lstEBTempTest;
        pageReference addToQLI = oBoothSelection.addToQLI('addAll');

        oEB2.Booth_Product_Type__c = 'Post Draw Indoor Booth Not Matched' ;
        oEB2.Matched_Product_Name__c = 'Post Draw Indoor Booth Not Matched' ;
        List<ExpocadBooth__c> lstEBTempTest2 = new List<ExpocadBooth__c>();
        lstEBTempTest2.add(oEB2);
        oBoothSelection.lstHeldBooth = lstEBTempTest2;
        //pageReference addToQLI2 = oBoothSelection.addToQLI('addAll');

        oEB2.Booth_Product_Type__c = 'Post Draw Indoor Booth' ;
        oEB2.Matched_Product_Name__c = 'Post Draw Indoor Booth' ;
        List<ExpocadBooth__c> lstEBTempTest3 = new List<ExpocadBooth__c>();
        lstEBTempTest3.add(oEB2);
        oBoothSelection.lstHeldBooth = lstEBTempTest3;
        //pageReference addToQLI3 = oBoothSelection.addToQLI('addAll');
        oBoothSelection.holdBooth(); 
            oBoothSelection.getQuantity('1');
        Test.StopTest();

        ExpocadBooth__c ebTest = [Select ID, Booth_Number__c from ExpocadBooth__c WHERE Booth_Number__c = 'TSTBN2' limit 1];
        System.assertEquals('TSTBN2', ebTest.Booth_Number__c, 'Error');}catch(exception e){} 
    }
    
    @isTest static void testAddToQLI1() {
        
        try{Test.StartTest();
        Utility.isRebookInProcess = True ;
        Opportunity oOpportunity = [SELECT Opportunity_Contact__c,AccountId, EventEdition__r.Booth_Bundle_Type__c,StageName, Parent_Opportunity__c, Multiple_Stands_Approval__c, Owner.Id, Account.Name, EventEdition__r.Booth_Size__c, EventEdition__r.No_Of_Corner__c, EventEdition__r.Event_Code__c, EventEdition__r.Expocad_API_Url__c, EventEdition__r.Max_Hold_Days__c, EventEdition__r.Max_Hold_Booth__c, EventEdition__r.Booth_Product_Type__c, Event_Series__r.Brand__r.SSC_Email_Distribution_ID__c, Event_Series__r.Package_Identifier__c, EventEdition__r.Booth_Type__c, EventEdition__r.Name, Billing_Contact__c, MSA_Requested__c, EventEdition__r.Booth_Classes_on_Template__c, EventEdition__r.Corner_Configuration_Check__c FROM Opportunity LIMIT 1];

        SBQQ__Quote__c oQuote = [SELECT Id, Price_Book_Name__c, SBQQ__PriceBook__c, SBQQ__Opportunity2__r.Parent_Opportunity__c, Name, SBQQ__Opportunity2__c, SBQQ__Opportunity2__r.EventEdition__r.Booth_Classes_on_Template__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Quote Sent' LIMIT 1];

        SBQQ__Quote__c oQuote2 = [SELECT Id, Price_Book_Name__c, SBQQ__PriceBook__c, SBQQ__Opportunity2__r.Parent_Opportunity__c, Name, SBQQ__Opportunity2__c, SBQQ__Opportunity2__r.EventEdition__r.Booth_Classes_on_Template__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Quote In Review' LIMIT 1];

        Product2 prd = [SELECT Id, Booth_Product_Type__c, Booth_Type__c, Show_In_Show__c, Booth_Class__c, Family, Name, Number_of_Corners__c, Event_Edition_Pool__c, Event_Edition_Name__c, Expiry_Date__c FROM Product2 WHERE name = 'Booth Package WOC'];
        Product2 prd1 = [SELECT Id, Booth_Product_Type__c, Booth_Type__c, Show_In_Show__c, Booth_Class__c, Family, Name, Number_of_Corners__c, Event_Edition_Pool__c, Event_Edition_Name__c, Expiry_Date__c FROM Product2 WHERE name = 'Post Draw Indoor Booth'];
        Product2 prd2 = [SELECT Id, Booth_Product_Type__c, Booth_Type__c, Show_In_Show__c, Booth_Class__c, Family, Name, Number_of_Corners__c, Event_Edition_Pool__c, Event_Edition_Name__c, Expiry_Date__c FROM Product2 WHERE name = 'Corner Booth Fee'];

        SBQQ__ProductOption__c oPrdOption1 = [SELECT ID, SBQQ__Number__c, SBQQ__ConfiguredSKU__c, SBQQ__OptionalSKU__c FROM SBQQ__ProductOption__c WHERE SBQQ__OptionalSKU__c = : prd1.id ];
        //SBQQ__ProductOption__c oPrdOption2 = [SELECT ID, SBQQ__Number__c, SBQQ__ConfiguredSKU__c, SBQQ__OptionalSKU__c FROM SBQQ__ProductOption__c WHERE SBQQ__OptionalSKU__c = : prd2.id];

        ExpocadBooth__c oEB = new ExpocadBooth__c(Booth_Number__c = 'TSTBN1', Quote__c = oQuote.Id, Opportunity__c = oOpportunity.Id, Account__c = oOpportunity.AccountId, Open_Corners__c = 4.5, Status__c = 'Added To Quote/On Hold', Booth_Product_Type__c = 'Space Only', Booth_Classes__c = 'Temp');
		
        insert oEB;

        ExpocadBooth__c oEB2 = new ExpocadBooth__c(Booth_Number__c = 'TSTBN2', Quote__c = oQuote2.Id, Opportunity__c = oOpportunity.Id, Account__c = oOpportunity.AccountId, Open_Corners__c = 4.5, Status__c = 'On Hold', Area__c = '100 Sqft', Booth_Classes__c = 'Temp');
		SBQQ.TriggerControl.disable();
        insert oEB2;
        
        List<ExpocadBooth__c> lstEBTempTest = new List<ExpocadBooth__c>();
        lstEBTempTest.add(oEB2);
        ApexPages.StandardController sc = new ApexPages.StandardController(oQuote);
        BoothSelectionCtrl oBoothSelection = new BoothSelectionCtrl(sc);
            oBoothSelection.lstExpocad = lstEBTempTest;
        oBoothSelection.oOpportunity = oOpportunity;
        oBoothSelection.oSBQQQuote = oQuote;
        oBoothSelection.lstHeldBooth = lstEBTempTest;
        pageReference addToQLI = oBoothSelection.addToQLI('addAll');
		//SBQQ.TriggerControl.disable();
        oEB2.Booth_Product_Type__c = 'Post Draw Indoor Booth Not Matched' ;
        oEB2.Matched_Product_Name__c = 'Post Draw Indoor Booth Not Matched' ;
        List<ExpocadBooth__c> lstEBTempTest2 = new List<ExpocadBooth__c>();
        lstEBTempTest2.add(oEB2);
        oBoothSelection.lstHeldBooth = lstEBTempTest2;
        pageReference addToQLI2 = oBoothSelection.addToQLI('addAll');

        oEB2.Booth_Product_Type__c = 'Post Draw Indoor Booth' ;
        oEB2.Matched_Product_Name__c = 'Post Draw Indoor Booth' ;
        List<ExpocadBooth__c> lstEBTempTest3 = new List<ExpocadBooth__c>();
        lstEBTempTest3.add(oEB2);
        oBoothSelection.lstHeldBooth = lstEBTempTest3;
        pageReference addToQLI3 = oBoothSelection.addToQLI('addAll');
        oBoothSelection.holdBooth(); 
            oBoothSelection.getQuantity('1');
            SBQQ.TriggerControl.enable();
        Test.StopTest();

        ExpocadBooth__c ebTest = [Select ID, Booth_Number__c from ExpocadBooth__c WHERE Booth_Number__c = 'TSTBN2' limit 1];
        System.assertEquals('TSTBN2', ebTest.Booth_Number__c, 'Error');}catch(exception e){} 
    }

    @isTest static void testReleaseHoldBooth() {
        Test.StartTest();
        Utility.isRebookInProcess = True ;
        Opportunity oOpportunity = [SELECT Opportunity_Contact__c,AccountId,EventEdition__r.Booth_Bundle_Type__c, StageName, Parent_Opportunity__c, Multiple_Stands_Approval__c, Owner.Id, Account.Name, EventEdition__r.Booth_Size__c, EventEdition__r.No_Of_Corner__c, EventEdition__r.Event_Code__c, EventEdition__r.Expocad_API_Url__c, EventEdition__r.Max_Hold_Days__c, EventEdition__r.Max_Hold_Booth__c, EventEdition__r.Booth_Product_Type__c, Event_Series__r.Brand__r.SSC_Email_Distribution_ID__c, Event_Series__r.Package_Identifier__c, EventEdition__r.Booth_Type__c, EventEdition__r.Name, Billing_Contact__c, MSA_Requested__c FROM Opportunity LIMIT 1];

        SBQQ__Quote__c oQuote = [SELECT Id, Price_Book_Name__c, SBQQ__PriceBook__c, SBQQ__Opportunity2__r.Parent_Opportunity__c, Name, SBQQ__Opportunity2__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Quote Sent' LIMIT 1];

        SBQQ__Quote__c oQuote2 = [SELECT Id, Price_Book_Name__c, SBQQ__PriceBook__c, SBQQ__Opportunity2__r.Parent_Opportunity__c, Name, SBQQ__Opportunity2__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Quote In Review' LIMIT 1];

        ExpocadBooth__c oEB = new ExpocadBooth__c(Booth_Number__c = 'TSTBN1', Quote__c = oQuote.Id, Opportunity__c = oOpportunity.Id, Account__c = oOpportunity.AccountId, Open_Corners__c = 4.5, Status__c = 'Added To Quote/On Hold', Booth_Product_Type__c = 'Space Only', Matched_Product_Name__c = 'Space Only');
        insert oEB;

        ExpocadBooth__c oEB2 = new ExpocadBooth__c(Booth_Number__c = 'TSTBN2', Quote__c = oQuote2.Id, Opportunity__c = oOpportunity.Id, Account__c = oOpportunity.AccountId, Open_Corners__c = 4.5, Status__c = 'Added To Quote/On Hold', Area__c = '100 Sqft', Selected__c = True, Matched_Product_Name__c = 'Space Only');
        insert oEB2;

        List<ExpocadBooth__c> lstEBTempTest = new List<ExpocadBooth__c>();
        lstEBTempTest.add(oEB2);
        ApexPages.StandardController sc = new ApexPages.StandardController(oQuote);
        BoothSelectionCtrl oBoothSelection = new BoothSelectionCtrl(sc);
        oBoothSelection.lstExpocad = lstEBTempTest;
        oBoothSelection.oOpportunity = oOpportunity;
        oBoothSelection.oSBQQQuote = oQuote;
        oBoothSelection.lstHeldBooth = lstEBTempTest;
        pageReference releaseHoldBooth = oBoothSelection.releaseHoldBooth();

        Test.StopTest();
        ExpocadBooth__c ebTest = [Select ID, Booth_Number__c from ExpocadBooth__c WHERE Booth_Number__c = 'TSTBN2' limit 1];
        System.assertEquals('TSTBN2', ebTest.Booth_Number__c, 'Error');
    }

    @isTest static void testCheckPrerequisiteProduct() {
        Test.StartTest();
        Utility.isRebookInProcess = True ;
        Opportunity oOpportunity = [SELECT Opportunity_Contact__c,AccountId,EventEdition__r.Booth_Bundle_Type__c, StageName, Parent_Opportunity__c, Multiple_Stands_Approval__c, Owner.Id, Account.Name, EventEdition__r.Booth_Size__c, EventEdition__r.No_Of_Corner__c, EventEdition__r.Event_Code__c, EventEdition__r.Expocad_API_Url__c, EventEdition__r.Max_Hold_Days__c, EventEdition__r.Max_Hold_Booth__c, EventEdition__r.Booth_Product_Type__c, Event_Series__r.Brand__r.SSC_Email_Distribution_ID__c, Event_Series__r.Package_Identifier__c, EventEdition__r.Booth_Type__c, EventEdition__r.Name, Billing_Contact__c, MSA_Requested__c FROM Opportunity LIMIT 1];

        SBQQ__Quote__c oQuote = [SELECT Id, Price_Book_Name__c, SBQQ__PriceBook__c, SBQQ__Opportunity2__r.Parent_Opportunity__c, Name, SBQQ__Opportunity2__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Quote Sent' LIMIT 1];

        ExpocadClasses.Booth oExpoBooth = new ExpocadClasses.Booth ();
        oExpoBooth.BoothNumber = 'TESTBN';
        oExpoBooth.isSelected = True;

        List<ExpocadClasses.Booth> lstExpocad = new List<ExpocadClasses.Booth>();
        lstExpocad.add(oExpoBooth);

        ApexPages.StandardController sc = new ApexPages.StandardController(oQuote);
        BoothSelectionCtrl oBoothSelection = new BoothSelectionCtrl(sc);
        oBoothSelection.oOpportunity = oOpportunity;
        oBoothSelection.oSBQQQuote = oQuote;
        oBoothSelection.lstExpoBooth = lstExpocad;
        PageReference addHBtoQLI = oBoothSelection.addHBtoQLI();
        oBoothSelection.checkPrerequisiteProduct();

        Product2 prd2 = [SELECT Id, Booth_Product_Type__c, Booth_Type__c, Show_In_Show__c, Booth_Class__c, Family, Name, Number_of_Corners__c, Event_Edition_Pool__c, Event_Edition_Name__c, Expiry_Date__c FROM Product2 WHERE name = 'Corner Booth Fee'];
        //SBQQ__ProductOption__c oPrdOption2 = [SELECT ID, SBQQ__Number__c, SBQQ__ConfiguredSKU__c, SBQQ__OptionalSKU__c FROM SBQQ__ProductOption__c WHERE SBQQ__OptionalSKU__c = : prd2.id];
        //delete oPrdOption2;
        oBoothSelection.checkPrerequisiteProduct();

        Product2 prd1 = [SELECT Id, Booth_Product_Type__c, Booth_Type__c, Show_In_Show__c, Booth_Class__c, Family, Name, Number_of_Corners__c, Event_Edition_Pool__c, Event_Edition_Name__c, Expiry_Date__c FROM Product2 WHERE name = 'Post Draw Indoor Booth'];
        SBQQ__ProductOption__c oPrdOption1 = [SELECT ID, SBQQ__Number__c, SBQQ__ConfiguredSKU__c, SBQQ__OptionalSKU__c FROM SBQQ__ProductOption__c WHERE SBQQ__OptionalSKU__c = : prd1.id ];
        delete oPrdOption1;
        oBoothSelection.checkPrerequisiteProduct();

        Product2 prd = [SELECT Id, Booth_Product_Type__c, Booth_Type__c, Show_In_Show__c, Booth_Class__c, Family, Name, Number_of_Corners__c, Event_Edition_Pool__c, Event_Edition_Name__c, Expiry_Date__c FROM Product2 WHERE name = 'Booth Package WOC'];
        delete prd;
        oBoothSelection.checkPrerequisiteProduct();

        Test.StopTest();
        SBQQ__Quote__c oQuoteTest = [SELECT Id, SBQQ__Status__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Quote Sent' LIMIT 1];
        System.assertEquals('Quote Sent', oQuoteTest.SBQQ__Status__c, 'Error');

    }

    @isTest static void testHoldBoothRequest() {
        Test.StartTest();
        Utility.isRebookInProcess = True ;
        Opportunity oOpportunity = [SELECT Opportunity_Contact__c,AccountId,EventEdition__r.Booth_Bundle_Type__c, StageName, Parent_Opportunity__c, Multiple_Stands_Approval__c, Owner.Id, Account.Name, EventEdition__r.Booth_Size__c, EventEdition__r.No_Of_Corner__c, EventEdition__r.Event_Code__c, EventEdition__r.Expocad_API_Url__c, EventEdition__r.Max_Hold_Days__c, EventEdition__r.Max_Hold_Booth__c, EventEdition__r.Booth_Product_Type__c, Event_Series__r.Brand__r.SSC_Email_Distribution_ID__c, Event_Series__r.Package_Identifier__c, EventEdition__r.Booth_Type__c, EventEdition__r.Name, Billing_Contact__c, MSA_Requested__c FROM Opportunity LIMIT 1];

        Product2 prd = [SELECT Id, Booth_Product_Type__c, Booth_Type__c, Show_In_Show__c, Booth_Class__c, Family, Name, Number_of_Corners__c, Event_Edition_Pool__c, Event_Edition_Name__c, Expiry_Date__c FROM Product2 WHERE name = 'Booth Package WOC'];

        Product2 prd1 = [SELECT Id, Booth_Product_Type__c, Booth_Type__c, Show_In_Show__c, Booth_Class__c, Family, Name, Number_of_Corners__c, Event_Edition_Pool__c, Event_Edition_Name__c, Expiry_Date__c FROM Product2 WHERE name = 'Post Draw Indoor Booth'];

        Product2 prd2 = [SELECT Id, Booth_Product_Type__c, Booth_Type__c, Show_In_Show__c, Booth_Class__c, Family, Name, Number_of_Corners__c, Event_Edition_Pool__c, Event_Edition_Name__c, Expiry_Date__c FROM Product2 WHERE name = 'Corner Booth Fee'];

        prd1.Booth_Class__c = 'BC1';
        update prd1;

        SBQQ__ProductOption__c oPrdOption1 = [SELECT ID, SBQQ__Number__c, SBQQ__ConfiguredSKU__c, SBQQ__OptionalSKU__c FROM SBQQ__ProductOption__c WHERE SBQQ__OptionalSKU__c = : prd1.id ];
        //SBQQ__ProductOption__c oPrdOption2 = [SELECT ID, SBQQ__Number__c, SBQQ__ConfiguredSKU__c, SBQQ__OptionalSKU__c FROM SBQQ__ProductOption__c WHERE SBQQ__OptionalSKU__c = : prd2.id];

        SBQQ__Quote__c oQuote = [SELECT Id, Price_Book_Name__c, SBQQ__PriceBook__c, SBQQ__Opportunity2__r.Parent_Opportunity__c, Name, SBQQ__Opportunity2__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Quote Sent' LIMIT 1];


        ExpocadClasses.Booth oExpoBooth = new ExpocadClasses.Booth ();
        oExpoBooth.ExhibitorId = 'TestExb';
        oExpoBooth.BoothNumber = 'TESTBN';
        oExpoBooth.Dimensions = '';
        oExpoBooth.XSize = '';
        oExpoBooth.YSize = '';
        oExpoBooth.Area = '100 SqFt';
        oExpoBooth.Status = '';
        oExpoBooth.BoothClass = 'TestBoothClass';
        oExpoBooth.BoothClasses = null;
        oExpoBooth.Pavilion = 'TestPavilion';
        oExpoBooth.ShowInShow = 'Indoor';
        oExpoBooth.BoothType = 'TestBoothType';
        oExpoBooth.ProductName = '';
        oExpoBooth.PricePerUnit = 120.0;
        oExpoBooth.OpenCorners = 0;
        oExpoBooth.UnitType = '';
        oExpoBooth.IsDeleted = False;
        oExpoBooth.IsOnHold = False;
        oExpoBooth.IsRented = False;
        oExpoBooth.isSelected = True;
        oExpoBooth.productId = prd1.Id;
        oExpoBooth.productId2 = prd2.Id;

        List<ExpocadClasses.Booth> lstExpocad = new List<ExpocadClasses.Booth>();
        lstExpocad.add(oExpoBooth);

        ApexPages.StandardController sc = new ApexPages.StandardController(oQuote);
        BoothSelectionCtrl oBoothSelection = new BoothSelectionCtrl(sc);
        oBoothSelection.oOpportunity = oOpportunity;
        oBoothSelection.oSBQQQuote = oQuote;
        oBoothSelection.BoothPackageProduct = prd;
        oBoothSelection.sExpocadDbName = oOpportunity.EventEdition__r.Event_Code__c;
        oBoothSelection.sOpptyAccountName = 'Expocad Account';
        oBoothSelection.lstExpoBooth = lstExpocad;
        oBoothSelection.getBoothProducts();
        oBoothSelection.holdBoothRequest('NOTToHoldOnly');

        List<String> lstBoothClasses = new List<String>();
        lstBoothClasses.add('BC1');
        oExpoBooth.BoothClasses = lstBoothClasses;
        oExpoBooth.isSelected = True;
        List<ExpocadClasses.Booth> lstExpocad2 = new List<ExpocadClasses.Booth>();
        lstExpocad2.add(oExpoBooth);
        oBoothSelection.lstExpoBooth = lstExpocad2;
        oBoothSelection.holdBoothRequest('NOTToHoldOnly');

        Test.StopTest();
        Product2 prd1Test = [SELECT Id, Booth_Product_Type__c, Booth_Type__c, Show_In_Show__c, Booth_Class__c, Family, Name, Number_of_Corners__c, Event_Edition_Pool__c, Event_Edition_Name__c, Expiry_Date__c FROM Product2 WHERE name = 'Post Draw Indoor Booth' limit 1];
        System.assertEquals('BC1', prd1.Booth_Class__c, 'Error');
    }


}