/**
* File:        BatchDeleteExpocadErrors.cls
* Project:     BAU
* Date:        Oct 24, 2019
* Test Class:  BatchDeleteExpocadErrors_Test.cls
* Created By:  Akshi Arora
* *************************************************************************
* @description: Deleting Expocad Error records which are 60 days older.
* *************************************************************************
*/
public class BatchDeleteExpocadErrors Implements Database.batchable<sobject>,Schedulable {
   final string query = 'Select Id FROM Expocad_Error__c WHERE createddate != LAST_N_DAYS:90';
    public Database.QueryLocator start(Database.BatchableContext BC){
       return Database.getQueryLocator(query);
    }
     public  void execute(Database.BatchableContext BC,List<SObject> scope){
        delete scope;
    }
    public void finish(Database.BatchableContext BC){
        System.debug('Batch has been removed record successfully.');
    }
    public void execute(SchedulableContext SC) {
     BatchDeleteExpocadErrors schObj = new BatchDeleteExpocadErrors();
     database.executebatch(schObj,200);
    }
}