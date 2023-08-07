/*
Created By		: Girikon
Created On		: May 26, 2022.
@description 	: test class for : GetActiveOrdersForProducts and UpdateEventPicklistTrg (productDeactivationController method of helper class UpdateEventPicklist_Class).

Modification log --
Modified By		: 
*/

@isTest
public class GetActiveOrdersForProducts_Test {
    
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
        
        blng__LegalEntity__c legalentity = new blng__LegalEntity__c(Name = 'Test LegalEntity' , blng__Active__c = true , Legal_Entity_Code__c = 'AE006');
        insert legalentity;
        
        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', Package_Identifier__c = 'WOC', Event_Edition_Pool__c = 'WOC', Active_VAT_Tax_Alt_Currency__c = True, VAT_Tax_Alt_Currency__c = 'ZAR' , Legal_Entity__c = legalentity.id,Status__c = 'Active');
        insert oEventseries;
        
        Pricebook2 pb = new Pricebook2(Name = 'TestPricebook');
        insert pb;
        
        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017',Enable_Invoice_Creation_Using_Batch__c = False, Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information',Approval_Service_Now_ID__c = '123', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = 'Space Only', Expocad_API_Url__c = 'test.com', Part_of_Series__c = oEventseries.id, Booth_Classes_on_Template__c = 'Temp', Corner_Configuration_Check__c = false, Product_Type_Order__c = 'BoothA;;BoothB', CurrencyIsoCode = 'USD',Payment_Schedule__c='25-25-25-25',Cutoff_Date_1__c=System.today(),Cutoff_Date_2__c=System.today().addDays(30),Cutoff_Date_3__c=System.today().addDays(60));
        oEvent.Event_Price_Book__c = pb.Id;
        oEvent.Event_Edition_code__c = 'Adarsh';
        oEvent.End_Date__c = Date.today();
        OEvent.Activate_Invoice_WF__c = true; 
        oEvent.No_Billing__c = false;
        oEVent.Event_Edition_Status__c ='Confirmed';
        insert oEvent;
        
        Map<String, SObject> sbObjectMap = TestUtilities.createBillingBackgroundStack(true);
        Account account = (Account) sbObjectMap.get(TestUtilities.ACCOUNT);
        Product2 product = (Product2) sbObjectMap.get(TestUtilities.PRODUCT);
        Opportunity opportunity = (Opportunity) sbObjectMap.get(TestUtilities.OPPORTUNITY);
        opportunity.Custom_Payment__c = True;
        opportunity.Milestone_1_Delivery_Date__c=System.today();
        opportunity.Milestone_2_Delivery_Date__c=System.today().addDays(30);
        opportunity.Milestone_3_Delivery_Date__c=System.today().addDays(60);
        opportunity.Milestone_4_Delivery_Date__c=System.today().addDays(90);
        opportunity.Milestone_5_Delivery_Date__c=System.today().addDays(120);
        opportunity.Milestone_6_Delivery_Date__c=System.today().addDays(150);
        opportunity.Milestone_7_Delivery_Date__c=System.today().addDays(180);
        opportunity.Milestone_8_Delivery_Date__c=System.today().addDays(210);
        opportunity.Milestone_9_Delivery_Date__c=System.today().addDays(240);
        opportunity.Milestone_10_Delivery_Date__c=System.today().addDays(270);
        opportunity.Milestone_11_Delivery_Date__c=System.today().addDays(300);
        opportunity.Milestone_12_Delivery_Date__c=System.today().addDays(330);
        opportunity.Milestone_1_Amount__c = 200.00;
        opportunity.Milestone_2_Amount__c = 200.00;
        opportunity.Milestone_3_Amount__c = 200.00;
        opportunity.Milestone_4_Amount__c = 200.00;
        opportunity.Milestone_5_Amount__c = 200.00;
        opportunity.Milestone_6_Amount__c = 200.00;
        opportunity.Milestone_7_Amount__c = 200.00;
        opportunity.Milestone_8_Amount__c = 200.00;
        opportunity.Milestone_9_Amount__c = 200.00;
        opportunity.Milestone_10_Amount__c = 200.00;
        opportunity.Milestone_11_Amount__c = 200.00;
        opportunity.Milestone_12_Amount__c = 200.00;
        opportunity.Milestone_1_Percent__c = 8.2; 
        opportunity.Milestone_2_Percent__c = 8.3; 
        opportunity.Milestone_3_Percent__c = 8.2;
        opportunity.Milestone_4_Percent__c = 8.2; 
        opportunity.Milestone_5_Percent__c = 8.3; 
        opportunity.Milestone_6_Percent__c = 8.3;
        opportunity.Milestone_7_Percent__c = 8.2; 
        opportunity.Milestone_8_Percent__c = 8.3; 
        opportunity.Milestone_9_Percent__c = 8.3;
        opportunity.Milestone_10_Percent__c = 8.2; 
        opportunity.Milestone_11_Percent__c = 8.3; 
        opportunity.Milestone_12_Percent__c = 8.3;
        
        opportunity.Event_Series__c = oEventseries.id ;
        opportunity.EventEdition__c = oEvent.Id;
        //opportunity.Online_Booth_Capture__c = objOBC.Id;
        opportunity.SBQQ__Contracted__c = false;
        
        update opportunity;
        opportunity.SBQQ__Contracted__c = true;
        opportunity.By_Pass_Validation_Rule__c = True;
        update opportunity;
        
        TestUtilities.closeWonOpportunity(opportunity.Id, true);
        Test.startTest();
        SBQQ__Quote__c oQuote = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = opportunity.Id, SBQQ__Account__c = account.Id, SBQQ__Primary__c = true);
        insert oQuote;
        
        SBQQ__QuoteLine__c oQuoteLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = oQuote.Id, SBQQ__Product__c = product.Id, SBQQ__Quantity__c = 2, SBQQ__Number__c = 1, Line_Description__c = 'Test', Booth_Number__c = 'TESTBN3', Booth__c = True);
        insert oQuoteLine ;
        
        Contract oContract = new Contract(AccountId = account.id, Status='Sent', StartDate = Date.today(), ContractTerm = 12, SBQQ__Opportunity__c = opportunity.id, SBQQ__Quote__c = oQuote.Id);
        insert oContract;
        Test.stopTest();
    }
    
    static testMethod void productDeactivationTriggerTest() {
        Utility.isRebookInProcess = True ;
        Test.startTest();
        Opportunity oOpportunity = [SELECT ID FROM Opportunity LIMIT 1] ;
        Account account = [SELECT Id FROM Account LIMIT 1];
        Product2 product = [SELECT Id,IsActive FROM Product2 LIMIT 1];
        
        Order order = TestUtilities.createAutomatedOrderFromOpportunity(oOpportunity);
        List<OrderItem> lstOrders = [SELECT ID, Actual_Tax__c FROM OrderItem WHERE ORDERID =: order.id];
        product.IsActive = false;
        update product;
        List<Order> activeOrders = getActiveOrdersForProducts.getActiveOrders(product.id);
        System.assertEquals(activeOrders.size(),0,'Active Order return count does not match.');
    }
    
}