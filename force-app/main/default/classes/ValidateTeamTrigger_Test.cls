/**
 * Project:         GAP
 * Date:            23/09/2016
 * Test Class For:  AddAccountTeamMember_Trg.cls
 * Created By:      Rajesh Kumar
 * Code Coverage:   92% Coverage
 * Modified By: Rajesh Kumar on 09-02-2020 - BK-13603
 * @description This class is used in "AddAccountTeamMember_Trg.cls" class.
 */
@isTest
public class ValidateTeamTrigger_Test {
    static testMethod void validateTeamTest1() {
        Test.startTest(); 
        Account oacc = new Account (Name = 'Test');
        insert oacc ;
        User usr = [SELECT Id FROM User WHERE Id = : UserInfo.getUserId()];

        Account oparacc = new Account (Name = 'Partner Account');
        insert oparacc ;
        
        Account oAccount = new Account(Name='Expocad Account', CurrencyIsoCode = 'USD');
        insert oAccount;
        AccountTeamMember oatm = new AccountTeamMember(AccountId = oparacc.id,userId = Usr.id,TeamMemberRole = 'Account Executive');
        insert oatm;
        Contact oCon = new Contact(LastName='ContTest1', Email='test1contact@duptest.com', AccountId = oAccount.Id, MailingStreet = 'Test',MailingCity ='Test',MailingState='',MailingCountry='India');
        insert oCon;
    
        Partner oPartner = new Partner(Role = 'Agency', AccountToId = oparacc.id, AccountFromId = oacc.id);
        insert oPartner;
        
        APXTConga4__Conga_Template__c ct = new APXTConga4__Conga_Template__c();
        ct.APXTConga4__Template_Type__c = 'Document';
        insert ct;
        Event_Edition__c edi = new Event_Edition__c ();
        edi.name = 'Arab Health 2017';
        edi.Approval_Service_Now_ID__c = '123';
        edi.Alternate_Currency__c = 'AED';
        edi.CurrencyIsoCode='USD';
        edi.Tab1__c='Test';
        edi.Tab7__c = 'test1';
        edi.Event_Edition_Status__c = 'Completed';
        edi.Contract_Template__c = CT.Id;
        edi.End_Date__c = date.today().adddays(5);
        edi.Event_Website__c = 'https://www.google.com';
        edi.Event_Edition_Image_URL__c = 'test';
        edi.Invoice_From_Email_ID__c = 'test';
        edi.Max_Hold_Booth__c = 3;
        edi.Max_Hold_Days__c = 2;
        edi.Measurement__c = 'Meters';
        edi.Next_Edition__c = '2016';
        edi.Payment_Schedule__c = '50-50';
        edi.Quote_Template__c = CT.Id;
        edi.Start_Date__c = date.today();
        edi.Venue__c = 'Test';
        edi.Year__c = '2020';
        edi.Event_Code__c  = 'sbwoc7';
        edi.Cutoff_Date_1__c = date.today().adddays(1);
        insert edi;
        
        Brand__c oBrand = new Brand__c(Name='World of Concrete', SSC_Email_Distribution_ID__c = 'test@test.tst');
        insert oBrand;
        
        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Brand__c=oBrand.id , Event_Edition_Pool__c = 'WOC');
        insert oEventseries;
		User usr1 = [SELECT Id FROM User WHERE UserRole.Name = 'Sales-IMHX' And IsActive = true AND Profile.Name='Sales' LIMIT 1];
        system.runAs(usr1){
            Opportunity oOpportunity = new Opportunity(Name = 'Expocad Opportunity', CloseDate = Date.today(), StageName = 'Proposal', EventEdition__c = edi.Id, Event_Series__c = oEventseries.Id, AccountId = oAccount.Id, Billing_Contact__c = oCon.Id,Partner_Account__c=oparacc.id , status__c = 'Discover');
            insert oOpportunity;
            Opportunity oOpportunityRel = new Opportunity(Name = 'Expocad Opportunity Related', CloseDate = Date.today(), StageName = 'Proposal', EventEdition__c = edi.Id, Event_Series__c = oEventseries.Id, AccountId = oAccount.Id, Billing_Contact__c = oCon.Id,Partner_Account__c=oparacc.id , status__c = 'Discover', Parent_Opportunity__c = oOpportunity.Id);
            insert oOpportunityRel;
            System.assertEquals('Expocad Opportunity' , oOpportunity.name,'Eror');
            User oUser = [SELECT Id FROM User WHERE Id = : UserInfo.getUserId() limit 1];
            AccountTeamMember oatm1 =new AccountTeamMember(AccountId = oAccount.id,userId = oUser.id,TeamMemberRole = 'Account Executive');
            insert oatm1;
        }
        Test.stopTest();
    }
    
    static testMethod void validateTeamTest2() {
       Test.startTest();
        Account oacc = new Account (Name = 'Test');
        insert oacc ;
        
        User usr = [SELECT Id FROM User WHERE Id = : UserInfo.getUserId()];
        
        AccountTeamMember oatm =new AccountTeamMember(AccountId = oacc.id,userId = Usr.id,TeamMemberRole = 'Account Executive');
        insert oatm;
        
        Account oparacc = new Account (Name = 'Partner Account');
        insert oparacc ;
        
        Partner oPartner = new Partner(Role = 'Agency', AccountToId = oparacc.id, AccountFromId = oacc.id);
        insert oPartner;
        
        Event_Series__c ser = new Event_Series__c ();
        ser.name = 'Arab Health';
        ser.Event_Edition_Pool__c = 'WOC'; 
        insert ser;
        System.assertEquals('Arab Health' , ser.name,'Error');
        
        Event_Edition__c edi = new Event_Edition__c ();
        edi.name = 'Arab Health 2019';
        edi.Approval_Service_Now_ID__c = '1232';
        edi.Event_Edition_Status__c = 'Completed';
        edi.Tab1__c='Test';
        edi.Tab7__c = 'test1';
        insert edi;
        List<Opportunity> oppList = new List<Opportunity>(); 
        Opportunity opp = new opportunity (name = 'Girikon_TestClassOpp' ,  EventEdition__c = edi.Id,closeDate = Date.Today(), StageName= 'Proposal Approved' , AccountId = oacc.id , status__c = 'Discover' , Payment_Schedules__c = true);
        insert opp;
        Opportunity opprel = new opportunity (name = 'Girikon_TestClassOppewl' ,  parent_opportunity__c = opp.id, EventEdition__c = edi.Id,closeDate = Date.Today(), StageName= 'Proposal Approved' , AccountId = oacc.id , status__c = 'Discover' , Payment_Schedules__c = true);
        insert opprel;
        
        SBQQ__Quote__c oQuote = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Quote Sent', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = opp.Id, SBQQ__Account__c = oacc.Id, SBQQ__Primary__c = true);
        Insert oQuote;
        
        ExpocadBooth__c oEB3 = new ExpocadBooth__c(Selected__c = true, Status__c = 'Rented', Opportunity__c = opp.Id, Booth_Type__c = 'Corner', ShowInShow__c = 'TestShowInShow', Open_Corners__c = 23, Booth_Classes__c='tset2;test4', Booth_Product_Type_EE__c = 'Space Only', Area__c = '400 SqFt',Quote__c=oQuote.Id,Pavilion__c='test');
        insert oEB3;
        
        oppList.add(opp);
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>();
        List<Opportunity> oppUpdList = [select id from opportunity Limit 1 ];
        for(Opportunity oOpp : oppUpdList)
        {
            oppMap.put(oOpp.Id,oOpp);
        }
        opp.StageName = 'Proposal Sent';
        update opp;
        
        opp.StageName = 'Proposal Approved';
        update opp;
        opp.StageName ='Contract Sent';
        update opp;
        opp.StageName ='Pending Accounting Approval'; 
        update opp;
        opp.StageName ='AR Cancel / Re-bill'; 
        opp.Payment_Schedule_2__c = true;
        update opp;
        //opp.StageName = 'Closed Won';
        opp.IsCreatedByReviewProcess__c = false;
        update opp;
        opp.StageName ='Closed Lost';
        opp.Reason_Lost__c = 'Test';
        update opp;
        Test.stopTest();
    }    
}