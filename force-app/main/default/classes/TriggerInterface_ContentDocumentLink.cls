/*
Created By: Garima Gupta
Created On: 01/11/2019 
Description/Purpose: Triggers calls apex classes which are further call this class for initialization of record. It is only run for ContentDocumentLink Object. Custom object used 'Trigger' and 'TriggerRecordtype'
Methods: Runnable
Test Class: ContentDocumentLink_Trig_test
*/
public with sharing class TriggerInterface_ContentDocumentLink 
{
  public TriggerInterface_ContentDocumentLink()
  {
      system.debug('Constructor Being Called');//Added by Palla Kishore for the ticket BK-19604
  }
  public interface Runnable 
  {
    void run(TriggerInterface_ContentDocumentLink.Trig trig);
  }  
  public class Trig 
  {
    public List<ContentDocumentLink> oldList;
    public List<ContentDocumentLink> newList;
    public Map<Id,ContentDocumentLink> oldMap;
    public Map<Id,ContentDocumentLink> newMap;
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