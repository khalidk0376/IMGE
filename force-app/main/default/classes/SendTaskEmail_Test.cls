/*
 * File         :   SendTaskEmail_Test
 * Project      :   IM GE
 * Created Date :   17th Oct 2022
 * Created By   :   Girikon(Palla Kishore)
 * ***************************************************************************
 * @description : Test Class to cover SendTaskEmail
 */

@isTest	
public class SendTaskEmail_Test {

    @isTest
    static void sendEmailTest(){
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        List<User> userList = new List<User>();
        User u = new User(
            ProfileId = profileId,
            LastName = 'last',
            Email = 'puser_rpc@test.com',
            Username = 'puser_rpc@test.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        User u1 = new User(
            ProfileId = profileId,
            LastName = 'last',
            Email = 'puser_rpc1@test.com',
            Username = 'puser_rpc1@test.com' + System.currentTimeMillis(),
            CompanyName = 'TEST 1',
            Title = 'title 1',
            Alias = 'alias1',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        userList.add(u);
        userList.add(u1);
        insert userList;
        System.runAs(u) {
            //@Description: Insert Account.
            Account acc = new Account();
            acc.Name = 'Testing Account'; 
            acc.CurrencyIsoCode = 'USD';
            insert acc;
            System.assertEquals('Testing Account',acc.name,'Error account is not created');
            
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
            //eventEdition.Event_Edition_Status__c = 'Active';
            insert eventEdition;
            
            //@Description: Insert Opportunity.
            Opportunity opp = new Opportunity();
            opp.Name = 'Testing Opportunity';
            opp.EventEdition__c = eventEdition.Id;
            opp.Opportunity_Contact__c = ocontact.Id;
            opp.AccountId = acc.Id;
            opp.CloseDate = Date.Today().addDays(1);
            opp.StageName = 'Customise';
            insert opp;
            
            List<Group> queuesList = [SELECT Id FROM Group WHERE (DeveloperName = 'UK_SSC' OR DeveloperName = 'Egypt_SSC') AND Type = 'Queue'];
            List<GroupMember> groupMemList = new List<GroupMember>();
            List<Task> taskList = new List<Task>();
            if (!queuesList.isEmpty()) {
                for (Group queue : queuesList) {
                    groupMemList.add(new GroupMember(GroupId = queue.Id, UserOrGroupId = Userinfo.getUserId()));
                    groupMemList.add(new GroupMember(GroupId = queue.Id, UserOrGroupId = u1.Id));
                    taskList.add(new Task(WhatId = opp.Id, Subject = 'Test Task', OwnerId = queue.Id));
                }
            }
            insert groupMemList;
            insert taskList;
            System.assertEquals(2 , taskList.size(), 'Tasks are created:');
            SendTaskEmail.sendEmail(taskList);
            
        }
    }
}