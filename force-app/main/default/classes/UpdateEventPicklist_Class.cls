/**
* Project:     GAP
* Date:        20/05/2019
* Created By:  Rajesh Kumar	
* Test class   UpdateEventPicklist_Test.cls
* *************************************************************************
* @description
* *************************************************************************
* History:Modified By:Rajesh Kumar [GGCW-3103] , Rajesh Kr 28-02-2020 - BK-3581 
*/

public with sharing class UpdateEventPicklist_Class {
    
    //variables
    List<Product2> lstProduct             	{ get; set; }
    Map<Id, Product2> oldmapProduct         { get; set; }
    Map<Id, Product2> newmapProduct         { get; set; }/* BK-21361 */
    Boolean isInsert                        { get; set; }
    Boolean isupdate                        { get; set; }
    Boolean isBefore                        { get; set; }
    Boolean isAfter                         { get; set; }
    map<string,string> eveVsbooth			{get;set; }
    set<Id> productIds 						{get; set; }
    set<String> boothValues					{get; set; }
    list<Event_Edition__c> evEList 			{get;set;}
    set<String> eveName						{get;set;}
    Set<Id> activeToInactiveProducts		{get;set;} /* BK-21361 */
    
    /** [UpdateEventPicklist_Class contructor call aal events] */
    public UpdateEventPicklist_Class (List<Product2> lstProduct , Map<Id , Product2> oldmapProduct, Map<Id , Product2> newmapProduct , Boolean isInsert, Boolean isupdate, Boolean isBefore, Boolean isAfter){
        this.lstProduct    = lstProduct; 
        this.oldmapProduct = oldmapProduct;
        this.newmapProduct = newmapProduct;/* BK-21361 */
        this.isInsert     = isInsert;
        this.isupdate     = isupdate;
        this.isBefore     = isBefore;
        this.isAfter      = isAfter;
        productIds = new set<Id>();
        eveName = new set<String>();
        eveVsbooth = new map<string,string>();
        boothValues = new set<String>();
        evEList = new list<Event_Edition__c>();
    }
    /**
* [beforeinsertMethod call only before insert from UpdateEventPicklistTrg ]
*/
    /*public void beforeinsertMethod(){
for(product2 oproduct : lstProduct ){
if (oproduct.Event_Product_Type__c !='' && oproduct.Event_Product_Type__c == 'Booth'){
oproduct.Product_Type_SAP__c = 'EXH';
}
if (oproduct.Event_Product_Type__c !='' && oproduct.Event_Product_Type__c == 'Booth Cancellation'){
oproduct.Product_Type_SAP__c = 'NA';
}
if (oproduct.Event_Product_Type__c !='' && oproduct.Event_Product_Type__c == 'Digital'){
oproduct.Product_Type_SAP__c ='DIG';
}
if (oproduct.Event_Product_Type__c !='' && oproduct.Event_Product_Type__c == 'Merchandize'){
oproduct.Product_Type_SAP__c= 'NA';
}
if (oproduct.Event_Product_Type__c !='' && oproduct.Event_Product_Type__c == 'Other'){
oproduct.Product_Type_SAP__c = 'OTH';
}
if (oproduct.Event_Product_Type__c !='' && oproduct.Event_Product_Type__c == 'Publishing'){
oproduct.Product_Type_SAP__c = 'PRN';
}
if (oproduct.Event_Product_Type__c !='' && oproduct.Event_Product_Type__c =='Sponsorship'){
oproduct.Product_Type_SAP__c ='SPN';
}
if (oproduct.Event_Product_Type__c !='' && oproduct.Event_Product_Type__c == 'Premium'){
oproduct.Product_Type_SAP__c ='NA';
}
if (oproduct.Event_Product_Type__c !='' && oproduct.Event_Product_Type__c == 'Commissions'){
oproduct.Product_Type_SAP__c ='NA';
}
if (oproduct.Event_Product_Type__c !='' && oproduct.Event_Product_Type__c == 'Attendees'){
oproduct.Product_Type_SAP__c = 'ATT';
}
if (oproduct.Event_Product_Type__c !='' && oproduct.Event_Product_Type__c == 'Conference'){		oproduct.Product_Type_SAP__c = 'CON';
}

}
}*/
    
    /**
* [beforeUpdateMethod call only before update from UpdateEventPicklistTrg ]
*/
    public void beforeUpdateMethod () {
        activeToInactiveProducts = new Set<Id>(); /* BK-21361 */
        for(Product2 productLst : lstProduct){
            
            if (productLst.SAP_Material_Code__c!= '' && !String.isEmpty(productLst.SAP_Material_Code__c) ){
                String materialCode = productLst.SAP_Material_Code__c;
                String code =materialCode.right(3);
                productLst.SAP_Material_Code_Type__c = code;
            }
            
            /* BK-21361  : If statement added for check of product status change from Active to Inactive*/
            if((oldmapProduct.get(productLst.Id).isActive != productLst.IsActive) && productLst.IsActive == false){
                activeToInactiveProducts.add(productLst.Id);
            }
        }
        /* BK-21361 : If statement added for to restrict the deactivation of product if status changed from Active to Inactive, and related active orders are present.*/
        if(!activeToInactiveProducts.isEmpty()){
            productDeactivationController(activeToInactiveProducts);               
        }
    }
    
    /**
* [afterUpdateInsertMethod call only after Insert/Update from UpdateEventPicklistTrg ]
*/
    public void afterUpdateInsertMethod (){
        for(Product2 p2 : lstProduct){
            if(p2.Booth_Product_Type__c!=null && p2.Event_Edition_Name__c!=null){
                productIds.add(p2.Id);
                eveName.add(p2.Event_Edition_Name__c);
                eveVsbooth.put(p2.Event_Edition_Name__c, p2.Booth_Product_Type__c);
            }
        }
        
        if (eveVsbooth != null){
            if (!Schema.sObjectType.Event_Edition__c.fields.Booth_Product_Type__c.isAccessible()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Insufficient Access'));
            }
            else {
                evEList = [select Id,Booth_Product_Type__c, Name from Event_Edition__c where Name IN : eveVsbooth.KeySet()];
            }
            if (evEList.size() > 0 ){
                for(Event_Edition__c evEdition : evEList){
                    if(evEdition.Booth_Product_Type__c!=null){
                        boothValues.addAll(evEdition.Booth_Product_Type__c.split(';'));
                    }
                    if(eveVsbooth.containsKey(evEdition.Name) && evEdition.Booth_Product_Type__c==null){
                        evEdition.Booth_Product_Type__c = eveVsbooth.get(evEdition.Name);
                    }
                    else{
                        if(!boothValues.contains(eveVsbooth.get(evEdition.Name))){
                            evEdition.Booth_Product_Type__c += ';' + eveVsbooth.get(evEdition.Name);
                        }
                    } 
                }
                if (!Schema.sObjectType.Product2.fields.Booth_Product_Type__c.isUpdateable()){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Insufficient Access'));
                }
                else {
                    update evEList;
                }
            }
        }
    }
    
    /* BK-21361 : productDeactivationController : restricts the deactivation of product if status changed from Active to Inactive, and related active orders are present.*/
    public void productDeactivationController(Set<Id> activeToInactiveProducts){
        List<OrderItem> orderItems = [Select OrderId, Product2Id from OrderItem WHERE Product2Id =: activeToInactiveProducts];
        if(orderItems.size() > 0){
            Map<String,String> orderIdToProductId = new Map<String, String>();
            for(orderItem eachOrderItem : orderItems){
                orderIdToProductId.put(eachOrderItem.OrderId, eachOrderItem.Product2Id);
            }
            
            List<Order> relatedActiveOrders = [Select Id,OrderNumber from Order WHERE Status='Activated' and Id in :orderIdToProductId.keySet()];
            if(relatedActiveOrders.size()>0){
                newmapProduct.get(orderIdToProductId.get(relatedActiveOrders[0].Id)).addError(System.Label.productDeactivationError);
            }                   
        }
    }
}