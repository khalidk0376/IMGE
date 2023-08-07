/* Created/Modified By  :   Girikon[Aishwarya CCEN-658]
 * Created On           :   19/02/2019
 * @description         :   Handler class which is called by BadgesAssignmentByBoothType class(As part of trigger interface)
 * Methods              :   createBoothTypeRecords
 * Test Class           :   BadgesAssignmentByBoothType_Test
 * Last Modified By     :   Girikon[Aishwarya CCEN-578 Apr 1 2019]  
**/
public without sharing class CreateBoothTypeBadgeLimitRecords
{
    public void createBoothTypeRecords(Set<Id> eeIdSet)
    {
        List<Booth_Size_Badge_Limit__c> listBadgeLimitToInsert = new List<Booth_Size_Badge_Limit__c>();
        List<string> listProductTypes = new List<string>();
        Map<string,string> mapProductEventEdition = new Map<string,string>();
        //Query to get the match product names from the event edition
        /*CCEN-578 replacing the reference of Booth Product Type to Matched Product Name of Event Edition Start*/
        Map<Id, Event_Edition__c> mapEventEdition = new Map<Id,Event_Edition__c>([Select Id, Matched_Product_Name__c FROM Event_Edition__c where Id IN: eeIdSet 
                                                                                  AND Event_Edition_Status__c ='Confirmed' AND Matched_Product_Name__c != null]); 
        system.debug('####################MatchProducts '+mapEventEdition);
        
        for(Booth_Size_Badge_Limit__c badgelimit :[Select Id, Booth_Type__c, Event_Edition__c FROM Booth_Size_Badge_Limit__c where Event_Edition__c    
                                                              IN:eeIdSet AND Booth_Size_From__c = null AND Booth_Size_To__c = null AND Booth_Type__c != null])
        {
            mapProductEventEdition.put(badgelimit.Booth_Type__c+badgelimit.Event_Edition__c,badgelimit.Event_Edition__c);
        }

        system.debug('@@@@@@@@@@@@@@@@@@@@@@@@MAP '+mapProductEventEdition+'size '+mapProductEventEdition.size());
        
        if(!mapEventEdition.isEmpty() && mapEventEdition.size()>0)
        {
            for(Event_Edition__c ee :mapEventEdition.values())
            {
                String productType = ee.Matched_Product_Name__c;            
                if(productType != null)
                {
                    listProductTypes = productType.split(';');
                }
                system.debug('%%%%%%%%%%%%%%%%%% '+listProductTypes);
            }
        }
        /*CCEN-578 replacing the reference of Booth Product Type to Matched Product Name of Event Edition End*/
        //Iteration on product types from which BoothTypeBadgeLimit records will be created
        if(!listProductTypes.isEmpty() && listProductTypes.size()>0)
        {
            for(Event_Edition__c ee :mapEventEdition.values())
            {
                for(integer i=0;i<listProductTypes.size();i++)
                {
                    //Check product type is not blank and matching booth type record is not exist for related product type
                    if(!mapProductEventEdition.isEmpty() && !mapProductEventEdition.containsKey(listProductTypes[i]+ee.id))
                    {
                        system.debug('$$$$$$$$$$$$$$ '+listProductTypes[i]+ee.id);
                        Booth_Size_Badge_Limit__c badgelimit = new Booth_Size_Badge_Limit__c();
                        badgelimit.Name = listProductTypes[i];
                        badgelimit.Booth_Type__c = listProductTypes[i];
                        badgelimit.Match_Product_Entry_Type__c ='Fixed';
                        badgelimit.Badges_Allowed_by_Booth_Type__c = 0;
                        badgelimit.Event_Edition__c = ee.id;
                        listBadgeLimitToInsert.add(badgelimit);
                    }
                    else if(mapProductEventEdition.isEmpty() || mapProductEventEdition.size() == 0)
                    {
                        system.debug('=====================HELLOOO');
                        Booth_Size_Badge_Limit__c badgelimit = new Booth_Size_Badge_Limit__c();
                        badgelimit.Name = listProductTypes[i];
                        badgelimit.Booth_Type__c = listProductTypes[i];
                        badgelimit.Match_Product_Entry_Type__c ='Fixed';
                        badgelimit.Badges_Allowed_by_Booth_Type__c = 0;
                        badgelimit.Event_Edition__c = ee.id;
                        listBadgeLimitToInsert.add(badgelimit);
                    }
                }
            }
        }
        
        system.debug('#################listBadgeLimitToInsert '+listBadgeLimitToInsert +'Size: '+listBadgeLimitToInsert.size());
        if(listBadgeLimitToInsert != null && listBadgeLimitToInsert.size()>0 && Schema.sObjectType.Booth_Size_Badge_Limit__c.IsCreateable())
        {
            insert listBadgeLimitToInsert;
        }
    }
}