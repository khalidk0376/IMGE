/*
* Created By:  Aishwarya (Girikon)
* Created on : 09/10/2019
* Modified by : 
* Modified On : 
* Description : This test class covers the apex class scheduledBatchAssignForms
* Apex Class: scheduledBatchAssignForms(100%) 
*/
@isTest
private class ScheduledBatchAssignForms_Test
{

    static testmethod void schedulerTest() 
    {
        String cronEXP = '0 45 19 * * ?';
        
        User_Type__c uType = new User_Type__c();
        Account acc  = new Account();
        Contact con = new Contact();
        User u = new User();
        Event_Series__c oEventseries = new Event_Series__c();
        Event_Edition__c oEve = new Event_Edition__c();
      //  skuid__Page__c skuidPage2 = new skuid__Page__c();
        Form__c oForm2 = new Form__c();
        uType = new User_Type__c(Name = 'Agent');
        insert uType;
        System.AssertEquals(uType.Name, 'Agent', 'Error Not Agent');
    
        acc = new account(Name = 'TestLName');
        insert acc;
        System.AssertNotEquals(acc, null, 'Error Account Not Created');
    
        con = new Contact(LastName = 'User', FirstName = 'Test', Type__c = uType.Id, AccountId = acc.id);
        insert con;
        System.AssertNotEquals(con, null, 'Error Contact Not Created');
    
        oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Event_Edition_Pool__c = 'WOC', Status__c = 'Active');
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
        
       // skuidPage2 = new skuid__Page__c(Name = 'Test2', skuid__Type__c = 'Desktop', skuid__Module__c = 'Page Templates');
       // insert skuidPage2;
        
        oForm2 = new Form__c(Doc_Type__c = 'Online', Form__c = 2, Deadline__c = System.Today());
       // oForm2.SKUID_Template__c = skuidPage2.id;
        insert oForm2;
       // System.assertEquals(oForm2.SKUID_Template__c, skuidPage2.id, 'checking SKUID_Template__c Id');
        
        List<Event_Edition_Form__c> listEventForms = new List<Event_Edition_Form__c>();
        Event_Edition_Form__c oEEForm2 = new Event_Edition_Form__c(Event_Edition__c = listEveSetting[0].Event_Edition__c, Forms__c = oForm2.id, Expocad_Booth_Type__c = 'Corner', Expocad_Product_Type__c = 'Space only', User_Type__c = 'Agent');
        listEventForms.add(oEEForm2);
        insert listEventForms;
        
        Test.startTest();
            String jobId = System.schedule('scheduledBatchAssignForms_Test',  cronEXP, new scheduledBatchAssignForms());
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