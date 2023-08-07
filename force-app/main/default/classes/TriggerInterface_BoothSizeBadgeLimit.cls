/*
Created By:   Girikon[Aishwarya BK-9194]
Created On:   19 Oct 2020
@Description: Interface for generic trigger on Booth Size Badge Limit Object.
Methods:      Runnable
Test Class:    
*/
public with sharing class TriggerInterface_BoothSizeBadgeLimit 
{
  public TriggerInterface_BoothSizeBadgeLimit(){
      system.debug('Constructor Being Called');//Added by Palla Kishore for the ticket BK-19604
  }
  public interface Runnable 
  {
    void run(TriggerInterface_BoothSizeBadgeLimit.Trig trig);
  }  
  public class Trig 
  {
    public List<Booth_Size_Badge_Limit__c> oldList;
    public List<Booth_Size_Badge_Limit__c> newList;
    public Map<Id,Booth_Size_Badge_Limit__c> oldMap;
    public Map<Id,Booth_Size_Badge_Limit__c> newMap;
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