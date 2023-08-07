/**
* Created By : Girikon(Abhishek)
* Created On : Sep 21, 2019
* @description : This test class covers all the methods of class BulkUploadBadgesCtrl
* Modification Log -------
* Modified By : 
**/
@isTest
public with sharing class BulkUploadBadgesCtrl_Test {

    public static testMethod void uploadBadgesDataInsert()
    {
        // Setup test data
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser11@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing11', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduserMark111@testorg.com');
        Event_Edition__c oEve;
        Account acc;
        System.runAs(u) {
            acc = new account(Name='TestLName');
            insert acc;
            System.AssertNotEquals(acc, null, 'Acc name must not be null');
            // The following code runs as user 'u' 
            Contact con = new Contact(LastName='User',FirstName ='Test');
            insert con;
            
            oEve = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today(),Event_Currency__c='USD');
            insert oEve;
            System.assertEquals(oEve.Event_Code__c,'WOC17', 'Event Code');
            
            Event_Settings__c eset = new Event_Settings__c();
            eset.Name ='event Setting Test';
            eset.Event_Edition__c = oEve.Id;
            eset.Branding_Color__c = 'yellow';
            eset.Badge_FName_Character_Limit__c = 500;           
            eset.Badge_LName_Character_Limit__c = 500;
            eset.Badge_JobTitle_Character_Limit__c = 500;
            eset.Badge_Email_Character_Limit__c = 500;
            eset.Badge_Mobile_Character_Limit__c = 500;
            eset.Badge_City_Character_Limit__c = 500;
            eset.Badge_Address_Character_Limit__c = 500;
            eset.Company_Name_on_Badge_Character_Limit__c = 500;
            eset.Allotment_By_Booth_Type__c=false;
            eset.Allotment_By_Booth_Size__c=true;
            eset.Agent_Badge_limit__c='10';
            insert eset;

            //Create Agent Event Edition Mapping
            AgentEventEditionMapping__c eventMapping = new AgentEventEditionMapping__c(Account__c=acc.Id,EventEdition__c=oEve.id,Is_Active__c=true);
            insert eventMapping;

            //Create Agent Badges
            Agent_Badges__c badge1 = new Agent_Badges__c(Address__c='NA',Age_Bracket__c='21-24',Account_Name__c='Test Company 1',AgentEventEditionMapping__c=eventMapping.Id,City__c='New City',Country__c='AW',Country_Code__c='+1',Email__c='test@company.com',First_Name__c='Test1',Job_Title__c='Jack of All Trades',Last_Name__c='Know it All',Mobile_Number__c='87768768',Nationality__c='AD',State__c='Plasma',Status__c='Approved',Is_VIP__c=true);
            insert badge1;
        }
        
        Test.startTest();

        ApexPages.currentPage().getParameters().put('eventCode',oEve.Event_Code__c);
        ApexPages.currentPage().getParameters().put('eventId',oEve.id);
        ApexPages.currentPage().getParameters().put('accountId',acc.id);
        BulkUploadBadgesCtrl oUploadBadges = new BulkUploadBadgesCtrl();
        oUploadBadges.nameFile = 'test.csv';
        oUploadBadges.importBadgesCSVFileId ='Badge CSV File';
        String sContFile ='Company Name on Badge,First Name,Last Name,Email,Country Code,Mobile Number,Country,State,City,Address,Nationality,Age,Job title,Is VIP';
        sContFile = sContFile+'\n ExhibitorTest,TestEx,Kumar,exhibitortest@test.com,+91,1234567890,India,Delhi,Delhi,A-123,India,25-34,Manager,Yes';
        oUploadBadges.contentFile= Blob.valueOf(sContFile);
        System.assert(sContFile!= null , 'Body Context');
        oUploadBadges.accountId = acc.id;
        oUploadBadges.ReadFile();
        oUploadBadges.detailBadges();
        
        oUploadBadges.nameFile = 'test.xls';
        oUploadBadges.ReadFile();
        
        oUploadBadges.ReadFile();
        Event_Settings__c eset1 = new Event_Settings__c();
        eset1.Badge_FName_Character_Limit__c = 5;
        eset1.Company_Name_on_Badge_Character_Limit__c = 2;
        oUploadBadges.ReadFile();  
        oUploadBadges.getuploadedExhibitorBadges();
        Test.stopTest();
    }
    
    public static testMethod void uploadBadgesElseDataInsert1()
    {
        // Setup test data
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser11@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing11', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduserMark111@testorg.com');
        Event_Edition__c oEve;

        Account acc;
        System.runAs(u) 
        {
            // The following code runs as user 'u' 
            acc = new account(Name='TestLName');
            insert acc;
            System.AssertNotEquals(acc, null,'Acc name must not be null');
            
            Contact con = new Contact(LastName='User',FirstName ='Test');
            insert con;
            
            oEve = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today(),Event_Currency__c='USD');
            insert oEve;
            System.assertEquals(oEve.Event_Code__c,'WOC17', 'Event Code');
            
            Event_Settings__c eset = new Event_Settings__c();
            eset.Name ='event Setting Test';
            eset.Event_Edition__c = oEve.Id;
            eset.Branding_Color__c = 'yellow';
             eset.Badge_FName_Character_Limit__c = 5;            
            eset.Badge_LName_Character_Limit__c = 2;
            eset.Badge_JobTitle_Character_Limit__c = 25;
            eset.Badge_Email_Character_Limit__c = 10;
            eset.Badge_Mobile_Character_Limit__c = 2;
            eset.Badge_City_Character_Limit__c = 2;
            eset.Badge_Address_Character_Limit__c = 9;
            eset.Company_Name_on_Badge_Character_Limit__c = 9;
            eset.Allotment_By_Booth_Type__c = false;
            eset.Allotment_By_Booth_Size__c = true;
            eset.Agent_Badge_limit__c='10';
            insert eset;
            
             //Create global email template
            Email_Templates__c testET = new Email_Templates__c();
            testET.name = 'test email template';
            testET.Template_Code__c = 'VBWR';
            testET.Content__c = 'testContent';
            testET.Subject__c = 'Test Template';
            insert testET;

            //Create event edition email template using global email template
            Event_Edition_Email_Template__c testEEET = new Event_Edition_Email_Template__c();
            testEEET.Event_Edition__c = oEve.id;
            testEEET.Subject__c = 'Test Template';
            testEEET.Email_Template__c = testET.id;
            testEEET.Email_Template_Code__c = 'VBWR';
            testEEET.Content__c = 'test email template';
            insert testEEET;

            //Create Agent Event Edition Mapping
            AgentEventEditionMapping__c eventMapping = new AgentEventEditionMapping__c(Account__c=acc.Id,EventEdition__c=oEve.id,Is_Active__c=true);
            insert eventMapping;

            //Create Agent Badges
            Agent_Badges__c badge1 = new Agent_Badges__c(Address__c='NA',Age_Bracket__c='21-24',Account_Name__c='Test Company 1',AgentEventEditionMapping__c=eventMapping.Id,City__c='New City',Country__c='AW',Country_Code__c='+1',Email__c='test@company.com',First_Name__c='Test1',Job_Title__c='Jack of All Trades',Last_Name__c='Know it All',Mobile_Number__c='87768768',Nationality__c='AD',State__c='Plasma',Status__c='Approved',Is_VIP__c=true);
            insert badge1;
        }
        
        Test.startTest();        
        ApexPages.currentPage().getParameters().put('eventCode',oEve.Event_Code__c);
        ApexPages.currentPage().getParameters().put('eventId',oEve.id);
        ApexPages.currentPage().getParameters().put('accountId',acc.id);
        BulkUploadBadgesCtrl oUploadBadges = new BulkUploadBadgesCtrl();
        oUploadBadges.nameFile = 'test.csv';
        oUploadBadges.importBadgesCSVFileId ='Badge CSV File';
        String sContFile ='Exhibitor Name,First Name,Last Name,Email,Country Number,City,State,Mobile,Address,Nationality,Age,Job title,Is VIP';
        sContFile = sContFile+'\n ExhibitorTest,TestEx,Kumar,exhibitortest@test.com,India,India,delhi,India,A-123,India,25-34,Manager,Yes';
        sContFile = sContFile+'\n AgentTest,TestAG,Kumar,agenttest@test.com,India,India,delhi,India,A-123,India,18-20,Manager,Yes';
        sContFile = sContFile+'\n AgentTest,TestAG,Kumar,agenttest@test.com,India,57147,delhi,India,A-123,885757,21-24,Manager,No';
        sContFile = sContFile+'\n AgentTest,TestAG,Kumar,agenttest@test.com,India,India,delhi,India,A-123,India,25-34,Manager,Yes';
        sContFile = sContFile+'\n AgentTest,TestAG,Kumar,agenttest@test.com,India,India,delhi,India,A-123,India,25-34,Manager, ';
        sContFile = sContFile+'\n AgentTest,TestAG,Kumar,agenttest@test.com,India,India,delhi,India,A-123,India,25-34,Manager,Yes';          
        oUploadBadges.contentFile= Blob.valueOf(sContFile);
        System.assert(sContFile!= null , 'Body Context');
        oUploadBadges.accountId = acc.id;
        oUploadBadges.ReadFile();
        oUploadBadges.detailBadges();       
        oUploadBadges.nameFile = 'test.xls';        
        oUploadBadges.ReadFile();          
                    
        Event_Settings__c eset1 = new Event_Settings__c();       
        eset1.Badge_FName_Character_Limit__c = 5;       
        oUploadBadges.ReadFile();
        oUploadBadges.getuploadedExhibitorBadges();
        Test.stopTest();
    }
    public static testMethod void uploadBadgesEmptyDataInsert()
    {
        // Setup test data
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser11@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing11', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduserMark111@testorg.com');
        Event_Edition__c oEve;
        Account acc;
        System.runAs(u) 
        {
            // The following code runs as user 'u' 
            acc = new account(Name='TestLName');
            insert acc;
            System.AssertNotEquals(acc, null, 'Acc name must not be null');
            
            Contact con = new Contact(LastName='User',FirstName ='Test');
            insert con;
            
            oEve = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today(),Event_Currency__c='USD');
            insert oEve;
            System.assertEquals(oEve.Event_Code__c,'WOC17', 'Event Code');
            
            Event_Settings__c eset = new Event_Settings__c();
            eset.Name ='event Setting Test';
            eset.Event_Edition__c = oEve.Id;
            eset.Branding_Color__c = 'yellow';
            eset.Badge_FName_Character_Limit__c = 5;            
            eset.Badge_LName_Character_Limit__c = 2;
            eset.Badge_JobTitle_Character_Limit__c = 25;
            eset.Badge_Email_Character_Limit__c = 10;
            eset.Badge_Mobile_Character_Limit__c = 2;
            eset.Badge_City_Character_Limit__c = 2;
            eset.Badge_Address_Character_Limit__c = 9;
            eset.Company_Name_on_Badge_Character_Limit__c = 9;
            eset.Allotment_By_Booth_Type__c = false;
            eset.Allotment_By_Booth_Size__c = true;
            eset.Allow_VIP_Badges__c=true;
            eset.Agent_Badge_limit__c='10';
            insert eset;

            //Create Agent Event Edition Mapping
            AgentEventEditionMapping__c eventMapping = new AgentEventEditionMapping__c(Account__c=acc.Id,EventEdition__c=oEve.id,Is_Active__c=true);
            insert eventMapping;

            //Create Agent Badges
            Agent_Badges__c badge1 = new Agent_Badges__c(Address__c='NA',Age_Bracket__c='21-24',Account_Name__c='Test Company 1',AgentEventEditionMapping__c=eventMapping.Id,City__c='New City',Country__c='AW',Country_Code__c='+1',Email__c='test@company.com',First_Name__c='Test1',Job_Title__c='Jack of All Trades',Last_Name__c='Know it All',Mobile_Number__c='87768768',Nationality__c='AD',State__c='Plasma',Status__c='Approved',Is_VIP__c=true);
            insert badge1;
        }
        
        Test.startTest();

        ApexPages.currentPage().getParameters().put('eventCode',oEve.Event_Code__c);
        ApexPages.currentPage().getParameters().put('eventId',oEve.id);
        ApexPages.currentPage().getParameters().put('accountId',acc.id);
        BulkUploadBadgesCtrl oUploadBadges = new BulkUploadBadgesCtrl();
        oUploadBadges.nameFile = 'test.csv';
        oUploadBadges.importBadgesCSVFileId ='Badge CSV File';
        
        String sContFile ='Company Name on Badge,First Name,Last Name,Email,Country Code,Mobile Number,Country,State,City,Address,Nationality,Age,Job title';
        sContFile = sContFile+'\n ,,,,,,,,,,,';
                
        oUploadBadges.contentFile= Blob.valueOf(sContFile);
        System.assert(sContFile!= null , 'Body Context');
        oUploadBadges.ReadFile();
        oUploadBadges.detailBadges();
        
        oUploadBadges.nameFile = 'test.xls';
        oUploadBadges.ReadFile();
        oUploadBadges.ReadFile(); 
        Event_Settings__c eset2 = new Event_Settings__c();
            
        Test.stopTest();
    }
}