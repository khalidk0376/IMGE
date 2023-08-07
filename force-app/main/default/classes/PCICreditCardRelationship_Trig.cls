/**
 * File:        PCICreditCardRelationship_Trig.cls
 * Project:     GAP
 * Created Date: 11-06-2020
 * Created By:  Rajesh Kumar
 * Test Class: zTest_PCI
 * Coverage: 
 *
 * *************************************************************************
 * @description This class is using in " Trigger Management app" Trigger.
 * *************************************************************************
 * 
 * 
 * History:Ticket :BK-3756
 *
*/

public with sharing class PCICreditCardRelationship_Trig implements TriggerInterface_PCICreditCardNumber.Runnable {
    public void run(TriggerInterface_PCICreditCardNumber.Trig trig){
 
        if(trig.isBefore)
        {
            SET<string> systemScanIds = new SET<string>();
            
            for(PCI_Credit_Card_Numbers__c opcicredit : trig.newList)
            {
                if(opcicredit.PCI_Scan_History__c == null)
                    systemScanIds.add(opcicredit.System_Scan_Id__c);
            }
            
            //Get mappings to ids
            if (!systemScanIds.isEmpty())
            {
                Map<String,Id> mapScanIds = new Map<String,Id>();
                for (PCI_Scan_History__c scan : [ Select Id,System_Scan_Id__c  from PCI_Scan_History__c Where System_Scan_Id__c IN :systemScanIds ]) {
                    mapScanIds.put(scan.System_Scan_Id__c, scan.Id);            
                }
                
                for(PCI_Credit_Card_Numbers__c opcicreditcrd : trig.newList)
                {
                    if(opcicreditcrd.PCI_Scan_History__c == null && mapScanIds.containsKey(opcicreditcrd.System_Scan_Id__c))
                        opcicreditcrd.PCI_Scan_History__c = mapScanIds.get(opcicreditcrd.System_Scan_Id__c);
                    
                }
            }
        }
    }
}