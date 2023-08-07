/**
 * File:        BatchProcessOrders_Test
 * Project:     GAP
 * Date:        July 11, 2017
 * Code Coverage:   87%
 * Created By:  Kumar Gaurav
 * *************************************************************************
 * @description Test class for BatchProcessOrders.
 * *************************************************************************
 * History:
 */

@isTest(seeAlldata = false)
public class BatchProcessOrders_Test {
  
  static testMethod void unitTest() {
    
    Account oAccount = new Account(Name='Expocad Account', CurrencyIsoCode = 'USD');
    insert oAccount;
    
    Contact oCon = new Contact(LastName='ContTest1', Email='test1contact@duptest.com', AccountId = oAccount.Id, MailingStreet = 'Test',MailingCity ='Test',MailingState='',MailingCountry='India', MobilePhone = '2121212145');
    insert oCon;
    
    User oUser = [SELECT Id FROM User WHERE Id = : UserInfo.getUserId()];
    AccountTeamMember oAtm =new AccountTeamMember(AccountId = oAccount.id, userId = oUser.id);
    insert oAtm;
    
    Brand__c oBrand = new Brand__c(Name='World of Concrete', SSC_Email_Distribution_ID__c = 'test@test.tst');
    insert oBrand;
    
    Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Brand__c=oBrand.id, Event_Edition_Pool__c = 'WOC');
    insert oEventseries;
    
    Event_Edition__c oEvent = new Event_Edition__c(Event_Currency__c = 'USD', Name = 'World of Concrete 2017',Part_of_Series__c=oEventseries.Id, Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information',Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = '');
    insert oEvent;
    
    Opportunity oOpportunity = new Opportunity(Name = 'Expocad Opportunity', CloseDate = Date.today(), StageName = 'Discover', EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id, AccountId = oAccount.Id,  Opportunity_Contact__c= oCon.Id);
    insert oOpportunity;
    system.assertEquals('Expocad Opportunity' , oOpportunity.Name, 'This oppotunity must be Expocad Opportunity');
    SBQQ__Quote__c oQuote = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Contract Sent', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = oOpportunity.Id, SBQQ__Account__c = oAccount.Id, SBQQ__Primary__c = true);
    insert oQuote;
    
    Id pricebookId = Test.getStandardPricebookId();
    Product2 prd1 = new Product2(Name = 'Post Draw Indoor Booth',Family = 'Booth', Number_of_Corners__c = 0, Event_Edition_Pool__c = 'WOC', Event_Edition__c = oEvent.Id, Expiry_Date__c = Date.today());
    insert prd1;
    Pricebook2 customPB = new Pricebook2(Name='ICRE', isActive=true);
    insert customPB;
    PricebookEntry stndrdPrice1 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prd1.Id,UnitPrice = 100, IsActive = true);
    insert stndrdPrice1;
    PricebookEntry iCREPrice1 = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = prd1.Id,UnitPrice = 200, IsActive = true);
    insert iCREPrice1;

    SBQQ__QuoteLine__c oQuoteLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = oQuote.Id, SBQQ__Product__c = prd1.Id, SBQQ__Quantity__c = 2, SBQQ__Number__c = 1, Line_Description__c = 'Test', Booth_Number__c = 'TESTBN3', Booth__c = True, SBQQ__PricingMethodEditable__c = true, SBQQ__BundledQuantity__c = 2);
    insert oQuoteLine ;

    Test.StartTest();
    
    Contract oContract = new Contract(AccountId = oAccount.id, Status='Sent', StartDate = Date.today(), ContractTerm = 12, SBQQ__Opportunity__c = oOpportunity.id, SBQQ__Quote__c = oQuote.Id);
    insert oContract;
    
    Order objOrder = new Order(AccountId = oAccount.id, Status = 'Draft', EffectiveDate=Date.today(), OpportunityId=oOpportunity.id, SBQQ__PriceCalcStatus__c='Completed', SBQQ__Quote__c = oQuote.Id, main_order__c = True, Type = 'New',Create_Customer_Result__c='Success',Ready_to_Activate__c = False);
    insert objOrder;
    
    oOpportunity.StageName = 'Closed Won';
    oOpportunity.Manual_Contract__c = True;
    oOpportunity.status__c = 'Awaiting Payment';
    update oOpportunity;
    
    /*Order objOrder2 = [SELECT status, Opportunity.stageName, SBQQ__PriceCalcStatus__c, Opportunity.status__c, main_order__c From Order WHERE Id=:objOrder.Id LIMIT 1];
    System.assertEquals('Draft', objOrder2.status);
    System.assertEquals('Closed Won', objOrder2.Opportunity.stageName);
    System.assertEquals('Completed', objOrder2.SBQQ__PriceCalcStatus__c);
    System.assertEquals('Awaiting Payment', objOrder2.Opportunity.status__c);
    System.assertEquals(True, objOrder2.main_order__c);
    
    List<Order> lstOrder = [SELECT Id  FROM order WHERE status = 'Draft' AND Opportunity.stageName ='Closed Won' AND SBQQ__PriceCalcStatus__c = 'Completed' AND Opportunity.status__c = 'Awaiting Payment' AND  main_order__c  = True];
    System.assertEquals(1, lstOrder.size());
    */
        
    
    BatchProcessOrders shBatchProcessOrders = new BatchProcessOrders();
    //Database.executeBatch(shBatchProcessOrders, 1);
    String sch = '0 0 23 * * ?';
    system.schedule('Test shBatchProcessOrders', sch, shBatchProcessOrders);
    Test.StopTest();
  }
}