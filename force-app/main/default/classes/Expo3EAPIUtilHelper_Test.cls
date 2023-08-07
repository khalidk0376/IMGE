/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 08-30-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * * *******************************************************************************************************
 * Last Modified By : Girikon(Isha), 24th Feb 2023[EX-154]
**/

@isTest
public with sharing class Expo3EAPIUtilHelper_Test {
    //EX-21 added test method
     @TestSetup
    static void testdata(){
        Account acc = new Account();
        acc.Name='Test1';
        insert acc;
        Account acc1 = new Account();
        acc1.Name='Test2';
        insert acc1;
        Contact con = new Contact();
        con.LastName = 'test';
        con.email = 'test@gmail.com'; 
        insert con;
        

        /*Event_Edition__c evntEdition = new Event_Edition__c();
        evntEdition.Name = 'test';
        evntEdition.X3E_API_ID__c = '22col';
        evntEdition.CompanyShowInShow__c = 'CompanyId, CompanyTypeId-CompanyName, ShowInShows\nTest,11-Test,11';
        evntEdition.All_CompanyTypes_List__c = 'CompanyId, CompanyTypeId-CompanyName, ShowInShows\nTest,11-Test,11';
        insert evntEdition;
        
        Opportunity opp = new Opportunity();  
        opp.Partner_Account__c = acc.Id;
        opp.AccountId = acc1.Id;
        opp.Name = 'opp Test';
        opp.StageName = 'Prospecting'; 
        opp.CloseDate = System.today() + 30;
        opp.Opportunity_Contact__c = con.Id;
        opp.EventEdition__c = evntEdition.Id;*/
        
       // insert opp;

        /*ExpocadBooth__c expoBooth = new ExpocadBooth__c();
        expoBooth.Booth_Number__c = 'test';
        expoBooth.ShowInShow__c = '11';
        expoBooth.Opportunity__c = opp.Id;
        expoBooth.Account__c =  acc1.Id;
        insert expoBooth;*/

        /*API_Synchronization_Transaction__c syncTrans = new API_Synchronization_Transaction__c();
        insert syncTrans;

        API_Synchronization_Item__c exhibitorSyncObj = new API_Synchronization_Item__c();
        //exhibitorSyncObj.Name = 'test';
        exhibitorSyncObj.ExpocadBooth__c = expoBooth.Id;
        exhibitorSyncObj.Opportunity__c = opp.Id;
        exhibitorSyncObj.API_Synchronization_Transaction__c = syncTrans.Id;
        exhibitorSyncObj.API_Call_Type__c = 'GET';
        exhibitorSyncObj.Event_Edition__c = evntEdition.Id;
        exhibitorSyncObj.Type__c = '3E Expocad Exhibitor Invite';
        insert exhibitorSyncObj;*/
        
        
        /*-------------------*/
        
         Utility.isRebookInProcess = True ;
        Account oAccount = new Account(Name = 'Expocad Account', CurrencyIsoCode = 'USD', Phone = '2423122323');
        insert oAccount;

        Contact oCon = new Contact(LastName = 'ContTest1', Email = 'test1contact@duptest.com', AccountId = oAccount.Id, MailingStreet = 'Test', MailingCity = 'Test', MailingState = '', MailingCountry = 'India', Phone = '2423122323', AssistantPhone = '2423122323', HomePhone = '2121212121', MobilePhone = '2121212145', OtherPhone = '2154215421');
        insert oCon;

        User oUser = [SELECT Id FROM User WHERE Id = : UserInfo.getUserId()];
        AccountTeamMember oAtm = new AccountTeamMember(AccountId = oAccount.id, userId = oUser.id);
        insert oAtm;

        Brand__c oBrand = new Brand__c(Name = 'World of Concrete', SSC_Email_Distribution_ID__c = 'test@test.tst');
        insert oBrand;

        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Brand__c = oBrand.id, Event_Edition_Pool__c = 'WOC');
        insert oEventseries;

        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017',CompanyShowInShow__c = 'CompanyId, CompanyTypeId-CompanyName, ShowInShows\nTest,11-Test,11',
                                                       All_CompanyTypes_List__c = 'CompanyId, CompanyTypeId-CompanyName, ShowInShows\nTest,11-Test,11',X3E_API_ID__c = '22col',Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information', Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = 'Space Only', Expocad_API_Url__c = 'test.com', Part_of_Series__c = oEventseries.id, Booth_Classes_on_Template__c = 'Temp', Corner_Configuration_Check__c = false, Product_Type_Order__c = 'BoothA;;BoothB');
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
        //SBQQ__ProductOption__c oPrdOption2 = new SBQQ__ProductOption__c(SBQQ__Number__c = 5, SBQQ__ConfiguredSKU__c = prd.id, SBQQ__OptionalSKU__c = prd2.id );
        //insert oPrdOption2;
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
    }
    @isTest
    static void unitTest1(){
		//Expocad3E_Wrapper recc = new Expocad3E_Wrapper();    
        API_Synchronization_Transaction__c syncTrans = new API_Synchronization_Transaction__c();
        insert syncTrans;

        API_Synchronization_Item__c exhibitorSyncObj = new API_Synchronization_Item__c();
        //exhibitorSyncObj.Name = 'test';
        exhibitorSyncObj.API_Call_Type__c = 'GET';
        exhibitorSyncObj.Type__c = '3E Expocad Exhibitor Invite';
        exhibitorSyncObj.API_Synchronization_Transaction__c = syncTrans.Id;
        insert exhibitorSyncObj;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExpocadAPIHttpResponse_Mock(200,'{ "message": "Invitation Emails Queued!", "errors": [] }'));
        Expocad3E_Wrapper.WrapperResponse wrap;
        String str = Expo3EAPIUtilHelper.fetchApiToken();
        System.assertNotEquals(str,Null,'ApiToken should not be null');


        
        ExpocadAPIHttpResponse_Mock rec = new ExpocadAPIHttpResponse_Mock();
        Map<String,String> mapstr = new Map<String,String>();
        mapstr.put('/update','dfssghfd');
        mapstr.put('/contact','dfssghfd');
        mapstr.put('/exhibitors/','dfssghfd');
        ExpocadAPIHttpResponse_Mock rec1 = new ExpocadAPIHttpResponse_Mock(mapstr);
        
        
        String API3EName = 'ExpoCad3E';
        String customerId = 'test';
        String boothNumber = '12';
        Boolean hasToken = true;
        String apiToken = 'test';
        String transcationId = String.valueOf(exhibitorSyncObj.Id);
        Expocad3E_Wrapper.InviteExhibitor inviteDetails ;
        Expocad3E_Wrapper.WrapperResponse resp = Expo3EAPIUtilHelper.inviteExhibitorIn3E(API3EName,inviteDetails,hasToken,apiToken);
        
        Expocad3E_Wrapper.WrapperResponse response = Expo3EAPIUtilHelper.getCompanyListIn3E(API3EName,hasToken,apiToken);
        
        Expocad3E_Wrapper.WrapperResponse respos = Expo3EAPIUtilHelper.fetchContractFrom3E(API3EName,customerId,boothNumber,hasToken,apiToken);
        
        Expo3EAPIUtilHelper.assignCompanyType(customerId,'test',transcationId);
        Expo3EAPIUtilHelper.unassignCompanyType(customerId,'test',transcationId);
        
        Expo3EAPIUtilHelper.sendRequestToExpoCAD('www.endPointURL.com', 'GET','',true,'apiToken'); 
        
        Expo3EAPIUtilHelper.getAllExpoBooths('API3EName','exhibitorId');
        Expo3EAPIUtilHelper.getExpoBooths('API3EName','exhibitorId');
        Expo3EAPIUtilHelper.getExpoRelatedList('API3EName','exhibitorId');
        
        Expo3EAPIUtilHelper.getBoothProduct(new Opportunity(),'Testing');
        Expo3EAPIUtilHelper.getBoothProductOptions(new Product2(),new Set<String>());
        
        
        
        Utility.isRebookInProcess = True ;
        Opportunity oOpportunity = [SELECT AccountId, StageName, Parent_Opportunity__c, Multiple_Stands_Approval__c, Owner.Id, Account.Name, EventEdition__r.Booth_Size__c, 
                                    EventEdition__r.No_Of_Corner__c, EventEdition__r.Event_Code__c,
                                    EventEdition__r.Expocad_API_Url__c, EventEdition__r.Max_Hold_Days__c, EventEdition__r.Max_Hold_Booth__c, EventEdition__r.Booth_Product_Type__c,
                                    Event_Series__r.Brand__r.SSC_Email_Distribution_ID__c, Event_Series__r.Package_Identifier__c, EventEdition__r.Booth_Type__c, EventEdition__r.Name,
                                    Billing_Contact__c, MSA_Requested__c, EventEdition__r.Booth_Classes_on_Template__c, EventEdition__r.Corner_Configuration_Check__c FROM Opportunity LIMIT 1];

        SBQQ__Quote__c oQuote = [SELECT Id, Price_Book_Name__c, SBQQ__PriceBook__c, SBQQ__Opportunity2__r.Parent_Opportunity__c, Name, SBQQ__Opportunity2__c, SBQQ__Opportunity2__r.EventEdition__r.Booth_Classes_on_Template__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Quote Sent' LIMIT 1];

        SBQQ__Quote__c oQuote2 = [SELECT Id, Price_Book_Name__c, SBQQ__PriceBook__c, SBQQ__Opportunity2__r.Parent_Opportunity__c, Name, SBQQ__Opportunity2__c, SBQQ__Opportunity2__r.EventEdition__r.Booth_Classes_on_Template__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Quote In Review' LIMIT 1];

        Product2 prd = [SELECT Id, Booth_Product_Type__c, Booth_Type__c, Show_In_Show__c, Booth_Class__c, Family, Name, Number_of_Corners__c, Event_Edition_Pool__c, Event_Edition_Name__c, Expiry_Date__c FROM Product2 WHERE name = 'Booth Package WOC'];
        Product2 prd1 = [SELECT Id, SBQQ__PriceEditable__c, SBQQ__NonDiscountable__c, SBQQ__Hidden__c, SBQQ__ConfigurationType__c,
                         Booth_Product_Type__c, Booth_Type__c, Show_In_Show__c, Booth_Class__c, Family, Name, Number_of_Corners__c, Event_Edition_Pool__c, Event_Edition_Name__c, Expiry_Date__c FROM Product2 WHERE name = 'Post Draw Indoor Booth'];
        Product2 prd2 = [SELECT Id, Booth_Product_Type__c, Booth_Type__c, Show_In_Show__c, Booth_Class__c, Family, Name, Number_of_Corners__c, Event_Edition_Pool__c, Event_Edition_Name__c, Expiry_Date__c FROM Product2 WHERE name = 'Corner Booth Fee'];

        SBQQ__ProductOption__c oPrdOption1 = [SELECT ID, SBQQ__Number__c,SBQQ__OptionalSKU__r.SBQQ__Hidden__c,SBQQ__OptionalSKU__r.SBQQ__ConfigurationType__c,SBQQ__OptionalSKU__r.SBQQ__PriceEditable__c,
                                              SBQQ__OptionalSKU__r.ExpoCAD_Booth_Product__c,SBQQ__OptionalSKU__r.SBQQ__NonDiscountable__c, SBQQ__OptionalSKU__r.Corner_Configuration__c, SBQQ__ConfiguredSKU__c, SBQQ__OptionalSKU__c,SBQQ__OptionalSKU__r.Name FROM SBQQ__ProductOption__c WHERE SBQQ__OptionalSKU__c = : prd1.id ];
        //SBQQ__ProductOption__c oPrdOption2 = [SELECT ID, SBQQ__Number__c, SBQQ__ConfiguredSKU__c, SBQQ__OptionalSKU__c FROM SBQQ__ProductOption__c WHERE SBQQ__OptionalSKU__c = : prd2.id];
		Map < String, SBQQ__ProductOption__c > mapProductOptions = new Map < String, SBQQ__ProductOption__c >();
        mapProductOptions.put(oPrdOption1.SBQQ__OptionalSKU__r.Name,oPrdOption1);
         Map<Id, SBQQ__ProductOption__c> mapProductOptionsId = new Map <Id, SBQQ__ProductOption__c >();
        mapProductOptionsId.put(oPrdOption1.Id,oPrdOption1);
        Set<String> ExpocadRelationshipCodeSet = new Set<String>();
        ExpocadRelationshipCodeSet.add(oPrdOption1.SBQQ__OptionalSKU__r.Name);
        
        ExpocadBooth__c oEB = new ExpocadBooth__c(Booth_Number__c = 'TSTBN1', Quote__c = oQuote.Id,Area__c='100 Sqft', Opportunity__c = oOpportunity.Id, Account__c = oOpportunity.AccountId, Open_Corners__c = 4.5, Status__c = 'Added To Quote/On Hold', Booth_Product_Type__c = 'Space Only', Booth_Classes__c = 'Temp');

        insert oEB;

        ExpocadBooth__c oEB2 = new ExpocadBooth__c(Booth_Number__c = 'TSTBN2', Quote__c = oQuote2.Id, Opportunity__c = oOpportunity.Id, Account__c = oOpportunity.AccountId, Open_Corners__c = 4.5, Status__c = 'On Hold', Area__c = '100 Sqft', Booth_Classes__c = 'Temp');

        insert oEB2;

        List<ExpocadBooth__c> lstEBTempTest = new List<ExpocadBooth__c>();
        lstEBTempTest.add(oEB2);
        
        Map<String, Expocad3E_Wrapper.RelatedItems> prodNameMap =  new Map<String, Expocad3E_Wrapper.RelatedItems>();
        
        Map < String, Expocad3E_Wrapper.financialBooth > rateToWrapMap =  new Map < String, Expocad3E_Wrapper.financialBooth >();
        //prd1 = boothPackageProduct
        
        
        Expocad3E_Wrapper.GetAllBoothsWrapper oEBWrap = new Expocad3E_Wrapper.GetAllBoothsWrapper();
        
        Expo3EAPIUtilHelper.sBPrd( mapProductOptionsId, oEBWrap,  oOpportunity,  prd1);
        Expo3EAPIUtilHelper.sBPrdGet( mapProductOptionsId, oEBWrap,  oOpportunity,  prd1);
        /*Expo3EAPIUtilHelper.InviteExhibitor InviteExhibitorwrap = new Expo3EAPIUtilHelper.InviteExhibitor();
        Expo3EAPIUtilHelper.ResponseInviteExhibitor ResponseInviteExhibitorw = new Expo3EAPIUtilHelper.ResponseInviteExhibitor();
        Expo3EAPIUtilHelper.cls_companyTypeList  cls_companyTypeListw= new Expo3EAPIUtilHelper.cls_companyTypeList(); 
        Expo3EAPIUtilHelper.cls_companyListIds  cls_companyListIdsw = new Expo3EAPIUtilHelper.cls_companyListIds();
        Expo3EAPIUtilHelper.CompanyTypes  CompanyTypesw= new Expo3EAPIUtilHelper.CompanyTypes();
        Expo3EAPIUtilHelper.GetAllBoothsWrapper  GetAllBoothsWrapperw= new Expo3EAPIUtilHelper.GetAllBoothsWrapper();
        Expo3EAPIUtilHelper.financialBooth  financialBoothw= new Expo3EAPIUtilHelper.financialBooth();
        Expo3EAPIUtilHelper.RelatedItems  RelatedItemsw= new Expo3EAPIUtilHelper.RelatedItems();*/
        
        
        //try{
            Expo3EAPIUtilHelper.addToQLI(oQuote.Id, oOpportunity,oEB.Id, mapProductOptions,
                                mapProductOptionsId,prd1,'cornerProductName', ExpocadRelationshipCodeSet,
                                         rateToWrapMap, prodNameMap);//}catch(Exception e){} 
        
        
        //EX-23
       // Opportunity op= [Select Id,name,EventEdition__r.Name from Opportunity Limit 1]; 
       // Expo3EAPIUtilHelper.getBoothProduct(op,'test');
        System.assertNotEquals(respos,Null,'Must contain response');//EX-125
        System.assertNotEquals(resp,Null,'Must contain response'); //EX-125
        System.assertNotEquals(response,Null,'Must contain response'); //EX-125
        //System.assertEquals(200, wrap.response.getStatusCode(), 'Error');
        //System.assertEquals(200, wrap.response.getStatusCode(), 'Error');
        //System.assertEquals(200, wrap.response.getStatusCode(), 'Error');
        Test.stopTest();
    }
    
    //Ex-154
    @isTest
    static void unitTestRent(){
        list<Trigger__c> trigs = new list<Trigger__c>();
        trigs.add( New Trigger__c(Name= 'APISyncFromAPITransaction', Enabled__c = true, Object__c = 'API_Synchronization_Transaction__c', After_Insert__c = false, After_Update__c = true, Execution_Order__c = 1, Run_for_Recordypes__c = 'All' ) );
        trigs.add( New Trigger__c(Name= 'ReleaseBooths_Trig', Enabled__c = true, Object__c = 'ExpocadBooth__c', Before_Insert__c = true, After_Insert__c = true, After_Update__c = true, After_Delete__c = true, After_UnDelete__c = true, Execution_Order__c = 1, Run_for_Recordypes__c = 'All' ) );
        insert trigs;
        //mock callout
        Test.setMock(HttpCalloutMock.class, new ExpoCADAPIHttpResponse_Mock()); 
        //Fetch Event_Edition__c record created in setup method
        Event_Edition__c event=[Select Id,Name,X3E_API_ID__c,Event_Code__c,Expocad_API_Url__c,Booth_Type__c,No_Of_Corner__c,
                                Booth_Size__c,Booth_Product_Type__c FROM Event_Edition__c LIMIT 1];
        //Fetch Opportunity record created in setup method
        Opportunity oOpportunity = [SELECT AccountId, StageName, Parent_Opportunity__c, Multiple_Stands_Approval__c, Owner.Id, Account.Name, EventEdition__r.Booth_Size__c, 
                                    EventEdition__r.No_Of_Corner__c, EventEdition__r.Event_Code__c,
                                    EventEdition__r.Expocad_API_Url__c, EventEdition__r.Max_Hold_Days__c, EventEdition__r.Max_Hold_Booth__c, EventEdition__r.Booth_Product_Type__c,
                                    Event_Series__r.Brand__r.SSC_Email_Distribution_ID__c, Event_Series__r.Package_Identifier__c, EventEdition__r.Booth_Type__c, EventEdition__r.Name,
                                    Billing_Contact__c, MSA_Requested__c, EventEdition__r.Booth_Classes_on_Template__c, EventEdition__r.Corner_Configuration_Check__c FROM Opportunity LIMIT 1]; 
        //Fetch Quote record created in setup method
        SBQQ__Quote__c oQuote = [SELECT Id, Price_Book_Name__c, SBQQ__PriceBook__c, SBQQ__Opportunity2__r.Parent_Opportunity__c, Name, SBQQ__Opportunity2__c, SBQQ__Opportunity2__r.EventEdition__r.Booth_Classes_on_Template__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Quote Sent' LIMIT 1];  
        //Booth creation
        ExpocadBooth__c oEB = new ExpocadBooth__c(Booth_Number__c = 'TSTBN1', Quote__c = oQuote.Id,Area__c='100 Sqft', Opportunity__c = oOpportunity.Id, Account__c = oOpportunity.AccountId, Open_Corners__c = 4.5, Status__c = 'Released', Booth_Product_Type__c = 'Space Only', Booth_Classes__c = 'Temp');
        insert oEB;
        oEB.Status__c='Rented';
        
        Test.startTest();
        update oEB;
        Expocad3E_Wrapper.WrapperResponse respBoothRent = Expo3EAPIUtilHelper.ExpoCADBoothRent(oEB.Booth_Number__c,event.Event_Code__c,event.Expocad_API_Url__c,'test001', oOpportunity.Id, 'Base Plan');
        Test.stopTest();
        
        System.assertNotEquals(respBoothRent,Null,'Must contain response');
    } 
    
    //Ex-154
    @isTest
    static void unitTestUnrent(){
        //mock callout
        Test.setMock(HttpCalloutMock.class, new ExpoCADAPIHttpResponse_Mock()); 
        //Fetch Event_Edition__c record created in setup method
        Event_Edition__c event=[Select Id,Name,X3E_API_ID__c,Event_Code__c,Expocad_API_Url__c,Booth_Type__c,No_Of_Corner__c,
                                Booth_Size__c,Booth_Product_Type__c FROM Event_Edition__c LIMIT 1];
        //Fetch Opportunity record created in setup method
        Opportunity oOpportunity = [SELECT AccountId, StageName, Parent_Opportunity__c, Multiple_Stands_Approval__c, Owner.Id, Account.Name, EventEdition__r.Booth_Size__c, 
                                    EventEdition__r.No_Of_Corner__c, EventEdition__r.Event_Code__c,
                                    EventEdition__r.Expocad_API_Url__c, EventEdition__r.Max_Hold_Days__c, EventEdition__r.Max_Hold_Booth__c, EventEdition__r.Booth_Product_Type__c,
                                    Event_Series__r.Brand__r.SSC_Email_Distribution_ID__c, Event_Series__r.Package_Identifier__c, EventEdition__r.Booth_Type__c, EventEdition__r.Name,
                                    Billing_Contact__c, MSA_Requested__c, EventEdition__r.Booth_Classes_on_Template__c, EventEdition__r.Corner_Configuration_Check__c FROM Opportunity LIMIT 1]; 
        ////Fetch Quote record created in setup method
        SBQQ__Quote__c oQuote = [SELECT Id, Price_Book_Name__c, SBQQ__PriceBook__c, SBQQ__Opportunity2__r.Parent_Opportunity__c, Name, SBQQ__Opportunity2__c, SBQQ__Opportunity2__r.EventEdition__r.Booth_Classes_on_Template__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Quote Sent' LIMIT 1];  
        //Booth creation
        ExpocadBooth__c oEB = new ExpocadBooth__c(Booth_Number__c = 'TSTBN1', Quote__c = oQuote.Id,Area__c='100 Sqft', Opportunity__c = oOpportunity.Id, Account__c = oOpportunity.AccountId, Open_Corners__c = 4.5, Status__c = 'Released', Booth_Product_Type__c = 'Space Only', Booth_Classes__c = 'Temp');
        insert oEB;
        
        Test.startTest();
        Expocad3E_Wrapper.WrapperResponse respBoothUnrent = Expo3EAPIUtilHelper.ExpoCADBoothUnrent(oEB.Booth_Number__c,event.Event_Code__c,event.Expocad_API_Url__c);
        Test.stopTest();
        
        System.assertNotEquals(respBoothUnrent,Null,'Must contain response');
    }
    
    //Ex-154
    @isTest
    static void unitTestRentToHold(){
        //mock callout
        Test.setMock(HttpCalloutMock.class, new ExpoCADAPIHttpResponse_Mock()); 
        //Fetch Event_Edition__c record created in setup method
        Event_Edition__c event=[Select Id,Name,X3E_API_ID__c,Event_Code__c,Expocad_API_Url__c,Booth_Type__c,No_Of_Corner__c,
                                Booth_Size__c,Booth_Product_Type__c FROM Event_Edition__c LIMIT 1];
        //Fetch Opportunity record created in setup method
        Opportunity oOpportunity = [SELECT AccountId, StageName, Parent_Opportunity__c, Multiple_Stands_Approval__c, Owner.Id, Account.Name, EventEdition__r.Booth_Size__c, 
                                    EventEdition__r.No_Of_Corner__c, EventEdition__r.Event_Code__c,
                                    EventEdition__r.Expocad_API_Url__c, EventEdition__r.Max_Hold_Days__c, EventEdition__r.Max_Hold_Booth__c, EventEdition__r.Booth_Product_Type__c,
                                    Event_Series__r.Brand__r.SSC_Email_Distribution_ID__c, Event_Series__r.Package_Identifier__c, EventEdition__r.Booth_Type__c, EventEdition__r.Name,
                                    Billing_Contact__c, MSA_Requested__c, EventEdition__r.Booth_Classes_on_Template__c, EventEdition__r.Corner_Configuration_Check__c FROM Opportunity LIMIT 1]; 
        ////Fetch Quote record created in setup method
        SBQQ__Quote__c oQuote = [SELECT Id, Price_Book_Name__c, SBQQ__PriceBook__c, SBQQ__Opportunity2__r.Parent_Opportunity__c, Name, SBQQ__Opportunity2__c, SBQQ__Opportunity2__r.EventEdition__r.Booth_Classes_on_Template__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Quote Sent' LIMIT 1];  
        //Booth creation
        ExpocadBooth__c oEB = new ExpocadBooth__c(Booth_Number__c = 'TSTBN1', Quote__c = oQuote.Id,Area__c='100 Sqft', Opportunity__c = oOpportunity.Id, Account__c = oOpportunity.AccountId, Open_Corners__c = 4.5, Status__c = 'Added To Quote/On Hold', Booth_Product_Type__c = 'Space Only', Booth_Classes__c = 'Temp');
        insert oEB;
        
        Test.startTest();
        Expocad3E_Wrapper.WrapperResponse respBoothRentToHold = Expo3EAPIUtilHelper.ExpoCADBoothRentToHold(oEB.Booth_Number__c,event.Event_Code__c,event.Expocad_API_Url__c);
        Test.stopTest();
        
        System.assertNotEquals(respBoothRentToHold,Null,'Must contain response');
    }
    
    //Ex-154
    @isTest
    static void unitTestUnhold(){
        //mock callout
        Test.setMock(HttpCalloutMock.class, new ExpoCADAPIHttpResponse_Mock());  
        //Fetch Event_Edition__c record created in setup method
        Event_Edition__c event=[Select Id,Name,X3E_API_ID__c,Event_Code__c,Expocad_API_Url__c,Booth_Type__c,No_Of_Corner__c,
                                Booth_Size__c,Booth_Product_Type__c FROM Event_Edition__c LIMIT 1];
        //Fetch Opportunity record created in setup method
        Opportunity oOpportunity = [SELECT AccountId, StageName, Parent_Opportunity__c, Multiple_Stands_Approval__c, Owner.Id, Account.Name, EventEdition__r.Booth_Size__c, 
                                    EventEdition__r.No_Of_Corner__c, EventEdition__r.Event_Code__c,
                                    EventEdition__r.Expocad_API_Url__c, EventEdition__r.Max_Hold_Days__c, EventEdition__r.Max_Hold_Booth__c, EventEdition__r.Booth_Product_Type__c,
                                    Event_Series__r.Brand__r.SSC_Email_Distribution_ID__c, Event_Series__r.Package_Identifier__c, EventEdition__r.Booth_Type__c, EventEdition__r.Name,
                                    Billing_Contact__c, MSA_Requested__c, EventEdition__r.Booth_Classes_on_Template__c, EventEdition__r.Corner_Configuration_Check__c FROM Opportunity LIMIT 1]; 
        //Fetch Quote record created in setup method
        SBQQ__Quote__c oQuote = [SELECT Id, Price_Book_Name__c, SBQQ__PriceBook__c, SBQQ__Opportunity2__r.Parent_Opportunity__c, Name, SBQQ__Opportunity2__c, SBQQ__Opportunity2__r.EventEdition__r.Booth_Classes_on_Template__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Quote Sent' LIMIT 1];  
        //Insert Booth
        ExpocadBooth__c oEB = new ExpocadBooth__c(Booth_Number__c = 'TSTBN1', Quote__c = oQuote.Id,Area__c='100 Sqft', Opportunity__c = oOpportunity.Id, Account__c = oOpportunity.AccountId, Open_Corners__c = 4.5, Status__c = 'Released', Booth_Product_Type__c = 'Space Only', Booth_Classes__c = 'Temp');
        insert oEB; 
        
        Test.startTest();
        Create3EApiSyncRecords.syncBooth(oEB, 'Asynchronous',Expocad3E_Wrapper.EXPOCAD_BOOTH_UNHOLD, false,'DisplayName');
        Expocad3E_Wrapper.WrapperResponse respBoothUnhold = Expo3EAPIUtilHelper.ExpoCADBoothUnhold(oEB.Booth_Number__c,event.Event_Code__c,event.Expocad_API_Url__c);
        Test.stopTest();
        
        System.assertNotEquals(respBoothUnhold,Null,'Must contain response'); //EX-154
    }
    
    //Ex-154
    @isTest
    static void unitTestOthers(){
        //mock callout
        Test.setMock(HttpCalloutMock.class, new ExpoCADAPIHttpResponse_Mock());  
        //Fetch Event_Edition__c record created in setup method
        Event_Edition__c event=[Select Id,Name,X3E_API_ID__c,Event_Code__c,Expocad_API_Url__c,Booth_Type__c,No_Of_Corner__c,
                                Booth_Size__c,Booth_Product_Type__c FROM Event_Edition__c LIMIT 1];
        //Fetch Opportunity record created in setup method
        Opportunity oOpportunity = [SELECT AccountId, StageName, Parent_Opportunity__c, Multiple_Stands_Approval__c, Owner.Id, Account.Name, EventEdition__r.Booth_Size__c, 
                                    EventEdition__r.No_Of_Corner__c, EventEdition__r.Event_Code__c,
                                    EventEdition__r.Expocad_API_Url__c, EventEdition__r.Max_Hold_Days__c, EventEdition__r.Max_Hold_Booth__c, EventEdition__r.Booth_Product_Type__c,
                                    Event_Series__r.Brand__r.SSC_Email_Distribution_ID__c, Event_Series__r.Package_Identifier__c, EventEdition__r.Booth_Type__c, EventEdition__r.Name,
                                    Billing_Contact__c, MSA_Requested__c, EventEdition__r.Booth_Classes_on_Template__c, EventEdition__r.Corner_Configuration_Check__c FROM Opportunity LIMIT 1]; 
        //Fetch Quote record created in setup method
        SBQQ__Quote__c oQuote = [SELECT Id, Price_Book_Name__c, SBQQ__PriceBook__c, SBQQ__Opportunity2__r.Parent_Opportunity__c, Name, SBQQ__Opportunity2__c, SBQQ__Opportunity2__r.EventEdition__r.Booth_Classes_on_Template__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Quote Sent' LIMIT 1];  
        //Insert Booth
        ExpocadBooth__c oEB = new ExpocadBooth__c(Booth_Number__c = 'TSTBN1', Quote__c = oQuote.Id,Area__c='100 Sqft', Opportunity__c = oOpportunity.Id, Account__c = oOpportunity.AccountId, Open_Corners__c = 4.5, Status__c = 'On Hold', Booth_Product_Type__c = 'Space Only', Booth_Classes__c = 'Temp');
        insert oEB; 
        
        Test.startTest();
        Expocad3E_Wrapper.WrapperResponse respBoothUnhold = Expo3EAPIUtilHelper.ExpoCADBoothHold(oEB.Booth_Number__c,event.Event_Code__c,event.Expocad_API_Url__c,oOpportunity.Id,'');
        Expocad3E_Wrapper.WrapperResponse respGetRatePlan = Expo3EAPIUtilHelper.getRateplan(event.Event_Code__c,event.Expocad_API_Url__c);
        Expocad3E_Wrapper.WrapperResponse respGetExhibitor = Expo3EAPIUtilHelper.getExhibitor(event.Event_Code__c,event.Expocad_API_Url__c,'test001');
        Expocad3E_Wrapper.WrapperResponse respUpdateExhibitor = Expo3EAPIUtilHelper.updateExhibitor(event.Event_Code__c,'test001',event.Expocad_API_Url__c,'Request Body');
        Expocad3E_Wrapper.WrapperResponse respCreateExhibitor = Expo3EAPIUtilHelper.createExhibitor(event.Event_Code__c,event.Expocad_API_Url__c,'Request Body');
        
        Test.stopTest();
        
        System.assertNotEquals(respBoothUnhold,Null,'Must contain response');
        System.assertNotEquals(respGetRatePlan,Null,'Must contain response');
        System.assertNotEquals(respGetExhibitor,Null,'Must contain response');
        System.assertNotEquals(respUpdateExhibitor,Null,'Must contain response');
        System.assertNotEquals(respCreateExhibitor,Null,'Must contain response');

    }
}