/**
* File         :   callbackLightningOutCtrl_Test 
* Project      :   Opportunity integration
* Created Date :   29th Apr 2022
* Created By   :   Girikon(Shiv Raghav, Abhishek)
* ******************************************************************************************************
 @description : Test Class to cover callbackLightningOutCtrl
*******************************************************************************************************
* Modification log :
* 1. 
*/

@isTest
private with sharing class callbackLightningOutCtrl_Test {
    @isTest static void testGetOpportunities() 
    {
        account acc = new account(Name='TestLName');
        insert acc;
        
        Contact con = new Contact(AccountId = acc.Id, FirstName = 'TestConFirst', LastName = 'TestConLast',phone='12346456', Email='abc@test.com',MailingCountry='USA',
                                  MailingStreet='123 Lake',MailingCity='Dallas',MailingState='Texas',MailingPostalCode='75039');
        insert con;
        
        Opportunity oOpportunity = new Opportunity( Name = 'Opportunity Test', CloseDate = Date.today().addDays(7), StageName = 'Discover', AccountId = acc.Id, Billing_Contact__c = con.Id, Payment_Status__c='Not Paid' );
        insert oOpportunity;
        
        list<Account> listacc = database.query('Select Id from Account LIMIT 1');
        list<Opportunity> opptys = callbackLightningOutCtrl.getOpportunities(listacc[0].Id);
        System.assertNotEquals(1, opptys.size(),'One Opportunity Found');       
        
    }
}