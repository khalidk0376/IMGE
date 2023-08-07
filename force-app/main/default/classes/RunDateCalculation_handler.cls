/**
* Created By : Rajesh Kumar 
* Created Date : 10-06-2020
* Test Class: RunDateCalculation_test
* Ticket: GGCW-3756
* ***********************************************************************************************************************************************
* @description : runDateCalculation object "OpportunityLineItem"
* ***********************************************************************************************************************************************
* Modified By  : Rajesh Kumar - BK-3756 on 10-06-2020
*
**/

public with sharing class RunDateCalculation_handler {

    public static void runDateCalculation(List<OpportunityLineItem> newOppLineItemLst, Map<id, OpportunityLineItem> oldOppLineItems, Boolean isInsert, Boolean isupdate,Boolean isAfter ,Boolean isBefore) {
        if (isInsert && isBefore) {
            Set<Id> setProductId = new Set<Id>();
            for (OpportunityLineItem oppitems: newOppLineItemLst ) {
                if (oppitems.Start_Date__c != null) {
                    oppitems.Run_Date__c = Date.ValueOf(string.ValueOf(oppitems.Start_Date__c.Year()) + '-' + string.ValueOf(oppitems.Start_Date__c.month()) + '-01');

                    // For Event Products
                    if (oppitems.Product_Family__c == 'Event') {
                        oppitems.ServiceEndDate__c = date.today();
                    }

                    // For Publishing Products
                    if (oppitems.Product_Family__c == 'Publishing') {
                        if (oppitems.Run_Date__c != null) {
                            oppitems.ServiceEndDate__c = oppitems.Run_Date__c;
                        }
                        //oppitemsListUpdate.add(oppitems);
                    }

                    // For Digital Products
                    if (oppitems.Run_Date__c != null) {
                        if (oppitems.Product_Family__c == 'Digital' && Date.today().daysBetween(oppitems.Run_Date__c) < 30 && date.today().month() == oppitems.Run_Date__c.month()) {
                            oppitems.ServiceEndDate__c = date.today();
                            //oppitemsListUpdate.add(oppitems);
                        } else if (oppitems.Product_Family__c == 'Digital' && Date.today().daysBetween(oppitems.Run_Date__c) < 30 && date.today().month() != oppitems.Run_Date__c.month()) {
                            oppitems.ServiceEndDate__c = oppitems.Run_Date__c.adddays(4);
                            //oppitemsListUpdate.add(oppitems);
                        } else if (oppitems.Product_Family__c == 'Digital' && Date.today().daysBetween(oppitems.Run_Date__c) > 30) {
                            oppitems.ServiceEndDate__c = oppitems.Run_Date__c.adddays(-30);
                        }

                    }
                }
                setProductId.add(oppitems.Product2Id);
            }
            // Assigning FOC field values from product to OpportunityLineItem record.
            if(checkRecursive.runOnceForOLI()){
                if(!setProductId.isEmpty()){
                    Map<Id, Product2> mapProduct = new Map<Id, Product2>([SELECT ID, Is_FOC_Product__c, Exclude_in_FOC_Quote__c FROM Product2 WHERE Id IN:setProductId]);
                    for (OpportunityLineItem oOLI: newOppLineItemLst) {               
                        oOLI.Is_FOC_Product2__c = mapProduct.get(oOLI.Product2Id).Is_FOC_Product__c ;
                        oOLI.Exclude_in_FOC_Quote2__c = mapProduct.get(oOLI.Product2Id).Exclude_in_FOC_Quote__c ;
                    }
                }
            }
        }
    
        // to update booth info on work order even after the opportunity has closed won.

        if (isUpdate && isAfter) {

            Map < String, WorkOrder > workOrderMap = new Map < String, WorkOrder > ();
            List < WorkOrder > updatedWorkOrder = new List < WorkOrder > ();
            set < String > oliIds = new set < String > ();

            for (OpportunityLineItem oli: newOppLineItemLst){
                oliIds.add(oli.Id);
            }

            for (WorkOrder wo: [select id, Opportunity_Product_Id__c, Booth_Number__c, Booth_Pavilion__c, Booth_Show_In_Show__c, Booth_Type__c from WorkOrder where Opportunity_Product_Id__c IN: oliIds]) {
                workOrderMap.put(wo.Opportunity_Product_Id__c, wo);
            }

            for (OpportunityLineItem oli: newOppLineItemLst) {
                if (workOrderMap.containsKey(oli.Id)) {
                    workOrderMap.get(oli.Id).Booth_Number__c = oli.Booth_Number__c;
                    workOrderMap.get(oli.Id).Booth_Pavilion__c = oli.Booth_Pavilion__c;
                    workOrderMap.get(oli.Id).Booth_Show_In_Show__c = oli.Show_In_Show__c;
                    workOrderMap.get(oli.Id).Booth_Type__c = oli.Booth_Type__c;
                    updatedWorkOrder.add(workOrderMap.get(oli.Id));
                }
            }

            if (!updatedWorkOrder.isEmpty()) {
                update updatedWorkOrder;
            }
        }
    }
}