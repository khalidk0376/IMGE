/**
* Created By    :   Girikon(Suraj)
* Created On    :   17/01/2019
* @description  :   Allow exhibitors to generate reports.
* Class  Tested :  ExportAOEReportsCtrl(94%)..
**/
@isTest 
public with sharing class ExportAOEReportsCtrl_Test 
{
    private static string sEventCodeNew;
    @isTest
    static void testExportToExcel()  
    {
        //Create account
        account objAcc = new account(Name='TestLName');
        insert objAcc;
        System.AssertNotEquals(objAcc, null, 'account must not be null');
        
        //Create User_Type__c
        User_Type__c uTypeAgn = new User_Type__c(Name='Agent');
        insert uTypeAgn;
        System.AssertNotEquals(uTypeAgn, null, 'User_Type__c must not be null');
        
        User_Type__c uTypeAOE = new User_Type__c(Name='Agent Owned Exhibitor');
        insert uTypeAOE;
        System.AssertNotEquals(uTypeAOE, null, 'User_Type__c must not be null');
        
        //Create contact
        Contact con = new Contact(LastName='User',FirstName ='Test',email='test1@test.com', Type__c=uTypeAgn.Id,AccountId = objAcc.id);
        insert con;
        System.AssertNotEquals(con, null, 'Contact must not be null');
        
        Contact conTest = new Contact(LastName='Test',FirstName ='Test',email='test1@test.com', Type__c=uTypeAgn.Id,AccountId = objAcc.id);
        insert conTest;
        System.AssertNotEquals(conTest, null, 'Contact must not be null');
        
        //create ExpocadBooth__c
        ExpocadBooth__c expBooth = new ExpocadBooth__c(Booth_Number__c='TestBoothNo',Matched_Product_Name__c = 'Space Only',Dimensions__c = '5M x 10M',Area__c ='50 m²',status__c='Rented');
        insert expBooth;
        System.AssertNotEquals(expBooth, null, 'ExpocadBooth__c must not be null');  
        
        //Create event edition
        Event_Edition__c eventEdition = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today());
        insert eventEdition;
        System.AssertNotEquals(eventEdition, null, 'Event_Edition__c must not be null');
        
        //Create Event_Settings__c
        Event_Settings__c eventSettings = new Event_Settings__c(Name='Test',About_Show__c='Test',ShowHours1__c='test',ShowHours2__c='Test',Branding_Color__c='Black',Link_1__c='http://m.www.google.com/',Is_Stand_Design_Visible__c=True,Is_Stand_Detail_Visible__c=True,Is_SubContractors_Visible__c=True,Is_Amount_Visible__c=True,
                                                                Link_2__c='http://m.www.google.com/',Link_3__c='http://m.www.google.com/',Link_4__c='http://m.www.google.com/',Link_1_Label__c='TestLink1',Link_2_Label__c='TestLink2',Link_3_Label__c='TestLink3',Link_4_Label__c='TestLink4',
                                                                FaceBook__c='http://m.www.facebook.com/',LinkedIn__c='http://m.www.linkedin.com/',Twitter__c='http://m.www.Twitter.com/',YouTube__c='http://m.www.youtube.com/',Custom_1_Title__c='CstmTitle',Event_Edition__c=eventEdition.Id,E_Commerce_Title__c='EC Title',Welcome_Stand_Contractor__c='WSC Test',Disable_this_information__c=True,
                                                                Is_Event_Edition_Live__c = true, Send_Welcome_Email__c = true,  Send_email_notification_to_Agents__c  =true);
        eventSettings.Allotment_By_Booth_Type__c=true; 
        insert eventSettings;
        System.AssertNotEquals(eventSettings, null, 'Event_Settings__c must not be null');
        
        //Create parent opportunity
        Opportunity oOpportunity1 = new Opportunity(Name = 'Expocad Opportunity', CloseDate = Date.today(),StageName = 'Closed Won', 
                                                    EventEdition__c = eventEdition.Id, Operations_Contact__c=con.Id,  AccountId = objAcc.Id, Billing_Contact__c = con.Id, Opportunity_Contact__c=con.id); 
        insert oOpportunity1;
        System.AssertNotEquals(oOpportunity1, null, 'Parent Opportunity must not be null');
        
        //Create another opportunity
        Opportunity oOpportunity = new Opportunity(Name = 'Expocad Opportunity', CloseDate = Date.today(),StageName = 'Closed Won', 
                                                   EventEdition__c = eventEdition.Id, parent_Opportunity__c = oOpportunity1.id, Operations_Contact__c=con.Id,  AccountId = objAcc.Id, Billing_Contact__c = con.Id, Opportunity_Contact__c=con.id); 
        insert oOpportunity;
        System.AssertNotEquals(oOpportunity, null, 'Opportunity must not be null');
        
        SBQQ__Quote__c oQuote = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Quote Sent', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = oOpportunity.Id, SBQQ__Account__c =objAcc.Id, SBQQ__Primary__c = true);
        insert oQuote;
        
        oOpportunity.StageName='Closed Won';
        oOpportunity.SBQQ__PrimaryQuote__c = oQuote.Id;
        update oOpportunity;
        
        expBooth.Opportunity__c=oOpportunity.Id;
        update expBooth;
        
        //create Opportunity_ExpoCAD_Booth_Mapping__c
        Opportunity_ExpoCAD_Booth_Mapping__c oppBooth=new Opportunity_ExpoCAD_Booth_Mapping__c();
        oppBooth.Account__c=objAcc.Id;
        oppBooth.Quote__c = oQuote.Id;
        oppBooth.Opportunity__c = oOpportunity.Id;
        oppBooth.Expocad_Booth__c = expBooth.Id;
        oppBooth.Status__c='Active';
        insert oppBooth;
        System.AssertNotEquals(oppBooth, null, 'Opportunity_ExpoCAD_Booth_Mapping__c must not be null'); 
        
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User Custom'].Id; 
        //Create user
        User usr = new User();
        usr.FirstName = 'Sunil';
        usr.LastName = 'Bajoliya';
        usr.Email = 'test@wexeurope.com';
        usr.Username = 'astest@wexeurope.com';
        usr.Alias = 'astest';
        usr.ProfileId = profileId;
        usr.TimeZoneSidKey    = 'America/Denver';
        usr.LocaleSidKey      = 'en_US';
        usr.EmailEncodingKey  = 'UTF-8';
        usr.LanguageLocaleKey = 'en_US';
        usr.ContactId=con.id;
        insert usr;
        System.AssertNotEquals(usr, null, 'usr must not be null ');
        
        //Create Booth Size Badge Limit
        Booth_Size_Badge_Limit__c objBoothLimit = new Booth_Size_Badge_Limit__c(Badges_Allowed__c=10,Booth_Size_From__c=10,Booth_Size_To__c=20,Event_Edition__c=eventEdition.Id);
        insert objBoothLimit;
        System.AssertNotEquals(objBoothLimit, null, 'Booth_Size_Badge_Limit__c must not be null');
        List<AgentOwnExhibitorsCtrl.exhibitorsWrapperClass> exhibitorsList = new List<AgentOwnExhibitorsCtrl.exhibitorsWrapperClass>();// list of wrapper class
        //exhibitorsList = AgentOwnExhibitorsCtrl.getAllCustomers('WOC17','','All','',null,null,false);
        System.debug('    exhibitorsList ::::: '+exhibitorsList);
        
            //Create Exhibitor_Badge__c
            Exhibitor_Badge__c  exbBadge = new Exhibitor_Badge__c();
            exbBadge.First_Name__c='test';
            exbBadge.Last_Name__c='test';
            exbBadge.Address__c ='test Add';
            exbBadge.City__c ='Noida';
            exbBadge.State__c ='UP';
            exbBadge.Nationality__c = 'DZ';
            exbBadge.Age_Bracket__c ='21-24';
            exbBadge.Account__c = objAcc.Id;
            exbBadge.User_Name__c = usr.Id;
            exbBadge.Event_Edition__c = eventEdition.Id;
            exbBadge.ExpocadBooth__c = expBooth.Id;
            exbBadge.Opp_Booth_Mapping__c = oppBooth.id;
            insert exbBadge;
            
            //Create BoothContractorMapping
            BoothContractorMapping__c bcm=new BoothContractorMapping__c();            
            bcm.Contact__c = con.id;
            bcm.Event_Edition__c=eventEdition.Id;   
            bcm.Status__c ='Approved';
            bcm.Approved__c = true;
            bcm.Opp_Booth_Mapping__c = oppBooth.id;
            insert bcm;
        
        
        system.runAs(usr)
        {            
            string sEventCode=eventEdition.Event_Code__c;
            
            Test.setCurrentPage(Page.ExportAOEReports);
            
            test.startTest();
            apexpages.currentpage().getparameters().put('eventId' , sEventCode);
            apexpages.currentpage().getparameters().put('accountId' , '');
            apexpages.currentpage().getparameters().put('reportName' , 'AllExhibitors');
            ExportAOEReportsCtrl aoe = new ExportAOEReportsCtrl();  // initialize class
            aoe.exportToExcel();
            
            //apexpages.currentpage().getparameters().put('reportName' , 'ExhibitorsMissingBadges');
            //ExportAOEReportsCtrl aoe1 = new ExportAOEReportsCtrl();
            //aoe1.exportToExcel();
            
            // apexpages.currentpage().getparameters().put('reportName' , 'ExhibitorsMissingForms');
            //ExportAOEReportsCtrl aoe2 = new ExportAOEReportsCtrl();
            ///aoe2.exportToExcel();
            
            //apexpages.currentpage().getparameters().put('reportName' , 'ExhibitorsMissingManuals');
            //ExportAOEReportsCtrl aoe3 = new ExportAOEReportsCtrl();
            //aoe3.exportToExcel();
            
            apexpages.currentpage().getparameters().put('reportName' , 'ExhibitorsBadgeInformation');
            ExportAOEReportsCtrl aoe4 = new ExportAOEReportsCtrl();
            aoe4.exportToExcel();
            
            
         
            
            //apexpages.currentpage().getparameters().put('reportName' , 'ExhibitorLastlogin');
            //ExportAOEReportsCtrl aoe6 = new ExportAOEReportsCtrl();
            //aoe6.exportToExcel();
            
            
            
            test.stopTest();
        }
    }
    @isTest static void testExcel()  {
        //Create account
        account objAcc = new account(Name='TestLName');
        insert objAcc;
        System.AssertNotEquals(objAcc, null, 'account must not be null');
        
        //Create User_Type__c
        User_Type__c uTypeAgn = new User_Type__c(Name='Agent');
        insert uTypeAgn;
        System.AssertNotEquals(uTypeAgn, null, 'User_Type__c must not be null');
        
        User_Type__c uTypeAOE = new User_Type__c(Name='Agent Owned Exhibitor');
        insert uTypeAOE;
        System.AssertNotEquals(uTypeAOE, null, 'User_Type__c must not be null');
        
        //Create contact
        Contact con = new Contact(LastName='User',FirstName ='Test',email='test1@test.com', Type__c=uTypeAgn.Id,AccountId = objAcc.id);
        insert con;
        System.AssertNotEquals(con, null, 'Contact must not be null');
        
        Contact conTest = new Contact(LastName='Test',FirstName ='Test',email='test1@test.com', Type__c=uTypeAgn.Id,AccountId = objAcc.id);
        insert conTest;
        System.AssertNotEquals(conTest, null, 'Contact must not be null');
        
        //create ExpocadBooth__c
        ExpocadBooth__c expBooth = new ExpocadBooth__c(Booth_Number__c='TestBoothNo',Matched_Product_Name__c = 'Space Only',Dimensions__c = '5M x 10M',Area__c ='50 m²',status__c='Rented');
        insert expBooth;
        System.AssertNotEquals(expBooth, null, 'ExpocadBooth__c must not be null');  
        
        //Create event edition
        Event_Edition__c eventEdition = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today());
        insert eventEdition;
        System.AssertNotEquals(eventEdition, null, 'Event_Edition__c must not be null');
        
        //Create Event_Settings__c
        Event_Settings__c eventSettings = new Event_Settings__c(Name='Test',About_Show__c='Test',ShowHours1__c='test',ShowHours2__c='Test',Branding_Color__c='Black',Link_1__c='http://m.www.google.com/',Is_Stand_Design_Visible__c=True,Is_Stand_Detail_Visible__c=True,Is_SubContractors_Visible__c=True,Is_Amount_Visible__c=True,
                                                                Link_2__c='http://m.www.google.com/',Link_3__c='http://m.www.google.com/',Link_4__c='http://m.www.google.com/',Link_1_Label__c='TestLink1',Link_2_Label__c='TestLink2',Link_3_Label__c='TestLink3',Link_4_Label__c='TestLink4',
                                                                FaceBook__c='http://m.www.facebook.com/',LinkedIn__c='http://m.www.linkedin.com/',Twitter__c='http://m.www.Twitter.com/',YouTube__c='http://m.www.youtube.com/',Custom_1_Title__c='CstmTitle',Event_Edition__c=eventEdition.Id,E_Commerce_Title__c='EC Title',Welcome_Stand_Contractor__c='WSC Test',Disable_this_information__c=True,
                                                                Is_Event_Edition_Live__c = true, Send_Welcome_Email__c = true,  Send_email_notification_to_Agents__c  =true);
        eventSettings.Allotment_By_Booth_Type__c=true; 
        insert eventSettings;
        System.AssertNotEquals(eventSettings, null, 'Event_Settings__c must not be null');
        
        //Create parent opportunity
        Opportunity oOpportunity1 = new Opportunity(Name = 'Expocad Opportunity', CloseDate = Date.today(),StageName = 'Closed Won', 
                                                    EventEdition__c = eventEdition.Id, Operations_Contact__c=con.Id,  AccountId = objAcc.Id, Billing_Contact__c = con.Id, Opportunity_Contact__c=con.id); 
        insert oOpportunity1;
        System.AssertNotEquals(oOpportunity1, null, 'Parent Opportunity must not be null');
        
        //Create another opportunity
        Opportunity oOpportunity = new Opportunity(Name = 'Expocad Opportunity', CloseDate = Date.today(),StageName = 'Closed Won', 
                                                   EventEdition__c = eventEdition.Id, parent_Opportunity__c = oOpportunity1.id, Operations_Contact__c=con.Id,  AccountId = objAcc.Id, Billing_Contact__c = con.Id, Opportunity_Contact__c=con.id); 
        insert oOpportunity;
        System.AssertNotEquals(oOpportunity, null, 'Opportunity must not be null');
        
        SBQQ__Quote__c oQuote = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Quote Sent', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = oOpportunity.Id, SBQQ__Account__c =objAcc.Id, SBQQ__Primary__c = true);
        insert oQuote;
        
        oOpportunity.StageName='Closed Won';
        oOpportunity.SBQQ__PrimaryQuote__c = oQuote.Id;
        update oOpportunity;
        
        expBooth.Opportunity__c=oOpportunity.Id;
        update expBooth;
        
        //create Opportunity_ExpoCAD_Booth_Mapping__c
        Opportunity_ExpoCAD_Booth_Mapping__c oppBooth=new Opportunity_ExpoCAD_Booth_Mapping__c();
        oppBooth.Account__c=objAcc.Id;
        oppBooth.Quote__c = oQuote.Id;
        oppBooth.Opportunity__c = oOpportunity.Id;
        oppBooth.Expocad_Booth__c = expBooth.Id;
        oppBooth.Status__c='Active';
        insert oppBooth;
        System.AssertNotEquals(oppBooth, null, 'Opportunity_ExpoCAD_Booth_Mapping__c must not be null'); 
        
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User Custom'].Id; 
        //Create user
        User usr = new User();
        usr.FirstName = 'Sunil';
        usr.LastName = 'Bajoliya';
        usr.Email = 'test@wexeurope.com';
        usr.Username = 'astest@wexeurope.com';
        usr.Alias = 'astest';
        usr.ProfileId = profileId;
        usr.TimeZoneSidKey    = 'America/Denver';
        usr.LocaleSidKey      = 'en_US';
        usr.EmailEncodingKey  = 'UTF-8';
        usr.LanguageLocaleKey = 'en_US';
        usr.ContactId=con.id;
        insert usr;
        System.AssertNotEquals(usr, null, 'usr must not be null ');
        
        //Create Booth Size Badge Limit
        Booth_Size_Badge_Limit__c objBoothLimit = new Booth_Size_Badge_Limit__c(Badges_Allowed__c=10,Booth_Size_From__c=10,Booth_Size_To__c=20,Event_Edition__c=eventEdition.Id);
        insert objBoothLimit;
        System.AssertNotEquals(objBoothLimit, null, 'Booth_Size_Badge_Limit__c must not be null');
       // List<AgentOwnExhibitorsCtrl.exhibitorsWrapperClass> exhibitorsList = new List<AgentOwnExhibitorsCtrl.exhibitorsWrapperClass>();// list of wrapper class
        //exhibitorsList = AgentOwnExhibitorsCtrl.getAllCustomers('WOC17','','All','',null,null,false);
      //  System.debug('    exhibitorsList ::::: '+exhibitorsList);
        
            //Create Exhibitor_Badge__c
            Exhibitor_Badge__c  exbBadge = new Exhibitor_Badge__c();
            exbBadge.First_Name__c='test';
            exbBadge.Last_Name__c='test';
            exbBadge.Address__c ='test Add';
            exbBadge.City__c ='Noida';
            exbBadge.State__c ='UP';
            exbBadge.Nationality__c = 'DZ';
            exbBadge.Age_Bracket__c ='21-24';
            exbBadge.Account__c = objAcc.Id;
            exbBadge.User_Name__c = usr.Id;
            exbBadge.Event_Edition__c = eventEdition.Id;
            exbBadge.ExpocadBooth__c = expBooth.Id;
            exbBadge.Opp_Booth_Mapping__c = oppBooth.id;
            insert exbBadge;
            
            //Create BoothContractorMapping
            BoothContractorMapping__c bcm=new BoothContractorMapping__c();            
            bcm.Contact__c = con.id;
            bcm.Event_Edition__c=eventEdition.Id;   
            bcm.Status__c ='Approved';
            bcm.Approved__c = true;
            bcm.Opp_Booth_Mapping__c = oppBooth.id;
            insert bcm;
        
        
        system.runAs(usr)
        {   
            string sEventCode=eventEdition.Event_Code__c;
            Test.setCurrentPage(Page.ExportAOEReports);
            test.startTest();
            apexpages.currentpage().getparameters().put('eventId' , sEventCode);
            apexpages.currentpage().getparameters().put('accountId' , '');
            
            apexpages.currentpage().getparameters().put('reportName' , 'ExhibitorsProfilesInformation');
            ExportAOEReportsCtrl aoe7 = new ExportAOEReportsCtrl();
            aoe7.exportToExcel();
            
            apexpages.currentpage().getparameters().put('reportName' , 'ExhibitorsStandContractorInformation');
            ExportAOEReportsCtrl aoe8 = new ExportAOEReportsCtrl();
            aoe8.exportToExcel(); 
            
            apexpages.currentpage().getparameters().put('reportName' , 'ExhibitorActivitySummary');
            ExportAOEReportsCtrl aoe5 = new ExportAOEReportsCtrl();
            aoe5.exportToExcel();
            
            test.stopTest();
        }
    }
}