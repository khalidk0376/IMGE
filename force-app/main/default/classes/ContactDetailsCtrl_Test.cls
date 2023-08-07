/**
* Created By       :   Girikon(Sunil)
* Created On       :   Mar 13 2019
* @description     :   Test class to provide code coverage.          
* Apex Class       :   ContactDetailsCtrl(100%)

* Modification log --
* Modified by      :   Girikon(Sunil)[LTN-32 (Mar 11 2019)]
**/

@isTest
public class ContactDetailsCtrl_Test {
    static testMethod void callTest() {
        Test.startTest();
        Account acc=new Account();
        acc.Name='test account';
        insert acc;
        System.assertNotEquals(null, acc.Id,'Account should not be null');
        
        opportunity opp= new opportunity();
        opp.AccountId=acc.id;
        opp.Name='test';
        opp.StageName='Prospecting';
        opp.CloseDate=system.today();
        insert opp;
        
        Contact con = new Contact();
        con.LastName='test';
        insert con;
        
        ContactDetailsCtrl.getRecords('Opportunity','StageName,AccountId','Opportunity_Contact__c',opp.id,1,5);
        //ContactDetailsCtrl.getOpportunities(opp.Id);
        ContactDetailsCtrl.getCurrentUserDtls();
        string recordId = con.Id;
       list<contact> conList =  LtngUtilityCtrl.getRecord(recordId,'Contact','LastName');
        LtngUtilityCtrl.getCurrentUserDtls();
        Test.stopTest();
    }
    
}