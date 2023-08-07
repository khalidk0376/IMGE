/**
* Created/Modified By: Girikon(Aishwarya)
* Created On:          05/12/2018      
* @description : This test class covers the apex class : ExportBadges
* Apex Class:          ExportBadges 
* Modification Log----- 
* Modified by :  Girikon(Prashant [CCEN-737 April 4 2019])
**/
@isTest
public class ExportBadges_Test
{
    /**
* @description : For data setup and test methods.
*/
    public static testMethod void badgesDataInsert()
    {
        Event_Edition__c oEve = new Event_Edition__c();
        oEve.Name='World of Concrete 2017';
        oEve.Event_Code__c='WOC17';
        oEve.End_Date__c=System.Today();
        oEve.Start_Date__c=System.Today();
        oEve.Event_Currency__c='USD';
        insert oEve;
        System.assertEquals(oEve.Event_Code__c,'WOC17', 'Event Code');
        
        Account acc = new Account();
        acc.Name='TestAccount';
        insert acc;
        System.AssertNotEquals(acc, null, 'Acc name must not be null');
        
        SBQQ__Quote__c oQuote = new SBQQ__Quote__c();
        oQuote.CurrencyIsoCode = 'USD';
        oQuote.SBQQ__Status__c = 'Quote Sent';
        oQuote.SBQQ__Type__c = 'Quote';
        oQuote.SBQQ__Account__c = acc.Id;
        oQuote.SBQQ__Primary__c = true;
        insert oQuote;
        
        ExpocadBooth__c oExpBooth = new ExpocadBooth__c();
        oExpBooth.Booth_Number__c='17';
        oExpBooth.Area__c='1100';
        oExpBooth.Unit_Type__c='SqFt';
        oExpBooth.Status__c ='Rented';
        oExpBooth.Quote__c = oQuote.Id;
        insert oExpBooth;
        System.assertEquals(oExpBooth.Unit_Type__c,'SqFt', 'Unit type');
        
        //Create Opportunity_ExpoCAD_Booth_Mapping__c [CCEN-737]
        Opportunity_ExpoCAD_Booth_Mapping__c oppExpoBoothMapping = new Opportunity_ExpoCAD_Booth_Mapping__c(Account__c = acc.Id, Badge_Limit__c = 2, status__c = 'Active', quote__c=oQuote.Id, Expocad_Booth__c = oExpBooth.Id);
        insert oppExpoBoothMapping;
        
        list<Exhibitor_Badge__c> listexhbdg = new list<Exhibitor_Badge__c>();
        
        for(integer i=0;i<850;i++)
        {
            Exhibitor_Badge__c badge1 = new Exhibitor_Badge__c();
            badge1.Name = 'Test'+i;
            badge1.Event_Edition__c=oEve.id;
            badge1.ExpocadBooth__c=oExpBooth.id;
            badge1.Opp_Booth_Mapping__c = oppExpoBoothMapping.id;
            badge1.Account__c = acc.id;
            listexhbdg.add(badge1);
        }
        insert listexhbdg;
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('eventId',oEve.Id);
        ApexPages.currentpage().getparameters().put('reportName' , 'AllBadges');
        ExportBadges ex = new ExportBadges();
        ex.getthousandBlocks();
        Test.stopTest();
        
    }
    /**
* @description : test for Agent badge C2E-105.
* @return
*/
    public static testMethod void agentbadgesexport() // C2E-105
    {
        //Create Accounts
        Account acc = new Account(Name='TstAccFrst');
        insert acc;
        system.AssertNotEquals(null, acc, 'Record name must not null.');
        
        //create some contacts
        List<Contact> contacts = new List<Contact>();
        for(Integer i=0;i<3;i++)
        {
            Contact c = new Contact(AccountId = acc.Id, FirstName = 'TstConFrst'+i, LastName = 'TstConLst1'+i, Email='test@test.com');
            contacts.add(c);    
        }
        insert contacts;
        
        
        //Create user
        //Profile pro = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        Profile pro = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User Custom'];
        User[] userList = new User[]{};
            User u = new User();
        
        u.FirstName = 'Sunil';
        u.LastName = 'Bajoliya';
        u.Email = 'test@wexeurope.com';
        u.Username = 'astest@wexeurope.com';
        u.Alias = 'astest';
        u.ProfileId = pro.Id;
        
        u.ContactId = contacts[1].id;
        u.TimeZoneSidKey    = 'America/Denver';
        u.LocaleSidKey      = 'en_US';
        u.EmailEncodingKey  = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        insert u;
        //userList.add(u);
        system.debug('u contains ' + u);
        //insert userList;
        
        //Create User_Type__c
        User_Type__c oUT = new User_Type__c(Name='Agent');
        insert oUT;
        
        //Create Event_Edition
        Event_Edition__c evntEditon = new Event_Edition__c(Name='TestName',CurrencyIsoCode='USD',Tab1__c='Booth Application',Tab4__c='Contact Information', Tab8__c='Transfer & Payments',Event_Currency__c ='USD',Event_Code__c='abc',End_Date__c=date.today(),Event_Website__c='http://www.testevent.com',Invoice_From_Email_ID__c='Test', Max_Hold_Booth__c=15, Max_Hold_Days__c=365, Measurement__c='Feet',Next_Edition__c='2019', Payment_Schedule__c='50-50',Start_Date__c=date.today()-1,Venue__c='Las Vegas Convention Center', Cutoff_Date_1__c=date.today()+1,Cutoff_Date_2__c=date.today()-10,Cutoff_Date_3__c=date.today()-15);
        insert evntEditon ;
        
        //Create Agent Event Edition Mapping
        AgentEventEditionMapping__c eventMapping = new AgentEventEditionMapping__c(Account__c=acc.Id,EventEdition__c=evntEditon.id,Is_Active__c=true);
        insert eventMapping;
        
        //Create Agent Badges
        Agent_Badges__c badge1 = new Agent_Badges__c(Address__c='NA',Age_Bracket__c='21-24',Account_Name__c='Test Company 1',AgentEventEditionMapping__c=eventMapping.Id,City__c='New City',Country__c='AW',Country_Code__c='+1',Email__c='test@company.com',First_Name__c='Test1',Job_Title__c='Jack of All Trades',Last_Name__c='Know it All',Mobile_Number__c='87768768',Nationality__c='AD',State__c='Plasma',Status__c='Approved',Is_VIP__c=true);
        insert badge1;
        Agent_Badges__c badge2 = new Agent_Badges__c(Address__c='NA',Age_Bracket__c='21-24',Account_Name__c='Test Company 2',AgentEventEditionMapping__c=eventMapping.Id,City__c='New City',Country__c='AW',Country_Code__c='+1',Email__c='test1@company.com',First_Name__c='Test2',Job_Title__c='Jack of All Trades',Last_Name__c='Know Nothing',Mobile_Number__c='87768768',Nationality__c='AD',State__c='Plasma',Status__c='Pending',Is_VIP__c=false);
        system.runAs(u)
        {
            insert badge2;    
        }
        test.startTest();
        ApexPages.currentPage().getParameters().put('eventId',evntEditon.Id);
        ApexPages.currentpage().getparameters().put('reportName' , 'AllAgentBadges');
        ExportBadges ex = new ExportBadges();
        ex.getthousandBlocks();
        test.stopTest();
    }
    /**
* @description : For data setup and test methods.
* @return
*/
    public static testMethod void exhibitorsWOBadgesDataInsert() // CCEN-671
    {
        Event_Edition__c oEve = new Event_Edition__c();  // event edition
        oEve.Name='World of Concrete 2017';
        oEve.Event_Code__c='WOC17';
        oEve.End_Date__c=System.Today();
        oEve.Start_Date__c=System.Today();
        oEve.Event_Currency__c='USD';
        insert oEve;
        System.assertEquals(oEve.Event_Code__c,'WOC17', 'Event Code');
        
        Account acc = new Account(); // account
        acc.Name='TestAccount';
        insert acc;
        System.AssertNotEquals(acc, null, 'Account Name must not be null');
        
        //opportunity
        Opportunity oOpportunity = new Opportunity( Name = 'Expocad Opportunity', CloseDate = Date.today().addDays(7), StageName = 'Needs Assessment', EventEdition__c = oEve.Id, AccountId = acc.Id);
        insert oOpportunity;
        oOpportunity.StageName = 'Closed Won'; 
        update oOpportunity;
        
        SBQQ__Quote__c oQuote = new SBQQ__Quote__c(); // quote
        oQuote.CurrencyIsoCode = 'USD';
        oQuote.SBQQ__Status__c = 'Quote Sent';
        oQuote.SBQQ__Type__c = 'Quote';
        oQuote.SBQQ__Account__c = acc.Id;
        oQuote.SBQQ__Primary__c = true;
        insert oQuote;
        
        ExpocadBooth__c oExpBooth = new ExpocadBooth__c(); // Booth
        oExpBooth.Booth_Number__c='17';
        oExpBooth.Area__c='1100';
        oExpBooth.Unit_Type__c='SqFt';
        oExpBooth.Status__c ='Rented';
        oExpBooth.Quote__c = oQuote.Id;
        oExpBooth.Opportunity__c = oOpportunity.Id;
        insert oExpBooth;
        System.assertEquals(oExpBooth.Unit_Type__c,'SqFt', 'Unit type');
        
        Test.startTest();  
        ApexPages.currentPage().getParameters().put('eventId',oEve.Id); // 
        ApexPages.currentpage().getparameters().put('reportName' , 'ExhibitorsWithoutBadges');
        
        ExportBadges ex = new ExportBadges(); // Export badges object
        ex.getthousandBlocks();
        Test.stopTest();
    }
    /**
* @description : For data setup and test methods.
* @return
*/
    public static testMethod void agentsWOBadgesTest() // C2E-105
    {
        Event_Edition__c oEve = new Event_Edition__c();  // event edition
        oEve.Name='World of Concrete 2017';
        oEve.Event_Code__c='WOC17';
        oEve.End_Date__c=System.Today();
        oEve.Start_Date__c=System.Today();
        oEve.Event_Currency__c='USD';
        insert oEve;
        System.assertEquals(oEve.Event_Code__c,'WOC17', 'Event Code');
        
        Account acc = new Account(); // account
        acc.Name='TestAccount';
        insert acc;
        System.AssertNotEquals(acc, null, 'Account Name must not be null');
        
        //create some contacts
        List<Contact> contacts = new List<Contact>();
        for(Integer i=0;i<3;i++)
        {
            Contact c = new Contact(AccountId = acc.Id, FirstName = 'TstConFrst'+i, LastName = 'TstConLst1'+i, Email='test@test.com');
            contacts.add(c);    
        }
        insert contacts;
        
        //Create User_Type__c
        User_Type__c oUT = new User_Type__c(Name='Agent');
        insert oUT;
        
        ContactEventEditionMapping__c ccem =new ContactEventEditionMapping__c();
        ccem.SFContactID__c = contacts[0].Id;
        ccem.SFEventEditionID__c = oEve.id;
        ccem.User_Type__c = oUT.id;
        insert ccem;
        
        //Create Agent Event Edition Mapping
        AgentEventEditionMapping__c eventMapping = new AgentEventEditionMapping__c(Account__c=acc.Id,EventEdition__c=oEve.id,Is_Active__c=true);
        insert eventMapping;
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('eventId',oEve.Id); // 
        ApexPages.currentpage().getparameters().put('reportName' , 'AgentsWithoutBadges');
        ExportBadges ex = new ExportBadges(); 
        ex.getagentsWithoutBadges();
        Test.stopTest();
        
    }
}