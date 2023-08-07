/**
 * Application  :   Informa Markets Identity (IM IdP)
 * Created By   :   Girikon(Mahesh)[Regarding:-(TES-15)]
 * Created On   :   June 11 2019
 * @description :   [Class to provide methods to enforce security for IDE reducing vulnerabilities.]
 * Test Class   :   SsoApplicationSecurityTest
 * Modification Log-----
 * Modified by  :   Shay.spoonmore@informa.com 20200618
 **/
public with sharing class SsoApplicationSecurity {

public class SsoApplicationSecurityException extends Exception {}



/*
   SAS 20190911 getting information from esso_configuration
   private static esso_Application_Security_Settings__c securitySettings{
   get{
     if(securitySettings == null){
       securitySettings = esso_Application_Security_Settings__c.getInstance();

       // Null or empty object e.g. setting not setup
       if(securitySettings == null || securitySettings == new esso_Application_Security_Settings__c(SetupOwnerId = UserInfo.getUserId())){
         // Instantiate a new object in memory with defaults
         securitySettings = new esso_Application_Security_Settings__c();
       }
     }
     return securitySettings;
   }
   set;
   } */

/*
   private static List<Esso_Site_Branding__c> siteBrandings {
        get {
                if(siteBrandings == null) {
                        siteBrandings = [SELECT Id, Customer_Support_Page__c,Default_Landing_Page__c, Referral_Id__c FROM Esso_Site_Branding__c];
                }
                return siteBrandings;
        }
        set;
   }
 */

/*
   private static Set<String> referralIdCache {
        get {
                // Create a cache of the referralIds
                if(referralIdCache == null) {
                        referralIdCache = new Set<String>();
                        // Get all existing and valid referral Id's from the Esso_Site_Branding__c object
                        for(Esso_Site_Branding__c branding : siteBrandings) {
                                if(String.isNotBlank(branding.Referral_Id__c)) {
                                        // Add normalised version of the Referral Id to SET as unique case sensitive value
                                        referralIdCache.add(normaliseString(branding.Referral_Id__c));
                                }
                        }
                }
                return referralIdCache;
        }
        set;
   }
 */
public static string customerCheckBrandingUrlLookUp { get; set; }
private static Set<String> returnUrlWhitelistCache {
    get {
        if(returnURLWhitelistCache == null)
        {

            returnURLWhitelistCache = new Set<String>();

            System.debug('####!DEBUG! Host: ' + URL.getSalesforceBaseUrl().getHost() + '; ExternalForm: ' +  URL.getSalesforceBaseUrl().toExternalForm() + '; ' + Network.getLogoutUrl(Network.getNetworkId()) + '; Site.getBaseSecureUrl()=' + Site.getBaseSecureUrl());

            // Get Salesorce base URL
            String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
            if(String.isNotBlank(sfdcBaseURL)) {
                //System.debug('*** -- SSOApplicationSecurity about to clean and add sfdcBaseURL ' + sfdcBaseURL + ' to returnURLWhitelistCache -- ***');
                returnURLWhitelistCache.add(getCleanURL(sfdcBaseURL));
            }

            // Get sites endpoint
            String communityURL = String.isNotBlank(Site.getBaseCustomUrl()) ? Site.getBaseCustomUrl() : Site.getBaseSecureUrl();
            //communityURL = (Test.isRunningTest()) ? 'https://id.informamarkets.com' : communityURL; // Set value for test class as unit test do not run in context of sites
            if(String.isNotBlank(communityURL)) {
                //System.debug('*** -- SSOApplicationSecurity about to clean and add communityURL ' + communityURL + ' to returnURLWhitelistCache -- ***');
                returnURLWhitelistCache.add(getCleanURL(communityURL));
            }

            if(Test.isRunningTest())//Add test host
            {
                returnURLWhitelistCache.add(getCleanURL('https://id.informamarkets.com'));
                URL cleanURL = new URL(getCleanURL(Network.getLoginUrl(CommunityBaseController.getCurrentNetworkId())));
                String cleanReturnHost = cleanURL.getProtocol() + '://' + cleanURL.getHost();
                returnURLWhitelistCache.add(cleanReturnHost);
            }

            // Get the whitelist urls from custom metadata
            List<esso_Whitelist_Return_URLs__c> whitelistMetaData = getWhiteListUrls();

            for(esso_Whitelist_Return_URLs__c whitelist : whitelistMetaData)
            {
                String cleanURL = getCleanURL(whitelist.URL__c);

                if(String.isNotBlank(cleanURL))
                {
                    returnURLWhitelistCache.add(cleanURL);
                }
            }

            //CustomerCheck Url - lookup brand by landing/support url and add to whitelist
            if (String.isNotBlank(customerCheckBrandingUrlLookUp))
            {
                customerCheckBrandingUrlLookUp = getCleanURL(customerCheckBrandingUrlLookUp);
                for(Esso_Site_Branding__c branding : [SELECT Default_Landing_Page__c, Customer_Support_Page__c FROM Esso_Site_Branding__c WHERE Default_Landing_Page__c LIKE : ( customerCheckBrandingUrlLookUp + '%') or Customer_Support_Page__c LIKE : ( customerCheckBrandingUrlLookUp + '%')])
                {
                    string landing = getCleanURL(branding.Default_Landing_Page__c);
                    string support = getCleanURL(branding.Customer_Support_Page__c);

                    if (String.isNotBlank(landing)) returnURLWhitelistCache.add(landing);
                    if (String.isNotBlank(support)) returnURLWhitelistCache.add(support);
                }

            }
            // Add site branding URL's
            for(string branding : SiteBrandingIdentifier.siteBrandings.keySet())
            {

                string landing = getCleanURL(SiteBrandingIdentifier.siteBrandings.get(branding).Default_Landing_Page__c);
                string support = getCleanURL(SiteBrandingIdentifier.siteBrandings.get(branding).Customer_Support_Page__c);

                if (String.isNotBlank(landing)) returnURLWhitelistCache.add(landing);
                if (String.isNotBlank(support)) returnURLWhitelistCache.add(support);


            }


            /*
                              // Now add site branding URL's
                              if(siteBrandings != null && !siteBrandings.isEmpty()) {
                                      for(Esso_Site_Branding__c branding : siteBrandings) {

                                              // Normalise the Default_Landing_Page__c
                                              String cleanDefaultLandingURL = getCleanURL(branding.Default_Landing_Page__c);
                                              // Check if its present within the whitelist cache
                                              if(String.isNotBlank(cleanDefaultLandingURL)) {
                                                      returnURLWhitelistCache.add(cleanDefaultLandingURL);
                                              }

                                              // Normalise the Email_Verification_Return_URL__c
                                              // String cleanEmailVerificationURL = getCleanURL(branding.Email_Verification_Return_URL__c);
                                              // Check if its present within the whitelist cache
                                              //  if(String.isNotBlank(cleanEmailVerificationURL)){
                                              //    returnURLWhitelistCache.add(cleanEmailVerificationURL);
                                              //  }

                                              // Normalise the Customer_Support_Page__c
                                              String cleanCustomerSupportURL = getCleanURL(branding.Customer_Support_Page__c);
                                              // Check if its present within the whitelist cache
                                              if(String.isNotBlank(cleanCustomerSupportURL)) {
                                                      returnURLWhitelistCache.add(cleanCustomerSupportURL);
                                              }
                                      }
                              }
             */
        }
        return returnURLWhitelistCache;
    }
    set;
}

/**
 * // 2019-09-03 moved to use custom settings
   private static Set<String> returnURLWhitelistCache {
    get{
      if(returnURLWhitelistCache == null)
      {
        // Instantiate new set and add current salesforce endpoint to the whitelist
        returnURLWhitelistCache = new Set<String>();

        // Get Salesorce base URL
        String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
                if(String.isNotBlank(sfdcBaseURL)){
          //System.debug('*** -- SSOApplicationSecurity about to clean and add sfdcBaseURL ' + sfdcBaseURL + ' to returnURLWhitelistCache -- ***');
                returnURLWhitelistCache.add(getCleanURL(sfdcBaseURL));
                }

        // Get sites endpoint
        String communityURL = String.isNotBlank(Site.getBaseCustomUrl()) ? Site.getBaseCustomUrl() : Site.getBaseSecureUrl();
        communityURL = (Test.isRunningTest()) ? 'https://admin.id.informa.com' : communityURL; // Set value for test class as unit test do not run in context of sites
        if(String.isNotBlank(communityURL)){
          //System.debug('*** -- SSOApplicationSecurity about to clean and add communityURL ' + communityURL + ' to returnURLWhitelistCache -- ***');
          returnURLWhitelistCache.add(getCleanURL(communityURL));
        }

        // Get the whitelist urls from custom metadata
        List<esso_Whitelist_Return_URL__mdt> whitelistMetaData = getWhiteListUrls();

        //List<esso_Custom_Whitelist_Return_URL__c> whitelistMetaData = getWhiteListUrls();
        if(whitelistMetaData != null && !whitelistMetaData.isEmpty()){
          for(esso_Whitelist_Return_URL__mdt whitelist : whitelistMetaData){
           //for(esso_Custom_Whitelist_Return_URL__c whitelist : whitelistMetaData){
            // Normalise the return URL
            String cleanURL = getCleanURL(whitelist.URL__c);
            // Check if its present within the whitelist cache
            if(String.isNotBlank(cleanURL)){
              returnURLWhitelistCache.add(cleanURL);
            }
          }
        }

        // Now add site branding URL's
        if(siteBrandings != null && !siteBrandings.isEmpty()){
          for(Esso_Site_Branding__c branding : siteBrandings){

            // Normalise the Default_Landing_Page__c
            String cleanDefaultLandingURL = getCleanURL(branding.Default_Landing_Page__c);
            // Check if its present within the whitelist cache
            if(String.isNotBlank(cleanDefaultLandingURL)){
              returnURLWhitelistCache.add(cleanDefaultLandingURL);
            }

            // Normalise the Email_Verification_Return_URL__c
           // String cleanEmailVerificationURL = getCleanURL(branding.Email_Verification_Return_URL__c);
           // Check if its present within the whitelist cache
           //  if(String.isNotBlank(cleanEmailVerificationURL)){
          //    returnURLWhitelistCache.add(cleanEmailVerificationURL);
          //  }

            // Normalise the Customer_Support_Page__c
            String cleanCustomerSupportURL = getCleanURL(branding.Customer_Support_Page__c);
            // Check if its present within the whitelist cache
            if(String.isNotBlank(cleanCustomerSupportURL)){
              returnURLWhitelistCache.add(cleanCustomerSupportURL);
            }
          }
        }
      }
      return returnURLWhitelistCache;
    }
    set;
   }
 **/

@testVisible
private static List<esso_Whitelist_Return_URLs__c> getWhiteListUrls()
{

    return [SELECT URL__c FROM esso_Whitelist_Return_URLs__c WHERE Active__c = true AND URL__c != NULL];

}

// 2019-09-03 moved to use custom settings
//private static List<esso_Whitelist_Return_URL__mdt> getWhiteListUrls()
//{
//private static List<esso_Custom_Whitelist_Return_URL__c> getWhiteListUrls(){
// Check if instance is a sandbox to get the appropriate whitelisted URL's
//Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
//String environment =  (isSandbox) ? 'Sandbox' : 'Production';
//Boolean environment =  isSandbox?true:false;
// Get all active whitelise urls based on the current environment
//return [SELECT URL__c FROM esso_Whitelist_Return_URL__mdt WHERE Active__c = true AND Whitelist_Environment__c = :environment AND URL__c != NULL];
//return [SELECT URL__c FROM esso_Custom_Whitelist_Return_URL__c WHERE Active__c = true AND Whitelist_Environment__c = :environment AND URL__c != NULL];
//}

public static PageReference processReturnUrl(String returnUrl){
    PageReference returnPage;

    if(String.isNotBlank(returnUrl) && isValidReturnUrl(returnUrl)) {
        returnPage = new PageReference(returnUrl);
    }
    return returnPage;
}

public static PageReference processReturnPageReference(PageReference returnPage){
    PageReference theReturnPage;

    if(returnPage != null && isValidReturnUrl(returnPage.getUrl())) {
        theReturnPage = returnPage;
    }
    return theReturnPage;
}

public static String processReturnUrlString(String returnUrl){
    PageReference returnPage = processReturnUrl(returnUrl);
    return (returnPage != null) ? returnPage.getUrl() : null;
}

public static boolean isValidReturnUrl(string returnUrl){

    Boolean isValid = true;

    if(String.isNotBlank(returnUrl) && esso_Configuration.setting.Enable_Return_URL_Whitelist_Check__c) {
        // Normalise the inbound return URL and validate if its valid based on the values stored in the whitelisting cache
        String cleanReturnURL = getCleanURL(returnUrl);

        // Get just the host to validate against base salesforce or base community
        String cleanReturnHost = '';
        try{
            URL cleanURL = new URL(cleanReturnURL);
            cleanReturnHost = cleanURL.getProtocol() + '://' + cleanURL.getHost();
        }catch(Exception ex) {
            // cleanReturnHost will return an exception if its a relative URL
            System.debug('####!DEBUG! Checking relative Urls cause an exception useing Salesforce method URL(' + cleanReturnURL + '). Ignore Message: ' + ex.getMessage());
        }

        System.debug('####!DEBUG! -- cleanReturnHost: ' + cleanReturnHost + '; cleanReturnURL: ' + cleanReturnURL + '; returnURLWhitelistCache: ' + returnURLWhitelistCache);


        //System.debug('*** -- returnURLWhitelistCache.contains(cleanReturnURL): ' + returnURLWhitelistCache.contains(cleanReturnURL));
        //System.debug('*** -- returnURLWhitelistCache.contains(cleanReturnHost): ' + returnURLWhitelistCache.contains(cleanReturnHost));
        //System.debug('*** -- cleanReturnURL.startsWithIgnoreCase(\'/\') : ' + cleanReturnURL.startsWithIgnoreCase('/') );

        boolean isReturnUrl = false;
        for(string r: returnURLWhitelistCache)
        {

            if (r == cleanReturnURL || r == cleanReturnHost || (r.contains('*') && cleanReturnHost.endsWith(r.replace('*',''))))
            {
                System.debug('####!DEBUG! -- UrlWhitelistCache: ' + r + '; true');
                isReturnUrl = true;
                break;
            }
        }


        // Set the isValid boolean if the cleaned version of the return url if its not withing the whitelist and is not a relative URL
        if(!isReturnUrl && !isRelativeUrl(cleanReturnURL)) {
            isValid = false;
        }

        System.debug('####!DEBUG! -- SSOApplicationSecurity.isValidReturnUrl(): ' + isValid);
    }



    return isValid;
}



/**
 * 2019-09-03 changed
   public static boolean isValidReturnUrl(String returnUrl){

   Boolean isValid = true;

   if(String.isNotBlank(returnUrl) && securitySettings.Enable_Return_URL_Whitelist_Check__c){
     // Normalise the inbound return URL and validate if its valid based on the values stored in the whitelisting cache
     String cleanReturnURL = getCleanURL(returnUrl);

     // Get just the host to validate against base salesforce or base community
     String cleanReturnHost = '';
     try{
       URL cleanURL = new URL(cleanReturnURL);
       cleanReturnHost = cleanURL.getProtocol() + '://' + cleanURL.getHost();
     }catch(Exception ex){
       // cleanReturnHost will return an exception if its a relative URL
     }

     System.debug('*** -- cleanReturnHost: ' + cleanReturnHost);
     System.debug('*** -- cleanReturnURL: ' + cleanReturnURL);

     //System.debug('*** -- returnURLWhitelistCache.contains(cleanReturnURL): ' + returnURLWhitelistCache.contains(cleanReturnURL));
     //System.debug('*** -- returnURLWhitelistCache.contains(cleanReturnHost): ' + returnURLWhitelistCache.contains(cleanReturnHost));
     //System.debug('*** -- cleanReturnURL.startsWithIgnoreCase(\'/\') : ' + cleanReturnURL.startsWithIgnoreCase('/') );

     // Set the isValid boolean if the cleaned version of the return url if its not withing the whitelist and is not a relative URL
     if(!returnURLWhitelistCache.contains(cleanReturnURL) && !returnURLWhitelistCache.contains(cleanReturnHost) && !isRelativeUrl(cleanReturnURL)){
       isValid = false;
     }
     System.debug('*** -- returnURLWhitelistCache: ' + returnURLWhitelistCache);
     System.debug('*** -- SSOApplicationSecurity.isValidReturnUrl() is: ' + isValid);
   }
   return isValid;
   }
 **/


public static Boolean isRelativeUrl(String returnUrl){
    // heck for relative url /path and // attack e.g. //www.google.com
    return (String.isNotBlank(returnUrl) && returnUrl.startsWithIgnoreCase('/') && !returnUrl.startsWithIgnoreCase('//'));
}

public static void verifyPageParameters(){

    if(ApexPages.currentPage() != null && esso_Configuration.setting.Enable_Xss_Parameter_Detection__c) {

        if(ApexPages.currentPage().getParameters() != null && !ApexPages.currentPage().getParameters().isEmpty()) {

            // Sets are case sensitive add values as lower case
            Set<String> urlParams = new Set<String> {'starturl', 'returl', 'referralurl'};

            for(String key : ApexPages.currentPage().getParameters().keySet()) {

                String value = ApexPages.currentPage().getParameters().get(key).escapeHtml4();
                String lowerCaseKey = key.toLowerCase();

                if(XssSecurityHelper.isXssVulnerable(value)) {
                    System.debug('*** -- XSS vulnerable param removed: ' + key + '=' + value);
                    ApexPages.currentPage().getParameters().remove(key);
                }else if(urlParams.contains(lowerCaseKey) && !SsoApplicationSecurity.isValidReturnUrl(value)) {
                    System.debug('*** -- Invalid return url removed: ' + key + '=' + value);
                    ApexPages.currentPage().getParameters().remove(key);
                }else if(urlParams.contains(lowerCaseKey) && SsoApplicationSecurity.isValidReturnUrl(value)) {
                    System.debug('*** -- Valid return url add back to page params incase of cleansing: ' + key + '=' + value);
                    ApexPages.currentPage().getParameters().put(key, SsoApplicationSecurity.processReturnUrlString(value));
                }else if(lowerCaseKey.equalsIgnoreCase('referralId') && !SiteBrandingIdentifier.isValidReferralId) {
                    System.debug('*** -- Invalid referral id removed: ' + key + '=' + value);
                    ApexPages.currentPage().getParameters().remove(key);
                }
            }
        }
    }
}

/*
   public static String processReferralId(String referralId){
        // Set the referral Id to null if its not valid
        return isValidReferralId(referralId) ? referralId : null;
   }

   public static Boolean isValidReferralId(String referralId){
        Boolean isValid = true;
        if(String.isNotBlank(referralId) && esso_Configuration.setting.Enable_Xss_Parameter_Detection__c) {
                // Normalise the inbound referral Id and validate if its valid based on the values stored in the branding record
                isValid = referralIdCache.contains(normaliseString(referralId));
        }
        return isValid;
   }
 */

public static String encode(String param){
    if(String.isNotBlank(param)) {
        param = EncodingUtil.urlEncode(param, 'UTF-8');
    }
    return param;
}

public static String decode(String param){
    if(String.isNotBlank(param)) {
        param = EncodingUtil.urlDecode(param, 'UTF-8');
    }
    return param;
}

private static String getCleanURL(String urlStr){
    String cleanURL;
    String lastDomain;
    if(String.isNotBlank(urlStr)) {
        // Rebuild the URL removing parameters if provided
        String urlStrNoParams = urlStr.substringBefore('?');
        lastDomain = urlStrNoParams;
        //System.debug('*** -- SSOApplicationSecurity.getCleanURL(urlStr) urlStrNoParams: ' + urlStrNoParams);
        // Normalise the string
        cleanURL = normaliseString(lastDomain);
    }
    return cleanURL;
}

//private static String lastDomainName(String str){
//    if(String.isNotBlank(str)){
//    str= (str.substringbeforelast('.').substringafterlast('.'))+'.'+str.substringafterlast('.');
//  }
//  return str;
//}

public static String normaliseString(String str){
    if(String.isNotBlank(str)) {
        str = str.escapeHtml4().toLowerCase().normalizeSpace().deleteWhitespace();
    }
    return str;
}
}