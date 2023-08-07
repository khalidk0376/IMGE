/**
 * Project:         GAP
 * Date:            June 28, 2017
 * Code Coverage:   89%
 * Created By:      Kumar Gaurav
 * * Modified By : Rajesh kumar Yadav Bk-3751
 * *************************************************************************
 * Description:     Test class for CompleteAmend_Cls.
 * *************************************************************************
 * History:
 */
 
 
@isTest(seeAlldata = false)
public class CompleteAmend_Cls_Test {
  
  static testMethod void completeAmend() {

    Utility.isRebookInProcess = True ;
    
    Account oAccount = new Account(Name='Expocad Account');
    insert oAccount;
    system.assertEquals(oAccount.Name, 'Expocad Account', 'Account name equals to Expocad Account');
    
    Contact oCon = new Contact(LastName='ContTest1', Email='test1contact@duptest.com', AccountId = oAccount.Id, MailingStreet = 'Test',MailingCity ='Test',MailingState='',MailingCountry='India');
    insert oCon;
    system.assertEquals(oCon.LastName, 'ContTest1', 'Contact last name equals to ContTest1');
    
    User oUser = [SELECT Id FROM User WHERE Id = : UserInfo.getUserId()];
    system.assertEquals(oUser.Id, UserInfo.getUserId(), 'User id equals to login user');
    
    AccountTeamMember oAtm =new AccountTeamMember(AccountId = oAccount.id, userId = oUser.id);
    insert oAtm;
    system.assertEquals(oAtm.AccountId, oAccount.id, 'Account id must be same.');
    
    Brand__c oBrand = new Brand__c(Name='World of Concrete', SSC_Email_Distribution_ID__c = 'test@test.tst');
    insert oBrand;
    system.assertEquals(oBrand.Name, 'World of Concrete', 'Brand name equals to World of Concrete');
    
    Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete',  Package_Identifier__c = 'WOC', Brand__c=oBrand.id, Event_Edition_Pool__c = 'WOC');
    insert oEventseries;
    
    Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017',Part_of_Series__c=oEventseries.Id, Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information',Approval_Service_Now_ID__c = '123',  Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = '', Signature_Required_in_Amend__c = true);
    insert oEvent;
    system.assertEquals(oEvent.Name, 'World of Concrete 2017', 'Event Edition name equals to World of Concrete 2017');
    
    Opportunity oOpportunity = new Opportunity(Name = 'Expocad Opportunity', CloseDate = Date.today(), StageName = 'Proposal', EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id, AccountId = oAccount.Id, Billing_Contact__c = oCon.Id, Opportunity_Contact__c= oCon.Id);
    insert oOpportunity;
    system.assertEquals(oOpportunity.AccountId, oAccount.Id, 'Account Id must be same');
    
    SBQQ__Quote__c oQuote = new SBQQ__Quote__c(SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = oOpportunity.Id, SBQQ__Account__c = oAccount.Id, SBQQ__Primary__c = true);
    insert oQuote;
    system.assertEquals(oQuote.SBQQ__Status__c, 'Draft', 'Both values should be the same.');
    Id pricebookId = Test.getStandardPricebookId();
    Product2 prd1 = new Product2(Name = 'Post Draw Indoor Booth',Family = 'Booth', Number_of_Corners__c = 0, Event_Edition_Pool__c = 'WOC', Event_Edition__c = oEvent.Id , Expiry_Date__c = Date.today());
    insert prd1;
    Pricebook2 customPB = new Pricebook2(Name='ICRE', isActive=true);
    insert customPB;
    PricebookEntry pbStndrdPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prd1.Id,UnitPrice = 100, IsActive = true);
    insert pbStndrdPrice;
    PricebookEntry pbICREPrice = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = prd1.Id,UnitPrice = 200, IsActive = true);
    insert pbICREPrice;

    SBQQ__QuoteLine__c oQuoteLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = oQuote.Id, SBQQ__Product__c = prd1.Id, SBQQ__Quantity__c = 2, SBQQ__Number__c = 1, Line_Description__c = 'Test', Booth_Number__c = 'TESTBN3', Booth__c = True);
    insert oQuoteLine ;

    Contract oContract = new Contract(AccountId = oAccount.id, Status='Sent', StartDate = Date.today(), ContractTerm = 12, SBQQ__Opportunity__c = oOpportunity.id, SBQQ__Quote__c = oQuote.Id);
    insert oContract;
    
    Test.StartTest();
    ApexPages.StandardController sc = new ApexPages.StandardController(oQuote);
    Apexpages.currentpage().getparameters().put('qId' , oQuote.id);
    CompleteAmend_Cls oCompleteAmend = new CompleteAmend_Cls(sc);
    oCompleteAmend.CompleteAmend();
    
    oQuote.SBQQ__Type__c = 'Amendment';
    update oQuote;
    oCompleteAmend.CompleteAmend();
    
    oEvent.Signature_Required_in_Amend__c = false;
    update oEvent;
    oCompleteAmend.CompleteAmend();
    
    oCompleteAmend.redirectQuote();
    oCompleteAmend.CompleteAmend();

    Test.StopTest();
  }
}