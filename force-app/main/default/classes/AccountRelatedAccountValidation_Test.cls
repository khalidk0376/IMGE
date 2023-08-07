/**
 * File:        AccountRelatedAccountValidation_Test
 * Date:        16/Jul/2018
 * Created By : Sudip Halder
 * Apex Class : AccountRelatedAccountValidation
 * *************************************************************************
 * Description: This test class test the AccountRelatedAccountValidation
 * *************************************************************************
 *  History: Modfied By Rajesh Kumar - BK-3755 on 29 - 04- 2020
 */
 
@isTest
public class AccountRelatedAccountValidation_Test {

    @testSetup
    public static void createSetup( ) {
        
        Account acc = new Account( );
        acc.name              = 'TestAccount';
        acc.BillingStreet     = '456 Zepplin Avenue';
        acc.BillingCity       = 'Las Vegas';
        acc.BillingState      = 'Delhi';
        acc.BillingPostalCode = '110025';
        acc.BillingCountry    = 'India';
        acc.Phone             = '1234567890';
        acc.Fax               = '1234567890';
        insert acc;
        
        Contact con = new Contact( );
        con.Email             = 'test.test@gmail.com';
        con.Phone             = '1234567890';
        con.Title             = 'Mr.';
        con.FirstName         = 'TestFN';
        con.LastName          = 'testLN';
        con.AccountId         = acc.Id;
        con.MailingStreet     = 'TestStreet';
        con.MailingCity       = 'Las Vegas';
        con.MailingPostalCode = '89131';
        con.MailingState      = 'Delhi';
        con.MailingCountry    = 'India';
        con.Fax               = '1234567890';
        insert con;
        
        Integration_Settings__c setting = new Integration_Settings__c( );
        setting.Name        = 'VALIDATE_CUSTOMER'; 
        setting.Endpoint__c = 'https://test.test.com/validation';
        setting.Username__c = 'testuser'; 
        setting.Password__c = 'testPass';
        insert setting;
       
    }
    public static TestMethod void testAccntValidation( ) {    
        Test.startTest( );
            Account oaccount  = new account(name = 'Test');
            System.assertEquals('Test', oaccount.Name,'Test class failed');
            Contact con = [ SELECT id FROM Contact LIMIT 1 ];
            PageReference pg = Page.ValidateBlngContactAccntBlngAdd;
            Test.setCurrentPage( pg );
            pg.getParameters( ).put( 'contactId', con.Id );
            AccountRelatedAccountValidationCtrl ctrl = new AccountRelatedAccountValidationCtrl( );
            AccountRelatedAccountValidationMock mock = new AccountRelatedAccountValidationMock(200, 'OK', '{"Header":{"Systems":{"SystemReference":"0011F000009bKCwQAM","MessageStatusText":"","MessageStatus":"","MessageDate":"2018-07-17","CallingApplication":"SFDC-GE"},"DataPacket":[]},"Content":{"AddressWrapper":{"Person":{"LastName":"testLN","FirstNames":"TestFN"},"Customer":{"CustomerNumberType":"web","CustomerNumber":"","CustomerGroup":"","CustomerEmail":"test.test@gmail.com"},"Address":{"State":"Delhi","PostalCode":"110025","PhoneNumber":"1234567890","PhoneExtension":"","Organisation":"","FaxNumber":"1234567890","Department":"","Country":"IN","City":"Las Vegas","AddressLine2":"","AddressLine1":"456 Zepplin Avenue"}}}}', new Map<String,String>());
            Test.setMock(HttpCalloutMock.class, mock);
            ctrl.validateAccountBillingAddress( );
            ctrl.back2Contact( );
            ctrl.batchProcess( );
        Test.stopTest();
        
    }
}