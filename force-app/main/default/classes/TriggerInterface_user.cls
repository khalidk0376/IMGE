/*
Created By: RajeshKumar
Created On: 13-03-2020
Description/Purpose: Triggers calls apex classes which are further call this class for initialization of record. It is only run for user Object. Custom object used 'Trigger' and 'TriggerRecordtype'
Methods: Runnable
Test Class:  ManageUserPackage_Trig_Test, Automatically_Assigned_Handler_Test
*/
public with sharing class TriggerInterface_user
{
  public TriggerInterface_user()
  {
     system.debug('Constructor Being Called');//Added by Palla Kishore for the ticket BK-19604
  }
  public interface Runnable 
  {
    void run(TriggerInterface_user.Trig trig);
  }  
  public class Trig 
  {
    public List<User> oldList;
    public List<User> newList;
    public Map<Id,User> oldMap;
    public Map<Id,User> newMap;
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