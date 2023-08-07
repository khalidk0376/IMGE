/**
* Project:             GAP
* Date:                Dec 4, 2018
* Created By:          Avinash Shukla
* Test Class For:      Association_Eb_CtrlEnh.cls.
* Code Coverage:       85%
* *************************************************************************
* Description:         Test class for Association_Eb_CtrlEnh.
* *************************************************************************
* History: [Aishwarya BK-3751 17 Aug 2020]
*/
@isTest
public class Association_EB_CtrlEnh_Test {
    
    //Common test setup Data.
    @testSetup static void testSetupData() {
        Utility.isRebookInProcess = True;
        Account oAccount = new Account(Name = 'Expocad Account', CurrencyIsoCode = 'USD',BillingCity='US',Billingstate='New York',BillingCountry='USA',BillingStreet='st thomas',BillingPostalCode='10001');
        insert oAccount;
        
        Contact oCon = new Contact(LastName = 'ContTest1', Email = 'test1contact@duptest.com', AccountId = oAccount.Id, MailingStreet = 'Test', MailingCity = 'Test', MailingState='',MailingCountry='India');
        insert oCon;
        
        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Event_Edition_Pool__c = 'WOC');
        insert oEventseries;
        
        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017', Tab7__c = 'Test',Tab1__c = 'Test', Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = 'Barter Shell Scheme', Start_Date__c = Date.today(),Part_of_Series__c = oEventseries.id);
        insert oEvent;
        
        Opportunity oOpportunity = new Opportunity(Name = 'Expocad Opportunity', CloseDate = Date.today(), StageName = 'Proposal', EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id, AccountId = oAccount.Id, Billing_Contact__c = oCon.Id,Exhibitor_Paid_By__c = 'Exhibitor Paid by Exhibitor', Type = 'New Business');
        insert oOpportunity;       
        
        SBQQ__Quote__c oQuote = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Quote Sent', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = oOpportunity.Id, SBQQ__Account__c = oAccount.Id, SBQQ__Primary__c = true);
        insert oQuote;
        
        Opportunity oOpportunityRel = new Opportunity(Name = 'Expocad Opportunity Related', Parent_Opportunity__c = oOpportunity.Id,CloseDate = Date.today(), StageName = 'Proposal', EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id, AccountId = oAccount.Id, Billing_Contact__c = oCon.Id,Exhibitor_Paid_By__c = 'Exhibitor Paid by Exhibitor' , Type = 'New Business');
        insert oOpportunityRel;
        
        SBQQ__Quote__c oQuoteRel = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Quote Sent', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = oOpportunityRel.Id, SBQQ__Account__c = oAccount.Id, SBQQ__Primary__c = true);
        insert oQuoteRel;
        
        ExpocadBooth__c oEB = new ExpocadBooth__c(Selected__c = true, Status__c = 'Rented', Opportunity__c = oOpportunity.Id, Booth_Type__c = 'Corner', ShowInShow__c = 'TestShowInShow', Open_Corners__c = 23, Booth_Classes__c='tset2;;test4', Booth_Product_Type_EE__c = 'Space Only', Area__c = '400 SqFt',Quote__c=oQuote.Id,Pavilion__c='test');
        insert oEB;
        oEB.Booth_Type__c = 'TestBooth';    
        update oEB;
        
        Opportunity_ExpoCAD_Booth_Mapping__c oEM = new Opportunity_ExpoCAD_Booth_Mapping__c(Opportunity__c = oOpportunity.Id, Quote__c=oQuote.Id,Expocad_Booth__c=oEB.ID,Relation__c='Agent');
        insert oEM;
        
        Opportunity_ExpoCAD_Booth_Mapping__c oEM2 = new Opportunity_ExpoCAD_Booth_Mapping__c(Parent_Opp_EB_Mapping__c  = oEM.Id, Opportunity__c = oOpportunityRel.Id, Quote__c=oQuoteRel.Id,Expocad_Booth__c=oEB.ID);
        insert oEM2;
        
        Product2 prd = new Product2(Name = 'Booth Package WOC',Family = 'Booth',Number_of_Corners__c = 0,Booth_Type__c='esc', Show_In_Show__c='Outdoor', Booth_Class__c='fsdf', Event_Edition_Pool__c = 'WOC', Product_Brand__c = 'World of Concrete 2017');
        insert prd;
        
