/**
* Created/Modified By: Girikon(Mahesh)
* Created On:          30 June 2018
* Description/Purpose: This test class covers the apex class : CloneFormBuilderTemplate
* Apex Class:        CloneFormBuilderTemplate (96%)
**/
@isTest
public class CloneFormBuilderTemplate_Test {
    
    public static testMethod void cloneFormBuilder()
    {
         //Event Edition Creation
        Event_Edition__c eventEdition = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today());
        insert eventEdition;
        System.assertEquals(eventEdition.Event_Code__c,'WOC17', 'Event Code');
        
     
        
        Form__c oForm = new Form__c(Doc_Type__c='Online',Form__c=1,Deadline__c=System.Today());
        insert oForm;
        
        //Create Questionnaire record
        Questionnaire__c oQnaire = new Questionnaire__c();
        oQnaire.Name='Template 1';
        oQnaire.Category__c='Healthcare';
        oQnaire.Description__c='Template 1';
        oQnaire.Community_URL__c=URL.getSalesforceBaseUrl().toExternalForm();
        insert oQnaire;
        List<Questionnaire__c> lstQuQnaire = [Select id,Category__c from Questionnaire__c where id=:oQnaire.id];
        System.assertEquals(oQnaire.Category__c,lstQuQnaire[0].Category__c,'Questionnaire should be inserted');
        
        Event_Edition_Form__c oEEForm = new Event_Edition_Form__c(Event_Edition__c = eventEdition.id,Forms__c =oForm.id,Expocad_Booth_Class__c='', Expocad_Booth_Type__c='', Expocad_Product_Type__c='',
                                                                 Template_Form__c=oQnaire.Id);
        insert oEEForm;
        System.assertEquals(oEEForm.Event_Edition__c,eventEdition.id, 'checking Event Id');
         
         //Create Question Library
        Question_Library__c oQL= new Question_Library__c(Name='Global Default',Name__c='Global Default');
        insert oQL;

        //Create Question Record 
        Question__c oQue = new Question__c(Name='Test',Help_Text_Required__c=true, Name__c='Test 1', Help_Text__c='Test Help Text', Label__c='Question 1', 
            Question_Library__c=oQL.id, Required__c=true, Type__c='TextPlain',Allow_Comment__c=true,Allow_Attachments__c=true);
        insert oQue;
        List<Question__c> lstQutn = [Select id,Type__c from Question__c where id=:oQue.id];
        System.assertEquals(oQue.Type__c,lstQutn[0].Type__c,'Question type should be inserted');
        //create Question Option
        Question_Option__c qOption = new Question_Option__c(Name ='Option 1',Name__c='Option 1',Question__c =oQue.id);
        insert qOption;
        List<Question_Option__c> listQueOptionData  = [Select id,Name__c from Question_Option__c];
        System.assertNotEquals(listQueOptionData,null,'Question Option must not be null');
        System.assertEquals(listQueOptionData.size(),1,'Question Option must not be null');
        //Create Question Group record
        Question_Group__c oQG = new Question_Group__c(Name='Test Group');
        insert oQG;
        List<Question_Group__c> lstQuGroup = [Select id,Name from Question_Group__c where id=:oQG.id];
        System.assertEquals(oQG.Name,lstQuGroup[0].Name,'QuestionGroup name should be inserted');

        //Create Question Questionnaire Record
        List<Question_Questionnaire__c> lstQuestionQnnaireAdd = new List<Question_Questionnaire__c>();
        Question_Questionnaire__c oQQuesnaireMain= new Question_Questionnaire__c(Allow_Attachments__c=oQue.Allow_Attachments__c,
                                                                                 Allow_Comment__c=oQue.Allow_Comment__c,Is_Allow_Branching__c=true,
            Questionnaire__c = oQnaire.id,Name=oQnaire.Name,Question_Group__c =oQG.id,Question__c=oQue.id,Question_Order__c=1 );
       
             insert oQQuesnaireMain;        
        
        //create Questionnaire_Dynamic_Logic record
         List<Questionnaire_Dynamic_Logic__c> lstQDLData = new List<Questionnaire_Dynamic_Logic__c>();
        Questionnaire_Dynamic_Logic__c QuestnDynLogic = new Questionnaire_Dynamic_Logic__c(Question_Questionnaire__c=oQQuesnaireMain.id,Question_Group__c =oQG.id,Question_Option__c=qOption.id,Show_Question_Questionnaire__c=oQQuesnaireMain.id);
        lstQDLData.add(QuestnDynLogic);
        // for insert data
        Questionnaire_Dynamic_Logic__c QuestnDynLogicInsert = new Questionnaire_Dynamic_Logic__c(Question_Questionnaire__c=oQQuesnaireMain.id,Question_Group__c =oQG.id,Question_Option__c=qOption.id,Show_Question_Questionnaire__c=oQQuesnaireMain.id);
        
        lstQDLData.add(QuestnDynLogicInsert);
        System.assertNotEquals(lstQDLData,null,'Questionnaire Dynamic Logic must not be null');
        insert lstQDLData;
        List<Questionnaire_Dynamic_Logic__c> lstQDLogic = [Select id from Questionnaire_Dynamic_Logic__c where Question_Questionnaire__c=:oQQuesnaireMain.id ];
        System.assertNotEquals(lstQDLogic,null,'Questionnaire Dynamic Logic must not be null');
        
       CloneFormBuilderTemplate.formBuilderTemplate(oQnaire.id, oEEForm.Id);
    }
}