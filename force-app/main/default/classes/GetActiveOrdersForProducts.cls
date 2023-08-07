/*
Created By		: Girikon
Created On		: May 26, 2022.
@description 	: This class is used to fetch the data of orders and order lines for LWC component(activeOrders) at Products.
Test Class		: GetActiveOrdersForProducts_Test(90%)

Modification log --
Modified By		: 
*/
public class GetActiveOrdersForProducts {
    
    @AuraEnabled
    public static List<Order> getActiveOrders(Id productId){
        List<OrderItem> orderItems = [Select OrderId, Product2Id from OrderItem WHERE Product2Id =: productId];
        if(orderItems.size() > 0){
            Set<Id> orderIds = new Set<Id>();
            for(OrderItem eachOrderItem : orderItems){
                orderIds.add(eachOrderItem.OrderId);
            }
            if(orderIds.size()>0){
                List<Order> relatedActiveOrders = [Select Id, OrderNumber, TotalAmount,(Select Id,Product_Name__c, SBQQ__OrderedQuantity__c, TotalPrice, SBQQ__TaxAmount__c, SBQQ__TotalAmount__c, SBQQ__Status__c, Quote_Line_Name__c, SAP_Primary_Tax_Rate__c, SAP_Tax_Code__c, blng__TaxStatus__c,orderId from OrderItems) from Order WHERE Status='Activated' and Id in :orderIds];
                if(!relatedActiveOrders.isEmpty()){
                    return relatedActiveOrders;
                }
            }
        }
        return new List<Order>();
    }

}