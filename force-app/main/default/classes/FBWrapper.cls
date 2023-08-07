/**
 * Created/Modified By: Girikon(Mahesh/Divaker)
 * Created On:          24 May 2018
 * Description/Purpose: Wrapper Class using in NewCreateTemplateCtr 
 * Test Class:  NewCreateTemplateCtrl_Test
 * Code Coverage: 100%
**/
public with sharing class FBWrapper {
    @AuraEnabled public QuestionGroupWithQuestionsWrap col1Questions;
    @AuraEnabled public QuestionGroupWithQuestionsWrap col2Questions;
    @AuraEnabled public QuestionGroupWithQuestionsWrap col3Questions;
    @AuraEnabled public String sectionColNumber;
    @AuraEnabled public String sectionName;

    public FBWrapper(){
        col1Questions = new QuestionGroupWithQuestionsWrap();
        col2Questions = new QuestionGroupWithQuestionsWrap();
        col3Questions = new QuestionGroupWithQuestionsWrap();
        sectionColNumber = '';
        sectionName ='';
    }
}