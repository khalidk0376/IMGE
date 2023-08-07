/**
 * File:        PCIScanHistoryRelationship  .cls
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


trigger PCIScanHistoryRelationship on PCI_Scan_History__c (after insert, after update) {
  PCIScanHistoryRelationship_Trig oPCIScanHistoryRelationship = new PCIScanHistoryRelationship_Trig(trigger.new , trigger.oldMap,trigger.isinsert, trigger.isUpdate, trigger.isAfter);
  oPCIScanHistoryRelationship.pciScanHistoryRelationships();
 
    /**************************************************************************
    List<PCI_Credit_Card_Numbers__c> updateMissingRelationship = new List<PCI_Credit_Card_Numbers__c>();
    for (PCI_Credit_Card_Numbers__c ccn : [Select Id,System_Scan_Id__c  from PCI_Credit_Card_Numbers__c Where PCI_Scan_History__c = null and System_Scan_Id__c IN :systemScanIds])
    {
      
            System.debug('*****ccn.Id' + ccn.Id);
                    System.debug('*****mapIds.get(ccn.System_Scan_Id__c)=' + mapIds.get(ccn.System_Scan_Id__c));
                    PCI_Credit_Card_Numbers__c updateCNN = new PCI_Credit_Card_Numbers__c(
                        Id = ccn.Id,
                        PCI_Scan_History__c = mapIds.get(ccn.System_Scan_Id__c)
                        );   
                
                    updateMissingRelationship.add(updateCNN);
            
    }
    
    if(updateMissingRelationship.size() > 0) update updateMissingRelationship;
    ***************************************************************************/
}