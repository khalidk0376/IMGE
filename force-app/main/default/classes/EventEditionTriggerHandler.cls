public with sharing class EventEditionTriggerHandler implements TriggerInterface_EventEdition.Runnable {
    
    public void run(TriggerInterface_EventEdition.Trig trig){
         try {
             System.debug('EventEditionTriggerHandler 1');
             Set<ID> eventEditionIdSet = new Set<ID>(); 
             for(Event_Edition__c rec : trig.newList){
                 System.debug('EventEditionTriggerHandler 2');
                 if(trig.isAfter && trig.isUpdate){// && rec.x3E_API_ID__c.toLowerCase() != trig.oldMap.get(rec.Id).x3E_API_ID__c.toLowerCase() && String.isBlank(trig.oldMap.get(rec.Id).x3E_API_ID__c)
                     if((String.isNotBlank(rec.x3E_API_ID__c)  && rec.x3E_API_ID__c != trig.oldMap.get(rec.Id).x3E_API_ID__c && rec.X3E_Status__c == 'Active' && rec.X3rd_Party_Relationship__c == '3E ExpoCAD') 
                        || (rec.X3E_Status__c != trig.oldMap.get(rec.Id).X3E_Status__c && rec.X3E_Status__c == 'Active' && rec.X3rd_Party_Relationship__c == '3E ExpoCAD' && String.isNotBlank(rec.x3E_API_ID__c))
                        || (rec.X3rd_Party_Relationship__c != trig.oldMap.get(rec.Id).X3rd_Party_Relationship__c && rec.X3rd_Party_Relationship__c == '3E ExpoCAD' && rec.X3E_Status__c == 'Active'  && String.isNotBlank(rec.x3E_API_ID__c))){
                            eventEditionIdSet.add(rec.Id);
                            System.debug('EventEditionTriggerHandler 3');
                     }
                 }
             }
             if(eventEditionIdSet != null && !eventEditionIdSet.isEmpty()){
                 System.debug('EventEditionTriggerHandler 4');
                 Id JobId = Database.executeBatch(new InitiateExhibitorInviteBatch(eventEditionIdSet),1);
             }
         }catch (Exception e){System.debug('Ex--'+e);
         } 
    }
    
    

}