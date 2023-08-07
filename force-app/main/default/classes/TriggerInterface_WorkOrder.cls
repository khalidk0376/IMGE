/**
 * File:        Trigger_WorkOrder trigger
 * Project:     GAP
 * Created Date: 14/05/2019
 * Created By:  Rajesh Kumar
 * Modified By:  Rajesh Kumar
 * Test Class: 
 * Coverage: 
 *
 * *************************************************************************
 * @description Description/Purpose: Triggers calls apex classes which are further call this class for initialization of record. It is only run for WorkOrder Object. Custom object used 'Trigger' and 'TriggerRecordtype'
 * *************************************************************************
 * History:Ticket :GGCkB-76
 * Methods: Runnable
 *
*/
public with sharing class TriggerInterface_WorkOrder {
  public TriggerInterface_WorkOrder() { 
     system.debug('Constructor Being Called');//Added by Palla Kishore for the ticket BK-19604
  }
  public interface Runnable {
    void run(TriggerInterface_WorkOrder.Trig trig);
  }  
  public class Trig {
    public List<WorkOrder> oldList;
    public List<WorkOrder> newList;
    public Map<Id,WorkOrder> oldMap;
    public Map<Id,WorkOrder> newMap;
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