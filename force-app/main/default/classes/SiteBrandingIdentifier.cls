/**
 * Application  :   Informa Markets Identity (IM IdP)
 * Created By   :   Girikon(Mahesh)[Regarding:-(TES-15)]
 * Created On   :   May 01 2019
 * @description :   [Fetching record details from the Site Branding Object for Header and footer of Community.]
 * Test Class   :   SiteBrandingIdentifierTest
 * Modification Log-----
 * Modified by  : Shay.Spoonmore@informa.com (2019-10-31)
 **/
public with sharing class SiteBrandingIdentifier {

public static Boolean isValidReferralId {get; set;}
public static String referralId              {get
                          {
                              System.debug('####!DEBUG! SiteBrandingIdentifier.referralId - isValidReferralId: ' + isValidReferralId);

                              if (SiteBrandingIdentifier.isValidReferralId == null)
                              {
                                  SiteBrandingIdentifier.isValidReferralId=false;

                                  if(String.isBlank(referralId))
                                  {
                                      referralId = SsoApplicationSecurity.normaliseString(ApexPages.currentPage().getParameters().get('referralid'));

                                      if(String.isBlank(referralId)) {

                                          // If no param is found search for cookie set via IdentiyBrandingService
                                          Cookie brandCookie = ApexPages.currentPage().getCookies().get('brand');

                                          if(brandCookie != null) {
                                              // Extract the value from the brand cookie
                                              referralId = SsoApplicationSecurity.normaliseString(brandCookie.getValue());
                                          }
                                      }
                                  }
                                  
                                  
                                  //if (string.isBlank(referralId)) 
                                  //{SiteBrandingIdentifier.isValidReferralId=false;}

                                  System.debug('####!DEBUG! SiteBrandingIdentifier.referralId - ' + referralId + '; SiteBrandingIdentifier.siteBrandings.size():' + SiteBrandingIdentifier.siteBrandings.size());


                              }

                              return referralId;
                          } set;}
//private static Boolean isValidReferralUrl {get; set;}


public static Map<string,Esso_Site_Branding__c> siteBrandings {
    get {

        if(siteBrandings == null || Test.isRunningTest())
        {
            Set<string> referralIds = new Set<string>();
            if(string.isNotEmpty(SiteBrandingIdentifier.referralId)) referralIds.add(SiteBrandingIdentifier.referralId);
            referralIds.add(esso_Configuration.setting.Branding_Default__c.toLowerCase());

            List<Esso_Site_Branding__c> s = [SELECT Footer_Background_Colour__c, Footer_Logo_File_Name__c, Name, Page_Background_Colour__c,
                                             Primary_Colour__c,Language__c,Referral_Id__c, Secondary_Colour__c, Standard_Font_Colour__c, Footer_Font_Colour__c,
                                             Headings_Font_Colour__c, Page_Image__c, Product_Logo_File_Name__c, reCAPTCHA_Theme__c, Footer_Image_Location__c,
                                             Registration_HTML_Markup__c, Product_Name__c, Division__c, Default_Landing_Page__c,Favourite_Icon_Logo_File_Name__c, Branding_Type__c, Registration_Contact_Source__c,Copyright_HTML__c, Customer_Support_Page__c,
                                             Registration_Blacklist_Error_HTML__c, Registration_Greylist_Error_HTML__c,Trial_Registration_Blacklist_Error_HTML__c,Trial_Registration_Greylist_Error_HTML__c, Registration_Button__c,
                                             Customer_Support_Email__c,Customer_Support_Phone_Overide__c,Customer_Support_Phone_EMEA__c,Customer_Support_Phone_AMERICAS__c,Email_Template_Logo__c,Email_Template_Button_Link_Hex_Color__c
                                             FROM Esso_Site_Branding__c WHERE Referral_Id__c =: referralIds ];

            siteBrandings = new Map<string,Esso_Site_Branding__c>();
            for (Esso_Site_Branding__c item: s)
            {
                if(!siteBrandings.containsKey(SsoApplicationSecurity.normaliseString(item.Referral_Id__c.toLowerCase()))) {siteBrandings.put(SsoApplicationSecurity.normaliseString(item.Referral_Id__c),item);}
            }

            if( siteBrandings.size() == 0 || (siteBrandings.size() == 1 && SiteBrandingIdentifier.referralId != SsoApplicationSecurity.normaliseString(esso_Configuration.setting.Branding_Default__c)))
            {
                isValidReferralId=false;
            }
            else {
                isValidReferralId=true;
            }

            System.debug('####!DEBUG! SiteBrandingIdentifier - siteBrandings: ' + siteBrandings.size() + '; SiteBrandingIdentifier.referralId: '+ SiteBrandingIdentifier.referralId + '; isValidReferralId: ' + isValidReferralId);

        }
        return siteBrandings;
    }
    private set;
}


//public String referralId              {get; private set;}
public Boolean isDefaultBrand   {get; private set;}
public String language               {get; private set;}
public String referralUrl               {get; private set;}
public String defaultLandingUrl           {get; private set;}     // Default url where no referral url supplied
public String defaultClientServicesEmail      {get; set;}     // Default url where no referral url supplied
public String defaultCustomerSupportPage      {get; private set;}     // Default url where no referral url supplied
public Esso_Site_Branding__c branding           {get; private set;}
public Esso_Site_Branding__c verticalDefaultBranding   {get; private set;}
public ContentVersion verticalLogo             {get; private set;}
public ContentVersion productLogo             {get; private set;}
public ContentVersion emailLogo             {get; private set;}
public ContentVersion pageImage             {get; private set;}
public ContentVersion favicon               {get; private set;}

public static final Integer brandCookieMaxAge = 86400;     // 1 Day
public static final Integer referralUrlCookieMaxAge = 86400;     // 1 Day

private String testSiteName {get; set;}     // Used to mimic methods of getting site names

public class BrandingIdentifierExtException extends Exception {}

// CONSTRUCTOR
public SiteBrandingIdentifier() {
    // Initialise search for branding
    isDefaultBrand = false;
    initialise();
}

@testVisible private void unitTestInitialise(String testSiteName){
    this.testSiteName = testSiteName;
    // Initialise search for branding
    initialise();
}

private void initialise(){


    // Get the branding
    getSiteBranding();

    // Capture the referral information
    getReferralInfo();

    // store the referral info as cookies so data persists
    setCookies(ApexPages.currentPage(), false);
}

private void getReferralInfo() {

    // Get the referral url to redirect back to
    referralUrl = ApexPages.currentPage().getParameters().get('referralurl');

    if(String.isBlank(referralUrl)) {

        // If no param is found search for cookie set via IdentiyBrandingService
        Cookie referralUrlCookie = ApexPages.currentPage().getCookies().get('rurl');

        if(referralUrlCookie != null) {
            // Extract the value from the brand cookie
            referralUrl = referralUrlCookie.getValue();
        }

    }
    setReferralUrl(referralUrl);
}


private void getSiteBranding(){

    // Instantiate objects to prevent null pointer exceptions
    branding = new Esso_Site_Branding__c();
    verticalLogo = new ContentVersion();
    productLogo = new ContentVersion();
    pageImage = new ContentVersion();
    emailLogo = new ContentVersion();

    if(SiteBrandingIdentifier.siteBrandings.isEmpty())
    {
        System.debug('####!DEBUG! SiteBrandingIdentifier.getSiteBranding(): isEmpty()' + SiteBrandingIdentifier.siteBrandings.isEmpty());
        //throw new BrandingIdentifierExtException('No branding found');
    }
    else
    {
        verticalDefaultBranding = SiteBrandingIdentifier.siteBrandings.get(esso_Configuration.setting.Branding_Default__c.toLowerCase());//default branding

        System.debug('####!DEBUG! SiteBrandingIdentifier.getSiteBranding(): isValidReferralId=' + SiteBrandingIdentifier.isValidReferralId + ';referralId = ' + SiteBrandingIdentifier.referralId + '; ');

        if(SiteBrandingIdentifier.isValidReferralId)// uses branding if exists else default branding
        {
            branding = SiteBrandingIdentifier.siteBrandings.get(SiteBrandingIdentifier.referralId);
            language = branding.Language__c;
        }
        else 
        {

            branding = SiteBrandingIdentifier.siteBrandings.get(esso_Configuration.setting.Branding_Default__c.toLowerCase());
            language = branding.Language__c;
            SiteBrandingIdentifier.referralId=branding.Referral_Id__c;
            
        }
        if(branding.Referral_Id__c == esso_Configuration.setting.Branding_Default__c.toLowerCase()){isDefaultBrand = true;}
        System.debug('####!DEBUG! SiteBrandingIdentifier.getSiteBranding(): ' + branding);

        queryImages(); // get page images
        if(String.isBlank(branding.Footer_Background_Colour__c)) {branding.Footer_Background_Colour__c=verticalDefaultBranding.Footer_Background_Colour__c;}
        if(String.isBlank(branding.Footer_Font_Colour__c)) {branding.Footer_Font_Colour__c=verticalDefaultBranding.Footer_Font_Colour__c;}
        if(String.isBlank(branding.Page_Background_Colour__c)) {branding.Page_Background_Colour__c=verticalDefaultBranding.Page_Background_Colour__c;}
        if(String.isBlank(branding.Footer_Image_Location__c)) {branding.Footer_Image_Location__c=verticalDefaultBranding.Footer_Image_Location__c;}
        if(String.isBlank(branding.Headings_Font_Colour__c)) {branding.Headings_Font_Colour__c=verticalDefaultBranding.Headings_Font_Colour__c;}
        if(String.isBlank(branding.Standard_Font_Colour__c)) {branding.Standard_Font_Colour__c=verticalDefaultBranding.Standard_Font_Colour__c;}
        if(String.isBlank(branding.reCAPTCHA_Theme__c)) {branding.reCAPTCHA_Theme__c=verticalDefaultBranding.reCAPTCHA_Theme__c;}
        if(String.isBlank(branding.Product_Name__c) ) {branding.Product_Name__c=branding.Name;}

        // Set the default branding values - landing url, Contact url
        defaultLandingUrl = (String.isNotBlank(branding.Default_Landing_Page__c)) ? branding.Default_Landing_Page__c : verticalDefaultBranding.Default_Landing_Page__c;
        defaultCustomerSupportPage = (String.isNotBlank(branding.Customer_Support_Page__c)) ? branding.Customer_Support_Page__c : verticalDefaultBranding.Customer_Support_Page__c;


    }

}


private void queryImages()
{
    Set<string> brandingIds = new Set<string>();
    brandingIds.add(branding.Id);
    brandingIds.add(verticalDefaultBranding.Id);
    map<String,contentVersion> mapattach = new map<String,contentVersion>();
    set<Id> setids = new set<Id>();
    List<ContentDocumentLink> lstContentDocumentLink = [SELECT Id, LinkedEntityId, ContentDocumentId, Visibility, ShareType FROM ContentDocumentLink  WHERE LinkedEntityId IN : brandingIds]; 
    Set<Id> sids = new Set<Id>();
    for(ContentDocumentLink objContentDocumentLink : lstContentDocumentLink){
        sids.add(objContentDocumentLink.ContentDocumentId);
    }
    if (!sids.isEmpty()){
        List<ContentVersion> lstcontentversion = [SELECT Id, Title, PathOnClient, VersionData, OwnerId, ContentDocumentId FROM ContentVersion where ContentDocumentId IN : sids ];
        
        for(ContentDocumentLink objContentDocumentLink : lstContentDocumentLink){
            for (ContentVersion ocontentvers : lstcontentversion){
                if(!mapattach.containsKey((objContentDocumentLink.LinkedEntityId + ocontentvers.PathOnClient))) {
                    mapattach.put(objContentDocumentLink.LinkedEntityId + ocontentvers.PathOnClient, ocontentvers);
                }
            }
        }
    }    
    System.debug('####!DEBUG! SiteBrandingIdentifier.queryImages() isVerticalLogo: branding.Footer_Logo_File_Name__c='+ branding.Footer_Logo_File_Name__c + '; ' + mapattach.get(branding.Id + branding.Footer_Logo_File_Name__c) + '; ' + mapattach.get(verticalDefaultBranding.Id + verticalDefaultBranding.Footer_Logo_File_Name__c));
    
    verticalLogo = mapattach.get(branding.Id + branding.Footer_Logo_File_Name__c);
    if(verticalLogo == null) {
        verticalLogo = mapattach.get(verticalDefaultBranding.Id + verticalDefaultBranding.Footer_Logo_File_Name__c);
    }

    favicon =  mapattach.get(branding.Id + branding.Favourite_Icon_Logo_File_Name__c);
    if(favicon == null) {favicon = mapattach.get(verticalDefaultBranding.Id + verticalDefaultBranding.Favourite_Icon_Logo_File_Name__c);}

    productLogo =mapattach.get(branding.Id + branding.Product_Logo_File_Name__c);
    if( productLogo == null) {productLogo = mapattach.get(verticalDefaultBranding.Id + verticalDefaultBranding.Product_Logo_File_Name__c);} //set default

    pageImage = String.isNotBlank(branding.Page_Image__c) ? mapattach.get(branding.Id + branding.Page_Image__c) : null;

    emailLogo = String.isNotBlank(branding.Email_Template_Logo__c) ? mapattach.get(branding.Id + branding.Email_Template_Logo__c) : null;   


}

//Setting the Cookies for Brand and ReturnURL.
public PageReference setCookies(PageReference returnPage, Boolean deleteCookies){
    returnPage = setBrandingCookie(returnPage, deleteCookies);
    returnPage = setReturnURLCookie(returnPage, deleteCookies);
    return returnPage;
}

public PageReference setBrandingCookie(PageReference returnPage, Boolean deleteCookie){

    Integer maxAge = (deleteCookie || !SiteBrandingIdentifier.isValidReferralId) ? 0 : brandCookieMaxAge; // 0 = delete, -1 = session, 3600 = 1 hour

    Cookie brandCookie = new Cookie('brand', SiteBrandingIdentifier.referralId, null, maxAge, true);

    returnPage = (returnPage != null) ? returnPage : ApexPages.currentPage();

    returnPage.setCookies(new List<Cookie> {brandCookie});

    return returnPage;
}

//Setting the Cookies for ReturnURL.
public PageReference setReturnURLCookie(PageReference returnPage, Boolean deleteCookie){

    Integer maxAge = (deleteCookie || String.isBlank(referralurl)) ? 0 : referralUrlCookieMaxAge; // 0 = delete, -1 = session, 3600 = 1 hour

    Cookie referralUrlCookie = new Cookie('rurl', referralurl, null, maxAge, true);

    returnPage = (returnPage != null) ? returnPage : ApexPages.currentPage();

    returnPage.setCookies(new List<Cookie> {referralUrlCookie});

    return returnPage;
}

public void setReferralUrl(String urlvalue){
    this.referralUrl = SsoApplicationSecurity.processReturnUrlString(urlvalue);

    if(String.isBlank(this.referralUrl)){this.referralUrl=defaultLandingUrl;}//use branding url when referralUrl is blank
}
}