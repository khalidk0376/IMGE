@isTest
public with sharing class InitiateExhibitorInviteBatch_Test {

    @testSetup
    static void testdataSetupMethod(){
        
        Account acc = new Account();
        acc.Name='Test1';
        insert acc;
        Account acc1 = new Account();
        acc1.Name='Test2';
        insert acc1;
        
        Event_Edition__c event = new Event_Edition__c();
        event.Name = 'test' ;
        event.X3E_API_ID__c = 'test';
        event.X3E_Status__c = 'Active';
        event.X3rd_Party_Relationship__c = '3E ExpoCAD';
        event.Auto_Invite_Exhibitor_in_3E__c = true ; 
        insert event;
        
        List<Opportunity> oppList = new List<Opportunity>();
        for(Integer i=0;i<5;i++){
        Opportunity opp = new Opportunity();  
        opp.Partner_Account__c = acc.Id;
        opp.AccountId = acc1.Id;
        opp.Name = 'opp Test' + i;
        opp.StageName = 'Prospecting'; 
        opp.CloseDate = System.today() + 30;
        opp.EventEdition__c = event.Id;
        oppList.add(opp);
        }

        insert oppList;
        
        
        API_Synchronization_Transaction__c newAPISynchronizationTransaction = new API_Synchronization_Transaction__c();
        newAPISynchronizationTransaction.Status__c = 'Paused';
        newAPISynchronizationTransaction.Started_From__c = 'Opportunity';
        newAPISynchronizationTransaction.X3rd_Party_Relationship__c = '3E ExpoCAD';
        newAPISynchronizationTransaction.Request_Type__c = 'Synchronous';
        insert newAPISynchronizationTransaction;
        
        API_Synchronization_Item__c newSynchronousItem = new API_Synchronization_Item__c();
        newSynchronousItem.Status__c = 'Paused';
        newSynchronousItem.API_Synchronization_Transaction__c = newAPISynchronizationTransaction.Id;
        newSynchronousItem.API_Call_Type__c = 'PUT';
        newSynchronousItem.X3rd_Party_Relationship__c = '3E ExpoCAD';
        newSynchronousItem.Type__c = '3E Expocad Exhibitor Invite'; 
        newSynchronousItem.Error_Message__c = '';
        newSynchronousItem.Opportunity__c = oppList[0].Id;
        newSynchronousItem.Request_Body__c = '3E Expocad Exhibitor Invite';
        insert newSynchronousItem;


        
    }
    @isTest
    static void testInitiateExhibitorInviteBatch(){
        Set<Id> eventIds = new Set<Id>();
        List<Event_Edition__c> events = [SELECT Id,Name FROM Event_Edition__c ];
        //System.debug('3'+events);
        for(Event_Edition__c event :events ){
            eventIds.add(event.Id); 
        }
        InitiateExhibitorInviteBatch batchClass = new InitiateExhibitorInviteBatch(eventIds);
        Id batchProcessedId = Database.executeBatch(batchClass);
        System.assertNotEquals(null, batchProcessedId,'Value cannot be Null');//EX-101
    }

}