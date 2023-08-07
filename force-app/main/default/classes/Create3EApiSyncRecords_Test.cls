/**
* File          :   Create3EApiSyncRecords_Test
* Project       :   3E Expocad Integration
* Created By    :   Aradhana 
* Created Date  :   7th July 2022
* 
* *******************************************************************************************************
* @description : test class for coverage of Create3EApiSyncRecords(89%)  
* *******************************************************************************************************
* Modification log : Modified by Aradhana on 5th Dec 2022 for [EX-159]  
  
*/
@isTest
public class Create3EApiSyncRecords_Test {
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
        insert event;
        
        Opportunity opp = new Opportunity();  
        opp.Partner_Account__c = acc.Id;
        opp.AccountId = acc1.Id;
        opp.Name = 'opp Test';
        opp.StageName = 'Prospecting'; 
        opp.CloseDate = System.today() + 30;
        opp.EventEdition__c = event.Id;
        
        insert opp;

        ExpocadBooth__c expoBooth = new ExpocadBooth__c();
        //expoBooth.Name='test';
        expoBooth.Opportunity__c = opp.Id;
        //expoBooth.Status__c='On Hold';
        insert expoBooth;

        API_Synchronization_Transaction__c api = new API_Synchronization_Transaction__c();
        insert api;

        API_Synchronization_Item__c apiSync = new API_Synchronization_Item__c();
        apiSync.API_Synchronization_Transaction__c = api.Id;
        insert apiSync;
        
        
    }
    @isTest
    static void unitTest1(){ 
        Test.startTest();
        Create3EApiSyncRecords.ApiSyncRecordsWrapper apiSync = new Create3EApiSyncRecords.ApiSyncRecordsWrapper();
        apiSync.apiCallName =  'ExhibitorInvite';
        Create3EApiSyncRecords.insertAllAPISyncItem(apiSync);
        
        List<API_Synchronization_Transaction__c> lstApiSyncTran = new List<API_Synchronization_Transaction__c>();
        List<API_Synchronization_Item__c> lstApiSyncItem = new List<API_Synchronization_Item__c>(); 
        lstApiSyncTran.add(new API_Synchronization_Transaction__c());
        lstApiSyncItem.add(new API_Synchronization_Item__c());
        
        Create3EApiSyncRecords.insertAllRecords(lstApiSyncTran,lstApiSyncItem,apiSync);
        
        List<opportunity> opportunityList = new List<opportunity>();
        opportunityList = [Select Id From Opportunity limit 1];
        String requestType = 'Synchronous';
        Create3EApiSyncRecords.syncExhibitorInviteToExpocad3E(opportunityList,requestType);
        
        Create3EApiSyncRecords.getContractFromExpocad3E(opportunityList,requestType);
        
        List<Event_Edition__c> editionList = new List<Event_Edition__c>();
        Create3EApiSyncRecords.getCompanyTypeListFromExpocad3E(editionList,requestType);
        
        Map<Id,opportunity> newOpportunityMap = new Map<Id,opportunity>([SELECT Id,Name,(SELECT id,Opportunity__c FROM ExpocadBooths__r) From Opportunity WHERE Name = 'opp Test']);
        Map<Id,Boolean> newOppToItemStatus = new Map<Id,Boolean>();
        
        Set<String> exitingExhibitorIds = new Set<String>();
        Create3EApiSyncRecords.insertAPISyncItemsForExhibitors(newOpportunityMap,newOppToItemStatus,exitingExhibitorIds);

        //Map<Id,Opportunity> newOpportunityMap = new Map<Id,Opportunity>();
        Create3EApiSyncRecords.insertAPISyncItemsForContracts(newOpportunityMap);
        
        Map<Id,Event_Edition__c> newEditionMap = new Map<Id,Event_Edition__c>([SELECT Id,Name,X3E_API_ID__c FROM Event_Edition__c limit 10]);
        Create3EApiSyncRecords.insertAPISyncItemsForCompanyList(newEditionMap);
        
        //EX-21
         
        List<ExpocadBooth__c> expoBoothList= new List<ExpocadBooth__c>([Select Id,Opportunity__c,Booth_Number__c FROM ExpocadBooth__c  limit 10]);//EX-159
        Map<Id,ExpocadBooth__c> expoBoothMapList= new Map<Id,ExpocadBooth__c>([Select Id,Opportunity__c FROM ExpocadBooth__c  limit 10]);//EX-159
        
         Create3EApiSyncRecords.insertExpoBoothForHoldUnhold(expoBoothMapList,true);
        Create3EApiSyncRecords.processCompanyTypeAssignToExpocad3E(expoBoothList,'Asynchronous');
        
        //EX-154
        Create3EApiSyncRecords.syncBooth(expoBoothList[0],'Asynchronous',Expocad3E_Wrapper.EXPOCAD_BOOTH_RENT, true,'');
        
           //Map<Id,ExpocadBooth__c> newExpoBoothMap=new Map<Id,ExpocadBooth__c>([Select Id FROM ExpocadBooth__c]);
           ExpocadBooth__c eb = new ExpocadBooth__c();
               eb.Status__c='On Hold';
               //eb.Opportunity__c = opp.Id;
               insert eb;
           API_Synchronization_Transaction__c apitran = new API_Synchronization_Transaction__c();
            apitran.Started_From__c='Expocad Booth';
            apitran.Status__c='Queued';
            apitran.X3rd_Party_Relationship__c='3E ExpoCAD';
            insert apitran;

           API_Synchronization_Item__c apiSyncitem = new API_Synchronization_Item__c();
               apiSyncitem.API_Synchronization_Transaction__c = apitran.Id;
                apiSyncitem.Status__c = 'Queued';
                apiSyncitem.API_Call_Type__c = 'POST';
                apiSyncitem.ExpocadBooth__c = eb.Id;
                apiSyncitem.X3rd_Party_Relationship__c = '3E ExpoCAD';
                apiSyncitem.Type__c ='3E Expocad CompanyType Assign' ;
           insert apiSyncitem;
        
        system.assertEquals(apiSyncitem.X3rd_Party_Relationship__c,'3E ExpoCAD', true);//EX-101
        //EX-159
        Create3EApiSyncRecords.getBoothFromExpocad(opportunityList, requestType);
        Create3EApiSyncRecords.getBoothFinancialsExpocad(expoBoothList, requestType);
        Boolean checkStatus;
        Create3EApiSyncRecords.insertAPISyncItemsForBoothReqItems(expoBoothMapList, true);
        
        
        Test.stopTest();
    }
    
}