/**
 * File:            ReleaseNotification_Test
 * Project:         GAP
 * Date:            Jan 31, 2017
 * Code Coverage:   89%
 * Created By:      Kumar Gaurav
 * *************************************************************************
 * Description: Test class for ReleaseNotification, Schedule_Email_Notification_BR
                and Schedule_Email_Notification_AR.
 * *************************************************************************
 * History:
 * * Modified By : Rajesh kumar Yadav Bk-3751,[Modified By : Aishwarya 12 Aug 2020 BK-3751]
 */

@isTest(seeAlldata = false)
public class ReleaseNotification_Test {

  static testMethod void callAllMethod() {
    // Common data for all three classes : Started
    Account oAccount = new Account(Name = 'Expocad Account', CurrencyIsoCode = 'USD', Phone = '2423122323');
    insert oAccount;
    system.assertEquals(oAccount.Name, 'Expocad Account', 'Both values should be the same.');

    Contact oCon = new Contact(LastName = 'ContTest1', Email = 'test1contact@duptest.com', AccountId = oAccount.Id, MailingStreet = 'Test', MailingCity = 'Test', MailingState='', MailingCountry='India',Phone = '2423122323', AssistantPhone = '2423122323', HomePhone = '2121212121', MobilePhone = '2121212145', OtherPhone = '2154215421');
    insert oCon;
    system.assertEquals(oCon.LastName, 'ContTest1', 'Both values should be the same.');
    
    ExpocadCredential__c oExpocadCredential = new ExpocadCredential__c(name = 'ExpocadApiCredential', Url__c='https://api.expocad.com');
    insert oExpocadCredential;
    system.assertEquals(oExpocadCredential.Url__c, 'https://api.expocad.com', 'Both values should be the same.');
    
    User oUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
    system.assertEquals(oUser.Id, UserInfo.getUserId(), 'User Id equals Login user id');
    
    AccountTeamMember oAtm = new AccountTeamMember(AccountId = oAccount.id, userId = oUser.id);
    insert oAtm;
    system.assertEquals(oAtm.AccountId, oAccount.id, 'Both values should be the same.');

    Brand__c oBrand = new Brand__c(Name = 'World of Concrete', SSC_Email_Distribution_ID__c = 'test@test.tst');
    insert oBrand;
    

    Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Brand__c = oBrand.id, Event_Edition_Pool__c = 'WOC');
    insert oEventseries;
    system.assertEquals(oEventseries.Package_Identifier__c, 'WOC', 'Both values should be the same.');
    
