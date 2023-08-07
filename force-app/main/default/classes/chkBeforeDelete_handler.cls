/**
 * File:        chkBeforeDelete_handler.cls
 * Project:     GAP
 * Created Date: 10-06-2020
 * Created By:  Rajesh Kumar
 * Modified By:  Rajesh Kumar
 * Test Class: Test_checkbeforeDelete
 * Coverage: 
 *
 * *************************************************************************
 * @description This class is using in CPQ_Product_Clone__c Object Trigger.
 * *************************************************************************
 * 
 * 
 * History:Ticket :BK-3756
 *
*/

public without sharing class chkBeforeDelete_handler {
    public static void chkBeforeDelete(List<CPQ_Product_Clone__c> newCPQProdcutCloneLst , Map<Id, CPQ_Product_Clone__c> oldmapCPQProdcutClone , Boolean isDelete, Boolean isBefore ){
        Map<Id, List<CPQ_Clone_Progress__c>> mapClonedPrdwithClonedProgress = new Map<Id, List<CPQ_Clone_Progress__c>>();
        list<Id> lstCPQPrdIds = new list<Id>();
        for (CPQ_Product_Clone__c  oCPC : oldmapCPQProdcutClone.values()) {
            lstCPQPrdIds.add(oCPC.id);
        }
        for(CPQ_Clone_Progress__c oCCP : [SELECT Id, CPQ_Product_Clone__c FROM CPQ_Clone_Progress__c WHERE CPQ_Product_Clone__c IN:lstCPQPrdIds LIMIT 5000]){
            if(mapClonedPrdwithClonedProgress.containsKey(oCCP.CPQ_Product_Clone__c)){                mapClonedPrdwithClonedProgress.get(oCCP.CPQ_Product_Clone__c).add(oCCP);
            }
            else{
                mapClonedPrdwithClonedProgress.put(oCCP.CPQ_Product_Clone__c, new List<CPQ_Clone_Progress__c>{oCCP});
            }
        }
        for (CPQ_Product_Clone__c  oCPC : oldmapCPQProdcutClone.values()) {
            if(oCPC.Cloned__c && mapClonedPrdwithClonedProgress.containsKey(oCPC.Id) && mapClonedPrdwithClonedProgress.get(oCPC.Id) != null && mapClonedPrdwithClonedProgress.get(oCPC.Id).Size() > 0){
                oCPC.addError('First Delete the cloned products');
            }
        }
    }
}