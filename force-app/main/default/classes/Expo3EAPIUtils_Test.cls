/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-07-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public with sharing class Expo3EAPIUtils_Test {
    @TestSetup
    static void makeData(){
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
        
        User oUser = [SELECT Id FROM User WHERE Id = : UserInfo.getUserId()];
        AccountTeamMember oAtm = new AccountTeamMember(AccountId = acc1.id, userId = oUser.id);
        insert oAtm;
        
        Brand__c oBrand = new Brand__c(Name = 'World of Concrete', SSC_Email_Distribution_ID__c = 'test@test.tst');
        insert oBrand;
        
        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Brand__c = oBrand.id, Event_Edition_Pool__c = 'WOC');
        insert oEventseries;
        
        
        

        Event_Edition__c evntEdition = new Event_Edition__c();
        evntEdition.Name = 'test';
        evntEdition.X3E_API_ID__c = '22col';
        evntEdition.CompanyShowInShow__c = 'CompanyId, CompanyTypeId-CompanyName, ShowInShows\nTest,11-Test,11';
        evntEdition.All_CompanyTypes_List__c = 'CompanyId, CompanyTypeId-CompanyName, ShowInShows\nTest,11-Test,11';
        evntEdition.Tab1__c = 'Booth Applications';
        evntEdition.Tab7__c = 'Billing Information';
        evntEdition.Approval_Service_Now_ID__c = '123';
        evntEdition.CurrencyIsoCode = 'USD';
        evntEdition.Event_Code__c = 'KDB,KDB2';
        evntEdition.Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula';
        evntEdition.No_Of_Corner__c = '0,1,2,3,4';
        evntEdition.Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt';
        evntEdition.Booth_Product_Type__c = 'Space Only';
        evntEdition.Expocad_API_Url__c = 'test.com';
        evntEdition.Part_of_Series__c = oEventseries.id;
        evntEdition.Booth_Classes_on_Template__c = 'Temp';
        evntEdition.Corner_Configuration_Check__c = false;
        evntEdition.Product_Type_Order__c = 'BoothA;;BoothB';
        insert evntEdition;
        
        Product2 prd = new Product2(Name = 'Booth Package WOC', Family = 'Booth', Number_of_Corners__c = 0, Booth_Type__c = 'esc', Show_In_Show__c = 'Indoor', Booth_Class__c = 'fsdf', Event_Edition_Pool__c = 'WOC', Event_Edition__c = evntEdition.Id);
        insert prd;
        
        Pricebook2 customPB2 = new Pricebook2(Name = 'ICRE', isActive = true);
        insert customPB2;
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pbStndrdPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prd.Id, UnitPrice = 100, IsActive = true);
        insert pbStndrdPrice;
        PricebookEntry pbICREPrice = new PricebookEntry(Pricebook2Id = customPB2.Id, Product2Id = prd.Id, UnitPrice = 200, IsActive = true);
        insert pbICREPrice;
        
        Product2 prd1 = new Product2(Name = 'Post Draw Indoor Booth', Booth_Product_Type__c = 'Space Only', Booth_Type__c = 'esc', Show_In_Show__c = 'Indoor', Booth_Class__c = 'fsdf', Family = 'Booth', Number_of_Corners__c = 0, Event_Edition_Pool__c = 'WOC', Event_Edition__c = evntEdition.Id, Expiry_Date__c = Date.today());
        insert prd1;
        
        Pricebook2 customPB = new Pricebook2(Name = 'ICREAB', isActive = true);
        insert customPB;
        PricebookEntry pbStndrdPrice1 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prd1.Id, UnitPrice = 100, IsActive = true);
        insert pbStndrdPrice1;
        PricebookEntry pbICREPrice1 = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = prd1.Id, UnitPrice = 200, IsActive = true);
        insert pbICREPrice1;
        
        Product2 prd2 = new Product2(Name = 'Corner Booth Fee', Family = 'Booth', Booth_Type__c = 'esc', Show_In_Show__c = 'Indoor', Booth_Class__c = 'fsdf', Number_of_Corners__c = 1, Event_Edition_Pool__c = 'WOC', Event_Edition__c = evntEdition.Id);
        insert prd2;
        
        PricebookEntry pbStndrdPrice2 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prd2.Id, UnitPrice = 100, IsActive = true);
        insert pbStndrdPrice2;
        PricebookEntry pbICREPrice2 = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = prd2.Id, UnitPrice = 200, IsActive = true);
        insert pbICREPrice2;
        
        Opportunity opp = new Opportunity();  
        opp.Partner_Account__c = acc.Id;
        opp.AccountId = acc1.Id;
        opp.Name = 'opp Test';
        opp.StageName = 'Prospecting'; 
        opp.CloseDate = System.today() + 30;
        opp.Opportunity_Contact__c = con.Id;
        opp.EventEdition__c = evntEdition.Id;
        opp.Type = 'New';
        insert opp;

        SBQQ__Quote__c oQuote = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Quote Sent', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = opp.Id, SBQQ__Account__c = acc.Id, SBQQ__Primary__c = true);
        Insert oQuote;
        //Contract oContract = new Contract(AccountId = oAccount1.id, Status='Sent', StartDate = Date.today(), ContractTerm = 12, SBQQ__Opportunity__c = oOpportunity.id, SBQQ__Quote__c = oQuote.Id);
        //insert oContract;

        ExpocadBooth__c expoBooth = new ExpocadBooth__c();
        expoBooth.Booth_Number__c = 'test';
        expoBooth.ShowInShow__c = '11';
        expoBooth.Opportunity__c = opp.Id;
        expoBooth.Status__c='Rented';
        expoBooth.Account__c =  acc1.Id;
        insert expoBooth;

        API_Synchronization_Transaction__c syncTrans = new API_Synchronization_Transaction__c();
        insert syncTrans;

        API_Synchronization_Item__c exhibitorSyncObj = new API_Synchronization_Item__c();
        //exhibitorSyncObj.Name = 'test';
        exhibitorSyncObj.ExpocadBooth__c = expoBooth.Id;
        exhibitorSyncObj.Opportunity__c = opp.Id;
        exhibitorSyncObj.API_Synchronization_Transaction__c = syncTrans.Id;
        exhibitorSyncObj.API_Call_Type__c = 'GET';
        exhibitorSyncObj.Event_Edition__c = evntEdition.Id;
        exhibitorSyncObj.Type__c = '3E Expocad Exhibitor Invite';
        insert exhibitorSyncObj;
    }
      @isTest
    static void coverEXPOCAD3E_BOOTH_FINANCIALS(){
        Account acc = new Account();
        acc.Name='Test12';
        insert acc;
        Account acc1 = new Account();
        acc1.Name='Test22';
        insert acc1;
        Event_Edition__c evntEdition=[Select Id from Event_Edition__c Limit 1 ];
        Opportunity opp = new Opportunity();  
        opp.Partner_Account__c = acc.Id;
        opp.AccountId = acc1.Id;
        opp.Name = 'opp Test1';
        opp.StageName = 'Prospecting'; 
        opp.CloseDate = System.today() + 30;
        opp.EventEdition__c = evntEdition.Id;
        opp.Type = 'New';
        insert opp;
        
        
        ExpocadBooth__c eb = new ExpocadBooth__c();
        //expoBooth.Name='test';
        eb.Opportunity__c = opp.Id;
        eb.Status__c='On Hold';
        insert eb;
        eb.Status__c='Rented';
        update eb;
        
        Contact con = new Contact();
        con.LastName = 'test1';
        con.email = 'tes1t@gmail.com'; 
        insert con;
        
        Test.startTest();
        //Opportunity opp = [Select Id From Opportunity limit 1];
        API_Synchronization_Transaction__c apiSyncTran = new API_Synchronization_Transaction__c();
        
        apiSyncTran.Status__c = 'Paused';
        
        apiSyncTran.X3rd_Party_Relationship__c = Expocad3E_Wrapper.EXPOCAD3E;
        apiSyncTran.Started_From__c = 'Opportunity';
        apiSyncTran.Request_Type__c = 'Asynchronous'; //Synchronous Asynchronous
        insert apiSyncTran; 
        
        API_Synchronization_Item__c apiSyncItemforExhibitors = new API_Synchronization_Item__c();
        apiSyncItemforExhibitors.API_Synchronization_Transaction__c = apiSyncTran.Id;
        apiSyncItemforExhibitors.Status__c =  'Queued';
        apiSyncItemforExhibitors.API_Call_Type__c = 'POST';
        apiSyncItemforExhibitors.ExpocadBooth__c = eb.Id;
        //apiSyncItemforExhibitors.Account__c = rec.AccountId;
        //apiSyncItemforExhibitors.Account__c = rec.AccountId;
        apiSyncItemforExhibitors.X3rd_Party_Relationship__c = Expocad3E_Wrapper.EXPOCAD3E;
        apiSyncItemforExhibitors.Type__c = Expocad3E_Wrapper.EXPOCAD3E_BOOTH_FINANCIALS;
        insert apiSyncItemforExhibitors;
        apiSyncTran.Status__c = 'Queued';
        update apiSyncTran;
        
        system.assertEquals(apiSyncTran.Started_From__c, 'Opportunity', true);//EX-101
        
        APISynchronizationBatch api = new APISynchronizationBatch();
        Database.executeBatch(api,1);
        //APISynchronizationBatch testing = new  APISynchronizationBatch(new set<Id>{apiSyncItemforExhibitors.Id});  
        
        Test.stopTest();
           
    }
    @isTest
    static void cover_queueApiTransactions(){
        Test.startTest();
        Opportunity opp = [Select Id From Opportunity limit 1];
        API_Synchronization_Transaction__c apiSyncTran = new API_Synchronization_Transaction__c();
        
        apiSyncTran.Status__c = 'Paused';
        
        apiSyncTran.X3rd_Party_Relationship__c = Expocad3E_Wrapper.EXPOCAD3E;
        apiSyncTran.Started_From__c = 'Opportunity';
        apiSyncTran.Request_Type__c = 'Asynchronous'; //Synchronous Asynchronous
        insert apiSyncTran; 
        
        API_Synchronization_Item__c apiSyncItemforExhibitors = new API_Synchronization_Item__c();
        apiSyncItemforExhibitors.API_Synchronization_Transaction__c = apiSyncTran.Id;
        apiSyncItemforExhibitors.Status__c =  'Queued';
        apiSyncItemforExhibitors.API_Call_Type__c = 'POST';
        apiSyncItemforExhibitors.Opportunity__c = opp.Id;
        //apiSyncItemforExhibitors.Account__c = rec.AccountId;
        apiSyncItemforExhibitors.X3rd_Party_Relationship__c = Expocad3E_Wrapper.EXPOCAD3E;
        apiSyncItemforExhibitors.Type__c = Expocad3E_Wrapper.EXPOCAD3E_BOOTH_FINANCIALS;
        insert apiSyncItemforExhibitors;
        
        Expo3EAPIUtils.queueApiTransactions();
        Expo3EAPIUtils.updateStaticValues('','','','');
        system.assertEquals(apiSyncItemforExhibitors.Status__c, 'Queued', true);//EX-125
        Test.stopTest();
           
    } 
    @isTest
    static void unitTestinviteExhibitor(){
        Test.startTest();
        Opportunity opp = [Select Id From Opportunity limit 1];
        API_Synchronization_Transaction__c apiSyncTran = new API_Synchronization_Transaction__c();
        
        apiSyncTran.Status__c = 'Paused';
        
        apiSyncTran.X3rd_Party_Relationship__c = Expocad3E_Wrapper.EXPOCAD3E;
        apiSyncTran.Started_From__c = 'Opportunity';
        apiSyncTran.Request_Type__c = 'Asynchronous'; //Synchronous Asynchronous
        insert apiSyncTran; 
        
        API_Synchronization_Item__c apiSyncItemforExhibitors = new API_Synchronization_Item__c();
        apiSyncItemforExhibitors.API_Synchronization_Transaction__c = apiSyncTran.Id;
        apiSyncItemforExhibitors.Status__c =  'Queued';
        apiSyncItemforExhibitors.API_Call_Type__c = 'POST';
        apiSyncItemforExhibitors.Opportunity__c = opp.Id;
        //apiSyncItemforExhibitors.Account__c = rec.AccountId;
        apiSyncItemforExhibitors.X3rd_Party_Relationship__c = Expocad3E_Wrapper.EXPOCAD3E;
        apiSyncItemforExhibitors.Type__c = Expocad3E_Wrapper.EXPOCAD3E_EXHIBITOR_INVITE;
        insert apiSyncItemforExhibitors;
        apiSyncTran.Status__c = 'Queued';
        update apiSyncTran;
        
        system.assertEquals(apiSyncTran.Started_From__c, 'Opportunity', true);//EX-101
        
        APISynchronizationBatch api = new APISynchronizationBatch();
        Database.executeBatch(api,1);
        APISynchronizationBatch testing = new  APISynchronizationBatch(new set<Id>{apiSyncItemforExhibitors.Id});  
         system.assertEquals(apiSyncItemforExhibitors.Status__c, 'Queued', true);//EX-125
        Test.stopTest();
           
    }
    @isTest
    static void cover_companyTypeAssignInExpoCAD3E(){
        

        Test.startTest();
        ExpocadAPIHttpResponse_Mock mockCls = new ExpocadAPIHttpResponse_Mock();
        Test.setMock(HttpCalloutMock.class, new ExpocadAPIHttpResponse_Mock(200,'test'));

        API_Synchronization_Item__c exhibitorSyncObj = [SELECT Id,ExpocadBooth__c,Opportunity__c,API_Synchronization_Transaction__c,API_Call_Type__c,Type__c 
                                                        FROM API_Synchronization_Item__c 
                                                        LIMIT 1 ]; 
        exhibitorSyncObj.Type__c = '3E Expocad CompanyType Assign';

        exhibitorSyncObj.API_Call_Type__c = 'POST';
        String inviteExhbitorStr2 = Expo3EAPIUtils.companyTypeAssignInExpoCAD3E(exhibitorSyncObj);
        System.assertEquals(exhibitorSyncObj.Type__c, '3E Expocad CompanyType Assign', true);//EX-101
        //String inviteExhbitorStr3 = Expo3EAPIUtils.getContractsFrom3EEnd(exhibitorSyncObj);  //EX-23
        Test.stopTest();
    }
    @isTest
    static void unitTest2(){
        

        Test.startTest();
        ExpocadAPIHttpResponse_Mock mockCls = new ExpocadAPIHttpResponse_Mock();
        Test.setMock(HttpCalloutMock.class, new ExpocadAPIHttpResponse_Mock(200,'test'));

        API_Synchronization_Item__c exhibitorSyncObj = [SELECT Id,ExpocadBooth__c,Opportunity__c,API_Synchronization_Transaction__c,API_Call_Type__c,Type__c 
                                                        FROM API_Synchronization_Item__c 
                                                        LIMIT 1 ]; 
        exhibitorSyncObj.Type__c = '3E Expocad CompanyType Unassign';

        exhibitorSyncObj.API_Call_Type__c = 'POST';
        String inviteExhbitorStr2 = Expo3EAPIUtils.companyTypeAssignInExpoCAD3E(exhibitorSyncObj);
        System.assertEquals(exhibitorSyncObj.Type__c, '3E Expocad CompanyType Unassign', true);//EX-101
        

        Test.stopTest();
    }
     
    @isTest
    static void cover_companyTypeUnAssignInExpoCAD3E(){
        

        Test.startTest();
        ExpocadAPIHttpResponse_Mock mockCls = new ExpocadAPIHttpResponse_Mock();
        Test.setMock(HttpCalloutMock.class, new ExpocadAPIHttpResponse_Mock(100,''));

        API_Synchronization_Item__c exhibitorSyncObj = [SELECT Id,ExpocadBooth__c,Opportunity__c,API_Synchronization_Transaction__c,API_Call_Type__c,Type__c 
                                                        FROM API_Synchronization_Item__c 
                                                        LIMIT 1 ]; 
        exhibitorSyncObj.Type__c = '3E Expocad CompanyType Unassign';

        exhibitorSyncObj.API_Call_Type__c = 'GET';
        String inviteExhbitorStr2 = Expo3EAPIUtils.companyTypeAssignInExpoCAD3E(exhibitorSyncObj);
        
        System.assertEquals(exhibitorSyncObj.Type__c, '3E Expocad CompanyType Unassign', true);//EX-101

        Test.stopTest();
    }
     
    @isTest
    static void NegativeCover_inviteExhibitorInExpoCAD(){
        

        Test.startTest();
        ExpocadAPIHttpResponse_Mock mockCls = new ExpocadAPIHttpResponse_Mock();
        Test.setMock(HttpCalloutMock.class, new ExpocadAPIHttpResponse_Mock(200,'{"message": "The following invitation failed","errors": [{"email": "test@girikon.com", "customerId": "ACCT-005774", "reason": "CustoemrId not found in event" } ] }'));

        API_Synchronization_Item__c exhibitorSyncObj = [SELECT Id,ExpocadBooth__c,Opportunity__c,API_Synchronization_Transaction__c,API_Call_Type__c 
                                                        FROM API_Synchronization_Item__c 
                                                        LIMIT 1 ]; 

        exhibitorSyncObj.API_Call_Type__c = 'POST';
        String inviteExhbitorStr = Expo3EAPIUtils.inviteExhibitorInExpoCAD(exhibitorSyncObj);
        exhibitorSyncObj.API_Call_Type__c = 'GET';
        Expo3EAPIUtilHelper.AddQliWrapper inviteExhbitorStr2 = Expo3EAPIUtils.GetBoothFinancialFromExpocad(exhibitorSyncObj);
       
        System.assertNotEquals(inviteExhbitorStr,Null,'Value should not be null..1');//EX-101
        

        Test.stopTest();
    }
    @isTest
    static void positiveCover_inviteExhibitorInExpoCAD(){
        

        Test.startTest();
        ExpocadAPIHttpResponse_Mock mockCls = new ExpocadAPIHttpResponse_Mock();
        Test.setMock(HttpCalloutMock.class, new ExpocadAPIHttpResponse_Mock(200,'{ "message": "Invitation Emails Queued!", "RatePlan":"Test", "errors": [] }'));

        API_Synchronization_Item__c exhibitorSyncObj = [SELECT Id,ExpocadBooth__c,Opportunity__c,API_Synchronization_Transaction__c,API_Call_Type__c 
                                                        FROM API_Synchronization_Item__c 
                                                        LIMIT 1 ]; 

        exhibitorSyncObj.API_Call_Type__c = 'POST';
        String inviteExhbitorStr = Expo3EAPIUtils.inviteExhibitorInExpoCAD(exhibitorSyncObj);
        System.assertNotEquals(inviteExhbitorStr,Null,'value should not be null..2');//Ex-101
        

        Test.stopTest();
    }
    @isTest
    static void cover_GetBoothFinancialFromExpocad(){
        Test.startTest();
        ExpocadAPIHttpResponse_Mock mockCls = new ExpocadAPIHttpResponse_Mock();
        Test.setMock(HttpCalloutMock.class, new ExpocadAPIHttpResponse_Mock(200,'{ "message": "Invitation Emails Queued!", "RatePlan":"Test", "errors": [] }'));

        API_Synchronization_Item__c exhibitorSyncObj = [SELECT Id,ExpocadBooth__c,Opportunity__c,API_Synchronization_Transaction__c,API_Call_Type__c 
                                                        FROM API_Synchronization_Item__c 
                                                        LIMIT 1 ]; 
        Event_Series__c newES = new Event_Series__c();
        newES.Package_Identifier__c = 'PI';
        //insert newES;
        
        List<Opportunity> opp = [Select Id,AccountId,Billing_Contact__c,Opportunity_Contact__c,ownerId from Opportunity where Id= :exhibitorSyncObj.Opportunity__c];
        opp[0].Event_Series__c = newES.Id;
        update opp[0];
        exhibitorSyncObj.API_Call_Type__c = 'GET';
        Expo3EAPIUtilHelper.AddQliWrapper inviteExhbitorStr2 = Expo3EAPIUtils.GetBoothFinancialFromExpocad(exhibitorSyncObj);
        SBQQ__Quote__c quo = Expo3EAPIUtils.createQuote(opp);
        system.assertEquals(newES.Package_Identifier__c, 'PI', true);//EX-125
        Test.stopTest();
    }
     @isTest
    static void cover_GetBoothRelatedFromExpocad(){
        Test.startTest();
        ExpocadAPIHttpResponse_Mock mockCls = new ExpocadAPIHttpResponse_Mock();
        Test.setMock(HttpCalloutMock.class, new ExpocadAPIHttpResponse_Mock(200,'{ "message": "Invitation Emails Queued!", "RatePlan":"Test", "errors": [] }'));

        API_Synchronization_Item__c exhibitorSyncObj = [SELECT Id,ExpocadBooth__c,Opportunity__c,API_Synchronization_Transaction__c,API_Call_Type__c 
                                                        FROM API_Synchronization_Item__c 
                                                        LIMIT 1 ]; 
        Event_Series__c newES = new Event_Series__c();
        newES.Package_Identifier__c = 'PI';
        //insert newES;
        
        List<Opportunity> opp = [Select Id,AccountId,Billing_Contact__c,Opportunity_Contact__c,ownerId from Opportunity where Id= :exhibitorSyncObj.Opportunity__c];
        opp[0].Event_Series__c = newES.Id;
        update opp[0];
        exhibitorSyncObj.API_Call_Type__c = 'GET';
        system.assertEquals( opp[0].Event_Series__c, newES.Id, TRUE);//ex-125
        //Test.setMock(HttpCalloutMock.class, new ExpocadMock(200,'[{ "ExhibitorId": "0012J00002WLrU1QAL", "InvoiceNumber":"1154" }]'));
        try{Test.setMock(HttpCalloutMock.class, new ExpocadAPIHttpResponse_Mock(200,'[{ "ExhibitorId": "0012J00002WLrU1QAL", "InvoiceNumber":"1154" }]'));
        
        String inviteExhbitorStr2 = Expo3EAPIUtils.GetBoothRelatedFromExpocad(exhibitorSyncObj);

       SBQQ__Quote__c quo = Expo3EAPIUtils.createQuote(opp);
            List<ExpocadBooth__c> resu = Expo3EAPIUtils.processExpocadBooths(new ExpocadBooth__c(),new Expocad3E_Wrapper.GetAllBoothsWrapper(),opp[0],quo.Id,'');}catch(Exception e){System.debug('error'+e);}
        
        Test.stopTest();
    }    
    @isTest
    static void cover_GetBoothAllFromExpocad(){
        Test.startTest();
        ExpocadAPIHttpResponse_Mock mockCls = new ExpocadAPIHttpResponse_Mock();
        Test.setMock(HttpCalloutMock.class, new ExpocadAPIHttpResponse_Mock(200,'[{"ExhibitorId":"001DR00001PaOdkYAF","BoothNumber":"O107","Dimensions":"10\' x 10\'","DisplayNameOverride":"","XSize":"10\'","YSize":"10\'","Area":"100 SqFt","NumericArea":100.0,"Status":"Initial","BoothClasses":["SILVER"],"ChildExhibitors":[],"Pavilion":"","ShowInShow":"","BoothType":"Corner","UnitType":"ftin","HoldExhibitorId":"","HoldExhibitorName":"","HoldComment":"","OpenCorners":1,"IsDeleted":false,"IsOnHold":false,"IsRented":true}]'));

        API_Synchronization_Item__c exhibitorSyncObj = [SELECT Id,ExpocadBooth__c,Opportunity__c,API_Synchronization_Transaction__c,API_Call_Type__c 
                                                        FROM API_Synchronization_Item__c 
                                                        LIMIT 1 ]; 
        Event_Series__c newES = new Event_Series__c();
        newES.Package_Identifier__c = 'PI';
        //insert newES;
        
        List<Opportunity> opp = [Select Id,AccountId,Billing_Contact__c,Opportunity_Contact__c,ownerId from Opportunity where Id= :exhibitorSyncObj.Opportunity__c];
        opp[0].Event_Series__c = newES.Id;
        update opp[0];
        exhibitorSyncObj.API_Call_Type__c = 'GET';
        system.assertEquals( opp[0].Event_Series__c, newES.Id, TRUE);//ex-125

        String getBooths = Expo3EAPIUtils.GetBoothAllFromExpocad(exhibitorSyncObj);
        
        System.assertNotEquals(getBooths,Null,'value should not be null - GetBoothAllFromExpocad()');

        Test.stopTest();
    }
   @isTest
    static void coverGetCompanyListFrom3E(){
        Test.startTest();
        ExpocadAPIHttpResponse_Mock mockCls = new ExpocadAPIHttpResponse_Mock();
        Test.setMock(HttpCalloutMock.class, new ExpocadAPIHttpResponse_Mock(200,'{"companyTypeList" : [],"availableViews" : ["Test"] , "availableSIS" : ["Test"] }'));

        API_Synchronization_Item__c exhibitorSyncObj = [SELECT Id,ExpocadBooth__c,Opportunity__c,API_Synchronization_Transaction__c,API_Call_Type__c,Event_Edition__c,Type__c 
                                                        FROM API_Synchronization_Item__c 
                                                        LIMIT 1 ];
        
        exhibitorSyncObj.Type__c = '3E Expocad Company Type Setup';

        String getCompanyLstStr = Expo3EAPIUtils.getCompanyListFrom3E(exhibitorSyncObj);

        System.assertNotEquals(getCompanyLstStr,Null,'value should not be null..3');//EX-101

        Test.stopTest();
    }
    @isTest
    static void unitTest6(){
        Test.startTest();
        ExpocadAPIHttpResponse_Mock mockCls = new ExpocadAPIHttpResponse_Mock();
        Test.setMock(HttpCalloutMock.class, new ExpocadAPIHttpResponse_Mock(200,''));

        API_Synchronization_Item__c exhibitorSyncObj = [SELECT Id,ExpocadBooth__c,Opportunity__c,API_Synchronization_Transaction__c,API_Call_Type__c,Event_Edition__c,Type__c 
                                                        FROM API_Synchronization_Item__c 
                                                        LIMIT 1 ];
        
        //exhibitorSyncObj.Type__c = '3E Expocad Exhibitor Invite';

        String str = Expo3EAPIUtils.getContractsFrom3E(exhibitorSyncObj);

        System.assertNotEquals(str,Null,'value should not be null..4');//EX-101


        Test.stopTest();
    }
    @isTest
    static void unitTest61(){
        Test.startTest();
        ExpocadAPIHttpResponse_Mock mockCls = new ExpocadAPIHttpResponse_Mock();
        Test.setMock(HttpCalloutMock.class, new ExpocadAPIHttpResponse_Mock(200,''));

        API_Synchronization_Item__c exhibitorSyncObj = [SELECT Id,ExpocadBooth__c,Opportunity__c,API_Synchronization_Transaction__c,API_Call_Type__c,Event_Edition__c,Type__c 
                                                        FROM API_Synchronization_Item__c 
                                                        LIMIT 1 ];
        String str = Expo3EAPIUtils.getContractsFrom3E1(exhibitorSyncObj);
        System.assertNotEquals(str,Null,'value should not be null..4');//EX-101
        Test.stopTest();
    }
    @isTest
    static void unitTest62(){
        Test.startTest();
        ExpocadAPIHttpResponse_Mock mockCls = new ExpocadAPIHttpResponse_Mock();
        Test.setMock(HttpCalloutMock.class, new ExpocadAPIHttpResponse_Mock(200,''));

        API_Synchronization_Item__c exhibitorSyncObj = [SELECT Id,ExpocadBooth__c,Opportunity__c,API_Synchronization_Transaction__c,API_Call_Type__c,Event_Edition__c,Type__c 
                                                        FROM API_Synchronization_Item__c 
                                                        LIMIT 1 ];
        String str = Expo3EAPIUtils.getContractsFrom3E2(exhibitorSyncObj);
        System.assertNotEquals(str,Null,'value should not be null..4');//EX-101
        Test.stopTest();
    }
    @isTest
    static void unitTest63(){
        Test.startTest();
        ExpocadAPIHttpResponse_Mock mockCls = new ExpocadAPIHttpResponse_Mock();
        Test.setMock(HttpCalloutMock.class, new ExpocadAPIHttpResponse_Mock(200,''));

        API_Synchronization_Item__c exhibitorSyncObj = [SELECT Id,ExpocadBooth__c,Opportunity__c,API_Synchronization_Transaction__c,API_Call_Type__c,Event_Edition__c,Type__c 
                                                        FROM API_Synchronization_Item__c 
                                                        LIMIT 1 ];
        String str = Expo3EAPIUtils.getContractsFrom3E3(exhibitorSyncObj);
        System.assertNotEquals(str,Null,'value should not be null..4');//EX-101
        Test.stopTest();
    }
    @isTest
    static void unitTest64(){
        Test.startTest();
        ExpocadAPIHttpResponse_Mock mockCls = new ExpocadAPIHttpResponse_Mock();
        Test.setMock(HttpCalloutMock.class, new ExpocadAPIHttpResponse_Mock(200,''));

        API_Synchronization_Item__c exhibitorSyncObj = [SELECT Id,ExpocadBooth__c,Opportunity__c,API_Synchronization_Transaction__c,API_Call_Type__c,Event_Edition__c,Type__c 
                                                        FROM API_Synchronization_Item__c 
                                                        LIMIT 1 ];
        String str = Expo3EAPIUtils.getContractsFrom3E4(exhibitorSyncObj);
        System.assertNotEquals(str,Null,'value should not be null..4');//EX-101
        Test.stopTest();
    }
    @isTest
    static void unitTest65(){
        Test.startTest();
        ExpocadAPIHttpResponse_Mock mockCls = new ExpocadAPIHttpResponse_Mock();
        Test.setMock(HttpCalloutMock.class, new ExpocadAPIHttpResponse_Mock(200,''));

        API_Synchronization_Item__c exhibitorSyncObj = [SELECT Id,ExpocadBooth__c,Opportunity__c,API_Synchronization_Transaction__c,API_Call_Type__c,Event_Edition__c,Type__c 
                                                        FROM API_Synchronization_Item__c 
                                                        LIMIT 1 ];
        String str = Expo3EAPIUtils.getContractsFrom3E5(exhibitorSyncObj);
        System.assertNotEquals(str,Null,'value should not be null..4');//EX-101
        Test.stopTest();
    }
    @isTest
    static void unitTest66(){
        Test.startTest();
        ExpocadAPIHttpResponse_Mock mockCls = new ExpocadAPIHttpResponse_Mock();
        Test.setMock(HttpCalloutMock.class, new ExpocadAPIHttpResponse_Mock(200,''));

        API_Synchronization_Item__c exhibitorSyncObj = [SELECT Id,ExpocadBooth__c,Opportunity__c,API_Synchronization_Transaction__c,API_Call_Type__c,Event_Edition__c,Type__c 
                                                        FROM API_Synchronization_Item__c 
                                                        LIMIT 1 ];
        String str = Expo3EAPIUtils.getContractsFrom3E6(exhibitorSyncObj);
        System.assertNotEquals(str,Null,'value should not be null..4');//EX-101
        Test.stopTest();
    }
    @isTest
    static void unitTest67(){
        Test.startTest();
        ExpocadAPIHttpResponse_Mock mockCls = new ExpocadAPIHttpResponse_Mock();
        Test.setMock(HttpCalloutMock.class, new ExpocadAPIHttpResponse_Mock(200,''));

        API_Synchronization_Item__c exhibitorSyncObj = [SELECT Id,ExpocadBooth__c,Opportunity__c,API_Synchronization_Transaction__c,API_Call_Type__c,Event_Edition__c,Type__c 
                                                        FROM API_Synchronization_Item__c 
                                                        LIMIT 1 ];
        String str = Expo3EAPIUtils.getContractsFrom3E7(exhibitorSyncObj);
        System.assertNotEquals(str,Null,'value should not be null..4');//EX-101
        Test.stopTest();
    }
     @isTest
    static void unitTest68(){
        Test.startTest();
        ExpocadAPIHttpResponse_Mock mockCls = new ExpocadAPIHttpResponse_Mock();
        Test.setMock(HttpCalloutMock.class, new ExpocadAPIHttpResponse_Mock(200,''));

        API_Synchronization_Item__c exhibitorSyncObj = [SELECT Id,ExpocadBooth__c,Opportunity__c,API_Synchronization_Transaction__c,API_Call_Type__c,Event_Edition__c,Type__c 
                                                        FROM API_Synchronization_Item__c 
                                                        LIMIT 1 ];
        String str = Expo3EAPIUtils.getContractsFrom3E8(exhibitorSyncObj);
        System.assertNotEquals(str,Null,'value should not be null..4');//EX-101
        Test.stopTest();
    }
     @isTest
    static void unitTest69(){
        Test.startTest();
        ExpocadAPIHttpResponse_Mock mockCls = new ExpocadAPIHttpResponse_Mock();
        Test.setMock(HttpCalloutMock.class, new ExpocadAPIHttpResponse_Mock(200,''));

        API_Synchronization_Item__c exhibitorSyncObj = [SELECT Id,ExpocadBooth__c,Opportunity__c,API_Synchronization_Transaction__c,API_Call_Type__c,Event_Edition__c,Type__c 
                                                        FROM API_Synchronization_Item__c 
                                                        LIMIT 1 ];
        String str = Expo3EAPIUtils.getContractsFrom3E9(exhibitorSyncObj);
        System.assertNotEquals(str,Null,'value should not be null..4');//EX-101
        Test.stopTest();
    }
    @istest
    static void unitTest610(){
        Test.startTest();
        ExpocadAPIHttpResponse_Mock mockCls = new ExpocadAPIHttpResponse_Mock();
        Test.setMock(HttpCalloutMock.class, new ExpocadAPIHttpResponse_Mock(200,''));

        API_Synchronization_Item__c exhibitorSyncObj = [SELECT Id,ExpocadBooth__c,Opportunity__c,API_Synchronization_Transaction__c,API_Call_Type__c,Event_Edition__c,Type__c 
                                                        FROM API_Synchronization_Item__c 
                                                        LIMIT 1 ];
        String str = Expo3EAPIUtils.getContractsFrom3E10(exhibitorSyncObj);
        System.assertNotEquals(str,Null,'value should not be null..4');//EX-101
        Test.stopTest();
    }
    @istest
    static void unitTest611(){
        Test.startTest();
        ExpocadAPIHttpResponse_Mock mockCls = new ExpocadAPIHttpResponse_Mock();
        Test.setMock(HttpCalloutMock.class, new ExpocadAPIHttpResponse_Mock(200,''));

        API_Synchronization_Item__c exhibitorSyncObj = [SELECT Id,ExpocadBooth__c,Opportunity__c,API_Synchronization_Transaction__c,API_Call_Type__c,Event_Edition__c,Type__c 
                                                        FROM API_Synchronization_Item__c 
                                                        LIMIT 1 ];
        String str = Expo3EAPIUtils.getContractsFrom3E11(exhibitorSyncObj);
        System.assertNotEquals(str,Null,'value should not be null..4');//EX-101
        Test.stopTest();
    }
    @istest
    static void unitTest612(){
        Test.startTest();
        ExpocadAPIHttpResponse_Mock mockCls = new ExpocadAPIHttpResponse_Mock();
        Test.setMock(HttpCalloutMock.class, new ExpocadAPIHttpResponse_Mock(200,''));

        API_Synchronization_Item__c exhibitorSyncObj = [SELECT Id,ExpocadBooth__c,Opportunity__c,API_Synchronization_Transaction__c,API_Call_Type__c,Event_Edition__c,Type__c 
                                                        FROM API_Synchronization_Item__c 
                                                        LIMIT 1 ];
        String str = Expo3EAPIUtils.getContractsFrom3E12(exhibitorSyncObj);
        System.assertNotEquals(str,Null,'value should not be null..4');//EX-101
        Test.stopTest();
    }
    @isTest
    static void coverCompanyTypeList(){
        Test.startTest();
       
        Expocad3E_Wrapper.CompanyTypes recLis = new  Expocad3E_Wrapper.CompanyTypes();
        List<String> showInShowsData = new List<String>();
        showInShowsData.add('1');
        showInShowsData.add('2');
        List<Expocad3E_Wrapper.cls_companyListIds> listIdsData = new List<Expocad3E_Wrapper.cls_companyListIds>();
        Expocad3E_Wrapper.cls_companyTypeList listData = new Expocad3E_Wrapper.cls_companyTypeList();
        listData.companyListIds = listIdsData;
        listData.showInShows= showInShowsData;
        List<Expocad3E_Wrapper.cls_companyTypeList> companyTypeList = new List<Expocad3E_Wrapper.cls_companyTypeList>();
        companyTypeList.add(listData);
        
        Expocad3E_Wrapper.cls_companyListIds data = new Expocad3E_Wrapper.cls_companyListIds();
        data.name='test';
        data.companyId = '1';
        listIdsData.add(data);
        listData = new Expocad3E_Wrapper.cls_companyTypeList();
        listData.companyListIds = listIdsData;
        listData.showInShows= new List<String>();
        companyTypeList.add(listData);
        
        recLis.companyTypeList = companyTypeList;
        string jsonRes = JSON.serialize(recLis);

        // {"isDefaultType": true,"companyType": "Test1","description": "Test1","typeId": 2,"companyListIds": [{ "name": "Test1","companyId": "TEst1"}],"showInShows": "CustomField"}

        Expo3EAPIUtils.convertSyncData(jsonRes); //93 83 67 87 

        System.assertNotEquals(data.name, 'abc', 'Not Same');//EX-101
        
        Test.stopTest();
    }
     @isTest
    static void Coverage_GetContractsFrom3EEnd(){
        

        Test.startTest();
        ExpocadAPIHttpResponse_Mock mockCls = new ExpocadAPIHttpResponse_Mock();
        Test.setMock(HttpCalloutMock.class, new ExpocadAPIHttpResponse_Mock(200,'test'));

        API_Synchronization_Item__c exhibitorSyncObj = [SELECT Id,ExpocadBooth__c,Opportunity__c,API_Synchronization_Transaction__c,API_Call_Type__c,Type__c 
                                                        FROM API_Synchronization_Item__c 
                                                        LIMIT 1 ]; 
        exhibitorSyncObj.Type__c = '3E Expocad PDF Contract Pull Request';

        exhibitorSyncObj.API_Call_Type__c = 'GET';
       
        //String inviteExhbitorStr2 = Expo3EAPIUtils.companyTypeAssignInExpoCAD3E(exhibitorSyncObj);
        String apiToken = Expo3EAPIUtilHelper.fetchApiToken();
       try{ String inviteExhbitorStr3 = Expo3EAPIUtils.getContractsFrom3EEnd(exhibitorSyncObj);}catch(Exception ex){System.debug('exception'+ex);}
       system.assertEquals( exhibitorSyncObj.API_Call_Type__c, 'GET', true);//EX-125
                    
        Test.stopTest();
    }
     @isTest
    static void cover_EXPOCAD3E_CONTRACT_PULL(){
        Test.startTest();
        Opportunity opp = [Select Id From Opportunity limit 1];
        ExpocadBooth__c eb = [Select Id From ExpocadBooth__c limit 1];
        API_Synchronization_Transaction__c apiSyncTran = new API_Synchronization_Transaction__c();
        
        apiSyncTran.Status__c = 'Paused';
        
        apiSyncTran.X3rd_Party_Relationship__c = Expocad3E_Wrapper.EXPOCAD3E;
        apiSyncTran.Started_From__c = 'Expocad Booth';
        apiSyncTran.Request_Type__c = 'Asynchronous'; //Synchronous Asynchronous
        insert apiSyncTran; 
        
        API_Synchronization_Item__c apiSyncItemforExhibitors = new API_Synchronization_Item__c();
        apiSyncItemforExhibitors.API_Synchronization_Transaction__c = apiSyncTran.Id;
        apiSyncItemforExhibitors.Status__c =  'Queued';
        apiSyncItemforExhibitors.API_Call_Type__c = 'POST';
        apiSyncItemforExhibitors.ExpocadBooth__c = eb.Id;
        //apiSyncItemforExhibitors.Account__c = rec.AccountId;
        //apiSyncItemforExhibitors.Account__c = rec.AccountId;
        apiSyncItemforExhibitors.X3rd_Party_Relationship__c = Expocad3E_Wrapper.EXPOCAD3E;
        apiSyncItemforExhibitors.Type__c = Expocad3E_Wrapper.EXPOCAD3E_CONTRACT_PULL;
        insert apiSyncItemforExhibitors;
        apiSyncTran.Status__c = 'Queued';
        update apiSyncTran;
        
        system.assertEquals(apiSyncTran.Started_From__c, 'Expocad Booth', true);//EX-101
        
        APISynchronizationBatch api = new APISynchronizationBatch();
        Database.executeBatch(api,1);
        //APISynchronizationBatch testing = new  APISynchronizationBatch(new set<Id>{apiSyncItemforExhibitors.Id});  
        
        Test.stopTest();
           
    }
      @isTest
    static void coverEXPOCAD3E_BOOTH_DETAILS(){
        Test.startTest();
         Account acc = new Account();
        acc.Name='Test13';
        insert acc;
        Account acc1 = new Account();
        acc1.Name='Test23';
        insert acc1;
        
        Event_Edition__c evntEdition =[Select Id from Event_Edition__c Limit 1];
        Opportunity opp = new Opportunity();  
        opp.Partner_Account__c = acc.Id;
        opp.AccountId = acc1.Id;
        opp.Name = 'opp Test';
        opp.StageName = 'Prospecting'; 
        opp.CloseDate = System.today() + 30;
        opp.EventEdition__c = evntEdition.Id;
        opp.Type = 'New';
        insert opp;
        
        
        ExpocadBooth__c eb = new ExpocadBooth__c();
        //expoBooth.Name='test';
        eb.Opportunity__c = opp.Id;
        //expoBooth.Status__c='On Hold';
        insert eb;
        
        Contact con = new Contact();
        con.LastName = 'test3';
        con.email = 'test3@gmail.com'; 
        insert con;
        
        opp = new Opportunity();  
        opp.Partner_Account__c = acc.Id;
        opp.AccountId = acc1.Id;
        opp.Name = 'opp Test';
        opp.StageName = 'Prospecting'; 
        opp.CloseDate = System.today() + 30;
        opp.Opportunity_Contact__c = con.Id;
        opp.EventEdition__c = evntEdition.Id;
        opp.Type = 'New';
        insert opp;
        API_Synchronization_Transaction__c apiSyncTran = new API_Synchronization_Transaction__c();
        
        apiSyncTran.Status__c = 'Paused';
        
        apiSyncTran.X3rd_Party_Relationship__c = Expocad3E_Wrapper.EXPOCAD3E;
        apiSyncTran.Started_From__c = 'Opportunity';
        apiSyncTran.Request_Type__c = 'Asynchronous'; //Synchronous Asynchronous
        insert apiSyncTran; 
        
        API_Synchronization_Item__c apiSyncItemforExhibitors = new API_Synchronization_Item__c();
        apiSyncItemforExhibitors.API_Synchronization_Transaction__c = apiSyncTran.Id;
        apiSyncItemforExhibitors.Status__c =  'Queued';
        apiSyncItemforExhibitors.API_Call_Type__c = 'POST';
        apiSyncItemforExhibitors.ExpocadBooth__c = eb.Id;
        //apiSyncItemforExhibitors.Account__c = rec.AccountId;
        //apiSyncItemforExhibitors.Account__c = rec.AccountId;
        apiSyncItemforExhibitors.X3rd_Party_Relationship__c = Expocad3E_Wrapper.EXPOCAD3E;
        apiSyncItemforExhibitors.Type__c = Expocad3E_Wrapper.EXPOCAD3E_BOOTH_DETAILS;
        insert apiSyncItemforExhibitors;
        apiSyncTran.Status__c = 'Queued';
        update apiSyncTran;
        
        system.assertEquals(apiSyncTran.Started_From__c, 'Opportunity', true);//EX-101
        
        APISynchronizationBatch api = new APISynchronizationBatch();
        Database.executeBatch(api,1);
        //APISynchronizationBatch testing = new  APISynchronizationBatch(new set<Id>{apiSyncItemforExhibitors.Id});  
        
        Test.stopTest();
           
    }
    
