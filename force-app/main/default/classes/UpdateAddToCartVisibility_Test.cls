/**
 * Created/Modified By: Girikon(Amish, archit)
 * Created On:          8/28/2017
 * Description/Purpose: This test class covers the apex class : UpdateAddToCartVisibility
 * Methods:             UpdateAddToCartVisibility_Test
 * Apex Class:          UpdateAddToCartVisibility
**/

@isTest
private class UpdateAddToCartVisibility_Test
{
    // Method name is changed by Palla Kishore for the ticket BK-19606
    public static testMethod void UpdateAddToCartVisibility_TestMethod()
    {
        Event_Edition__c OEve= new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today());
        insert OEve;    
        system.debug(OEve.id);                             
        System.assertEquals('World of Concrete 2017', OEve.name, 'Here value is not same');
        
        Product2 pro= new Product2(Name='TestPro',Add_To_Cart_Visibility__c=true,Event_Edition_Pool__c='WOC',Product_Brand__c=OEve.Name);          
        insert pro;        
        String ProBoolean= pro.id+'true';
        
        List<String> pList= new  List<String>();
        pList.Add(ProBoolean);
        string prodIDs=System.JSON.serialize(pList);
        UpdateAddToCartVisibility.updateAddToCartVisibility(prodIDs,OEve.Name);
    }
}