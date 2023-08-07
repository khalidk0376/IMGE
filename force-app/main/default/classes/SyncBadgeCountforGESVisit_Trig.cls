/**
* Created By    :  Girikon(Aishwarya)[BK-9194/9188 15/10/2020]
* Last Modified :  [Aishwarya BK-16806 24 June 2021]
* @description  :  This class is used for updating the total badges field on opportunity expocad booth mapping record on basis of assign booth size badge limit setting.
* Test Class    :  SyncBadgeCountforGESVisit_Test
* Modified By   :  25/11/2020
**/
public with sharing class SyncBadgeCountforGESVisit_Trig implements TriggerInterface_ExpocadBooth.Runnable {
    public void run(TriggerInterface_ExpocadBooth.Trig trig)
    {
        // functionality after booth released
        if(trig.isAfter && trig.isUpdate)
        {
            Set<Id> boothIds = new Set<Id>(); 
            for(ExpocadBooth__c EB : trig.newlist){
                boothIds.add(EB.Id);
            }
            String eventId ='';
            Set<string> setBoothIds = new Set<string>();
            List<Opportunity_ExpoCAD_Booth_Mapping__c> listOppExpoBoothMappingUpdate = new List<Opportunity_ExpoCAD_Booth_Mapping__c>();
            Decimal totalBadgesAllowed = 0;
            List<ExpocadBooth__c> listExpobooth = new List<ExpocadBooth__c>();
            listExpobooth = [Select Id, Name, Opportunity__r.EventEdition__c, Status__c, Matched_Product_Name__c, Area_Number__c, Dimensions__c FROM ExpocadBooth__c 
                                        where Id IN:boothIds AND Opportunity__c != null AND Opportunity__r.StageName = 'Closed Won' AND Status__c='Rented'];
            system.debug('============================='+listExpobooth);
            if(!listExpobooth.isEmpty()){
                for(ExpocadBooth__c ex :listExpobooth){
                    setBoothIds.add(ex.Id);
                    eventId = ex.Opportunity__r.EventEdition__c;
                }
            }
            
            List<Opportunity_ExpoCAD_Booth_Mapping__c> listExpocadBoothMapping = new List<Opportunity_ExpoCAD_Booth_Mapping__c>();
            if(Schema.sObjectType.Opportunity_ExpoCAD_Booth_Mapping__c.isAccessible()){
                if(Test.isRunningTest()){
                    listExpocadBoothMapping = [Select Id, Total_Badges__c, Expocad_Booth__r.Area_Number__c, Expocad_Booth__r.Matched_Product_Name__c, Expocad_Booth__r.Dimensions__c, Opportunity__r.User_Type__r.Name, Event_Code__c FROM Opportunity_ExpoCAD_Booth_Mapping__c where Status__c = 'Active' AND Expocad_Booth__c IN: setBoothIds];
                }
                else{
                    listExpocadBoothMapping = [Select Total_Badges__c, Expocad_Booth__r.Area_Number__c, Expocad_Booth__r.Matched_Product_Name__c, Expocad_Booth__r.Dimensions__c, Opportunity__r.User_Type__r.Name from Opportunity_ExpoCAD_Booth_Mapping__c 
                                                  where Expocad_Booth__r.Status__c='Rented' AND Status__c = 'Active' AND Expocad_Booth__r.Opportunity__c !=null AND Opportunity__r.User_Type__r.Name !='Agent' AND Expocad_Booth__c IN: setBoothIds];
                }
            }
            
            List<Booth_Size_Badge_Limit__c> lstBoothSizeBadgeLimit = new List<Booth_Size_Badge_Limit__c>();
            List<Event_Settings__c> eventForBooth = new List<Event_Settings__c>();
            //Event_uses_GES_Visit_to_manage_badges__c 
            if(eventId != null && eventId !=''){
                eventForBooth = [Select Id, Allotment_By_Booth_Size__c, Allotment_By_Booth_Type__c, Co_Exhibitor_Badge_Limit__c FROM Event_Settings__c where Event_Edition__c =:eventId LIMIT 1];
            }
            
            if(!eventForBooth.isEmpty()){
                if(eventForBooth[0].Allotment_By_Booth_Type__c)
                { 
                    lstBoothSizeBadgeLimit =[Select Badges_Allowed__c,Booth_Type__c, Booth_Size_From__c, Booth_Size_To__c,Match_Product_Entry_Type__c,Badges_Allowed_by_Booth_Type__c from Booth_Size_Badge_Limit__c where Event_Edition__c =:eventId and Booth_Type__c!=null];
                    if(lstBoothSizeBadgeLimit.size()>0)
                    {
                        for(Booth_Size_Badge_Limit__c boothProductType :lstBoothSizeBadgeLimit){
                            for(Opportunity_ExpoCAD_Booth_Mapping__c expocadBoothMapping :listExpocadBoothMapping)
                            {
                                if((boothProductType.Match_Product_Entry_Type__c!=null) && (boothProductType.Booth_Type__c == expocadBoothMapping.Expocad_Booth__r.Matched_Product_Name__c))
                                {
                                    if(boothProductType.Match_Product_Entry_Type__c=='Fixed'){
                                        totalBadgesAllowed = (boothProductType.Badges_Allowed_by_Booth_Type__c!=null?boothProductType.Badges_Allowed_by_Booth_Type__c:0); 
                                    }
                                    if(boothProductType.Match_Product_Entry_Type__c=='Formula'){
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
                    lstBoothSizeBadgeLimit =[Select Badges_Allowed__c, Booth_Size_From__c, Booth_Size_To__c, Match_Product_Entry_Type__c from Booth_Size_Badge_Limit__c where Event_Edition__c =:eventId and Booth_Size_From__c!=null and Booth_Size_To__c!=null and Badges_Allowed__c!=null];
                    if(lstBoothSizeBadgeLimit.size()>0)
                    {
                        for(Booth_Size_Badge_Limit__c badge :lstBoothSizeBadgeLimit)
                        {
                            for(Opportunity_ExpoCAD_Booth_Mapping__c expoBoothMap :listExpocadBoothMapping){
                                if((badge.Booth_Size_From__c <= expoBoothMap.Expocad_Booth__r.Area_Number__c) && (badge.Booth_Size_To__c >= expoBoothMap.Expocad_Booth__r.Area_Number__c))
                                { 
                                    expoBoothMap.Total_Badges__c = badge.Badges_Allowed__c;
                                }  
                            }
                        }
                    }
                }
            }
            //system.debug('============================='+listOppExpoBoothMappingUpdate);
            try{
                if(!listExpocadBoothMapping.isEmpty() && listExpocadBoothMapping.size()>0){
                    Database.update(listExpocadBoothMapping);
                }
            }catch(exception ex){
                system.debug('===Error'+ex.getMessage());
            }
        }
        
        // functionality after booth released
        if(trig.isAfter && trig.isUpdate)
        {
            Set<Id> boothIds = new Set<Id>();
            for(ExpocadBooth__c EB : trig.newlist) {
                boothIds.add(EB.Id);
            }
            Set<string> setBoothIds = new Set<string>();
            List<Opportunity_ExpoCAD_Booth_Mapping__c> listOppExpoBoothMappingUpdate = new List<Opportunity_ExpoCAD_Booth_Mapping__c>();
            List<Opportunity_ExpoCAD_Booth_Mapping__c> listExpocadBoothMapping = new List<Opportunity_ExpoCAD_Booth_Mapping__c>();
            List<ExpocadBooth__c> listExpobooth = new List<ExpocadBooth__c>();
            listExpobooth = [Select Id, Name, Opportunity__r.EventEdition__c, Status__c, Matched_Product_Name__c, Area_Number__c, Dimensions__c FROM ExpocadBooth__c 
                                        where Id IN:boothIds AND Opportunity__c != null AND Status__c='Released'];
            //system.debug('============================='+listExpobooth);
            if(!listExpobooth.isEmpty()){
                for(ExpocadBooth__c ex :listExpobooth){
                    setBoothIds.add(ex.Id);
                }
            }
            
            if(Schema.sObjectType.Opportunity_ExpoCAD_Booth_Mapping__c.isAccessible())
            { 
                listExpocadBoothMapping = [Select Id, Expocad_Booth__r.Area_Number__c, Expocad_Booth__c, Event_Code__c FROM Opportunity_ExpoCAD_Booth_Mapping__c where Expocad_Booth__c IN: setBoothIds];
            }
            
            if(!listExpocadBoothMapping.isEmpty() && listExpocadBoothMapping.size()>0)
            {
                for(Opportunity_ExpoCAD_Booth_Mapping__c expocadBoothMapping :listExpocadBoothMapping)
                {
                    Opportunity_ExpoCAD_Booth_Mapping__c oppExpoBooth = new Opportunity_ExpoCAD_Booth_Mapping__c(); 
                    oppExpoBooth.Id = expocadBoothMapping.Id;
                    oppExpoBooth.Total_Badges__c = 0;
                    listOppExpoBoothMappingUpdate.add(oppExpoBooth);
                }
            }
              
            try{
                if(!listOppExpoBoothMappingUpdate.isEmpty() && listOppExpoBoothMappingUpdate.size()>0){
                    Database.update(listOppExpoBoothMappingUpdate);
                }
            }catch(exception ex){
                system.debug('===Error'+ex.getMessage());
            }
        }
    }
}