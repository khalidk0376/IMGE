/*Created By: Avinash Singh
Created On: 27/09/2018, [Aishwarya BK-3759 27 Aug 2020]
Description/Purpose: This class is used to schedule the LicenseInformationBatchController Batch class.
*/
public class LicenseInformationSchedular implements Schedulable {
    
    // public String sqlQr;  
    public void execute(SchedulableContext sc) {
      //  LicenseInformationBatchController lcns = new LicenseInformationBatchController('Select Name,Salesforce_Org_Type__c,RefreshToken__c,ClientKey__c,Target_Oid__c, ClientSecret__c,Package_Name__c, domain__c, Email__c, Org__c, Password__c,User_Name__c from Salesforce_Org__c ');
        LicenseInformationBatchController lcns = new LicenseInformationBatchController('Select Name,Is_OAuth_Authorize__c,AuthId__c,AccessToken__c,RefreshToken__c,Salesforce_Org_Type__c,ClientKey__c,Target_Oid__c, ClientSecret__c,Package_Name__c, domain__c, Email__c, Org__c, PasswordE__c ,User_Name__c from Salesforce_Org__c where RefreshToken__c!=null  OR Is_OAuth_Authorize__c = false');

        Database.executeBatch(lcns);
    }        
}