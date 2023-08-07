/**
 * Created  By    :  Girikon(Aishwarya, Bappi)
 * Created On     :  9/11/2017
 * @description   :  This test class covers the apex class : UploadBadges
 * Methods        :  UploadBadgesDataInsert
 * Apex Class     :  UploadBadges (83%)
 * Modification Log----- 
 * Modified by :  (Girikon(Amish/Aishwarya) - CEN 150, CCEN 112) ,Girikon(Prashant [CCEN-737 April 4 2019])
 * Modified On    :  07/04/2018
**/

@isTest
private class UploadBadges_Test
{
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
            ExpocadBooth__c oExpBooth;
            Opportunity_ExpoCAD_Booth_Mapping__c oppExpoBoothMapping;
            Account acc;
        System.runAs(u) 
        {
            acc = new account(Name='TestLName');
            insert acc;
            System.AssertNotEquals(acc, null,'The account not equal null');
            // The following code runs as user 'u' 
            Contact con = new Contact(LastName='User',FirstName ='Test');
            insert con;
            
            oEve = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today(),Event_Currency__c='USD');
            insert oEve;
            System.assertEquals(oEve.Event_Code__c,'WOC17', 'Event Code');
            
            oExpBooth = new ExpocadBooth__c(Booth_Number__c='17', Area__c='1100',Unit_Type__c='SqFt');
            insert oExpBooth;
            System.assertEquals(oExpBooth.Unit_Type__c,'SqFt', 'Unit type');
            
            Booth_Size_Badge_Limit__c oBoothSizeBadgeLimit = new Booth_Size_Badge_Limit__c(Event_Edition__c =oEve.id,Name='test',Badges_Allowed__c=30.0,Booth_Size_From__c=1100.0,Booth_Size_To__c=1200.0);
            insert oBoothSizeBadgeLimit;
            //System.assert(oBoothSizeBadgeLimit != null , 'Booth size');
            System.assertNotEquals(oBoothSizeBadgeLimit, null , 'Booth size not equal null');
            
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
            insert eset;

            //Create Opportunity_ExpoCAD_Booth_Mapping__c [CCEN-737]
            oppExpoBoothMapping = new Opportunity_ExpoCAD_Booth_Mapping__c(Account__c = acc.Id, Badge_Limit__c = 2, status__c = 'Active', Expocad_Booth__c = oExpBooth.Id);
            insert oppExpoBoothMapping;
            
