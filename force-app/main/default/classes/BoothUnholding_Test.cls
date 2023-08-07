/**
* File:             BoothUnholding_Test.class
* Project:          GAP
* Date:             Aug 26, 2016
* Test Class For:   BoothUnholding
* Code Coverage:    89%
* Created By:       Kumar Gaurav
* *************************************************************************
* @description Test class for Trigger BoothUnholding & releaseBooth
* *************************************************************************
* History: 
*/

@isTest
public class BoothUnholding_Test{
    static testMethod void boothUnholdingBefore(){
        // Create Trigger test record 
        Trigger__c trig = new Trigger__c(Name = 'BoothUnholding_Trig' , Trigger_Name_Unique__c='BoothUnholding_Trig',Enabled__c=true,Object__c='SBQQ__QuoteLine__c',Run_for_Recordypes__c='All',  Description__c='my test',Execution_Order__c=1,
                                        Before_Insert__c=true , Before_Update__c = true , After_Delete__c = true);
        Insert trig;
        Trigger_Recordtype__c rt = new Trigger_Recordtype__c(Enabled__c=true,Recordtype_Id__c=trig.Id,Trigger__c=trig.Id,Parameters__c='param=1;param=2');
        Insert rt;    
        //Call event edition trigger interface
        TriggerInterface_QuoteLine obj = new TriggerInterface_QuoteLine();

        //Call trigger app handler for insert event
        TriggerInterfaceHelper.runTrigger('BoothUnholding_Trig','SBQQ__QuoteLine__c',1, 'bi', null,null,'All');
        TriggerInterfaceHelper.initTriggerMapAndList('BoothUnholding_Trig');
        //Utility.isRebookInProcess = True ;
        Product2 prd1 = new Product2(Name = 'Linear Booth',Family = 'Booth', Number_of_Corners__c = 0);
        insert prd1;
                
        Pricebook2 customPB = new Pricebook2(Name='ICRE', isActive=true);
        insert customPB;
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry stndrdPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prd1.Id,UnitPrice = 100, IsActive = true);
        insert stndrdPrice;
        
