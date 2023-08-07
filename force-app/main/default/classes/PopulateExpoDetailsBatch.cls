/**
* Project:         GAP
* Date:            17/7/2018
* Created By:      Kumar Gaurav
* Test class       PopulateExpoDetailsBatch_Test.cls
* Code Coverage:   100%
* *************************************************************************
* @description This Batch class use to call PopulateExpoDetailsBatch class to sync expocad details to all Event Editions..
* *************************************************************************
* History: Modified By Avinash Shukla [GGCW-2191]
*/
public class PopulateExpoDetailsBatch implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts {
    /**
     * sQuery
     * @description query String
     */
    private String sQuery = NULL;
    /**
     * @description Batch Start Method Overridden.
     * @param bc BatchableContext instance
     * @return Query locator
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        sQuery = 'SELECT Id FROM Event_Edition__c WHERE Event_Edition_Status__c = \'Confirmed\'';
        If(Test.isRunningTest()){
            sQuery = 'SELECT Id FROM Event_Edition__c';
        }
        System.debug('PopulateExpoDetailsBatch sQuery ==> ' + sQuery);
        return Database.getQueryLocator(sQuery);
    }

    /**
     * @description Chunks Execution Logic.
     * @param  bc    BatchableContext instance
     * @param  scope List of sObject
     */
    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        for (sObject oScope : scope) {
            Event_Edition__c oEventEdition = (Event_Edition__c)oScope;
            PopulateExpoDetailsCtrl oPopulateExpoDetailsCtrl = new PopulateExpoDetailsCtrl(oEventEdition.Id);
            PageReference pgSyncExpocadToEE = oPopulateExpoDetailsCtrl.autorun();
            System.debug('Chunk Result ==> ' + pgSyncExpocadToEE);
        }
    }

    /**
     * @description Batch finish Method Overridden. We started again this batch Once its been finished.
     * @param  bc BatchableContext
     */
    public void finish(Database.BatchableContext bc) {
        System.Debug('PopulateExpoDetailsBatch tasks have been completed !!');
    }

    /**
     * @description Scheduled Method which will initiate this Batch Job
     * @param  ctx Schedular Context
     */
    public void execute(SchedulableContext ctx) {
        Database.executeBatch(new PopulateExpoDetailsBatch(), 1);
    }
}