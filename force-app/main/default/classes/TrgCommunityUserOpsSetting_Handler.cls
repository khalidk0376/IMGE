/*
* Created By   : Girikon[Adarsh BK-3756]
* Created On   : 6/01/2020
* ***********************************************************************************************************************************************************
* Description  : This trigger calls action to check weather an Event Edition is live or not and creates user. It is called when an event setting is updated.
* ***********************************************************************************************************************************************************
* Last Modified By    : [Aishwarya BK-16456 9 June 2021]
* Test Class   : AttachDocumentCtr_Test
*/
public with sharing  class TrgCommunityUserOpsSetting_Handler{    
    public static void trgCommunityUserOpsSetting (List<Event_Settings__c> newEventSettingLst , Map<Id,Event_Settings__c>  oldmapEventSettingLst , Boolean isUpdate, Boolean isAfter ){
        set<Id> sEventIds       = new set<Id>();
        set<Id> sContId         = new set<Id>(); 
        Set<String> sConEvntIds = new set<string>();
        set<Id> exstUsrContId   = new set<Id>();
        for(Event_Settings__c oEventSetting : newEventSettingLst){
            Event_Settings__c oOldEventSetting = oldmapEventSettingLst.get(oEventSetting.Id);
            if((oOldEventSetting.Is_Event_Edition_Live__c != oEventSetting.Is_Event_Edition_Live__c || oOldEventSetting.Send_Welcome_Email__c != oEventSetting.Send_Welcome_Email__c) && oEventSetting.Is_Event_Edition_Live__c == true && oEventSetting.Send_Welcome_Email__c == true){
                sEventIds.add(oEventSetting.Event_Edition__c);
            }
        }

        System.debug('sEventIds====================='+sEventIds);
        If(sEventIds!=null && !sEventIds.IsEmpty())
        {
            if (!Schema.sObjectType.ContactEventEditionMapping__c.fields.User_Type__c.isAccessible()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Insufficient Access'));
            }
            List<ContactEventEditionMapping__c> lstCEEMApping = [SELECT id, SFContactID__c, IsEmailSent__c, User_Type__c, User_Type__r.Name FROM ContactEventEditionMapping__c WHERE SFEventEditionID__c IN :sEventIds AND SFContactID__c !=null AND User_Type__c !=null];
            if(lstCEEMApping != null && lstCEEMApping.size()>0)
            {
                for(ContactEventEditionMapping__c oCEEMapping : lstCEEMApping)
                {
                    if(oCEEMapping.IsEmailSent__c== false && oCEEMapping.User_Type__r.Name != 'Agent owned Exhibitor')
                    {
                        sContId.add(oCEEMapping.SFContactID__c);
                        sConEvntIds.add(oCEEMapping.Id);
                    } 
                }
            }
            if(sConEvntIds != null && !sConEvntIds.isEmpty())
            {
                ContactEventEditionMappingTriggerHandler conObj = new ContactEventEditionMappingTriggerHandler();  
                conObj.createCommunityUser(sConEvntIds);
            }        
        }
    }
    
    // For updating Agent Total badges
    public static void updateAgentBadges(Set<String> eventId){
        set<Id> sEventIds = new set<Id>();
        Map<String,String> MapAgentBadgeLimitDefault = new Map<String,String>();
        List<AgentEventEditionMapping__c> listAgentEventMapping = new List<AgentEventEditionMapping__c>();
        List<Event_Settings__c> listEveSetting = new List<Event_Settings__c>();
        
        listEveSetting = [Select Id, Event_Edition__c, Agent_Badge_limit__c, Is_Event_Edition_Live__c FROM Event_Settings__c where Id IN:eventId];
        for(Event_Settings__c oEventSetting : listEveSetting){
            sEventIds.add(oEventSetting.Event_Edition__c);
            MapAgentBadgeLimitDefault.put(oEventSetting.Event_Edition__c, oEventSetting.Agent_Badge_limit__c);
        }
        
        if(!sEventIds.isEmpty()){
            listAgentEventMapping = [Select Id, Account__c, EventEdition__c, Badge_Limit__c, Total_Badges_without_additonal__c, Is_Active__c FROM AgentEventEditionMapping__c where 
                                            EventEdition__c IN :sEventIds AND Is_Active__c = True];
            if(!listAgentEventMapping.isEmpty() && listAgentEventMapping.size()>0){
                for(AgentEventEditionMapping__c AgentMap : listAgentEventMapping){
                    if(!MapAgentBadgeLimitDefault.isEmpty() && MapAgentBadgeLimitDefault.containskey(AgentMap.EventEdition__c) && MapAgentBadgeLimitDefault.get(AgentMap.EventEdition__c) != null){
                        AgentMap.Total_Badges_without_additonal__c= Decimal.ValueOf(MapAgentBadgeLimitDefault.get(AgentMap.EventEdition__c)) == null?0:Decimal.ValueOf(MapAgentBadgeLimitDefault.get(AgentMap.EventEdition__c));
                    }
                    else{
                        AgentMap.Total_Badges_without_additonal__c = 0;
                    }
                }
                Database.update(listAgentEventMapping);
            }
        }
    }
}