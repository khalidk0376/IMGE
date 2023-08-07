/**
 * Created By       :   Mahesh (Girikon)
 * Created On       :   06/30/2018
 * @description     :   
 * Test Class       :   NewCreateTemplateCtrl_Test 
 * Modification log --
 * Modified Date    :   May 16, 2019
 * Modified By      :   Girikon(Mahesh Kumar [CCEN-523] 5th Dec 2018, CCEN-577 2nd Jan 2019,CCEN-594 31st Jan2019), Amish ([CCEN 797], Prashant [C2E-13] 4th Sept 2019),[Aishwarya BK-6779 5 Aug 2020] 
**/
public with sharing class NewCreateTemplateCtr{
    /**
     * fetch Quentions record behalf of Questionnaire Id and Question group id.
     * @param  qnaireId   : Questionnaire id
     * @param  sectionId  : Question Group id.
     * @return            : List of the questions of particular Question Group
     */
    @AuraEnabled
    public static FBWrapper getQuestnsForQuesGroup(String qnaireId,String sectionId) {
        
        FBWrapper wrapper = new FBWrapper();
        QuestionGroupWithQuestionsWrap oQGWQuesWrap1 = new QuestionGroupWithQuestionsWrap();
        QuestionGroupWithQuestionsWrap oQGWQuesWrap2 = new QuestionGroupWithQuestionsWrap();
        QuestionGroupWithQuestionsWrap oQGWQuesWrap3 = new QuestionGroupWithQuestionsWrap();
        //string qId = Id.valueOf(qnaireId);
        //string secId = Id.valueOf(sectionId);
        if (String.isNotBlank(qnaireId)) {
            String sQuery = 'Select id,Related_To_Column__c,Question_Group__c,Question__c,Question_Group__r.Name,Question_Group__r.No_Of_Columns__c From Question_Questionnaire__c WHERE is_Delete__c=false  ';
            if (String.isNotBlank(qnaireId))
            {
                sQuery += ' and Questionnaire__c = :qnaireId ';
            }
            if(String.isNotBlank(sectionId)){
                sQuery += ' AND Question_Group__c =:sectionId ';
            }
            sQuery +=' ORDER BY Question_Order__c ASC';
            List<Question_Questionnaire__c> lstQuesQuestionnaire = Database.query(sQuery);
            
            List<String> lstcol1QuesId = new List<String>();
            List<String> lstcol2QuesId = new List<String>();
            List<String> lstcol3QuesId = new List<String>();
            
            // Get the question group(section) id and add all the questions in to list behalf of the this question group id.
            
            String colnum='1';
            
            for(Question_Questionnaire__c qustnQnaire: lstQuesQuestionnaire){
                if(String.isBlank(sectionId))
                { 
                    sectionId=qustnQnaire.Question_Group__c;
                }
                colnum = String.isNotBlank(qustnQnaire.Question_Group__r.No_Of_Columns__c)?qustnQnaire.Question_Group__r.No_Of_Columns__c:'1';
                
                if(String.isNotBlank(sectionId)){
                    oQGWQuesWrap1.groupName = qustnQnaire.Question_Group__r.Name;
                    oQGWQuesWrap1.sectionColNumber = colnum;
                    oQGWQuesWrap1.groupId = sectionId;
                }

                if(String.isNotBlank(sectionId) && qustnQnaire.Question_Group__c == sectionId && (colnum=='0'||colnum=='1')){
                    lstcol1QuesId.add(qustnQnaire.Question__c);
                }

                if(String.isNotBlank(sectionId) && qustnQnaire.Question_Group__c == sectionId && colnum=='2' && qustnQnaire.Related_To_Column__c=='col1'){
                    lstcol1QuesId.add(qustnQnaire.Question__c);
                }
                if(String.isNotBlank(sectionId) && qustnQnaire.Question_Group__c == sectionId && colnum=='2' && qustnQnaire.Related_To_Column__c=='col2'){
                    lstcol2QuesId.add(qustnQnaire.Question__c);
                }

                if(String.isNotBlank(sectionId) && qustnQnaire.Question_Group__c == sectionId && colnum=='3' && qustnQnaire.Related_To_Column__c=='col1'){
                    lstcol1QuesId.add(qustnQnaire.Question__c);
                }
                if(String.isNotBlank(sectionId) && qustnQnaire.Question_Group__c == sectionId && colnum=='3' && qustnQnaire.Related_To_Column__c=='col2'){
                    lstcol2QuesId.add(qustnQnaire.Question__c);
                }
                if(String.isNotBlank(sectionId) && qustnQnaire.Question_Group__c == sectionId && colnum=='3' && qustnQnaire.Related_To_Column__c=='col3'){
                    lstcol3QuesId.add(qustnQnaire.Question__c);
                }
            }
            //Initialize value
            oQGWQuesWrap1.lstQuestn = new List<Question__c>();
            oQGWQuesWrap2.lstQuestn = new List<Question__c>();
            oQGWQuesWrap3.lstQuestn = new List<Question__c>();
            
            // Retrive all the questions from Question object.
            if(lstcol1QuesId.size()>0){
               oQGWQuesWrap1.lstQuestn = new List<Question__c>([Select Id,background_Color__c, Label__c,Is_Weight_Required__c,Is_Score_Required__c,Step_Size__c,Is_Allow_Branching__c,Default_Value__c,Maximum_value__c,Minimum_Value__c,Allow_Currency__c,Currency_Symbol__c,Decimal_value__c
                                                              ,Metadata__c,lookup_Object_Field_Name__c,lookup_Object_API_Name__c,(Select id,Currency_Symbol__c,Metadata__c,Allow_Currency__c
                                                             ,Decimal_value__c,Help_Text__c,Max_Char_Length__c,lookup_Object_API_Name__c,lookup_Object_Field_Name__c, Allow_Attachments__c,Allow_Comment__c
                                                             ,Help_Text_Required__c,Is_Weight_Required__c,Is_Score_Required__c,Related_To_Column__c,Required__c,Step_Size__c,Default_Value__c,Is_Allow_Branching__c,Maximum_value__c,Minimum_Value__c,Weight__c,question_order__c,Question__r.Label__c,
                                                             Question__r.Type__c,Question__r.Allow_Currency__c,Question__r.Metadata__c,Question__r.Decimal_value__c,Question__r.Currency_Symbol__c from Question_Questionnaires__r 
                                                             where Questionnaire__c =:qnaireId and Question_Group__c =:sectionId and is_Delete__c=false ORDER BY Related_To_Column__c ASC LIMIT 1), 
                                                Help_Text__c, Type__c,Allow_Attachments__c,Allow_Comment__c,Max_Char_Length__c,Help_Text_Required__c,Required__c,
                                                (Select id,Value__c,Name__c,Score__c from Question_Options__r ORDER BY ID ASC) 
                                                              From Question__c WHERE id IN :lstcol1QuesId and is_Delete__c=false ORDER BY CreatedDate ASC]);
                
            }
            if(lstcol2QuesId.size()>0){
               oQGWQuesWrap2.lstQuestn = new List<Question__c>([Select Id,background_Color__c, Label__c,Is_Weight_Required__c,Is_Score_Required__c,Step_Size__c,Is_Allow_Branching__c,Default_Value__c,Maximum_value__c,Minimum_Value__c,Allow_Currency__c,Currency_Symbol__c,Decimal_value__c
                                                              ,Metadata__c,lookup_Object_Field_Name__c,lookup_Object_API_Name__c,(Select id,Currency_Symbol__c,Metadata__c,Allow_Currency__c
                                                             ,Decimal_value__c,Help_Text__c,Max_Char_Length__c,lookup_Object_API_Name__c,lookup_Object_Field_Name__c, Allow_Attachments__c,Allow_Comment__c
                                                             ,Help_Text_Required__c,Is_Weight_Required__c,Is_Score_Required__c,Related_To_Column__c,Required__c,Step_Size__c,Default_Value__c,Is_Allow_Branching__c,Maximum_value__c,Minimum_Value__c,Weight__c,question_order__c,Question__r.Label__c,
                                                             Question__r.Type__c,Question__r.Allow_Currency__c,Question__r.Metadata__c,Question__r.Decimal_value__c,Question__r.Currency_Symbol__c from Question_Questionnaires__r 
                                                             where Questionnaire__c =:qnaireId and Question_Group__c =:sectionId and is_Delete__c=false ORDER BY Related_To_Column__c ASC LIMIT 1), 
                                                Help_Text__c, Type__c,Allow_Attachments__c,Allow_Comment__c,Max_Char_Length__c,Help_Text_Required__c,Required__c,
                                                (Select id,Value__c,Name__c,Score__c from Question_Options__r ORDER BY ID ASC) 
                                                              From Question__c WHERE id IN :lstcol2QuesId and is_Delete__c=false ORDER BY CreatedDate ASC]);
                
            }
            if(lstcol3QuesId.size()>0){
               oQGWQuesWrap3.lstQuestn = new List<Question__c>([Select Id,background_Color__c, Label__c,Is_Weight_Required__c,Is_Score_Required__c,Step_Size__c,Is_Allow_Branching__c,Default_Value__c,Maximum_value__c,Minimum_Value__c,Allow_Currency__c,Currency_Symbol__c,Decimal_value__c
                                                              ,Metadata__c,lookup_Object_Field_Name__c,lookup_Object_API_Name__c,(Select id,Currency_Symbol__c,Metadata__c,Allow_Currency__c
                                                             ,Decimal_value__c,Help_Text__c,Max_Char_Length__c,lookup_Object_API_Name__c,lookup_Object_Field_Name__c, Allow_Attachments__c,Allow_Comment__c
                                                             ,Help_Text_Required__c,Is_Weight_Required__c,Is_Score_Required__c,Related_To_Column__c,Required__c,Step_Size__c,Default_Value__c,Is_Allow_Branching__c,Maximum_value__c,Minimum_Value__c,Weight__c,question_order__c,Question__r.Label__c,
                                                             Question__r.Type__c,Question__r.Allow_Currency__c,Question__r.Metadata__c,Question__r.Decimal_value__c,Question__r.Currency_Symbol__c from Question_Questionnaires__r 
                                                             where Questionnaire__c =:qnaireId and Question_Group__c =:sectionId and is_Delete__c=false ORDER BY Related_To_Column__c ASC LIMIT 1), 
                                                Help_Text__c, Type__c,Allow_Attachments__c,Allow_Comment__c,Max_Char_Length__c,Help_Text_Required__c,Required__c,
                                                (Select id,Value__c,Name__c,Score__c from Question_Options__r ORDER BY ID ASC) 
                                                              From Question__c WHERE id IN :lstcol3QuesId and is_Delete__c=false ORDER BY CreatedDate ASC]);
                
            }
        }
        wrapper.col1Questions = oQGWQuesWrap1;
        wrapper.col2Questions = oQGWQuesWrap2;
        wrapper.col3Questions = oQGWQuesWrap3;
        return wrapper;
    }
   @AuraEnabled
    public static boolean backButtonRender() { 
        Profile profile1 = new Profile();
        
            profile1 = [SELECT Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        
        if(profile1.Name=='Customer Community Login User Custom'){ return true;       
        }   
        return false;
   }
    // Approval and reject method, update the records read only in ops Admin
    @AuraEnabled
    public static boolean selectApprovedStatus(String questionaryId,String sAccountId)
    {   
        String accId = '';
        if(sAccountId != null && sAccountId !='')
        {
            accId = sAccountId;
        }
        String userId = UserInfo.getUserId();
        User acc = new User();
        if(Schema.sObjectType.user.isAccessible()) 
        {
            acc=[select id,name,AccountId from user where id=:userId];
        }
        if(accId == null && accId == '')
        {
            accId=acc.AccountId;
        }
        List <User_Form_Action__c> usrlst = new List <User_Form_Action__c>();
        Forms_Permission__c fpList = new Forms_Permission__c();
        if(Schema.sObjectType.Forms_Permission__c.isAccessible())
        {
            fpList =[select id,name,Event_Edition_Form__r.Template_Form__c from Forms_Permission__c WHERE Event_Edition_Form__r.Template_Form__c = :questionaryId limit 1 ];
        }
        
        if(Schema.sObjectType.User_Form_Action__c.isAccessible()){
          usrlst =[select id,Status__c,User_Form_Action__c.Form_Permission__c,Account__c from User_Form_Action__c where Account__c=:accId and Form_Permission__r.Event_Edition_Form__r.Template_Form__c = :questionaryId and (Status__c='Approved' or Status__c='Rejected')];
        }
        if(usrlst.size()>0)
        { return true;
        }
        else {
            return false;   
        }
    }
    @AuraEnabled
    public static boolean isMergeSection(String qnaireId) {
        List<Questionnaire__c> q = new List<Questionnaire__c>();
        if(!String.isBlank(qnaireId) && Schema.sObjectType.Questionnaire__c.isAccessible()){
            q = [Select id,isMerge__c from Questionnaire__c where id=:qnaireId];
            if(q.size()>0){
                return q[0].isMerge__c;
            }
        }
        return false;
    }
    @AuraEnabled
    public static FBPreviewWrapper getQuestnsForAllQuesGroup(String qnaireId, String sectionId) {
        FBPreviewWrapper fbPreview = new FBPreviewWrapper();
        List<FBWrapper> wrapperList = new List<FBWrapper>();
        if (String.isNotBlank(qnaireId)) {
            List<AggregateResult> qqlist;
            //order BY Question_Group__r.Sort_Order__c
            if (String.isNotBlank(sectionId) && Schema.sObjectType.Question_Questionnaire__c.isAccessible()) {
                qqlist = [Select count(id), Question_Group__c from Question_Questionnaire__c where Question_Group__c = :sectionId AND Questionnaire__c = :Id.valueOf(qnaireId) group by Question_Group__c];
            } else {
                qqlist = [Select count(id), Question_Group__c from Question_Questionnaire__c where Questionnaire__c = :Id.valueOf(qnaireId) group by Question_Group__c];
            }
            List<Id> sectionIdList = new List<Id>();
            for (AggregateResult qq : qqlist) {
                sectionIdList.add(String.valueOf(qq.get('Question_Group__c')));
            }
            
            Map<Id, Question_Group__c> sections = new Map<Id, Question_Group__c>();
            if(Schema.SObjectType.Question_Group__c.isAccessible() && Schema.SObjectType.Question_Group__c.Fields.Id.isAccessible()){
                sections = new Map<Id, Question_Group__c>([Select Id from Question_Group__c Where Id IN:sectionIdList order by Sort_Order__c ASC]);
            }
 
            String strQuery = '';
            Transient List<String> lstcol1QuesId; 
            Transient List<String> lstcol2QuesId; 
            Transient List<String> lstcol3QuesId; 
            List<Question_Questionnaire__c> lstQuesQuestionnaire = new List<Question_Questionnaire__c>();
            List<String> allQuestionIds = new List<String>();
            
            
            strQuery = 'Select id,Question_Order__c,Related_To_Column__c,Question_Group__c,Question__c,Question_Group__r.Name,Question_Group__r.No_Of_Columns__c From Question_Questionnaire__c WHERE is_Delete__c=false  ';            
            if (String.isNotBlank(qnaireId)) {
                strQuery += ' and Questionnaire__c = :qnaireId ';
            }
            if (String.isNotBlank(sectionId)) {
                strQuery += ' and Question_Group__c = :sectionId ';
            }
            strQuery += ' ORDER BY Question_Order__c ASC';
            
            Boolean isQuestionQuestionnaireAccessible = FBUtils.isAccessible('Question_Questionnaire__c','Id,Currency_Symbol__c,Metadata__c,Allow_Currency__c,Decimal_value__c,Help_Text__c,Max_Char_Length__c,lookup_Object_API_Name__c,lookup_Object_Field_Name__c, Allow_Attachments__c,Allow_Comment__c,Help_Text_Required__c,Related_To_Column__c,Required__c,Step_Size__c,Default_Value__c,Is_Allow_Branching__c,Maximum_value__c,Minimum_Value__c,question_order__c');
            if(isQuestionQuestionnaireAccessible)
            {
                lstQuesQuestionnaire = Database.query(strQuery);
            }
            
            for (Id qq : sections.keySet()) {
                FBWrapper wrapper = new FBWrapper();
                QuestionGroupWithQuestionsWrap oQGWQuesWrap1 = new QuestionGroupWithQuestionsWrap();
                QuestionGroupWithQuestionsWrap oQGWQuesWrap2 = new QuestionGroupWithQuestionsWrap();
                QuestionGroupWithQuestionsWrap oQGWQuesWrap3 = new QuestionGroupWithQuestionsWrap();
                sectionId = qq;
                
                lstcol1QuesId = new List<String>();
                lstcol2QuesId = new List<String>();
                lstcol3QuesId = new List<String>();

                // Get the question group(section) id and add all the questions in to list behalf of the this question group id.

                String colnum = '1';
                for (Question_Questionnaire__c qustnQnaire : lstQuesQuestionnaire) {
                    if (String.isBlank(sectionId)) {
                        sectionId = qustnQnaire.Question_Group__c;
                    }
                    if(qustnQnaire.Question_Group__c==qq){
                        colnum = String.isNotBlank(qustnQnaire.Question_Group__r.No_Of_Columns__c) ? qustnQnaire.Question_Group__r.No_Of_Columns__c : '1';
                        if (String.isNotBlank(sectionId)) {
                            oQGWQuesWrap1.groupName = qustnQnaire.Question_Group__r.Name;
                            oQGWQuesWrap1.sectionColNumber = colnum;
                            oQGWQuesWrap1.groupId = sectionId;
                            wrapper.sectionColNumber = colnum;
                            wrapper.sectionName = qustnQnaire.Question_Group__r.Name;
                        }
                        
                        if (qustnQnaire.Question__c!=null && String.isNotBlank(sectionId) && qustnQnaire.Question_Group__c == sectionId && (colnum == '0' || colnum == '1')) {
                            lstcol1QuesId.add(qustnQnaire.Question__c);
                        }
                        
                        if (qustnQnaire.Question__c!=null && String.isNotBlank(sectionId) && qustnQnaire.Question_Group__c == sectionId && colnum == '2' && qustnQnaire.Related_To_Column__c == 'col1') {
                            lstcol1QuesId.add(qustnQnaire.Question__c);
                        }
                        if (qustnQnaire.Question__c!=null && String.isNotBlank(sectionId) && qustnQnaire.Question_Group__c == sectionId && colnum == '2' && qustnQnaire.Related_To_Column__c == 'col2') {
                            lstcol2QuesId.add(qustnQnaire.Question__c);
                        }
                        
                        if (qustnQnaire.Question__c!=null && String.isNotBlank(sectionId) && qustnQnaire.Question_Group__c == sectionId && colnum == '3' && qustnQnaire.Related_To_Column__c == 'col1') {
                            lstcol1QuesId.add(qustnQnaire.Question__c);
                        }
                        if (qustnQnaire.Question__c!=null && String.isNotBlank(sectionId) && qustnQnaire.Question_Group__c == sectionId && colnum == '3' && qustnQnaire.Related_To_Column__c == 'col2') {
                            lstcol2QuesId.add(qustnQnaire.Question__c);
                        }
                        if (qustnQnaire.Question__c!=null && String.isNotBlank(sectionId) && qustnQnaire.Question_Group__c == sectionId && colnum == '3' && qustnQnaire.Related_To_Column__c == 'col3') {
                            lstcol3QuesId.add(qustnQnaire.Question__c);
                        }
                        
                    }
                }

                Boolean isQuestionOptionAccessible = FBUtils.isAccessible('Question_Option__c','Id,Value__c,Name__c');
                Boolean isQuestionAccessible = FBUtils.isAccessible('Question__c','Id,background_Color__c,Label__c,Step_Size__c,Is_Allow_Branching__c,Default_Value__c,Maximum_value__c,Minimum_Value__c,Allow_Currency__c,Currency_Symbol__c,Decimal_value__c,Metadata__c,lookup_Object_Field_Name__c,lookup_Object_API_Name__c,Help_Text__c,Type__c,Allow_Attachments__c,Allow_Comment__c,Max_Char_Length__c,Help_Text_Required__c,Required__c');
                
                if(isQuestionQuestionnaireAccessible && isQuestionOptionAccessible && isQuestionAccessible)
                {
                    oQGWQuesWrap1.lstQuestn = new List<Question__c>();
                    oQGWQuesWrap2.lstQuestn = new List<Question__c>();
                    oQGWQuesWrap3.lstQuestn = new List<Question__c>();
                    
                    // Retrive all the questions from Question object.
                    if (lstcol1QuesId.size() > 0) {                        
                        oQGWQuesWrap1.col1QuestionIds = lstcol1QuesId;
                        allQuestionIds.addAll(lstcol1QuesId);
                    }
                    if (lstcol2QuesId.size() > 0) {                        
                        oQGWQuesWrap2.col2QuestionIds = lstcol2QuesId;
                        allQuestionIds.addAll(lstcol2QuesId);
                    }
                    if (lstcol3QuesId.size() > 0) {
                        oQGWQuesWrap3.col3QuestionIds = lstcol3QuesId;
                        allQuestionIds.addAll(lstcol3QuesId);
                    }
                }                
                wrapper.col1Questions = oQGWQuesWrap1;
                wrapper.col2Questions = oQGWQuesWrap2;
                wrapper.col3Questions = oQGWQuesWrap3;
                wrapperList.add(wrapper);
            }
            
            //fbPreview.sectionList = wrapperList;
            Boolean  isQuestionnaireAccessible = FBUtils.isAccessible('Questionnaire__c','Previous_Button_Color__c, Previous_Button_Label__c, Submit_Button_Color__c, Submit_Button_Label__c, Button_Alignment__c, Buttons_Position__c, Is_Customize_Buttons__c, Next_Button_Color__c, Next_Button_Label__c');

            if(isQuestionnaireAccessible){
                fbPreview.Questionnaire = [Select Previous_Button_Color__c, Previous_Button_Label__c, Submit_Button_Color__c, Submit_Button_Label__c, Button_Alignment__c, Buttons_Position__c, Is_Customize_Buttons__c, Next_Button_Color__c, Next_Button_Label__c from Questionnaire__c WHERE id = :Id.valueOf(qnaireId)];
            }
            
            
            
            // get all questions
            Map<Id,Question__c> allQuestions = new Map<Id,Question__c>([Select Id,background_Color__c, Label__c,Is_Weight_Required__c,Is_Score_Required__c,Step_Size__c,Is_Allow_Branching__c,Default_Value__c,Maximum_value__c,Minimum_Value__c,Allow_Currency__c,Currency_Symbol__c,Decimal_value__c
                                                              ,Metadata__c,lookup_Object_Field_Name__c,lookup_Object_API_Name__c,(Select id,Currency_Symbol__c,Metadata__c,Allow_Currency__c
                                                             ,Decimal_value__c,Help_Text__c,Max_Char_Length__c,lookup_Object_API_Name__c,lookup_Object_Field_Name__c, Allow_Attachments__c,Allow_Comment__c
                                                             ,Help_Text_Required__c,Is_Weight_Required__c,Is_Score_Required__c,Related_To_Column__c,Required__c,Step_Size__c,Default_Value__c,Is_Allow_Branching__c,Maximum_value__c,Minimum_Value__c,Weight__c,question_order__c,Question__r.Label__c,
                                                             Question__r.Type__c,Question__r.Allow_Currency__c,Question__r.Metadata__c,Question__r.Decimal_value__c,Question__r.Currency_Symbol__c from Question_Questionnaires__r 
                                                             where Questionnaire__c =:qnaireId and Question_Group__c In :sectionIdList and is_Delete__c=false ORDER BY Related_To_Column__c ASC LIMIT 1), 
                                                Help_Text__c, Type__c,Allow_Attachments__c,Allow_Comment__c,Max_Char_Length__c,Help_Text_Required__c,Required__c,
                                                (Select id,Value__c,Name__c,Score__c from Question_Options__r ORDER BY ID ASC) 
                                                              From Question__c WHERE id IN :allQuestionIds and is_Delete__c=false ORDER BY CreatedDate ASC]);
            
            

            for(FBWrapper item : wrapperList){
                if(item.col1Questions.col1QuestionIds.size()>0){
                    for(String idStr : item.col1Questions.col1QuestionIds){
                        if(allQuestions.containsKey(idStr)){
                            item.col1Questions.lstQuestn.add(allQuestions.get(idStr));        
                        }
                    }
                }
                if(item.col2Questions.col2QuestionIds.size()>0){
                    for(String idStr : item.col2Questions.col2QuestionIds){
                        if(allQuestions.containsKey(idStr)){
                            item.col2Questions.lstQuestn.add(allQuestions.get(idStr));        
                        }
                    }
                }
                if(item.col3Questions.col3QuestionIds.size()>0){
                    for(String idStr : item.col3Questions.col3QuestionIds){
                        if(allQuestions.containsKey(idStr)){
                            item.col3Questions.lstQuestn.add(allQuestions.get(idStr));        
                        }
                    }
                }
            }
            fbPreview.sectionList = wrapperList;
        }
        return fbPreview;
    }

    @AuraEnabled
    public static QuestionGroupWithQuestionsWrap getQuestnsForQuesGroup2(String qnaireId,String sectionId) {
        QuestionGroupWithQuestionsWrap oQGWQuesWrap = new QuestionGroupWithQuestionsWrap();
       
        if (String.isNotBlank(qnaireId)) {
            Boolean isMergeAllSection=false;
            List<Questionnaire__c> qnaireList = [Select id,isMerge__c FROM Questionnaire__c Where ID=:qnaireId];
            if(qnaireList.size()>0){
                isMergeAllSection = qnaireList[0].isMerge__c;
            }
            string qId = Id.valueOf(qnaireId);
            string secId = Id.valueOf(sectionId);
            String sQueryWrap = 'Select id,Question_Group__c,Question__c,Question_Group__r.Name,Question_Group__r.No_Of_Columns__c From Question_Questionnaire__c WHERE is_Delete__c=false  ';
            if (String.isNotBlank(qnaireId))
            {
                    sQueryWrap += ' and Questionnaire__c = :qnaireId ';
            }
            // if(String.isNotBlank(sectionId) && !isMergeAllSection){
            //     sQueryWrap += ' AND Question_Group__c =\''+String.escapeSingleQuotes(secId)+'\'';
            // }
            sQueryWrap +=' ORDER BY Question_Order__c ASC';
            List<Question_Questionnaire__c> lstQuesQuestionnaire = Database.query(sQueryWrap);
            List<String> lstQuesId = new List<String>();
            
            // Get the question group(section) id and add all the questions in to list behalf of the this question group id.
            if(isMergeAllSection)
            {
                for(Question_Questionnaire__c qustnQnaire: lstQuesQuestionnaire){
                    if(String.isBlank(sectionId)){ sectionId=qustnQnaire.Question_Group__c;
                    }
                    if(sectionId!=null && String.isNotBlank(sectionId)){ // && qustnQnaire.Question_Group__c == sectionId
                        lstQuesId.add(qustnQnaire.Question__c);
                        oQGWQuesWrap.groupName = qustnQnaire.Question_Group__r.Name;
                        oQGWQuesWrap.sectionColNumber = (String.isNotBlank(qustnQnaire.Question_Group__r.No_Of_Columns__c)?qustnQnaire.Question_Group__r.No_Of_Columns__c:'0');
                        oQGWQuesWrap.groupId = sectionId;
                    }   
                }
                if(lstQuesId != null && lstQuesId.size()>0){
                   oQGWQuesWrap.lstQuestn = new List<Question__c>([Select Id, Label__c,Is_Weight_Required__c,Is_Score_Required__c,Step_Size__c,Is_Allow_Branching__c,Default_Value__c,Maximum_value__c,Minimum_Value__c,Allow_Currency__c,Currency_Symbol__c,Decimal_value__c
                                                                  ,Metadata__c,lookup_Object_Field_Name__c,lookup_Object_API_Name__c,(Select id,Currency_Symbol__c,Metadata__c,Allow_Currency__c
                                                                 ,Decimal_value__c,Help_Text__c,Max_Char_Length__c,lookup_Object_API_Name__c,lookup_Object_Field_Name__c, Allow_Attachments__c,Allow_Comment__c
                                                                 ,Help_Text_Required__c,Is_Weight_Required__c,Is_Score_Required__c,Related_To_Column__c,Required__c,Step_Size__c,Default_Value__c,Is_Allow_Branching__c,Maximum_value__c,Minimum_Value__c,Weight__c,question_order__c,Question__r.Label__c,
                                                                 Question__r.Type__c,Question__r.Allow_Currency__c,Question__r.Metadata__c,Question__r.Decimal_value__c,Question__r.Currency_Symbol__c from Question_Questionnaires__r 
                                                                 where Questionnaire__c =:qnaireId and is_Delete__c=false ORDER BY Related_To_Column__c ASC LIMIT 1), 
                                                    Help_Text__c, Type__c,Allow_Attachments__c,Allow_Comment__c,Max_Char_Length__c,Help_Text_Required__c,Required__c,
                                                    (Select id,Value__c,Name__c,Score__c from Question_Options__r ORDER BY ID ASC) 
                                                                  From Question__c WHERE id IN :lstQuesId and is_Delete__c=false ORDER BY CreatedDate ASC]);
                    
                }
            }

            if(!isMergeAllSection)
            {
                for(Question_Questionnaire__c qustnQnaire: lstQuesQuestionnaire){
                    if(String.isBlank(sectionId)){
                        sectionId=qustnQnaire.Question_Group__c;
                    }
                    if(String.isNotBlank(sectionId) && qustnQnaire.Question_Group__c == sectionId){
                        lstQuesId.add(qustnQnaire.Question__c);oQGWQuesWrap.groupName = qustnQnaire.Question_Group__r.Name;
                        oQGWQuesWrap.sectionColNumber = (String.isNotBlank(qustnQnaire.Question_Group__r.No_Of_Columns__c)?qustnQnaire.Question_Group__r.No_Of_Columns__c:'0');
                        oQGWQuesWrap.groupId = sectionId;
                    }   
                }            
                if(lstQuesId != null && lstQuesId.size()>0){
                   oQGWQuesWrap.lstQuestn = new List<Question__c>([Select Id, Label__c,Is_Weight_Required__c,Is_Score_Required__c,Step_Size__c,Is_Allow_Branching__c,Default_Value__c,Maximum_value__c,Minimum_Value__c,Allow_Currency__c,Currency_Symbol__c,Decimal_value__c
                                                                  ,Metadata__c,lookup_Object_Field_Name__c,lookup_Object_API_Name__c,(Select id,Currency_Symbol__c,Metadata__c,Allow_Currency__c
                                                                 ,Decimal_value__c,Help_Text__c,Max_Char_Length__c,lookup_Object_API_Name__c,lookup_Object_Field_Name__c, Allow_Attachments__c,Allow_Comment__c
                                                                 ,Help_Text_Required__c,Is_Weight_Required__c,Is_Score_Required__c,Related_To_Column__c,Required__c,Step_Size__c,Default_Value__c,Is_Allow_Branching__c,Maximum_value__c,Minimum_Value__c,Weight__c,question_order__c,Question__r.Label__c,
                                                                 Question__r.Type__c,Question__r.Allow_Currency__c,Question__r.Metadata__c,Question__r.Decimal_value__c,Question__r.Currency_Symbol__c from Question_Questionnaires__r 
                                                                 where Questionnaire__c =:qnaireId and Question_Group__c =:sectionId and is_Delete__c=false ORDER BY Related_To_Column__c ASC LIMIT 1), 
                                                    Help_Text__c, Type__c,Allow_Attachments__c,Allow_Comment__c,Max_Char_Length__c,Help_Text_Required__c,Required__c,
                                                    (Select id,Value__c,Name__c,Score__c from Question_Options__r ORDER BY ID ASC) 
                                                                  From Question__c WHERE id IN :lstQuesId and is_Delete__c=false ORDER BY CreatedDate ASC]);
                    
                }
            }
        }

        return oQGWQuesWrap;
    }

    /**
     * fetch Questionnaire(Template) record
     * @param  qnaireId : Questionnaire Id.
     * @return           : Questionnaire record
     */
    @AuraEnabled
    public static Questionnaire__c getTemplateRecord(String qnaireId) {
        if(String.isNotBlank(qnaireId)){
            List<Questionnaire__c> lstQuestnnaire = new List<Questionnaire__c>([Select Name,Community_URL__c,Description__c,Version__c,Category__c,is_Published__c from Questionnaire__c WHERE Id=:qnaireId]);
            if(lstQuestnnaire != null && lstQuestnnaire.size()>0){
                return lstQuestnnaire[0];
            }
            
        }return new Questionnaire__c(); 
    }
    /**
     * fetch Questionnaire(Template) name
     * @param  qnaireId : Questionnaire Id.
     * @return           : Questionnaire name
     */
    public static String getTemplateName(String qnaireId) {
         return [Select Name from Questionnaire__c WHERE Id=:qnaireId].Name;
    }
    
    
    /**
     * fetch all Question Group for Questionnaire
     * @param  sQnaireId : set Questionnaire id.
     * @return           : All Question Group name for Questionnaire.
     */
     @AuraEnabled
     public static List<Question_Questionnaire__c> getAllQuestnGrpNameForQuesnnaire(String sQnaireId) {
            List<Question_Questionnaire__c> lstQuestnQnaire = new List<Question_Questionnaire__c>();
            if (String.isNotBlank(sQnaireId)) {
                lstQuestnQnaire  = new List<Question_Questionnaire__c>([SELECT Id,
                         Question_Group__c,Question_Group__r.No_Of_Columns__c, Question_Group__r.Name__c, Question_Group__r.Name, Question_Group__r.Sort_Order__c
                        From Question_Questionnaire__c WHERE Questionnaire__c =:sQnaireId and Question__c =null and is_Delete__c=false ORDER by Question_Group__r.Sort_Order__c asc]);  
                
            }
            return lstQuestnQnaire;
     }
    /**
     * fetch Question Categories picklist value
     * @return : list of Question Category.
     */
    @AuraEnabled
    public static List<String> getQueCategory(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Question__c.Category__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple) {
            options.add(f.getLabel());
        }
        return options;
    }

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
    public static void createQuestnAndQuestnQnaire(String qnaireId,String qGroupId,Question__c question,String qnaireName,String qOrder,String colNumber){
        //try{
            String sQLib = NewCreateTemplateCtr.getDefaultQuestnLibraryId();
            question.Name__c = question.Label__c;
            question.Related_To_Column__c = colNumber;
            if(String.isNotBlank( sQLib)){
                question.Question_Library__c = sQLib; 
            }
            question.Name = qOrder;
            insert question;
            Question_Questionnaire__c oQQuesnaire= new Question_Questionnaire__c(Required__c=question.Required__c,Related_To_Column__c=colNumber,Help_Text__c=question.Help_Text__c,Help_Text_Required__c=question.Help_Text_Required__c,Category__c=question.Category__c,Allow_Attachments__c=question.Allow_Attachments__c,Allow_Comment__c=question.Allow_Comment__c,Questionnaire__c = qnaireId,Name=qnaireName,Max_Char_Length__c =question.Max_Char_Length__c,Question_Group__c =qGroupId,Question__c=question.id,Question_Order__c=Integer.valueOf(qOrder));
            if(Schema.sObjectType.Question_Questionnaire__c.IsCreateable())
            {
                insert oQQuesnaire;
            }
            
        //}
        //catch(Exception ex){
           // throw new AuraHandledException(ex.getMessage());
        //} 
    }
    /**
     * Deleting Question and Question Questionnaire record.
     * @param  quesId : question record id
     * 
     */
    @AuraEnabled
    public static void delQuestion(String questnQuestnnaireId) {
        if (String.isNotBlank(questnQuestnnaireId)) {
            List<Question_Questionnaire__c> lstQQnaire = new List<Question_Questionnaire__c>([select id,is_delete__c,Question__c,
                    Question__r.Is_Approve_For_Library__c from Question_Questionnaire__c where id=:questnQuestnnaireId]);
            if(lstQQnaire != null && lstQQnaire.size()>0 && Schema.sObjectType.Question_Questionnaire__c.isUpdateable()){
                lstQQnaire[0].is_delete__c =true;
                update lstQQnaire;
                if(lstQQnaire[0].Question__c != null && lstQQnaire[0].Question__r.Is_Approve_For_Library__c==false && Schema.sObjectType.Question__c.isAccessible()){
                    List<Question__c> lstQuestn =[Select id,is_delete__c from Question__c where id =:lstQQnaire[0].Question__c];
                    if(lstQuestn != null && lstQuestn.size()>0 && Schema.sObjectType.Question__c.isUpdateable()){
                        lstQuestn[0].is_delete__c =true; 
                        update lstQuestn;
                        NewCreateTemplateCtr.delQuestnDynLogic(questnQuestnnaireId);
                    }
                    //delete new Question__C(id=quesId); 
                }
            }
        }
        
    }
    /**
     * Delete branching record when admin deleting input field record.
     * @param questnQuestnnaireId : Question Questionnaire Id
     */
    public static void delQuestnDynLogic(String questnQuestnnaireId){
        List<Questionnaire_Dynamic_Logic__c> lstQuestnDynLogic = new List<Questionnaire_Dynamic_Logic__c>();
        if(Schema.sObjectType.Questionnaire_Dynamic_Logic__c.isAccessible()){
            lstQuestnDynLogic= [Select Id,Question_Questionnaire__c,Question_Questionnaire__r.Question__c,Show_Question_Questionnaire__c from Questionnaire_Dynamic_Logic__c where (Question_Questionnaire__c =:questnQuestnnaireId OR Show_Question_Questionnaire__c=:questnQuestnnaireId)];
        }
        if(lstQuestnDynLogic != null && lstQuestnDynLogic.size()>0 && Questionnaire_Dynamic_Logic__c.sObjectType.getDescribe().isDeletable()){ 
            delete lstQuestnDynLogic;
        }
    }
    /**
     * fetch a question detail
     * @param  sQuesId : Question record id
     * @return          question detail
     */
    @AuraEnabled
    public static Question__c getQuesDetail(String quesId) {
        if (String.isNotBlank(quesId) && Schema.sObjectType.Question__c.isAccessible() && Schema.sObjectType.Question_Option__c.isAccessible()) {
            return [Select Id,background_Color__c, Label__c, Is_Allow_Branching__c,Is_Weight_Required__c,Is_Score_Required__c,lookup_Object_Field_Name__c,
            Step_Size__c,Default_Value__c,Maximum_value__c,Minimum_Value__c,lookup_Object_API_Name__c,Help_Text__c,Currency_Symbol__c,
            Allow_Currency__c,Decimal_value__c,Metadata__c,Max_Char_Length__c,Category__c, Type__c, Allow_Comment__c,
            Allow_Attachments__c,Help_Text_Required__c,Weight__c,
            (Select Id,Value__c,Name__c,Score__c, Is_Score_Required__c from Question_Options__r ORDER BY ID ASC),Required__c 
             From Question__c WHERE id=:quesId LIMIT 1];
        }return new Question__c();
    }
    
    /**
     * save edited Question and Question Questionniare record
     * @param  oQues: Question object values.
     * @return      Boolean value for update secussfull. 
     */
    @AuraEnabled
    public static Boolean saveEditQuesRecord(Question__c oQues) {
        if (oQues != null) 
        {
            if(oQues.Help_Text_Required__c==false){oQues.Help_Text__c='';
            }
            update oQues;
            
            List<Question_Questionnaire__c> lstQQnnaire=[Select Id,Allow_Attachments__c,Allow_Comment__c,Help_Text_Required__c,Help_Text__c,Category__c,Weight__c from Question_Questionnaire__c where Question__c=:oQues.id];
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
                if(oQues.Weight__c!=null){lstQQnnaire[0].Weight__c=oQues.Weight__c;
                }
                
                lstQQnnaire[0].Category__c=oQues.Category__c;
                update lstQQnnaire;
            }
            return true;
        }return false;
    }

    /**
     * fetch default set Question Library id
     * @return : Question library id
     */
    public static String getDefaultQuestnLibraryId(){
        List<Question_Library__c>  qllist = new List<Question_Library__c>();
        if(Schema.sObjectType.Question_Library__c.isAccessible())
        {
            qllist = [Select id from Question_Library__c where Name='Global Default' Limit 1];
        }
        
        
        if(qllist.size()>0){
            return qllist[0].id;
        }
        else if(Schema.sObjectType.Question_Library__c.isCreateable())
        {Question_Library__c objQLib = new Question_Library__c(Name='Global Default',Name__c='Global Default');
            insert objQLib;
        } return null;
    }
   
 
     /**
     * Create new Question group
     * @param  sectionName: Question Group name.
     * @param  questionaryId: Questionniare Id.
     * @param  columnNumber: No of columns in section.
     */
    @AuraEnabled
    public static Question_Group__c createSection(String sectionName,String questionaryId,String columnNumber)
    {
        Question_Group__c qg=new Question_Group__c();
        try
        {
            if(String.isNotBlank(sectionName) && String.isNotBlank(questionaryId) && String.isNotBlank(columnNumber))
            {
                List<Question_Questionnaire__c> lstQstnGrp=[Select id,Questionnaire__c,Question_Group__c from Question_Questionnaire__c where Questionnaire__c=:questionaryId];
                Question_Group__c questnGroup=new Question_Group__c(name=sectionName,No_Of_Columns__c=columnNumber,Sort_Order__c=lstQstnGrp.size());
                if(Schema.sObjectType.Question_Group__c.isCreateable()){
                    insert questnGroup;
                }
                
                Question_Questionnaire__c questnQuestnnaire=new Question_Questionnaire__c(name=getTemplateName(questionaryId),Question_Group__c=questnGroup.id,Questionnaire__c=questionaryId);
                insert questnQuestnnaire;
                qg=questnGroup;
                return qg;    
            }
        }
        catch(Exception ex)
        {throw new AuraHandledException(ex.getMessage());
        }return qg;
    }
    /**
     * Delete Question group(Section)
     * @param  sectionId: Question Group ID.
     * @param  questionaryId: Questionnaire ID
     */
    @AuraEnabled
    public static void deleteSectionWithQuestionsAndQstnQustnry(String sectionId,String questionaryId){
        
        if(String.isNotBlank(sectionId)){
            List<String> lstQuestionsId=new List<String>();
            List<Question_Group__c> lstQuestionGrp=new List<Question_Group__c>();
            List<Question__c> lstupdateQuestions=new List<Question__c>();
            List<Question_Questionnaire__c> lstQustnQustnire=new List<Question_Questionnaire__c>();
            List<Question_Questionnaire__c> lstqustnQuestionnaire=[Select Id,Question_Group__c,Question__c,is_Delete__c from Question_Questionnaire__c Where Questionnaire__c=:questionaryId and Question_Group__c=:sectionId];
            if(lstqustnQuestionnaire!=null && lstqustnQuestionnaire.size()>0){
                for(Question_Questionnaire__c qq:lstqustnQuestionnaire){
                    qq.is_Delete__c=true;
                    lstQuestionsId.add(qq.Question__c);
                    lstQustnQustnire.add(qq);
                }
                lstQuestionGrp=[Select id,is_Delete__c from Question_Group__c Where Id=:lstqustnQuestionnaire[0].Question_Group__c and is_Delete__c=false];
                List<Question__c> lstQuestions=[Select Id,is_Delete__c from Question__c Where Id IN:lstQuestionsId and Is_Approve_For_Library__c=false and is_Delete__c=false];
                if(lstQuestions!=null && lstQuestions.size()>0){
                    for(Question__c question:lstQuestions){
                        question.is_Delete__c=true;
                        lstupdateQuestions.add(question);
                    }
                }
                
            }
            if(lstQustnQustnire.size()>0 && lstQuestionGrp.size()>0 && lstupdateQuestions.size()>0 && Schema.sObjectType.Question_Group__c.isUpdateable()){
                lstQuestionGrp[0].is_Delete__c=true;
                update lstQuestionGrp;
                update lstQustnQustnire;
                update lstupdateQuestions;
            }
            else{lstQuestionGrp[0].is_Delete__c=true;
                update lstQuestionGrp;update lstQustnQustnire;
            }
            
        }
        
    }
    
    /**
     * Get score and weight from Question options and question
     * @param  qqnaireId: Question Questionnaire ID.
     */
    @AuraEnabled
    public static List<Question_Option__c> getScoreAndWeight(String qstnId){
        List<Question_Option__c> questionOptions=new List<Question_Option__c>();
        if(String.isNotBlank(qstnId)){
                questionOptions=[Select Id,Score__c From Question_Option__c Where Question__c=:qstnId];
        }
        return questionOptions;
    }
    /**
     * fetching Questionnaire Dynamic logic information.
     * @param  sectionId  Question Group Id
     * @return           list of Questionnaire Dynamic logic recoed.
     */
    @AuraEnabled
    public static List<Questionnaire_Dynamic_Logic__c> getBranchingQuestn(String sectionId){
        return [Select Id,Question_Questionnaire__c,Question_Questionnaire__r.Question__r.Type__c,Question_Questionnaire__r.Question__c,Question_Option__c,Question_Option__r.Name__c,Show_Question_Questionnaire__c from 
                    Questionnaire_Dynamic_Logic__c where Question_Group__c =:sectionId];
    }    
    
    /**
     * fetching Questionnaire Dynamic logic information.
     * @param  templateId : Questionnaire Id
     * @return list of Questionnaire Dynamic logic recoed.
     */
    @AuraEnabled
    public static void setpublishStatusOnTemplate(String templateId){
        Questionnaire__c questnnaire = [Select Id,is_Published__c from Questionnaire__c where Id =:templateId];
        if(questnnaire!=null && Schema.sObjectType.Questionnaire__c.isUpdateable()){
            questnnaire.is_Published__c=true;
            update questnnaire;
        }
    }
    /**
     * Update Question Questionniare order.
     * @param  lstOrderOfQQniare : List of Quenstion Questionnaire Ids
     * 
     */
    @AuraEnabled
    public static void setQuestnQnniareOrder(List<Question_Questionnaire__c> lstOrderOfQQniare){        
        if(lstOrderOfQQniare != null && lstOrderOfQQniare.size()>0){
            update lstOrderOfQQniare;
        }
    }

    @AuraEnabled
    public static void updateColumn(String questionaryId,String questionId,String colNum,String selectedSectionId){
        NewCreateTemplateCtr_Handler.updateColumn(questionaryId,questionId,colNum,selectedSectionId);
    }
 

    @AuraEnabled
    public static String saveQuestionResponse(String JSONResponse,String questionaryId, String eventEditiId, string sAccountId )
    {
        String sResponse = NewCreateTemplateCtr_Handler.saveQuestionResponse(JSONResponse, questionaryId, eventEditiId, sAccountId);
        return sResponse;
        }
       
    //CCEN 809 --Start--
     @AuraEnabled
    public static void delAttchmntListIds(list<string> newIdsToDelete)
    {
       Delete([SELECT Id FROM ContentDocument WHERE id IN: newIdsToDelete]);
    }



    

    //BK-6779
    @AuraEnabled
    public static String getFormName(String questionaryId){
        String FormName = '';
        List<Event_Edition_Form__c> listEEFORM = new List<Event_Edition_Form__c>();
        listEEFORM =[Select Forms__r.Name, Template_Form__c FROM Event_Edition_Form__c where Template_Form__c != null AND Template_Form__c =:questionaryId ];//AND Event_Edition__r.Event_Code__c =:eventEditiId LIMIT 1];
        if(listEEFORM.size()>0){
            FormName = listEEFORM[0].Forms__r.Name;
        }
        return FormName;
    }
    
    public class QuestionResponse{
        @AuraEnabled public List<Question_Questionnairesr> Question_Questionnairesr;
    }

    public class Question_Questionnairesr{
        @AuraEnabled public String Question;
        @AuraEnabled public String Id;
        @AuraEnabled public String responseValue1;
        @AuraEnabled public String responseValue2;
        @AuraEnabled public String comment;
        @AuraEnabled public List<BranchingQuestions> branchingQuestnQuetnnaire;
    }

    public class BranchingQuestions{
        @AuraEnabled public String Question;
        @AuraEnabled public String Id;
        @AuraEnabled public String responseValue1;
        @AuraEnabled public String responseValue2;
        @AuraEnabled public String comment;
    }

    @AuraEnabled
    public static res_wrapper getQuestionResponses(String questionnaireId,String sectionId, string sAccountId) 
    {
        String accId = '';
        if(sAccountId != null && sAccountId != '')
        {
            accId = sAccountId;
        }
        String userId = UserInfo.getUserId();     
        User acc=[select id,name,user.AccountId from user where id=:userId];
        if(accId == null || accId == '')
        {
            accId=acc.AccountId;
        }
        String query = 'Select Id,Answer__c,Comment__c,Question__c ,Question__r.Type__c,Questionnaire__c,(SELECT ContentDocumentId,LinkedEntityId, ContentDocument.Title, ContentDocument.ContentSize FROM ContentDocumentLinks) from Question_Response__c WHERE Questionnaire__c=\''+String.escapeSingleQuotes(questionnaireId)+'\'';
        if(accId != null && accId != '')
        {
           query +=  ' AND Account__c=\''+accId+'\'';
        }
        List<sObject> objList = FBUtils.getRecords('Question_Response__c', 'Id', query);
            res_wrapper wrp = new res_wrapper();
         wrp.responses = JSON.serialize(objList);
        Map<Id,Question_Questionnaire__c> qqList = new Map<Id,Question_Questionnaire__c>([Select id from Question_Questionnaire__c WHERE Questionnaire__c=:questionnaireId]);
        if(String.isNotBlank(sectionId)){
            wrp.lstQDynLogic = [Select Id,Question_Questionnaire__c,Question_Questionnaire__r.Question__r.Type__c,Question_Questionnaire__r.Question__c,Question_Option__c,Question_Option__r.Name__c,Show_Question_Questionnaire__c from Questionnaire_Dynamic_Logic__c where Question_Questionnaire__c in:qqList.keySet() AND Question_Group__c =:sectionId];
        }
        else{
            wrp.lstQDynLogic = [Select Id,Question_Questionnaire__c,Question_Questionnaire__r.Question__r.Type__c,Question_Questionnaire__r.Question__c,Question_Option__c,Question_Option__r.Name__c,Show_Question_Questionnaire__c from Questionnaire_Dynamic_Logic__c WHERE Question_Questionnaire__c in:qqList.keySet()];
        }
        return wrp;
    }

    public class res_wrapper 
    {
        @AuraEnabled public string responses;
        @AuraEnabled public List<Questionnaire_Dynamic_Logic__c> lstQDynLogic;
    }
}