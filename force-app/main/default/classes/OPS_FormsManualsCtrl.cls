/**
* Created By       :   Girikon(Sunil[STL-156])
* Created On       :   Sep 19, 2019
* @description     :   This controller is used in manuals and Forms reports in CC ops admin.          
* Test Class       : 	OPS_FormsManualsCtrl_Test

* Modification log --
* Modified by      :   History: BK-3758 Modified By Rajesh Kumar - on 28-05-2020 
**/
public with sharing class OPS_FormsManualsCtrl {
    /*
* @description [getRecords description]
* @param  objName     [Object api name]
* @param  fieldNames  [Field api names]
* @param  compareWith [Compare field]
* @param  recordId    [Record id]
* @param  pageNumber  [Page Number]
* @param  pageSize    [Page Size]
* @return             [List of sObject]
*/
    @AuraEnabled
    public static RecordDataTableWrapper getAggregateRecords(string objName, string fieldNames,string srchField,string srchText,string conditions,string groupbyFields,string sortBy,string sortType,Decimal pageNumber, Decimal pageSize) {
        
        srchText = string.escapeSingleQuotes(srchText);
        srchText ='%'+srchText+'%';
        Integer pSize = (Integer)pageSize;
        Integer pNumber = (Integer)pageNumber;
        
        //Offset for SOQL
        Integer offset = (pNumber - 1) * pSize;
        string strCountQuery='SELECT COUNT(Id) FROM '+String.escapeSingleQuotes(objName); 
        if(string.isNotBlank(conditions))
        {
            strCountQuery=strCountQuery+ ' '+conditions;
        }
        if(string.isNotBlank(srchField) && string.isNotBlank(srchText))
        {
            if(srchField.Contains(','))
            {
                strCountQuery=strCountQuery+ ' and (';  
                String[] srchFields = srchField.split(',');
                for(Integer i=0;i<srchFields.size();i++)
                {
                    strCountQuery= i==0?strCountQuery + String.escapeSingleQuotes(srchFields[i])+' LIKE \''+srchText+'\' ': strCountQuery+' Or '+String.escapeSingleQuotes(srchFields[i])+' LIKE \''+srchText+'\' ';
                }
                strCountQuery=strCountQuery+ ' )';  
            }
            else 
            {
                strCountQuery=strCountQuery+ ' and '+String.escapeSingleQuotes(srchField)+' LIKE \''+srchText+'\' '; 
            }
        }
        if(string.isNotBlank(groupbyFields))
        {
            strCountQuery=strCountQuery+ ' '+String.escapeSingleQuotes(groupbyFields);
        }
        //Total Records
        Integer totalRecords = database.query(strCountQuery).Size();
        Integer recordEnd = pSize * pNumber;
        //Instance of Contact DataTable Wrapper Class
        RecordDataTableWrapper objDT =  new RecordDataTableWrapper();  
        objDT.pageSize = pSize;
        objDT.pageNumber = pNumber;
        objDT.recordStart = offset + 1;
        objDT.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
        objDT.totalRecords = totalRecords;
        string strQuery='SELECT '+String.escapeSingleQuotes(fieldNames) +' from '+String.escapeSingleQuotes(objName);
        
        if(string.isNotBlank(conditions))
        {
            strQuery=strQuery+ ' '+conditions;
        }
        if(string.isNotBlank(srchField) && string.isNotBlank(srchText))
        {
            if(srchField.Contains(','))
            {
                strQuery=strQuery+ ' and (';  
                String[] srchFields = srchField.split(',');
                for(Integer i=0;i<srchFields.size();i++)
                {
                    strQuery= i==0?strQuery + String.escapeSingleQuotes(srchFields[i])+' LIKE \''+srchText+'\' ': strQuery+' Or '+String.escapeSingleQuotes(srchFields[i])+' LIKE \''+srchText+'\' ';
                }
                strQuery=strQuery+ ' )';  
            }
            else 
            {
                strQuery=strQuery+ ' and '+String.escapeSingleQuotes(srchField)+' LIKE \''+srchText+'\' '; 
            }
        }
        if(string.isNotBlank(groupbyFields))
        {
            strQuery=strQuery+ ' '+String.escapeSingleQuotes(groupbyFields);
        }
        if(string.isNotBlank(sortBy) && string.isNotBlank(sortType) )
        {
            strQuery=strQuery+' order by '+String.escapeSingleQuotes(sortBy)+' '+ String.escapeSingleQuotes(sortType);
        }
        strQuery=strQuery+'  LIMIT :pSize OFFSET :offset';
        
        objDT.recordList = Database.query(strQuery);
        return objDT;
    }
    
    //Wrapper Class For Contact DataTable  
    public class RecordDataTableWrapper {
        @AuraEnabled
        public Integer pageSize {get;set;}
        @AuraEnabled
        public Integer pageNumber {get;set;}
        @AuraEnabled
        public Integer totalRecords {get;set;}
        @AuraEnabled
        public Integer recordStart {get;set;}
        @AuraEnabled
        public Integer recordEnd {get;set;}
        @AuraEnabled
        public List<AggregateResult> recordList {get;set;}
    }
    /*
* @description [get User Manual Action ]
* @param  manualsId     [Manual id ]
* @return [List of sObject(User_Manual_Action__c)]
*/
    @AuraEnabled
    public static List<User_Manual_Action__c> getUserManualAction(string manualsId) 
    { 
        List<User_Manual_Action__c> userAction = new List<User_Manual_Action__c>();
        if(string.isNotBlank(manualsId))
            userAction = [Select Id,Name,Account__c,Is_Agree__c from 
                          User_Manual_Action__c 
                          where Manual_Permission__r.Active__c=true 
                          and Is_Agree__c=false 
                          and Manual_Permission__r.Manuals__c=: manualsId];
        return userAction;
    }
    
    /*
* @description [Send remainder email]
* @param  eventEditionId     [Event edition id ]
* @param  accList     [list of account  ]
* @param  EventEditionManual     [Event edition manuals ]
* @return [boolean return success or faliure status  of email message  ]
*/
    
    @AuraEnabled
    public static boolean SingleManualReminderEmail(String eventEditionId,String accList ,String EventEditionManual) 
    {
        SingleManualReminderEmailBatch batch = new SingleManualReminderEmailBatch(eventEditionId,accList,EventEditionManual);
        Database.executeBatch(batch,10);
        return true;
    }
    
        /*
* @description [Fetch User Form Action information ]
* @param  formsId     [form id for which we need to fetch data ]
* @return [ return  list of user form action  ]
*/
    
    @AuraEnabled
    public static List<User_Form_Action__c> getUserFormAction(string formsId) 
    { 
        List<User_Form_Action__c> userAction = new List<User_Form_Action__c>();
        if(string.isNotBlank(formsId))
            userAction = [Select Id,Name,Account__c 
                          from User_Form_Action__c 
                          where Form_Permission__r.Active__c=true 
                          and Is_Filled_Up__c=false 
                          and Form_Permission__r.Event_Edition_Form__c=: formsId 
                          AND Account__c!=null];
        return userAction;
    }
        /*
    * @description [Send remainder email to accounts ]
    * @param  eventEditionId     [form id for which we need to fetch data]
    * @param  accList     [form id for which we need to fetch data ]
	* @param  EventEditionForm     [fevent edition form id  ]
    * @return [ boolean return success or faliure status  of email message ]
    */
    @AuraEnabled
    public static boolean SingleFormReminderEmail(String eventEditionId, String accList, String EventEditionForm)
    { 
        SingleFormReminderEmailBatch batch = new SingleFormReminderEmailBatch(eventEditionId, accList, EventEditionForm);
        Database.executeBatch(batch,10);
        return true;
    }
    
    @AuraEnabled
    public static void approveAndRejectFormSendEmail(String status,String note,String eventEditionId,String userActionId,String eventEditionForm,sobject formData){
        if(status=='Approved'){
            FormAcceptEmail.FormAcceptEmail(eventEditionId, userActionId, eventEditionForm, note);
        }
        else if(status=='Rejected'){
            FormRejectEmail.FormRejectEmail(eventEditionId, userActionId, eventEditionForm,note);
        }
        update formData;
    }
}