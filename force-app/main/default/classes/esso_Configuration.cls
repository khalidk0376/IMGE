/**
 * Application  :   Informa Markets Identity (IM IdP)
 * Created By   :   shay
 * Created On   :   20190918
 * @description :   [IM IdP Configuration]
 * Test Class   :   esso_ConfigurationTest
 * Modification Log-----
 * Modified by  : Shay
 **/
public without sharing class esso_Configuration
{
public static final String DEFAULT_PROVIDER = 'Informa Markets Identity';


public static Organization org {
  get {
    if (org == null)
    {
      org = [SELECT Id,InstanceName,IsReadOnly,IsSandbox,Name FROM Organization LIMIT 1];
      System.debug('####!DEBUG! Cached Org: ' + org);
    }

    return org;
  }
  private set;
}

@TestVisible
public static esso_Configuration__c setting {
  get {
    if (setting == null)
    {

      //IM Idp Website Config/Setup
      setting = [SELECT Adobe_Analytics_Id__c,Branding_Default__c,Enable_Return_URL_Whitelist_Check__c,Enable_Xss_Input_Detection__c,Enable_Xss_Parameter_Detection__c,Id,Identity_Profile_Name__c
            ,Name,reCAPTCHA_Disable__c,reCAPTCHA_Endpoint__c,reCAPTCHA_Private_Key__c,reCAPTCHA_Public_Key__c,Email_Template_Preview_User_Id__c,Email_Reset_Password_Header_Image__c,Email_Reset_Password_Footer_Image__c   FROM esso_Configuration__c LIMIT 1];
      System.debug('####!DEBUG! Cached Settings: ' + setting);

      //Social Network Config/Setup
      list<SocialNetwork> sn = esso_Configuration.socialNetworks;


    }

    return setting;
  }
  private set;
}


public static esso_Configuration.SocialNetwork informaEmployeeIdentity {
  get {

    //Employee Login Config
    if (informaEmployeeIdentity == null )
    {
      list<esso_Configuration.SocialNetwork> sn = esso_Configuration.socialNetworks;
    }

    return informaEmployeeIdentity;
  }
  private set;
}

public static Boolean isInformaEmployeeIdentity {
  get{return (isInformaEmployeeIdentity==null?false:isInformaEmployeeIdentity);}private set;
}

public static Boolean isSocialNetwork {
  get{return (isSocialNetwork==null?false:isSocialNetwork);} private set;
}

public static list<esso_Configuration.SocialNetwork>  socialNetworks {
  get {

    if (socialNetworks == null )
    {
      //Get Social Networks and Employee login
      socialNetworks = new list<esso_Configuration.SocialNetwork>();
      list<esso_Configuration_Social_Networks__c> confSocial = new list<esso_Configuration_Social_Networks__c> ();
      confSocial = [SELECT Auth_Provider_Name__c,Auth_Provider_URL_Suffix__c,Display_0rder__c,Enabled__c,Id,Image_Static_Resource_URL__c,Name,Is_Employee_Login__c
                    FROM esso_Configuration_Social_Networks__c WHERE Enabled__c = true ORDER BY Display_0rder__c ASC, Name ASC];

      for (esso_Configuration_Social_Networks__c si : confSocial  )
      //for (esso_Configuration_Social_Networks__c si : esso_Configuration.socialNetworks) // custom settings is list doesnt work as a property
      {
        if (si.Is_Employee_Login__c == false)
        {
          esso_Configuration.SocialNetwork sn = new esso_Configuration.SocialNetwork();
          sn.Name=si.Name;
          sn.Image_Static_Resource_URL=si.Image_Static_Resource_URL__c;
          sn.Auth_Provider_URL_Suffix=si.Auth_Provider_URL_Suffix__c;
          socialNetworks.add(sn);
          esso_Configuration.isSocialNetwork = true;
        }
        else
        {
          esso_Configuration.SocialNetwork sn = new esso_Configuration.SocialNetwork();
          sn.Name=si.Name;
          sn.Image_Static_Resource_URL=si.Image_Static_Resource_URL__c;
          sn.Auth_Provider_URL_Suffix=si.Auth_Provider_URL_Suffix__c;
          esso_Configuration.informaEmployeeIdentity = sn;
          esso_Configuration.isInformaEmployeeIdentity = true;
        }
      }

      System.debug('####!DEBUG! Cached esso_Configuration_Social_Networks__c: ' + socialNetworks);
    }

    return socialNetworks;
  }
  private set;
}


// public static AuthProvider getAuthProvider(string devName)
// {
//   return [SELECT AppleTeam,AuthorizeUrl,ConsumerKey,ConsumerSecret,CreatedDate,CustomMetadataTypeRecord,DefaultScopes,DeveloperName,EcKey,ErrorUrl,ExecutionUserId,FriendlyName,IconUrl,Id,IdTokenIssuer,LinkKickoffUrl,LogoutUrl,OauthKickoffUrl,OptionsIncludeOrgIdInId,OptionsSendAccessTokenInHeader,OptionsSendClientCredentialsInHeader,OptionsSendSecretInApis,PluginId,ProviderType,RegistrationHandlerId,SsoKickoffUrl,TokenUrl,UserInfoUrl
//           FROM AuthProvider WHERE DeveloperName =: devName LIMIT 1];

// }

public class SocialNetwork
{
public string Name {get; set;}
public string Image_Static_Resource_URL {get; set;}
public string Auth_Provider_URL_Suffix {get; set;}
}

}