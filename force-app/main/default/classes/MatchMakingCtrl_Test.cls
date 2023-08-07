/**
 * Created By   :   Girikon(Rajeev)
 * Created On   :   23/08/2019
 * @description :   Test class of MatchMakingCtrl controller
 * Apex Class   :   MatchMakingCtrl
 
 * Modification Log----- 
 * Modified by  :   Girikon(Aishwarya [Sep 2 2019])
 **/

@IsTest
public class MatchMakingCtrl_Test {
  static testMethod void matchMethod()
  {
        //insert account data
        account acc = new account(Name='TestLName');
        insert acc;
        System.AssertNotEquals(acc, null, 'Account cannot be null');
       
        Contact con = new Contact(LastName='User',FirstName ='Test', AccountId = acc.id);
        insert con;
        System.AssertNotEquals(con, null, 'Contact cannot be null');
        
        User_Type__c uType1 = new User_Type__c(Name ='Exhibitor');
        insert uType1;
        System.AssertEquals(uType1.Name, 'Exhibitor', 'The user type name must be exhibitor.');
        
        String commUsrProfile;
        If(Label.Community_User_Profile!= NULL)
        {
            commUsrProfile= Label.Community_User_Profile;
        }  
        else
        {
            commUsrProfile='Customer Community Login User Custom';
        }
        Profile p = [SELECT Id FROM Profile WHERE Name=:commUsrProfile]; 
          User u = new User(
          Alias = 'testu',
          Email = 'test@unitingambition.com',
          EmailEncodingKey = 'UTF-8',
          LastName = 'Test',
          LanguageLocaleKey = 'en_US',
          LocaleSidKey = 'en_US',
          TimeZoneSidKey='America/Los_Angeles',
          ProfileId = p.Id,
          ContactId=con.Id,
          UserName='test@unitingambition.com'
        );      
        insert u;
        
        //insert EventEdition
        Event_Edition__c eventEdition1 = new Event_Edition__c(Name='TOC 2018',Event_Code__c='TOC18',Event_Currency__c='USD',End_Date__c=System.Today(),Start_Date__c=System.Today());
        insert eventEdition1;
        System.assertEquals(eventEdition1.Event_Code__c,'TOC18', 'Event Code');
        
        GoMed2Med__c goMed2Med = new GoMed2Med__c();
        goMed2Med.Account__c=acc.Id;
        goMed2Med.Event_Edition__c=eventEdition1.Id;
        goMed2Med.Are_you_a_distributor__c='yes';
        goMed2Med.Are_you_a_manufacturer_supplying_to_End__c='no';
        goMed2Med.Are_you_a_manufacturer_supplying_to_Dist__c='yes';
        goMed2Med.LastModifiedByCC__c=system.today();
        goMed2Med.Contact__c=con.Id;
        insert goMed2Med;
        
        system.runAs(u)
        {
            Test.startTest();
                MatchMakingCtrl.MatchMaking('yes', 'no', 'yes', acc.id ,eventEdition1.id,system.today());
                MatchMakingCtrl.med2MedDetails(eventEdition1.id,acc.id);
            Test.stopTest(); 
        }
  }
}