        PricebookEntry iCREPrice = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = prd1.Id,UnitPrice = 200, IsActive = true);
        insert iCREPrice;
        Account oAccount = new Account(Name='Expocad Account');
        insert oAccount;
        Contact oCon = new Contact(LastName='ContTest1', Email='test1contact@duptest.com', AccountId = oAccount.Id,MailingState='',MailingCountry='India', MobilePhone = '2121212145');
        insert oCon;
        System.assertEquals('ContTest1' , oCon.LastName , 'Conctact Lastname must be ContTest1');
        
        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017',Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information',Payment_Schedule__c = '50-50',cutoff_date_1__c = date.today(),Approval_Service_Now_ID__c = '123',Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt');
        insert oEvent;
        
        Opportunity oOpportunity = new Opportunity(Name = 'Expocad Opportunity', CloseDate = Date.today(), StageName = 'Proposal', EventEdition__c = oEvent.Id, AccountId = oAccount.Id, Billing_Contact__c = oCon.Id);
        insert oOpportunity;
        
        SBQQ__Quote__c oQuote = new SBQQ__Quote__c( SBQQ__Status__c = 'Quote Sent' , SBQQ__Type__c = 'Amendment', SBQQ__Opportunity2__c = oOpportunity.Id, SBQQ__Account__c = oAccount.Id ,SBQQ__Primary__c = false, Parent_Opp_Primary_Quote_Total__c = 10000.00);
        insert oQuote;
        
         //CompleteAmendButton_class.getuserInfo(oQuote.id);
   /*     Opportunity oOppAmend = new Opportunity(Name = 'amend Opportunity', CloseDate = Date.today(), StageName = 'Proposal', EventEdition__c = oEvent.Id, AccountId = oAccount.Id, Billing_Contact__c = oCon.Id , Master_Opportunity__c = oOpportunity.Id);
        insert oOppAmend;
        SBQQ__Quote__c oQuoteAmnd = new SBQQ__Quote__c( SBQQ__Status__c = 'Quote Sent', SBQQ__Type__c = 'Amendment', SBQQ__Opportunity2__c = oOppAmend.Id, SBQQ__Account__c = oAccount.Id ,SBQQ__Primary__c = false, Parent_Opp_Primary_Quote_Total__c = 10000.00);
        insert oQuoteAmnd;  */
        
        SBQQ__QuoteLine__c oQuoteLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = oQuote.Id, SBQQ__Product__c = prd1.Id, SBQQ__Quantity__c = 2, SBQQ__Number__c = 1, Line_Description__c = 'Test', Booth_Number__c = 'TESTBN3', Booth__c = True);
        insert oQuoteLine ;
        
        
        TriggerInterfaceHelper.runTrigger('BoothUnholding_Trig','SBQQ__QuoteLine__c',1, 'bi', null,null,'All');
        update oQuoteLine;
        TriggerInterfaceHelper.runTrigger('BoothUnholding_Trig','SBQQ__QuoteLine__c',1, 'bu', null,null,'All');
        
        oQuote.SBQQ__Primary__c = true;
        update oQuote;
        
        ExpocadBooth__c oExpocadBooth = new ExpocadBooth__c(Status__c = 'On Hold',Released__c = false,Booth_Number__c='TESTBN3',Quote__c = oQuote.Id, Opportunity__c = oOpportunity.Id);
        insert oExpocadBooth;
        oExpocadBooth.Status__c = 'Released';
        update oExpocadBooth;
        delete oQuoteLine ;
        TriggerInterfaceHelper.runTrigger('BoothUnholding_Trig','SBQQ__QuoteLine__c',1, 'ad', null,null,'All');
        
    }
    
    static testMethod void boothUnholdingAfter(){
        // Create Trigger test record 
        Trigger__c trig = new Trigger__c(Name = 'BoothUnholding_Trig' , Trigger_Name_Unique__c='BoothUnholding_Trig',Enabled__c=true,Object__c='SBQQ__QuoteLine__c',Run_for_Recordypes__c='All',  Description__c='my test',Execution_Order__c=1,
                                        Before_Insert__c=true , Before_Update__c = true , After_Delete__c = true);
        Insert trig;
        Trigger_Recordtype__c rt = new Trigger_Recordtype__c(Enabled__c=true,Recordtype_Id__c=trig.Id,Trigger__c=trig.Id,Parameters__c='param=1;param=2');
        Insert rt;    
        //Call event edition trigger interface
        TriggerInterface_QuoteLine obj = new TriggerInterface_QuoteLine();

        //Call trigger app handler for insert event
        TriggerInterfaceHelper.runTrigger('BoothUnholding_Trig','SBQQ__QuoteLine__c',1, 'bi', null,null,'All');
        TriggerInterfaceHelper.initTriggerMapAndList('BoothUnholding_Trig');
        //Utility.isRebookInProcess = True ;
        Product2 prd1 = new Product2(Name = 'Linear Booth',Family = 'Booth', Number_of_Corners__c = 0);
        insert prd1;        
        Pricebook2 customPB = new Pricebook2(Name='ICRE', isActive=true);
        insert customPB;
        System.assertEquals('ICRE' , customPB.Name , 'The pricebook on the even edition is ICRE');
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry stndrdPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prd1.Id,UnitPrice = 100, IsActive = true);
        insert stndrdPrice;
        
        PricebookEntry iCREPrice = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = prd1.Id,UnitPrice = 200, IsActive = true);
        insert iCREPrice;
        Account oAccount = new Account(Name='Expocad Account', CurrencyIsoCode = 'USD');
        insert oAccount;
        
        Contact oCon = new Contact(LastName='ContTest1', Email='test1contact@duptest.com', AccountId = oAccount.Id,MailingState='',MailingCountry='India', MobilePhone = '2121212145');
        insert oCon;
        
        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017',Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information',Payment_Schedule__c = '50-50',cutoff_date_1__c = date.today(),Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt');
        insert oEvent;
        
        Opportunity oOpportunity = new Opportunity(Name = 'Expocad Opportunity', CloseDate = Date.today(), StageName = 'Proposal', EventEdition__c = oEvent.Id, AccountId = oAccount.Id, Billing_Contact__c = oCon.Id);
        insert oOpportunity;
        
        Opportunity oOpportunity2 = new Opportunity(Name = 'Expocad Opportunity', Parent_Opportunity__c = oOpportunity.Id,CloseDate = Date.today(), StageName = 'Proposal', EventEdition__c = oEvent.Id, AccountId = oAccount.Id, Billing_Contact__c = oCon.Id);
        insert oOpportunity2;
        
        SBQQ__Quote__c oQuote2 = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Quote Sent', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = oOpportunity2.Id, SBQQ__Account__c = oAccount.Id ,SBQQ__Primary__c = false);
        insert oQuote2;
        
        SBQQ__QuoteLine__c oQuoteLine2 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = oQuote2.Id, SBQQ__Product__c = prd1.Id, SBQQ__Quantity__c = 2, SBQQ__Number__c = 1, Line_Description__c = 'Test', Booth_Number__c = 'TESTBN2', Booth__c = True);
        insert oQuoteLine2 ;
        TriggerInterfaceHelper.runTrigger('BoothUnholding_Trig','SBQQ__QuoteLine__c',1, 'ai', null,null,'All');
        
        ExpocadBooth__c oExpocadBooth2 = new ExpocadBooth__c(Status__c = 'On Hold',Released__c = false,Booth_Number__c='TESTBN2',Quote__c = oQuote2.Id,AddedToQLI__c = true,Opportunity__c=oOpportunity2.Id);
        insert oExpocadBooth2;
        
        delete oQuoteLine2 ;
        TriggerInterfaceHelper.runTrigger('BoothUnholding_Trig','SBQQ__QuoteLine__c',1, 'ad', null,null,'All');
    }
    
    /*static testMethod void quoteLineNetAmt(){
        Account acct = new Account(Name = 'testAccount', CurrencyIsoCode = 'BRL');
        insert acct;
        
        Contact ocontact = new Contact();
        ocontact.Email = 'test.test@gmail.com';
        ocontact.Phone = '1234567890';
        ocontact.FirstName = 'TestFN';
        ocontact.LastName = 'testLN';
        ocontact.AccountId = acct.Id;
        ocontact.MailingStreet = 'TestStreet';
        ocontact.MailingCity = 'Delhi';
        ocontact.MailingPostalCode = '110025';
        ocontact.MailingState = 'Delhi';
        ocontact.MailingCountry = 'India';
        ocontact.Fax = '1234567890';
        ocontact.Address_Verified__c = false;
        insert ocontact;
        
        Event_Edition__c ee = new Event_Edition__c();
        ee.Name = 'TestEvent';
        ee.Tab1__c = 'tab1';
        ee.Tab4__c = 'tab4';
        ee.Tab7__c = 'tab7';
        ee.Tab8__c = 'Tab8__c';
        ee.Payment_Schedule__c = '25-25-25-25';
        ee.X50_Cutoff_Date__c = date.today();
        ee.Cutoff_Date_1__c = date.today().addDays(1);
        ee.Cutoff_Date_2__c = date.today().addDays(2);
        ee.Cutoff_Date_3__c = date.today().addDays(3);
        insert ee;
        
        Opportunity oppty = new Opportunity(Name = 'testOpp' , EventEdition__c = ee.Id);    
        oppty.AccountId = acct.Id;
        oppty.StageName = 'Discover';
        oppty.CloseDate = date.today();
        oppty.Opportunity_Contact__c=ocontact.Id;
        oppty.custom_Payment__c=true;
        oppty.Milestone_1_Delivery_Date__c=System.today();
        oppty.Milestone_2_Delivery_Date__c=System.today().addDays(30);
        oppty.Milestone_3_Delivery_Date__c=System.today().addDays(60);
        oppty.Milestone_4_Delivery_Date__c=System.today().addDays(90);
        oppty.Milestone_5_Delivery_Date__c=System.today().addDays(120);
        oppty.Milestone_6_Delivery_Date__c=System.today().addDays(150);
        oppty.Milestone_7_Delivery_Date__c=System.today().addDays(180);
        oppty.Milestone_8_Delivery_Date__c=System.today().addDays(210);
        oppty.Milestone_9_Delivery_Date__c=System.today().addDays(240);
        oppty.Milestone_10_Delivery_Date__c=System.today().addDays(270);
        oppty.Milestone_11_Delivery_Date__c=System.today().addDays(300);
        oppty.Milestone_12_Delivery_Date__c=System.today().addDays(330);
        oppty.Milestone_1_Amount__c = 200.00;
        oppty.Milestone_2_Amount__c = 200.00;
        oppty.Milestone_3_Amount__c = 200.00;
        oppty.Milestone_4_Amount__c = 200.00;
        oppty.Milestone_5_Amount__c = 200.00;
        oppty.Milestone_6_Amount__c = 200.00;
        oppty.Milestone_7_Amount__c = 200.00;
        oppty.Milestone_8_Amount__c = 200.00;
        oppty.Milestone_9_Amount__c = 200.00;
        oppty.Milestone_10_Amount__c = 200.00;
        oppty.Milestone_11_Amount__c = 200.00;
        oppty.Milestone_12_Amount__c = 200.00;
        oppty.Milestone_1_Percent__c = 8.2; oppty.Milestone_2_Percent__c = 8.3; oppty.Milestone_3_Percent__c = 8.2;
        oppty.Milestone_4_Percent__c = 8.2; oppty.Milestone_5_Percent__c = 8.3; oppty.Milestone_6_Percent__c = 8.3;
        oppty.Milestone_7_Percent__c = 8.2; oppty.Milestone_8_Percent__c = 8.3; oppty.Milestone_9_Percent__c = 8.3;
        oppty.Milestone_10_Percent__c = 8.2; oppty.Milestone_11_Percent__c = 8.3; oppty.Milestone_12_Percent__c = 8.3;
        insert oppty;
        
        System.assertEquals('testOpp' , oppty.Name);
        Product2 prodObj = new Product2(Name = 'testProd', validated_in_sap__c=true);
        insert prodObj;
        
        SBQQ__Quote__c qtObj = new SBQQ__Quote__c();
        qtObj.SBQQ__Account__c = acct.Id;
        qtObj.SBQQ__Status__c = 'Draft';
        qtObj.SBQQ__Type__c = 'Quote';
        qtObj.SBQQ__StartDate__c = date.today();
        qtObj.SBQQ__Opportunity2__c = oppty.Id;
        qtObj.Billing_Contact__c = ocontact.Id;
        qtObj.CurrencyIsoCode='BRL';
        insert qtObj;
        
        SBQQ__QuoteLine__c qlObj = new SBQQ__QuoteLine__c(SBQQ__Quote__c = qtObj.Id,SBQQ__Product__c = prodObj.Id,Product_Local_Name__c='',SBQQ__NetPrice__c =5000.00);
        qlObj.CurrencyIsoCode = 'BRL';
        insert qlObj;
        
        Test.startTest();
        List<SBQQ__QuoteLine__c> lstQuoteLine = new List<SBQQ__QuoteLine__c>();
        lstQuoteLine.add(qlObj);
        Map<Id,SBQQ__QuoteLine__c> prodIdQuoteLineMap =new Map<Id,SBQQ__QuoteLine__c> ();
        prodIdQuoteLineMap.put(qlObj.SBQQ__Product__c, qlObj);  
        Test.stopTest(); 
            
    }*/
    
}