/**
* File:         TriggerInterface_Task.cls
* Created Date: 03/13/2023
* Created By:   Faisal Khan
* Test Class:   TriggerInterface_Task_Test
* Coverage:     100%
*
* ***************************************************************************************************
* @description : Interface to link the Task Handlers and TriggerInterface_Task with new and old data
* ***************************************************************************************************
* History: 
*
*/
public class TriggerInterface_Task {
  
    
    public TriggerInterface_Task(){
        system.debug('Constructor Being Called');//Added by Palla Kishore for the ticket BK-19604
    }
    
    public interface Runnable {
        void run(TriggerInterface_Task.Trig trig);
    }  
    
    public class Trig{
        public List<Task> oldList;
        public List<Task> newList;
        public Map<Id,Task> oldMap;
        public Map<Id,Task> newMap;
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