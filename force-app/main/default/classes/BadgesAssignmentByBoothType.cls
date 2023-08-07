/*
* Created By   : Girikon[Aishwarya CCEN-658]
* Created On   : Feb 20 2019 
* @description : Calling the handler class - CreateBoothTypeBadgeLimitRecords on creation/updation of a EventEdition record
* Test Class   : BadgesAssignmentByBoothType_Test (100%)
* Last Modified By: Girikon[Aishwarya CCEN-578 Apr 2 2019, Aishwarya CCEN-759 April 8 2019]   
*/
public without sharing class BadgesAssignmentByBoothType implements TriggerInterface_EventEdition.Runnable
{
    public void run(TriggerInterface_EventEdition.Trig trig)
    {
        //Contains event edition Ids
        Set<Id> setEEIds = New Set<Id>();
        if(trig.isInsert || Test.isRunningTest())
        {
            //Iteration on Event Edition records
            for(Event_Edition__c ee: trig.newList)
            {
                // CCEN-578 Replace Booth Product Type with Matched Product Name on Event Edition
                if(String.IsNotBlank(ee.Matched_Product_Name__c ))
                {
                    setEEIds.add(ee.Id);
                }               
            }
            if(setEEIds.size()>0)
            {
                CreateBoothTypeBadgeLimitRecords boothhandler = new CreateBoothTypeBadgeLimitRecords();
                boothhandler.createBoothTypeRecords(setEEIds);
            }
        }
        if(trig.isUpdate)
        {
            List<String> listBPTypes = new List<String>();
            List<String> listMPN = new List<String>();
            Boolean checkIfBPTypeBlank = true;
            //Iteration on updated Event Edition records
            for(Event_Edition__c ee: trig.newList)
            {
                // CCEN-578 Replace Booth Product Type with Matched Product Name on Event Edition
                System.debug('Matched_Product_Name__c-------- ' +ee.Matched_Product_Name__c );
                System.debug('Old Matched_Product_Name__c-------- ' +trig.oldMap.get(ee.Id).Matched_Product_Name__c );
                if(String.IsNotBlank(ee.Matched_Product_Name__c ) && trig.oldMap.get(ee.Id).Matched_Product_Name__c != ee.Matched_Product_Name__c)
                {
                    setEEIds.add(ee.Id);
                }
                
                /*CCEN-759 Check if any changes are made on Booth Product Type picklist on event edition start */
                System.debug('Booth_Product_Type__c-------- ' +ee.Booth_Product_Type__c );
                System.debug('Old Booth_Product_Type__c-------- ' +trig.oldMap.get(ee.Id).Booth_Product_Type__c );
                if(String.IsNotBlank(ee.Booth_Product_Type__c) && trig.oldMap.get(ee.Id).Booth_Product_Type__c != ee.Booth_Product_Type__c)
                {
                    checkIfBPTypeBlank = false;
                    String productType = ee.Booth_Product_Type__c;            
                    if(productType != null)
                    {
                        listBPTypes = productType.split(';');
                    }
                    setEEIds.add(ee.Id);
                }
                else if(String.IsNotBlank(ee.Booth_Product_Type__c) && trig.oldMap.get(ee.Id).Booth_Product_Type__c == ee.Booth_Product_Type__c)
                {
                    checkIfBPTypeBlank = false;
                    setEEIds.add(ee.Id);
                }
                else if(checkIfBPTypeBlank == true)
                {
                    setEEIds.add(ee.Id);
                }
                System.debug('checkIfBPTypeBlank-------- ' +checkIfBPTypeBlank );
                /*CCEN-759 Check if any changes are made on Booth Product Type picklist on event edition end */
            }

            /* CCEN-759 calling the handler class UpdateMPNOnEventEdition start */
            if(!listBPTypes.isEmpty() || checkIfBPTypeBlank == true)
            {
                UpdateMPNOnEventEditionCtrl handler = new UpdateMPNOnEventEditionCtrl();
                handler.updateMpnRecordsOnEE(setEEIds, listBPTypes, checkIfBPTypeBlank);
            }
            /* CCEN-759 calling the handler class UpdateMPNOnEventEdition end */
            
            if(setEEIds.size()>0)
            {
                CreateBoothTypeBadgeLimitRecords boothhandler = new CreateBoothTypeBadgeLimitRecords();
                boothhandler.createBoothTypeRecords(setEEIds);
            }
            
            
        }
    }
}