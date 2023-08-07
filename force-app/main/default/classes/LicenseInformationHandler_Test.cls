/**
* Author     : Avinash Singh
* Company    : Informa
* Date       : 2017-03-15
* Class      : LicenseInformationHandler 
* Modified by:   
**/

@isTest
public class LicenseInformationHandler_Test
{
    
    public static testmethod void licenseInformationHandler() 
    {
        
        Salesforce_Org__c so = new Salesforce_Org__c(Name='KN Devgirikon',Is_OAuth_Authorize__c=true,Salesforce_Org_Type__c='Sandbox',Target_Oid__c='test123', domain__c='https://informakn--DevGirikon.cs88.my.salesforce.com');    
        insert so; 
        system.assertEquals('KN Devgirikon',so.Name,false);
        Test.setMock(HttpCalloutMock.class, new OauthRedirectMock());
        LicenseInformationHandler.deserializeResponse deserial = new LicenseInformationHandler.deserializeResponse();
        Test.StartTest();
        
        LicenseInformationBatchController bc =  new LicenseInformationBatchController('Select Name,Salesforce_Org_Type__c,RefreshToken__c,ClientKey__c,Target_Oid__c, ClientSecret__c,Package_Name__c, domain__c,Is_OAuth_Authorize__c, Email__c, Org__c,PasswordE__c,User_Name__c from Salesforce_Org__c ');
        Id batchJobId = Database.executeBatch(bc, 1);
        
        // Check batch status after execution 
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems
                          from AsyncApexJob where Id = :batchJobId];
        
        system.assertEquals('Queued',a.Status,false);
        
        LicenseInformationHandler lihObj = new LicenseInformationHandler();
        lihObj.getMonthText(1);
        lihObj.getMonthText(2);
        lihObj.getMonthText(3);
        lihObj.getMonthText(4);
        lihObj.getMonthText(5);
        lihObj.getMonthText(6);
        lihObj.getMonthText(7);
        lihObj.getMonthText(8);
        lihObj.getMonthText(9);
        lihObj.getMonthText(10);
        lihObj.getMonthText(11);
        lihObj.getMonthText(12);
        Test.StopTest();   
    }
       public static testmethod void licenseInformationHandlerUsingCred() 
    {
        
        Salesforce_Org__c so = new Salesforce_Org__c(Name='KN Devgirikon',Is_OAuth_Authorize__c=false,Salesforce_Org_Type__c='Sandbox',Target_Oid__c='test123', domain__c='https://informakn--DevGirikon.cs88.my.salesforce.com');    
        insert so; 
        system.assertEquals('KN Devgirikon',so.Name,false);
        Test.setMock(HttpCalloutMock.class, new OauthRedirectMock());
        LicenseInformationHandler.deserializeResponse deserial = new LicenseInformationHandler.deserializeResponse();
        Test.StartTest();
        
        LicenseInformationBatchController bc = 
            new LicenseInformationBatchController('Select Name,Salesforce_Org_Type__c,RefreshToken__c,ClientKey__c,Target_Oid__c, ClientSecret__c,Package_Name__c, domain__c,Is_OAuth_Authorize__c, Email__c, Org__c,PasswordE__c,User_Name__c from Salesforce_Org__c ');
        Id batchJobId = Database.executeBatch(bc, 1);
        
        // Check batch status after execution 
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems
                          from AsyncApexJob where Id = :batchJobId];
        
        system.assertEquals('Queued',a.Status,false);
        
        LicenseInformationHandler lihObj = new LicenseInformationHandler();
        lihObj.getMonthText(1);
        lihObj.getMonthText(2);
        lihObj.getMonthText(3);
        lihObj.getMonthText(4);
        lihObj.getMonthText(5);
        lihObj.getMonthText(6);
        lihObj.getMonthText(7);
        lihObj.getMonthText(8);
        lihObj.getMonthText(9);
        lihObj.getMonthText(10);
        lihObj.getMonthText(11);
        lihObj.getMonthText(12);
        Test.StopTest();   
    }
           public static testmethod void licenseInformationBatchScheduleJob() 
    {
        
        Salesforce_Org__c so = new Salesforce_Org__c(Name='KN Devgirikon',Is_OAuth_Authorize__c=false,Salesforce_Org_Type__c='Sandbox',Target_Oid__c='test123', domain__c='https://informakn--DevGirikon.cs88.my.salesforce.com');    
        insert so; 
        system.assertEquals('KN Devgirikon',so.Name,false);
        Test.setMock(HttpCalloutMock.class, new OauthRedirectMock());
        LicenseInformationHandler.deserializeResponse deserial = new LicenseInformationHandler.deserializeResponse();
        Test.StartTest();
        LicenseInformationSchedular obj = new LicenseInformationSchedular();
        String sch = '0 0 23 * * ?';
        system.schedule('License Usage Job',sch,obj);

        Test.StopTest();   
    }
}