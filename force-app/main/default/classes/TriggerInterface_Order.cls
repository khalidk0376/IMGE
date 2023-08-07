/*
Created By  :   Girikon[Adarsh BK-3756]
Created On  :   6/01/2020  
@Description:   Interface for generic trigger on Order Object.
Methods     :   Runnable
Coverage    :   100%
Test Class  :   OnlyOneMainOrder_Test
*/
public class TriggerInterface_Order{
    
    public TriggerInterface_Order() {
        system.debug('Constructor Being Called');//Added by Palla Kishore for the ticket BK-19604
    }
    public interface Runnable{
        void run(TriggerInterface_Order.Trig trig);
    }  
    public class Trig 
    {
        public List<Order> oldList;
        public List<Order> newList;
        public Map<Id,Order> oldMap;
        public Map<Id,Order> newMap;
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