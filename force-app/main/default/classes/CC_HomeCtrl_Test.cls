/*
Created By		: Girikon(Sunil[STL-18])
Created On		: Aug 01 2019
@description 	: This class is the test class of CC_HomeCtrl.
Test Class		: 

Modification log --
Modified By		:  
*/
@isTest
public with sharing class CC_HomeCtrl_Test {
    
    @isTest static void ccHomeCtrlData()
    {
        Profile pro = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User Custom'];
        
        //Create User_Type__c
        User_Type__c uTypeExh = new User_Type__c(Name='Exhibitor');
        insert uTypeExh;
        System.AssertNotEquals(uTypeExh, null, 'UserType must have a name');
        
        //Create Account record
        Account acc = new account();
        acc.Name = 'Kevin & Co.';
        insert acc;
        System.assertNotEquals(null, acc.Name, 'Account Name must not be null');
        
        //Create Contact
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.FirstName = 'TestConFirst';
        con.LastName = 'TestConLast';
        con.Email='abc@test.com';
        insert con;
        System.assertNotEquals(null, con.LastName, 'Contact Name must not be null');
        
        //Create User record
        User usr = new User();
        usr.FirstName = 'Kevin';
        usr.LastName = 'Doe';
        usr.Email = 'test@test.com';
        usr.Username = 'atest@test.com';
        usr.Alias = 'astest';
        usr.ContactId = con.Id;
        usr.ProfileId = pro.Id;
        usr.TimeZoneSidKey    = 'America/Denver';
        usr.LocaleSidKey      = 'en_US';
        usr.EmailEncodingKey  = 'UTF-8';
        usr.LanguageLocaleKey = 'en_US';
        insert usr;
        
        //Create event edition
        Event_Edition__c eventEdition = new Event_Edition__c(Name='Arab Health 2019',Event_Code__c='sbah19',End_Date__c=System.Today(),Start_Date__c=System.Today());
        insert eventEdition;
        
        //Create Opportunity
        Opportunity oOpportunity = new Opportunity(Name = 'Expocad Opportunity', CloseDate = Date.today(),StageName = 'Discover', 
                                                   EventEdition__c = eventEdition.Id, Operations_Contact__c=con.Id,  AccountId = acc.Id, Billing_Contact__c = con.Id, Opportunity_Contact__c=con.id, User_Type__c = uTypeExh.Id); 
        insert oOpportunity;
        
        //Create Quote 
        SBQQ__Quote__c oQuote = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Quote Sent', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = oOpportunity.Id, SBQQ__Account__c =acc.Id, SBQQ__Primary__c = true);
        insert oQuote;
       	
        oOpportunity.SBQQ__PrimaryQuote__c = oQuote.Id;
        oOpportunity.StageName = 'Closed Won';
        update oOpportunity;
        
        
        
        //Create Event_Settings__c
        Event_Settings__c eventSet = new Event_Settings__c();
        eventSet = new Event_Settings__c(Name='Test',About_Show__c='Test',ShowHours1__c='test',ShowHours2__c='Test',Branding_Color__c='Black',Link_1__c='http://m.www.google.com/',Is_Stand_Design_Visible__c=True,Is_Stand_Detail_Visible__c=True,Is_SubContractors_Visible__c=True,Is_Amount_Visible__c=True,
                                                                Link_2__c='http://m.www.google.com/',Link_3__c='http://m.www.google.com/',Link_4__c='http://m.www.google.com/',Link_1_Label__c='TestLink1',Link_2_Label__c='TestLink2',Link_3_Label__c='TestLink3',Link_4_Label__c='TestLink4',
                                                                FaceBook__c='http://m.www.facebook.com/',LinkedIn__c='http://m.www.linkedin.com/',Twitter__c='http://m.www.Twitter.com/',YouTube__c='http://m.www.youtube.com/',Custom_1_Title__c='CstmTitle',Event_Edition__c=eventEdition.Id,E_Commerce_Title__c='EC Title',Welcome_Stand_Contractor__c='WSC Test',Disable_this_information__c=True);
        insert eventSet;
        
        //create ExpocadBooth__c
        ExpocadBooth__c expBooth = new ExpocadBooth__c(Booth_Number__c='TestBoothNo',Dimensions__c = '5M x 10M',Area__c ='50 m²',status__c='Rented',Matched_Product_Name__c='Pavilion Space');
        insert expBooth;
        
        
        //create Opportunity_ExpoCAD_Booth_Mapping__c
        Opportunity_ExpoCAD_Booth_Mapping__c oppBooth=new Opportunity_ExpoCAD_Booth_Mapping__c();
        oppBooth.Account__c=acc.Id;
        oppBooth.Status__c='Active';
        oppBooth.Quote__c = oQuote.Id;
        oppBooth.Expocad_Booth__c=expBooth.id;
        insert oppBooth;
        
        System.runAs(usr)
        {
            Test.startTest();
        	String eventCode = 'sbah19';
        	CC_HomeCtrl.getOppBoothDetails(eventCode);
            CC_HomeCtrl.checkPermission(eventCode,acc.Id);
        	Test.stopTest();
        }
    }
}