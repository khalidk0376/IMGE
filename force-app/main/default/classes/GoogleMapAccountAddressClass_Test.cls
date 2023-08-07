/**
 * Project:         GAP
 * Date:            4/2/2019
 * Test Class For:  GoogleMapAccountAddressClass
 * Code Coverage:   
 * Created By:      Yash Gupta
 * Modified Date:   25th March 2019
 * *************************************************************************
 * @Description:   This test class covers "GoogleMapAccountAddressClass" class.
 * *************************************************************************
 * History: 
 */
 
 @isTest
public class GoogleMapAccountAddressClass_Test {
     @isTest static void googleMapAccountAddressClassMethodOne() {     
        Account acc = new Account();
        acc.Name = 'Testing Account'; 
        acc.CurrencyIsoCode = 'USD';
        insert acc;
        System.assertEquals('Testing Account', acc.name, 'Account cannot be null');

        PageReference pg = Page.Account_Address_Google_Map;
        pg.getParameters().put('id', acc.Id); 
        test.setCurrentPageReference( pg );
        GoogleMapAccountAddressClass gMapClass = new GoogleMapAccountAddressClass();
        gMapClass.sAccountId = acc.Id;
        gMapClass.accountQry();
        gMapClass.autoRedirect();
     }
}