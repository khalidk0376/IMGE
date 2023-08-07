/***
*
* Class Name: WorkOrderTemplateTrigger
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

trigger WorkOrderTemplateTrigger on Work_Order_Template__c (after insert,after update) {
    CreateAndUpdateWorkOrderTemplate_handler.createupdatewotemp(Trigger.New,Trigger.oldMap , Trigger.isInsert , trigger.isUpdate , trigger.isAfter,trigger.old );
}