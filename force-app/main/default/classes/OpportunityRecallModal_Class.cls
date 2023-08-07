/**
* Project:     GAP
* Date:        27/05/2019
* Created By:  Rajesh Kumar
* Test Class:  OpportunityNotesAttachmentActivity_Test 
* *************************************************************************
* @Description Recall Opportunity .
* *************************************************************************
* History:
*/


public with sharing class OpportunityRecallModal_Class {
    @AuraEnabled
    public Static void updateOpp (Id oppId){
        Map<Id , Opportunity> mapOpportunity  = new Map<Id , Opportunity>([Select Id , Status__c , StageName from Opportunity where Id = : oppId]);
        for (Opportunity opp: mapOpportunity.values()){
        	opp.StageName = 'Customize';
        	opp.Status__c = 'Recalled';
        }
        update mapOpportunity.values(); 
    }
}