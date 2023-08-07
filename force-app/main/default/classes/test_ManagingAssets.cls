/**
 * @Author      : 
 * @Date        : 
 * Apex Class : 
 * * Modified By : Rajesh kumar Yadav Bk-3751, [Modified By : Aishwarya 12 Aug 2020 BK-3751]
 */
@isTest
public class test_ManagingAssets{
    static testMethod void unitTest(){
        
        Account oAccount = new Account(Name='Rebook_EE Account', CurrencyIsoCode = 'USD');
        insert oAccount;
        system.assertEquals(oAccount.Name, 'Rebook_EE Account', 'Both values should be the same.');
        
        Contact oCon = new Contact(LastName='Rebook_EECont', Email='test1contact@sforce.com', AccountId = oAccount.Id, MailingStreet = 'Test',MailingCity ='Test',MailingState='',MailingCountry='India', MobilePhone = '2121212145');
        insert oCon;
        system.assertEquals(oCon.LastName, 'Rebook_EECont', 'Both values should be the same.');
        
        Product2 prd1 = new Product2(Name = 'Linear Booth',Family = 'Booth', Number_of_Corners__c = 0);
        insert prd1;
        
        Pricebook2 customPB = new Pricebook2(Name='ICRE', isActive=true);
        insert customPB;
        
        Id pricebookId = Test.getStandardPricebookId();
        system.assertEquals(pricebookId, Test.getStandardPricebookId(), 'Id must be same');
        
        PricebookEntry stndrdPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prd1.Id,UnitPrice = 100, IsActive = true);
        insert stndrdPrice;
        
        PricebookEntry iCREPrice = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = prd1.Id,UnitPrice = 200, IsActive = true);
        insert iCREPrice;
        
        Event_Edition__c oEvent = new Event_Edition__c(
            Name = 'World of Concrete 2017',
            Approval_Service_Now_ID__c = '123',
            End_Date__c =Date.today().adddays(-1),
            Assets_Creation_Days__c = 1, 
            CurrencyIsoCode = 'USD', 
            Event_Code__c = 'KDB,KDB2', 
            Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', 
            No_Of_Corner__c = '0,1,2,3,4', 
            Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', 
            Start_Date__c = Date.today()
        );
        insert oEvent;
        system.assertEquals(oEvent.Name, 'World of Concrete 2017', 'Both values should be the same.');
        
        list<Event_Edition__c> eelist = new list<Event_Edition__c>();
        eelist.add(oEvent);
        
        Opportunity oOpportunity = new Opportunity(
            Name = 'Expocad Opportunity', 
            CloseDate = Date.today(), 
            StageName = 'Proposal Sent',
            EventEdition__c = oEvent.Id, 
            AccountId = oAccount.Id, 
            Billing_Contact__c = oCon.Id 
        );
        insert oOpportunity;  
        
        SBQQ__Quote__c oQuote = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Quote Sent', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = oOpportunity.Id, SBQQ__Account__c = oAccount.Id);
        insert oQuote;
        system.assertEquals(oQuote.SBQQ__Status__c, 'Quote Sent', 'Both values should be the same.');
        SBQQ__QuoteLine__c oQuoteLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = oQuote.Id, SBQQ__Product__c = prd1.Id, SBQQ__Quantity__c = 2, SBQQ__Number__c = 1, Line_Description__c = 'Test', Booth_Number__c = 'TESTBN3', Booth__c = True);
        insert oQuoteLine;
        system.assertNotEquals(oQuoteLine.Id, null, 'Id cannot be blank');
        
        oOpportunity.StageName = 'Closed Booked';
        update oOpportunity;
        Test.startTest();
        btchCls_createAssestsForEventEditions btch = new btchCls_createAssestsForEventEditions();
        DataBase.executeBatch(btch);
        
        schedulerManageAssets sh1 = new schedulerManageAssets();
        schedulerManageAssets.scheduleAssets();
        String sch = '0 0 23 * * ?'; system.schedule('Manage Assets', sch, sh1); 
        Test.stopTest();

/*      
        ID batchprocessid = Database.executeBatch(btch);
        
        schedulerManageAssets sh1 = new schedulerManageAssets();
        schedulerManageAssets.scheduleAssets();
        String sch = '0 0 23 * * ?'; system.schedule('Manage Assets', sch, sh1); 
        
        
        Database.QueryLocator QL;
        Database.BatchableContext BC;
        
        btchCls_createAssestsForEventEditions btch = new btchCls_createAssestsForEventEditions();
        btch.start(BC);
        btch.execute(BC,eelist);
        btch.finish(BC);   
        */
        
    }
}