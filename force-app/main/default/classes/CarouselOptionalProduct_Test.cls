/**
 * Created/Modified By: Girikon(Archit)
 * Created On:          9/1/2017
 * Description/Purpose: This test class covers the apex class : CarouselOptionalProduct
 * Methods:             unitTest
 * Apex Class:          CarouselOptionalProduct
 **/

@isTest
public class CarouselOptionalProduct_Test {
    public static testMethod void CarouselOptionalProduct_DataInsert()
    {
        Pricebook2 testprice = new Pricebook2();
        testprice.name = 'testPricebook2';
        insert testprice;
        
        Event_Edition__c OEve = new Event_Edition__c(Name='World of Concrete 2017',Event_Price_Book__c=testprice.id,Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today());
        insert OEve;
        System.assertEquals(OEve.Event_Code__c,'WOC17', 'Event Code');
        EventCurrecies__c eventCurrency = new EventCurrecies__c (Name='USD',Event_Edition__c=OEve.id);
        insert eventCurrency;
        System.assertEquals(eventCurrency.Name,'USD', 'Event Currency');
        OEve.EventCurrency__c = eventCurrency.id;
        update OEve;
        System.assert(OEve.EventCurrency__c != null, 'Event Currency');
        
        ApexPages.currentPage().getParameters().put('ProductId',testprice.id);
        ApexPages.currentPage().getParameters().put('eventId',OEve.id);
        
        Test.startTest();
            new CarouselOptionalProduct();
        Test.stopTest();
    }

}