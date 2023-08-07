/**
* File:        TriggerInterface_Lead
* Project:     GAP
* Created Date: 22/09/2019
* Created By:  Adarsh Sharma
* Test Class: UpdtESeriesPopultOppContcs_class_test
* Coverage: 
*
* *******************************************************************************************************
* @description : Interface Class to provide Trigger values to the 'UpdateEventSeries_Trig' 
* *******************************************************************************************************
* History: 
*/

public with sharing class TriggerInterface_Lead {
    public TriggerInterface_Lead(){
        system.debug('Constructor Being Called');//Added by Palla Kishore for the ticket BK-19604
    }
        
    public interface Runnable {
        void run(TriggerInterface_Lead.Trig trig);
    }  
    
    public class Trig {
        public List<Lead> oldList;
        public List<Lead> newList;
        public Map<Id,Lead> oldMap;
        public Map<Id,Lead> newMap;
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