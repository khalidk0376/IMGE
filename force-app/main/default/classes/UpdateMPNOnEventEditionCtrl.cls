/**
 * Created/Modified By  :   Girikon[Aishwarya-759]
 * Created On   :           Apr 5 2019
 * @description :           This class is used for updating the MPN picklist values on addition/removal of booth product type
 * Test Class   :           UpdateMPNOnEventEditionCtrl_Test (96%)
 * Last Modified By :       Girikon[Aishwarya Apr 9 2019]
 */

public with sharing class UpdateMPNOnEventEditionCtrl
{
    public void updateMpnRecordsOnEE(Set<Id> eeIdSet, List<String> bpTypeSet, Boolean checkIfBPTypeBlank)
    {
        List<Booth_Product_Type_Configuration__c> listBPTypeConfig = new List<Booth_Product_Type_Configuration__c>();
        Map<String,String> mapBPTConfigMapping = new Map<String,String>();
        // query to booth type configuration for fetching the mapping values defined related to booth product type
        if(Schema.sObjectType.Booth_Product_Type_Configuration__c.isAccessible())
        {
            listBPTypeConfig =[Select Id, Booth_Product_Type__c, Matched_Product_Name__c FROM Booth_Product_Type_Configuration__c where Booth_Product_Type__c IN:bpTypeSet AND Matched_Product_Name__c !=null];
        }
        system.debug('======listBPTC '+listBPTypeConfig); system.debug('======bpTypeSet '+bpTypeSet);
        if(!listBPTypeConfig.isEmpty() && listBPTypeConfig.size()>0)
        {
            for(Booth_Product_Type_Configuration__c bptc : listBPTypeConfig)
            {
                mapBPTConfigMapping.put(bptc.Booth_Product_Type__c, bptc.Matched_Product_Name__c);
            }
        }
        
        // query event edition for updating the corresponding matched product name
        Map<Id,Event_Edition__c> mapEventEdition = new Map<Id,Event_Edition__c>([Select Id, Booth_Product_Type__c, Matched_Product_Name__c FROM Event_Edition__c  
                                                                                 WHERE Id IN:eeIdSet AND Event_Edition_Status__c ='Confirmed']);
        
        /* If any picklist value is added/removed from the booth product type picklist on EE start */
        if(PreventRecursive.runOnceCreate() && !mapEventEdition.isEmpty() && mapEventEdition.size()>0 )
        {
            system.debug('Helloooo');
            String interests = '';
            Set<String> setPreventDupMPN = new Set<String>();
            for(Event_Edition__c ee : mapEventEdition.values())
            {
                for(String str: bpTypeSet)
                {
                    if(mapBPTConfigMapping.size()>0 && mapBPTConfigMapping.containsKey(str) && !setPreventDupMPN.contains(mapBPTConfigMapping.get(str) + ';'))
                    {
                        interests  = interests + mapBPTConfigMapping.get(str) + ';' ;
                        setPreventDupMPN.add(mapBPTConfigMapping.get(str) + ';' );
                    }
                }
                if(checkIfBPTypeBlank == false)
                {
                    ee.Matched_Product_Name__c = interests;
                }
                else{
                    ee.Matched_Product_Name__c =null;
                }
            }
            update mapEventEdition.values();
        }
        /* If any picklist value is added/removed from the booth product type picklist on EE end */
    }
}