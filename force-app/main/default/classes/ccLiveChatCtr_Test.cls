@isTest
public class ccLiveChatCtr_Test
{
    public static testMethod void ccLiveChatCtrTest1()  
    {
        Account acc  = new Account();
        Contact con = new Contact();
        User u = new User();
        
        acc = new account(Name = 'TestLName');
        insert acc;
        System.AssertNotEquals(acc, null, 'Error Account Not Created');

        con = new Contact(LastName = 'User', FirstName = 'Test', Email ='johnabimo@gmail.com', AccountId = acc.id);
        insert con;
        System.AssertNotEquals(con, null, 'Error Contact Not Created');
        
        Brand__c oBrand = new Brand__c(Name = 'World of Concrete', SSC_Email_Distribution_ID__c = 'test@test.tst');
        insert oBrand;
            
        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', Status__c = 'Active', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Brand__c = oBrand.id, Event_Edition_Pool__c = 'WOC');
        insert oEventseries;
  
        Event_Edition__c oEve = new Event_Edition__c();
        oEve.Name='Test Event 2017';
        oEve.Part_of_Series__c = oEventseries.ID;
        oEve.Event_Code__c='TEV17';
        insert oEve;
        System.assertEquals(oEve.Event_Code__c,'TEV17', 'Event Code');
        
        ChatSupportTeam__c cs = new ChatSupportTeam__c();
        cs.AgentDevName__c = 'EmbeddedServiceLiveAgen';
        cs.Button_ID__c = 'Test Button';
        cs.Chat_Deployment__c = 'UAT_ME_Chat_Deployment';
        cs.Deployment_Id__c = 'Deployment Ids';
        cs.SupportTeam__c = 'ME Team';
        insert cs;
        
        Event_Settings__c eve = new Event_Settings__c();
        eve.Event_Edition__c = OEve.Id;
        eve.IM_EventEditionId__c = 'a3dwsdefghtrdbjh';
        eve.Live_Agent_Online__c = false;
        eve.CS_Team__c = cs.Id;
        insert eve;
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User Custom'];
        u = new User(Alias = 'standt', Email = 'kumarusertskndskndsk@test123org.com',
                     EmailEncodingKey = 'UTF-8', LastName = 'Kumar', LanguageLocaleKey = 'en_US',
                     LocaleSidKey = 'en_US', ProfileId = p.Id, contactID=con.Id,
                     TimeZoneSidKey = 'America/Los_Angeles', UserName = 'kumarusertskndskndsk12345@testorg.com');
        insert u;
        //System.runAs(u){
        String eventcode;
        PageReference pageRef = Page.ccLiveChat;
        pageRef.getParameters().put('Referer','https://qa-informamarkets.cs44.force.com/CustomerCenter/s/?eventcode=SBARHE1&eventedition=AEL21DAH');
        
        Test.setCurrentPageReference(pageRef);
        Test.StartTest();
            ccLiveChatCtr ctr = new ccLiveChatCtr();
            ctr.getCurrentUserContact();
        Test.StopTest();
       // }
    }
}