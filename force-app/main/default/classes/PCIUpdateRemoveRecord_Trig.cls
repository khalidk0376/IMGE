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

public with sharing class PCIUpdateRemoveRecord_Trig implements TriggerInterface_PCICreditCardNumber.Runnable {
    Set<Id> rIds = new Set<Id>();
    List<Sobject> sObjsToUpdate = new List<SObject>();
    Map<String, Set<Id>> objToId = new Map<String, Set<Id>>();
    Map<String, Map<Id, SObject>> objToMapOfRec = new Map<String, Map<Id, SObject>>();
    public void run(TriggerInterface_PCICreditCardNumber.Trig trig){
        
        for (PCI_Credit_Card_Numbers__c  pci : trig.newList) {
            if (pci.Record_Action__c == 'Removed') {
                if (pci.Object_Name__c == 'Task' || pci.Object_Name__c == 'Event') {                    rIds.add(pci.Record_Id__c);
                } else {
                    if (objToId.containsKey(pci.Object_Name__c)) {
                    objToId.get(pci.Object_Name__c).add(pci.Record_Id__c);
                    } else {
                    Set<Id> rIds = new Set<Id>();
                    rIds.add(pci.Record_Id__c);
                    objToId.put(pci.Object_Name__c, rIds);
                    }
                }
            } 
            else if (pci.Record_Action__c == 'No Credit Card - Deleted Record' || pci.Record_Action__c == 'Had Credit Card - Deleted Record') {
                if (objToId.containsKey(pci.Object_Name__c)) {                    objToId.get(pci.Object_Name__c).add(pci.Record_Id__c);
                } else {
                    Set<Id> rIds = new Set<Id>();
                    rIds.add(pci.Record_Id__c);
                    objToId.put(pci.Object_Name__c, rIds);
                }
            }
        }
        // Seperating the Query into bulk.
        Map<Id, Task> allTasks = new Map<Id, Task>([Select Id from Task where id IN : rIds]);
        Map<Id, Event> allEvents = new Map<Id, Event>([Select Id from Event where id IN : rIds]);
        for (String objName : objToId.keySet()) {

            Set<Id> idToQuery = new Set<Id>();
            idToQuery = objToId.get(objName);
            Map<Id, SObject> sObjMap = new Map<Id, SObject>(Database.query('Select Id from ' + objName + ' WHERE ID IN: idToQuery'));
            if (!sObjMap.isEmpty()) { 
                objToMapOfRec.put(objName, sObjMap); sObjsToUpdate.addAll(sObjMap.values()); 
            }
        }

        for (PCI_Credit_Card_Numbers__c  pci : trig.newList) {
            Boolean hasNoRecords = false;
            Boolean hasRecords = false;
            if (pci.Record_Action__c == 'Removed') {

                if (pci.Object_Name__c == 'Task' && !allTasks.containsKey(pci.Record_Id__c)) {                    hasNoRecords = true;
                } 
                else if (pci.Object_Name__c == 'Event' && !allEvents.containsKey(pci.Record_Id__c)) {                     hasNoRecords = true;
                } 
                else if (pci.Object_Name__c != NULL) {
                    if (objToMapOfRec.containsKey(pci.Object_Name__c)) {
                        if (!objToMapOfRec.get(pci.Object_Name__c).containsKey(pci.Record_Id__c)) {                             hasNoRecords = true;
                        }
                    } 
                    else {
                        hasNoRecords = true;
                    }
                } else {
                    hasNoRecords = true;
                }
            } 
            else if (pci.Record_Action__c == 'No Credit Card - Deleted Record' || pci.Record_Action__c == 'Had Credit Card - Deleted Record') {
                if (objToMapOfRec.containsKey(pci.Object_Name__c)) {
                    if (objToMapOfRec.get(pci.Object_Name__c).containsKey(pci.Record_Id__c)) {
                        hasRecords = true;
                    }
                }
            }
            //Adding error message condition
            if (hasNoRecords) { 
                pci.addError(' If the record was deleted before reviewed or Credit Card, please select "No Credit Card - Deleted Record" or "Had Credit Card - Deleted Record".');
            }
            if (hasRecords) { 
                pci.addError(' The record exists, Please select the appropriate value after you review the record.');
            }
        }

        if (!allTasks.isEmpty()) { Update allTasks.values(); }
        if (!allEvents.isEmpty()) { Update allEvents.values(); }
        if (!sObjsToUpdate.isEmpty()) { Update sObjsToUpdate; }
    }
}