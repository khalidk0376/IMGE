/**
* Created By    :  Girikon(Ashish) C2E-105
* Created On    :  21 Sep 2019
* @description  :  Provides Code Covrage To AgentBadgesReportOpsCtrl (86%),MassBadgeReminderEmailBatch(97%)
* Modification Log----- 
* Modified by :  
**/
@isTest
public class AgentBadgesReportOpsCtrl_Test 
{
    //SetUp data for test class
    @isTest static void opsBadges()
    {        
        Utility.isRebookInProcess = True;

        //Create Accounts
        Account acc = new Account(Name='TstAccFrst');
        insert acc;
        
        //create some contacts
        List<Contact> contacts = new List<Contact>();
        for(Integer i=0;i<3;i++)
        {
            Contact c = new Contact(AccountId = acc.Id, FirstName = 'TstConFrst'+i, LastName = 'TstConLst1'+i, Email='test@test.com');
            contacts.add(c);    
        }
        insert contacts;
    
            
        //Create user
        //Profile pro = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        Profile pro = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User Custom'];
        User[] userList = new User[]{};
        User u = new User();

        u.FirstName = 'Sunil';
        u.LastName = 'Bajoliya';
        u.Email = 'test@wexeurope.com';
        u.Username = 'astest@wexeurope.com';
        u.Alias = 'astest';
        u.ProfileId = pro.Id;
        
        u.ContactId = contacts[1].id;
        u.TimeZoneSidKey    = 'America/Denver';
        u.LocaleSidKey      = 'en_US';
        u.EmailEncodingKey  = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        insert u;
        //userList.add(u);
        system.debug('u contains ' + u);
        //insert userList;
        
        //Create User_Type__c
        User_Type__c oUT = new User_Type__c(Name='Agent');
        insert oUT;

        //Create APXTConga4__Conga_Template__c
        APXTConga4__Conga_Template__c conga = new APXTConga4__Conga_Template__c( APXTConga4__Template_Type__c = 'Document');
        insert conga;
         
        //Insert event edition image
        Document doc = new Document(); 
        doc.Name = 'TEV17-Event-Image'; 
        doc.FolderId = UserInfo.getUserId();
        doc.IsPublic = true; 
        doc.Body =Blob.valueOf('Some Text'); 
        doc.ContentType = 'image/jpeg';
        insert doc;
        
        //Create Event_Edition
        Event_Edition__c evntEditon = new Event_Edition__c(Name='TestName',CurrencyIsoCode='USD',Tab1__c='Booth Application',Tab4__c='Contact Information', Tab8__c='Transfer & Payments',Event_Currency__c ='USD',Event_Code__c='abc',Event_Edition_Status__c='Prospecting', Contract_Template__c = conga.id,End_Date__c=date.today(),Event_Website__c='http://www.testevent.com',Event_Edition_Image_URL__c= doc.Id,Invoice_From_Email_ID__c='Test', Max_Hold_Booth__c=15, Max_Hold_Days__c=365, Measurement__c='Feet',Next_Edition__c='2019', Payment_Schedule__c='50-50', Quote_Template__c=conga.id,Start_Date__c=date.today()-1,Venue__c='Las Vegas Convention Center', Year__c='2019',Informa_Logo__c=doc.Id, Cutoff_Date_1__c=date.today()+1,Cutoff_Date_2__c=date.today()-10,Cutoff_Date_3__c=date.today()-15);
        insert evntEditon ;
        
         //create Email_Templates__c
        List<Email_Templates__c> lstETemp = new List<Email_Templates__c>();
        for(Integer i=0;i<1;i++)
        {
            Email_Templates__c eTemp = new Email_Templates__c(Name='TestName'+i,Template_Code__c='BDGAPR');
            lstETemp.add(eTemp);    
        }
        insert lstETemp;
        //create Event_Edition_Email_Template__c
        List<Event_Edition_Email_Template__c> lstEEETemp = new List<Event_Edition_Email_Template__c>();
        for(Integer i=0;i<3;i++)
        {
            Event_Edition_Email_Template__c eeet = new Event_Edition_Email_Template__c(Name='TestName'+i,Content__c='TestContent'+i,Email_Template_Code__c='BDGAPR', 
                                                                                       Subject__c='test'+i,Email_Template__c=LstETemp[0].Id,Event_Edition__c=evntEditon.Id);
            lstEEETemp.add(eeet);   
        }
        insert lstEEETemp;
  
        //Create Event_Settings__c
        Event_Settings__c evntSetting = new Event_Settings__c(Name='Test Event',CurrencyIsoCode='USD',Event_Edition__c=evntEditon.id,Badge_State__c=true,Badge_Nationality__c=true,Badge_Mobile_Number__c=true,Badge_Last_Name__c=true,Badge_Job_Title__c=true,Badge_First_Name__c=true,Badge_Email__c=true
                                                          ,Badge_Country__c=true,Company_Name_on_Badge_ToUpperCase__c=false,Badge_City__c=true,Badges_Title__c='abc',Badges_Sub_Title__c='abch',Badge_LName_To_UpperCase__c=false,Badge_FName_To_UpperCase__c=false,Badge_Age_Bracket__c=true,Badge_Address__c=false,Company_Name_on_Badge__c= false);
        insert evntSetting;
        
                    //Create Agent Event Edition Mapping
        AgentEventEditionMapping__c eventMapping = new AgentEventEditionMapping__c(Account__c=acc.Id,EventEdition__c=evntEditon.id,Is_Active__c=true);
        insert eventMapping;

        //Create Agent Badges
        Agent_Badges__c badge1 = new Agent_Badges__c(Address__c='NA',Age_Bracket__c='21-24',Account_Name__c='Test Company 1',AgentEventEditionMapping__c=eventMapping.Id,City__c='New City',Country__c='AW',Country_Code__c='+1',Email__c='test@company.com',First_Name__c='Test1',Job_Title__c='Jack of All Trades',Last_Name__c='Know it All',Mobile_Number__c='87768768',Nationality__c='AD',State__c='Plasma',Status__c='Approved',Is_VIP__c=true);
        insert badge1;
        Agent_Badges__c badge2 = new Agent_Badges__c(Address__c='NA',Age_Bracket__c='21-24',Account_Name__c='Test Company 2',AgentEventEditionMapping__c=eventMapping.Id,City__c='New City',Country__c='AW',Country_Code__c='+1',Email__c='test1@company.com',First_Name__c='Test2',Job_Title__c='Jack of All Trades',Last_Name__c='Know Nothing',Mobile_Number__c='87768768',Nationality__c='AD',State__c='Plasma',Status__c='Pending',Is_VIP__c=false);
        system.runAs(u)
        {
        	insert badge2;    
        }

        
        Test.startTest();  // Call test Methords
        AgentBadgesReportOpsCtrl.AggregateResultWrapper  wrap = AgentBadgesReportOpsCtrl.getAgentBadgeAggregate(evntEditon.Id,1,5,'All');
        
        List<String> pickVal = AgentBadgesReportOpsCtrl.getPicklistValues('Case','Status');
        
        Event_Settings__c evntStng = AgentBadgesReportOpsCtrl.getEventSettings(evntEditon.Id);
                
        List<String> idStr = new List<String>();
        idStr.add(badge1.id);
        
        AgentBadgesReportOpsCtrl.updateAgentBadge(idStr, 'Approved', true, 'TESTING ONLY');
        
        list<Agent_Badges__c> ebBDge = AgentBadgesReportOpsCtrl.getAgentBadges(acc.Id, evntEditon.Id);
        
        string result = AgentBadgesReportOpsCtrl.updateBadgeAllFields(badge1, true, 'Test');
        system.assertNotEquals(null, result, 'The record must not be null');
        
        Boolean msg = AgentBadgesReportOpsCtrl.massBadgesEmailReminder(evntEditon.Id);
        
        set<string> batchIds = new set<string>();
        batchIds.add(badge2.id);
        batchIds.add(badge1.id);
        
        BatchAgentBadgesStatusEmail batch1 = new BatchAgentBadgesStatusEmail(batchIds,'Approved', 'Test');
        Database.executeBatch(batch1, 10); 
        Test.stopTest();
    }    
}