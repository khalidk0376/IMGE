/**
 * @Author      : Sudip Halder
 * @Date        : 19/Jun/2018
 * Apex Class   : AddressValidationTrncDetailsCtrl
 * * Modified By : Rajesh kumar Yadav Bk-3751
 */
@IsTest
public class AddressValidationTrncDetailsCtrl_Test {
	
    public static TestMethod void testAddressValidationTrncDetailsCtrl( ){
        
		List <AddressValidationTrncLog__c> validationLogs = new List <AddressValidationTrncLog__c> ( );
        for( integer i = 0; i< 10; i++ ) {
            AddressValidationTrncLog__c log = new AddressValidationTrncLog__c();
            log.Valid_Account_Address_ID__c   = 'TestValidatedIds';
            log.Invalid_Account_Address_ID__c = 'TestInvalidatedIds';
            log.Valid_Account_Tax_ID__c       = 'TestvalidAccount';
            log.Invalid_Account_Tax_ID__c     = 'TestvalidAccount';
            log.Valid_Contact_Address_ID__c   = '';
            log.Invalid_Contact_Address_ID__c = '';
            validationLogs.add( log );
        }        
        insert validationLogs;
        system.assertEquals(validationLogs[0].Valid_Account_Address_ID__c, 'TestValidatedIds', 'Both values should be the same.');
        Test.startTest( );
        	AddressValidationTrncDetailsCtrl logObj = new AddressValidationTrncDetailsCtrl( );
        	logObj.totaTrncLogs( );
        	logObj.getAddressValidationTrncLog( );
        	logObj.FirstPage( );
        	logObj.previous( );
        	logObj.next( );
            logObj.LastPage( );
        	logObj.getprev( );
            logObj.getnxt( );         
        Test.stopTest( );
        
    }
 }