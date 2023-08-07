/**
 * Created/Modified By: Girikon(Aishwarya)/Sunil CCEN-344
 * Created On:          19/07/2017
 * Modified On:         09/17/2018,15/05/2020
 * @description : This test class covers the apex class : triggersHandler
 * Methods:             cloneEventEditionCSDataInsert, trgCreateFormPermissionRecordsDataInsert
 * Apex Class:          triggersHandler_EEM, trgCreateFormPermissionRecords
**/

@isTest
public class triggersHandler_Test
{
    /**
    * @description : test class method 
    **/
    public static testMethod void cloneEventEditionCSDataInsert()
    {
        
         // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser11@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing11', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduserJohnson1@testorg.com');
                          
        // The following code runs as user 'u' created above
        System.runAs(u)
        {
            // This code runs as the system user
            Event_Series__c eventSeries = new Event_Series__c(Name= 'testSeries' ,  Status__c='Active');
            insert eventSeries;
            //System.AssertNotEquals(eventSeries, null);
            
            Event_Edition__c oEv = new Event_Edition__c(Name='testSeries 2016',Part_of_Series__c=eventSeries.id,Event_Code__c='TS16test', Event_Edition_Code__c = 'TS16test' , Event_Currency__c='USD',Start_Date__c=System.Today(),End_Date__c= System.Today()
                                                             ,Event_Edition_Status__c ='Confirmed');
            insert oEv;
            
            Event_Edition__c oEve = new Event_Edition__c(Name='testSeries 2017',Part_of_Series__c=eventSeries.id,Event_Code__c='TS17',Event_Currency__c='USD',Start_Date__c=System.Today() ,End_Date__c= System.Today()+5,Event_Edition_Status__c ='Confirmed',Year__c ='2017');
            insert oEve;
            System.assertEquals(oEve.Event_Code__c,'TS17', 'Event Code');
            
            Manual__c man = new Manual__c(Section__c = 123, Name = 'testManual',Event_Edition__c=oEve.Id);
            insert man;
            //System.assertEquals(man.Event_Edition__c,oEve.id, 'Event Id');
            
            Form__c form = new Form__c(Name = 'testForm',Form__c=2);
            insert form;
            //System.AssertNotEquals(form, null);
            //System.AssertEquals(form.Name, 'testForm'); 
            
            Event_Edition_Form__c eDF = new Event_Edition_Form__c(Forms__c=Form.id,Name='testEDF',Event_Edition__c=oEve.id);
            insert eDF;
            //System.AssertEquals(eDF.Forms__c,Form.id);
            
            //Manual__c manual = new Manual__c(Name='testManual',Event_Edition__c=oEve.id);
            Manual__c manual = new Manual__c(Name='testManual',Event_Edition__c=oEve.id,User_Type__c ='Agent');
            insert Manual;
            
            Email_Templates__c email = new Email_Templates__c(Name='testEmail',Template_Code__c='XX01');
            insert email;
            //System.AssertEquals(email.Template_Code__c,'XX01');
            
            Event_Edition_Email_Template__c eventEmail = new Event_Edition_Email_Template__c(name='testEventEmail',Event_Edition__c=oEve.id,Email_Template__c=email.id);
            insert eventEmail;
            //System.AssertEquals(eventEmail.Email_Template__c, email.id);
            
            Booth_Size_Badge_Limit__c boothSize = new Booth_Size_Badge_Limit__c(Name='testBoothSize',Event_Edition__c=oEve.id,Badges_Allowed__c=3,Booth_Size_From__c=3,Booth_Size_To__c=3);
            insert boothSize;
            //System.AssertEquals(boothSize.Badges_Allowed__c,3);
            
            Test.startTest();
            Event_Settings__c setting = new Event_Settings__c(Name='testSetting',Event_Edition__c=oEve.id);
                insert setting;
                //System.AssertEquals(setting.Event_Edition__c, oEve.id);
                //System.AssertNotEquals(setting, null);
            
                Event_Edition__c oEve1 = new Event_Edition__c(Name='testSeries 2018',Part_of_Series__c=eventSeries.id,Event_Code__c='TS18test', Event_Edition_Code__c = 'TS18test' , Event_Currency__c='USD',Start_Date__c=System.Today(),End_Date__c= System.Today()
                                                             ,Event_Edition_Status__c ='Confirmed',Year__c ='2018');
                insert oEve1;
                //System.AssertEquals(oEve1.Part_of_Series__c,eventSeries.id);
               
                Form__c frm1 = new Form__c(Name = 'testnonform',Form__c=3);
                insert frm1; 
                
                Event_Edition_Form__c eDF12 = new Event_Edition_Form__c(Forms__c=frm1.id,Name='testvalEDF',Event_Edition__c=oEve1.id);
                insert eDF12;
            
                Email_Templates__c eml = new Email_Templates__c(Name='testNonEmail',Template_Code__c='CC01');
                insert eml;
                
                Event_Edition_Email_Template__c eventOnEmail = new Event_Edition_Email_Template__c(name='tstevntnameeml',Event_Edition__c=oEve1.id,Email_Template__c=eml.id);
                insert eventOnEmail;
             
            }
    }
    