    Event_Edition__c oEvent = new Event_Edition__c(Event_Currency__c = 'USD', Name = 'World of Concrete 2017',Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information', Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = '', Max_Hold_Days__c = 0);
    insert oEvent;
    system.assertEquals(oEvent.Name, 'World of Concrete 2017', 'Both values should be the same.');

    //Event_Edition__c oEvent2 = new Event_Edition__c(Event_Currency__c = 'USD', Name = 'Toc Europe 2018',Tab1__c = 'Booth Applications2', Tab7__c = 'Billing Information1', Approval_Service_Now_ID__c = '123456', CurrencyIsoCode = 'USD', Event_Code__c = 'TOC218', Booth_Type__c = 'Island,Corner,Inline,Custom', No_Of_Corner__c = '0,1,2,3', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt', Booth_Product_Type__c = '', Max_Hold_Days__c = 3);
    //insert oEvent2;

    Opportunity oOpportunity = new Opportunity(Name = 'Expocad Opportunity', CloseDate = Date.today(), StageName = 'Proposal', EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id, AccountId = oAccount.Id, Billing_Contact__c = oCon.Id);
    insert oOpportunity;

    Opportunity oOpportunity2 = new Opportunity(Name = 'Expocad Opportunity', CloseDate = Date.today(), StageName = 'Proposal', EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id, AccountId = oAccount.Id, Billing_Contact__c = oCon.Id);
    insert oOpportunity2;

    SBQQ__Quote__c oQuote = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Quote Sent', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = oOpportunity.Id, SBQQ__Account__c = oAccount.Id, SBQQ__Primary__c = true);
    insert oQuote;
    system.assertEquals(oQuote.SBQQ__Status__c, 'Quote Sent', 'Both values should be the same.');

    ExpocadBooth__c oEB = new ExpocadBooth__c(Quote__c = oQuote.Id, Opportunity__c = oOpportunity.Id, Account__c = oAccount.Id, Open_Corners__c = 4, Dimensions__c = '', Booth_Type__c = 'Linear', Area__c = '100 SqFt', Last_Action_Date__c = Date.today(), Booth_Number__c = 'TESTBN', Status__c = 'On Hold', Selected__c = True);
    insert oEB;
    system.assertEquals(oEB.Quote__c, oQuote.Id, 'Both values should be the same.');

    ExpocadBooth__c oEB2 = new ExpocadBooth__c(Quote__c = oQuote.Id, Opportunity__c = oOpportunity.Id, Account__c = oAccount.Id, Open_Corners__c = 4, Dimensions__c = '', Booth_Type__c = 'Linear', Area__c = '100 SqFt', Last_Action_Date__c = Date.today(), Booth_Number__c = 'TESTBN4', Status__c = 'On Hold', Selected__c = True);
    insert oEB2;
    system.assertEquals(oEB2.Quote__c, oQuote.Id, 'Both values should be the same.');

    ExpocadBooth__c oEB3 = new ExpocadBooth__c(Quote__c = oQuote.Id, Opportunity__c = oOpportunity2.Id, Account__c = oAccount.Id, Open_Corners__c = 4, Dimensions__c = '', Booth_Type__c = 'Linear', Area__c = '100 SqFt', Last_Action_Date__c = Date.today(), Booth_Number__c = 'TESTBN3', Status__c = 'On Hold', Selected__c = True);
    insert oEB3;
    system.assertEquals(oEB3.Quote__c, oQuote.Id, 'Both values should be the same.');

    ExpocadBooth__c oEB4 = new ExpocadBooth__c(Quote__c = oQuote.Id, Opportunity__c = oOpportunity2.Id, Account__c = oAccount.Id, Open_Corners__c = 4, Dimensions__c = '', Booth_Type__c = 'Linear', Area__c = '100 SqFt', Last_Action_Date__c = Date.today(), Booth_Number__c = 'TESTBN4', Status__c = 'On Hold', Selected__c = True);
    insert oEB4;
    system.assertEquals(oEB4.Quote__c, oQuote.Id, 'Both values should be the same.');

    // Common data for all three classes : Closed

    Test.StartTest();

    // Test code to cover ReleaseNotification class
    ReleaseNotification oRN = new ReleaseNotification();
    oRN.OpportunityID = oOpportunity.Id;
    oRN.getHeldBooths();
    oRN.getHostUrl();
    oRN.getExpocadCode();
    oRN.getFooterLogo();
    String sBoothNamesAfterRelease = oRN.getBoothNamesAfterRelease();
    oRN.OpportunityID = oOpportunity2.Id;
    String sBoothNames = oRN.getBoothNames();
    String sBoothStatus = oRN.getBoothStatus();

    Datetime dt = Datetime.now().addMinutes(0);
    String sCRONEXP = '0 ' + dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();

    // Test code to cover Schedule_Email_Notification_BR class
    //String jobId = System.schedule('Schedule_Email_Notification_BR', sCRONEXP, new Schedule_Email_Notification_BR());

    // Test code to cover Schedule_Email_Notification_AR class
    String jobId2 = System.schedule('Schedule_Email_Notification_AR', sCRONEXP, new Schedule_Email_Notification_AR());
    Test.StopTest();
  }
  
