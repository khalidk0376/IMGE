/**
 * Date:        6/7/2018
 * Created By : Divaker Singh
 * *************************************************************************
 * Description: This trigger calles action to check weather of Event Edition is live or not and creating user*  
 * Ticket CCEN: 46
 * Test Class : AttachDocumentCtr_Test(Code Cover 85%)
 * ************************************************************************* *
 * Last Modified By:    [Ashish/CCEN-585 (8 Jan 2019)],[Aishwarya BK-16730 27 July 2021]
 **/
trigger TrgCommunityUserOpsSetting on Event_Settings__c (after update)
{
    TrgCommunityUserOpsSetting_Handler.trgCommunityUserOpsSetting(trigger.new, trigger.oldMap,trigger.isUpdate,trigger.isAfter);
    Set<String> eveSettingSet = new Set<String>();
    Set<String> eveSettingCoExhibitor = new Set<String>();
    for(Event_Settings__c eveSetting : trigger.New){
        if(eveSetting.Agent_Badge_limit__c!= Trigger.oldMap.get(eveSetting.Id).Agent_Badge_limit__c){ 
            eveSettingSet.add(eveSetting.Id);
        }
        if(eveSetting.Co_Exhibitor_Badge_Limit__c != Trigger.oldMap.get(eveSetting.Id).Co_Exhibitor_Badge_Limit__c){
            eveSettingCoExhibitor.add(eveSetting.Event_Edition__c);
        }    
    }
    if(!eveSettingSet.isEmpty() && eveSettingSet.size()>0){
        TrgCommunityUserOpsSetting_Handler.updateAgentBadges(eveSettingSet);
    }
    if(!eveSettingCoExhibitor.isEmpty() && eveSettingCoExhibitor.size()>0){
        database.executeBatch(new updateBadgeCountforGESVisit(eveSettingCoExhibitor)); // Calling batch class.
    }
}