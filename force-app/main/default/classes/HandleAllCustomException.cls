/**
* File:         HandleAllCustomException
* Project:      Foundational CRM
* Created Date: 24-04-2022
* Created By:   (Girikon)
* Test Class:   HandleAllCustomException_Test
* Coverage:     100%
* *******************************************************************************************************
* @description : Handles all exceptions related to Apex Classes and Triggers designed and stores in Custom_Error_Log__c object as a record.
* *******************************************************************************************************
* Last Modified By : 
*/
public with sharing class HandleAllCustomException extends Exception 
{
    /**
    * @description  The method to logging exception in Custom_Error_Log__c object.
    * @param  e Exception
    * @param  relatedToId
    * @param triggerOn
    */
    public static void logException(Exception e,string relatedToId, string triggerOn)
    {
        String stackTrace = e.getStackTraceString().substringBefore('\n');
        String className = stackTrace.substringAfter('.').substringBefore('.'); 
        String methodName = stackTrace.substringBefore(':').substringAfter(className).substringAfter('.');
        
        Custom_Error_Log__c customLog = new Custom_Error_Log__c();
        customLog.Line_Number__c = String.isNotBlank(String.valueof(e.getLineNumber())) ? String.valueof(e.getLineNumber()) : '';
        customLog.Message__c = String.isNotBlank(e.getMessage()) ? e.getMessage():'';
        customLog.StackTrace__c = String.isNotBlank(e.getStackTraceString()) ? e.getStackTraceString() : '';
        customLog.Type__c = String.isNotBlank(e.getTypeName()) ? e.getTypeName() : '';
        customLog.Method__c = String.isNotBlank(methodName) ? methodName : '';
        customLog.Apex_Class__c = String.isNotBlank(className) ? className : '';
        customLog.UserID__c = UserInfo.getUserId();
        customLog.On__c = triggerOn;
        customLog.RecordID__c = relatedToId;  
        
        Database.insert(customLog);           
    } 
}