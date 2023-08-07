@isTest
public class Rebooking_without_Products_Test {
  
    static testMethod void unitTest() {
        Test.StartTest();
        Account oAccount = new Account(Name='Rebook_EE Account', CurrencyIsoCode = 'USD');
        insert oAccount;
        
        Contact oCon = new Contact(LastName='Rebook_EECont', Email='test1contact@sforce.com', AccountId = oAccount.Id, MailingStreet = 'Test',MailingCity ='Test',MailingState='',MailingCountry='India', MobilePhone = '2121212145');
        insert oCon;
        System.AssertEquals( 'Rebook_EECont' , oCon.LastName, 'lastName must not be null');
        
        User oUser = [SELECT Id FROM User WHERE Id = : UserInfo.getUserId()];

        AccountTeamMember oAtm =new AccountTeamMember(AccountId = oAccount.id, userId = oUser.id);
        
        insert oAtm;
        
        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017',Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information',Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Start_Date__c = Date.today());
        insert oEvent;
        
       // Event_Edition__c oEvent2 = new Event_Edition__c(Name = 'Arab Health Exhibition and Congress 2020',Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information',Approval_Service_Now_ID__c = '1234', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Start_Date__c = Date.today());
        //insert oEvent2;
        
        Opportunity oOpportunity = new Opportunity(Name = 'Expocad Opportunity', CloseDate = Date.today(), StageName = 'Closed Booked', EventEdition__c = oEvent.Id, AccountId = oAccount.Id, Billing_Contact__c = oCon.Id, Rebooked__c = true);
        insert oOpportunity;  
        oOpportunity.Rebooked__c = true;
        update oOpportunity;
        
        Product2 prd1 = new Product2(Name = 'Linear Booth',Family = 'Booth', Number_of_Corners__c = 0, Event_Edition_Pool__c = 'WOC',Product_Brand__c = 'World of Concrete 2017');
        insert prd1;
        Pricebook2 customPB = new Pricebook2(Name='ICRE', isActive=true);
        insert customPB;
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry stndrdPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prd1.Id,UnitPrice = 100, IsActive = true);
        insert stndrdPrice;
        PricebookEntry iCREPrice = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = prd1.Id,UnitPrice = 200, IsActive = true);
        insert iCREPrice;

        Product2 prd2 = new Product2(Name = 'Linear Booth2',Family = 'Booth', Number_of_Corners__c = 0, Event_Edition_Pool__c = 'WOC',Product_Brand__c = 'World of Concrete 2018');
        insert prd2;
        Pricebook2 customPB2 = new Pricebook2(Name='ICR2E', isActive=true);
        insert customPB2;
        Id pricebookId2 = Test.getStandardPricebookId();
        PricebookEntry stndrdPrice2 = new PricebookEntry(Pricebook2Id = pricebookId2, Product2Id = prd2.Id,UnitPrice = 100, IsActive = true);
        insert stndrdPrice2;
        PricebookEntry iCREPrice2 = new PricebookEntry(Pricebook2Id = customPB2.Id, Product2Id = prd2.Id,UnitPrice = 200, IsActive = true);
        insert iCREPrice2;
        
        //OpportunityLineItem oppLine = new OpportunityLineItem(pricebookentryid=ICREPrice.Id,TotalPrice=2000,Quantity = 2,OpportunityID = oOpportunity.Id);
        //insert oppLine;
        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(oOpportunity);
        Apexpages.currentpage().getparameters().put('id' , oOpportunity.id);
        Rebooking_without_Products rWp = new Rebooking_without_Products(sc);
        rWp.nextYearOfEvent = 2018;
        rWp.nameOfNextYear = 'Test 2018';
        rWp.eventEditionName = 'Test 2017';
        rWp.yearOfEvent = '2017';
        rWp.objectDetails();
        PageReference pg = rWp.previous();
        PageReference pg1 = rWp.next();
        Test.StopTest();

    }
}