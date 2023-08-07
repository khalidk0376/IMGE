/******************
Created By - Aish
Test class for - HomeFinanceSummaryCtr
******************/
@isTest
public class HomeFinanceSummaryCtr_Test {
    public static testMethod void HomeFinanceSummaryCtr_DataInsert()
    {
        // Setup test data
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser11@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing11', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1abc@testorg.com');
        insert u;
        System.AssertEquals(u.ProfileId, p.id,'Error user is not created');
        System.runAs(u) 
        {
            Account acc = new Account();
            acc.Name = 'Test Account';
            insert acc;
            System.AssertNotEquals(acc, null,'account should not be null');
                
            Contact con = new Contact();
            con.LastName = 'testLastName';
            con.FirstName = 'testFirstName';
            con.MailingStreet = '111';
            con.MailingCity = 'Dallas';
            con.MailingCountry = 'USA';
            con.MailingState = 'Texas';
            con.MailingPostalCode = '75068';
            con.Email = 'test@gmail.com';
            con.Phone = '2012012012';
            con.accountId = acc.Id;
            insert con;
            System.AssertEquals(con.AccountId,acc.Id,'Error contact is not created');
        
            Event_Edition__c OEve = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today());
            insert OEve;
            System.assertEquals(OEve.Event_Code__c,'WOC17', 'Event Code');
            EventCurrecies__c eventCurrency = new EventCurrecies__c (Name='USD',Event_Edition__c=OEve.id);
            insert eventCurrency;
            System.assertEquals(eventCurrency.Name,'USD', 'Event Currency');
            OEve.EventCurrency__c = eventCurrency.id;
            update OEve;
            //System.assert(OEve.EventCurrency__c != null, 'Event Currency');
            System.assertNotEquals(OEve.EventCurrency__c ,null, 'Event Currency should not be null');
            opportunity opp = new opportunity(Name='World of Concrete 2017',EventEdition__c=OEve.id,AccountId = acc.id,Paid_Amount__c=10.00,Amount=20.00,CloseDate=System.Today(),Payment_Status__c='Not Paid',StageName='Need Assesment',CurrencyIsoCode=OEve.EventCurrency__r.Name);
            insert opp;
            System.AssertEquals(opp.AccountId, acc.id,'Error Opportunity is not created');
            System.AssertNotEquals(opp, null,'Opportunity should not be null');
            
            ApexPages.currentPage().getParameters().put('accountId',acc.id);
            ApexPages.currentPage().getParameters().put('eventId',OEve.Id);
            
            Test.startTest();
                HomeFinanceSummaryCtr obj = new HomeFinanceSummaryCtr();
                obj.updateAccount();
                Date todayDate = System.Today();
                HomeFinanceSummaryCtr.changeDateFormat(todayDate);
                HomeFinanceSummaryCtr.getOppAccountDetails();
                opp.StageName ='Closed Won';
                update opp;
                HomeFinanceSummaryCtr.getOppAccountDetails();
                obj.updateAccount();
            Test.stopTest();
        }
    }
     public static testMethod void HomeFinanceSummaryCtr_DataInsert1()
    {
        // Setup test data
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser11@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing11', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1abc@testorg.com');
        insert u;
        System.AssertEquals(u.ProfileId, p.id,'Error user is not created');
        System.runAs(u) 
        {
            Account acc = new Account();
            acc.Name = 'Test Account';
            insert acc;
            System.AssertNotEquals(acc, null,'account should not be null');
                
            Contact con = new Contact();
            con.LastName = 'testLastName';
            con.FirstName = 'testFirstName';
            con.MailingStreet = '111';
            con.MailingCity = 'Dallas';
            con.MailingCountry = 'USA';
            con.MailingState = 'Texas';
            con.MailingPostalCode = '75068';
            con.Email = 'test@gmail.com';
            con.Phone = '2012012012';
            con.accountId = acc.Id;
            insert con;
            System.AssertEquals(con.AccountId,acc.Id,'Error contact is not created');
        
            Event_Edition__c OEve = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today());
            insert OEve;
            System.assertEquals(OEve.Event_Code__c,'WOC17', 'Event Code');
            EventCurrecies__c eventCurrency = new EventCurrecies__c (Name='USD',Event_Edition__c=OEve.id);
            insert eventCurrency;
            System.assertEquals(eventCurrency.Name,'USD', 'Event Currency');
            OEve.EventCurrency__c = eventCurrency.id;
            update OEve;
            //System.assert(OEve.EventCurrency__c != null, 'Event Currency');
            System.assertNotEquals(OEve.EventCurrency__c ,null, 'Event Currency should not be null');
            opportunity opp = new opportunity(Name='World of Concrete 2017',EventEdition__c=OEve.id,AccountId = acc.id,Paid_Amount__c=10.00,Amount=10.00,CloseDate=System.Today(),Payment_Status__c='Not Paid',StageName='Need Assesment',CurrencyIsoCode=OEve.EventCurrency__r.Name);
            insert opp;
            System.AssertEquals(opp.AccountId, acc.id,'Error Opportunity is not created');
            System.AssertNotEquals(opp, null,'Opportunity should not be null');
            
            ApexPages.currentPage().getParameters().put('accountId',acc.id);
            ApexPages.currentPage().getParameters().put('eventId',OEve.Id);
            
            Test.startTest();
                HomeFinanceSummaryCtr obj = new HomeFinanceSummaryCtr();
                obj.updateAccount();
                Date todayDate = System.Today();
                HomeFinanceSummaryCtr.changeDateFormat(todayDate);
                HomeFinanceSummaryCtr.getOppAccountDetails();
                opp.StageName ='Closed Won';
                update opp;
                HomeFinanceSummaryCtr.getOppAccountDetails();
                obj.updateAccount();
            Test.stopTest();
        }
    }
}