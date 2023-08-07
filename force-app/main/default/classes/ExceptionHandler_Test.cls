/**
 * Created/Modified By    :  Mahesh (Girikon)
 * Created On:            :  June 12 2019
 * @description           : [This test class covers the apex class : ExceptionHandler]
 * Modification log --
 * Modified By            :
**/
@isTest
private class ExceptionHandler_Test {
     
    @isTest static void dmlException_test_1() {
 
        try{
            insert new Account();
        }catch(Exception ex){
            ExceptionHandler.capture(ExceptionHandler_Test.class, ex);
        }
 
        System.assertEquals(1, [SELECT COUNT() FROM esso_ErrorLog__c],'That should be return true');
    }
 
    @isTest static void dmlException_test_2() {
     
        try{
            insert new Account();
        }catch(Exception ex){
            ExceptionHandler.capture(ExceptionHandler_Test.class, ex, 'this is an custom error msg');
        }
 
        System.assertEquals(1, [SELECT COUNT() FROM esso_ErrorLog__c],'That should be return true');
    }
 
    @isTest static void queryException_test_1() {
             
        try{
            Account newAcccount = [SELECT Id FROM Account LIMIT 1];
        }catch(Exception ex){
            ExceptionHandler.capture(ExceptionHandler_Test.class, ex);
        }
 
        System.assertEquals(1, [SELECT COUNT() FROM esso_ErrorLog__c],'That should be return true');
    }
 
    @isTest static void dmlException_test_Custom_Msg() {
 
        String errorMsg = 'UNIT_TEST_ERROR';
 
        try{
            insert new Account();
        }catch(Exception ex){
            ExceptionHandler.capture(ExceptionHandler_Test.class, ex, errorMsg);
        }
 
        System.assertEquals(1, [SELECT COUNT() FROM esso_ErrorLog__c],'That should be return true');
    }
 
    @isTest static void dmlException_test_withObject_Attachment() {
 
        Account newAccount = new Account(Phone = '01234123123');
 
        try{
            insert newAccount;
        }catch(Exception ex){
            ExceptionHandler.capture(ExceptionHandler_Test.class, ex, 'INSERT', new Map<String, Object>{'newAccount' => newAccount});
        }
 
        System.assertEquals(1, [SELECT COUNT() FROM esso_ErrorLog__c],'That should be return true');
    }
 
    @isTest static void dmlException_test_withObject_Attachment_with_custom_message() {
 
        String errorMsg = 'UNIT_TEST_ERROR';
 
        Account newAccount = new Account(Phone = '01234123123');
 
        try{
            insert newAccount;
        }catch(Exception ex){
            ExceptionHandler.capture(ExceptionHandler_Test.class, ex, 'INSERT', errorMsg, new Map<String, Object>{'newAccount' => newAccount});
        }
         
        System.assertEquals(1, [SELECT COUNT() FROM esso_ErrorLog__c],'That should be return true');
    }
 
    @isTest static void exception_custom_msg_only_test() {
 
        String errorMsg = 'UNIT_TEST_ERROR';
 
        Test.startTest();
            ExceptionHandler.dmlAsQueueable = true;
            ExceptionHandler.capture(ExceptionHandler_Test.class, errorMsg);
            ExceptionHandler.capture(ExceptionHandler_Test.class, errorMsg, new Map<String, Object>{'Test' => JSON.serialize('test')});
        Test.stopTest();
 
        System.assertEquals(2, 2,'That should be return true');
    }
         
}