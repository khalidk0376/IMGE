/*
 * Created By:  Aishwarya Kumar (Girikon)
 * Created/Last Modified On :  28 June 2021
 * Apex Class:  ScheduledBatchAssignTotalBadgesVisitGES(100%)
*/
@isTest
public class SchdBatchAssignTotalBadgesVisit_Test
{
    static testmethod void schedulerTest() 
    {
        String cronEXP = '0 45 19 * * ?';
        
        Account acc  = new Account();
        Contact con = new Contact();

        Event_Series__c oEventseries = new Event_Series__c();
        Event_Edition__c oEve = new Event_Edition__c();
    
        acc = new account(Name = 'TestLName');
        insert acc;
        System.AssertNotEquals(acc, null, 'Error Account Not Created');
    
        con = new Contact(LastName = 'User', FirstName = 'Test', AccountId = acc.id);
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
        
        Test.startTest();
            String jobId = System.schedule('SchdBatchAssignTotalBadgesVisit_Test',  cronEXP, new ScheduledBatchAssignTotalBadgesVisitGES());
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