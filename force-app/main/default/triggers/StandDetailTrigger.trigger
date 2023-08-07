/**
* Created By:  Girikon(Shashank)
* Created On:  20/08/2018
* Modified by :  Girikon(Shashank)
* Modified On: 20/08/2018
* Description: This is a trigger on Stand_Design__c object on after update and insert.It provides following functionalities:      
*             -copy the  stand details fields to boothcontarctorMapping fields.    
* handler Class : StandDesignTriggerHandler
* Test Class    : StandDetailTrigger_Test(100%)
**/
trigger StandDetailTrigger on Stand_Detail__c (after update, after insert )
{
    if(trigger.isAfter && (Trigger.isUpdate|| Trigger.isInsert))
    {
        // method to copy the  Booth_Design_Status__c fields of stand design to boothcontarctorMapping status field.  
       StandDetailTriggerHandler.updateBoothContractorMapping(trigger.new);
    }
}