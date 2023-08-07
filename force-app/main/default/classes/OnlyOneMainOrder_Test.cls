/**
* Project:         GAP
* Date:            May 24, 2018
* Created By:      Kumar Gaurav
* Test Class For:  OnlyOneMainOrder
* Code Coverage:   90%
* *************************************************************************
* Description:     Test class for OnlyOneMainOrder Apex Trigger.
* *************************************************************************
* History:
*/

@isTest(seeAlldata = false)
public class OnlyOneMainOrder_Test {
    
    @testSetup
    public static void setupData() {
        Utility.isRebookInProcess = True ;
        
        TestUtilities.createCSIntegrationSettings();
        TestUtilities.createCSBatchSettings();
        TestUtilities.createBillingPrefix();
        TestUtilities.createBillingConfigs();
        
        Application_Bypass__c oAB = new Application_Bypass__c(SetupOwnerId=UserInfo.getOrganizationId(), Bypass_Validation_Rules__c = True);
        Insert oAB ;
        Integration_Service__c oCyberSourceCredential = new Integration_Service__c();
        oCyberSourceCredential.Name= 'Cybersource';
        oCyberSourceCredential.User_Name__c = 'girikon'; 
        oCyberSourceCredential.Password__c = 'tttttttttttttt';
        oCyberSourceCredential.End_Point_Url__c = 'https://paymentservicestest.informa.com';
        Insert oCyberSourceCredential;
        
        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', Package_Identifier__c = 'WOC', Event_Edition_Pool__c = 'WOC', Active_VAT_Tax_Alt_Currency__c = True, VAT_Tax_Alt_Currency__c = 'ZAR', LegalEntityCode__c = 'LEC01' , Status__c = 'Active');
        insert oEventseries;
        
        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017',Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information',Approval_Service_Now_ID__c = '123', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = 'Space Only', Expocad_API_Url__c = 'test.com', Part_of_Series__c = oEventseries.id, Booth_Classes_on_Template__c = 'Temp', Corner_Configuration_Check__c = false, Product_Type_Order__c = 'BoothA;;BoothB', CurrencyIsoCode = 'USD');
        oEvent.Event_Edition_Status__c = 'Confirmed';
        oEvent.Event_Edition_Code__c = 'Test1';
        insert oEvent;
        
        blng__LegalEntity__c oLegalEntity = new blng__LegalEntity__c(Name = 'KK G Legal Pvt', Invoice_Number_Prefix__c = 'INVCRS', Latest_Invoice_Number__c = '0000000017', Legal_Entity_Code__c = 'LEC01');
        Insert oLegalEntity;
        
        //@Description: Insert Account.
        Account acc = new Account();
        acc.Name = 'Testing Account'; 
        acc.CurrencyIsoCode = 'USD';
        insert acc;
        //System.assertEquals('Testing Account', acc.name);
        System.assertNotEquals('Testing Account', acc.Id,'Account Id should not be null');
        
        //@Description: Insert Contact.
        Contact ocontact = new Contact();
        ocontact.FirstName = 'Testing First Name';
        ocontact.LastName = 'Testing Last Name';
        ocontact.Email = 'test.test@gmail.com';
        ocontact.AccountId = acc.Id;
        insert ocontact;
        
        //@Description: Insert Event Edition.
        Event_Edition__c eventEdition = new Event_Edition__c();
        eventEdition.Name = 'Testing Event Edition';
        eventEdition.Tab1__c = 'Tab1';
        eventEdition.Tab4__c = 'Tab4';
        eventEdition.Tab8__c = 'Tab8';
        eventEdition.Event_Edition_Code__c = 'Test2';
        insert eventEdition;
        
        Account_Legal_Entity__c oALE = new Account_Legal_Entity__c(Account__c = acc.Id, Legal_Entity__c = oLegalEntity.Id, Business_Partner_Number__c = 'KG07');
        Insert oALE;
        
