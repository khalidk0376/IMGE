/**
 * Created/Modified By   :  Shay.spoonmore@informa.com
 * Created On:           :  20200305
 * @description          : [This test class covers the apex class : esso_ChangePasswordTemplateController,esso_TestPassEmailTemplateController]
 * Modification log --
 * Modified By           :
 **/
//Ticket No. BK-14521 Updating API Version

@isTest
public class esso_ChangePasswordTemplateCtrTest {



@TestSetup
private static void setupData(){

	
	// Create site branding data
	esso_Site_Branding__c brand =TestUtility.createSiteBranding('informa', 'informa', 'informa', 'Informa Markets', true);

    esso_Site_Branding__c brandEmail = new esso_Site_Branding__c();
    brandEmail.Id=brand.Id;
    brandEmail.Customer_Support_Email__c = 'Test@test.com';
    brandEmail.Email_Template_Logo__c = brand.Product_Logo_File_Name__c;
    brandEmail.Customer_Support_Phone_AMERICAS__c= '333-333-3333';
    brandEmail.Customer_Support_Phone_Overide__c= true;
    update brandEmail;

}


@isTest static void test_method_one() 
{
    esso_ConfigurationTest.setupData();
    User guestSiteUser = [SELECT Id, UserType FROM User WHERE UserType = 'Guest' and name = 'Informa Markets Site Guest User' AND IsActive = true LIMIT 1];
    Profile informaProfile =[select id,name from profile where name=:esso_Configuration.setting.Identity_Profile_Name__c limit 1];

    User communityUser = new User(
		FirstName = 'Test1',
		LastName = 'Test1',
		Email = '1testex5@test.com',
		ProfileId = informaProfile.Id,
		Username = '1testex5@test.com',
		Alias = 'test2',
		CommunityNickname = 'esso_ChangePasswordTemplateController_1',
		TimeZoneSidKey = 'GMT',
		LocaleSidKey = 'en_GB',
		EmailEncodingKey = 'ISO-8859-1',
		LanguageLocaleKey = 'en_US',
		IsActive = TRUE
		);
    insert communityUser;

    
    
    Test.setCurrentPage(Page.esso_TestPassEmailTemplate);

    System.runAs(communityUser) 
    {
        Test.startTest();

        
        esso_ChangePasswordTemplateController eChangePasswordTemplateController = new esso_ChangePasswordTemplateController();
        esso_TestPassEmailTemplateController passEmailController = new esso_TestPassEmailTemplateController();
        PageReference pageRef = Page.esso_TestPassEmailTemplate;
        pageRef.getParameters().put('referralid', String.valueOf('informa'));
        Test.setCurrentPage(pageRef);

        PageReference controller = passEmailController.SendEmail();

        System.assertEquals(true, passEmailController.ResponseInfo.contains(communityUser.Id),'String should contain ' + communityUser.Id);
        System.assertEquals(eChangePasswordTemplateController.u.Id, communityUser.Id,'Both value should be ' + communityUser.Id);

        Test.stopTest(); 
    }







}

@isTest static void test_method_two() 
{
    esso_ConfigurationTest.setupData();
    User guestSiteUser = [SELECT Id, UserType FROM User WHERE UserType = 'Guest' and name = 'Informa Markets Site Guest User' AND IsActive = true LIMIT 1];
    Profile informaProfile =[select id,name from profile where name=: esso_ConfigurationTest.identityProfileName limit 1];

    User communityUser = new User(
		FirstName = 'Test2',
		LastName = 'Test2',
		Email = '2testex5@test.com',
		ProfileId = informaProfile.Id,
		Username = '2testex5@test.com',
		Alias = 'test1',
		CommunityNickname = 'esso_ChangePasswordTemplateController_2',
		TimeZoneSidKey = 'GMT',
		LocaleSidKey = 'en_GB',
		EmailEncodingKey = 'ISO-8859-1',
		LanguageLocaleKey = 'en_US',
		IsActive = TRUE
		);
    insert communityUser;
    System.debug('####!DEBUG! communityUser: ' + communityUser);

    //Add default user to settings
    
    esso_Configuration__c config = new esso_Configuration__c();
    config.Id = esso_ConfigurationTest.config.Id;
    config.Adobe_Analytics_Id__c = communityUser.Id;
    config.Email_Template_Preview_User_Id__c = communityUser.Id;
    update config;
    System.debug('####!DEBUG! config: ' + config);
    System.debug('####!DEBUG! esso_Configuration.setting: ' + esso_Configuration.setting);


    
    Test.setCurrentPage(Page.esso_TestPassEmailTemplate);

    System.runAs(guestSiteUser) 
    {
        Test.startTest();

        
        esso_ChangePasswordTemplateController eChangePasswordTemplateController = new esso_ChangePasswordTemplateController();
        String x = eChangePasswordTemplateController.buttonColor;
        eChangePasswordTemplateController.buttonColor='#33d27e';
        esso_TestPassEmailTemplateController passEmailController = new esso_TestPassEmailTemplateController();
        PageReference pageRef = Page.esso_TestPassEmailTemplate;
        pageRef.getParameters().put('referralid', String.valueOf('informa'));
        pageRef.getParameters().put('isTest', String.valueOf('true'));
        Test.setCurrentPage(pageRef);
        

        PageReference controller = passEmailController.SendEmail();
        System.debug('####!DEBUG! passEmailController.ResponseInfo: ' + passEmailController.ResponseInfo);
        System.assertEquals(true, passEmailController.ResponseInfo.contains(guestSiteUser.Id),'String should contain ' + guestSiteUser.Id);
        System.assertEquals(eChangePasswordTemplateController.u.Id, communityUser.Id,'Both value should be ' + communityUser.Id);

        Test.stopTest(); 
    }

    





}

}