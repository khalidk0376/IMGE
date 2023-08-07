/**
 * Created : Girikon(Divaker)
 * Created On:          11 May 2018
 * Class:         WelcomeEmailPreviewCtr
**/
@isTest
public class WelcomeEmailPreviewCtr_Test{
    static testMethod void welcomeEmailTest(){
        User_Type__c uType = new User_Type__c(Name ='Exhibitor');
        insert uType;
        System.AssertEquals(UType.Name, 'Exhibitor','Invalid Account');
        
        account acc = new account(Name='TestLName');
        insert acc;
        System.AssertNotEquals(acc, null,'Account not equal null');
        
        Contact con = new Contact(LastName='UserLast',FirstName ='Test',email='test1@test.com', Type__c=uType.Id,AccountId = acc.id);
        insert con;
        System.AssertNotEquals(con, null,'Contact not equal null');
        
        Event_Edition__c oEve = new Event_Edition__c(Name='TOC Europe 2018',Event_Code__c='18toce',End_Date__c=System.Today(),Start_Date__c=System.Today());
        insert oEve;
        
        ContactEventEditionMapping__c conevmap = new ContactEventEditionMapping__c(SFContactID__c=con.id,SFEventEditionID__c=OEve.id, User_Type__c=UType.Id);
        insert conevmap;
        
        Event_Settings__c oEventSett = new Event_Settings__c(Co_Exhibitor_Email_Content1__c='test Co Exh1',Co_Exhibitor_Email_Content2__c='test Co Exh2',Exhibitor_Email_Content1__c='testExh1',Exhibitor_Email_Content2__c='testExh2',Agent_Email_Content1__c='Test Agent1', Agent_Email_Content2__c='Test Agent 2', Stand_Contractor_Content1__c='stantcon1', Stand_Contractor_Content2__c='standcon2', Event_Edition__c=oEve.id);
        insert oEventSett;
        
        Test.setCurrentPageReference(new PageReference('Page.WelcomeEmailPreview'));
        System.currentPageReference().getParameters().put('eventCode', oEve.Id);
        System.currentPageReference().getParameters().put('Tab', 'Exhibitor');
        WelcomeEmailPreviewCtr objcomEx =new WelcomeEmailPreviewCtr ();
        
        Test.setCurrentPageReference(new PageReference('Page.WelcomeEmailPreview'));
        System.currentPageReference().getParameters().put('eventCode', oEve.Id);
        System.currentPageReference().getParameters().put('Tab', 'StandContractor');
        WelcomeEmailPreviewCtr objcomSH =new WelcomeEmailPreviewCtr ();
        
        Test.setCurrentPageReference(new PageReference('Page.WelcomeEmailPreview'));
        System.currentPageReference().getParameters().put('eventCode', oEve.Id);
        System.currentPageReference().getParameters().put('Tab', 'Agent');
        WelcomeEmailPreviewCtr objcomAg =new WelcomeEmailPreviewCtr ();
        
        Test.setCurrentPageReference(new PageReference('Page.WelcomeEmailPreview'));
        System.currentPageReference().getParameters().put('eventCode', oEve.Id);
        System.currentPageReference().getParameters().put('Tab', 'Co_Exhibitor');
        WelcomeEmailPreviewCtr objcomCOExh =new WelcomeEmailPreviewCtr ();
        
        Test.setCurrentPageReference(new PageReference('Page.WelcomeEmailPreview'));
        System.currentPageReference().getParameters().put('eventCode', oEve.Id);
        System.currentPageReference().getParameters().put('Tab', 'Contractor');
        WelcomeEmailPreviewCtr objcom =new WelcomeEmailPreviewCtr ();
    }
}