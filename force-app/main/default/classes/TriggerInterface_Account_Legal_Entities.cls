/*
Created By: Rajesh Kumar
Created On: 10-06-2020
Description/Purpose: Triggers calls apex classes which are further call this class for initialization of record. It is only run for Account Legal Entity Object. Custom object used 'Trigger' and 'TriggerRecordtype'
Methods: Runnable
Test Class:  
*/
public with sharing class TriggerInterface_Account_Legal_Entities
{
  public TriggerInterface_Account_Legal_Entities()
  {
      system.debug('Constructor Being Called');//Added by Palla Kishore for the ticket BK-19604
  }
  public interface Runnable 
  {
    void run(TriggerInterface_Account_Legal_Entities.Trig trig);
  }  
  public class Trig 
  {
    public List<Account_Legal_Entity__c> oldList;
    public List<Account_Legal_Entity__c> newList;
    public Map<Id,Account_Legal_Entity__c> oldMap;
    public Map<Id,Account_Legal_Entity__c> newMap;
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