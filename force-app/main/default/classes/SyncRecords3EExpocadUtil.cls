/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-18-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class SyncRecords3EExpocadUtil {

    public static final String NO_DATA = 'no Data';
    public static final String JOB_ABORTED = 'Job Aborted';
    public static String thirdPartyRelation = Expocad3E_Wrapper.EXPOCAD3E;
    public static final Set<String> COMPLETE_STATUES  = new Set<String> {'Completed','Error','Paused'};
    /**
    * @description : this method will fetch apex jobs and will update status,JobItemsProcessed,NumberOfErrors,TotalJobItems
    * @param batchId batch Id
    * @return AsyncApexJob
    **/
    @AuraEnabled
    public static AsyncApexJob getJobs(String batchId) {
        AsyncApexJob apexJobs; // Added Query in for loop for Sales Profile Access [SFV-880]
        Boolean isAccess = true;
        if(Schema.sObjectType.AsyncApexJob.isAccessible() || isAccess){
            List<AsyncApexJob> jobs = [SELECT TotalJobItems, Status, NumberOfErrors, ExtendedStatus, JobItemsProcessed, Id, JobType, ApexClassId, CreatedDate FROM AsyncApexJob WHERE Id=:batchId];
            apexJobs = (jobs.isEmpty()?null:jobs.get(0)); 
        }
        return apexJobs; 
    } 
    //[EX-21]
    @AuraEnabled
    public static Boolean getCompanyTypeList(Id eventEditionId){
        Event_Edition__c ed = [Select Id,Company_Type_Setup_Required__c from Event_Edition__c where Id = :eventEditionId];
        if(ed!=null)
            return ed.Company_Type_Setup_Required__c;
        return false;
    }

   

    
   
   /**
    * @description : TransactionDetails class
    */
   public class TransactionDetails{
       /**
        * @description : batch Id
        */
        @AuraEnabled
        public Id batchId {get;set;}

        /**
        * @description : trasaction Id
        */
        @AuraEnabled 
        public String trasactionId {get;set;} 

        /**
        * @description : interface Log Id
        */
        @AuraEnabled  
        public Id interfaceLogId {get;set;} 

        /**
        * @description : errorMessage
        */
        @AuraEnabled  
        public String errorMessage {get;set;} 
    } 

    /**
    * @description : to get API Synchronization Transaction detail
    * @param txnId API Synchronization Transaction Id
    * @return Transaction Details
    **/
    @AuraEnabled
    public static API_Synchronization_Transaction__c getTransactionDetail(String txnId){
        API_Synchronization_Transaction__c tranDetail = getTransactionSOQL(txnId);
        System.debug('tranDetail---'+tranDetail);
        boolean hasErrorOrQueued = false;
        for(API_Synchronization_Item__c item : tranDetail.API_Synchronization_Items__r){
            if(item.Status__c == Expocad3E_Wrapper.ERROR){hasErrorOrQueued = true;}
            if(item.Status__c == Expocad3E_Wrapper.QUEUED && tranDetail.X3rd_Party_Relationship__c == Expocad3E_Wrapper.EXPOCAD3E){hasErrorOrQueued = true;}
        }
        if((tranDetail.Status__c == APISynchronizationBatch.COMPLETED_WITH_ERRORS || tranDetail.Status__c == Expocad3E_Wrapper.PROCESSING) && !hasErrorOrQueued && Schema.sObjectType.API_Synchronization_Transaction__c.isUpdateable()){
            update new API_Synchronization_Transaction__c(Id=txnId,Status__c=Expocad3E_Wrapper.COMPLETED);
            tranDetail.Status__c = Expocad3E_Wrapper.COMPLETED; 
        }
        return tranDetail; 
    }

    /**
    * @description : to get API Synchronization Transaction detail
    * @param txnId API Synchronization Transaction Id
    * @return Transaction Details
    **/
    public static API_Synchronization_Transaction__c getTransactionSOQL(String txnId){
        API_Synchronization_Transaction__c tranDetail = new API_Synchronization_Transaction__c();
        try{
            if(!String.isBlank(txnId)){
                tranDetail = [SELECT Id, Status__c, Interface_Log__c, JobId__c,X3rd_Party_Relationship__c, 
                (SELECT Status__c FROM API_Synchronization_Items__r)
                FROM API_Synchronization_Transaction__c Where Id=:txnId WITH SECURITY_ENFORCED];//WITH SECURITY_ENFORCED
            }
        }
        catch(Exception ex){HandleAllCustomException.LogException(ex,'','');}
        return tranDetail;
    }

    /**
    * @description : to sync 
    * @param oppId opportunity Id
    * @param thirdParty thirdParty Name
    * @return TransactionDetails
    **/
    @AuraEnabled
    public static TransactionDetails syncExhibitorInvite(Id recId,Boolean exhibitorOnly){//, String thirdParty
        //List<Opportunity> oppList = [SELECT Id,AccountId,X3rd_Party_Relationship__c FROM Opportunity WHERE Id=:oppId WITH SECURITY_ENFORCED];
        TransactionDetails tranDetail = new TransactionDetails();
        
        List<Opportunity> oppList;
        List<Opportunity> filteredOppList = new List<Opportunity>();
        Map<String,Decimal> stageToProbabilityMap = new Map<String,Decimal>();
        List<Expo3E_Invite_Probabiltity__mdt> inviteProbabilityMetadata = [Select Probability__c,Stage__c From Expo3E_Invite_Probabiltity__mdt];
        if(inviteProbabilityMetadata != null && !inviteProbabilityMetadata.isEmpty()){
            for(Expo3E_Invite_Probabiltity__mdt recMeta : inviteProbabilityMetadata){
                stageToProbabilityMap.put(recMeta.Stage__c,recMeta.Probability__c); 
            }
        }
        if(Id.valueOf(recId).getSobjectType() == Opportunity.getSObjectType()){
             oppList = fetchOpportunity(recId); 
             if(oppList[0].X3E_Exhibitor_Invite_Status__c == 'Invited'){
                 throw new AuraHandledException(System.label.This_Opportunity_is_already_invited);
             }
             if(String.isNotBlank(oppList[0].EventEdition__c) && String.isNotBlank(oppList[0].EventEdition__r.Opportunity_Probability_During_3E_Invite__c)){
                 if(oppList[0].Probability < Integer.ValueOf(oppList[0].EventEdition__r.Opportunity_Probability_During_3E_Invite__c)){
                     throw new AuraHandledException(System.label.Opportunity_probability_is_less_the_mentioned_in_Edition);
                 }
             }/*else if(String.isNotBlank(oppList[0].EventEdition__c) && stageToProbabilityMap.containsKey(oppList[0].StageName) &&  oppList[0].Probability >= stageToProbabilityMap.get(oppList[0].StageName)){
                    filteredOppList.add(oppList[0]);
            }*/
        }else if(Id.valueOf(recId).getSobjectType() == Event_Edition__c.getSObjectType()){
            oppList = fetchAllOpportunity(recId); 
        }
        if(oppList != null && !oppList.isEmpty()){
            if(String.isBlank(oppList[0].EventEdition__c)){
                throw new AuraHandledException(System.label.Event_edition_is_not_available);
            }/*else if(!oppList[0].EventEdition__r.Auto_Invite_Exhibitor_in_3E__c){
                throw new AuraHandledException('Auto Invite is not true');
            }*/
        }
        for(Opportunity oppRec : oppList){
            if(oppRec.X3E_Exhibitor_Invite_Status__c != 'Invited'){
                if(String.isNotBlank(oppRec.EventEdition__r.Opportunity_Probability_During_3E_Invite__c)){
                    if(oppRec.Probability >= Integer.ValueOf(oppRec.EventEdition__r.Opportunity_Probability_During_3E_Invite__c)){
                        filteredOppList.add(oppRec);
                    }
                }else if(stageToProbabilityMap.containsKey(oppRec.StageName) &&  oppRec.Probability >= stageToProbabilityMap.get(oppRec.StageName)){
                    filteredOppList.add(oppRec);
                }
            }
        }
        if(filteredOppList.isEmpty()){
            throw new AuraHandledException(System.label.There_is_no_valid_opportunity_to_invite);
        }
        String errorMessage = validateInviteSync(oppList[0]);
        try{
        
        String aycnApiTrnsctnId;
        Set<Id> apiSyncTranSet = new Set<Id>();
        //TransactionDetails tranDetail = new TransactionDetails(); 
        Id batchId;
        System.debug('oppList--'+oppList);
        System.debug('errorMessage--'+errorMessage);
        tranDetail.errorMessage = errorMessage;
        
            aycnApiTrnsctnId = NO_DATA;
            if(!oppList.isEmpty())
            {
                aycnApiTrnsctnId = null;
                aycnApiTrnsctnId = Create3EApiSyncRecords.syncExhibitorInviteToExpocad3E(filteredOppList,'Synchronous');
               
            }
            if(aycnApiTrnsctnId != null && aycnApiTrnsctnId != NO_DATA) 
            {
                
                apiSyncTranSet.add(aycnApiTrnsctnId); 
                APISynchronizationBatch batch = new APISynchronizationBatch(apiSyncTranSet);
                batchId= database.executebatch(batch,1);
                API_Synchronization_Transaction__c apisyctransaction= new API_Synchronization_Transaction__c(Id=aycnApiTrnsctnId);
                apisyctransaction.JobId__c = batchId;
                if(Schema.sObjectType.API_Synchronization_Transaction__c.isUpdateable())
                {
                    update apisyctransaction;
                }
                tranDetail.batchId = batchId;
                tranDetail.trasactionId = aycnApiTrnsctnId;
                tranDetail.interfaceLogId = apisyctransaction.Interface_Log__c; 
            }
            tranDetail.trasactionId = aycnApiTrnsctnId;
            //tranDetail.errorMessage = errorMessage;
        }
        catch(Exception e){
            HandleAllCustomException.LogException(e,'','');
            throw new AuraHandledException(e.getMessage()+e.getLineNumber());
           }
        return tranDetail; 
    }


      /**
    * @description : to sync 
    * @param oppId opportunity Id
    * @param thirdParty thirdParty Name
    * @return TransactionDetails
    **/
    @AuraEnabled
    public static TransactionDetails getContractsFrom3E(Id oppId,Boolean exhibitorOnly){//, String thirdParty
        //List<Opportunity> oppList = [SELECT Id,AccountId,X3rd_Party_Relationship__c FROM Opportunity WHERE Id=:oppId WITH SECURITY_ENFORCED];
        List<Opportunity> oppList = fetchOpportunity(oppId);
        System.debug('oppListbbb3e32'+oppList);
        validateSync(oppList[0]);
        String aycnApiTrnsctnId;
        Set<Id> apiSyncTranSet = new Set<Id>();
        TransactionDetails tranDetail = new TransactionDetails();
        Id batchId;

        try{
            
            aycnApiTrnsctnId = NO_DATA;
            if(!oppList.isEmpty())
            {
                aycnApiTrnsctnId = null;
                aycnApiTrnsctnId = Create3EApiSyncRecords.getContractFromExpocad3E(oppList,'Synchronous');
               
            }
            
            
            if(aycnApiTrnsctnId != null && aycnApiTrnsctnId != NO_DATA)
            {
                
                apiSyncTranSet.add(aycnApiTrnsctnId);
                APISynchronizationBatch batch = new APISynchronizationBatch(apiSyncTranSet);
                batchId= database.executebatch(batch,1);
                API_Synchronization_Transaction__c apisyctransaction= new API_Synchronization_Transaction__c(Id=aycnApiTrnsctnId);
                apisyctransaction.JobId__c = batchId;
                if(Schema.sObjectType.API_Synchronization_Transaction__c.isUpdateable())
                {
                    update apisyctransaction;
                }
                tranDetail.batchId = batchId;
                tranDetail.trasactionId = aycnApiTrnsctnId;
                tranDetail.interfaceLogId = apisyctransaction.Interface_Log__c; 
            }
            tranDetail.trasactionId = aycnApiTrnsctnId;
        }
        catch(Exception e){HandleAllCustomException.LogException(e,'','');}
        return tranDetail; 
    }


      /**
    * @description : to sync 
    * @param oppId opportunity Id
    * @param thirdParty thirdParty Name
    * @return TransactionDetails
    **/
    @AuraEnabled
    public static TransactionDetails getCompanyListFrom3E(Id recId){//, String thirdParty
        //List<Opportunity> oppList = [SELECT Id,AccountId,X3rd_Party_Relationship__c FROM Opportunity WHERE Id=:oppId WITH SECURITY_ENFORCED];
        List<Event_Edition__c> eventList = [Select Id,X3E_API_ID__c,X3E_Status__c,X3rd_Party_Relationship__c  
                                      From Event_Edition__c Where Id = :recId];
        //validateSync(oppList[0]);
        String aycnApiTrnsctnId;
        Set<Id> apiSyncTranSet = new Set<Id>();
        TransactionDetails tranDetail = new TransactionDetails(); 
        Id batchId;

        try{
            
            aycnApiTrnsctnId = NO_DATA;
            if(!eventList.isEmpty())
            {
                aycnApiTrnsctnId = null;
                aycnApiTrnsctnId = Create3EApiSyncRecords.getCompanyTypeListFromExpocad3E(eventList,'Synchronous');
               
            }
            if(aycnApiTrnsctnId != null && aycnApiTrnsctnId != NO_DATA)
            {
                
                apiSyncTranSet.add(aycnApiTrnsctnId);
                APISynchronizationBatch batch = new APISynchronizationBatch(apiSyncTranSet);
                batchId= database.executebatch(batch,1);
                API_Synchronization_Transaction__c apisyctransaction= new API_Synchronization_Transaction__c(Id=aycnApiTrnsctnId);
                apisyctransaction.JobId__c = batchId;
                if(Schema.sObjectType.API_Synchronization_Transaction__c.isUpdateable())
                {
                    update apisyctransaction;
                }
                tranDetail.batchId = batchId;
                tranDetail.trasactionId = aycnApiTrnsctnId;
                tranDetail.interfaceLogId = apisyctransaction.Interface_Log__c; 
            }
            tranDetail.trasactionId = aycnApiTrnsctnId;
        }
        catch(Exception e){HandleAllCustomException.LogException(e,'','');}
        return tranDetail; 
    }


     /**
    * @description : to sync 
    * @param oppId opportunity Id
    * @param thirdParty thirdParty Name
    * @return TransactionDetails
    **/
   @AuraEnabled
    public static TransactionDetails getBoothDetailsFromExpocad(Id oppId){//, String thirdParty
        //List<Opportunity> oppList = [SELECT Id,AccountId,X3rd_Party_Relationship__c FROM Opportunity WHERE Id=:oppId WITH SECURITY_ENFORCED];
        List<Opportunity> oppList = fetchOpportunity(oppId);
        System.debug('oppListbbb3e32'+oppList);
        validateSync(oppList[0]);////???? relation ship 3rd party???
        String aycnApiTrnsctnId;
        Set<Id> apiSyncTranSet = new Set<Id>();
        TransactionDetails tranDetail = new TransactionDetails();
        Id batchId;

        try{
            
            aycnApiTrnsctnId = NO_DATA;
            if(!oppList.isEmpty())
            {
                aycnApiTrnsctnId = null;
                aycnApiTrnsctnId = Create3EApiSyncRecords.getBoothFromExpocad(oppList,'Synchronous');
               
            }
            
            
            if(aycnApiTrnsctnId != null && aycnApiTrnsctnId != NO_DATA)
            {
                
                apiSyncTranSet.add(aycnApiTrnsctnId);
                APISynchronizationBatch batch = new APISynchronizationBatch(apiSyncTranSet);
                batchId= database.executebatch(batch,1);
                API_Synchronization_Transaction__c apisyctransaction= new API_Synchronization_Transaction__c(Id=aycnApiTrnsctnId);
                apisyctransaction.JobId__c = batchId;
                if(Schema.sObjectType.API_Synchronization_Transaction__c.isUpdateable())
                {
                    update apisyctransaction;
                }
                tranDetail.batchId = batchId;
                tranDetail.trasactionId = aycnApiTrnsctnId;
                tranDetail.interfaceLogId = apisyctransaction.Interface_Log__c; 
            }
            tranDetail.trasactionId = aycnApiTrnsctnId;
        }
        catch(Exception e){HandleAllCustomException.LogException(e,'','');}
        return tranDetail; 
    }


  

    public static List<Opportunity> fetchOpportunity(Id OppId){
        return  [Select Id,AccountId,EventEdition__c,EventEdition__r.X3E_API_ID__c,StageName,Probability,EventEdition__r.Opportunity_Probability_During_3E_Invite__c,X3E_Exhibitor_Invite_Status__c,EventEdition__r.Auto_Invite_Exhibitor_in_3E__c,EventEdition__r.X3E_Status__c,EventEdition__r.X3rd_Party_Relationship__c  FROM Opportunity Where Id = :OppId WITH SECURITY_ENFORCED];
    }

    public static List<Opportunity> fetchAllOpportunity(Id eventId){
        return  [Select Id,AccountId,EventEdition__c,EventEdition__r.X3E_API_ID__c,StageName,Probability,EventEdition__r.Opportunity_Probability_During_3E_Invite__c,X3E_Exhibitor_Invite_Status__c,EventEdition__r.Auto_Invite_Exhibitor_in_3E__c,EventEdition__r.X3E_Status__c,EventEdition__r.X3rd_Party_Relationship__c  FROM Opportunity Where EventEdition__c = :eventId WITH SECURITY_ENFORCED];
    }

    public static void validateSync(Opportunity opp){
        if(String.isBlank(opp.EventEdition__c)){
            throw new AuraHandledException(System.Label.Event_Edition_Name_Is_Empty);
        }else if(String.isBlank(opp.EventEdition__r.X3E_API_ID__c)){
            throw new AuraHandledException(System.Label.Event_Edition_3E_Api_Id_Is_empty);
        }else if(String.isBlank(opp.EventEdition__r.X3E_Status__c) || opp.EventEdition__r.X3E_Status__c != 'Active'){
            throw new AuraHandledException(System.Label.Event_Edition_status_is_not_Active);
        }else if(opp.EventEdition__r.X3rd_Party_Relationship__c != Expocad3E_Wrapper.EXPOCAD3E){
            throw new AuraHandledException(System.Label.X3rd_Party_relationship_is_not_3E_ExpoCAD);
        }
    }


     public static String validateInviteSync(Opportunity opp){
        if(String.isNotBlank(opp.EventEdition__c) && !opp.EventEdition__r.Auto_Invite_Exhibitor_in_3E__c){
            throw new AuraHandledException(System.Label.X3E_setup_is_not_active_for_this_edition_Please_contact_your_system_admin);
        }else if(String.isBlank(opp.EventEdition__c) || String.isBlank(opp.EventEdition__r.X3E_API_ID__c)
            || String.isBlank(opp.EventEdition__r.X3E_Status__c) || opp.EventEdition__r.X3E_Status__c != 'Active'
            || opp.EventEdition__r.X3rd_Party_Relationship__c != Expocad3E_Wrapper.EXPOCAD3E){
                return System.Label.X3E_setup_is_not_active_for_this_edition_Please_contact_your_system_admin;
        }
        return '';
    }

    @AuraEnabled
    public static string getOpportunitiesprobability(Id eventId){
        try {
            System.debug(eventId);
            String oppProbability ;
            if(Id.valueOf(eventId).getSobjectType() == Opportunity.getSObjectType()){
                Opportunity opp = [SELECT Id,EventEdition__r.Opportunity_Probability_During_3E_Invite__c FROM Opportunity WHERE id =:eventId WITH SECURITY_ENFORCED];
                oppProbability = String.valueOf(opp.EventEdition__r.Opportunity_Probability_During_3E_Invite__c);
            }else if(Id.valueOf(eventId).getSobjectType() == Event_Edition__c.getSObjectType()){
                Event_Edition__c eventEdition = [SELECT Id,Opportunity_Probability_During_3E_Invite__c FROM Event_Edition__c WHERE id =:eventId WITH SECURITY_ENFORCED];
                oppProbability = (String)eventEdition.Opportunity_Probability_During_3E_Invite__c;
            }
            if(oppProbability == null){
                oppProbability = '';
            }
            return oppProbability;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
   
}