/**
 * File:            cls_amendContract_Test
 * Project:         GAP
 * Code Coverage:   97%
 * Date:            June 28, 2017
 * Created By:      Kumar Gaurav
 * *************************************************************************
 * Description:     Test class for cls_amendContract.
 * *************************************************************************
 * History:
 */

@isTest(seeAlldata = false)
public class cls_amendContract_Test {
  
  static testMethod void amendTest() {
    
    Application_Bypass__c oAB = new Application_Bypass__c(SetupOwnerId=UserInfo.getOrganizationId(), Bypass_Validation_Rules__c = True);
    Insert oAB ;

    Account oAccount = new Account(Name='Expocad Account', CurrencyIsoCode = 'USD');
    insert oAccount;
    System.assertEquals('Expocad Account', oAccount.name, 'Account cannot be null');
    
    Contact oCon = new Contact(LastName='ContTest1', Email='test1contact@duptest.com', AccountId = oAccount.Id, MailingStreet = 'Test',MailingCity ='Test',MailingState='',MailingCountry='India', MobilePhone = '2121212145');
    insert oCon;
    
    User oUser = [SELECT Id FROM User WHERE Id = : UserInfo.getUserId()];
    AccountTeamMember oAtm =new AccountTeamMember(AccountId = oAccount.id, userId = oUser.id);
    insert oAtm;
    
    Brand__c oBrand = new Brand__c(Name='World of Concrete', SSC_Email_Distribution_ID__c = 'test@test.tst');
    insert oBrand;
    
    Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Brand__c=oBrand.id, Event_Edition_Pool__c = 'WOC');
    insert oEventseries;
    
    Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017',Part_of_Series__c=oEventseries.Id, Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information',Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = '');
    insert oEvent;
    
    Opportunity oOpportunity = new Opportunity(Name = 'Expocad Opportunity', CloseDate = Date.today(), StageName = 'Proposal', EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id, AccountId = oAccount.Id, Billing_Contact__c = oCon.Id, Opportunity_Contact__c= oCon.Id);
    insert oOpportunity;
    
    SBQQ__Quote__c oQuote = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = oOpportunity.Id, SBQQ__Account__c = oAccount.Id, SBQQ__Primary__c = true);
    insert oQuote;
    
    Id pricebookId = Test.getStandardPricebookId();
    Product2 prd1 = new Product2(Name = 'Post Draw Indoor Booth',Family = 'Booth', Number_of_Corners__c = 0, Event_Edition_Pool__c = 'WOC', Event_Edition__c = oEvent.Id, Expiry_Date__c = Date.today());
    insert prd1;
    Pricebook2 customPB = new Pricebook2(Name='ICRE', isActive=true);
    insert customPB;
    PricebookEntry StndrdPrice1 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prd1.Id,UnitPrice = 100, IsActive = true);
    insert StndrdPrice1;
    PricebookEntry ICREPrice1 = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = prd1.Id,UnitPrice = 200, IsActive = true);
    insert ICREPrice1;

    SBQQ__QuoteLine__c oQuoteLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = oQuote.Id, SBQQ__Product__c = prd1.Id, SBQQ__Quantity__c = 2, SBQQ__Number__c = 1, Line_Description__c = 'Test', Booth_Number__c = 'TESTBN3', Booth__c = True);
    insert oQuoteLine ;

    Contract oContract = new Contract(AccountId = oAccount.id, Status='Sent', StartDate = Date.today(), ContractTerm = 12, SBQQ__Opportunity__c = oOpportunity.id, SBQQ__Quote__c = oQuote.Id);
    insert oContract;
    
    /*Change_Request__c cReq = new Change_Request__c();
    cReq.Account__c = oAccount.Id;
    cReq.Event_Edition__c = oEvent.Id;
    cReq.Opportunity__c = oOpportunity.Id;
    cReq.Product_Type__c = 'Financial Change';
    cReq.Type_of_Change__c = 'Booth Change';
    cReq.Change_Request_Status__c = 'New';
    cReq.Amended_Opportunity__c = oOpportunity.Id;
    insert cReq;*/

    Test.StartTest();
    ApexPages.StandardController sc = new ApexPages.StandardController(oOpportunity);
    Apexpages.currentpage().getparameters().put('oppId' , oOpportunity.id);
    //ApexPages.currentPage().getParameters().put('prdType', cReq.Product_Type__c);
    //ApexPages.currentPage().getParameters().put('tyChg', cReq.Type_of_Change__c);
    cls_amendContract oAmendContract = new cls_amendContract(sc);
    oAmendContract.amendContract();

    oOpportunity.StageName = 'Closed Won';
    oOpportunity.Main_Contract__c = null;
    update oOpportunity;
    oAmendContract.amendContract();
    
    oOpportunity.Main_Contract__c = oContract.id;
    //oOpportunity.SBQQ__Contracted__c = true;
    update oOpportunity;
    oAmendContract.amendContract();
    
    oOpportunity.SBQQ__AmendedContract__c = oContract.id;
    update oOpportunity;
    oAmendContract.amendContract();
    
    oAmendContract.redirectOppty();
    Test.StopTest();
  }
}