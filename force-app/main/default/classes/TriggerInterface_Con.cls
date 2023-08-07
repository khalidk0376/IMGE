/*
Created By: Girikon(Prashant)
Created On: 12/03/2018 
Description/Purpose: Interface for generic trigger on Contact Object.
Methods: Runnable
Test Class: UpdateContactEmailOnUser_Handler_Test
*/
public with sharing class TriggerInterface_Con 
{
  public TriggerInterface_Con()
  {
      system.debug('Constructor Being Called');//Added by Palla Kishore for the ticket BK-19604
  }
  public interface Runnable 
  {
    void run(TriggerInterface_Con.Trig trig);
  }  
  public class Trig 
  {
    public List<Contact> oldList;
    public List<Contact> newList;
    public Map<Id,Contact> oldMap;
    public Map<Id,Contact> newMap;
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