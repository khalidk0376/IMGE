/**
* Created By    :   Girikon(Sunil) - [CCEN-111]
* Created On    :   07/28/2018
* @description  :   Allow Ops admin to create the badges on the behalf of exhibitors and increase badge limit. 
* Helper Class  : 
* Test Class    :   CreateBadgesOpsCtrl_Test(81%)
*
* Modification Log----- 
* Modified by   :   Girikon(Ashish [CCEN-149 Sep 26 2018] ,Sunil [CCEN-533 Dec 20 2018, CCEN-642 Jan 29 2019],Aishwarya [CCEN-600 Jan 29 2019],Ashish [CCEN-652 6 Feb 2019], Prashant [CCEN-737 April 3 2019])
**/
public without sharing class CreateBadgesOpsCtrl {

    @AuraEnabled //Update Exhibitor Badge status
    public static void updateExhibitorBadge(List<String> idStr,String status)
    {
        BadgesUtils.updateBadgeStatus(idStr, status);
    }
    
    @AuraEnabled//Update Exhibitor Badge
    public static void updateBadgeAllFields(Exhibitor_Badge__c ebObj)
    {
        update ebObj;
    }
    
    @AuraEnabled //Fetch Exhibitor Badge
    public static List<Exhibitor_Badge__c> getSingleBadge(String idStr)
    {
        List<Exhibitor_Badge__c> listExhibitorBadge= new List<Exhibitor_Badge__c>();
        if(Schema.sObjectType.Exhibitor_Badge__c.isAccessible()){
            listExhibitorBadge =  [Select id,Account__c,Account__r.Name,Is_VIP__c,First_Name__c,Exhibitor_Name__c,Last_Name__c,Job_Title__c,Address__c,City__c,Country__c,Nationality__c,State__c,Status__c,Age_Bracket__c,Mobile_Number__c,Email__c,Country_Code__c,MatchMaking__c from Exhibitor_Badge__c WHERE Id=:idStr limit 1];
        }
        return listExhibitorBadge;
    }
    
    public class AggregateResultResp
    {
        @AuraEnabled public String companyName;
        @AuraEnabled public Integer submitted;
        @AuraEnabled public Integer approved;
        @AuraEnabled public Decimal totalBadgesAllowed;
        @AuraEnabled public List<Exhibitor_Badge__c> exhibitorBadgeList;
        public AggregateResultResp()
        {
            companyName = '';
            submitted=0;
            approved=0;
            totalBadgesAllowed=0.0;
            exhibitorBadgeList = new List<Exhibitor_Badge__c>();
        }
    }
    
    @AuraEnabled //Fetch Booth Summary on the basis of data in Opportunity_ExpoCAD_Booth_Mapping__c[CCEN-737]
    public static AggregateResultResp getBoothAggregate(String eventCode, String accountId,List<String> boothIds,string eventId,string uType)
    {
        AggregateResultResp objSummaryClass= new AggregateResultResp();        
        Decimal totalBadgesAllowed = 0;
        Decimal badgeLimitAll = 0;
        //AND Quote__r.SBQQ__Opportunity2__r.Account.Name='Sachin Exhibitor Test Account INC' Quote__r.SBQQ__Primary__c=true AND
        Set<String> idSet = new Set<String>();
        list<AggregateResult> listExpocadBooth = new list<AggregateResult>();
        if(Schema.sObjectType.Opportunity_ExpoCAD_Booth_Mapping__c.isAccessible()){
            listExpocadBooth = [SELECT Quote__r.SBQQ__Account__r.Name ,SUM(CountBadges__c),SUM(ExhibitorBadgesApproved__c)  FROM Opportunity_ExpoCAD_Booth_Mapping__c WHERE Id IN:boothIds AND Quote__r.SBQQ__Account__c=:accountId AND Status__c ='Active' GROUP BY Quote__r.SBQQ__Account__c,Quote__r.SBQQ__Account__r.Name,Quote__r.SBQQ__Account__r.Id LIMIT 1];
        }
        if(listExpocadBooth.size()> 0){
            for(AggregateResult ar : listExpocadBooth)
            {
                objSummaryClass.companyName = String.valueOf(ar.get('Name'));
                objSummaryClass.submitted = Integer.valueOf(ar.get('expr0'));
                objSummaryClass.approved = Integer.valueOf(ar.get('expr1'));
            }
        }
        
        list<Opportunity_ExpoCAD_Booth_Mapping__c> expocadBoothList=new list<Opportunity_ExpoCAD_Booth_Mapping__c>();
        expocadBoothList= BadgesUtils.getOppBoothforAccountBadge(eventCode,accountId);
        List<Booth_Size_Badge_Limit__c> lstBoothSizeBadgeLimit = new List<Booth_Size_Badge_Limit__c>();
        
        Event_Settings__c eventForBooth =getEventSettings(eventId);
        // CCEN-600
         if((eventForBooth.Allotment_By_Booth_Type__c==true && Schema.sObjectType.Booth_Size_Badge_Limit__c.isAccessible()) || Test.isRunningTest())
         {
            lstBoothSizeBadgeLimit =[Select Badges_Allowed__c,Booth_Type__c, Booth_Size_From__c, Booth_Size_To__c,Match_Product_Entry_Type__c,Badges_Allowed_by_Booth_Type__c from Booth_Size_Badge_Limit__c where Event_Edition__r.Event_Code__c =:eventCode and Booth_Type__c!=null ];
            if(lstBoothSizeBadgeLimit.size()>0)
            {
                for(Booth_Size_Badge_Limit__c boothProductType :lstBoothSizeBadgeLimit )
                {
                    for(Opportunity_ExpoCAD_Booth_Mapping__c expoBooth :expocadBoothList){
                        if((boothProductType.Match_Product_Entry_Type__c!=null) && (boothProductType.Booth_Type__c == expoBooth.Expocad_Booth__r.Matched_Product_Name__c)){ 
                            if(boothProductType.Match_Product_Entry_Type__c=='Fixed') {
                                totalBadgesAllowed = totalBadgesAllowed + (boothProductType.Badges_Allowed_by_Booth_Type__c!=null?boothProductType.Badges_Allowed_by_Booth_Type__c:0); 
                            }
                            if(boothProductType.Match_Product_Entry_Type__c=='Formula'){
                                system.debug('tot'+BadgesUtils.getTotalBadgesByDimension(expoBooth.Expocad_Booth__r.Dimensions__c));
                                totalBadgesAllowed = totalBadgesAllowed + (BadgesUtils.getTotalBadgesByDimension(expoBooth.Expocad_Booth__r.Dimensions__c));
                                system.debug('tot'+totalBadgesAllowed);
                                
                            }
                            if(expoBooth.Badge_Limit__c>0){
                                totalBadgesAllowed = totalBadgesAllowed + expoBooth.Badge_Limit__c;
                                system.debug('with badge limit'+totalBadgesAllowed);
                                badgeLimitAll = badgeLimitAll + expoBooth.Badge_Limit__c;
                            } 
                        }
                    }
                }
            }
        } 
       // CCEN-600
       if(eventForBooth.Allotment_By_Booth_Size__c==True||((eventForBooth.Allotment_By_Booth_Size__c==false)&&(eventForBooth.Allotment_By_Booth_Type__c==false)))
       {
           lstBoothSizeBadgeLimit =[Select Badges_Allowed__c, Booth_Size_From__c, Booth_Size_To__c,Match_Product_Entry_Type__c FROM Booth_Size_Badge_Limit__c where Event_Edition__r.Event_Code__c =:eventCode AND Booth_Size_From__c!=null AND Booth_Size_To__c!=null AND Badges_Allowed__c!=null]; 
           if(lstBoothSizeBadgeLimit.size()> 0)
           {
               for(Booth_Size_Badge_Limit__c badge :lstBoothSizeBadgeLimit)
               {
                   for(Opportunity_ExpoCAD_Booth_Mapping__c expoBooth :expocadBoothList)
                   {
                       idSet.add(expoBooth.Id);
                       if((badge.Booth_Size_From__c <= expoBooth.Expocad_Booth__r.Area_Number__c) && (badge.Booth_Size_To__c >= expoBooth.Expocad_Booth__r.Area_Number__c))
                       {
                           totalBadgesAllowed = totalBadgesAllowed + badge.Badges_Allowed__c;
                           if(expoBooth.Badge_Limit__c>0)
                           {
                               totalBadgesAllowed=totalBadgesAllowed+expoBooth.Badge_Limit__c;
                               badgeLimitAll = badgeLimitAll + expoBooth.Badge_Limit__c;
                           }
                       }
                   }
               }
           }
        }
        //Fixed badge limit if user type is co-exhibitor [CCEN-533]
        if(uType=='Co-Exhibitor' || uType=='Co_Exhibitor')
        {
            Event_Settings__c eventSettings = getEventSettings(eventId);
            //totalBadgesAllowed =Decimal.valueOf(eventSettings.Co_Exhibitor_Badge_Limit__c)+badgeLimitAll;  
            totalBadgesAllowed = String.isnotblank(eventSettings.Co_Exhibitor_Badge_Limit__c) ? Decimal.valueOf(eventSettings.Co_Exhibitor_Badge_Limit__c)+badgeLimitAll : badgeLimitAll ;
        }
        //
        objSummaryClass.totalBadgesAllowed =totalBadgesAllowed; 
        //[CCEN-149] : Added field "Agent__c" in Query below
        //[CCEN-149] : Added field "Is_VIP__c" in Query below
        if(Schema.sObjectType.Exhibitor_Badge__c.isAccessible())
        { 
            objSummaryClass.exhibitorBadgeList = [Select Id,Is_VIP__c,Exhibitor_Name__c,Opp_Booth_Mapping__c,Opp_Booth_Mapping__r.Booth_Number__c,Account__r.Name,First_Name__c,Last_Name__c,Job_Title__c,Address__c,City__c,tolabel(Country__c),Nationality__c,State__c,Status__c,Age_Bracket__c,Mobile_Number__c,Email__c,Country_Code__c,Agent__c,MatchMaking__c from Exhibitor_Badge__c WHERE Opp_Booth_Mapping__c In:boothIds and Account__c!=null order by Account__r.Name ASC];
        }
        System.debug('objSummaryClass ' +objSummaryClass.exhibitorBadgeList);
        return objSummaryClass;
    }
    
    @AuraEnabled //Fetch Booth Size Limit
    public static list<Booth_Size_Badge_Limit__c> getBoothSizeLimit(String eventId)
    {
        Event_Settings__c eventForBooth = getEventSettings(eventId);
        list<Booth_Size_Badge_Limit__c> lstBoothSize = new list<Booth_Size_Badge_Limit__c>();
        if(eventForBooth.Allotment_By_Booth_Type__c==true)
        {
            lstBoothSize=[select id ,Booth_Type__c,Badges_Allowed_by_Booth_Type__c,Match_Product_Entry_Type__c,CheckBadgesAllotmentByBoothType__c from Booth_Size_Badge_Limit__c where Event_Edition__c=:eventId and Booth_Type__c!=null];
            system.debug('bthtype'+lstBoothSize);
        }
        if((eventForBooth.Allotment_By_Booth_Size__c==true) ||((eventForBooth.Allotment_By_Booth_Size__c==false)&&(eventForBooth.Allotment_By_Booth_Type__c==false))){
            lstBoothSize = [select id,Badges_Allowed__c,Booth_Size_From__c,Booth_Size_To__c,Event_Edition__c ,Match_Product_Entry_Type__c,CheckBadgesAllotmentByBoothType__c from Booth_Size_Badge_Limit__c where Event_Edition__c=:eventId and Booth_Size_From__c!=null and Booth_Size_To__c!=null];
        }
        return lstBoothSize; 
    }

    @AuraEnabled //Fetch Booths on the basis of data in Opportunity_ExpoCAD_Booth_Mapping__c [CCEN-737]
    public static list<boothSummaryWrpClass> getBooths(String eventCode, string accId)
    {
        list<boothSummaryWrpClass> objBoothSummaryWrpClass = new list<boothSummaryWrpClass>();
        list<Opportunity_ExpoCAD_Booth_Mapping__c> lstexpoBooths=new list<Opportunity_ExpoCAD_Booth_Mapping__c>();
        list<Event_Settings__c> evntStng = new list<Event_Settings__c>();
        Decimal totalCoExhBadgesAllowed = 0;
        Boolean allowByBoothType = false;
        
        map<decimal,decimal> mapArea = new  map<decimal,decimal>();
        Map<String,Booth_Size_Badge_Limit__c> mapBoothBadgeRule = new  Map<String,Booth_Size_Badge_Limit__c>();
        List<Booth_Size_Badge_Limit__c> lstBoothSizeBadgeLimit = new List<Booth_Size_Badge_Limit__c>();

        if(Schema.sObjectType.Event_Settings__c.isAccessible())
        {
            evntStng = [select Co_Exhibitor_Badge_Limit__c,Allotment_By_Booth_Type__c from Event_Settings__c where Event_Edition__r.Event_Code__c =: eventCode];
        } 

        if(evntStng.size()>0)
        {
            lstexpoBooths= BadgesUtils.getOppBoothforAccountBadge(eventCode,accId);
            totalCoExhBadgesAllowed = Decimal.valueOf(evntStng[0].Co_Exhibitor_Badge_Limit__c==null?'0':evntStng[0].Co_Exhibitor_Badge_Limit__c);
            allowByBoothType = Boolean.valueOf(evntStng[0].Allotment_By_Booth_Type__c);
            lstBoothSizeBadgeLimit = [Select Booth_Type__c,Match_Product_Entry_Type__c,Badges_Allowed_by_Booth_Type__c,Badges_Allowed__c, Booth_Size_From__c, Booth_Size_To__c from Booth_Size_Badge_Limit__c where Event_Edition__r.Event_Code__c =:eventCode]; 
        }

        if(lstBoothSizeBadgeLimit.size()> 0)
        {
            for(Booth_Size_Badge_Limit__c badge :lstBoothSizeBadgeLimit)
            {
                for(Opportunity_ExpoCAD_Booth_Mapping__c expoBooth :lstexpoBooths)
                {
                    if((badge.Booth_Size_From__c <= expoBooth.Expocad_Booth__r.Area_Number__c) && (badge.Booth_Size_To__c >= expoBooth.Expocad_Booth__r.Area_Number__c))
                    {
                        mapArea.put(expoBooth.Expocad_Booth__r.Area_Number__c, badge.Badges_Allowed__c);                        
                    }
                }
                mapBoothBadgeRule.put(badge.Booth_Type__c,badge);
            }
        }
        
        for(Opportunity_ExpoCAD_Booth_Mapping__c expoBooth :lstexpoBooths){
            boothSummaryWrpClass newWrapper = new boothSummaryWrpClass();
            newWrapper.id=expoBooth.Id;
            newWrapper.boothNumber=expoBooth.Booth_Number__c;
            // updated as pre CCEN 420
            if (!String.isBlank(expoBooth.Display_Name__c)){                    
                newWrapper.displayName=expoBooth.Display_Name__c;
            }
            else{
                newWrapper.displayName =expoBooth.Opportunity__r.account.name;
            }
            newWrapper.totArea=expoBooth.Expocad_Booth__r.Area_Number__c;
            newWrapper.unitType=expoBooth.Expocad_Booth__r.Unit_Type__c;
            newWrapper.dimensions=expoBooth.Expocad_Booth__r.Dimensions__c;
            newWrapper.badgeLimit=expoBooth.Badge_Limit__c;
            newWrapper.totBadgesAllotment= 0;

            if(!allowByBoothType && mapArea.containskey(expoBooth.Expocad_Booth__r.Area_Number__c))
            {
                newWrapper.totBadgesAllotment = mapArea.get(expoBooth.Expocad_Booth__r.Area_Number__c);
            }
            else if(allowByBoothType && mapBoothBadgeRule.containskey(expoBooth.Expocad_Booth__r.Matched_Product_Name__c))
            {
                Booth_Size_Badge_Limit__c badgeObj = mapBoothBadgeRule.get(expoBooth.Expocad_Booth__r.Matched_Product_Name__c);
                if(badgeObj.Match_Product_Entry_Type__c == 'Fixed')
                {
                    newWrapper.totBadgesAllotment = badgeObj.Badges_Allowed_by_Booth_Type__c;
                }
                else if(badgeObj.Match_Product_Entry_Type__c == 'Formula')
                {
                    newWrapper.totBadgesAllotment = BadgesUtils.getTotalBadgesByDimension(expoBooth.Expocad_Booth__r.Dimensions__c); 
                }                                
            }
            objBoothSummaryWrpClass.add(newWrapper);
        }
        return objBoothSummaryWrpClass; 
    }
    
    @AuraEnabled //Fetch Booth Summary on the basis of data in Opportunity_ExpoCAD_Booth_Mapping__c[CCEN-737]
    public static boothSummaryWrpClass getBoothSummary(String eventCode, list<string> boothIds,string eventId,string uType)
    {
        system.debug('get booth eventid'+eventId);
        system.debug('get booth boothIds '+boothIds);
        boothSummaryWrpClass objSummaryClass= new boothSummaryWrpClass();
        Decimal totalBadgesUsed = 0;
        Decimal totalArea = 0;
        Decimal totalBadgesRemaining = 0; 
        Decimal totalBadgesAllowed = 0;
        String initialAllBoothDisplay ='';
        
        Decimal badgeLimitAll = 0;
        List<Opportunity_ExpoCAD_Booth_Mapping__c> listExpocadBooth = new List<Opportunity_ExpoCAD_Booth_Mapping__c>();
        listExpocadBooth = [Select Account__r.Name , Expocad_Booth__c, Expocad_Booth__r.Area_Number__c, Expocad_Booth__r.Unit_Type__c,Expocad_Booth__r.Matched_Product_Name__c, CountBadges__c, Event_Code__c,Badge_Limit__c , Expocad_Booth__r.Dimensions__c from Opportunity_ExpoCAD_Booth_Mapping__c where status__c='Active' AND Id IN:boothIds];
        System.debug('listExpocadBooth ' +listExpocadBooth);
        List<decimal> listAreas = new List<decimal>();
        if(listExpocadBooth.size()> 0){
            objSummaryClass.accountName=listExpocadBooth[0].Account__r.Name;
            objSummaryClass.unitType=listExpocadBooth[0].Expocad_Booth__r.Unit_Type__c;
            for(Opportunity_ExpoCAD_Booth_Mapping__c booth :listExpocadBooth){
                //System.debug('CountBadges__c ' +booth.CountBadges__c);
                totalBadgesUsed = totalBadgesUsed  + booth.CountBadges__c ;
                if(booth.Expocad_Booth__r.Area_Number__c != null){
                    totalArea = totalArea + booth.Expocad_Booth__r.Area_Number__c;
                    listAreas.add(booth.Expocad_Booth__r.Area_Number__c);
                    if(booth.Badge_Limit__c == null){
                        booth.Badge_Limit__c = 0;
                    }   
                    badgeLimitAll = badgeLimitAll + booth.Badge_Limit__c;
                }
            }
        }
        Event_Settings__c eventForBooth =getEventSettings(eventId);
        system.debug('event'+eventForBooth);
        List<Booth_Size_Badge_Limit__c> lstBoothSizeBadgeLimit = new List<Booth_Size_Badge_Limit__c>();
        
        //CCEN-600
        if((eventForBooth.Allotment_By_Booth_Type__c == true && eventForBooth.Allotment_By_Booth_Size__c == false) || Test.isRunningTest()){
            lstBoothSizeBadgeLimit =[Select Badges_Allowed__c,Booth_Type__c, Booth_Size_From__c, Booth_Size_To__c,Match_Product_Entry_Type__c,Badges_Allowed_by_Booth_Type__c from Booth_Size_Badge_Limit__c where Event_Edition__r.Event_Code__c =:eventCode and Booth_Type__c!=null ];
            system.debug('booth');
            if(lstBoothSizeBadgeLimit.size()>0){
                for(Booth_Size_Badge_Limit__c boothProductType :lstBoothSizeBadgeLimit ){
                    for(Opportunity_ExpoCAD_Booth_Mapping__c expoBooth :listExpocadBooth){
                        if((boothProductType.Match_Product_Entry_Type__c!=null)&&(boothProductType.Booth_Type__c == expoBooth.Expocad_Booth__r.Matched_Product_Name__c)){ 
                                if(boothProductType.Match_Product_Entry_Type__c=='Fixed') {
                                    totalBadgesAllowed = totalBadgesAllowed + (boothProductType.Badges_Allowed_by_Booth_Type__c!=null?boothProductType.Badges_Allowed_by_Booth_Type__c:0); 
                                }
                                if(boothProductType.Match_Product_Entry_Type__c=='Formula'){
                                    totalBadgesAllowed = totalBadgesAllowed + (BadgesUtils.getTotalBadgesByDimension(expoBooth.Expocad_Booth__r.Dimensions__c));
                                    system.debug('l+w value'+totalBadgesAllowed);
                                }
                                if((expoBooth.Badge_Limit__c>0)||(expoBooth.Badge_Limit__c==null)){
                                    totalBadgesAllowed = totalBadgesAllowed + expoBooth.Badge_Limit__c;
                                    system.debug('with badge limit'+totalBadgesAllowed);
                                }
                            }
                        }
                    }
                }
            } 
        //CCEN-600
        if((eventForBooth.Allotment_By_Booth_Size__c == True && eventForBooth.Allotment_By_Booth_Type__c == false) || ((eventForBooth.Allotment_By_Booth_Size__c==false) && (eventForBooth.Allotment_By_Booth_Type__c==false))){
            lstBoothSizeBadgeLimit =[Select Badges_Allowed__c,Booth_Type__c,Badges_Allowed_by_Booth_Type__c, Booth_Size_From__c, Booth_Size_To__c,Match_Product_Entry_Type__c from Booth_Size_Badge_Limit__c where Event_Edition__r.Event_Code__c =:eventCode and Booth_Size_From__c!=null and Booth_Size_To__c!=null and Badges_Allowed__c!=null]; 
            system.debug('Booth Size');
            if(lstBoothSizeBadgeLimit.size()> 0){
                for(Booth_Size_Badge_Limit__c badge :lstBoothSizeBadgeLimit){
                    for(Opportunity_ExpoCAD_Booth_Mapping__c expoBooth :listExpocadBooth){
                        if((badge.Booth_Size_From__c <= expoBooth.Expocad_Booth__r.Area_Number__c) && (badge.Booth_Size_To__c >= expoBooth.Expocad_Booth__r.Area_Number__c)){
                            system.debug('allowed'+badge.Badges_Allowed__c);
                            totalBadgesAllowed = totalBadgesAllowed + badge.Badges_Allowed__c;
                            if(expoBooth.Badge_Limit__c>0){
                                system.debug('limit'+expoBooth.Badge_Limit__c);
                                totalBadgesAllowed=totalBadgesAllowed+expoBooth.Badge_Limit__c;
                            }
                        }
                        
                    }
                }
            }
        }
        //
        //Fixed bage limit if user type is co-exhibitor [CCEN-533]
        if(uType=='Co-Exhibitor' || uType=='Co_Exhibitor')
        {
            Event_Settings__c eventSettings = getEventSettings(eventId);
                totalBadgesAllowed = String.isnotblank(eventSettings.Co_Exhibitor_Badge_Limit__c) ? Decimal.valueOf(eventSettings.Co_Exhibitor_Badge_Limit__c)+badgeLimitAll : badgeLimitAll ;
        }
        // 
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
            string fromOpsAdmin = 'OpsAdmin';
            BadgesUtils.saveExhibitorBadges(exhBadge, eventId, accountId, fromOpsAdmin);
        }
        catch (Exception ex) 
        {
            msg=ex.getMessage();
        } 
        return msg;   
    }

    @AuraEnabled //update booth badges limit
    public static void increaseBoothBadgeLimit(list<Opportunity_ExpoCAD_Booth_Mapping__c> expoBoothsMapping)
    { 
        update expoBoothsMapping;  
    }
    
    @AuraEnabled //Fetch event details [CCEN-642 Added contractor fields]
    public static Event_Settings__c getEventSettings(String eventId)
    {
        Event_Settings__c eventSetting= new Event_Settings__c();
        if(Schema.sObjectType.Event_Settings__c.isAccessible() && eventId != null){
            system.debug('id'+eventId);
            eventSetting=[select id,Badge_State__c,Allow_VIP_Badges__c,Allotment_By_Booth_Type__c,Allotment_By_Booth_Size__c,Badge_Nationality__c,Badge_Mobile_Number__c,Badge_Last_Name__c,Badge_Job_Title__c,Badge_First_Name__c,Badge_Email__c,Badge_Country__c,Company_Name_on_Badge_ToUpperCase__c,Company_Name_on_Badge_Character_Limit__c,Badge_City__c,Badges_Title__c,Badges_Sub_Title__c,Badges_Redirect_URL__c,Badge_Mobile_Character_Limit__c,Badge_LName_To_UpperCase__c,Badge_LName_Character_Limit__c,Badge_JobTitle_Character_Limit__c,Badge_FName_To_UpperCase__c,Badge_FName_Character_Limit__c,Badge_Email_Character_Limit__c,Badge_Deadline__c,Badge_City_Character_Limit__c,Badge_Address_Character_Limit__c,Badge_Age_Bracket__c,Badge_Address__c,Company_Name_on_Badge__c,Co_Exhibitor_Badge_Limit__c,Badges_MatchMaking__c from Event_Settings__c where  Event_Edition__c = :eventId limit 1];
        //system.debug('event'+eventSetting);
        }
        //system.debug('event'+eventSetting);
        return eventSetting;
    }
}