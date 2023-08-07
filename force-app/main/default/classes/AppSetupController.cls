/**
 * Created/Modified By: Girikon(Mahesh/Divaker)
 * Created On:          24 May 2018
 * Description/Purpose: Set App Data  
 * Test Class:  FBUtilTest
 * Code Coverage: 85%
**/
public with sharing class AppSetupController {
    @AuraEnabled
	public static sObject getTemplates(String qid) {
		String query='Select Id,Submit_Button_Label__c,Submit_Button_Color__c,Previous_Button_Label__c,Previous_Button_Color__c,Next_Button_Label__c,Button_Alignment__c,Buttons_Position__c,Is_Customize_Buttons__c,Next_Button_Color__c from Questionnaire__c WHERE id=\''+qid+'\'';
		List<sObject> objList = FBUtils.getRecords('Questionnaire__c', 'Id,Submit_Button_Label__c,Submit_Button_Color__c,Previous_Button_Label__c,Previous_Button_Color__c,Next_Button_Label__c,Button_Alignment__c,Buttons_Position__c,Is_Customize_Buttons__c,Next_Button_Color__c', query);
        if(objList.size()>0){
        	return objList[0];
        }
        return new Questionnaire__c();
	}
    @AuraEnabled
	public static String getSections(String qid) {
		System.debug('qid::::'+qid);
        String results = '[]';
        if(FBUtils.isSafeField('Question_Questionnaire__c','Question_Group__c',true,false,false,false) && 
        	FBUtils.isSafeField('Question_Group__c','Name',true,false,false,false))
        {
        	AggregateResult [] res = [Select count(id),Question_Group__c,MIN(Question_Group__r.Name) sectionName from Question_Questionnaire__c WHERE Questionnaire__c=:qid group by Question_Group__c];
    		results = JSON.serialize(res);
		}
		return results;
	}
    @AuraEnabled
    public static String setAppData(String datas) {
        FBUtils.FBResponse response = new FBUtils.FBResponse();

        wrap_cl questionary = (wrap_cl)JSON.deserialize(datas, wrap_cl.class);
        System.debug(questionary);

        Map<Integer,List<FBUtils.KeyValuePair>> recordsToupdate = new Map<Integer,List<FBUtils.KeyValuePair>>();
        List<FBUtils.KeyValuePair> listObj2 = new List<FBUtils.KeyValuePair>();                                
        listObj2.add(new FBUtils.KeyValuePair('Id',questionary.qid));
        listObj2.add(new FBUtils.KeyValuePair('Button_Alignment__c',questionary.alignment));
        listObj2.add(new FBUtils.KeyValuePair('Buttons_Position__c',questionary.buttonPosition));
        listObj2.add(new FBUtils.KeyValuePair('Is_Customize_Buttons__c',questionary.isCutomize));
        listObj2.add(new FBUtils.KeyValuePair('Next_Button_Color__c',questionary.nextButonColor));
        listObj2.add(new FBUtils.KeyValuePair('Next_Button_Label__c',questionary.nextButonLabel));
        listObj2.add(new FBUtils.KeyValuePair('Previous_Button_Color__c',questionary.prevButonColor));
        listObj2.add(new FBUtils.KeyValuePair('Previous_Button_Label__c',questionary.prevButonLabel));
        listObj2.add(new FBUtils.KeyValuePair('Submit_Button_Color__c',questionary.submitButonColor));
        listObj2.add(new FBUtils.KeyValuePair('Submit_Button_Label__c',questionary.submitButonLabel));
        recordsToupdate.put(0,listObj2);

        response = FBUtils.updateRecords('Questionnaire__c', recordsToupdate);

        return JSON.serialize(response);
    }

    public class wrap_cl
    {
        @AuraEnabled public String qid;
        @AuraEnabled public String alignment;
        @AuraEnabled public String nextButonLabel;
        @AuraEnabled public String prevButonLabel;
        @AuraEnabled public String submitButonLabel;
        @AuraEnabled public String nextButonColor;
        @AuraEnabled public String prevButonColor;
        @AuraEnabled public String submitButonColor;
        @AuraEnabled public Boolean isCutomize;
        @AuraEnabled public String buttonPosition;
    }
    public class fbmessage
    {
        @AuraEnabled public string message;
        @AuraEnabled public string type;
        public fbmessage(string message,string type){
            this.message = message;
            this.type = type;
        }
    }

}