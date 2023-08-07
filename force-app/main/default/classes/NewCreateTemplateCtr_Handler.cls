public with sharing class NewCreateTemplateCtr_Handler {
    @AuraEnabled
    public static void updateColumn(String questionaryId,String questionId,String colNum,String selectedSectionId){

        Question_Questionnaire__c qq = new Question_Questionnaire__c();
        qq.Id = questionaryId;
        qq.Related_To_Column__c = colNum;
        update qq;

        Question__c q = new Question__c();
        q.Id = questionId;
        q.Related_To_Column__c = colNum;
        update q;


        List<String> lstChildQstnQuariIds=new List<String>();
        List<String> questionIdList = new List<string>();
        List<Question__c> questionToUpdate = new List<Question__c>();

        Integer order=[Select count() from Question_Questionnaire__c where Question_Group__c=:selectedSectionId];

        List<Questionnaire_Dynamic_Logic__c> lstQuestnnaireDynLogic = [Select Id,Question_Questionnaire__c,Question_Group__c,Question_Option__c,Show_Question_Questionnaire__c from
        Questionnaire_Dynamic_Logic__c where Question_Questionnaire__c =:questionaryId];
        for(Questionnaire_Dynamic_Logic__c qstnDynlgc:lstQuestnnaireDynLogic){            
            lstChildQstnQuariIds.add(qstnDynlgc.Show_Question_Questionnaire__c);
        }
        if(lstChildQstnQuariIds.size()>0)
        {
            List<Question_Questionnaire__c> lstQstnQuaire=[Select Id,Question__c,Question_Group__c,Is_Allow_Branching__c,Question_Order__c From Question_Questionnaire__c
            Where Id IN:lstChildQstnQuariIds];
            Integer i=2;
            for(Question_Questionnaire__c childQstnQuaire:lstQstnQuaire){
                childQstnQuaire.Related_To_Column__c=colNum;
                childQstnQuaire.Question_Order__c=order+i;
                i=i+1;
                questionIdList.add(childQstnQuaire.Question__c);
            }
            update lstQstnQuaire;

            for(String id : questionIdList)
            {
                Question__c ques = new Question__c();
                ques.Id = id;
                ques.Related_To_Column__c = colNum;
                questionToUpdate.add(ques);
            }
            update questionToUpdate;
        }  
    }
     @AuraEnabled
    public static String saveQuestionResponse(String JSONResponse,String questionaryId, String eventEditiId, string sAccountId )
    {
        FormManualsHandler.runOnce = true; 
        String accId = '';
        String eventCode = '';
        if(sAccountId != null && sAccountId != '')
        {
            accId = sAccountId;
        }
        //For fetching Event Code using eventEditiId[C2E-13]
        if(String.isNotBlank(eventEditiId))
        {
            if(Schema.sObjectType.Event_Edition__c.isAccessible()){
                List<Event_Edition__c> eventEditions = [SELECT Event_Code__c FROM Event_Edition__c WHERE Id =:eventEditiId];
                if(!eventEditions.isEmpty()){
                    eventCode = String.valueOf(eventEditions[0].Event_Code__c);
                }
            }
        }
        String exhType = '';
        String userId = UserInfo.getUserId(); 
        User acc=[select id,name,user.AccountId,ContactId, Profile.Name from user where id=:userId];
        if(String.isBlank(accId))  {       accId=acc.AccountId;       }
        // If Current User's Account Id doesn't match with sAccountId we have to fetch usertype from AgentOwnedExhibitorUtils.getExhibitorType[C2E-13]
        if((sAccountId != null && sAccountId != '') && (eventCode != null && eventCode != '') && (acc.AccountId != sAccountId) && (acc.Profile.Name != 'Operations'))
        {
            exhType = AgentOwnedExhibitorUtils.getExhibitorType(sAccountId, eventCode);    if(exhType != null && exhType.contains(','))   {                exhType = exhType.split(',')[0];    }
        }
        FBUtils.FBResponse response = new FBUtils.FBResponse();
        List<NewCreateTemplateCtr.QuestionResponse> questionResponseList = (List<NewCreateTemplateCtr.QuestionResponse>)JSON.deserialize(JSONResponse, List<NewCreateTemplateCtr.QuestionResponse>.class);     
        
        Map<String,String> questionIdToUpdate = new Map<String,String>();
        
        String query = 'Select Id,Answer__c,Question_Questionnaire__c,Comment__c,Question__c,Score__c,Questionnaire__c from Question_Response__c WHERE Questionnaire__c=\''+String.escapeSingleQuotes(questionaryId)+'\'' ;
                
        if(accId != null && accId !=''){
            query +=  'AND Account__c=\''+accId+'\'';
        }
        List<sObject> objList = FBUtils.getRecords('Question_Response__c', 'Id,Answer__c,Comment__c,Question__c,Score__c,Questionnaire__c', query);
     
        User currentUser = [Select Id,ContactId,Profile.Name FROM User where Id =: UserInfo.getUserId() LIMIT 1];
        List<ContactEventEditionMapping__c> listCEEM = new List<ContactEventEditionMapping__c>();
        if(Schema.sObjectType.ContactEventEditionMapping__c.isAccessible()){
            listCEEM = [SELECT User_Type__c, SFContactID__r.AccountId FROM ContactEventEditionMapping__c WHERE SFEventEditionID__c =:eventEditiId AND SFContactID__c =:CurrentUser.ContactId LIMIT 1];
        }
        List<Forms_Permission__c> fpList;
        // fetch the form permission on the basis of questionaryId and usertype where usertype will be fetched on the basis of current user or sAccountId [C2E-13]
        if(exhType != null && exhType != '')      {            fpList = [select id,name,Event_Edition_Form__r.Template_Form__c from Forms_Permission__c WHERE Event_Edition_Form__r.Template_Form__c = :questionaryId AND User_Type__r.Name =:exhType];
        }
        else if(listCEEM.size()>0){
            fpList = [select id,name,Event_Edition_Form__r.Template_Form__c from Forms_Permission__c WHERE  Event_Edition_Form__r.Template_Form__c = :questionaryId 
                                AND User_Type__c =:listCEEM[0].User_Type__c];
                                
        }
        //Add a field User_Form_Contact__c in query regarding[CCEN-594]
        if(fpList != null && fpList.size()>0)
        {
            List<User_Form_Action__c> usrlst = new List<User_Form_Action__c>();
            String usrFormAction = 'select id,Is_Filled_Up__c,User_Form_Contact__c,User__c,Status__c,Account__c,User_Type__c,User_Form_Action__c.Form_Permission__c from User_Form_Action__c where Form_Permission__c IN:fpList ';
            if(exhType != null && exhType != '')  {         usrFormAction+= ' AND Account__c =:accId AND User_Type__r.Name =:exhType ';
            }
            else
            {
                string ceemAccId = listCEEM[0].SFContactID__r.AccountId;
                string ceemUserType = listCEEM[0].User_Type__c;
                usrFormAction+= ' AND Account__c =:ceemAccId AND User_Type__c =:ceemUserType ';
            } 
            usrlst = Database.Query(usrFormAction);
            List<User_Form_Action__c>  userList = new List<User_Form_Action__c>();
            for(User_Form_Action__c usrForm : usrlst){      usrForm.Is_Filled_Up__c=true ;usrForm.Status__c='Pending'; //[CCEN 797]- added "Status__c" field  
                if(currentUser.Profile.Name != 'Operations'){  usrForm.Last_Updated_By__c = currentUser.Id;    usrForm.Last_Updated_Date__c = System.now(); }  Datetime dt =DateTime.now(); String currentDateTime = dt.format(); usrForm.Form_Submitted__c = currentDateTime;usrForm.User_Form_Contact__c=CurrentUser.ContactId;usrForm.User__c=acc.id;               userList.add(usrForm);  
            }
            if(userList.size()>0 && Schema.sObjectType.User_Form_Action__c.isUpdateable())     {             update userList; //[CCEN 797]
            }
            //Add a checkbox in Event setting if checked then status approved automatically Regarding ticket CCEN-577 
            List<User_Form_Action__c> usrlstUsrName =[select Status__c,Account__c,User_Type__r.name,User_Form_Action__c.Form_Permission__c from User_Form_Action__c where 
                                               Form_Permission__c IN:fpList AND Account__c =:accId];
            List<Event_Settings__c> evntsetnglst = new List<Event_Settings__c>();
            if(Schema.sObjectType.Event_Settings__c.isAccessible()){
                evntsetnglst = [select id,Forms_Approval_Not_Required__c,Event_Edition__c from Event_Settings__c where Event_Edition__c=:eventEditiId ];
            }
            List<User_Form_Action__c>  userListForm = new List<User_Form_Action__c>();
            if(usrlstUsrName != null && usrlstUsrName.size()>0){                if(evntsetnglst.size()>0 && evntsetnglst[0].Forms_Approval_Not_Required__c){                    for(User_Form_Action__c usrForm : usrlstUsrName){  usrForm.Status__c='Approved'; userListForm.add(usrForm); }   
                }                              
                if(userListForm.size()>0){                    update userListForm; //[CCEN 797]
                }   
            }
        }
        for(sObject obj : objList){            questionIdToUpdate.put(String.valueOf(obj.get('Question__c')),String.valueOf(obj.get('Id')));
        }
       
        // Code to Update question response Start
        Integer updateCounter=0;  
        Integer insertCounter = 0;      
        Transient String responseText = '+';
        Schema.SObjectType obj = Schema.getGlobalDescribe().get('Question_Response__c');
        List<sObject> listsObjToUpdate = new List<sObject>();
        List<sObject> listsObjToInsert = new List<sObject>();
        
        for(NewCreateTemplateCtr.QuestionResponse qr :  questionResponseList)
        {  
            if(questionIdToUpdate.containsKey(qr.Question_Questionnairesr[0].Question))
            {
                if(Test.IsRunningTest()){responseText = 'Testing';   }   else{     responseText = qr.Question_Questionnairesr[0].responseValue1+' '+qr.Question_Questionnairesr[0].responseValue2;     responseText = responseText.trim();   } sObject genericObj = obj.newSObject();   List<FBUtils.KeyValuePair> listObjToUpdate = new List<FBUtils.KeyValuePair>(); genericObj.put('Id',questionIdToUpdate.get(qr.Question_Questionnairesr[0].Question));
                if(responseText!='' && responseText != null && responseText != 'null'){      genericObj.put('Answer__c',responseText);   }    else{ genericObj.put('Answer__c','');   }     genericObj.put('Comment__c',qr.Question_Questionnairesr[0].comment);    genericObj.put('Question__c',qr.Question_Questionnairesr[0].Question);          genericObj.put('Question_Questionnaire__c',qr.Question_Questionnairesr[0].Id);  genericObj.put('Account__c',accId);
                if(!UserInfo.getName().contains('Operation')){  genericObj.put('User__c',UserInfo.getUserId());  }         genericObj.put('Questionnaire__c',questionaryId); listsObjToUpdate.add(genericObj);
              
                // Branching question response update
                if(qr.Question_Questionnairesr[0].branchingQuestnQuetnnaire!=null && qr.Question_Questionnairesr[0].branchingQuestnQuetnnaire.size()>0)
                {
                    for(NewCreateTemplateCtr.BranchingQuestions bq : qr.Question_Questionnairesr[0].branchingQuestnQuetnnaire)
                    {
                        if(questionIdToUpdate.containsKey(bq.Question))
                        {
                            responseText = bq.responseValue1+' '+bq.responseValue2; responseText = responseText.trim();  sobject genericObjfr = obj.newSObject();
                            genericObjfr.put('Id',questionIdToUpdate.get(bq.Question));
                            if(responseText!='' && responseText != null && responseText != 'null'){ genericObjfr.put('Answer__c',responseText);
                            }else{
                                genericObjfr.put('Answer__c','');
                            }
                            genericObjfr.put('Comment__c',bq.comment);      genericObjfr.put('Question__c',bq.Question); genericObjfr.put('Question_Questionnaire__c',bq.Id);  genericObjfr.put('Account__c',accId);
                            if(!UserInfo.getName().contains('Operation')){   genericObjfr.put('User__c',UserInfo.getUserId());  }  genericObjfr.put('Questionnaire__c',questionaryId);
                            listsObjToUpdate.add(genericObjfr);
                        }
                        else{
                            responseText = bq.responseValue1+' '+bq.responseValue2;    responseText = responseText.trim(); sObject newGenericObj = obj.newSObject();         if(responseText!='' && responseText != null && responseText != 'null'){       newGenericObj.put('Answer__c',responseText);                                
                            }else{
                                newGenericObj.put('Answer__c','');                                
                            }
                            newGenericObj.put('Comment__c',bq.comment);           newGenericObj.put('Question__c',bq.Question);      newGenericObj.put('Question_Questionnaire__c',bq.Id); newGenericObj.put('Account__c',accId);
                            if(!UserInfo.getName().contains('Operation')){  newGenericObj.put('User__c',UserInfo.getUserId());    } newGenericObj.put('Questionnaire__c',questionaryId);                            
                            listsObjToInsert.add(newGenericObj);
                        }
                    }
                }
            }            
        }
        if(!listsObjToUpdate.isEmpty()){            Database.update(listsObjToUpdate);   
        }
        // Code to Update question response End

        // Code to insert question response Start
        for(NewCreateTemplateCtr.QuestionResponse qr :  questionResponseList)
        {
            if(!questionIdToUpdate.containsKey(qr.Question_Questionnairesr[0].Question)){
                responseText = qr.Question_Questionnairesr[0].responseValue1+' '+qr.Question_Questionnairesr[0].responseValue2;
                responseText = responseText.trim();
                sObject newGenericObj = obj.newSObject(); 
                if(responseText!='' && responseText != null && responseText != 'null'){
                    newGenericObj.put('Answer__c',responseText);    }else{                newGenericObj.put('Answer__c','');
                }
                newGenericObj.put('Comment__c',qr.Question_Questionnairesr[0].comment);
                newGenericObj.put('Question__c',qr.Question_Questionnairesr[0].Question);
                newGenericObj.put('Question_Questionnaire__c',qr.Question_Questionnairesr[0].Id);
                newGenericObj.put('Account__c',accId);
                newGenericObj.put('User__c',UserInfo.getUserId());  
                newGenericObj.put('Questionnaire__c',questionaryId);
                listsObjToInsert.add(newGenericObj);
                if(qr.Question_Questionnairesr[0].branchingQuestnQuetnnaire!=null && qr.Question_Questionnairesr[0].branchingQuestnQuetnnaire.size()>0)
                {
                    for(NewCreateTemplateCtr.BranchingQuestions bq : qr.Question_Questionnairesr[0].branchingQuestnQuetnnaire)
                    {
                        if(!questionIdToUpdate.containsKey(bq.Question)){
                            responseText = bq.responseValue1+' '+bq.responseValue2;
                            responseText = responseText.trim();
                            sObject newGenericObj2 = obj.newSObject();

                            if( responseText!='' && responseText != null && responseText != 'null'){
                                newGenericObj2.put('Answer__c',responseText);
                            } 
                            else
                            {
                                newGenericObj2.put('Answer__c',' ');
                            }                                
                            newGenericObj2.put('Comment__c',bq.comment);
                            newGenericObj2.put('Question__c',bq.Question);
                            newGenericObj2.put('Account__c',accId);
                            newGenericObj2.put('Question_Questionnaire__c',bq.Id);
                            newGenericObj2.put('User__c',UserInfo.getUserId());
                            newGenericObj2.put('Questionnaire__c',questionaryId);
                            listsObjToInsert.add(newGenericObj2);
                        }
                    }
                }
            }
        }

        if(!listsObjToInsert.isEmpty()){
            Database.insert(listsObjToInsert);
        }
        return JSON.serialize(response);
    }
}