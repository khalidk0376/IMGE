/**
 * Created By:  Girikon(Shashank)
 * Created On:  20/08/2018
 * Modified by :  Girikon(Shashank)
 * Modified On: 20/08/2018
 * Description:This trigger class on Stand_Design__c object provides following functionalities:         
 *              -copy the  Booth_Design_Status__c fields of stand design to boothcontarctorMapping status field.        
 * handler Class : StandDesignTriggerHandler
 * Test Class   : StandDesignTrigger_Test(100%)
 **/
trigger StandDesignTrigger on Stand_Design__c (after update, after insert) {
    if(trigger.isAfter && (Trigger.isUpdate|| Trigger.isInsert)){
        // method to copy the  Booth_Design_Status__c fields of stand design to boothcontarctorMapping status field.    
        StandDesignTriggerHandler.updateBoothContractorMapping(Trigger.new);
    }
}