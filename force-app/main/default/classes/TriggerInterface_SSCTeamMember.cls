/*
Created By  :   Girikon[Adarsh BK-3756]
Created On  :   29/05/2020 
@Description:   Interface for generic trigger on SSCTeamMember Object.
Methods     :   Runnable
Test Class  :   OperationsTeamMemberValidation_Test [100%]
*/
public class TriggerInterface_SSCTeamMember 
{
    public TriggerInterface_SSCTeamMember() {
        system.debug('Constructor Being Called');//Added by Palla Kishore for the ticket BK-19604
    }
    public interface Runnable{
        void run(TriggerInterface_SSCTeamMember.Trig trig);
    }  
    public class Trig 
    {
        public List<SSC_Team_Member__c> oldList;
        public List<SSC_Team_Member__c> newList;
        public Map<Id,SSC_Team_Member__c> oldMap;
        public Map<Id,SSC_Team_Member__c> newMap;
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