  static testMethod void callAllMethod2() {
    Account oAccount = new Account(Name = 'Expocad Account', CurrencyIsoCode = 'USD', Phone = '2423122323');
    insert oAccount;
    system.assertEquals(oAccount.Name, 'Expocad Account', 'Both values should be the same.');

    Contact oCon = new Contact(LastName = 'ContTest1', Email = 'test1contact@duptest.com', AccountId = oAccount.Id, MailingStreet = 'Test', MailingCity = 'Test', MailingState='', MailingCountry='India',Phone = '2423122323', AssistantPhone = '2423122323', HomePhone = '2121212121', MobilePhone = '2121212145', OtherPhone = '2154215421');
    insert oCon;
    system.assertEquals(oCon.LastName, 'ContTest1', 'Both values should be the same.');
    
    ExpocadCredential__c oExpocadCredential = new ExpocadCredential__c(name = 'ExpocadApiCredential', Url__c='https://api.expocad.com');
    insert oExpocadCredential;
    system.assertEquals(oExpocadCredential.Url__c, 'https://api.expocad.com', 'Both values should be the same.');
    
    User oUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
    system.assertEquals(oUser.Id, UserInfo.getUserId(), 'User Id equals Login user id');
    
    AccountTeamMember oAtm = new AccountTeamMember(AccountId = oAccount.id, userId = oUser.id);
    insert oAtm;
    system.assertEquals(oAtm.AccountId, oAccount.id, 'Both values should be the same.');

    Brand__c oBrand = new Brand__c(Name = 'World of Concrete', SSC_Email_Distribution_ID__c = 'test@test.tst');
    insert oBrand;
    
    Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Brand__c = oBrand.id, Event_Edition_Pool__c = 'WOC');
    insert oEventseries;
    system.assertEquals(oEventseries.Package_Identifier__c, 'WOC', 'Both values should be the same.');
    
    Event_Edition__c oEvent = new Event_Edition__c(Event_Currency__c = 'USD', Name = 'World of Concrete 2017',Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information', Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = '', Max_Hold_Days__c = 1);
    insert oEvent;
    system.assertEquals(oEvent.Name, 'World of Concrete 2017', 'Both values should be the same.');

    Opportunity oOpportunity = new Opportunity(Name = 'Expocad Opportunity', CloseDate = Date.today(), StageName = 'Proposal', EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id, AccountId = oAccount.Id, Billing_Contact__c = oCon.Id);
    insert oOpportunity;

    SBQQ__Quote__c oQuote = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Quote Sent', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = oOpportunity.Id, SBQQ__Account__c = oAccount.Id, SBQQ__Primary__c = true);
    insert oQuote;
    system.assertEquals(oQuote.SBQQ__Status__c, 'Quote Sent', 'Both values should be the same.');

    ExpocadBooth__c oEB = new ExpocadBooth__c(Quote__c = oQuote.Id, Opportunity__c = oOpportunity.Id, Account__c = oAccount.Id, Open_Corners__c = 4, Dimensions__c = '', Booth_Type__c = 'Linear', Area__c = '100 SqFt', Last_Action_Date__c = Date.today(), Booth_Number__c = 'TESTBN', Status__c = 'On Hold', Selected__c = True,IsAssociatedBooth__c = false);
    insert oEB;
    system.assertEquals(oEB.Quote__c, oQuote.Id, 'Both values should be the same.');

    // Common data for all three classes : Closed

    Test.StartTest();
    // Test code to cover ReleaseNotification class
    ReleaseNotification oRN = new ReleaseNotification();
    oRN.OpportunityID = oOpportunity.Id;
    String sBoothNames = oRN.getBoothNames();

    Datetime dt = Datetime.now().addMinutes(0);
    String sCRONEXP = '0 ' + dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();

    // Test code to cover Schedule_Email_Notification_BR class
    String jobId = System.schedule('Schedule_Email_Notification_BR', sCRONEXP, new Schedule_Email_Notification_BR());
    Test.StopTest();
  }
}