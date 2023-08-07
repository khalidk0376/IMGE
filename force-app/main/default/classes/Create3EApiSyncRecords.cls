/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @testClass         : Create3EApiSyncRecords_Test
 * @last modified on  : 10-14-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * ***************************************************************************************
 * Last Modified By:
 * Abhishek Sharma on 22Feb2023 - EX-154 [Created methods 'syncBooth','insertAPISyncItemsBoothSync', updated method 'insertAllAPISyncItem'] 
**/

public with sharing class Create3EApiSyncRecords {

    public static List<String> statuses = new List<String>{'Queued','Paused','Processing','Re-Queued'};

    public static List<String> apiTransStatus = new List<String>{'Processing','Queued','Paused'};

    public class ApiSyncRecordsWrapper{

        Set<String> exitingExhibitorIds = new Set<String>(); 

        Map<Id,ExpocadBooth__c> newExpoBoothMap = new Map<Id,ExpocadBooth__c>();

        Map<Id,opportunity> newOpportunityMap = new Map<Id,opportunity>();

         Map<Id,Event_Edition__c> editionToApiItemStatus = new Map<Id,Event_Edition__c>();

        Map<Id,opportunity> newConToOpportunityMap = new Map<Id,opportunity>();

        Boolean exhibitorOnly;

        Boolean isAssign;

        Map<Id,Boolean> oppToApiItemStatus = new Map<Id,Boolean>();
        /**
        * @description For OpportunityId
        */
        Public List<opportunity> validExhibitorsList;
        /**
        * @description For checking the record is for update
        */
        public Boolean isUpdate;
        /**
        * @description For checking the record is for Insert
        */
        public Boolean isInsert;        
        /**
        * @description For checking the if the Booth is to be Replaced 
        */
        public Boolean isReplaceBooth;
        /**
        * @description For Checking where this trigger is started from
        */
        public String startedFrom;
     
        /**
        * @description For checking whether the record is created for direct sync or can take some time.
        */
        public String requestType;
        /**
        * @description For checking the transaction status
        */
        public String transactionStatus;
        /**
        * @description For checking the transaction status
        */
        public String apiCallName;
      
        /**
        * @description For third Party Relation Name.
        */
        public String thirdPartyRelation= '3E ExpoCAD';
        
        /**
        * @description For Display Name of Expocad Booth.
        */
        public String displayName;
    }





    public static Id insertAllAPISyncItem(ApiSyncRecordsWrapper apiSyncWrap)
    {
        List<API_Synchronization_Transaction__c> lstApiSyncTran = new List<API_Synchronization_Transaction__c>();
        List<API_Synchronization_Item__c> listApiSyncItem = new List<API_Synchronization_Item__c>();
        Id syncTranId;
        String triggerOn;
        Boolean checkAllStatus = false;
        try{
            if(apiSyncWrap.apiCallName ==  'ExhibitorInvite'){
                system.debug('2');
                for(String recId : apiSyncWrap.oppToApiItemStatus.keySet()){
                    checkAllStatus = apiSyncWrap.oppToApiItemStatus.get(recId); 
                }
                if(!apiSyncWrap.newOpportunityMap.isEmpty()){
                    system.debug('3');
                    listApiSyncItem = insertAPISyncItemsForExhibitors(apiSyncWrap.newOpportunityMap,apiSyncWrap.oppToApiItemStatus,apiSyncWrap.exitingExhibitorIds);
                }
                
            }else if(apiSyncWrap.apiCallName == 'GetContract'){
                checkAllStatus = true;
                listApiSyncItem = insertAPISyncItemsForContracts(apiSyncWrap.newOpportunityMap);
            }else if(apiSyncWrap.apiCallName == 'GetCompanyList'){
                checkAllStatus = true;
                listApiSyncItem = insertAPISyncItemsForCompanyList(apiSyncWrap.editionToApiItemStatus);
            }else if(apiSyncWrap.apiCallName == 'ExpoBooth'){
                checkAllStatus = true;
                listApiSyncItem = insertExpoBoothForHoldUnhold(apiSyncWrap.newExpoBoothMap,apiSyncWrap.isAssign);
            }
            else if(apiSyncWrap.apiCallName == 'GetAllBooth'){
                checkAllStatus = true;
                listApiSyncItem = insertAPISyncItemsForBoothDetails(apiSyncWrap.newOpportunityMap);
                if(!apiSyncWrap.newExpoBoothMap.isEmpty()){
                    listApiSyncItem.addAll(insertAPISyncItemsForBoothFinancials(apiSyncWrap.newExpoBoothMap,true));
                    listApiSyncItem.addAll(insertAPISyncItemsForBoothReqItems(apiSyncWrap.newExpoBoothMap,true));
                    listApiSyncItem.addAll(insertAPISyncItemsContracts(apiSyncWrap.newExpoBoothMap,true));
                    listApiSyncItem.addAll(insertAPISyncItemsQuoteCalculate(apiSyncWrap.newExpoBoothMap,true));
                    listApiSyncItem.addAll(insertAPISyncItemsOppUpdate(apiSyncWrap.newExpoBoothMap,true));
                }
            }else if(apiSyncWrap.apiCallName == 'GetNewBooth'){
                if(!apiSyncWrap.newExpoBoothMap.isEmpty()){
                    listApiSyncItem.addAll(insertAPISyncItemsForBoothFinancials(apiSyncWrap.newExpoBoothMap,false));
                    listApiSyncItem.addAll(insertAPISyncItemsForBoothReqItems(apiSyncWrap.newExpoBoothMap,false));
                    listApiSyncItem.addAll(insertAPISyncItemsContracts(apiSyncWrap.newExpoBoothMap,false)); 
                    listApiSyncItem.addAll(insertAPISyncItemsQuoteCalculate(apiSyncWrap.newExpoBoothMap,false));
                    listApiSyncItem.addAll(insertAPISyncItemsOppUpdate(apiSyncWrap.newExpoBoothMap,false));
                }
               
            }
            //Modified by Abhishek Sharma on 21/02/2023 : EX-154
            else if(apiSyncWrap.apiCallName == Expocad3E_Wrapper.EXPOCAD_BOOTH_UNHOLD || 
                    apiSyncWrap.apiCallName == Expocad3E_Wrapper.EXPOCAD_BOOTH_UNRENT ||
                    apiSyncWrap.apiCallName == Expocad3E_Wrapper.EXPOCAD_BOOTH_RENT ||
                    apiSyncWrap.apiCallName == Expocad3E_Wrapper.EXPOCAD_BOOTH_RENTTOHOLD){
                        checkAllStatus = true;
                        if(!apiSyncWrap.newExpoBoothMap.isEmpty()){
                            listApiSyncItem.addAll(insertAPISyncItemsBoothSync(apiSyncWrap.newExpoBoothMap, apiSyncWrap.apiCallName, true, apiSyncWrap.isReplaceBooth, apiSyncWrap.displayName)); 
                        }
            }//------------------------------------------------------------------------------------
            API_Synchronization_Transaction__c apiSyncTran = new API_Synchronization_Transaction__c();  
            apiSyncWrap.transactionStatus = (checkAllStatus == true) ? 'Queued' : 'Paused';
            apiSyncTran.Status__c = 'Paused';

            apiSyncTran.X3rd_Party_Relationship__c = apiSyncWrap.thirdPartyRelation;
            apiSyncTran.Started_From__c = apiSyncWrap.startedFrom;
            apiSyncTran.Request_Type__c = apiSyncWrap.requestType == 'Synchronous' ? 'Synchronous' : 'Asynchronous';
            if(apiSyncWrap.apiCallName ==  'ExhibitorInvite' && apiSyncWrap.transactionStatus == 'Paused'){
                apiSyncTran.Request_Type__c = 'Asynchronous';
            }
            lstApiSyncTran.add(apiSyncTran);

           syncTranId =  insertAllRecords(lstApiSyncTran, listApiSyncItem, apiSyncWrap);            
        }
        catch(Exception e) 
        {
            triggerOn = apiSyncWrap.isUpdate == false ? 'After Insert' : 'After Update';
            HandleAllCustomException.LogException(e,'',triggerOn);
        }
        return syncTranId;
    }

    public static Id insertAllRecords(List<API_Synchronization_Transaction__c> lstApiSyncTran, List<API_Synchronization_Item__c> lstApiSyncItem, ApiSyncRecordsWrapper apiSyncWrap)
    {
        Id apiSyncTranId;
        if(!lstApiSyncTran.isEmpty() && !lstApiSyncItem.isEmpty())
        {
            if(Schema.sObjectType.API_Synchronization_Transaction__c.isCreateable())
            {
                insert lstApiSyncTran;
            }
            apiSyncTranId = lstApiSyncTran[0].Id;
            
            for(API_Synchronization_Item__c apiSyncItm : lstApiSyncItem)
            {
                apiSyncItm.API_Synchronization_Transaction__c = lstApiSyncTran[0].Id;
            }

            if(Schema.sObjectType.API_Synchronization_Item__c.isCreateable())
            {
                insert lstApiSyncItem;
            }

            if(Schema.sObjectType.API_Synchronization_Transaction__c.isUpdateable())
            {
                lstApiSyncTran[0].Status__c = apiSyncWrap.transactionStatus;
                update lstApiSyncTran;
            }
        }
        return apiSyncTranId;
    }

     public static Id syncExhibitorInviteToExpocad3E(List<opportunity> opportunityList,String requestType){
        Id asynctransId;
        try{
        Boolean isUpdate = false;
        Map<Id,opportunity> newOppMap = new Map<Id,opportunity>();
        Map<Id,Boolean> newOppToItemStatus = new Map<Id,Boolean>();
        List<opportunity> validExhibitorsList = new List<opportunity>();
        List<OpportunityContactRole> oppContactRoleList = New List<OpportunityContactRole>();
            for(opportunity rec : [Select Id,AccountId,EventEdition__c,EventEdition__r.X3E_API_ID__c,EventEdition__r.X3E_Status__c,EventEdition__r.X3rd_Party_Relationship__c  
                                      From opportunity Where Id IN :opportunityList and EventEdition__r.Auto_Invite_Exhibitor_in_3E__c = true WITH SECURITY_ENFORCED]){
                newOppMap.put(rec.Id,rec);
                if(String.isNotBlank(rec.EventEdition__r.X3E_API_ID__c) && rec.EventEdition__r.X3E_Status__c == Expocad3E_Wrapper.ACTIVE && rec.EventEdition__r.X3rd_Party_Relationship__c == Expocad3E_Wrapper.EXPOCAD3E){
                    newOppToItemStatus.put(rec.Id,true);
                }else{
                    newOppToItemStatus.put(rec.Id,false);
                }
              
            }
            system.debug('12');
           Set<String> typeStatus = new Set<String>{Expocad3E_Wrapper.EXPOCAD3E_EXHIBITOR_INVITE};
            Set<String> exitingExhibitorIds = new Set<String>();
            for(API_Synchronization_Item__c item : [Select Id,Account__c,Opportunity__c from API_Synchronization_Item__c where Status__c IN:statuses and type__c IN :typeStatus and API_Synchronization_Transaction__r.Status__c IN :apiTransStatus  and Opportunity__c IN :newOppMap.keySet() WITH SECURITY_ENFORCED])// and Account__c = :accountIdSet
            {
                exitingExhibitorIds.add(item.Opportunity__c);
            }
           
            ApiSyncRecordsWrapper apiSyncInsertWrap = new ApiSyncRecordsWrapper();
            apiSyncInsertWrap.exitingExhibitorIds = exitingExhibitorIds;
            apiSyncInsertWrap.oppToApiItemStatus = newOppToItemStatus;
            apiSyncInsertWrap.newOpportunityMap = newOppMap;
            apiSyncInsertWrap.startedFrom = 'Opportunity';
            apiSyncInsertWrap.apiCallName = 'ExhibitorInvite';
            apiSyncInsertWrap.requestType = requestType == 'Synchronous' ? 'Synchronous' : 'Asynchronous';
            asynctransId = insertAllAPISyncItem(apiSyncInsertWrap);
        } catch (Exception e) 
        {
            system.System.debug('---error--'+String.valueof(e.getLineNumber()));
            system.System.debug('---error--'+String.valueof(e.getMessage()));
            HandleAllCustomException.LogException(e,'','After Insert');
           
        }
         return asynctransId;
     }

     public static Id getContractFromExpocad3E(List<opportunity> opportunityList,String requestType){
        Id asynctransId;
        try{
            Boolean isUpdate = false;
            Map<Id,opportunity> newOppMap = new Map<Id,opportunity>();
            Map<Id,Boolean> newOppToItemStatus = new Map<Id,Boolean>(); 
            for(opportunity rec : [Select Id,AccountId,EventEdition__c,EventEdition__r.X3E_API_ID__c,EventEdition__r.X3E_Status__c,EventEdition__r.X3rd_Party_Relationship__c,
                                    (SELECT Id,Name,Booth_Number__c FROM ExpocadBooths__r)   
                                    From opportunity Where Id IN :opportunityList WITH SECURITY_ENFORCED]){
                newOppMap.put(rec.Id,rec);
              
            }
           
            ApiSyncRecordsWrapper apiSyncInsertWrap = new ApiSyncRecordsWrapper();
            apiSyncInsertWrap.newOpportunityMap = newOppMap;
            apiSyncInsertWrap.startedFrom = 'Opportunity';
            apiSyncInsertWrap.apiCallName = 'GetContract';
            apiSyncInsertWrap.requestType = requestType == 'Synchronous' ? 'Synchronous' : 'Asynchronous';
            asynctransId = insertAllAPISyncItem(apiSyncInsertWrap);
        } catch (Exception e) 
        {
            system.System.debug('---error--'+String.valueof(e.getLineNumber()));
            system.System.debug('---error--'+String.valueof(e.getMessage()));
            HandleAllCustomException.LogException(e,'','After Insert');
           
        }
         return asynctransId;
     }

     public static Id getCompanyTypeListFromExpocad3E(List<Event_Edition__c> editionList,String requestType){
        Id asynctransId;
        try{
            Boolean isUpdate = false;
            Map<Id,Event_Edition__c> newEditionMap = new Map<Id,Event_Edition__c>();
            Map<Id,Boolean> newEditionToItemStatus = new Map<Id,Boolean>();
            for(Event_Edition__c rec : [Select Id,X3E_API_ID__c,X3E_Status__c,X3rd_Party_Relationship__c  
                                      From Event_Edition__c Where Id IN :editionList ]){
                newEditionMap.put(rec.Id,rec);
                if(String.isNotBlank(rec.X3E_API_ID__c) && rec.X3E_Status__c == Expocad3E_Wrapper.ACTIVE && rec.X3rd_Party_Relationship__c == Expocad3E_Wrapper.EXPOCAD3E){
                    newEditionToItemStatus.put(rec.Id,true);
                }else{
                    newEditionToItemStatus.put(rec.Id,false);
                }
              
            }

            ApiSyncRecordsWrapper apiSyncInsertWrap = new ApiSyncRecordsWrapper();
            apiSyncInsertWrap.editionToApiItemStatus = newEditionMap;
            apiSyncInsertWrap.startedFrom = 'Event Edition';
            apiSyncInsertWrap.apiCallName = 'GetCompanyList';
            apiSyncInsertWrap.requestType = requestType == 'Synchronous' ? 'Synchronous' : 'Asynchronous';
            asynctransId = insertAllAPISyncItem(apiSyncInsertWrap);
        } catch (Exception e) 
        {
            system.System.debug('---error--'+String.valueof(e.getLineNumber()));
            system.System.debug('---error--'+String.valueof(e.getMessage()));
            HandleAllCustomException.LogException(e,'','After Insert');
           
        }
         return asynctransId;
     }


  

     /**
    * @description  Creation of All API Sync items if triggered from Opportunity .
    * @param  newOpportunityMap
    * @param  newOppToItemStatus
    * @param exitingExhibitorIds
    * @return  lstApiSyncItem
    * Added for [FC-1701]
    */                                      
    public static List<API_Synchronization_Item__c> insertAPISyncItemsForExhibitors(Map<Id,opportunity> newOpportunityMap, Map<Id,Boolean> newOppToItemStatus,Set<String> exitingExhibitorIds){
        List<API_Synchronization_Item__c> newItemList = new List<API_Synchronization_Item__c>();
        System.debug('exitingExhibitorIdsinvite--'+exitingExhibitorIds);
        for(String recId :newOpportunityMap.keySet()){
            opportunity rec = newOpportunityMap.get(recId);
            if(!exitingExhibitorIds.contains(recId)){
                API_Synchronization_Item__c apiSyncItemforExhibitors = new API_Synchronization_Item__c();
                apiSyncItemforExhibitors.Status__c =  (newOppToItemStatus.containsKey(recId) && newOppToItemStatus.get(recId)) ? 'Queued' : 'Paused';
                apiSyncItemforExhibitors.API_Call_Type__c = 'POST';
                apiSyncItemforExhibitors.Opportunity__c = rec.Id;
                apiSyncItemforExhibitors.X3rd_Party_Relationship__c = Expocad3E_Wrapper.EXPOCAD3E;
                apiSyncItemforExhibitors.Type__c = Expocad3E_Wrapper.EXPOCAD3E_EXHIBITOR_INVITE;
                newItemList.add(apiSyncItemforExhibitors);
            }
                
        }
        return newItemList;
    }

     /**
    * @description  Creation of All API Sync items if triggered from Opportunity .
    * @param  newOpportunityMap
    * @return  lstApiSyncItem
    * Added for [FC-1701]
    */                                      
    public static List<API_Synchronization_Item__c> insertAPISyncItemsForContracts(Map<Id,opportunity> newOpportunityMap){
        List<API_Synchronization_Item__c> newItemList = new List<API_Synchronization_Item__c>();
        for(String recId :newOpportunityMap.keySet()){
            opportunity rec = newOpportunityMap.get(recId);
            if(rec.ExpocadBooths__r != null && !rec.ExpocadBooths__r.isEmpty()){
                for(ExpocadBooth__c booth : rec.ExpocadBooths__r){
                    API_Synchronization_Item__c apiSyncItemforExhibitors = new API_Synchronization_Item__c();
                    apiSyncItemforExhibitors.Status__c = 'Queued';
                    apiSyncItemforExhibitors.API_Call_Type__c = 'GET';
                    apiSyncItemforExhibitors.Opportunity__c = rec.Id;
                    apiSyncItemforExhibitors.ExpocadBooth__c = booth.Id;
                    apiSyncItemforExhibitors.X3rd_Party_Relationship__c = Expocad3E_Wrapper.EXPOCAD3E;
                    apiSyncItemforExhibitors.Type__c = Expocad3E_Wrapper.EXPOCAD3E_CONTRACT_PULL;
                    newItemList.add(apiSyncItemforExhibitors);
                }
            }
        }
        return newItemList;
    }

    public static Id processCompanyTypeAssignToExpocad3E(List<ExpocadBooth__c> expoBoothList,String requestType){
        Id asynctransId;
        try{
            Boolean isAssign = false;
            Map<Id,ExpocadBooth__c> newExpoBoothMap = new Map<Id,ExpocadBooth__c>();
            for(ExpocadBooth__c rec : [Select Id,Booth_Number__c,Status__c,Name,ShowInShow__c,Company_Type__c,Opportunity__c,Opportunity__r.EventEdition__c,Opportunity__r.EventEdition__r.X3E_API_ID__c,Opportunity__r.EventEdition__r.X3E_Status__c,Opportunity__r.EventEdition__r.X3rd_Party_Relationship__c 
                                       From ExpocadBooth__c Where Id IN :expoBoothList and ShowInShow__c != null WITH SECURITY_ENFORCED]){
                                           newExpoBoothMap.put(rec.Id,rec);
                                           if(rec.Status__c == 'On Hold' || rec.Status__c == 'Added To Quote/On Hold'){
                                               isAssign = true;
                                           }else if(rec.Status__c == 'Released'){
                                               isAssign = false;
                                           }
                                           
                                       }
            
            ApiSyncRecordsWrapper apiSyncInsertWrap = new ApiSyncRecordsWrapper();
            apiSyncInsertWrap.newExpoBoothMap = newExpoBoothMap;
            apiSyncInsertWrap.startedFrom = 'Expocad Booth';
            apiSyncInsertWrap.isAssign = isAssign;
            apiSyncInsertWrap.apiCallName = 'ExpoBooth';
            apiSyncInsertWrap.requestType = requestType == 'Synchronous' ? 'Synchronous' : 'Asynchronous';
            asynctransId = insertAllAPISyncItem(apiSyncInsertWrap);
        } catch (Exception e) 
        {
            system.System.debug('---error--'+String.valueof(e.getLineNumber()));
            system.System.debug('---error--'+String.valueof(e.getMessage()));
             HandleAllCustomException.LogException(e,'','After Insert');
           
        }
         return asynctransId;
     }



    /**
    * @description  Creation of All API Sync items if triggered from EventEdition .
    * @param  newEditionMap
    * @return  lstApiSyncItem
    * Added for [EX-21]
    */                                      
    public static List<API_Synchronization_Item__c> insertAPISyncItemsForCompanyList(Map<Id,Event_Edition__c> newEditionMap){
        List<API_Synchronization_Item__c> newItemList = new List<API_Synchronization_Item__c>();
        for(String recId :newEditionMap.keySet()){
            Event_Edition__c rec = newEditionMap.get(recId);
            API_Synchronization_Item__c apiSyncItemforExhibitors = new API_Synchronization_Item__c();
            apiSyncItemforExhibitors.Status__c = 'Queued';
            apiSyncItemforExhibitors.API_Call_Type__c = 'GET';
            apiSyncItemforExhibitors.Event_Edition__c = rec.Id;
            apiSyncItemforExhibitors.X3rd_Party_Relationship__c = Expocad3E_Wrapper.EXPOCAD3E;
            apiSyncItemforExhibitors.Type__c = Expocad3E_Wrapper.EXPOCAD3E_COMPANY_TYPE;
            newItemList.add(apiSyncItemforExhibitors);
        }
        return newItemList;
    }

     /**
    * @description  Creation of All API Sync items if triggered from Expo Booth .
    * @param  newExpoBoothMap
    * @return  lstApiSyncItem
    * Added for [EX-21]
    */                                      
    public static List<API_Synchronization_Item__c> insertExpoBoothForHoldUnhold(Map<Id,ExpocadBooth__c> newExpoBoothMap,Boolean isAssign){
        List<API_Synchronization_Item__c> newItemList = new List<API_Synchronization_Item__c>();
        for(String recId :newExpoBoothMap.keySet()){
            ExpocadBooth__c rec = newExpoBoothMap.get(recId);
            API_Synchronization_Item__c apiSyncItemforExhibitors = new API_Synchronization_Item__c();
            apiSyncItemforExhibitors.Status__c = 'Queued';
            apiSyncItemforExhibitors.API_Call_Type__c = 'POST';
            apiSyncItemforExhibitors.ExpocadBooth__c = rec.Id;
            apiSyncItemforExhibitors.X3rd_Party_Relationship__c = Expocad3E_Wrapper.EXPOCAD3E;
            apiSyncItemforExhibitors.Type__c =  isAssign ? Expocad3E_Wrapper.EXPOCAD3E_COMPANY_TYPE_ASSIGN : Expocad3E_Wrapper.EXPOCAD3E_COMPANY_TYPE_UNASSIGN;
            newItemList.add(apiSyncItemforExhibitors);
        }
        return newItemList;
    }


    /*----------------------------------------------------------------------------------------*/


    public static Id getBoothFromExpocad(List<opportunity> opportunityList,String requestType){
        Id asynctransId;
        try{
            Boolean isUpdate = false;
            Map<Id,opportunity> newOppMap = new Map<Id,opportunity>();
            Map<Id,Boolean> newOppToItemStatus = new Map<Id,Boolean>(); 
            Map<Id,ExpocadBooth__c> newExpoBoothMap1 = new Map<Id,ExpocadBooth__c>();
            for(opportunity rec : [Select Id,AccountId,EventEdition__c,EventEdition__r.X3E_API_ID__c,EventEdition__r.X3E_Status__c,EventEdition__r.X3rd_Party_Relationship__c,
                                    (SELECT Id,Name,Booth_Number__c,opportunity__c FROM ExpocadBooths__r where status__c = 'Rented')   
                                    From opportunity Where Id IN :opportunityList WITH SECURITY_ENFORCED]){//and EventEdition__r.Auto_Invite_Exhibitor_in_3E__c = true
                newOppMap.put(rec.Id,rec);
                if(rec.ExpocadBooths__r != null && !rec.ExpocadBooths__r.isEmpty()){
                    for(ExpocadBooth__c booth : rec.ExpocadBooths__r){
                        newExpoBoothMap1.put(booth.Id,booth);
                    }
                }
              
            }
            system.debug('12');
           system.debug(newOppMap);
            ApiSyncRecordsWrapper apiSyncInsertWrap = new ApiSyncRecordsWrapper();
            apiSyncInsertWrap.newOpportunityMap = newOppMap;
            apiSyncInsertWrap.startedFrom = 'Opportunity';
            apiSyncInsertWrap.newExpoBoothMap = newExpoBoothMap1;
            apiSyncInsertWrap.apiCallName = 'GetAllBooth';
            apiSyncInsertWrap.requestType = requestType == 'Synchronous' ? 'Synchronous' : 'Asynchronous';
            asynctransId = insertAllAPISyncItem(apiSyncInsertWrap);
        } catch (Exception e) 
        {
            HandleAllCustomException.LogException(e,'','After Insert');
           
        }
         return asynctransId;
     }


     public static Id getBoothFinancialsExpocad(List<ExpocadBooth__c> boothList,String requestType){
        Id asynctransId;
        try{
        Boolean isUpdate = false;
        Map<Id,ExpocadBooth__c> newExpoBoothMap1 = new Map<Id,ExpocadBooth__c>();
            for(ExpocadBooth__c rec : boothList){
                newExpoBoothMap1.put(rec.Id,rec);
              
            }
            ApiSyncRecordsWrapper apiSyncInsertWrap = new ApiSyncRecordsWrapper();
            apiSyncInsertWrap.startedFrom = 'Opportunity';
            apiSyncInsertWrap.newExpoBoothMap = newExpoBoothMap1;
            apiSyncInsertWrap.apiCallName = 'GetNewBooth';
            apiSyncInsertWrap.requestType = requestType == 'Synchronous' ? 'Synchronous' : 'Asynchronous';
            asynctransId = insertAllAPISyncItem(apiSyncInsertWrap);
        } catch (Exception e) 
        {
            system.System.debug('---error--'+String.valueof(e.getLineNumber()));
            system.System.debug('---error--'+String.valueof(e.getMessage()));
            HandleAllCustomException.LogException(e,'','After Insert'); 
           
        }
         return asynctransId;
     }


      /**
    * @description  Creation of All API Sync items if triggered from Opportunity .
    * @param  newOpportunityMap
    * @return  lstApiSyncItem
    * Added for [FC-1701]
    */                                      
    public static List<API_Synchronization_Item__c> insertAPISyncItemsForBoothDetails(Map<Id,opportunity> newOpportunityMap){
        List<API_Synchronization_Item__c> newItemList = new List<API_Synchronization_Item__c>();
        for(String recId :newOpportunityMap.keySet()){
            opportunity rec = newOpportunityMap.get(recId);
            API_Synchronization_Item__c apiSyncItemforExhibitors = new API_Synchronization_Item__c();
            apiSyncItemforExhibitors.Status__c = 'Queued';
            apiSyncItemforExhibitors.API_Call_Type__c = 'GET';
            apiSyncItemforExhibitors.Opportunity__c = rec.Id;
            apiSyncItemforExhibitors.X3rd_Party_Relationship__c = Expocad3E_Wrapper.EXPOCAD3E;
            apiSyncItemforExhibitors.Type__c = Expocad3E_Wrapper.EXPOCAD3E_BOOTH_DETAILS;
            newItemList.add(apiSyncItemforExhibitors);
        }
        return newItemList;
    }
       /**
    * @description  Creation of All API Sync items if triggered from Opportunity .
    * @param  newOpportunityMap
    * @return  lstApiSyncItem
    * Added for [FC-1701]
    */                                      
    public static List<API_Synchronization_Item__c> insertAPISyncItemsForBoothFinancials(Map<Id,ExpocadBooth__c> newExpoBoothMap,Boolean checkStatus){
        List<API_Synchronization_Item__c> newItemList = new List<API_Synchronization_Item__c>();
        for(String recId :newExpoBoothMap.keySet()){
            ExpocadBooth__c rec = newExpoBoothMap.get(recId);
            API_Synchronization_Item__c apiSyncItemforExhibitors = new API_Synchronization_Item__c();
            apiSyncItemforExhibitors.Status__c = checkStatus ? 'Queued' : 'Paused';
            apiSyncItemforExhibitors.API_Call_Type__c = 'GET';
            apiSyncItemforExhibitors.Opportunity__c = rec.opportunity__c;
            apiSyncItemforExhibitors.ExpocadBooth__c = rec.Id;
            apiSyncItemforExhibitors.X3rd_Party_Relationship__c = Expocad3E_Wrapper.EXPOCAD3E;
            apiSyncItemforExhibitors.Type__c = Expocad3E_Wrapper.EXPOCAD3E_BOOTH_FINANCIALS;
            newItemList.add(apiSyncItemforExhibitors);
        }
        return newItemList;
    }
       /**
    * @description  Creation of All API Sync items if triggered from Opportunity .
    * @param  newOpportunityMap
    * @return  lstApiSyncItem
    * Added for [FC-1701]
    */                                      
   public static List<API_Synchronization_Item__c> insertAPISyncItemsForBoothReqItems(Map<Id,ExpocadBooth__c> newExpoBoothMap,Boolean checkStatus){
        List<API_Synchronization_Item__c> newItemList = new List<API_Synchronization_Item__c>();
        for(String recId :newExpoBoothMap.keySet()){
            ExpocadBooth__c rec = newExpoBoothMap.get(recId);
            API_Synchronization_Item__c apiSyncItemforExhibitors = new API_Synchronization_Item__c();
            apiSyncItemforExhibitors.Status__c = checkStatus ? 'Queued' : 'Paused';
            apiSyncItemforExhibitors.API_Call_Type__c = 'GET';
            apiSyncItemforExhibitors.Opportunity__c = rec.opportunity__c;
            apiSyncItemforExhibitors.ExpocadBooth__c = rec.Id;
            apiSyncItemforExhibitors.X3rd_Party_Relationship__c = Expocad3E_Wrapper.EXPOCAD3E;
            apiSyncItemforExhibitors.Type__c = Expocad3E_Wrapper.EXPOCAD3E_BOOTH_REQITEMS;
            newItemList.add(apiSyncItemforExhibitors);
        }
        return newItemList;
    }


       /**
    * @description  Creation of All API Sync items if triggered from Opportunity .
    * @param  newOpportunityMap
    * @return  lstApiSyncItem
    * Added for [FC-1701]
    */                                      
   public static List<API_Synchronization_Item__c> insertAPISyncItemsContracts(Map<Id,ExpocadBooth__c> newExpoBoothMap,Boolean checkStatus){
        List<API_Synchronization_Item__c> newItemList = new List<API_Synchronization_Item__c>();
        for(String recId :newExpoBoothMap.keySet()){
            ExpocadBooth__c rec = newExpoBoothMap.get(recId);
            API_Synchronization_Item__c apiSyncItemforExhibitors = new API_Synchronization_Item__c();
            apiSyncItemforExhibitors.Status__c = checkStatus ? 'Queued' : 'Paused';
            apiSyncItemforExhibitors.API_Call_Type__c = 'GET';
            apiSyncItemforExhibitors.Opportunity__c = rec.opportunity__c;
            apiSyncItemforExhibitors.ExpocadBooth__c = rec.Id;
            apiSyncItemforExhibitors.X3rd_Party_Relationship__c = Expocad3E_Wrapper.EXPOCAD3E;
            apiSyncItemforExhibitors.Type__c = Expocad3E_Wrapper.EXPOCAD3E_CONTRACT_PULL_END;
            newItemList.add(apiSyncItemforExhibitors);
        }
        return newItemList;
    }

    /**
    * @description  Creation of All API Sync items if triggered from Opportunity .
    * @param  newOpportunityMap
    * @return  lstApiSyncItem
    * Added for [FC-1701]
    */                                      
    public static List<API_Synchronization_Item__c> insertAPISyncItemsQuoteCalculate(Map<Id,ExpocadBooth__c> newExpoBoothMap,Boolean checkStatus){
        List<API_Synchronization_Item__c> newItemList = new List<API_Synchronization_Item__c>();
        for(String recId :newExpoBoothMap.keySet()){
            ExpocadBooth__c rec = newExpoBoothMap.get(recId);
            API_Synchronization_Item__c apiSyncItemforExhibitors = new API_Synchronization_Item__c();
            apiSyncItemforExhibitors.Status__c = checkStatus ? 'Queued' : 'Paused';
            apiSyncItemforExhibitors.API_Call_Type__c = 'GET';
            apiSyncItemforExhibitors.Opportunity__c = rec.opportunity__c;
            apiSyncItemforExhibitors.X3rd_Party_Relationship__c = Expocad3E_Wrapper.EXPOCAD3E;
            apiSyncItemforExhibitors.Type__c = Expocad3E_Wrapper.EXPOCAD3E_QUOTE_CALCULATE;
            newItemList.add(apiSyncItemforExhibitors);
            break;
        }
        return newItemList;
    }


    public static List<API_Synchronization_Item__c> insertAPISyncItemsOppUpdate(Map<Id,ExpocadBooth__c> newExpoBoothMap,Boolean checkStatus){
        List<API_Synchronization_Item__c> newItemList = new List<API_Synchronization_Item__c>();
        for(String recId :newExpoBoothMap.keySet()){
            ExpocadBooth__c rec = newExpoBoothMap.get(recId);
            API_Synchronization_Item__c apiSyncItemforExhibitors = new API_Synchronization_Item__c();
            apiSyncItemforExhibitors.Status__c = checkStatus ? 'Queued' : 'Paused';
            apiSyncItemforExhibitors.API_Call_Type__c = 'GET';
            apiSyncItemforExhibitors.Opportunity__c = rec.opportunity__c;
            apiSyncItemforExhibitors.X3rd_Party_Relationship__c = Expocad3E_Wrapper.EXPOCAD3E;
            apiSyncItemforExhibitors.Type__c = Expocad3E_Wrapper.EXPOCAD3E_OPP_UPDATE;
            newItemList.add(apiSyncItemforExhibitors);
            break;
        }
        return newItemList;
    }

    /**
    * @description  Helper method for creation of API Sync items for Booth Sync with Expocad
    * @param  expoBooth
    * @param  requestType
    * @param  apiCallName
    * @param  isReplaceBooth
    * @return  asynctransId
    * Added by Abhishek Sharma on 22/02/2023 : EX-154
    */  
    public static Id syncBooth(ExpocadBooth__c expoBooth, String requestType, String apiCallName, Boolean isReplaceBooth, String displayName){
        Id asynctransId;
        try{
			
            ApiSyncRecordsWrapper apiSyncInsertWrap = new ApiSyncRecordsWrapper();
            if(expoBooth.Id == null){
                ExpocadBooth__c eBooth = [SELECT Id, Booth_Number__c, Opportunity__c, Status__c FROM ExpocadBooth__c 
                                          WHERE Booth_Number__c=:expoBooth.Booth_Number__c AND Opportunity__c=:expoBooth.Opportunity__c AND Status__c= 'Rented'];
                apiSyncInsertWrap.newExpoBoothMap.put(eBooth.Id, eBooth);            
            }
            else{
                apiSyncInsertWrap.newExpoBoothMap.put(expoBooth.Id, expoBooth);            
            }
            apiSyncInsertWrap.startedFrom = 'Expocad Booth';
            apiSyncInsertWrap.apiCallName = apiCallName;
            apiSyncInsertWrap.isReplaceBooth = isReplaceBooth;
            apiSyncInsertWrap.requestType = requestType == 'Synchronous' ? 'Synchronous' : 'Asynchronous';
            apiSyncInsertWrap.displayName = displayName;
            apiSyncInsertWrap.thirdPartyRelation = Expocad3E_Wrapper.EXPOCAD_EDGE;
            asynctransId = insertAllAPISyncItem(apiSyncInsertWrap);
        } catch (Exception e) 
        {
            system.System.debug('---error--'+String.valueof(e.getLineNumber()));
            system.System.debug('---error--'+String.valueof(e.getMessage()));
            HandleAllCustomException.LogException(e,'','After Insert');
           
        }
         return asynctransId;
     }

    /**
    * @description  Creation of All API Sync items for Booth Sync with Expocad
    * @param  expoBoothMap
    * @param  apiCallName
    * @param  checkStatus
    * @param  isReplaceBooth
    * @return  newItemList
    * Added by Abhishek Sharma on 22/02/2023 : EX-154
    */  
	public static List<API_Synchronization_Item__c> insertAPISyncItemsBoothSync(Map<Id,ExpocadBooth__c> newExpoBoothMap, String apiCallName, Boolean checkStatus, Boolean isReplaceBooth, String displayName){
        
		List<API_Synchronization_Item__c> newItemList = new List<API_Synchronization_Item__c>();
		for(String recId :newExpoBoothMap.keySet()){
			ExpocadBooth__c rec = newExpoBoothMap.get(recId);

            if(apiCallName == Expocad3E_Wrapper.EXPOCAD_BOOTH_RENT){
                API_Synchronization_Item__c apiSyncItemforExhibitors = new API_Synchronization_Item__c();
                apiSyncItemforExhibitors.Status__c = checkStatus ? 'Queued' : 'Paused';
                apiSyncItemforExhibitors.API_Call_Type__c = 'POST';
                apiSyncItemforExhibitors.Opportunity__c = rec.opportunity__c;
                apiSyncItemforExhibitors.ExpocadBooth__c = rec.Id;
                apiSyncItemforExhibitors.X3rd_Party_Relationship__c = Expocad3E_Wrapper.EXPOCAD_EDGE;
                apiSyncItemforExhibitors.Type__c = Expocad3E_Wrapper.EXPOCAD_ADDEXHIBITOR;
                newItemList.add(apiSyncItemforExhibitors);
                //Create UnHold call for the Booth which is updated from Hold to Rent. For the replaceBooth functionality, booth is rented direct without calling unHold.
                if(!isReplaceBooth){
                    API_Synchronization_Item__c apiSyncItemforSyncBoothUnhold = new API_Synchronization_Item__c();
                    apiSyncItemforSyncBoothUnhold.Status__c = checkStatus ? 'Queued' : 'Paused';
                    apiSyncItemforSyncBoothUnhold.API_Call_Type__c = 'PUT';
                    apiSyncItemforSyncBoothUnhold.Opportunity__c = rec.opportunity__c;
                    apiSyncItemforSyncBoothUnhold.ExpocadBooth__c = rec.Id;
                    apiSyncItemforSyncBoothUnhold.X3rd_Party_Relationship__c = Expocad3E_Wrapper.EXPOCAD_EDGE;
                    apiSyncItemforSyncBoothUnhold.Type__c = Expocad3E_Wrapper.EXPOCAD_BOOTH_UNHOLD;
                    newItemList.add(apiSyncItemforSyncBoothUnhold);
                }
            }

            API_Synchronization_Item__c apiSyncItemforSyncBooth = new API_Synchronization_Item__c();
			apiSyncItemforSyncBooth.Status__c = checkStatus ? 'Queued' : 'Paused';
			apiSyncItemforSyncBooth.API_Call_Type__c = 'PUT';
			apiSyncItemforSyncBooth.Opportunity__c = rec.opportunity__c;
			apiSyncItemforSyncBooth.ExpocadBooth__c = rec.Id;
			apiSyncItemforSyncBooth.X3rd_Party_Relationship__c = Expocad3E_Wrapper.EXPOCAD_EDGE;
			apiSyncItemforSyncBooth.Type__c = apiCallName;
			newItemList.add(apiSyncItemforSyncBooth);
            
            if(apiCallName == Expocad3E_Wrapper.EXPOCAD_BOOTH_UNHOLD && !String.isBlank(displayName) && displayName != ''){
                API_Synchronization_Item__c apiSyncItemforSyncBoothHold = new API_Synchronization_Item__c();
                apiSyncItemforSyncBoothHold.Status__c = checkStatus ? 'Queued' : 'Paused';
                apiSyncItemforSyncBoothHold.API_Call_Type__c = 'PUT';
                apiSyncItemforSyncBoothHold.Opportunity__c = rec.opportunity__c;
                apiSyncItemforSyncBoothHold.ExpocadBooth__c = rec.Id;
                apiSyncItemforSyncBoothHold.X3rd_Party_Relationship__c = Expocad3E_Wrapper.EXPOCAD_EDGE;
                apiSyncItemforSyncBoothHold.Type__c = Expocad3E_Wrapper.EXPOCAD_BOOTH_HOLD;
                newItemList.add(apiSyncItemforSyncBoothHold);
            }

		}
		return newItemList;
	}

}