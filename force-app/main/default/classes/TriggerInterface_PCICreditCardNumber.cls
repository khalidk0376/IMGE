/*
Created By: Rajesh Kumar    
Created On: 10-06-2020
Description/Purpose: Triggers calls apex classes which are further call this class for initialization of record. It is only run for Opportunity Object. Custom object used 'Trigger' and 'TriggerRecordtype'
Methods: Runnable
Test Class:  
*/

//Ticket No. BK-14521 Updating API Version

public with sharing class TriggerInterface_PCICreditCardNumber {
    
    public TriggerInterface_PCICreditCardNumber() {
        system.debug('Constructor Being Called');//Added by Palla Kishore for the ticket BK-19604
    }
    public interface Runnable 
    {
        void run(TriggerInterface_PCICreditCardNumber.Trig trig);
    }  
    public class Trig 
    {
        public List<PCI_Credit_Card_Numbers__c> oldList;
        public List<PCI_Credit_Card_Numbers__c> newList;
        public Map<Id,PCI_Credit_Card_Numbers__c> oldMap;
        public Map<Id,PCI_Credit_Card_Numbers__c> newMap;
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