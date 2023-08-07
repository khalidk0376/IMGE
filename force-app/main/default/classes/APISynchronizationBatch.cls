/**
* File          :   APISynchronizationBatch
* Project       :   Foundational CRM
* Created By    :   (Girikon) 
* Created Date  :   19th April 2022
* Test Class    :   APISynchronization_Test,SyncEditionProductsCtrl_Test
* Coverage      :   91% 
* *******************************************************************************************************
* @description : batch to make API calls using API_Synchronization_Items Records  
* *******************************************************************************************************
* Modification log :   
* Abhishek Sharma on 22Feb2023 for EX-154
  
*/
public with sharing class APISynchronizationBatch implements Database.Batchable<sObject>,Database.stateful,Database.AllowsCallouts
{
    /****** FINAL CONSTANT VARIABLES  *****/
    public static final String BATCH_EXECUTION_ERRORS = 'Batch Execution errors';
    public static final String EXTERNAL_API_CALL = 'External Api Call';
    public static final String COMPLETED_WITH_ERRORS =  'Completed With Errors';

    /****** PUBLIC Varibales *******/
    public string token;
    public ID tokenEditionId;
    public ID interfaceLogId;
    public datetime tokenGenrationTime;
    public Integer tokenTimeoutMin = 55;
    public Set<Id> setErroneousAPISyncTrans;
    public List<Expo3EAPIUtilHelper.AddQliWrapper> AddQliWrapperList;
    public List<Opportunity> listOppForStatusUpdate;
    public Set<Id> setAllAPISyncTrans;
    public set<Id> synchronizationTransIds;
    public list<API_Synchronization_Item__c> syncItems;
    
    /**
    * @description APISynchronizationBatch this constructor is used to execute batch in front mode
    * @param syncTransIds api transaction ids
    */
    public APISynchronizationBatch(set<Id> syncTransIds)
    {
        AddQliWrapperList = new List<Expo3EAPIUtilHelper.AddQliWrapper>();
        tokenGenrationTime = Datetime.now();
        syncItems = new list<API_Synchronization_Item__c>();        
        setErroneousAPISyncTrans = New Set<Id> ();
        setAllAPISyncTrans = New Set<Id> ();
        this.synchronizationTransIds = new Set<Id>();
        this.synchronizationTransIds = syncTransIds;
    }
     
    /**
    * @description  This constructor is used to execute batch in background mode
    **/
    public APISynchronizationBatch()
    {        
        AddQliWrapperList = new List<Expo3EAPIUtilHelper.AddQliWrapper>();
        tokenGenrationTime = Datetime.now();
        syncItems = new list<API_Synchronization_Item__c>();        
        setErroneousAPISyncTrans = New Set<Id> ();
        setAllAPISyncTrans = New Set<Id> ();
    }

  /**
    * @description  This method is used to get the query and records in chunk
    * @param bc BatchableContext
    * @return Database.QueryLocator
    **/
    public Database.QueryLocator start(Database.BatchableContext bc)
    {
        this.listOppForStatusUpdate = new List<Opportunity>();
        System.debug('APISynchronizationBatch--1.1');
        String query = APISynchronizationHelper.getAPISyncItemsQueryAndStartProcessing(this.synchronizationTransIds);
        System.debug('APISynchronizationBatch--1'+query);
        this.interfaceLogId = ErrorLogUtility.createInterfaceLog(BATCH_EXECUTION_ERRORS,EXTERNAL_API_CALL); 
        System.debug('APISynchronizationBatch--2');
        return Database.getQueryLocator(query);
    }
     
    /**
    * @description : This method is used to make callouts for sync
    * @param bc BatchableContext
    * @param items line items to be processed
    **/
    public void execute(Database.BatchableContext bc, List<API_Synchronization_Item__c> items)
    {
        for(API_Synchronization_Item__c item: items) // Valid for one data in loop only
        {
            System.debug('APISynchronizationBatch--3');
            this.setAllAPISyncTrans.add(item.API_Synchronization_Transaction__c);
            try
            {    
                System.debug(logginglevel.DEBUG,'Processing Item : '+item.Id +' of Trans : '+item.API_Synchronization_Transaction__c); 

                if(APISynchronizationHelper.validateSyncItem(item)) 
                {
                    System.debug('APISynchronizationBatch--4');
                    String calloutStatus = Expocad3E_Wrapper.PROCESSING;
                   

                    if(item.X3rd_Party_Relationship__c == Expocad3E_Wrapper.EXPOCAD3E){                        
                       
                        if(String.isNotBlank(item.Type__c) && item.Type__c == Expocad3E_Wrapper.EXPOCAD3E_EXHIBITOR_INVITE) 
                        {
                            System.debug('APISynchronizationBatch--5');
                            calloutStatus = Expo3EAPIUtils.inviteExhibitorInExpoCAD(item);//, this.interfaceLogId
                        }else if(String.isNotBlank(item.Type__c) && item.Type__c == Expocad3E_Wrapper.EXPOCAD3E_CONTRACT_PULL) 
                        {
                            calloutStatus = Expo3EAPIUtils.getContractsFrom3E(item);//, this.interfaceLogId
                        }else if(String.isNotBlank(item.Type__c) && item.Type__c == Expocad3E_Wrapper.EXPOCAD3E_COMPANY_TYPE) 
                        {
                            calloutStatus = Expo3EAPIUtils.getCompanyListFrom3E(item);//, this.interfaceLogId  
                        }else if(String.isNotBlank(item.Type__c) && (item.Type__c == Expocad3E_Wrapper.EXPOCAD3E_COMPANY_TYPE_ASSIGN || item.Type__c == Expocad3E_Wrapper.EXPOCAD3E_COMPANY_TYPE_UNASSIGN)) 
                        {
                            calloutStatus = Expo3EAPIUtils.companyTypeAssignInExpoCAD3E(item);//, this.interfaceLogId  
                        }else if(String.isNotBlank(item.Type__c) && item.Type__c == Expocad3E_Wrapper.EXPOCAD3E_BOOTH_DETAILS) 
                        {
                            calloutStatus = Expo3EAPIUtils.GetBoothAllFromExpocad(item); 
                        }
                        else if(String.isNotBlank(item.Type__c) && item.Type__c == Expocad3E_Wrapper.EXPOCAD3E_BOOTH_FINANCIALS) 
                        {
                            Expo3EAPIUtilHelper.AddQliWrapper qliWrapper = Expo3EAPIUtils.GetBoothFinancialFromExpocad(item);
                        }
                        else if(String.isNotBlank(item.Type__c) && item.Type__c == Expocad3E_Wrapper.EXPOCAD3E_BOOTH_REQITEMS) 
                        {
                            calloutStatus = Expo3EAPIUtils.GetBoothRelatedFromExpocad(item);
                        }
                        else if(String.isNotBlank(item.Type__c) && item.Type__c == Expocad3E_Wrapper.EXPOCAD3E_QUOTE_CALCULATE) 
                        {
                            calloutStatus = Expo3EAPIUtils.CalculateQuote(item);
                                                       
                        }
                        else if(String.isNotBlank(item.Type__c) && item.Type__c == Expocad3E_Wrapper.EXPOCAD3E_OPP_UPDATE) 
                        {
                           calloutStatus = Expo3EAPIUtils.UpdateOpportunity(item,listOppForStatusUpdate);
                                                       
                        }
                        else if(String.isNotBlank(item.Type__c) && item.Type__c == Expocad3E_Wrapper.EXPOCAD3E_CONTRACT_PULL_END) 
                        {
                            calloutStatus = Expo3EAPIUtils.getContractsFrom3EEnd(item);
                        }
                    }
                    //Added by Abhishek Sharma on 22/02/2023 : EX-154					
                    else if(item.X3rd_Party_Relationship__c == Expocad3E_Wrapper.EXPOCAD_EDGE){   
                        if(String.isNotBlank(item.Type__c) && (item.Type__c == Expocad3E_Wrapper.EXPOCAD_BOOTH_UNHOLD || 
                                                                    item.Type__c == Expocad3E_Wrapper.EXPOCAD_BOOTH_RENTTOHOLD || 
                                                                    item.Type__c == Expocad3E_Wrapper.EXPOCAD_BOOTH_HOLD ||
                                                                   	item.Type__c == Expocad3E_Wrapper.EXPOCAD_BOOTH_UNRENT  ||
                                                                   	item.Type__c == Expocad3E_Wrapper.EXPOCAD_BOOTH_RENT ))
                        {
                            calloutStatus = Expo3EAPIUtils.syncExpocadBooth(item);
                        } 
                        else if(String.isNotBlank(item.Type__c) && item.Type__c == Expocad3E_Wrapper.EXPOCAD_ADDEXHIBITOR) 
                        {
                            calloutStatus = Expo3EAPIUtils.createExpocadExhibitor(item);
                        }
                    }   
                    // Incase of Error
                    if(calloutStatus == Expocad3E_Wrapper.ERROR)
                    {
                        this.setErroneousAPISyncTrans.add(item.API_Synchronization_Transaction__c);
                    }
                }
                
                else{
                    item.Error_Message__c = item.API_Synchronization_Transaction__r.X3rd_Party_Relationship__c + ' Synchronization is not valid for the Edition';
                    item.Status__c = Expocad3E_Wrapper.ERROR;
                    syncItems.add(item);
                    this.setErroneousAPISyncTrans.add(item.API_Synchronization_Transaction__c);
                }             
            }catch(Exception e){
                item.Error_Message__c = e.getMessage();
                item.Status__c = Expocad3E_Wrapper.ERROR;
                system.debug(logginglevel.DEBUG,'Error_Message__c --> '+item.Error_Message__c +' At Line' + e.getLineNumber());
                this.setErroneousAPISyncTrans.add(item.API_Synchronization_Transaction__c);
                system.debug(logginglevel.DEBUG,' Trace --> '+ e.getStackTraceString());
                syncItems.add(item);
                HandleAllCustomException.LogException(e,String.valueof(item.Id),'');
            }
        }
    }

    /**
    * @description  This method is used to update final status on items and Transactions
    * @param bc BatchableContext
    **/
    public void finish(Database.BatchableContext bc)
    {
        list<API_Synchronization_Transaction__c> syncTrans = new list<API_Synchronization_Transaction__c>();
       //? list<Edition__c> editions = new list<Edition__c>();
        try { 
            for(ID syncTranId:this.setAllAPISyncTrans)
            {
                API_Synchronization_Transaction__c syncTran = new API_Synchronization_Transaction__c();
                syncTran.Id = syncTranId;
                syncTran.Status__c  = this.setErroneousAPISyncTrans.contains(syncTranId)?COMPLETED_WITH_ERRORS:Expocad3E_Wrapper.COMPLETED;
                syncTran.Interface_Log__c = this.setErroneousAPISyncTrans.contains(syncTranId)?this.interfaceLogId:null;
                syncTrans.add(syncTran);
            }
            if(Schema.sObjectType.API_Synchronization_Transaction__c.isUpdateable())
            {
                update syncTrans;
            }
            if(!this.syncItems.isEmpty() && Schema.sObjectType.API_Synchronization_Item__c.isUpdateable())
            {
                update syncItems;
            }
            if(this.listOppForStatusUpdate != null && !this.listOppForStatusUpdate.isEmpty()){
                update this.listOppForStatusUpdate;
            }
            TriggerInterfaceHelper.isRunning = false;
            Expo3EAPIUtils.queueApiTransactions();
            if(setErroneousAPISyncTrans.isEmpty())
            {
                Delete new Interface_Log__c(id=this.interfaceLogId);//??
            }
           //? APISynchronizationHelper.updateEditionsStatus(editions);
            APISynchronizationHelper.scheduleBatchForNextItems();
            
            //Sending Email to Batch Owner and other user in CC when Batch Execution Fails[FC-1929]
            if(!setErroneousAPISyncTrans.isEmpty())
            {
                 APISynchronizationHelper.sendEmailOnBatchFail(setErroneousAPISyncTrans); 
            }                       
        
        }
        catch(Exception e){

            HandleAllCustomException.LogException(e,String.valueof(bc.getJobId()),'');
        }
    }
}