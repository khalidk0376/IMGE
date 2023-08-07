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
    createQuestion: function(component, event, vQnaireId, vSectionId, vDragId, colNumber, lstQuestionOptions) {
        
        var vQues = component.get("v.objCrteQues");
        vQues.Type__c = vDragId;
        vQues.Label__c = vQues.Label__c.trim();
        if(!vQues.Weight__c){
           vQues.Weight__=1; 
        }
        vQues.Label__c = this.removePTag(component, event, vQues.Label__c.trim());
        vQues.Is_Score_Required__c = false;
        var vQnaireName = component.get("v.QnaireName");
        var action = component.get("c.createQuestnAndQuestnQnaireWithOptions"); //Calling Apex class controller 'createQueQnaire' method
        var vQuesOrder = '2';
        action.setParams({
            qnaireId: vQnaireId,
            qGroupId: vSectionId,
            question: vQues,
            qnaireName: vQnaireName,
            qOrder: vQuesOrder,
            colNumber: colNumber,
            questnOptns: JSON.stringify(lstQuestionOptions)
        });
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {
                this.crudModalEvent(component, event, false, true);

            } else {
                this.showToast(component, event, res.getError()[0].message);
            }
        });
        $A.enqueueAction(action);

    },
    helperSaveEditQues: function(component, event) {
        var vQnaireId = component.get("v.QnaireId");
        var vSectionId = component.get("v.QuestnGroupId");
        var vDesc = component.get("v.description");
        component.set("v.objeditQues.Label__c", vDesc);
        var vQues = component.get("v.objeditQues");
        vQues.Label__c = vQues.Label__c.trim();
        vQues.Label__c = this.removePTag(component, event, vQues.Label__c.trim());
        vQues.Is_Score_Required__c = false;
        if(!vQues.Weight__c){
           vQues.Weight__=1; 
        }
        var action = component.get("c.saveEditQuesRecord"); //Calling Apex class controller 'saveEditQuesRecord' method
        action.setParams({
            oQues: vQues,
            qnaireId: vQnaireId,
            sectionId: vSectionId,
            isUnderBranching : component.get("v.isUnderBranching")
        });
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {

                this.crudModalEvent(component, event, false, true);

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
    crudModalEvent: function(component, event, closeModel, isUpdateRecord) {
        var vDragId = component.get("v.modalHeader");
        var appEvent = $A.get("e.c:QFFieldModelCloseEvt");
        // Optional: set some data for the event (also known as event shape)
        // A parameter’s name must match the name attribute
        // of one of the event’s <aura:attribute> tags
        appEvent.setParams({ "closeModel": closeModel, "isUpdateRecord": isUpdateRecord, "modelName": vDragId });
        appEvent.fire();
    },
    saveEditOption: function(component, event, name, alias, score) {
        var oQues = component.get("v.objeditQues");
        var action = component.get("c.saveQuestionEditOption");
        action.setParams({
            oQues: oQues,
            name: name,
            alias: alias,
            score: score
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
                component.set("v.objeditQues", data);
                component.set("v.description", component.get("v.objeditQues.Label__c"));
                component.find("optnEditName").set("v.value", "");
                //component.find("optnEditAlias").set("v.value", "");
                component.find("optnEditScore").set("v.value", "");
               
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
    removePTag: function(component, event, labelText) {
        var text = labelText.split("<p>");
        var myString ="";
        if(text !== undefined && text.length>0){
            for(var index=0 ;index<text.length;index++){
                myString = myString + text[index].replace("<p>", "");
                myString = myString.replace("</p>", "<br/>");
            }
            var strBr = myString.substr(myString.length - 5, myString.length);
            if(strBr ==='<br/>'){
                return myString.slice(0, -5);
            }
            return myString;
            
        }
        return labelText;
    },
    onlyReturnString: function(component, event, valueWithHtmlTag) {
        var tmp = document.createElement("DIV");
        tmp.innerHTML = valueWithHtmlTag;
        return tmp.textContent || tmp.innerText || "";
    },
    deleteOptionInEdit: function(component, event, optionId) {
        var oQues = component.get("v.objeditQues");
        var action = component.get("c.deleteQuestionOptionInEdit");
        action.setParams({
            oQues: oQues,
            qstnOptionId: optionId,
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
                component.set("v.objeditQues", data);
                component.set("v.description", component.get("v.objeditQues.Label__c"));
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
    updateOptionInEdit: function(component, event, oQustnOptions) {
        var oQues = component.get("v.objeditQues");
        var action = component.get("c.editQuestionOptionInEdit");
        action.setParams({
            oQuesOption: oQustnOptions,
            oQues: oQues
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
                component.set("v.objeditQues", data);
                component.set("v.description", component.get("v.objeditQues.Label__c"));
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
    }
})