/*
* Project:     GAP
* Date:        20/05/2019
* Created By:  Rajesh Kumar 
* Test class   UpdateEventPicklist_Test.cls
* *************************************************************************
* @description
* *************************************************************************
* History:
* Trigger : UpdateEventPicklistTrg 
* Modified By:Rajesh Kumar [GGCW-3103] , Rajesh Kr 28-02-2020 - BK-3581 
 */

trigger UpdateEventPicklistTrg on Product2 (before insert, after insert, after update, before update) {
  UpdateEventPicklist_Class objUpdateEventPicklist_Class = new UpdateEventPicklist_Class(Trigger.new, Trigger.oldMap, Trigger.newMap, Trigger.isInsert, Trigger.isupdate, Trigger.isBefore, Trigger.isAfter);
 /* if (Trigger.isBefore && Trigger.isInsert){
      objUpdateEventPicklist_Class.beforeinsertMethod();
  } */
  if (Trigger.isBefore && Trigger.isUpdate){
      objUpdateEventPicklist_Class.beforeUpdateMethod();
  }
  
  if (Trigger.isAfter){
    objUpdateEventPicklist_Class.afterUpdateInsertMethod();
  }
}