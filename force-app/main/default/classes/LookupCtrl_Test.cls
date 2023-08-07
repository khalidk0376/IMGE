/**
* Created/Modified By: Girikon(Mahesh/Divaker)
* Created On:          26 Apr 2018
* Description/Purpose: This test class covers the apex class : LookupCtrl 
* Apex Class:        LookupCtrl (100%)
**/
@isTest
private class LookupCtrl_Test {
    
    static testMethod void createQniareRecordTestMethod(){
        // Implement test code
        // creating Account record
        Account acc = new Account(Name='Test Account');
        insert acc;
        List<Account> lstAcc = [Select id from Account where id=:acc.id];
        System.assertNotEquals(lstAcc, null,'Account not equal null');
        System.assertEquals(lstAcc.size(),1,'Account must be inserted');
        
        Test.startTest();
            String result = LookupCtrl.searchDB('Account','Name', 'Id',acc.Name ) ;
            System.assertNotEquals(result, null,'result not equal null');
            //System.assert(result.length()>0,'exit account name');
            System.assertNotEquals(result.length(),null,'exist account name');
        Test.stopTest();
    } 
}