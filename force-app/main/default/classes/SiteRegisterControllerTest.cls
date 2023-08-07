/**
* Created By:  Camille Ward
* Created On:   22/11/2016
* @description :This test class containing tests for SiteRegisterController 
* Apex Class: SiteRegisterController (88%) 
* Modified by   :  Himanshu Jasuja [BK -3719] on 25/03/2020 
**/


@IsTest 
	public with sharing class SiteRegisterControllerTest {
    Public static testMethod void testRegistration() {
        SiteRegisterController controller = new SiteRegisterController();    
        
        Account a = new Account(Name='Test Big Co');
        Insert a;
        
        Contact c = new Contact(LastName='TestUser', Email='testUser@bigCo.com', AccountId=a.Id);
        Insert c;
        
        Profile pf= [Select Id from profile where Name='System Administrator'];
        User u = new User(); 
        u.LastName = 'test';
        u.Username = 'testUser@bigCo.com';
        u.Email = 'testUser@bigCo.com';
        u.CommunityNickname = 'testUser';   
        u.EmailEncodingKey = 'ISO-8859-1';
        u.Alias = 'nju123'; 
        u.TimeZoneSidKey = 'America/Los_Angeles'; 
        u.LocaleSidKey = 'en_US';
        u.LanguageLocaleKey = 'en_US'; 
        u.ProfileId = pf.Id;
        insert u;
       
        controller.username = 'test@force.com';
        controller.email = 'test@force.com';
        controller.communityNickname = 'test';
       
        
        // registerUser will always return null when the page isn't accessed as a guest user
        System.assertNotEquals(controller.registerUser() == null ,null, 'false');     
               
        PageReference pageRef = Page.SiteRegisterConfirm;
        Test.setCurrentPage(pageRef);
        controller.password = 'abcd1234';
        controller.confirmPassword = 'abcd1234';
         
        System.assertNotEquals(controller.registerUser() == null ,null, 'false');  

    }
        
        
}