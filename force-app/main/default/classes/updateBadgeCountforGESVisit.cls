/*
Created By:   Girikon[Aishwarya BK-9194 18 Oct 2020]
Last Modified On: [Aishwarya BK-16806 24 June 2021]
@Description: Batch class call from trigger runnable class - 'BadgeCountforGESVisit_Trig' for updating total badge field on Opportunity Expocad Booth Mapping record.
Test Class:   BadgeCountforGESVisit_Trig_Test
*/

public class updateBadgeCountforGESVisit implements Database.Batchable<sObject>
{
    public Set<string> setEventIds = new Set<string>();
    public updateBadgeCountforGESVisit(Set<string> setEvent){
        setEventIds = setEvent;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator([SELECT Id, Event_Code__c FROM Event_Edition__c where Id IN: setEventIds]); 
    }
    public void execute(Database.BatchableContext BC, List<Event_Edition__c> listEventEdition){    
        String eventId ='';
        Decimal totalBadgesAllowed = 0;
        for(Event_Edition__c ee :listEventEdition){
            eventId = ee.Id;
        }
        List<Opportunity_ExpoCAD_Booth_Mapping__c> listExpocadBoothMapping = new List<Opportunity_ExpoCAD_Booth_Mapping__c>();
        if(Schema.sObjectType.Opportunity_ExpoCAD_Booth_Mapping__c.isAccessible() ) 
        {
            listExpocadBoothMapping = [Select Total_Badges__c, Expocad_Booth__r.Area_Number__c, Expocad_Booth__r.Matched_Product_Name__c, Expocad_Booth__r.Dimensions__c, Opportunity__r.User_Type__r.Name FROM Opportunity_ExpoCAD_Booth_Mapping__c 
            where Expocad_Booth__r.Status__c='Rented' and Status__c = 'Active' AND Expocad_Booth__r.Opportunity__c !=null AND Opportunity__r.User_Type__r.Name !='Agent' AND Expocad_Booth__r.Opportunity__r.EventEdition__c =:eventId]; //AND Event_Code__c =:eventCode
        }
        system.debug('#####################'+listExpocadBoothMapping);
        List<Booth_Size_Badge_Limit__c> lstBoothSizeBadgeLimit = new List<Booth_Size_Badge_Limit__c>();
        Event_Settings__c eventForBooth = new Event_Settings__c();
        if(eventId !=null && eventId !=''){
            eventForBooth = [Select Id, Allotment_By_Booth_Size__c, Allotment_By_Booth_Type__c, Co_Exhibitor_Badge_Limit__c FROM Event_Settings__c where Event_Edition__c =:eventId LIMIT 1];
        }
        
        if(eventForBooth != null && eventForBooth.Allotment_By_Booth_Type__c)
        { 
            lstBoothSizeBadgeLimit =[Select Badges_Allowed__c,Booth_Type__c, Booth_Size_From__c, Booth_Size_To__c,Match_Product_Entry_Type__c,Badges_Allowed_by_Booth_Type__c from Booth_Size_Badge_Limit__c where Event_Edition__c =:eventId and Booth_Type__c!=null];
            if(lstBoothSizeBadgeLimit.size()>0)
            {
                for(Booth_Size_Badge_Limit__c boothProductType :lstBoothSizeBadgeLimit)
                {
                    for(Opportunity_ExpoCAD_Booth_Mapping__c expocadBoothMapping :listExpocadBoothMapping)
                    {
                        if(expocadBoothMapping.Opportunity__r.User_Type__r.Name =='Co-Exhibitor' || expocadBoothMapping.Opportunity__r.User_Type__r.Name =='Co_Exhibitor'){
                            totalBadgesAllowed = Decimal.valueOf(eventForBooth.Co_Exhibitor_Badge_Limit__c==null?'0':eventForBooth.Co_Exhibitor_Badge_Limit__c);
                            expocadBoothMapping.Total_Badges__c = totalBadgesAllowed;  
                        }
                        else if((boothProductType.Match_Product_Entry_Type__c!=null) && (boothProductType.Booth_Type__c == expocadBoothMapping.Expocad_Booth__r.Matched_Product_Name__c))
                        {
                            if(boothProductType.Match_Product_Entry_Type__c=='Fixed')
                            {
                                totalBadgesAllowed = (boothProductType.Badges_Allowed_by_Booth_Type__c!=null?boothProductType.Badges_Allowed_by_Booth_Type__c:0); 
                            }
                            if(boothProductType.Match_Product_Entry_Type__c=='Formula')
                            {
                                totalBadgesAllowed = (BadgesUtils.getTotalBadgesByDimension(expocadBoothMapping.Expocad_Booth__r.Dimensions__c));
                            }
                            expocadBoothMapping.Total_Badges__c = totalBadgesAllowed;
                        }
                    }
                }
            }
        } 
        else
        {
            lstBoothSizeBadgeLimit =[Select Badges_Allowed__c, Booth_Size_From__c, Booth_Size_To__c, Match_Product_Entry_Type__c from Booth_Size_Badge_Limit__c where Event_Edition__c =:eventId AND Booth_Size_From__c!=null AND Booth_Size_To__c!=null AND Badges_Allowed__c!=null];
            if(lstBoothSizeBadgeLimit.size()>0)
            {
                for(Booth_Size_Badge_Limit__c badge :lstBoothSizeBadgeLimit)
                {
                    for(Opportunity_ExpoCAD_Booth_Mapping__c expoBoothMap :listExpocadBoothMapping)
                    {
                        if(expoBoothMap.Opportunity__r.User_Type__r.Name =='Co-Exhibitor' || expoBoothMap.Opportunity__r.User_Type__r.Name =='Co_Exhibitor'){
                            totalBadgesAllowed = Decimal.valueOf(eventForBooth.Co_Exhibitor_Badge_Limit__c==null?'0':eventForBooth.Co_Exhibitor_Badge_Limit__c);
                            expoBoothMap.Total_Badges__c = totalBadgesAllowed;  
                        }
                        else if((badge.Booth_Size_From__c <= expoBoothMap.Expocad_Booth__r.Area_Number__c) && (badge.Booth_Size_To__c >= expoBoothMap.Expocad_Booth__r.Area_Number__c)){ 
                            expoBoothMap.Total_Badges__c = badge.Badges_Allowed__c == null?0:badge.Badges_Allowed__c;
                        }  
                    }
                }
            }
        }
        
        try{    
            if(!listExpocadBoothMapping.isEmpty() && listExpocadBoothMapping.size()>0)
                Database.update(listExpocadBoothMapping);
        }catch(exception ex){
            system.debug('====error'+ex.getMessage());
        }
    }
    public void finish(Database.BatchableContext BC)
    {
        // Added by Palla Kishore for the ticket Bk-19604
           system.debug('Batch job completed successfully');
    }
}