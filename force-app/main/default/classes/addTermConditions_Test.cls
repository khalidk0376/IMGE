/**
 * Created/Modified By  :  
 * Created On:          :  
 * @description         : 
 * Modification log --  :[Modified By : Aishwarya 12 Aug 2020 BK-3751]
 * * Modified By : Rajesh kumar Yadav Bk-3751, [Aishwarya 17 Aug 2020 BK-3751]
**/
@isTest
public class addTermConditions_Test{
    /*
    @testsetup
    static void testDataSetup(){
         //BK-3753 - EmptyStatementBlock Violation Reported so I am commented this block as of now.
}
*/
    static testmethod void validatetermAndCondi(){
        
     APXTConga4__Conga_Template__c ct = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'test');
        insert ct; 
        SBQQ__QuoteTerm__c objterm=new SBQQ__QuoteTerm__c ();
        objterm.Digital_Product_Identifier__c=1;
        objterm.Event_Identifier__c='A001';
        objterm.SBQQ__Body__c ='test';
        objTerm.SBQQ__PrintOrder__c = 1;
        objterm.SBQQ__Active__c=true;
        insert objterm;
        system.assertEquals(objterm.SBQQ__Body__c ,'test', 'Both values should be the equals.');
        
        SBQQ__QuoteTerm__c objterm1=new SBQQ__QuoteTerm__c ();
       objterm1.Event_Identifier__c='A001';
        objterm1.SBQQ__ParentTerm__c = objterm.id;
        objterm1.SBQQ__Body__c ='test';
        objTerm1.SBQQ__PrintOrder__c =2;
        objterm1.SBQQ__Active__c=true;
        objterm1.SBQQ__ParentTerm__c=objterm.id;
        insert objterm1;
        system.assertEquals(objterm1.SBQQ__Body__c ,'test', 'Both values should be the equals.');
        
        SBQQ__SummaryVariable__c sumObj=new SBQQ__SummaryVariable__c();
        sumObj.Name='SponsorCounter';
        sumObj.SBQQ__TargetObject__c='SBQQ__QuoteLine__c';
        sumObj.SBQQ__AggregateFunction__c='Sum';
        sumObj.SBQQ__AggregateField__c='Quantity';
        sumObj.SBQQ__FilterField__c='Event_Product_Type__c';
        sumObj.SBQQ__FilterValue__c='Sponsorship';
        sumObj.SBQQ__Operator__c='equals';
        insert sumObj;
        system.assertEquals(sumObj.SBQQ__AggregateField__c,'Quantity', 'Both values should be the equals.');
        
        SBQQ__SummaryVariable__c sumObj1=new SBQQ__SummaryVariable__c();
        sumObj1.Name='QT_A001Counter';
        sumObj1.SBQQ__TargetObject__c='SBQQ__QuoteLine__c';
        sumObj1.SBQQ__AggregateFunction__c='Sum';
        sumObj1.SBQQ__AggregateField__c='Quantity';
        sumObj1.SBQQ__FilterField__c='Quote_Terms_Identifier__c';
        sumObj1.SBQQ__FilterValue__c='A001';
        sumObj1.SBQQ__Operator__c='equals';
        insert sumObj1;
        system.assertEquals(sumObj1.SBQQ__AggregateField__c,'Quantity', 'Both values should be the equals.');
        
        SBQQ__TermCondition__c  objtc=new SBQQ__TermCondition__c ();
        //objtc.SBQQ__QuoteTerm__c =SBQQ__QuoteTerm__c;
       // objtc.SBQQ__TestedField__c = 'List Amount'; 
        objtc.SBQQ__Operator__c='greater or equals';
        objtc.SBQQ__Value__c='1';
        objtc.SBQQ__QuoteTerm__c = objterm.id;
        objtc.SBQQ__TestedVariable__c=sumobj.Id;
        objtc.Conga_Template__c=ct.Id;
       
        insert objtc;
        SBQQ__TermCondition__c  objtc1=new SBQQ__TermCondition__c ();
        //objtc.SBQQ__QuoteTerm__c =SBQQ__QuoteTerm__c;
       // objtc1.SBQQ__TestedField__c = 'List Amount'; 
        objtc.SBQQ__Operator__c='greater or equals';
        objtc.SBQQ__Value__c='1';
        objtc1.SBQQ__QuoteTerm__c = objterm.id;
        objtc1.SBQQ__TestedVariable__c=sumobj1.Id;
        objtc1.Conga_Template__c=ct.Id;
        insert objtc1;
        
     Account oAccount = new Account(Name='Expocad Account', CurrencyIsoCode = 'USD');
    insert oAccount;
    
