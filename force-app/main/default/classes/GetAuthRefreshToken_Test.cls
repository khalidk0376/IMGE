/*LicenseUsageCTRL
*
* Author     : Himanshu Rana
* Date       : 16/07/2020
* Class 	 : GetAuthRefreshToken 
* Modified by:   
**/

@isTest
public class GetAuthRefreshToken_Test {
    public static testMethod void ReturnAuthToken()
    {
        Salesforce_Org__c org = new Salesforce_Org__c();
        org.Salesforce_Org_Type__c = 'Sandbox';
        org.Name = 'testorg';
        insert org;
        
        test.startTest();
        Salesforce_Org__c org2 = [select Salesforce_Org_Type__c,Name from Salesforce_Org__c where Name='testorg'];
        ApexPages.StandardController sc = new ApexPages.StandardController(org2);
        GetAuthRefreshToken Obj = new GetAuthRefreshToken(sc);
        Test.setMock(HttpCalloutMock.class, new OAuthMockHttpResponseGenerator());
        PageReference AuthToken =  obj.ReturnAuthToken();
        system.assertEquals(AuthToken.getUrl().contains('https://test.salesforce.com/setup/secur/RemoteAccessAuthorizationPage.apexp'), true, 'Here value is not same');
        test.stopTest();

    }
}