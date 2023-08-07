/**
 * Created/Modified By: Girikon(Mahesh/Divaker)
 * Created On:          24 May 2018
 * Description/Purpose: Wrapper Class using in NewCreateTemplateCtr 
 * Test Class:  NewCreateTemplateCtrl_Test
 * Code Coverage: 100%
**/
public with sharing class FBPreviewWrapper {
    @AuraEnabled public List<FBWrapper> sectionList;
    @AuraEnabled public Questionnaire__c Questionnaire;

    public FBPreviewWrapper(){
        sectionList = new List<FBWrapper>();
        Questionnaire = new Questionnaire__c();
    }
}