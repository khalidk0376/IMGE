/**
* File:        BatchDeleteErrorLogs_Test
* Project:     BAU
* Date:        Oct 24, 2019 
* Created By:  Akshi Arora
* *************************************************************************
*/
@isTest 
public class BatchDeleteErrorLogs_Test 
{
    static testMethod void testMethod1() {
            String CRON_EXP = '0 0 0 15 3 ? *';
            Error_Log__c errlog = new Error_Log__c();
            errlog.Source_Name__c ='Test';
            errlog.CurrencyIsoCode = 'USD';
            insert errlog; 
            System.assertEquals('Test', errlog.Source_Name__c, 'Test Class Fail');
            Test.setCreatedDate(errlog.Id, DateTime.newInstance(2019,08,01));
            Test.startTest();
            BatchDeleteErrorLogs obj = new BatchDeleteErrorLogs();
            DataBase.executeBatch(obj); 
            String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new BatchDeleteErrorLogs());
            Test.stopTest();
    }
}