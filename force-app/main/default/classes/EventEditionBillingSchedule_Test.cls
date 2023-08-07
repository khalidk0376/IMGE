/**
* Project:     GE-CRM IOM
* Date:        21/04/2023
* Created By:  Ansh
* *************************************************************************
* @description Test Class for EventEditionBillingScheduleController.
* *************************************************************************
* Ticket No: GECI-1461
*/
@istest
private class EventEditionBillingSchedule_Test {
    @isTest static void oppNotesAttachmentActivityMethodOne() {     
        
        //@Description: Insert Account.
        Account acc = new Account();
        acc.Name = 'Testing Account'; 
        acc.CurrencyIsoCode = 'USD';
        insert acc;
        
        //@Description: Insert Contact.
        Contact ocontact = new Contact();
        ocontact.FirstName = 'Testing First Name';
        ocontact.LastName = 'Testing Last Name';
        ocontact.Email = 'test.test@gmail.com';
        ocontact.AccountId = acc.Id;
        insert ocontact;
        
        //@Description: Insert Event Edition.
        Event_Edition__c eventEdition = new Event_Edition__c();
        eventEdition.Name = 'Testing Event Edition';
        eventEdition.Tab1__c = 'Tab1';
        eventEdition.Tab4__c = 'Tab4';
        eventEdition.Tab8__c = 'Tab8';
        insert eventEdition;
        
        //@Description: Insert Opportunity.
        Opportunity opp = new Opportunity();
        opp.Name = 'Testing Opportunity';
        opp.EventEdition__c = eventEdition.Id;
        opp.Opportunity_Contact__c = ocontact.Id;
        opp.AccountId = acc.Id;
        opp.CloseDate = Date.Today().addDays(1);
        opp.Type = 'New';
        opp.StageName = 'Customise';
        insert opp;

        Test.startTest();
        Opportunity opp2 = EventEditionBillingScheduleController.getPaymentSchedule(opp.Id);
        System.assertNotEquals(null, opp2, 'Opportunity detail not found');
        Test.stopTest();
    }
}