/**
* Created By:  Girikon(Hemendra)
* Created On:  7 June 2018
* @description : This is a test class for AccountContactsCt.
* Methods: 
* Apex Class: AccountContactsCtr (89%)
* Modified Date: August 17, 2018 ,11/22/2018,04/16/2019
* Modified By : Mahesh Gupta (Girikon),Ashish (Girikon)[CCEN-502], Amish (CCEN-758
**/
@isTest
public class AccountContactsCtr_Test {
    //SetUp data for test class
    
    static testMethod void dataSetUp() 
    {
        // Setup test data
        // This code runs as the system user
        Profile prof = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User oUsr = new User(Alias = 'standt', Email='testsabbassas@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Kumar', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = prof.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='testsabbassasdadasa@testorg.com');
            Event_Edition__c oEve;
        List <User_Form_Action__c> ufaList = new List<User_Form_Action__c >();
        System.runAs(oUsr) 
        {
            User_Type__c uType = new User_Type__c(Name ='Agent Owned Exhibitor');
            insert uType;
            System.AssertEquals(uType.Name, 'Agent Owned Exhibitor','Both the Value should be match');
            
            //User Type Created 
            User_Type__c uTypeEx = new User_Type__c(Name ='Exhibitor');
            insert uTypeEx;
            System.AssertEquals(uTypeEx.Name, 'Exhibitor','Both the Value should be match');
            
            //Create Account
            Account oAcc = new Account(Name='TestAcc');
            insert oAcc;
            
            //create some contacts
            Contact oCon = new Contact(AccountId = oAcc.Id, FirstName = 'TestConFirst', LastName = 'TestConLast',phone='12346456', Email='abc@test.com',MailingCountry='USA',
                                        MailingStreet='123 Lake',MailingCity='Dallas',MailingState='Texas',MailingPostalCode='75039',Type__c=uType.Id);
            insert oCon;

            //Fetch community user profile from label
            string commUsrProfile='';
            If(Label.Community_User_Profile!= NULL)
            {
                commUsrProfile= Label.Community_User_Profile;
            }
            else
            {
                commUsrProfile='Customer Community Login User Custom';            
            }
            //Fetch community user profile
            Profile pro =[select id , Name from Profile Where Name =:commUsrProfile];
                        
            User usr = new User();            
            usr.FirstName = 'Alex';
            usr.LastName = 'Sherwood';
            usr.Email = 'test@wexeurope.com';
            usr.Username = 'astest@wexeurope.com';
            usr.Alias = 'astest';
            usr.ProfileId = pro.Id;
            usr.TimeZoneSidKey    = 'America/Denver';
            usr.LocaleSidKey      = 'en_US';
            usr.EmailEncodingKey  = 'UTF-8';
            usr.LanguageLocaleKey = 'en_US';
            usr.ContactId = oCon.Id;
            insert usr;
                      
            Event_Edition__c oEE = new Event_Edition__c(Name='TestName');
            insert oEE;
            
             //Create Event_Settings__c
            Event_Settings__c oEvntSttng = new Event_Settings__c(Name='Test',Event_Edition__c=oEE.Id,Welcome_Stand_Contractor__c='WSC Test');
            insert oEvntSttng;
            
            //create Opportunities
            Opportunity oObjOpp = new Opportunity(AccountId = oAcc.Id, Name = 'TestOpp',StageName='Needs Assessment', EventEdition__c=oEE.Id,closedate=system.today(), Billing_Contact__c=oCon.Id,Operations_Contact__c=oCon.Id,Operation_Contact_2__c=oCon.Id,Operation_Contact_3__c=oCon.Id,Operation_Contact_4__c=oCon.Id,Operation_Contact_5__c=oCon.Id,Opportunity_Contact__c=oCon.Id,User_Type__c=uType.Id);
            insert oObjOpp;
            oObjOpp.StageName='Closed Won';
            update oObjOpp;
            System.debug('&&& ' +oObjOpp);

            List<ContactEventEditionMapping__c> conevmap = new List<ContactEventEditionMapping__c>();
            insert conevmap;
            System.debug('*** '+conevmap);
            System.AssertEquals(conevmap.isEmpty(), true,'Both the Value should be match');
            
            AccountContactsCtr.wrapperClass oObjWrpr=AccountContactsCtr.GetOpportunityCtr(oAcc.Id, oEE.Id, uType.name); 
            AccountContactsCtr.SendEmails(oCon.Id,oEE.Id);
            AccountContactsCtr.resetPasswords(oCon.Id); 
        }
    }
    
    static testMethod void elsedataSetUp() 
    {
            User_Type__c uType = new User_Type__c(Name ='Agent Owned Exhibitor');
            insert uType;
            System.AssertEquals(uType.Name, 'Agent Owned Exhibitor','Both the Value should be match');
            //Create Account
            Account oAcc = new Account(Name='TestAcc');
            insert oAcc;
            
            //create some contacts
            Contact oCon = new Contact(AccountId = oAcc.Id, FirstName = 'TestConFirst', LastName = 'TestConLast',phone='12346456', Email='abc@test.com',MailingCountry='USA',
                                        MailingStreet='123 Lake',MailingCity='Dallas',MailingState='Texas',MailingPostalCode='75039',Type__c=uType.Id);
            insert oCon;
            User[] userList = new User[]{};
            insert userList;
            System.debug('*** '+userList);
            System.AssertEquals(userList.isEmpty(), true,'Both the Value should be match');
        
        
            Event_Edition__c oEE = new Event_Edition__c(Name='TestName');
            insert oEE;
        
            //create Opportunities
            Opportunity oObjOpp = new Opportunity(AccountId = oAcc.Id, Name = 'TestOpp',StageName='Needs Assessment', EventEdition__c=oEE.Id,closedate=system.today(), Billing_Contact__c=oCon.Id,Operations_Contact__c=oCon.Id,Operation_Contact_2__c=oCon.Id,Operation_Contact_3__c=oCon.Id,Operation_Contact_4__c=oCon.Id,Operation_Contact_5__c=oCon.Id,Opportunity_Contact__c=oCon.Id,User_Type__c=uType.Id);
            insert oObjOpp;
            oObjOpp.StageName='Closed Won';
            update oObjOpp;
            System.debug('&&& ' +oObjOpp);
        
            AccountContactsCtr.SendEmails(oCon.Id,oEE.Id);
    }
    
}