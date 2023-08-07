/**
* File:         APISyncFromAPITransaction
* Project:      3E Expocad Integration
* Created Date: 19th April 2022
* Created By:   (Girikon)
* Test Class:   APISyncFromAPITransaction_Test
* Coverage:     90%
* *******************************************************************************************************
* @description : This class will execute the batch which will sync the API Sync Transaction records to MYS.
* *******************************************************************************************************
* Modification log :   
    1. Girikon (Aradhana)  [15th June 2022 (EX-7)]  
*
*/
public with sharing class APISyncFromAPITransaction implements TriggerInterface_APISyncTransaction.Runnable
{
   
    public static final String REQUEUE_FOR_ERRONEOUS_RECORDS    = 'Requeue for Erroneous records';
    public static final String REQUEUE_FOR_SUCCESSFUL_RECORDS   = 'Requeue for Successful records';
    public static final String API_SYNCHRONIZATION_BATCH   = 'APISynchronizationBatch';    
    public static final String AFTER_UPDATE    = 'After Update';

    public static final Set<String> VALID_PROCESSING_STATUES  = new Set<String> {'Holding','Queued','Preparing','Processing'};
    

    /**
    * @description [This method is for running the Trigger on API_Synchronization_Transaction__c using the interface class on After insert and After Update.]
    * @param trig
    */
    
    public void run(TriggerInterface_APISyncTransaction.Trig trig)
    {
        List<API_Synchronization_Transaction__c> lstApiSyncTran = new List<API_Synchronization_Transaction__c>();
         List<API_Synchronization_Transaction__c> lstApiSyncTranBoothAll = new List<API_Synchronization_Transaction__c>();
         List<Expo3EAPIUtilHelper.AddQliWrapper> AddQliWrapperList = new List<Expo3EAPIUtilHelper.AddQliWrapper>();
        String triggerOn;
        System.debug('lstApiSyncTranBoothAll1---'+lstApiSyncTranBoothAll);
        boolean isBypass = true;//?? APISynchronizationHelper.getBypassExternalSync();  
        try {
            for(API_Synchronization_Transaction__c apiSyncTran : trig.newList)
            {                //                if((String.isBlank(apiSyncTran.Description__c) || (!apiSyncTran.Description__c.contains(Expocad3E_Wrapper.AUDIT_SYNC) && apiSyncTran.Description__c != Expocad3E_Wrapper.BOOTH_FINANCIAL_SCHEDULABLE)) && (apiSyncTran.Status__c == Expocad3E_Wrapper.QUEUED || apiSyncTran.Status__c == REQUEUE_FOR_ERRONEOUS_RECORDS || apiSyncTran.Status__c == Expocad3E_Wrapper.REQUEUE_ALL || apiSyncTran.Status__c == REQUEUE_FOR_SUCCESSFUL_RECORDS) && (apiSyncTran.X3rd_Party_Relationship__c == Expocad3E_Wrapper.EXPOCAD || (apiSyncTran.X3rd_Party_Relationship__c == Expocad3E_Wrapper.MYS && (apiSyncTran.Started_From__c == Expocad3E_Wrapper.OPPORTUNITY_CONTACT_ROLE || !isBypass))))
                if((apiSyncTran.Status__c == Expocad3E_Wrapper.QUEUED || apiSyncTran.Status__c == REQUEUE_FOR_ERRONEOUS_RECORDS || apiSyncTran.Status__c == Expocad3E_Wrapper.REQUEUE_ALL || apiSyncTran.Status__c == REQUEUE_FOR_SUCCESSFUL_RECORDS) && (apiSyncTran.X3rd_Party_Relationship__c == Expocad3E_Wrapper.EXPOCAD3E || apiSyncTran.X3rd_Party_Relationship__c == Expocad3E_Wrapper.EXPOCAD_EDGE))//((!isBypass))
                { 
                    if((trig.isAfter && trig.isUpdate) && (trig.oldMap.get(apiSyncTran.Id).Status__c != apiSyncTran.Status__c || trig.oldMap.get(apiSyncTran.Id).Request_Type__c != apiSyncTran.Request_Type__c) && (apiSyncTran.Request_Type__c == Expocad3E_Wrapper.ASYNCHRONOUS || apiSyncTran.Status__c != Expocad3E_Wrapper.QUEUED))
                    {
                        triggerOn = AFTER_UPDATE;
                        lstApiSyncTran.add(apiSyncTran);
                    }
                   
                }
                 /*if((trig.isAfter && trig.isUpdate) && (trig.oldMap.get(apiSyncTran.Id).Status__c != apiSyncTran.Status__c && apiSyncTran.Status__c == Expocad3E_Wrapper.COMPLETED))
                {
                    triggerOn = AFTER_UPDATE;
                    lstApiSyncTranBoothAll.add(apiSyncTran);
                }   */  
            }
          

            if(!lstApiSyncTran.isEmpty())
            {
                Set<Id> jobIds = new Set<Id>();
                for(API_Synchronization_Transaction__c tran: [SELECT JobId__c FROM API_Synchronization_Transaction__c WHERE Status__c =: Expocad3E_Wrapper.PROCESSING AND Request_Type__c =: Expocad3E_Wrapper.SYNCHRONOUS]){
                    jobIds.add(tran.JobId__c);
                }
                Map<Id,AsyncApexJob> synchronousBatches = new Map<Id,AsyncApexJob>([SELECT Id FROM AsyncApexJob WHERE Status IN : VALID_PROCESSING_STATUES AND Id IN:jobIds]);
                
                //Map<Id,String> mapRoleIdRoleName = APISynchronizationHelper.getRolesAndSubordinatesIds(); ???? To DO??
                //String currentUserRole = mapRoleIdRoleName.get(UserInfo.getUserRoleId());
                Boolean isExecuting = false;
                /*for(AsyncApexJob job : [SELECT Id,CreatedById,CreatedBy.UserRoleId FROM AsyncApexJob WHERE Status IN :VALID_PROCESSING_STATUES AND Id NOT IN:synchronousBatches.keySet() AND ApexClassId IN (SELECT Id FROM ApexClass WHERE Name = :API_SYNCHRONIZATION_BATCH )]){
                    if(currentUserRole == mapRoleIdRoleName.get(job.CreatedBy.UserRoleId) || (Expocad3E_Wrapper.ADMINROLES.contains(mapRoleIdRoleName.get(job.CreatedBy.UserRoleId)) && !Expocad3E_Wrapper.ADMINROLES.contains(currentUserRole))){
                        isExecuting = true;
                    }
                } */
                //Boolean isExecuting = (([SELECT COUNT() FROM AsyncApexJob WHERE Status IN :VALID_PROCESSING_STATUES AND Id NOT IN:synchronousBatches.keySet() AND ApexClassId IN (SELECT Id FROM ApexClass WHERE Name = :API_SYNCHRONIZATION_BATCH )]) == 0) ? false : true ;

                if(!isExecuting){
                    System.debug(logginglevel.DEBUG,'Schedule batch Time : '+Datetime.Now());
                    Database.executeBatch(new APISynchronizationBatch(),1);
                }
            }
        } 
        catch (Exception e){ HandleAllCustomException.LogException(e,'',triggerOn);
        }        
    }
}