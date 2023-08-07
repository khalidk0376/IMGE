/**
 * File:        BatchExpocadPendingAction_Test
 * Project:     GAP
 * Date:        May 10, 2017
 * Created By:  Kumar Gaurav
 * *************************************************************************
 * @Description Test class for BatchExpocadPendingAction.
 * *************************************************************************
 * History:
 */
@isTest(seeAlldata = false)
public class BatchExpocadPendingAction_Test {
  
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
    
    Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017',Part_of_Series__c=oEventseries.Id, Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information',Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = '', Expocad_API_Url__c = 'test.test');
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
    
    Expocad_Pending_Action__c oEPA = new Expocad_Pending_Action__c(Booth_Number__c='AB1', Opportunity__c = oOpportunity.Id, Quote__c = oQuote.Id, Request_Method_Type__c = 'Rent', Status__c = 'Fail' , Status_Code__c = '500');
    insert oEPA ;
    system.assertEquals('AB1', oEPA.Booth_Number__c , 'Test Class Failed') ;   
    BatchExpocadPendingAction shBatchExpocadPendingAction = new BatchExpocadPendingAction();
    String sch = '0 0 23 * * ?';
    system.schedule('Test shBatchExpocadPendingAction', sch, shBatchExpocadPendingAction);
    Test.StopTest();
    
  }
  
  static testMethod void unitTest2() {
    Test.StartTest();
    Opportunity oOpportunity = [SELECT ID, Name, CloseDate, StageName, EventEdition__c, Event_Series__c, AccountId, Billing_Contact__c FROM Opportunity LIMIT 1];
        
    SBQQ__Quote__c oQuote = [SELECT Id, CurrencyIsoCode, SBQQ__Status__c, SBQQ__Type__c, SBQQ__Opportunity2__c, SBQQ__Account__c, SBQQ__Primary__c FROM SBQQ__Quote__c LIMIT 1];
    
    Expocad_Pending_Action__c oEPA2 = new Expocad_Pending_Action__c(Booth_Number__c='AB1', Opportunity__c = oOpportunity.Id, Quote__c = oQuote.Id, Request_Method_Type__c = 'DisplayNameOverride', Status__c = 'Fail', Display_Name__c = 'Test' , Status_Code__c = '500');
    insert oEPA2 ;
    system.assertEquals('AB1', oEPA2.Booth_Number__c  , 'Test Class Failed') ;
    BatchExpocadPendingAction shBatchExpocadPendingAction = new BatchExpocadPendingAction();
    String sch = '0 0 23 * * ?';
    system.schedule('Test shBatchExpocadPendingAction', sch, shBatchExpocadPendingAction);
    Test.StopTest();
  }
  
  static testMethod void unitTest3() {
    Test.StartTest();
    Opportunity oOpportunity = [SELECT ID, Name, CloseDate, StageName, EventEdition__c, Event_Series__c, AccountId, Billing_Contact__c FROM Opportunity LIMIT 1];
        
    SBQQ__Quote__c oQuote = [SELECT Id, CurrencyIsoCode, SBQQ__Status__c, SBQQ__Type__c, SBQQ__Opportunity2__c, SBQQ__Account__c, SBQQ__Primary__c FROM SBQQ__Quote__c LIMIT 1];
    
    Expocad_Pending_Action__c oEPA3 = new Expocad_Pending_Action__c(Booth_Number__c='AB1', Opportunity__c = oOpportunity.Id, Quote__c = oQuote.Id, Request_Method_Type__c = 'Unhold', Status__c = 'Fail', Display_Name__c = 'Test' , Status_Code__c = '500');
    insert oEPA3 ;
    system.assertEquals('AB1', oEPA3.Booth_Number__c  , 'Test Class Failed') ;
    BatchExpocadPendingAction shBatchExpocadPendingAction = new BatchExpocadPendingAction();
    String sch = '0 0 23 * * ?';
    system.schedule('Test shBatchExpocadPendingAction', sch, shBatchExpocadPendingAction);
    Test.StopTest();
  }
  
  static testMethod void unitTestUnrent() {
    Test.StartTest();
    Opportunity oOpportunity = [SELECT ID, Name, CloseDate, StageName, EventEdition__c, Event_Series__c, AccountId, Billing_Contact__c FROM Opportunity LIMIT 1];
        
    SBQQ__Quote__c oQuote = [SELECT Id, CurrencyIsoCode, SBQQ__Status__c, SBQQ__Type__c, SBQQ__Opportunity2__c, SBQQ__Account__c, SBQQ__Primary__c FROM SBQQ__Quote__c LIMIT 1];
    
    Expocad_Pending_Action__c oEPA3 = new Expocad_Pending_Action__c(Booth_Number__c='AB1', Opportunity__c = oOpportunity.Id, Quote__c = oQuote.Id, Request_Method_Type__c = 'Unrent', Status__c = 'Fail', Display_Name__c = 'Test' , Status_Code__c = '500');
    insert oEPA3 ;
    system.assertEquals('AB1', oEPA3.Booth_Number__c  , 'Test Class Failed') ;
    BatchExpocadPendingAction shBatchExpocadPendingAction = new BatchExpocadPendingAction();
    String sch = '0 0 23 * * ?';
    system.schedule('Test shBatchExpocadPendingAction', sch, shBatchExpocadPendingAction);
    Test.StopTest();
  }
  static testMethod void unitTest4() {
    Test.StartTest();
    Opportunity oOpportunity = [SELECT ID, Name, CloseDate, StageName, EventEdition__c, Event_Series__c, AccountId, Billing_Contact__c FROM Opportunity LIMIT 1];        
    SBQQ__Quote__c oQuote = [SELECT Id, CurrencyIsoCode, SBQQ__Status__c, SBQQ__Type__c, SBQQ__Opportunity2__c, SBQQ__Account__c, SBQQ__Primary__c FROM SBQQ__Quote__c LIMIT 1];
    
    Expocad_Pending_Action__c oEPA3 = new Expocad_Pending_Action__c(Booth_Number__c='AB1', Opportunity__c = oOpportunity.Id, Quote__c = oQuote.Id, Request_Method_Type__c = 'RentToHold', Status__c = 'Fail', Display_Name__c = 'Test' , Status_Code__c = '500');
    insert oEPA3 ;
    system.assertEquals('AB1', oEPA3.Booth_Number__c  , 'Test Class Failed') ;
    oOpportunity.StageName = 'Discover';
    update oOpportunity;

    BatchExpocadPendingAction shBatchExpocadPendingAction = new BatchExpocadPendingAction();
    String sch = '0 0 23 * * ?';
    system.schedule('Test shBatchExpocadPendingAction', sch, shBatchExpocadPendingAction);
    Test.StopTest();
  }
  static testMethod void unitTest5() {
    Test.StartTest();
    Opportunity oOpportunity = [SELECT ID, Name, CloseDate, StageName, EventEdition__c, Event_Series__c, AccountId, Billing_Contact__c FROM Opportunity LIMIT 1];        
    SBQQ__Quote__c oQuote = [SELECT Id, CurrencyIsoCode, SBQQ__Status__c, SBQQ__Type__c, SBQQ__Opportunity2__c, SBQQ__Account__c, SBQQ__Primary__c FROM SBQQ__Quote__c LIMIT 1];
    
    Expocad_Pending_Action__c oEPA3 = new Expocad_Pending_Action__c(Booth_Number__c='AB1', Opportunity__c = oOpportunity.Id, Quote__c = oQuote.Id, Request_Method_Type__c = 'Exhibitor Display Name', Status__c = 'Fail', Display_Name__c = 'Test' , Status_Code__c = '500');
    insert oEPA3 ;
    system.assertEquals('AB1', oEPA3.Booth_Number__c  , 'Test Class Failed') ;
    oOpportunity.StageName = 'Discover';
    update oOpportunity;

    BatchExpocadPendingAction shBatchExpocadPendingAction = new BatchExpocadPendingAction();
    String sch = '0 0 23 * * ?';
    system.schedule('Test shBatchExpocadPendingAction', sch, shBatchExpocadPendingAction);
    Test.StopTest();
  }
  static testMethod void unitTest7() {
    Test.StartTest();
    Opportunity oOpportunity = [SELECT ID, Name, CloseDate, StageName, EventEdition__c, Event_Series__c, AccountId, Billing_Contact__c FROM Opportunity LIMIT 1];        
    SBQQ__Quote__c oQuote = [SELECT Id, CurrencyIsoCode, SBQQ__Status__c, SBQQ__Type__c, SBQQ__Opportunity2__c, SBQQ__Account__c, SBQQ__Primary__c FROM SBQQ__Quote__c LIMIT 1];
    
    Expocad_Pending_Action__c oEPA3 = new Expocad_Pending_Action__c(Booth_Number__c='AB1', Opportunity__c = oOpportunity.Id, Quote__c = oQuote.Id, Request_Method_Type__c = 'Hold', Status__c = 'Fail', Display_Name__c = 'Test' , Status_Code__c = '500');
    insert oEPA3 ;
    system.assertEquals('AB1', oEPA3.Booth_Number__c  , 'Test Class Failed') ;
    oOpportunity.StageName = 'Discover';
    update oOpportunity;

    BatchExpocadPendingAction shBatchExpocadPendingAction = new BatchExpocadPendingAction();
    String sch = '0 0 23 * * ?';
    system.schedule('Test shBatchExpocadPendingAction', sch, shBatchExpocadPendingAction);
    Test.StopTest();
  }
  static testMethod void unitTest6() {
    Test.StartTest();
    Opportunity oOpportunity = [SELECT ID, Name, CloseDate, StageName, EventEdition__c, Event_Series__c, AccountId, Billing_Contact__c FROM Opportunity LIMIT 1];        
    SBQQ__Quote__c oQuote = [SELECT Id, CurrencyIsoCode, SBQQ__Status__c, SBQQ__Type__c, SBQQ__Opportunity2__c, SBQQ__Account__c, SBQQ__Primary__c FROM SBQQ__Quote__c LIMIT 1];
    
    Expocad_Pending_Action__c oEPA3 = new Expocad_Pending_Action__c(Booth_Number__c='AB1', Opportunity__c = oOpportunity.Id, Quote__c = oQuote.Id, Request_Method_Type__c = 'Add Co-Exhibitor', Status__c = 'Fail', Display_Name__c = 'Test' , Status_Code__c = '500');
    insert oEPA3 ;
    system.assertEquals('AB1', oEPA3.Booth_Number__c  , 'Test Class Failed') ;
    oOpportunity.StageName = 'Discover';
    update oOpportunity;

    BatchExpocadPendingAction shBatchExpocadPendingAction = new BatchExpocadPendingAction();
    String sch = '0 0 23 * * ?';
    system.schedule('Test shBatchExpocadPendingAction', sch, shBatchExpocadPendingAction);
    Test.StopTest();
  }
  static testMethod void unitTest8() {
    Test.StartTest();
    Opportunity oOpportunity = [SELECT ID, Name, CloseDate, StageName, EventEdition__c, Event_Series__c, AccountId, Billing_Contact__c FROM Opportunity LIMIT 1];        
    SBQQ__Quote__c oQuote = [SELECT Id, CurrencyIsoCode, SBQQ__Status__c, SBQQ__Type__c, SBQQ__Opportunity2__c, SBQQ__Account__c, SBQQ__Primary__c FROM SBQQ__Quote__c LIMIT 1];
    
    Expocad_Pending_Action__c oEPA3 = new Expocad_Pending_Action__c(Booth_Number__c='AB1', Opportunity__c = oOpportunity.Id, Quote__c = oQuote.Id, Request_Method_Type__c = 'Remove Co-Exhibitor', Status__c = 'Fail', Display_Name__c = 'Test' , Status_Code__c = '500');
    insert oEPA3 ;
    system.assertEquals('AB1', oEPA3.Booth_Number__c  , 'Test Class Failed') ;
    oOpportunity.StageName = 'Discover';
    update oOpportunity;

    BatchExpocadPendingAction shBatchExpocadPendingAction = new BatchExpocadPendingAction();
    String sch = '0 0 23 * * ?';
    system.schedule('Test shBatchExpocadPendingAction', sch, shBatchExpocadPendingAction);
    Test.StopTest();
  }
}