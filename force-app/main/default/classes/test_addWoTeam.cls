/**
 * @Author      : 
 * @Date        : 
 * Apex Class : 
 * * Modified By : Rajesh kumar Yadav Bk-3751, [Modified By : Aishwarya 12 Aug 2020 BK-3751]
 */
@isTest

public class test_addWoTeam{
    static testMethod void method_01(){
    
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
        system.assertEquals(ee.Name, 'TestEvent', 'Both values should be the same.');
        Account acct=new Account(Name='testAccount',CurrencyIsoCode='EUR');
        insert acct;
        
        Opportunity oppty=new Opportunity(Name='testOpp',EventEdition__c=ee.Id);
        oppty.AccountId=acct.Id;
        oppty.StageName='Needs Assessment';
        oppty.CloseDate=date.today();
        insert oppty;
               
        Profile p = [SELECT Id, Name FROM Profile WHERE Name='Standard User'];
        system.assertEquals(p.Name, 'Standard User', 'profile name Standard User'); 
        User u = new User(Alias = 'stndt', Email='stander@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='stanusertestu@testorg.com');
        insert u;
        system.assertEquals(u.ProfileId, p.id, 'profile Id must be same'); 
        
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
        system.assertEquals(wot.Operations_Team__c, objTeam.id, 'Operation team id must be same'); 
        
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
        system.assertEquals(objTeamMemb.User_Name__c, u.Id, 'user id should be equals to ops team member');
        
        objTeamMemb.User_Name__c = u2.id;
        update objTeamMemb;
        
        delete objTeamMemb;
    }
    
     
}