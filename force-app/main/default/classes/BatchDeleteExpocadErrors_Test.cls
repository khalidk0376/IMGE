/**
* File:        BatchDeleteExpocadErrors_Test.cls
* Project:     BAU
* Date:        Oct 24, 2019 
* Created By:  Akshi Arora
* *************************************************************************
*/
@isTest 
public class BatchDeleteExpocadErrors_Test {
    static testMethod void testMethod1() {
        String CRON_EXP = '0 0 0 15 3 ? *';
        Expocad_Error__c eerr = new Expocad_Error__c();
        eerr.Description__c ='Test Description';
        eerr.CurrencyIsoCode = 'USD';
        insert eerr;
        System.assertEquals('Test Description', eerr.Description__c, 'Test Class Fail');
        Test.setCreatedDate(eerr.Id, DateTime.newInstance(2019,08,01));
        Test.startTest();
        BatchDeleteExpocadErrors obj = new BatchDeleteExpocadErrors();
        DataBase.executeBatch(obj); 
        String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new BatchDeleteExpocadErrors());
        Test.stopTest();
    }
}