/**
* File:         ErrorLogUtility
* Project:      Foundational CRM
* Created Date: 19th April 2022
* Created By:   (Girikon)
* Test Class:   ErrorLogUtility_Test
* Coverage:     100%
* *******************************************************************************************************
* @description : Calling from Batch Class to insert the Error Log In Interface Error Line Object.
* *******************************************************************************************************
* Last Modified By :   
*/
public with sharing class ErrorLogUtility {
    
    /**
    * @description  Used for Inserting the Intreface Error Log Record from Batch Class.
    * @param  interfaceLogLine
    * @return  Id
    */
    public static Id logApexCalloutError(Interface_Error_Line__c interfaceLogLine)
    {
        Interface_Error_Line__c errorLine = InterfaceLogLine.clone(false, false, false, false);
        errorLine.Error_Message__c = (errorLine.Error_Message__c!=null?errorLine.Error_Message__c.left(32768):'');
        errorLine.Error_Code__c = (errorLine.Error_Code__c!=null?errorLine.Error_Code__c.left(255):'');
        if(String.isNotBlank(errorLine.Interface_Log__c) && Schema.sObjectType.Interface_Error_Line__c.isCreateable())
        {
            insert errorLine;
        }else{
            Interface_Log__c  interfaceLog = New Interface_Log__c(Context__c =''); 
            if(Schema.sObjectType.Interface_Log__c.isCreateable())
            {
                insert interfaceLog;
            }    
            errorLine.Interface_Log__c = interfaceLog.Id;
            if(Schema.sObjectType.Interface_Error_Line__c.isCreateable())
            {
                insert errorLine;
            }    
        }
        return errorLine.Interface_Log__c;
    }

    /**
    * @description  Calling from Batch class to insert context and logType.
    * @param  context
    * @param  logType
    * @return  ID
    */
    public static Id createInterfaceLog(String context, String logType)
    { 
        String interfaceLofId;
        if(String.isNotBlank(Context) && String.isNotBlank(LogType)){
            Interface_Log__c  interfaceLof = New Interface_Log__c();
            interfaceLof.Context__c=Context;
            interfaceLof.Log_Type__c=LogType;
            if(Schema.sObjectType.Interface_Log__c.isCreateable())
            {
                insert interfaceLof ;  
            }    
            interfaceLofId = interfaceLof.Id;
        }
        return interfaceLofId;
    }
}