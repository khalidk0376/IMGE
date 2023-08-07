/*
Created By: Avinash Singh
Created On: 07/05/2018 
Description/Purpose: Triggers calls apex classes which are further call this class for initialization of record. It is only run for Opportunity Object. Custom object used 'Trigger' and 'TriggerRecordtype'
Methods: Runnable
Test Class:  ManageUserPackage_Trig_Test
*/
public with sharing class TriggerInterface_Opp 
{
  public TriggerInterface_Opp()
  {
      system.debug('Constructor Being Called');//Added by Palla Kishore for the ticket BK-19604
  }
  public interface Runnable 
  {
    void run(TriggerInterface_Opp.Trig trig);
  }  
  public class Trig 
  {
    public List<Opportunity> oldList;
    public List<Opportunity> newList;
    public Map<Id,Opportunity> oldMap;
    public Map<Id,Opportunity> newMap;
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