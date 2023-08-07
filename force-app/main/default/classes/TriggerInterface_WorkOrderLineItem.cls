/**
* File:        TriggerInterface_WorkOrderLineItem Class
* Project:     GAP
* Created Date: 06/11/2019
* Created By:  Avinash Shukla
* Modified By:  Avinash Shukla
* Test Class: WorkOrderLineItem_Trig_Test(100%)
* Coverage:
*
* *************************************************************************
* @description Description/Purpose: Triggers calls apex classes which are further call this class for initialization of record. It is only run for WorkOrderLineItem Object. Custom object used 'Trigger' and 'TriggerRecordtype'
* *************************************************************************
* History:Ticket :GGCkB-76
* Methods: Runnable
*
*/
public with sharing class TriggerInterface_WorkOrderLineItem {
  public TriggerInterface_WorkOrderLineItem(){
    System.debug('Constructor Invokation');
  }
  public interface Runnable {
    void run(TriggerInterface_WorkOrderLineItem.Trig trig);
  }
  public class Trig {
    public List<WorkOrderLineItem> oldList;
    public List<WorkOrderLineItem> newList;
    public Map<Id, WorkOrderLineItem> oldMap;
    public Map<Id, WorkOrderLineItem> newMap;
    public Integer triggerSize;
    public Boolean isBefore;
    public Boolean isAfter;
    public Boolean isInsert;
    public Boolean isUpdate;
    public Boolean isDelete;
    public Boolean isUnDelete;
    public Map<Id, Map<String, String>> mapRtIdsToParams;
  }
}