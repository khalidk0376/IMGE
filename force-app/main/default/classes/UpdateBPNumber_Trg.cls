/**
 * File:        UpdateBPNumber_Trg.cls
 * Project:     GAP
 * Created Date: 10-06-2020
 * Created By:  Rajesh Kumar
 * Modified By:  Rajesh Kumar
 * Test Class: 
 * Coverage: 
 *
 * *************************************************************************
 * @description This class is using in "Trigger Management App" Trigger.
 * *************************************************************************
 * 
 * 
 * History:Ticket : BK-3756
 *
*/
public with sharing class UpdateBPNumber_Trg implements TriggerInterface_Account_Legal_Entities.Runnable {
    public void run(TriggerInterface_Account_Legal_Entities.Trig trig){
    
         Map<ID,String> accIdMap = new Map<ID,String>();
         for(Account_Legal_Entity__c oALE : trig.newList){
           accIdMap.Put(oALE.Account__c,oALE.Business_Partner_Number__c ); 
         }

         List<Account> accList = [SELECT id,Business_Partner_Number__c from Account WHERE id IN: accIdMap.keySet()];
         for(Account acc : accList ){
            acc.Business_Partner_Number__c=accIdMap.get(acc.Id); 
         }
         if(!accList.isEmpty()){
         
               update accList ;
         }
    }

}