        Product2 product = new Product2( name='test product', ProductCode = 'P001', Family = 'test', validated_in_sap__c = false );
        product.Event_Edition__c = eventEdition.Id;
        insert product;
        
        //@Description: Insert Opportunity.
        Opportunity oppo = new Opportunity();
        oppo.Name = 'Testing Opportunity';
        oppo.EventEdition__c = eventEdition.Id;
        oppo.Opportunity_Contact__c = ocontact.Id;
        oppo.AccountId = acc.Id;
        oppo.CloseDate = Date.Today().addDays(1);
        oppo.StageName = 'Close Won';
        insert oppo;
        
        oppo.Custom_Payment__c = True;
        oppo.Milestone_1_Delivery_Date__c=System.today();
        oppo.Milestone_2_Delivery_Date__c=System.today().addDays(30);
        oppo.Milestone_3_Delivery_Date__c=System.today().addDays(60);
        oppo.Milestone_4_Delivery_Date__c=System.today().addDays(90);
        oppo.Milestone_5_Delivery_Date__c=System.today().addDays(120);
        oppo.Milestone_6_Delivery_Date__c=System.today().addDays(150);
        oppo.Milestone_7_Delivery_Date__c=System.today().addDays(180);
        oppo.Milestone_8_Delivery_Date__c=System.today().addDays(210);
        oppo.Milestone_9_Delivery_Date__c=System.today().addDays(240);
        oppo.Milestone_10_Delivery_Date__c=System.today().addDays(270);
        oppo.Milestone_11_Delivery_Date__c=System.today().addDays(300);
        oppo.Milestone_12_Delivery_Date__c=System.today().addDays(330);
        oppo.Milestone_1_Amount__c = 200.00;
        oppo.Milestone_2_Amount__c = 200.00;
        oppo.Milestone_3_Amount__c = 200.00;
        oppo.Milestone_4_Amount__c = 200.00;
        oppo.Milestone_5_Amount__c = 200.00;
        oppo.Milestone_6_Amount__c = 200.00;
        oppo.Milestone_7_Amount__c = 200.00;
        oppo.Milestone_8_Amount__c = 200.00;
        oppo.Milestone_9_Amount__c = 200.00;
        oppo.Milestone_10_Amount__c = 200.00;
        oppo.Milestone_11_Amount__c = 200.00;
        oppo.Milestone_12_Amount__c = 200.00;
        oppo.Milestone_1_Percent__c = 8.2; 
        oppo.Milestone_2_Percent__c = 8.3; 
        oppo.Milestone_3_Percent__c = 8.2;
        oppo.Milestone_4_Percent__c = 8.2; 
        oppo.Milestone_5_Percent__c = 8.3; 
        oppo.Milestone_6_Percent__c = 8.3;
        oppo.Milestone_7_Percent__c = 8.2; 
        oppo.Milestone_8_Percent__c = 8.3; 
        oppo.Milestone_9_Percent__c = 8.3;
        oppo.Milestone_10_Percent__c = 8.2; 
        oppo.Milestone_11_Percent__c = 8.3; 
        oppo.Milestone_12_Percent__c = 8.3;
        
        oppo.Event_Series__c = oEventseries.id ;
        oppo.SBQQ__Contracted__c = false;
        update oppo;
        oppo.SBQQ__Contracted__c = True;
        update oppo;
        
