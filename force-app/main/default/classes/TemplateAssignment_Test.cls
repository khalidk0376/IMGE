/**
 * Created/Modified By: Aish(Girikon)
 * Created On:          01/07/2018
 * Description/Purpose: This test class covers the apex class : TemplateAssignment
 * Apex Class:          TemplateAssignment
**/
@isTest
public class TemplateAssignment_Test {
    
    static testMethod void TemplateAssignmentDataInsert(){
        //Create Questionnaire record
        Questionnaire__c oQnaire = new Questionnaire__c();
        oQnaire.Name='Template 1';
        oQnaire.Category__c='Healthcare';
        oQnaire.Description__c='Template 1';
        oQnaire.Community_URL__c=URL.getSalesforceBaseUrl().toExternalForm();       
        oQnaire.isMerge__c=true;
        insert oQnaire;
        
        account acc = new account(Name='TestLName');
        insert acc;
        System.AssertNotEquals(acc, null,'Account not equal null');
        
        Contact con = new Contact(LastName='User',FirstName ='Test', AccountId = acc.id);
        insert con;
        System.AssertNotEquals(con, null,'Contact not equal null');
        
        string commUsrProfile ='Customer Community Login User Custom';
        //Fetch community user profile
        Profile p = [SELECT Id FROM Profile WHERE Name=:commUsrProfile]; 
        User u = new User(Alias = 'cUser', Email='comm.user@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Kumar', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id,contactID=con.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='comm.user@test.org.comuser');        
        Test.StartTest();
            insert u;
            
            List<string> listUserId = new List<string>();
            listUserId.add(u.id);
            
            String searchValue = 'test';
            List<Id> listLocationIds = new List<Id>();
            listLocationIds.add(u.id);
        
            TemplateAssignment.searchUserType(searchValue);
        
            
            TemplateAssignment.saveShareLocationData(listUserId, oQnaire.Id);
            TemplateAssignment.fetchChildernLocationData(listLocationIds);
        Test.StopTest();
    }

}