/**
 * Created/Modified By: Girikon(Mahesh/Divaker)
 * Created On:          26 Apr 2018
 * Description/Purpose: Using for Create question and question questionnaire.
 * Test Class:   SwitchInputCtrl_Test
 * Code Coverage: 95%
**/
public class SwitchInputCtrl {
    /**
     * Create question and question questionnaire.
     * @param  qnaireId: Questionnaire id.
     * @param  qGroupId: Question group id.
     * @param  question: Question object values.
     * @param  qnaireName : Questionnaire name.
     * @param  qOrder: Order of question.
     * @param  lstQstnOptn: list Question options of the question.
     */
    @AuraEnabled
    public static void createQuestnAndQuestnQnaireWithOptions(String qnaireId, String qGroupId, Question__c question, String qnaireName, String qOrder,
                                                            String colNumber, List<Question_Option__c> lstQstnOptn) 
    {
        String sQLib = NewCreateTemplateCtr.getDefaultQuestnLibraryId();
        if(Schema.sObjectType.Question__c.fields.Name__c.isCreateable())
        {
            question.Name__c = question.Label__c;
        }
          
        if(Schema.sObjectType.Question__c.fields.Related_To_Column__c.isCreateable())
        {
            question.Related_To_Column__c = colNumber;
        }
          
        if (String.isNotBlank( sQLib)) {
            if(Schema.sObjectType.Question__c.fields.Question_Library__c.isCreateable())
            {
                question.Question_Library__c = sQLib;
            }
        }
          
        qOrder = String.valueOf(FieldInputCtr.countQuestnQuestnnaireRecord(qnaireId, qGroupId));
          
        if(Schema.sObjectType.Question__c.fields.Name.isCreateable())
        {
            question.Name = qOrder;
        }
        if(Schema.sObjectType.Question__c.isCreateable())
        {
            insert question;
        }

        Question_Questionnaire__c oQQuesnaire;
          
        if(Schema.sObjectType.Question_Questionnaire__c.fields.Weight__c.isCreateable() && Schema.sObjectType.Question_Questionnaire__c.fields.Required__c.isCreateable()
             && Schema.sObjectType.Question_Questionnaire__c.fields.Allow_Currency__c.isCreateable() && Schema.sObjectType.Question_Questionnaire__c.fields.Decimal_value__c.isCreateable()  
             && Schema.sObjectType.Question_Questionnaire__c.fields.Related_To_Column__c.isCreateable() && Schema.sObjectType.Question_Questionnaire__c.fields.Help_Text__c.isCreateable()
             && Schema.sObjectType.Question_Questionnaire__c.fields.Help_Text_Required__c.isCreateable() && Schema.sObjectType.Question_Questionnaire__c.fields.Category__c.isCreateable()
             && Schema.sObjectType.Question_Questionnaire__c.fields.Allow_Attachments__c.isCreateable() && Schema.sObjectType.Question_Questionnaire__c.fields.Allow_Comment__c.isCreateable()
             && Schema.sObjectType.Question_Questionnaire__c.fields.Questionnaire__c.isCreateable() && Schema.sObjectType.Question_Questionnaire__c.fields.Name.isCreateable()
             && Schema.sObjectType.Question_Questionnaire__c.fields.Question__c.isCreateable() && Schema.sObjectType.Question_Questionnaire__c.fields.Question_Order__c.isCreateable()
             && Schema.sObjectType.Question_Questionnaire__c.fields.Is_Allow_Branching__c.isCreateable() && Schema.sObjectType.Question_Questionnaire__c.fields.Question_Group__c.isCreateable())
        {
            oQQuesnaire = new Question_Questionnaire__c(Weight__c = question.Weight__c, Required__c = question.Required__c,
                                                                                   Allow_Currency__c = question.Allow_Currency__c, Decimal_value__c = question.Decimal_value__c, Related_To_Column__c = colNumber,
                                                                                   Help_Text__c = question.Help_Text__c, Help_Text_Required__c = question.Help_Text_Required__c, Category__c = question.Category__c,
                                                                                   Allow_Attachments__c = question.Allow_Attachments__c, Allow_Comment__c = question.Allow_Comment__c, Questionnaire__c = qnaireId, 
                                                                                   Name = qnaireName, Question_Group__c = qGroupId, Question__c = question.id, Question_Order__c = Integer.valueOf(qOrder),
                                                                                   Is_Allow_Branching__c =question.Is_Allow_Branching__c);
        }
        if(Schema.sObjectType.Question_Questionnaire__c.fields.Max_Char_Length__c.isCreateable())
        {
            oQQuesnaire.Max_Char_Length__c = (question.Max_Char_Length__c != null ? question.Max_Char_Length__c : 0);
        }
        if(Schema.sObjectType.Question_Questionnaire__c.isCreateable())
        {
            insert oQQuesnaire;
        }
          
        for (Question_Option__c questnOptns : lstQstnOptn) 
        {
            if(Schema.sObjectType.Question_Option__c.fields.Question__c.isCreateable())
            {
                questnOptns.Question__c = question.id;
            }
            if(Schema.sObjectType.Question_Option__c.fields.Name__c.isCreateable())
            {
                questnOptns.Name = questnOptns.Name__c;
            }
        }
          
        if (lstQstnOptn != null && lstQstnOptn.size() > 0 && Schema.sObjectType.Question_Questionnaire__c.isCreateable()) 
        {
            insert lstQstnOptn;
        }
    }
 
