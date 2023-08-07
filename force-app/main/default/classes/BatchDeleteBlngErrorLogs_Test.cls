/**
* File:        BatchDeleteBlngErrorLogs_Test
* Project:     BAU
* Date:        Oct 24, 2019 
* Created By:  Akshi Arora
* *************************************************************************
*/
@isTest 
public class BatchDeleteBlngErrorLogs_Test
{
    static testMethod void testMethod1() {
        String CRON_EXP = '0 0 0 15 3 ? *';
            blng__ErrorLog__c blngerrlog = new blng__ErrorLog__c();
            blngerrlog.Name ='Test';
            blngerrlog.blng__ErrorCode__c = 'Code';
            insert blngerrlog;
            System.assertEquals('Test', blngerrlog.Name, 'Test Class Fail');
            Test.setCreatedDate(blngerrlog.Id, DateTime.newInstance(2019,08,01));
            Test.startTest();
            BatchDeleteBlngErrorLogs obj = new BatchDeleteBlngErrorLogs();
            DataBase.executeBatch(obj); 
            String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new BatchDeleteBlngErrorLogs());
            Test.stopTest();
    }
}