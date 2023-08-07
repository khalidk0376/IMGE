/**
* Created/Modified By: Girikon(Pramod)
* Created On:          19 Feb 2018 
* @description : This test class covers the apex class : ContactEventEditionMappingTriggerHandler and BatchCreateCommunityUsers
* Methods Cover:       CreateCommunityUser, CreateUserActions
* Apex Class:          ContactEventEditionMappingTriggerHandler (78%),BatchCreateCommunityUsers (100%)
**/
@isTest
public class ContactEventEditionMapping_Test
{
    public static testMethod void contactEventEditionMappingTest()
    {
        account acc = new account(Name='TestLName');
        insert acc;
        System.AssertNotEquals(acc, null, 'Account should not be null');
        
        Contact con = new Contact(LastName='User',FirstName ='Test', AccountId = acc.id);
        insert con;
        System.AssertNotEquals(con, null, 'Contact should not be null');
        
        Contact con1 = new Contact(LastName='User1',FirstName ='Test', AccountId = acc.id);
        insert con1;
        System.AssertNotEquals(con1, null, 'Contact should not be null');
        
        Contact con2 = new Contact(LastName='User2',FirstName ='Test', AccountId = acc.id);
        insert con2;
        System.AssertNotEquals(con2, null, 'Contact should not be null');
        
        Contact con3 = new Contact(LastName='User5',FirstName ='Test', AccountId = acc.id);
        insert con3;
        
        Contact con4 = new Contact(LastName='User7',FirstName ='Test', AccountId = acc.id);
        insert con4;
        
        Contact con5 = new Contact(LastName='User9',FirstName ='Test', AccountId = acc.id);
        insert con5;
        
        Contact con6 = new Contact(LastName='User10',FirstName ='Test1', AccountId = acc.id);
        insert con6;
        
        //Create user
        Profile pro = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User Custom'];
        User u = new User();

        u.FirstName = 'Sunil';
        u.LastName = 'Bajoliya';
        u.Email = 'test@wexeurope.com';
        u.Username = 'astest@wexeurope.com';
        u.Alias = 'astest';
        u.ProfileId = pro.Id;
        u.ContactId = con1.id;
        u.TimeZoneSidKey    = 'America/Denver';
        u.LocaleSidKey      = 'en_US';
        u.EmailEncodingKey  = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        system.debug('u contains ' + u);
        insert u;
        
        User comnUsr = new User();
        comnUsr.FirstName = 'Sunil';
        comnUsr.LastName = 'Bajoliya';
        comnUsr.Email = 'test@wexeurope.com';
        comnUsr.Username = 'astest@wexeurope.com978';
        comnUsr.Alias = 'Gft';
        comnUsr.ProfileId = pro.Id;
        comnUsr.ContactId = con2.id;
        comnUsr.IsActive = false;
        comnUsr.TimeZoneSidKey    = 'America/Denver';
        comnUsr.LocaleSidKey      = 'en_US';
        comnUsr.EmailEncodingKey  = 'UTF-8';
        comnUsr.LanguageLocaleKey = 'en_US';        
        insert comnUsr;
                        
        
        //Profile pAdmin = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u1 = new User(Alias = 'cUser', Email='admin.user@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Kumar', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = UserInfo.getprofileId(),
                          TimeZoneSidKey='America/Los_Angeles', UserName='admin.user@test.org.comuser');        
            insert u1;
                
            User_Type__c uType = new User_Type__c(Name ='Exhibitor');
            insert uType;
            System.AssertEquals(uType.Name, 'Exhibitor', 'User type should be Exhibitor');
            
            User_Type__c uTypeAgent = new User_Type__c(Name ='Agent');
            insert uTypeAgent;
            System.AssertEquals(uTypeAgent.Name, 'Agent', 'User Type should be Agent');
        
        	User_Type__c uTypeCoExhibitor = new User_Type__c(Name ='Co-Exhibitor');
            insert uTypeCoExhibitor;
            System.AssertEquals(uTypeCoExhibitor.Name, 'Co-Exhibitor', 'User type should be Exhibitor');
        	
        	User_Type__c uTypeAOE = new User_Type__c(Name ='Agent Owned Exhibitor');
            insert uTypeAOE;
            System.AssertEquals(uTypeAOE.Name, 'Agent Owned Exhibitor', 'User type should be Agent Owned Exhibitor');
        
