/**
* Author     : Himanshu Rana
* Date       : 16/07/2020
* Class 	 : LicenseUsageCTRL 
* Modified by:   
**/
@isTest
private class LicenseUsageCTRL_Test {
    
    @isTest static void batchExecuteValidOrg() {
        
        Salesforce_Org__c org = new Salesforce_Org__c();
        org.Salesforce_Org_Type__c = 'Sandbox';
        org.Name = 'testorg';
        org.RefreshToken__c='234534535';
        insert org;
        
        Test.startTest();
        LicenseUsageCTRL obj =new LicenseUsageCTRL();
        LicenseUsageCTRL.selectedValue ='testorg';
        Test.setMock(HttpCalloutMock.class, new OauthRedirectMock());
        SelectOption[] SelectOption =  obj.getselectValues();
        PageReference pageref2 =  obj.startBatch();
        
        system.assertEquals(SelectOption.size(),2,'Option list having two values');
        system.assertEquals(pageref2,null,'Page reference is equal to null');
        
        Test.stopTest();
    }
    @isTest static void batchExecuteInValidOrg() {
        
        Salesforce_Org__c org = new Salesforce_Org__c();
        org.Salesforce_Org_Type__c = 'Sandbox';
        org.Name = 'testorg';
        insert org;
        
        Test.startTest();
        LicenseUsageCTRL obj =new LicenseUsageCTRL();
        LicenseUsageCTRL.selectedValue ='None';
        Test.setMock(HttpCalloutMock.class, new OauthRedirectMock());
        SelectOption[] SelectOption =  obj.getselectValues();
        PageReference pageref2 =  obj.startBatch();
        
         system.assertEquals(SelectOption.size(),2,'Option list having two values');
        system.assertEquals(pageref2,null,'Page reference is equal to null');
        
        Test.stopTest();
    }
    
    @isTest static void startbatchForAll() {
        
        Salesforce_Org__c org = new Salesforce_Org__c();
        org.Salesforce_Org_Type__c = 'Sandbox';
        org.Name = 'testorg';
        insert org;
        
        Test.startTest();
        LicenseUsageCTRL obj =new LicenseUsageCTRL();
        SelectOption[] SelectOption =  obj.getselectValues();
        PageReference pageref2 =  obj.startBatchForAll();
        
        system.assertEquals(SelectOption.size(),2,'Option list having two values');
        system.assertEquals(pageref2,null,'Page reference is equal to null');
        Test.stopTest();
    }
    
}