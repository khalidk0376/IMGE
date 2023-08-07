/**
 * Created/Modified By: Girikon(Archit)
 * Created On:          10/27/2017
 * Description/Purpose: This test class covers the apex class : SSO_FreemanCtrl
 * Methods:             SSO_FreemanCtrl_Data
 * Apex Class:          SSO_FreemanCtrl
**/

@isTest
public class SSO_FreemanCtrl_Test {
    public static testMethod void SSO_FreemanCtrl_Data()
    {
        // Setup test data
        // This code runs as the system user
        Event_Edition__c OEve;
        Account acc1;
        acc1 = new Account();
        acc1.Name='acc1';             
        insert acc1;
        Contact con = new Contact(LastName='User',FirstName ='Test',AccountId=acc1.id,Email='test1@test.com',Phone='1787263457');
        insert con;
        Profile p = [SELECT Id FROM Profile WHERE Name='Customer Community Login User Custom']; 
        User u = new User(Alias = 'standt', Email='standarduser11@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing11', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, ContactId =con.id,
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1@testorg.com');
            
        OEve = new Event_Edition__c(Name='World of Concrete 2017',Freeman_Show_ID__c=12345,Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today());
        insert OEve;
        System.assertEquals('World of Concrete 2017', OEve.name, 'Here value is not same');
        
        List<IntegrationUrls__c> listIntegrationUrls = New List<IntegrationUrls__c>();
        IntegrationUrls__c oIntegrationURl = new IntegrationUrls__c(Name='URL', Freeman_Url__c='www.freeman.com/store');
        listIntegrationUrls.add(oIntegrationURl);
        insert listIntegrationUrls;
        System.runAs(u) 
        {
            
            ApexPages.currentPage().getParameters().put('freemanshowid',String.valueOf(OEve.Freeman_Show_ID__c));
            Test.startTest();
                SSO_FreemanCtrl sso = new SSO_FreemanCtrl();
                sso.sso_record();
                sso.getSSOData();
            Test.stopTest();            
        }
        
    }
}