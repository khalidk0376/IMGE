({
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
    showToastAlert: function(component, event, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: 'Success', 
            message: message,
            duration: ' 5000',
            key: 'info_alt',
            type: 'SUCCESS',
            mode: 'dismissible'
        });
        toastEvent.fire();
    },
    getQuestionWithoutBranching: function(component, event) {
        var vQnaireId = component.get("v.QnaireId");
        var vSectionId = component.get("v.QuestnGroupId");
        var vQuestionPrintOrder = component.get("v.questionPrintOrder");
        var vMainQuesQuetnnaireId = component.get("v.MainQuesQuetnnaireId");
        var colnum = component.get("v.currentCoumn");
        var action = component.get("c.getAllQuestnQuestnnaire"); //Calling Apex class controller 'getAllQuestnQuestnnaire' method
        
        action.setParams({
            qnaireId: vQnaireId,
            sectionId: vSectionId,
            questnOrder: vQuestionPrintOrder,
            mainQuesQuetnnaireId: vMainQuesQuetnnaireId,
            colnum: colnum
        });
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {
                component.set("v.lstQuesQuetnnaire", res.getReturnValue());
                
                this.getCheckQuestionRecord(component, event);
            } else {
                this.showToast(component, event, res.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },
    getCheckQuestionRecord: function(component, event) {
        var lstQuesQuetnnaire = component.get("v.lstQuesQuetnnaire");
        var selectedOptionBranching = component.get("v.selectedOptionBranching");
        var selectedOptionId = component.get("v.selectedOptionId");
        var vMainQuesQuetnnaireId = component.get("v.MainQuesQuetnnaireId");
        for (var i = 0; i < lstQuesQuetnnaire.length; i++) {
            for (var j = 0; j < selectedOptionBranching.length; j++) {
                if (lstQuesQuetnnaire[i].Id === selectedOptionBranching[j].show_Question_QuestionnaireID &&
                    selectedOptionBranching[j].qstnOptionId === selectedOptionId) {
                    lstQuesQuetnnaire[i].SelectedQuestion = true;
                }
            }
        }
    },
    helperUpdateBreachingRecord: function(component, event) {
        var vSectionId = component.get("v.QuestnGroupId");
        var lstQuestinnaireDynLogic = component.get("v.lstQuestinnaireDynLogic");
        var selectedOptionBranching = component.get("v.selectedOptionBranching");
        if (selectedOptionBranching !== undefined && selectedOptionBranching.length > 0) {
            for (var i = 0; i < selectedOptionBranching.length; i++) {
                var objQuestinnaireDynLogic = {
                    sobjectType: 'Questionnaire_Dynamic_Logic__c',
                    Question_Option__c : selectedOptionBranching[i].qstnOptionId,
                    Question_Group__c : vSectionId,
                    Question_Questionnaire__c : selectedOptionBranching[i].question_QuestionnaireID,
                    Show_Question_Questionnaire__c : selectedOptionBranching[i].show_Question_QuestionnaireID
                };
                lstQuestinnaireDynLogic.push(objQuestinnaireDynLogic); 
            }
            component.set("v.lstQuestinnaireDynLogic", lstQuestinnaireDynLogic);
            this.saveQDLogic(component,event);
        } else {
            this.showToast(component, event, "Please select anyone");
        }
    },
    getAllBranchingRecord: function(component, event) {
        var vSectionId = component.get("v.QuestnGroupId");
        var vMainQuesQuetnnaireId = component.get("v.MainQuesQuetnnaireId");
        var selectedOptionBranching = component.get("v.selectedOptionBranching");
        var action = component.get("c.getAlraedyBranching"); //Calling Apex class controller 'getAlraedyBranching' method
        action.setParams({
            sectionId: vSectionId,
            mainQuesQuetnnaireId: vMainQuesQuetnnaireId
        });
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {
                var lstQnnaireDynLogic = res.getReturnValue();
                if (lstQnnaireDynLogic !== undefined && lstQnnaireDynLogic.length > 0) {
                    for (var i = 0; i < lstQnnaireDynLogic.length; i++) {
                        var branchingMap = {
                            qstnOptionId: lstQnnaireDynLogic[i].Question_Option__c,
                            question_QuestionnaireID: lstQnnaireDynLogic[i].Question_Questionnaire__c,
                            show_Question_QuestionnaireID: lstQnnaireDynLogic[i].Show_Question_Questionnaire__c
                        };
                        selectedOptionBranching.push(branchingMap);
                        component.set("v.selectedOptionBranching", selectedOptionBranching);
                    }
                }

            } else {
                this.showToast(component, event, res.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },
    saveQDLogic : function(component,event){
        var vQnaireId = component.get("v.QnaireId");
        var vSectionId = component.get("v.QuestnGroupId");
        var vMainQuesQuetnnaireId = component.get("v.MainQuesQuetnnaireId");
        var action = component.get("c.saveQuestnDynLogic"); //Calling Apex class controller 'saveQuestnDynLogic' method
        action.setParams({
            qnaireId: vQnaireId,
            sectionId: vSectionId,
            mainQuesQuetnnaireId: vMainQuesQuetnnaireId,
            lstQuestnnaireDynLogic :component.get("v.lstQuestinnaireDynLogic"),
            questionnaireOrder : component.get("v.questionPrintOrder")
        });
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {
                this.showToastAlert(component, event, "Successfully saved");
                var appEvent = $A.get("e.c:QFFieldModelCloseEvt");
                // Optional: set some data for the event (also known as event shape)
                // A parameter’s name must match the name attribute
                // of one of the event’s <aura:attribute> tags
                appEvent.setParams({ "closeModel": false, "isUpdateRecord": true, "modelName": "Branching" });
                appEvent.fire();

            } else {
                this.showToast(component, event, res.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    }

})