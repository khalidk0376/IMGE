/*
* Created By   : Girikon[Adarsh BK-3756]
* Created On   : 6/01/2020
* ***********************************************************************************************************************************************************
* Description  : Trigger to update main Order checkbox true. 
* ***********************************************************************************************************************************************************
* Coverage     : 85% 
* Test Class   : OnlyOneMainOrder_Test
*/

public class OnlyOneMainOrder_Handler implements TriggerInterface_Order.Runnable{
    
    public void run(TriggerInterface_Order.Trig trig){
        if(trig.isBefore) {
            List<Id> lstOpportunityIds =  new List<Id>();
            //List<Id> lstParentOppyIds =  new List<Id>();
            // GGCW-2123: Kumar
            List<Id> lstAccountIds =  new List<Id>();
            List<Id> lstBillingInvoiceAccountIds =  new List<Id>();
            
            for (Order order: trig.newList) {
                if(trig.isInsert){
                    order.main_order__c = True;
                    lstOpportunityIds.add(order.OpportunityId);
                    
                }else if(trig.isUpdate){
                    Order oldOrder = trig.oldmap.get(order.id);
                    if(!oldOrder.main_order__c && order.main_order__c){
                        lstOpportunityIds.add(order.OpportunityId);
                    }
                    // GGCW-2123: Kumar
                    If(oldOrder.Create_Customer_Result__c != order.Create_Customer_Result__c && order.Create_Customer_Result__c == 'Success'){
                        lstAccountIds.add(order.Billing_Invoice_Account__c);
                    }
                }
            }
            
            if (!lstOpportunityIds.isEmpty()){
                List<Order> lstOrderToUpdate =  new List<Order>();
                for(Order oOrder : [SELECT Id, main_order__c FROM Order WHERE OpportunityId IN:lstOpportunityIds AND main_order__c = True]){
                    oOrder.main_order__c = False;
                    lstOrderToUpdate.add(oOrder);
                }
                if(!lstOrderToUpdate.isEmpty()){
                    update lstOrderToUpdate;
                }
            }
            // GGCW-2082
            /*if( !lstParentOppyIds.IsEmpty( ) ) {
                Map <Id, String> mapParentOpp = new Map <Id, String> ( );
                for( Opportunity Opp : [ SELECT Id, Parent_Opportunity__r.Main_Order__c  FROM Opportunity WHERE Id IN: lstParentOppyIds ] ){
                    mapParentOpp.put( opp.Id, opp.Parent_Opportunity__r.Main_Order__c ); 
                }
                for ( Order oTempOrder: trig.newList) { 
                    oTempOrder.Parent_Opp_Order__c = mapParentOpp.get( oTempOrder.OpportunityId ); 
                }
            }*/
            ////Rajesh Kumar Yadav   GGCW-3243
            If(!lstAccountIds.isEmpty()){
                Map<Id, Map<String, String>> mapBPNoByAccountIds = new Map<Id, Map<String, String>>();
                for(Account_Legal_Entity__c oAccountLE : [SELECT Id,Account__c,Business_Partner_Number__c,Account__r.Name, Name, Legal_Entity__r.Legal_Entity_Code__c, Active__c FROM Account_Legal_Entity__c where Account__c IN:lstAccountIds]){
                    if(!mapBPNoByAccountIds.containsKey(oAccountLE.Account__c)){
                        Map<String, String> mapBPNoByEntityCode = new Map<String, String>();
                        mapBPNoByEntityCode.put(oAccountLE.Legal_Entity__r.Legal_Entity_Code__c, oAccountLE.Business_Partner_Number__c);
                        mapBPNoByAccountIds.put(oAccountLE.Account__c, mapBPNoByEntityCode);
                    }
                    else{
                        mapBPNoByAccountIds.get(oAccountLE.Account__c).put(oAccountLE.Legal_Entity__r.Legal_Entity_Code__c, oAccountLE.Business_Partner_Number__c);
                    }
                }
                If(!mapBPNoByAccountIds.isEmpty()){
                    for(Order order: trig.newList){
                        If(mapBPNoByAccountIds.containsKey(order.Billing_Invoice_Account__c)){
                            order.SAP_BP_Number__c = mapBPNoByAccountIds.get(order.Billing_Invoice_Account__c).get(order.Legal_Entity_Code__c);
                        }
                    }
                }
            }
        }
        
        if(trig.isAfter) {        
            Map<Id, Id> mapOpptyIds =  new Map<Id, Id>();
            //List<Id> lstOrderIdForTaxCalculation =  new List<Id>();
            
            for (Order order: trig.newList) 
            {
                if(trig.isInsert){
                    OrderObjectHelper_Cls.createCustomerCallout(order.Id);
                    mapOpptyIds.put(order.OpportunityId, order.Id);
                    
                } else if(trig.isUpdate) {
                    Order oldOrder = trig.oldmap.get(order.id);
                    if(!oldOrder.main_order__c && order.main_order__c){
                        mapOpptyIds.put(order.OpportunityId, order.Id);
                    }
                }
            }
            
            if (!mapOpptyIds.isEmpty()) {
                List<Opportunity> lstOpportunityToUpdate =  new List<Opportunity>();
                for(Opportunity oOpportunity : [SELECT Id, Main_Order__c FROM Opportunity WHERE Id IN:mapOpptyIds.KeySet()]){
                    if(oOpportunity.Main_Order__c != mapOpptyIds.get(oOpportunity.Id)){
                        oOpportunity.Main_Order__c = mapOpptyIds.get(oOpportunity.Id);
                        lstOpportunityToUpdate.add(oOpportunity);
                    }
                }
                if(!lstOpportunityToUpdate.isEmpty()){
                    update lstOpportunityToUpdate;
                }
            }
        }
    }
}