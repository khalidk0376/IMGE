/**
 * Created : Girikon(Divaker)
 * Created On:          11 May 2018
 * Test Class:          SendWelcomeEmailPreview
**/
@isTest
public class SendWelcomeEmailPreview_Test {
    static testMethod void sendWelcomTestMethod(){
        Contact con = new Contact(LastName='UserLast',FirstName ='Test',email='test1@test.com');
        insert con;
        System.AssertNotEquals(con, null,'Contact not equal null');
        Event_Edition__c oEve = new Event_Edition__c(Name='TOC Europe 2018',Event_Code__c='18toce',End_Date__c=System.Today(),Start_Date__c=System.Today());
        insert oEve;
        Event_Settings__c oEventSett = new Event_Settings__c(Contractor_Email_Content1__c='Test Contractor',Contractor_Email_Content2__c='Test Contractor',Co_Exhibitor_Email_Content1__c='test Co Exh1',Co_Exhibitor_Email_Content2__c='test Co Exh2',Exhibitor_Email_Content1__c='testExh1',Exhibitor_Email_Content2__c='testExh2',Agent_Email_Content1__c='Test Agent1', Agent_Email_Content2__c='Test Agent 2', Stand_Contractor_Content1__c='stantcon1', Stand_Contractor_Content2__c='standcon2', Event_Edition__c=OEve.id);
        insert oEventSett;

        SendWelcomeEmailPreview.sendWelcomeEmail('SendEmail', 'Exhibitor', oEve.Id);
        SendWelcomeEmailPreview.sendWelcomeEmail('SendEmail', 'StandContractor', oEve.Id);
        SendWelcomeEmailPreview.sendWelcomeEmail('SendEmail', 'Co-Exhibitor', oEve.Id);
        SendWelcomeEmailPreview.sendWelcomeEmail('SendEmail', 'Agent', oEve.Id);
        SendWelcomeEmailPreview.sendWelcomeEmail('SendEmail', 'Contractor', oEve.Id);
    }
}