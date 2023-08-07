/**
 * This AccountAddressValidationCtrl_Test class used to test AccountAddressValidationCtrl
 * @Author      : Sudip Halder
 * @Date        : 21/Dec/2017  
 */
@IsTest
public class AccountAddressValidationCtrl_Test {
	
    public TestMethod static void testAccountAddressValidationCtrl( ) {
    	
        Event_Series__c evntSeries = new Event_Series__c( name='test series' );
        insert evntSeries;
        Event_Series__c series = [ Select Id, Name From Event_Series__c Limit 1 ];
        System.AssertEquals(evntSeries.name,'test series','Event Series is not Valid');
        
        Event_Edition__c evntEdition = new Event_Edition__c( name='Test Edition' );
        evntEdition.Part_of_Series__c = evntSeries.id;
        evntEdition.Event_Currency__c = 'USD';
        evntEdition.Event_Code__c     = 'TestEdition';
        insert evntEdition;
        System.AssertEquals(evntEdition.name,'Test Edition','Event Edition is not Valid');
        Event_Edition__c edition = [ Select id, name From Event_Edition__c Limit 1 ];
        
        
        Account acc1 = new Account( name='Acc1', BillingStreet='test billStreet1', BillingCity='test city', BillingState='Arizona', BillingCountry='USA', Billing_Address_Line_2__c=' test Billing Address Line2', Tax_Id__c='tx001', CurrencyIsoCode = 'USD', Phone = '2423122323'); 
        Account acc2 = new Account( name='Acc2', BillingStreet='test billStreet2', BillingCity='test city', BillingState='Arizona', BillingCountry='USA', Billing_Address_Line_2__c=' test Billing Address Line2', Tax_Id__c='tx002', CurrencyIsoCode = 'USD', Phone = '2423122323'); 
		
		insert acc1;
        insert acc2;
        System.AssertEquals(acc1.Name,'Acc1','Invalid Account');	        
        
        Contact con1 = new Contact( FirstName='FName', LastName = 'ContTest1', Email = 'test1contact@duptest.com', AccountId = acc1.Id, MailingStreet = 'Test', MailingCity = 'Test', MailingState='Delhi', MailingCountry='India',Phone = '2423122323', AssistantPhone = '2423122323', HomePhone = '2121212121', MobilePhone = '2121212145', OtherPhone = '2154215421' );
        Contact con2 = new Contact( FirstName='FName', LastName = 'ContTest2', Email = 'test2contact@duptest.com', AccountId = acc1.Id, MailingStreet = 'Test', MailingCity = 'Test', MailingState='Delhi', MailingCountry='India',Phone = '2423122323', AssistantPhone = '2423122323', HomePhone = '2121212121', MobilePhone = '2121212145', OtherPhone = '2154215421' );        
        Contact con3 = new Contact( FirstName='FName', LastName = 'ContTest3', Email = 'test3contact@duptest.com', AccountId = acc2.Id, MailingStreet = 'Test', MailingCity = 'Test', MailingState='Delhi', MailingCountry='India',Phone = '2423122323', AssistantPhone = '2423122323', HomePhone = '2121212121', MobilePhone = '2121212145', OtherPhone = '2154215421' ); 
        Contact con4 = new Contact( FirstName='FName', LastName = 'ContTest4', Email = 'test4contact@duptest.com', AccountId = acc2.Id, MailingStreet = 'Test', MailingCity = 'Test', MailingState='Delhi', MailingCountry='India',Phone = '2423122323', AssistantPhone = '2423122323', HomePhone = '2121212121', MobilePhone = '2121212145', OtherPhone = '2154215421'  );
        
        insert con1;
        insert con2;
        insert con3;
        insert con4;
        
        Opportunity opp1 = new Opportunity( Name = 'Opportunity 1', CloseDate = Date.today(), StageName = 'Proposal', EventEdition__c = edition.Id, Event_Series__c = series.Id, AccountId = acc1.Id, Billing_Contact__c = con1.Id );
        Opportunity opp2 = new Opportunity( Name = 'Opportunity 2', CloseDate = Date.today(), StageName = 'Proposal', EventEdition__c = edition.Id, Event_Series__c = series.Id, AccountId = acc1.Id, Billing_Contact__c = con2.Id );
        Opportunity opp3 = new Opportunity( Name = 'Opportunity 3', CloseDate = Date.today(), StageName = 'Proposal', EventEdition__c = edition.Id, Event_Series__c = series.Id, AccountId = acc2.Id, Billing_Contact__c = con3.Id );
        Opportunity opp4 = new Opportunity( Name = 'Opportunity 4', CloseDate = Date.today(), StageName = 'Proposal', EventEdition__c = edition.Id, Event_Series__c = series.Id, AccountId = acc2.Id, Billing_Contact__c = con4.Id );

		insert opp1;
        insert opp2;
        insert opp3;
        insert opp4;
        
        String ids = 'tx001,tx002';
        PageReference pg = Page.AccountAddressValidation;
        pg.getParameters( ).put( 'selectedIDs', ids );
        pg.getParameters( ).put( 'AccounttNameString', 'Acc' );
        test.setCurrentPageReference( pg );
        
        Test.startTest( );
        AccountAddressValidationCtrl accAddValidObj = new AccountAddressValidationCtrl( );
        accAddValidObj.evntSeriesChnge( );
        accAddValidObj.getEventSeries( );
        accAddValidObj.selectedOptionchng( );
        accAddValidObj.selectedEventSeries = series.Id;
        accAddValidObj.getEventEdition( );
        accAddValidObj.selectedEventEdition = edition.Id;
        accAddValidObj.evntEditionChnge( );
        accAddValidObj.evntSeriesChnge( );
        accAddValidObj.selectedOptionchng( );
        accAddValidObj.getAccounts( );
        accAddValidObj.selectedAccounts( );
        accAddValidObj.continueValidate( );
        accAddValidObj.batchProcess( );
        accAddValidObj.reloadPopup( );
        accAddValidObj.getFilterOptions( );
        accAddValidObj.selectedOption = 'Tax_ID_Verified__c';
        accAddValidObj.searchAccounts( );
        accAddValidObj.accountName = 'Acc';
        accAddValidObj.selectedEventEdition = edition.Id;
        accAddValidObj.getAccounts( );
        accAddValidObj.totalAccounts( );
        accAddValidObj.accountName = '';
        accAddValidObj.getAccounts( );
        accAddValidObj.totalAccounts( );
        accAddValidObj.FirstPage( );
        accAddValidObj.previous( );
        accAddValidObj.next( );
        accAddValidObj.LastPage( );
        accAddValidObj.getprev( );
        accAddValidObj.getnxt( );
        accAddValidObj.resetOffset( );
        accAddValidObj.refreshTable( );
        accAddValidObj.getAllAccountsId( );
        accAddValidObj.addAllAccountsIds( );
        
        Test.stopTest( );        
    }
  
}