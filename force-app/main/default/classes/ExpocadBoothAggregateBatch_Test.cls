/**
* File:        ExpocadBoothAggregateBatch_Test.cls
* Project:     Informa Market (BAU GE)
* Date:		   24-12-2020
* Created By : Rajesh Kumar 
* Test Class for  : ExpocadBoothAggregateBatch.cls
* *************************************************************************
* Description: Test class for ExpocadBoothAggregateBatch.
 * *************************************************************************
 * History:BK-9619
 */
@isTest(seeAlldata = false)
public class ExpocadBoothAggregateBatch_Test {
  
  @testSetup static void setup() {
    Application_Bypass__c oAB = new Application_Bypass__c(SetupOwnerId=UserInfo.getOrganizationId(), Bypass_Validation_Rules__c = True);
    Insert oAB ;
    
    Account oAccount = new Account(Name = 'Expocad Account', CurrencyIsoCode = 'USD', Phone = '2423122323');
    insert oAccount;

    Contact oCon = new Contact(LastName = 'ContTest1', Email = 'test1contact@duptest.com', AccountId = oAccount.Id, MailingStreet = 'Test', MailingCity = 'Test', MailingState='', MailingCountry='India',Phone = '2423122323', AssistantPhone = '2423122323', HomePhone = '2121212121', MobilePhone = '2121212145', OtherPhone = '2154215421');
    insert oCon;
    
    
    User oUser = [SELECT Id FROM User WHERE Id = : UserInfo.getUserId()];
    AccountTeamMember oAtm =new AccountTeamMember(AccountId = oAccount.id, userId = oUser.id);
    insert oAtm;
    
    Brand__c oBrand = new Brand__c(Name='World of Concrete', SSC_Email_Distribution_ID__c = 'test@test.tst');
    insert oBrand;
    
    Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Brand__c=oBrand.id, Event_Edition_Pool__c = 'WOC');
    insert oEventseries;
    
    Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017',Part_of_Series__c=oEventseries.Id, Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information',Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula',Run_Historical_Batch__c= True , No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = '', Expocad_API_Url__c = 'test.test');
    insert oEvent;
    
    Opportunity oOpportunity = new Opportunity(Name = 'Expocad Opportunity', CloseDate = Date.today(), StageName = 'Discover', EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id, AccountId = oAccount.Id,  Opportunity_Contact__c= oCon.Id);
    insert oOpportunity;
    
    oOpportunity.StageName = 'Closed Won';
    update oOpportunity;
    
    SBQQ__Quote__c oQuote = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Contract Sent', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = oOpportunity.Id, SBQQ__Account__c = oAccount.Id, SBQQ__Primary__c = true);
    insert oQuote;
  }
  static testMethod void unitTest1() {
    Test.StartTest();
    Opportunity oOpportunity = [SELECT ID, Name, CloseDate, StageName, EventEdition__c, Event_Series__c, AccountId, Billing_Contact__c FROM Opportunity LIMIT 1];
    SBQQ__Quote__c oQuote = [SELECT Id, CurrencyIsoCode, SBQQ__Status__c, SBQQ__Type__c, SBQQ__Opportunity2__c, SBQQ__Account__c, SBQQ__Primary__c FROM SBQQ__Quote__c LIMIT 1];
    
	ExpocadBooth__c oEB = new ExpocadBooth__c(Selected__c = true, Status__c = 'Rented', Opportunity__c = oOpportunity.Id, Booth_Type__c = 'Corner', ShowInShow__c = 'TestShowInShow', Open_Corners__c = 23, Booth_Classes__c='tset2;;test4', Booth_Product_Type_EE__c = 'Space Only', Area__c = '400 SqFt',Quote__c=oQuote.Id,Pavilion__c='test' , Matched_Product_Name__c = 'Agent Pavilion Space Only');
	insert oEB;
      
    Historical_Reporting_Setting__c ohistorycustomsetting = new Historical_Reporting_Setting__c(Report_Type_Description__c = 'Report Type 2', Name='Report Type 2');
    insert ohistorycustomsetting; 
      
    system.assertEquals('400 SqFt', oEB.Area__c , 'Test Class Failed') ;   
    ExpocadBoothAggregateBatch shBatchExpocadPendingAction = new ExpocadBoothAggregateBatch('All');
    String sch = '0 0 23 * * ?';
    system.schedule('Test shBatchExpocadPendingAction', sch, shBatchExpocadPendingAction);
    Test.StopTest();
    
  }
}