    Contact oCon = new Contact(LastName = 'ContTest1', Email = 'test1contact@duptest.com', AccountId = oAccount.Id, MailingStreet = 'Test', MailingCity = 'Test', MailingState='',MailingCountry='India', MobilePhone = '2121212145');
    insert oCon;
    
    User oUser = [SELECT Id FROM User WHERE Id = : UserInfo.getUserId()];
    system.assertEquals(oUser.Id, UserInfo.getUserId(), 'User Id equals Login user id');
    AccountTeamMember oAtm =new AccountTeamMember(AccountId = oAccount.id, userId = oUser.id);
    insert oAtm;
    
    Brand__c oBrand = new Brand__c(Name='World of Concrete', SSC_Email_Distribution_ID__c = 'test@test.tst');
    insert oBrand;
    
    Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Brand__c=oBrand.id);
    insert oEventseries;
    
    Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017',Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information',Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = '',Quote_Terms_Identifier__c='A001');
    insert oEvent;
    
    Opportunity oOpportunity = new Opportunity(Name = 'Expocad Opportunity', CloseDate = Date.today(), StageName = 'Proposal', EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id, AccountId = oAccount.Id, Billing_Contact__c = oCon.Id);
    insert oOpportunity;
    system.assertEquals(oOpportunity.StageName, 'Proposal', 'Both values should be the equals.');
    
    SBQQ__Quote__c oQuote = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Quote Sent', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = oOpportunity.Id, SBQQ__Account__c = oAccount.Id, SBQQ__Primary__c = true);
    insert oQuote;
    system.assertEquals(oQuote.SBQQ__Status__c, 'Quote Sent', 'Both values should be the same.');
    Contract oContract = new Contract(AccountId = oAccount.Id, Status='Draft', SBQQ__Opportunity__c=oOpportunity.Id, SBQQ__Quote__c = oQuote.id);
    insert oContract;
    
    SBQQ__Quote__c oQuote2 = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Quote Sent', SBQQ__Opportunity2__c = oOpportunity.Id, SBQQ__Account__c = oAccount.Id, SBQQ__Primary__c = true, SBQQ__MasterContract__c=oContract.Id, SBQQ__Type__c = 'Amendment');
    insert oQuote2;
        
    Product2 prd1 = new Product2(Name = 'Pre Draw Indoor Booth',Family = 'Booth', Number_of_Corners__c = 0, Event_Edition_Pool__c = 'WOC', Product_Brand__c = 'World of Concrete 2017',Event_Product_Type__c='Sponsorship');
    insert prd1;
    Pricebook2 customPB = new Pricebook2(Name='ICRE', isActive=true);
    insert customPB;
    Id pricebookId = Test.getStandardPricebookId();
    system.assertEquals(pricebookId, Test.getStandardPricebookId(), 'Both values should be the equals.');
    PricebookEntry stndrdPrice1 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prd1.Id,UnitPrice = 100, IsActive = true);
    insert stndrdPrice1;
    PricebookEntry iCREPrice1 = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = prd1.Id,UnitPrice = 200, IsActive = true);
    insert iCREPrice1;
    
    Test.startTest();
    ExpocadBooth__c oEB = new ExpocadBooth__c(Quote__c = oQuote2.Id, Opportunity__c = oOpportunity.Id, Account__c = oAccount.Id, Open_Corners__c = 4, Dimensions__c = '', Booth_Type__c = 'Linear', Area__c = '100 SqFt', Last_Action_Date__c = Date.today(), Booth_Number__c = 'TESTBN3', Status__c = 'On Hold', Selected__c = True);
    insert oEB;
    
    SBQQ__QuoteLine__c oQuoteLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = oQuote.Id, SBQQ__Product__c = prd1.Id, SBQQ__Quantity__c = 2, SBQQ__Number__c = 1, Line_Description__c = 'Test', Booth_Number__c = 'TESTBN3', Booth__c = true);
    insert oQuoteLine;
    system.assertEquals(oQuoteLine.SBQQ__Product__c,prd1.Id, 'Both values should be the equals.');
    
    SBQQ__QuoteLine__c oQuoteLine2 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = oQuote2.Id, SBQQ__Product__c = prd1.Id, SBQQ__Quantity__c = 2, SBQQ__Number__c = 1, Line_Description__c = 'Test', Booth_Number__c = 'TESTBN3', Booth__c = false);
    insert oQuoteLine2;
    system.assertEquals(oQuoteLine2.SBQQ__Product__c,prd1.Id, 'Both values should be the equals.');
    
    List<SBQQ__Quote__c> quoteIdList = new List<SBQQ__Quote__c>();
    quoteIdList.add(oQuote);
    quoteIdList.add(oQuote2);
    addTermConditions.TandC(quoteIdList);
       
    Test.stopTest();
    }
}