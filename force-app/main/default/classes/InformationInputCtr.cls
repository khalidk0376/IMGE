/**
 * Created/Modified By: Girikon(Mahesh/Divaker)
 * Created On:          26 Apr 2018
 * Description/Purpose: Using for create Questions and  Questions Questinnary 
 * Test Class:  InformationInputCtr_Test
 * Code Coverage: 97%
**/
public class InformationInputCtr{
    /**
     * Create question and question questionnaire.
     * @param  qnaireId: Questionnaire id.
     * @param  qGroupId: Question group id.
     * @param  question: Question object values.
     * @param  qnaireName : Questionnaire name.
     * @param  qOrder: Order of question.
     * @param  colNumber: column number of question.
     */
    @AuraEnabled
    public static void createQuestnAndQuestnQnaire(String qnaireId,String qGroupId,Question__c question,String qnaireName,String qOrder,String colNumber,String colorCode,String textColor){
        String sQLib = NewCreateTemplateCtr.getDefaultQuestnLibraryId();
        question.Related_To_Column__c = colNumber;
        if(String.isNotBlank( sQLib)){
            question.Question_Library__c = sQLib; 
            question.Metadata__c=colorCode;
            question.background_Color__c = textColor;
        }
        System.debug(textColor);
        qOrder = String.valueOf(FieldInputCtr.countQuestnQuestnnaireRecord(qnaireId, qGroupId));
        question.Name = qOrder;
        insert question;
        Question_Questionnaire__c oQQuesnaire= new Question_Questionnaire__c(Metadata__c=colorCode,Required__c=question.Required__c,Allow_Currency__c =question.Allow_Currency__c,Decimal_value__c =question.Decimal_value__c,Related_To_Column__c=colNumber,Help_Text__c=question.Help_Text__c,Help_Text_Required__c=question.Help_Text_Required__c,Category__c=question.Category__c,Allow_Attachments__c=question.Allow_Attachments__c,Allow_Comment__c=question.Allow_Comment__c,Questionnaire__c = qnaireId,Name=qnaireName,Question_Group__c =qGroupId,Question__c=question.id,Question_Order__c=Integer.valueOf(qOrder));
        oQQuesnaire.Max_Char_Length__c=(question.Max_Char_Length__c != null?question.Max_Char_Length__c:0);
        if(String.isNotBlank(question.Currency_Symbol__c)){
            oQQuesnaire.Currency_Symbol__c=question.Currency_Symbol__c;
        }
        
        insert oQQuesnaire;
    }
    /**
     * save edited Question and Question Questionniare record
     * @param  oQues: Question object values.
     * @param  qnaireId: Questionnaire id.
     * @param  sectionId: Question group(Section) Id.
     */
    @AuraEnabled
    public static void saveEditQuesRecord(Question__c oQues,String qnaireId,String sectionId) {
        if (oQues != null) 
        {
            if(oQues.Help_Text_Required__c==false){
                oQues.Help_Text__c='';

            }
            update oQues;
            
            List<Question_Questionnaire__c> lstQQnnaire=[Select Id,Allow_Attachments__c,Allow_Comment__c,Help_Text_Required__c,Help_Text__c,Category__c from Question_Questionnaire__c where Question__c=:oQues.id and Questionnaire__c=:qnaireId and Question_Group__c=:sectionId];
            if(lstQQnnaire!=null && lstQQnnaire.size()>0)
            {
                lstQQnnaire[0].Allow_Attachments__c=oQues.Allow_Attachments__c;
                lstQQnnaire[0].Allow_Comment__c=oQues.Allow_Comment__c;
                lstQQnnaire[0].Help_Text_Required__c=oQues.Help_Text_Required__c;
                lstQQnnaire[0].Help_Text__c='';
                lstQQnnaire[0].Required__c=oQues.Required__c;
                if(oQues.Help_Text_Required__c==true){
                    lstQQnnaire[0].Help_Text__c=oQues.Help_Text__c;
                }
                if(String.isNotBlank(oQues.Currency_Symbol__c)){
                    lstQQnnaire[0].Currency_Symbol__c=oQues.Currency_Symbol__c;
                }
                lstQQnnaire[0].Decimal_value__c =oQues.Decimal_value__c;
                lstQQnnaire[0].Allow_Currency__c =oQues.Allow_Currency__c;
                lstQQnnaire[0].Max_Char_Length__c =(oQues.Max_Char_Length__c != null?oQues.Max_Char_Length__c:0);
                lstQQnnaire[0].Category__c=oQues.Category__c;
                update lstQQnnaire;
            }
        } 
    }
    
    /**
     * fetch Question Currency Symbols picklist value
     * @return : list of Question Currency sysmbol.
     */
    @AuraEnabled
    public static List<String> getQueCurrencySymbol(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Question__c.Currency_Symbol__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple) {
            options.add(f.getLabel());
        }
        return options;
    }
}