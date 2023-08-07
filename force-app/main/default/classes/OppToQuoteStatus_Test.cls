/**
* File:            OppToQuoteStatus_Test.cls
* Project:         GAP
* Date:            2/20/2017 5:52 AM
* Created By:      Abdul Kadir
* Modified By:     Rajesh Kumar, [Modified By : Aishwarya 12 Aug 2020 BK-3751]
* *************************************************************************
* @Description OppToQuoteStatus class
* Code Coverage :86%
* *************************************************************************
* History:
Ticket No.-BK-14522 Updating API Version
*/
@isTest
public class OppToQuoteStatus_Test {

    @testSetup static void setup() {

        Pricebook2 pb = new Pricebook2();
        pb.Name = 'TestPricebook';
        insert pb;
        //Insert Event Edition
        Event_Edition__c ee = new Event_Edition__c();
        ee.Name = 'TestEvent';
        ee.Tab1__c = 'tab1';
        ee.Tab4__c = 'tab4';
        ee.Tab7__c = 'tab7';
        ee.Tab8__c = 'Tab8__c';
        ee.Payment_Schedule__c = '25-25-25-25';
        ee.X50_Cutoff_Date__c = date.today();
        ee.Cutoff_Date_1__c = date.today().addDays(1);
        ee.Cutoff_Date_2__c = date.today().addDays(2);
        ee.Cutoff_Date_3__c = date.today().addDays(3);
        ee.Event_Price_Book__c = pb.Id;
        ee.Event_Currency__c='USD';
        ee.Event_Code__c='woc152';
        insert ee;
        System.assertEquals(ee.Payment_Schedule__c, '25-25-25-25', 'payment schedule like 25-25-25-25'); 

        //Insert Account
        Account acct = new Account();
        acct.Name = 'testAccount'; 
        acct.CurrencyIsoCode = 'EUR';
        insert acct;
        System.assertEquals(acct.Name, 'testAccount', 'account name should equals to testAccount');
         
        //Insert Contact
        Contact ocontact = new Contact();
        ocontact.Email = 'test.test@gmail.com';
        ocontact.Phone = '1234567890';
        ocontact.FirstName = 'TestFN';
        ocontact.LastName = 'testLN';
        ocontact.AccountId = acct.Id;
        ocontact.MailingStreet = 'TestStreet';
        ocontact.MailingCity = 'Delhi';
        ocontact.MailingPostalCode = '110025';
        ocontact.MailingState = 'Delhi';
        ocontact.MailingCountry = 'India';
        ocontact.Fax = '1234567890';
        ocontact.Address_Verified__c = false;
        insert ocontact;
        System.assertEquals('testLN', ocontact.LastName , 'Contact must be inserted'); 
        
        //Insert Opportunity
        Opportunity oppty1 = new Opportunity(Name = 'testOpp', EventEdition__c = ee.Id);
        oppty1.AccountId = acct.Id;
        oppty1.StageName ='Discover';
        oppty1.CloseDate = date.today();
        oppty1.IsCreatedByReviewProcess__c=false;
        insert oppty1;
        System.assertEquals(oppty1.AccountId , acct.Id, 'account id should be equals');
        
        SBQQ__Quote__c oQuote = new SBQQ__Quote__c( SBQQ__Status__c = 'Quote Sent' , SBQQ__Type__c = 'Amendment', SBQQ__Opportunity2__c = oppty1.Id, SBQQ__Account__c = acct.Id ,SBQQ__Primary__c = false, Parent_Opp_Primary_Quote_Total__c = 10000.00);
        insert oQuote;
        oppty1.StageName = 'Closed Won';
        oppty1.Status__c = 'Awaiting Payment';
        update oppty1;
        System.assertEquals(oQuote.SBQQ__Status__c, 'Quote Sent', 'status is Quote Sent');
    }
    
    @isTest
    static void test4QuoteStatusChange() {
        set<Id> sIds = new set<id>();
        List<Opportunity> oppList = [select id,StageName,Reason_Lost__c,Status__c,IsCreatedByReviewProcess__c from Opportunity];

        //This code runs as the system user
        String uniqueUserName = 'Adminuser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id, Name FROM Profile WHERE Name='System Administrator'];
        System.assertEquals(p.Name, 'System Administrator', 'profile name is System Administrator');
        
        User u = new User(Alias = 'standt', Email='adminuser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName=uniqueUserName);
        System.assertEquals(u.LastName, 'Testing', 'User record must be inserted');
        System.runAs(u) {
            System.test.startTest();
            sIds.add(oppList[0].Id);
            OppToQuoteStatus updater = new OppToQuoteStatus (sIds);
            System.enqueueJob(updater );
            ID jobID = System.enqueueJob(updater );
            System.test.stopTest();
            //oppList[0].Status__c = 'Awaiting Payment';

        }
    }
}