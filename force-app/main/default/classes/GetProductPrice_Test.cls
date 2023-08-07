/**
 * Created/Modified By: Girikon(Archit)
 * Created On:          9/9/2017
 * Description/Purpose: This test class covers the apex class : GetProductPrice
 * Methods:             GetProductPrice_DataInsert
 * Apex Class:          GetProductPrice
**/

@isTest
public class GetProductPrice_Test 
{
    public static testMethod void GetProductPrice_DataInsert()
    {
        // Setup test data
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='standardusergetprod@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing11', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standardusergetprod@testorg.com');
            Event_Edition__c OEve;
            Account acc1;
            Product2 prd1;
        System.runAs(u) 
        {
            // The following code runs as user 'u' 
            
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId());
            
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
            
            prd1 = new Product2(Name = 'Linear Booth',Family = 'Booth',Product_Brand__c=OEve.name,To_Be_Dispalyed_On_OBC__c = true,Expired__c='No', Number_of_Corners__c = 0, Event_Edition_Pool__c = 'WOC');
            insert prd1;

          
            
            Pricebook2 customPB = new Pricebook2(Name='ICRE', isActive=true);
            insert customPB;
            
            Pricebook2 stdPB = new Pricebook2(Name='ICRE2', isActive=true);
            insert stdPB;
            
            Id pricebookId = Test.getStandardPricebookId();
            
            PricebookEntry StndrdPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prd1.Id,UnitPrice = 100, IsActive = true);
            insert StndrdPrice;
            
            ICRE__c objicre = new ICRE__c();
            objicre.PBName__c = stdpb.id;
            objicre.PBName__c = stdpb.id;
            objicre.Product__c = prd1.id;
            objicre.active__c = true;
            objicre.Price__c=100;
            insert objicre;
            
            Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC');
            insert oEventseries;

            Opportunity oOpportunity = new Opportunity(Name = 'Expocad Opportunity', CloseDate = Date.today(), StageName = 'Proposal', EventEdition__c = OEve.Id, Event_Series__c = oEventseries.Id, AccountId = acc1.Id, Billing_Contact__c = Con.Id);
            insert oOpportunity;
            
            SBQQ__Quote__c oQuote = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Quote Sent', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = oOpportunity.id, SBQQ__Account__c = acc1.Id);
            insert oQuote;
            
            SBQQ__QuoteLine__c oQuoteLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = oQuote.Id, SBQQ__Product__c = prd1.Id, SBQQ__ListPrice__c=10.10, SBQQ__Quantity__c = 2, SBQQ__Number__c = 1, Line_Description__c = 'Test', Booth_Number__c = 'TESTBN3', Booth__c = True);
            insert oQuoteLine ;
            
            SBQQ__ProductFeature__c objFeature = new SBQQ__ProductFeature__c();
            objFeature.name='Core Product';
            objFeature.SBQQ__Number__c = 10;
            objFeature.SBQQ__ConfiguredSKU__c = prd1.id;
            objFeature.SBQQ__MinOptionCount__c = 1;
            insert objFeature;
            
            SBQQ__ProductOption__c objOptions = new SBQQ__ProductOption__c();
            objOptions.SBQQ__Number__c =5;
            objOptions.SBQQ__ConfiguredSKU__c = prd1.id;
            objOptions.SBQQ__OptionalSKU__c = prd1.id;
            objOptions.SBQQ__Feature__c = objFeature.id;
            insert objOptions;
            
        }
        Test.startTest();
        // Modified by Palla Kishore for the ticket BK-19606
            GetProductPrice.getProductPriceMethod(prd1.id,'ICRE__c', OEve.id,'200');
            GetProductPrice.getCalclatedPriceRule(prd1.id,'50', '100');
        Test.stopTest();
    }
}