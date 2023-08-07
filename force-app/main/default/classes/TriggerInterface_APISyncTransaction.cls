/**
* File:         TriggerInterface_APISyncTransaction
* Project:      3E Expocad Integration 
* Created Date: 18th april 2022 
* Created By:   Girikon
* Test Class:   APISyncFromAPITransaction_Test
* Coverage:     100%
* *******************************************************************************************************
* @description : Interface Class to provide Trigger values.
* *******************************************************************************************************
*Modified By  : Aradhana(Girikon)[EX-7]
*/

public with sharing class TriggerInterface_APISyncTransaction
{
    /**
    * @description : Constructor for TriggerInterface_APISyncTransaction
    */
    public TriggerInterface_APISyncTransaction()
    { 
        System.debug(logginglevel.DEBUG,'Calling TriggerInterface_APISyncTransaction class!');
    }
    /**
    * @description : Runnable interface for TriggerInterface_APISyncTransaction
    */
    public interface Runnable
    {
        /**
        * @description  method run
        * @param  trig
        */
        void run(TriggerInterface_APISyncTransaction.Trig trig);
    }  
    /**
    * @description : Inner class to fetch all the parameters related to API_Synchronization_Transaction__c.
    */
    public class Trig 
    {
        public List<API_Synchronization_Transaction__c> oldList;
        public List<API_Synchronization_Transaction__c> newList;
        public Map<Id,API_Synchronization_Transaction__c> oldMap;
        public Map<Id,API_Synchronization_Transaction__c> newMap;
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