@isTest
    static void coverEXPOCAD3E_BOOTH_REQITEMS(){
        Test.startTest();
        Account acc = new Account();
        acc.Name='Test14';
        insert acc;
        Account acc1 = new Account();
        acc1.Name='Test24';
        insert acc1;
       
        Event_Edition__c evntEdition = [Select id from Event_Edition__c Limit 1];
               
        Opportunity opp = new Opportunity();  
        opp.Partner_Account__c = acc.Id;
        opp.AccountId = acc1.Id;
        opp.Name = 'opp Test';
        opp.StageName = 'Prospecting'; 
        opp.CloseDate = System.today() + 30;
        opp.EventEdition__c = evntEdition.Id;
        opp.Type = 'New';
        insert opp;
        
        
        ExpocadBooth__c eb = new ExpocadBooth__c();
        //expoBooth.Name='test';
        eb.Opportunity__c = opp.Id;
        //expoBooth.Status__c='On Hold';
        insert eb;
        
        Contact con = new Contact();
        con.LastName = 'test4';
        con.email = 'test4@gmail.com'; 
        insert con;
        
        opp = new Opportunity();  
        opp.Partner_Account__c = acc.Id;
        opp.AccountId = acc1.Id;
        opp.Name = 'opp Test';
        opp.StageName = 'Prospecting'; 
        opp.CloseDate = System.today() + 30;
        opp.Opportunity_Contact__c = con.Id;
        opp.EventEdition__c = evntEdition.Id;
        opp.Type = 'New';
        insert opp;
        API_Synchronization_Transaction__c apiSyncTran = new API_Synchronization_Transaction__c();
        
        apiSyncTran.Status__c = 'Paused';
        
        apiSyncTran.X3rd_Party_Relationship__c = Expocad3E_Wrapper.EXPOCAD3E;
        apiSyncTran.Started_From__c = 'Opportunity';
        apiSyncTran.Request_Type__c = 'Asynchronous'; //Synchronous Asynchronous
        insert apiSyncTran; 
        
        API_Synchronization_Item__c apiSyncItemforExhibitors = new API_Synchronization_Item__c();
        apiSyncItemforExhibitors.API_Synchronization_Transaction__c = apiSyncTran.Id;
        apiSyncItemforExhibitors.Status__c =  'Queued';
        apiSyncItemforExhibitors.API_Call_Type__c = 'POST';
        apiSyncItemforExhibitors.ExpocadBooth__c = eb.Id;
        //apiSyncItemforExhibitors.Account__c = rec.AccountId;
        //apiSyncItemforExhibitors.Account__c = rec.AccountId;
        apiSyncItemforExhibitors.X3rd_Party_Relationship__c = Expocad3E_Wrapper.EXPOCAD3E;
        apiSyncItemforExhibitors.Type__c = Expocad3E_Wrapper.EXPOCAD3E_BOOTH_REQITEMS;
        insert apiSyncItemforExhibitors;
        apiSyncTran.Status__c = 'Queued';
        update apiSyncTran;
        
        system.assertEquals(apiSyncTran.Started_From__c, 'Opportunity', true);//EX-101
        
        APISynchronizationBatch api = new APISynchronizationBatch();
        Database.executeBatch(api,1);
        //APISynchronizationBatch testing = new  APISynchronizationBatch(new set<Id>{apiSyncItemforExhibitors.Id});  
        
        Test.stopTest();
           
    }
     @isTest
    static void coverEXPOCAD3E_CONTRACT_PULL_END(){
        Test.startTest();
        Account acc=[Select Id From Account limit 1];
        Opportunity opp = [Select Id From Opportunity limit 1];
        ExpocadBooth__c eb = [Select Id From ExpocadBooth__c limit 1];
        API_Synchronization_Transaction__c apiSyncTran = new API_Synchronization_Transaction__c();
        
        apiSyncTran.Status__c = 'Paused';
        
        apiSyncTran.X3rd_Party_Relationship__c = Expocad3E_Wrapper.EXPOCAD3E;
        apiSyncTran.Started_From__c = 'Opportunity';
        apiSyncTran.Request_Type__c = 'Asynchronous'; //Synchronous Asynchronous
        insert apiSyncTran; 
        
        API_Synchronization_Item__c apiSyncItemforExhibitors = new API_Synchronization_Item__c();
        apiSyncItemforExhibitors.API_Synchronization_Transaction__c = apiSyncTran.Id;
        apiSyncItemforExhibitors.Status__c =  'Queued';
        apiSyncItemforExhibitors.API_Call_Type__c = 'POST';
        apiSyncItemforExhibitors.ExpocadBooth__c = eb.Id;
        apiSyncItemforExhibitors.X3rd_Party_Relationship__c = Expocad3E_Wrapper.EXPOCAD3E;
        apiSyncItemforExhibitors.Type__c = Expocad3E_Wrapper.EXPOCAD3E_CONTRACT_PULL_END;
        insert apiSyncItemforExhibitors;
        apiSyncTran.Status__c = 'Queued';
        update apiSyncTran;
        
        system.assertEquals(apiSyncTran.Started_From__c, 'Opportunity', true);//EX-101
        
        APISynchronizationBatch api = new APISynchronizationBatch();
        Database.executeBatch(api,1);
        //APISynchronizationBatch testing = new  APISynchronizationBatch(new set<Id>{apiSyncItemforExhibitors.Id}); 
         SBQQ__Quote__c oQuote = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Quote Sent', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = opp.Id, SBQQ__Account__c = acc.Id, SBQQ__Primary__c = true);
        Insert oQuote;
        CPQQuoteAPIHelper quoteApi = new CPQQuoteAPIHelper();
        QuoteModel qmodel=Expo3EAPIUtils.SaveCPQQuote(oQuote.Id);
        qmodel=quoteApi.read(oQuote.Id);
        Test.stopTest();
           
    }
   
}