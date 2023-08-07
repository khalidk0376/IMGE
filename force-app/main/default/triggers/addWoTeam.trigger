/**
 * File:        addWoTeam.trg
 * Project:     GAP
 * Created Date: 10-06-2020
 * Created By:  Rajesh Kumar
 * Modified By:  Rajesh Kumar
 * Test Class: 
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
trigger addWoTeam on Operations_Team_Member__c (before insert,after insert, after update, after delete) {
    AddWorkorderTeam_handler.addworkorderteam(trigger.new , trigger.oldMap ,trigger.isInsert, trigger.isUndelete, trigger.isBefore, trigger.isAfter, trigger.isDelete );
}