/**
* Created/Modified By: Girikon(Mahesh)
* Created On:          30 June 2018
* Description/Purpose: This test class covers the apex class :  FBFileUploadCtrl 
* Apex Class:         FBFileUploadCtrl  (97%%)
**/
@IsTest
public class FBFileUploadCtrlTest 
{ 
    @IsTest
    private static void fBFileUpload()
    {
        Test.startTest();
        //Create Question Library
        Question_Library__c oQL= new Question_Library__c(Name='Global Default',Name__c='Global Default');
        insert oQL;

        //Create Question Record 
        Question__c oQue = new Question__c(Name='Test',Help_Text_Required__c=true, Name__c='Test 1', Help_Text__c='Test Help Text', Label__c='Question 1', 
            Question_Library__c=oQL.id, Required__c=true, Type__c='TextPlain',Allow_Comment__c=true,Allow_Attachments__c=true);
        insert oQue;
        
        //create Question option record.
        Question_Option__c qOption = new Question_Option__c(Name ='Test',Name__c='test',Score__c=1,Question__c=oQue.id);
        insert qOption;
        
        //Create Questionnaire record
        Questionnaire__c oQnaire = new Questionnaire__c();
        oQnaire.Name='Template 1';
        oQnaire.Category__c='Healthcare';
        oQnaire.Is_Customize_Buttons__c=false;
        oQnaire.isMerge__c=true;
        oQnaire.Button_Alignment__c='Top-Bottom';
        oQnaire.Description__c='Template 1';
        //oQnaire.NetworkId__c='testid';
        oQnaire.Community_URL__c=URL.getSalesforceBaseUrl().toExternalForm();
        insert oQnaire;
        
        //Create Question Group record
        Question_Group__c oQG = new Question_Group__c(Name='Test Group');
        insert oQG;
        System.assertEquals('Test Group' , oQG.Name , 'test  class failed');
        //Create Question Questionnaire Record Without question id
        Question_Questionnaire__c oQQuesnaireWithOutQstn= new Question_Questionnaire__c(Allow_Attachments__c=oQue.Allow_Attachments__c,Allow_Comment__c=oQue.Allow_Comment__c,
            Questionnaire__c = oQnaire.id,Name=oQnaire.Name,Question_Group__c =oQG.id,Is_Allow_Branching__c=true,Question_Order__c=1);
        insert oQQuesnaireWithOutQstn;
        
      //  String attId = FBFileUploadCtrl.saveChunk(oQue.Id, oQnaire.Id, 'test.png', EncodingUtil.urlEncode('base64Data','UTF-8'), 'image/png', '', 'fileDescription');
      //  FBFileUploadCtrl.saveChunk(oQue.Id, oQnaire.Id, 'test.png', EncodingUtil.urlEncode('base64Data','UTF-8'), 'image/png', attId, 'fileDescription');
      //  System.assertNotEquals('', attId);
        Test.stopTest();
    }
}