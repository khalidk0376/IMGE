({
    callScriptsLoaded: function(component, event) {
        var self = this;        
        
        $(".selecttableField").draggable({
            helper: 'clone',
            revert: "invalid",
            tolerance: "fit",            
            zIndex: 10000,
            start: function(event, ui) {                
                $(ui.helper).addClass("ui-draggable-helper");
                $(ui.helper).width($('.selecttableField').width());

                if ($(".qf-left-panel").hasClass("slds-is-fixed")) {

                } else {
                    $(ui.helper).css('margin-top', '-10px');
                }
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
        var lstQuestn = [];
        var lstQuestion_Questionnaires = [];

        //Start sorting code
        $("#sortableArea1,#sortableArea2,#sortableArea3").sortable({
            placeholder: "ui-state-highlight",
            scroll: false,
            connectWith: ".sortableArea",
            cursor: "move",
            start: function(e, ui) {
                // creates a temporary attribute on the element with the old index
                ui.item.attr('data-previndex', ui.item.index());
                ui.item.attr('data-id', ui.item.parent().attr('id'));
            },
            update: function(e, ui) {
            //alert('update: '+ui.item.index());
            },
            stop: function(e, ui) {
                try
                {
                    // gets the new and old index then removes the temporary attribute
                    var newIndex = parseInt(ui.item.index(),10);
                    var oldIndex = parseInt(ui.item.attr('data-previndex'),10);
                    var colNum = ui.item.parent().attr("id").replace('sortableArea','');
                    component.set("v.Spinner",true);
                    lstQuestn = [];
                    lstQuestion_Questionnaires = [];
                    
                    qqid = ui.item.data('qqid');
                    qid = ui.item.data('qid');
                    
                    console.log('134::'+new Date());
                    if(ui.item.parent().attr("id")!=ui.item.attr('data-id'))
                    {
                        console.log('137::'+new Date());
                        self.updateColumn(component,qqid,qid,'col'+colNum,event)
                        console.log('139::'+new Date());
                    }
                    else if(newIndex==oldIndex){
                        component.set("v.Spinner",false);
                    }
                    else
                    {   
                        //return;
                        lstQuestn = component.get("v.lstQQuesnnaire."+'col'+colNum+"Questions.lstQuestn");
                        if(oldIndex>newIndex){

                            //down to up sorting code..
                            var Obj_Question_QuestionnairesDown = {
                                sobjectType: 'Question_Questionnaire__c',
                                Id: lstQuestn[oldIndex].Question_Questionnaires__r[0].Id,
                                Question_Order__c:  newIndex
                            };
                            var qOrder =newIndex;
                            lstQuestion_Questionnaires.push(Obj_Question_QuestionnairesDown);
                            console.log('158::::::'+new Date());
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
                            console.log('174::::'+new Date());
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
                            console.log('201::::'+new Date());
                        }
                        else
                        {
                            console.log('204::::'+new Date());
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
                                console.log('231::::'+new Date());
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
                                console.log('255::::'+new Date());
                            }
                        }
                        if(lstQuestion_Questionnaires !== undefined && lstQuestion_Questionnaires !== null && lstQuestion_Questionnaires.length>0){
                            console.log('260::::'+new Date());
                            console.log(lstQuestion_Questionnaires);
                            console.log('262::::'+new Date());
                            self.shortColumn(component,lstQuestion_Questionnaires,lstQuestn,oldIndex,newIndex,colNum);
                        }
                    }
                }
                catch(e){
                    console.log(e);
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
    shortColumn:function(component,lstQuestion_Questionnaires,lstQuestn,oldIndex,newIndex,colNum)
    {
        var self = this;
        var action = component.get("c.setQuestnQnniareOrder");
        action.setParams({
            lstOrderOfQQniare: lstQuestion_Questionnaires
        });
        action.setCallback(this, function(res) {
            component.set("v.Spinner",false);
            console.log('266::::'+new Date());
            var state = res.getState();
            if (state === "SUCCESS") {
                self.showToast("Success ",'SUCCESS','Successfully re-order question');
                var oldQues = lstQuestn[oldIndex];
                lstQuestn.splice(oldIndex,1);
                lstQuestn.splice(newIndex, 0, oldQues);
                component.set("v.lstQQuesnnaire."+'col'+colNum+"Questions.lstQuestn",lstQuestn);
                //component.set("v.lstQQuesnnaire.lstQuestn",lstQuestn);
                
            } else {
                self.showToast("Error: ",'error',res.getError()[0].message);
            }
        });
        $A.getCallback(function() {
            $A.enqueueAction(action);
        })();
    },
    updateColumn:function(component,questionaryId,questionId,colNum,event)
    {
        console.log('326::'+new Date());
        var vQnaireId = component.get("v.QnaireId");
        var vSectionId = component.get("v.selTabId");
        var action = component.get("c.updateColumn"); //Calling Apex class controller 'getTemplateRecrod' method
        action.setParams({
            questionaryId:questionaryId,
            questionId:questionId,
            colNum:colNum,
            selectedSectionId:vSectionId
        });
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {
                this.showToast("Success ",'SUCCESS','Column changed!');
                this.getAllQuestion(component, event, vQnaireId, vSectionId);
            } else {
                this.showToast("Error: ",'error',res.getError()[0].message);
            }
        });
        $A.getCallback(function() {
            $A.enqueueAction(action);
        })();
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
                this.showToast("Error: ",'error',res.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },
    getQuesGroupRecord: function(component, event, vQnaireId, type) {
        component.set("v.Spinner",true);
        var action = component.get("c.getAllQuestnGrpNameForQuesnnaire"); //Calling Apex class controller 'getAllQuestnGrpNameForQuesnnaire' method
        action.setParams({
            sQnaireId: vQnaireId
        });
        action.setCallback(this, function(res) {
            component.set("v.Spinner",false);
            var state = res.getState();
            if (state === "SUCCESS") {
                component.set("v.lstQuesGroup", res.getReturnValue());
                var lstQGroup = component.get("v.lstQuesGroup");
                console.log('lstQGroup'+lstQGroup);
                if(lstQGroup)
                {
                    if (type === "delete section") {
                    component.set("v.selTabId", lstQGroup[0].Question_Group__c);
                    this.getAllQuestion(component, event, vQnaireId, component.get("v.selTabId"));
                    } else if (type === "change") {
                        this.getAllQuestion(component, event, vQnaireId, component.get("v.selTabId"));
                    } else {
                        component.set("v.selTabId", lstQGroup[0].Question_Group__c);
                        this.getAllQuestion(component, event, vQnaireId, component.get("v.selTabId"));
                    } 
                }
                 
            } else {
                this.showToast("Error: ",'error',res.getError()[0].message);
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
                //component.set('v.lstQQuesnnaire',res.getReturnValue());
                this.branchingOnCol(component, event, res.getReturnValue(), vSectionId);                
            } else {
                this.showToast("Error: ",'error',res.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },
    branchingOnCol : function(component, event, lstQuestion, vSectionId) {
        component.set("v.Spinner",true);
        var action = component.get("c.getBranchingQuestn");
        action.setParams({
            sectionId: vSectionId,
        });
        
        action.setCallback(this, function(res) {
            component.set("v.Spinner",false);
            var state = res.getState();
            if (state === "SUCCESS") {
                try
                {
                    var lstQDynLogic = res.getReturnValue();                    
                    component.set("v.lstQDynLogicMain", lstQDynLogic);
                    if(lstQuestion.col1Questions.lstQuestn.length>0){
                        this.setQuestionBranching(component,event,lstQuestion,vSectionId,'col1');
                    }
                    if(lstQuestion.col2Questions.lstQuestn.length>0){
                        this.setQuestionBranching(component,event,lstQuestion,vSectionId,'col2');
                    }
                    if(lstQuestion.col3Questions.lstQuestn.length>0){
                        this.setQuestionBranching(component,event,lstQuestion,vSectionId,'col3');
                    }                    
                    if(lstQuestion.col1Questions.lstQuestn.length==0){
                        component.set('v.lstQQuesnnaire',lstQuestion);    
                    } 
                }
                catch(e)
                {
                    console.log(e);
                }
            }
            else
            {
                this.showToast("Error: ",'error',res.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },
    setQuestionBranching: function(component, event, lstQuestion, vSectionId,col) {
        
        var question = [];
        if(col=='col1'){
            question = lstQuestion.col1Questions.lstQuestn;
        }
        else if(col=='col2'){
            question = lstQuestion.col2Questions.lstQuestn;
        }
        else if(col=='col3'){
            question = lstQuestion.col3Questions.lstQuestn;
        }

        var lst_Question_Questionnaires = component.get("v.lst_Question_Questionnaires");
        var Obj_Question_Questionnaires = component.get("v.Obj_Question_Questionnaires");
        var isRemove = false;                
        lst_Question_Questionnaires = [];
        var lstQDynLogic = component.get("v.lstQDynLogicMain");                
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
                    for (var indexQQnnaire = 0; indexQQnnaire < lst_Question_Questionnaires.length; indexQQnnaire++) 
                    {                                        
                        if (lst_Question_Questionnaires[indexQQnnaire].MainQuestionId === questnId)
                        {
                            if(question[indexQueResult].Question_Questionnaires__r[0].branchingQuestnQuetnnaire !== undefined){
                                var branchingQuestionQuestnnnaire = question[indexQueResult].Question_Questionnaires__r[0].branchingQuestnQuetnnaire;
                                
                                if (lstQuestionsId.indexOf(lst_Question_Questionnaires[indexQQnnaire].Id) === -1) {
                                    branchingQuestionQuestnnnaire.push(lst_Question_Questionnaires[indexQQnnaire]);
                                }
                                lstQuestionsId.push(lst_Question_Questionnaires[indexQQnnaire].Id);
                                question[indexQueResult].Question_Questionnaires__r[0].branchingQuestnQuetnnaire = branchingQuestionQuestnnnaire; 
                            }
                            else
                            {
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
            }
        }
        
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

        if(col=='col1'){
            lstQuestion.col1Questions.lstQuestn = question;
        }
        else if(col=='col2'){
            lstQuestion.col2Questions.lstQuestn = question;
        }
        else if(col=='col3'){
            lstQuestion.col3Questions.lstQuestn = question;
        }
        component.set('v.lstQQuesnnaire',lstQuestion);
    },

    getQuesCategory: function(component, event, vQnaireId, vSectionId) {
        var action = component.get("c.getQueCategory"); //Calling Apex class controller 'getQueCategory' method
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {
                component.set("v.lstQuesCategory", res.getReturnValue());
            } else {
                this.showToast("Error: ",'error',res.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },
    createQuestion: function(component, event, vQnaireId, vSectionId, vDragId, colNumber) {
        component.set("v.Spinner",true);
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
            component.set("v.Spinner",false);
            var state = res.getState();
            if (state === "SUCCESS") {
                component.set("v.isShowModal", false);
                this.getAllQuestion(component, event, vQnaireId, vSectionId);
                this.removeQuesValue(component, event);
            } else {
                this.showToast("Error: ",'error',res.getError()[0].message);
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
        component.set("v.Spinner",true);
        var vQnaireId = component.get("v.QnaireId");
        var vSectionId = component.get("v.selTabId");
        var action = component.get("c.delQuestion"); //Calling Apex class controller 'delQuestion' method
        action.setParams({
            questnQuestnnaireId: vQuestnQuestnnaireId
        });
        action.setCallback(this, function(res) {
            component.set("v.Spinner",false);
            var state = res.getState();
            if (state === "SUCCESS") {
                this.getAllQuestion(component, event, vQnaireId, vSectionId);

            } else {
                this.showToast("Error: ",'error',res.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },
    editQuestion: function(component, event, vQuesId) {
        component.set("v.Spinner",true);
        var action = component.get("c.getQuesDetail"); //Calling Apex class controller 'getQuesDetail' method
        action.setParams({
            quesId: vQuesId
        });
        action.setCallback(this, function(res) {
            component.set("v.Spinner",false);
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
                this.showToast("Error: ",'error',res.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },
    helperSaveEditQues: function(component, event) {
        component.set("v.Spinner",true);
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
            component.set("v.Spinner",false);
            var state = res.getState();
            if (state === "SUCCESS") {
                this.getAllQuestion(component, event, vQnaireId, vSectionId);
                component.set("v.isShowModal", false);
            } else {
                this.showToast("Error: ",'error',res.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },
    saveSectionHelper: function(component, event, sectionName, questionaryId, columnNo) {
        component.set("v.Spinner",true);
        var action = component.get("c.createSection");
        action.setParams({
            sectionName: sectionName,
            questionaryId: questionaryId,
            columnNumber: columnNo
        });
        action.setCallback(this, function(res) {
            component.set("v.Spinner",false);
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
                this.showToast("Error: ",'error',res.getError()[0].message);
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
    
    showToast: function(title, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            duration: ' 5000',
            key: 'info_alt',
            type: type,
            mode: 'dismissible'
        });
        toastEvent.fire();
    },
    onlyReturnString: function(component, event, valueWithHtmlTag) {
        var tmp = document.createElement("DIV");
        tmp.innerHTML = valueWithHtmlTag;
        return tmp.textContent || tmp.innerText || "";
    }
})