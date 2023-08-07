/**
 * Created/Modified By   :  Mahesh (Girikon)
 * Created On:           :  June 12 2019
 * @description          :  [This test class covers the apex class : ReCAPTCHAService]
 * Modification log --
 * Modified By           :
 **/
//Ticket No. BK-14521 Updating API Version
@isTest
private class ReCAPTCHAServiceTest {


@testSetup static void setup()
{
	esso_ConfigurationTest.setupData();

}
@isTest static void test_method_one() {

	// Set the mock response from reCatpcha callout
	// Test.setMock(HttpCalloutMock.class, new TestHttpCalloutMock(200, 'OK','{"success": true,"challenge_ts": "' + Datetime.now().format('yyyy-MM-DD hh:mm:ssZZ').replace(' ', 'T') + '", "hostname": "' + URL.getSalesforceBaseUrl().getHost() +'"}', null));

	ReCAPTCHAService reCAPTCHA = new ReCAPTCHAService();

	// Assert public key is not null
	System.assert (String.isNotBlank(reCAPTCHA.publicKey),'Condition should match');

	// Assert service is not verifed on instansiation
	System.assertEquals(false, reCAPTCHA.reCAPTCHA_Verified,'The value should be return false');

	reCAPTCHA.recaptchaVerify();

	// Assert reCAPTCHA is now verified
	//System.assertEquals(true, reCAPTCHA.reCAPTCHA_Verified);
}

@isTest static void test_method_two() {
	//Set the mock response from reCatpcha callout
	// Test.setMock(HttpCalloutMock.class, new TestHttpCalloutMock(401, 'Bad Request','{"success": false,"challenge_ts": "' + Datetime.now().format('yyyy-MM-DD hh:mm:ssZZ').replace(' ', 'T') + '", "hostname": "' + URL.getSalesforceBaseUrl().getHost() +'"}', null));

	ReCAPTCHAService reCAPTCHA = new ReCAPTCHAService();

	// Assert public key is not null
	System.assert (String.isNotBlank(reCAPTCHA.publicKey),'Condition should match');

	// Assert service is not verifed on instansiation
	System.assertEquals(false, reCAPTCHA.reCAPTCHA_Verified,'The value should be return false');

	reCAPTCHA.recaptchaVerify();

	// Assert reCAPTCHA is not verified
	System.assertEquals(false, reCAPTCHA.reCAPTCHA_Verified,'The value should be return false');
}

@isTest static void test_method_three() {

	// Do not set the mock response to test callout try catch

	ReCAPTCHAService reCAPTCHA = new ReCAPTCHAService();

	// Assert public key is not null
	System.assert (String.isNotBlank(reCAPTCHA.publicKey),'Condition should match');

	// Assert service is not verifed on instansiation
	System.assertEquals(false, reCAPTCHA.reCAPTCHA_Verified,'The value should be return false');

	reCAPTCHA.recaptchaVerify();

	// Assert reCAPTCHA is not verified
	System.assertEquals(false, reCAPTCHA.reCAPTCHA_Verified,'The value should be return false');
}


@isTest static void test_method_four() {

	

	// Set the mock response from reCatpcha callout
	// Test.setMock(HttpCalloutMock.class, new TestHttpCalloutMock(200, 'OK','{"success": true,"challenge_ts": "' + Datetime.now().format('yyyy-MM-DD hh:mm:ssZZ').replace(' ', 'T') + '", "hostname": "' + URL.getSalesforceBaseUrl().getHost() +'"}', null));

	Test.startTest();

	ReCAPTCHAService reCAPTCHA = new ReCAPTCHAService();

	// Assert public key is same as settings
	System.assertEquals(esso_Configuration.setting.reCAPTCHA_Public_Key__c, reCAPTCHA.publicKey,'The value should be match');


	// Assert service is not verifed on instansiation
	System.assertEquals(false, reCAPTCHA.reCAPTCHA_Verified,'The value should be return false');

	reCAPTCHA.recaptchaVerify();

	//Assert reCAPTCHA is now verified
	// System.assertEquals(true, reCAPTCHA.reCAPTCHA_Verified);

	Test.stopTest();
}

@isTest static void test_method_disabled() {



	Test.startTest();

  esso_Configuration.setting.reCAPTCHA_Disable__c=true;
  esso_Configuration.setting = esso_Configuration.setting;

	ReCAPTCHAService reCAPTCHA = new ReCAPTCHAService();

	// Assert public key is same as settings
	System.assertEquals(esso_Configuration.setting.reCAPTCHA_Public_Key__c, reCAPTCHA.publicKey,'The value should be match');


	// Assert service is verifed on instansiation due to disable setting
	System.assertEquals(true, reCAPTCHA.isDisabled,'The value should be return true');

	// Assert service is verifed on instansiation due to disable setting
	System.assertEquals(true, reCAPTCHA.reCAPTCHA_Verified,'The value should be return true');

	reCAPTCHA.recaptchaVerify();

	// Assert reCAPTCHA is now verified
	System.assertEquals(true, reCAPTCHA.reCAPTCHA_Verified,'The value should be return true');

	Test.stopTest();
}
}