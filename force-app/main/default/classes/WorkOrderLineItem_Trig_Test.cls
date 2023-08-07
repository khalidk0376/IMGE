/**
 * Created By: Palla Kishore(Girikon)
 * Created On:          06/06/2022
 * Description/Purpose: This test class covers the apex class : Trigger_WorkOrderLineItem, TriggerInterface_WorkOrderLineItem, WorkOrderLineItem_Trig
 * Methods:             workOrderLITestMethod,workOrderLITestMethod2
 * Apex Class:          Trigger_WorkOrderLineItem, TriggerInterface_WorkOrderLineItem, WorkOrderLineItem_Trig
**/
@isTest
public class WorkOrderLineItem_Trig_Test {
    @isTest static void workOrderLITestMethod(){
        Test.startTest();
        
        Trigger__c trig = new Trigger__c(Name = 'WorkOrderLineItem_Trig' , Trigger_Name_Unique__c='WorkOrderLineItem_Trig',Enabled__c=true,Object__c='WorkOrderLineItem',Run_for_Recordypes__c='All',  Description__c='my test',Execution_Order__c=2,
                                         Before_Insert__c=true,Before_Delete__c=true , After_Delete__c = true,Before_Update__c=true,After_Update__c = true);
        insert trig;
        Trigger_Recordtype__c rrrt = new Trigger_Recordtype__c(Recordtype_Id__c=trig.Id , Trigger__c=trig.Id,Enabled__c=true, Parameters__c='param=1;param=2');
        Insert rrrt; 
        
        TriggerInterface_WorkOrderLineItem obj=new TriggerInterface_WorkOrderLineItem();
        
        TriggerInterfaceHelper.runTrigger('WorkOrderLineItem_Trig','WorkOrderLineItem', 2, 'ai', rrrt.id ,rrrt.Parameters__c,'All');
        TriggerInterfaceHelper.runTrigger('WorkOrderLineItem_Trig','WorkOrderLineItem', 2, 'au', rrrt.id ,rrrt.Parameters__c,'All');
        
        Account acc = new Account();
        acc.Name = 'test';
        acc.CurrencyIsoCode = 'USD';
        insert acc;
        System.assertEquals('test', acc.name,'Error account is not created');
        
        opportunity opp = new opportunity();
        opp.AccountId = acc.Id;
        opp.Name ='test';
        opp.CurrencyIsoCode = 'USD';
        opp.CloseDate = System.Today();
        opp.StageName = 'Need Assessment';
        opp.Contract_Attached__c = True;
        insert opp;
        
        WorkOrder_Team__c wtTeam = new WorkOrder_Team__c ();
        wtTeam.Team_Member__c = userInfo.getUserId();
        wtTeam.CurrencyIsoCode = 'USD';
        insert wtTeam;
        
        WorkOrder wo = new WorkOrder();
        wo.Work_Order_Name__c = 'test';
        wo.OwnerId = userInfo.getUserId();
        wo.Opportunity__c = opp.id;
        insert wo;
        
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.Task_Name__c = 'test';
        woli.WorkOrderId = wo.Id;
        woli.Assign_To__c = wtTeam.id;
        insert woli;
        
        woli.Assign__c = userInfo.getUserId();
        woli.Status = 'Closed';
        update woli;
        Test.stopTest();
        
    }
    @isTest static void workOrderLITestMethod2(){
        Test.startTest();
        
        Trigger__c trig = new Trigger__c(Name = 'WorkOrderLineItem_Trig' , Trigger_Name_Unique__c='WorkOrderLineItem_Trig',Enabled__c=true,Object__c='WorkOrderLineItem',Run_for_Recordypes__c='All',  Description__c='my test',Execution_Order__c=2,
                                         Before_Insert__c=true,Before_Delete__c=true , After_Delete__c = true,Before_Update__c=true,After_Update__c = true);
        insert trig;
        Trigger_Recordtype__c rrrt = new Trigger_Recordtype__c(Recordtype_Id__c=trig.Id , Trigger__c=trig.Id,Enabled__c=true, Parameters__c='param=1;param=2');
        Insert rrrt; 
        
        TriggerInterface_WorkOrderLineItem obj=new TriggerInterface_WorkOrderLineItem();
        
        TriggerInterfaceHelper.runTrigger('WorkOrderLineItem_Trig','WorkOrderLineItem', 2, 'ai', rrrt.id ,rrrt.Parameters__c,'All');
        TriggerInterfaceHelper.runTrigger('WorkOrderLineItem_Trig','WorkOrderLineItem', 2, 'au', rrrt.id ,rrrt.Parameters__c,'All');
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User u = new User(
            ProfileId = p.Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert u;
        Account acc = new Account();
        acc.Name = 'test';
        acc.CurrencyIsoCode = 'USD';
        insert acc;
        System.assertEquals('test', acc.name,'Error account is not created');
        
        opportunity opp = new opportunity();
        opp.AccountId = acc.Id;
        opp.Name ='test';
        opp.CurrencyIsoCode = 'USD';
        opp.CloseDate = System.Today();
        opp.StageName = 'Need Assessment';
        opp.Contract_Attached__c = True;
        insert opp;
        Brand__c oBrand = new Brand__c(Name = 'World of Concrete', SSC_Email_Distribution_ID__c = 'test@test.tst');
        insert oBrand;
        
        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Brand__c = oBrand.id, Event_Edition_Pool__c = 'WOC');
        insert oEventseries;
        
        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017',Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information', Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = 'Space Only', Expocad_API_Url__c = 'test.com', Part_of_Series__c = oEventseries.id, Booth_Classes_on_Template__c = 'Temp', Corner_Configuration_Check__c = false, Product_Type_Order__c = 'BoothA;;BoothB');
        insert oEvent;
        