            User_Type__c uTypeStandCon = new User_Type__c(Name ='Stand Contractor');
            insert uTypeStandCon;
            System.AssertEquals(uTypeStandCon.Name, 'Stand Contractor', 'User type should be Stand Contractor');
        
            //Create event edition
            Event_Edition__c eventEdition = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today(),Event_Currency__c='INR');
            insert eventEdition;
            System.assertEquals(eventEdition.Event_Code__c,'WOC17', 'Event Code');
            
        system.runAs(u1)
        { 
            //Populate event edition settings
            List<Event_Settings__c> lstEventSetting = new List<Event_Settings__c>();
            Event_Settings__c eve = new Event_Settings__c();
            eve.Send_Welcome_Email__c = True;
            eve.Is_Event_Edition_Live__c = True;
            eve.Event_Edition__c = eventEdition.Id;
            lstEventSetting.add(eve);
            insert lstEventSetting;
            
              
            
            Form__c oForm = new Form__c(Doc_Type__c='Online',Form__c=1,Deadline__c=System.Today());
            insert oForm;
            
            Event_Edition_Form__c oEEForm = new Event_Edition_Form__c(Event_Edition__c = eventEdition.id,Forms__c =oForm.id,Expocad_Booth_Class__c='', Expocad_Booth_Type__c='', Expocad_Product_Type__c='',User_Type__c=uType.Name);
            insert oEEForm;
            System.assertEquals(oEEForm.Event_Edition__c,eventEdition.id, 'checking Event Id');
            
            Forms_Permission__c fPermission = new Forms_Permission__c(Event_Edition_Form__c = oEEForm.id, User_Type__c= uType.Id);
            insert fPermission;
            System.assertEquals(fPermission.Event_Edition_Form__c,oEEForm.id, 'checking Event_Edition_Form Id');
            
            List<ContactEventEditionMapping__c> lstCEEM=new List<ContactEventEditionMapping__c>();
            ContactEventEditionMapping__c cEEM1 = new ContactEventEditionMapping__c(Status__c = true,SFEventEditionID__c=eventEdition.Id, SFContactID__c=con.Id, User_Type__c=uType.Id);            
            lstCEEM.Add(cEEM1);            
            
            Opportunity oOpportunity = new Opportunity( Name = 'Expocad Opportunity', CloseDate = Date.today().addDays(7), StageName = 'Proposal', EventEdition__c = eventEdition.Id, AccountId = acc.Id, Payment_Status__c='Not Paid',Billing_Contact__c = con.Id );
        	insert oOpportunity;
            
            SBQQ__Quote__c oQuote = new SBQQ__Quote__c(CurrencyIsoCode = 'USD',SBQQ__Status__c = 'Quote Sent', SBQQ__Type__c = 'Quote',SBQQ__Opportunity2__c = oOpportunity.Id, SBQQ__Account__c =acc.Id, SBQQ__Primary__c = true);
        	insert oQuote;
            
            oOpportunity.SBQQ__PrimaryQuote__c=oQuote.id;
            oOpportunity.StageName='Closed Won';
            update oOpportunity; 

            //create ExpocadBooth__c
            List<ExpocadBooth__c> lstExpoBooth = new List<ExpocadBooth__c>();
            for(Integer i=0;i<3;i++)
            {
                ExpocadBooth__c eB = new ExpocadBooth__c(Booth_Number__c='TestBoothNo.'+i,quote__c =oQuote.id , status__c = 'Rented');
                lstExpoBooth.add(eB);   
            }
            insert lstExpoBooth;
        
            Opportunity_ExpoCAD_Booth_Mapping__c oppExBooMapp= new Opportunity_ExpoCAD_Booth_Mapping__c(Account__c=acc.id,Status__c='Active',Quote__c=oQuote.id, Expocad_Booth__c=lstExpoBooth[0].id);
            
            insert oppExBooMapp;
            //Manual permission records for "Exhibitor" type user
            Manual__c man = new Manual__c(Section__c = 123, Name = 'Test Manual',Event_Edition__c=eventEdition.Id, User_Type__c=uType.Name);
            insert man;
            System.assertEquals(man.Event_Edition__c,eventEdition.id, 'Event Id');
            
            Manual__c manual = new Manual__c(Section__c = 123, Name = 'Test Manual',Expocad_Booth_Type__c='test',Expocad_Product_Type__c='test',Event_Edition__c=eventEdition.Id, User_Type__c=uType.Name);
            insert manual;
            
            Manuals_Permission__c mPermission = new Manuals_Permission__c(Manuals__c = man.id, User_Type__c= uType.Id);
            insert mPermission;
            System.assertEquals(mPermission.Manuals__c,man.id, 'Manuals Id');
            
            User_Manual_Action__c usrManualAction = new User_Manual_Action__c(Manual_Permission__c =mPermission.id, User_Manual_Contact__c =con.Id,User_Type__c =uType.Id);
            insert usrManualAction;
            
           Form__c oForm1 = new Form__c(Doc_Type__c='Link',Form__c=1,Deadline__c=System.Today());
            insert oForm1;
            
            Event_Edition_Form__c oEEFormNew = new Event_Edition_Form__c(Event_Edition__c = eventEdition.id,Forms__c =oForm1.id, Expocad_Booth_Class__c='aaa', Expocad_Booth_Type__c='aaa', Expocad_Product_Type__c='aaa', User_Type__c=uType.Name);
            insert oEEFormNew;
            
            Test.startTest();
            ContactEventEditionMapping__c cEEM2 = new ContactEventEditionMapping__c(Status__c = true,SFEventEditionID__c=eventEdition.Id, SFContactID__c=con.Id, User_Type__c=uType.Id);
            lstCEEM.Add(cEEM2);
            
            ContactEventEditionMapping__c cEEM5 = new ContactEventEditionMapping__c(Status__c = true,SFEventEditionID__c=eventEdition.Id, SFContactID__c=con3.Id, User_Type__c=uTypeAgent.Id);            
             lstCEEM.Add(cEEM5);
            
            ContactEventEditionMapping__c cEEM6 = new ContactEventEditionMapping__c(Status__c = true,SFEventEditionID__c=eventEdition.Id, SFContactID__c=con4.Id, User_Type__c=uTypeCoExhibitor.Id);            
             lstCEEM.Add(cEEM6);
            
            ContactEventEditionMapping__c cEEM10 = new ContactEventEditionMapping__c(Status__c = true,SFEventEditionID__c=eventEdition.Id, SFContactID__c=con6.Id, User_Type__c=uTypeStandCon.Id);            
             lstCEEM.Add(cEEM10);
            
            ContactEventEditionMapping__c cEEM7 = new ContactEventEditionMapping__c(Status__c = true,SFEventEditionID__c=eventEdition.Id, SFContactID__c=con5.Id, User_Type__c=uTypeAOE.Id);            
             lstCEEM.Add(cEEM7);
            
            ContactEventEditionMapping__c cEEM3 = new ContactEventEditionMapping__c(Status__c = true,SFEventEditionID__c=eventEdition.Id, SFContactID__c=con1.Id, User_Type__c=uType.Id);            
             lstCEEM.Add(cEEM3);
            
            ContactEventEditionMapping__c cEEM4 = new ContactEventEditionMapping__c(Status__c = true,SFEventEditionID__c=eventEdition.Id, SFContactID__c=con2.Id, User_Type__c=uType.Id);            
            lstCEEM.Add(cEEM4);
            insert lstCEEM;
  
            set<id> conEEMIds = new set<id>();
            conEEMIds.add(lstCEEM[2].Id);
            conEEMIds.add(lstCEEM[3].Id);
           
            BatchSendWelcomeEmailToExistingUsers objbatchActive= new BatchSendWelcomeEmailToExistingUsers(conEEMIds);
            Database.executeBatch(objbatchActive,2);
            
            set<string> setconEEMIds = new set<string>();
            setconEEMIds.add(lstCEEM[0].Id);
            setconEEMIds.add(lstCEEM[1].Id);
            setconEEMIds.add(lstCEEM[2].Id);
            setconEEMIds.add(lstCEEM[3].Id);
            setconEEMIds.add(lstCEEM[4].Id);
                        
            ContactEventEditionMappingTriggerHandler obj = new ContactEventEditionMappingTriggerHandler();
            
            Test.stopTest();
        }
    }    
}