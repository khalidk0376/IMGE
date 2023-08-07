/*
* Created By:  Aishwarya (Girikon)
* Created on : 09/10/2019
* Modified by : 
* Modified On : 
* Description : This test class covers the apex class scheduledBatchAssignManuals
* Apex Class: scheduledBatchAssignManuals(100%) 
*/
@isTest
private class ScheduledBatchAssignManuals_Test
{
    @testSetup static void testSetupData() {
        
       // String cronEXP = '0 45 19 * * ?';
        User_Type__c uType = new User_Type__c();
        Account acc  = new Account();
        Contact con = new Contact();
        User u = new User();
        Event_Series__c oEventseries = new Event_Series__c();
        Event_Edition__c oEve = new Event_Edition__c();
        Form__c oForm = new Form__c();
        Form__c oForm2 = new Form__c();
        Form__c oForm3 = new Form__c();
        Profile communityprofile = new Profile();

         uType = new User_Type__c(Name = 'Agent');
        insert uType;
        System.AssertEquals(uType.Name, 'Agent', 'Error Not Agent');

        acc = new account(Name = 'TestLName');
        insert acc;
        System.AssertNotEquals(acc, null, 'Error Account Not Created');

        con = new Contact(LastName = 'User', FirstName = 'Test', Type__c = uType.Id, AccountId = acc.id);
        insert con;
        System.AssertNotEquals(con, null, 'Error Contact Not Created');        
        
        oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Event_Edition_Pool__c = 'WOC',Status__c = 'Active' );
        insert oEventseries;

        APXTConga4__Conga_Template__c conTemp = new APXTConga4__Conga_Template__c();
        conTemp.APXTConga4__Name__c = 'CongaTest';
        insert conTemp;
        
        APXTConga4__Conga_Template__c quoteTemp = new APXTConga4__Conga_Template__c();
        conTemp.APXTConga4__Name__c = 'QuoteTest';
        insert quoteTemp;

        oEve = new Event_Edition__c(Name = 'World of Concrete 2017', Contract_Template__c = conTemp.id, Event_Edition_Status__c = 'Confirmed', 
                                        Max_Hold_Days__c =10, Max_Hold_Booth__c = 10, Invoice_From_Email_ID__c='johncorner@gmail.com', Event_Website__c= 'google.com', 
                                        Measurement__c = 'Feet',Next_Edition__c ='2018',Payment_Schedule__c ='100', Quote_Template__c = quoteTemp.Id, Venue__c ='Corner',
                                        Year__c ='2018',
                                        Event_Edition_Image_URL__c ='0152J000003UrMhQAL', Event_Code__c = 'WOC17', End_Date__c = System.Today(), Start_Date__c = System.Today(), Event_Currency__c = 'USD', Part_of_Series__c = oEventseries.Id);
        insert oEve;
        System.assertEquals(oEve.Event_Code__c, 'WOC17', 'Event Code');
        
        List<Event_Settings__c> listEveSetting = new List<Event_Settings__c>();
        Event_Settings__c es = new Event_Settings__c();
        es.Event_Edition__c = oEve.Id;
        es.Is_Event_Edition_Live__c = True;
        listEveSetting.add(es);
        insert listEveSetting;
        
        List<Manual__c> listManuals = new List<Manual__c>();
       Manual__c man = new Manual__c(Section__c = 12345, Name = 'Test Manual Toc', Event_Edition__c = listEveSetting[0].Event_Edition__c, User_Type__c = 'Agent', Expocad_Booth_Type__c = 'Inline', Expocad_Product_Type__c = 'Barter Shell Scheme');
        listManuals.add(man);
        insert listManuals;
        
        ContactEventEditionMapping__c conevmap = new ContactEventEditionMapping__c(SFContactID__c=con.id,SFEventEditionID__c=oEve.id, User_Type__c=uType.Id);
        insert conevmap;
        
        Opportunity opp = new opportunity(name = 'test', Type = 'Existing Business',closeDate = Date.Today(), EventEdition__c=oEve.Id, StageName = 'Discover', AccountId = acc.id, Opportunity_Contact__c = con.id);
        insert opp;
        System.assertEquals('test' , opp.Name, 'error in asserts');
		
        SBQQ__Quote__c oQuote = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Contract Approved', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = opp.Id, SBQQ__Account__c = acc.Id, SBQQ__Primary__c = true);
        insert oQuote;
        
        opp.StageName = 'Closed Won';
        opp.SBQQ__PrimaryQuote__c= oQuote.Id;
        update opp;
        
        ExpocadBooth__c oEB = new ExpocadBooth__c(Selected__c = true, Status__c = 'Rented', Opportunity__c = opp.Id, Booth_Type__c = 'Corner', ShowInShow__c = 'TestShowInShow', Open_Corners__c = 23, Booth_Classes__c='tset2;;test4', Booth_Product_Type_EE__c = 'Space Only', Area__c = '400 SqFt',Quote__c=oQuote.Id,Pavilion__c='test');
        insert oEB;
        oEB.Booth_Type__c = 'TestBooth';    
        update oEB;		
		
        Opportunity_ExpoCAD_Booth_Mapping__c oEM = new Opportunity_ExpoCAD_Booth_Mapping__c(Opportunity__c = opp.Id, Quote__c=oQuote.Id,Expocad_Booth__c=oEB.ID, Status__c='Active');
        insert oEM;
        
        Manuals_Permission__c mPermission = new Manuals_Permission__c(Manuals__c = man.id);
        insert mPermission;
        User_Manual_Action__c userManual = new User_Manual_Action__c(Manual_Permission__c=mPermission.id, Account__c=acc.Id, User_Type__c=uType.Id);
        insert userManual;

    }
    static testmethod void schedulerTest() 
    {
        String cronEXP = '0 45 19 * * ?';       
        
        Test.startTest();
            String jobId = System.schedule('scheduledBatchAssignManuals_Test',  cronEXP, new scheduledBatchAssignManuals());
            CronTrigger ct = [SELECT 
                                Id, CronExpression, TimesTriggered, NextFireTime 
                              FROM 
                                CronTrigger 
                              WHERE 
                                id = :jobId];
            System.assertEquals(cronEXP, ct.CronExpression,0);
            System.assertEquals(0, ct.TimesTriggered,cronEXP);
        Test.stopTest();
    }
    
    static testmethod void schedulerTest2() 
    {
        String cronEXP = '0 45 19 * * ?'; 
        Manual__c m = new Manual__c();
        m = [select id,Name,Expocad_Booth_Type__c,Expocad_Product_Type__c from manual__c LIMIT 1];
        m.Expocad_Booth_Type__c = '';
        m.Expocad_Product_Type__c = '';
        update m;
      //  Manual__c man = new Manual__c(Section__c = 12345, Name = 'Test Manual Toc', Event_Edition__c = listEveSetting[0].Event_Edition__c, User_Type__c = 'Agent', Expocad_Booth_Type__c = 'Inline', Expocad_Product_Type__c = 'Barter Shell Scheme');

        Test.startTest();
            String jobId = System.schedule('scheduledBatchAssignManuals_Test',  cronEXP, new scheduledBatchAssignManuals());
            CronTrigger ct = [SELECT 
                                Id, CronExpression, TimesTriggered, NextFireTime 
                              FROM 
                                CronTrigger 
                              WHERE 
                                id = :jobId];
            System.assertEquals(cronEXP, ct.CronExpression,0);
            System.assertEquals(0, ct.TimesTriggered,cronEXP);
        Test.stopTest();
    }
    
    
}