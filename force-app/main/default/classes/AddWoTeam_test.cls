/**
 * Project:         GAP
 * Date:            23/09/2016
 * Test Class For:  addWoTeam.Trigger
 * Created By:      Rajesh Kumar
 * Code Coverage:   82% Coverage
 * Modified By: Rajesh Kumar
 * @description This class is used in "addWoTeam" Trigger.
 */

@isTest
public class AddWoTeam_test{
    static testMethod void addWoTeamMethod(){
        Pricebook2 pb=new Pricebook2(Name='TestPricebook');
        insert pb;
        Event_Edition__c ee=new Event_Edition__c();
        ee.Name='TestEvent';
        ee.Tab1__c='tab1';
        ee.Tab4__c='tab4';
        ee.Tab7__c='tab7';
        ee.Tab8__c='Tab8__c';
        ee.Event_Price_Book__c=pb.Id;
        insert ee;
        Account acct=new Account(Name='testAccount',CurrencyIsoCode='EUR');
        insert acct;
        Opportunity oppty=new Opportunity(Name='testOpp',EventEdition__c=ee.Id);
        oppty.AccountId=acct.Id;
        oppty.StageName='Discover';
        oppty.CloseDate=date.today();
        insert oppty;
        
        System.assertEquals(oppty.StageName ,'Discover', 'Revalidate the opportunity to be inserted');
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'stndt', Email='stander@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='stanusertestu@testorg.com');
        insert u;
        User u2 = new User(Alias = 'stndt', Email='stander@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='stanusertest2@testorg.com');
        insert u2;
        Operations_Team__c objTeam = new Operations_Team__c();
        objTeam.Operations_Team_Description__c = 'Test';
        insert objTeam;
        Work_Order_Template__c wot = new Work_Order_Template__c();
        wot.Name = 'test';
        wot.CurrencyIsoCode = 'USD';
        wot.Operations_Team__c = objTeam.id;
        insert wot;
        WorkOrder wo = new WorkOrder();
        wo.Work_Order_Name__c = 'test';
        wo.OwnerId = userInfo.getUserId();
        wo.Status = 'Closed';
        wo.Opportunity__c = oppty.Id;
        wo.Work_Order_Template__c =wot.Id;
        insert wo;
        WorkOrder_Team__c objWOTeam = new WorkOrder_Team__c();
        objWOTeam.Work_Order_Template__c = wot.id;
        objWOTeam.Team_Member__c = u2.id;
        objWOTeam.Work_Order__c=wo.id;
        insert objWOTeam;
        Operations_Team_Member__c objTeamMemb = new Operations_Team_Member__c();
        objTeamMemb.Operations_Team__c = objTeam.id;
        objTeamMemb.User_Name__c = u.Id;
        insert objTeamMemb;
        objTeamMemb.User_Name__c = u2.id;
        update objTeamMemb;
        delete objTeamMemb;
    }
}