/**
* Created/Modified By: Girikon(Mahesh/Divaker)
* Created On:          26 Apr 2018
* Description/Purpose:This Controller Using for Template Assignment
* Test Class:         TemplateAssignment_Test (91%)
*  History: BK-3758 Modified By Rajesh Kumar - on 28-05-2020
**/
public with sharing class TemplateAssignment
{
     /**
     * Search location(hierarchy) for particular template to share.
     * @param  searchValue: Input value for search.
     */
    @AuraEnabled
    public static String searchUserType(String searchValue){
        List<User> lstHierarchy=new List<User>();
        try{
            if(String.isNotBlank(searchValue)){
                searchValue = string.escapeSingleQuotes(searchValue);
                searchValue = searchValue.replaceAll('(?<!\\\\)%', '\\\\%');
                searchValue ='%'+searchValue+'%';
                string sQuery ='Select Id,Name From User Where Name LIKE \''+ String.escapeSingleQuotes(searchValue) + '\'';
                lstHierarchy=Database.query(sQuery);
            } 
        }
        catch(Exception ex){ throw new AuraHandledException(ex.getMessage());
        }
        return JSON.serialize(lstHierarchy);
    }
    
    /**
     * Fetch children loaction(hierarchy) of selected loactions
     * @param  lstLocationIds: List of parent loactions(hierarchy) Id..
     */
    @AuraEnabled
    public static String fetchChildernLocationData(List<Id> lstLocationIds){
        List<User> lstHierarchy=new List<User>();
        try{
            lstHierarchy= [Select Id,Name From User Where Name IN:lstLocationIds];
        }
        catch(Exception ex){ throw new AuraHandledException(ex.getMessage());
        }
        return JSON.serialize(lstHierarchy);
    }
    /**
     * Save locations related with particular template in to the Questionnaire_Form__c object.
     * @param  lstUserId: List of selected loactions(hierarchy) Id.
     * @param  templateId: Selected Questionnaire(template) id.
     */
    @AuraEnabled
    public static boolean saveShareLocationData(List<String> lstUserId,String templateId){
        boolean success;
        
        List<Questionnaire_Form__c> lstQuestionnaireForm=new List<Questionnaire_Form__c>();
        try
        {
            if(lstUserId.size()>0)
            {   
                for(String strId:lstUserId){
                    Questionnaire_Form__c qstnForm=new Questionnaire_Form__c();
                    qstnForm.User__c=strId;
                    qstnForm.Questionnaire__c=templateId;
                    qstnForm.Assigned_Date__c=DateTime.now();
                    qstnForm.status__c='Inprogress';
                    lstQuestionnaireForm.add(qstnForm);
                }
                if(lstQuestionnaireForm.size()>0){
                    insert lstQuestionnaireForm;
                    success=true;
                }
            }
        }
        catch(Exception ex){ throw new AuraHandledException(ex.getMessage());
        }
        return success;
    }
}