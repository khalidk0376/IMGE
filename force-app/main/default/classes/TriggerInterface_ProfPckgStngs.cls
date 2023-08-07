/*Created By: {Girikon(Pramod)}
Created On: 08/30/2018
Description/Purpose: Trigger calls apex classes which are further call this class for initialization of record. 
It is only run for "Profile_Package_Setting__c" Object. Custom object used are 'Trigger__c' and 'TriggerRecordtype__c'
Implementable Interface: Runnable
Test Class: AddUpdateUserPackage_Trig_Test
 
Modification log --
Modified By: {####(####)} [Jira #]
Modified On: MM/DD/YYYY*/

public with sharing class TriggerInterface_ProfPckgStngs 
{
  public TriggerInterface_ProfPckgStngs ()
  {
      system.debug('Constructor Being Called');//Added by Palla Kishore for the ticket BK-19604
  }
  public interface Runnable 
  {
    void run(TriggerInterface_ProfPckgStngs.Trig trig);
  }  
  
  public class Trig 
  {
    public List<Profile_Package_Setting__c> oldList;
    public List<Profile_Package_Setting__c> newList;
    public Map<Id,Profile_Package_Setting__c> oldMap;
    public Map<Id,Profile_Package_Setting__c> newMap;
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