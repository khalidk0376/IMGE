/**
 * @Author      : 
 * @Date        : 
 * Apex Class : 
 * * Modified By : Rajesh kumar Yadav Bk-3751,[Modified By : Aishwarya 12 Aug 2020 BK-3751]
 */
@isTest
public class createAndUpdateWorkOrderTeam_test {
    static testMethod void method_01(){
        
        Operations_Team__c objTeam = new Operations_Team__c();
        objTeam.Operations_Team_Description__c = 'Test';
        insert objTeam;
        System.assertEquals(objTeam.Operations_Team_Description__c,'Test', 'Value should be equals');
        
        Operations_Team_Member__c objTeamMemb = new Operations_Team_Member__c();
        objTeamMemb.Operations_Team__c = objTeam.id;
        objTeamMemb.User_Name__c = userinfo.getuserId();
        insert objTeamMemb;
        System.assertEquals(objTeamMemb.User_Name__c, userinfo.getuserId(), 'Value should be equals');
        
        Work_Order_Template__c wot = new Work_Order_Template__c();
        wot.Name = 'test';
        wot.CurrencyIsoCode = 'USD';
        wot.Operations_Team__c = objTeam.id;
        insert wot;
        system.assertEquals(wot.Name, 'test', 'Both values should be the same.');
        wot.Name='testUpdate';
        update wot;
        
        
        Profile p = [SELECT Id, Name FROM Profile WHERE Name='Standard User'];
        system.assertEquals(p.Name, 'Standard User', 'profile name Standard User'); 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduserGAPTest@testorg.com');

        System.runAs(u) {
             WorkOrder_Team__c objWOTeam = new WorkOrder_Team__c();
            objWOTeam.Work_Order_Template__c = wot.id;
            objWOTeam.Team_Member__c = u.Id;
            insert objWOTeam;

        }

       // wot.Name='testUpdate';
      //  update wot;
    }
}