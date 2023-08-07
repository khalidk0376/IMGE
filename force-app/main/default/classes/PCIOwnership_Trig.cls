/**
 * File:        PCIOwnership_Trig.cls
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

public with sharing class PCIOwnership_Trig implements TriggerInterface_PCICreditCardNumber.Runnable {

    Set<String> objectIds = new Set<String>();
    Set<String> objectFields = new Set<String>();
    Set<String> lastDigits = new Set<String>();

    public void run(TriggerInterface_PCICreditCardNumber.Trig trig){
        for (Integer i=0;i<trig.newList.size();i++){
            //Begin Short Value
            if (trig.newList[i].Field_Value__c != null && (trig.newList[i].Field_Value__c.length() <= 50)) {
                trig.newList[i].Field_Value_Short__c = trig.newList[i].Field_Value__c;
            }
            else if (trig.newList[i].Field_Value__c != null){
                Integer fieldLength= trig.newList[i].Field_Value__c.length();
                System.debug('test Rajesh Kumar :' + trig.newList[i].Field_Value__c.substring(fieldLength-50, fieldLength) );
                //trig.newList[i].Field_Value_Short__c = trig.newList[i].Field_Value__c.substring(fieldLength-50, fieldLength);
            }
            //End Short Value
            if (trig.newList[i].Record_Action__c == 'Pending'){
                objectIds.add(trig.newList[i].Record_Id__c);
                objectFields.add(trig.newList[i].Field_Name__c);
                lastDigits.add(trig.newList[i].CCN_Last_4_Digits__c);
            }
        }
        AggregateResult[] cnnFalsePositives= [Select p.Record_Id__c, p.Field_Name__c, p.CCN_Last_4_Digits__c, COUNT(Id) From PCI_Credit_Card_Numbers__c p Where  p.Record_Action__c = 'False Positive' AND Record_Id__c =:objectIds AND Field_Name__c =:objectFields AND CCN_Last_4_Digits__c  =:lastDigits GROUP BY p.Record_Id__c, p.Field_Name__c, p.CCN_Last_4_Digits__c ];
        if (cnnFalsePositives.Size() > 0){
            for (Integer i=0;i<trig.newList.size();i++) {
                if (trig.newList[i].Record_Action__c == 'Pending') {
                    for (Integer j=0;j<cnnFalsePositives.size();j++){
                        if (trig.newList[i].Record_Id__c == cnnFalsePositives[j].get('Record_Id__c') && trig.newList[i].Field_Name__c == cnnFalsePositives[j].get('Field_Name__c') && trig.newList[i].CCN_Last_4_Digits__c == cnnFalsePositives[j].get('CCN_Last_4_Digits__c'))
                        {
                            trig.newList[i].Record_Action__c  = 'False Positive';
                            Break;
                        }
                    }
                }
            }
        }
        PCIOwnership.ProcessingOwnership(trig.newList ,true);        
    }
}