        Product2 prd = new Product2(Name = 'Booth Package WOC', Family = 'Booth', Number_of_Corners__c = 0, Booth_Type__c = 'esc', Show_In_Show__c = 'Indoor', Booth_Class__c = 'fsdf', Event_Edition_Pool__c = 'WOC', Event_Edition__c = oEvent.Id);
        insert prd;
        WorkOrder_Team__c wtTeam = new WorkOrder_Team__c ();
        wtTeam.Team_Member__c = userInfo.getUserId();
        wtTeam.CurrencyIsoCode = 'USD';
        insert wtTeam;
        
        WorkOrder wo = new WorkOrder();
        wo.Work_Order_Name__c = 'test';
        wo.OwnerId = u.Id;
        wo.AccountId = acc.id;
        wo.Product_Name__c = prd.id;
        wo.Opportunity__c = opp.id;
        wo.Event_Edition__c = oEvent.Id;
        insert wo;
        workorder wo1 = [select id , ownerId,owner.Email from Workorder];
        system.debug('wo1::::'+wo1);
        Folder myfolder =[select id from Folder where Folder.name='Conga Preview Documents' LIMIT 1];
        Document document;
        
        document = new Document();
        document.Body = Blob.valueOf('Some Text');
        document.ContentType = 'application/pdf';
        document.DeveloperName = 'my_document';
        document.IsPublic = true;
        document.Name = 'EmailTemplateFooter_Logo';
        document.FolderId = myfolder.id;
        insert document;
        document = new Document();
        document.Body = Blob.valueOf('Some Text');
        document.ContentType = 'application/pdf';
        document.DeveloperName = 'my_document1';
        document.IsPublic = true;
        document.Name = 'EmailTemplateHeader_Logo';
        document.FolderId =myfolder.id;
        insert document;
        
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.Task_Name__c = 'test';
        woli.WorkOrderId = wo.Id;
        woli.Assign_To__c = wtTeam.id;
        insert woli;
        woli.Assign__c = userInfo.getUserId();
        woli.Status = 'Completed';
        update woli;
        Test.stopTest();
        
    } 
}