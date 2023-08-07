/**
* File:        releaseBooths_Test.class
* Project:     GAP
* Date:        Aug 26, 2016
* Created By:  Kumar Gaurav
* Code Coverage: (Trigger, releaseBooth, Expocad_BoothTriggerHandler : 97%)
* *************************************************************************
* Description: Test class for Trigger releaseBooth
* *************************************************************************
* History: Modified for [EX-21] on Dated-Sep 8,2022
*/

@isTest
public class ReleaseBooths_Test {
/*    @istest //EX-101
    static  void releaseBoothTest() {
        Trigger__c trig = new Trigger__c(Name = 'ReleaseBooths_Trig' , Trigger_Name_Unique__c='ReleaseBooths_Trig',Enabled__c=true,Object__c='ExpocadBooth__c',Run_for_Recordypes__c='All',  Description__c='my test',Execution_Order__c=2,
                                         After_Insert__c=true , After_Delete__c = true , Before_Insert__c = true , After_Update__c = true , After_UnDelete__c = true);
        insert trig;
        Trigger_Recordtype__c rrrt = new Trigger_Recordtype__c(Recordtype_Id__c=trig.Id , Trigger__c=trig.Id,Enabled__c=true, Parameters__c='param=1;param=2');
        Insert rrrt; 
         
        TriggerInterface_ExpocadBooth obj=new TriggerInterface_ExpocadBooth();
       
        TriggerInterfaceHelper.runTrigger('ReleaseBooths_Trig','ExpocadBooth__c', 2, 'ai', rrrt.id ,rrrt.Parameters__c,'All');
        TriggerInterfaceHelper.runTrigger('ReleaseBooths_Trig','ExpocadBooth__c', 2, 'ad', rrrt.id ,rrrt.Parameters__c,'All');
        Product2 prd1 = new Product2(Name = 'Linear Booth', Family = 'Booth', Number_of_Corners__c = 0);
        insert prd1;
        
        
        Account oAccount = new Account(Name = 'Expocad Account', CurrencyIsoCode = 'USD');
        insert oAccount;
        
        Contact oCon = new Contact(LastName = 'ContTest1', Email = 'test1contact@duptest.com', AccountId = oAccount.Id, MailingState = '', MailingCountry = 'India');
        insert oCon;
        
        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017', Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information', Payment_Schedule__c = '50-50', cutoff_date_1__c = date.today(), Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt' , Expocad_API_URL__c = 'https://expocad.api.com');
        insert oEvent;
        //[EX-131]
        oEvent.X3rd_Party_Relationship__c='3E Expocad';
        oEvent.X3E_Status__c='Active';
        oEvent.X3E_API_ID__c='22col';
        update oEvent;
        
        Opportunity oOpportunity = new Opportunity(Name = 'Expocad Opportunity',Exhibitor_Paid_By__c='Delegate Sales', CloseDate = Date.today(), StageName = 'Proposal', EventEdition__c = oEvent.Id, AccountId = oAccount.Id, Billing_Contact__c = oCon.Id , IsCreatedByReviewProcess__c = false, CurrencyIsoCode = 'USD');
        insert oOpportunity;
        
        
        SBQQ__Quote__c oQuote = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = oOpportunity.Id, SBQQ__Account__c = oAccount.Id );
        insert oQuote;
        
        SBQQ__Quote__c oQuote2 = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = oOpportunity.Id, SBQQ__Account__c = oAccount.Id );
        insert oQuote2;
        
        ExpocadBooth__c oExpocadBooth = new ExpocadBooth__c(Status__c = 'On hold', Released__c = false, Booth_Number__c = 'TESTBN2', Quote__c = oQuote2.Id, Opportunity__c = oOpportunity.Id, Booth_Product_Type_EE__c = 'Space Only', Area__c = '18 m²');
       //EX-131
      // oExpocadBooth.Primary_Contact__c=oOpportunity.Opportunity_Contact__c.Id;
        insert oExpocadBooth;
        
       
        ExpocadBooth__c oExpocadBooth1 = new ExpocadBooth__c(Status__c = 'Rented', Released__c = false, Booth_Number__c = 'TESTBN2325', Quote__c = oQuote.Id, Opportunity__c = oOpportunity.Id, Booth_Product_Type_EE__c = 'Space Only' , Area__c = '18 m²',Display_Name__c= oAccount.Name);
        insert oExpocadBooth1;
        
        oExpocadBooth.Status__c = 'Released';
        update oExpocadBooth;
        oExpocadBooth.Status__c = 'Rented';
        update oExpocadBooth;
        //[EX-131]
        List<Id> lstOpptyIds = new List<Id>();
        Map<Id, Opportunity> mapOppty = new Map<Id, Opportunity>([SELECT Id, Opportunity_Contact__r.Id,EventEdition__r.X3E_API_ID__c, EventEdition__r.X3E_Status__c,EventEdition__r.X3rd_Party_Relationship__c FROM Opportunity WHERE Id IN: lstOpptyIds]); // [EX-131]
         List<ExpocadBooth__c> expoBoothList= new List<ExpocadBooth__c>([Select Id FROM ExpocadBooth__c  limit 1]);
         Map<Id,ExpocadBooth__c> expoBoothMapList= new Map<Id,ExpocadBooth__c>([Select Id FROM ExpocadBooth__c  limit 1]);
        
        Create3EApiSyncRecords.insertExpoBoothForHoldUnhold(expoBoothMapList,true);
        Create3EApiSyncRecords.processCompanyTypeAssignToExpocad3E(expoBoothList,'Asynchronous');
        
        Test.startTest();
        oQuote.SBQQ__Primary__c = false;
        update oQuote;
        
        oQuote.SBQQ__Primary__c = true;
        update oQuote;
        
        oExpocadBooth1.Booth_Type__c = 'Island';
        oExpocadBooth1.ShowInShow__c = 'Test';
        oExpocadBooth1.Pavilion__c = 'Test';
        oExpocadBooth1.Booth_Number__c = 'TESTBN3';
        oExpocadBooth1.Booth_Classes__c = 'Standard Booth';
        oExpocadBooth1.Booth_Classes__c = 'Standard Booth';
       // oExpocadBooth1.Status__c = 'Released';
        update oExpocadBooth1;
        
         Opportunity_ExpoCAD_Booth_Mapping__c expocadChild = new Opportunity_ExpoCAD_Booth_Mapping__c();
        expocadChild.Expocad_Booth__c = oExpocadBooth1.id;
        expocadChild.Status__c = 'Active';
        expocadChild.Is_Parent_Mapping__c = false;
        expocadChild.Account__c = oAccount.id;
        expocadChild.Opportunity__c = oOpportunity.Id;
        expocadChild.Quote__c = oQuote2.Id;
        
        insert expocadChild;
        
        ExpocadBooth__c oExpocadBooth2 = new ExpocadBooth__c(Status__c = 'Rented', Released__c = false, Booth_Number__c = 'TESTBN2325', Quote__c = oQuote.Id, Opportunity__c = oOpportunity.Id, Booth_Product_Type_EE__c = 'Space Only' , Area__c = '18 m²');
        insert oExpocadBooth2;
        oExpocadBooth2.Status__c = 'Released';
        update oExpocadBooth2;
        
        ExpocadBooth__c oExpocadBooth3 = new ExpocadBooth__c(Status__c = 'Rented', Released__c = false, Booth_Number__c = 'TESTBN2325', Quote__c = oQuote.Id, Opportunity__c = oOpportunity.Id, Booth_Product_Type_EE__c = 'Space Only' , Area__c = '18 m²');
        insert oExpocadBooth3;
        oExpocadBooth3.Status__c = 'Added To Quote/On Hold';
        update oExpocadBooth3; 
        
        Booth_Product_Type_Configuration__c boothProType = new Booth_Product_Type_Configuration__c();
        boothProType.Booth_Product_Type__c = 'Space Only';
        insert boothProType;
        
        Opportunity_ExpoCAD_Booth_Mapping__c oppExpoBoothMap = new Opportunity_ExpoCAD_Booth_Mapping__c();
        oppExpoBoothMap.Status__c = 'Active';
        oppExpoBoothMap.Relation__c = 'Exhibitor';
        oppExpoBoothMap.Is_Parent_Mapping__c = True;
        
        insert oppExpoBoothMap;
        
        set<Id> setExpocadIds = new set<Id>();
        setExpocadIds.add(oppExpoBoothMap.Id);

        

        Test.stopTest();
        ExpocadBooth__c ebTest = [Select ID, Booth_Number__c from ExpocadBooth__c WHERE Booth_Number__c = 'TESTBN3' limit 1];
        System.assertEquals('TESTBN3', ebTest.Booth_Number__c, 'Error');
        System.debug('ebTest'+ebTest);
        Opportunity oOpportunity2 = new Opportunity(Name = 'Expocad Opportunity2', CloseDate = Date.today(), StageName = 'Proposal', EventEdition__c = oEvent.Id, AccountId = oAccount.Id, Billing_Contact__c = oCon.Id , IsCreatedByReviewProcess__c = false, CurrencyIsoCode = 'USD');
        insert oOpportunity2;
        
        oExpocadBooth1.Opportunity__c = oOpportunity2.Id;
        Update oExpocadBooth1;
        Delete oExpocadBooth1;
       
        
    }*/
    @istest //EX-131
    static  void releaseBoothTest3() {
        Trigger__c trig = new Trigger__c(Name = 'ReleaseBooths_Trig' , Trigger_Name_Unique__c='ReleaseBooths_Trig',Enabled__c=true,Object__c='ExpocadBooth__c',Run_for_Recordypes__c='All',  Description__c='my test',Execution_Order__c=2,
                                         After_Insert__c=true , After_Delete__c = true , Before_Insert__c = true , After_Update__c = true , After_UnDelete__c = true);
        insert trig;
        Trigger_Recordtype__c rrrt = new Trigger_Recordtype__c(Recordtype_Id__c=trig.Id , Trigger__c=trig.Id,Enabled__c=true, Parameters__c='param=1;param=2');
        Insert rrrt; 
         
        TriggerInterface_ExpocadBooth obj=new TriggerInterface_ExpocadBooth();
       
        TriggerInterfaceHelper.runTrigger('ReleaseBooths_Trig','ExpocadBooth__c', 2, 'ai', rrrt.id ,rrrt.Parameters__c,'All');
        TriggerInterfaceHelper.runTrigger('ReleaseBooths_Trig','ExpocadBooth__c', 2, 'ad', rrrt.id ,rrrt.Parameters__c,'All');
        Product2 prd1 = new Product2(Name = 'Linear Booth', Family = 'Booth', Number_of_Corners__c = 0);
        insert prd1;
        
        
        Account oAccount = new Account(Name = 'Expocad Account', CurrencyIsoCode = 'USD');
        insert oAccount;
        
        Contact oCon = new Contact(LastName = 'ContTest1', Email = 'test1contact@duptest.com', AccountId = oAccount.Id, MailingState = '', MailingCountry = 'India');
        insert oCon;
        
        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017', Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information', Payment_Schedule__c = '50-50', cutoff_date_1__c = date.today(), Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt' , Expocad_API_URL__c = 'https://expocad.api.com');
        insert oEvent;
        //[EX-131]
        oEvent.X3rd_Party_Relationship__c='3E Expocad';
        oEvent.X3E_Status__c='Active';
        oEvent.X3E_API_ID__c='22col';
        update oEvent;
        
        Opportunity oOpportunity = new Opportunity(Name = 'Expocad Opportunity',Exhibitor_Paid_By__c='Delegate Sales', CloseDate = Date.today(), StageName = 'Proposal', EventEdition__c = oEvent.Id, AccountId = oAccount.Id, Billing_Contact__c = oCon.Id , IsCreatedByReviewProcess__c = false, CurrencyIsoCode = 'USD');
        insert oOpportunity;
        
        
        
        SBQQ__Quote__c oQuote2 = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = oOpportunity.Id, SBQQ__Account__c = oAccount.Id );
        insert oQuote2;
        
