/**
* File          :   APISynchronization_Test
* Project       :   (3E Intregration)
* Created Date  :   24th April 2022
* Created By    :   (Girikon)

* *******************************************************************************************************
* @description : APISynchronizationBatch,Expo3EAPIUtils
* *******************************************************************************************************
* Last Modified By : Girikon(Aradhana),on 13th Oct 2022[EX-23]
*/
@isTest
public class APISynchronization_Test {
    @testSetup
    static void setupMethod(){
        
        Account acc = new Account();
        acc.Name='Test1';
        insert acc;
        Account acc1 = new Account();
        acc1.Name='Test2';
        insert acc1;
        /*
        Event_Edition__c event = new Event_Edition__c();
        event.Name = 'test';
        event.X3E_API_ID__c = 'test';
        event.X3E_Status__c = 'Active';
        event.X3rd_Party_Relationship__c = '3E ExpoCAD';
        event.Auto_Invite_Exhibitor_in_3E__c = true ; 
        insert event;
        */
        Event_Edition__c evntEdition = new Event_Edition__c();
        evntEdition.Name = 'test';
        evntEdition.X3E_API_ID__c = '22col';
        evntEdition.CompanyShowInShow__c = 'CompanyId, CompanyTypeId-CompanyName, ShowInShows\nTest,11-Test,11';
        evntEdition.All_CompanyTypes_List__c = 'CompanyId, CompanyTypeId-CompanyName, ShowInShows\nTest,11-Test,11';
        evntEdition.X3E_Status__c = 'Active';
        evntEdition.X3rd_Party_Relationship__c = '3E ExpoCAD';
        evntEdition.Auto_Invite_Exhibitor_in_3E__c = true ; 
        insert evntEdition;
        
        Opportunity opp = new Opportunity();  
        opp.Partner_Account__c = acc.Id;
        opp.AccountId = acc1.Id;
        opp.Name = 'opp Test';
        opp.StageName = 'Prospecting'; 
        opp.CloseDate = System.today() + 30;
        opp.EventEdition__c = evntEdition.Id;
        
        insert opp;
        
        
        ExpocadBooth__c expoBooth = new ExpocadBooth__c();
        //expoBooth.Name='test';
        expoBooth.Opportunity__c = opp.Id;
        //expoBooth.Status__c='On Hold';
        insert expoBooth;
        
        Contact con = new Contact();
        con.LastName = 'test';
        con.email = 'test@gmail.com'; 
        insert con;
        
        opp = new Opportunity();  
        opp.Partner_Account__c = acc.Id;
        opp.AccountId = acc1.Id;
        opp.Name = 'opp Test';
        opp.StageName = 'Prospecting'; 
        opp.CloseDate = System.today() + 30;
        opp.Opportunity_Contact__c = con.Id;
        opp.EventEdition__c = evntEdition.Id;
        
        insert opp;
        
    }
    @isTest
    static void unitTest1(){
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
        
        Test.stopTest();
           
    }
    @isTest
    static void unitTest2(){
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
        apiSyncItemforExhibitors.Type__c = Expocad3E_Wrapper.EXPOCAD3E_COMPANY_TYPE;
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
    static void unitTest4(){
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
    static void unitTest5(){
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
        apiSyncItemforExhibitors.Type__c = Expocad3E_Wrapper.EXPOCAD3E_COMPANY_TYPE_ASSIGN;
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
    static void unitTest6(){
        Test.startTest();
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
        //apiSyncItemforExhibitors.Account__c = rec.AccountId;
        //apiSyncItemforExhibitors.Account__c = rec.AccountId;
        apiSyncItemforExhibitors.X3rd_Party_Relationship__c = Expocad3E_Wrapper.EXPOCAD3E;
        apiSyncItemforExhibitors.Type__c = Expocad3E_Wrapper.EXPOCAD3E_CONTRACT_PULL;
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
    static void unitTest7(){
        Test.startTest();
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
    static void unitTest8(){
        Test.startTest();
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
    static void unitTest9(){
        Test.startTest();
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
    static void unitTest10(){
        Test.startTest();
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
        //apiSyncItemforExhibitors.Account__c = rec.AccountId;
        //apiSyncItemforExhibitors.Account__c = rec.AccountId;
        apiSyncItemforExhibitors.X3rd_Party_Relationship__c = Expocad3E_Wrapper.EXPOCAD3E;
        apiSyncItemforExhibitors.Type__c = Expocad3E_Wrapper.EXPOCAD3E_CONTRACT_PULL_END;
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
    static void unitTest3(){
        Test.StartTest();
        
        string jsonRes = '{"ExhibitorId":"","BoothNumber":"1011A234","Dimensions":"20\' x 20\'","DisplayNameOverride":"","XSize":"20\'","YSize":"20\'","Area":"400 SqFt","NumericArea":400,"Status":"","BoothClasses":["Standard Booth"],"ChildExhibitors":[],"Pavilion":"","ShowInShow":"","BoothType":"Island","UnitType":"ftin","HoldExhibitorId":"530307","HoldExhibitorName":"Account_530307","HoldComment":"Booth","OpenCorners":4,"IsDeleted":false,"IsOnHold":true,"IsRented":false}';

        Test.setMock(HttpCalloutMock.class, new ExpocadAPIHttpResponse_Mock(200,jsonRes));
        system.assertNotEquals(jsonRes, '', 'No body found');
        
        Test.stopTest();
    }
    
    
}