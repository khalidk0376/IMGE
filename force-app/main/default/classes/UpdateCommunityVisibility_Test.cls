/**
 * Created/Modified By: Girikon(Archit)
 * Created On:          8/1/2017
 * Description/Purpose: This test class covers the apex class : UpdateCommunityVisibility
 * Methods:             unitTest
 * Apex Class:          UpdateCommunityVisibility
**/

@isTest
public class UpdateCommunityVisibility_Test {
    static testMethod void unitTest() 
    {  
        Event_Edition__c event = new Event_Edition__c(Name = 'World of Concrete');
        insert event;
        system.debug(event);
        System.assertEquals('World of Concrete', event.name, 'Here value is not same');
        
        list<product2> productLst = new list<product2>();
        product2 p = new product2();                
        p.Name= 'testProduct';
        p.Event_Edition_Pool__c ='WOC';
        p.Product_Brand__c='World of Concrete';
        productLst.add(p); 
        insert productLst;
        system.debug(productLst);
        string exhibitorId=productLst[0].id;
        List<String> exbadgeIdList= new  List<String>();
        exbadgeIdList.Add(exhibitorId);
        string exbadgeIds=System.JSON.serialize(exbadgeIdList);
        Test.startTest();
             UpdateCommunityVisibility.UpdateCommunityVisibility(exbadgeIds,event.Name);
        Test.stopTest();
    }

}