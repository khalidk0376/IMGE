/**
 * This class test 'AccountAddressValidationBatch' class
 * 
 * @Author    : Sudip Halder
 * @Date      : 20/Jul/2018
 * Apex Class : AccountAddressValidationBatch
 */
@IsTest
public class AccountAddressValidationBatch_Test {
    
      public static TestMethod void testAccountAddressValidationBatch( ) {
        List <String> accIds = new List <String>( );
        
        Event_Series__c evntSeries = new Event_Series__c( name='test series' );
        insert evntSeries;
        Event_Series__c series = [ Select Id, Name From Event_Series__c Limit 1 ];
        
        Event_Edition__c evntEdition = new Event_Edition__c( name='Test Edition' );
        evntEdition.Part_of_Series__c = evntSeries.id;
        evntEdition.Event_Currency__c = 'USD';
        evntEdition.Event_Code__c     = 'TestEdition';
        insert evntEdition;
        Event_Edition__c edition = [ Select id, name From Event_Edition__c Limit 1 ];
          
        System.AssertEquals(evntEdition.name,'Test Edition','Event Edition is not Valid');
        Account acc1 = new Account( name='Acc1', BillingStreet='test billStreet1', BillingCity='test city', BillingState='Arizona', BillingCountry='USA', Billing_Address_Line_2__c=' test Billing Address Line2', Tax_Id__c='tx001', CurrencyIsoCode = 'USD', Phone = '2423122323'); 
        Account acc2 = new Account( name='Acc2', BillingStreet='test billStreet2', BillingCity='test city', BillingState='Arizona', BillingCountry='USA', Billing_Address_Line_2__c=' test Billing Address Line2', Tax_Id__c='tx002', CurrencyIsoCode = 'USD', Phone = '2423122323'); 
        
        insert acc1;
        insert acc2;
        
        accIds.add( acc1.Id );
        accIds.add( acc2.Id );
        
        Contact con1 = new Contact( FirstName='FName', LastName = 'ContTest1', Email = 'test1contact@duptest.com', AccountId = acc1.Id, MailingStreet = 'Test', MailingCity = 'Test', MailingState='Delhi', MailingCountry='India',Phone = '2423122323', AssistantPhone = '2423122323', HomePhone = '2121212121', MobilePhone = '2121212145', OtherPhone = '2154215421' );
        Contact con2 = new Contact( FirstName='FName', LastName = 'ContTest2', Email = 'test2contact@duptest.com', AccountId = acc1.Id, MailingStreet = 'Test', MailingCity = 'Test', MailingState='Delhi', MailingCountry='India',Phone = '2423122323', AssistantPhone = '2423122323', HomePhone = '2121212121', MobilePhone = '2121212145', OtherPhone = '2154215421' );        
        Contact con3 = new Contact( FirstName='FName', LastName = 'ContTest3', Email = 'test3contact@duptest.com', AccountId = acc2.Id, MailingStreet = 'Test', MailingCity = 'Test', MailingState='Delhi', MailingCountry='India',Phone = '2423122323', AssistantPhone = '2423122323', HomePhone = '2121212121', MobilePhone = '2121212145', OtherPhone = '2154215421' ); 
        Contact con4 = new Contact( FirstName='FName', LastName = 'ContTest4', Email = 'test4contact@duptest.com', AccountId = acc2.Id, MailingStreet = 'Test', MailingCity = 'Test', MailingState='Delhi', MailingCountry='India',Phone = '2423122323', AssistantPhone = '2423122323', HomePhone = '2121212121', MobilePhone = '2121212145', OtherPhone = '2154215421'  );
        
        insert con1;
        insert con2;
        insert con3;
        insert con4;
        
        AddressValidationTrncLog__c log = new AddressValidationTrncLog__c( );
        insert log;
        
        Test.startTest( );
          
            //Integer value = new AccountAddressValidationBatch( ).countNumber( 'Hello Test' );
           
            AccountAddressValidationBatch btch = new AccountAddressValidationBatch( accIds, log );
             btch.countNumber( 'Hello Test' );
            Database.executeBatch( btch );
          
        Test.stopTest( );
        
    }
}