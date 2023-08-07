/**
 * Application          :   Informa Markets Identity (IM IdP)
 * Created/Modified By   :  Mahesh (Girikon)
 * Created On:           :  June 11 2019
 * @description          :  [This test class covers the apex class : SsoApplicationSecurity]
 * Modification log --
 * Modified By           :  Shay.Spoonmore@informa.com (20200901)
 **/
@isTest
private class SsoApplicationSecurityTest {

@testSetup
private static void setupData(){

    esso_Whitelist_Return_URLs__c we = new esso_Whitelist_Return_URLs__c(Active__c=true,Name='id.informamarkets.com',Notes__c = 'id.informamarkets.com',URL__c = 'https://id.informamarkets.com');
    insert we;
    we = new esso_Whitelist_Return_URLs__c(Active__c=true,Name='sfdc.unittest.informa.com',Notes__c = 'sfdc.unittest.informa.com',URL__c = 'https://sfdc.unittest.informa.com');
    insert we;

    esso_ConfigurationTest.setupData();
    esso_UserTest.setupData();
    SiteBrandingIdentifierTest.defaultSiteBranding();

    esso_Site_Branding__c customBrand = SiteBrandingIdentifierTest.createSiteBranding('SecurityBrand', BRAND_REFERRAL_ID, 'SecurityBrand', 'Markets', true);
    customBrand.Default_Landing_Page__c = BRAND_DEFAULT_LANDING_PAGE;
    customBrand.Customer_Support_Page__c = BRAND_CUSTOMER_SUPPORT_PAGE;
    update customBrand;

}



private static final String COMMUNITY_TEST_URL = 'https://id.informamarkets.com';

private static final String BRAND_CUSTOMER_SUPPORT_PAGE = 'https://sfdc.unittest.informa.com/support';
private static final String BRAND_DEFAULT_LANDING_PAGE = 'https://sfdc.unittest.informa.com/start';
private static final String BRAND_EMAIL_VERIFICATION_PAGE = 'https://sfdc.unittest.informa.com/emailverification';
private static final String BRAND_REFERRAL_ID = 'SecurityBrand';

private static final String GOOD_RELATIVE_URL = '/SFDC__RELATIVE_PATH';
private static final String BAD_RELATIVE_URL = '//www.bad-url.com';
private static final String BAD_RETURN_URL = 'https://www.bad-url.com?test=1';
private static final String BAD_REFERRAL_ID = 'UNKNOWN';

private static final String BAD_XSS_VALUE = '<img onerror="alert(\'XSS\')"/>';


static testMethod void UnitTest_CustomerCheck()
{
    Test.StartTest();
    SsoApplicationSecurity.customerCheckBrandingUrlLookUp = BRAND_DEFAULT_LANDING_PAGE;
    //CreateWhiteListing();

    PageReference apexPage = Page.CustomerCheck;
    Test.setCurrentPage(apexPage);

    ApexPages.currentPage().getHeaders().put('Referer',BRAND_DEFAULT_LANDING_PAGE);

    esso_CustomerCheckController cc = new esso_CustomerCheckController();
    cc.CheckCustomer();


    System.debug('####!DEBUG! '+ ApexPages.currentPage().getHeaders().get('IdP'));
    system.assert ((ApexPages.currentPage().getHeaders().get('IdP')=='true'),'Should be return true');


    Test.StopTest();


}



@isTest static void test_processReturnUrl_enabled(){

    SsoApplicationSecurity.isValidReturnUrl('/signin');//cover error on relitive url
    // Enable security checks
    XssSecurityHelperTest.setupSettings(true);
    
    PageReference returnPage_1 = SsoApplicationSecurity.processReturnUrl(BAD_RETURN_URL);
    // URL not on whitelist, null is returned
    System.assertEquals(null, returnPage_1,'The first and second parameter value should be match');

    // PageReference returnPage_2 = SsoApplicationSecurity.processReturnUrl(GOOD_RELATIVE_URL);
    // relative urls are supported
    // System.assertEquals(GOOD_RELATIVE_URL, returnPage_2.getUrl(),'The first and second parameter value should be match');

    PageReference returnPage_3 = SsoApplicationSecurity.processReturnUrl(BRAND_CUSTOMER_SUPPORT_PAGE);
    // Site Branding Customer_Support_Page__c urls are whitelisted
    System.assertEquals(BRAND_CUSTOMER_SUPPORT_PAGE, returnPage_3.getUrl(),'The first and second parameter value should be match');

    PageReference returnPage_4 = SsoApplicationSecurity.processReturnUrl(BRAND_DEFAULT_LANDING_PAGE);
    // Site Branding Default_Landing_Page__c urls are whitelisted
    System.assertEquals(BRAND_DEFAULT_LANDING_PAGE, returnPage_4.getUrl(),'The first and second parameter value should be match');

    /*PageReference returnPage_5 = SsoApplicationSecurity.processReturnUrl(BRAND_EMAIL_VERIFICATION_PAGE);
       // Site Branding Email_Verification_Return_URL__c urls are whitelisted
       System.assertEquals(BRAND_EMAIL_VERIFICATION_PAGE, returnPage_5.getUrl()); */

    List<esso_Whitelist_Return_URLs__c> whiteList = SsoApplicationSecurity.getWhiteListUrls();
    if(whiteList != null && !whiteList.isEmpty()) {
        PageReference returnPage_6 = SsoApplicationSecurity.processReturnUrl(whiteList[0].URL__c);
        // Custom metadata urls are whitelisted
        System.assertEquals(whiteList[0].URL__c, returnPage_6.getUrl(),'The first and second parameter value should be match');
    }

    PageReference returnPage_Community = SsoApplicationSecurity.processReturnUrl(COMMUNITY_TEST_URL);
    // relative urls are supported
    System.assertEquals(COMMUNITY_TEST_URL, returnPage_Community.getUrl(),'Should match');
}

@isTest static void test_processReturnUrl_disabled(){

    // Disable security checks
    XssSecurityHelperTest.setupSettings(false);

    PageReference returnPage = SsoApplicationSecurity.processReturnUrl(BAD_RETURN_URL);

    // Settings are disabled so input url is returned
    System.assertNotEquals(null, returnPage,'The first and second parameter value should be not match');
    System.assertEquals(BAD_RETURN_URL, returnPage.getUrl(),'The first and second parameter value should be match');
}

/*
   @isTest static void test_processReturnUrl_No_Settings(){

   // No settings setup use defaults (disabled)

   PageReference returnPage = SsoApplicationSecurity.processReturnUrl(BAD_RETURN_URL);

   // Settings are disabled so input url is returned
   System.assertNotEquals(null, returnPage,'The first and second parameter value should be not match');
   System.assertEquals(BAD_RETURN_URL, returnPage.getUrl(),'The first and second parameter value should be match');
   }
 */
@isTest static void test_processReturnPageReference_enabled(){

    // Enable security checks
    XssSecurityHelperTest.setupSettings(true);

    PageReference returnPage = new PageReference(BAD_RETURN_URL);

    returnPage = SsoApplicationSecurity.processReturnPageReference(returnPage);

    // URL not on whitelist, null is returned
    System.assertEquals(null, returnPage,'The first and second parameter value should be match');
}

@isTest static void test_processReturnPageReference_disabled(){

    // Disable security checks
    XssSecurityHelperTest.setupSettings(false);

    PageReference returnPage = new PageReference(BAD_RETURN_URL);

    returnPage = SsoApplicationSecurity.processReturnPageReference(returnPage);

    // Settings are disabled so input url is returned
    System.assertNotEquals(null, returnPage,'The first and second parameter value should not match');
    System.assertEquals(BAD_RETURN_URL, returnPage.getUrl(),'The first and second parameter value should be match');
}

@isTest static void test_processReturnUrlString_enabled(){

    // Enable security checks
    XssSecurityHelperTest.setupSettings(true);

    String returnURL = SsoApplicationSecurity.processReturnUrlString(BAD_RETURN_URL);

    // URL not on whitelist, null is returned
    System.assertEquals(null, returnURL,'The first and second parameter value should be match');
}

@isTest static void test_processReturnUrlString_disabled(){

    // Disable security checks
    XssSecurityHelperTest.setupSettings(false);

    String returnURL = SsoApplicationSecurity.processReturnUrlString(BAD_RETURN_URL);

    // Settings are disabled so input url is returned
    System.assertEquals(BAD_RETURN_URL, returnURL,'The first and second parameter value should be match');
}

@isTest static void test_isValidReturnUrl_enabled(){

    // Enable security checks
    XssSecurityHelperTest.setupSettings(true);

    Boolean isValid = SsoApplicationSecurity.isValidReturnUrl(BAD_RETURN_URL);

    // URL not on whitelist, false is returned
    System.assertEquals(false, isValid,'The first and second parameter value should be match');
}

@isTest static void test_isValidReturnUrl_disabled(){

    // Disable security checks
    XssSecurityHelperTest.setupSettings(false);

    Boolean isValid = SsoApplicationSecurity.isValidReturnUrl(BAD_RETURN_URL);

    // Settings are disabled so true url is returned
    System.assertEquals(true, isValid,'The first and second parameter value should be match');
}

@isTest static void test_isRelativeUrl_enabled(){

    // Enable security checks
    XssSecurityHelperTest.setupSettings(true);

    Boolean isValid_1 = SsoApplicationSecurity.isRelativeUrl(GOOD_RELATIVE_URL);
    // relative urls are supported
    System.assertEquals(true, isValid_1,'The first and second parameter value should be match');

    Boolean isValid_2 = SsoApplicationSecurity.isRelativeUrl(BAD_RELATIVE_URL);
    // relative urls are supported however // approach is rejected as can be used in an open redirect attack
    System.assertEquals(false, isValid_2,'The first and second parameter value should be match');
}

@isTest static void test_isRelativeUrl_disabled(){

    // Disable security checks
    XssSecurityHelperTest.setupSettings(false);

    Boolean isValid_1 = SsoApplicationSecurity.isRelativeUrl(GOOD_RELATIVE_URL);
    // relative urls are supported
    System.assertEquals(true, isValid_1,'The first and second parameter value should be match');

    Boolean isValid_2 = SsoApplicationSecurity.isRelativeUrl(BAD_RELATIVE_URL);
    // Settings do not apply to relative URL checks. Relative urls are supported however // approach is rejected as can be used in an open redirect attack
    System.assertEquals(false, isValid_2,'The first and second parameter value should be match');
}

@isTest static void test_verifyPageParameters_enabled(){

    // Enable security checks
    XssSecurityHelperTest.setupSettings(true);

    Test.setCurrentPage(Page.signin);

    ApexPages.currentPage().getParameters().put('returl', BRAND_DEFAULT_LANDING_PAGE + '?param1=123¶m2=456');
    ApexPages.currentPage().getParameters().put('startURL', BRAND_DEFAULT_LANDING_PAGE);
    ApexPages.currentPage().getParameters().put('referralId', BAD_REFERRAL_ID);
    ApexPages.currentPage().getParameters().put('referralUrl', BAD_RETURN_URL);
    ApexPages.currentPage().getParameters().put('data', BAD_XSS_VALUE);

    Map<string,Esso_Site_Branding__c> siteBrandings = SiteBrandingIdentifier.siteBrandings;//load site data

    SsoApplicationSecurity.verifyPageParameters();

    // BRAND_DEFAULT_LANDING_PAGE exists on a site branding record & params are ignored in whitelist check, so is whitelisted and value retained
    // System.assertEquals(BRAND_DEFAULT_LANDING_PAGE + '?param1=123¶m2=456', ApexPages.currentPage().getParameters().get('returl'));
    // BRAND_DEFAULT_LANDING_PAGE exists on a site branding record so is whitelisted and value retained
    System.assertEquals(BRAND_DEFAULT_LANDING_PAGE, ApexPages.currentPage().getParameters().get('startURL'),'The first and second parameter value should be match');
    // BAD_REFERRAL_ID does not exist on a site branding record so is removed from page parameters via method
    System.assertEquals(null, ApexPages.currentPage().getParameters().get('referralId'),'The first and second parameter value should be match');
    // BAD_RETURN_URL does not exist on a site branding record so is removed from page parameters via method
    System.assertEquals(null, ApexPages.currentPage().getParameters().get('referralUrl'),'The first and second parameter value should be match');
    // BAD_XSS_VALUE contains an Xss vulnerability so is removed from page parameters via method
    //System.assertEquals(null, ApexPages.currentPage().getParameters().get('data'),'The first and second parameter value should be match');
}

@isTest static void test_verifyPageParameters_disabled(){

    // Disable security checks
    XssSecurityHelperTest.setupSettings(false);

    Test.setCurrentPage(Page.signin);

    ApexPages.currentPage().getParameters().put('returl', BRAND_DEFAULT_LANDING_PAGE + '?param1=123¶m2=456');
    ApexPages.currentPage().getParameters().put('startURL', BRAND_DEFAULT_LANDING_PAGE);
    ApexPages.currentPage().getParameters().put('referralId', BAD_REFERRAL_ID);
    ApexPages.currentPage().getParameters().put('referralUrl', BAD_RETURN_URL);
    ApexPages.currentPage().getParameters().put('data', BAD_XSS_VALUE);


    SsoApplicationSecurity.verifyPageParameters();

    // BRAND_DEFAULT_LANDING_PAGE exists on a site branding record & params are ignored in whitelist check, so is whitelisted and value retained
    System.assertEquals(BRAND_DEFAULT_LANDING_PAGE + '?param1=123¶m2=456', ApexPages.currentPage().getParameters().get('returl'),'The first and second parameter value should be match');
    // BRAND_DEFAULT_LANDING_PAGE exists on a site branding record so is whitelisted however settings are disabled so value is retained anyway
    System.assertEquals(BRAND_DEFAULT_LANDING_PAGE, ApexPages.currentPage().getParameters().get('startURL'),'The first and second parameter value should be match');
    // BAD_REFERRAL_ID does not exist on a site branding record however settings are disabled so value is retained
    System.assertEquals(BAD_REFERRAL_ID, ApexPages.currentPage().getParameters().get('referralId'),'The first and second parameter value should be match');
    // BAD_RETURN_URL does not exist on a site branding record however settings are disabled so value is retained
    System.assertEquals(BAD_RETURN_URL, ApexPages.currentPage().getParameters().get('referralUrl'),'The first and second parameter value should be match');
    // BAD_XSS_VALUE contains an Xss vulnerability however settings are disabled so value is retained
    System.assertEquals(BAD_XSS_VALUE, ApexPages.currentPage().getParameters().get('data'),'The first and second parameter value should be match');
}

@isTest static void test_processReferralId_enabled(){

    // Enable security checks
    XssSecurityHelperTest.setupSettings(true);
    Map<string,Esso_Site_Branding__c> siteBrandings = SiteBrandingIdentifier.siteBrandings;//load site data

    String returnId_1 = SiteBrandingIdentifier.referralId = BAD_REFERRAL_ID;
    // BAD_REFERRAL_ID does not exist on a site branding record so is removed from response
    System.assertEquals(false, SiteBrandingIdentifier.isValidReferralId,'The first and second parameter value should be match');

    String returnId_2 = SiteBrandingIdentifier.referralId =BRAND_REFERRAL_ID;
    // BRAND_REFERRAL_ID exists on a site branding record so is returned as valid
    // BRAND_REFERRAL_ID exists on a site branding record so is returned as valid
    System.assertEquals(BRAND_REFERRAL_ID, returnId_2,'The first and second parameter value should be match');
}

@isTest static void test_processReferralId_disabled(){

    // Disable security checks
    XssSecurityHelperTest.setupSettings(false);

    String returnId_1 = SiteBrandingIdentifier.referralId = BRAND_REFERRAL_ID;
    // BRAND_REFERRAL_ID exist on a site branding record however settings disabled, value is returned
    System.assertEquals(BRAND_REFERRAL_ID, returnId_1,'The first and second parameter value should be match');

    String returnId_2 = SiteBrandingIdentifier.referralId = BAD_REFERRAL_ID;
    // BAD_REFERRAL_ID does not exist on a site branding record however settings disabled, value is returned
    System.assertEquals(BAD_REFERRAL_ID, returnId_2,'The first and second parameter value should be match');
}

@isTest static void test_isValidReferralId_enabled(){

    // Enable security checks
    XssSecurityHelperTest.setupSettings(true);

    SiteBrandingIdentifier.referralId = BAD_REFERRAL_ID;
    Map<string,Esso_Site_Branding__c> siteBrandings = SiteBrandingIdentifier.siteBrandings;//load site data

    Boolean isValid = SiteBrandingIdentifier.isValidReferralId;/// = BAD_REFERRAL_ID;
    System.assertEquals(false, isValid,'The first and second parameter value should be match');
}

@isTest static void test_isValidReferralId_disabled(){

    // Disable security checks
    XssSecurityHelperTest.setupSettings(false);
    SiteBrandingIdentifier.referralId = BAD_REFERRAL_ID;
    Map<string,Esso_Site_Branding__c> siteBrandings = SiteBrandingIdentifier.siteBrandings; //load site data

    Boolean isValid = SiteBrandingIdentifier.isValidReferralId;//(BAD_REFERRAL_ID);
    // BRAND_REFERRAL_ID exist on a site branding record however settings disabled, true for valid returned
    System.assertEquals(false, isValid,'The first and second parameter value should be match');
}

@isTest static void test_encode(){

    String output_1 = SsoApplicationSecurity.encode('<TEST>');
    System.assertEquals('%3CTEST%3E', output_1,'The first and second parameter value should be match');

    String output_2 = SsoApplicationSecurity.encode('TEST');
    System.assertEquals('TEST', output_2,'The first and second parameter value should be match');
}

@isTest static void test_decode(){

    String output_1 = SsoApplicationSecurity.decode('%3CTEST%3E');
    System.assertEquals('<TEST>', output_1,'The first and second parameter value should be match');

    String output_2 = SsoApplicationSecurity.decode('TEST');
    System.assertEquals('TEST', output_2,'The first and second parameter value should be match');
}
}