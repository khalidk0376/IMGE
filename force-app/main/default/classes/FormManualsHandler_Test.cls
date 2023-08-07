/**
 * Created/Modified By: Girikon(Aishwarya)
 * Created On:          12/13/2017
 * Modified On:         18/07/2018, [Aishwarya BK-4903 June 3 2020]
 * @description : This test class covers the apex class : FormManualsHandler
 * Apex Class:          FormManualsHandler, trgDuplicateCheckOnManualPermission
**/

@isTest
public class FormManualsHandler_Test {
    
    /*@isTest static void testSetupData() {
        User_Type__c uType = new User_Type__c();
        User_Type__c uTypeAgent = new User_Type__c();
        Account acc  = new Account();
        Contact con = new Contact();
        User u = new User();
        Event_Series__c oEventseries = new Event_Series__c();
        Event_Edition__c oEve = new Event_Edition__c();
        skuid__Page__c skuidPage = new skuid__Page__c();
        skuid__Page__c skuidPage2 = new skuid__Page__c();
        Form__c oForm = new Form__c();
        Form__c oForm2 = new Form__c();
        Form__c oForm3 = new Form__c();
        Profile communityprofile = new Profile();

        uType = new User_Type__c(Name = 'Exhibitor');
        insert uType;
        System.AssertEquals(uType.Name, 'Exhibitor', 'Error Not Exhibitor');

        uTypeAgent = new User_Type__c(Name = 'Agent');
        insert uTypeAgent;
        System.AssertEquals(uTypeAgent.Name, 'Agent', 'Error NOt Agent');

        acc = new account(Name = 'TestLName');
        insert acc;
        System.AssertNotEquals(acc, null, 'Error Account Not Created');

        con = new Contact(LastName = 'User', FirstName = 'Test', Type__c = uType.Id, AccountId = acc.id);
        insert con;
        System.AssertNotEquals(con, null, 'Error Contact Not Created');

        Opportunity opp = new Opportunity(Name = 'TestLName', StageName = 'Closed Won', closedate = System.today(), AccountId = acc.Id);
        insert opp;
        System.AssertNotEquals(opp, null, 'Error Opp Not Created');

        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        u = new User(Alias = 'standt', Email = 'kumarusertskndskndsk@testorg.com',
                     EmailEncodingKey = 'UTF-8', LastName = 'Kumar', LanguageLocaleKey = 'en_US',
                     LocaleSidKey = 'en_US', ProfileId = p.Id, //contactID=con.Id,
                     TimeZoneSidKey = 'America/Los_Angeles', UserName = 'kumarusertskndskndsk@testorg.com');
        insert u;

        oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Event_Edition_Pool__c = 'WOC');
        insert oEventseries;

        oEve = new Event_Edition__c(Name = 'World of Concrete 2017', Event_Code__c = 'WOC17', End_Date__c = System.Today(), Start_Date__c = System.Today(), Event_Currency__c = 'USD');
        insert oEve;
        System.assertEquals(oEve.Event_Code__c, 'WOC17', 'Event Code');

        skuidPage = new skuid__Page__c(Name = 'Test', skuid__Type__c = 'Desktop', skuid__Module__c = 'Page Templates');
        insert skuidPage;
        System.assertEquals(skuidPage.skuid__Module__c, 'Page Templates', 'checking Page Templates type');

        skuidPage2 = new skuid__Page__c(Name = 'Test2', skuid__Type__c = 'Desktop', skuid__Module__c = 'Page Templates');
        insert skuidPage2;

        oForm = new Form__c(SKUID_Template__c = skuidPage.id, Doc_Type__c = 'Online', Form__c = 1, Deadline__c = System.Today());
        insert oForm;
        System.assertEquals(oForm.SKUID_Template__c, skuidPage.id, 'checking SKUID_Template__c Id');

        oForm2 = new Form__c(SKUID_Template__c = skuidPage2.id, Doc_Type__c = 'Online', Form__c = 2, Deadline__c = System.Today());
        insert oForm2;
        System.assertEquals(oForm2.SKUID_Template__c, skuidPage2.id, 'checking SKUID_Template__c Id');

        oForm3 = new Form__c(SKUID_Template__c = skuidPage2.id, Doc_Type__c = 'Online', Form__c = 3, Deadline__c = System.Today());
        insert oForm3;
    }*/
    @isTest
    static void createUserFormActionRecordsTest() {
        User_Type__c uType = new User_Type__c();
        User_Type__c uTypeAgent = new User_Type__c();
        Account acc  = new Account();
        Contact con = new Contact();
        User u = new User();
        Event_Series__c oEventseries = new Event_Series__c();
        Event_Edition__c oEve = new Event_Edition__c();
        Form__c oForm = new Form__c();
        Form__c oForm2 = new Form__c();
        Form__c oForm3 = new Form__c();
        Profile communityprofile = new Profile();

        uType = new User_Type__c(Name = 'Exhibitor');
        insert uType;
        System.AssertEquals(uType.Name, 'Exhibitor', 'Error Not Exhibitor');

        uTypeAgent = new User_Type__c(Name = 'Agent');
        insert uTypeAgent;
        System.AssertEquals(uTypeAgent.Name, 'Agent', 'Error NOt Agent');

        acc = new account(Name = 'TestLName');
        insert acc;
        System.AssertNotEquals(acc, null, 'Error Account Not Created');

        con = new Contact(LastName = 'User', FirstName = 'Test', Type__c = uType.Id, AccountId = acc.id);
        insert con;
        System.AssertNotEquals(con, null, 'Error Contact Not Created');

        Opportunity opp = new Opportunity(Name = 'TestLName', StageName = 'Closed Won', closedate = System.today(), AccountId = acc.Id);
        insert opp;
        System.AssertNotEquals(opp, null, 'Error Opp Not Created'); 

        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        u = new User(Alias = 'standt', Email = 'kumarusertskndskndsk@testorg.com',
                     EmailEncodingKey = 'UTF-8', LastName = 'Kumar', LanguageLocaleKey = 'en_US',
                     LocaleSidKey = 'en_US', ProfileId = p.Id, //contactID=con.Id,
                     TimeZoneSidKey = 'America/Los_Angeles', UserName = 'kumarusertskndskndsk@testorg.com');
        insert u;

        oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Event_Edition_Pool__c = 'WOC');
        insert oEventseries;

