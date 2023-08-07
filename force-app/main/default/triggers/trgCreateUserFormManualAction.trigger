/**https://informage--baudev.cs125.my.salesforce.com/_ui/common/apex/debug/ApexCSIPage#
 * Date:        9/8/2017
 * Created By/Modified By: Amish Ranjit, Pramod Kumar 
 * *************************************************************************
 * Description: This trigger calles action to create record for "UserFormAction" and "UserManualAction" when a new record for ContactEventEditionMapping__c is created.*  
 * Test class : trgCreateUserFormManualAction_Test (100%)
 * ************************************************************************** 
 **/

trigger trgCreateUserFormManualAction on ContactEventEditionMapping__c (after insert) 
{
    //After Insert call of Apex Handler Class
    ContactEventEditionMappingTriggerHandler handler=new ContactEventEditionMappingTriggerHandler();
    System.Debug('####### In trgCreateUserFormManualAction on ContactEventEditionMapping__c #######');
    handler.handleAfterInsert(Trigger.new);
}