/**
 * File:        AddWorkorderTeam_handler.cls
 * Project:     GAP
 * Created Date: 10-06-2020
 * Created By:  Rajesh Kumar
 * Modified By:  Rajesh Kumar
 * Test Class: AddWoTeam_test
 * Coverage: 
 *
 * *************************************************************************
 * @description This class is using in Operations_Team_Member__c Object Trigger.
 * *************************************************************************
 * 
 * 
 * History:Ticket :BK-3756
 *
*/
public without sharing class AddWorkorderTeam_handler {
    public static void addworkorderteam(List<Operations_Team_Member__c> newOperationTeamMemberLst , Map<Id, Operations_Team_Member__c> oldmapOperationTeamMember ,Boolean isInsert, Boolean isupdate, Boolean isBefore, Boolean isAfter ,  Boolean isDelete){
        list<Operations_Team_Member__c> tempList = new list<Operations_Team_Member__c>();
        map<Id,list<Operations_Team_Member__c>> teamIds = new map<Id,list<Operations_Team_Member__c>>();
        if(isAfter && isUpdate || isInsert){
        
            for(Operations_Team_Member__c optm : newOperationTeamMemberLst){
                if(!teamIds.containsKey(optm.Operations_Team__c)){
                    tempList.add(optm);   teamIds.put(optm.Operations_Team__c,tempList); }  else{  teamIds.get(optm.Operations_Team__c).add(optm);
                }
            }
        }

        if(isAfter && isDelete){
            for(Operations_Team_Member__c ot : oldmapOperationTeamMember.values()){
                if(!teamIds.containsKey(ot.Operations_Team__c)){
                    tempList.add(ot);             teamIds.put(ot.Operations_Team__c,tempList); }  else{teamIds.get(ot.Operations_Team__c).add(ot);
                }
            }
        }
        list<Work_Order_Template__c> wotList = [select id,Operations_Team__c,(select Id,Team_Member__c from Workspace_Teams__r) from Work_Order_Template__c where Operations_Team__c IN : teamIds.keyset()];
        List<WorkOrder_Team__c > tempListNew = new List<WorkOrder_Team__c>();
        List<WorkOrder_Team__c > tempListUpdate = new List<WorkOrder_Team__c>();
        List<WorkOrder_Team__c > tempListDelete = new List<WorkOrder_Team__c>();

        for(Work_Order_Template__c wot : wotList){

            if(isAfter && isInsert){
                for(Operations_Team_Member__c otm : teamIds.get(wot.Operations_Team__c)){
                    WorkOrder_Team__c  newwoteam = new WorkOrder_Team__c();
                    newwoteam.Team_Member__c = otm.User_Name__c;
                    newwoteam.Work_Order_Template__c = wot.Id;
                    newwoteam.Notify_User__c = otm.Notify_User__c;
                    newwoteam.Team_Roles__c = otm.Team_Roles__c;
                    newwoteam.Work_Order_Owner__c = otm.Work_Order_Owner__c;
                    tempListNew.add(newwoteam);
                }
            }
            else if(isAfter && isUpdate){
                for(Operations_Team_Member__c otm : teamIds.get(wot.Operations_Team__c)){
                    for(WorkOrder_Team__c woteam : wot.Workspace_Teams__r){
                        if(oldmapOperationTeamMember.get(otm.Id).User_Name__c !=  otm.User_Name__c){
                            if(oldmapOperationTeamMember.get(otm.Id).User_Name__c == woteam.Team_Member__c){
                                woteam.Team_Member__c = otm.User_Name__c;  woteam.Notify_User__c = otm.Notify_User__c;                                woteam.Team_Roles__c = otm.Team_Roles__c;  woteam.Work_Order_Owner__c = otm.Work_Order_Owner__c;                                tempListUpdate.add(woteam);      break;
                            }
                        }
                    }   
                }
            }
            else if(isAfter && isDelete){
                for(Operations_Team_Member__c otm : teamIds.get(wot.Operations_Team__c)){
                    for(WorkOrder_Team__c woteam : wot.Workspace_Teams__r){
                        if(otm.User_Name__c == woteam.Team_Member__c){
                            tempListDelete.add(woteam);
                            break;
                        }
                    }   
                }
            }
        }

        if(!tempListNew.IsEmpty()){
            if (!Schema.sObjectType.WorkOrder_Team__c.fields.Work_Order_Template__c.isCreateable()){      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Insufficient Access'));         }
            insert tempListNew;
        }
        
        if(!tempListUpdate.IsEmpty()){
            if (!Schema.sObjectType.WorkOrder_Team__c.fields.Notify_User__c.isUpdateable()){  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Insufficient Access')); }           update tempListUpdate;
        }
        
        if(!tempListDelete.IsEmpty()){
            //if (WorkOrder_Team__c.sObjectType.getDescribe().isDeleteable()){
                delete tempListDelete;
            //}
            /*if (Schema.sObjectType.WorkOrder_Team__c.isDeleteable()){
                delete tempListDelete;
            }*/
        }

        //Added by Kadir to prevent duplicate 
        if(isBefore && isInsert){

            Map<String, string> mapOpTeamMember = new Map<String, string>();
            Set<String> setOpTeam = new Set<String>();
            
            for( Operations_Team_Member__c  otm : newOperationTeamMemberLst){
                setOpTeam .add(otm.Operations_Team__c);
            }

            for(Operations_Team_Member__c opTeamMember :[ SELECT Id, User_Name__c,User_Name__r.name FROM Operations_Team_Member__c WHERE  Operations_Team__c IN :setOpTeam ]) {   mapOpTeamMember.put(opTeamMember.User_Name__c, opTeamMember.User_Name__r.name);
            }

            for(Operations_Team_Member__c otm : newOperationTeamMemberLst){
                if(mapOpTeamMember.containsKey(otm.User_Name__c)){ otm.addError('There is already another Team Member with the name.'+ mapOpTeamMember.get(otm.User_Name__c) , true); }
            }
        }
    }
}