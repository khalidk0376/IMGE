/**
* Created By    :  Girikon(Prashant)[CCEN-737]
* Created On    :  March 29 2019
* @description  :  The purpose of this class is to keep common reusable functionalities at single place for Customer Badges.
* Test Class    :  BadgesUtils_Test(91%)
* Modification log --
* Modified By   : Girikon[Prashant C2E-103 (Sept 26 2019)]
**/
public without sharing class BadgesUtils 
{
    public static Set<Id> setBoothIds;
    
    public static void updateBadgeStatus(List<String> idStr,String status)
    {
        List<Exhibitor_Badge__c> ebList = new List<Exhibitor_Badge__c>(); 
        if(Schema.sObjectType.Exhibitor_Badge__c.isAccessible())
        {
            ebList =  [Select id,Status__c from Exhibitor_Badge__c where id In :idStr]; 
        }
        if(ebList.size()>0)
        {
            for(Exhibitor_Badge__c eb : ebList)
            {
                eb.Status__c=status;
            }
            if(Schema.sObjectType.Exhibitor_Badge__c.isUpdateable())
            {
                update ebList;  
            }
        }
    }

    // Changes based on ExpocadBooth replacement with Opportunity_ExpoCAD_Booth_Mapping__c[CCEN-737]
    public static list<Opportunity_ExpoCAD_Booth_Mapping__c> getOppBoothforAccountBadge(String sEventcode,String accId) 
    {
        list<Opportunity_ExpoCAD_Booth_Mapping__c> lstOppExpoBoothsMapping=new list<Opportunity_ExpoCAD_Booth_Mapping__c>();
        set<string> quoteIds = new set<string>();
        List<opportunity> opp = [select id,Name,SBQQ__PrimaryQuote__c from opportunity where AccountId=:accId 
                                 AND EventEdition__r.Event_Code__c =: sEventcode AND EventEdition__r.Event_Edition_Status__c = 'Confirmed' AND (StageName='Closed Won' OR StageName='Closed Booked') order by createdDate];
        if(!opp.IsEmpty())
        {
            for(opportunity oppty: opp)
            {
                if(oppty.SBQQ__PrimaryQuote__c!=null)
                {
                    quoteIds.add(oppty.SBQQ__PrimaryQuote__c); 
                }
            }
            //Added condition of Related_Opportunity__c and Opportunity__r.User_Type__r.Name for [CCEN-416]
            if(Schema.sObjectType.Opportunity_ExpoCAD_Booth_Mapping__c.isAccessible())
            {
                lstOppExpoBoothsMapping = [Select Id,Expocad_Booth__c,Badge_Limit__c,Booth_Number__c,Expocad_Booth__r.Matched_Product_Name__c,CountBadges__c, Expocad_Booth__r.Area_Number__c, Expocad_Booth__r.Unit_Type__c,Expocad_Booth__r.Dimensions__c,Expocad_Booth__r.Open_Corners__c,Expocad_Booth__r.Booth_Product_Type_EE__c,Opportunity__c, Opportunity__r.Name, Opportunity__r.createdDate, Display_Name__c,Opportunity__r.account.name, Status__c From Opportunity_ExpoCAD_Booth_Mapping__c where Expocad_Booth__r.Status__c='Rented' and quote__c IN:quoteIds and Status__c = 'Active' and (Opportunity__r.User_Type__r.Name != 'Agent' OR Opportunity__r.Parent_Opportunity__c != null) order by Opportunity__r.createdDate];                
            }
        }
        System.debug('lstOppExpoBoothsMapping ========================================================='+lstOppExpoBoothsMapping);
        return lstOppExpoBoothsMapping;
    }

    //for calculating L+w/2 of dimension // CCEN-600
    Public static decimal getTotalBadgesByDimension(String dimension)
    {
        decimal totalBadges = 0;
        if(string.isNotBlank(dimension) && !dimension.containsIgnoreCase('Custom'))
        {
            system.debug('@@@');
            String regex = '[a-wA-W]{1,}|\\-';
            String recordNumber = dimension.replaceAll(regex, '');
            list<string> str  = recordNumber.split('x');
            totalBadges =  decimal.valueOf(str[0].trim()) + decimal.valueOf(str[1].trim());
            totalBadges = (totalBadges/2).round(RoundingMode.UP);
            
        }       
        return totalBadges;
    }

    //Added this method to send email notifications to email recipients[CCEN-662]
    public static void sendEmailByCode(string templateCode, String eventId, String accountId)
    {
        List<Messaging.SingleEmailMessage> massEmailLst= new List<Messaging.SingleEmailMessage>();
        List<String> emailAddresses = new List<String>();
        List<Event_Edition_Email_Template__c> eeeTemplateList = new List<Event_Edition_Email_Template__c>();
        if(Schema.sObjectType.Event_Edition_Email_Template__c.isAccessible())
        {
            eeeTemplateList = [Select Id, Name,From_Email_Address__r.Org_Wide_From_Email_Addresses__c, Content__c, Subject__c, Email_Template__c, Event_Edition__c from Event_Edition_Email_Template__c where Event_Edition__c =:eventId AND Email_Template_Code__c =: templateCode];
        }
        String fromAdd;
        string content='';
        string subject='';
        //added this functionality regarding ticket [CCEN-358]
        if(eeeTemplateList!=null && !eeeTemplateList.IsEmpty())
        {
            fromAdd = eeeTemplateList[0].From_Email_Address__r.Org_Wide_From_Email_Addresses__c;   
            content = eeeTemplateList[0].Content__c;
            subject = eeeTemplateList[0].Subject__c;
        }
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =:fromAdd];
        Account acc = new Account();
        if(Schema.sObjectType.Account.isAccessible())
        {   
            acc = [Select id, Name  from Account where id = :accountId limit 1];
        }
        Event_Edition__c evtEdition = new Event_Edition__c();
        
        if(Schema.sObjectType.Event_Edition__c.isAccessible())
        {
           evtEdition = [select Id,Name from Event_Edition__c where id =:eventId limit 1];
        }
        if(acc!=null && evtEdition !=null)
        {
            content = content.replaceAll('\\{Account.Name\\}',acc.name);
            content = content.replaceAll('\\{Event_Edition__c.Name\\}',evtEdition.Name);
            subject = subject.replaceAll('\\{Event_Edition__c.Name\\}',evtEdition.Name);
        }
        Event_Settings__c evntSetting = new Event_Settings__c();
        if(Schema.sObjectType.Event_Settings__c.isAccessible())
        {
            evntSetting=[select id,VIP_badge_notification_recipient__c from Event_Settings__c where Event_Edition__c = :eventId limit 1];
        }
        String emailAddress = evntSetting.VIP_badge_notification_recipient__c;
        if(emailAddress !=  null && emailAddress != ' ')
        {
            emailAddresses = emailAddress.split(',');
        }
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();    
            
            email.setToAddresses(emailAddresses);
            //added this functionality regarding ticket [CCEN-358]
            if(!owea.isEmpty() && owea.size()>0)
            {
              email.setOrgWideEmailAddressId(owea.get(0).Id);
            } 
            email.setSaveAsActivity(false);
            email.setHtmlBody(content);
            email.setSubject(subject);
            // Add emails to list
            massEmailLst.Add(email); 
        
        //Send all emails if list is not empty
        if(massEmailLst!=null && massEmailLst.size()>0)
        {
            Messaging.sendEmail(massEmailLst,false);
        }
    }

    //Created picklist for Booth behalf eventcode and accountid for the ImportExhibitor button for Badges[CCEN-737]
    public List<SelectOption> getBooths(String sEventcode,String accId)
    {
           setBoothIds = new set<Id>();
           List<SelectOption> options = new List<SelectOption>();
           List<Opportunity_ExpoCAD_Booth_Mapping__c> oppExpoMappingDetails= getOppBoothforAccountBadge(sEventcode, accId);
           if(oppExpoMappingDetails != null)
           {
                for(Opportunity_ExpoCAD_Booth_Mapping__c boothDetail : oppExpoMappingDetails)
                {
                    // Added Display Name for CCEN-420 
                    if(!String.isBlank(boothDetail.Display_Name__c))
                    {
                    options.add(new SelectOption(boothDetail.Id,boothDetail.Display_Name__c+' - '+boothDetail.Booth_Number__c +' ('+boothDetail.Expocad_Booth__r.Area_Number__c +' '+boothDetail.Expocad_Booth__r.Unit_Type__c+')'));
                    setBoothIds.add(boothDetail.Id);
                    system.debug('#############IDS'+setBoothIds);
                    }
                    else {
                    options.add(new SelectOption(boothDetail.Id,boothDetail.Opportunity__r.account.name+' '+boothDetail.Booth_Number__c +' ('+boothDetail.Expocad_Booth__r.Area_Number__c +' '+boothDetail.Expocad_Booth__r.Unit_Type__c+')'));
                    setBoothIds.add(boothDetail.Id);
                    }
                }
           }
           return options;
    }

    @AuraEnabled // Save exhibitor badge data changes based on ExpocadBooth replacement with Opportunity_ExpoCAD_Booth_Mapping__c[CCEN-737]
    public static string saveExhibitorBadges(Exhibitor_Badge__c exhBadge, String eventId, String accountId, string fromOpsAdmin)
    { 
        string msg='success';
        string exhBadgeOppExpoId = exhBadge.Opp_Booth_Mapping__c;
        try 
        {
            list<Opportunity_ExpoCAD_Booth_Mapping__c> lstOppExpoMap = new list<Opportunity_ExpoCAD_Booth_Mapping__c>();
            if(Schema.sObjectType.Opportunity_ExpoCAD_Booth_Mapping__c.isAccessible())
            {
                lstOppExpoMap = [Select id, Expocad_Booth__c from Opportunity_ExpoCAD_Booth_Mapping__c where id =:exhBadgeOppExpoId limit 1];
            }
            list<Account> lstAcc = new list<Account>();
            if(Schema.sObjectType.account.isAccessible()) {
                lstAcc=[select id,Name from account where id=:exhBadge.Account__c];
            }
            exhBadge.User_Name__c=UserInfo.getUserId();
            if(lstAcc.size()>0)
            {
                exhBadge.Account_Name__c=lstAcc[0].Name;
            }
            if(Schema.sObjectType.Exhibitor_Badge__c.isCreateable()){
                if(lstOppExpoMap.size()>0 && lstOppExpoMap != null)
                {
                    exhBadge.ExpocadBooth__c = lstOppExpoMap[0].Expocad_Booth__c;
                    exhBadge.Booth_Size__c = lstOppExpoMap[0].Expocad_Booth__c;
                }
                //System.debug('savwe '+exhBadge);
                insert exhBadge;    
            }
            if(exhBadge.Is_VIP__c && fromOpsAdmin != 'OpsAdmin')
            {
                System.debug('savwe Email '+exhBadge.Is_VIP__c);
                sendEmailByCode('VBWR',eventId,accountId);
            }
        }  
        catch (Exception ex) 
        {
            msg=ex.getMessage();
        } 
        return msg;  
    }

    /**
    *   Created By : Girikon(Prashant) 
    *   Created On : Sep 16, 2019
    *   @description : It will be used to save Agent Badges and send email when Vip Badge is created[C2E-103].
    */
    @AuraEnabled
    public static string saveAgentBadges(Agent_Badges__c agnBadge, String eventId, String accountId)
    { 
        string msg='success';
        try 
        {
            if(Schema.sObjectType.Agent_Badges__c.isCreateable()){
                //System.debug('savwe '+exhBadge);
                insert agnBadge;    
            }
            if(agnBadge.Is_VIP__c)
            {
                //System.debug('savwe Email '+agnBadge.Is_VIP__c);
                sendEmailByCode('VBWR',eventId,accountId);
            }
        }  
        catch (Exception ex) 
        {
            msg=ex.getMessage();
        } 
        return msg;  
    }

    /**
    *   Created By : Girikon(Abhishek) 
    *   Created On : Sep 16, 2019
    *   @description : It will be used to get bulk upload template Id
    */
    public static String getMultipleBadgesTemplateId() {
        List<document> listDocumentBadgesCSV = new List<document>();
        String importBadgesCSVFileId = '';
        listDocumentBadgesCSV =[Select Id FROM document where DeveloperName = 'Badge_CSV_File' LIMIT 1];
        if(!listDocumentBadgesCSV.IsEmpty()){
            importBadgesCSVFileId = listDocumentBadgesCSV[0].Id;
        }
        return importBadgesCSVFileId;
    }
    
    /**
    *   Created By : Girikon(Prashant) C2E-103
    *   Created On : Sep 20, 2019
    *   @description : Get current user type from contactEventEditionMapping of login user
    */ 
    @AuraEnabled
    public static ContactEventEditionMapping__c getCurrentUserType(String eventId, String eventCode)
    {   
        list<ContactEventEditionMapping__c> lstconEvnMp = new list<ContactEventEditionMapping__c>();
        ContactEventEditionMapping__c objConEvnMap= new ContactEventEditionMapping__c();
        if(Schema.sObjectType.ContactEventEditionMapping__c.isAccessible())
        {
            lstconEvnMp = [select Id,User_Type__r.Name,SFContactID__r.Account.Name from ContactEventEditionMapping__c where (SFEventEditionID__c =:eventId or SFEventEditionID__r.Event_Code__c =:eventCode) And SFContactID__c in (SELECT Contactid FROM User WHERE Id = : UserInfo.getUserId()) ];
        }
        System.debug('objConEvnMap'+lstconEvnMp);
        if(!lstconEvnMp.isEmpty())
        {  
            objConEvnMap= lstconEvnMp[0];
        }   
        System.debug('objConEvnMap'+objConEvnMap);            
        return objConEvnMap;
    }
    /* 
     * Description: for getting eventId from eventCode and AccountId of current user
     */
    @AuraEnabled 
    public static EventIdAccountIdWrapper getEventIdAccountId(string eventCode){
        system.debug('UserInfo.getUserId()'+UserInfo.getUserId());
        EventIdAccountIdWrapper eiaiw = new EventIdAccountIdWrapper();
        if(eventCode!=null){
            system.debug('UserInfo.getUserId()'+UserInfo.getUserId());
            eiaiw.sAccountId = [Select Id, AccountId from User where Id=:UserInfo.getUserId()].AccountId;
            eiaiw.sEventId = [Select Id from Event_Edition__c where Event_Code__c=:eventCode][0].Id;
        }
        return eiaiw;
    }

    public class EventIdAccountIdWrapper{
        @AuraEnabled
        public string sEventId;
        @AuraEnabled
        public string sAccountId;
    }
}