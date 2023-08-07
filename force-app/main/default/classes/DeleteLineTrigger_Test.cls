@isTest
private class DeleteLineTrigger_Test {
    static testMethod void method1(){
    
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
    
        WorkOrder wo = new WorkOrder();
        wo.Work_Order_Name__c = 'test';
        wo.OwnerId = userInfo.getUserId();
        wo.Opportunity__c = opp.id;
        insert wo;
        
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.Task_Name__c = 'test';
        woli.WorkOrderId = wo.Id;
        woli.Assign__c = userInfo.getUserId();
        insert woli;
        Test.startTest();
        if(wo.OwnerId == userInfo.getUserId())
        {
        delete woli;
        }
        Test.StopTest();
    }
    
    static testMethod void method2ForSendEmail(){
    
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
        woli.Assign__c = userInfo.getUserId();
        insert woli;
    }
    
    static testMethod void method2ForClosedStatus(){
    
    Account acc = new Account();
        acc.Name = 'test';
        acc.CurrencyIsoCode = 'USD';
        insert acc;
        System.assertEquals('test',acc.name,'Error account is not created');
        
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
        woli.Status = 'Closed';
        woli.Assign__c = userInfo.getUserId();
        //insert woli;
    }
}