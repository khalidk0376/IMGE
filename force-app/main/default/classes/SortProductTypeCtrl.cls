/**
* File:        SortProductTypeCtrl.cls
* Project:     GAP
* Date:        April 23, 2018
* Test Class:  SortProductTypeCtrl_Test
* Created By:  Kumar Gaurav
* *************************************************************************
* Description: Controller to reorder Booth Product Type List to display in Floor plan page.
* *************************************************************************
* History:
*/ 
public with sharing class SortProductTypeCtrl {

    // Variables
    private final sObject mysObject;
    public Event_Edition__c oEventEdition {get; private set;}
    public Set<String> lstPrdTypeExtOrder {get;set;}
    public String sUpdatedOrder {get;set;}

    // Cunstructor.
    public SortProductTypeCtrl(ApexPages.StandardController stdController) {
        this.mysObject = (sObject)stdController.getRecord();
    }

    public void existingProductTypeOrder() {
        lstPrdTypeExtOrder = new Set<String>();
        sUpdatedOrder = '';
        if(mysObject.get('Id') != NULL){
            oEventEdition = [SELECT Id, Name, Product_Type_Order__c, Booth_Product_Type__c FROM Event_Edition__c WHERE ID =: (Id)mysObject.get('Id') LIMIT 1] ;
            if(!String.isBlank(oEventEdition.Product_Type_Order__c) && !String.isBlank(oEventEdition.Booth_Product_Type__c)){
                Set<String> setBPT = new Set<String>(oEventEdition.Booth_Product_Type__c.split(';'));
                Set<String> setPTO = new Set<String>(oEventEdition.Product_Type_Order__c.split(';;'));
                for(String sPTO : oEventEdition.Product_Type_Order__c.split(';;')){
                    if(setBPT.contains(sPTO))
                        lstPrdTypeExtOrder.add(sPTO);
                }
                for(String sBPT : oEventEdition.Booth_Product_Type__c.split(';')){
                    if(!setPTO.contains(sBPT))
                        lstPrdTypeExtOrder.add(sBPT);
                }
            }
            else if(!String.isBlank(oEventEdition.Booth_Product_Type__c)){
                lstPrdTypeExtOrder.addAll(oEventEdition.Booth_Product_Type__c.split(';'));
            }
        }
    }
    
    public PageReference saveProductTypeOrder() {
        //String sTemp = apexpages.currentpage().getparameters().get('sUpdatedOrder');
        System.debug('sUpdatedOrder ==> '+sUpdatedOrder);
        oEventEdition.Product_Type_Order__c = sUpdatedOrder ;
        Update oEventEdition ;
        lstPrdTypeExtOrder = new Set<String>();
        lstPrdTypeExtOrder.addAll(sUpdatedOrder.split(';;'));
        pageReference backToRecord = new pageReference('/' + mysObject.get('Id'));
        return backToRecord;
    }
    
    public pageReference returnToEE() {
        pageReference backToRecord = new pageReference('/' + mysObject.get('Id'));
        return backToRecord;
    }
}