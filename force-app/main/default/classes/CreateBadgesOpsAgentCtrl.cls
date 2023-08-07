/**
* Created By : Girikon(Abhishek)
* Created On : Sep 16, 2019
* @description : This class is used for the various functionalities at Badges Tab from Customer Centre and Operations Admin 
* Test Class : CreateBadgesOpsAgentCtrl_Test(90% coverage)
* Modification Log -------

* Modified By : Girikon[Prashant C2E-103 (Sept 20 2019)], [Aishwarya BK-9188 13 Oct 2020], [Aishwarya BK-9812 1 Dec 2020]

**/
public without sharing class CreateBadgesOpsAgentCtrl {

    @AuraEnabled//Update Exhibitor Badge
    public static void updateBadgeAllFields(Agent_Badges__c ebObj)
    {
        if(Schema.sObjectType.Agent_Badges__c.isUpdateable())
        {   
            update ebObj;
        }
    }

    @AuraEnabled //Update Exhibitor Badge status
    public static void updateExhibitorBadge(List<String> idStr,String status)
    {
        List<Agent_Badges__c> badges = new List<Agent_Badges__c>();
        if(Schema.sObjectType.Agent_Badges__c.isAccessible())
        {
            badges = [SELECT Id, Status__c 
                      FROM Agent_Badges__c 
                      WHERE Id in : idStr];
        }
        if(badges.size()>0){
            for(Agent_Badges__c badge : badges){
                badge.Status__c = status;
            }
            update badges;
        }
    }
    
    public class AggregateResultResp
    {
        @AuraEnabled public String companyName;
        @AuraEnabled public Integer submitted;
        @AuraEnabled public Integer approved;
        @AuraEnabled public Decimal additionalBadges;
        @AuraEnabled public List<Agent_Badges__c> agentBadgeList;
        @AuraEnabled public String eventEditionMappingId;
        public AggregateResultResp()
        {
            companyName = '';
            eventEditionMappingId = '';
            submitted=0;
            approved=0;
            additionalBadges=0.0;
            agentBadgeList = new List<Agent_Badges__c>();
        }
    }

    @AuraEnabled
    public static AggregateResultResp getBadgesStatusMap(Id accountId, Id eventEditionId){
        AggregateResultResp badgesStatus = new AggregateResultResp();
        if(Schema.sObjectType.AgentEventEditionMapping__c.isAccessible()) {
            List<AgentEventEditionMapping__c> badgesMappingList = new List<AgentEventEditionMapping__c>();
            badgesMappingList = [SELECT Id, Account__r.Name, Badge_Limit__c, ApprovedBadgeCount__c, Total_Badges__c, (Select Id,Account_Name__c,Address__c,Age_Bracket__c,AgentEventEditionMapping__c,City__c,Country__c,Country_Code__c,Email__c,First_Name__c,Is_VIP__c,Job_Title__c,Last_Name__c,Mobile_Number__c,Nationality__c,State__c,Status__c, Matchmaking__c, CreatedBy.Name, CreatedDate from Agent_Badges__r) 
                                 FROM AgentEventEditionMapping__c
                                 WHERE Account__c = :accountId 
                                 AND EventEdition__c = :eventEditionId 
                                 AND Is_Active__c = true];
            if(!badgesMappingList.isEmpty()){
                AgentEventEditionMapping__c badgesMapping = badgesMappingList[0];
                badgesStatus.companyName = badgesMapping.Account__r.Name;
                badgesStatus.submitted = Integer.valueOf(badgesMapping.Total_Badges__c);
                badgesStatus.approved = Integer.valueOf(badgesMapping.ApprovedBadgeCount__c);
                badgesStatus.eventEditionMappingId = badgesMapping.Id;
                badgesStatus.additionalBadges = badgesMapping.Badge_Limit__c;
                badgesStatus.agentBadgeList = badgesMapping.Agent_Badges__r;
            }
        }
        return badgesStatus;
    }

    // Added Method for fetching badges status for Customer Centre [C2E-103]
    @AuraEnabled
    public static AggregateResultResp getBadgesStatusCCMap(Id accountId, Id eventEditionId){
        AggregateResultResp badgesStatus = new AggregateResultResp();
        if(Schema.sObjectType.AgentEventEditionMapping__c.isAccessible()) {
            List<AgentEventEditionMapping__c> badgesMappingList = new List<AgentEventEditionMapping__c>();
            badgesMappingList = [SELECT Id, Account__r.Name, Badge_Limit__c, ApprovedBadgeCount__c, Total_Badges__c, (Select Id,Account_Name__c,Address__c,Age_Bracket__c,AgentEventEditionMapping__c,City__c,Country__c,Country_Code__c,Email__c,First_Name__c,Is_VIP__c,Job_Title__c,Last_Name__c,Mobile_Number__c,Nationality__c,State__c,Status__c,Matchmaking__c, CreatedBy.Name, CreatedDate from Agent_Badges__r where Status__c != 'Rejected')
                                 FROM AgentEventEditionMapping__c 
                                 WHERE Account__c = :accountId 
                                 AND EventEdition__c = :eventEditionId 
                                 AND Is_Active__c = true];
            if(!badgesMappingList.isEmpty()){
                AgentEventEditionMapping__c badgesMapping = badgesMappingList[0];
                badgesStatus.companyName = badgesMapping.Account__r.Name;
                badgesStatus.submitted = Integer.valueOf(badgesMapping.Total_Badges__c);
                badgesStatus.approved = Integer.valueOf(badgesMapping.ApprovedBadgeCount__c);
                badgesStatus.eventEditionMappingId = badgesMapping.Id;
                badgesStatus.additionalBadges = badgesMapping.Badge_Limit__c;
                badgesStatus.agentBadgeList = badgesMapping.Agent_Badges__r;
            }
        }
        return badgesStatus;
    }


    
    @AuraEnabled //fetch picklist values.
    public static List<String> getPicklistValues(String objApi,String fieldName)
    { 
        List<String> lstPickvals=new List<String>();    
        lstPickvals = UtilityMethods.getPicklistValues(objApi,fieldName);
        return lstPickvals;  
    }

    @AuraEnabled //Save Agent badge data
    public static string saveAgentBadge(Agent_Badges__c agentBadge, String eventId, String accountId)
    { 
        string msg='success';
        try
        {
            BadgesUtils.saveAgentBadges(agentBadge, eventId, accountId);
        }
        catch (Exception ex) 
        {
            msg=ex.getMessage();
        } 
        return msg;
    }
    
    @AuraEnabled //update booth badges limit
    public static void increaseBadgeLimit(Integer newLimit, Id eventEditionMappingId){
        if(Schema.sObjectType.AgentEventEditionMapping__c.isAccessible() && Schema.sObjectType.AgentEventEditionMapping__c.isUpdateable()){
            AgentEventEditionMapping__c eventEditionMapping = new AgentEventEditionMapping__c();
            eventEditionMapping.Id = eventEditionMappingId;
            eventEditionMapping.Badge_Limit__c = newLimit;
            update eventEditionMapping;
        }
    }

    @AuraEnabled //Fetch event details [CCEN-642 Added contractor fields]
    public static Event_Settings__c getEventSettings(String eventId)
    {
        List<Event_Settings__c> eventSettings = new List<Event_Settings__c>();
        if(Schema.sObjectType.Event_Settings__c.isAccessible() && eventId != null){
            eventSettings=[
                            SELECT  id,
                                    Show_GoMed2Med_Match_Making_question__c,
                                    Badge_State__c,Approval_Not_Required__c,
                                    On_Off_Badge_Status__c,
                                    Allow_VIP_Badges__c,
                                    Allotment_By_Booth_Type__c,
                                    Allotment_By_Booth_Size__c,
                                    Badge_Nationality__c,
                                    Badge_Mobile_Number__c,
                                    Badge_Last_Name__c,
                                    Badge_Job_Title__c,
                                    Badge_First_Name__c,
                                    Badge_Email__c,
                                    Badge_Country__c,
                                    Company_Name_on_Badge_ToUpperCase__c,
                                    Company_Name_on_Badge_Character_Limit__c,
                                    Badge_City__c,
                                    Badges_Title__c,
                                    Welcome_Text_Badges__c,
                                    Badges_Sub_Title__c,
                                    Badges_Redirect_URL__c,
                                    Badge_Mobile_Character_Limit__c,
                                    Badge_LName_To_UpperCase__c,
                                    Badge_LName_Character_Limit__c,
                                    Badge_JobTitle_Character_Limit__c,
                                    Badge_FName_To_UpperCase__c,
                                    Badge_FName_Character_Limit__c,
                                    Badge_Email_Character_Limit__c,
                                    Badge_Deadline__c,
                                    Badge_City_Character_Limit__c,
                                    Badge_Address_Character_Limit__c,
                                    Badge_Age_Bracket__c,
                                    Badge_Address__c,
                                    Company_Name_on_Badge__c,
                                    Co_Exhibitor_Badge_Limit__c,
                                    Agent_Badge_limit__c,

                                    Badges_MatchMaking__c, Event_uses_GES_Visit_to_manage_badges__c, Button_colors__c,Event_Edition__r.Event_Edition_Code__c   // BK-9188 Added parameters in query

                            FROM    Event_Settings__c 
                            WHERE   Event_Edition__c = :eventId 
                            LIMIT   1
            ];
        }
        if(eventSettings.size()>0){
            return eventSettings[0];
        } else {
            return null;
        }
    }
    
    @AuraEnabled //check if file is added on event setting //BK-9812
    public static Boolean checkFileId(String evntCode){
        Boolean checkIfFile;
        List<ContentDocumentLink> listInformaTemplateByEvent = new List<ContentDocumentLink>();
        List<Event_Settings__c> eventSetting = new List<Event_Settings__c>([Select Id FROM Event_Settings__c Where Event_Edition__r.Event_Code__c =:evntCode AND Event_Edition__r.Event_Edition_Status__c ='Confirmed' LIMIT 1]);
        if(eventSetting.size()>0){
            listInformaTemplateByEvent = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink where LinkedEntityId =:eventSetting[0].Id LIMIT 1];    
        }
        if(!listInformaTemplateByEvent.isEmpty() && listInformaTemplateByEvent.size()>0){
            checkIfFile = true;
        }
        return checkIfFile;
    }
    
    @AuraEnabled //Fetch document ID // CCEN-672
    public static String getDocumentId(String evntCode){
        String docId='';
        List<Event_Settings__c> eventSetting = new List<Event_Settings__c>([Select Id, Allow_VIP_Badges__c ,Badges_MatchMaking__c FROM Event_Settings__c Where Event_Edition__r.Event_Code__c =:evntCode AND Event_Edition__r.Event_Edition_Status__c ='Confirmed' LIMIT 1]);
        List<document> listDocumentBadgesCSV = new List<document>();
        List<document> listDocumentBadgesWithoutVipCSV = new List<document>();
        List<document> listDocumentBadgesWithoutMatchCSV = new List<document>();
        List<document> listDocumentBadgesWithoutVIPandMatchCSV = new List<document>();
        //List<Attachment> listInformaTemplateByEvent = new List<Attachment>();
        List<ContentDocumentLink> listInformaTemplateByEvent = new List<ContentDocumentLink>();
        /**** BK-1820 Start ****/
        if(eventSetting.size()>0)
        {
          //listInformaTemplateByEvent = [Select Id FROM Attachment where ParentId =:eventSetting[0].Id order by createdDate desc LIMIT 1];
          listInformaTemplateByEvent = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink where LinkedEntityId =:eventSetting[0].Id order by ContentDocument.CreatedDate desc LIMIT 1];    
        }
        // Querying on badge template on basis of the VIP badges checkbox from event setting start
        if(!eventSetting.isEmpty() && eventSetting[0].Allow_VIP_Badges__c == True && listInformaTemplateByEvent.size()==0 && eventSetting[0].Badges_MatchMaking__c ==True ){
            listDocumentBadgesCSV =[Select Id from document where DeveloperName = 'Badge_CSV_File' LIMIT 1];
            docId = listDocumentBadgesCSV[0].Id;
        }
        else if(!eventSetting.isEmpty() && eventSetting[0].Allow_VIP_Badges__c == False && listInformaTemplateByEvent.size()==0 && eventSetting[0].Badges_MatchMaking__c==True){
            listDocumentBadgesWithoutVipCSV = [Select Id, Name from document where DeveloperName = 'Badge_CSV_File_Without_VIP' LIMIT 1];
            docId = listDocumentBadgesWithoutVipCSV[0].Id;
        }
        else if(!eventSetting.isEmpty() && eventSetting[0].Allow_VIP_Badges__c == True && listInformaTemplateByEvent.size()==0 && eventSetting[0].Badges_MatchMaking__c==False){
            listDocumentBadgesWithoutMatchCSV = [Select Id, Name from document where DeveloperName = 'Badges_CSV_File_Without_MatchMaking' LIMIT 1];
            docId = listDocumentBadgesWithoutMatchCSV[0].Id;
        }
        else if(listInformaTemplateByEvent.size()>0){
            //docId = listInformaTemplateByEvent[0].Id;
            docId = listInformaTemplateByEvent[0].ContentDocumentId;
        }
        else{
            listDocumentBadgesWithoutVIPandMatchCSV =[Select Id, Name from document where DeveloperName = 'Badge_CSV_File_Without_VIP_Match' LIMIT 1];
            docId= listDocumentBadgesWithoutVIPandMatchCSV[0].Id;            
        }
        /**** BK-1820 End ****/
        return docId;
        // Querying on badge template on basis of the VIP badges checkbox from event setting end
    }
    @AuraEnabled //Fetch Exhibitor Badge
    public static List<Agent_Badges__c> getSingleBadge(String idStr)
    {
        return [Select id,Account_Name__c,Is_VIP__c,First_Name__c,Last_Name__c,Job_Title__c,Address__c,City__c,Country__c,Nationality__c,State__c,Status__c,Age_Bracket__c,Mobile_Number__c,Email__c,Country_Code__c, Matchmaking__c 
                from Agent_Badges__c 
                WHERE Id=:idStr 
                limit 1];
    }
    @AuraEnabled //Delete Exhibitor Badge
    public static void deleteSelectedBadge(String badgeId){        
        List<Agent_Badges__c> badgeToDelete = [Select Id from Agent_Badges__c where Id =:badgeId  LIMIT 1];
        if(!badgeToDelete.IsEmpty() && Schema.sObjectType.Agent_Badges__c.isDeletable()){
            delete badgeToDelete;
        }
    }
    // get current user type from contactEventEiddionMaping of login user [C2E-15]
    @AuraEnabled
    public static ContactEventEditionMapping__c getCurrentUserType(String eventId)
    {   
        list<ContactEventEditionMapping__c> lstconEvnMp = new list<ContactEventEditionMapping__c>();
        ContactEventEditionMapping__c objConEvnMap= new ContactEventEditionMapping__c();
        if(Schema.sObjectType.ContactEventEditionMapping__c.isAccessible())
        {
            lstconEvnMp = [select Id,User_Type__r.Name,SFContactID__r.Account.Name 
                           from ContactEventEditionMapping__c
                           where  (SFEventEditionID__c =:eventId or SFEventEditionID__r.Event_Code__c =:eventId  ) 
                           And SFContactID__c in (SELECT Contactid FROM User WHERE Id = : UserInfo.getUserId()) ];
        }
        
        if(lstconEvnMp.size()>0 )
        {  
            objConEvnMap= lstconEvnMp[0];
        }               
        return objConEvnMap;
    }
}