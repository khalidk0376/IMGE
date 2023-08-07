/**
 * File:        TriggerInterface_QuoteLine
 * Project:     GAP
 * Created Date: 03/06/2019
 * Created By:  Rajesh Kumar
 * Modified By:  Rajesh Kumar
 * Test Class: 
 * Coverage: 
 *
 * *************************************************************************
 * @description Triggers calls apex classes which are further call this class for initialization of record. It is only run for WorkOrder Object. Custom object used 'Trigger' and 'TriggerRecordtype'
 * *************************************************************************
 * History:Ticket :
 * Methods: Runnable
 *
*/
public with sharing class TriggerInterface_QuoteLine {

  /**
   * [TriggerInterface_QuoteLine description blank interface method]
   * @return [description blank]
   */
  public TriggerInterface_QuoteLine() {
    System.debug('Calling Trigger');
  }
  /**
   * Runnable interface while apex handler.
   */
  public interface Runnable {
    void run(TriggerInterface_QuoteLine.Trig trig);
  }
  /**
   * Trig class used to handle event on handler.
   */
  public class Trig {
    public List<SBQQ__QuoteLine__c > oldList;
    public List<SBQQ__QuoteLine__c > newList;
    public Map<Id,SBQQ__QuoteLine__c > oldMap;
    public Map<Id,SBQQ__QuoteLine__c > newMap;
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