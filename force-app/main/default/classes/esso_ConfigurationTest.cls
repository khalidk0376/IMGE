/**
 * Application  :   Informa Markets Identity (IM IdP)
 * Created By   :   shay
 * Created On   :   20190918
 * @description :   [IM IdP Configuration]
 * Test Class   :   esso_ConfigurationTest
 * Modification Log-----
 * Modified by  :   Shay.Spoonmore@informa.com (20200901)
 **/
@isTest
public class esso_ConfigurationTest {

public static Boolean isTest= false;  
public static String identityProfileName= 'Informa Markets Identity';
public static esso_Configuration__c config {get;set;}
public static list<esso_Configuration_Social_Networks__c> configSocialNetwork {get{

  
  
  if (configSocialNetwork == null ||  configSocialNetwork.size() == 0)
  {
    list<esso_Configuration_Social_Networks__c> confSocial = new list<esso_Configuration_Social_Networks__c> ();
    confSocial = [SELECT Auth_Provider_Name__c,Auth_Provider_URL_Suffix__c,Display_0rder__c,Enabled__c,Id,Image_Static_Resource_URL__c,Name,Is_Employee_Login__c, Auth_Provider_Id__c
              FROM esso_Configuration_Social_Networks__c WHERE Enabled__c = true ORDER BY Display_0rder__c ASC, Name ASC];
    configSocialNetwork = confSocial;
  }

  return configSocialNetwork;
}
set;}

public static void setupData()
{

  Document d = new Document();
  if([SELECT count() FROM Document WHERE NAME= 'essoEmailImageTest']==0)
  {
    Folder f = [SELECT Id FROM Folder where Type='Document' ][0];
    
    d = new Document(
      FolderId=f.Id,Body=Blob.valueOf('test'),ContentType='image/png',DeveloperName='essoEmailImageTest',IsInternalUseOnly=false,IsPublic=true,Name='essoEmailImageTest',Type='png');
    insert d;

  }else {
    d = [SELECT Id,Name FROM Document WHERE NAME= 'essoEmailImageTest'];
  }


  Integer c = [select count() from esso_Configuration__c];
  if(c == 0)
  {
    

    esso_Configuration__c config = new esso_Configuration__c();

    config.Adobe_Analytics_Id__c = 'xyz';
    config.Branding_Default__c = 'informa';
    config.Enable_Return_URL_Whitelist_Check__c =true;
    config.Enable_Xss_Input_Detection__c=true;
    config.Enable_Xss_Parameter_Detection__c=true;
    config.Identity_Profile_Name__c = esso_ConfigurationTest.identityProfileName;
    config.Name = 'config';
    config.reCAPTCHA_Disable__c =false;
    config.reCAPTCHA_Endpoint__c = 'https://www.google.com/recaptcha/api/siteverify';
    config.reCAPTCHA_Private_Key__c  = '6LeIxAcTAAAAAGG-vFI1TnRWxMZNFuojJ4WifJWe';
    config.reCAPTCHA_Public_Key__c = '6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI';
    config.Email_Reset_Password_Header_Image__c= d.Name;
    config.Email_Reset_Password_Footer_Image__c= d.Name;
    insert config;

    esso_ConfigurationTest.config =  config;
  }

  
  //create Social/employee configuration
  if (esso_ConfigurationTest.configSocialNetwork.size() == 0) 
  {
    esso_Configuration_Social_Networks__c sn = new esso_Configuration_Social_Networks__c();
    list<esso_Configuration_Social_Networks__c> confSocial = new list<esso_Configuration_Social_Networks__c> ();
    sn = new esso_Configuration_Social_Networks__c(Auth_Provider_Id__c='IM_IdP_Informa', Auth_Provider_Name__c ='IM_IdP_Informa' ,Auth_Provider_URL_Suffix__c='IM_IdP_Informa',Display_0rder__c = 0,
                            Enabled__c = true,Image_Static_Resource_URL__c ='/',Name = 'Informa',Is_Employee_Login__c = true);
    confSocial.add(sn);
    sn = new esso_Configuration_Social_Networks__c(Auth_Provider_Id__c='IM_IdP_LinkedIn', Auth_Provider_Name__c ='IM_IdP_LinkedIn' ,Auth_Provider_URL_Suffix__c='IM_IdP_LinkedIn',Display_0rder__c = 0,
                            Enabled__c = true,Image_Static_Resource_URL__c ='linkedin/Retina/Sign-In-Small---Default.png',Name = 'LinkedIn',Is_Employee_Login__c = false);
    confSocial.add(sn);
    sn = new esso_Configuration_Social_Networks__c(Auth_Provider_Id__c='IM_IdP_LinkedIn2', Auth_Provider_Name__c ='IM_IdP_LinkedIn' ,Auth_Provider_URL_Suffix__c='IM_IdP_LinkedIn',Display_0rder__c = 1,
                            Enabled__c = true,Image_Static_Resource_URL__c ='linkedin/Retina/Sign-In-Small---Default.png',Name = 'LinkedIn2',Is_Employee_Login__c = false);
    confSocial.add(sn);

    insert confSocial;
  }            

}



@testSetup static void setup()
{
  esso_ConfigurationTest.setupData();
}

static testmethod void testSetting() {

  System.assertEquals(true, (esso_Configuration.setting !=null),'The value should be return true');
    System.assertEquals(true, (esso_Configuration.org !=null),'The value should be return true');
}

static testmethod void testSocialNetwork() {

  esso_Configuration essoConfig = new esso_Configuration();

  System.assertEquals(true, (esso_Configuration.informaEmployeeIdentity.Name  == 'Informa'),'The value should be return true');
  System.assertEquals(true, (esso_Configuration.socialNetworks.size() > 0),'The value should be return true');
  System.assertEquals(true, (esso_Configuration.isSocialNetwork),'The value should be return true');
  System.assertEquals(true, (esso_Configuration.isInformaEmployeeIdentity),'The value should be return true');
    
}



}