            Exhibitor_Badge__c badge1 = new Exhibitor_Badge__c();
            badge1.Name = 'Test';
            badge1.Event_Edition__c=oEve.id;
            badge1.ExpocadBooth__c=oExpBooth.id;
            badge1.Opp_Booth_Mapping__c = oppExpoBoothMapping.id;
            insert badge1;
         }
        
        Test.startTest();
        
            ApexPages.currentPage().getParameters().put('eventCode',oEve.Event_Code__c);
            //ApexPages.currentPage().getParameters().put('boothInfo',oppExpoBoothMapping.id);
            ApexPages.currentPage().getParameters().put('accountId',acc.id);
            UploadBadges oUploadBadges = new UploadBadges();
            oUploadBadges.nameFile = 'test.csv';
            oUploadBadges.importBadgesCSVFileId ='Badge CSV File';
            //String sContFile ='Exhibitor Name,First Name,Last Name,Email,Country Number,City,State,Country Code,Mobile,Address,Nationality,Age,Job title';
            String sContFile ='Company Name on Badge,First Name,Last Name,Email,Country Code,Mobile Number,Country,State,City,Address,Nationality,Age,Job title,Is VIP';
            sContFile = sContFile+'\n ExhibitorTest,TestEx,Kumar,exhibitortest@test.com,+91,1234567890,India,Delhi,Delhi,A-123,India,25-34,Manager,vip';
            oUploadBadges.contentFile= Blob.valueOf(sContFile);
            //System.assert(sContFile!= null , 'Body Context');
            System.assertNotEquals(sContFile,null,'Body Context');
            oUploadBadges.boothInfoFromURL = oppExpoBoothMapping.id;
            oUploadBadges.accountId = acc.id;
            oUploadBadges.ReadFile();
           // oUploadBadges.getuploadedExhibitorBadges();
            oUploadBadges.getBoothItems();
           // oUploadBadges.getBoothInformMessage();
            oUploadBadges.detailBadges();
            
            oUploadBadges.nameFile = 'test.xls';
            oUploadBadges.ReadFile();
            //oUploadBadges.boothInfoFromURL = '';
            
            oUploadBadges.ReadFile();
            Event_Settings__c eset1 = new Event_Settings__c();
            eset1.Badge_FName_Character_Limit__c = 5;
            eset1.Company_Name_on_Badge_Character_Limit__c = 2;
            oUploadBadges.ReadFile();
            
            
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
        ExpocadBooth__c oExpBooth;
        Opportunity_ExpoCAD_Booth_Mapping__c oppExpoBoothMapping;
        Account acc;
        System.runAs(u) 
        {
            // The following code runs as user 'u' 
            acc = new account(Name='TestLName');
            insert acc;
            System.AssertNotEquals(acc, null,'Account not equal null');
            
            Contact con = new Contact(LastName='User',FirstName ='Test');
            insert con;
            
            oEve = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today(),Event_Currency__c='USD');
            insert oEve;
            System.assertEquals(oEve.Event_Code__c,'WOC17', 'Event Code');
            
            oExpBooth = new ExpocadBooth__c(Booth_Number__c='17', Area__c='1100',Unit_Type__c='SqFt');
            insert oExpBooth;
            System.assertEquals(oExpBooth.Unit_Type__c,'SqFt', 'Unit type');
            
            Booth_Size_Badge_Limit__c oBoothSizeBadgeLimit = new Booth_Size_Badge_Limit__c(Event_Edition__c =oEve.id,Name='test',Badges_Allowed__c=30.0,Booth_Size_From__c=1100.0,Booth_Size_To__c=1200.0);
            insert oBoothSizeBadgeLimit;
            //System.assert(oBoothSizeBadgeLimit != null , 'Booth size');
            System.assertNotEquals(oBoothSizeBadgeLimit, null , 'Booth size not equal null');
            
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
             eset.Allow_VIP_Badges__c=false;
            eset.Badges_MatchMaking__c=True;
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

            //Create Opportunity_ExpoCAD_Booth_Mapping__c [CCEN-737]
            oppExpoBoothMapping = new Opportunity_ExpoCAD_Booth_Mapping__c(Account__c = acc.Id, Badge_Limit__c = 2, status__c = 'Active', Expocad_Booth__c = oExpBooth.Id);
            insert oppExpoBoothMapping;
            
            
            Exhibitor_Badge__c badge1 = new Exhibitor_Badge__c();      
            badge1.Name = 'Test';       
            badge1.Event_Edition__c=oEve.id;        
            badge1.ExpocadBooth__c=oExpBooth.id;       
            badge1.Opp_Booth_Mapping__c = oppExpoBoothMapping.id; 
           insert badge1;
         }
        
        Test.startTest();        
            ApexPages.currentPage().getParameters().put('eventCode',oEve.Event_Code__c);
            //ApexPages.currentPage().getParameters().put('boothInfo',oppExpoBoothMapping.id);
            ApexPages.currentPage().getParameters().put('accountId',acc.id);
            UploadBadges oUploadBadges = new UploadBadges();
            oUploadBadges.nameFile = 'test.csv';
            oUploadBadges.importBadgesCSVFileId ='Badge_CSV_File_Without_VIP';
            String sContFile ='Exhibitor Name,First Name,Last Name,Email,Country Number,City,State,Mobile,Address,Nationality,Age,Job title,Is VIP';
            sContFile = sContFile+'\n ExhibitorTest,TestEx,Kumar,exhibitortest@test.com,India,India,delhi,India,A-123,India,25-34,Manager,vip';
            sContFile = sContFile+'\n AgentTest,TestAG,Kumar,agenttest@test.com,India,India,delhi,India,A-123,India,18-20,Manager,vip';
            sContFile = sContFile+'\n AgentTest,TestAG,Kumar,agenttest@test.com,India,57147,delhi,India,A-123,885757,21-24,Manager,vip';
            sContFile = sContFile+'\n AgentTest,TestAG,Kumar,agenttest@test.com,India,India,delhi,India,A-123,India,25-34,Manager,vip';
            sContFile = sContFile+'\n AgentTest,TestAG,Kumar,agenttest@test.com,India,India,delhi,India,A-123,India,25-34,Manager, ';
            sContFile = sContFile+'\n AgentTest,TestAG,Kumar,agenttest@test.com,India,India,delhi,India,A-123,India,25-34,Manager,vip';          
            oUploadBadges.contentFile= Blob.valueOf(sContFile);
            //System.assert(sContFile!= null , 'Body Context');
            System.assertNotEquals(sContFile, null , 'Body Context');
            oUploadBadges.boothInfoFromURL = oppExpoBoothMapping.id;
            //oUploadBadges.boothInfoFromURL = '';
            oUploadBadges.accountId = acc.id;
            oUploadBadges.ReadFile();
             oUploadBadges.getuploadedExhibitorBadges();        
            oUploadBadges.getBoothItems();      
                //oUploadBadges.getBoothInformMessage();      
                oUploadBadges.detailBadges();       
                        
                oUploadBadges.nameFile = 'test.xls';        
                oUploadBadges.ReadFile();       
                //oUploadBadges.boothInfoFromURL = '';        
                        
           Event_Settings__c eset1 = new Event_Settings__c();       
                eset1.Badge_FName_Character_Limit__c = 5;       
                oUploadBadges.ReadFile();
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
            ExpocadBooth__c oExpBooth;
            Opportunity_ExpoCAD_Booth_Mapping__c oppExpoBoothMapping;
            Account acc;
        System.runAs(u) 
        {
            // The following code runs as user 'u' 
            acc = new account(Name='TestLName');
            insert acc;
            System.AssertNotEquals(acc, null,'The account is null');
            
            Contact con = new Contact(LastName='User',FirstName ='Test');
            insert con;
            
            oEve = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today(),Event_Currency__c='USD');
            insert oEve;
            System.assertEquals(oEve.Event_Code__c,'WOC17', 'Event Code');
            
            oExpBooth = new ExpocadBooth__c(Booth_Number__c='17', Area__c='1100',Unit_Type__c='SqFt');
            insert oExpBooth;
            System.assertEquals(oExpBooth.Unit_Type__c,'SqFt', 'Unit type');
            
            Booth_Size_Badge_Limit__c oBoothSizeBadgeLimit = new Booth_Size_Badge_Limit__c(Event_Edition__c =oEve.id,Name='test',Badges_Allowed__c=3.0,Booth_Size_From__c=1100.0,Booth_Size_To__c=1200.0);
            insert oBoothSizeBadgeLimit;
            //System.assert(oBoothSizeBadgeLimit != null , 'Booth size');
            System.assertNotEquals(oBoothSizeBadgeLimit, null , 'Booth size not equal null');
               
            //Create Opportunity_ExpoCAD_Booth_Mapping__c [CCEN-737]
            oppExpoBoothMapping = new Opportunity_ExpoCAD_Booth_Mapping__c(Account__c = acc.Id, Badge_Limit__c = 2, status__c = 'Active', Expocad_Booth__c = oExpBooth.Id);
            insert oppExpoBoothMapping;
            
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
            eset.Badges_MatchMaking__c=true;
            insert eset;
         }
        
        Test.startTest();
        
            ApexPages.currentPage().getParameters().put('eventCode',oEve.Event_Code__c);
            //ApexPages.currentPage().getParameters().put('boothInfo',oppExpoBoothMapping.id);
            ApexPages.currentPage().getParameters().put('accountId',acc.id);
            UploadBadges oUploadBadges = new UploadBadges();
            oUploadBadges.nameFile = 'test.csv';
            oUploadBadges.importBadgesCSVFileId ='Badge CSV File';
            
            String sContFile ='Company Name on Badge,First Name,Last Name,Email,Country Code,Mobile Number,Country,State,City,Address,Nationality,Age,Job title';
            sContFile = sContFile+'\n ,,,,,,,,,,,';
                  
            oUploadBadges.contentFile= Blob.valueOf(sContFile);
            //(sContFile!= null , 'Body Context');
            System.assertNotEquals(sContFile,null,'Body Context');
            
            oUploadBadges.boothInfoFromURL = oppExpoBoothMapping.id;
            //oUploadBadges.boothInfoFromURL = '';
            oUploadBadges.ReadFile();
            oUploadBadges.getuploadedExhibitorBadges();
            oUploadBadges.getBoothItems();
            //oUploadBadges.getBoothInformMessage();
            oUploadBadges.detailBadges();
            
            oUploadBadges.nameFile = 'test.xls';
            oUploadBadges.ReadFile();
            oUploadBadges.boothInfoFromURL = '';
            oUploadBadges.ReadFile(); 
            Event_Settings__c eset2 = new Event_Settings__c();
            
        Test.stopTest();
    }
}