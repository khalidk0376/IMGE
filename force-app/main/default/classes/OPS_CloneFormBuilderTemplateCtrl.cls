/*
Created By		: Girikon(Sunil[STL-145])
Created On		: Nov 11, 2019
@description 	: This class is used to clone the Form Builder Template.
Test Class		: OPS_CloneFormBuilderTemplateCtrl_Test(96%)

Modification log --
Modified By		: 
*/

public with sharing class OPS_CloneFormBuilderTemplateCtrl {
    /*
    * @description [Clone Form Builder Template]
    * @param  tempId [Template Id]
    * @param  formId [Form Id]  
    */
    @AuraEnabled
    public static void cloneFormBuilderTemplate(String globalFormId, String formId)
    {
        if(string.isNotBlank(globalFormId) && string.isNotBlank(formId))
        {
            
            // List<Questionnaire__c> lstQnaire=new List<Questionnaire__c>();
            list<Form__c> lstForm =[Select Id,Template_Form_Name__c From Form__c Where Id=:globalFormId];
            if(!lstForm.IsEmpty())
            {
                string tempId = lstForm[0].Template_Form_Name__c;
                Questionnaire__c qnaire=[Select Id,Name,Allow_download_copy__c,Binding_Object__c,Category__c,Description__c,Name__c, isMerge__c, Template__c,Send_Copy__c,Version__c,Is_Clone__c
                From Questionnaire__c Where Id=:tempId];
                Questionnaire__c cloneqnaire=qnaire.clone(false);
                cloneqnaire.Name=qnaire.Name;
                cloneqnaire.Version__c=qnaire.Version__c;
                cloneqnaire.isMerge__c=true;
                cloneqnaire.Is_Clone__c=true;
                insert cloneqnaire;
                Event_Edition_Form__c oEditionForm = [SELECT Id, Template_Form__c FROM Event_Edition_Form__c WHERE  Id=:formId];
                //system.debug(oEditionForm);
                if(oEditionForm != null){
                    oEditionForm.Template_Form__c = cloneqnaire.Id;
                    update oEditionForm;
                }
                List<Question_Questionnaire__c> lstQuestionQuestionnaire=[Select Id,Name,Allow_Attachments__c,Allow_Comment__c,Allow_Currency__c,Category__c,Default_Value__c,
                                                                        Comment__c,Currency_Symbol__c,Help_Text__c,Help_Text_Required__c,Decimal_value__c,
                                                                        is_Delete__c,lookup_Object_API_Name__c,lookup_Object_Field_Name__c,Maximum_value__c,Minimum_Value__c,
                                                                        Max_Char_Length__c,Metadata__c,No_Of_Columns__c,Points__c,Question__c,Step_Size__c,
                                                                        Question_Group__c,Questionnaire__c,Question_Order__c,Related_To_Column__c,
                                                                        Required__c,Scoreable__c,Weight__c,Is_Allow_Branching__c,Is_Score_Required__c,Is_Weight_Required__c,background_Color__c From Question_Questionnaire__c Where Questionnaire__c=:tempId and is_delete__c=false];
                Map<String,List<Question_Questionnaire__c>> mapGrpQQ=new Map<String,List<Question_Questionnaire__c>>();
                Map<String,List<Question_Questionnaire__c>> mapQuestionQQ=new Map<String,List<Question_Questionnaire__c>>();
                List<Question_Questionnaire__c> lstCloneQQ= new List<Question_Questionnaire__c>();
                List<String> lstBranchedQstnQriIds= new List<String>();
                // Update tempalte Id in this loop.
                for (Question_Questionnaire__c pi : lstQuestionQuestionnaire) {
                    Question_Questionnaire__c newQQ = pi.clone(false);
                    newQQ.Questionnaire__c = cloneqnaire.id;
                    lstCloneQQ.add(newQQ);
                    if(pi.Is_Allow_Branching__c==true){
                        lstBranchedQstnQriIds.add(pi.Id);
                    }
                }
                
                // Get the Question dynamic branching
                List<Questionnaire_Dynamic_Logic__c> lstQstnDynamicLgc=[Select Id,Question_Group__c,Question_Option__c,Question_Questionnaire__c,
                                                                        Show_Question_Questionnaire__c From Questionnaire_Dynamic_Logic__c Where Question_Questionnaire__c IN:lstBranchedQstnQriIds];
                //System.debug('lstBranchedQstnQriIds:='+lstBranchedQstnQriIds);
                
                Map<String,List<Questionnaire_Dynamic_Logic__c>> mapQstnGrpWithDynQstns=new Map<String,List<Questionnaire_Dynamic_Logic__c>>();
                List<Questionnaire_Dynamic_Logic__c> lstCloneDynLogic=new List<Questionnaire_Dynamic_Logic__c>();
                for(Questionnaire_Dynamic_Logic__c qstnDyn:lstQstnDynamicLgc){
                    Questionnaire_Dynamic_Logic__c qstnaireDynLogic=qstnDyn.clone(false);
                    lstCloneDynLogic.add(qstnaireDynLogic);
                    //qstnaireDynLogic.Question_Group__c=
                }
                // Create the map with Question group as key and value Questionnaire_Dynamic_Logic__c record.
                for(Questionnaire_Dynamic_Logic__c qstnDyn : lstCloneDynLogic){
                    if(mapQstnGrpWithDynQstns.containsKey(qstnDyn.Question_Group__c)){
                        List<Questionnaire_Dynamic_Logic__c> lstMapQstnDynLgc=mapQstnGrpWithDynQstns.get(qstnDyn.Question_Group__c);
                        lstMapQstnDynLgc.add(qstnDyn);
                        mapQstnGrpWithDynQstns.put(qstnDyn.Question_Group__c,lstMapQstnDynLgc);
                    }
                    else{
                        List<Questionnaire_Dynamic_Logic__c> lstQstnDynLgc=new List<Questionnaire_Dynamic_Logic__c>();
                        lstQstnDynLgc.add(qstnDyn);
                        mapQstnGrpWithDynQstns.put(qstnDyn.Question_Group__c,lstQstnDynLgc);
                    }
                }
                
                for(Question_Questionnaire__c qq : lstCloneQQ){
                    if(mapGrpQQ.containsKey(qq.Question_Group__c)){
                        List<Question_Questionnaire__c> lstmapQQ=mapGrpQQ.get(qq.Question_Group__c);
                        lstmapQQ.add(qq);
                        mapGrpQQ.put(qq.Question_Group__c,lstmapQQ);
                    }
                    else{
                        List<Question_Questionnaire__c> lstQQ=new List<Question_Questionnaire__c>();
                        lstQQ.add(qq);
                        mapGrpQQ.put(qq.Question_Group__c,lstQQ);
                    }
                }
                
                Set<String> qustnGroupIds=mapGrpQQ.keySet();
                List<Question_Questionnaire__c> lstQstnQuriWithNewgrp=new List<Question_Questionnaire__c>();
                List<Questionnaire_Dynamic_Logic__c> lstDynQstnWithNewgrp=new List<Questionnaire_Dynamic_Logic__c>();
                List<Question_Group__c> lstQstnGroup=[Select Id,Name,is_Delete__c,Name__c,No_Of_Columns__c,Score__c,Sort_Order__c from Question_Group__c 
                                                    Where Id IN:qustnGroupIds and is_Delete__c=false];
                
                //Map<String,>
                List<Question_Group__c> lstCloneQstnGroup=new List<Question_Group__c>();
                List<Question_Group__c> lstCloneUpdateQstnGroup=new List<Question_Group__c>();
                for(Question_Group__c qstnGroup:lstQstnGroup){
                    Question_Group__c cloneQstnGrp=qstnGroup.clone(false);
                    cloneQstnGrp.Name=qstnGroup.Name+'~'+qstnGroup.id;
                    lstCloneQstnGroup.add(cloneQstnGrp);
                }
                if(lstCloneQstnGroup!=null && lstCloneQstnGroup.size()>0){
                    insert lstCloneQstnGroup; 
                    for(Question_Group__c qstnGroup:lstCloneQstnGroup){
                        String name=qstnGroup.Name;
                        List<String> nameSplitWithGrpId=name.split('~');
                        qstnGroup.Name=nameSplitWithGrpId[0];
                        lstCloneUpdateQstnGroup.add(qstnGroup);
                        List<Question_Questionnaire__c> lstQstnQsri=mapGrpQQ.get(nameSplitWithGrpId[1]);
                        List<Questionnaire_Dynamic_Logic__c> lstDynQstns=mapQstnGrpWithDynQstns.get(nameSplitWithGrpId[1]);
                        //Update new question group Id in to question_questionnaire record
                        if(lstQstnQsri!=null && lstQstnQsri.size()>0){
                            for(Question_Questionnaire__c qq:lstQstnQsri){
                                qq.Question_Group__c=qstnGroup.id;
                                lstQstnQuriWithNewgrp.add(qq);
                            }
                        }
                        //Update new question group Id in to Dynamic question logic record
                        if(lstDynQstns!=null && lstDynQstns.size()>0){
                            for(Questionnaire_Dynamic_Logic__c dynQstn:lstDynQstns){
                                dynQstn.Question_Group__c=qstnGroup.id;
                                lstDynQstnWithNewgrp.add(dynQstn);
                            }
                        }
                    }
                    update lstCloneUpdateQstnGroup;
                }
                System.debug('lstDynQstnWithNewgrp:='+lstDynQstnWithNewgrp);
                Map<String,List<Question_Questionnaire__c>> mapQstnQuriWithNewQuestions=new Map<String,List<Question_Questionnaire__c>>();
                List<Question_Questionnaire__c> lstQstnQuriWithOutQuestions=new List<Question_Questionnaire__c>();
                // Get all the question related to question_questionnaire
                for(Question_Questionnaire__c qq:lstQstnQuriWithNewgrp){
                    if(qq.Question__c!=null){
                        if(mapGrpQQ.containsKey(qq.Question__c)){
                            List<Question_Questionnaire__c> lstmapQQ=mapGrpQQ.get(qq.Question__c);
                            lstmapQQ.add(qq);
                            mapQstnQuriWithNewQuestions.put(qq.Question__c,lstmapQQ);
                        }
                        else{
                            List<Question_Questionnaire__c> lstQQ=new List<Question_Questionnaire__c>();
                            lstQQ.add(qq);
                            mapQstnQuriWithNewQuestions.put(qq.Question__c,lstQQ);
                        }
                    }
                    else{
                        lstQstnQuriWithOutQuestions.add(qq);
                    }
                }
                
                // Create Map with key as Question_Option__c and value Questionnaire_Dynamic_Logic__c record
                Map<String,List<Questionnaire_Dynamic_Logic__c>> mapmainQstnOptnWithDynQstn=new Map<String,List<Questionnaire_Dynamic_Logic__c>>();
                // Get all the question related to question_questionnaire
                for(Questionnaire_Dynamic_Logic__c qstnDynWithNewGrp:lstDynQstnWithNewgrp){
                    if(qstnDynWithNewGrp.Question_Option__c!=null){
                        if(mapmainQstnOptnWithDynQstn.containsKey(qstnDynWithNewGrp.Question_Option__c)){
                            List<Questionnaire_Dynamic_Logic__c> lstDynQstn=mapmainQstnOptnWithDynQstn.get(qstnDynWithNewGrp.Question_Option__c);
                            lstDynQstn.add(qstnDynWithNewGrp);
                            mapmainQstnOptnWithDynQstn.put(qstnDynWithNewGrp.Question_Option__c,lstDynQstn);
                        }
                        else{
                            List<Questionnaire_Dynamic_Logic__c> lstDynlgc=new List<Questionnaire_Dynamic_Logic__c>();
                            lstDynlgc.add(qstnDynWithNewGrp);
                            mapmainQstnOptnWithDynQstn.put(qstnDynWithNewGrp.Question_Option__c,lstDynlgc);
                        }
                    }
                }
                System.debug('mapmainQstnOptnWithDynQstn:='+mapmainQstnOptnWithDynQstn);
                Set<String> qustionsIds=mapQstnQuriWithNewQuestions.keySet();
                List<Question_Option__c> lstCloneQuestionOptions=new List<Question_Option__c>();
                List<Question_Questionnaire__c> lstCloneQuestionQuestionnaire=new List<Question_Questionnaire__c>();
                List<Question__c> lstQuestions=[Select Id,Name,Allow_Attachments__c,Allow_Comment__c,Allow_Currency__c,Category__c,Currency_Symbol__c,Decimal_value__c,Default_Value__c,
                                                Help_Text__c,Help_Text_Required__c,Is_Approve_For_Library__c,is_Delete__c,Label__c,
                                                lookup_Object_API_Name__c,lookup_Object_Field_Name__c,Max_Char_Length__c,
                                                Maximum_value__c,Metadata__c,Minimum_Value__c,Name__c,No_Of_Columns__c,Question_Library__c,
                                                Related_To_Column__c,Required__c,Step_Size__c,Type__c,Weight__c,Is_Allow_Branching__c,Is_Weight_Required__c,Is_Score_Required__c,background_Color__c,(Select Id,Name,Index__c,Name__c,Question__c,Score__c,Value__c,Weight__c From Question_Options__r) From Question__c Where Id IN:qustionsIds and is_Delete__c=false];
                        
                List<Question__c> lstCloneQstn=new List<Question__c>();
                List<Question__c> lstCloneUpdateQstnName=new List<Question__c>();
                List<String> lstOldQuestionIds=new List<String>();
                for(Question__c question:lstQuestions){
                    Question__c cloneQuestion=question.clone(false);
                    cloneQuestion.Name=question.Name+'~'+question.id;
                    lstCloneQstn.add(cloneQuestion); 
                    lstOldQuestionIds.add(question.id);
                }
                // Insert cloned question with old question id append with name.
                if(lstCloneQstn!=null && lstCloneQstn.size()>0){
                    insert lstCloneQstn;
                    // Get question options with old question from name and attach new question id with question option.
                    List<Question_Option__c> lstQstnOptions=[Select Id,Name,Index__c,Name__c,Question__c,Score__c,Value__c,Weight__c From Question_Option__c Where Question__c IN:lstOldQuestionIds];
                    List<Question_Questionnaire__c> lstOldQstnQueries=[Select Id,Name,Question__c From Question_Questionnaire__c Where Question__c IN:lstOldQuestionIds];
                    for(Question__c question:lstCloneQstn){
                        String name=question.Name;
                        List<String> nameSplitWithQstnId=name.split('~');
                        question.name=nameSplitWithQstnId[0];
                        lstCloneUpdateQstnName.add(question);
                        
                        // Get question_questionnaire with this old question Id and update new question id.
                        List<Question_Questionnaire__c> lstQstnQure=mapQstnQuriWithNewQuestions.get(nameSplitWithQstnId[1]);
                        if(lstQstnQure!=null && lstQstnQure.size()>0){
                            for(Question_Questionnaire__c oldQstnQri:lstOldQstnQueries){
                                for(Question_Questionnaire__c qq:lstQstnQure){
                                    if(oldQstnQri.Question__c==nameSplitWithQstnId[1])
                                    {
                                        qq.Question__c=question.id;
                                        qq.Name=qq.Name+'~'+oldQstnQri.Id;
                                        lstCloneQuestionQuestionnaire.add(qq);
                                    }
                                }
                            }
                            
                            
                        }
                        // Update cloned question id in question options
                        if(lstQstnOptions!=null && lstQstnOptions.size()>0){
                            for(Question_Option__c qo:lstQstnOptions){
                                if(qo.Question__c==nameSplitWithQstnId[1]){
                                    Question_Option__c cloneQstnOptn=qo.clone(false);
                                    cloneQstnOptn.Question__c=question.id;
                                    cloneQstnOptn.Name=qo.Name+'~'+qo.id;
                                    lstCloneQuestionOptions.add(cloneQstnOptn);
                                }
                            }   
                        }
                    }
                    // Update cloned question without old question id
                    update lstCloneUpdateQstnName;
                }
                List<Questionnaire_Dynamic_Logic__c> lstDynQstnWithNewQstnOptions=new List<Questionnaire_Dynamic_Logic__c>();
                List<Questionnaire_Dynamic_Logic__c> lstDynQstnWithNewBranchedQstnQri=new List<Questionnaire_Dynamic_Logic__c>();
                if(lstQstnQuriWithOutQuestions.size()>0){
                    insert lstQstnQuriWithOutQuestions;
                }
                if(lstCloneQuestionOptions.size()>0){
                    insert lstCloneQuestionOptions;
                    List<Question_Option__c> lstUpdateCloneQuestionOptionsName=new List<Question_Option__c>();
                    for(Question_Option__c newQstnOption:lstCloneQuestionOptions){
                        String name=newQstnOption.Name;
                        List<String> nameSplitOptionId=name.split('~');
                        newQstnOption.Name=nameSplitOptionId[0];
                        lstUpdateCloneQuestionOptionsName.add(newQstnOption);
                        List<Questionnaire_Dynamic_Logic__c> lstDynQstns=mapmainQstnOptnWithDynQstn.get(nameSplitOptionId[1]);
                        //Update new question Option Id in to Dynamic question logic record
                        if(lstDynQstns!=null && lstDynQstns.size()>0){
                            for(Questionnaire_Dynamic_Logic__c dynQstn:lstDynQstns){
                                dynQstn.Question_Option__c=newQstnOption.id;
                                lstDynQstnWithNewQstnOptions.add(dynQstn);
                            }
                        }
                    }
                    update lstUpdateCloneQuestionOptionsName;
                }
                // Create Map with parent question key of Question_Questionnaire__c and value Questionnaire_Dynamic_Logic__c record
                Map<String,List<Questionnaire_Dynamic_Logic__c>> mapmainQstnQriWithDynQstn=new Map<String,List<Questionnaire_Dynamic_Logic__c>>();
                // Get all the question related to question_questionnaire
                for(Questionnaire_Dynamic_Logic__c qstnDynWithNewQstnOptn:lstDynQstnWithNewQstnOptions){
                    if(qstnDynWithNewQstnOptn.Question_Questionnaire__c!=null){
                        if(mapmainQstnQriWithDynQstn.containsKey(qstnDynWithNewQstnOptn.Question_Questionnaire__c)){
                            List<Questionnaire_Dynamic_Logic__c> lstDynQstn=mapmainQstnQriWithDynQstn.get(qstnDynWithNewQstnOptn.Question_Questionnaire__c);
                            lstDynQstn.add(qstnDynWithNewQstnOptn);
                            mapmainQstnQriWithDynQstn.put(qstnDynWithNewQstnOptn.Question_Questionnaire__c,lstDynQstn);
                        }
                        else{
                            List<Questionnaire_Dynamic_Logic__c> lstDynlgc=new List<Questionnaire_Dynamic_Logic__c>();
                            lstDynlgc.add(qstnDynWithNewQstnOptn);
                            mapmainQstnQriWithDynQstn.put(qstnDynWithNewQstnOptn.Question_Questionnaire__c,lstDynlgc);
                        }
                    }
                }
                if(lstCloneQuestionQuestionnaire.size()>0){
                    insert lstCloneQuestionQuestionnaire;
                    List<Question_Questionnaire__c> lstUpdateCloneQuestionQriName=new List<Question_Questionnaire__c>();
                    List<Questionnaire_Dynamic_Logic__c> lstDynQstnWithNewMainQstnQri=new List<Questionnaire_Dynamic_Logic__c>();
                    // Update main Question_Questionnaire__c in dynamic qstn
                    for(Question_Questionnaire__c newQstnQri:lstCloneQuestionQuestionnaire){
                        String name=newQstnQri.Name;
                        List<String> nameSplitQstnQriId=name.split('~');
                        List<Questionnaire_Dynamic_Logic__c> lstDynQstns=mapmainQstnQriWithDynQstn.get(nameSplitQstnQriId[1]);
                        //Update new question Questionnaire Id in to Dynamic question logic record
                        if(lstDynQstns!=null && lstDynQstns.size()>0){
                            for(Questionnaire_Dynamic_Logic__c dynQstn:lstDynQstns){
                                dynQstn.Question_Questionnaire__c=newQstnQri.id;
                                lstDynQstnWithNewMainQstnQri.add(dynQstn);
                            }
                        }
                    }
                    // Create Map with branched question_questionnaire as key and value Questionnaire_Dynamic_Logic__c record
                    Map<String,List<Questionnaire_Dynamic_Logic__c>> mapmainBranchedQstnQriWithDynQstn=new Map<String,List<Questionnaire_Dynamic_Logic__c>>();
                    // Get all the question related to question_questionnaire
                    for(Questionnaire_Dynamic_Logic__c qstnDynWithNewMainQstnQri:lstDynQstnWithNewMainQstnQri){
                        if(qstnDynWithNewMainQstnQri.Show_Question_Questionnaire__c !=null){
                            if(mapmainBranchedQstnQriWithDynQstn.containsKey(qstnDynWithNewMainQstnQri.Show_Question_Questionnaire__c)){
                                List<Questionnaire_Dynamic_Logic__c> lstDynQstn=mapmainBranchedQstnQriWithDynQstn.get(qstnDynWithNewMainQstnQri.Show_Question_Questionnaire__c);
                                lstDynQstn.add(qstnDynWithNewMainQstnQri);
                                mapmainBranchedQstnQriWithDynQstn.put(qstnDynWithNewMainQstnQri.Show_Question_Questionnaire__c,lstDynQstn);
                            }
                            else{
                                List<Questionnaire_Dynamic_Logic__c> lstDynlgc=new List<Questionnaire_Dynamic_Logic__c>();
                                lstDynlgc.add(qstnDynWithNewMainQstnQri);
                                mapmainBranchedQstnQriWithDynQstn.put(qstnDynWithNewMainQstnQri.Show_Question_Questionnaire__c,lstDynlgc);
                            }
                        }
                    }
                    
                    // Update branched  question -- Show_Question_Questionnaire__c in dynamic qstn list
                    for(Question_Questionnaire__c newQstnQri:lstCloneQuestionQuestionnaire){
                        String name=newQstnQri.Name;
                        List<String> nameSplitQstnQriId=name.split('~');
                        newQstnQri.Name=nameSplitQstnQriId[0];
                        lstUpdateCloneQuestionQriName.add(newQstnQri);
                        List<Questionnaire_Dynamic_Logic__c> lstDynQstns=mapmainBranchedQstnQriWithDynQstn.get(nameSplitQstnQriId[1]);
                        //Update new question Questionnaire Id in to Dynamic question logic record
                        if(lstDynQstns!=null && lstDynQstns.size()>0){
                            for(Questionnaire_Dynamic_Logic__c dynQstn:lstDynQstns){
                                dynQstn.Show_Question_Questionnaire__c=newQstnQri.id;
                                lstDynQstnWithNewBranchedQstnQri.add(dynQstn);
                            }
                        }
                    }
                    update lstUpdateCloneQuestionQriName;
                }
                if(lstDynQstnWithNewBranchedQstnQri.size()>0){
                    insert lstDynQstnWithNewBranchedQstnQri;
                }
                    //lstQnaire=[Select id,Name From Questionnaire__c Order by CreatedDate desc LIMIT 40];
            }

        }
    }
}