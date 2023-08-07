/*
Created By: Rajeev Mishra
Created On: 24-03-2020
Description/Purpose: Triggers calls apex classes which are further call this class for initialization of record. It is only run for Attachment Object. Custom object used 'Trigger' and 'TriggerRecordtype'
Methods: Runnable
Test Class: ManageAttachment_Trig_Test
*/
public with sharing class TriggerInterface_Attachment
{
  public TriggerInterface_Attachment()
  {
      system.debug('Constructor Being Called');//Added by Palla Kishore for the ticket BK-19604
  }
  public interface Runnable 
  {
    void run(TriggerInterface_Attachment.Trig trig);
  }  
  public class Trig 
  {
    public List<Attachment> oldList;
    public List<Attachment> newList;
    public Map<Id,Attachment> oldMap;
    public Map<Id,Attachment> newMap;
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