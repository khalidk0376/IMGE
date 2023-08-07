/**
* File:        BatchRemoveAccountTeamMember
* Project:     GAP
* Date:        Aug 28, 2019
* Test Class:  BatchRemoveAccountTeamMember_test
* Created By:  Rajesh Kumar
 *************************************************************************************************************************************************
* @description :Batch to remove the Account Team Members who are not the Opportunity Owners as well as those Account Team Member who
                don't have 'Sales' and 'Sales-Brazil' Profile
 *************************************************************************************************************************************************
*
* Created By Rajesh Kumar :BK-23 /Modifed By Rajesh Kr - BK-3456 on 19-03-2020
* Modified By Rajesh Kumar :BK-5419 - 17-06-2020
*/ 

public without sharing class BatchRemoveAccountTeamMember implements Database.Batchable<sObject>, Schedulable{
    set <Id> setIds = new set<Id>();
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator('Select Id, Name From Account where inactive__c = false');
    }
    public void execute(Database.BatchableContext bc, List<Account> lstAccounts){
        try {
            for (Account oAccounts : lstAccounts){
                setIds.add(oAccounts.id);
            }
            Utility.removeAccountTeammember(setIds);
        }
        catch (Exception Ex) {         
            Utility.logsError(Ex.getMessage(), Ex.getCause(), Ex.getLineNumber(), Ex.getStackTraceString(), 'BatchRemoveAccountTeamMember' , 'Integration');
        } 
    }
    public void finish(Database.BatchableContext bc){ 
        System.debug('The Batch Executed Sucessfully');
    }
    
    public void execute(SchedulableContext ctx) {
        BatchRemoveAccountTeamMember schObj = new BatchRemoveAccountTeamMember();database.executebatch(schObj,200);
    }
}