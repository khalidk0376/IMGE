/**
 * Created/Modified By: Girikon(Archit)
 * Created On:          8/1/2017
 * Methods:             unitTest
 * Apex Class:          EventBasedProductList
 * * Modified By : Rajesh kumar Yadav Bk-3751
 **/

@isTest
public class EventBasedProductList_Test {
    static testMethod void unitTest() 
    {  
        //ProductDetailWrapper pro = new ProductDetailWrapper();
        Event_Series__c es=new Event_Series__c(Name='World of Concrete');
        insert es;
        system.assertEquals(es.Name, 'World of Concrete', 'Event series equals to World of Concrete');
        
        Event_Edition__c event = new Event_Edition__c(Name = 'World of Concrete 2017',Part_of_Series__c=es.Id);
        insert event;
        system.assertEquals(event.Name, 'World of Concrete 2017', 'Event name equals to World of Concrete 2017');
       
        list<product2> productLst = new list<product2>();
        product2 p = new product2();                
        p.Name= 'testProduct';     
        p.Event_Product_Type__c='Other';
        P.Brand__c=es.Name;
        P.Event_Edition_Pool__C='WOC';
        p.Product_Brand__c=event.Name;
        productLst.add(p); 
        insert productLst;
        system.debug(productLst);
        system.assertEquals(event.Name, 'World of Concrete 2017', 'Both values should be the same.');
       
        EventBasedProductList.eventBasedProduct(event.Name);
        
        EventBasedProductList.ProductDetailWrapper wrp= new EventBasedProductList.ProductDetailWrapper();
         wrp.Id=productLst[0].id;
         wrp.Name=productLst[0].Name;
         wrp.CommunityVisibility=true;
         wrp.AddToCartVisibility=false;
         wrp.SoldOut=true;
         wrp.ProductOwner='test';
        //insert wrp;       
    }
}