        ExpocadBooth__c oExpocadBooth = new ExpocadBooth__c(Status__c = 'On hold', Released__c = false, Booth_Number__c = 'TESTBN2', Quote__c = oQuote2.Id, Opportunity__c = oOpportunity.Id, Booth_Product_Type_EE__c = 'Space Only', Area__c = '18 m²');
       //EX-131
      // oExpocadBooth.Primary_Contact__c=oOpportunity.Opportunity_Contact__c.Id;
        insert oExpocadBooth;
        
       
        oExpocadBooth.Status__c = 'Released';
        update oExpocadBooth;
        //[EX-131]
        List<Id> lstOpptyIds = new List<Id>();
        Map<Id, Opportunity> mapOppty = new Map<Id, Opportunity>([SELECT Id, Opportunity_Contact__r.Id,EventEdition__r.X3E_API_ID__c, EventEdition__r.X3E_Status__c,EventEdition__r.X3rd_Party_Relationship__c FROM Opportunity WHERE Id IN: lstOpptyIds]); // [EX-131]
         List<ExpocadBooth__c> expoBoothList= new List<ExpocadBooth__c>([Select Id FROM ExpocadBooth__c  limit 1]);
         Map<Id,ExpocadBooth__c> expoBoothMapList= new Map<Id,ExpocadBooth__c>([Select Id FROM ExpocadBooth__c  limit 1]);
        
