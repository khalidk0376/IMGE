/**
* Created By    :  Girikon(Aishwarya)[BK-16730]
* Last Modified :  [Aishwarya BK-16730 28 July 2021]
* @description  :  This class is used for updating the total badges field on opportunity expocad booth mapping record for Co-Exhibitor.
* Test Class    :  updateCoExhBadges_Test
**/
public with sharing class updateCoExhBadges{
    public static void updateCoExhibitorBadges(Set<String> OppExpoMapIds){
        Map<String,String> mapEventSetting = new Map<String,String>();
        List<Opportunity_ExpoCAD_Booth_Mapping__c> listOppExpoBoothMapping = new List<Opportunity_ExpoCAD_Booth_Mapping__c>();
        listOppExpoBoothMapping = [Select Total_Badges__c, Opportunity__r.EventEdition__c, Opportunity__r.User_Type__r.Name from Opportunity_ExpoCAD_Booth_Mapping__c where Expocad_Booth__r.Status__c='Rented'
                                       AND Status__c = 'Active' AND Expocad_Booth__r.Opportunity__c !=null AND (Opportunity__r.User_Type__r.Name ='Co-Exhibitor' OR Opportunity__r.User_Type__r.Name ='Co_Exhibitor') AND Id IN: OppExpoMapIds];
        
    
        List<Event_Settings__c> listEventForBooth = new List<Event_Settings__c>();
        listEventForBooth = [Select Id, Event_Edition__c, Co_Exhibitor_Badge_Limit__c FROM Event_Settings__c where Co_Exhibitor_Badge_Limit__c !=null LIMIT 500];
        if(!listEventForBooth.isEmpty() && listEventForBooth.size()>0){
            for(Event_Settings__c eves : listEventForBooth){
                mapEventSetting.put(eves.Event_Edition__c,eves.Co_Exhibitor_Badge_Limit__c); 
            }
        }
    
        if(!listOppExpoBoothMapping.isEmpty() && listOppExpoBoothMapping.size()>0){
            for(Opportunity_ExpoCAD_Booth_Mapping__c oppExpo :listOppExpoBoothMapping){
                if(!mapEventSetting.isEmpty() && mapEventSetting.containsKey(oppExpo.Opportunity__r.EventEdition__c)){
                    oppExpo.Total_Badges__c = Decimal.Valueof(mapEventSetting.get(oppExpo.Opportunity__r.EventEdition__c));
                }
            }
            Database.update(listOppExpoBoothMapping); 
        }
    }
}