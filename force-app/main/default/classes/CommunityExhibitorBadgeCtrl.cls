/**
* Created By    :  Girikon(Mukesh,Sunil)[CCEN-533]
* Created On    :  11/29/2018
* @description  :  Allow Community Exhibitor to create the badges on the behalf of exhibitors and increase badge limit. 
* Test Class    :  CommunityExhibitorBadgeCtrl_Test(82%)
* Modified By   : Girikon(Mahesh [CCEN-577 Jan 2 2019],Sunil[CCEN-589 Jan 10 2019, CCEN-642 Jan 29 2019], Aishwarya[CCEN-600 Jan 28 2019], Ashish[CCEN-652 Jan 31 2019], Prashant[CCEN-662 (Feb 14 2019),CCEN-737 (April 2 2019)], Aishwarya[CCEN-672 March 18 2019], Aishwarya[BK-1820 Aug 9 2019],Rajeev[BK-2188 Sep 2 2019], Ashish[C2E-15 Aug 14 2019], Prashant[C2E-102 24th Sept 2019])
                  [Aishwarya BK-9188 13 Oct 2020], [Aishwarya BK-9812 1 Dec 2020]

**/
public without sharing class CommunityExhibitorBadgeCtrl 
{   
    @AuraEnabled//Update Exhibitor Badge status
    public static void updateExhibitorBadge(List<String> idStr,String status)
    {
        BadgesUtils.updateBadgeStatus(idStr, status);
    } 
    
    @AuraEnabled//Update Exhibitor Badge
    public static void updateBadgeAllFields(Exhibitor_Badge__c ebObj)
    {
        if(Schema.sObjectType.Exhibitor_Badge__c.isUpdateable()){
            update ebObj;
        }
    }
    
    @AuraEnabled //Fetch Exhibitor Badge
    public static List<Exhibitor_Badge__c> getSingleBadge(String idStr)
    {
        return [Select id,Account__c,MatchMaking__c,Is_VIP__c,Account__r.Name,Exhibitor_Name__c,First_Name__c,Last_Name__c,Job_Title__c,Address__c,City__c,Country__c,Nationality__c,State__c,Status__c,Age_Bracket__c,Mobile_Number__c,Email__c,Country_Code__c from Exhibitor_Badge__c WHERE Id=:idStr limit 1];
    }
    
    public class AggregateResultResp
    {
        @AuraEnabled public String companyName;
        @AuraEnabled public Integer submitted;
        @AuraEnabled public Integer approved;
        @AuraEnabled public Decimal totalBadgesAllowed;
        @AuraEnabled public List<Exhibitor_Badge__c> exhibitorBadgeList;
        @AuraEnabled public boolean isVipAllowed; 
        public AggregateResultResp()
        {
            companyName = '';
            submitted=0;
            approved=0;
            totalBadgesAllowed=0.0;
            exhibitorBadgeList = new List<Exhibitor_Badge__c>();
        }
    }
    
    @AuraEnabled //get booths on the basis of Opportunity_ExpoCAD_Booth_Mapping__c custom object[CCEN-737]
    public static AggregateResultResp getBoothAggregate(String eventCode, String accountId,List<String> boothIds)
    {
        AggregateResultResp objSummaryClass= new AggregateResultResp();        
        Decimal totalBadgesAllowed = 0;
        Event_Settings__c eventStng = new Event_Settings__c();
        if(Schema.sObjectType.Event_Settings__c.isAccessible())
        {
            eventStng =  [select id , Allow_VIP_Badges__c from  Event_Settings__c where Event_Edition__r.Event_Code__c=:eventCode LIMIT 1];
        }
        //vipAllowedForEvent = eventStng.Allow_VIP_Badges__c;
        //AND Quote__r.SBQQ__Opportunity2__r.Account.Name='Sachin Exhibitor Test Account INC' Quote__r.SBQQ__Primary__c=true AND
        Set<String> idSet = new Set<String>();
        AggregateResult []listExpoBoothMapping = new list<AggregateResult>();
        
        if(Schema.sObjectType.Opportunity_ExpoCAD_Booth_Mapping__c.isAccessible())
        {
            listExpoBoothMapping = [SELECT Quote__r.SBQQ__Account__r.Name, SUM(CountBadges__c),SUM(ExhibitorBadgesApproved__c) FROM Opportunity_ExpoCAD_Booth_Mapping__c 
                                    WHERE Id IN:boothIds AND Quote__r.SBQQ__Account__c=:accountId AND Status__c ='Active'
                                    GROUP BY Quote__r.SBQQ__Account__c,Quote__r.SBQQ__Account__r.Name,Quote__r.SBQQ__Account__r.Id LIMIT 1];
        }
        
        
        if(listExpoBoothMapping.size()> 0)
        {
            for(AggregateResult ar : listExpoBoothMapping)
            {
                objSummaryClass.companyName = String.valueOf(ar.get('Name'));
                objSummaryClass.submitted = Integer.valueOf(ar.get('expr0'));
                objSummaryClass.approved = Integer.valueOf(ar.get('expr1'));
            }
        }
        
        list<Opportunity_ExpoCAD_Booth_Mapping__c> expoBoothMapList=new list<Opportunity_ExpoCAD_Booth_Mapping__c>();
        expoBoothMapList= BadgesUtils.getOppBoothforAccountBadge(eventCode,accountId);
        
        List<Booth_Size_Badge_Limit__c> lstBoothSizeBadgeLimit = new List<Booth_Size_Badge_Limit__c>();
        
        if(Schema.sObjectType.Booth_Size_Badge_Limit__c.isAccessible())
        {
            lstBoothSizeBadgeLimit =[Select Badges_Allowed__c, Booth_Size_From__c, Booth_Size_To__c from Booth_Size_Badge_Limit__c where Event_Edition__r.Event_Code__c =:eventCode];
        }
        
        if(lstBoothSizeBadgeLimit.size()> 0)
        {
            for(Booth_Size_Badge_Limit__c badge :lstBoothSizeBadgeLimit)
            {
                for(Opportunity_ExpoCAD_Booth_Mapping__c expoBoothMap :expoBoothMapList)
                {
                    idSet.add(expoBoothMap.Id);
                    if((badge.Booth_Size_From__c <= expoBoothMap.Expocad_Booth__r.Area_Number__c) && (badge.Booth_Size_To__c >= expoBoothMap.Expocad_Booth__r.Area_Number__c))
                    {
                        totalBadgesAllowed = totalBadgesAllowed + badge.Badges_Allowed__c;
                        totalBadgesAllowed=totalBadgesAllowed + (expoBoothMap.Badge_Limit__c == null?0:expoBoothMap.Badge_Limit__c); 
                        system.debug('aggregatetotalBadgesAllowed'+totalBadgesAllowed);
                    }
                }
            }
        }
        
        objSummaryClass.totalBadgesAllowed =totalBadgesAllowed; 
        objSummaryClass.isVipAllowed= eventStng.Allow_VIP_Badges__c;
        //[CCEN-149] : Added field "Agent__c" in Query below
        //[CCEN-589 Jan 10 2019]
        // Added new field CreatedBy.ContactId for[C2E-102]
        objSummaryClass.exhibitorBadgeList = [Select Id,Opp_Booth_Mapping__c,Opp_Booth_Mapping__r.Booth_Number__c,Is_VIP__c,Opp_Booth_Mapping__r.Area__c,Exhibitor_Name__c,Account__r.Name,First_Name__c,Last_Name__c,Job_Title__c,Address__c,City__c,tolabel(Country__c),Nationality__c,CreatedBy.Name, CreatedBy.ContactId,CreatedDate,State__c,Status__c,Age_Bracket__c,Mobile_Number__c,Email__c,Country_Code__c,Agent__c  from Exhibitor_Badge__c WHERE Opp_Booth_Mapping__c In:boothIds and Account__c!=null and Status__c!='Rejected' order by createddate desc];
        
        return objSummaryClass;
    }
    
    @AuraEnabled //Fetch Booth Size Limit
    public static list<Booth_Size_Badge_Limit__c> getBoothSizeLimit(String eventId)
    {
        Event_Settings__c eventForBooth = getEventSettings(eventId);
        list<Booth_Size_Badge_Limit__c> lstBoothSize = new list<Booth_Size_Badge_Limit__c>();
        if(eventForBooth.Allotment_By_Booth_Type__c==true && Schema.sObjectType.Booth_Size_Badge_Limit__c.isAccessible())
        {
            lstBoothSize=[select id ,Booth_Type__c,Badges_Allowed_by_Booth_Type__c ,Match_Product_Entry_Type__c,CheckBadgesAllotmentByBoothType__c from Booth_Size_Badge_Limit__c where Event_Edition__c=:eventId and Booth_Type__c!=null];
        }
        if((eventForBooth.Allotment_By_Booth_Size__c==true) ||((eventForBooth.Allotment_By_Booth_Size__c==false)&&(eventForBooth.Allotment_By_Booth_Type__c==false)))
        {
            lstBoothSize = [select id,Badges_Allowed__c,Booth_Size_From__c,Booth_Size_To__c,Event_Edition__c,Match_Product_Entry_Type__c,CheckBadgesAllotmentByBoothType__c from Booth_Size_Badge_Limit__c where Event_Edition__c=:eventId and Booth_Size_From__c!=null and Booth_Size_To__c!=null];
        }
        return lstBoothSize; 
    }
    
    @AuraEnabled //Fetch Booths on the basis of Opportunity_ExpoCAD_Booth_Mapping__c custom object[CCEN-737]
    public static list<boothSummaryWrpClass> getBooths(String eventCode, string accId)
    {
        list<boothSummaryWrpClass> objBoothSummaryWrpClass = new list<boothSummaryWrpClass>();
        list<Opportunity_ExpoCAD_Booth_Mapping__c> lstOppExpoBoothsMapping=new list<Opportunity_ExpoCAD_Booth_Mapping__c>();
        lstOppExpoBoothsMapping= BadgesUtils.getOppBoothforAccountBadge(eventCode,accId);
        
        
        map<decimal,decimal> mapArea= new  map<decimal,decimal>();
        List<Booth_Size_Badge_Limit__c> lstBoothSizeBadgeLimit = new List<Booth_Size_Badge_Limit__c>();
        lstBoothSizeBadgeLimit =[Select Badges_Allowed__c, Booth_Size_From__c, Booth_Size_To__c from Booth_Size_Badge_Limit__c where Event_Edition__r.Event_Code__c =:eventCode]; 
        if(lstBoothSizeBadgeLimit.size()> 0)
        {
            for(Booth_Size_Badge_Limit__c badge :lstBoothSizeBadgeLimit){
                for(Opportunity_ExpoCAD_Booth_Mapping__c oppExpoBoothMap :lstOppExpoBoothsMapping){
                    if((badge.Booth_Size_From__c <= oppExpoBoothMap.Expocad_Booth__r.Area_Number__c) && (badge.Booth_Size_To__c >= oppExpoBoothMap.Expocad_Booth__r.Area_Number__c)){
                        mapArea.put(oppExpoBoothMap.Expocad_Booth__r.Area_Number__c, badge.Badges_Allowed__c);
                    }
                }
            }
        }
        
        for(Opportunity_ExpoCAD_Booth_Mapping__c oppExpoBoothMap :lstOppExpoBoothsMapping)
        {
            boothSummaryWrpClass newWrapper = new boothSummaryWrpClass();
            newWrapper.id=oppExpoBoothMap.Id;
            newWrapper.boothNumber = oppExpoBoothMap.Booth_Number__c;
            // updated as pre CCEN 420
            if (!String.isBlank(oppExpoBoothMap.Display_Name__c))
            {                    
                newWrapper.displayName = oppExpoBoothMap.Display_Name__c;
            }
            else
            {
                newWrapper.displayName = oppExpoBoothMap.Opportunity__r.account.name;
            }
            
            newWrapper.totArea=oppExpoBoothMap.Expocad_Booth__r.Area_Number__c;
            newWrapper.unitType=oppExpoBoothMap.Expocad_Booth__r.Unit_Type__c;
            newWrapper.dimensions=oppExpoBoothMap.Expocad_Booth__r.Dimensions__c;
            newWrapper.badgeLimit=oppExpoBoothMap.Badge_Limit__c;
            if(mapArea.containskey(oppExpoBoothMap.Expocad_Booth__r.Area_Number__c))
            {
                newWrapper.totBadgesAllotment= mapArea.get(oppExpoBoothMap.Expocad_Booth__r.Area_Number__c);
            }
            else
            {
                newWrapper.totBadgesAllotment= 0;
            }
            
            objBoothSummaryWrpClass.add(newWrapper);
            System.debug('objBoothSummaryWrpClass ' +objBoothSummaryWrpClass);
        }
        return objBoothSummaryWrpClass; 
    }
    
    @AuraEnabled //Fetch Booth Summary
    public static boothSummaryWrpClass getBoothSummary(String eventCode, list<string> boothIds,string eventId)
    {
        boothSummaryWrpClass objSummaryClass= new boothSummaryWrpClass();
        Decimal totalBadgesUsed = 0;
        Decimal totalArea = 0;
        Decimal totalBadgesRemaining = 0; 
        Decimal totalBadgesAllowed = 0;
        String initialAllBoothDisplay ='';
        Decimal badgeLimitAll = 0;
        String uType;        
        List<Opportunity_ExpoCAD_Booth_Mapping__c> listExpocadBoothMapping = new List<Opportunity_ExpoCAD_Booth_Mapping__c>();
        if(Schema.sObjectType.Opportunity_ExpoCAD_Booth_Mapping__c.isAccessible() ) 
        {
            listExpocadBoothMapping = [Select Account__r.Name ,Expocad_Booth__r.Area_Number__c,Expocad_Booth__r.Unit_Type__c,Opportunity__r.User_Type__r.Name, CountBadges__c,Expocad_Booth__r.Matched_Product_Name__c,Event_Code__c,Badge_Limit__c ,Expocad_Booth__r.Dimensions__c from Opportunity_ExpoCAD_Booth_Mapping__c where Expocad_Booth__r.Status__c='Rented' and Status__c = 'Active' AND Id IN:boothIds];
        }
        List<decimal> listAreas = new List<decimal>();
        if(listExpocadBoothMapping.size()> 0) 
        {
            objSummaryClass.accountName=listExpocadBoothMapping[0].Account__r.Name;
            objSummaryClass.unitType=listExpocadBoothMapping[0].Expocad_Booth__r.Unit_Type__c;
            for(Opportunity_ExpoCAD_Booth_Mapping__c boothMap :listExpocadBoothMapping)
            {
                totalBadgesUsed = totalBadgesUsed + boothMap.CountBadges__c;
                if(boothMap.Expocad_Booth__r.Area_Number__c != null)
                {
                    totalArea = totalArea + boothMap.Expocad_Booth__r.Area_Number__c;
                    listAreas.add(boothMap.Expocad_Booth__r.Area_Number__c);
                    badgeLimitAll = badgeLimitAll + (boothMap.Badge_Limit__c == null?0:boothMap.Badge_Limit__c);
                }
            }
        }
        
        List<Booth_Size_Badge_Limit__c> lstBoothSizeBadgeLimit = new List<Booth_Size_Badge_Limit__c>();
        
        Event_Settings__c eventForBooth = getEventSettings(eventId);
        // //Fixed badge limit if user type is co-exhibitor [CCEN-533] 
        // uType= getCurrentUserType(eventId).User_Type__r.Name; 
        // if(uType=='Co-Exhibitor' || uType=='Co_Exhibitor')
        // {
        //     Event_Settings__c eventSettings = getEventSettings(eventId);
        //     totalBadgesAllowed = Decimal.valueOf(eventSettings.Co_Exhibitor_Badge_Limit__c==null?'0':eventSettings.Co_Exhibitor_Badge_Limit__c)+badgeLimitAll;  
        // }        //CCEN-600
        if(eventForBooth.Allotment_By_Booth_Type__c)
        { 
            lstBoothSizeBadgeLimit =[Select Badges_Allowed__c,Booth_Type__c, Booth_Size_From__c, Booth_Size_To__c,Match_Product_Entry_Type__c,Badges_Allowed_by_Booth_Type__c from Booth_Size_Badge_Limit__c where Event_Edition__r.Event_Code__c =:eventCode and Booth_Type__c!=null];
            if(lstBoothSizeBadgeLimit.size()>0)
            {
                for(Booth_Size_Badge_Limit__c boothProductType :lstBoothSizeBadgeLimit)
                {
                    for(Opportunity_ExpoCAD_Booth_Mapping__c expocadBoothMapping :listExpocadBoothMapping)
                    {
                        if(expocadBoothMapping.Opportunity__r.User_Type__r.Name =='Co-Exhibitor' || expocadBoothMapping.Opportunity__r.User_Type__r.Name =='Co_Exhibitor') // C2E-15
                        {
                            totalBadgesAllowed = Decimal.valueOf(eventForBooth.Co_Exhibitor_Badge_Limit__c==null?'0':eventForBooth.Co_Exhibitor_Badge_Limit__c)+badgeLimitAll;  
                        }
                        else if((boothProductType.Match_Product_Entry_Type__c!=null) && (boothProductType.Booth_Type__c == expocadBoothMapping.Expocad_Booth__r.Matched_Product_Name__c))
                        {
                            if(boothProductType.Match_Product_Entry_Type__c=='Fixed')
                            {
                                totalBadgesAllowed = totalBadgesAllowed +  (boothProductType.Badges_Allowed_by_Booth_Type__c!=null?boothProductType.Badges_Allowed_by_Booth_Type__c:0); 
                            }
                            if(boothProductType.Match_Product_Entry_Type__c=='Formula')
                            {
                                totalBadgesAllowed = totalBadgesAllowed + (BadgesUtils.getTotalBadgesByDimension(expocadBoothMapping.Expocad_Booth__r.Dimensions__c));
                            }
                            if(expocadBoothMapping.Badge_Limit__c!=null) 
                            {
                                totalBadgesAllowed = totalBadgesAllowed + expocadBoothMapping.Badge_Limit__c;
                            }
                        }
                    }
                }
            }
        } 
        else
        {
            lstBoothSizeBadgeLimit =[Select Badges_Allowed__c, Booth_Size_From__c, Booth_Size_To__c, Match_Product_Entry_Type__c from Booth_Size_Badge_Limit__c where Event_Edition__r.Event_Code__c =:eventCode and Booth_Size_From__c!=null and Booth_Size_To__c!=null and Badges_Allowed__c!=null];
            if(lstBoothSizeBadgeLimit.size()>0)
            {
                for(Booth_Size_Badge_Limit__c badge :lstBoothSizeBadgeLimit)
                {
                    for(Opportunity_ExpoCAD_Booth_Mapping__c expoBoothMap :listExpocadBoothMapping)
                    {
                        if(expoBoothMap.Opportunity__r.User_Type__r.Name =='Co-Exhibitor' || expoBoothMap.Opportunity__r.User_Type__r.Name =='Co_Exhibitor') // C2E-15
                        {
                            totalBadgesAllowed = Decimal.valueOf(eventForBooth.Co_Exhibitor_Badge_Limit__c==null?'0':eventForBooth.Co_Exhibitor_Badge_Limit__c)+badgeLimitAll;  
                        }
                        else if((badge.Booth_Size_From__c <= expoBoothMap.Expocad_Booth__r.Area_Number__c) && (badge.Booth_Size_To__c >= expoBoothMap.Expocad_Booth__r.Area_Number__c))
                        { 
                            totalBadgesAllowed = totalBadgesAllowed + badge.Badges_Allowed__c;
                            if(expoBoothMap.Badge_Limit__c>0)
                            {
                                totalBadgesAllowed=totalBadgesAllowed+expoBoothMap.Badge_Limit__c;
                            }
                        }  
                    }
                }
            }
        }
        
        totalBadgesRemaining = totalBadgesAllowed - totalBadgesUsed;
        objSummaryClass.totBadgesUsed=totalBadgesUsed;
        objSummaryClass.totArea=totalArea;
        objSummaryClass.totBadgesAllotment=totalBadgesAllowed; 
        objSummaryClass.totBadgesRemaining=totalBadgesRemaining;
        return objSummaryClass;
    }
    
    public class boothSummaryWrpClass
    { 
        @AuraEnabled public Decimal totBadgesUsed; 
        @AuraEnabled public Decimal totArea;
        @AuraEnabled public Decimal totBadgesAllotment;
        @AuraEnabled public Decimal badgeLimit;
        @AuraEnabled public Decimal totBadgesRemaining;
        @AuraEnabled public String accountName;
        @AuraEnabled public String boothNumber;  
        @AuraEnabled public String displayName;  
        @AuraEnabled public String unitType; 
        @AuraEnabled public String id; 
        @AuraEnabled public String dimensions; 
        @AuraEnabled public Boolean userType;
        
    }
    
    @AuraEnabled //fetch picklist values.
    public static List<String> getPicklistValues(String objApi,String fieldName)
    { 
        List<String> lstPickvals=new List<String>();    
        lstPickvals = UtilityMethods.getPicklistValues(objApi,fieldName);
        return lstPickvals;  
    }
    
    @AuraEnabled //Save exhibitor badge data
    public static string saveExhibitorBadge(Exhibitor_Badge__c exhBadge, String eventId, String accountId)
    { 
        string msg='success';
        try
        {
            string fromOpsAdmin = '';
            BadgesUtils.saveExhibitorBadges(exhBadge, eventId, accountId, fromOpsAdmin);
        }
        catch (Exception ex) 
        {
            msg=ex.getMessage();
        } 
        return msg;
    }
    // Added a field On_Off_Badge_Status__c for Ops Admin setting regarding Tikcet[CCEN-577]
    @AuraEnabled //Fetch event details
    public static Event_Settings__c getEventSettings(String eventId)
    {
        Event_Settings__c eventSetting = new Event_Settings__c();
        if(Schema.sObjectType.Event_Settings__c.isAccessible())
        {
            system.debug('dasd'+eventId); //BK-9188 Added parameters in query
            eventSetting=[select id,Show_GoMed2Med_Match_Making_question__c,Allotment_By_Booth_Size__c,Allow_VIP_Badges__c,Allotment_By_Booth_Type__c,Welcome_Text_Badges__c,Badge_State__c,Badge_Nationality__c,Badge_Mobile_Number__c,Badge_Last_Name__c,Badge_Job_Title__c,Badge_First_Name__c,Badge_Email__c,Badge_Country__c,Approval_Not_Required__c,On_Off_Badge_Status__c,Company_Name_on_Badge_ToUpperCase__c,Company_Name_on_Badge_Character_Limit__c,

                          Badge_City__c,Badges_Title__c,Badges_Sub_Title__c,Badges_Redirect_URL__c,Badge_Mobile_Character_Limit__c,Badge_LName_To_UpperCase__c,Badge_LName_Character_Limit__c,Badge_JobTitle_Character_Limit__c,Badge_FName_To_UpperCase__c,Badge_FName_Character_Limit__c,Badge_Email_Character_Limit__c,Badge_Deadline__c,Badge_City_Character_Limit__c,Badge_Address_Character_Limit__c,Badge_Age_Bracket__c,Badge_Address__c,Company_Name_on_Badge__c,Co_Exhibitor_Badge_Limit__c, Badges_MatchMaking__c, Event_uses_GES_Visit_to_manage_badges__c, Event_Edition__r.Name, Event_Edition__r.Event_Edition_Code__c FROM Event_Settings__c where  Event_Edition__c =:eventId or Event_Edition__r.Event_Code__c =:eventId  limit 1];

        }
        system.debug('country'+eventSetting.Badge_Country__c);
        return eventSetting;
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
    
    @AuraEnabled //Fetch document // CCEN-672
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
        if(eventSetting.size()>0){
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
    
    @AuraEnabled //Delete Exhibitor Badge
    public static void deleteSelectedBadge(String badgeId){        
        List<Exhibitor_Badge__c> badgeToDelete = [Select Id from Exhibitor_Badge__c where Id =:badgeId  LIMIT 1];
        if(!badgeToDelete.IsEmpty() && Schema.sObjectType.Exhibitor_Badge__c.isDeletable()){
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
            lstconEvnMp = [select Id,User_Type__r.Name,SFContactID__r.Account.Name from ContactEventEditionMapping__c where  (SFEventEditionID__c =:eventId or SFEventEditionID__r.Event_Code__c =:eventId  )  And SFContactID__c in (SELECT Contactid FROM User WHERE Id = : UserInfo.getUserId()) ];
        }
        
        if(lstconEvnMp.size()>0 )
        {  
            objConEvnMap= lstconEvnMp[0];
        }               
        return objConEvnMap;
    }
    
    /* commented as per ticket BK-2895
    //Changes Regarding Ticket No.BK-2188
    @AuraEnabled
    public Static List<GoMed2Med__c> medDetail(String eventId , String accountId)
    {
       List<GoMed2Med__c> goMed2MedMapng = new List<GoMed2Med__c>(); 
        if(Schema.sObjectType.GoMed2Med__c.isAccessible())
        {
          goMed2MedMapng = [select Id, Badge_Form__c, LastModifiedByCC__c, Contact__c FROM GoMed2Med__c where Event_Edition__c=:eventId AND Account__c=:accountId LIMIT 1];
        }
        return goMed2MedMapng;
    }
    //Changes Regarding Ticket No.BK-2188
    @AuraEnabled
    public static List<GoMed2Med__c> med2MedMatching(string medValues, String AccountID ,String eventId ,Datetime lastModifiedDate)
    {
        List<GoMed2Med__c> goMed2MedMapng = new List<GoMed2Med__c>();
        list<Event_Edition__c> evntCode = new List<Event_Edition__c>();
        List<User> users = new List<User>();
        String userName = UserInfo.getUserId();
        if(Schema.sObjectType.Event_Edition__c.isAccessible())
        {
            evntCode=[select Id, Event_Code__c FROM Event_Edition__c where id=:eventId LIMIT 1];
        }
        users=[Select Id, ContactId from User where id =: userName];
        system.debug('users'+users[0].ContactId);
        goMed2MedMapng = [select Id, Badge_Form__c, LastModifiedByCC__c, Contact__c FROM GoMed2Med__c where Event_Edition__c=:eventId AND Account__c=:AccountID AND Event_Code__c=:evntCode[0].Event_Code__c LIMIT 1];
        if(goMed2MedMapng.isEmpty())
        {
            if(Schema.sObjectType.GoMed2Med__c.isCreateable()){
                GoMed2Med__c goMed = new GoMed2Med__c();
                goMed.Event_Edition__c=eventId;
                goMed.Account__c=AccountID;
                goMed.Event_Code__c=evntCode[0].Event_Code__c;
                goMed.Badge_Form__c=medValues;
                goMed.LastModifiedByCC__c=lastModifiedDate; 
                goMed.Contact__c=users[0].ContactId;
                //system.debug('goMed2MedMapng'+goMed2MedMapng); 
                insert goMed ;
                goMed2MedMapng.add(goMed);
            }
        }
        else
        {
            if(Schema.sObjectType.GoMed2Med__c.isUpdateable()){
                goMed2MedMapng[0].Badge_Form__c=medValues;
                goMed2MedMapng[0].LastModifiedByCC__c=lastModifiedDate;  
                goMed2MedMapng[0].Contact__c=users[0].ContactId;
                update goMed2MedMapng;
            }
        }
        system.debug('goMed2MedMapng'+goMed2MedMapng);
        return goMed2MedMapng; 
    }
    */
    
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
    
    @AuraEnabled
    public static List<Exhibitor_Badge__c> fetchLastModifiedofUser(String accountId, String eventId, String expoId)
    {
        List<Exhibitor_Badge__c> getExhibitorBadges = new List<Exhibitor_Badge__c>();
        if(Schema.sObjectType.Exhibitor_Badge__c.isAccessible())
        {
            getExhibitorBadges = [SELECT Id,Account__c,User_Name__c,Event_Edition__c,Opp_Booth_Mapping__c, LastModifiedBy.Name, LastModifiedBy.Id, LastModifiedBy.Profile.Name, LastModifiedDate FROM Exhibitor_Badge__c WHERE Account__c=:accountId  AND Event_Edition__c=:eventId AND Opp_Booth_Mapping__c=:expoId order by CreatedDate DESC limit 1 ];
        }

        return getExhibitorBadges;  
    }
    
    public class EventIdAccountIdWrapper{
        @AuraEnabled
        public string sEventId;
        @AuraEnabled
        public string sAccountId;
    }
}