        Create3EApiSyncRecords.insertExpoBoothForHoldUnhold(expoBoothMapList,true);
        Create3EApiSyncRecords.processCompanyTypeAssignToExpocad3E(expoBoothList,'Asynchronous');
        
        Test.startTest();
        
        Opportunity_ExpoCAD_Booth_Mapping__c expocadChild = new Opportunity_ExpoCAD_Booth_Mapping__c();
        expocadChild.Expocad_Booth__c = oExpocadBooth.id;
        expocadChild.Status__c = 'Active';
        expocadChild.Is_Parent_Mapping__c = false;
        expocadChild.Account__c = oAccount.id;
        expocadChild.Opportunity__c = oOpportunity.Id;
        expocadChild.Quote__c = oQuote2.Id;
        
        insert expocadChild;
        
        ExpocadBooth__c oExpocadBooth3 = new ExpocadBooth__c(Status__c = 'Rented', Released__c = false, Booth_Number__c = 'TESTBN2325', Quote__c = oQuote2.Id, Opportunity__c = oOpportunity.Id, Booth_Product_Type_EE__c = 'Space Only' , Area__c = '18 m²');
        insert oExpocadBooth3;
        oExpocadBooth3.Status__c = 'Added To Quote/On Hold';
        update oExpocadBooth3; 
        
