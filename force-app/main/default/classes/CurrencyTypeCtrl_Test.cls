/**
 * This test class test 'CurrencyTypeCtrl, CurrencyTypeScheduler' class and 'CurrencyTypeUpdaterTrg' trigger
 * @Author      : Sudip Halder
 * @Date        : 26/Apr/2018
 * Apex Class   : CurrencyTypeCtrl, CurrencyTypeScheduler
 * Apex Trigger : CurrencyTypeUpdaterTrg
 */

@isTest
public class CurrencyTypeCtrl_Test {
    
    /**
     * This method create test user
     */
    public static User createTestUser( Id roleId, Id profID, String fName, String lName ) {
        String orgId      = UserInfo.getOrganizationId( );
        String dateString = String.valueof( Datetime.now( ) ).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf( math.rint( math.random( ) * 1000000 ) );
        String uniqueName = orgId + dateString + randomInt;
        User tuser = new User( firstname         = fName,
                               lastName          = lName,
                               email             = uniqueName + '@test' + orgId + '.org',
                               Username          = uniqueName + '@test' + orgId + '.org',
                               EmailEncodingKey  = 'ISO-8859-1',
                               Alias             = uniqueName.substring(18, 23),
                               TimeZoneSidKey    = 'America/Los_Angeles',
                               LocaleSidKey      = 'en_US',
                               LanguageLocaleKey = 'en_US',
                               ProfileId         = profId,
                               UserRoleId        = roleId );
        return tuser;
    }
    /**
     * Test method
     */
    public static testMethod void testCurrencyTypeCtrl( ) {
        Profile pf       = [ SELECT Id FROM Profile WHERE Name = 'System Administrator' ];
        UserRole usrRole = new UserRole( Name = 'CEO' );
        insert usrRole;
        User usr = createTestUser( usrRole.Id, pf.Id, 'Test Currency', 'Test TypeCtrl' );
        System.runAs( usr ) {
            Test.startTest();
            Integration_Service__c service = new Integration_Service__c( Name = 'DATED_EXCHANGE_RATE', User_name__c = 'testuser', Password__c = 'testPass' );
            insert service;
            CurrencyTypeCtrl.connectSFDCForTest( );
            Currency_Master__c currencyMasterINR  = new Currency_Master__c ( );
            currencyMasterINR.LocalCurrency__c    = 'USD';
            currencyMasterINR.ForeignCurrency__c  = 'INR';
            insert currencyMasterINR;
            Currency_Master__c currencyMasterGBP  = new Currency_Master__c ( );
            currencyMasterGBP.LocalCurrency__c    = 'USD';
            currencyMasterGBP.ForeignCurrency__c  = 'GBP';
            currencyMasterGBP.ExchangeRate__c     = 20;
            insert currencyMasterGBP;
            Datetime dTime = Datetime.now( ).addMinutes( 2 );            
            CurrencyTypeScheduler curType = new CurrencyTypeScheduler(  );
            String cronexp = '0 '+ dTime.minute( ) + ' * ' + dTime.day( ) + ' ' + dTime.month( ) + ' ? ' + dTime.year( );
            CurrencyTypeCtrlMock mock = new CurrencyTypeCtrlMock (201 , 'success', '{"message":"duplicate value found: <unknown> duplicates value on record with id: <unknown>","errorCode":"DUPLICATE_VALUE","fields":[]}', new Map<String,String>());
            Test.setMock( HttpCalloutMock.class, mock);
            System.schedule( 'Test Check', cronexp, curType );
            System.assertEquals('DATED_EXCHANGE_RATE', service.Name,'Test class failed');
            Test.stopTest( );
        }
    }
}