        oEve = new Event_Edition__c(Name = 'World of Concrete 2017', Event_Code__c = 'WOC17', End_Date__c = System.Today(), Start_Date__c = System.Today(), Event_Currency__c = 'USD');
        insert oEve;
        System.assertEquals(oEve.Event_Code__c, 'WOC17', 'Event Code');

        oForm = new Form__c( Doc_Type__c = 'Online', Form__c = 1, Deadline__c = System.Today());
        insert oForm;

        oForm2 = new Form__c( Doc_Type__c = 'Online', Form__c = 2, Deadline__c = System.Today());
        insert oForm2;

        oForm3 = new Form__c( Doc_Type__c = 'Online', Form__c = 3, Deadline__c = System.Today());
        insert oForm3;
        System.runAs(u) {
            // The following code runs as user 'u'
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId());

            Event_Edition_Form__c oEEForm = new Event_Edition_Form__c(Event_Edition__c = oEve.id, Forms__c = oForm.id);
            insert oEEForm;
            System.assertEquals(oEEForm.Event_Edition__c, oEve.id, 'checking Event Id');

            Event_Edition_Form__c oEEForm2 = new Event_Edition_Form__c(Event_Edition__c = oEve.id, Forms__c = oForm2.id, Expocad_Booth_Class__c = 'Show Management', Expocad_Booth_Type__c = 'Corner', Expocad_Product_Type__c = 'Space only', User_Type__c = 'Exhibitor');
            insert oEEForm2;

