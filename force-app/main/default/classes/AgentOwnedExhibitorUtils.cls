/**
 * Created By   :   Girikon(Ashish)
 * Created On   :   Aug 5 2018
 * @description :   [A Utility Class for agents to manage their exhibitors.]
 * Test Class   :   AgentOwnedExhibitorUtils_Test ()
 * Modification Log------
 * Modified by  : ---  [Aishwarya BK-16730 27 July 2021]
 **/
 
public without sharing class AgentOwnedExhibitorUtils
{
    static String eventId; 

    @AuraEnabled //Fetch event details
    public static Event_Settings__c getEventDetails(String sEventcode)
    {        
        return UtilityMethods.getEventDetails(sEventcode);
    }

    @AuraEnabled //Fetch Account Details from id 
    public static Account getAccountDetails(String sAccID)
    {        
        Account acc = new Account();
        if(sAccID != null && string.isNotBlank(sAccID))
        {
            acc= [select name,id from account where id =:sAccID ];
        }
        return acc;
    }
    @AuraEnabled //Fetch AOE Booth from there Account Id And Event Code
    public static list<Opportunity_ExpoCAD_Booth_Mapping__c> getAOEbooths(String accId,String sEventcode) 
    {
        System.debug('sEventcode : '+sEventcode +' accId : '+accId);
        List<opportunity> opp = new List<opportunity>();
        list<Opportunity_ExpoCAD_Booth_Mapping__c> lstOppExpoBoothsMapping=new list<Opportunity_ExpoCAD_Booth_Mapping__c>();
        set<string> quoteIds = new set<string>();
        opp = [select id,Name,SBQQ__PrimaryQuote__c from opportunity where AccountId=:accId AND EventEdition__r.Event_Code__c =: sEventcode AND EventEdition__r.Event_Edition_Status__c ='Confirmed' AND (StageName='Closed Won' OR StageName='Closed Booked') order by createdDate];
               System.debug('opp::::::::' + opp);
        if(!opp.IsEmpty()){
            System.debug('opp' + opp[0]);
            for(opportunity oppty: opp){ if(oppty.SBQQ__PrimaryQuote__c!=null){ quoteIds.add(oppty.SBQQ__PrimaryQuote__c); 
                }
            }
            //Added condition of Related_Opportunity__c and Opportunity__r.User_Type__r.Name for [CCEN-416]
            if(Schema.sObjectType.Opportunity_ExpoCAD_Booth_Mapping__c.isAccessible()){
                lstOppExpoBoothsMapping = [Select Id,Expocad_Booth__c,Booth_Number__c,Expocad_Booth__r.Matched_Product_Name__c, Expocad_Booth__r.Area_Number__c,Expocad_Booth__r.Dimensions__c,Opportunity__r.account.name From Opportunity_ExpoCAD_Booth_Mapping__c where Expocad_Booth__r.Status__c='Rented' and quote__c IN:quoteIds and Status__c = 'Active' and (Opportunity__r.User_Type__r.Name != 'Agent' OR Opportunity__r.Parent_Opportunity__c != null) order by Opportunity__r.createdDate];
            }
        }
        System.debug('lstOppExpoBoothsMapping ========================================================='+lstOppExpoBoothsMapping);
        return lstOppExpoBoothsMapping;
    }

    /**
    * Created By: {Girikon(Abhishek)}
    * Created On: 07/31/2019
    * Description: Fetch all the coexhibitors for current exhibitor and account for agentOwnedExhibitorAccountInfo LWC
    */
    @AuraEnabled
    public static List<Account> getCoexhibitors(String accId, String sEventcode){
        System.debug('CoExhibitor sEventcode : '+sEventcode +' accId : '+accId);
        //Fetch agent owned Exhibitors Opportunity
        List<Opportunity> agentOwnedOpps = new List<Opportunity>();
        agentOwnedOpps = [
            SELECT  Id,
                    Name
            FROM    Opportunity
            WHERE   EventEdition__r.Event_Code__c =: sEventcode AND 
                    EventEdition__r.Event_Edition_Status__c = 'Confirmed' AND 
                    (
                        StageName='Closed Won' OR 
                        StageName='Closed Booked'
                    ) AND
                    Parent_Opportunity__c != NULL AND
                    AccountId =:accId
        ];

        //Fetch agent owned Co-Exhibitors Opportunity
        List<Opportunity> agentOwnedCoExhOpps = new List<Opportunity>();
        agentOwnedCoExhOpps = [
            SELECT  Id,
                    Name,
                    AccountId,
                    Account.Name
            FROM    Opportunity
            WHERE   EventEdition__r.Event_Code__c =: sEventcode AND 
                    EventEdition__r.Event_Edition_Status__c = 'Confirmed' AND 
                    (
                        StageName='Closed Won' OR 
                        StageName='Closed Booked'
                    ) AND
                    Parent_Opportunity__c IN :agentOwnedOpps AND
                    Exhibitor_Paid_By__c='Co-Exhibitor Paid by Exhibitor'
        ];
        
        //Create list of Account for returning data as Community users don't have access to Opportunity Object
        List<Account> agentOwnedCoExhibitors = new List<Account>();
        for(Opportunity opp : agentOwnedCoExhOpps){
            Account coExhAccount = new Account();
            coExhAccount.Id = opp.AccountId; coExhAccount.Name = opp.Account.Name;
            agentOwnedCoExhibitors.add(coExhAccount);
        }
        return agentOwnedCoExhibitors;
    }

    /**
    * Created By: {Girikon(Abhishek)}
    * Created On: 08/02/2019
    * Description: Get Event ID using Event Code for agentOwnedExhibitorAccountInfo LWC
    */
    @AuraEnabled(cacheable=true)
    public static string getEventId(String eventCode)
    {
        if(Schema.sObjectType.Event_Edition__c.isAccessible()){
            List<Event_Edition__c> eventEditions = [SELECT Id FROM Event_Edition__c WHERE Event_Code__c =:eventCode];
            if(eventEditions.size()>=1){
                return String.valueOf(eventEditions[0].Id);
            }
        }
        return Null;
    }

    /**
    * Created By: {Girikon(Abhishek)}
    * Created On: 08/02/2019
    * Description: Get all contacts of an account using AccountId and Event code for agentOwnedExhibitorAccountInfo LWC
    */
    @AuraEnabled
    public static Opportunity getAccccountContacts(String accId, String sEventcode)
    {
        if(String.isBlank(eventId)){
            eventId = getEventId(sEventcode);
        }
        UtilityMethods objUtilityMethods= new UtilityMethods();
        return objUtilityMethods.getAccccountContacts(accId,eventId);   
    }

    /**
    * Created By: {Girikon(Abhishek)}
    * Created On: 08/05/2019
    * Description: Get exhibitor type using AccountId and Event code for agentOwnedExhibitorAccountInfo LWC
    */
    @AuraEnabled(cacheable=true)
    public static string getExhibitorType(String accId, String sEventCode)
    {
        if(String.isBlank(eventId)){
            eventId = getEventId(sEventcode);
        }
        if(String.isNotBlank(accId) && String.isNotBlank(eventId)){
            List<Opportunity> opps = new List<Opportunity>();
            Contact con = [SELECT Id, AccountId FROM Contact WHERE Id in (SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId())];
            //opps = [SELECT User_Type__r.Name, Exhibitor_Paid_By__c,parent_Opportunity__r.Exhibitor_Paid_By__c FROM Opportunity WHERE AccountId=:accId AND EventEdition__c=:eventId AND StageName = 'Closed Won' AND ((parent_Opportunity__r.AccountId=:con.AccountId or parent_Opportunity__r.parent_Opportunity__r.AccountId=:con.AccountId or (Agent_s_Opportunity__r.AccountId =:con.AccountId And parent_Opportunity__c = null)) or ((Exhibitor_Paid_By__c = 'SubAgent Paid By Exhibitor' or Exhibitor_Paid_By__c = 'SubAgent Paid By Subagent'  ) And parent_Opportunity__r.parent_Opportunity__C = null  And parent_Opportunity__r.Agent_s_Opportunity__r.AccountId=:con.AccountId )) AND User_Type__c != Null ORDER BY CreatedDate];
            opps = [SELECT User_Type__r.Name, Exhibitor_Paid_By__c,parent_Opportunity__r.Exhibitor_Paid_By__c FROM Opportunity WHERE AccountId=:accId AND EventEdition__c=:eventId AND StageName = 'Closed Won' AND ((parent_Opportunity__r.AccountId=:con.AccountId or parent_Opportunity__r.parent_Opportunity__r.AccountId=:con.AccountId or (Agent_s_Opportunity__r.AccountId =:con.AccountId And parent_Opportunity__c = null)) or (((Exhibitor_Paid_By__c = 'SubAgent Paid By Exhibitor' or Exhibitor_Paid_By__c = 'SubAgent Paid By Subagent'  ) And parent_Opportunity__r.parent_Opportunity__C = null  And parent_Opportunity__r.Agent_s_Opportunity__r.AccountId=:con.AccountId ) OR (parent_Opportunity__r.parent_Opportunity__r.parent_Opportunity__C = null And parent_Opportunity__r.parent_Opportunity__r.Agent_s_Opportunity__r.AccountId=:con.AccountId)  OR(parent_Opportunity__C = null And parent_Opportunity__r.parent_Opportunity__C = null  And  Agent_s_Opportunity__r.Agent_s_Opportunity__r.AccountId=:con.AccountId))) AND User_Type__c != Null ORDER BY CreatedDate];
            if(!opps.isEmpty()){
                System.debug('opps[0].User_Type__r.Name opps[0].Exhibitor_Paid_By__c    '+opps[0].User_Type__r.Name +','+opps[0].Exhibitor_Paid_By__c);
                return opps[0].User_Type__r.Name +','+opps[0].Exhibitor_Paid_By__c+','+opps[0].parent_Opportunity__r.Exhibitor_Paid_By__c;
            }
        }
        return NULL;
    }

    /**
    * Created By: {Girikon(Abhishek)}
    * Created On: 08/05/2019
    * Description: Last Email sent date for Operations contact for agentOwnedExhibitorAccountInfo LWC
    */
    @AuraEnabled
    public static datetime getLastMailSentDate(String eventCode, String contactId){
        DateTime lastMailSentDate;
        List<ContactEventEditionMapping__c> conEveEdMap = new List<ContactEventEditionMapping__c>();
        if(String.isNotBlank(eventCode) && String.isNotBlank(contactId)){
            if(Schema.sObjectType.ContactEventEditionMapping__c.isAccessible() && Schema.sObjectType.Event_Edition__c.isAccessible()){
                conEveEdMap = [
                    SELECT Email_Sent__c 
                    FROM ContactEventEditionMapping__c 
                    WHERE SFContactID__c=:contactId AND SFEventEditionID__r.Event_Code__c=:eventCode
                ];
            }
        }
        if(!conEveEdMap.isEmpty()){
            lastMailSentDate = conEveEdMap[0].Email_Sent__c;
        }
        return lastMailSentDate;
    }

    /**
    * Created By: {Girikon(Abhishek)}
    * Created On: 08/06/2019
    * Description: Send Welcome mail to contactId provided for agentOwnedExhibitorAccountInfo LWC
    */
    @AuraEnabled
    public static string resendWelcomeMail(String contactId, String eventCode){
        String message;
        if(String.isNotBlank(contactId) && String.isNotBlank(eventCode)){
            if(String.isBlank(eventId)){
                eventId = getEventId(eventCode);
            }
            List<String> contactIds = new List<String>();
            contactIds.add(contactId);
            message = AgentOwnExhibitorsCtrl.sendEmailtoExhibitors(contactIds, eventId);
        } else{
            message = 'Error';
        }
        return message;
    }

    /**
    * Created By: {Girikon(Abhishek)}
    * Created On: 08/06/2019
    * Description: Send Welcome mail to contactId provided for agentOwnedExhibitorAccountInfo LWC
    */
    @AuraEnabled
    public static string getLastLoginDate(Id accountId, String eventCode){
        String message;
        if(String.isNotBlank(accountId) && String.isNotBlank(eventCode)){
            if(String.isBlank(eventId)){
                eventId = getEventId(eventCode);
            }
            Set<Id> accountIds = new Set<Id>();
            accountIds.add(accountId);
            Map<Id, DateTime> loginMap = new Map<Id, DateTime>();
            loginMap = AgentOwnedExhibitorUtils.getlastLoginMap(accountIds, eventCode);
            if(!loginMap.isEmpty()){
                message = String.valueOf(loginMap.get(accountId));
            }
        }
        return message;
    }

    /**
    * Created By: {Girikon(Abhishek)}
    * Created On: 08/07/2019
    * Description: Get form completion status for agentOwnedExhibitorAccountInfo LWC
    */
    @AuraEnabled
    public static CountWraper getFormsStatus(Id accountId, String eventCode){
        CountWraper formsStatus = new CountWraper();
        if(String.isNotBlank(accountId) && String.isNotBlank(eventCode))
        {
            Set<Id> accountIds = new Set<Id>();
            accountIds.add(accountId);
            Map<Id, CountWraper> formStatusMap = AgentOwnedExhibitorUtils.getFormsStatusMap(accountIds, eventCode);
            if(formStatusMap!=Null && !formStatusMap.isEmpty()){
                formsStatus = formStatusMap.get(accountId);
            }
        }
        return formsStatus;
    }

    /**
    * Created By: {Girikon(Abhishek)}
    * Created On: 08/07/2019
    * Description: Get manuals completion status for agentOwnedExhibitorAccountInfo LWC
    */
    @AuraEnabled
    public static CountWraper getManualsStatus(Id accountId, String eventCode){
        CountWraper manualsStatus = new CountWraper();
        if(String.isNotBlank(accountId) && String.isNotBlank(eventCode)){
            Set<Id> accountIds = new Set<Id>();
            accountIds.add(accountId);
            Map<Id, CountWraper> manualsStatusMap = AgentOwnedExhibitorUtils.getManualsStatusMap(accountIds, eventCode);
            if(manualsStatusMap!=Null && !manualsStatusMap.isEmpty()){
                manualsStatus = manualsStatusMap.get(accountId);
            }
        }
        return manualsStatus;
    }

    /**
    * Created By: {Girikon(Abhishek)}
    * Created On: 08/07/2019
    * Description: Get forms and manuals completion status for agentOwnedExhibitorAccountInfo LWC
    */
    @AuraEnabled
    public static AccountInfoDataWrapper getInitialData(String accountId, String eventCode){
        Opportunity accountContacts = AgentOwnedExhibitorUtils.getAccccountContacts(accountId, eventCode);
        CountWraper formsStatus     = AgentOwnedExhibitorUtils.getFormsStatus(accountId, eventCode);
        CountWraper manualsStatus   = AgentOwnedExhibitorUtils.getManualsStatus(accountId, eventCode);
        String exhibitorType        = AgentOwnedExhibitorUtils.getExhibitorType(accountId, eventCode);
        String lastLoginDate        = AgentOwnedExhibitorUtils.getLastLoginDate(accountId, eventCode);
        List<Account> coExhibitors  = AgentOwnedExhibitorUtils.getCoexhibitors(accountId, eventCode);
        List<Opportunity_ExpoCAD_Booth_Mapping__c> eventBooths = AgentOwnedExhibitorUtils.getAOEbooths(accountId, eventCode);
        Map<Id, CountWraper> badges = new Map<Id, CountWraper>();
        Map<Id, String> exhibitorProfileStatus = new Map<Id, String>();
        Map<Id, String> standContractorProfileStatus = new Map<Id, String>();
        String lastMailSentDate;
        if(eventBooths.size()>0){
            Set<Id> boothIds = new Set<Id>();
            for(Opportunity_ExpoCAD_Booth_Mapping__c mapping : eventBooths){ boothIds.add(mapping.Id);
            }
            badges = AgentOwnedExhibitorUtils.getbadgesStatusMap(boothIds, eventCode);
            exhibitorProfileStatus = AgentOwnedExhibitorUtils.getExhibitorProfileStatusMap(boothIds, eventCode);
            standContractorProfileStatus = AgentOwnedExhibitorUtils.getStandContractorStatusMap(boothIds, eventCode);
        }
        if(accountContacts != Null && accountContacts.Operations_Contact__c != Null){
            lastMailSentDate = String.valueOf(AgentOwnedExhibitorUtils.getLastMailSentDate(eventCode, accountContacts.Operations_Contact__c));
        }

        AccountInfoDataWrapper dataWrapper = new AccountInfoDataWrapper();
        dataWrapper.formsStatus = formsStatus;
        dataWrapper.manualsStatus = manualsStatus;
        dataWrapper.exhibitorType = exhibitorType;
        dataWrapper.lastLoginDate = lastLoginDate;
        dataWrapper.lastMailSentDate = lastMailSentDate;
        dataWrapper.accountContacts = accountContacts;
        dataWrapper.coExhibitors = coExhibitors;
        dataWrapper.eventBooths = eventBooths;
        dataWrapper.badges = badges;
        dataWrapper.exhibitorProfileStatus = exhibitorProfileStatus;
        dataWrapper.standContractorProfileStatus = standContractorProfileStatus;
        return dataWrapper;
    }

    // module Specific 
    
    // to get a map of key as Acount Id and value of tatal and complted manuals 
    public static map<Id,CountWraper> getManualsStatusMap(set<Id> accIds,string sEventcode)
    {
        List<User_Manual_Action__c> lstUserManualAction = new  List<User_Manual_Action__c>(); 
        map<Id,CountWraper> manualsStatusMap = new map<Id,CountWraper>();
        if(Schema.sObjectType.User_Manual_Action__c.isAccessible()) 
        {
            //CCEN 795
            lstUserManualAction=[SELECT Is_Viewed__c, Is_Agree__c,Id,Account__c FROM User_Manual_Action__c where Account__c IN : accIds and Manual_Permission__r.Manuals__r.Event_Edition__r.Event_Code__c =: sEventcode AND Manual_Permission__r.Manuals__r.Required__c=true and (User_Type__r.Name='Agent Owned Exhibitor' OR User_Type__r.Name='Exhibitor' OR User_Type__r.Name='Co-Exhibitor')];
            for(Id acc:accIds){                
                manualsStatusMap.put(acc,new CountWraper());
            }
            for(User_Manual_Action__c manualAction:lstUserManualAction){
                CountWraper wrapobj = manualsStatusMap.get(manualAction.Account__c);  wrapobj.total = wrapobj.total+1; 
                if(manualAction.Is_Agree__c && manualAction.Is_Viewed__c){ wrapobj.Completed = wrapobj.Completed+1; 
                }
                ManualsStatusMap.put(manualAction.Account__c,wrapobj);
            }
        }
        return ManualsStatusMap;
    }

    // to get a map of key as Acount Id and value of tatal and complted forms 
    public static map<Id,CountWraper> getFormsStatusMap(set<Id> accIds,string sEventcode)
    {
        List<User_Form_Action__c> lstUserFormAction = new  List<User_Form_Action__c>(); 
        map<Id,CountWraper> formStatusMap = new map<Id,CountWraper>();
        if(Schema.sObjectType.User_Form_Action__c.isAccessible()) 
        {
            lstUserFormAction = [SELECT Id,Account__c,Is_Filled_Up__c, Is_Viewed__c,Form_Permission__r.Event_Edition_Form__r.Name FROM User_Form_Action__c where Account__c IN : accIds  and Form_Permission__r.Event_Edition_Form__r.Event_Edition__r.Event_Code__c=:sEventcode and Form_Permission__r.Event_Edition_Form__r.Mandatory__c = true and (User_Type__r.Name='Agent Owned Exhibitor' OR User_Type__r.Name='Exhibitor' OR User_Type__r.Name='Co-Exhibitor')]; 
                
            for(Id acc:accIds){                
                formStatusMap.put(acc,new CountWraper());
            }
            for(User_Form_Action__c formAction:lstUserFormAction){
                system.debug('formAction__Account'+formAction.Account__c);
                CountWraper wrapobj = formStatusMap.get(formAction.Account__c);                
                wrapobj.total = wrapobj.total+1 ;
                if(formAction.Is_Filled_Up__c){ wrapobj.Completed = wrapobj.Completed+1; 
                }
                formStatusMap.put(formAction.Account__c,wrapobj);
            }
        }
        return formStatusMap;
    }
    // to get a map of key as Acount Id and value last login date for current Event
    public static map<Id,datetime> getlastLoginMap(set<Id> accIds,string sEventcode)
    {
        Map<Id,datetime> maplastLogin = new Map <Id,datetime>();
        list<user> listuser = new list<User>();
        if(Schema.sObjectType.ContactEventEditionMapping__c.isAccessible() && Schema.sObjectType.Event_Edition__c.isAccessible()) {
            listuser = [select id,username,contactId,Contact.AccountId,LastLoginDate from user where contactId in(select SFContactID__c from ContactEventEditionMapping__c Where SFEventEditionID__r.Event_Code__c =:sEventcode And SFContactID__r.AccountId in :accIds) And LastLoginDate != null ORDER BY LastLoginDate DESC ];
        }
        for(Id acc:accIds){            
            maplastLogin.put(acc,null);
        }
        for(user usr : listuser){
            if(usr.LastLoginDate != null ){ maplastLogin.put(usr.Contact.AccountId,usr.LastLoginDate);
            }
        }
        return maplastLogin;
    }

    // to get a map of key as Acount Id and value of tatal and complted Badges
    public static map<Id,CountWraper> getbadgesStatusMap(set<Id> boothIds,string sEventcode)
    {
        Map<Id,CountWraper> mapBadgesStatus = new map<Id,CountWraper>();
        
        List<Opportunity_ExpoCAD_Booth_Mapping__c> listExpoBoothMapping = new List<Opportunity_ExpoCAD_Booth_Mapping__c>();
        list<Event_Settings__c> evntStng = new list<Event_Settings__c>();
        List<Booth_Size_Badge_Limit__c> lstBoothSizeBadgeLimit = new List<Booth_Size_Badge_Limit__c>();
        Map<String,Booth_Size_Badge_Limit__c> mapBoothBadgeRule = new  Map<String,Booth_Size_Badge_Limit__c>();
        Decimal totalCoExhBadgesAllowed = 0;
        Boolean allowByBoothType = false;

        if(Schema.sObjectType.Event_Settings__c.isAccessible())
        {
            evntStng = [select Co_Exhibitor_Badge_Limit__c,Allotment_By_Booth_Type__c from Event_Settings__c where Event_Edition__r.Event_Code__c =: sEventcode];
            
        }        
        
        if(evntStng.size()>0)
        {
            listExpoBoothMapping = [select id,CountBadges__c,Expocad_Booth__r.Area_Number__c,Badge_Limit__c,Expocad_Booth__r.Dimensions__c,Expocad_Booth__r.Matched_Product_Name__c,Opportunity__r.User_Type__r.Name from Opportunity_ExpoCAD_Booth_Mapping__c where id in:boothIds];
            totalCoExhBadgesAllowed = Decimal.valueOf(evntStng[0].Co_Exhibitor_Badge_Limit__c==null?'0':evntStng[0].Co_Exhibitor_Badge_Limit__c);
            allowByBoothType = Boolean.valueOf(evntStng[0].Allotment_By_Booth_Type__c);
        }
            if(Schema.sObjectType.Booth_Size_Badge_Limit__c.isAccessible())
        {
            lstBoothSizeBadgeLimit =[Select Badges_Allowed__c,Match_Product_Entry_Type__c,Badges_Allowed_by_Booth_Type__c,Booth_Size_From__c, Booth_Size_To__c,Booth_Type__c from Booth_Size_Badge_Limit__c where Event_Edition__r.Event_Code__c =:sEventcode]; 
        } 
      
        // Badges Allotment By BoothType Rule 
        if(allowByBoothType){
            for(Booth_Size_Badge_Limit__c badge :lstBoothSizeBadgeLimit){ mapBoothBadgeRule.put(badge.Booth_Type__c,badge);
            }
            for(Opportunity_ExpoCAD_Booth_Mapping__c expoBooth :listExpoBoothMapping){
                //Decimal totalBadgesAllowed = 0;
                CountWraper wrap = new CountWraper();
                wrap.Completed = expoBooth.CountBadges__c;
                if(String.isNotBlank(expoBooth.Expocad_Booth__r.Matched_Product_Name__c) && mapBoothBadgeRule.containsKey(expoBooth.Expocad_Booth__r.Matched_Product_Name__c)){ Booth_Size_Badge_Limit__c badgeObj = mapBoothBadgeRule.get(expoBooth.Expocad_Booth__r.Matched_Product_Name__c);
                    
                    if(expoBooth.Opportunity__r.User_Type__r.Name == 'Co-Exhibitor' || expoBooth.Opportunity__r.User_Type__r.Name =='Co_Exhibitor'){ wrap.total = totalCoExhBadgesAllowed; //incase of Co-Exhibitor badge limit are fatched from event Setting
                    }else{
                        if(badgeObj.Match_Product_Entry_Type__c == 'Fixed'){ wrap.total = badgeObj.Badges_Allowed_by_Booth_Type__c;
                        }
                        else if(badgeObj.Match_Product_Entry_Type__c == 'Formula'){ wrap.total = BadgesUtils.getTotalBadgesByDimension(expoBooth.Expocad_Booth__r.Dimensions__c);                                            
                        }
                    }                        
                    if(expoBooth.Badge_Limit__c>0){  wrap.total= wrap.total + expoBooth.Badge_Limit__c;
                    }
                }
                mapBadgesStatus.put(expoBooth.Id,wrap);     // Puting value in map
            }
        }
        else
        {
            // Badges Allotment By BoothSize Rule   
            for(Opportunity_ExpoCAD_Booth_Mapping__c expoBooth :listExpoBoothMapping)
            {
                CountWraper wrap = new CountWraper();
                wrap.Completed = expoBooth.CountBadges__c;
                system.debug('lstBoothSizeBadgeLimit'+lstBoothSizeBadgeLimit);
                system.debug('lstBoothSizeBadgeLimit'+lstBoothSizeBadgeLimit.size());
                for(Booth_Size_Badge_Limit__c badge :lstBoothSizeBadgeLimit)
                {   if((badge.Booth_Size_From__c <= expoBooth.Expocad_Booth__r.Area_Number__c) && (badge.Booth_Size_To__c >= expoBooth.Expocad_Booth__r.Area_Number__c))
                    {
                        if(expoBooth.Opportunity__r.User_Type__r.Name == 'Co-Exhibitor' || expoBooth.Opportunity__r.User_Type__r.Name =='Co_Exhibitor')
                        {
                            wrap.total = totalCoExhBadgesAllowed; //incase of Co-Exhibitor badge limit are fatched from event Setting
                        }else
                        {
                            wrap.total = badge.Badges_Allowed__c;
                        }                        
                        if(expoBooth.Badge_Limit__c>0) { wrap.total = wrap.total+expoBooth.Badge_Limit__c;
                        }
                    }                      
                }
                mapBadgesStatus.put(expoBooth.Id,wrap);  // Puting value in map
            }
        }     
        return mapBadgesStatus;
    }

    // to get a map of key as Opportunity_ExpoCAD_Booth_Mapping__c Id and value as [Submitted , Not Submitted] for ExhibitorProfile
    public static map<Id,string> getExhibitorProfileStatusMap(set<Id> boothIds,string sEventcode)
    {
        System.debug('boothIds : '+boothIds);
        Map<Id,string> mapExhibitorProfileStatus = new map<Id,String>();
        List<Opportunity_ExpoCAD_Booth_Mapping__c> listExpoBoothMapping = new List<Opportunity_ExpoCAD_Booth_Mapping__c>();
        if(Schema.sObjectType.Opportunity_ExpoCAD_Booth_Mapping__c.isAccessible() && Schema.sObjectType.Customer_Product_Category__c.isAccessible() && Schema.sObjectType.BoothContactInfo__c.isAccessible() && Schema.sObjectType.Event_Edition__c.isAccessible())
        {
            listExpoBoothMapping = [select Id from Opportunity_ExpoCAD_Booth_Mapping__c where id in:boothIds And id not In (select Opp_Booth_Mapping__c from Customer_Product_Category__c where Event_Edition__r.Event_Code__c =: sEventcode) And id not In ( select Opportunity_Booth_Mapping__c from BoothContactInfo__c where IsSubmitted__c = true And Event_Edition__r.Event_Code__c =: sEventcode)];
        }
        for(Id bthId:boothIds)
        {            
            mapExhibitorProfileStatus.put(bthId,'Submitted');
        }
        for(Opportunity_ExpoCAD_Booth_Mapping__c oppBth : listExpoBoothMapping)
        {
            mapExhibitorProfileStatus.put(oppBth.Id,'Not Submitted');
        }
        return mapExhibitorProfileStatus;
    }
    // to get a map of key as Opportunity_ExpoCAD_Booth_Mapping__c Id and value as [Submitted , Not Submitted] for Stand Contractor
    public static map<Id,string> getStandContractorStatusMap(set<Id> boothIds,string sEventcode)
    {
        Map<Id,string> mapStandContractorStatus = new map<Id,String>();

        list<BoothContractorMapping__c> listBoothConMap = new List<BoothContractorMapping__c>();
        if(Schema.sObjectType.BoothContractorMapping__c.isAccessible())
        {
            listBoothConMap = [select id,Opp_Booth_Mapping__c from BoothContractorMapping__c WHERE Opp_Booth_Mapping__c in : boothIds and Event_Edition__r.Event_Code__c =: sEventcode and Opp_Booth_Mapping__r.Opportunity__c != NULL And Opp_Booth_Mapping__r.Expocad_Booth__c != NULL And Opp_Booth_Mapping__r.Status__c = 'Active' And Opp_Booth_Mapping__r.Expocad_Booth__r.status__c = 'Rented' And (Contact__c != NULL AND Approved__c = TRUE)];
        }
        for(Id bthId:boothIds)
        {            
            mapStandContractorStatus.put(bthId,'Not Submitted');
        }
        for(BoothContractorMapping__c bthcm : listBoothConMap){ mapStandContractorStatus.put(bthcm.Opp_Booth_Mapping__c,'Submitted');
        }
        return mapStandContractorStatus;
    }

    // to get a map of key as Contact Id and value Contact EventEdition Mapping
    public static map<Id,ContactEventEditionMapping__c> getWelcomeEmailStatus(set<Id> conIds,string sEventcode)
    {
        map<Id,ContactEventEditionMapping__c> conMap = new map<Id,ContactEventEditionMapping__c>();
        
        for(ContactEventEditionMapping__c ccm : [select id ,Email_Sent__c,IsEmailSent__c,SFContactID__c from ContactEventEditionMapping__c where SFContactID__c in :conIds And SFEventEditionID__r.Event_Code__c =: sEventcode])
        { conMap.put(ccm.SFContactID__c,ccm);}
        return conMap;
    }

      // to get a map of key as Contact Id and User Details
    public static map<Id,User> getContactUserMap(set<Id> conIds)
    {
        System.debug('conIds : ' + JSon.serialize(conIds));
        Map<Id,User> mapContactUser = new Map <Id,User>();
        list<user> listuser = new list<User>();
        
        listuser = [select id,username,contactId,Contact.AccountId,LastLoginDate from user where contactId in:conIds];
        System.debug('listuser' + listuser.size());       
        for(Id con:conIds)
        {            
            mapContactUser.put(con,new user());
        }
        for(user usr : listuser)
        {
            mapContactUser.put(usr.contactId,usr);            
        }
        return mapContactUser;
    }
     /**
    * Created By: {Girikon(Ashish)}
    * Created On: 10/09/2019
    * @description: 
    */
    public static map<Id,boolean> getAgentExhContactMap(set<Id> conIds, String sEventcode)
    {
        List<User> lstUser = new List<User>();
        lstUser = [SELECT Id, Contactid FROM User WHERE Id = : UserInfo.getUserId()];
        Map<Id,boolean> mapAgentExhContact = new Map <Id,boolean>();
        list<AgentExhibitorsContact__c> listAgentExhContact = new list<AgentExhibitorsContact__c>();
        
        if(Schema.sObjectType.AgentExhibitorsContact__c.isAccessible())
        {
            listAgentExhContact = [select Id,ExhibitorContactId__c,IsUserCreated__c from AgentExhibitorsContact__c where AgentContactId__c = :lstUser[0].Contactid and ExhibitorContactId__c in:conIds and EventEdition__r.Event_Code__c =:sEventcode order by createddate desc];
        }
        
        for(AgentExhibitorsContact__c agnExhContact : listAgentExhContact){mapAgentExhContact.put(agnExhContact.ExhibitorContactId__c,agnExhContact.IsUserCreated__c);            
        }
        return mapAgentExhContact;
    }
       /**
    * Created By: {Girikon(Ashish)}
    * Created On: 23/09/2019
    * Description: create Agent EventEdition Maping when Contact EventEdition Maping is inserted [C2E-21]
    */
    public static void createAgentEventEditionMaping(list<ContactEventEditionMapping__c> agentContactEventEditionMapping)
    {
        set<id> agentAccId = new set<id>();
        set<id> eventEdtId = new set<id>();
        list<AgentEventEditionMapping__c> newAgentEventEditionMappingList = new list<AgentEventEditionMapping__c>();
        map<string , AgentEventEditionMapping__c> newAgentEventMap = new map<string , AgentEventEditionMapping__c>();
        system.debug('newAgentEventMap...'+newAgentEventMap.size());
        system.debug('newAgentEventMap'+newAgentEventMap);
        for(ContactEventEditionMapping__c ccem:agentContactEventEditionMapping )
        {
            
            AgentEventEditionMapping__c agentMapObj = new AgentEventEditionMapping__c();
            agentAccId.add(ccem.SFContactID__r.AccountID);
            eventEdtId.add(ccem.SFEventEditionID__c);
            agentMapObj.Account__c = ccem.SFContactID__r.AccountID;
            agentMapObj.EventEdition__c = ccem.SFEventEditionID__c;
            newAgentEventMap.put(string.valueOf(ccem.SFContactID__r.AccountID) +'#'+string.valueOf(ccem.SFEventEditionID__c),agentMapObj);  // to remove dupliacte insert
        }
        for(AgentEventEditionMapping__c agntEem:[select id,Account__c,EventEdition__c from AgentEventEditionMapping__c where EventEdition__c in:eventEdtId And Account__c in:agentAccId And Is_Active__c = true])
        { String key  = string.valueOf(agntEem.Account__c)+'#'+string.valueOf(agntEem.EventEdition__c);
            if(newAgentEventMap.containsKey(key)) { newAgentEventMap.remove(key);
            }
        }
        newAgentEventEditionMappingList =  newAgentEventMap.values();
        // Adding Agent Badge update scenario
        List<Event_Settings__c> listEveSetting = new List<Event_Settings__c>();
        Set<String> eveSettingSet = new Set<String>();
        listEveSetting = [Select Id, Event_Edition__c FROM Event_Settings__c where Event_Edition__c IN:eventEdtId];
        if(!listEveSetting.isEmpty() && listEveSetting.size()>0){
            for(Event_Settings__c eve : listEveSetting){
                eveSettingSet.add(eve.Id);
            }
        }
        if(!newAgentEventEditionMappingList.isEmpty() && Schema.sObjectType.AgentEventEditionMapping__c.isCreateable())
        {
            insert newAgentEventEditionMappingList;
            TrgCommunityUserOpsSetting_Handler.updateAgentBadges(eveSettingSet);
        }
    }
    /**
    * Created By: {Girikon(Ashish)}
    * Created On: 12/07/2019
    * Description: Data Wrapper for Count Report
    */
    public class CountWraper
    {
        @AuraEnabled public decimal total; 
        @AuraEnabled public decimal completed;
        public CountWraper(){ total= 0; completed = 0; }
    }

    /**
    * Created By: {Girikon(Abhishek)}
    * Created On: 08/07/2019
    * Description: Data Wrapper for agentOwnedExhibitorAccountInfo LWC
    */
    public class AccountInfoDataWrapper
    {
        @AuraEnabled public CountWraper formsStatus;
        @AuraEnabled public CountWraper manualsStatus;
        @AuraEnabled public String exhibitorType;
        @AuraEnabled public String lastMailSentDate;
        @AuraEnabled public String lastLoginDate;
        @AuraEnabled public Opportunity accountContacts;
        @AuraEnabled public List<Account> coExhibitors;
        @AuraEnabled public List<Opportunity_ExpoCAD_Booth_Mapping__c> eventBooths;
        @AuraEnabled public Map<Id, CountWraper> badges;
        @AuraEnabled public Map<Id, String> exhibitorProfileStatus;
        @AuraEnabled public Map<Id, String> standContractorProfileStatus;
        public AccountInfoDataWrapper(){
            formsStatus = new CountWraper();
            manualsStatus = new CountWraper();
            exhibitorType = '';
            lastMailSentDate = '';
            lastLoginDate = '';
            accountContacts = new Opportunity();
            coExhibitors = new List<Account>();
            eventBooths = new List<Opportunity_ExpoCAD_Booth_Mapping__c>();
            badges = new Map<Id, CountWraper>();
            exhibitorProfileStatus = new Map<Id, String>();
            standContractorProfileStatus = new Map<Id, String>();
        }
    }
}