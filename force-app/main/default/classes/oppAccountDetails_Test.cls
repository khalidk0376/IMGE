/**
 * Created/Modified By: Girikon(Archit)
 * Created On:          10/30/2017 
 * Modified By:    Girikon(Amish) - CCEN 274
 * Modified On: 08/29/2018
 * Description/Purpose: This test class covers the apex class : oppAccountDetails
 * Methods:             oppAccountDetails_DataInsert
 * Apex Class:          oppAccountDetails
**/

@isTest
public class oppAccountDetails_Test {
    public static testMethod void oppAccountDetailsDataInsert()
    {
        // Setup test data
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser11@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing11', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduserjohn11@testorg.com');
            Event_Edition__c oEve;
            Account acc1;
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
            
            oEve = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today());
            insert oEve;
            System.assertEquals(oEve.Event_Code__c,'WOC17', 'Event Code');
            EventCurrecies__c eventCurrency = new EventCurrecies__c (Name='USD',Event_Edition__c=oEve.id);
            insert eventCurrency;
            System.assertEquals(eventCurrency.Name,'USD', 'Event Currency');
            oEve.EventCurrency__c = eventCurrency.id;
            update oEve;
            System.assert(oEve.EventCurrency__c != null, 'Event Currency');
            opportunity opp = new opportunity(Name='World of Concrete 2017',EventEdition__c=oEve.id,AccountId = acc1.id,Paid_Amount__c=10.00,Amount=20.00,CloseDate=System.Today(),StageName='Needs Assessment',CurrencyIsoCode=oEve.EventCurrency__r.Name);
            insert opp;
            System.assert(opp != null, 'opportunity');
            SBQQ__Quote__c oQuote = new SBQQ__Quote__c(SBQQ__Status__c ='Draft',SBQQ__Primary__c =true, CurrencyIsoCode=eventCurrency.name,SBQQ__Type__c='Quote',SBQQ__StartDate__c=System.Today(),SBQQ__Opportunity2__c=opp.id);
            insert oQuote;
            System.assert(oQuote != null, 'SBQQ__Quote');
            System.assert(oQuote.SBQQ__Opportunity2__c == opp.id, 'SBQQ__Quote oppId');
            ExpocadBooth__c oExpocadBooth = new ExpocadBooth__c(Booth_Number__c='Test booth 1',Status__c='Rented', Area__c='201',Unit_Type__c='Test Unit',quote__c=oQuote.id);
            insert oExpocadBooth;
        
        
            opp.StageName='Closed Won';
            update opp;
            System.assert(opp.StageName =='Closed Won', 'StageName is Clsoed Won');
            
        }
        Test.startTest();
            String strJSON = oppAccountDetails.oppAccountDetails(acc1.id,oEve.id);
            String strJSON1 = oppAccountDetails.oppAccountDetailsOPS(oEve.id);
            System.assert(strJSON  != null, 'Checking JSON');
        Test.stopTest();
    }
}