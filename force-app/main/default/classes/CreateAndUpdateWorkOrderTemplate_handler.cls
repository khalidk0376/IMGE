/***
*
* Class Name: CreateAndUpdateWorkOrderTemplate_handler
* Date:  31/1/2019 
* Created By : Rajesh Kumar 
* Created Date : 13/02/2019
* Test Class: createAndUpdateWorkOrderTeam_test
* Ticket: GGCW-3124
* ***********************************************************************************************************************************************
* @description : WorkOrderTemplateTrigger object "Work_Order_Template__c"
* ***********************************************************************************************************************************************\
* Modified By  : Rajesh Kumar - BK-3756 on 10-06-2020
*
**/
public with sharing class CreateAndUpdateWorkOrderTemplate_handler {

    public static void createupdatewotemp(List<Work_Order_Template__c> newWorkOrderTemplateLst, Map<id, Work_Order_Template__c> oldWorkOrderTemplate, Boolean isInsert, Boolean isupdate,Boolean isAfter , List <Work_Order_Template__c>  oldWorkOrderTemplatelst ){

        list<Operations_Team_Member__c> lstOpTeamMember = new list<Operations_Team_Member__c>();
        Map<String,Id> mapOpTeam = new Map<String,Id>();
        list<WorkOrder_Team__c> insertWorkOrderteam = new list<WorkOrder_Team__c>();
        list<WorkOrder_Team__c> deleteWOTeam = new list<WorkOrder_Team__c>();
        set<Id> oldOperationTeam=new set<Id>();
        set<Id> newOperationTeam = new set<Id>();
        set<Id> listOPMember=new set<Id>();

        for(Work_Order_Template__c workOT: newWorkOrderTemplateLst){
            mapOpTeam.put(workOT.Operations_Team__c,workOT.Id);
            newOperationTeam.add(workOT.Operations_Team__c);
        }

        if(isAfter && isUpdate){
            for(Work_Order_Template__c temp : oldWorkOrderTemplate.values()){
                oldOperationTeam.add(temp.Operations_Team__c);
            }
            
            for(Operations_Team_Member__c objotm : [select id,Name,Notify_User__c,Team_Roles__c,User_Name__c,User_Name__r.Name,Work_Order_Owner__c,Operations_Team__c from Operations_Team_Member__c where Operations_Team__c IN :oldOperationTeam]){
                listOPMember.add(objotm.User_Name__c);            
            }

            for(WorkOrder_Team__c objTemp :[select id,Team_Member__c,Team_Member__r.Name,Work_Order_Template__r.OPerations_Team__c from WorkOrder_Team__c where Work_Order_Template__c IN : oldWorkOrderTemplatelst]){

                if(listOPMember.contains(objTemp.Team_Member__c)){
                    deleteWOTeam.add(objTemp);
                }
                else{
                    for(Id objcompare : newOperationTeam){
                        if(!oldOperationTeam.contains(objcompare)){
                            deleteWOTeam.add(objTemp);
                        }
                    }
                }
            }

            if(!deleteWOTeam.isEmpty()){
                delete deleteWOTeam;
            }
        }
        if (!Schema.sObjectType.Operations_Team_Member__c.fields.Notify_User__c.isAccessible() || !Schema.sObjectType.Operations_Team_Member__c.fields.User_Name__c.isAccessible() ){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Insufficient Access'));
        }
        lstOpTeamMember = [SELECT id,Name,Notify_User__c,Team_Roles__c,User_Name__c,Work_Order_Owner__c,Operations_Team__c from Operations_Team_Member__c where Operations_Team__c IN : mapOpTeam.keySet()];

        if(!mapOpTeam.isEmpty()){
            for(Operations_Team_Member__c objotm : lstOpTeamMember){
                WorkOrder_Team__c objWorkOT = new WorkOrder_Team__c();
                objWorkOT.Notify_User__c = objotm.Notify_User__c;
                objWorkOT.Team_Member__c = objotm.User_Name__c;
                objWorkOT.Team_Roles__c = objotm.Team_Roles__c;
                objWorkOT.Work_Order_Owner__c = objotm.Work_Order_Owner__c;
                objWorkOT.Work_Order_Template__c = mapOpTeam.get(objotm.Operations_Team__c );
                insertWorkOrderteam.add(objWorkOT);
            }
        }
        if(!insertWorkOrderteam.isEmpty()){
            if (!Schema.sObjectType.WorkOrder_Team__c.fields.Notify_User__c.isCreateable()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Insufficient Access'));
            }
            insert insertWorkOrderteam;
        }
    }
}