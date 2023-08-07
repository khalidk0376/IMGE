/**
 * Created By   :   Girikon(Mahesh)[Regarding:-(TES-15)]
 * Created On   :   May 03 2019
 * @description :   [For the google reCAPTCHA service.]
 * Test Class   :   ReCAPTCHAServiceTest
 * Modification Log-----
 * Modified by  :
 * Ticket No    : BK-14521 Updating API Version
 **/

public with sharing class ReCAPTCHAService {

/*
   private static reCAPTCHA_Settings__c settings {
       get{
           if(settings == null){

               settings = reCAPTCHA_Settings__c.getOrgDefaults();

               // If no key has been setup in custom settings apply google test keys
               if(settings == null || settings == new reCAPTCHA_Settings__c()){
                   // Apply Google Test Key
                   settings = new reCAPTCHA_Settings__c(
                       Endpoint__c = 'https://www.google.com/recaptcha/api/siteverify',
                       Private_Key__c = '6LeIxAcTAAAAAGG-vFI1TnRWxMZNFuojJ4WifJWe',
                       Public_Key__c = '6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI');
               }
           }
           return settings;
       }
       set;
   }



   // The API endpoint for the reCAPTCHA service
   @TestVisible private static final string baseUrl = settings.Endpoint__c;

   // The keys you get by signing up for reCAPTCHA for your domain
   @TestVisible private static final string privateKey = settings.Private_Key__c;
 */

public String publicKey {get { return esso_Configuration.setting.reCAPTCHA_Public_Key__c;}}
public String endpoint {get { return esso_Configuration.setting.reCAPTCHA_Endpoint__c; }}


//Flag for success
public boolean reCAPTCHA_Verified {get; private set;}

public Boolean isDisabled {get; private set;}

// remote IP address
@TestVisible public String ipAddress {get; private set;}

// CONSTRUCTOR
public ReCAPTCHAService() {
	isDisabled = esso_Configuration.setting.reCAPTCHA_Disable__c;
	reCAPTCHA_Verified = (isDisabled) ? true : false;
	ipAddress = RegistrationHandler.getUserIpAddress();
}

public PageReference recaptchaVerify() {

	if(!isDisabled) {

		String recaptchaResponseToken = ApexPages.currentPage().getParameters().get('g-recaptcha-response');
		HttpResponse response = makeRequest(esso_Configuration.setting.reCAPTCHA_Endpoint__c,
		                                    'secret=' + esso_Configuration.setting.reCAPTCHA_Private_Key__c +
		                                    '&response='  + recaptchaResponseToken +
		                                    '&remoteip='  + ipAddress
		                                    );

		if(response!= null) {

			System.debug('*** -- response.getBody(): ' + response.getBody());

			map<string, object> resultData =(map<string, object>)JSON.deserializeUntyped(response.getBody());

			reCAPTCHA_Verified = boolean.valueOf(resultData.get('success'));
			/* if(reCAPTCHA_Verified == false){
			     System.debug('*** -- reCAPTCHA_Verification was false -- ***');
			   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.reCAPTCHA_Verification_Fail_Message));
			   } */
		}
	}

	return null;
}

private static HttpResponse makeRequest(string url, string body)  {

	HttpRequest req = new HttpRequest();
	req.setEndpoint(url);
	req.setMethod('POST');
	req.setBody (body);

	HttpResponse response;
	try {
		Http http = new Http();
		response = http.send(req);
		system.debug('*** response: ' + response);
		system.debug('*** body: ' + response.getBody());
	}
	catch(system.Exception e) {
		System.debug('*** -- reCAPTCHA_callout failed: ' +  e.getMessage() + ' at line number ' + e.getLineNumber());
		ExceptionHandler.capture(ReCAPTCHAService.class, e, 'ReCAPTCHA CALLOUT', null, new Map<String, Object> {'HttpRequestEndpoint' => url, 'HttpRequestBody' => body });
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.reCAPTCHA_Verification_Fail_Message));
	}

	return response;
}
}