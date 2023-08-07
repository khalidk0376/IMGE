/**
 * File:        OppCustomPaymentHandler.cls
 * Project:     GE-IOM
 * Date:        3-Jan-2023
 * Created By:  Ansh (GECI-654)
 * Modified By: 
 * Test Class:  OppCustomPaymentHandler_Test(100%)
 * *************************************************************************
 * @description : This is Handler for Opportunity Trigger. It is used mainly for Pre-population of Opportunity object fields.
 * *************************************************************************
 */
public with sharing class OppCustomPaymentHandler {

    /**
    * @description to populate milestone fields from IOM custom billing info
    * @param newOppLst List new Opp From Trigger.New 
    * @param oldOppMap Map old Opp From Trigger.OldMap 
    */
    public static void customopportunityPaymentSchedule(List<Opportunity> newOppLst, Map<id, Opportunity> oldOppMap) {
        string milestone = 'Milestone_';
        string percent = '_Percent__c';
        string amount = '_Amount__c';
        string deliivery = '_Delivery_Date__c';

        set<Id> edIds = new Set<Id>();        
        for(Opportunity opp : newOppLst){
            if(String.isNotBlank(opp.EventEdition__c)){
                edIds.add(opp.EventEdition__c);
            }
        }

        Map<Id,Event_Edition__c> mapOfed = new Map<Id,Event_Edition__c>([SELECT Id,Enabled_for_IOM_Billing__c FROM Event_Edition__c WHERE Id in:edIds]);

        for(Opportunity opp : newOppLst){
            if(mapOfed.containsKey(opp.EventEdition__c) && mapOfed.get(opp.EventEdition__c).Enabled_for_IOM_Billing__c == true){
                Opportunity oldOpp = oldOppMap.get( opp.Id );
                if(oldOpp.IOM_Custom_Billing_Info__c != opp.IOM_Custom_Billing_Info__c){
                    opp.Total_No_of_payment__c = null;
                    opp.Start_Date__c = null;
                    opp.Total_Milestone_Dates__c = null;
                    opp.Custom_Payment__c = false;
                    opp.Payment_Schedules__c = true;
                    for(Integer i = 1; i <= 12; i++){
                        opp.put(milestone+i+percent, null);
                        opp.put(milestone+i+amount, null);
                        opp.put(milestone+i+deliivery, null);
                    }
                    if(opp.IOM_Custom_Billing_Info__c != null){
                        Integer fieldcount = 0;
                        List<Map<String, String>> payments = (List<Map<String, String>>) JSON.deserialize(opp.IOM_Custom_Billing_Info__c, List<Map<String, String>>.class);
                        opp.Total_No_of_payment__c = payments.size();
                        for(Map<String, String> p : payments){
                            fieldcount++;
                            if(p.get('PaymentNumber') == string.valueOf(fieldcount)){
                                opp.put(milestone+fieldcount+percent, Decimal.valueOf(p.get('Percent')));
                                opp.put(milestone+fieldcount+amount, Decimal.valueOf(p.get('Amount')));
                                opp.put(milestone+fieldcount+deliivery, Date.valueOf(p.get('Date')));
                            }
                        }
                        opp.Custom_Payment__c = true;
                        opp.Payment_Schedules__c = false;
                    }
                }
            }
        }
    }
}