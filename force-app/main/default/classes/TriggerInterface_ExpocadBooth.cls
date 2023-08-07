/*
Created By:   Girikon[Aishwarya CCEN-658]
Created On:   Feb 20 2019 
@Description: Interface for generic trigger on Event Edition Object.
Methods:      Runnable
Test Class:   BadgesAssignmentByBoothType_Test 
*/
public with sharing class TriggerInterface_ExpocadBooth 
{
  public TriggerInterface_ExpocadBooth (){
     system.debug('Constructor Being Called');//Added by Palla Kishore for the ticket BK-19604
  }
  public interface Runnable 
  {
    void run(TriggerInterface_ExpocadBooth.Trig trig);
  }  
  public class Trig 
  {
    public List<ExpocadBooth__c> oldList;
    public List<ExpocadBooth__c> newList;
    public Map<Id,ExpocadBooth__c> oldMap;
    public Map<Id,ExpocadBooth__c> newMap;
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