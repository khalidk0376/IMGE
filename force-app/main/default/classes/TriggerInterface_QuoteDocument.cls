/*
Created By: Rajesh Kr
Created On: 31-03-2020
Description/Purpose: This triggers is used for update opportunity stage and Quote Status after docusign process using this SBQQ__QuoteDocument__c object
Test Class:  
*/
public with sharing class TriggerInterface_QuoteDocument
{
  public TriggerInterface_QuoteDocument()
  {
      system.debug('Constructor Being Called');//Added by Palla Kishore for the ticket BK-19604
  }
  public interface Runnable 
  {
    void run(TriggerInterface_QuoteDocument.Trig trig);
  }  
  public class Trig 
  {
    public List<SBQQ__QuoteDocument__c> oldList;
    public List<SBQQ__QuoteDocument__c> newList;
    public Map<Id,SBQQ__QuoteDocument__c> oldMap;
    public Map<Id,SBQQ__QuoteDocument__c> newMap;
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