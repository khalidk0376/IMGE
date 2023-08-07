/**
 * Created/Modified By  : Girikon(Pramod)
 * Created On   :  06/06/2018
 * @description : This test class covers the apex class : UtilityMethods
 * Apex Class   : UtilityMethods (86%)
 
 * Modification Log----- 
 * Modified by : Girikon(Mahesh) Aug 01 2018, Prashant on Mar 08 2019[CCEN-695]
**/
@isTest
public class UtilityMethods_Test
{
    @isTest
    public static  void prepareCommunityUserAgentTest()  
    {
        Utility.isRebookInProcess = True ; 
        // Setup test data
        // This code runs as the system user
        Profile pr = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User usr = new User(Alias = 'standt', Email='standarduser11@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing11', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = pr.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduserjohn11@testorg.com');
        System.runAs(usr) 
        {
            //Create exhibitor user type   
            User_Type__c uType = new User_Type__c(Name ='Exhibitor');
            insert uType;
            System.AssertEquals(uType.Name, 'Exhibitor','Invalid User Type');

            //Create Account
            account acc = new account(Name='TestLName');
            insert acc;
            System.AssertNotEquals(acc, null,'Account not equal null');
            System.Debug('acc: '+acc);

            //Create contact
            Contact con = new Contact(LastName='User',FirstName ='Test',email='test1@test.com', Type__c=uType.Id,AccountId = acc.id);
            insert con;
            System.AssertNotEquals(con, null,'Contact not equal');
            System.Debug('con: '+con);

            //Create contact list
            List<Contact> conts = new List<Contact>();
            conts.add(con);
            
            //Create event edition
            Event_Edition__c oEve = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today(),Event_Currency__c='INR');
            insert oEve;
            User_Type__c uType1 = new User_Type__c(Name ='Exhibitor');
        insert uType1;
            
             ComponentUserTypeMapping__c compUsrMap = new ComponentUserTypeMapping__c(Event_Edition__c = oEve.Id, User_Type__c= uType1.Id,Do_not_send_welcome_email__c=false);
        insert compUsrMap;
            System.Debug('oEve: '+oEve);
            
            //Create opportunity for this account
            Opportunity oOpportunity = new Opportunity(Name = 'Expocad Opportunity', CloseDate = Date.today(),StageName = 'Closed Won', 
                                           EventEdition__c = oEve.Id,  AccountId = acc.Id, Billing_Contact__c = Con.Id,Operations_Contact__c=Con.Id);
            insert oOpportunity;
            System.Debug('oOpportunity: '+oOpportunity);
            
            oOpportunity.StageName = 'Closed Won';
            //update oOpportunity;
            
             //create ExpocadBooth__c
            List<ExpocadBooth__c> lstExpoBooth = new List<ExpocadBooth__c>();
            for(Integer i=0;i<2;i++)
            {
                ExpocadBooth__c eB = new ExpocadBooth__c(Booth_Number__c='TestBoothNo.'+i,Display_Name__c='TestDisplay'+i,Opportunity__c=oOpportunity.Id);
                lstExpoBooth.add(eB);   
            }
            insert lstExpoBooth;
             
             //Create Event_Settings__c
            Event_Settings__c evntSttng = new Event_Settings__c(Name='Test',About_Show__c='Test',ShowHours1__c='test',ShowHours2__c='Test',Branding_Color__c='Black',Link_1__c='http://m.www.google.com/',Is_Stand_Design_Visible__c=True,Is_Stand_Detail_Visible__c=True,Is_SubContractors_Visible__c=True,Is_Amount_Visible__c=True,
            Link_2__c='http://m.www.google.com/',Link_3__c='http://m.www.google.com/',Link_4__c='http://m.www.google.com/',Link_1_Label__c='TestLink1',Link_2_Label__c='TestLink2',Link_3_Label__c='TestLink3',Link_4_Label__c='TestLink4',Is_Event_Edition_Live__c=true,Send_Welcome_Email__c=true,
            FaceBook__c='http://m.www.facebook.com/',LinkedIn__c='http://m.www.linkedin.com/',Twitter__c='http://m.www.Twitter.com/',YouTube__c='http://m.www.youtube.com/',Custom_1_Title__c='CstmTitle',Event_Edition__c=oEve.Id,E_Commerce_Title__c='EC Title',Welcome_Stand_Contractor__c='WSC Test',Disable_this_information__c=True,
            Exhibitor_Email_Content2__c='test',Exhibitor_Email_Content1__c='test',Stand_Contractor_Content2__c='test',Stand_Contractor_Content1__c='test',Co_Exhibitor_Email_Content2__c='test',Co_Exhibitor_Email_Content1__c='test',Agent_Email_Content2__c='test',Agent_Email_Content1__c='test');
            insert evntSttng;
            
            stand_Detail__c standDetails = new Stand_Detail__c(ExpocadBooth__c =lstExpoBooth[0].Id,Stand_Height__c=2.0,Account__c=acc.Id);
            insert standDetails;
            
            Stand_Design__c standDesign = new Stand_Design__c(ExpocadBooth__c =lstExpoBooth[0].Id,Account__c=acc.Id,Is_Rejected__c=false);
            insert standDesign;
            
            //Fetch community user profile from label
            string commUsrProfile='';
            If(Label.Community_User_Profile!= NULL)
            {
                commUsrProfile= Label.Community_User_Profile;
            } 
            else{
                commUsrProfile='Customer Community Login User Custom'; 
            }
                           
            //Fetch community user profile
            Profile p =[select id , Name from Profile Where Name =:commUsrProfile];

            //Create contact & event edition mapping
            ContactEventEditionMapping__c oMapping = new ContactEventEditionMapping__c(SFContactID__c=con.id,SFEventEditionID__c=oEve.id,User_Type__c=uType.Id,IsEmailSent__c =false,Status__c=true);
            insert oMapping;         
            System.Debug('oMapping: '+oMapping);
                        
            //Create global email template
            Email_Templates__c testET = new Email_Templates__c();
            testET.name = 'test email template';
            testET.Template_Code__c = 'ISC';
            testET.Content__c = 'testContent';
            testET.Subject__c = 'Test Template';
            insert testET;
            
            //Create event edition email template using global email template
            Event_Edition_Email_Template__c testEEET = new Event_Edition_Email_Template__c();
            testEEET.Event_Edition__c = oEve.id;
            testEEET.Subject__c = 'Test Template';
            testEEET.Email_Template__c = testET.id;
            testEEET.Email_Template_Code__c = 'ISC';
            testEEET.Content__c = 'test email template';
            insert testEEET;
            
            list<string> lstBoothIds = new list<string>();
            for(ExpocadBooth__c  ec : lstExpoBooth)
            {
                lstBoothIds.add(ec.id);
            }
            UtilityMethods.sendEmailByCode(oEve.Id,'ISC',con,lstBoothIds); 
            
            //Create community user for already created contact
            User u = new User(Alias = 'standt', Email='test1@test.com', 
                              EmailEncodingKey='UTF-8',FirstName='test1', LastName='Testing11', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = p.Id, ContactID=con.id,
                              TimeZoneSidKey='America/Los_Angeles', UserName='suser@test.com');
            insert u;
            set<Id> sUsrIds = new set<Id>(); 
            sUsrIds.add(u.Id);
            set<Id> sConIds = new set<Id>(); 
            set<Id> sEveIds = new set<Id>(); 
            sConIds.add(u.ContactId);
            sEveIds.add(oEve.Id);
            //Send email to user(s)
            Test.startTest();
            UtilityMethods.sendEmailToExistingUser(sConIds,sEveIds);
           
           
            //Call methods
            UtilityMethods.PrepareCommunityUser(p.id,conts);
            UtilityMethods.getEventDetails(oEve.Event_Code__c);
            UtilityMethods.SendEmailNotification(New String[]{'test@test.com'},'Hi','Hello');
            UtilityMethods.getStandDetail(oEve.Event_Code__c);
            UtilityMethods.getStandDesign(oEve.Event_Code__c);
            UtilityMethods.getProfileid();
           // UtilityMethods.returnCommunityURL();
            UtilityMethods um= new UtilityMethods();
            
            UtilityMethods.getOppBoothDetails(oEve.Event_Code__c);
            UtilityMethods.getOppBoothDetails(con.Id,oEve.Id);
            UtilityMethods.getCommunityURL();
            um.getAccccountContacts(acc.Id,oEve.Id);
            um.getContactEventEditionMapping(con.Id,oEve.Id);
            //um.returnCommunityURL();
            
           
            uType.Name='Stand Contractor';
            update uType;
            UtilityMethods.sendEmailToExistingUser(sConIds,sEveIds);
            
            uType.Name='Co-Exhibitor';
            update uType;
            UtilityMethods.sendEmailToExistingUser(sConIds,sEveIds);
            
            uType.Name='Agent';
            update uType;
            UtilityMethods.sendEmailToExistingUser(sConIds,sEveIds);
            UtilityMethods.sendEmailToAgentUser(sConIds,oEve.Id,u.ContactId);
            
                    
            uType.Name='Agent Owned Exhibitor';
            update uType;
            UtilityMethods.sendEmailToExistingUser(sConIds,sEveIds);
                  
            sConIds.clear();
            sConIds.add(con.id);
            oMapping.IsEmailSent__c =false;
            update oMapping;
            UtilityMethods.updateContactsSentEmail(sConIds);
            
            UtilityMethods.sendEmailToExistingUserAccCon(sConIds,sEveIds);
            
            string encryptCode = UtilityMethods.Encrypt_aes256(oEve.Id);
            string decryptId  = UtilityMethods.Decrypt_aes256(encryptCode);
            system.assertEquals(decryptId, oEve.Id,'encryptCode should be equal');
            
            Decimal bdlimit = UtilityMethods.getTotalBadgesByDimension('8M x 8M');
           
            UtilityMethods.getPicklistValues('Account','BillingCountryCode');
            Test.stopTest();
            
                       
        }
    }
}