/**
 * Created On                :     06/30/2018
 * @description              :     This test class covers the apex class : FormPreviewOpsAdminctr/FormReportCtrl
 * Apex Class                :     FormPreviewOpsAdminctr(100%)/FormReportCtrl(78%)

 Created/Modified By       :     Mahesh Gupta , [Aishwarya 3
   **/                                              
@isTest
public class FormReportCtrl_Test {
    
 static testMethod void createFormRecordTestMethod(){
  
        //account created 
        account acc = new account(Name='TestLName');
        insert acc;
        System.AssertNotEquals(acc, null,'account should not be null');
        
        account acc2 = new account(Name='TestAccount');
        insert acc2;
        System.AssertNotEquals(acc2, null,'account should not be null');
     
        //Create contact
        Contact con = new Contact(LastName='User',FirstName ='Test',email='test1@test.com',AccountId = acc.id);
        insert con;
        System.AssertNotEquals(con, null,'Contact should not be null');
        set<Id> conIds = new set<Id>();
        conIds.add(con.id);  
         
        Contact con2 = new Contact(LastName='User2',FirstName ='Test2',email='test2@test.com',AccountId = acc2.id);
        insert con2;
        System.AssertNotEquals(con2, null,'Contact should not be null');
         
        //Create user
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User Custom'].Id;
        
        User usr = new User();
        usr.FirstName = 'Sunil';
        usr.LastName = 'Bajoliya';
        usr.Email = 'test@wexeurope.com';
        usr.Username = 'astest@wexeurope.com';
        usr.Alias = 'astest';
        usr.ProfileId = profileId;
        usr.TimeZoneSidKey    = 'America/Denver';
        usr.LocaleSidKey      = 'en_US';
        usr.EmailEncodingKey  = 'UTF-8';
        usr.LanguageLocaleKey = 'en_US';
        usr.ContactId=con.id;
        //usr.AccountId=acc.id;
        insert usr;
        System.AssertNotEquals(usr, null,'user Not equal null');
     
        //Create Question Library
        Question_Library__c oQesLib= new Question_Library__c(Name='Global Default',Name__c='Global Default');
        insert oQesLib;
        
        //Create Question Record 
        Question__c oQue = new Question__c(Name='Test',lookup_Object_API_Name__c='Account',lookup_Object_Field_Name__c='Name',Currency_Symbol__c='$',Help_Text_Required__c=true, Name__c='Test 1', Help_Text__c='Test Help Text', Label__c='Question 1', 
                                           Question_Library__c=oQesLib.id, Required__c=true, Type__c='TextPlain',Allow_Comment__c=true,Allow_Attachments__c=true);
        insert oQue;
        List<Question__c> lstQutn = [Select id,Type__c from Question__c where id=:oQue.id];
        System.assertEquals(oQue.Type__c, lstQutn[0].Type__c, 'question not equal null ');
        
        //Create Questionnaire record
        Questionnaire__c oQnaire = new Questionnaire__c();
        oQnaire.Name='Template 1';
        oQnaire.Category__c='Healthcare';
        oQnaire.Description__c='Template 1';
        oQnaire.Community_URL__c=URL.getSalesforceBaseUrl().toExternalForm();
        insert oQnaire;
        List<Questionnaire__c> lstQuQnaire = [Select id,Category__c from Questionnaire__c where id=:oQnaire.id];
        System.assertEquals(oQnaire.Category__c,lstQuQnaire[0].Category__c,'Questionnaire not equal null');
     
        //Create Question Group record
        Question_Group__c oQG = new Question_Group__c(Name='Test Group');
        insert oQG;
        List<Question_Group__c> lstQuGroup = [Select id,Name from Question_Group__c where id=:oQG.id];
        System.assertEquals(oQG.Name,lstQuGroup[0].Name,'question Group Not equal null');
        
        
        //Create Question Questionnaire Record
        Question_Questionnaire__c oQQuesnaire= new Question_Questionnaire__c(Allow_Attachments__c=oQue.Allow_Attachments__c,Allow_Comment__c=oQue.Allow_Comment__c,
                                                                             Questionnaire__c = oQnaire.id,Name=oQnaire.Name,Question_Group__c =oQG.id,Question__c=oQue.id,Question_Order__c=1,lookup_Object_API_Name__c='Account',lookup_Object_Field_Name__c='Name');
        insert oQQuesnaire;
        
        List<Question_Questionnaire__c> lstQuestionQnnaire = [Select id,Question__c from Question_Questionnaire__c where id=:oQQuesnaire.id AND Questionnaire__c=:oQnaire.Id AND is_Delete__c=false AND Question__r.Type__c!='Information' AND Question__r.Type__c!='Media' AND Question__r.Type__c!='Signature' AND 
                                                                              Question__r.Type__c!='Header/Footer' AND Question__c!=null ];
        System.assertEquals(oQQuesnaire.Question__c,lstQuestionQnnaire[0].Question__c,'Questionarrie not equal to null');
        //setup New Question Record 
        Question__c createNewQuestion = new Question__c(Name='Test',Currency_Symbol__c='$', Name__c='Test 1', Help_Text__c='Test Help Text', Label__c='Question 1', 
                                                        Question_Library__c=oQesLib.id, Required__c=true, Type__c='TextPlain',Allow_Comment__c=true,Allow_Attachments__c=true,lookup_Object_API_Name__c='Account',lookup_Object_Field_Name__c='Name');
    
       //Create Question Response Record 
       Questionnaire_Form__c createNewQuestionnForm = new Questionnaire_Form__c(Assigned_Date__c=System.today() + 5,Completed_Date__c=System.today() + 5,Expiration_Date__c=System.today() + 5,
                                                                               Questionnaire__c=oQnaire.Id,User__c=usr.id);
     
       insert createNewQuestionnForm;
       //Create Question Response Record 
       Question_Response__c createNewQuestionRes = new Question_Response__c(Answer__c='Answer',Question__c=oQue.id,Questionnaire__c=oQnaire.Id, Questionnaire_Form__c=createNewQuestionnForm.id, Question_Questionnaire__c
                                                                           =oQQuesnaire.id,User__c=usr.Id);
       insert createNewQuestionRes;
       List<Question_Response__c> listQuesResp = new List<Question_Response__c>();
       listQuesResp = [Select User__r.AccountId FROM Question_Response__c where Id =:createNewQuestionRes.Id LIMIT 1];
       
       Account accountId= new Account();
       //accountId = createNewQuestionRes.User__r.AccountId;
     
        //create Event_Edition__c
        List<Event_Edition__c> lstEE = new List<Event_Edition__c>();
        for(Integer i=0;i<3;i++)
        {
            Event_Edition__c ee = new Event_Edition__c(Name='TestName'+i,Event_Currency__c='USD',Event_Code__c='tocesb');
            lstEE.add(ee);  
        }
        insert lstEE;
        system.debug('=======================USERACCOUNT'+listQuesResp[0].User__r.AccountId);
        //create Opportunity
        Opportunity oOpportunity = new Opportunity( Name = 'Expocad Opportunity', CloseDate = Date.today().addDays(7), StageName = 'Closed Won', EventEdition__c = lstEE[0].Id, AccountId =listQuesResp[0].User__r.AccountId,Partner_Account__c=acc2.Id);//Billing_Contact__c = con2.Id
        insert oOpportunity;
        
        //Insert Quote
        SBQQ__Quote__c oQuote = new SBQQ__Quote__c(SBQQ__Status__c = 'Quote Sent', SBQQ__Type__c = 'Quote', SBQQ__Account__c =acc.Id, CurrencyIsoCode = 'USD', SBQQ__Primary__c = true);
        insert oQuote;
     
        //create ExpocadBooth__c
        ExpocadBooth__c expoBooth = new ExpocadBooth__c(Booth_Number__c='TestBoothNo.',Opportunity__c = oOpportunity.Id ,Matched_Product_Name__c ='Space Only', Status__c = 'Rented',Booth_Product_Type_EE__c='Test1',Booth_Type__c='BoothTest',Booth_Classes__c='test');
        insert expoBooth; 
        System.debug('expoBooth ' +expoBooth);
        
        Opportunity_ExpoCAD_Booth_Mapping__c ebm = new Opportunity_ExpoCAD_Booth_Mapping__c();
        ebm.Expocad_Booth__c =expoBooth.id;
        ebm.Display_Name__c = 'Test';
        ebm.quote__c = oQuote.id;
        ebm.Opportunity__c = oOpportunity.id;
        //ebm.Related_Opportunity__c = null;
        ebm.Status__c ='Active';
        insert ebm;
        //system.debug('###################'+ebm);
        
        /** Data set up for ConnectApi **/
         ConnectApi.Community com = new ConnectApi.Community();
         com.url = '';
     
        Test.startTest();   
         PageReference pageRef = Page.FormPreviewOpsAdmin; 
         pageRef.getParameters().put('id',oQnaire.Id);
         Test.setCurrentPage(pageRef);
     
         FormPreviewOpsAdminctr previewControllerac = new FormPreviewOpsAdminctr();
     
         PageReference pageRefacc = Page.FormPreviewOpsAdmin; 
         pageRefacc.getParameters().put('AccId',acc.Id);
         Test.setCurrentPage(pageRefacc);
     
         FormPreviewOpsAdminctr previewController = new FormPreviewOpsAdminctr();
         
         PageReference pageRefr = Page.FormReport; 
         pageRefr.getParameters().put('formId',oQnaire.Id);
         pageRefr.getparameters().put('EveId' , lstEE[0].Event_Code__c);
         Test.setCurrentPage(pageRefr);
         FormReportCtrl controller = new FormReportCtrl();
         FormReportController.searchForm(10,10,'test');
      Test.stopTest();
    }
    
}