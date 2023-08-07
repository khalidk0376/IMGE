/**
* File:        Expocad_BoothTriggerHandler.Class
* Project:     GE Informa
* Date:        Sept 24, 2019
* Created By:  Shiv Raghav Sharma
* Test class : releaseBooths_Test(97%)
* Ticket No - Bk-2262
* *************************************************************************
* Description: Trigger Handler for rull up total rented and unrented area of booth into parent opportunity
* *************************************************************************
*/

public class Expocad_BoothTriggerHandler {
    
    public Void opportunityExpoCadRollUpsummary(List<ExpocadBooth__c> newExpoCadLst,List<ExpocadBooth__c> oldExpoCadLst, Map<id, ExpocadBooth__c> oldExpocadMap,Boolean isAfter, Boolean isInsert, Boolean isupdate ,Boolean isDelete,  Boolean isUndelete )
    {        
        map<id,opportunity> oppMap = new map<id,opportunity>();            
        Set<Id> setParentOppId = new Set<Id>();
        
        if(isInsert || isUndelete ){
            for(ExpocadBooth__c Expo: newExpoCadLst) {
                if(Expo.Opportunity__c != null)
                    setParentOppId.add(Expo.Opportunity__c);
            }
        }
        
        else if(isDelete){
            for(ExpocadBooth__c Expo: oldExpoCadLst){
                if(Expo.Opportunity__c !=null)
                {
                    setParentOppId.add(Expo.Opportunity__c);
                }                        
            }
        } 
        else if(isUpdate)
        {
            for(ExpocadBooth__c Expo : newExpoCadLst){
                
                if(Expo.Opportunity__c !=null )                 
                {                                       
                    if( oldExpocadMap.get(Expo.id).Opportunity__c == Expo.Opportunity__c && (oldExpocadMap.get(Expo.id).Status__c != Expo.Status__c || oldExpocadMap.get(Expo.id).Area_Number__c != Expo.Area_Number__c ) )
                    {
                        setParentOppId.add(Expo.Opportunity__c);
                    }
                    if(oldExpocadMap.get(Expo.id).Opportunity__c != null && oldExpocadMap.get(Expo.id).Opportunity__c != Expo.Opportunity__c)
                    {
                        setParentOppId.add(Expo.Opportunity__c);  
                        setParentOppId.add(oldExpocadMap.get(Expo.id).Opportunity__c);
                    }
                    if(oldExpocadMap.get(Expo.id).Opportunity__c == null && Expo.Opportunity__c != Null) { setParentOppId.add(Expo.Opportunity__c); 
                    }
                }
            }                
        }
        
        if(setParentOppId.Size()> 0 ){  

            for(ID OppId : setParentOppId)
            {
                oppMap.put(OppId, new opportunity(Id = OppId , Total_Area_Rented__c = 0 ));
            }
            
            for(ExpocadBooth__c expo : [Select Area_Number__c ,Opportunity__c, Status__c from ExpocadBooth__c where Opportunity__c In :setParentOppId ])
            {
                if(expo.Status__c == 'Rented' && expo.Area_Number__c != null)
                {                               
                    oppMap.get(expo.Opportunity__c).Total_Area_Rented__c += expo.Area_Number__c; 
                }
            }
            
            if(oppMap.size()> 0 && oppMap != null)
            {                
                try 
                {
                    update oppMap.values();
                    System.debug('Updates Succesfully');
                } 
                catch (Exception ex) { Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'After Insert Trigger(@Expocad_BoothTriggerHandler)');
                }
            }
        }        
    }         
}