        Pricebook2 customPB2 = new Pricebook2(Name='ICRE', isActive=true);
        insert customPB2;
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry stndrdPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prd.Id,UnitPrice = 100, IsActive = true);
        insert stndrdPrice;
        PricebookEntry iCREPrice = new PricebookEntry(Pricebook2Id = customPB2.Id, Product2Id = prd.Id,UnitPrice = 200, IsActive = true);
        insert iCREPrice;
        
        Product2 prd1 = new Product2(Name = 'Post Draw Indoor Booth',Booth_Product_Type__c ='Space Only',Booth_Type__c='esc', Show_In_Show__c='Outdoor', Booth_Class__c='fsdf',Family = 'Booth',Number_of_Corners__c = 0, Event_Edition_Pool__c = 'WOC', Product_Brand__c = 'World of Concrete 2017', Expiry_Date__c = Date.today());
        insert prd1;
        
        Pricebook2 customPB = new Pricebook2(Name='ICREABC', isActive=true);
        insert customPB;
        PricebookEntry stndrdPrice1 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prd1.Id,UnitPrice = 100, IsActive = true);
        insert stndrdPrice1;
        PricebookEntry iCREPrice1 = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = prd1.Id,UnitPrice = 200, IsActive = true);
        insert iCREPrice1;
        
        Product2 prd2 = new Product2(Name = 'Corner Booth Fee',Family = 'Booth',Booth_Type__c='esc', Show_In_Show__c='Outdoor', Booth_Class__c='fsdf', Number_of_Corners__c = 1, Event_Edition_Pool__c = 'WOC', Product_Brand__c = 'World of Concrete 2017');
        insert prd2;
        
        PricebookEntry stndrdPrice2 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prd2.Id,UnitPrice = 100, IsActive = true);
        insert stndrdPrice2;
        PricebookEntry iCREPrice2 = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = prd2.Id,UnitPrice = 200, IsActive = true);
        insert iCREPrice2;
        /* Commented BK-3751  */
        //SBQQ__ProductOption__c oPrdOption = new SBQQ__ProductOption__c(SBQQ__Number__c = 5,SBQQ__ConfiguredSKU__c = prd.id, SBQQ__OptionalSKU__c = prd1.id );
        //insert oPrdOption;
        SBQQ__ProductOption__c oPrdOption2 = new SBQQ__ProductOption__c(SBQQ__Number__c = 5,SBQQ__ConfiguredSKU__c = prd.id, SBQQ__OptionalSKU__c = prd2.id ,SBQQ__Quantity__c = 1);
        insert oPrdOption2;
        
        SBQQ__QuoteLine__c qLine =   new SBQQ__QuoteLine__c();
        qLine.Booth_Number__c    = '1234';
        qLine.SBQQ__Quantity__c  = 15;
        qLine.SBQQ__Quote__c = oQuote.Id;
        qLine.SBQQ__Product__c=prd.Id; 
        qLine.SBQQ__PricingMethodEditable__c = true;
        qLine.SBQQ__ProductOption__c      = oPrdOption2.Id;
        insert qLine; 
        
        Application_Bypass__c oAB = new Application_Bypass__c(SetupOwnerId=UserInfo.getOrganizationId(), Bypass_Validation_Rules__c = True);
        Insert oAB ;
        
        
    }
    
    static testMethod void testCreateOpptybyNewAccount() {
        Utility.isRebookInProcess = True ;
        Opportunity oOpportunity = [SELECT ID, Name, CloseDate, StageName,  EventEdition__r.Booth_Product_Type__c,EventEdition__c, Event_Series__c, AccountId, Billing_Contact__c FROM Opportunity LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(oOpportunity);
        Account oAccount = [SELECT Id, NAME FROM Account LIMIT 1];
        Apexpages.currentpage().getparameters().put('id', oOpportunity.id);
        Account oAccount2 = new Account(Name = 'Test Account2', CurrencyIsoCode = 'USD',BillingCity='CA',Billingstate='Ontario',BillingCountry='Canada',BillingStreet='st street',BillingPostalCode='10006');
        //System.assertEquals('Expocad Account2', oAccount2.Name, 'Account Not Created');
        Contact oCon1 = new Contact(LastName = 'ContTest2', Email = 'test1contactdr@duptest.com', MailingStreet = 'Test2', MailingCity = 'Test2', MailingState='',MailingCountry='India');
        Association_Eb_CtrlEnh oAssociationEBCtrl = new Association_Eb_CtrlEnh(sc);
        oAssociationEBCtrl.oAccount = oAccount2;
        oAssociationEBCtrl.oContact = oCon1 ;
        oAssociationEBCtrl.sOpptyName = 'Oppty1';
        oAssociationEBCtrl.sOpptyName2 = 'Oppty2';
        oAssociationEBCtrl.sOpptyName3 = 'Oppty3';
        oAssociationEBCtrl.sDisplayName = 'GirikonTestDisplayName';
        List<Account> lstAcc = oAssociationEBCtrl.getAccounts();
        Integer totalAcc = oAssociationEBCtrl.getTotalAccounts();
        oAssociationEBCtrl.FirstPage();
        oAssociationEBCtrl.next();
        oAssociationEBCtrl.previous();
        oAssociationEBCtrl.LastPage();
        Boolean isPrev = oAssociationEBCtrl.getprev();
        Boolean isNext = oAssociationEBCtrl.getnxt();
        oAssociationEBCtrl.unRentedbooth();  
        oAssociationEBCtrl.isLightingEnv = true;
        oAssociationEBCtrl.viewFloorPlan();
        oAssociationEBCtrl.replaceBooth();
        oAssociationEBCtrl.getBoothProducts();
        oAssociationEBCtrl.getQuantity('1');
        oAssociationEBCtrl.createOpptyNewContact();
        oAssociationEBCtrl.checkIsCChasData();
        Test.StartTest();
        pageReference pg1 = oAssociationEBCtrl.createOpptybyNewAccount();
        pageReference pg2 = oAssociationEBCtrl.cancelPopPup();

        
        oAssociationEBCtrl.accountName = 'Expocad Account2';
        lstAcc = oAssociationEBCtrl.getAccounts();
        Test.StopTest();
    }
    
    static testMethod void testCreateOpptybyNewAccountRel() {
        Utility.isRebookInProcess = True ;
        Opportunity oOpportunity = [SELECT ID, Name, CloseDate, EventEdition__r.Booth_Product_Type__c, StageName, EventEdition__c, Event_Series__c, AccountId, Billing_Contact__c FROM Opportunity WHERE Name = 'Expocad Opportunity Related' LIMIT 1 ];
        ApexPages.StandardController sc = new ApexPages.StandardController(oOpportunity);
        Account oAccount = [SELECT Id, NAME FROM Account LIMIT 1];
        Apexpages.currentpage().getparameters().put('id', oOpportunity.id);
        Account oAccount2 = new Account(Name = 'Retest Account2', CurrencyIsoCode = 'USD',BillingCity='CA',Billingstate='Ontario',BillingCountry='Canada',BillingStreet='st street',BillingPostalCode='10006');
       // System.assertEquals('Expocad Account2', oAccount2.Name, 'Account NOt Created');
        Contact oCon1 = new Contact(LastName = 'ContTest2', Email = 'test1contactdr@duptest.com', MailingStreet = 'Test2', MailingCity = 'Test2', MailingState='',MailingCountry='India');
        Association_Eb_CtrlEnh oAssociationEBCtrl = new Association_Eb_CtrlEnh(sc);
        oAssociationEBCtrl.oAccount = oAccount2;
        oAssociationEBCtrl.oContact = oCon1 ;
        oAssociationEBCtrl.sOpptyName = 'Oppty1';
        oAssociationEBCtrl.sOpptyName2 = 'Oppty2';
        oAssociationEBCtrl.sOpptyName3 = 'Oppty3';
        oAssociationEBCtrl.sDisplayName = 'GirikonTestDisplayName';
        List<Account> lstAcc = oAssociationEBCtrl.getAccounts();
        Integer totalAcc = oAssociationEBCtrl.getTotalAccounts();
        oAssociationEBCtrl.FirstPage();
        oAssociationEBCtrl.next();
        oAssociationEBCtrl.previous();
        oAssociationEBCtrl.LastPage();
        Boolean isPrev = oAssociationEBCtrl.getprev();
        Boolean isNext = oAssociationEBCtrl.getnxt();
        oAssociationEBCtrl.unRentedbooth();  
        oAssociationEBCtrl.viewFloorPlan();
        oAssociationEBCtrl.replaceBooth();   
        oAssociationEBCtrl.createRelatedOppty();
        oAssociationEBCtrl.getContact();
        oAssociationEBCtrl.getBoothProductType();
        oAssociationEBCtrl.returnToPT();
        oAssociationEBCtrl.updateDisplayName();
        //oAssociationEBCtrl.getExpocadBoothMapping();
        oAssociationEBCtrl.cornerProductName = 'test';
        Test.StartTest();
       // pageReference pg1 = oAssociationEBCtrl.createOpptybyNewAccount();
        
        Test.StopTest();
        
    }
}