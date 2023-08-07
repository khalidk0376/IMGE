public with sharing class InitiateExhibitorInviteBatch implements Database.Batchable<sObject>,Database.stateful {
    
    public list<Opportunity> opprtunityList;
    public Set<Id> oppConSet;
    public List<API_Synchronization_Transaction__c> newApiTransList = new List<API_Synchronization_Transaction__c>();
    public List<API_Synchronization_Item__c> newItemList = new List<API_Synchronization_Item__c>();
    public Set<ID> APiSyncTransIdSet = new Set<ID>();

    Public InitiateExhibitorInviteBatch(Set<ID> eventEditionIdSet){
        oppConSet = new Set<Id>();
         opprtunityList = [Select Id,AccountID From Opportunity Where EventEdition__c IN  :eventEditionIdSet];
        System.debug('##'+opprtunityList);
        if (opprtunityList != null && !opprtunityList.isEmpty()) {
            for(Opportunity rec : opprtunityList){
                oppConSet.add(rec.Id); 
            }
        }
    }


    public Database.QueryLocator start(Database.BatchableContext bc){
        Set<String> typeStatus = new Set<String>{Expocad3E_Wrapper.EXPOCAD3E_EXHIBITOR_INVITE};
        String query = 'SELECT API_Synchronization_Transaction__c, API_Call_Type__c, X3rd_Party_Relationship__c, Account__c, Id, Status__c, Type__c, Opportunity__c, Contact__c FROM API_Synchronization_Item__c Where Status__c = \'Paused\' and type__c IN :typeStatus and X3rd_Party_Relationship__c = \'3E ExpoCAD\' and (Opportunity__c IN :opprtunityList) WITH SECURITY_ENFORCED';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<API_Synchronization_Item__c> items){
        
         for(API_Synchronization_Item__c item: items){ 
             if(!APiSyncTransIdSet.contains(item.API_Synchronization_Transaction__c)){
                 newApiTransList.add(new API_Synchronization_Transaction__c(Id = item.API_Synchronization_Transaction__c,Status__c = 'Queued'));
                 APiSyncTransIdSet.add(item.API_Synchronization_Transaction__c);
             }
            
            item.Status__c = 'Queued';
            newItemList.add(item);
         }
        
    }

    public void finish(Database.BatchableContext bc){
 
        if(newItemList != null && !newItemList.isEmpty()){
             if(Schema.sObjectType.API_Synchronization_Item__c.isupdateable()) 
            {
                update newItemList;
            }
         }
         if(newApiTransList != null && !newApiTransList.isEmpty()){
             if(Schema.sObjectType.API_Synchronization_Transaction__c.isupdateable())
            {
                update newApiTransList;
            }
         }

    }

}