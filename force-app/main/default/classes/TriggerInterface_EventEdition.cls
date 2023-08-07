/*
Created By:   Girikon[Aishwarya CCEN-658]
Created On:   Feb 20 2019 
@Description: Interface for generic trigger on Event Edition Object.
Methods:      Runnable
Test Class:   BadgesAssignmentByBoothType_Test 
*/
public with sharing class TriggerInterface_EventEdition 
{
  public TriggerInterface_EventEdition (){ 
      System.debug('Trigger Called');
  }
  public interface Runnable 
  {
    void run(TriggerInterface_EventEdition.Trig trig);
  }  
  public class Trig 
  {
    public List<Event_Edition__c> oldList;
    public List<Event_Edition__c> newList;
    public Map<Id,Event_Edition__c> oldMap;
    public Map<Id,Event_Edition__c> newMap;
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