/**
* File:        BatchDeleteErrorLogs.cls
* Project:     BAU
* Date:        Oct 24, 2019
* Test Class:  BatchDeleteBlngErrorLogs_Test
* Created By:  Akshi Arora
* *************************************************************************
* @description: Deleting Error Log records which are 60 days older.
* *************************************************************************
*/
public class BatchDeleteErrorLogs Implements Database.batchable<sobject>,Schedulable {
   final string query = 'select Id FROM Error_Log__c WHERE createddate != LAST_N_DAYS:90';
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
     BatchDeleteErrorLogs schObj = new BatchDeleteErrorLogs();
     database.executebatch(schObj,200);
    }
 }