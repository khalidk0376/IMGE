/**
* Project:     Informa Markets
* Date:        Dec, 11 2019
* Created By:  Avinash Shukla
* Test Class For :  Opp_Handler_WorkOrder(97%)
* *************************************************************************
* @description This is test class for Opp_Handler_WorkOrder handler.
* *************************************************************************
*/
@isTest
public without sharing class Opp_Handler_WorkOrder_Test {
    /**
    * @description data Setup.
    */
    @testSetup static void testDataSetup() {
        Document  document = new Document();
        document.Body = Blob.valueOf('TestingText');
        document.ContentType = 'image/png';
        document.DeveloperName = 'Tester';
        document.IsPublic = true;
        document.Name = 'EmailTemplateHeader_Logo';
        document.FolderId = [select id from folder where name = 'Images'].id;
        insert document;

        Document  documentfooter = new Document();
        documentfooter .Body = Blob.valueOf('TestingText');
        documentfooter .ContentType = 'image/png';
        documentfooter .DeveloperName = 'TesterName';
        documentfooter .IsPublic = true;
        documentfooter .Name = 'EmailTemplateFooter_Logo';
        documentfooter .FolderId = [select id from folder where name = 'Images'].id;
        insert documentfooter ;

        Account oAccount = new Account(Name = 'Expocad Account', CurrencyIsoCode = 'USD');
        insert oAccount;
        Contact oCon = new Contact(LastName = 'ContTest1', Email = 'abdul.kadir@gmail.com', AccountId = oAccount.Id, MailingState = '', MailingCountry = 'India');
        insert oCon;
        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017', Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information', Booth_Rent_Stage__c = 'On Contract', Approval_Service_Now_ID__c = '123', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt' );
        insert oEvent;
        Opportunity oOpportunity = new Opportunity(Name = 'Expocad Opportunity', CloseDate = Date.today().addDays(7), StageName = 'Needs Assessment', EventEdition__c = oEvent.Id, AccountId = oAccount.Id, Billing_Contact__c = oCon.Id, Payment_Status__c = 'Not Paid');
        insert oOpportunity;
        Work_Order_Template__c wot = new Work_Order_Template__c();
        wot.Name = 'test';
        wot.CurrencyIsoCode = 'USD';
        insert wot;

        Pricebook2 pb = new Pricebook2(Name = 'ICRE');
        insert pb;
        Product2 pro = new Product2(Name = 'BXCD', isActive = true, Work_Order_Template__c = wot.Id, Family = 'Event');
        insert pro;
        PricebookEntry pbe = new PricebookEntry(unitprice = 0.01, Product2Id = pro.Id, Pricebook2Id = Test.getStandardPricebookId(), isActive = true, UseStandardPrice = false);
        insert pbe;

        OpportunityLineItem oPplineitem = new OpportunityLineItem (Quantity = 2, OpportunityId = oOpportunity.Id, UnitPrice = 0.01, PriceBookEntryId = pbe.Id,
                ServiceEndDate__c = date.today(), Run_Date__c = date.today());
        insert oPplineitem;

        Work_Order_Task__c wotask = new Work_Order_Task__c();
        wotask.Name = 'test';
        wotask.CurrencyIsoCode = 'USD';
        wotask.Work_Order_Template__c = wot.Id;
        insert wotask;

        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User u = new User(Alias = 'stndt', Email = 'stander@testorg.com',
                          EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                          LocaleSidKey = 'en_US', ProfileId = p.Id,
                          TimeZoneSidKey = 'America/Los_Angeles', UserName = 'stanuser@testorg.com');
        insert u;

        WorkOrder wo = new WorkOrder();
        wo.Work_Order_Name__c = 'test';
        wo.Status = 'Closed';
        wo.Work_Order_Template__c = wot.Id;
        wo.Opportunity__c = oOpportunity.Id;
        wo.AccountId = oAccount.Id;
        wo.Event_Edition__c = oEvent.Id;
        wo.Product_Name__c = pro.Id;
        wo.OwnerId = u.Id;

        insert wo;

        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.Task_Name__c = wotask.Name;
        woli.WorkOrderId = wo.Id;
        woli.status = 'New';
        insert woli;

        woli.Assign__c = userinfo.getUserId();

        woli.status = 'Closed';
        update woli;

        woli.status = 'Completed';
        update woli;

        WorkOrder_Team__c woTeam = new WorkOrder_Team__c();
        woTeam.Team_Member__c = u.id;
        woTeam.Work_Order_Template__c = wot.Id;
        woTeam.Work_Order__c = wo.Id;
        woTeam.CurrencyIsoCode = 'USD';
        woTeam.Work_Order_Owner__c = true;
        woTeam.Notify_User__c = true;
        insert woTeam;
    }
    /**
    * @description Update opportunity to Closed Won
    */
    static testMethod void testOppCw1() {
        Test.startTest();
        Opportunity opp = [SELECT StageName from Opportunity Where Name = 'Expocad Opportunity'];
        opp.StageName = 'Closed Won';
        update opp;
        Test.stopTest();
        Opportunity oppp = [Select Id, StageName from Opportunity WHERE Name = 'Expocad Opportunity'];
        System.assertEquals(oppp.StageName, 'Closed Won', 'Update Failed');
    }
    /**
    * @description Update opportunity to Closed Lost
    */
    static testMethod void testOppCl() {
        Test.startTest();
        Opportunity opp = [SELECT StageName from Opportunity Where Name = 'Expocad Opportunity'];
        opp.StageName = 'Closed Lost';
        opp.Cancel_Reason__c = 'Test';
        opp.Reason_Lost__c = 'AR Cancel / Re-bill';
        update opp;
        Test.stopTest();
        Opportunity oppp = [Select Id, StageName from Opportunity WHERE Name = 'Expocad Opportunity'];
        System.assertEquals(oppp.StageName, 'Closed Lost', 'Update Failed');
    }
}