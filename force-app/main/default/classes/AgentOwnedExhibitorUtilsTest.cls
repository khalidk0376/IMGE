@isTest
public class AgentOwnedExhibitorUtilsTest {
    @testSetup
    static void setup(){
        system.debug('times');
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User Custom'].Id; 
        
        //Create account
        account objAcc = new account(Name='TestLName');
        insert objAcc;
        System.assertEquals('TestLName', objAcc.name,'Error account is not created');
        
        //Create User_Type__c
        User_Type__c uTypeAgn = new User_Type__c(Name='Agent');
        insert uTypeAgn;
        
        User_Type__c uTypeAOE = new User_Type__c(Name='Agent Owned Exhibitor');
        insert uTypeAOE;
        
        User_Type__c uTypeCoExh = new User_Type__c(Name='Co-Exhibitor');
        insert uTypeCoExh;
        
        
        //Create contact
        Contact con = new Contact(LastName='User',FirstName ='Test',email='test1@test.com', Type__c=uTypeAgn.Id,AccountId = objAcc.id);
        insert con;
        
       
        Contact conTest = new Contact(LastName='Test',FirstName ='Test',email='test1@test.com', Type__c=uTypeAgn.Id,AccountId = objAcc.id);
        insert conTest;
        
        //Create conga template
        APXTConga4__Conga_Template__c congaTemp=new APXTConga4__Conga_Template__c(APXTConga4__Name__c='Test Cong Template');
        Insert congaTemp;
        
        Document d = new Document(); 
        d.Name = 'TEV17-Event-Image'; 
        d.FolderId = UserInfo.getUserId();//documents[0].FolderId;
        d.IsPublic = true; 
        d.Body =Blob.valueOf('Some Text'); 
        d.ContentType = 'image/jpeg';
        insert d;
        
        Event_Series__c evntSeries = new Event_Series__c();
        evntSeries.Status__c='Active';
        insert evntSeries;
        
        Event_Edition__c eventEdition = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today(),Event_Edition_Status__c='Confirmed',Part_of_Series__c=evntSeries.id,Contract_Template__c=congaTemp.Id,Event_Website__c='http://www.testevent.com',Event_Edition_Image_URL__c=d.Id,Invoice_From_Email_ID__c='Test',Max_Hold_Booth__c=50,Max_Hold_Days__c=10,Measurement__c='Feet',Next_Edition__c='2019',Payment_Schedule__c='50-50',Quote_Template__c=congaTemp.Id,Venue__c='Test',Year__c='2018',Event_Currency__c='USD',Cutoff_Date_1__c=  System.today() + 5,Informa_Logo__c=d.Id);
        insert eventEdition;
        
        //Create Event_Settings__c
        Event_Settings__c eventSettings = new Event_Settings__c(Name='Test',About_Show__c='Test',ShowHours1__c='test',ShowHours2__c='Test',Branding_Color__c='Black',Link_1__c='http://m.www.google.com/',Is_Stand_Design_Visible__c=True,Is_Stand_Detail_Visible__c=True,Is_SubContractors_Visible__c=True,Is_Amount_Visible__c=True,
                                                                Link_2__c='http://m.www.google.com/',Link_3__c='http://m.www.google.com/',Link_4__c='http://m.www.google.com/',Link_1_Label__c='TestLink1',Link_2_Label__c='TestLink2',Link_3_Label__c='TestLink3',Link_4_Label__c='TestLink4',Allotment_By_Booth_Type__c=true,
                                                                FaceBook__c='http://m.www.facebook.com/',LinkedIn__c='http://m.www.linkedin.com/',Twitter__c='http://m.www.Twitter.com/',YouTube__c='http://m.www.youtube.com/',Custom_1_Title__c='CstmTitle',Event_Edition__c=eventEdition.Id,E_Commerce_Title__c='EC Title',Welcome_Stand_Contractor__c='WSC Test',Disable_this_information__c=True);
        
        insert eventSettings;
        //Create parent opportunity
        Opportunity oOpportunity1 = new Opportunity(Name = 'Expocad Opportunity', CloseDate = Date.today(),StageName = 'Closed Won', EventEdition__c = eventEdition.Id, Operations_Contact__c=con.Id,  AccountId = objAcc.Id, Billing_Contact__c = con.Id, Opportunity_Contact__c=con.id, User_Type__c=uTypeAgn.Id); 
        insert oOpportunity1;
        
        //Create another opportunity
        Opportunity oOpportunity = new Opportunity(Name = 'Expocad Opportunity',Parent_Opportunity__c = oOpportunity1.Id,Exhibitor_Paid_By__c = 'Co-Exhibitor Paid by Exhibitor', CloseDate = Date.today(),StageName = 'Closed Won', EventEdition__c = eventEdition.Id, Operations_Contact__c=con.Id,  AccountId = objAcc.Id, Billing_Contact__c = con.Id, Opportunity_Contact__c=con.id, User_Type__c=uTypeCoExh.id); 
        insert oOpportunity;
             