        Booth_Product_Type_Configuration__c boothProType = new Booth_Product_Type_Configuration__c();
        boothProType.Booth_Product_Type__c = 'Space Only';
        insert boothProType;
        
        Opportunity_ExpoCAD_Booth_Mapping__c oppExpoBoothMap = new Opportunity_ExpoCAD_Booth_Mapping__c();
        oppExpoBoothMap.Status__c = 'Active';
        oppExpoBoothMap.Relation__c = 'Exhibitor';
        oppExpoBoothMap.Is_Parent_Mapping__c = True;
        
        insert oppExpoBoothMap;
        
        set<Id> setExpocadIds = new set<Id>();
        setExpocadIds.add(oppExpoBoothMap.Id);
        
        System.assertEquals( oppExpoBoothMap.Status__c, 'Active', true);

        Test.stopTest();
        
        
    }
    @istest //EX-101
    static  void releaseBoothTest2() {
        Trigger__c trig = new Trigger__c(Name = 'ReleaseBooths_Trig' , Trigger_Name_Unique__c='ReleaseBooths_Trig',Enabled__c=true,Object__c='ExpocadBooth__c',Run_for_Recordypes__c='All',  Description__c='my test',Execution_Order__c=2,
                                         After_Insert__c=true , After_Delete__c = true , Before_Insert__c = true , After_Update__c = true , After_UnDelete__c = true);
        insert trig;
        Trigger_Recordtype__c rrrt = new Trigger_Recordtype__c(Recordtype_Id__c=trig.Id , Trigger__c=trig.Id,Enabled__c=true, Parameters__c='param=1;param=2');
        Insert rrrt; 
         
        TriggerInterface_ExpocadBooth obj=new TriggerInterface_ExpocadBooth();
       
        TriggerInterfaceHelper.runTrigger('ReleaseBooths_Trig','ExpocadBooth__c', 2, 'ai', rrrt.id ,rrrt.Parameters__c,'All');
        TriggerInterfaceHelper.runTrigger('ReleaseBooths_Trig','ExpocadBooth__c', 2, 'ad', rrrt.id ,rrrt.Parameters__c,'All');
        Product2 prd1 = new Product2(Name = 'Linear Booth', Family = 'Booth', Number_of_Corners__c = 0);
        insert prd1;
        
        
        Account oAccount = new Account(Name = 'Expocad Account', CurrencyIsoCode = 'USD');
        insert oAccount;
        
        Contact oCon = new Contact(LastName = 'ContTest1', Email = 'test1contact@duptest.com', AccountId = oAccount.Id, MailingState = '', MailingCountry = 'India');
        insert oCon;
        
        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017', Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information', Payment_Schedule__c = '50-50', cutoff_date_1__c = date.today(), Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt' , Expocad_API_URL__c = 'https://expocad.api.com');
        insert oEvent;
        //[EX-131]
        oEvent.X3rd_Party_Relationship__c='3E Expocad';
        oEvent.X3E_Status__c='Active';
        oEvent.X3E_API_ID__c='22col';
        update oEvent;
        
        Opportunity oOpportunity = new Opportunity(Name = 'Expocad Opportunity',Exhibitor_Paid_By__c='Delegate Sales', CloseDate = Date.today(), StageName = 'Proposal', EventEdition__c = oEvent.Id, AccountId = oAccount.Id, Billing_Contact__c = oCon.Id , IsCreatedByReviewProcess__c = false, CurrencyIsoCode = 'USD');
        insert oOpportunity;
        
        
        SBQQ__Quote__c oQuote = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = oOpportunity.Id, SBQQ__Account__c = oAccount.Id );
        insert oQuote;
        
        
       
        ExpocadBooth__c oExpocadBooth1 = new ExpocadBooth__c(Status__c = 'Rented', Released__c = false, Booth_Number__c = 'TESTBN2325', Quote__c = oQuote.Id, Opportunity__c = oOpportunity.Id, Booth_Product_Type_EE__c = 'Space Only' , Area__c = '18 m²',Display_Name__c= oAccount.Name);
        insert oExpocadBooth1;
        
        //[EX-131]
        List<Id> lstOpptyIds = new List<Id>();
        Map<Id, Opportunity> mapOppty = new Map<Id, Opportunity>([SELECT Id, Opportunity_Contact__r.Id,EventEdition__r.X3E_API_ID__c, EventEdition__r.X3E_Status__c,EventEdition__r.X3rd_Party_Relationship__c FROM Opportunity WHERE Id IN: lstOpptyIds]); // [EX-131]
         List<ExpocadBooth__c> expoBoothList= new List<ExpocadBooth__c>([Select Id FROM ExpocadBooth__c  limit 1]);
         Map<Id,ExpocadBooth__c> expoBoothMapList= new Map<Id,ExpocadBooth__c>([Select Id FROM ExpocadBooth__c  limit 1]);
        
        Create3EApiSyncRecords.insertExpoBoothForHoldUnhold(expoBoothMapList,true);
        Create3EApiSyncRecords.processCompanyTypeAssignToExpocad3E(expoBoothList,'Asynchronous');
        
        Test.startTest();
        oQuote.SBQQ__Primary__c = false;
        update oQuote;
        
        oQuote.SBQQ__Primary__c = true;
        update oQuote;
        
        oExpocadBooth1.Booth_Type__c = 'Island';
        oExpocadBooth1.ShowInShow__c = 'Test';
        oExpocadBooth1.Pavilion__c = 'Test';
        oExpocadBooth1.Booth_Number__c = 'TESTBN3';
        oExpocadBooth1.Booth_Classes__c = 'Standard Booth';
        oExpocadBooth1.Booth_Classes__c = 'Standard Booth';
       // oExpocadBooth1.Status__c = 'Released';
        update oExpocadBooth1;
        
        
        ExpocadBooth__c oExpocadBooth2 = new ExpocadBooth__c(Status__c = 'Rented', Released__c = false, Booth_Number__c = 'TESTBN2325', Quote__c = oQuote.Id, Opportunity__c = oOpportunity.Id, Booth_Product_Type_EE__c = 'Space Only' , Area__c = '18 m²');
        insert oExpocadBooth2;
        oExpocadBooth2.Status__c = 'Released';
        update oExpocadBooth2;
        
        ExpocadBooth__c oExpocadBooth3 = new ExpocadBooth__c(Status__c = 'Rented', Released__c = false, Booth_Number__c = 'TESTBN2325', Quote__c = oQuote.Id, Opportunity__c = oOpportunity.Id, Booth_Product_Type_EE__c = 'Space Only' , Area__c = '18 m²');
        insert oExpocadBooth3;
        oExpocadBooth3.Status__c = 'Added To Quote/On Hold';
        update oExpocadBooth3; 
        
        Booth_Product_Type_Configuration__c boothProType = new Booth_Product_Type_Configuration__c();
        boothProType.Booth_Product_Type__c = 'Space Only';
        insert boothProType;
        
        Opportunity_ExpoCAD_Booth_Mapping__c oppExpoBoothMap = new Opportunity_ExpoCAD_Booth_Mapping__c();
        oppExpoBoothMap.Status__c = 'Active';
        oppExpoBoothMap.Relation__c = 'Exhibitor';
        oppExpoBoothMap.Is_Parent_Mapping__c = True;
        
        insert oppExpoBoothMap;
        
        set<Id> setExpocadIds = new set<Id>();
        setExpocadIds.add(oppExpoBoothMap.Id);

        System.assertEquals( oppExpoBoothMap.Status__c, 'Active', true);

        Test.stopTest();
    }

}