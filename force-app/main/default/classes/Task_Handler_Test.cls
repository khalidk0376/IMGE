/**
* Class Name: Task_Handler
* Created By : Faisal Khan
* Created Date : 13/03/2023
* Test Class: Task_Handler_test(90%)
*/
@isTest
private class Task_Handler_Test {
    
    @testSetup 
        private static void testDataSetup() {
        Trigger__c trig = new Trigger__c(Name = 'Task_Handler' , Trigger_Name_Unique__c = 'Task_Handler', Enabled__c = true, Object__c = 'Task', Run_for_Recordypes__c = 'All',  Description__c = 'my test', Execution_Order__c = 1, Before_Update__c = true, Before_Insert__c = true );
        Insert trig;
        Account oAccount1 = new Account(Name = 'Test Account 1', CurrencyIsoCode = 'USD', Brand__c = 'Expocad', BillingCountry = 'USA');
        Insert oAccount1;
        Contact oCon1 = new Contact(LastName = 'Test Contact 1', Email = 'test1@contact.com', AccountId = oAccount1.Id, MailingStreet = 'Test', MailingCity = 'Test', MailingState = '', MailingCountry = 'India', Contact_Type__c = 'Primary Contact');
        Insert oCon1;
        Brand__c oBrand = new Brand__c(Name = 'World Of Concrete', Business_Unit__c = 'Life Science');
        Insert oBrand;
        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', Brand__c = oBrand.Id , CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Event_Edition_Pool__c = 'WOC');
        Insert oEventseries;
        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017', Booth_Rent_Stage__c = 'On Payment', Tab7__c = 'Test', Tab1__c = 'Test', Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Edition_Code__c = 'Test321', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = 'Barter Shell Scheme', Start_Date__c = Date.today(), Part_of_Series__c = oEventseries.id);
        Insert oEvent;
        EventCurrecies__c ecr = new EventCurrecies__c(Name = 'Test', Event_Edition__c = oEvent.Id);
        insert ecr;
    
        Test.startTest();
          //Call contact trigger interface
        TriggerInterface_Task obj=new TriggerInterface_Task();
        
        //Call trigger app handler
        TriggerInterfaceHelper.runTrigger('Task_Handler','Task',99, 'bi,bu', null,null,'All');
        
          Opportunity oOpportunity = new Opportunity(Name = 'Test Opportunity',Type = 'Existing Business',CurrencyIsoCode = 'ZAR',Payment_Status__c = 'Not Paid', Opportunity_Contact__c = oCon1.Id, CloseDate = Date.today(), StageName = 'Customize', EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id, AccountId = oAccount1.Id, Billing_Contact__c = oCon1.Id, Exhibitor_Paid_By__c = 'Exhibitor Paid by Exhibitor');
        Insert oOpportunity;
          
        Group queueObj=[SELECT Id,Name FROM Group WHERE Type = 'Queue' AND Name = 'Egypt SSC'];

        Utility.triggerBIExecuted=false;
        Task tsk = new Task();
        tsk.Subject = 'OtherTest';
        tsk.CurrencyIsoCode = 'USD';
        tsk.Priority='Normal';
        tsk.Status = 'Open';
        tsk.WhatId=oOpportunity.Id;
        tsk.OwnerId=queueObj.id;
        insert tsk;
          
          Task tsk1 = new Task();
          tsk1.Subject = 'OtherTest123';
          tsk1.CurrencyIsoCode = 'USD';
          tsk1.Priority='Normal';
          tsk1.Status = 'Open';
          tsk1.WhatId=oOpportunity.Id;
          tsk1.OwnerId=UserInfo.getUserId();
          insert tsk1;
          
          Task_Handler.returnWeekday(0);
          
     
       
      }
    
       @isTest
    private static void getTest1(){
        TriggerInterfaceHelper.runTrigger('Task_Handler','Task',99, 'bu', null,null,'All');

        Test.startTest();
        List<Task> taskObj=[Select id,ownerId,ActivityDate from Task where Subject='OtherTest'];
        System.debug('Query task'+taskObj);
        taskObj[0].ownerId=Userinfo.getUserId();
        update taskObj;
        Datetime datetoUpdate=Date.today();
        List<Task> taskObj1=[Select id,ownerId,ActivityDate from Task where Subject='OtherTest'];
        System.debug('QuerytaskObj'+taskObj1[0].ActivityDate);
        System.assertnotEquals(datetoUpdate, taskObj1[0].ActivityDate,'Dates will not be equal');
        Task_Handler.returnWeekday(2);
       Test.stopTest();

    }
    
        @isTest
    private static void getTest2(){
        TriggerInterfaceHelper.runTrigger('Task_Handler','Task',99, 'bu', null,null,'All');

        Test.startTest();
        List<Task> taskObj=[Select id,ownerId,ActivityDate from Task where Subject='OtherTest123'];
        Group queueObj=[SELECT Id,Name FROM Group WHERE Type = 'Queue' AND Name = 'Egypt SSC'];
        System.debug('Query task'+taskObj);
        taskObj[0].ownerId=queueObj.Id;
        update taskObj;
        List<Task> taskObj1=[Select id,ownerId,ActivityDate from Task where Subject='OtherTest123'];
        Datetime datetoUpdate;
        Date dateToday=Date.today();
        Date weekStart = dateToday.toStartofWeek();
        Integer Difference=weekStart.daysBetween(dateToday);
        String dayOfWeek=Task_Handler.returnWeekday(Difference);
        if(dayOfWeek=='Friday'){
            datetoUpdate=dateToday.adddays(3);
        } 
        else if(dayOfWeek=='Saturday'){
            datetoUpdate=dateToday.adddays(2);
        }
        else{
            Date dateTodayAdd=Date.today().adddays(1);
            Date weekStartAdd = dateTodayAdd.toStartofWeek();
            Integer DifferenceDay=weekStartAdd.daysBetween(dateTodayAdd);
            String dayOfWeekonAddtion=Task_Handler.returnWeekday(DifferenceDay);
            if(dayOfWeekonAddtion=='Friday'){
                datetoUpdate=dateTodayAdd.adddays(2);
            } 
            else if(dayOfWeekonAddtion=='Saturday'){
                datetoUpdate=dateTodayAdd.adddays(2);
            }
            else{
                datetoUpdate=Date.today().adddays(1);
            }
        }
           
//        Datetime datetoUpdate=Date.today().adddays(1);
        System.debug('datetoUpdate'+datetoUpdate+'  '+taskObj1[0].ActivityDate);
        System.assertEquals(datetoUpdate, taskObj1[0].ActivityDate,'dates should be same');
        Task_Handler.returnWeekday(3);
        Task_Handler.returnWeekday(6);
        Task_Handler.returnWeekday(7);
        Task_Handler.returnWeekday(1);
        Task_Handler.returnWeekday(4);
        Task_Handler.returnWeekday(5);
  
       Test.stopTest();

    }
}