    /**
     * save edited Question and Question Questionniare record
     * @param  oQues: Question object values.
     * @param  qnaireId: Questionnaire id.
     * @param  sectionId: Question group(Section) Id.
     * @param  lstQstnOptn: list Question options of the question.
     */
    @AuraEnabled
    public static void saveEditQuesRecord(Question__c oQues, String qnaireId, String sectionId, List<Question_Option__c> lstQstnOptn,Boolean isUnderBranching) 
    {
        if (oQues != null) {
            if (oQues.Help_Text_Required__c == false) 
            {
                if(Schema.sObjectType.Question__c.fields.Help_Text__c.isUpdateable())
                { 
                    oQues.Help_Text__c = '';
                }
            }
            if(Schema.sObjectType.Question__c.isUpdateable())
            {
                update oQues;
            }
            List<Question_Questionnaire__c> lstQQnnaire;
      
            if(Schema.sObjectType.Question_Questionnaire__c.isAccessible() && Schema.sObjectType.Question_Questionnaire__c.fields.Id.isAccessible() && Schema.sObjectType.Question_Questionnaire__c.fields.Allow_Attachments__c.isAccessible() 
                && Schema.sObjectType.Question_Questionnaire__c.fields.Allow_Comment__c.isAccessible() && Schema.sObjectType.Question_Questionnaire__c.fields.Weight__c.isAccessible() 
                && Schema.sObjectType.Question_Questionnaire__c.fields.Help_Text_Required__c.isAccessible() && Schema.sObjectType.Question_Questionnaire__c.fields.Help_Text__c.isAccessible() 
                && Schema.sObjectType.Question_Questionnaire__c.fields.Category__c.isAccessible() && Schema.sObjectType.Question_Questionnaire__c.fields.lookup_Object_API_Name__c.isAccessible()
                && Schema.sObjectType.Question_Questionnaire__c.fields.lookup_Object_Field_Name__c.isAccessible()&& Schema.sObjectType.Question_Questionnaire__c.fields.Question__c.isAccessible()
                && Schema.sObjectType.Question_Questionnaire__c.fields.Question_Group__c.isAccessible() && Schema.sObjectType.Question_Questionnaire__c.fields.Questionnaire__c.isAccessible())
            {
                lstQQnnaire = [Select Id, Allow_Attachments__c, Allow_Comment__c,Weight__c,Help_Text_Required__c,Help_Text__c,Category__c,lookup_Object_API_Name__c,
                lookup_Object_Field_Name__c from Question_Questionnaire__c where Question__c = :oQues.id and Questionnaire__c = :qnaireId and Question_Group__c = :sectionId];
            }
      
            if (lstQQnnaire != null && lstQQnnaire.size() > 0)
            {
                if(Schema.sObjectType.Question_Questionnaire__c.fields.Allow_Attachments__c.isUpdateable())
                {
                    lstQQnnaire[0].Allow_Attachments__c = oQues.Allow_Attachments__c;
                }
                if(Schema.sObjectType.Question_Questionnaire__c.fields.Allow_Comment__c.isUpdateable())
                {
                    lstQQnnaire[0].Allow_Comment__c = oQues.Allow_Comment__c;
                }
                if(Schema.sObjectType.Question_Questionnaire__c.fields.Help_Text_Required__c.isUpdateable()){
                    lstQQnnaire[0].Help_Text_Required__c = oQues.Help_Text_Required__c;
                }
                if(Schema.sObjectType.Question_Questionnaire__c.fields.Help_Text__c.isUpdateable())
                {
                    lstQQnnaire[0].Help_Text__c = '';
                }
                if(Schema.sObjectType.Question_Questionnaire__c.fields.Required__c.isUpdateable())
                {
                    lstQQnnaire[0].Required__c = oQues.Required__c;
                }
                if (oQues.Help_Text_Required__c == true && Schema.sObjectType.Question_Questionnaire__c.fields.Help_Text__c.isUpdateable())
                {
                    lstQQnnaire[0].Help_Text__c = oQues.Help_Text__c;
                }
                if(Schema.sObjectType.Question_Questionnaire__c.fields.Is_Allow_Branching__c.isUpdateable())
                {
                    lstQQnnaire[0].Is_Allow_Branching__c =oQues.Is_Allow_Branching__c;
                }
                if(lstQQnnaire[0].Is_Allow_Branching__c==false && isUnderBranching==false){
                    NewCreateTemplateCtr.delQuestnDynLogic(lstQQnnaire[0].id);
                }
                if(oQues.Weight__c!=null){
                    if(Schema.sObjectType.Question_Questionnaire__c.fields.Weight__c.isUpdateable())
                    {
                        lstQQnnaire[0].Weight__c=oQues.Weight__c;
                    }
                }
                if(Schema.sObjectType.Question_Questionnaire__c.fields.Max_Char_Length__c.isUpdateable())
                {
                    lstQQnnaire[0].Max_Char_Length__c = (oQues.Max_Char_Length__c != null ? oQues.Max_Char_Length__c : 0);
                }
                if(Schema.sObjectType.Question_Questionnaire__c.fields.Category__c.isUpdateable())
                {
                    lstQQnnaire[0].Category__c = oQues.Category__c;
                }
                if(Schema.sObjectType.Question_Questionnaire__c.isUpdateable())
                { 
                    update lstQQnnaire;
                }
            }
            if (lstQstnOptn != null && lstQstnOptn.size() > 0 && Schema.sObjectType.Question_Option__c.isUpdateable())
            {
                update lstQstnOptn;
            }
        }
    }
}