/**
 * Created/Modified By: Girikon(Mahesh/Divaker)
 * Created On:          26 Apr 2018
 * Description/Purpose: Using for Question Branching 
 * Test Class:   QuestionBranchingCtrl_Test
 * Code Coverage: 93%
**/
public class QuestionBranchingCtrl {
    /**
     * fetching Question_Questionnaire records 
     * @param  qnaireId    :Quenstionnaire id
     * @param  sectionId   : Question group id
     * @param  questnOrder : Question order
     * @param mainQuesQuetnnaireId: Question Questionnaire id
     * @return             : Question_Questionnaire records
     */
    @AuraEnabled
    public static List<Question_Questionnaire__c>  getAllQuestnQuestnnaire(String qnaireId,String sectionId,Integer questnOrder, String mainQuesQuetnnaireId,String colnum) {
        System.debug(qnaireId+'::'+sectionId+'::'+questnOrder+'::'+mainQuesQuetnnaireId+'::'+colnum);
        List<Questionnaire_Dynamic_Logic__c> lstQuestnnaireDynLogic = [Select Id,Question_Questionnaire__c,Show_Question_Questionnaire__c from 
        Questionnaire_Dynamic_Logic__c where Question_Group__c =:sectionId];
        List<Question_Questionnaire__c> lstQQuestnnaire = new List<Question_Questionnaire__c>();
        List<Id> lstQQuestnniareId = new List<Id>();
        lstQQuestnniareId.add(mainQuesQuetnnaireId);
        if(lstQuestnnaireDynLogic != null && lstQuestnnaireDynLogic.size()>0){
            for(Questionnaire_Dynamic_Logic__c objQDLogic : lstQuestnnaireDynLogic){
                if(objQDLogic.Question_Questionnaire__c != mainQuesQuetnnaireId){
                    lstQQuestnniareId.add(objQDLogic.Question_Questionnaire__c);
                    lstQQuestnniareId.add(objQDLogic.Show_Question_Questionnaire__c);
                }
            }
        }
        questnOrder = QuestionBranchingCtrl.getQuestnQuestnniareOrder(mainQuesQuetnnaireId);
        lstQQuestnnaire = [SELECT id, Name, Question__c,Question__r.Label__c from Question_Questionnaire__c 
            where Questionnaire__c =:qnaireId AND Question_Group__c =:sectionId AND Question__c != null AND Is_Allow_Branching__c =false
            AND question_order__c >:questnOrder AND Related_To_Column__c=:colnum AND ID NOT IN :lstQQuestnniareId AND is_Delete__c=false ORDER By question_order__c asc];
        return lstQQuestnnaire; 
    }
    
    public static Integer getQuestnQuestnniareOrder(String qQnniareID){
        Integer orderVal ;
        if(String.isNotBlank(qQnniareID)){
            orderVal= Integer.valueOf([Select question_order__c  from Question_Questionnaire__c where Id=:qQnniareID].question_order__c);
        }
        return orderVal;
    }

    /**
     * fetching already branching questionnaire record
     * @param  sectionId            Question Grorp Id
     * @param  mainQuesQuetnnaireId Question Questionnaire Id
     * @return                      list of Questinniare dynamic logic record
     */
    @AuraEnabled
    public static List<Questionnaire_Dynamic_Logic__c>  getAlraedyBranching(String sectionId, String mainQuesQuetnnaireId) {
        List<Questionnaire_Dynamic_Logic__c> lstQuestnnaireDynLogic = [Select Id,Question_Questionnaire__c,Question_Group__c,Question_Option__c,Show_Question_Questionnaire__c from
         Questionnaire_Dynamic_Logic__c where Question_Group__c =:sectionId and Question_Questionnaire__c =:mainQuesQuetnnaireId];
        return lstQuestnnaireDynLogic; 
    }
    /**
     * Insert new branching record in questinnaire dynamic logic object.
     * Delete old branching record in questionniare dynamic logic object.
     * @param qnaireId               Questionnaire Id
     * @param sectionId              Question Group section
     * @param mainQuesQuetnnaireId   Question Questionnaire Id
     * @param lstQuestnnaireDynLogic List of Questionnaire Dynamic login object record
     * @param questionnaireOrder     Question Order Number.
     */
    @AuraEnabled
    public static void saveQuestnDynLogic(String qnaireId,String sectionId, String mainQuesQuetnnaireId,List<Questionnaire_Dynamic_Logic__c> lstQuestnnaireDynLogic,Integer questionnaireOrder){
        List<Questionnaire_Dynamic_Logic__c>  lstQDLogic = QuestionBranchingCtrl.getAlraedyBranching(sectionId, mainQuesQuetnnaireId);
        if(lstQuestnnaireDynLogic != null && lstQuestnnaireDynLogic.size()>0){
            if(lstQDLogic != null && lstQDLogic.size()>0){
                delete lstQDLogic;
            }
            System.debug(lstQuestnnaireDynLogic);
            
            insert lstQuestnnaireDynLogic;
        }
    }
}