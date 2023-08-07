/**
* File         :   SendForOrderOverride 
* Project      :   GE CRM-IOM
* Created Date :   21st Nov 2022
* Created By   :   Girikon(Ashish)
* Test Class   :   SendForOrderOverride_Test(94%)
* ***************************************************************************
@description : Overideclass Class for IOM Order payload 
*****************************************************************************
* Modification log : 
* 1.  Added method createCustomBillingScheduleNodes
*/
public with sharing class SendForOrderOverride implements IOM_Interfaces.SendForOrderoverride {
    
    /**
    * @description  This method is used for generate Dynamic Payload for IOM
    * @param  opportunityId  Opportunity Id
    * @param  payloadMapMap<string,object>  - JSON in OBject 
    * @return Map<string,object> - Final payload Object
    */
    public Map<string,object> overridePayloadJSON(String oppId,Map<string,object> payloadMap) 
    {  
        payloadMap.put('OpportunityLineItem',filterProducts(oppId,payloadMap.get('OpportunityLineItem')));
        payloadMap.put('CustomBillingSchedule',createCustomBillingScheduleNodes(oppId));
        return payloadMap;
    }
    
    /**
    * @description  This method is used for generate Dynamic Payload for IOM
    * @param  payloadObjectNodeGroupMap - label Map
    * @return Map<string,string> - lables Map
    */
    public Map<string,string> overrideGroupNodeLabel(Map<string,string> payloadObjectNodeGroupMap) 
    {        
        payloadObjectNodeGroupMap.put('Account_Translated_FieldSet__c-Account__c-AccountId','Translations');
        return payloadObjectNodeGroupMap;
    }
    
    /**
    * @description  This method is used for removing Do Not Bill Products from IOM Sync
    * @param  payloadObjectNodeGroupMap - label Map
    * @return Map<string,string> - labels Map
    */
    private static list<Map<string,object>> filterProducts(String oppId,Object obj)
    {
        list<Map<string,object>> productLines = (list<Map<string,object>>)obj;
        list<Map<string,object>> cildNodes = new list<Map<string,object>>();
        set<String> validOliNumber = new set<String>();

        Map<String,String> quoteLineOLINumberMap = new Map<String,String>();
        Map<String,String> childParentQLIMap = new Map<String,String>();
        
        for(OpportunityLineItem oli:[SELECT Id,IOM_OLI_Number__c,SBQQ__QuoteLine__c,SBQQ__QuoteLine__r.SBQQ__RequiredBy__c,IOM_Do_not_send_for_Billing__c FROM OpportunityLineItem WHERE OpportunityId =:oppId WITH SECURITY_ENFORCED])
        {
            if(oli.IOM_Do_not_send_for_Billing__c == false){
                validOliNumber.add(oli.IOM_OLI_Number__c);
            }
            if(String.isNotBlank(oli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c)){ // get parent produt QuoteLineId
                childParentQLIMap.put(oli.IOM_OLI_Number__c, oli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c);
            }
            quoteLineOLINumberMap.put(oli.SBQQ__QuoteLine__c, oli.IOM_OLI_Number__c);
        }
        
        for(Map<string,object> oliMap:productLines)
        {
            if(oliMap.containsKey('CRMOLINumber') && validOliNumber.contains(String.valueOf(oliMap.get('CRMOLINumber')))) // valid OLI
            {
                // [GECI -595] - Add parent OLI Number for child products of a bundle 
                string crmOLINumber = String.valueOf(oliMap.get('CRMOLINumber'));                
                string crmParentOLINumber = (childParentQLIMap.containsKey(crmOLINumber) && quoteLineOLINumberMap.containsKey(childParentQLIMap.get(crmOLINumber))) ? quoteLineOLINumberMap.get(childParentQLIMap.get(crmOLINumber)) :'';
                oliMap.put('CRMParentOLINumber',crmParentOLINumber);

                cildNodes.add(oliMap);
            }
        }
        
        return cildNodes;
    }
    

    /**
    * @description  This method is used for remove create Nodes for Custom Billing Schedule
	* @param  oppId  Opportunity Id    
    * @return list<Map<string,object>> - list of labels Map
    */
    public static list<Map<string,object>> createCustomBillingScheduleNodes(String oppId)
    {
        list<Map<string,object>> childNodes = new list<Map<string,object>>();
        Map<String,object> customScheduleMap=new Map<String,object>();  
        Opportunity opp=[SELECT Id,Name,IOM_Custom_Billing_Info__c FROM Opportunity WHERE Id=:oppId];

        if(String.isNotBlank(opp.IOM_Custom_Billing_Info__c))
        {
            List<Object> deserializedList = (List<Object>)JSON.deserializeUntyped(opp.IOM_Custom_Billing_Info__c);
            for(Object paymentOBJ: deserializedList )
            {
                Map<String, Object> payment= (Map<String, Object>)paymentOBJ;
                String paymentName = 'CustomBillingSchedule'+String.valueOf(payment.get('PaymentNumber'));
                Decimal milestonePercent = (Decimal.valueOf(String.valueOf(payment.get('Percent')))).setScale(2);
                Date milestoneDeliveryDate = Date.valueOf((String)payment.get('Date'));
                DateTime milestoneDeliveryDateTime = DateTime.newInstance(milestoneDeliveryDate.year(), milestoneDeliveryDate.month(), milestoneDeliveryDate.day());
                customScheduleMap.put(paymentName,milestonePercent+','+milestoneDeliveryDateTime.format('MM/dd/yyyy'));
            }
        }
        if(!customScheduleMap.isEmpty()){
            childNodes.add(customScheduleMap);
        }
        // System.debug('childNodes '+JSON.serialize(childNodes));
        return childNodes;
    }




    /**
    * @description  This method is used for remove create Nodes for Custom Billing Schedule
	* @param  oppId  Opportunity Id    
    * @return list<Map<string,object>> - list of labels Map
    */
    /*
    public static list<Map<string,object>> createCustomBillingScheduleNodes(String oppId)
    {
        list<Map<string,object>> childNodes = new list<Map<string,object>>();
        Map<String,object> customScheduleMap=new Map<String,object>();
        
        Map<String,String> bilingSchedulefieldMap =  new Map<String,String>{'Milestone_1_Percent__c'=>'Milestone_1_Delivery_Date__c',
            'Milestone_2_Percent__c'=>'Milestone_2_Delivery_Date__c',
            'Milestone_3_Percent__c'=>'Milestone_3_Delivery_Date__c',
            'Milestone_4_Percent__c'=>'Milestone_4_Delivery_Date__c',
            'Milestone_5_Percent__c'=>'Milestone_5_Delivery_Date__c',
            'Milestone_6_Percent__c'=>'Milestone_6_Delivery_Date__c',
            'Milestone_7_Percent__c'=>'Milestone_7_Delivery_Date__c',
            'Milestone_8_Percent__c'=>'Milestone_8_Delivery_Date__c',
            'Milestone_9_Percent__c'=>'Milestone_9_Delivery_Date__c',
            'Milestone_10_Percent__c'=>'Milestone_10_Delivery_Date__c',
            'Milestone_11_Percent__c'=>'Milestone_11_Delivery_Date__c',
            'Milestone_12_Percent__c'=>'Milestone_12_Delivery_Date__c'
            };
                Map<String,String> bilingScheduleNodeNameMap =  new Map<String,String>{'Milestone_1_Percent__c'=>'CustomBillingSchedule1',
                    'Milestone_2_Percent__c'=>'CustomBillingSchedule2',
                    'Milestone_3_Percent__c'=>'CustomBillingSchedule3',
                    'Milestone_4_Percent__c'=>'CustomBillingSchedule4',
                    'Milestone_5_Percent__c'=>'CustomBillingSchedule5',
                    'Milestone_6_Percent__c'=>'CustomBillingSchedule6',
                    'Milestone_7_Percent__c'=>'CustomBillingSchedule7',
                    'Milestone_8_Percent__c'=>'CustomBillingSchedule8',
                    'Milestone_9_Percent__c'=>'CustomBillingSchedule9',
                    'Milestone_10_Percent__c'=>'CustomBillingSchedule10',
                    'Milestone_11_Percent__c'=>'CustomBillingSchedule11',
                    'Milestone_12_Percent__c'=>'CustomBillingSchedule12'
                    };
                        
                        
                        
                        Opportunity opp=[SELECT Id, Milestone_10_Delivery_Date__c, Milestone_10_Percent__c, Milestone_11_Delivery_Date__c, Milestone_11_Percent__c, 
                                         Milestone_12_Delivery_Date__c, Milestone_12_Percent__c, Milestone_1_Delivery_Date__c, Milestone_1_Percent__c, 
                                         Milestone_2_Delivery_Date__c, Milestone_2_Percent__c, Milestone_3_Delivery_Date__c, Milestone_3_Percent__c, 
                                         Milestone_4_Delivery_Date__c, Milestone_4_Percent__c, Milestone_5_Delivery_Date__c, Milestone_5_Percent__c, 
                                         Milestone_6_Delivery_Date__c, Milestone_6_Percent__c, Milestone_7_Delivery_Date__c, Milestone_7_Percent__c, 
                                         Milestone_8_Delivery_Date__c, Milestone_8_Percent__c, Milestone_9_Delivery_Date__c, Milestone_9_Percent__c
                                         FROM Opportunity WHERE Id=:oppId];
        
        for(String key: bilingSchedulefieldMap.keySet()){
            if(opp.get(key)!=null && opp.get(bilingSchedulefieldMap.get(key))!=null){
                Decimal milestonePercent = ((Decimal)opp.get(key)).setScale(2);
                Date milestoneDeliveryDate = (Date)opp.get(bilingSchedulefieldMap.get(key));
                DateTime milestoneDeliveryDateTime = DateTime.newInstance(milestoneDeliveryDate.year(), milestoneDeliveryDate.month(), milestoneDeliveryDate.day());
                customScheduleMap.put(bilingScheduleNodeNameMap.get(key),milestonePercent+','+milestoneDeliveryDateTime.format('MM/dd/yyyy'));
            }    
        }
        
        if(!customScheduleMap.isEmpty()){
            childNodes.add(customScheduleMap);
        }
        //system.debug(json.serialize(new Map<String,list<Map<string,object>>>{'CustomBillingSchedule'=>childNodes}));
        return childNodes;
    }*/
}