        ContactEventEditionMapping__c contevntmappng= new ContactEventEditionMapping__c();
        contevntmappng.SFContactID__c=conTest.id;
        contevntmappng.SFEventEditionID__c=eventEdition.Id;
        insert contevntmappng;
        
        //Creating USER
        User communityUser = new User();
        communityUser.FirstName = 'Sunil';
        communityUser.LastName = 'Bajoliya';
        communityUser.Email = 'test@wexeurope.com';
        communityUser.Username = 'astest@wexeurope.com';
        communityUser.Alias = 'astest';
        communityUser.ProfileId = profileId;
        communityUser.TimeZoneSidKey    = 'America/Denver';
        communityUser.LocaleSidKey      = 'en_US';
        communityUser.EmailEncodingKey  = 'UTF-8';
        communityUser.LanguageLocaleKey = 'en_US';
        communityUser.ContactId=con.id;
        insert communityUser;
        
        Opportunity_ExpoCAD_Booth_Mapping__c booths = new Opportunity_ExpoCAD_Booth_Mapping__c(Status__c ='Active');
        insert booths;
        
    }
    private static testMethod void unitTest1(){
        account objAcc1 = [select id, Name from account where Name='TestLName'];
        System.assertEquals('TestLName', objAcc1.name,'Error account is not created');
        
        AgentOwnedExhibitorUtils.getLastLoginDate(objAcc1.Id,'WoC');
        User usr = [select id,ContactId from User where UserName =: 'astest@wexeurope.com'];
        system.runAs(usr){
        AgentOwnedExhibitorUtils.getExhibitorType(objAcc1.Id,'Qo');
        }
        Contact testCon = [select id from Contact limit 1];
        AgentOwnedExhibitorUtils.resendWelcomeMail(testCon.Id,'WOC');
        
    }
    private static testMethod void unitTest(){
        AgentOwnedExhibitorUtils utils = new AgentOwnedExhibitorUtils();
        AgentOwnedExhibitorUtils.getEventDetails('WOC17');       
        Account testAcc = [select id from Account limit 1];
        System.assert(testAcc!=Null, 'Account should not be blank.');
        AgentOwnedExhibitorUtils.getAccountDetails(testAcc.Id);        
        //Opportunity testOpp = [select id,AccountId,EventEdition__r.Event_Code__c,EventEdition__r.Event_Edition_Status__c,StageName from Opportunity limit 1];
        AgentOwnedExhibitorUtils.getAOEbooths(testAcc.Id,'WOC17');
        AgentOwnedExhibitorUtils.getCoexhibitors(testAcc.Id,'WOC17');
        AgentOwnedExhibitorUtils.getEventId('WOC17');
        AgentOwnedExhibitorUtils.getAccccountContacts(testAcc.Id,'WOC17');
        User usr = [select id,ContactId from User where UserName =: 'astest@wexeurope.com'];
        system.runAs(usr){
        	AgentOwnedExhibitorUtils.getExhibitorType(testAcc.Id,'WOC17');
        }
        set<Id> conSet = new set<Id>();
        Contact testCon = [select id from Contact limit 1];
        AgentOwnedExhibitorUtils.getLastMailSentDate('WOC17',testCon.Id);
        AgentOwnedExhibitorUtils.resendWelcomeMail(testCon.Id,'WOC17');
        AgentOwnedExhibitorUtils.getLastLoginDate(testAcc.Id,'WOC17');
        
        AgentOwnedExhibitorUtils.getFormsStatus(testAcc.Id,'WOC17');
        AgentOwnedExhibitorUtils.getManualsStatus(testAcc.Id,'WOC17');
        system.runAs(usr){
        	AgentOwnedExhibitorUtils.getInitialData(testAcc.Id,'WOC17');
        }
        conSet.add(testCon.Id);
        AgentOwnedExhibitorUtils.getWelcomeEmailStatus(conSet,'WOC17');
        AgentOwnedExhibitorUtils.getContactUserMap(conSet);
        AgentOwnedExhibitorUtils.getAgentExhContactMap(conSet,'WOC17');
        set<Id> boothids = new set<Id>();
        list<ContactEventEditionMapping__c> conEvntMap = [select id,SFContactID__c,SFEventEditionID__c,SFContactID__r.AccountID from ContactEventEditionMapping__c limit 1];
        
        Opportunity_ExpoCAD_Booth_Mapping__c booth = [select id from Opportunity_ExpoCAD_Booth_Mapping__c limit 1];
        boothids.add(booth.Id);
        AgentOwnedExhibitorUtils.createAgentEventEditionMaping(conEvntMap);
        AgentOwnedExhibitorUtils.getbadgesStatusMap(boothids,'WOC17');
        AgentOwnedExhibitorUtils.getExhibitorProfileStatusMap(boothids,'WOC17');
        AgentOwnedExhibitorUtils.getStandContractorStatusMap(boothids,'WOC17');
        
    }
}