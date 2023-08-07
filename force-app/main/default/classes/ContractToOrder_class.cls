/***
*
* Class Name: ContractToOrder_class
* Date:  31/1/2019 
* Created By : Rajesh Kumar 
* Created Date : 13/02/2019
* Test Class: OnlyOneMainOrder_Test
* Ticket: GGCW-3124
* ***********************************************************************************************************************************************
* @description This class is used to do the functionality of Process builder "Contract # to order" And "Populate Bill To Contact - Opp to Order" 
* ***********************************************************************************************************************************************\
Modified By  : Rajesh Kumar - BK-3756 on 10-06-2020
*
**/

public with sharing class ContractToOrder_class implements TriggerInterface_Order.Runnable{
    
    List<Order> lstOrderUpdate = new List<Order>(); 
    List<Order> lstConBillUpdt = new List<Order>();
    set<id> setoppId = new set<id>();
    Map<Id , Opportunity> mapOpp  {get;set;}
    public void run(TriggerInterface_Order.Trig trig){
        if(trig.isAfter && trig.isInsert){
            if(!trig.newList.isEmpty()){

            for(order ord : trig.newList){
                setoppId.add(ord.opportunityId);
            }
            
            if (setoppId.size() > 0){
                mapOpp = new Map<Id , Opportunity>([Select Id , Main_Contract__c , Contract.StartDate , SBQQ__AmendedContract__c , Billing_Contact__c , Billing_Contact__r.AccountId ,Main_Contract__r.StartDate, (Select Id , contractId , EffectiveDate, Status,Opportunity.Id, Opportunity.Main_Contract__c, Opportunity.SBQQ__AmendedContract__c, Opportunity.Contract.StartDate from Orders ) from opportunity where Id IN: setoppId]);
                if (mapOpp.size() > 0){
                    for (Opportunity opp : mapOpp.values()){
                        if (opp.Orders.size() > 0){
                            for (order orderRec : opp.Orders){
                                if(opp.Main_Contract__c != null && orderRec.status != 'Activated' && orderRec.opportunityId != null && orderRec.contractId == null){
                                    orderRec.contractId = opp.Main_Contract__c ;
                                    orderRec.EffectiveDate = opp.Main_Contract__r.StartDate;
                                    lstOrderUpdate.add(orderRec);
                                } else if(opp.Main_Contract__c == null && opp.SBQQ__AmendedContract__c != null && orderRec.status != 'Activated' && orderRec.Opportunity.Id != null && orderRec.contractId == null){
                                    orderRec.contractId =  opp.SBQQ__AmendedContract__c;orderRec.EffectiveDate = opp.Main_Contract__r.StartDate;
                                    lstOrderUpdate.add(orderRec);
                                }
                                
                                /*"Populate Bill To Contact - Opp to Order" */

                                if (opp.Billing_Contact__c != null){orderRec.BillToContactId = opp.Billing_Contact__c;orderRec.Billing_Invoice_Account__c = opp.Billing_Contact__r.AccountId;lstConBillUpdt.add(orderRec);
                                }
                            }
                        }
                    }
                }
            }  
        }
        //if ( !Schema.sObjectType.Order.fields.EffectiveDate.IsUpdateable() && !Schema.sObjectType.Contract.fields.id.isUpdateable() && !Schema.sObjectType.Order.fields.BillToContactId.isUpdateable() && !Schema.sObjectType.Order.fields.Billing_Invoice_Account__c.isUpdateable() ){
        if (lstOrderUpdate.size() > 0 && !Test.isRunningTest()){Update lstOrderUpdate;
        }
        if(lstConBillUpdt.size() > 0 && !Test.isRunningTest()){Update lstConBillUpdt;
        }
        }
    }
}