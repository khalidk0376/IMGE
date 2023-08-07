/*
Created By: Rajesh Kumar
Created On: 10-06-2020
Description/Purpose: Triggers calls apex classes which are further call this class for initialization of record. It is only run for Account Legal Entity Object. Custom object used 'Trigger' and 'TriggerRecordtype'
Methods: Runnable
Test Class:  CreditNoteTrigger_Test
*/
public with sharing class TriggerInterface_Credit_Note
{
  public TriggerInterface_Credit_Note()
  {
      system.debug('Constructor Being Called');//Added by Palla Kishore for the ticket BK-19604
  }
  public interface Runnable 
  {
    void run(TriggerInterface_Credit_Note.Trig trig);
  }  
  public class Trig 
  {
    public List<blng__CreditNote__c> oldList;
    public List<blng__CreditNote__c> newList;
    public Map<Id,blng__CreditNote__c> oldMap;
    public Map<Id,blng__CreditNote__c> newMap;
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