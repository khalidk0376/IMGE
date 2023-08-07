/**
 * Application          :   Informa Markets Identity (IM IdP)
 * Created/Modified By   :  Shay.spoonmore@informa.com
 * Created On:           :  20200305
 * @description          : [This test class covers the apex class : esso_ChangePasswordTemplateControllerTest]
 * Modification log --
 * Modified By           :
 **/
//Ticket No. BK-14521 Updating API Version
public without sharing class esso_ChangePasswordTemplateController {

	public User u                 {get; set;}
	public boolean isBrand                  {get; set;}
	public esso_Site_Branding__c brand      {get; set;}
	public ContentVersion emailLogo             {get; private set;}
	public string baseUrl                   {get; private set;}
	public string urlFooterImage           {get; private set;}
	public string urlHeaderImage           {get; private set;}
	
	@TestVisible
	public string buttonColor               {get
						 {
							 if(string.isBlank(buttonColor))
							 { buttonColor = '#33d27e';}
							 return buttonColor;
						 }
										 private set;}
	
	public esso_ChangePasswordTemplateController() {
	
		isBrand=false;
		string userId = UserInfo.getUserId();
		boolean isUserTest = false;
		
		if(userInfo.getUserType() == 'Guest' )// This is for preveiwing/testing the email template in a browser
		{
			if(test.isRunningTest() || (string.isNotBlank(ApexPages.currentPage().getParameters().get('isTest')) && ApexPages.currentPage().getParameters().get('isTest')=='true'))
			{
				isUserTest=true;
				userId = string.isNotBlank(esso_Configuration.setting.Email_Template_Preview_User_Id__c) ? esso_Configuration.setting.Email_Template_Preview_User_Id__c : userId;
	
			}
	
			System.debug('####!DEBUG! esso_ChangePasswordTemplateController: userId' + userId);
		}
	
		u = [SELECT Id,esso_BrandId__c,esso_BrandName__c, username, FirstName,esso_LocalLanguage__c FROM user WHERE Id =: userId ];
	
		baseUrl = '';
		urlHeaderImage = '';
		urlFooterImage = '';
		if(!test.isRunningTest())
		{
			ConnectApi.Community myCommunity = ConnectApi.Communities.getCommunity((Network.getNetworkId() == null ? ([SELECT Id FROM Network WHERE Name ='Informa Markets' ].id) : Network.getNetworkId()));
			baseUrl = myCommunity.siteUrl;
		}
	
		//Get default header/footer images
		List<Document> docs = [SELECT Id, Name From Document where Name IN (:esso_Configuration.setting.Email_Reset_Password_Header_Image__c, :esso_Configuration.setting.Email_Reset_Password_Footer_Image__c)];
		for (Document doc : docs)
		{
			if(doc.Name.toLowerCase() == esso_Configuration.setting.Email_Reset_Password_Header_Image__c.toLowerCase())
			{urlHeaderImage = baseUrl + '/servlet/servlet.ImageServer?id=' + doc.Id + '&oid='+ UserInfo.getOrganizationId();}
			if(doc.Name.toLowerCase() == esso_Configuration.setting.Email_Reset_Password_Footer_Image__c.toLowerCase())
			{urlFooterImage = baseUrl + '/servlet/servlet.ImageServer?id=' + doc.Id + '&oid='+ UserInfo.getOrganizationId();}
		}
	
	
		if(u != null)
		{
			if(String.isBlank(u.esso_BrandId__c)) {u.esso_BrandId__c= 'use_default_brand';}//set default brand if blank
			if(!isUserTest) {SiteBrandingIdentifier.referralId = u.esso_BrandId__c.toLowerCase();}//when current user, user branding is used otherwise default looks for param
			SiteBrandingIdentifier sbi = new SiteBrandingIdentifier();
			//System.debug('####!DEBUG! brand = '+ sbi.branding );
			brand = sbi.branding;
			emailLogo = sbi.emailLogo;
	
			if(!sbi.isDefaultBrand)
			{
				if(brand.Email_Template_Logo__c != null && brand.Email_Template_Button_Link_Hex_Color__c == null)// default button colors
				{ brand.Email_Template_Button_Link_Hex_Color__c = brand.Primary_Colour__c;}
				buttonColor = brand.Email_Template_Button_Link_Hex_Color__c;
				isBrand=true;
			}
	
		}
	
	}
	
	}