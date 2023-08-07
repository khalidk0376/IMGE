/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-14-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class SyncRecords3EExpocadUtil_Test {
    
    @testSetup
    static void setupMethod(){
        
        Account acc = new Account();
        acc.Name='Test1';
        insert acc;
        Account acc1 = new Account();
        acc1.Name='Test2';
        insert acc1;
        
        Event_Edition__c event = new Event_Edition__c();
        event.Name = 'test';
        event.X3E_API_ID__c = 'test';
        event.X3E_Status__c = 'Active';
        event.X3rd_Party_Relationship__c = '3E ExpoCAD';
        event.Auto_Invite_Exhibitor_in_3E__c = true ;
        event.Opportunity_Probability_During_3E_Invite__c = '5'; 
        insert event;
        
        Opportunity opp = new Opportunity();  
        opp.Partner_Account__c = acc.Id;
        opp.AccountId = acc1.Id;
        opp.Name = 'opp Test';
        opp.StageName = 'Prospecting'; 
        opp.CloseDate = System.today() + 30; 
        opp.EventEdition__c = event.Id; 
        opp.Probability = 20;
        
        insert opp;

        ExpocadBooth__c expoBooth = new ExpocadBooth__c();
        expoBooth.Booth_Number__c = 'test';
        expoBooth.status__c = 'Rented';
        //expoBooth.Event_Code__c = 'test';
        expoBooth.Opportunity__c = opp.Id;
        insert expoBooth;

        API_Synchronization_Transaction__c syncTrans = new API_Synchronization_Transaction__c();
        insert syncTrans;

        API_Synchronization_Item__c exhibitorSyncObj = new API_Synchronization_Item__c();
        //exhibitorSyncObj.Name = 'test';
        exhibitorSyncObj.ExpocadBooth__c = expoBooth.Id;
        exhibitorSyncObj.Opportunity__c = opp.Id;
        exhibitorSyncObj.API_Synchronization_Transaction__c = syncTrans.Id;
        exhibitorSyncObj.API_Call_Type__c = 'GET';
        exhibitorSyncObj.Event_Edition__c = event.Id;
        exhibitorSyncObj.Type__c = '3E Expocad Exhibitor Invite';
        insert exhibitorSyncObj;
        
        
    }
    
    @isTest
    static void unitTest1(){
        Test.startTest();
        ExpocadAPIHttpResponse_Mock mockCls = new ExpocadAPIHttpResponse_Mock();
        Test.setMock(HttpCalloutMock.class, new ExpocadAPIHttpResponse_Mock(200,'{"companyTypeList" : [],"availableViews" : ["Test"] , "availableSIS" : ["Test"] }'));
        opportunity opp1 = [SELECT Id FROM Opportunity WHERE Name = 'opp Test' LIMIT 1];
        Event_Edition__c event = [SELECT Id,Name FROM Event_Edition__c WHERE Name = 'test'];
        API_Synchronization_Transaction__c api = new API_Synchronization_Transaction__c();
        insert api;
        
        Boolean exhibitorOnly = true;
        
        
        APISynchronizationBatch ApiSync = new APISynchronizationBatch(); 
        id batchId = Database.executeBatch(ApiSync);
        SyncRecords3EExpocadUtil.getJobs(batchId);
        boolean actual = SyncRecords3EExpocadUtil.getCompanyTypeList(event.id);
        System.assertEquals(false, actual,true);//EX-101

        SyncRecords3EExpocadUtil.getCompanyTypeList(event.id);
        
        SyncRecords3EExpocadUtil.getBoothDetailsFromExpocad(opp1.id);
        //SyncRecords3EExpocadUtil.getTransactionDetail(api.Id);
        
        
        //SyncRecords3EExpocadUtil.getCompanyListFrom3E(event.id);
        
        List<Opportunity> oppList = SyncRecords3EExpocadUtil.fetchOpportunity(opp1.Id); 
        System.assertNotEquals(oppList,Null,'Value cannot be Null');//EX-101
        
        List<Opportunity> oppList1 = SyncRecords3EExpocadUtil.fetchAllOpportunity(event.id);
        System.assertNotEquals(oppList1,Null,'Must contain value');//EX-125
        //SyncRecords3EExpocadUtil.syncExhibitorInvite(opp1.Id,false);
        //SyncRecords3EExpocadUtil.getContractsFrom3E(opp1.Id,exhibitorOnly);
        SyncRecords3EExpocadUtil.getCompanyListFrom3E(event.Id);
        SyncRecords3EExpocadUtil.getOpportunitiesprobability(event.Id); 
        
        
        
        Test.stopTest();
    }
    @isTest
    public static void SyncExhibitortest(){
        Test.startTest();
        ExpocadAPIHttpResponse_Mock mockCls = new ExpocadAPIHttpResponse_Mock();
        Test.setMock(HttpCalloutMock.class, new ExpocadAPIHttpResponse_Mock(200,'{"message": "The following invitation failed","errors": [{"email": "test@girikon.com", "customerId": "ACCT-005774", "reason": "CustoemrId not found in event" } ] }'));
        opportunity oppList = [Select id,Name,accountId from Opportunity Where Name = 'opp Test' LIMIT 1];
        Event_Edition__c event = [SELECT Id,Name FROM Event_Edition__c WHERE Name = 'test'];
        SyncRecords3EExpocadUtil.TransactionDetails wrap = SyncRecords3EExpocadUtil.getContractsFrom3E(oppList.Id,true);
        
        API_Synchronization_Transaction__c rec = SyncRecords3EExpocadUtil.getTransactionDetail(wrap.trasactionId);
        AsyncApexJob rec1 = SyncRecords3EExpocadUtil.getJobs(wrap.batchId);

        System.assertNotEquals(null, wrap,'Value cannot be Null');//EX-101
        Test.stopTest();
    } 
     @isTest
    public static void syncExhibitorInvitetest(){
        Test.startTest();
        ExpocadAPIHttpResponse_Mock mockCls = new ExpocadAPIHttpResponse_Mock();
        Test.setMock(HttpCalloutMock.class, new ExpocadAPIHttpResponse_Mock(200,'{ "message": "Invitation Emails Queued!", "errors": [] }'));
        opportunity oppList = [Select id,Name,accountId from Opportunity Where Name = 'opp Test' LIMIT 1];
        Event_Edition__c event = [SELECT Id,Name FROM Event_Edition__c WHERE Name = 'test'];
        SyncRecords3EExpocadUtil.TransactionDetails wrap = SyncRecords3EExpocadUtil.syncExhibitorInvite(oppList.Id,true);
        
        //API_Synchronization_Transaction__c rec = SyncRecords3EExpocadUtil.getTransactionDetail(wrap.trasactionId);
        //AsyncApexJob rec1 = SyncRecords3EExpocadUtil.getJobs(wrap.batchId);

        System.assertNotEquals(null, wrap,'Value cannot be Null');//EX-101
        Test.stopTest();
    } 

    

    
}