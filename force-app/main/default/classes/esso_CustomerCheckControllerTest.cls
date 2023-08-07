/**************************************************************************
** Application      :   Informa Markets Identity (IM IdP)
** Last Modified    :   shay.spoonmore@informa.com 2020-09-01
** @description     :   [Checks user is logged in]
***************************************************************************/
@isTest
public class esso_CustomerCheckControllerTest {

@testSetup static void setup()
{
	esso_ConfigurationTest.setupData();
	esso_UserTest.setupData();
	SiteBrandingIdentifierTest.defaultSiteBranding();
	
}

static testMethod void UnitTest_CustomerCheck()
{
	Test.StartTest();

	CreateWhiteListing();

	PageReference apexPage = Page.CustomerCheck;
	Test.setCurrentPage(apexPage);

	ApexPages.currentPage().getHeaders().put('Referer','https://CustomerCheck');


	esso_CustomerCheckController cc = new esso_CustomerCheckController();
	cc.CheckCustomer();


	System.debug('####!DEBUG! '+ ApexPages.currentPage().getHeaders().get('IdP'));
	system.assert ((ApexPages.currentPage().getHeaders().get('IdP')=='true'),'Should be return true');


	Test.StopTest();


}

static testMethod void UnitTest_CustomerCheckGuest()
{
	Test.StartTest();

	user u = [SELECT Id, name, UserType FROM User where usertype= 'Guest' limit 1];
	system.runAs(u)
	{

		CreateWhiteListing();

		PageReference apexPage = Page.CustomerCheck;
		Test.setCurrentPage(apexPage);

		ApexPages.currentPage().getHeaders().put('Referer','https://CustomerCheck');


		esso_CustomerCheckController cc = new esso_CustomerCheckController();
		cc.CheckCustomer();


		System.debug('####!DEBUG! '+ ApexPages.currentPage().getHeaders().get('IdP'));
		system.assert ((ApexPages.currentPage().getHeaders().get('IdP')=='false'),'Should be return false');

	}
	Test.StopTest();


}

private static void CreateWhiteListing()
{
	

	esso_Whitelist_Return_URLs__c we = new esso_Whitelist_Return_URLs__c(Active__c=true,Name='CustomerCheck',Notes__c = 'CustomerCheck',URL__c = 'https://CustomerCheck');
	insert we;
}

//private static user CreateUser()
//{
//    profile p = [SELECT Id,Name FROM Profile WHERE Name = 'External Identity User' limit 1];
//    user u = new user(FirstName = 'CustomerCheck', LastName= 'CustomerCheck', email='CustomerCheck@test.com', username='CustomerCheck@test.com', country='usa', profileId =p.id);
//    insert u;
//    return u;
//}

}