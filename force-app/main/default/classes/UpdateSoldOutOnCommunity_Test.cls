/**
 * Created/Modified By: Girikon(Amish)
 * Created On:          8/23/2017
 * Description/Purpose: This test class covers the apex class : UpdateSoldOutOnCommunity
 * Methods:             UpdateSoldOutOnCommunity_Test
 * Apex Class:          UpdateSoldOutOnCommunity
**/

@isTest
private class UpdateSoldOutOnCommunity_Test
{
    // Method name is changed by Palla Kishore for the ticket BK-19606
    public static testMethod void UpdateSoldOutOnCommunity_TestMethod()
    {
        Event_Edition__c OEve= new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today());
        insert OEve;    
        system.debug(OEve.id);                             
        System.assertEquals('World of Concrete 2017', OEve.Name, 'Here value is not same');
        
        Product2 pro= new Product2(Name='TestPro',Sold_Out__c=true,Event_Edition_Pool__c='WOC',Product_Brand__c=OEve.Name);          
        insert pro;        
        String ProBoolean= pro.id+'true';
        
        List<String> pList= new  List<String>();
        pList.Add(ProBoolean);
        string prodIDs=System.JSON.serialize(pList);
        UpdateSoldOutOnCommunity.UpdateSoldOutOnCommunity(prodIDs,OEve.Name);
    }
}