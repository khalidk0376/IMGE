/**
* Created/Modified By: Girikon(Aishwarya )
* Created On:         18-09-2019
* Methods:            multiMethod
* Class:              DefaultCtrl
* Modification log --
* Modified By: 
**/

@isTest
public class DefaultCtrl_Test {

    static testMethod  void multiMethod()
    {
        Account testAccount = new Account();
        testAccount.Name='Test Account' ;
        insert testAccount;
        
        Event_Edition__c evntEdtn = new Event_Edition__c(Name='TestName',Event_Currency__c='USD',Event_Code__c='XYZ');
        insert evntEdtn;
        
        string evntId1=string.valueOf(evntEdtn.Event_Code__c);
        System.AssertNotEquals(evntEdtn, null,'Event Edition should not be null');
        Test.StartTest(); 
            //PageReference pageRef = Page.cclogin; // Referring VF page name
            //Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('eventcode',evntId1);
            DefaultCtrl dfultCtrl  = new DefaultCtrl();
            dfultCtrl.eventCode = 'test event code';
            dfultCtrl.redirectCommunity();
            dfultCtrl.redirectToResetPassword();
        
        Test.StopTest();
        
    }
    
}