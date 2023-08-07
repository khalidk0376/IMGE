@isTest
public class updateEventPicklist_Test {
    static testMethod void unitTest() {
    
        Event_Edition__c eve = new Event_Edition__c(Name='World Of Concrete 2017',CurrencyIsoCode='USD',Approval_Service_Now_ID__c='Test');
        insert eve;
        Product2 prod = new Product2(Name = 'TestForEvent0',Family = 'Hardware',CurrencyIsoCode='USD',Booth_Product_Type__c='Contra Shell Scheme',Event_Edition_Pool__c = 'WOC',Event_Edition__c = eve.Id , Event_Product_Type__c = 'Booth');
        insert prod;
        Product2 prod1 = new Product2(Name = 'TestForEvent1',Family = 'Hardware',CurrencyIsoCode='USD',Booth_Product_Type__c='Contra Shell Scheme',Event_Edition_Pool__c = 'WOC',Event_Edition__c = eve.Id , Event_Product_Type__c = 'Booth Cancellation');
        insert prod1;
        Product2 prod2 = new Product2(Name = 'TestForEvent2',Family = 'Hardware',CurrencyIsoCode='USD',Booth_Product_Type__c='Contra Shell Scheme',Event_Edition_Pool__c = 'WOC',Event_Edition__c = eve.Id , Event_Product_Type__c = 'Digital');
        insert prod2;
        Product2 prod3 = new Product2(Name = 'TestForEvent3',Family = 'Hardware',CurrencyIsoCode='USD',Booth_Product_Type__c='Contra Shell Scheme',Event_Edition_Pool__c = 'WOC',Event_Edition__c = eve.Id , Event_Product_Type__c = 'Merchandize');
        insert prod3;
        Product2 prod4 = new Product2(Name = 'TestForEvent4',Family = 'Hardware',CurrencyIsoCode='USD',Booth_Product_Type__c='Contra Shell Scheme',Event_Edition_Pool__c = 'WOC',Event_Edition__c = eve.Id , Event_Product_Type__c = 'Other');
        insert prod4;
        Product2 prod5 = new Product2(Name = 'TestForEvent5',Family = 'Hardware',CurrencyIsoCode='USD',Booth_Product_Type__c='Contra Shell Scheme',Event_Edition_Pool__c = 'WOC',Event_Edition__c = eve.Id , Event_Product_Type__c = 'Publishing');
        insert prod5;
        Product2 prod6 = new Product2(Name = 'TestForEvent6',Family = 'Hardware',CurrencyIsoCode='USD',Booth_Product_Type__c='Contra Shell Scheme',Event_Edition_Pool__c = 'WOC',Event_Edition__c = eve.Id , Event_Product_Type__c = 'Sponsorship');
        insert prod6;
        Product2 prod7 = new Product2(Name = 'TestForEvent7',Family = 'Hardware',CurrencyIsoCode='USD',Booth_Product_Type__c='Contra Shell Scheme',Event_Edition_Pool__c = 'WOC',Event_Edition__c = eve.Id , Event_Product_Type__c = 'Premium');
        insert prod7;
        Product2 prod8 = new Product2(Name = 'TestForEvent8',Family = 'Hardware',CurrencyIsoCode='USD',Booth_Product_Type__c='Contra Shell Scheme',Event_Edition_Pool__c = 'WOC',Event_Edition__c = eve.Id , Event_Product_Type__c = 'Commissions');
        insert prod8;
        Product2 prod10 = new Product2(Name = 'TestForEvent9',Family = 'Hardware',CurrencyIsoCode='USD',Booth_Product_Type__c='Contra Shell Scheme',Event_Edition_Pool__c = 'WOC',Event_Edition__c = eve.Id , Event_Product_Type__c = 'Attendees' , SAP_Material_Code__c = 'SAP0002');
        insert prod10;
        Product2 prod9 = new Product2(Name = 'TestForEvent10',Family = 'Hardware',CurrencyIsoCode='USD',Booth_Product_Type__c='Contra Shell Scheme',Event_Edition_Pool__c = 'WOC',Event_Edition__c = eve.Id , Event_Product_Type__c = 'Conference', SAP_Material_Code__c = 'SAP0002');
        insert prod9;
        prod9.Booth_Product_Type__c = 'Shell Scheme';
        update prod9;
        System.assertNotEquals('TestForEvent', prod9.Name, 'Test Method has been failed');
    }
}