/**
 * Created/Modified By: Girikon(Archit)
 * Created On:          9/11/2017
 * Description/Purpose: This test class covers the apex class : CarouselCompulsoryProduct
 * Methods:             unitTest
 * Apex Class:          CarouselCompulsoryProduct
 **/

@isTest
public class CarouselCompulsoryProduct_Test{
    static testMethod void unitTest() 
    {   
        
         // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='fhfhfhfhhffha@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing11', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='fhfhfhfhhffha@testorg.com');
            Event_Edition__c OEve;
            Account acc1;
        System.runAs(u) 
        {
            acc1 = new Account();
            acc1.Name='acc1';
            insert acc1;
            
            Contact con = new Contact(LastName='User',FirstName ='Test',AccountId=acc1.id);
            insert con;
            
            OEve = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today());
            insert OEve;
            System.assertEquals(OEve.Event_Code__c,'WOC17', 'Event Code');
            EventCurrecies__c eventCurrency = new EventCurrecies__c (Name='USD',Event_Edition__c=OEve.id);
            insert eventCurrency;
            System.assertEquals(eventCurrency.Name,'USD', 'Event Currency');
            OEve.EventCurrency__c = eventCurrency.id;
            update OEve;
            System.assert(OEve.EventCurrency__c != null, 'Event Currency');
            
            Product2 prod = new Product2();
            prod.Name = 'test Product';
            insert prod;
            
            ApexPages.currentPage().getParameters().put('eventId',oEve.Id);
            ApexPages.currentPage().getParameters().put('ProductId',prod.Id);
                
            CarouselCompulsoryProduct com= new CarouselCompulsoryProduct ();
            CarouselOptionalProduct opt = new CarouselOptionalProduct();
            com.getItems();
            opt.getItems();
        }
       
    }
}