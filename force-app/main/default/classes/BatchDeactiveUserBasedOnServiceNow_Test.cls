/**
* Created By    :       Adarsh Sharma
* Created On    :       01/10/2019
* @description  :       Test class for the below apex classes
* Apex Class    :       BatchDeactiveUserBasedOnServiceNow
**/
@isTest
public class BatchDeactiveUserBasedOnServiceNow_Test {
    //Test method for setup test data
    @isTest
    public static void serviceNowUserDataSetup()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'test', Email= 'testservicenow@gmail.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/New_York', 
                          UserName= 'testservicenow@gmail.com' , FederationIdentifier = 'test@servicenow.com');
        insert u;
        
        Test.startTest();                 
        Active_Directory_Details__c adu = new Active_Directory_Details__c(Name = 'test' , Active__c = false , AD_UPN__c = 'test@servicenow.com');  
        insert adu; 
        System.assertEquals ('test' ,adu.Name , 'Test Class failed' );  
        Adu.Active__c = false;
        System.assertEquals(adu.Active__c, false , 'Test Class Failed');  
        update adu;
        BatchDeactiveUserBasedOnServiceNow batchSchObj = new BatchDeactiveUserBasedOnServiceNow();
        String sch = '0 0 23 * * ?'; 
        system.schedule('BatchDeactiveUserBasedOnServiceNowTestclass', sch, batchSchObj);
        Test.stopTest();    
    }
}