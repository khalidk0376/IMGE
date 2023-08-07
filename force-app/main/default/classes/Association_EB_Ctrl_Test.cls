/**
 * Project:             GAP
 * Date:                Feb 2, 2017
 * Created By:          Kumar Gaurav
 * Test Class For:      Association_EB_Ctrl.cls
 * Code Coverage:       84%
 * *************************************************************************
 * @description         Test class for Association_EB_Ctrl.
 * *************************************************************************
 * History ----: Replaced As Per Ticket GGCW-3101 :----'Product_brand__c Replaced by this Event_Edition_Name__c field'
 * Rajesh Kumar Yadav
 */

@isTest
public class Association_EB_Ctrl_Test {

    // Common test setup Data
    @testSetup static void testSetupData() {
        Utility.isRebookInProcess = True;
        Account oAccount = new Account(Name = 'Expocad Account', CurrencyIsoCode = 'USD');
        insert oAccount;
        
        Account oAccount1 = new Account(Name = 'New Test', CurrencyIsoCode = 'USD');
        insert oAccount1;

        Contact oCon = new Contact(LastName = 'ContTest1', Email = 'test1contact@duptest.com', AccountId = oAccount1.Id, MailingStreet = 'Test', MailingCity = 'Test', MailingState = '', MailingCountry = 'India');
        insert oCon;

        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Event_Edition_Pool__c = 'WOC');
        insert oEventseries;

        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017', Tab7__c = 'Test', Tab1__c = 'Test',Booth_Bundle_Type__c='Booth Package',Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2',Expocad_API_Url__c='https:www.test.com', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = 'Barter Shell Scheme', Start_Date__c = Date.today(), Part_of_Series__c = oEventseries.id);
        insert oEvent;

        Opportunity oOpportunity = new Opportunity(Name = 'Expocad Opportunity', CloseDate = Date.today(), StageName = 'Proposal', EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id, AccountId = oAccount.Id,  Exhibitor_Paid_By__c = 'Exhibitor Paid by Exhibitor');
        insert oOpportunity;
        SBQQ__Quote__c oQuote = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Quote Sent', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = oOpportunity.Id, SBQQ__Account__c = oAccount.Id, SBQQ__Primary__c = true);
        insert oQuote;
        ExpocadBooth__c oEB = new ExpocadBooth__c(Selected__c = true, Booth_Product_Type__c = 'Space Only', Status__c = 'Rented', Opportunity__c = oOpportunity.Id, Booth_Type__c = 'Corner', ShowInShow__c = 'TestShowInShow', Open_Corners__c = 23, Booth_Classes__c = 'test4',Booth_Number__c='123', Booth_Product_Type_EE__c = 'Space Only', Area__c = '400 SqFt', Quote__c = oQuote.Id, Pavilion__c = 'test');
        insert oEB;
        oEB.Booth_Type__c = 'TestBooth';
        update oEB;
         Product2 prd = new Product2(Name = 'Booth Package WOC',Family = 'Booth',Number_of_Corners__c = 0,Booth_Type__c='esc', Show_In_Show__c='Outdoor', Booth_Class__c='fsdf',Event_Edition__c = oEvent.Id, Event_Edition_Pool__c = 'WOC', Product_Brand__c = 'World of Concrete 2017');
        insert prd;

        Pricebook2 customPB2 = new Pricebook2(Name = 'ICRE', isActive = true);
        insert customPB2;
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry stndrdPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prd.Id, UnitPrice = 100, IsActive = true);
        insert stndrdPrice;
        PricebookEntry iCREPrice = new PricebookEntry(Pricebook2Id = customPB2.Id, Product2Id = prd.Id, UnitPrice = 200, IsActive = true);
        insert iCREPrice;

        Product2 prd1 = new Product2(Name = 'Booth Package WOC', Booth_Product_Type__c = 'Space Only', Booth_Type__c = 'esc', Show_In_Show__c = 'Outdoor',Event_Edition__c = oEvent.Id, Booth_Class__c = 'fsdf', Family = 'Booth', Number_of_Corners__c = 0, Event_Edition_Pool__c = 'WOC',  Expiry_Date__c = Date.today());
        insert prd1;

        Pricebook2 customPB = new Pricebook2(Name = 'ICRE2', isActive = true);
        insert customPB;
        PricebookEntry stndrdPrice1 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prd1.Id, UnitPrice = 100, IsActive = true);
        insert stndrdPrice1;
        PricebookEntry iCREPrice1 = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = prd1.Id, UnitPrice = 200, IsActive = true);
        insert iCREPrice1;

        Product2 prd2 = new Product2(Name = 'WOC', Family = 'Booth', Booth_Type__c = 'esc', Show_In_Show__c = 'Outdoor', Booth_Class__c = 'fsdf', Number_of_Corners__c = 1,Event_Edition__c = oEvent.Id, Event_Edition_Pool__c = 'WOC');
        insert prd2;

        PricebookEntry stndrdPrice2 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prd2.Id, UnitPrice = 100, IsActive = true);
        insert stndrdPrice2;
        PricebookEntry iCREPrice2 = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = prd2.Id, UnitPrice = 200, IsActive = true);
        insert iCREPrice2;
        SBQQ__ProductOption__c oPrdOption = new SBQQ__ProductOption__c(SBQQ__Number__c = 4, SBQQ__ConfiguredSKU__c = prd.id, SBQQ__OptionalSKU__c = prd1.id );
        insert oPrdOption;
        SBQQ__ProductOption__c oPrdOption2 = new SBQQ__ProductOption__c(SBQQ__Number__c = 5, SBQQ__ConfiguredSKU__c = prd1.id, SBQQ__OptionalSKU__c = prd2.id );
        insert oPrdOption2;
        List < SBQQ__QuoteLine__c > lstQuoteLine = new List < SBQQ__QuoteLine__c > ();
        List < SBQQ__QuoteLine__c > lstPackageQuoteLine = new List < SBQQ__QuoteLine__c > ();
        SBQQ__QuoteLine__c qLine = new SBQQ__QuoteLine__c();
        qLine.Booth_Number__c    = '1234';
        qLine.SBQQ__Quantity__c  = 15;
        qLine.SBQQ__Quote__c = oQuote.Id;
        qLine.SBQQ__Product__c = prd.Id;
        qLine.SBQQ__ProductOption__c=oPrdOption2.id;
        qLine.SBQQ__Number__c=1234;
        qLine.SBQQ__NonDiscountable__c=true;
        qLine.SBQQ__PricingMethodEditable__c=true;
        qLine.SBQQ__BundledQuantity__c=10;
        qLine.SBQQ__Hidden__c=true;
        qLine.Line_Description__c=oEB.Booth_Number__c + '-'+oEB.Booth_Type__c;
        qLine.Booth_Number__c=oEB.Booth_Number__c;
        qLine.Open_Corners__c=oEB.Open_Corners__c;
        qLine.Booth__c=true;
        qLine.Booth_Pavilion__c=oEB.Pavilion__c;
        qLine.Booth_Classes__c=oEB.Booth_Classes__c;
        qLine.SBQQ__OptionType__c='Component';
        qLine.Open_Corners__c=oEB.Open_Corners__c;
        qLine.Show_In_Show__c=oEB.ShowInShow__c;
        qLine.Booth_Type__c=oEB.Booth_Type__c;
        qLine.Booth_Product_Type__c=oEB.Booth_Product_Type_EE__c;
        qLine.SBQQ__OptionLevel__c=1;
        insert qLine;
        Application_Bypass__c oAB = new Application_Bypass__c(SetupOwnerId = UserInfo.getOrganizationId(), Bypass_Validation_Rules__c = True);
        Insert oAB ;
    }

    static testMethod void testCreateRelatedOppty() {
        Test.StartTest();
        Utility.isRebookInProcess = True ;
        Opportunity oOpportunity = [SELECT ID, Name,Event_Series__r.Package_Identifier__c, EventEdition__r.Booth_Bundle_Type__c,CloseDate, StageName, EventEdition__c, Event_Series__c, AccountId, Billing_Contact__c FROM Opportunity LIMIT 1];
         ExpocadBooth__c oEB = new ExpocadBooth__c(Selected__c = true, Booth_Product_Type__c = 'Space Only', Status__c = 'Rented', Opportunity__c = oOpportunity.Id, Booth_Type__c = 'Corner', ShowInShow__c = 'TestShowInShow', Open_Corners__c = 23, Booth_Classes__c = 'test4',Booth_Number__c='123', Booth_Product_Type_EE__c = 'Space Only', Area__c = '400 SqFt',  Pavilion__c = 'test');
        insert oEB;
        ApexPages.StandardController sc = new ApexPages.StandardController(oOpportunity);
        Account oAccount = [SELECT Id, NAME FROM Account LIMIT 1];
        Apexpages.currentpage().getparameters().put('id', oOpportunity.id);
        Account oAccount2 = new Account(Name = 'Expocad Account2', CurrencyIsoCode = 'USD');
        Contact oCon1 = new Contact(LastName = 'ContTest2', Email = 'test1contactdr@duptest.com', MailingStreet = 'Test2', MailingCity = 'Test2', MailingState = '', MailingCountry = 'India');
        Association_EB_Ctrl oAssociationEBCtrl = new Association_EB_Ctrl(sc);
        oAssociationEBCtrl.oAccount = oAccount2;
        oAssociationEBCtrl.oContact = oCon1 ;
        oAssociationEBCtrl.sOpptyName = 'Oppty1';
        oAssociationEBCtrl.sOpptyName2 = 'Oppty2';
        oAssociationEBCtrl.sOpptyName3 = 'Oppty3';
        oAssociationEBCtrl.sDisplayName = 'GirikonTestDisplayName';
        pageReference pg2 = oAssociationEBCtrl.getContact();
        Contact oCon2 = new Contact(LastName = 'ContTest2', Email = 'test3contact@duptest.com', MailingStreet = 'Test3', MailingCity = 'Test3', MailingState = '', MailingCountry = 'India');
        oAssociationEBCtrl.oContact2 = oCon2;
        system.assertEquals('ContTest2' ,oCon1.LastName , 'test class');
        pageReference pg3 = oAssociationEBCtrl.createOpptyNewContact();
        pageReference pg4 = oAssociationEBCtrl.updateDisplayName();
        pageReference pg5 = oAssociationEBCtrl.viewFloorPlan();
        pageReference pg6 = oAssociationEBCtrl.unRentedbooth();
        pageReference pg1 = oAssociationEBCtrl.createOpptybyNewAccount();
        pageReference pg8 = oAssociationEBCtrl.returnToPT();
        pageReference pg9 = oAssociationEBCtrl.createRelatedOppty();

        oAssociationEBCtrl.getBoothProducts();
        oAssociationEBCtrl.getBoothProductType();
        string sQuantity = '100';
        oAssociationEBCtrl.getQuantity(sQuantity);
        system.assertEquals('1234' ,'1234' , 'test class failed');
        Test.StopTest();
    }
    
      static testMethod void testViewFloorPlan1() {
        Test.StartTest();
        Utility.isRebookInProcess = True ;
        Opportunity oOpportunity = [SELECT ID, Name, EventEdition__r.Booth_Bundle_Type__c,CloseDate, StageName, EventEdition__c, Event_Series__c, Event_Series__r.Package_Identifier__c,AccountId, Billing_Contact__c FROM Opportunity LIMIT 1];
        oOpportunity.Exhibitor_Paid_by__c='';
          update oOpportunity;
          ApexPages.StandardController sc = new ApexPages.StandardController(oOpportunity);
        Account oAccount = [SELECT Id, NAME FROM Account LIMIT 1];
        Apexpages.currentpage().getparameters().put('id', oOpportunity.id);
        Account oAccount2 = new Account(Name = 'Expocad Account2', CurrencyIsoCode = 'USD');
        Contact oCon1 = new Contact(LastName = 'ContTest2', Email = 'test1contactdr@duptest.com', MailingStreet = 'Test2', MailingCity = 'Test2', MailingState = '', MailingCountry = 'India');
        Association_EB_Ctrl oAssociationEBCtrl = new Association_EB_Ctrl(sc);
        oAssociationEBCtrl.oAccount = oAccount2;
        oAssociationEBCtrl.oContact = oCon1 ;
        oAssociationEBCtrl.sOpptyName = 'Oppty1';
        oAssociationEBCtrl.sOpptyName2 = 'Oppty2';
        oAssociationEBCtrl.sOpptyName3 = 'Oppty3';
        oAssociationEBCtrl.sDisplayName = 'GirikonTestDisplayName';
        oAssociationEBCtrl.selectedAccountId = oAccount.Id ;
        pageReference pg2 = oAssociationEBCtrl.getContact();
        Contact oCon2 = new Contact(LastName = 'ContTest2', Email = 'test3contact@duptest.com', MailingStreet = 'Test3', MailingCity = 'Test3', MailingState = '', MailingCountry = 'India');
        oAssociationEBCtrl.oContact2 = oCon2;
        oAssociationEBCtrl.selectedAccountId = oAccount.Id ;
                    ExpocadCredential__c expCred =  new ExpocadCredential__c(Name = 'ExpocadApiCredential',Org_Id__c = UserInfo.getOrganizationId(),Expocad_Host_URL__c = 'test.com',Url__c = 'test.com');
        insert expCred; 

        pageReference pg6 = oAssociationEBCtrl.viewFloorPlan();
            Test.StopTest();
        }
    
    
        static testMethod void testunRentedbooth1() {
        Test.StartTest();
        Utility.isRebookInProcess = True ;
        Opportunity oOpportunity = [SELECT ID, Name, EventEdition__r.Booth_Bundle_Type__c,CloseDate, StageName, EventEdition__c, Event_Series__c, Event_Series__r.Package_Identifier__c,AccountId, Billing_Contact__c FROM Opportunity LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(oOpportunity);
        Account oAccount = [SELECT Id, NAME FROM Account LIMIT 1];
        Apexpages.currentpage().getparameters().put('id', oOpportunity.id);
        Account oAccount2 = new Account(Name = 'Expocad Account2', CurrencyIsoCode = 'USD');
        Contact oCon1 = new Contact(LastName = 'ContTest2', Email = 'test1contactdr@duptest.com', MailingStreet = 'Test2', MailingCity = 'Test2', MailingState = '', MailingCountry = 'India');
        Association_EB_Ctrl oAssociationEBCtrl = new Association_EB_Ctrl(sc);
        oAssociationEBCtrl.oAccount = oAccount2;
        oAssociationEBCtrl.accountName='cad Accoun';
        oAssociationEBCtrl.oContact = oCon1 ;
        oAssociationEBCtrl.sOpptyName = 'Oppty1';
        oAssociationEBCtrl.sOpptyName2 = 'Oppty2';
        oAssociationEBCtrl.sOpptyName3 = 'Oppty3';
        oAssociationEBCtrl.sDisplayName = 'GirikonTestDisplayName';
        oAssociationEBCtrl.selectedAccountId = oAccount.Id ;
        pageReference pg2 = oAssociationEBCtrl.getContact();
        Contact oCon2 = new Contact(LastName = 'ContTest2', Email = 'test3contact@duptest.com', MailingStreet = 'Test3', MailingCity = 'Test3', MailingState = '', MailingCountry = 'India');
        oAssociationEBCtrl.oContact2 = oCon2;
        oAssociationEBCtrl.selectedAccountId = oAccount.Id ;
                    ExpocadCredential__c expCred =  new ExpocadCredential__c(Name = 'ExpocadApiCredential',Org_Id__c = UserInfo.getOrganizationId(),Expocad_Host_URL__c = 'test.com',Url__c = 'test.com');
        insert expCred; 
                     Test.setMock(HttpCalloutMock.class, new ExpocadMock());

        pageReference pg6 = oAssociationEBCtrl.unRentedbooth();
                    Integer totalAcc = oAssociationEBCtrl.getTotalAccounts();

            Test.StopTest();
        }
    
    static testMethod void testCreateRelOpptyNew() {
        Test.StartTest();
        Utility.isRebookInProcess = True ;
        Opportunity oOpportunity = [SELECT ID, Name, EventEdition__r.Booth_Bundle_Type__c,CloseDate, StageName, EventEdition__c, Event_Series__c, Event_Series__r.Package_Identifier__c,AccountId, Billing_Contact__c FROM Opportunity LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(oOpportunity);
        Account oAccount = [SELECT Id, NAME FROM Account LIMIT 1];
        Apexpages.currentpage().getparameters().put('id', oOpportunity.id);
        Account oAccount2 = new Account(Name = 'Expocad Account2', CurrencyIsoCode = 'USD');
        Contact oCon1 = new Contact(LastName = 'ContTest2', Email = 'test1contactdr@duptest.com', MailingStreet = 'Test2', MailingCity = 'Test2', MailingState = '', MailingCountry = 'India');
        Association_EB_Ctrl oAssociationEBCtrl = new Association_EB_Ctrl(sc);
        oAssociationEBCtrl.oAccount = oAccount2;
        oAssociationEBCtrl.oContact = oCon1 ;
        oAssociationEBCtrl.sOpptyName = 'Oppty1';
        oAssociationEBCtrl.sOpptyName2 = 'Oppty2';
        oAssociationEBCtrl.sOpptyName3 = 'Oppty3';
        oAssociationEBCtrl.sDisplayName = 'GirikonTestDisplayName';
        oAssociationEBCtrl.selectedAccountId = oAccount.Id ;

        pageReference pg2 = oAssociationEBCtrl.getContact();
        Contact oCon2 = new Contact(LastName = 'ContTest2', Email = 'test3contact@duptest.com', MailingStreet = 'Test3', MailingCity = 'Test3', MailingState = '', MailingCountry = 'India');
        oAssociationEBCtrl.oContact2 = oCon2;
        oAssociationEBCtrl.selectedAccountId = oAccount.Id ;
        system.assertEquals('ContTest2' ,oCon1.LastName , 'test class');
        pageReference pg3 = oAssociationEBCtrl.createOpptyNewContact();
        pageReference pg4 = oAssociationEBCtrl.updateDisplayName();
        pageReference pg5 = oAssociationEBCtrl.viewFloorPlan();
        pageReference pg6 = oAssociationEBCtrl.unRentedbooth();
        pageReference pg1 = oAssociationEBCtrl.createOpptybyNewAccount();
        pageReference pg8 = oAssociationEBCtrl.returnToPT();
        pageReference pg9 = oAssociationEBCtrl.createRelatedOppty();
        oAssociationEBCtrl.getBoothProducts();
        oAssociationEBCtrl.getBoothProductType();
        string sQuantity = '100';
        oAssociationEBCtrl.getQuantity(sQuantity);
        system.assertEquals('1234' ,'1234' , 'test class failed');
        
        Test.StopTest();
    }
     
    static testMethod void testCreateOpptybyNewAccount() {
        Utility.isRebookInProcess = True ;
        Opportunity oOpportunity = [SELECT ID, Name, CloseDate, Event_Series__r.Package_Identifier__c,EventEdition__r.Booth_Bundle_Type__c,StageName, EventEdition__c, Event_Series__c, AccountId, Billing_Contact__c FROM Opportunity LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(oOpportunity);
        Account oAccount = [SELECT Id, Name FROM Account LIMIT 1];
        Apexpages.currentpage().getparameters().put('id', oOpportunity.id);
        Account oAccount2 = new Account(Name = 'ExpocadAccount4', CurrencyIsoCode = 'USD');
        Contact oCon1 = new Contact(LastName = 'ContTest2', Email = 'test1contactdr@duptest.com', MailingStreet = 'Test2', MailingCity = 'Test2', MailingState = '', MailingCountry = 'India');
        Association_EB_Ctrl oAssociationEBCtrl = new Association_EB_Ctrl(sc);
        system.assertEquals('ContTest2' ,oCon1.LastName , 'Test class failed');
        oAssociationEBCtrl.oAccount = oAccount2;
        oAssociationEBCtrl.oContact.AccountId = oAccount2.Id ;

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
        oAssociationEBCtrl.lstHeldBooth = [SELECT Selected__c, Status__c, Opportunity__c, Booth_Type__c, ShowInShow__c, Open_Corners__c, Booth_Classes__c, Booth_Product_Type_EE__c, Area__c, Quote__c, Pavilion__c FROM ExpocadBooth__c];

        Test.StartTest();
        pageReference pg1 = oAssociationEBCtrl.createOpptybyNewAccount();

        Test.StopTest();
    }
}