/**
 * Created/Modified By: Mahesh (Girikon)
 * Created On:          06/30/2018
 * @description : This test class covers the apex class : QuestionGroupWithQuestionsWrap,NewCreateTemplateCtrl
 * Apex Class:          NewCreateTemplateCtrl(78%),QuestionGroupWithQuestionsWrap(80%)
 * Modification log --
 * Modified By:{Girikon(Mahesh Kumar)[Jira CCEN-577] 2nd Jan 2019},[Aishwarya BK-6779 5 Aug 2020] 
**/
@isTest
public class NewCreateTemplateCtrl_Test {
    static testMethod void createQniareRecordTestMethod(){
           //Create Question Library
        Question_Library__c oQL= new Question_Library__c(Name='Global Default',Name__c='Global Default');
        insert oQL;

        //Create Question Record 
        Question__c oQue = new Question__c(Name='Test',Help_Text_Required__c=true, Name__c='Test 1', Help_Text__c='Test Help Text', Label__c='Question 1', 
            Question_Library__c=oQL.id, Required__c=true, Type__c='TextPlain',Allow_Comment__c=true,Allow_Attachments__c=true);
        //insert oQue;
        
        Question__c oQue3 = new Question__c(Name='Test',Help_Text_Required__c=true, Name__c='Test 1', Help_Text__c='Test Help Text', Label__c='Question 1', 
            Question_Library__c=oQL.id, Required__c=true, Type__c='TextPlain',Allow_Comment__c=true,Allow_Attachments__c=true);
        insert oQue3;
        
        Question__c oQue4 = new Question__c(Name='Test',Help_Text_Required__c=true, Name__c='Test 1', Help_Text__c='Test Help Text', Label__c='Question 1', 
            Question_Library__c=oQL.id, Required__c=true, Type__c='TextPlain',Allow_Comment__c=true,Allow_Attachments__c=true);
        insert oQue4;
        
        Question__c oQue2 = new Question__c(Name='Test', Name__c='Test 1', Help_Text__c='Test Help Text', Label__c='Question 1', 
            Question_Library__c=oQL.id, Required__c=true, Type__c='TextPlain',Allow_Comment__c=true,Allow_Attachments__c=true,Help_Text_Required__c=true, Is_Approve_For_Library__c = false);
        insert oQue2;

        List<Question_Questionnaire__c> lstQue = new List<Question_Questionnaire__c>(); 
        
        List<Question__c> lstQutn = [Select id,Type__c from Question__c where id=:oQue2.id];
        //create Question option record.
        Question_Option__c qOption = new Question_Option__c(Name ='Test',Name__c='test',Score__c=1,Question__c=oQue2.id);
        insert qOption; 
        List<Question_Option__c> lstqOption = [Select id,Score__c from Question_Option__c where Question__c=:oQue.id];
        System.assertNotEquals(lstqOption, null,'should not be null');
        
        
        //Create Questionnaire record
        Questionnaire__c oQnaire = new Questionnaire__c();
        oQnaire.Name='Template 1';
        oQnaire.Category__c='Healthcare';
        oQnaire.Description__c='Template 1';
        oQnaire.Community_URL__c=URL.getSalesforceBaseUrl().toExternalForm();       
        oQnaire.isMerge__c=false;
        insert oQnaire;
        
        //Create Questionnaire record
        Questionnaire__c oQnaire1 = new Questionnaire__c();
        oQnaire1.Name='Template 1';
        oQnaire.Category__c='Healthcare';
        oQnaire1.Description__c='Template 1';
        oQnaire1.Community_URL__c=URL.getSalesforceBaseUrl().toExternalForm();
        oQnaire1.isMerge__c=true;
        insert oQnaire1;
        List<Questionnaire__c> lstQuQnaire = [Select id,Category__c from Questionnaire__c where id=:oQnaire.id];
        System.assertEquals(oQnaire.Category__c,lstQuQnaire[0].Category__c,'should be inserted');

        //Create Question Group record
        
        Question_Group__c oQG = new Question_Group__c(Name='Test Group',No_Of_Columns__c='1');
        insert oQG;

        Question_Group__c oQG1 = new Question_Group__c(Name='Test Group',No_Of_Columns__c='2');
        insert oQG1;

        Question_Group__c oQG2 = new Question_Group__c(Name='Test Group',No_Of_Columns__c='3');
        insert oQG2;
        List<Question_Group__c> lstQuGroup = [Select id,Name from Question_Group__c where id=:oQG.id];
        System.assertEquals(oQG.Name,lstQuGroup[0].Name,'should be inserted');

        //Create Question Questionnaire Record
        Question_Questionnaire__c oQQuesnaire= new Question_Questionnaire__c(Allow_Attachments__c=oQue2.Allow_Attachments__c,Allow_Comment__c=oQue2.Allow_Comment__c,
            Questionnaire__c = oQnaire.id,Name=oQnaire.Name,Question_Group__c =oQG.id,Question__c=oQue2.id,Question_Order__c=1, is_Delete__c=false,Related_To_Column__c='col1');
        insert oQQuesnaire;
        
        Question_Questionnaire__c oQQuesnaire3= new Question_Questionnaire__c(Allow_Attachments__c=oQue2.Allow_Attachments__c,Allow_Comment__c=oQue2.Allow_Comment__c,
            Questionnaire__c = oQnaire.id,Name=oQnaire.Name,Question_Group__c =oQG.id,Question__c=oQue3.id,Question_Order__c=1, is_Delete__c=false,Related_To_Column__c='col1');
        insert oQQuesnaire3;
        
        Question_Questionnaire__c oQQuesnaire4= new Question_Questionnaire__c(Allow_Attachments__c=oQue2.Allow_Attachments__c,Allow_Comment__c=oQue2.Allow_Comment__c,
            Questionnaire__c = oQnaire.id,Name=oQnaire.Name,Question_Group__c =oQG.id,Question__c=oQue3.id,Question_Order__c=1, is_Delete__c=false,Related_To_Column__c='col1');
        insert oQQuesnaire4;
        
         Question_Questionnaire__c oQQuesnaire1= new Question_Questionnaire__c(Allow_Attachments__c=oQue2.Allow_Attachments__c,Allow_Comment__c=oQue2.Allow_Comment__c,
            Questionnaire__c = oQnaire1.id,Name=oQnaire.Name,Question_Group__c =oQG1.id,Question__c=oQue2.id,Question_Order__c=1, is_Delete__c=false,Related_To_Column__c='col2');
        insert oQQuesnaire1;
        lstQue.add(oQQuesnaire);
        List<Question_Questionnaire__c> lstQuestionQnnaire = [Select id,Question__c from Question_Questionnaire__c where id=:oQQuesnaire.id];
        System.assertEquals(oQQuesnaire.Question__c,lstQuestionQnnaire[0].Question__c,'should be inserted');

        
        
        account acc = new account(Name='TestLName');
        insert acc;
        System.AssertNotEquals(acc, null,'Account should not be null');
        
        account acc1 = new account(Name='TestLName2');
        insert acc1;
        System.AssertNotEquals(acc1, null,'Account should not be null');
        
        Contact con = new Contact(LastName='User',FirstName ='Test', AccountId = acc.id);
        insert con;
        System.AssertNotEquals(con, null,'Contact should not be null');
        
        Contact con2 = new Contact(LastName='User',FirstName ='Test2', AccountId = acc.id);
        insert con2;
        System.AssertNotEquals(con2, null,'Contact should not be null');
        
        String commUsrProfile;
        If(Label.Community_User_Profile!= NULL)
        {
            commUsrProfile= Label.Community_User_Profile;
        }  
        else
        {
            commUsrProfile='Customer Community Login User Custom';
        }
        //Fetch community user profile
        Profile p = [SELECT Id FROM Profile WHERE Name=:commUsrProfile]; 
        User u = new User(Alias = 'cUser', Email='comm.user@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Kumar', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id, ContactId=con.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='comm.user@test.org.comuser');        
        insert u;
                
        Profile pAdmin = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u1 = new User(Alias = 'cUser', Email='admin.user@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Kumar', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = pAdmin.Id, //UserInfo.getprofileId(),
                          TimeZoneSidKey='America/Los_Angeles', UserName='admin.user@test.org.comuser');        
        insert u1;
        
        Event_Edition__c eventEdition1 = new Event_Edition__c(Name='TOC 2018',Event_Code__c='TOC18',Event_Currency__c='USD',End_Date__c=System.Today(),Start_Date__c=System.Today());
        eventEdition1.Event_Edition_Code__c = 'Test1';
        insert eventEdition1;
        System.assertEquals(eventEdition1.Event_Code__c,'TOC18', 'Event Code');
        
        //Event Edition Creation
        Event_Edition__c eventEdition = new Event_Edition__c(Name='World of Concrete 2017',Event_Currency__c='USD',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today());
        eventEdition.Event_Edition_Code__c = 'Test2';
        insert eventEdition;
        System.assertEquals(eventEdition.Event_Code__c,'WOC17', 'Event Code');

        system.runAs(u)
        {
         
        // This code runs as the system user
        User_Type__c uType = new User_Type__c(Name ='Agent');
        insert uType;
        System.AssertEquals(uType.Name, 'Agent','user type should be equal');
            
        User_Type__c uType1 = new User_Type__c(Name ='Exhibitor');
        insert uType1;
        System.AssertEquals(uType1.Name, 'Exhibitor','user type should be equal');
        
        
        
        ContactEventEditionMapping__c cEEMNew = new ContactEventEditionMapping__c(SFEventEditionID__c=eventEdition1.Id, SFContactID__c=con.Id, User_Type__c=uType1.Id);
        insert cEEMNew;
        system.debug('cEEMNew=='+cEEMNew); 
        set<Id> setCEEMNew = new set<Id>();
        setCEEMNew.add(CEEMNew.SFContactID__c);
        
 
        Form__c oForm = new Form__c(Doc_Type__c='Online',Form__c=1,Deadline__c=System.Today(),Template_Form_Name__c=oQnaire.id);
        insert oForm;
        
        Event_Edition_Form__c oEEForm = new Event_Edition_Form__c(Event_Edition__c = eventEdition.id,Forms__c =oForm.id,Expocad_Booth_Class__c='', Expocad_Booth_Type__c='', Expocad_Product_Type__c='',Template_Form__c=oQnaire.id);
        insert oEEForm;
        System.assertEquals(oEEForm.Event_Edition__c,eventEdition.id, 'checking Event Id');
        
        Forms_Permission__c fPermission = new Forms_Permission__c(Event_Edition_Form__c = oEEForm.id, User_Type__c= uType1.Id);
        insert fPermission;
        System.assertEquals(fPermission.Event_Edition_Form__c,oEEForm.id, 'checking Event_Edition_Form Id');

        User_Form_Action__c oUserAction = new User_Form_Action__c(Form_Permission__c=fPermission.id,Account__c=CEEMNew.SFContactID__r.AccountId,User_Type__c=CEEMNew.User_Type__c);
        insert oUserAction;
        System.assertNotEquals(null, oUserAction,'');
            
            
        Test.startTest();
            Question_Response__c qr = new Question_Response__c();
            qr.Answer__c='test';
            qr.Comment__c='sdsf';
            qr.Question__c=oQue4.Id;
            qr.Questionnaire__c =oQnaire.Id;
            qr.User__c=u.Id;
            qr.Question_Questionnaire__c=oQQuesnaire4.Id;
            insert qr;
            string jSone = '[{"Id":"'+qr.Id+'","Question_Questionnairesr":[{"responseValue2":null,"responseValue1":"sass","Question":"'+oQue4.Id+'","Id":"'+oQQuesnaire4.Id+'","comment":null,"branchingQuestnQuetnnaire":null}]},{"Question_Questionnairesr":[{"responseValue2":null,"responseValue1":"gasjdsja","Question":"'+oQue2.Id+'","Id":"'+oQQuesnaire1.Id+'","comment":null,"branchingQuestnQuetnnaire":[{"Question":"'+oQue3.Id+'","Id":"","Metadata":"#f9f9f9","Allow_Currency":false,"Max_Char_Length":0,"Allow_Attachments":false,"Allow_Comment":false,"Help_Text_Required":false,"Is_Weight_Required":false,"Is_Score_Required":false,"Related_To_Column":"col1","Required":false,"Step_Size":0,"Is_Allow_Branching":false,"Maximum_value":0,"Weight":1,"Question_Order":1,"Questionr":{"Label":"test1"}}]}]}]';
            NewCreateTemplateCtr.getQuestnsForQuesGroup(oQnaire.id,oQG.id);
            NewCreateTemplateCtr.getQuestnsForQuesGroup(oQnaire.id,oQG1.id);
            NewCreateTemplateCtr.SelectApprovedStatus(oQnaire.id,acc.id);
            NewCreateTemplateCtr.isMergeSection(oQnaire.id);
            NewCreateTemplateCtr.getQuestnsForAllQuesGroup(oQnaire.id,oQG.id);
            NewCreateTemplateCtr.getQuestnsForQuesGroup2(oQnaire.id,oQG2.id);
            NewCreateTemplateCtr.getQuestnsForQuesGroup2(oQnaire1.id,oQG2.id);
            //NewCreateTemplateCtr.saveEmpatyResponse(oQnaire.id);
            NewCreateTemplateCtr.getTemplateRecord(oQnaire.id);
            NewCreateTemplateCtr.getTemplateName(oQnaire.id);
            NewCreateTemplateCtr.getAllQuestnGrpNameForQuesnnaire(oQnaire.id);
            NewCreateTemplateCtr.getQueCategory();
            NewCreateTemplateCtr.BackButtonRender();
            NewCreateTemplateCtr.createQuestnAndQuestnQnaire(oQnaire.id,oQG.id,oQue,'TestQuestion','1','1');
            NewCreateTemplateCtr.delQuestion(oQQuesnaire.Id);
            NewCreateTemplateCtr.delQuestnDynLogic(oQQuesnaire.Id);
            NewCreateTemplateCtr.getQuesDetail(oQue2.Id);
            NewCreateTemplateCtr.saveEditQuesRecord(oQue);
            NewCreateTemplateCtr.getDefaultQuestnLibraryId();
            NewCreateTemplateCtr.createSection('test',oQnaire.id,'1');
            NewCreateTemplateCtr.deleteSectionWithQuestionsAndQstnQustnry(oQG.id,oQnaire.id);
            NewCreateTemplateCtr.getScoreAndWeight(oQue2.id);
            NewCreateTemplateCtr.getBranchingQuestn(oQG.id);
            NewCreateTemplateCtr.setpublishStatusOnTemplate(oQnaire.id);
            NewCreateTemplateCtr.updateColumn(oQQuesnaire.id,oQue2.id,'1',oQG.id);
            NewCreateTemplateCtr.setQuestnQnniareOrder(lstQue);
            NewCreateTemplateCtr.saveQuestionResponse(jSone,oQnaire.id,eventEdition1.id,acc.id);
            
            NewCreateTemplateCtr.getQuestionResponses(oQnaire.id,oQG.id,acc.id);
            NewCreateTemplateCtr.getQuestionResponses(oQnaire.id,oQG.id,acc.id);  
            NewCreateTemplateCtr.getQuestionResponses(oQnaire.id,oQG.id,'');
            NewCreateTemplateCtr.getQuestionResponses(oQnaire.id,'',acc.id);
            List<String> lstCategoris =NewCreateTemplateCtr.getQueCategory();
            System.assert(lstCategoris.size()>0,'exist Categories');

            Question__c questn =NewCreateTemplateCtr.getQuesDetail(oQue.id);
            System.assertEquals(questn.id,oQue.id,'Fetching id should be matched');

            String sDefaultLib =NewCreateTemplateCtr.getDefaultQuestnLibraryId();
            System.assert(sDefaultLib != null,'exist Default Library Id');
            List<Question_Library__c> lstQuestnLib = [Select id from Question_Library__c where Name='Global Default'];
            System.assert(lstQuestnLib != null,'exist Default Library');
            System.assertEquals(lstQuestnLib[0].id,sDefaultLib,'should be inserted');

            NewCreateTemplateCtr.saveEditQuesRecord(oQue);
            List<Question__c> lstQuestion = [Select id,Allow_Comment__c from Question__c where id=: oQue.id];
            System.assertNotEquals(lstQuestion,null,'should not be null');
            System.assertEquals(lstQuestion[0].Allow_Comment__c,true,false);

            Integer countQuestnQnaireResult = [Select count() from Question_Questionnaire__c where Questionnaire__c =:oQnaire.id and Question_Group__c=:oQG.id];
            System.assertNotEquals(countQuestnQnaireResult,null,'should not be null');
            //Added this for [CCEN-577]
            String templateName =NewCreateTemplateCtr.getTemplateName(oQnaire.id);
            System.assertNotEquals(templateName,null,'should not be null');

            String questionnaireName = [Select Name from Questionnaire__c where id=:oQnaire.id].Name;
            System.assertNotEquals(questionnaireName,null,'should not be null');
            System.assertEquals(questionnaireName,templateName,'Fetched data should be matched');

            List<Question_Questionnaire__c> lstQuesQnaire =NewCreateTemplateCtr.getAllQuestnGrpNameForQuesnnaire(oQnaire.id);
            System.assertNotEquals(lstQuesQnaire,null,'should not be null');
            Integer countQutnQnaireResult = [Select count() from Question_Questionnaire__c where Questionnaire__c=:oQnaire.id and Question__c = null];
            System.assertNotEquals(countQutnQnaireResult,null,'should not be null');

            List<Question_Questionnaire__c> lstQuesQnaireResult = [Select id from Question_Questionnaire__c where Questionnaire__c=:oQnaire.id 
            and Question_Group__c =: oQG.id ]; 
            System.assertNotEquals(lstQuesQnaireResult,null,'should not be null');
            System.assertNotEquals(lstQuesQnaireResult.size(),0,'');
            
            NewCreateTemplateCtr.delQuestion(oQQuesnaire.id);
            List<Question_Questionnaire__c> lstQuesQuestnnaireResult = [Select id from Question_Questionnaire__c where id=:oQQuesnaire.id and is_delete__c =true];
            System.assertNotEquals(lstQuesQuestnnaireResult,null,'should not be null');
            System.assertEquals(lstQuesQuestnnaireResult.size(),1,0);

            NewCreateTemplateCtr.createSection('Test Group1',oQnaire.id,'4');
            String groupName = [Select Name from Question_Group__c where Name='Test Group1'].Name ;
            System.assertNotEquals(groupName,null,'should not be null');
            System.assertEquals(groupName,'Test Group1','group name should be equal');
        
            Questionnaire__c questnRueslt=NewCreateTemplateCtr.getTemplateRecord(oQnaire.id);
            System.assertNotEquals(questnRueslt,null,'should not be null');
            System.assertEquals(questnRueslt.Name,'Template 1','should be inserted');
        
            List<Question_Option__c> lstScoreAndWeight =NewCreateTemplateCtr.getScoreAndWeight(oQue.id);
            System.assertNotEquals(lstScoreAndWeight, null,'should not be null');
            NewCreateTemplateCtr.setpublishStatusOnTemplate(oQnaire.id);
            List<Questionnaire__c> lstQuQnaireResult = [Select id,Category__c from Questionnaire__c where id=:oQnaire.id and is_Published__c =true];
            System.assertNotEquals(lstQuQnaireResult, null,'should not be null');
            List<Question_Group__c> lstQuestnGroup =[Select id,is_Delete__c from Question_Group__c where id=:oQG.id ];
            System.assertNotEquals(lstQuestnGroup,null,'should not be null');
            System.assertEquals(lstQuestnGroup[0].is_Delete__c,true,false);
            Test.stopTest();
        }
        
    }
    
    
    static testMethod void createBranchingRecordTestMethod(){
        //Create Question Library
        Question_Library__c oQL= new Question_Library__c(Name='Global Default',Name__c='Global Default');
        insert oQL;

        //Create Question Record 
        Question__c oQue = new Question__c(Name='Test',Help_Text_Required__c=true, Name__c='Test 1', Help_Text__c='Test Help Text', Label__c='Question 1', 
            Question_Library__c=oQL.id, Required__c=true, Type__c='TextPlain',Allow_Comment__c=true,Allow_Attachments__c=true);
        insert oQue;
        List<Question__c> lstQutn = [Select id,Type__c from Question__c where id=:oQue.id];
        System.assertEquals(oQue.Type__c,lstQutn[0].Type__c,'Fetched data should be matched');
        //create Question Option
        Question_Option__c qOption = new Question_Option__c(Name ='Option 1',Name__c='Option 1',Question__c =oQue.id);
        insert qOption;
        List<Question_Option__c> listQueOptionData  = [Select id,Name__c from Question_Option__c];
        System.assertNotEquals(listQueOptionData,null,'should not be null');
        System.assertEquals(listQueOptionData.size(),1,'');
        //Create Questionnaire record
        Questionnaire__c oQnaire = new Questionnaire__c();
        oQnaire.Name='Template 1';
        oQnaire.Category__c='Healthcare';
        oQnaire.Description__c='Template 1';
        oQnaire.Community_URL__c=URL.getSalesforceBaseUrl().toExternalForm();
        insert oQnaire;
        String questionnaireId = oQnaire.Id;
        List<Questionnaire__c> lstQuQnaire = [Select id,Category__c from Questionnaire__c where id=:oQnaire.id];
        System.assertEquals(oQnaire.Category__c,lstQuQnaire[0].Category__c,'');
        //Create Question Group record
        Question_Group__c oQG = new Question_Group__c(Name='Test Group');
        insert oQG;
        List<Question_Group__c> lstQuGroup = [Select id,Name from Question_Group__c where id=:oQG.id];
        System.assertEquals(oQG.Name,lstQuGroup[0].Name,'');
        
        //create Question Response   
        Question_Response__c   qResponce = new Question_Response__c(Answer__c='test',Questionnaire__c=oQnaire.id);
        insert qResponce;
        
        //Create Question Questionnaire Record
        List<Question_Questionnaire__c> lstQuestionQnnaireAdd = new List<Question_Questionnaire__c>();
        Question_Questionnaire__c oQQuesnaireMain= new Question_Questionnaire__c(Allow_Attachments__c=oQue.Allow_Attachments__c,Allow_Comment__c=oQue.Allow_Comment__c,
            Questionnaire__c = oQnaire.id,Name=oQnaire.Name,Question_Group__c =oQG.id,Question__c=oQue.id,Question_Order__c=1);
        lstQuestionQnnaireAdd.add(oQQuesnaireMain);

        Question_Questionnaire__c oQQuesnaireBranching= new Question_Questionnaire__c(Allow_Attachments__c=oQue.Allow_Attachments__c,Allow_Comment__c=oQue.Allow_Comment__c,
            Questionnaire__c = oQnaire.id,Name=oQnaire.Name,Question_Group__c =oQG.id,Question__c=oQue.id,Question_Order__c=2);
        lstQuestionQnnaireAdd.add(oQQuesnaireBranching);
        Question_Questionnaire__c oQQuesnaireBranchingSecond= new Question_Questionnaire__c(Allow_Attachments__c=oQue.Allow_Attachments__c,Allow_Comment__c=oQue.Allow_Comment__c,
            Questionnaire__c = oQnaire.id,Name=oQnaire.Name,Question_Group__c =oQG.id,Question__c=oQue.id,Question_Order__c=2);
        lstQuestionQnnaireAdd.add(oQQuesnaireBranchingSecond);
        insert lstQuestionQnnaireAdd;
        System.assertNotEquals(lstQuestionQnnaireAdd,null,'should not be null');
        List<Question_Questionnaire__c> lstQuestionQnnaire = [Select id,Question__c from Question_Questionnaire__c where id=:lstQuestionQnnaireAdd[0].id];
        System.assertEquals(lstQuestionQnnaireAdd[0].Question__c,lstQuestionQnnaire[0].Question__c,'');
        
        //create Questionnaire_Dynamic_Logic record
        Questionnaire_Dynamic_Logic__c questnDynLogic = new Questionnaire_Dynamic_Logic__c(Question_Questionnaire__c=oQQuesnaireMain.id,Question_Group__c =oQG.id,Question_Option__c=qOption.id,Show_Question_Questionnaire__c=lstQuestionQnnaireAdd[1].id);
        insert questnDynLogic;
        // for insert data
        Questionnaire_Dynamic_Logic__c questnDynLogicInsert = new Questionnaire_Dynamic_Logic__c(Question_Questionnaire__c=oQQuesnaireMain.id,Question_Group__c =oQG.id,Question_Option__c=qOption.id,Show_Question_Questionnaire__c=lstQuestionQnnaireAdd[1].id);
        List<Questionnaire_Dynamic_Logic__c> lstQDLData = new List<Questionnaire_Dynamic_Logic__c>();
        lstQDLData.add(questnDynLogicInsert);
        System.assertNotEquals(lstQDLData,null,'should not be null');
        List<Questionnaire_Dynamic_Logic__c> lstQDLogic = [Select id from Questionnaire_Dynamic_Logic__c where Question_Questionnaire__c=:lstQuestionQnnaireAdd[0].id and Question_Group__c =:oQG.id and Question_Option__c=:qOption.id];
        System.assertNotEquals(lstQDLogic,null,'should not be null');
        System.assertEquals(lstQDLogic.size(),1,0);
        
        
        Test.startTest();
            List<Questionnaire_Dynamic_Logic__c> lstBranchingQuestn =NewCreateTemplateCtr.getBranchingQuestn(oQG.id);
            System.assertNotEquals(lstBranchingQuestn, null,'should not be null');
            System.assertEquals(lstBranchingQuestn.size(),1,0);
            for(Question_Questionnaire__c obj : lstQuestionQnnaireAdd){
                obj.question_order__c = 1;
            }
            NewCreateTemplateCtr.updateColumn(oQQuesnaireMain.id,oQue.id,'1',oQG.id);
        Test.stopTest();
        List<string> lst=new List<string>();
        
        NewCreateTemplateCtr.getFormName(questionnaireId);
    }
    
    public static testMethod void testMethod3(){
        Profile pAdmin = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u1 = new User(Alias = 'cUser', Email='admin.user@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Kumar', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = pAdmin.Id, //UserInfo.getprofileId(),
                          TimeZoneSidKey='America/Los_Angeles', UserName='admin.user@test.org.comuser');        
        insert u1;
        System.assertEquals(u1.Email, 'admin.user@testorg.com','should be same');
        string questionnaireId ='';
        String sectionName ='Default';
        String columnNumber ='ab';
        system.runAs(u1)
        {
        Test.startTest();
            Question__c ques;
            Question_Library__c quesLib = new Question_Library__c();
            quesLib.Name ='TestQuestion1';
            quesLib.Name__c = 'Global Default';
            insert quesLib;
            NewCreateTemplateCtr.BackButtonRender();
            NewCreateTemplateCtr.getTemplateRecord(questionnaireId);
            NewCreateTemplateCtr.getQuesDetail(questionnaireId);
            NewCreateTemplateCtr.saveEditQuesRecord(ques);
            NewCreateTemplateCtr.getDefaultQuestnLibraryId();
            NewCreateTemplateCtr.createSection(sectionName,questionnaireId,columnNumber);
        Test.stopTest();
        }
    }
    
}