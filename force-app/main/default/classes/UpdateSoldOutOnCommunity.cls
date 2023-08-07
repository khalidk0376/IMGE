/**
 * Created/Modified By: Girikon(Amish)
 * Created On:          7/25/2017
 * Description/Purpose: This class is called through the SKUID page: Event_Edition_Product_List
 *                      This Class is for updating teh availability of product (SOLD Out) as per the eventIDs.
 * Methods:             UpdateSoldOutOnCommunity
 * Test Class:          UpdateSoldOutOnCommunity_Test
**/

Global class UpdateSoldOutOnCommunity
{
    webservice static string UpdateSoldOutOnCommunity(String ProductIdList,String eventId)
    {
        // list of product as per "Product_Brand__c"
        list<product2> productLst = [select id,Sold_Out__c, Name,Product_Brand__c,Event_Product_Type__c,Family from product2 where Product_Brand__c=:eventId];        
        system.debug(ProductIdList.length());
        List<String> st = new  List<String>();
        st =(List<String>) System.JSON.deserialize(ProductIdList, List<String>.class);// deseriazing the ProductIdList using JSON
        //system.debug(st );       
        //system.debug(productLst );
        List<product2> newList = new  List<product2>();
        // updating the community_visibility field
        if(productLst.size()>0)      
        {
        //system.debug('amish');
            for(product2 pro : productLst)
            {
                
               for (String proIds: st)
               {
                   String subProId= proIds.substring(0,18);// Grabing the 18 digit salesforce id from string
                   String subBoolean= proIds.substring(18);// Grabing Boolean value from string
                   system.debug(subProId);
                   system.debug(subBoolean);
                   if (subProId==pro.Id)
                   {
                       pro.id=subProId;
                       pro.Sold_Out__c=boolean.valueof(subBoolean); 
                       if ( boolean.valueof(subBoolean)== false)
                       {
                           pro.Status__c='Available';
                       }
                       if ( boolean.valueof(subBoolean)== true)
                       {
                           pro.Status__c='  Sold Out';
                       }
                                          
                       newList.add(pro);
                   }
               }
               
            }
            if(newList.size()>=0)
            {
                update newList;
            }
        }
        return null;  
    }    
          
}