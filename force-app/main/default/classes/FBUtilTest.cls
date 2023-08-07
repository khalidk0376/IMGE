/**
* Created/Modified By: Girikon(Mahesh/Divaker)
* Created On:          26 Apr 2018
* Description/Purpose: This test class covers the apex class : AppSetupController,FBUtils
* Apex Class:         AppSetupController(85%),FBUtils(78%)
**/
@IsTest
private class FBUtilTest {

    private static testMethod void testInsertRecords()
    {
        Profile profileRec = [SELECT Id, Name FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        FBUtils.isAccessible('Question_Response__c', 'Answer__c,Comment__c');
        FBUtils.isAccessible('Question_Response__c', 'Answer,Comment__c');
        
        FBUtils.isCreateable('Question_Response__c', 'Answer__c,Comment__c');
        FBUtils.isCreateable('Question_Response__c', 'Answer,Comment__c');
        FBUtils.isCreateable('Question_Response__c', 'Id,Comment__c');
        
        FBUtils.isUpdateable('Question_Response__c', 'Answer__c,Comment__c');
        FBUtils.isUpdateable('Question_Response__c', 'Answer,Comment__c');
        FBUtils.isUpdateable('Question_Response__c', 'Id,Comment__c');
        
        List<FBUtils.KeyValuePair> listObj = new List<FBUtils.KeyValuePair>();
        
        listObj.add(new FBUtils.KeyValuePair('Answer__c', 'responseText'));
        listObj.add(new FBUtils.KeyValuePair('Comment__c', 'bq.comment'));        
        listObj.add(new FBUtils.KeyValuePair('User__c', UserInfo.getUserId()));
        
        
        Map<Integer,List<FBUtils.KeyValuePair>> recordsToInsert = new Map<Integer,List<FBUtils.KeyValuePair>>();
        recordsToInsert.put(0,listObj);
        
        //Test insertRecords() method
        FBUtils.FBResponse response = FBUtils.insertRecords('Question_Response__c', recordsToInsert);
        System.assertEquals(response.isSuccess, true , 'To update records value must be true');
        
        //Test getRecords() method
        List<sObject> dbRecords = FBUtils.getRecords('Question_Response__c', 'Id,Answer__c,Question__r.Label__c,Comment__c,User__c', 'Select Id,Answer__c,Comment__c,User__c from Question_Response__c Where Answer__c=\'responseText\'');
        if(dbRecords.size()>0){
            System.assertEquals('responseText', dbRecords[0].get('Answer__c'), 'dbRecords must be inserted and not null');
        }
        
        
        //Create Questionnaire record
        Questionnaire__c oQnaire = new Questionnaire__c();
        oQnaire.Name='Template 1';
        oQnaire.Category__c='Healthcare';
        oQnaire.Description__c='Template 1';
        oQnaire.Community_URL__c=URL.getSalesforceBaseUrl().toExternalForm();       
        oQnaire.isMerge__c=true;
        insert oQnaire;
         
        //Test updateRecords() method
        recordsToInsert.get(0).add(new FBUtils.KeyValuePair('Id',dbRecords[0].get('Id')));
        recordsToInsert.get(0).add(new FBUtils.KeyValuePair('Answer__c','Girikon LLC'));
        FBUtils.FBResponse response2 = FBUtils.updateRecords('Question_Response__c', recordsToInsert);System.debug(response2);
        System.assertEquals(response2.isSuccess, true, 'To update records value must be true');
        
        List<FBUtils.wrp_cl> rsult = FBUtils.getSelectedProfileToCommunity('testid');
        string data='{"qid":"test","alignment":"test","nextButonLabel":"test","prevButonLabel":"test","submitButonLabel":"test","nextButonColor":"test","prevButonColor":"test"}';
        string result = AppSetupController.setAppData(data); 
        AppSetupController.getTemplates(oQnaire.Id);
        AppSetupController.getSections(oQnaire.Id);
    }
}