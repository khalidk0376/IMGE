/**
 * Created/Modified By: Girikon(Amish)
 * Created On:          7/13/2017
 * Description/Purpose: This class is called through the SKUID page: Event_Edition_Product_List
 *                      This Class is for fetching the product as per the eventIDs and pasing it to the skuid page
 * Methods:             EventBasedProductList
 * Test Class:          EventBasedProductList_Test
 **/

Global class EventBasedProductList
{
    webservice static string eventBasedProduct(String eventName)
    {
        // getting list of all product as per "Product_Brand__c"    
        list<product2> productLst = [select id,ProductOwner__c,Name,Sold_Out__c,Visible_On_Community__c,Product_Brand__c,Event_Product_Type__c,Family, Add_To_Cart_Visibility__c from product2 where Event_Product_Type__c!='Booth' AND Product_Brand__c=:eventName];
        List<ProductDetailWrapper> proWrapper=new List<ProductDetailWrapper>();
        //Adding all product to the wrapper class
        if(productLst != null && productLst.size()>0)      
        {
        //system.debug('amish');
            for(product2 pro : productLst)
            {
              ProductDetailWrapper pDetail=new ProductDetailWrapper();
              pDetail.Id=pro.id;
              pDetail.Name=pro.Name; 
              pDetail.CommunityVisibility=pro.Visible_On_Community__c; 
              pDetail.AddToCartVisibility=pro.Add_To_Cart_Visibility__c;
              pDetail.SoldOut=pro.Sold_Out__c;
              pDetail.ProductOwner=pro.ProductOwner__c;                                      
              proWrapper.add(pDetail);                 
            }
        }
        system.debug(proWrapper);
        String JSONString = JSON.serialize(proWrapper);
        system.debug(JSONString );
        return JSONString;// returing in Json format
    }
    // wrapper class to populate value with product fields that will be passed to skuid in JSON format
    global class ProductDetailWrapper
    {
        public String Id{get;set;}
        public String Name{get;set;}
        public Boolean CommunityVisibility{get;set;}
        public Boolean AddToCartVisibility{get;set;}
        public Boolean SoldOut{get;set;}
        public String ProductOwner{get;set;}              
    }
       
}