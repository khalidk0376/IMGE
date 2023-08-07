/**
* Created By    :  Girikon(Ashish)
* Created On    :  21 Jan 2019 [CCEN-613]
* @description  :  Shows  The Report list view of all exhibitors in a Event (Ctrl Class of [CustomerBadgesReportOps])
* Test Class    :  CustomerBadgesReportOpsCtrl_Test (82%)
* Modification Log----- 
* Modified by : Girikon(Ashish [CCEN-652 Feb 6 2019] , Prashant [CCEN-737 April 3 2019])
**/
public without sharing class CustomerBadgesReportOpsCtrl 
{
    public class AggregateResultResp
    {
        @AuraEnabled public String companyName;
        @AuraEnabled public String companyAccId;
        @AuraEnabled public Integer submitted;
        @AuraEnabled public Integer approved;
        @AuraEnabled public Decimal totalBadgesAllowed;
        @AuraEnabled public List<Exhibitor_Badge__c> exhibitorBadgeList;
        public AggregateResultResp()
        {
            companyName = '';
            companyAccId = '';
            submitted=0;
            approved=0;
            totalBadgesAllowed=0.0;
            exhibitorBadgeList = new List<Exhibitor_Badge__c>();
        }
    }
    //Wrapper Class For Aggregate Result Wrapper 
    public class AggregateResultWrapper
    {
        @AuraEnabled public Integer pageSize {get;set;}
        @AuraEnabled public Integer pageNumber {get;set;}
        @AuraEnabled public Integer totalRecords {get;set;}
        @AuraEnabled public Integer recordStart {get;set;}
        @AuraEnabled public Integer recordEnd {get;set;}
        @AuraEnabled public List<AggregateResultResp> aggregateResult {get;set;}
        public AggregateResultWrapper()
        {
            aggregateResult = new List<AggregateResultResp>();
        }
    }

    @AuraEnabled //Fetch Exhibitor Badge Aggregate Result on the basis of data in Opportunity_ExpoCAD_Booth_Mapping__c[CCEN-737]
    public static AggregateResultWrapper getExhibitorBadgeAggregate(String sEventId,Decimal pageNumber, Decimal pageSize,string status)
    {
        list<AggregateResultResp> listExhBadgeAgg = new list<AggregateResultResp>(); 
        AggregateResultWrapper agrResultWrap = new AggregateResultWrapper();

        Integer pSize =  (Integer)pageSize;
        Integer pNumber = (Integer)pageNumber;
         
        //Offset for SOQL 
        Integer offset = (pNumber - 1) * pSize;

        if(String.isNotBlank(sEventId))
        {
            String query = '';

            String fields  = 'Quote__r.SBQQ__Account__r.Id,Quote__r.SBQQ__Account__r.Name,SUM(CountBadges__c),SUM(ExhibitorBadgesApproved__c)';

            // string condition = ' from ExpocadBooth__c where Status__c = \'Rented\' And Opportunity__r.EventEdition__c=\''+String.escapeSingleQuotes(sEventId)+'\'  And Opportunity__c != null And Opportunity__r.User_Type__r.Name != \'Agent\' And Opportunity__r.Operations_Contact__c != null  And (Opportunity__r.StageName = \'Closed Won\' or Opportunity__r.StageName = \'Closed Booked\') ';

            
            string condition = ' from Opportunity_ExpoCAD_Booth_Mapping__c where Status__c = \'Active\' And Expocad_Booth__r.Status__c = \'Rented\' And Opportunity__r.EventEdition__c= :sEventId  And Opportunity__c != null And (Related_Opportunity__c  = null OR Opportunity__r.User_Type__r.Name != \'Agent\') And Opportunity__r.AccountId != null And (Opportunity__r.StageName = \'Closed Won\' or Opportunity__r.StageName = \'Closed Booked\') ';

            if(status == 'All VIP')
            {
                condition = condition + 'And Vip_Badges_Count__c > 0';
            }
            if(status == 'VIP Pending Review')
            {
                condition = condition + 'And VIP_Pending_Badges_Count__c > 0';
            }
            if(status == 'Submitted')
            {
                condition = condition + ' And CountBadges__c > 0';
            }
            if(status == 'Not Submitted')
            {
                condition = condition + ' And CountBadges__c = 0';
            }

            string groupBy = ' GROUP BY Quote__r.SBQQ__Account__c,Quote__r.SBQQ__Account__r.Name,Quote__r.SBQQ__Account__r.Id ';

            query = 'select '+String.escapeSingleQuotes(fields)+ condition +String.escapeSingleQuotes(groupBy);

            system.debug('query----'+query);

            if(pSize>0){  
                query = query+' LIMIT '+ pSize +' OFFSET ' + offset  ;
            }
            AggregateResult [] listExpoBoothMapping  =  Database.query(query); 
            //Total Records
            AggregateResult [] listExpoBoothMapCount  =  database.Query('select Quote__r.SBQQ__Account__r.Id '+condition +String.escapeSingleQuotes(groupBy));
            Integer totalRecords = listExpoBoothMapCount.size();
            Integer recordEnd = pSize * pNumber; 

            listExpoBoothMapCount.clear();
            agrResultWrap.pageSize = pSize;
            agrResultWrap.pageNumber = pNumber;
            agrResultWrap.recordStart = offset + 1;
            agrResultWrap.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
            agrResultWrap.totalRecords = totalRecords;
            set<string> accIds = new set<String>();
            if(listExpoBoothMapping.size()> 0)
            {
                for(AggregateResult ar : listExpoBoothMapping){                    
                    accIds.add(String.valueOf(ar.get('Id')));
                }
                map<String,Decimal> mapAccTotalBadgesLimit = new map<string,Decimal>();
                mapAccTotalBadgesLimit = getAccTotalBadgesAllowed(accIds,sEventId);
                for(AggregateResult ar : listExpoBoothMapping)
                {
                    AggregateResultResp objSummaryClass= new AggregateResultResp();
                    objSummaryClass.companyName = String.valueOf(ar.get('Name'));
                    objSummaryClass.companyAccId = String.valueOf(ar.get('Id'));
                    objSummaryClass.submitted = Integer.valueOf(ar.get('expr0'));
                    objSummaryClass.approved = Integer.valueOf(ar.get('expr1'));
                    if(mapAccTotalBadgesLimit.containsKey(String.valueOf(ar.get('Id')))){
                        objSummaryClass.totalBadgesAllowed  = mapAccTotalBadgesLimit.get(String.valueOf(ar.get('Id')));
                    }
                    else{
                        objSummaryClass.totalBadgesAllowed  = 0;
                    }
                    listExhBadgeAgg.add(objSummaryClass);
                }
            }                              
        } 
        agrResultWrap.aggregateResult = listExhBadgeAgg;
        return agrResultWrap;
    } 
    // Get total Badges Allowed on the basis of data in Opportunity_ExpoCAD_Booth_Mapping__c[CCEN-737]
    private static map<string,Decimal> getAccTotalBadgesAllowed(set<String> accIDs,String sEventId)
    {
        map<String,Decimal> mapAccTotalBadgesLimit = new map<string,Decimal>();
        List<Opportunity_ExpoCAD_Booth_Mapping__c> listExpoBoothMapping = new List<Opportunity_ExpoCAD_Booth_Mapping__c>();
        list<Event_Settings__c> evntStng = new list<Event_Settings__c>();
        List<Booth_Size_Badge_Limit__c> lstBoothSizeBadgeLimit = new List<Booth_Size_Badge_Limit__c>();
        Map<String,Booth_Size_Badge_Limit__c> mapBoothBadgeRule = new  Map<String,Booth_Size_Badge_Limit__c>();
        Decimal totalCoExhBadgesAllowed = 0;
        Boolean allowByBoothType = false;
        if(Schema.sObjectType.Event_Settings__c.isAccessible()){
            evntStng = [select Co_Exhibitor_Badge_Limit__c,Allotment_By_Booth_Type__c from Event_Settings__c where Event_Edition__c =: sEventId];
        }        
        if(evntStng.size()>0){
            listExpoBoothMapping = getAllBooths(accIDs,sEventId);
            totalCoExhBadgesAllowed = Decimal.valueOf(evntStng[0].Co_Exhibitor_Badge_Limit__c==null?'0':evntStng[0].Co_Exhibitor_Badge_Limit__c);
            allowByBoothType = Boolean.valueOf(evntStng[0].Allotment_By_Booth_Type__c);
        }
        
        if(Schema.sObjectType.Booth_Size_Badge_Limit__c.isAccessible()){
            lstBoothSizeBadgeLimit =[Select Badges_Allowed__c,Match_Product_Entry_Type__c,Badges_Allowed_by_Booth_Type__c,Booth_Size_From__c, Booth_Size_To__c,Booth_Type__c from Booth_Size_Badge_Limit__c where Event_Edition__c =:sEventId]; 
        } 
        if(listExpoBoothMapping.size()>0 && lstBoothSizeBadgeLimit.size()>0)
        {
            // Badges Allotment By BoothType Rule 
            if(allowByBoothType){
                for(Booth_Size_Badge_Limit__c badge :lstBoothSizeBadgeLimit){
                    mapBoothBadgeRule.put(badge.Booth_Type__c,badge);
                }
                for(Opportunity_ExpoCAD_Booth_Mapping__c expoBooth :listExpoBoothMapping){
                    Decimal totalBadgesAllowed = 0;
                    if(String.isNotBlank(expoBooth.Expocad_Booth__r.Matched_Product_Name__c) && mapBoothBadgeRule.containsKey(expoBooth.Expocad_Booth__r.Matched_Product_Name__c))
                    {                    
                        Booth_Size_Badge_Limit__c badgeObj = mapBoothBadgeRule.get(expoBooth.Expocad_Booth__r.Matched_Product_Name__c);
                        if(expoBooth.Opportunity__r.User_Type__r.Name == 'Co-Exhibitor' || expoBooth.Opportunity__r.User_Type__r.Name =='Co_Exhibitor') { totalBadgesAllowed = totalCoExhBadgesAllowed; } //incase of Co-Exhibitor badge limit are fatched from event Setting 
                        else{ if(badgeObj.Match_Product_Entry_Type__c == 'Fixed'){ totalBadgesAllowed = badgeObj.Badges_Allowed_by_Booth_Type__c; }
                            else if(badgeObj.Match_Product_Entry_Type__c == 'Formula'){ totalBadgesAllowed = BadgesUtils.getTotalBadgesByDimension(expoBooth.Expocad_Booth__r.Dimensions__c); }
                        }                        
                        if(expoBooth.Badge_Limit__c>0){ totalBadgesAllowed=totalBadgesAllowed+expoBooth.Badge_Limit__c; }
                    }
                    if(mapAccTotalBadgesLimit.containsKey(expoBooth.Opportunity__r.AccountId)){
                        mapAccTotalBadgesLimit.put(expoBooth.Opportunity__r.AccountId,mapAccTotalBadgesLimit.get(expoBooth.Opportunity__r.AccountId)+totalBadgesAllowed);
                    }
                    else{
                        mapAccTotalBadgesLimit.put(expoBooth.Opportunity__r.AccountId,totalBadgesAllowed);
                    } 
                }
            }
            else
            {
                // Badges Allotment By BoothSize Rule   
                for(Booth_Size_Badge_Limit__c badge :lstBoothSizeBadgeLimit)
                {
                    for(Opportunity_ExpoCAD_Booth_Mapping__c expoBooth :listExpoBoothMapping)
                    {
                        Decimal totalBadgesAllowed = 0;
                        if((badge.Booth_Size_From__c <= expoBooth.Expocad_Booth__r.Area_Number__c) && (badge.Booth_Size_To__c >= expoBooth.Expocad_Booth__r.Area_Number__c))
                        {
                            if(expoBooth.Opportunity__r.User_Type__r.Name == 'Co-Exhibitor' || expoBooth.Opportunity__r.User_Type__r.Name =='Co_Exhibitor'){
                                totalBadgesAllowed = totalCoExhBadgesAllowed; //incase of Co-Exhibitor badge limit are fatched from event Setting
                            }else {
                                totalBadgesAllowed = badge.Badges_Allowed__c;
                            }                        
                            if(expoBooth.Badge_Limit__c>0){ totalBadgesAllowed=totalBadgesAllowed+expoBooth.Badge_Limit__c; }
                        }
                        if(mapAccTotalBadgesLimit.containsKey(expoBooth.Opportunity__r.AccountId)){
                            mapAccTotalBadgesLimit.put(expoBooth.Opportunity__r.AccountId,mapAccTotalBadgesLimit.get(expoBooth.Opportunity__r.AccountId)+totalBadgesAllowed);
                        }
                        else {
                            mapAccTotalBadgesLimit.put(expoBooth.Opportunity__r.AccountId,totalBadgesAllowed);
                        }                    
                    }
                }
            }
        }                 
        return mapAccTotalBadgesLimit;
    }
    // get all booths on the basis of Opportunity_ExpoCAD_Booth_Mapping__c [CCEN-737]
    private static List<Opportunity_ExpoCAD_Booth_Mapping__c> getAllBooths(set<String> accIDs,String sEventId)
    {
        List<Opportunity_ExpoCAD_Booth_Mapping__c> listExpoBoothMap = new List<Opportunity_ExpoCAD_Booth_Mapping__c>();
        set<string> quoteIds = new set<string>();
        List<opportunity> opp = new List<opportunity>();
        opp = [select id,Name,SBQQ__PrimaryQuote__c from opportunity where AccountId in: accIDs AND EventEdition__r.Event_Edition_Status__c = 'Confirmed' And EventEdition__c =: sEventId AND (StageName='Closed Won' OR StageName='Closed Booked') order by createdDate];
        if(!opp.IsEmpty() && opp.size()>0){
            for(opportunity oppty: opp){
                if(oppty.SBQQ__PrimaryQuote__c!=null){
                    quoteIds.add(oppty.SBQQ__PrimaryQuote__c); 
                }
            } 
        }
        if(Schema.sObjectType.Opportunity_ExpoCAD_Booth_Mapping__c.isAccessible() && quoteIds.size()>0){
            listExpoBoothMap = [Select Id,Opportunity__r.AccountId,Account__r.Id,Account__r.Name,Expocad_Booth__r.Dimensions__c,Expocad_Booth__r.Area_Number__c,Expocad_Booth__r.Unit_Type__c,Opportunity__r.User_Type__r.Name ,CountBadges__c, Event_Code__c,Badge_Limit__c,Expocad_Booth__r.Matched_Product_Name__c from Opportunity_ExpoCAD_Booth_Mapping__c where Expocad_Booth__r.status__c='Rented' and status__c = 'Active' and quote__c IN:quoteIds and  (Related_Opportunity__c  = null OR Opportunity__r.User_Type__r.Name != 'Agent') And Opportunity__r.AccountId != null order by Opportunity__r.createdDate];
        }
        return listExpoBoothMap;
    }
    
    @AuraEnabled //Fetch Exhibitor Badge From Account Id
    public static list<Exhibitor_Badge__c> getAccountBadges (String sAccId,String sEventId)
    {
        List<Opportunity_ExpoCAD_Booth_Mapping__c> listExpocadBooth = new List<Opportunity_ExpoCAD_Booth_Mapping__c>();        
        List<Exhibitor_Badge__c> listExhibitorBadges = new List<Exhibitor_Badge__c>();
        set<string> setAccId = new set<String>();
        setAccId.add(sAccId);
        listExpocadBooth = getAllBooths(setAccId,sEventId);
        set<id> boothIds = new set<Id>();
        if(listExpocadBooth.size()>0){
            for(Opportunity_ExpoCAD_Booth_Mapping__c expoBth : listExpocadBooth){
                boothIds.add(expoBth.Id);
            }
        }

        if(boothIds.size()>0 && Schema.sObjectType.Exhibitor_Badge__c.isAccessible()){
            listExhibitorBadges = [Select Id,Opp_Booth_Mapping__c, Opp_Booth_Mapping__r.Booth_Number__c ,Is_VIP__c,Account__r.Name,First_Name__c,Last_Name__c,Job_Title__c,Address__c,City__c,Country__c,Nationality__c,State__c,Status__c,Age_Bracket__c,Mobile_Number__c,Email__c,Country_Code__c,Agent__c,MatchMaking__c from Exhibitor_Badge__c WHERE Opp_Booth_Mapping__c In:boothIds and Account__c!=null order by Account__r.Name ASC limit 600];
        }
        return listExhibitorBadges;
    }      
    @AuraEnabled //fetch picklist values.
    public static List<String> getPicklistValues(String objApi,String fieldName)
    { 
        List<String> lstPickvals=new List<String>();    
        lstPickvals = UtilityMethods.getPicklistValues(objApi,fieldName);
        return lstPickvals;  
    }
    @AuraEnabled //Fetch event details
    public static Event_Settings__c getEventSettings(String eventId)
    {
        Event_Settings__c eventSetting = new Event_Settings__c ();
        if(Schema.sObjectType.Event_Settings__c.isAccessible()){
            eventSetting=[select id,Badge_State__c,Allow_VIP_Badges__c,Badge_Nationality__c,Badge_Mobile_Number__c,Badge_Last_Name__c,Badge_Job_Title__c,Badge_First_Name__c,Badge_Email__c,Badge_Country__c,Company_Name_on_Badge_ToUpperCase__c,Company_Name_on_Badge_Character_Limit__c,Badge_City__c,Badges_Title__c,Badges_Sub_Title__c,Badges_Redirect_URL__c,Badge_Mobile_Character_Limit__c,Badge_LName_To_UpperCase__c,Badge_LName_Character_Limit__c,Badge_JobTitle_Character_Limit__c,Badge_FName_To_UpperCase__c,Badge_FName_Character_Limit__c,Badge_Email_Character_Limit__c,Badge_Deadline__c,Badge_City_Character_Limit__c,Badge_Address_Character_Limit__c,Badge_Age_Bracket__c,Badge_Address__c,Company_Name_on_Badge__c,Co_Exhibitor_Badge_Limit__c,Badges_MatchMaking__c from Event_Settings__c where  Event_Edition__c = :eventId limit 1];
        }
        return eventSetting;
    }

    @AuraEnabled //Update Exhibitor Badge status
    public static void updateExhibitorBadge(List<String> idStr,String status,Boolean sendEmail,String notes)
    {
        List<Exhibitor_Badge__c> ebList =  [Select id,Status__c from Exhibitor_Badge__c where id In :idStr];
        if(ebList.size()>0)
        {   
            set<string> ebIds = new set<String>();
            for(Exhibitor_Badge__c eb : ebList){
                eb.Status__c= status;//'pending';
                ebIds.add(eb.Id);
            }
            if(Schema.sObjectType.Exhibitor_Badge__c.isUpdateable()){
                update ebList;
            }
            if(sendEmail == true){
                BatchBadgesStatusSendEmail objBatch = new BatchBadgesStatusSendEmail(ebIds,status,notes);
                Database.executeBatch(objBatch,5);
            }            
        }
    }
    @AuraEnabled//Update Exhibitor Badge
    public static String updateBadgeAllFields(Exhibitor_Badge__c ebObj,Boolean sendEmail,String notes)
    {   
        String msg = 'Record Saved!'; 
        try{
            update ebObj;
        }
        catch(DmlException ex){
            msg=ex.getMessage();
            msg=msg+' #   At Line No =: '+ex.getLineNumber();
            system.debug('Msg =: '+msg);
        }
        if(sendEmail == true && (ebObj.Status__c == 'Approved' || ebObj.Status__c == 'Rejected'))
        {
            set<string> ebIds = new set<String>();
            ebIds.add(ebObj.Id);
            BatchBadgesStatusSendEmail objBatch = new BatchBadgesStatusSendEmail(ebIds,ebObj.Status__c,notes);
            Database.executeBatch(objBatch,1);
        }
        return msg;        
    }
     @AuraEnabled //Send Mass Badges Email Reminder
    public static Boolean massBadgesEmailReminder(string sEventId)
    { 
        set<String>accIDS= new set<string>();
        for(Opportunity_ExpoCAD_Booth_Mapping__c ebth : [select id,Opportunity__r.AccountId from Opportunity_ExpoCAD_Booth_Mapping__c where Expocad_Booth__r.Status__c = 'Rented' and Status__c = 'Active'  And Opportunity__r.EventEdition__c =: sEventId  And Opportunity__c != null And Opportunity__r.User_Type__r.Name != 'Agent' And Opportunity__r.Operations_Contact__c != null 
        And (Opportunity__r.StageName = 'Closed Won' or Opportunity__r.StageName = 'Closed Booked') And CountBadges__c = 0 ]) {
            accIDS.add(ebth.Opportunity__r.AccountId);
        }
        if(accIDS.size()>0){
            string accList = JSON.serialize(accIDS);
            MassBadgeReminderEmailBatch batch = new MassBadgeReminderEmailBatch(sEventId,accList);
            Database.executeBatch(batch, 10);
            return true;
        }
        else{ return false; }
    }
}