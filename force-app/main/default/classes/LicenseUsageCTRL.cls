/* Create Date : 27/07/2020
* Created By : Himanshu Rana
* */

public with sharing class LicenseUsageCTRL {
    public static String selectedValue {get;set;}
    
    public SelectOption[] getselectValues() {     
        SelectOption[] options = new SelectOption[]{};
            options.add(new SelectOption('None','--------None--------')); 
        for(Salesforce_Org__c salesforceOrg : [Select  Id,Name  FROM Salesforce_Org__c where RefreshToken__c !=null  OR Is_OAuth_Authorize__c = false]) {
            options.add(new SelectOption(
                String.valueOf(salesforceOrg.Name),salesforceOrg.Name)); 
        } 
        return options;           
    } 
    
    public PageReference startBatch() {
        if(selectedValue !='None'){
            String whereCondition = ' Name=\''+selectedValue+'\'';
            String Query ='Select Name,AuthId__c,Is_OAuth_Authorize__c,AccessToken__c,RefreshToken__c,Salesforce_Org_Type__c,ClientKey__c,Target_Oid__c, ClientSecret__c,Package_Name__c, domain__c, Email__c, Org__c, PasswordE__c,User_Name__c from Salesforce_Org__c where ';
            Query+=' '+whereCondition;
            LicenseInformationBatchController bc =  new LicenseInformationBatchController(Query);
            Id batchJobId = Database.executeBatch(bc, 1);
            System.debug('Id '+batchJobId);
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO,'Batch start successfully'));   
        }
        else{
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO,'Please select a valid org'));   
            
        }
        return null;
    }
    
    public PageReference startBatchForAll() {
        try{
            LicenseInformationBatchController bc = new LicenseInformationBatchController('Select Name,Is_OAuth_Authorize__c,AuthId__c,AccessToken__c,RefreshToken__c,Salesforce_Org_Type__c,ClientKey__c,Target_Oid__c, ClientSecret__c,Package_Name__c, domain__c, Email__c, Org__c, PasswordE__c ,User_Name__c from Salesforce_Org__c where RefreshToken__c!=null  OR Is_OAuth_Authorize__c = false');
            Id batchJobId = Database.executeBatch(bc, 1);
            System.debug('Id '+batchJobId);
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO,'Batch start successfully'));   
            return null;
        } catch (Exception e) {
            ApexPages.addMessages(e);
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.Error,'Unable to execute batch something went wrong '));
            
            return null;
        }
    }
}