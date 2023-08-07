/**
* File:        BoothSelectionHlpr_Test
* Project:     GAP
* Date:        Sep 13, 2016
* Created By:  Kumar Gaurav
* *************************************************************************
* Description: Test class for BoothSelectionHlpr.
* *************************************************************************
* History: Modified By Avinash Shukla (Parent_opportunity__c, User_Type__r.Name fields to the Opportunity object Query, FOR BK-2896) 12-02-2020
*/
@isTest(seeAlldata = false)
public class BoothSelectionHlpr_Test {
    
    static testMethod void unitTest() {
        ExpocadCredential__c expCred =  new ExpocadCredential__c(Name = 'ExpocadApiCredential',Org_Id__c = UserInfo.getOrganizationId(),Expocad_Host_URL__c = 'test.com',Url__c = 'test.com');
        insert expCred;
        
        Account oAccount = new Account(Name='Expocad Account', CurrencyIsoCode = 'USD');
        insert oAccount;
        List<Account> acc = [Select Id, NAme from Account];
        System.assertEquals('Expocad Account', acc[0].Name, 'Error');
        Contact oCon = new Contact(LastName='ContTest1', Email='test1contact@duptest.com', AccountId = oAccount.Id, MailingStreet = 'Test',MailingCity ='Test',MailingState='Delhi',MailingCountry='India',MailingPostalCode = '123445',Phone = '1212121212',Fax='2323232323');
        insert oCon;
        
        User oUser = [SELECT Id FROM User WHERE Id = : UserInfo.getUserId()];
        AccountTeamMember oAtm =new AccountTeamMember(AccountId = oAccount.id, userId = oUser.id);
        insert oAtm;
        
        Brand__c oBrand = new Brand__c(Name='World of Concrete', SSC_Email_Distribution_ID__c = 'test@test.tst');
        insert oBrand;
        
        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Brand__c=oBrand.id,Event_Edition_Pool__c = 'WOC');
        insert oEventseries;
        
        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017',Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information',Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'sbwoc7', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = '',Booth_Rent_Stage__c='On Contract');
        oEvent.Expocad_API_Url__c = 'https://api2.expocad.com';
        insert oEvent;
        
        Opportunity oOpportunity = new Opportunity(Name = 'Expocad Opportunity', CloseDate = Date.today(), StageName = 'Proposal', EventEdition__c = oEvent.Id, Event_Series__c = oEventseries.Id, AccountId = oAccount.Id, Billing_Contact__c = oCon.Id , Exhibitor_Paid_By__c = 'Exhibitor Paid by Agent');
        insert oOpportunity;
        
        SBQQ__Quote__c oQuote = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Contract Approved', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = oOpportunity.Id, SBQQ__Account__c = oAccount.Id, SBQQ__Primary__c = true);
        insert oQuote;
        
        Opportunity oOpportunity2 = [SELECT Id, Parent_opportunity__c, User_Type__r.Name, Name, Account.Name, AccountId, SBQQ__PrimaryQuote__c, Billing_Contact__c FROM Opportunity WHERE Name = 'Expocad Opportunity'];
        Opportunity_ExpoCAD_Booth_Mapping__c oppexpmpp = new Opportunity_ExpoCAD_Booth_Mapping__c(Display_Name__c = 'Test Rajesh' , Account__c = oAccount.Id , Opportunity__c = oOpportunity2.Id) ;
        insert oppexpmpp;     
        Test.StartTest();
        BoothSelectionHlpr oBoothSelectionHlpr = new BoothSelectionHlpr();
        Boolean isEXB = oBoothSelectionHlpr.ExbIDPresent('sbwoc7', oOpportunity2 , '');
        isEXB = oBoothSelectionHlpr.ExbIDPresentOrNot('BN', 'sbwoc7', oOpportunity2 , '');
        BoothSelectionHlpr.AsyncExhibitor('Z3.F10A', 'sbwoc7', oOpportunity2.Id , oQuote.Id , oOpportunity.AccountId, 'test@g.com' , '');
        BoothSelectionHlpr.AsyncRemoveExhibitor ('Z3.F10A', 'sbwoc7', oOpportunity2.Id , oQuote.Id , oOpportunity.AccountId, 'test@g.com');
        BoothSelectionHlpr.updateComment2onExbhitor('Z3.F10A', 'sbwoc7', oOpportunity.Id);
        BoothSelectionHlpr.AsyncupdateComment2onExbhitor('Z3.F10A', 'sbwoc7', oOpportunity.Id);
        BoothSelectionHlpr.createCoExibitor('Z3.F10A', 'sbwoc7',oQuote.Id, oOpportunity.Id, oOpportunity.AccountId,'test@g.com' , '');
        Test.StopTest();
        
    }
}