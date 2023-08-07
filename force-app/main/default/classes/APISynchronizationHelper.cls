/**
* File      :   APISynchronizationHelper 
* Project    :   Foundational CRM
* Created Date  :  19th April 2022
* Created By  :   (Girikon)
* Test Class  :   
* Coverage    :   
* *******************************************************************************************************
* @description : to support APISynchronizationBatch batch class with methords to create query and make updates 
* *******************************************************************************************************
* Modification log :   
   
*/
public with sharing class APISynchronizationHelper 
{    
    /****** FINAL CONSTANT VARIABLES  *****/
    public static final String NOTIFICATION_EMAIL_SUBJECT = 'SF-3ExpoCAD synchronization completed with errors';

    /**
    * @description  This method is used for genrate Dynamic Query to process in batch 
    * @param  synchronizationTransIds  Api synchronization Trans Ids
    * @return  String APISyncItemsQuery
    */
    Public Static String getAPISyncItemsQueryAndStartProcessing(set<Id> synchronizationTransIds)
    {
       // Map<Id,String> mapRoleIdRoleName = getRolesAndSubordinatesIds();??
        String currentUserRole = '';//mapRoleIdRoleName.get(UserInfo.getUserRoleId());??
        Set<String> thirdParty = new Set<String>{Expocad3E_Wrapper.EXPOCAD3E,Expocad3E_Wrapper.EXPOCAD_EDGE}; 
        //if(currentUserRole == Expocad3E_Wrapper.SFV){thirdParty = new Set<String>{Expocad3E_Wrapper.EXPOCAD};}
        //if(currentUserRole == Expocad3E_Wrapper.ICRE){thirdParty = new Set<String>{Expocad3E_Wrapper.MYS};}
        List<Id> setProcessQueuedItems       = new List<Id>(); // API_Synchronization_Transactions with Status "Queued"
        List<Id> setProcessAllItems          = new List<Id>(); // API_Synchronization_Transactions with Status "Requeue All"
        List<Id> setProcessErroneousItems    = new List<Id>(); // API_Synchronization_Transactions with Status "Requeue for Erroneous records"    
        List<Id> setProcessSuccessfulItems   = new List<Id>(); // API_Synchronization_Transactions with Status "Requeue for Successful records"
        
        String syncTransaQuerycp = 'Select Id,Status__c from API_Synchronization_Transaction__c where X3rd_Party_Relationship__c IN:thirdParty And Status__c in (\'Queued\',\'Requeue for Erroneous records\',\'Requeue All\',\'Requeue for Successful records\') '; 

        String syncTransaQuery = synchronizationTransIds != null ? syncTransaQuerycp+' And Request_Type__c = \'Synchronous\' And id in : synchronizationTransIds' : syncTransaQuerycp+ ' And (Request_Type__c = \'Asynchronous\' or Status__c != \'Queued\') ';
                
        /** DEBUG **/ System.debug(logginglevel.DEBUG,'syncTransaQuery : '+syncTransaQuery);
        
        // get API_Synchronization_Transaction ready to be pocessed
        for(API_Synchronization_Transaction__c apiSyncTr : Database.query(syncTransaQuery))
        {            
            switch on apiSyncTr.Status__c {
                when 'Queued'{
                    setProcessQueuedItems.add(apiSyncTr.Id);
                }
                when 'Requeue All'{
                    setProcessAllItems.add(apiSyncTr.Id);
                }
                when 'Requeue for Erroneous records'{
                    setProcessErroneousItems.add(apiSyncTr.Id);
                }
                when 'Requeue for Successful records'{
                    setProcessSuccessfulItems.add(apiSyncTr.Id);
                }             
            }
        }
        
        // Creating Query for API_Synchronization_Item to process in batch[modified for EX-7]
        String fields = 'ID,Type__c,X3rd_Party_Relationship__c,API_Call_Type__c,Request_Body__c,opportunity__r.EventEdition__r.Auto_Invite_Exhibitor_in_3E__c,opportunity__r.EventEdition__r.Opportunity_Probability_During_3E_Invite__c,Event_Edition__r.Expocad_API_URL__c,';//3e
        fields += 'Event_Edition__r.X3rd_Party_Relationship__c,Event_Edition__r.External_Status__c,opportunity__r.EventEdition__c,opportunity__r.EventEdition__r.X3rd_Party_Relationship__c,opportunity__r.EventEdition__r.x3E_API_ID__c,opportunity__r.EventEdition__r.X3E_Status__c,';//3e
        fields += 'opportunity__r.EventEdition__r.Event_Code__c,opportunity__r.EventEdition__r.Expocad_API_URL__c,ExpocadBooth__r.Opportunity__r.EventEdition__r.Expocad_API_URL__c,ExpocadBooth__r.Opportunity__r.EventEdition__r.Event_Code__c,';
        fields += 'Event_Edition__r.Event_Code__c,Status__c,Event_Edition__c,Event_Edition__r.x3E_API_ID__c,Event_Edition__r.X3E_Status__c,ExpocadBooth__c,ExpocadBooth__r.Opportunity__r.EventEdition__r.X3rd_Party_Relationship__c,ExpocadBooth__r.Opportunity__r.EventEdition__r.x3E_API_ID__c,ExpocadBooth__r.Opportunity__r.EventEdition__r.X3E_Status__c,';
        fields += 'API_Synchronization_Transaction__c,API_Synchronization_Transaction__r.Status__c,API_Synchronization_Transaction__r.X3rd_Party_Relationship__c ';
       // fields += 'API_Synchronization_Transaction__r.Type__c,Opportunity_Contact_Role__c,Asset__c,Asset__r.Booth_Number__c,Asset__r.Product2Id,Asset__r.Area__c,Asset__r.Length__c,Asset__r.Width__c,';
       // fields += 'Asset__r.Account.IM_Account_Number__c,Asset__r.AccountId,Asset__r.Account.Name,Asset__r.Product2.Name,';
       // fields += 'Asset__r.Opportunity__c,Opportunity__c,Opportunity__r.StageName,Description__c,Error_Message__c,API_Synchronization_Transaction__r.Description__c,Related_API_Transaction__c,';
      //  fields += 'Opportunity__r.Invoice__c,Edition__r.ExpoCAD_Folder_Name__c';
        //Event_Edition__c != null And
        String condition = ' where  Status__c Not In (\'Paused\',\'Completed with Financials\',\'Pending with Financials\') And ( '; 
        string filter='';
        
        if(!setProcessQueuedItems.isEmpty()) // Process -  Queued 
        {
            filter += ' Or (  API_Synchronization_Transaction__c in (\''+String.join(setProcessQueuedItems,'\',\'')+'\') And Status__c = \'Queued\') ';
        }
        
        if(!setProcessAllItems.isEmpty()) // Process - Error ; Queued ; Re-Queued
        {
            filter += ' Or (  API_Synchronization_Transaction__c in (\''+String.join(setProcessAllItems,'\',\'')+'\') ) ';
        }

        if(!setProcessErroneousItems.isEmpty()) // Process - Error
        {
            filter += ' Or (  API_Synchronization_Transaction__c in (\''+String.join(setProcessErroneousItems,'\',\'')+'\') And Status__c = \'Error\') ';
        }

        if(!setProcessSuccessfulItems.isEmpty()) // Process - Completed
        {
            filter += ' Or (  API_Synchronization_Transaction__c in (\''+String.join(setProcessSuccessfulItems,'\',\'')+'\') And Status__c = \'Completed\') ';
        }
        filter = String.isNotBlank(filter) ? filter.removeStart(' Or') :' API_Synchronization_Transaction__c = null ';

        String query = 'Select '+fields+' from API_Synchronization_Item__c '+condition+filter + ' ) ORDER BY Name,Opportunity__c,Sort_Order__c ';
        if(Test.isRunningTest())
        {
            query+= ' limit 1 ';
        }
        System.debug(logginglevel.DEBUG,' API_Synchronization_Item query :' + query );

        map<Id,API_Synchronization_Transaction__c> mapAPITrs = New map<Id,API_Synchronization_Transaction__c>();
        map<Id,Event_Edition__c> mapEditions = New map<Id,Event_Edition__c>();
        map<Id,opportunity> mapOpportunity = New map<Id,opportunity>();
        
        for(API_Synchronization_Item__c item :database.query(query))
        {
            mapAPITrs.put(item.API_Synchronization_Transaction__c,New API_Synchronization_Transaction__c (Id=item.API_Synchronization_Transaction__c,Status__c = Expocad3E_Wrapper.PROCESSING));

           //? mapEditions.put(item.Event_Edition__c,New Event_Edition__c(Id = item.Event_Edition__c,API_Synchronization_Status__c =Expocad3E_Wrapper.PROCESSING));

         /* ?  if(String.isNotBlank(item.Opportunity__c) && (item.API_Synchronization_Transaction__r.Type__c ==Expocad3E_Wrapper.PRODUCT_SYNC || item.API_Synchronization_Transaction__r.Type__c ==Expocad3E_Wrapper.FINANCIALS || item.API_Synchronization_Transaction__r.Type__c == Expocad3E_Wrapper.AUDIT_SYNC))
            {
                mapOpportunity.put(item.Opportunity__c,New Opportunity(Id=item.Opportunity__c,Bypass_validation_Rule__c=true));
            }*/
        }

        if(!mapAPITrs.isEmpty() && Schema.sObjectType.API_Synchronization_Transaction__c.isUpdateable())
        {
            update mapAPITrs.values();
        }        

        //updateEditionsStatus(mapEditions.values()); // update Status on Editions 

        //updateOpportunityData(mapOpportunity.values()); // update Bypass value on Opportunity

        return query;
    }
    /**
    * @description  This method is used to update Event_Edition__c
    * @param editions List<Event_Edition__c>
    */
    public Static void updateEditionsStatus(List<Event_Edition__c> editions)
    {
        Boolean isUpdate = true;
        if(!editions.isEmpty() && (Schema.sObjectType.Event_Edition__c.isUpdateable() || isUpdate))
        {
            update editions;
        }
    }

    /**
    * @description  This method is used to update API_Synchronization_Transaction__c
    * @param apiSyncTrans API Synchronization Transaction
    */
    public Static void updateSingleAPISyncTransaction(API_Synchronization_Transaction__c apiSyncTrans)
    {
        if(apiSyncTrans != null && Schema.sObjectType.API_Synchronization_Transaction__c.isUpdateable())
        {
            update apiSyncTrans;
        }
    }

    /**
    * @description  This method is used to update Opportunity
    * @param opps List<Opportunity>
    */
    public Static void updateOpportunityData(List<Opportunity> opps)
    {
        if(!opps.isEmpty() && Schema.sObjectType.Opportunity.isUpdateable())
        {
            update opps;
        }
    }

    /**
    * @description  This method is used to update API_Synchronization_Item__c
    * @param item API Synchronization Item
    */
    public Static void updateSyncItemStatus(API_Synchronization_Item__c item)
    {
        if(item != null && Schema.sObjectType.API_Synchronization_Item__c.isUpdateable())
        {
            Boolean isSaveAttachment = ((item.Response_Code__c!=null && item.Response_Code__c.length()>255) || (item.Response_Body__c!=null && item.Response_Body__c.length()>131072) || (item.Request_Body__c!=null && item.Request_Body__c.length()>131072));
            item.Response_Code__c = (item.Response_Code__c!=null?item.Response_Code__c.left(255):'');
            item.Response_Body__c = (item.Response_Body__c!=null?item.Response_Body__c.left(131072):'');
            item.Request_Body__c = (item.Request_Body__c!=null?item.Request_Body__c.left(131072):'');
            update item;
            String body = (isSaveAttachment?((item.Request_Body__c!=null?item.Request_Body__c:'') + '\n\n' + (item.Response_Code__c!=null?item.Response_Code__c:'') + '\n\n' + (item.Response_Body__c!=null?item.Response_Body__c:'')):'');
            if(isSaveAttachment){APISynchronizationHelper.createResponseAttchment(item.Id, body);}
        }
    }
    
    /**
    * @description  This method is used to get callout details like username,passwords & End points for  diffrent Systems
    * @param  metaDataName metadata label name
    * @param thirdParty third party name
    * @return  API_Detail__mdt
    */
    public Static API_Detail__mdt getAPIDetails(String metaDataName, String thirdParty)
    {
        API_Detail__mdt apiMappings;
        if(Schema.sObjectType.API_Detail__mdt.isaccessible() && thirdParty == Expocad3E_Wrapper.EXPOCAD3E)
        {
            apiMappings = [Select API_End_Point__c,API_Method__c from API_Detail__mdt Where API_3rd_Party_Name__c=:Expocad3E_Wrapper.EXPOCAD3E and MasterLabel =:metaDataName limit 1];
        }
        return apiMappings;
    }

    /**
    * @description  This method is used to validate Editions data before callouts
    * @param  item API Synchronization Item     
    * @return  Boolean Status
    */
    public Static Boolean validateSyncItem(API_Synchronization_Item__c item)
    {
        Boolean allvalid = false;
        // FOR ExpoCAD 3E
        if(String.isNotBlank(item.opportunity__r.EventEdition__c)){ 
            if(item.X3rd_Party_Relationship__c == Expocad3E_Wrapper.EXPOCAD3E  && String.isNotBlank(item.opportunity__r.EventEdition__r.x3E_API_ID__c) && item.opportunity__r.EventEdition__r.X3E_Status__c == 'Active')
            {
                allvalid = true;
            }
            else if(item.X3rd_Party_Relationship__c == Expocad3E_Wrapper.EXPOCAD_EDGE &&  String.isNotBlank(item.opportunity__r.EventEdition__r.Event_Code__c) && String.isNotBlank(item.opportunity__r.EventEdition__r.Expocad_API_URL__c)){
                allvalid = true;
            }
        }
        if(String.isNotBlank(item.Event_Edition__c)){ 
            if(item.X3rd_Party_Relationship__c == Expocad3E_Wrapper.EXPOCAD3E  && String.isNotBlank(item.Event_Edition__r.x3E_API_ID__c) && item.Event_Edition__r.X3E_Status__c == 'Active')
            {
                allvalid = true;
            }
            else if(item.X3rd_Party_Relationship__c == Expocad3E_Wrapper.EXPOCAD_EDGE &&  String.isNotBlank(item.Event_Edition__r.Event_Code__c) && String.isNotBlank(item.Event_Edition__r.Expocad_API_URL__c)){
                allvalid = true;
            }
        }
        if(String.isNotBlank(item.ExpocadBooth__c)){ 
            if(item.X3rd_Party_Relationship__c == Expocad3E_Wrapper.EXPOCAD3E  && String.isNotBlank(item.ExpocadBooth__r.Opportunity__r.EventEdition__r.x3E_API_ID__c) && item.ExpocadBooth__r.Opportunity__r.EventEdition__r.X3E_Status__c == 'Active')
            {
                allvalid = true;
            }
            else if(item.X3rd_Party_Relationship__c == Expocad3E_Wrapper.EXPOCAD_EDGE &&  String.isNotBlank(item.ExpocadBooth__r.Opportunity__r.EventEdition__r.Event_Code__c) && String.isNotBlank(item.ExpocadBooth__r.Opportunity__r.EventEdition__r.Expocad_API_URL__c)){
                allvalid = true;
            }
        }
        return allvalid;
    }

    /**
    * @description  This method is used to re-Schedule the batch if more items are Queued
    * @return  String jobid
    */
    public Static String scheduleBatchForNextItems()
    {
        //Map<Id,String> mapRoleIdRoleName = getRolesAndSubordinatesIds();????
        String currentUserRole = '';//mapRoleIdRoleName.get(UserInfo.getUserRoleId()); ????
        Set<String> thirdParty = new Set<String>{Expocad3E_Wrapper.EXPOCAD3E};
        //if(currentUserRole == Expocad3E_Wrapper.SFV){thirdParty = new Set<String>{Expocad3E_Wrapper.EXPOCAD};}
        //if(currentUserRole == Expocad3E_Wrapper.ICRE){thirdParty = new Set<String>{Expocad3E_Wrapper.MYS};}
        string jobId;
        string strCountQuery = 'Select count() from API_Synchronization_Transaction__c where X3rd_Party_Relationship__c IN:thirdParty And Request_Type__c = \'Asynchronous\' And Status__c in (\'Queued\',\'Requeue for Erroneous records\',\'Requeue All\',\'Requeue for Successful records\')';
        Integer pendingTrsCount =  Database.countQuery(strCountQuery);
      if(pendingTrsCount>0 )//&& !getBypassExternalSync()
        {
            APISynchronizationBatch obj = new APISynchronizationBatch(); 
            jobId = System.scheduleBatch(obj,'APISynchronization_Batch_'+currentUserRole+ Math.random()*1000+' - '+Datetime.now(),2,1);
        }
        return jobId;
    }

    /**
    * @description  Sending Email to Batch Owner and other user in CC when Batch Execution Fails[FC-1929]
    * @param  setErroneousAPISyncTrans
    */
    public static void sendEmailOnBatchFail(Set<Id> setErroneousAPISyncTrans)
    {
        String bodyText = '';
        List<String> ccAddresses = new List<String>();
        Set<String> toAddressesSet = new Set<String>(); 
        List<String> toAddresses=new List<String>();
        List<Notify_User__mdt> notifyCCUsers = new List<Notify_User__mdt>([Select MasterLabel, Profiles__c,CC_Emails__c,Send_To_CC_User__c from Notify_User__mdt where MasterLabel =: APISyncFromAPITransaction.API_SYNCHRONIZATION_BATCH ]);
        if(Test.isRunningTest()){
            //notifyCCUsers = new List<Notify_User__mdt>([Select MasterLabel, Profiles__c,CC_Emails__c,Send_To_CC_User__c from Notify_User__mdt]);
            Notify_User__mdt notify = new Notify_User__mdt();
            notify.MasterLabel = 'test';
            notify.Profiles__c = 'System Administrator';
            notifyCCUsers.add(notify);

        }
        if(!notifyCCUsers.isEmpty())
        {
            String toProfiles = notifyCCUsers[0].Profiles__c;
            List<String> lstProfiles = new List<String>();
            if(toProfiles.contains(',')){
                lstProfiles =  toProfiles.trim().split('\\s*,\\s*'); 
            }
            else{
                lstProfiles.add(toProfiles);
            }
            
            List<User> notifyToUser = new List<User>([Select id,Email,Username from user where Profile.Name = :lstProfiles and isActive = true And Id =: userinfo.getUserId()]);

            System.debug(logginglevel.DEBUG, 'notifyToUser ' +notifyToUser);

            for(User toUser : notifyToUser)
            {
                toAddressesSet.add(toUser.Email);
            }
            toAddresses.addAll(toAddressesSet);

            String ccEmails = (notifyCCUsers[0].CC_Emails__c != null && notifyCCUsers[0].Send_To_CC_User__c) ? notifyCCUsers[0].CC_Emails__c : null;
            
            if(ccEmails != null && ccEmails.contains(',')){
                ccAddresses =  ccEmails.trim().split('\\s*,\\s*');
            }
            else if(ccEmails != null)
            {
                ccAddresses.add(ccEmails);
            }
            System.debug(logginglevel.DEBUG, 'ccAddresses ' +ccAddresses); 
          

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            if(!toAddresses.isEmpty())
            {
                mail.setToAddresses(toAddresses);
            }
            if(!ccAddresses.isEmpty())
            {
                mail.setCcAddresses(ccAddresses);
            }
            mail.setSubject(NOTIFICATION_EMAIL_SUBJECT);
            
            bodyText = 'The SF-MYS/ExpoCAD synchronization completed with errors for ';
            if(!setErroneousAPISyncTrans.isEmpty())
            {
                bodyText += ' the following API synchronization transaction Records: <br/><br/>';
                bodyText += 'Link for the list of records: <br/>'; 
                for(Id apiSyncTranErrIds : setErroneousAPISyncTrans)
                {
                    bodyText += URL.getSalesforceBaseUrl().toExternalForm() + '/' + apiSyncTranErrIds + ' <br/>';
                }
                bodyText += ' <br/><br/> Please check the records in the org for detailed errors.';
            }    
            mail.setHtmlBody(bodyText);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail} , false);
        }
    } 
    /**
    * @description  Insert Attachment for Response Body 
    * @param  parentId
    * @param  jsonResponse    
    */
    public static void createResponseAttchment(Id parentId, String jsonResponse)
    {
        Attachment att = new Attachment();
        att.ParentId = parentId;
        att.ContentType = 'text/plain';
        att.Name = 'TextResponse.txt';
        att.Body = Blob.valueof(jsonResponse);
        Database.insert(att, false);
    }

    /**
    * @description  get response String from Response Attachment
    * @param  parentId
    * @return  String jsonResponse
    */
    public static String getBodyFormResponseAttchment(Id parentId)
    {
        string resBody='';
        List<Attachment> listAtts = new List<Attachment>([Select Id,Body from Attachment where ParentId =:parentId limit 1]);
        if(!listAtts.isEmpty())
        {
            resBody = listAtts.get(0).Body.toString();
        }
        return resBody;
    }

   
    /**
    * @description [This method is for getting sub role ids Recursively]
    * @param mapRoles
    * @param roleId
    * @param subRoleIds
    */
    public static void getRolesAndSubordinates(Map<Id,List<Id>> mapRoles, Id roleId, List<Id> subRoleIds){
        if(mapRoles.containsKey(roleId)){
            List<Id> subRoleIds2 = mapRoles.get(roleId);
            subRoleIds.addAll(subRoleIds2);
            for(Id subRoleId : subRoleIds2){
                getRolesAndSubordinates(mapRoles, subRoleId, subRoleIds);
            }
        }
    }
}