            List<Forms_Permission__c> listFP = new List<Forms_Permission__c>();
            Forms_Permission__c fPermission = new Forms_Permission__c(Event_Edition_Form__c = oEEForm.id, User_Type__c = uType.Id);
            listFP.add(fPermission);
            Forms_Permission__c fPermission2 = new Forms_Permission__c(Event_Edition_Form__c = oEEForm.id, User_Type__c = uType.Id);
            listFP.add(fPermission2);
            Set<String> formId = new Set<String>();
            formId.add(fPermission.Id);
            Test.startTest();

            insert listFP;
            ContactEventEditionMapping__c cEEM = new ContactEventEditionMapping__c(SFEventEditionID__c = oEEForm.Event_Edition__c, SFContactID__c = con.Id, User_Type__c = fPermission.User_Type__c);
            insert cEEM;
            system.debug('==================cEEM: ' + cEEM);

            ExpocadBooth__c expocad = new ExpocadBooth__c(Booth_Number__c = 'TestBoothNo', status__c = 'Rented', Booth_Type__c = 'Island', Matched_Product_Name__c = 'Shell Scheme');
            insert expocad;
            system.debug('==================expocad: ' + expocad);

            Opportunity_ExpoCAD_Booth_Mapping__c oppexpobooth = new Opportunity_ExpoCAD_Booth_Mapping__c(Expocad_Booth__c = expocad.id , Account__c = acc.id);
            insert oppexpobooth;
            system.debug('==================oppexpobooth: ' + oppexpobooth);

            User_Form_Action__c uFAction = new User_Form_Action__c(Form_Permission__c = fPermission.id, User_Form_Contact__c = cEEM.SFContactID__c, Account__c = cEEM.SFContactID__r.AccountId);
            insert uFAction;
            System.assert(uFAction != null, 'checking User_Form_Action');

