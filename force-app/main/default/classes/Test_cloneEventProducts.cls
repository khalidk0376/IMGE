@isTest
public class Test_cloneEventProducts{
  
    static testMethod void unitTest() {
        
    Test.StartTest();
    Account oAccount = new Account(Name='Rebook_EE Account', CurrencyIsoCode = 'USD');
    insert oAccount;
    System.assertEquals('Rebook_EE Account',oAccount.name,'Error account is not created');
    
    Contact oCon = new Contact(LastName='Rebook_EECont', Email='test1contact@sforce.com', AccountId = oAccount.Id, MailingStreet = 'Test',MailingCity ='Test',MailingState='',MailingCountry='India');
    insert oCon;
    
    User oUser = [SELECT Id FROM User WHERE Id = : UserInfo.getUserId()];
    AccountTeamMember oAtm =new AccountTeamMember(AccountId = oAccount.id, userId = oUser.id);
    insert oAtm;
        
    Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017',Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Start_Date__c = Date.today());
    oEvent.Event_Edition_Code__c = 'KDB';
    insert oEvent;
    
    Event_Edition__c oEvent3 = new Event_Edition__c(Name = 'World of Concrete 2018',Approval_Service_Now_ID__c = '1234', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Start_Date__c = Date.today());
    oEvent3.Event_Edition_Code__c = 'KDB1';
    insert oEvent3;
    
    Event_Edition__c oEvent2 = new Event_Edition__c(Name = 'Arab Health 2018', Approval_Service_Now_ID__c = '1234', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Start_Date__c = Date.today(),End_Date__c = Date.today());
    oEvent2.Event_Edition_Code__c = 'KDB2';
    insert oEvent2;
    
    Opportunity oOpportunity = new Opportunity(Name = 'Expocad Opportunity', CloseDate = Date.today(), StageName = 'Closed Booked', EventEdition__c = oEvent.Id, AccountId = oAccount.Id, Billing_Contact__c = oCon.Id, Rebooked__c = false);
    insert oOpportunity;    
    
    Product2 prd1 = new Product2(Name = 'Linear Booth',Family = 'Booth', Number_of_Corners__c = 0, Event_Edition_Pool__c = 'WOC',Product_Brand__c = 'World of Concrete 2017');
    insert prd1;
    
    Pricebook2 customPB = new Pricebook2(Name='ICRE', isActive=true);
    insert customPB;
    
    Pricebook2 stdPB = new Pricebook2(Name='ICRE1', isActive=true);
    insert stdPB;
    
    Id pricebookId = Test.getStandardPricebookId();
    
    PricebookEntry stndrdPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prd1.Id,UnitPrice = 100, IsActive = true);
    insert stndrdPrice;
    
    PricebookEntry iCREPrice = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = prd1.Id,UnitPrice = 200, IsActive = true);
    insert iCREPrice;

    Product2 prd2 = new Product2(Name = 'Linear Booth',Family = 'Booth', Number_of_Corners__c = 0, ProductCode='Linear Booth' ,Event_Edition_Pool__c = 'LFSC',Product_Brand__c = 'Arab Health 2017');
    insert prd2;
    
    Pricebook2 customPB2 = new Pricebook2(Name='ICRE2', isActive=true);
    insert customPB2;
    
    //Added by palla kishore for the ticket BK-19604
    Pricebook2 standardPricebook = new Pricebook2(
	Id = Test.getStandardPricebookId(),
	IsActive = true);
    update standardPricebook;
    standardPricebook = [SELECT IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];
        
    PricebookEntry stndrdPrice2 = new PricebookEntry(Pricebook2Id = standardPricebook.Id, Product2Id = prd2.Id,UnitPrice = 100, IsActive = true );
    insert stndrdPrice2;
    
    PricebookEntry iCREPrice2 = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = prd2.Id,UnitPrice = 200, IsActive = true);
    insert iCREPrice2;
    
    /*OpportunityLineItem oppLine = new OpportunityLineItem(pricebookentryid=ICREPrice.Id,TotalPrice=2000,Quantity = 2,OpportunityID = oOpportunity.Id);
    insert oppLine;*/
    
    SBQQ__ProductRule__c objPRule = new SBQQ__ProductRule__c();
    objPRule.name= 'Test P Rule';
    objPRule.SBQQ__Type__c = 'Filter';
    objPRule.SBQQ__ConditionsMet__c = 'All';
    objPRule.SBQQ__Scope__c = 'Product';
    insert objPRule;
    
    SBQQ__ProductFeature__c objFeature = new SBQQ__ProductFeature__c();
    objFeature.name='Core Product';
    objFeature.SBQQ__Number__c = 10;
    objFeature.SBQQ__ConfiguredSKU__c = prd2.id;
    objFeature.SBQQ__MinOptionCount__c = 1;
    insert objFeature;
    
    SBQQ__ProductOption__c objOptions = new SBQQ__ProductOption__c();
    objOptions.SBQQ__Number__c =5;
    objOptions.SBQQ__ConfiguredSKU__c = prd2.id;
    objOptions.SBQQ__OptionalSKU__c = prd2.id;
    objOptions.SBQQ__Feature__c = objFeature.id;
    insert objOptions;
    
    SBQQ__ConfigurationRule__c objCRules = new SBQQ__ConfigurationRule__c();
    objCRules.SBQQ__Product__c = prd2.id;
    objCRules.SBQQ__ProductRule__c = objPRule.id;
    insert objCRules;
    
    CPQ_Product_Clone__c objClone = new CPQ_Product_Clone__c();
    objClone.Event_Series__c ='Arab Health';
    objClone.Cloned__c = false;
    objClone.Source_Event_Edition__c = 'Arab Health 2017';
    objClone.Target_Event_Edition__c = 'Arab Health 2018';
    insert objClone;
    
    /*ApexPages.StandardController sc = new ApexPages.StandardController(oOpportunity);
    Apexpages.currentpage().getparameters().put('id' , oOpportunity.id);
    Rebooking_with_Products RWp = new Rebooking_with_Products(sc);
    RWp.objectDetails();
    PageReference pg = RWp.previous();
    PageReference pg1 = RWp.next();
    */
    
    cls_cloneEventProducts cloneProd = new cls_cloneEventProducts();
    Apexpages.currentpage().getparameters().put('eventId' , objClone.id);
    Apexpages.currentpage().getparameters().put('sourceEventEdition' , objClone.Source_Event_Edition__c);
    Apexpages.currentpage().getparameters().put('targetEventEdition' , objClone.Target_Event_Edition__c);
    
    cloneProd.eventProductsSearch();
    cloneProd.cancelRecord();

    Test.StopTest();
    }
}