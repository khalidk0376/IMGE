/**
 * Created By: Girikon(Archit)
 * Created On:  09/09/2017
 * Modified by :  
 * Modified On: 
 * Description/Purpose: This test class covers the apex class : GetProductPriceOnCustomerPortal
 * Apex Class: GetProductPriceOnCustomerPortal
**/

@isTest
public class GetProductPriceOnCustomerPortal_Test {
    public static testMethod void ProductPriceOnCustomerPortal_DataInsert(){
        // Setup test data
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='fhjkbfjkbfjdffsdfs@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing11', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='fhjkbfjkbfjdffsdfs@testorg.com');
            Event_Edition__c OEve;
            Account acc1;
          Product2 prd1;
          Pricebook2 customPB;
        System.runAs(u) 
        {
            // The following code runs as user 'u' 
            
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId());
            
            
            acc1 = new Account();
            acc1.Name='acc1';
            acc1.BillingCity ='DAllas' ;
            acc1.BillingCountry='USA';
            acc1.BillingPostalCode='75068';
            acc1.BillingState='Texas';
            acc1.BillingStreet='water well street';              
            insert acc1;
            Contact con = new Contact(LastName='User',FirstName ='Test',AccountId=acc1.id, MobilePhone = '2121212145');
            insert con;
            
            Id pricebookId = Test.getStandardPricebookId();
             customPB = new Pricebook2(Name='ICRE', isActive=true);
            insert customPB;
            OEve = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',Price_Rule_object_Name__c='TOC__c', Year__c='2017',End_Date__c=System.Today(),Start_Date__c=System.Today(),Event_Price_Book__c=customPB.Id);
            insert OEve;
            System.assertEquals(OEve.Event_Code__c,'WOC17', 'Event Code');
            EventCurrecies__c eventCurrency = new EventCurrecies__c (Name='USD',Event_Edition__c=OEve.id);
            insert eventCurrency;
            System.assertEquals(eventCurrency.Name,'USD', 'Event Currency');
            OEve.EventCurrency__c = eventCurrency.id;
            update OEve;
            System.assert(OEve.EventCurrency__c != null, 'Event Currency');
            
            prd1 = new Product2(Name = 'Linear Booth',Family = 'Booth',Product_Brand__c=OEve.name,To_Be_Dispalyed_On_OBC__c = true,Expired__c='No', Number_of_Corners__c = 0, Event_Edition_Pool__c = 'WOC',EAC_Fee__c=true);
            insert prd1;

          
            
           
            
        
            PricebookEntry StndrdPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prd1.Id,UnitPrice = 100, IsActive = true);
            insert StndrdPrice;
            
            PricebookEntry custmPrice = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = prd1.Id,UnitPrice = 100, IsActive = true);
            insert custmPrice;
            
            ICRE__c objicre = new ICRE__c();
            objicre.PBName__c = customPB.id;
            objicre.PBName__c = customPB.id;
            objicre.Product__c = prd1.id;
            objicre.active__c = true;
            insert objicre;
            
            Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC');
            insert oEventseries;

            Opportunity oOpportunity = new Opportunity(Name = 'Expocad Opportunity', CloseDate = Date.today(), StageName = 'Proposal', EventEdition__c = OEve.Id,Amount=200.00, Event_Series__c = oEventseries.Id, AccountId = acc1.Id, Billing_Contact__c = Con.Id);
            insert oOpportunity;
            
            SBQQ__Quote__c oQuote = new SBQQ__Quote__c(CurrencyIsoCode = 'USD',SBQQ__Status__c = 'Quote Sent', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = oOpportunity.id, SBQQ__Account__c = acc1.Id);
            insert oQuote;
            
            //SBQQ__QuoteLine__c oQuoteLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = oQuote.Id, SBQQ__Product__c = prd1.Id, SBQQ__ListPrice__c=10.10, SBQQ__Quantity__c = 2, SBQQ__Number__c = 1, Line_Description__c = 'Test', Booth_Number__c = 'TESTBN3', Booth__c = True);
            //insert oQuoteLine ;
            
            SBQQ__ProductFeature__c objFeature = new SBQQ__ProductFeature__c();
            objFeature.name='Core Product';
            objFeature.SBQQ__Number__c = 10;
            objFeature.SBQQ__ConfiguredSKU__c = prd1.id;
            objFeature.SBQQ__MinOptionCount__c = 1;
            insert objFeature;
            
            SBQQ__ProductOption__c objOptions = new SBQQ__ProductOption__c();
            objOptions.SBQQ__Number__c =5;
            objOptions.SBQQ__Required__c=true;
            objOptions.SBQQ__ConfiguredSKU__c = prd1.id;
            objOptions.SBQQ__OptionalSKU__c = prd1.id;
            objOptions.SBQQ__Feature__c = objFeature.id;
            insert objOptions;
            
        }
        Test.startTest();
        GetProductPriceOnCustomerPortal.getCalclatedPriceRule(prd1.id,'1','200.00');
        GetProductPriceOnCustomerPortal.getProductPriceOnCustomerPortal(prd1.id,customPB.id,OEve.Price_Rule_object_Name__c , OEve.id, '1');
        GetProductPriceOnCustomerPortal.getProductPriceOnCustomerPortalForAddtoCart(prd1.id,customPB.id,OEve.Price_Rule_object_Name__c , OEve.id, '1');
        GetProductPriceOnCustomerPortal.getProductDetails(OEve.Event_Code__c);
        Test.stopTest();
    }
}