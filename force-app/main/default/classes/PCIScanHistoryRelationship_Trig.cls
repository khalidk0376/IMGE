/**
 * File:        PCIScanHistoryRelationship_Trig  .cls
 * Project:     GAP
 * Created Date: 03/09/2019
 * Created By:  Rajesh Kumar
 * Modified By:  Rajesh Kumar
 * Test Class: zTest_PCI
 * Coverage: 
 *
 * *************************************************************************
 * @description This class is using in "Opportunity Trigger Management app" Trigger.
 * *************************************************************************
 * 
 * 
 * History:Ticket :BK-3756
 *
*/
public with sharing class PCIScanHistoryRelationship_Trig {
    List<PCI_Scan_History__c> newPCIScanHistoryLst          {get;set;}
    Map<Id, PCI_Scan_History__c > mapPCIScanHistoryMapLst   {get;set;}
    Boolean isinsert                                        {get;set;}
    Boolean isUpdate                                        {get;set;}
    Boolean isAfter                                         {get;set;}

    public PCIScanHistoryRelationship_Trig(List<PCI_Scan_History__c> newPCIScanHistoryLst, Map<Id, PCI_Scan_History__c > mapPCIScanHistoryMapLst , Boolean isinsert,Boolean isUpdate,Boolean isAfter) {
        this.newPCIScanHistoryLst    = newPCIScanHistoryLst;
        this.mapPCIScanHistoryMapLst = mapPCIScanHistoryMapLst;
        this.isInsert     = isInsert;
        this.isupdate     = isupdate;
        this.isAfter      = isAfter;
    }

    public void pciScanHistoryRelationships(){
        Map<String,Id> mapIds = new Map<String,Id>();
        List<string> systemScanIds = new List<string>();
        String ids = ''; 

        for (Integer i=0;i<newPCIScanHistoryLst.size();i++)   
        {
            systemScanIds.add(newPCIScanHistoryLst[i].System_Scan_Id__c);
            mapIds.put(newPCIScanHistoryLst[i].System_Scan_Id__c, newPCIScanHistoryLst[i].Id);

            ids = ids + ', \'' + newPCIScanHistoryLst[i].System_Scan_Id__c + '\''; 
        } 
        
        if (systemScanIds.size() > 0)  
        {
            String query = 'Select Id,System_Scan_Id__c  from PCI_Credit_Card_Numbers__c Where PCI_Scan_History__c = null and System_Scan_Id__c IN (' + ids.substring(1, ids.length()).trim() + ')';
            System.debug('*****SELECT=' + query);
            PCIScanHistoryRelationship checkCNN = new PCIScanHistoryRelationship();
            checkCNN.query = query;
            checkCNN.isTesting = false;
            checkCNN.systemScanIds = systemScanIds ; 
            checkCNN.mapIds = mapIds;
            ID batchprocessid = Database.executeBatch(checkCNN);
        }
    }
}