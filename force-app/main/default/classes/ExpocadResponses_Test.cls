/**
 * File:                ExpocadResponses_Test
 * Project:             GAP
 * Date:                Feb 10, 2017
 * Test Class For:      ExpocadResponses
 * Code Coverage:       79%
 * Created By:          Kumar Gaurav
 * *************************************************************************
 * Description:         Test class for ExpocadResponses.
 * *************************************************************************
 * History:
 */

@isTest(seeAlldata = false)
public class ExpocadResponses_Test
{
    static testMethod void ExpocadResponses_Test_Method()
    {
        Utility.isRebookInProcess = True ;
        Application_Bypass__c oAB = new Application_Bypass__c(SetupOwnerId=UserInfo.getOrganizationId(), Bypass_Validation_Rules__c = True);
        Insert oAB ;
        
        Account oaccount = new Account(Name='Expocad Account', CurrencyIsoCode = 'USD');
        insert oaccount;
        
        Contact ocontact = new Contact(LastName='ContTest1', Email='test1contact@duptest.com', AccountId = oaccount.Id,MailingState='',MailingCountry='India');
        insert ocontact;
        
        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017',Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information',Payment_Schedule__c = '50-50',cutoff_date_1__c = date.today(),Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt',Expocad_API_Url__c  = 'https://api2.expocad.com');
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
                
        Opportunity opportunity1 = new Opportunity();
        opportunity1.Name = 'Test1';
        opportunity1.AccountId= oaccount.Id;
        opportunity1.CloseDate= dt;
        opportunity1.StageName='Closed Lost';
        opportunity1.Reason_Lost__c = 'Increase Code Coverage';
        opportunity1.CurrencyIsoCode='USD';
        opportunity1.Opportunity_Contact__c=ocontact.Id;
        opportunity1.EventEdition__c = oEvent.Id;
        insert opportunity1;
        
        SBQQ__Quote__c oQuote2 = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Quote Sent', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = opportunity1.Id, SBQQ__Account__c = oaccount.Id, SBQQ__Primary__c = True);
        insert oQuote2;
        opportunity1.SBQQ__PrimaryQuote__c = oQuote2.Id;
        update opportunity1;
        
        
        Product2 prd1 = new Product2(Name = 'Pre Draw Indoor Booth',Family = 'Booth', Number_of_Corners__c = 0, Event_Edition_Pool__c = 'WOC', Event_Edition__c = oEvent.Id);
        insert prd1;
        
        SBQQ__QuoteLine__c oQuoteLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = oQuote.Id, SBQQ__Product__c = prd1.Id, SBQQ__Quantity__c = 2, SBQQ__Number__c = 1, Line_Description__c = 'Test', Booth_Number__c = 'TESTBN3', Booth__c = True);
        insert oQuoteLine ;
        Test.StopTest();
        
        SBQQ__QuoteLine__c oQuoteLine1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = oQuote2.Id, SBQQ__Product__c = prd1.Id, SBQQ__Quantity__c = 3, SBQQ__Number__c = 2, Line_Description__c = 'Test1', Booth_Number__c = 'TESTBN31', Booth__c = True);
        insert oQuoteLine1 ;
        
        ExpocadBooth__c oEB = new ExpocadBooth__c(Quote__c = oQuote.Id,Booth_Number__c='Test131', Opportunity__c = opportunity.Id, Account__c = oaccount.Id, Last_Action_Date__c = Date.today(), Status__c = 'On Hold', Selected__c = True);
        insert oEB;
        oEB.Status__c = 'Added To Quote/On Hold';
        update oEB;
        
        String sExpocadDB = opportunity.EventEdition__r.Event_Code__c ;
        Set<Id> soppIds = new Set<Id>();
        soppIds.add(opportunity.Id);
        soppIds.add(opportunity1.Id);
        //Test.setMock(HttpCalloutMock.class, new ExpocadMock());
        ExpocadResponses.AsyncUNHOLD('400Res', opportunity.Id, oQuote.Id, 'KDB,KDB2', 'Test', 'Displayname');
        ExpocadResponses.RentBooth(soppIds);
        ExpocadResponses.SyncHOLD('500Res', opportunity.Id, oQuote.Id, 'KDB2', 'https://api2.expocad.com', 'test');
        ExpocadResponses.asyncUpdateExhibitorDetails ('b001' , opportunity.Id, opportunity1.Id ,oQuote.Id, oQuote2.Id , 'Kdb2', 'https://api2.expocad.com' , 'DisplayName');
        ExpocadResponses.AsyncRentToHold('EB1', opportunity.Id, oQuote.Id, 'Test','Displayname');
        ExpocadResponses.logFailedTransaction('EB1', opportunity.Id, oQuote.Id, 'Rent', 'Test', 'API is not responding', System.now(), 'Fail', 'Test', 'Test','DisplayName');
        ExpocadResponses.syncUpdateDisplay ('EB1', opportunity.Id, oQuote.Id, 'Kdb2', 'https://api2.expocad.com', 'DisplayName');
        ExpocadResponses.aSyncUnrent('500Res', opportunity.Id, oQuote.Id, 'KDB2', 'https://api2.expocad.com', '');
        ExpocadResponses.SyncUnRentReplaceBooths('EB2',opportunity.Id,oQuote.Id,'Kdb','https://api2.expocad.com','');
        ExpocadResponses.asyncRENT('500Res', opportunity.Id, oQuote.Id, 'KDB2', 'test',false);
        ExpocadResponses.SyncUnhold('EB3', opportunity.Id, oQuote.Id, 'KDB1', 'https://api2.expocad.com', 'test1');
        ExpocadBooth__c ebTest = [Select ID, Booth_Number__c from ExpocadBooth__c WHERE Booth_Number__c = 'Test131' limit 1];
        System.assertEquals('Test131', ebTest.Booth_Number__c, 'Error');
    }
}