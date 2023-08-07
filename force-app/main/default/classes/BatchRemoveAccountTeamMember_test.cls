@isTest
public class BatchRemoveAccountTeamMember_test {
    
    static testMethod void validateBatch() {
        
        Account oAccount = new Account(Name='Account TeamMember Account', CurrencyIsoCode = 'USD');
        insert oAccount;
        System.assertEquals('Account TeamMember Account' , oAccount.name,'Error');
        User usr = [SELECT Id FROM User WHERE Id = : UserInfo.getUserId()];
        
        Contact oCon = new Contact(LastName='ContTest1', Email='test1contact@duptest.com', AccountId = oAccount.Id, MailingStreet = 'Test',MailingCity ='Test',MailingState='',MailingCountry='India');
        insert oCon;
        
        Event_Edition__c edi = new Event_Edition__c ();
        edi.name = 'Arab Health 2017';
        edi.Approval_Service_Now_ID__c = '123';
        edi.Alternate_Currency__c = 'AED';
        edi.CurrencyIsoCode='USD';
        edi.Tab1__c='Test';
        edi.Tab7__c = 'test1';
        edi.Event_Edition_Status__c = 'Completed';
        edi.End_Date__c = date.today().adddays(5);
        edi.Event_Website__c = 'https://www.google.com';
        edi.Event_Edition_Image_URL__c = 'test';
        edi.Invoice_From_Email_ID__c = 'test';
        edi.Max_Hold_Booth__c = 3;
        edi.Max_Hold_Days__c = 2;
        edi.Measurement__c = 'Meters';
        edi.Next_Edition__c = '2016';
        edi.Payment_Schedule__c = '50-50';
        edi.Start_Date__c = date.today();
        edi.Venue__c = 'Test';
        edi.Year__c = '2020';
        edi.Event_Code__c  = 'sbwoc7';
        edi.Cutoff_Date_1__c = date.today().adddays(1);
        insert edi;
        
        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC' , Event_Edition_Pool__c = 'WOC');
        insert oEventseries;
        
        Opportunity oOpportunity = new Opportunity(Name = 'Test Opportunity', CloseDate = Date.today(), StageName = 'Proposal', EventEdition__c = edi.Id, Event_Series__c = oEventseries.Id, AccountId = oAccount.Id, Billing_Contact__c = oCon.Id, status__c = 'Discover');
        oOpportunity.ownerId = usr.id;
        insert oOpportunity;
        
        AccountTeamMember oatm1 =new AccountTeamMember(AccountId = oAccount.id,userId = usr.id,TeamMemberRole = 'Account Executive');
        oatm1.UserId = oOpportunity.OwnerId;
        insert oatm1;
        
        Test.startTest();
        BatchRemoveAccountTeamMember batchObj = new BatchRemoveAccountTeamMember();
        Set<Id> oppId = new  Set<Id>();
        oppId.add(oatm1.userId);
        Database.executeBatch(batchObj);
        String sch = '0 0 23 * * ?'; 
        system.schedule('BatchRemoveAccountTeamMember', sch, batchObj);
        Test.stopTest();       
    }
}