        TestUtilities.closeWonOpportunity(oppo.Id, True);
        Test.startTest();
        SBQQ__Quote__c oQuote = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = oppo.Id, SBQQ__Account__c = acc.Id, SBQQ__Primary__c = true);
        insert oQuote;
        
        SBQQ__QuoteLine__c oQuoteLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = oQuote.Id, SBQQ__Product__c = product.Id, SBQQ__Quantity__c = 2, SBQQ__Number__c = 1, Line_Description__c = 'Test', Booth_Number__c = 'TESTBN3', Booth__c = True);
        insert oQuoteLine ;
        
        Contract oContract = new Contract(AccountId = acc.id, Status='Sent', StartDate = Date.today(), ContractTerm = 12, SBQQ__Opportunity__c = oppo.id, SBQQ__Quote__c = oQuote.Id);
        insert oContract;
        Test.stopTest();
    }
    
    static testMethod void insertUpdateOrder() {
        // Create Trigger test record 
        Trigger__c trig = new Trigger__c(Name = 'OrderHandler_Trg' , Trigger_Name_Unique__c='OrderHandler_Trg',Enabled__c=true,Object__c='Order',Run_for_Recordypes__c='All',  Description__c='my test',Execution_Order__c=2,
                                         Before_Update__c = true);
        Insert trig;
        Trigger__c trig2 = new Trigger__c(Name = 'OnlyOneMainOrder_Handler' , Trigger_Name_Unique__c='OnlyOneMainOrder_Handler',Enabled__c=true,Object__c='Order',Run_for_Recordypes__c='All',  Description__c='my test',Execution_Order__c=1,
                                          Before_Insert__c=true , Before_Update__c = true, After_Insert__c = true, After_Update__c = true);
        Insert trig2;
        
        Trigger__c trig3 = new Trigger__c(Name = 'ContractToOrder_class' , Trigger_Name_Unique__c='ContractToOrder_class',Enabled__c=true,Object__c='Order',Run_for_Recordypes__c='All',  Description__c='my test',Execution_Order__c=3,
                                         After_Insert__c = true);
        Insert trig3;
        
        Trigger_Recordtype__c rt = new Trigger_Recordtype__c(Enabled__c=true,Recordtype_Id__c=trig.Id,Trigger__c=trig.Id,Parameters__c='param=1;param=2');
        Insert rt;
        TriggerInterface_Order obj = new TriggerInterface_Order();
        
        TriggerInterfaceHelper.runTrigger('OnlyOneMainOrder_Handler','Order',1, 'bi', null,null,'All');
        TriggerInterfaceHelper.runTrigger('OrderHandler_Trg','Order',2, 'bu', null,null,'All');
        TriggerInterfaceHelper.runTrigger('ContractToOrder_class','Order',3, 'ai', null,null,'All');

        Test.startTest();
        Utility.isRebookInProcess = True ;
        Opportunity oOpportunity = [SELECT ID FROM Opportunity LIMIT 1] ;
        Account account = [SELECT Id FROM Account LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        SBQQ__Quote__c oQuote = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Contract Sent', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = oOpportunity.Id, SBQQ__Account__c = account.Id, SBQQ__Primary__c = true);
        insert oQuote;
        
        Order objOrder = new Order(AccountId = account.id, Status = 'Draft', EffectiveDate=Date.today(), OpportunityId=oOpportunity.id, SBQQ__PriceCalcStatus__c='Completed', SBQQ__Quote__c = oQuote.Id, main_order__c = True, Type = 'New',Billing_Invoice_Account__c = account.id,Ready_to_Activate__c = False);
        insert objOrder;
        
        System.assertNotEquals('Draft', objOrder.SBQQ__PriceCalcStatus__c,'Completed');
        
        /*List<OrderItem> lstOrders = [SELECT ID, Actual_Tax__c FROM OrderItem WHERE ORDERID =: order.id];
        for(OrderItem oTemp : lstOrders){
        oTemp.Actual_Tax__c = 12 ;
        }
        update lstOrders ;*/
        objOrder.Create_Customer_Result__c = 'Success';
        update objOrder;
        Order orderDup = new Order(AccountId = account.id, Status = 'Draft', EffectiveDate=Date.today(), OpportunityId=oOpportunity.id, SBQQ__PriceCalcStatus__c='Completed', SBQQ__Quote__c = oQuote.Id, main_order__c = True, Type = 'New',Create_Customer_Result__c='Success',Billing_Invoice_Account__c = account.id,Ready_to_Activate__c = False);
        insert orderDup;
        orderDup.main_order__c = True;
        update orderDup;
        Test.stopTest();
    }
}