/**
 * File:        EventEditionTrigg_Test.cls
 * Project:     GAP
 * Created By:  [11-15-2016]: Muhammad Bangash
 * Modified :   [30-03-2017]:Rajesh Kumar
 * *************************************************************************
 * @description EventEditionTrigg trigger
 * *************************************************************************
 * History: Yash Gupta [As per ticket GGCW-2929] 
 */

@isTest
public class EventEditionTrigg_Test
{
  static testMethod void eventEditionTriggTestMethod()
  {
        // Create Trigger test record 
        Trigger__c trig = new Trigger__c(Name = 'EventEditionTrigg_Trig' , Trigger_Name_Unique__c='EventEditionTrigg_Trig',Enabled__c=true,Object__c='Event_Edition__c',Run_for_Recordypes__c='All',  Description__c='my test',Execution_Order__c=2,
                                         Before_Insert__c=true , Before_Update__c = true, After_Update__c = true , After_insert__c = true);
        Insert trig;
        Trigger_Recordtype__c rt = new Trigger_Recordtype__c(Enabled__c=true,Recordtype_Id__c=trig.Id,Trigger__c=trig.Id,Parameters__c='param=1;param=2');
        Insert rt;
        //Call event edition trigger interface
        TriggerInterface_EventEdition obj = new TriggerInterface_EventEdition();


        Trigger__c trig2 = new Trigger__c(Name = 'CloneEventEditionCS_Trig' , Trigger_Name_Unique__c='CloneEventEditionCS_Trig',Enabled__c=true,Object__c='Event_Edition__c',Run_for_Recordypes__c='All',  Description__c='my test',Execution_Order__c=2,
                                         Before_Insert__c=true , Before_Update__c = true, After_Update__c = true , After_insert__c = true);
        Insert trig2;
        TriggerInterfaceHelper.runTrigger('EventEditionTrigg_Trig','Event_Edition__c',2, 'bi', null,null,'All');
        TriggerInterfaceHelper.runTrigger('CloneEventEditionCS_Trig','Event_Edition__c',2, 'ai', null,null,'All');



    Event_Edition__c ee = new Event_Edition__c();
    ee.Name = 'Test GIri 2017';
    ee.Approval_Service_Now_ID__c = '111111111111111';
    ee.Alternate_Currency__c = 'AED';
    ee.CurrencyIsoCode='USD';
    ee.Tab1__c='Test';
    ee.Tab7__c = 'test1';
    ee.Booth_Product_Type__c = 'Shell Scheme';
    ee.Matched_Product_Name__c ='Shell Scheme';
    ee.Payment_Dates_Approved__c = true;
    ee.Start_Date__c = System.today();
    ee.X50_Cutoff_Date__c = System.today();
        ee.Event_Edition_Status__c = 'Completed';
    ee.Booth_Product_Type__c = 'Space Only';
        //insert ee; 
        
        Database.SaveResult result = Database.insert(ee, false);
        if(result.getErrors().size() > 0){
            System.assertEquals('Payment Schedule 1 Cutoff Date 1 should not greater than start date.',result.getErrors()[0].getMessage(), 'Here value is not same');    
        }
        
        ee.Booth_Product_Type__c = 'Shell Scheme';
        ee.Event_Edition_Status__c = 'Completed';
    update ee;
        
    System.assertEquals('Test GIri 2017', ee.Name, 'Success');
    EventCurrecies__c oEventCurrency = new EventCurrecies__c();
    oEventCurrency.Event_Edition__c = ee.Id;
        oEventCurrency.Name = 'INR';
    Insert oEventCurrency;
    
    
    Product2 prod = new Product2(Name = 'Laptop X200', Family = 'Hardware',CurrencyIsoCode='USD', Event_Edition_Pool__c = 'WOC', Event_Edition__c  =ee.Id );
    insert prod;
      
    Id pricebookId = Test.getStandardPricebookId();
    
    PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId,CurrencyIsoCode='USD', Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
    insert standardPrice;
      
    Pricebook2 customPB = new Pricebook2(Name = 'Custom Pricebook', isActive = true,CurrencyIsoCode='USD');
    insert customPB;

    Test.StartTest();
        PricebookEntry customPrice = new PricebookEntry(Pricebook2Id = customPB.Id,CurrencyIsoCode='USD', Product2Id = prod.Id, UnitPrice = 12000, IsActive = true);
    insert customPrice;
                
    date d = Date.today(); 
    ee.Alternate_Currency__c = 'USD';
    ee.Event_Edition_Status__c = 'Completed';
    ee.Event_Currency__c = 'AED';
    ee.EventCurrency__c = oEventCurrency.Id;
    ee.Payment_Schedule__c = '50-50';
    ee.Cutoff_Date_1__c = d;  
    update ee; 
    Account acc= new Account();
        acc.Name='Adarsh';
        insert acc;
        
        Contact oCon = new Contact(LastName='ContTest1', Email='test1contact@duptest.com', AccountId = acc.Id, MailingStreet = 'Test',MailingCity ='Test',MailingState='',MailingCountry='India', MobilePhone = '2121212145');
        insert oCon;  
      Opportunity opp=new opportunity(Name='TestOpp');
        opp.AccountId=acc.Id;
        opp.CloseDate = Date.newInstance(2019, 10, 03);
        opp.StageName = 'Proposal sent';
        opp.EventEdition__c= ee.Id;
       // opp.Main_Contract__c=contracts.Id;
        opp.Billing_Contact__c=oCon.Id;
        Insert opp;
        
        Booth_Product_Type_Configuration__c bpt = new Booth_Product_Type_Configuration__c();
        bpt.Booth_Product_Type__c = 'Space Only';
        bpt.Matched_Product_Name__c = 'Space Only';
        bpt.CurrencyIsoCode = 'USD';
        insert bpt;
        
        WorkOrder wo = new WorkOrder();
        wo.Work_Order_Name__c = 'Test Work Order';
        wo.Event_Edition__c = ee.Id;
        wo.Status = 'New'; 
        wo.Opportunity__c =opp.Id ;
        insert wo;
        
        WorkOrderLineItem woli= new WorkOrderLineItem();
      //  woli.Task_Name__c = wo.Name;
        woli.WorkOrderId = wo.Id;
        woli.status = 'New';
        insert woli;
        
        TriggerInterfaceHelper.runTrigger('EventEditionTrigg_Handler','Event_Edition__c',2, 'au', null,null,'All');
        //TriggerInterfaceHelper.runTrigger('EventEditionTrigg_Handler','Event_Edition__c',2, 'bu', null,null,'All');
        
        Test.StopTest();
  }
}