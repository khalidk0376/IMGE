({
    callScriptsLoaded: function(component, event) {
        var self = this;
        //$(".dropSection").sortable();
        var isSortAllQuestion = false;
        $(".selecttableField").draggable({
            helper: 'clone',
            revert: "invalid",
            tolerance: "fit",
            // appendTo: "body",
            zIndex: 10000,
            //connectToSortable: '.sortableArea',
            //cursorAt: { top: 200 },
            start: function(event, ui) {

                $(ui.helper).addClass("ui-draggable-helper");
                $(ui.helper).width($('.selecttableField').width());

                // $(ui.helper).css('background-color', '#727272'); 
                // $(ui.helper).find('.slds-icon-text-default').css('fill', 'rgb(255, 255, 255)');
                //$(ui.helper).css('color', '#fff'); 
                //$("#question-builder-panel").css('overflow', 'visible');
                if ($(".qf-left-panel").hasClass("slds-is-fixed")) {

                } else {
                    $(ui.helper).css('margin-top', '-180px');
                }
                //$(ui.helper).css('margin-top', '-180px');
            }

        });

        $(".dropSection").droppable({
            accept: ".selecttableField",
            drop: function(event, ui) {
                var dropped = ui.draggable;
                
                //$("#question-builder-panel").css('overflow', 'scroll');
                component.set("v.dropColNumber", $(this).attr("id"));
                component.set("v.dragId", $(dropped).attr("id"));
                component.set("v.modalHeader", $(dropped).attr("id"));
                component.set("v.isEditQue", false);

                if ($(dropped).attr("id") === "Date") {
                    component.set("v.isShowDateModal", true);
                } else if ($(dropped).attr("id") === "URL") {
                    component.set("v.isShowURLModal", true);
                }else if ($(dropped).attr("id") === "Header/Footer") {
                    component.set("v.isShowHeaderModal", true);
                } else if ($(dropped).attr("id") === "DateTime") {
                    component.set("v.isShowDatetimeModal", true);
                } else if ($(dropped).attr("id") === "TextPlain") {
                    component.set("v.isShowTextPlainModal", true);
                } else if ($(dropped).attr("id") === "RichText") {
                    component.set("v.isShowRichTextModal", true);
                } else if ($(dropped).attr("id") === "Address") {
                    component.set("v.isShowAddressModal", true);
                } else if ($(dropped).attr("id") === "Email") {
                    component.set("v.isShowEmailModal", true);
                } else if ($(dropped).attr("id") === "Phone") {
                    component.set("v.isShowPhoneModal", true);
                } else if ($(dropped).attr("id") === "Information") {
                    component.set("v.isShowInformationModal", true);
                } else if ($(dropped).attr("id") === "Checkbox") {
                    component.set("v.isShowCheckboxModal", true);
                }
                else if ($(dropped).attr("id") === "Radio") {
                    component.set("v.isShowRadioModal", true);
                }
                else if ($(dropped).attr("id") === "Picklist") {
                    component.set("v.isShowPicklistModal", true);
                } else if ($(dropped).attr("id") === "Number") {
                    component.set("v.isShowNumberAndCurrencyModal", true);
                } else if ($(dropped).attr("id") === "Lookup") {
                    component.set("v.isShowLookupModal", true);
                } else if ($(dropped).attr("id") === "Signature") {
                    component.set("v.isShowSignatureModal", true);
                } else if ($(dropped).attr("id") === "Switch") {
                    component.set("v.isShowSwitchModal", true);
                } else if ($(dropped).attr("id") === "Slider") {
                    component.set("v.isShowSliderModal", true);
                } else if ($(dropped).attr("id") === "GPS Location") {
                    component.set("v.isShowGPSLocationModal", true);
                } else if ($(dropped).attr("id") === "Media") {
                    component.set("v.isShowMediaModal", true);
                } else {
                    component.set("v.isShowModal", true);
                }

            },
            over: function(event, elem) {
                $(this).addClass("dropSectionHighlight");
            },
            out: function(event, elem) {
                $(this).removeClass("dropSectionHighlight");
            }
        });
        var qqid = '',qid='';
        //Start sorting code
        $("#sortableArea1,#sortableArea2,#sortableArea3").sortable({
            placeholder: "ui-state-highlight",
            scroll: false,
            connectWith: ".sortableArea",
            cursor: "move",
            start: function(e, ui) {
                // creates a temporary attribute on the element with the old index
                $(this).attr('data-previndex', ui.item.index());
                $(this).attr('data-id', ui.item.parent().attr('id'));
                $(this).attr('data-qqid', ui.item.attr('data-qqid'));
                $(this).attr('data-qid', ui.item.attr('data-qid'));
            },
            update: function(e, ui) {
                // gets the new and old index then removes the temporary attribute
                var newIndex = parseInt(ui.item.index(),10);
                var oldIndex = parseInt($(this).attr('data-previndex'),10);
                component.set("v.Spinner",true);
                var lstQuestn = component.get("v.lstQQuesnnaire.lstQuestn");
                var lstQuestion_Questionnaires = [];
                var colNum = $(this).attr("id").replace('sortableArea','');
                
                if($(this).attr('data-qqid')!=undefined){
                    qqid = $(this).attr('data-qqid');   
                }
                if($(this).attr('data-qid')!=undefined){
                    qid = $(this).attr('data-qid'); 
                }

               // alert($(this).attr('data-qqid')+':::'+$(this).attr('data-qid'));

                if($(this).attr('data-id')!=$(this).attr("id")){
                    self.updateColumn(component,qqid,qid,'col'+colNum);
                    //alert('in-side if: '+$(this).attr("id")+'::::'+colNum+'::::'+$(this).attr('data-id'));
                    return;
                }

                
                if(oldIndex>newIndex){

                    //down to up sorting code..
                    var Obj_Question_QuestionnairesDown = {
                        sobjectType: 'Question_Questionnaire__c',
                        Id: lstQuestn[oldIndex].Question_Questionnaires__r[0].Id,
                        Question_Order__c:  newIndex
                    };
                    var qOrder =newIndex;
                    lstQuestion_Questionnaires.push(Obj_Question_QuestionnairesDown);
                    console.log(lstQuestion_Questionnaires);
                    //checking this question has branching
                    
                    if(lstQuestn[oldIndex].Question_Questionnaires__r[0].branchingQuestnQuetnnaire !== undefined){
                        var branchingQuestnQuetnnaireOldIndex =lstQuestn[oldIndex].Question_Questionnaires__r[0].branchingQuestnQuetnnaire ;
                        for(var indexSortbranchingQuestnQuetnnaireOld=0; indexSortbranchingQuestnQuetnnaireOld<branchingQuestnQuetnnaireOldIndex.length;indexSortbranchingQuestnQuetnnaireOld++){
                           
                            qOrder=qOrder+1;
                            var Obj_Question_QuestionnairesOldNew = {
                                sobjectType: 'Question_Questionnaire__c',
                                Id : branchingQuestnQuetnnaireOldIndex[indexSortbranchingQuestnQuetnnaireOld].Id,
                                Question_Order__c : qOrder
                            };
                            lstQuestion_Questionnaires.push(Obj_Question_QuestionnairesOldNew);
                        }
                    }
                    for (var varQuestn = newIndex; varQuestn < lstQuestn.length; varQuestn++) {
                        
                        if(lstQuestn[oldIndex].Question_Questionnaires__r[0].Id !== lstQuestn[varQuestn].Question_Questionnaires__r[0].Id){
                             qOrder =qOrder+1;
                            var Obj_Question_QuestionnairesNew = {
                                sobjectType: 'Question_Questionnaire__c',
                                Id: lstQuestn[varQuestn].Question_Questionnaires__r[0].Id,
                                Question_Order__c: qOrder
                            };
                           
                            lstQuestion_Questionnaires.push(Obj_Question_QuestionnairesNew);
                            var branchingQuestnQuetnnaire =lstQuestn[varQuestn].Question_Questionnaires__r[0].branchingQuestnQuetnnaire ;
                            if(branchingQuestnQuetnnaire !== undefined && branchingQuestnQuetnnaire.length>0){
                                for(var indexSortbranchingQuestnQuetnnaire=0; indexSortbranchingQuestnQuetnnaire<branchingQuestnQuetnnaire.length;indexSortbranchingQuestnQuetnnaire++){
                                    
                                    qOrder=qOrder+1;
                                    var Obj_QQuestionnairesOld = {
                                        sobjectType: 'Question_Questionnaire__c',
                                        Id : branchingQuestnQuetnnaire[indexSortbranchingQuestnQuetnnaire].Id,
                                        Question_Order__c : qOrder
                                    };
                                    lstQuestion_Questionnaires.push(Obj_QQuestionnairesOld);
                                }
                            }
                        }
                    }
                }
                else{
                    //up to down sorting code..
                    var upQOrder = oldIndex;
                    for (var varUpQuestn = upQOrder; varUpQuestn < lstQuestn.length; varUpQuestn++) {
                        if(lstQuestn[oldIndex].Question_Questionnaires__r[0].Id !== lstQuestn[varUpQuestn].Question_Questionnaires__r[0].Id){

                            var Obj_Question_QuestionnairesUp = {
                                sobjectType: 'Question_Questionnaire__c',
                                Id : lstQuestn[varUpQuestn].Question_Questionnaires__r[0].Id,
                                Question_Order__c : upQOrder
                            };
                            lstQuestion_Questionnaires.push(Obj_Question_QuestionnairesUp);
                            upQOrder++;
                            var branchingQuestnQuetnnaireUpAndDown =lstQuestn[varUpQuestn].Question_Questionnaires__r[0].branchingQuestnQuetnnaire ;
                            if(branchingQuestnQuetnnaireUpAndDown !== undefined && branchingQuestnQuetnnaireUpAndDown.length>0){
                                for(var indexSortbranchingQQnnaire=0; indexSortbranchingQQnnaire<branchingQuestnQuetnnaireUpAndDown.length;indexSortbranchingQQnnaire++){
                                    
                                    var Obj_Question_QuestionnairesUpDown = {
                                        sobjectType: 'Question_Questionnaire__c',
                                        Id : branchingQuestnQuetnnaireUpAndDown[indexSortbranchingQQnnaire].Id,
                                        Question_Order__c : upQOrder
                                    };
                                    lstQuestion_Questionnaires.push(Obj_Question_QuestionnairesUpDown);
                                     upQOrder++;
                                }
                            }
                            
                        }
                        if( lstQuestn[varUpQuestn].Question_Questionnaires__r[0].Id === lstQuestn[newIndex].Question_Questionnaires__r[0].Id)
                        {
                            
                            var Obj_Question_QuestionnairesUpDownLast = {
                                sobjectType: 'Question_Questionnaire__c',
                                Id : lstQuestn[oldIndex].Question_Questionnaires__r[0].Id,
                                Question_Order__c : upQOrder
                            };
                            lstQuestion_Questionnaires.push(Obj_Question_QuestionnairesUpDownLast);
                            upQOrder++;
                            var mainBranchingQQnnaire =lstQuestn[oldIndex].Question_Questionnaires__r[0].branchingQuestnQuetnnaire ;
                            if(mainBranchingQQnnaire !== undefined && mainBranchingQQnnaire.length>0){
                                for(var pointSortbranchingQQnnaire=0; pointSortbranchingQQnnaire<mainBranchingQQnnaire.length;pointSortbranchingQQnnaire++){
                                    var Obj_Question_QuestionnairesChild = {
                                        sobjectType: 'Question_Questionnaire__c',
                                        Id : mainBranchingQQnnaire[pointSortbranchingQQnnaire].Id,
                                        Question_Order__c : upQOrder
                                    };
                                    lstQuestion_Questionnaires.push(Obj_Question_QuestionnairesChild);
                                     upQOrder++;
                                }
                            }
                        }
                    }
                }
                if(lstQuestion_Questionnaires !== undefined && lstQuestion_Questionnaires !== null && lstQuestion_Questionnaires.length>0){
                    console.log(lstQuestion_Questionnaires);
                    var action = component.get("c.setQuestnQnniareOrder"); //Calling Apex class controller 'setQuestnQnniareOrder' method
                    action.setParams({
                        lstOrderOfQQniare: lstQuestion_Questionnaires
                    });
                    action.setCallback(this, function(res) {
                        var state = res.getState();
                        if (state === "SUCCESS") {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title: 'Success',
                                message: "Successfully re-order question",
                                duration: '500',
                                key: 'info_alt',
                                type: 'SUCCESS',
                                mode: 'dismissible'
                            });
                            toastEvent.fire();
                            isSortAllQuestion = true;
                            var oldQues = lstQuestn[oldIndex];
                            lstQuestn.splice(oldIndex,1);
                            lstQuestn.splice(newIndex, 0, oldQues);
                            component.set("v.lstQQuesnnaire.lstQuestn",lstQuestn);
                            component.set("v.Spinner",false);
                            
                        } else {
                            var toastEventError = $A.get("e.force:showToast");
                            toastEventError.setParams({
                                "title": "Error :",
                                "mode": "sticky",
                                "message": res.getError()[0].message
                            });
                            toastEventError.fire();
                        }
                    });
                    $A.enqueueAction(action);
                }
            }
        });
        $("#sortableArea1,#sortableArea2,#sortableArea3").disableSelection();
        //End sorting code
        $(".questionBuilder-left-box").height($(window).height() - $(".cQFQuesLibraryComp").height() - 350);
        var win_height = $(window).height();
        window.onscroll = function() {
            var _top = 88; 
            if (document.body.scrollTop > 180 || document.documentElement.scrollTop > 180) {
                var questnLfPanel = component.get("v.questnLfPanel");
                if (!questnLfPanel) {

                    var LftWidth = component.find('lftPnlDiv').getElement().offsetWidth;
                    var styleVal = 'width :' + LftWidth + 'px;';
                    var questionBuilderleftbox = 'height :' + (win_height - 250) + 'px;';
                    styleVal = styleVal + ' height :' + (win_height - 180) + 'px;';
                    styleVal = styleVal + ' top :' + (_top + 3) + 'px;';
                    component.set("v.questionBuilderleftbox", questionBuilderleftbox);
                    component.set("v.questnLfPanelStyleValue", styleVal);
                    component.set("v.questnLfPanel", " slds-is-fixed");
                }
            } else {
                var questnLfPanelVal = component.get("v.questnLfPanel");
                if (questnLfPanelVal === " slds-is-fixed") {
                    component.set("v.questnLfPanel", "");
                    component.set("v.questnLfPanelStyleValue", "");
                    component.set("v.questionBuilderleftbox", 'height :' + (win_height - 350) + 'px;');
                }
            }
        }
        

    },

    updateColumn:function(component,questionaryId,questionId,colNum)
    {
        var action = component.get("c.updateColumn"); //Calling Apex class controller 'getTemplateRecrod' method
        action.setParams({
            questionaryId:questionaryId,
            questionId:questionId,
            colNum:colNum
        });
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {
                
            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error :",
                    "mode": "sticky",
                    "message": res.getError()[0].message
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },

    getQuestionnaireRecord: function(component, event) {
        var vQnaireId = component.get("v.QnaireId");
        var vSectionId = '';
        this.getTempRecord(component, event, vQnaireId);
        this.getQuesGroupRecord(component, event, vQnaireId, "");

    },
    getTempRecord: function(component, event, vQnaireId) {
        var action = component.get("c.getTemplateRecord"); //Calling Apex class controller 'getTemplateRecrod' method
        action.setParams({
            qnaireId: vQnaireId
        });
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {
                if (res.getReturnValue().is_Published__c === true) {
                    var appEvent = $A.get("e.c:QFSetActiveHeaderEvt");
                    appEvent.setParams({ "compName": "search" });
                    appEvent.fire();
                } else {
                    component.set("v.objQnaire", res.getReturnValue());
                    component.set("v.QnaireName", component.get("v.objQnaire.Name"));
                }

            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error :",
                    "mode": "sticky",
                    "message": res.getError()[0].message
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    getQuesGroupRecord: function(component, event, vQnaireId, type) {
        var action = component.get("c.getAllQuestnGrpNameForQuesnnaire"); //Calling Apex class controller 'getAllQuestnGrpNameForQuesnnaire' method
        action.setParams({
            sQnaireId: vQnaireId
        });
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {
                component.set("v.lstQuesGroup", res.getReturnValue());
                var lstQGroup = component.get("v.lstQuesGroup");
                if (type === "delete section") {
                    component.set("v.selTabId", lstQGroup[0].Question_Group__c);
                    this.getAllQuestion(component, event, vQnaireId, component.get("v.selTabId"));
                } else if (type === "change") {
                    this.getAllQuestion(component, event, vQnaireId, component.get("v.selTabId"));
                } else {
                    component.set("v.selTabId", lstQGroup[0].Question_Group__c);
                    this.getAllQuestion(component, event, vQnaireId, component.get("v.selTabId"));
                }



            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error :",
                    "mode": "sticky",
                    "message": res.getError()[0].message
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    getAllQuestion: function(component, event, vQnaireId, vSectionId) {
        var action = component.get("c.getQuestnsForQuesGroup"); //Calling Apex class controller 'getQuestnForQuesGroup' method
        action.setParams({
            qnaireId: vQnaireId,
            sectionId: vSectionId,
        });
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {
                var totalSwitchScore = 0.0;
                var totalSwitchProbableScore = 0.0;
                var switchProbableScore = 0.0;
                var switchScoreValue = [];
                var selectedScore = component.get("v.selectedScore");
                var selectedScoreQstnIds = component.get("v.selectedScoreIds");
                this.setQuestionBranching(component, event, res.getReturnValue(), vSectionId);
                var data = res.getReturnValue();
                var qstnsData = data.lstQuestn;
                //console.log(JSON.stringify(data));
                if (qstnsData !== undefined) {
                    for (var i = 0; i < qstnsData.length; i++) {
                        var scoreMap = {
                            qstnId: '',
                            score: 0.0,
                            totalPosibile: 0.0,
                            is_AddSroce: true
                        };
                        if (qstnsData[i].Type__c === 'Switch') {
                            var swithQstnOptn = qstnsData[i].Question_Options__r;
                            if (swithQstnOptn !== null) {

                                if (swithQstnOptn[1].Score__c !== undefined) {
                                    scoreMap.qstnId = qstnsData[i].Question_Questionnaires__r[0].Question__c;
                                    scoreMap.score = parseFloat(swithQstnOptn[1].Score__c) * parseFloat(qstnsData[i].Question_Questionnaires__r[0].Weight__c);
                                    totalSwitchScore = parseFloat(swithQstnOptn[1].Score__c) * parseFloat(qstnsData[i].Question_Questionnaires__r[0].Weight__c) + totalSwitchScore;
                                    switchScoreValue.push(swithQstnOptn[0].Score__c);
                                    switchScoreValue.push(swithQstnOptn[1].Score__c);
                                    scoreMap.is_AddSroce = true;
                                    var largestScoreValue = this.returnLargestSocreNumber(component, switchScoreValue);
                                    switchProbableScore = parseFloat(largestScoreValue) * parseFloat(qstnsData[i].Question_Questionnaires__r[0].Weight__c);
                                    scoreMap.totalPosibile = parseFloat(switchProbableScore);
                                    totalSwitchProbableScore += parseFloat(switchProbableScore);
                                    switchScoreValue.splice(0, switchScoreValue.length);
                                    if (selectedScoreQstnIds.indexOf(qstnsData[i].Question_Questionnaires__r[0].Question__c) === -1) {
                                        selectedScoreQstnIds.push(qstnsData[i].Question_Questionnaires__r[0].Question__c);
                                        selectedScore.push(scoreMap);
                                    }

                                }
                            }
                        }
                    }
                }
                component.set("v.selectedScoreIds", selectedScoreQstnIds);
                component.set("v.selectedScore", selectedScore);
                component.set("v.calculatedScore", totalSwitchScore);
                component.set("v.scoreTotalValues", totalSwitchProbableScore);
            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error :",
                    "mode": "sticky",
                    "message": res.getError()[0].message
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    setQuestionBranching: function(component, event, lstQuestion, vSectionId) {
        
        if (lstQuestion !== undefined && lstQuestion !== null && lstQuestion.lstQuestn !== undefined && lstQuestion.lstQuestn !== null && lstQuestion.lstQuestn.length > 0) {
            var action = component.get("c.getBranchingQuestn"); //Calling Apex class controller 'getBranchingQuestn' method
            var question = lstQuestion.lstQuestn;
            var lst_Question_Questionnaires = component.get("v.lst_Question_Questionnaires");
            var Obj_Question_Questionnaires = component.get("v.Obj_Question_Questionnaires");
            var isRemove = false;
            
            lst_Question_Questionnaires = [];
            action.setParams({
                sectionId: vSectionId,
            });
            
            action.setCallback(this, function(res) {
                var state = res.getState();
                if (state === "SUCCESS") {
                    var lstQDynLogic = res.getReturnValue();                    
                    component.set("v.lstQDynLogicMain", lstQDynLogic);
                    if (lstQDynLogic !== undefined && lstQDynLogic !== null && lstQDynLogic.length > 0) {
                        for (var indexQDynLogic = 0; indexQDynLogic < lstQDynLogic.length; indexQDynLogic++) {
                            for (var indexQue = 0; indexQue < question.length; indexQue++) {
                                var questionQuestnnnaire = question[indexQue].Question_Questionnaires__r;
                                question[indexQue].Question_Questionnaires__r[0].branchingQuestnQuetnnaire = [];
                                for (var indeQQnnaire = 0; indeQQnnaire < questionQuestnnnaire.length; indeQQnnaire++) {
                                    if (lstQDynLogic[indexQDynLogic].Show_Question_Questionnaire__c === questionQuestnnnaire[indeQQnnaire].Id) {
                                        isRemove = true;
                                        Obj_Question_Questionnaires = questionQuestnnnaire[indeQQnnaire];
                                        if (question[indexQue].Question_Options__r !== undefined) {
                                            Obj_Question_Questionnaires.QuestionOptions = question[indexQue].Question_Options__r;
                                        } else {
                                            Obj_Question_Questionnaires.QuestionOptions = [];
                                        }
                                        Obj_Question_Questionnaires.isShowQuestion =true;
                                        Obj_Question_Questionnaires.MainQuestionId = lstQDynLogic[indexQDynLogic].Question_Questionnaire__r.Question__c;
                                        question.splice(indexQue, 1);
                                    }
                                }
                                
                            }
                           lst_Question_Questionnaires.push(Obj_Question_Questionnaires); 
                            
                        }
                        var lstQuestionsId = [];
                        if (isRemove === true) {
                            for (var indexQueResult = 0; indexQueResult < question.length ; indexQueResult++) {
                                var questnId = question[indexQueResult].Id;
                                for (var indexQQnnaire = 0; indexQQnnaire < lst_Question_Questionnaires.length; indexQQnnaire++) {
                                    
                                    if (lst_Question_Questionnaires[indexQQnnaire].MainQuestionId === questnId) {
                                            if(question[indexQueResult].Question_Questionnaires__r[0].branchingQuestnQuetnnaire !== undefined){
                                                var branchingQuestionQuestnnnaire = question[indexQueResult].Question_Questionnaires__r[0].branchingQuestnQuetnnaire;
                                                
                                                if (lstQuestionsId.indexOf(lst_Question_Questionnaires[indexQQnnaire].Id) === -1) {
                                                    branchingQuestionQuestnnnaire.push(lst_Question_Questionnaires[indexQQnnaire]);
                                                }
                                                lstQuestionsId.push(lst_Question_Questionnaires[indexQQnnaire].Id);
                                                question[indexQueResult].Question_Questionnaires__r[0].branchingQuestnQuetnnaire = branchingQuestionQuestnnnaire; 
                                            }
                                            else{
                                                var branchingQuestionQuestnnnaireNew =[];
                                                if (lstQuestionsId.indexOf(lst_Question_Questionnaires[indexQQnnaire].Id) === -1) {
                                                    branchingQuestionQuestnnnaireNew.push(lst_Question_Questionnaires[indexQQnnaire]);
                                                }
                                                lstQuestionsId.push(lst_Question_Questionnaires[indexQQnnaire].Id);
                                                question[indexQueResult].Question_Questionnaires__r[0].branchingQuestnQuetnnaire = branchingQuestionQuestnnnaireNew;
                                            }
                                    }
                                    
                                    
                                }
                            }
                            var done = false;
                            while (!done) {
                                done = true;
                                for (var i = 1; i < question.length; i += 1) {
                                    if (question[i - 1].Question_Questionnaires__r[0].Question_Order__c > question[i].Question_Questionnaires__r[0].Question_Order__c) {
                                        done = false;
                                        var tmpMianQuestn = question[i - 1];
                                        question[i - 1] = question[i];
                                        question[i] = tmpMianQuestn;
                                    }
                                }
                            }
                            lstQuestion.lstQuestn =question;
                            component.set("v.lstQQuesnnaire", lstQuestion);
                            component.set("v.lstQQuesnnaireMain", lstQuestion);
                        }
                       
                        
                    } else {
                        
                        var doneReuslt = false;
                        while (!doneReuslt) {
                            doneReuslt = true;
                            for (var point = 1; point < question.length; point += 1) {
                                if (question[point - 1].Question_Questionnaires__r[0].Question_Order__c > question[point].Question_Questionnaires__r[0].Question_Order__c) {
                                    doneReuslt = false;
                                    var tmpQuestn = question[point - 1];
                                    question[point - 1] = question[point];
                                    question[point] = tmpQuestn;
                                }
                            }
                        }
                        lstQuestion.lstQuestn =question;
                        component.set("v.lstQQuesnnaire", lstQuestion);
                        component.set("v.lstQQuesnnaireMain", lstQuestion);
                    }
                    
                    
                } else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error :",
                        "mode": "sticky",
                        "message": res.getError()[0].message
                    });
                    toastEvent.fire();
                }
            });
            $A.enqueueAction(action);
        } else {
            component.set("v.lstQQuesnnaire", lstQuestion);
            component.set("v.lstQQuesnnaireMain", lstQuestion);
        }
    },
    getQuesCategory: function(component, event, vQnaireId, vSectionId) {
        var action = component.get("c.getQueCategory"); //Calling Apex class controller 'getQueCategory' method
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {
                component.set("v.lstQuesCategory", res.getReturnValue());

            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error :",
                    "mode": "sticky",
                    "message": res.getError()[0].message
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    createQuestion: function(component, event, vQnaireId, vSectionId, vDragId, colNumber) {
        var vQues = component.get("v.objCrteQues");
        vQues.Type__c = vDragId;
        var vQnaireName = component.get("v.QnaireName");
        var action = component.get("c.createQuestnAndQuestnQnaire"); //Calling Apex class controller 'createQueQnaire' method
        var vQuesOrder = '2';
        action.setParams({
            qnaireId: vQnaireId,
            qGroupId: vSectionId,
            question: vQues,
            qnaireName: vQnaireName,
            qOrder: vQuesOrder,
            colNumber: colNumber
        });
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {
                component.set("v.isShowModal", false);
                this.getAllQuestion(component, event, vQnaireId, vSectionId);
                this.removeQuesValue(component, event);
            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error :",
                    "mode": "sticky",
                    "message": res.getError()[0].message
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);

    },
    removeQuesValue: function(component, event) {
        var data = {
            'sobjectType': 'Question__c',
            'Label__c': '',
            'Type__c': '',
            'Help_Text__c': '',
            'Allow_Comment__c': false,
            'Allow_Attachments__c': false,
            'Category__c': '',
            'Required__c': false
        }

        component.set("v.objCrteQues", data);
        component.set("v.description", "");
    },
    deleteQuestion: function(component, event, vQuestnQuestnnaireId) {
        var vQnaireId = component.get("v.QnaireId");
        var vSectionId = component.get("v.selTabId");
        var action = component.get("c.delQuestion"); //Calling Apex class controller 'delQuestion' method
        action.setParams({
            questnQuestnnaireId: vQuestnQuestnnaireId
        });
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {
                this.getAllQuestion(component, event, vQnaireId, vSectionId);

            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error :",
                    "mode": "sticky",
                    "message": res.getError()[0].message
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    editQuestion: function(component, event, vQuesId) {
        var action = component.get("c.getQuesDetail"); //Calling Apex class controller 'getQuesDetail' method
        action.setParams({
            quesId: vQuesId
        });
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {
                var data = res.getReturnValue();
                if (data.Question_Options__r != null) {
                    for (var i = 0; i < data.Question_Options__r.length; i++) {
                        data.Question_Options__r[i].isEditOption = false;
                    }
                }
                component.set("v.objQues", data);
                component.set("v.description", component.get("v.objQues.Label__c"));
                component.set("v.isEditQue", true);
                component.set("v.modalHeader", component.get("v.objQues.Type__c"));
                if (component.get("v.objQues.Type__c") === "Date") {
                    component.set("v.isShowDateModal", true);
                } else if (component.get("v.objQues.Type__c") === "URL") {
                    component.set("v.isShowURLModal", true);
                } else if (component.get("v.objQues.Type__c") === "DateTime") {
                    component.set("v.isShowDatetimeModal", true);
                } else if (component.get("v.objQues.Type__c") === "TextPlain") {
                    component.set("v.isShowTextPlainModal", true);
                } else if (component.get("v.objQues.Type__c") === "RichText") {
                    component.set("v.isShowRichTextModal", true);
                } else if (component.get("v.objQues.Type__c") === "Address") {
                    component.set("v.isShowAddressModal", true);
                } else if (component.get("v.objQues.Type__c") === "Email") {
                    component.set("v.isShowEmailModal", true);
                } else if (component.get("v.objQues.Type__c") === "Phone") {
                    component.set("v.isShowPhoneModal", true);
                } else if (component.get("v.objQues.Type__c") === "Information") {
                    component.set("v.isShowInformationModal", true);
                } else if (component.get("v.objQues.Type__c") === "Checkbox") {
                    component.set("v.isShowCheckboxModal", true);
                } else if (component.get("v.objQues.Type__c") === "Radio") {
                    component.set("v.isShowRadioModal", true);
                }
                else if (component.get("v.objQues.Type__c") === "Number") {
                    component.set("v.isShowNumberAndCurrencyModal", true);
                } else if (component.get("v.objQues.Type__c") === "Picklist") {
                    component.set("v.isShowPicklistModal", true);
                } else if (component.get("v.objQues.Type__c") === "Lookup") {
                    component.set("v.isShowLookupModal", true);
                } else if (component.get("v.objQues.Type__c") === "Switch") {
                    component.set("v.isShowSwitchModal", true);
                } else if (component.get("v.objQues.Type__c") === "Slider") {
                    component.set("v.isShowSliderModal", true);
                } else if (component.get("v.objQues.Type__c") === "GPS Location") {
                    component.set("v.isShowGPSLocationModal", true);
                } else if (component.get("v.objQues.Type__c") === "Media") {
                    component.set("v.isShowMediaModal", true);
                } else if (component.get("v.objQues.Type__c") === "Signature") {
                    component.set("v.isShowSignatureModal", true);
                } else if (component.get("v.objQues.Type__c") === "Header/Footer") {
                    component.set("v.isShowHeaderModal", true);
                } else {
                    component.set("v.isShowModal", true);
                }

            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error :",
                    "mode": "sticky",
                    "message": res.getError()[0].message
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    helperSaveEditQues: function(component, event) {
        var vQnaireId = component.get("v.QnaireId");
        var vSectionId = component.get("v.selTabId");
        var vDesc = component.get("v.description");
        component.set("v.objQues.Label__c", vDesc);
        var vQues = component.get("v.objQues");
        var action = component.get("c.saveEditQuesRecord"); //Calling Apex class controller 'saveEditQuesRecord' method
        action.setParams({
            oQues: vQues
        });
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {
                this.getAllQuestion(component, event, vQnaireId, vSectionId);
                component.set("v.isShowModal", false);
            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error :",
                    "mode": "sticky",
                    "message": res.getError()[0].message
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    saveSectionHelper: function(component, event, sectionName, questionaryId, columnNo) {
        //Calling Apex class controller 'createQueQnaire' method
        var action = component.get("c.createSection");
        action.setParams({
            sectionName: sectionName,
            questionaryId: questionaryId,
            columnNumber: columnNo
        });
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {
                var response = res.getReturnValue();
                component.set("v.isShowSection", false);
                component.set("v.selectedSection", response.Id);
                component.set("v.selTabId", response.Id);
                this.getQuesGroupRecord(component, event, questionaryId, "change");
                //this.getAllQuestion(component, event, questionaryId, response.Id);
                //this.callScriptsLoaded(component, event);
            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error :",
                    "mode": "sticky",
                    "message": res.getError()[0].message
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    minMaxWindowHelper: function(component, event, secId) {
        var acc = component.find(secId);
        for (var cmp in acc) {
            $A.util.toggleClass(acc[cmp], 'slds-show');
            $A.util.toggleClass(acc[cmp], 'slds-hide');
        }

    },
    minMaxWindowQstnHelper: function(component, event, secId) {
        var acc = component.find(secId);
        for (var cmp in acc) {
            $A.util.toggleClass(acc[cmp], 'slds-show');
            $A.util.toggleClass(acc[cmp], 'slds-hide');
        }

    },
    minMaxWindowPanelnHelper: function(component, event, secId) {
        var acc = component.find(secId);
        $A.util.addClass(acc, 'slds-hide');
    },
    showToast: function(component, event, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: 'Alert',
            message: message,
            duration: ' 5000',
            key: 'info_alt',
            type: 'error',
            mode: 'dismissible'
        });
        toastEvent.fire();
    },
    onlyReturnString: function(component, event, valueWithHtmlTag) {
        var tmp = document.createElement("DIV");
        tmp.innerHTML = valueWithHtmlTag;
        return tmp.textContent || tmp.innerText || "";
    },
    returnLargestSocreNumber: function(component, scoreArray) {
        return Math.max.apply(Math,scoreArray);
    },
    setOptionBranching: function(component, event, selctedOptionId, index) {
        var mainQuestion = component.get("v.lstQQuesnnaire.lstQuestn");
        var mainQuestionBranching = mainQuestion[index].Question_Questionnaires__r[0].branchingQuestnQuetnnaire;
        if (mainQuestionBranching !== undefined) {
            for (var indexMBranching = 0; indexMBranching < mainQuestionBranching.length; indexMBranching++) {
                mainQuestionBranching[indexMBranching].isShowQuestion = true;
                if (selctedOptionId !== undefined && selctedOptionId !== null && selctedOptionId.length > 0) {
                    mainQuestionBranching[indexMBranching].isShowQuestion = false;
                }
            }
            var lstAddScore = []; //list for which want to count score in branching question.
            var lstRemoveScore = []; //list for which not count score in branching question.
            mainQuestion[index].Question_Questionnaires__r[0].branchingQuestnQuetnnaire = mainQuestionBranching;
            if (selctedOptionId !== undefined && selctedOptionId !== null && selctedOptionId.length > 0) {
                var lstQDynLogic = component.get("v.lstQDynLogicMain");
                var questnniareId = mainQuestion[index].Question_Questionnaires__r[0].Id;
                //remove question which is not set in Question option
                for (var branchingQuestnQuetnnaireIndex = 0; branchingQuestnQuetnnaireIndex < mainQuestionBranching.length; branchingQuestnQuetnnaireIndex++) {
                    for (var indexMainQDynLogic = 0; indexMainQDynLogic < lstQDynLogic.length; indexMainQDynLogic++) {

                        if (lstQDynLogic[indexMainQDynLogic].Show_Question_Questionnaire__c === mainQuestionBranching[branchingQuestnQuetnnaireIndex].Id &&
                            lstQDynLogic[indexMainQDynLogic].Question_Questionnaire__c === questnniareId &&
                            selctedOptionId === lstQDynLogic[indexMainQDynLogic].Question_Option__c) {
                            mainQuestionBranching[branchingQuestnQuetnnaireIndex].isShowQuestion = true;
                            if (lstRemoveScore.indexOf(mainQuestionBranching[branchingQuestnQuetnnaireIndex].Question__c) > -1) {
                                var alredyAddInRemvePoint = lstRemoveScore.indexOf(mainQuestionBranching[branchingQuestnQuetnnaireIndex].Question__c);
                                lstRemoveScore.splice(alredyAddInRemvePoint, 1);
                            }
                            lstAddScore.push(mainQuestionBranching[branchingQuestnQuetnnaireIndex].Question__c);
                        } else {
                            if (lstAddScore.indexOf(mainQuestionBranching[branchingQuestnQuetnnaireIndex].Question__c) === -1 && lstRemoveScore.indexOf(mainQuestionBranching[branchingQuestnQuetnnaireIndex].Question__c) === -1) {
                                lstRemoveScore.push(mainQuestionBranching[branchingQuestnQuetnnaireIndex].Question__c);
                            }
                        }
                    }
                }
                mainQuestion[index].Question_Questionnaires__r[0].branchingQuestnQuetnnaire = mainQuestionBranching;
            } else {
                for (var scorebranchgQuestnQnaireIndex = 0; scorebranchgQuestnQnaireIndex < mainQuestionBranching.length; scorebranchgQuestnQnaireIndex++) {
                    lstAddScore.push(mainQuestionBranching[scorebranchgQuestnQnaireIndex].Question__c);
                }
            }
            component.set("v.lstQQuesnnaire.lstQuestn", mainQuestion);
            //update score after change branching record.
            var totalpossible = 0.0;
            var totalscore = 0.0;
            var selectedScoreQstnIds = component.get("v.selectedScoreIds");
            var selectedScore = component.get("v.selectedScore");
            if (lstAddScore !== undefined && lstAddScore.length > 0) {
                for (var indexAddScore = 0; indexAddScore < lstAddScore.length; indexAddScore++) {
                    var indexPoint = selectedScoreQstnIds.indexOf(lstAddScore[indexAddScore]);
                    if (indexPoint !== -1) {
                        selectedScore[indexPoint].is_AddSroce = true;
                    }
                }
            }
            if (lstRemoveScore !== undefined && lstRemoveScore.length > 0) {
                for (var indexRemoveScore = 0; indexRemoveScore < lstRemoveScore.length; indexRemoveScore++) {
                    var indexRemovePoint = selectedScoreQstnIds.indexOf(lstRemoveScore[indexRemoveScore]);
                    if (indexRemovePoint !== -1) {
                        selectedScore[indexRemovePoint].is_AddSroce = false;
                    }
                }
            }
            var isUpdate = false;
            for (var indexMainScore = 0; indexMainScore < selectedScore.length; indexMainScore++) {
                if (selectedScore[indexMainScore].is_AddSroce === true) {
                    totalpossible += parseFloat(selectedScore[indexMainScore].totalPosibile);
                    totalscore += parseFloat(selectedScore[indexMainScore].score);
                    isUpdate = true;
                }
            }
            if (isUpdate === true) {
                component.set("v.scoreTotalValues", totalpossible);
                component.set("v.calculatedScore", totalscore);
                component.set("v.selectedScore", selectedScore);
            }
        }

    },
    sortListQuestionQuestionnaire: function(component, event, arrayQQuesnnaire) {
        var done = false;
        while (!done) {
            done = true;
            for (var i = 1; i < arrayQQuesnnaire.length; i += 1) {
                if (arrayQQuesnnaire[i - 1].Question_Questionnaires__r[0].Question_Order__c > arrayQQuesnnaire[i].Question_Questionnaires__r[0].Question_Order__c) {
                    done = false;
                    var tmp = arrayQQuesnnaire[i - 1];
                    arrayQQuesnnaire[i - 1] = arrayQQuesnnaire[i];
                    arrayQQuesnnaire[i] = tmp;
                }
            }
        }

        return arrayQQuesnnaire;
    }
})