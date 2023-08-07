/**
* Author     : Himanshu Rana
* Date       : 16/07/2020
* Class 	 : OauthRedirectCtrl 
* Modified by:   
**/

@isTest
public class OauthRedirectCtrl_Test {
    public static testmethod void OauthRedirectCtrl() {
        Salesforce_Org__c so = new Salesforce_Org__c(Name='KN Devgirikon',Salesforce_Org_Type__c='Sandbox',Target_Oid__c='test123', domain__c='https://informakn--DevGirikon.cs88.my.salesforce.com', Email__c='avinash.c.singh@informa.com');    
        insert so; 
        
        AuthTempData__c setting = AuthTempData__c.getOrgDefaults();
        setting.SalesforceOrg_RecordId__c = so.id;
        upsert setting;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OauthRedirectMock());
        OauthRedirectionCtrl.jsonWrapper res =new OauthRedirectionCtrl.jsonWrapper();
        OauthRedirectionCtrl obj= new OauthRedirectionCtrl();
        res = obj.ReturnAccessToken(so,'refdfdgfbvcngthrgrfsddsdsdsa');
        obj.RedirectBack();
        system.assertEquals(res.access_token,'SESSION_ID_REMOVED','Access token has some value');
        system.assertEquals(res.refresh_token,'5Aep861ulCxXNoWflrgVsdFgVFNWLohNiJ5nRiizzJP5Gexj5GUTAV3JUFUg6DkFOD6AIl5NVu.qGsdqp6vSytM','refresh tokenhas some value');
        system.assertEquals(res.instance_url,'https://informage--devbau.my.salesforce.com','Instance url has value');
        Test.stopTest();
        
    }
    public static testmethod void OauthRedirectCtrlNegative() {
        Salesforce_Org__c so = new Salesforce_Org__c(Name='KN Devgirikon',Salesforce_Org_Type__c='Sandbox',ClientKey__c='test',Target_Oid__c='123456', ClientSecret__c='test', domain__c='https://informakn--DevGirikon.cs88.my.salesforce.com', Email__c='avinash.c.singh@informa.com', PasswordE__c='Test@12345', User_Name__c='lma@informa.com.kn.devgirikon');    
        insert so; 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OAuthMockHttpResponseGenerator());
        OauthRedirectionCtrl.jsonWrapper res =new OauthRedirectionCtrl.jsonWrapper();
        
        system.assertEquals(res.access_token,null,'Access token null');
        system.assertEquals(res.refresh_token,null,'Refresh Token null');
        system.assertEquals(res.instance_url,null,'Instance Url is null');
        Test.stopTest();
        
    }
}