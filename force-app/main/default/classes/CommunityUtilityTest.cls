/**
 * Created/Modified By   :  Mahesh (Girikon)
 * Created On:           :  June 12 2019
 * @description          :  [This is test Utility class creating sitebranding object and getting the label message]
 * Modification log --
 * Modified By           :
**/
@isTest
public class CommunityUtilityTest {

@isTest static void getLabelMessage_test(){
    Folder f = [SELECT Id FROM Folder where Type='Document' ][0];
    Document d = new Document();
    d = new Document(
      FolderId=f.Id,Body=Blob.valueOf('test'),ContentType='image/png',DeveloperName='essoEmailImageTest',IsInternalUseOnly=false,IsPublic=true,Name='essoEmailImageTest',Type='png');
    insert d;
    
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

    esso_Site_Branding__c siteBranding = TestUtility.createSiteBranding('Informa', 'informa', 'informa', 'BI', true);

    SiteBrandingIdentifier brandIdentifier = new SiteBrandingIdentifier();

   //String label1 = CommunityUtility.getLabelMessage(brandIdentifier, 'Contact {Client_Services_Contact_Email__c}');
   //System.assertEquals('Contact ' + siteBranding.Client_Services_Contact_Email__c, label1);

    String label2 = CommunityUtility.getLabelMessage(brandIdentifier, 'Contact {Customer_Support_Page__c}');
    System.assertEquals('Contact ' + siteBranding.Customer_Support_Page__c, label2,'That should be return true');
    
    String label3 = CommunityUtility.getLabelMessage(brandIdentifier, 'null');
    System.assertEquals(null, label3,'That should be return true');
  }
}