    /**
    * @description : test class method 
    **/
    public static testMethod void trgCreateFormPermissionRecordsDataInsert()
    {
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser11@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing11', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduserJohnson1@testorg.com');
                          Event_Edition__c oEve;
        // The following code runs as user 'u' created above
        System.runAs(u)
        {
            
                Contact con = new Contact(LastName='User',FirstName ='Test');
                insert con;
                //System.AssertEquals(con.LastName,'User');
                //System.AssertNotEquals(con,null);
                System.assertNotEquals('Test', con.LastName,'Contact should not be null');
                Event_Series__c oEventSeries = new Event_Series__c  (Name = 'World of Concrete Test' , Status__c = 'Active');
                insert oEventSeries;
                oEve = new Event_Edition__c(Name='World of Concrete 2017 event',Event_Code__c='WOC178',Event_Edition_Code__c = 'TS18tes1t', Event_Currency__c='USD',Start_Date__c=System.Today());
                insert oEve;
                //System.AssertEquals(oEve.Event_Code__c,'WOC178');
                
                User_Type__c uType = new User_Type__c(Name ='Exhibitor');
                insert uType;
                //System.AssertEquals(uType.Name ,'Exhibitor');
                Blob b3 = Blob.valueOf('Test Data record');
                ContentVersion cVersion = new ContentVersion();
                cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
                cVersion.PathOnClient = 'Complete.pdf';//File name with extention
                cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
                cVersion.OwnerId = userinfo.getUserId();//Owner of the file
                cVersion.Title ='Completed Test Signed Files for Parent Manual';//Name of the file
                cVersion.VersionData = b3;//File content
                insert cVersion;
                Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
                ContentDocumentLink cDocLink = new ContentDocumentLink();
                cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
                cDocLink.LinkedEntityId =  uType.id;//Add Files parentId
                cDocLink.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
                cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
                insert cDocLink; 
                //System.AssertEquals(attach.parentId, uType.id);
                
                Form__c oForm = new Form__c(Doc_Type__c='Online',Form__c=1,Deadline__c=System.Today());
                insert oForm;
                
                Test.StartTest();
                Event_Edition_Form__c oEEForm = new Event_Edition_Form__c(Event_Edition__c = oEve.id,Forms__c =oForm.id,User_Type__c='Agent;Exhibitor;');
                insert oEEForm;
                
                oEEForm.User_Type__c='Agent';
                update oEEForm;
                                 
                //System.AssertEquals(oEEForm.Event_Edition__c, oEve.id);
                //System.AssertEquals(oEEForm.Forms__c, oForm.id);
                //System.AssertNotEquals(oEEForm, null);
                
                Forms_Permission__c fPermission = new Forms_Permission__c(Event_Edition_Form__c = oEEForm.id, User_Type__c= uType.Id);
                insert fPermission;
                //System.AssertEquals(fPermission.User_Type__c, uType.Id);
                
                Manual__c man = new Manual__c(Section__c = 12345, Name = 'Test Manual Toc',Event_Edition__c=oEve.Id, User_Type__c ='Exhibitor');
                insert man;
                
                ComponentUserTypeMapping__c compUsrMap = new ComponentUserTypeMapping__c(Event_Edition__c = oEve.id, User_Type__c= uType.Id);
                insert compUsrMap;
                //System.AssertEquals(compUsrMap.User_Type__c, uType.Id);
                
                Test.StopTest();
        }
    }  
    
    //test method for Manual
    public static testMethod void trgManualPermisssionUpdate()
    {
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser11@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing11', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduserJohnson1@testorg.com');
                          Event_Edition__c oEve;
        // The following code runs as user 'u' created above
        System.runAs(u)
        {
            
                Contact con = new Contact(LastName='User',FirstName ='Test');
                insert con;
                
                System.assertNotEquals('Test', con.LastName,'Contact should not be null');
                
                Event_Series__c oEventSeries = new Event_Series__c  (Name = 'World of Concrete Test' , Status__c = 'Active');
                insert oEventSeries;
                oEve = new Event_Edition__c(Name='World of Concrete 2018 event',Event_Code__c='WOC20',Event_Edition_Code__c = 'TS18tes1t', Event_Currency__c='USD',Start_Date__c=System.Today());
                insert oEve;
                System.AssertEquals(oEve.Event_Code__c,'WOC20', 'Here value is not same');
                
                User_Type__c uType = new User_Type__c(Name ='Exhibitor');
                insert uType;
                System.AssertEquals(uType.Name ,'Exhibitor', 'Here value is not same');
                
                Test.StartTest();
                
                Manual__c man = new Manual__c(Section__c = 101, Name = 'Manual Woc20',Event_Edition__c=oEve.Id, User_Type__c ='Exhibitor',Manual_Type__c='Link',Url__c='Google.com',Expocad_Booth_Type__c = 'Inline');
                insert man;
                
                Manuals_Permission__c mPermission = new Manuals_Permission__c(Manuals__c = man.id, User_Type__c = uType.Id,Active__c=true);
                insert mPermission;
                
                man.User_Type__c ='Agent';
                man.Expocad_Booth_Type__c = '';
                update man;
          
                Test.StopTest();
        }
    }  
}