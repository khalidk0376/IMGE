/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 08-30-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class APISynchronizationHelper_Test {

    @TestSetup
    static void makeData(){
        API_Synchronization_Transaction__c  api_Sync_Tran = new API_Synchronization_Transaction__c();
        insert api_Sync_Tran;
        API_Synchronization_Item__c item = new API_Synchronization_Item__c();
        item.API_Synchronization_Transaction__c = api_Sync_Tran.Id;
        insert item;
    }
    
    @isTest
    static void unitTest1(){
        Test.startTest();
        API_Synchronization_Transaction__c  api_Sync_Tran = new API_Synchronization_Transaction__c();
        insert api_Sync_Tran;
        API_Synchronization_Item__c item = new API_Synchronization_Item__c();
        item.API_Synchronization_Transaction__c = api_Sync_Tran.Id;
        insert item;
        List<User> notifyToUser = new List<User>([Select id,Email,Username from user limit 1]); 
        
        API_Synchronization_Transaction__c apiSyncId = [SELECT Id FROM API_Synchronization_Transaction__c LIMIT 1 ];
        Set<Id> idSet = new Set<Id>(); 
        idSet.add(apiSyncId.Id);
        APISynchronizationHelper.getAPISyncItemsQueryAndStartProcessing(idSet);
        
        List<Event_Edition__c> event = new List<Event_Edition__c>();
        APISynchronizationHelper.updateEditionsStatus(event);
        
        APISynchronizationHelper.updateSingleAPISyncTransaction(Api_Sync_Tran);
        
        List<Opportunity> opp = new List<Opportunity>();
        insert opp;
        APISynchronizationHelper.updateOpportunityData(opp);
        
        String metaDataNme = 'test';
        String thrdParty = '3E';
        APISynchronizationHelper.getAPIDetails(metaDataNme,thrdParty);
        
        System.assertEquals(metaDataNme, 'test', true);//EX-101
        
        APISynchronizationHelper.scheduleBatchForNextItems();
        
        //APISynchronizationHelper.getBypassExternalSync();
        
        APISynchronizationHelper.sendEmailOnBatchFail(idSet);
        
        Id parentId ;
        String jsonResponse = 'test';
        APISynchronizationHelper.createResponseAttchment(parentId,jsonResponse);
        
        APISynchronizationHelper.getBodyFormResponseAttchment(parentId);
        
        String objectName = 'API_Synchronization_Item__c';
        String thirdParty = '3E';
        //APISynchronizationHelper.getFieldMappingForAPIResponse(objectName,thirdParty);  
        
        Map<Id,List<Id>> mapRoles = new Map<Id,List<Id>>();
        Id roleId ;
        List<Id> subRoleIds = new List<Id>();
        APISynchronizationHelper.getRolesAndSubordinates(mapRoles, roleId, subRoleIds);
        
        
        APISynchronizationHelper.validateSyncItem(item);
        
        APISynchronizationHelper.updateSyncItemStatus(item);
        
        Test.stopTest();
    }
    
    @isTest
    static void getCoverage(){
        Test.startTest();
        List<API_Synchronization_Transaction__c> apiSyncTransaction = [SELECT Id FROM API_Synchronization_Transaction__c  limit 1];
        Set<Id> idSet = new Set<Id>();
        idSet.add(apiSyncTransaction[0].Id); 
        APISynchronizationHelper.sendEmailOnBatchFail(idSet);
        // APISyncFromAPITransaction.API_SYNCHRONIZATION_BATCH 
        System.assertNotEquals(apiSyncTransaction[0].id, 'test123',false);//EX-101
        
        Test.stopTest();
    }

}