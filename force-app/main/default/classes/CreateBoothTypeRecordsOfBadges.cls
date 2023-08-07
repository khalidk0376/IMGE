/**
 * Created/Modified By  :   Girikon[Aishwarya-658]
 * Created On   :           21/02/2019
 * @description :           This class is called through the SKUID page: Badges_ExhibitorProfile_ForOps
 * Test Class   :           CreateBoothTypeRecordsOfBadges_Test
 * Last Modified By :       Girikon[Aishwarya CCEN-578 Apr 1 2019]
 */

global  class CreateBoothTypeRecordsOfBadges
{
    webservice static boolean createBoothTypeRecordsBadges(String eventId)    
    {
        List<Booth_Size_Badge_Limit__c> listBadgeLimitToInsert = new List<Booth_Size_Badge_Limit__c>();
        List<string> listProductTypes = new List<string>();
        Map<string,string> mapProductEventEdition = new Map<string,string>();
        //Map<String,Booth_Size_Badge_Limit__c > mapExistingProductType= new Map<String,Booth_Size_Badge_Limit__c >();//added
        //List<Booth_Size_Badge_Limit__c > delList= new List<Booth_Size_Badge_Limit__c>();//added
        //List<Booth_Size_Badge_Limit__c > badgeList= [Select Id, Booth_Type__c, Event_Edition__c FROM Booth_Size_Badge_Limit__c where Event_Edition__c    
                                                              //=:eventId AND Booth_Size_From__c = null AND Booth_Size_To__c = null AND Booth_Type__c != null];//added
        List<Event_Settings__c> listEventSetting = new List<Event_Settings__c>();
        if(Schema.sObjectType.Event_Settings__c.isAccessible())
        {
            listEventSetting = [Select Id, Allotment_By_Booth_Type__c FROM Event_Settings__c where Event_Edition__c =:eventId AND Allotment_By_Booth_Type__c =True LIMIT 1];
        }
        for(Booth_Size_Badge_Limit__c badgelimit :[Select Id, Booth_Type__c, Event_Edition__c FROM Booth_Size_Badge_Limit__c where Event_Edition__c    
                                                              =:eventId AND Booth_Size_From__c = null AND Booth_Size_To__c = null AND Booth_Type__c != null])
        {
            mapProductEventEdition.put(badgelimit.Booth_Type__c+badgelimit.Event_Edition__c,badgelimit.Event_Edition__c);
            //mapExistingProductType.put(badgelimit.Booth_Type__c,badgelimit);//added
        }
        
        if(!listEventSetting.isEmpty() && listEventSetting.size()>0 && mapProductEventEdition.size() == 0)
        {
            //Query to get the match product names from the event edition
            /*CCEN-578 replacing the reference of Booth Product Type to Matched Product Name of Event Edition Start*/
            Map<Id, Event_Edition__c> mapEventEdition = new Map<Id,Event_Edition__c>([Select Id, Matched_Product_Name__c FROM Event_Edition__c where Id =:eventId
                                                                                      AND Event_Edition_Status__c ='Confirmed' AND Matched_Product_Name__c != null]);
            if(!mapEventEdition.isEmpty() && mapEventEdition.size()>0)
            {
                for(Event_Edition__c ee :mapEventEdition.values())
                {
                    String productType = ee.Matched_Product_Name__c;            
                    if(productType != null)
                    {
                        listProductTypes = productType.split(';');
                    }
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
                        if(mapProductEventEdition.isEmpty() || mapProductEventEdition.size() == 0)
                        {
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
            return true;
        }
      
        else
        {
            return false;
        } 
            
    }
}