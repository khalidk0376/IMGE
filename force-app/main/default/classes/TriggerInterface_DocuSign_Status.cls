/*
Created By: Rajesh Kr
Created On: 31-03-2020
Description/Purpose: This triggers is used for update opportunity stage and Quote Status after docusign process using this dsfs__DocuSign_Status__c object
Test Class:  
*/
public with sharing class TriggerInterface_DocuSign_Status
{
  public TriggerInterface_DocuSign_Status()
  {
      system.debug('Constructor Being Called');//Added by Palla Kishore for the ticket BK-19604
  }
  public interface Runnable 
  {
    void run(TriggerInterface_DocuSign_Status.Trig trig);
  }  
  public class Trig 
  {
    public List<dsfs__DocuSign_Status__c> oldList;
    public List<dsfs__DocuSign_Status__c> newList;
    public Map<Id,dsfs__DocuSign_Status__c> oldMap;
    public Map<Id,dsfs__DocuSign_Status__c> newMap;
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