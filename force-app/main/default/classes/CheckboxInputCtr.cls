/**
 * Created/Modified By: Girikon(Mahesh/Divaker)
 * Created On:          26 Apr 2018
 * Description/Purpose: For Checkbox Input   
 * Test Class:  CheckboxInputCtr_Test
 * Code Coverage: 98%
**/
public with sharing class CheckboxInputCtr{
     /**
      * FLS Check DONE
     * Create question and question questionnaire.
     * @param  qnaireId: Questionnaire id.
     * @param  qGroupId: Question group id.
     * @param  question: Question object values.
     * @param  qnaireName : Questionnaire name.
     * @param  qOrder: Order of question.
     * @param  colNumber: column number of question.
     * @param  questnOptns: Question options of the question.
     */
    @AuraEnabled 
    public static void createQuestnAndQuestnQnaireWithOptions(String qnaireId,String qGroupId,Question__c question,String qnaireName,String qOrder,String colNumber,String questnOptns){
        String sQLib = NewCreateTemplateCtr.getDefaultQuestnLibraryId();
        if(Schema.SObjectType.Question__c.Fields.Name__c.isCreateable()){
            question.Name__c = question.Label__c;    
        }
        if(Schema.SObjectType.Question__c.Fields.Related_To_Column__c.isCreateable()){
            question.Related_To_Column__c = colNumber;
        }

        if(String.isNotBlank( sQLib) && Schema.SObjectType.Question__c.Fields.Question_Library__c.isCreateable()){
            question.Question_Library__c = sQLib; 
        }
        qOrder = String.valueOf(FieldInputCtr.countQuestnQuestnnaireRecord(qnaireId, qGroupId));
        
        if(Schema.SObjectType.Question__c.Fields.Name.isCreateable()){
            question.Name = qOrder;
        }
        if(Schema.SObjectType.Question__c.isCreateable()){
            insert question;
        }

        if(Schema.SObjectType.Question_Questionnaire__c.Fields.Weight__c.isCreateable() && Schema.SObjectType.Question_Questionnaire__c.Fields.Question_Order__c.isCreateable()
            && Schema.SObjectType.Question_Questionnaire__c.Fields.Required__c.isCreateable() && Schema.SObjectType.Question_Questionnaire__c.Fields.Allow_Currency__c.isCreateable() 
            && Schema.SObjectType.Question_Questionnaire__c.Fields.Decimal_value__c.isCreateable()&& Schema.SObjectType.Question_Questionnaire__c.Fields.Related_To_Column__c.isCreateable()
            && Schema.SObjectType.Question_Questionnaire__c.Fields.Help_Text__c.isCreateable() && Schema.SObjectType.Question_Questionnaire__c.Fields.Is_Allow_Branching__c.isCreateable()
            && Schema.SObjectType.Question_Questionnaire__c.Fields.Category__c.isCreateable() && Schema.SObjectType.Question_Questionnaire__c.Fields.Help_Text_Required__c.isCreateable()
            && Schema.SObjectType.Question_Questionnaire__c.Fields.Allow_Attachments__c.isCreateable() && Schema.SObjectType.Question_Questionnaire__c.Fields.Allow_Comment__c.isCreateable()
            && Schema.SObjectType.Question_Questionnaire__c.Fields.Questionnaire__c.isCreateable() && Schema.SObjectType.Question_Questionnaire__c.Fields.Name.isCreateable()
            && Schema.SObjectType.Question_Questionnaire__c.Fields.Question_Group__c.isCreateable() && Schema.SObjectType.Question_Questionnaire__c.Fields.Question__c.isCreateable()
            )
        {
            Question_Questionnaire__c oQQuesnaire= new Question_Questionnaire__c(Weight__c=question.Weight__c,Required__c=question.Required__c,
            Allow_Currency__c =question.Allow_Currency__c,Decimal_value__c =question.Decimal_value__c, Related_To_Column__c=colNumber,
            Help_Text__c=question.Help_Text__c,Help_Text_Required__c=question.Help_Text_Required__c,Category__c=question.Category__c,
            Allow_Attachments__c=question.Allow_Attachments__c,Allow_Comment__c=question.Allow_Comment__c,Questionnaire__c = qnaireId,
            Name=qnaireName,Question_Group__c =qGroupId,Question__c=question.id,Question_Order__c=Integer.valueOf(qOrder),
            Is_Allow_Branching__c =question.Is_Allow_Branching__c);

            oQQuesnaire.Max_Char_Length__c=(question.Max_Char_Length__c != null?question.Max_Char_Length__c:0);

            if(String.isNotBlank(question.Currency_Symbol__c)){
                oQQuesnaire.Currency_Symbol__c=question.Currency_Symbol__c;
            }
            if(Schema.SObjectType.Question_Questionnaire__c.isCreateable()){
                insert oQQuesnaire;    
            }
        }


        List<fieldWrapper> qstnOptnList = (List<fieldWrapper>) JSON.deserialize(questnOptns, List<fieldWrapper>.class);
        List<Question_Option__c> lstQstnOptn=new List<Question_Option__c>();
        Question_Option__c qusthOption;
        for(fieldWrapper wrapper: qstnOptnList){
            qusthOption=new Question_Option__c();
            if(Schema.SObjectType.Question_Option__c.Fields.Name.isCreateable()){
                qusthOption.Name = wrapper.name;
            }
            if(Schema.SObjectType.Question_Option__c.Fields.Name__c.isCreateable()){
                qusthOption.Name__c = wrapper.name;
            }
            if(Schema.SObjectType.Question_Option__c.Fields.Question__c.isCreateable()){
                qusthOption.Question__c = question.id;
            }
            if(String.isNotBlank(wrapper.score) && Schema.SObjectType.Question_Option__c.Fields.Score__c.isCreateable()){
                qusthOption.Score__c = Decimal.ValueOf(wrapper.score);
            }
            if(Schema.SObjectType.Question_Option__c.Fields.Value__c.isCreateable()){
                qusthOption.Value__c = wrapper.alias;
            }
            lstQstnOptn.add(qusthOption);
        }
        if(Schema.SObjectType.Question_Option__c.isCreateable()){
            insert lstQstnOptn;    
        }
    }
    
    //Save question option  when edit question.
    @AuraEnabled
    public static Question__c saveQuestionEditOption(Question__c oQues,String name,String alias,String score){
        Question__c question = new Question__c();
        
        if(Schema.SObjectType.Question_Option__c.isCreateable() && Schema.SObjectType.Question_Option__c.Fields.Question__c.isCreateable() && Schema.SObjectType.Question_Option__c.Fields.Name.isCreateable() &&
            Schema.SObjectType.Question_Option__c.Fields.Name.isCreateable() && Schema.SObjectType.Question_Option__c.Fields.Score__c.isCreateable() && Schema.SObjectType.Question_Option__c.Fields.Value__c.isCreateable())
        {
            Question_Option__c qusthOption=new Question_Option__c();
            if(oQues != null && String.isNotBlank(name)){
                if(String.isNotBlank(score)){
                    qusthOption=new Question_Option__c(Question__c=oQues.id,Name=name,Name__c=name,Score__c=Decimal.ValueOf(score),Value__c=alias);
                }
                else{
                    qusthOption=new Question_Option__c(Question__c=oQues.id,Name=name,Name__c=name,Value__c=alias);
                }
                insert qusthOption;
                question = NewCreateTemplateCtr.getQuesDetail(oQues.id);
            }
        }
        return question ;
    }
    
     /**
     * Delete question option  when edit question.
     * @param  oQues: Question object
     * @param  qstnOptionId: Id of question option.
     * @return : Question record
     */
    @AuraEnabled
    public static Question__c deleteQuestionOptionInEdit(Question__c oQues,String qstnOptionId){
        Question__c question = new Question__c();
        if(oQues!= null && String.isNotBlank(qstnOptionId) && Schema.SObjectType.Question_Option__c.isAccessible() && 
            Schema.SObjectType.Question_Option__c.isDeletable()){
           Question_Option__c qstnOption=[Select Id from Question_Option__c Where Id=:qstnOptionId];
           if(qstnOption!=null){
               delete qstnOption;
           }
           question=NewCreateTemplateCtr.getQuesDetail(oQues.id);
        }
        return question;
    }
    
    /**
     * Edit question option  when edit question.
     * @param  oQues: Question object
     * @param  qstnOptionId: Id of question option.
     * @return : Question record
     */
    @AuraEnabled
    public static Question__c editQuestionOptionInEdit(Question_Option__c oQuesOption,Question__c oQues){
        Question__c question = new Question__c();
        if(oQuesOption != null && oQues!= null){
            if(Schema.SObjectType.Question_Option__c.isUpdateable() && Schema.SObjectType.Question_Option__c.Fields.Name__c.isUpdateable() && Schema.SObjectType.Question_Option__c.Fields.Value__c.isUpdateable()){
                update oQuesOption;    
            }
            if(Schema.SObjectType.Question__c.isAccessible() && Schema.SObjectType.Question__c.Fields.Id.isAccessible()){
                question=NewCreateTemplateCtr.getQuesDetail(oQues.Id);
            }
        }
        return question;
    }
    
     /**
     * save edited Question and Question Questionniare record
     * @param  oQues: Question object values.
     * @param  qnaireId: Question object values.
     * @param  sectionId: Question object values.
     */
    @AuraEnabled
    public static void saveEditQuesRecord(Question__c oQues,String qnaireId,String sectionId,Boolean isUnderBranching) {
        if (oQues != null) 
        {
            if(oQues.Help_Text_Required__c==false){
                oQues.Help_Text__c='';
            }
            if(Schema.SObjectType.Question__c.isUpdateable() && Schema.SObjectType.Question__c.Fields.Help_Text__c.isUpdateable()){
                update oQues;    
            }
            //Id,Allow_Attachments__c,Allow_Comment__c,Help_Text_Required__c,Help_Text__c,Category__c
            if(Schema.SObjectType.Question_Questionnaire__c.isAccessible() && Schema.SObjectType.Question_Questionnaire__c.Fields.Id.isAccessible() &&
                Schema.SObjectType.Question_Questionnaire__c.Fields.Questionnaire__c.isAccessible() && Schema.SObjectType.Question_Questionnaire__c.Fields.Question__c.isAccessible()&&
                Schema.SObjectType.Question_Questionnaire__c.Fields.Question_Group__c.isAccessible() && Schema.SObjectType.Question_Questionnaire__c.Fields.Is_Allow_Branching__c.isAccessible())
            {
                List<Question_Questionnaire__c> lstQQnnaire=[Select Id,Is_Allow_Branching__c from Question_Questionnaire__c where Question__c=:oQues.id and Questionnaire__c=:qnaireId and Question_Group__c=:sectionId];
                if(lstQQnnaire!=null && lstQQnnaire.size()>0)
                {
                    if(Schema.SObjectType.Question_Questionnaire__c.Fields.Allow_Attachments__c.isUpdateable()){
                        lstQQnnaire[0].Allow_Attachments__c=oQues.Allow_Attachments__c;
                    }
                    if(Schema.SObjectType.Question_Questionnaire__c.Fields.Allow_Comment__c.isUpdateable()){
                        lstQQnnaire[0].Allow_Comment__c=oQues.Allow_Comment__c;
                    }
                    if(Schema.SObjectType.Question_Questionnaire__c.Fields.Help_Text_Required__c.isUpdateable()){
                        lstQQnnaire[0].Help_Text_Required__c=oQues.Help_Text_Required__c;
                    }
                    if(Schema.SObjectType.Question_Questionnaire__c.Fields.Help_Text__c.isUpdateable()){
                        lstQQnnaire[0].Help_Text__c='';
                    }
                    if(Schema.SObjectType.Question_Questionnaire__c.Fields.Required__c.isUpdateable()){
                        lstQQnnaire[0].Required__c=oQues.Required__c;
                    }

                    if(oQues.Help_Text_Required__c==true && Schema.SObjectType.Question_Questionnaire__c.Fields.Help_Text__c.isUpdateable()){
                        lstQQnnaire[0].Help_Text__c=oQues.Help_Text__c;
                    }
                    if(Schema.SObjectType.Question_Questionnaire__c.Fields.Is_Allow_Branching__c.isUpdateable()){
                        lstQQnnaire[0].Is_Allow_Branching__c =oQues.Is_Allow_Branching__c;
                    }

                    if(lstQQnnaire[0].Is_Allow_Branching__c==false && isUnderBranching ==false){
                        NewCreateTemplateCtr.delQuestnDynLogic(lstQQnnaire[0].id);
                    }

                    if(String.isNotBlank(oQues.Currency_Symbol__c) && Schema.SObjectType.Question_Questionnaire__c.Fields.Currency_Symbol__c.isUpdateable()){
                        lstQQnnaire[0].Currency_Symbol__c=oQues.Currency_Symbol__c;
                    }
                    if(Schema.SObjectType.Question_Questionnaire__c.Fields.Decimal_value__c.isUpdateable()){
                        lstQQnnaire[0].Decimal_value__c =oQues.Decimal_value__c;    
                    }
                    if(Schema.SObjectType.Question_Questionnaire__c.Fields.Allow_Currency__c.isUpdateable()){
                        lstQQnnaire[0].Allow_Currency__c =oQues.Allow_Currency__c;
                    }
                    if(Schema.SObjectType.Question_Questionnaire__c.Fields.Max_Char_Length__c.isUpdateable()){
                        lstQQnnaire[0].Max_Char_Length__c =(oQues.Max_Char_Length__c != null?oQues.Max_Char_Length__c:0);
                    }
                    if(Schema.SObjectType.Question_Questionnaire__c.Fields.Category__c.isUpdateable()){
                        lstQQnnaire[0].Category__c=oQues.Category__c;
                    }
                    if(Schema.SObjectType.Question_Questionnaire__c.Fields.Weight__c.isUpdateable()){
                        lstQQnnaire[0].Weight__c=oQues.Weight__c;
                    }
                    if(Schema.SObjectType.Question_Questionnaire__c.isUpdateable())
                    {
                        update lstQQnnaire;
                    }
                }
            }
        } 
    }

    /**
     * Wrapper class to read quetion option values.
    */
    public with sharing class fieldWrapper {
        public String name;
        public String alias;
        public String score;
    }
}