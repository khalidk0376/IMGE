@isTest
public class ErrorLogUtility_Test {
    @isTest 
    static void errorLogMethod()
    {
        Interface_Log__c  interfaceLog = New Interface_Log__c(Context__c ='');       
        insert interfaceLog;
        Interface_Error_Line__c  interfaceerror = New Interface_Error_Line__c (Interface_Log__c= interfaceLog.Id,Error_Code__c='Test'); 
        insert interfaceerror ;
        Interface_Error_Line__c  interfaceerrorlog = New Interface_Error_Line__c (Error_Code__c='Test'); 
        ErrorLogUtility.logApexCalloutError(interfaceerror);
        Id logId =  ErrorLogUtility.createInterfaceLog('context','logType'); 
        System.assertNotEquals(logId, null,'Error in InterfaceLog Creation');
        ErrorLogUtility.logApexCalloutError(interfaceerrorlog);
    }
}