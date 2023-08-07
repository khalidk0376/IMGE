/**
* File:        BatchGetEventsStats_Test.cls
* Project:     Informa Market (BAU GE)
* Created By : Shiv Raghav
* Test Class for  : BatchGetEventsStats.cls
* *************************************************************************
* Description: Test class for BatchGetEventsStats.
* *************************************************************************
* History:BK-9620
*/
@isTest(seeAlldata = false)
public class BatchGetEventsStats_Test{

    static testMethod void unitTest1() {
        
        Utility.isRebookInProcess = True ;
        Application_Bypass__c oAB = new Application_Bypass__c(SetupOwnerId=UserInfo.getOrganizationId(), Bypass_Validation_Rules__c = True);
        Insert oAB ;
        
        Account oaccount = new Account(Name='Expocad Account', CurrencyIsoCode = 'USD');
        insert oaccount;
        
        Contact ocontact = new Contact(LastName='ContTest1', Email='test1contact@duptest.com', AccountId = oaccount.Id,MailingState='',MailingCountry='India');
        insert ocontact;
        
        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017',Run_Historical_Batch__c = True,Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information',Payment_Schedule__c = '50-50',cutoff_date_1__c = date.today(),Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt',Expocad_API_Url__c  = 'https://api2.expocad.com');
        insert oEvent;

        String surl = 'test';
        Date dt = Date.today();     
        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'Test';
        opportunity.AccountId= oaccount.Id;
        opportunity.CloseDate= dt;
        opportunity.StageName='Closed Won';
        opportunity.Contract_Attached__c = true;
        opportunity.CurrencyIsoCode='USD';
        opportunity.Opportunity_Contact__c=ocontact.Id;
        opportunity.EventEdition__c = oEvent.Id;
        insert opportunity;
        
       
        Test.StartTest();
        SBQQ__Quote__c oQuote = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Quote Sent', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = opportunity.Id, SBQQ__Account__c = oaccount.Id, SBQQ__Primary__c = true);
        insert oQuote;
       
        ExpocadCredential__c expCred =  new ExpocadCredential__c(Name = 'ExpocadApiCredential',Org_Id__c = UserInfo.getOrganizationId(),Expocad_Host_URL__c = 'test.com',Url__c = 'test.com');
        insert expCred;        
        
        opportunity.SBQQ__PrimaryQuote__c = oQuote.Id;
        update opportunity;
       

        Product2 prd1 = new Product2(Name = 'Pre Draw Indoor Booth',Family = 'Booth', Number_of_Corners__c = 0, Event_Edition_Pool__c = 'WOC', Event_Edition__c = oEvent.Id);
        insert prd1;

        SBQQ__QuoteLine__c oQuoteLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = oQuote.Id, SBQQ__Product__c = prd1.Id, SBQQ__Quantity__c = 2, SBQQ__Number__c = 1, Line_Description__c = 'Test', Booth_Number__c = 'TESTBN3', Booth__c = True);
        insert oQuoteLine ;

        ExpocadBooth__c oEB = new ExpocadBooth__c(Quote__c = oQuote.Id,Booth_Number__c='Test131', Opportunity__c = opportunity.Id, Account__c = oaccount.Id, Last_Action_Date__c = Date.today(), Status__c = 'On Hold', Selected__c = True);
        insert oEB;
        System.assertEquals('Test131', oEB.Booth_Number__c, 'Error');
        
        Historical_Reporting_Setting__c ohistorycustomsetting = new Historical_Reporting_Setting__c(Report_Type_Description__c = 'Report Type 1', Name='Report Type 1');
        insert ohistorycustomsetting; 

        BatchGetEventsStats eventStats = new BatchGetEventsStats('All');
        String sch = '0 0 23 * * ?';
        system.schedule('Test eventStats', sch, eventStats);
        Test.StopTest();
    }
}