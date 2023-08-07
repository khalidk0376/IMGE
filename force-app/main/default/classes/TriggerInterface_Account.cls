/**
* File:         TriggerInterface_Account.cls
* Project:      GAP
* Created Date: 01/04/2020
* Created By:   Adarsh Sharma
* Test Class:   AccountCreditStatusHold_Test
* Coverage:     100%
*
* ***************************************************************************************************
* @description : Interface to link the Account Handlers and Trigger_Account with new and old data
* ***************************************************************************************************
* History: 
*
*/
public with sharing class TriggerInterface_Account{
    
    public TriggerInterface_Account(){
        system.debug('Constructor Being Called');//Added by Palla Kishore for the ticket BK-19604
    }
    
    public interface Runnable {
        void run(TriggerInterface_Account.Trig trig);
    }  
    
    public class Trig{
        public List<Account> oldList;
        public List<Account> newList;
        public Map<Id,Account> oldMap;
        public Map<Id,Account> newMap;
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