/**
* Created/Modified By: Girikon(Mahesh)
* Created On:          26 Apr 2018
* @description : This test class covers the apex class :  NewCreateTemplateCtrl_Test
* Apex Class:         NewCreateTemplateCtrl_Test (80%)

* Modification Log----- 
* Modified by    : Girikon(Amish)[CCEN-360 (Jan 31 2019)]
**/
public with sharing class QuestionGroupWithQuestionsWrap {
       
   /* wrapper class for Question Group */    
    @AuraEnabled public String groupName{get;set;}
    @AuraEnabled public String sectionColNumber{get;set;}
    @AuraEnabled public String groupId{get;set;}
    @AuraEnabled public List<Question__c> lstQuestn{get;set;}
    @AuraEnabled public integer lstSize{get;set;}
    @AuraEnabled public List<String> col1QuestionIds;
    @AuraEnabled public List<String> col2QuestionIds;
    @AuraEnabled public List<String> col3QuestionIds;
    
    public QuestionGroupWithQuestionsWrap(){
        col1QuestionIds = new List<String>();
        col2QuestionIds = new List<String>();
        col3QuestionIds = new List<String>();
    }
}