            //Duplicate form permission check
            FormManualsHandler handler = new FormManualsHandler();
            handler.duplicateCheckOnFormPermission(listFP);
            FormManualsHandler.createUserFormAction2(formId);
            Test.stopTest();
        }
    }
    @isTest
    static void createUserManualActionRecordsTest() {
        // This code runs as the system user
        User_Type__c uType = new User_Type__c();
        User_Type__c uTypeAgent = new User_Type__c();
        Account acc  = new Account();
        Contact con = new Contact();
        User u = new User();
        Event_Series__c oEventseries = new Event_Series__c();
        Event_Edition__c oEve = new Event_Edition__c();
        Form__c oForm = new Form__c();
        Form__c oForm2 = new Form__c();
        Form__c oForm3 = new Form__c();
        Profile communityprofile = new Profile();

        uType = new User_Type__c(Name = 'Exhibitor');
        insert uType;
        System.AssertEquals(uType.Name, 'Exhibitor', 'Error Not Exhibitor');

        uTypeAgent = new User_Type__c(Name = 'Agent');
        insert uTypeAgent;
        System.AssertEquals(uTypeAgent.Name, 'Agent', 'Error NOt Agent');

        acc = new account(Name = 'TestLName');
        insert acc;
        System.AssertNotEquals(acc, null, 'Error Account Not Created');

        con = new Contact(LastName = 'User', FirstName = 'Test', Type__c = uType.Id, AccountId = acc.id);
        insert con;
        System.AssertNotEquals(con, null, 'Error Contact Not Created');

        Opportunity opp = new Opportunity(Name = 'TestLName', StageName = 'Closed Won', closedate = System.today(), AccountId = acc.Id);
        insert opp;
        System.AssertNotEquals(opp, null, 'Error Opp Not Created');

        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        u = new User(Alias = 'standt', Email = 'kumarusertskndskndsk@testorg.com',
                     EmailEncodingKey = 'UTF-8', LastName = 'Kumar', LanguageLocaleKey = 'en_US',
                     LocaleSidKey = 'en_US', ProfileId = p.Id, //contactID=con.Id,
                     TimeZoneSidKey = 'America/Los_Angeles', UserName = 'kumarusertskndskndsk@testorg.com');
        insert u;

        oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Event_Edition_Pool__c = 'WOC');
        insert oEventseries;

        oEve = new Event_Edition__c(Name = 'World of Concrete 2017', Event_Code__c = 'WOC17', End_Date__c = System.Today(), Start_Date__c = System.Today(), Event_Currency__c = 'USD');
        insert oEve;
        System.assertEquals(oEve.Event_Code__c, 'WOC17', 'Event Code');

        oForm = new Form__c( Doc_Type__c = 'Online', Form__c = 1, Deadline__c = System.Today());
        insert oForm;

        oForm2 = new Form__c( Doc_Type__c = 'Online', Form__c = 2, Deadline__c = System.Today());
        insert oForm2;

        oForm3 = new Form__c( Doc_Type__c = 'Online', Form__c = 3, Deadline__c = System.Today());
        insert oForm3;
        System.runAs(u) {
            // The following code runs as user 'u'
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId());

            Manual__c man = new Manual__c(Section__c = 12345, Name = 'Test Manual Toc', Event_Edition__c = oEve.Id, User_Type__c = 'Exhibitor', Expocad_Booth_Class__c = '', Expocad_Booth_Type__c = 'Inline', Expocad_Product_Type__c = 'Barter Shell Scheme');
            insert man;
            System.assertEquals(man.Event_Edition__c, oEve.id, 'Event Id');

            Manuals_Permission__c mPermission = new Manuals_Permission__c(Manuals__c = man.id, User_Type__c = uType.Id);
            Manuals_Permission__c mPermission2 = new Manuals_Permission__c(Manuals__c = man.id, User_Type__c = uType.Id);
            List<Manuals_Permission__c> listManulaPermission = new List<Manuals_Permission__c>();
            listManulaPermission.Add(mPermission);
            listManulaPermission.Add(mPermission2);
            Set<String> manualId = new Set<String>();
            manualId.add(mPermission.Id);
            Test.startTest();

            // Setup test data
            insert listManulaPermission;

            ContactEventEditionMapping__c cEEM = new ContactEventEditionMapping__c(SFEventEditionID__c = man.Event_Edition__c, SFContactID__c = con.Id, User_Type__c = mPermission.User_Type__c);
            insert cEEM;
            system.debug('cEEM====' + cEEM);
            System.assert(cEEM != null, 'checking cEEM');

            User_Manual_Action__c uMAction = new User_Manual_Action__c(Manual_Permission__c = mPermission.id, User_Manual_Contact__c = cEEM.SFContactID__c, Account__c = cEEM.SFContactID__r.AccountId);
            insert uMAction;
            system.debug('uMAction====' + uMAction);
            System.assert(uMAction != null, 'checking User_Form_Action');

            //Duplicate manual permission check
            FormManualsHandler handler = new FormManualsHandler();
            handler.DuplicateCheckOnManualPermission(listManulaPermission);
            FormManualsHandler.createUserManualAction2(manualId);
            Test.stopTest();
        }
    }
    @isTest
    static void createUserManualWithOutExpocadTest() {
        // This code runs as the system user
        User_Type__c uType = new User_Type__c();
        User_Type__c uTypeAgent = new User_Type__c();
        Account acc  = new Account();
        Contact con = new Contact();
        User u = new User();
        Event_Series__c oEventseries = new Event_Series__c();
        Event_Edition__c oEve = new Event_Edition__c();
        Form__c oForm = new Form__c();
        Form__c oForm2 = new Form__c();
        Form__c oForm3 = new Form__c();
        Profile communityprofile = new Profile();

        uType = new User_Type__c(Name = 'Exhibitor');
        insert uType;
        System.AssertEquals(uType.Name, 'Exhibitor', 'Error Not Exhibitor');

        uTypeAgent = new User_Type__c(Name = 'Agent');
        insert uTypeAgent;
        System.AssertEquals(uTypeAgent.Name, 'Agent', 'Error NOt Agent');

        acc = new account(Name = 'TestLName');
        insert acc;
        System.AssertNotEquals(acc, null, 'Error Account Not Created');

        con = new Contact(LastName = 'User', FirstName = 'Test', Type__c = uType.Id, AccountId = acc.id);
        insert con;
        System.AssertNotEquals(con, null, 'Error Contact Not Created');

        Opportunity opp = new Opportunity(Name = 'TestLName', StageName = 'Closed Won', closedate = System.today(), AccountId = acc.Id);
        insert opp;
        System.AssertNotEquals(opp, null, 'Error Opp Not Created');

        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        u = new User(Alias = 'standt', Email = 'kumarusertskndskndsk@testorg.com',
                     EmailEncodingKey = 'UTF-8', LastName = 'Kumar', LanguageLocaleKey = 'en_US',
                     LocaleSidKey = 'en_US', ProfileId = p.Id, //contactID=con.Id,
                     TimeZoneSidKey = 'America/Los_Angeles', UserName = 'kumarusertskndskndsk@testorg.com');
        insert u;

        oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Event_Edition_Pool__c = 'WOC');
        insert oEventseries;

        oEve = new Event_Edition__c(Name = 'World of Concrete 2017', Event_Code__c = 'WOC17', End_Date__c = System.Today(), Start_Date__c = System.Today(), Event_Currency__c = 'USD');
        insert oEve;
        System.assertEquals(oEve.Event_Code__c, 'WOC17', 'Event Code');

        oForm = new Form__c( Doc_Type__c = 'Online', Form__c = 1, Deadline__c = System.Today());
        insert oForm;

        oForm2 = new Form__c(Doc_Type__c = 'Online', Form__c = 2, Deadline__c = System.Today());
        insert oForm2;

        oForm3 = new Form__c(Doc_Type__c = 'Online', Form__c = 3, Deadline__c = System.Today());
        insert oForm3;
        System.runAs(u) {
            // The following code runs as user 'u'
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId());

            Account acc1 = new account(Name = 'TestLNameAcc');
            insert acc1;
            System.AssertNotEquals(acc1, null, 'Error Account Not Created');

            User_Type__c uType1 = new User_Type__c(Name = 'Agent');
            insert uType1;

            Contact con1 = new Contact(LastName = 'User', FirstName = 'Test', Type__c = uType1.Id, AccountId = acc1.id);
            insert con1;
            System.AssertNotEquals(con1, null, 'Error Contact Not Created');


            //Manual with blank expocad details
            Manual__c man = new Manual__c(Section__c = 12345, Name = 'Test Manual Toc', Event_Edition__c = oEve.Id, User_Type__c = 'Exhibitor', Expocad_Booth_Class__c = '', Expocad_Booth_Type__c = '', Expocad_Product_Type__c = '');
            insert man;
            System.assertEquals(man.Event_Edition__c, oEve.id, 'Event Id');

            Manuals_Permission__c mPermission = new Manuals_Permission__c(Manuals__c = man.id, User_Type__c = uType1.Id);
            insert mPermission;

            System.assertEquals(mPermission.Manuals__c, man.id, 'Manuals Id');
            Test.startTest();

            // Setup test data
            ContactEventEditionMapping__c cEEM = new ContactEventEditionMapping__c(SFEventEditionID__c = man.Event_Edition__c, SFContactID__c = con1.Id, User_Type__c = mPermission.User_Type__c);
            insert cEEM;
            system.debug('cEEM====' + cEEM);
            System.assert(cEEM != null, 'checking cEEM');
            User_Manual_Action__c uMAction = new User_Manual_Action__c(Manual_Permission__c = mPermission.id, User_Manual_Contact__c = cEEM.SFContactID__c, Account__c = cEEM.SFContactID__r.AccountId);
            insert uMAction;
            system.debug('uMAction====' + uMAction);
            System.assert(uMAction != null, 'checking User_Form_Action');

            Test.stopTest();
        }
    }
    
    @isTest
    static void createUserManualRecords() {
        // This code runs as the system user
        User_Type__c uType = new User_Type__c();
        User_Type__c uTypeAgent = new User_Type__c();
        Account acc  = new Account();
        Contact con = new Contact();
        User u = new User();
        Event_Series__c oEventseries = new Event_Series__c();
        Event_Edition__c oEve = new Event_Edition__c();
        Form__c oForm = new Form__c();
        Profile communityprofile = new Profile();

        uType = new User_Type__c(Name = 'Exhibitor');
        insert uType;
        System.AssertEquals(uType.Name, 'Exhibitor', 'Error Not Exhibitor');

        uTypeAgent = new User_Type__c(Name = 'Agent');
        insert uTypeAgent;
        System.AssertEquals(uTypeAgent.Name, 'Agent', 'Error NOt Agent');

        acc = new account(Name = 'TestLName');
        insert acc;
        System.AssertNotEquals(acc, null, 'Error Account Not Created');

        con = new Contact(LastName = 'User', FirstName = 'Test', Type__c = uType.Id, AccountId = acc.id);
        insert con;
        System.AssertNotEquals(con, null, 'Error Contact Not Created');

        Opportunity opp = new Opportunity(Name = 'TestLName', StageName = 'Closed Won', closedate = System.today(), AccountId = acc.Id);
        insert opp;
        System.AssertNotEquals(opp, null, 'Error Opp Not Created');

        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        u = new User(Alias = 'kks', Email = 'kkskndskndsk@testorg.com',
                     EmailEncodingKey = 'UTF-8', LastName = 'Kumar', LanguageLocaleKey = 'en_US',
                     LocaleSidKey = 'en_US', ProfileId = p.Id, //contactID=con.Id,
                     TimeZoneSidKey = 'America/Los_Angeles', UserName = 'kkskndskndsk@testorg.com');
        insert u;

        oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Event_Edition_Pool__c = 'WOC');
        insert oEventseries;

        oEve = new Event_Edition__c(Name = 'World of Concrete 2017', Event_Code__c = 'WOC17', End_Date__c = System.Today(), Start_Date__c = System.Today(), Event_Currency__c = 'USD');
        insert oEve;
        System.assertEquals(oEve.Event_Code__c, 'WOC17', 'Event Code');

        oForm = new Form__c( Doc_Type__c = 'Online', Form__c = 1, Deadline__c = System.Today());
        insert oForm;

        System.runAs(u) {
            // The following code runs as user 'u'
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId());

            Account acc1 = new account(Name = 'TestLNameAcc');
            insert acc1;
            System.AssertNotEquals(acc1, null, 'Error Account Not Created');

            User_Type__c uType1 = new User_Type__c(Name = 'Agent');
            insert uType1;

            Contact con1 = new Contact(LastName = 'User', FirstName = 'Test', Type__c = uType1.Id, AccountId = acc1.id);
            insert con1;
            System.AssertNotEquals(con1, null, 'Error Contact Not Created');


            //Manual with blank expocad details
            Manual__c man = new Manual__c(Section__c = 12345, Name = 'Test Manual Toc', Event_Edition__c = oEve.Id, User_Type__c = 'Exhibitor', Expocad_Booth_Type__c = 'Inline', Expocad_Product_Type__c = '');
            insert man;
            System.assertEquals(man.Event_Edition__c, oEve.id, 'Event Id');

            Manuals_Permission__c mPermission = new Manuals_Permission__c(Manuals__c = man.id, User_Type__c = uType1.Id);
            insert mPermission;

            System.assertEquals(mPermission.Manuals__c, man.id, 'Manuals Id');
            Test.startTest();

            // Setup test data
            ContactEventEditionMapping__c cEEM = new ContactEventEditionMapping__c(SFEventEditionID__c = man.Event_Edition__c, SFContactID__c = con1.Id, User_Type__c = mPermission.User_Type__c);
            insert cEEM;
            system.debug('cEEM====' + cEEM);
            System.assert(cEEM != null, 'checking cEEM');
            User_Manual_Action__c uMAction = new User_Manual_Action__c(Manual_Permission__c = mPermission.id, User_Manual_Contact__c = cEEM.SFContactID__c, Account__c = cEEM.SFContactID__r.AccountId);
            insert uMAction;
            system.debug('uMAction====' + uMAction);
            System.assert(uMAction != null, 'checking User_Form_Action');

            Test.stopTest();
        }
    }
}