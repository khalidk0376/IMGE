/**
 * File:        RunDateCalculation_test.cls
 * Project:     GAP
 * Date:        17/10/2017
 * Created By:  Abdul Kadir
 * *************************************************************************
 * @description test class for runDateCalculation.tgr.
 * *************************************************************************
 * History:History:Ticket :GGCKB-76 
 */
@IsTest(seeAllData=false)
public class RunDateCalculation_test {
    /**
     * [runDateCalculation runDateCalculation]
     * @return [runDateCalculation]
     */
    public TestMethod static void runDateCalculation(){

        // Create Trigger test record 
        Trigger__c trig = new Trigger__c(Name = 'SendEmailCloseworkOrder_Trig' , Trigger_Name_Unique__c='SendEmailCloseworkOrder_Trig',Enabled__c=true,Object__c='WorkOrder',Run_for_Recordypes__c='All',  Description__c='my test',Execution_Order__c=2,
                                        After_Insert__c=true , After_Update__c = true);
        Insert trig;
        Trigger_Recordtype__c rt = new Trigger_Recordtype__c(Enabled__c=true,Recordtype_Id__c=trig.Id,Trigger__c=trig.Id,Parameters__c='param=1;param=2');
        Insert rt;    
        //Call event edition trigger interface
        TriggerInterface_WorkOrder obj = new TriggerInterface_WorkOrder();

        //Call trigger app handler for insert event
        TriggerInterfaceHelper.runTrigger('SendEmailCloseworkOrder_Trig','WorkOrder',2, 'au', null,null,'All');
        TriggerInterfaceHelper.initTriggerMapAndList('SendEmailCloseworkOrder_Trig');
        Pricebook2 pb=new Pricebook2(Name='Arab Health 2016');
        insert pb;
         Account oAccount = new Account(Name='Expocad Account', CurrencyIsoCode = 'USD');
            insert oAccount;
            
            Contact oCon = new Contact(LastName='ContTest1', Email='test1contact@duptest.com', AccountId = oAccount.Id,MailingState='',MailingCountry='India');
            insert oCon;
            
            Event_Edition__c ee = new Event_Edition__c(Event_Currency__c = 'USD', Name = 'World of Concrete 2017',Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information',Booth_Rent_Stage__c = 'On Contract', Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt' );
            insert ee;
            System.AssertEquals('World of Concrete 2017', ee.Name , 'test class failed');
            Opportunity oppty = new Opportunity(Name = 'Expocad Opportunity', CloseDate = Date.today().addDays(7), StageName = 'Discover', EventEdition__c = ee.Id, AccountId = oAccount.Id, Billing_Contact__c = oCon.Id, Payment_Status__c='Not Paid');
            insert oppty;
            
        
            Product2 prod = new Product2(Name = 'Laptop X200',Family = 'Event');
            insert prod;
            Product2 prod1 = new Product2(Name = 'Laptop X200',Family = 'Publishing');
            insert prod1;
            Product2 prod2 = new Product2(Name = 'Laptop X200',Family = 'Digital');
            insert prod2;

            Id pricebookId = Test.getStandardPricebookId();
            PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id,UnitPrice = 10000, IsActive = true);
            INSERT standardPrice ;
            PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod1.Id,UnitPrice = 10000, IsActive = true);
            INSERT standardPrice1 ;
            PricebookEntry standardPrice2 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod2.Id,UnitPrice = 10000, IsActive = true);
            INSERT standardPrice2 ;
           // PricebookEntry pbe = [ SELECT Id,Product2Id,Pricebook2Id,UnitPrice FROM PricebookEntry WHERE Id = :standardPrice.Id];
            OpportunityLineItem opppp=new OpportunityLineItem(Start_Date__c=system.today(),Opportunity=oppty,Quantity=1,Brand__c='Arab Health',UnitPrice=25.0,OpportunityId=oppty.Id,PricebookEntryId=standardPrice.Id);
            insert opppp;
            OpportunityLineItem opppp1=new OpportunityLineItem(Start_Date__c=system.today(),Opportunity=oppty,Quantity=1,Brand__c='Arab Health',UnitPrice=25.0,OpportunityId=oppty.Id,PricebookEntryId=standardPrice1.Id);
            insert opppp1;
            OpportunityLineItem opppp2=new OpportunityLineItem(Start_Date__c=system.today(),Opportunity=oppty,Quantity=1,Brand__c='Arab Health',UnitPrice=25.0,OpportunityId=oppty.Id,PricebookEntryId=standardPrice2.Id);
            insert opppp2;
        
            WorkOrder wo = new WorkOrder();
            wo.Work_Order_Name__c = 'test';
            wo.Status='Closed';
            //wo.Work_Order_Template__c = wot.Id;
            wo.Opportunity__c = oppty.Id;
            wo.AccountId=oAccount.Id;
            //wo.Event_Edition__c=oEvent.Id;
            wo.Product_Name__c=prod.Id;
            wo.OwnerId=UserInfo.getUserId();//u.Id;
            wo.Opportunity_Product_Id__c=opppp2.Id;
            wo.Booth_Number__c='test';
            wo.Booth_Pavilion__c='test';
            wo.Booth_Show_In_Show__c='test';
            wo.Booth_Type__c='test';
            insert wo;
            
            opppp2.UnitPrice=30.0;
            update opppp2;
            
            update oppty;
    }
}