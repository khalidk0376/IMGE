/**
* Project:     Informa Markets
* Date:        Dec, 11 2019
* Created By:  Avinash Shukla
* Test Class For :  Opp_Handler_Opportunity2
* *************************************************************************
* @description This is Handler for Opportunity Trigger. It is used mainly for Account updation.
* *************************************************************************
*/
@isTest
public with sharing class Opp_Handler_Opportunity2_Test {
    static testMethod void updateQuoteStatusTest2() {
        Set<Id> setIds = new Set<Id>();
        Account oacc = new Account (Name = 'testAccount',BillingCountryCode='US');
        insert oacc ;
        Trigger__c trig = new Trigger__c(Name = 'UpdateQuoteStatus' , Trigger_Name_Unique__c = 'UpdateQuoteStatus', Enabled__c = true, Object__c = 'Opportunity', Run_for_Recordypes__c = 'All',  Description__c = 'my test', Execution_Order__c = 1, Before_Update__c = true, After_Update__c = true );
        Insert trig;
        Trigger_Recordtype__c rt = new Trigger_Recordtype__c(Enabled__c=true,Recordtype_Id__c=trig.Id,Trigger__c=trig.Id,Parameters__c='param=1;param=2');
        Insert rt;
        TriggerInterface_Opp obj=new TriggerInterface_Opp();
        Contact oCon = new Contact(LastName = 'ContTest1', Email = 'test1contact@duptest.com', AccountId = oacc.Id, MailingStreet = 'Test', MailingCity = 'Test', MailingState = '', MailingCountry = 'India');
        insert oCon;

        Brand__c oBrand = new Brand__c(Name = 'World of Concrete', SSC_Email_Distribution_ID__c = 'test@test.tst');
        insert oBrand;

        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Brand__c = oBrand.id, Event_Edition_Pool__c = 'WOC');
        insert oEventseries;

        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017', Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information', Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = 'Space Only', Expocad_API_Url__c = 'test.com', Part_of_Series__c = oEventseries.id, Booth_Classes_on_Template__c = 'Temp', Corner_Configuration_Check__c = false, Product_Type_Order__c = 'BoothA;;BoothB');
        insert oEvent;

        Opportunity oOpportunity = new Opportunity(Name = 'Expocad Opportunity', CloseDate = Date.today(), StageName = 'Proposal', EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id, AccountId = oacc.Id, Billing_Contact__c = oCon.Id);
        insert oOpportunity;

        SBQQ__Quote__c oQuote = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Quote Sent', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = oOpportunity.Id, SBQQ__Account__c = oacc.Id);
        insert oQuote;

        Test.startTest();
        Opportunity opp1 = new opportunity (name = 'OpportunityTest' , closeDate = Date.Today(), StageName = 'Qualification' , Milestone_1_Amount__c = 3 , Milestone_2_Amount__c = 2 , Milestone_3_Amount__c = 2 , Milestone_4_Amount__c = 2 , Milestone_5_Amount__c = 2 , Milestone_6_Amount__c = 2 , Milestone_7_Amount__c = 2 , Milestone_8_Amount__c = 2 , Milestone_9_Amount__c = 2 , Milestone_10_Amount__c = 2 , Milestone_11_Amount__c = 2 , Milestone_12_Amount__c = 2 ,  Amount = 1000 , AccountId = oacc.id , Total_No_of_payment__c = 5 , Start_Date__c = Date.today() , Custom_Payment__c = false, EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id);
        insert opp1;
        opp1.Total_No_of_payment__c = 2;
        opp1.Milestone_2_Amount__c = 2;
        update opp1;
        system.assertEquals('ContTest1', oCon.LastName, true) ;
        Test.stopTest();

    }
    static testMethod void updateQuoteStatusTest3() {
        Account oacc = new Account (Name = 'testAccount',BillingCountryCode='US');
        insert oacc ;
        Brand__c oBrand = new Brand__c(Name = 'World of Concrete', SSC_Email_Distribution_ID__c = 'test@test.tst');
        insert oBrand;

        Trigger__c trig = new Trigger__c(Name = 'UpdateQuoteStatus' , Trigger_Name_Unique__c = 'UpdateQuoteStatus', Enabled__c = true, Object__c = 'Opportunity', Run_for_Recordypes__c = 'All',  Description__c = 'my test', Execution_Order__c = 1, Before_Update__c = true, After_Update__c = true );
        Insert trig;
        Trigger_Recordtype__c rt = new Trigger_Recordtype__c(Enabled__c=true,Recordtype_Id__c=trig.Id,Trigger__c=trig.Id,Parameters__c='param=1;param=2');
        Insert rt;
        TriggerInterface_Opp obj=new TriggerInterface_Opp();

        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Brand__c = oBrand.id, Event_Edition_Pool__c = 'WOC');
        insert oEventseries;

        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017', Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information', Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = 'Space Only', Expocad_API_Url__c = 'test.com', Part_of_Series__c = oEventseries.id, Booth_Classes_on_Template__c = 'Temp', Start_Date__c = Date.today(), Corner_Configuration_Check__c = false, Product_Type_Order__c = 'BoothA;;BoothB');
        insert oEvent;
        Test.startTest();
        Opportunity opp1 = new opportunity (name = 'OpportunityTest' , closeDate = Date.Today(), StageName = 'Qualification', Milestone_1_Amount__c = 3 , Milestone_2_Amount__c = 2 , Milestone_3_Amount__c = 2 , Milestone_4_Amount__c = 2 , Milestone_5_Amount__c = 2 , Milestone_6_Amount__c = 2 , Milestone_7_Amount__c = 2 , Milestone_8_Amount__c = 2 , Milestone_9_Amount__c = 2 , Milestone_10_Amount__c = 2 , Milestone_11_Amount__c = 2 , Milestone_12_Amount__c = 2 ,   Amount = 1000 , AccountId = oacc.id , Total_No_of_payment__c = 5 , Start_Date__c = Date.newInstance(2018, 3, 3) , Custom_Payment__c = true, EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id);
        insert opp1;
        opp1.Total_No_of_payment__c = 3;
        opp1.Milestone_3_Amount__c = 3;
        update opp1;
        system.assertEquals('World of Concrete 2017', oEvent.Name, true) ;
        Test.stopTest();
    }
    static testMethod void unitTest4() {
        Account oacc = new Account (Name = 'testAccount',BillingCountryCode='US');
        insert oacc ;
        Brand__c oBrand = new Brand__c(Name = 'World of Concrete', SSC_Email_Distribution_ID__c = 'test@test.tst');
        insert oBrand;

        Trigger__c trig = new Trigger__c(Name = 'UpdateQuoteStatus' , Trigger_Name_Unique__c = 'UpdateQuoteStatus', Enabled__c = true, Object__c = 'Opportunity', Run_for_Recordypes__c = 'All',  Description__c = 'my test', Execution_Order__c = 1, Before_Update__c = true, After_Update__c = true );
        Insert trig;
        Trigger_Recordtype__c rt = new Trigger_Recordtype__c(Enabled__c=true,Recordtype_Id__c=trig.Id,Trigger__c=trig.Id,Parameters__c='param=1;param=2');
        Insert rt;
        TriggerInterface_Opp obj=new TriggerInterface_Opp();

        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Brand__c = oBrand.id, Event_Edition_Pool__c = 'WOC');
        insert oEventseries;

        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017', Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information', Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = 'Space Only', Expocad_API_Url__c = 'test.com', Part_of_Series__c = oEventseries.id, Start_Date__c = Date.today(), Booth_Classes_on_Template__c = 'Temp', Corner_Configuration_Check__c = false, Product_Type_Order__c = 'BoothA;;BoothB');
        insert oEvent;
        Test.startTest();
        Opportunity opp1 = new opportunity (name = 'OpportunityTest' , closeDate = Date.Today(), StageName = 'Qualification' , Milestone_1_Amount__c = 3 , Milestone_2_Amount__c = 2 , Milestone_3_Amount__c = 2 , Milestone_4_Amount__c = 2 , Milestone_5_Amount__c = 2 , Milestone_6_Amount__c = 2 , Milestone_7_Amount__c = 2 , Milestone_8_Amount__c = 2 , Milestone_9_Amount__c = 2 , Milestone_10_Amount__c = 2 , Milestone_11_Amount__c = 2 , Milestone_12_Amount__c = 2 ,   Amount = 1000 , AccountId = oacc.id , Total_No_of_payment__c = 5 , Start_Date__c = Date.newInstance(2018, 3, 3) , Custom_Payment__c = true, Payment_Status__c = 'Invoice', EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id);
        insert opp1;
        opp1.Total_No_of_payment__c = 4;
        opp1.Milestone_4_Amount__c = 4;
        opp1.Payment_Status__c = 'Paid';
        update opp1;
        system.assertEquals('World of Concrete 2017', oEvent.Name, true) ;
        Test.stopTest();
    }
    static testMethod void updateQuoteStatusTest4() {
        Account oacc = new Account (Name = 'testAccount',BillingCountryCode='US');
        insert oacc ;
        Brand__c oBrand = new Brand__c(Name = 'World of Concrete', SSC_Email_Distribution_ID__c = 'test@test.tst');
        insert oBrand;
        Trigger__c trig = new Trigger__c(Name = 'UpdateQuoteStatus' , Trigger_Name_Unique__c = 'UpdateQuoteStatus', Enabled__c = true, Object__c = 'Opportunity', Run_for_Recordypes__c = 'All',  Description__c = 'my test', Execution_Order__c = 1, Before_Update__c = true, After_Update__c = true );
        Insert trig;
        Trigger_Recordtype__c rt = new Trigger_Recordtype__c(Enabled__c=true,Recordtype_Id__c=trig.Id,Trigger__c=trig.Id,Parameters__c='param=1;param=2');
        Insert rt;
        TriggerInterface_Opp obj=new TriggerInterface_Opp();
        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Brand__c = oBrand.id, Event_Edition_Pool__c = 'WOC');
        insert oEventseries;

        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017', Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information', Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = 'Space Only', Expocad_API_Url__c = 'test.com', Part_of_Series__c = oEventseries.id, Start_Date__c = Date.today(), Booth_Classes_on_Template__c = 'Temp', Corner_Configuration_Check__c = false, Product_Type_Order__c = 'BoothA;;BoothB');
        insert oEvent;
        Test.startTest();
        Opportunity opp1 = new opportunity (name = 'OpportunityTest' , closeDate = Date.Today(), StageName = 'Qualification' , Milestone_1_Amount__c = 3 , Milestone_2_Amount__c = 2 , Milestone_3_Amount__c = 2 , Milestone_4_Amount__c = 2 , Milestone_5_Amount__c = 2 , Milestone_6_Amount__c = 2 , Milestone_7_Amount__c = 2 , Milestone_8_Amount__c = 2 , Milestone_9_Amount__c = 2 , Milestone_10_Amount__c = 2 , Milestone_11_Amount__c = 2 , Milestone_12_Amount__c = 2 ,   Amount = 1000 , AccountId = oacc.id , Total_No_of_payment__c = 4 , Start_Date__c = Date.newInstance(2018, 3, 3) , Custom_Payment__c = true, EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id);
        insert opp1;
        opp1.Total_No_of_payment__c = 5 ;
        opp1.Milestone_5_Amount__c = 5;
        update opp1;
        system.assertEquals('World of Concrete 2017', oEvent.Name, true) ;
        Test.stopTest();
    }
    static testMethod void updateQuoteStatusTest5() {
        Account oacc = new Account (Name = 'testAccount',BillingCountryCode='US');
        insert oacc ;
        Brand__c oBrand = new Brand__c(Name = 'World of Concrete', SSC_Email_Distribution_ID__c = 'test@test.tst');
        insert oBrand;
        Trigger__c trig = new Trigger__c(Name = 'UpdateQuoteStatus' , Trigger_Name_Unique__c = 'UpdateQuoteStatus', Enabled__c = true, Object__c = 'Opportunity', Run_for_Recordypes__c = 'All',  Description__c = 'my test', Execution_Order__c = 1, Before_Update__c = true, After_Update__c = true );
        Insert trig;
        Trigger_Recordtype__c rt = new Trigger_Recordtype__c(Enabled__c=true,Recordtype_Id__c=trig.Id,Trigger__c=trig.Id,Parameters__c='param=1;param=2');
        Insert rt;
        TriggerInterface_Opp obj=new TriggerInterface_Opp();
        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Brand__c = oBrand.id, Event_Edition_Pool__c = 'WOC');
        insert oEventseries;

        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017', Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information', Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = 'Space Only', Expocad_API_Url__c = 'test.com', Part_of_Series__c = oEventseries.id, Booth_Classes_on_Template__c = 'Temp', Start_Date__c = Date.today(),  Corner_Configuration_Check__c = false, Product_Type_Order__c = 'BoothA;;BoothB');
        insert oEvent;
        Test.startTest();
        Opportunity opp1 = new opportunity (name = 'OpportunityTest' , closeDate = Date.Today(), StageName = 'Qualification' , Milestone_1_Amount__c = 3 , Milestone_2_Amount__c = 2 , Milestone_3_Amount__c = 2 , Milestone_4_Amount__c = 2 , Milestone_5_Amount__c = 2 , Milestone_6_Amount__c = 2 , Milestone_7_Amount__c = 2 , Milestone_8_Amount__c = 2 , Milestone_9_Amount__c = 2 , Milestone_10_Amount__c = 2 , Milestone_11_Amount__c = 2 , Milestone_12_Amount__c = 2 ,   Amount = 1000 , AccountId = oacc.id , Total_No_of_payment__c = 5 , Start_Date__c = Date.newInstance(2018, 3, 3) , Custom_Payment__c = true, EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id);
        insert opp1;
        opp1.Total_No_of_payment__c = 6;
        opp1.Milestone_6_Amount__c = 6;
        update opp1;
        system.assertEquals('World of Concrete 2017', oEvent.Name, true) ;
        Test.stopTest();
    }
    static testMethod void updateQuoteStatusTest6() {
        Account oacc = new Account (Name = 'testAccount',BillingCountryCode='US');
        insert oacc ;
        Brand__c oBrand = new Brand__c(Name = 'World of Concrete', SSC_Email_Distribution_ID__c = 'test@test.tst');
        insert oBrand;
        Trigger__c trig = new Trigger__c(Name = 'UpdateQuoteStatus' , Trigger_Name_Unique__c = 'UpdateQuoteStatus', Enabled__c = true, Object__c = 'Opportunity', Run_for_Recordypes__c = 'All',  Description__c = 'my test', Execution_Order__c = 1, Before_Update__c = true, After_Update__c = true );
        Insert trig;
        Trigger_Recordtype__c rt = new Trigger_Recordtype__c(Enabled__c=true,Recordtype_Id__c=trig.Id,Trigger__c=trig.Id,Parameters__c='param=1;param=2');
        Insert rt;
        TriggerInterface_Opp obj=new TriggerInterface_Opp();
        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Brand__c = oBrand.id, Event_Edition_Pool__c = 'WOC');
        insert oEventseries;

        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017', Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information', Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = 'Space Only', Expocad_API_Url__c = 'test.com', Part_of_Series__c = oEventseries.id, Booth_Classes_on_Template__c = 'Temp', Start_Date__c = Date.today(), Corner_Configuration_Check__c = false, Product_Type_Order__c = 'BoothA;;BoothB');
        insert oEvent;
        Test.startTest();
        Opportunity opp1 = new opportunity (name = 'OpportunityTest' , closeDate = Date.Today(), StageName = 'Qualification' , Milestone_1_Amount__c = 3 , Milestone_2_Amount__c = 2 , Milestone_3_Amount__c = 2 , Milestone_4_Amount__c = 2 , Milestone_5_Amount__c = 2 , Milestone_6_Amount__c = 2 , Milestone_7_Amount__c = 2 , Milestone_8_Amount__c = 2 , Milestone_9_Amount__c = 2 , Milestone_10_Amount__c = 2 , Milestone_11_Amount__c = 2 , Milestone_12_Amount__c = 2 ,  Amount = 1000 , AccountId = oacc.id , Total_No_of_payment__c = 5 , Start_Date__c = Date.newInstance(2018, 3, 3) , Custom_Payment__c = true, EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id);
        insert opp1;
        opp1.Total_No_of_payment__c = 7;
        opp1.Milestone_7_Amount__c = 7;
        update opp1;
        system.assertEquals('World of Concrete 2017', oEvent.Name, true) ;
        Test.stopTest();
    }
    static testMethod void updateQuoteStatusTest7() {
        Account oacc = new Account (Name = 'testAccount',BillingCountryCode='US');
        insert oacc ;
        Brand__c oBrand = new Brand__c(Name = 'World of Concrete', SSC_Email_Distribution_ID__c = 'test@test.tst');
        insert oBrand;
        Trigger__c trig = new Trigger__c(Name = 'UpdateQuoteStatus' , Trigger_Name_Unique__c = 'UpdateQuoteStatus', Enabled__c = true, Object__c = 'Opportunity', Run_for_Recordypes__c = 'All',  Description__c = 'my test', Execution_Order__c = 1, Before_Update__c = true, After_Update__c = true );
        Insert trig;
        Trigger_Recordtype__c rt = new Trigger_Recordtype__c(Enabled__c=true,Recordtype_Id__c=trig.Id,Trigger__c=trig.Id,Parameters__c='param=1;param=2');
        Insert rt;
        TriggerInterface_Opp obj=new TriggerInterface_Opp();
        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Brand__c = oBrand.id, Event_Edition_Pool__c = 'WOC');
        insert oEventseries;

        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017', Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information', Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = 'Space Only', Expocad_API_Url__c = 'test.com', Part_of_Series__c = oEventseries.id, Start_Date__c = Date.today(), Booth_Classes_on_Template__c = 'Temp', Corner_Configuration_Check__c = false, Product_Type_Order__c = 'BoothA;;BoothB');
        insert oEvent;
        Test.startTest();
        Opportunity opp1 = new opportunity (name = 'OpportunityTest' , closeDate = Date.Today(), StageName = 'Qualification' , Milestone_1_Amount__c = 3 , Milestone_2_Amount__c = 2 , Milestone_3_Amount__c = 2 , Milestone_4_Amount__c = 2 , Milestone_5_Amount__c = 2 , Milestone_6_Amount__c = 2 , Milestone_7_Amount__c = 2 , Milestone_8_Amount__c = 2 , Milestone_9_Amount__c = 2 , Milestone_10_Amount__c = 2 , Milestone_11_Amount__c = 2 , Milestone_12_Amount__c = 2 ,  Amount = 1000 , AccountId = oacc.id , Total_No_of_payment__c = 5 , Start_Date__c = Date.newInstance(2018, 3, 3) , Custom_Payment__c = true, EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id);
        insert opp1;
        opp1.Total_No_of_payment__c = 8;
        opp1.Milestone_8_Amount__c = 8;
        update opp1;
        system.assertEquals('World of Concrete 2017', oEvent.Name, true) ;
        Test.stopTest();
    }
    static testMethod void updateQuoteStatusTest8() {
        Account oacc = new Account (Name = 'testAccount',BillingCountryCode='US');
        insert oacc ;
        Brand__c oBrand = new Brand__c(Name = 'World of Concrete', SSC_Email_Distribution_ID__c = 'test@test.tst');
        insert oBrand;
        Trigger__c trig = new Trigger__c(Name = 'UpdateQuoteStatus' , Trigger_Name_Unique__c = 'UpdateQuoteStatus', Enabled__c = true, Object__c = 'Opportunity', Run_for_Recordypes__c = 'All',  Description__c = 'my test', Execution_Order__c = 1, Before_Update__c = true, After_Update__c = true );
        Insert trig;
        Trigger_Recordtype__c rt = new Trigger_Recordtype__c(Enabled__c=true,Recordtype_Id__c=trig.Id,Trigger__c=trig.Id,Parameters__c='param=1;param=2');
        Insert rt;
        TriggerInterface_Opp obj=new TriggerInterface_Opp();
        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Brand__c = oBrand.id, Event_Edition_Pool__c = 'WOC');
        insert oEventseries;

        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017', Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information', Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = 'Space Only', Expocad_API_Url__c = 'test.com', Part_of_Series__c = oEventseries.id, Booth_Classes_on_Template__c = 'Temp', Start_Date__c = Date.today(), Corner_Configuration_Check__c = false, Product_Type_Order__c = 'BoothA;;BoothB');
        insert oEvent;
        Test.startTest();
        Opportunity opp1 = new opportunity (name = 'OpportunityTest' , closeDate = Date.Today(), StageName = 'Qualification' , Milestone_1_Amount__c = 3 , Milestone_2_Amount__c = 2 , Milestone_3_Amount__c = 2 , Milestone_4_Amount__c = 2 , Milestone_5_Amount__c = 2 , Milestone_6_Amount__c = 2 , Milestone_7_Amount__c = 2 , Milestone_8_Amount__c = 2 , Milestone_9_Amount__c = 2 , Milestone_10_Amount__c = 2 , Milestone_11_Amount__c = 2 , Milestone_12_Amount__c = 2 ,   Amount = 1000 , AccountId = oacc.id , Total_No_of_payment__c = 5 , Start_Date__c = Date.newInstance(2018, 3, 3), Custom_Payment__c = true, EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id);
        insert opp1;
        opp1.Total_No_of_payment__c = 9;
        opp1.Milestone_9_Amount__c = 9;
        update opp1;
        system.assertEquals('World of Concrete 2017', oEvent.Name, true) ;
        Test.stopTest();
    }
    static testMethod void updateQuoteStatusTest9() {
        Account oacc = new Account (Name = 'testAccount',BillingCountryCode='US');
        insert oacc ;
        Trigger__c trig = new Trigger__c(Name = 'UpdateQuoteStatus' , Trigger_Name_Unique__c = 'UpdateQuoteStatus', Enabled__c = true, Object__c = 'Opportunity', Run_for_Recordypes__c = 'All',  Description__c = 'my test', Execution_Order__c = 1, Before_Update__c = true, After_Update__c = true );
        Insert trig;
        Trigger_Recordtype__c rt = new Trigger_Recordtype__c(Enabled__c=true,Recordtype_Id__c=trig.Id,Trigger__c=trig.Id,Parameters__c='param=1;param=2');
        Insert rt;
        TriggerInterface_Opp obj=new TriggerInterface_Opp();
        Brand__c oBrand = new Brand__c(Name = 'World of Concrete', SSC_Email_Distribution_ID__c = 'test@test.tst');
        insert oBrand;

        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Brand__c = oBrand.id, Event_Edition_Pool__c = 'WOC');
        insert oEventseries;

        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017', Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information', Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = 'Space Only', Expocad_API_Url__c = 'test.com', Part_of_Series__c = oEventseries.id, Booth_Classes_on_Template__c = 'Temp', Start_Date__c = Date.today(), Corner_Configuration_Check__c = false, Product_Type_Order__c = 'BoothA;;BoothB');
        insert oEvent;

        Test.startTest();
        Opportunity opp1 = new opportunity (name = 'OpportunityTest' , closeDate = Date.Today(), StageName = 'Qualification' , Milestone_1_Amount__c = 3 , Milestone_2_Amount__c = 2 , Milestone_3_Amount__c = 2 , Milestone_4_Amount__c = 2 , Milestone_5_Amount__c = 2 , Milestone_6_Amount__c = 2 , Milestone_7_Amount__c = 2 , Milestone_8_Amount__c = 2 , Milestone_9_Amount__c = 2 , Milestone_10_Amount__c = 2 , Milestone_11_Amount__c = 2 , Milestone_12_Amount__c = 2 ,  Amount = 1000 , AccountId = oacc.id , Total_No_of_payment__c = 5  , Start_Date__c = Date.newInstance(2018, 3, 3), Custom_Payment__c = true, EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id);
        insert opp1;
        opp1.Total_No_of_payment__c = 10;
        opp1.Milestone_10_Amount__c = 10;
        update opp1;
        system.assertEquals('World of Concrete 2017', oEvent.Name, true) ;
        Test.stopTest();
    }
    static testMethod void updateQuoteStatusTest01() {
        Account oacc = new Account (Name = 'testAccount',BillingCountryCode='US');
        insert oacc ;
        Trigger__c trig = new Trigger__c(Name = 'UpdateQuoteStatus' , Trigger_Name_Unique__c = 'UpdateQuoteStatus', Enabled__c = true, Object__c = 'Opportunity', Run_for_Recordypes__c = 'All',  Description__c = 'my test', Execution_Order__c = 1, Before_Update__c = true, After_Update__c = true );
        Insert trig;
        Trigger_Recordtype__c rt = new Trigger_Recordtype__c(Enabled__c=true,Recordtype_Id__c=trig.Id,Trigger__c=trig.Id,Parameters__c='param=1;param=2');
        Insert rt;
        TriggerInterface_Opp obj=new TriggerInterface_Opp();
        Brand__c oBrand = new Brand__c(Name = 'World of Concrete', SSC_Email_Distribution_ID__c = 'test@test.tst');
        insert oBrand;

        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Brand__c = oBrand.id, Event_Edition_Pool__c = 'WOC');
        insert oEventseries;

        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017', Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information', Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = 'Space Only', Expocad_API_Url__c = 'test.com', Part_of_Series__c = oEventseries.id, Booth_Classes_on_Template__c = 'Temp', Start_Date__c = Date.today(), Corner_Configuration_Check__c = false, Product_Type_Order__c = 'BoothA;;BoothB');
        insert oEvent;

        Test.startTest();
        Opportunity opp1 = new opportunity (name = 'OpportunityTest' , closeDate = Date.Today(), StageName = 'Qualification' , Milestone_1_Amount__c = 3 , Milestone_2_Amount__c = 2 , Milestone_3_Amount__c = 2 , Milestone_4_Amount__c = 2 , Milestone_5_Amount__c = 2 , Milestone_6_Amount__c = 2 , Milestone_7_Amount__c = 2 , Milestone_8_Amount__c = 2 , Milestone_9_Amount__c = 2 , Milestone_10_Amount__c = 2 , Milestone_11_Amount__c = 2 , Milestone_12_Amount__c = 2 ,  Amount = 1000 , AccountId = oacc.id , Total_No_of_payment__c = 5 , Start_Date__c = Date.newInstance(2018, 3, 3) , Custom_Payment__c = true, EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id);
        insert opp1;
        opp1.Total_No_of_payment__c = 1;
        opp1.Milestone_1_Amount__c = 10;
        update opp1;
        system.assertEquals('World of Concrete 2017', oEvent.Name, true) ;
        Test.stopTest();
    }
    static testMethod void updateQuoteStatusTest02() {
        Account oacc = new Account (Name = 'testAccount',BillingCountryCode='US');
        insert oacc ;
        Trigger__c trig = new Trigger__c(Name = 'UpdateQuoteStatus' , Trigger_Name_Unique__c = 'UpdateQuoteStatus', Enabled__c = true, Object__c = 'Opportunity', Run_for_Recordypes__c = 'All',  Description__c = 'my test', Execution_Order__c = 1, Before_Update__c = true, After_Update__c = true );
        Insert trig;
        Trigger_Recordtype__c rt = new Trigger_Recordtype__c(Enabled__c=true,Recordtype_Id__c=trig.Id,Trigger__c=trig.Id,Parameters__c='param=1;param=2');
        Insert rt;
        TriggerInterface_Opp obj=new TriggerInterface_Opp();
        Brand__c oBrand = new Brand__c(Name = 'World of Concrete', SSC_Email_Distribution_ID__c = 'test@test.tst');
        insert oBrand;

        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Brand__c = oBrand.id, Event_Edition_Pool__c = 'WOC');
        insert oEventseries;

        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017', Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information', Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = 'Space Only', Expocad_API_Url__c = 'test.com', Part_of_Series__c = oEventseries.id, Booth_Classes_on_Template__c = 'Temp', Start_Date__c = Date.today(), Corner_Configuration_Check__c = false, Product_Type_Order__c = 'BoothA;;BoothB');
        insert oEvent;

        Test.startTest();
        Opportunity opp1 = new opportunity (name = 'OpportunityTest' , closeDate = Date.Today(), StageName = 'Qualification' , Milestone_1_Amount__c = 3 , Milestone_2_Amount__c = 2 , Milestone_3_Amount__c = 2 , Milestone_4_Amount__c = 2 , Milestone_5_Amount__c = 2 , Milestone_6_Amount__c = 2 , Milestone_7_Amount__c = 2 , Milestone_8_Amount__c = 2 , Milestone_9_Amount__c = 2 , Milestone_10_Amount__c = 2 , Milestone_11_Amount__c = 2 , Milestone_12_Amount__c = 2 ,  Amount = 1000 , AccountId = oacc.id , Total_No_of_payment__c = 5 , Start_Date__c = Date.newInstance(2018, 3, 3) , Custom_Payment__c = true, EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id);
        insert opp1;
        opp1.Total_No_of_payment__c = 2;
        opp1.Milestone_2_Amount__c = 10;
        update opp1;
        system.assertEquals('World of Concrete 2017', oEvent.Name, true) ;
        Test.stopTest();
    }
    static testMethod void updateQuoteStatusTest11() {
        Account oacc = new Account (Name = 'testAccount',BillingCountryCode='US');
        insert oacc ;

        Brand__c oBrand = new Brand__c(Name = 'World of Concrete', SSC_Email_Distribution_ID__c = 'test@test.tst');
        insert oBrand;
        Trigger__c trig = new Trigger__c(Name = 'UpdateQuoteStatus' , Trigger_Name_Unique__c = 'UpdateQuoteStatus', Enabled__c = true, Object__c = 'Opportunity', Run_for_Recordypes__c = 'All',  Description__c = 'my test', Execution_Order__c = 1, Before_Update__c = true, After_Update__c = true );
        Insert trig;
        Trigger_Recordtype__c rt = new Trigger_Recordtype__c(Enabled__c=true,Recordtype_Id__c=trig.Id,Trigger__c=trig.Id,Parameters__c='param=1;param=2');
        Insert rt;
        TriggerInterface_Opp obj=new TriggerInterface_Opp();
        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Brand__c = oBrand.id, Event_Edition_Pool__c = 'WOC');
        insert oEventseries;

        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017', Start_Date__c = Date.today(), Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information', Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = 'Space Only', Expocad_API_Url__c = 'test.com', Part_of_Series__c = oEventseries.id, Booth_Classes_on_Template__c = 'Temp', Corner_Configuration_Check__c = false, Product_Type_Order__c = 'BoothA;;BoothB');
        insert oEvent;

        Test.startTest();
        Opportunity opp1 = new opportunity (name = 'OpportunityTest' , closeDate = Date.Today(), StageName = 'Qualification' , Milestone_1_Amount__c = 3 , Milestone_2_Amount__c = 2 , Milestone_3_Amount__c = 2 , Milestone_4_Amount__c = 2 , Milestone_5_Amount__c = 2 , Milestone_6_Amount__c = 2 , Milestone_7_Amount__c = 2 , Milestone_8_Amount__c = 2 , Milestone_9_Amount__c = 2 , Milestone_10_Amount__c = 2 , Milestone_11_Amount__c = 2 , Milestone_12_Amount__c = 2 ,   Amount = 1000 , AccountId = oacc.id , Total_No_of_payment__c = 5 , Start_Date__c = Date.newInstance(2018, 3, 3), Custom_Payment__c = true, EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id);
        insert opp1;
        opp1.Total_No_of_payment__c = 11;
        opp1.Milestone_11_Amount__c = 11;
        update opp1;
        system.assertEquals('World of Concrete 2017', oEvent.Name, true) ;
        Test.stopTest();
    }
    static testMethod void updateQuoteStatusTest12() {
        Account oacc = new Account (Name = 'testAccount',BillingCountryCode='US');
        insert oacc ;
        Trigger__c trig = new Trigger__c(Name = 'UpdateQuoteStatus' , Trigger_Name_Unique__c = 'UpdateQuoteStatus', Enabled__c = true, Object__c = 'Opportunity', Run_for_Recordypes__c = 'All',  Description__c = 'my test', Execution_Order__c = 1, Before_Update__c = true, After_Update__c = true );
        Insert trig;
        Trigger_Recordtype__c rt = new Trigger_Recordtype__c(Enabled__c=true,Recordtype_Id__c=trig.Id,Trigger__c=trig.Id,Parameters__c='param=1;param=2');
        Insert rt;
        TriggerInterface_Opp obj=new TriggerInterface_Opp();
        Brand__c oBrand = new Brand__c(Name = 'World of Concrete', SSC_Email_Distribution_ID__c = 'test@test.tst');
        insert oBrand;

        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Brand__c = oBrand.id, Event_Edition_Pool__c = 'WOC');
        insert oEventseries;

        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017', Start_Date__c = Date.today(), Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information', Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = 'Space Only', Expocad_API_Url__c = 'test.com', Part_of_Series__c = oEventseries.id, Booth_Classes_on_Template__c = 'Temp', Corner_Configuration_Check__c = false, Product_Type_Order__c = 'BoothA;;BoothB');
        insert oEvent;

        Test.startTest();
        Account acc = [Select id,BillingCountryCode from Account where id =: oacc.Id];
        system.debug('acc'+acc);
        Opportunity opp1 = new opportunity (name = 'OpportunityTest' , closeDate = Date.Today(), StageName = 'Qualification' , Milestone_1_Amount__c = 3 , Milestone_2_Amount__c = 2 , Milestone_3_Amount__c = 2 , Milestone_4_Amount__c = 2 , Milestone_5_Amount__c = 2 , Milestone_6_Amount__c = 2 , Milestone_7_Amount__c = 2 , Milestone_8_Amount__c = 2 , Milestone_9_Amount__c = 2 , Milestone_10_Amount__c = 2 , Milestone_11_Amount__c = 2 , Milestone_12_Amount__c = 2 ,   Amount = 1000 , AccountId = oacc.id , Total_No_of_payment__c = 5 , Start_Date__c = Date.newInstance(2018, 3, 3) , Custom_Payment__c = true, EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id);
        insert opp1;
        opp1.Total_No_of_payment__c = 12;
        opp1.Milestone_12_Amount__c = 12;
        opp1.StageName = 'Closed Won';
        update opp1;
        system.assertEquals('World of Concrete 2017', oEvent.Name, true) ;
        Test.stopTest();
    }
    static testMethod void updateQuoteStatusTest13() {
        Account oacc = new Account (Name = 'testAccount',BillingCountryCode='US');
        insert oacc ;
        Trigger__c trig = new Trigger__c(Name = 'UpdateQuoteStatus' , Trigger_Name_Unique__c = 'UpdateQuoteStatus', Enabled__c = true, Object__c = 'Opportunity', Run_for_Recordypes__c = 'All',  Description__c = 'my test', Execution_Order__c = 1, Before_Update__c = true, After_Update__c = true );
        Insert trig;
        Trigger_Recordtype__c rt = new Trigger_Recordtype__c(Enabled__c=true,Recordtype_Id__c=trig.Id,Trigger__c=trig.Id,Parameters__c='param=1;param=2');
        Insert rt;
        TriggerInterface_Opp obj=new TriggerInterface_Opp();
        Brand__c oBrand = new Brand__c(Name = 'World of Concrete', SSC_Email_Distribution_ID__c = 'test@test.tst');
        insert oBrand;

        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Brand__c = oBrand.id, Event_Edition_Pool__c = 'WOC');
        insert oEventseries;

        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017', Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information', Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = 'Space Only', Expocad_API_Url__c = 'test.com', Part_of_Series__c = oEventseries.id, Booth_Classes_on_Template__c = 'Temp', Corner_Configuration_Check__c = false, Product_Type_Order__c = 'BoothA;;BoothB');
        insert oEvent;

        Opportunity opp1 = new opportunity (name = 'OpportunityTest' , closeDate = Date.Today(), StageName = 'Qualification' , Milestone_1_Amount__c = 3 , Milestone_2_Amount__c = 2 , Milestone_3_Amount__c = 2 , Milestone_4_Amount__c = 2 , Milestone_5_Amount__c = 2 , Milestone_6_Amount__c = 2 , Milestone_7_Amount__c = 2 , Milestone_8_Amount__c = 2 , Milestone_9_Amount__c = 2 , Milestone_10_Amount__c = 2 , Milestone_11_Amount__c = 2 , Milestone_12_Amount__c = 2 ,   Amount = 1000 , AccountId = oacc.id , Total_No_of_payment__c = 12 , Start_Date__c = Date.today() , Custom_Payment__c = true, EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id);
        insert opp1;
        opp1.Milestone_1_Amount__c = 12;
        opp1.Total_No_of_payment__c = 12;
        update opp1;
        system.assertEquals('World of Concrete 2017', oEvent.Name, true) ;
    }
    static testMethod void updateQuoteStatusTest14() {
        Account oacc = new Account (Name = 'testAccount',BillingCountryCode='US');
        insert oacc ;
        Trigger__c trig = new Trigger__c(Name = 'UpdateQuoteStatus' , Trigger_Name_Unique__c = 'UpdateQuoteStatus', Enabled__c = true, Object__c = 'Opportunity', Run_for_Recordypes__c = 'All',  Description__c = 'my test', Execution_Order__c = 1, Before_Update__c = true, After_Update__c = true );
        Insert trig;
        Trigger_Recordtype__c rt = new Trigger_Recordtype__c(Enabled__c=true,Recordtype_Id__c=trig.Id,Trigger__c=trig.Id,Parameters__c='param=1;param=2');
        Insert rt;
        TriggerInterface_Opp obj=new TriggerInterface_Opp();
        Brand__c oBrand = new Brand__c(Name = 'World of Concrete', SSC_Email_Distribution_ID__c = 'test@test.tst');
        insert oBrand;

        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Brand__c = oBrand.id, Event_Edition_Pool__c = 'WOC');
        insert oEventseries;

        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017', Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information', Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = 'Space Only', Expocad_API_Url__c = 'test.com', Part_of_Series__c = oEventseries.id, Booth_Classes_on_Template__c = 'Temp', Corner_Configuration_Check__c = false, Product_Type_Order__c = 'BoothA;;BoothB');
        insert oEvent;

        Opportunity opp1 = new opportunity (name = 'OpportunityTest' , closeDate = Date.Today(), StageName = 'Qualification' , Milestone_1_Amount__c = 3 , Milestone_2_Amount__c = 2 , Milestone_3_Amount__c = 2 , Milestone_4_Amount__c = 2 , Milestone_5_Amount__c = 2 , Milestone_6_Amount__c = 2 , Milestone_7_Amount__c = 2 , Milestone_8_Amount__c = 2 , Milestone_9_Amount__c = 2 , Milestone_10_Amount__c = 2 , Milestone_11_Amount__c = 2 , Milestone_12_Amount__c = 2 ,   Amount = 1000 , AccountId = oacc.id , Total_No_of_payment__c = 11, Start_Date__c = Date.today() , Custom_Payment__c = true, EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id);
        insert opp1;
        opp1.Milestone_2_Amount__c = 11;
        opp1.Total_No_of_payment__c = 11;
        update opp1;
        system.assertEquals('World of Concrete 2017', oEvent.Name, true) ;
    }
    static testMethod void updateQuoteStatusTest15() {
        Account oacc = new Account (Name = 'testAccount',BillingCountryCode='US');
        insert oacc ;
        Trigger__c trig = new Trigger__c(Name = 'UpdateQuoteStatus' , Trigger_Name_Unique__c = 'UpdateQuoteStatus', Enabled__c = true, Object__c = 'Opportunity', Run_for_Recordypes__c = 'All',  Description__c = 'my test', Execution_Order__c = 1, Before_Update__c = true, After_Update__c = true );
        Insert trig;
        Trigger_Recordtype__c rt = new Trigger_Recordtype__c(Enabled__c=true,Recordtype_Id__c=trig.Id,Trigger__c=trig.Id,Parameters__c='param=1;param=2');
        Insert rt;
        TriggerInterface_Opp obj=new TriggerInterface_Opp();
        Brand__c oBrand = new Brand__c(Name = 'World of Concrete', SSC_Email_Distribution_ID__c = 'test@test.tst');
        insert oBrand;

        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Brand__c = oBrand.id, Event_Edition_Pool__c = 'WOC');
        insert oEventseries;

        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017', Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information', Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = 'Space Only', Expocad_API_Url__c = 'test.com', Part_of_Series__c = oEventseries.id, Booth_Classes_on_Template__c = 'Temp', Corner_Configuration_Check__c = false, Product_Type_Order__c = 'BoothA;;BoothB');
        insert oEvent;

        Opportunity opp1 = new opportunity (name = 'OpportunityTest' , closeDate = Date.Today(), StageName = 'Qualification' , Milestone_1_Amount__c = 3 , Milestone_2_Amount__c = 2 , Milestone_3_Amount__c = 2 , Milestone_4_Amount__c = 2 , Milestone_5_Amount__c = 2 , Milestone_6_Amount__c = 2 , Milestone_7_Amount__c = 2 , Milestone_8_Amount__c = 2 , Milestone_9_Amount__c = 2 , Milestone_10_Amount__c = 2 , Milestone_11_Amount__c = 2 , Milestone_12_Amount__c = 2 ,   Amount = 1000 , AccountId = oacc.id , Total_No_of_payment__c = 10, Start_Date__c = Date.today() , Custom_Payment__c = true, EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id);
        insert opp1;
        opp1.Milestone_3_Amount__c = 11;
        opp1.Total_No_of_payment__c = 10;
        update opp1;
        system.assertEquals('World of Concrete 2017', oEvent.Name, true) ;
    }
    static testMethod void updateQuoteStatusTest16() {
        Account oacc = new Account (Name = 'testAccount',BillingCountryCode='US');
        insert oacc ;

        Brand__c oBrand = new Brand__c(Name = 'World of Concrete', SSC_Email_Distribution_ID__c = 'test@test.tst');
        insert oBrand;
        Trigger__c trig = new Trigger__c(Name = 'UpdateQuoteStatus' , Trigger_Name_Unique__c = 'UpdateQuoteStatus', Enabled__c = true, Object__c = 'Opportunity', Run_for_Recordypes__c = 'All',  Description__c = 'my test', Execution_Order__c = 1, Before_Update__c = true, After_Update__c = true );
        Insert trig;
        Trigger_Recordtype__c rt = new Trigger_Recordtype__c(Enabled__c=true,Recordtype_Id__c=trig.Id,Trigger__c=trig.Id,Parameters__c='param=1;param=2');
        Insert rt;
        TriggerInterface_Opp obj=new TriggerInterface_Opp();
        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Brand__c = oBrand.id, Event_Edition_Pool__c = 'WOC');
        insert oEventseries;

        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017', Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information', Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = 'Space Only', Expocad_API_Url__c = 'test.com', Part_of_Series__c = oEventseries.id, Booth_Classes_on_Template__c = 'Temp', Corner_Configuration_Check__c = false, Product_Type_Order__c = 'BoothA;;BoothB');
        insert oEvent;

        Opportunity opp1 = new opportunity (name = 'OpportunityTest' , closeDate = Date.Today(), StageName = 'Qualification' , Milestone_1_Amount__c = 3 , Milestone_2_Amount__c = 2 , Milestone_3_Amount__c = 2 , Milestone_4_Amount__c = 2 , Milestone_5_Amount__c = 2 , Milestone_6_Amount__c = 2 , Milestone_7_Amount__c = 2 , Milestone_8_Amount__c = 2 , Milestone_9_Amount__c = 2 , Milestone_10_Amount__c = 2 , Milestone_11_Amount__c = 2 , Milestone_12_Amount__c = 2 ,   Amount = 1000 , AccountId = oacc.id , Total_No_of_payment__c = 5, Start_Date__c = Date.today() , Custom_Payment__c = true, EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id);
        insert opp1;
        opp1.Milestone_4_Amount__c = 11;
        opp1.Total_No_of_payment__c = 5;
        update opp1;
        system.assertEquals('World of Concrete 2017', oEvent.Name, true) ;
    }
    static testMethod void updateQuoteStatusTest17() {
        Account oacc = new Account (Name = 'testAccount',BillingCountryCode='US');
        insert oacc ;
        Trigger__c trig = new Trigger__c(Name = 'UpdateQuoteStatus' , Trigger_Name_Unique__c = 'UpdateQuoteStatus', Enabled__c = true, Object__c = 'Opportunity', Run_for_Recordypes__c = 'All',  Description__c = 'my test', Execution_Order__c = 1, Before_Update__c = true, After_Update__c = true );
        Insert trig;
        Trigger_Recordtype__c rt = new Trigger_Recordtype__c(Enabled__c=true,Recordtype_Id__c=trig.Id,Trigger__c=trig.Id,Parameters__c='param=1;param=2');
        Insert rt;
        TriggerInterface_Opp obj=new TriggerInterface_Opp();
        Brand__c oBrand = new Brand__c(Name = 'World of Concrete', SSC_Email_Distribution_ID__c = 'test@test.tst');
        insert oBrand;

        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Brand__c = oBrand.id, Event_Edition_Pool__c = 'WOC');
        insert oEventseries;

        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017', Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information', Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = 'Space Only', Expocad_API_Url__c = 'test.com', Part_of_Series__c = oEventseries.id, Booth_Classes_on_Template__c = 'Temp', Corner_Configuration_Check__c = false, Product_Type_Order__c = 'BoothA;;BoothB');
        insert oEvent;

        Opportunity opp1 = new opportunity (name = 'OpportunityTest' , closeDate = Date.Today(), StageName = 'Qualification' , Milestone_1_Amount__c = 3 , Milestone_2_Amount__c = 2 , Milestone_3_Amount__c = 2 , Milestone_4_Amount__c = 2 , Milestone_5_Amount__c = 2 , Milestone_6_Amount__c = 2 , Milestone_7_Amount__c = 2 , Milestone_8_Amount__c = 2 , Milestone_9_Amount__c = 2 , Milestone_10_Amount__c = 2 , Milestone_11_Amount__c = 2 , Milestone_12_Amount__c = 2 ,   Amount = 1000 , AccountId = oacc.id , Total_No_of_payment__c = 6, Start_Date__c = Date.today() , Custom_Payment__c = true, EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id);
        insert opp1;
        opp1.Milestone_5_Amount__c = 11;
        opp1.Total_No_of_payment__c = 6;
        update opp1;
        system.assertEquals('World of Concrete 2017', oEvent.Name, true) ;
    }
    static testMethod void updateQuoteStatusTest18() {
        Account oacc = new Account (Name = 'testAccount',BillingCountryCode='US');
        insert oacc ;

        Brand__c oBrand = new Brand__c(Name = 'World of Concrete', SSC_Email_Distribution_ID__c = 'test@test.tst');
        insert oBrand;

        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Brand__c = oBrand.id, Event_Edition_Pool__c = 'WOC');
        insert oEventseries;
        Trigger__c trig = new Trigger__c(Name = 'UpdateQuoteStatus' , Trigger_Name_Unique__c = 'UpdateQuoteStatus', Enabled__c = true, Object__c = 'Opportunity', Run_for_Recordypes__c = 'All',  Description__c = 'my test', Execution_Order__c = 1, Before_Update__c = true, After_Update__c = true );
        Insert trig;
        Trigger_Recordtype__c rt = new Trigger_Recordtype__c(Enabled__c=true,Recordtype_Id__c=trig.Id,Trigger__c=trig.Id,Parameters__c='param=1;param=2');
        Insert rt;
        TriggerInterface_Opp obj=new TriggerInterface_Opp();
        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017', Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information', Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = 'Space Only', Expocad_API_Url__c = 'test.com', Part_of_Series__c = oEventseries.id, Booth_Classes_on_Template__c = 'Temp', Corner_Configuration_Check__c = false, Product_Type_Order__c = 'BoothA;;BoothB');
        insert oEvent;

        Opportunity opp1 = new opportunity (name = 'OpportunityTest' , closeDate = Date.Today(), StageName = 'Qualification' , Milestone_1_Amount__c = 3 , Milestone_2_Amount__c = 2 , Milestone_3_Amount__c = 2 , Milestone_4_Amount__c = 2 , Milestone_5_Amount__c = 2 , Milestone_6_Amount__c = 2 , Milestone_7_Amount__c = 2 , Milestone_8_Amount__c = 2 , Milestone_9_Amount__c = 2 , Milestone_10_Amount__c = 2 , Milestone_11_Amount__c = 2 , Milestone_12_Amount__c = 2 ,   Amount = 1000 , AccountId = oacc.id , Total_No_of_payment__c = 7, Start_Date__c = Date.today() , Custom_Payment__c = true, EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id);
        insert opp1;
        opp1.Milestone_6_Amount__c = 11;
        opp1.Total_No_of_payment__c = 7;
        update opp1;
        system.assertEquals('World of Concrete 2017', oEvent.Name, true) ;
    }
    static testMethod void updateQuoteStatusTest19() {
        Account oacc = new Account (Name = 'testAccount',BillingCountryCode='US');
        insert oacc ;

        Brand__c oBrand = new Brand__c(Name = 'World of Concrete', SSC_Email_Distribution_ID__c = 'test@test.tst');
        insert oBrand;

        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Brand__c = oBrand.id, Event_Edition_Pool__c = 'WOC');
        insert oEventseries;
        Trigger__c trig = new Trigger__c(Name = 'UpdateQuoteStatus' , Trigger_Name_Unique__c = 'UpdateQuoteStatus', Enabled__c = true, Object__c = 'Opportunity', Run_for_Recordypes__c = 'All',  Description__c = 'my test', Execution_Order__c = 1, Before_Update__c = true, After_Update__c = true );
        Insert trig;
        Trigger_Recordtype__c rt = new Trigger_Recordtype__c(Enabled__c=true,Recordtype_Id__c=trig.Id,Trigger__c=trig.Id,Parameters__c='param=1;param=2');
        Insert rt;
        TriggerInterface_Opp obj=new TriggerInterface_Opp();
        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017', Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information', Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = 'Space Only', Expocad_API_Url__c = 'test.com', Part_of_Series__c = oEventseries.id, Booth_Classes_on_Template__c = 'Temp', Corner_Configuration_Check__c = false, Product_Type_Order__c = 'BoothA;;BoothB');
        insert oEvent;

        Opportunity opp1 = new opportunity (name = 'OpportunityTest' , closeDate = Date.Today(), StageName = 'Qualification' , Milestone_1_Amount__c = 3 , Milestone_2_Amount__c = 2 , Milestone_3_Amount__c = 2 , Milestone_4_Amount__c = 2 , Milestone_5_Amount__c = 2 , Milestone_6_Amount__c = 2 , Milestone_7_Amount__c = 2 , Milestone_8_Amount__c = 2 , Milestone_9_Amount__c = 2 , Milestone_10_Amount__c = 2 , Milestone_11_Amount__c = 2 , Milestone_12_Amount__c = 2 ,   Amount = 1000 , AccountId = oacc.id , Total_No_of_payment__c = 8, Start_Date__c = Date.today() , Custom_Payment__c = true, EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id);
        insert opp1;
        opp1.Milestone_7_Amount__c = 11;
        opp1.Total_No_of_payment__c = 8;
        update opp1;
        system.assertEquals('World of Concrete 2017', oEvent.Name, true) ;
    }
    static testMethod void updateQuoteStatusTest20() {
        Account oacc = new Account (Name = 'testAccount',BillingCountryCode='US');
        insert oacc ;

        Brand__c oBrand = new Brand__c(Name = 'World of Concrete', SSC_Email_Distribution_ID__c = 'test@test.tst');
        insert oBrand;
        Trigger__c trig = new Trigger__c(Name = 'UpdateQuoteStatus' , Trigger_Name_Unique__c = 'UpdateQuoteStatus', Enabled__c = true, Object__c = 'Opportunity', Run_for_Recordypes__c = 'All',  Description__c = 'my test', Execution_Order__c = 1, Before_Update__c = true );
        Insert trig;
        Trigger_Recordtype__c rt = new Trigger_Recordtype__c(Enabled__c=true,Recordtype_Id__c=trig.Id,Trigger__c=trig.Id,Parameters__c='param=1;param=2');
        Insert rt;
        TriggerInterface_Opp obj=new TriggerInterface_Opp();
        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Brand__c = oBrand.id, Event_Edition_Pool__c = 'WOC');
        insert oEventseries;

        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017', Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information', Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = 'Space Only', Expocad_API_Url__c = 'test.com', Part_of_Series__c = oEventseries.id, Booth_Classes_on_Template__c = 'Temp', Corner_Configuration_Check__c = false, Product_Type_Order__c = 'BoothA;;BoothB');
        insert oEvent;

        Opportunity opp1 = new opportunity (name = 'OpportunityTest' , closeDate = Date.Today(), StageName = 'Qualification' , Milestone_1_Amount__c = 3 , Milestone_2_Amount__c = 2 , Milestone_3_Amount__c = 2 , Milestone_4_Amount__c = 2 , Milestone_5_Amount__c = 2 , Milestone_6_Amount__c = 2 , Milestone_7_Amount__c = 2 , Milestone_8_Amount__c = 2 , Milestone_9_Amount__c = 2 , Milestone_10_Amount__c = 2 , Milestone_11_Amount__c = 2 , Milestone_12_Amount__c = 2 ,   Amount = 1000 , AccountId = oacc.id , Total_No_of_payment__c = 9, Start_Date__c = Date.today() , Custom_Payment__c = true, EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id);
        insert opp1;
        opp1.Milestone_8_Amount__c = 11;
        opp1.Total_No_of_payment__c = 9;
        update opp1;
        system.assertEquals('World of Concrete 2017', oEvent.Name, true) ;
    }

    static testMethod void updateQuoteStatusTest21() {
        Account oacc = new Account (Name = 'testAccount',BillingCountryCode='US');
        insert oacc ;
        Trigger__c trig = new Trigger__c(Name = 'UpdateQuoteStatus' , Trigger_Name_Unique__c = 'UpdateQuoteStatus', Enabled__c = true, Object__c = 'Opportunity', Run_for_Recordypes__c = 'All',  Description__c = 'my test', Execution_Order__c = 1, Before_Update__c = true, After_Update__c = true );
        Insert trig;
        Trigger_Recordtype__c rt = new Trigger_Recordtype__c(Enabled__c=true,Recordtype_Id__c=trig.Id,Trigger__c=trig.Id,Parameters__c='param=1;param=2');
        Insert rt;
        TriggerInterface_Opp obj=new TriggerInterface_Opp();
        Brand__c oBrand = new Brand__c(Name = 'World of Concrete', SSC_Email_Distribution_ID__c = 'test@test.tst');
        insert oBrand;

        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Brand__c = oBrand.id, Event_Edition_Pool__c = 'WOC');
        insert oEventseries;

        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017', Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information', Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = 'Space Only', Expocad_API_Url__c = 'test.com', Part_of_Series__c = oEventseries.id, Booth_Classes_on_Template__c = 'Temp', Corner_Configuration_Check__c = false, Product_Type_Order__c = 'BoothA;;BoothB');
        insert oEvent;

        Opportunity opp1 = new opportunity (name = 'OpportunityTest' , closeDate = Date.Today(), StageName = 'Qualification' , Milestone_1_Amount__c = 3 , Milestone_2_Amount__c = 2 , Milestone_3_Amount__c = 2 , Milestone_4_Amount__c = 2 , Milestone_5_Amount__c = 2 , Milestone_6_Amount__c = 2 , Milestone_7_Amount__c = 2 , Milestone_8_Amount__c = 2 , Milestone_9_Amount__c = 2 , Milestone_10_Amount__c = 2 , Milestone_11_Amount__c = 2 , Milestone_12_Amount__c = 2 ,   Amount = 1000 , AccountId = oacc.id , Total_No_of_payment__c = 9, Start_Date__c = Date.today() , Custom_Payment__c = true , Payment_Status__c = 'Invoice', EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id) ;
        insert opp1;
        opp1.Milestone_8_Amount__c = 11;
        opp1.Total_No_of_payment__c = 9;
        opp1.Payment_Status__c = 'Partial Paid';
        update opp1;
        system.assertEquals('World of Concrete 2017', oEvent.Name, true) ;
    }
    static testMethod void updateQuoteStatusTest22() {
        Account oacc = new Account (Name = 'testAccount',BillingCountryCode='US');
        insert oacc ;
        Trigger__c trig = new Trigger__c(Name = 'UpdateQuoteStatus' , Trigger_Name_Unique__c = 'UpdateQuoteStatus', Enabled__c = true, Object__c = 'Opportunity', Run_for_Recordypes__c = 'All',  Description__c = 'my test', Execution_Order__c = 1, Before_Update__c = true, After_Update__c = true );
        Insert trig;
        Trigger_Recordtype__c rt = new Trigger_Recordtype__c(Enabled__c=true,Recordtype_Id__c=trig.Id,Trigger__c=trig.Id,Parameters__c='param=1;param=2');
        Insert rt;
        TriggerInterface_Opp obj=new TriggerInterface_Opp();
        Brand__c oBrand = new Brand__c(Name = 'World of Concrete', SSC_Email_Distribution_ID__c = 'test@test.tst');
        insert oBrand;

        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Brand__c = oBrand.id, Event_Edition_Pool__c = 'WOC');
        insert oEventseries;

        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017', Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information', Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = 'Space Only', Expocad_API_Url__c = 'test.com', Part_of_Series__c = oEventseries.id, Booth_Classes_on_Template__c = 'Temp', Corner_Configuration_Check__c = false, Product_Type_Order__c = 'BoothA;;BoothB');
        insert oEvent;

        Opportunity opp1 = new opportunity (name = 'OpportunityTest' , closeDate = Date.Today(), StageName = 'Qualification' , Milestone_1_Amount__c = 3 , Milestone_2_Amount__c = 2 , Milestone_3_Amount__c = 2 , Milestone_4_Amount__c = 2 , Milestone_5_Amount__c = 2 , Milestone_6_Amount__c = 2 , Milestone_7_Amount__c = 2 , Milestone_8_Amount__c = 2 , Milestone_9_Amount__c = 2 , Milestone_10_Amount__c = 2 , Milestone_11_Amount__c = 2 , Milestone_12_Amount__c = 2 ,   Amount = 1000 , AccountId = oacc.id , Total_No_of_payment__c = 9, Start_Date__c = Date.today() , Custom_Payment__c = true , Payment_Status__c = 'Invoice', EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id) ;
        insert opp1;
        opp1.Milestone_9_Amount__c = 11;
        opp1.Total_No_of_payment__c = 9;
        opp1.Payment_Status__c = 'Partial Paid';
        update opp1;
        system.assertEquals('World of Concrete 2017', oEvent.Name, true) ;
    }
    
}