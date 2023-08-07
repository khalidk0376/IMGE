/**
* File:        TriggerInterface_BoothApprovalDashboard.cls
* Project:     GAP
* Created Date: 07/05/2018
* Created By:  Rajesh Kumar Yadav
* Modified By:  Rajesh Kumar 
* Test Class: BoothApprovalProcess_test
* Coverage: 
*
* *************************************************************************
* @description 
* *************************************************************************
* History: 
*
*/
public with sharing class TriggerInterface_BoothApprovalDashboard{
    
    public TriggerInterface_BoothApprovalDashboard(){
        System.debug('Calling Trigger');
    }
    
    
    public interface Runnable {
        void run(TriggerInterface_BoothApprovalDashboard.Trig trig);
    }  
    
    public class Trig{
        public List<Booth_Approval_Dashboard__c> oldList;
        public List<Booth_Approval_Dashboard__c> newList;
        public Map<Id,Booth_Approval_Dashboard__c> oldMap;
        public Map<Id,Booth_Approval_Dashboard__c> newMap;
        public Integer triggerSize;
        public Boolean isBefore;
        public Boolean isAfter;
        public Boolean isInsert;
        public Boolean isUpdate;
        public Boolean isDelete;
        public Boolean isUnDelete;
        public Map<Id,Map<String,String>> mapRtIdsToParams;
    }
}