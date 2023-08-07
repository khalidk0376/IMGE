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
    SaveQuestion: function(component, event) {
        var isEdit = component.get("v.isEditQue");
        var vQues = component.get("v.objCrteQues");
        vQues.Type__c = component.get("v.modalHeader");
        vQues.Label__c = vQues.Label__c.trim();
        vQues.Label__c = this.removePTag(component, event, vQues.Label__c);
        var vQnaireName = component.get("v.QnaireName");
        var vQuesOrder = '2';
        if(!vQues.Weight__c){
           vQues.Weight__c=1; 
        }
        //Calling Apex class controller 'createQuestnAndQuestnQnaireWithOptions' method
        var action = component.get("c.createQuestnAndQuestnQnaireWithOptions");
        action.setParams({
            qnaireId: component.get("v.QnaireId"),
            qGroupId: component.get("v.QuestnGroupId"),
            question: vQues,
            qnaireName: vQnaireName,
            qOrder: vQuesOrder,
            lstQstnOptn: component.get("v.lstSwitchQuestionOptions"),
            colNumber: component.get("v.dropColNumber")
        });
        if (isEdit) {
            action = component.get("c.saveEditQuesRecord"); //Calling Apex class controller 'saveEditQuesRecord' method
            action.setParams({
                oQues: vQues,
                qnaireId: component.get("v.QnaireId"),
                sectionId: component.get("v.QuestnGroupId"),
                lstQstnOptn: component.get("v.lstSwitchQuestionOptions"),
                isUnderBranching : component.get("v.isUnderBranching")
            });
        }
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {
                this.crudModalEvent(component, event, false, true);

            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: 'Error :',
                    message: res.getError()[0].message,
                    duration: ' 5000',
                    key: 'error',
                    type: 'error',
                    mode: 'dismissible'
                });
                toastEvent.fire();
                component.set("v.isShowbutton", false);
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
    onlyReturnString: function(component, event, valueWithHtmlTag) {
        var tmp = document.createElement("DIV");
        tmp.innerHTML = valueWithHtmlTag;
        return tmp.textContent || tmp.innerText || "";
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
        //component.set("v.description", "");
    },
    checkNumber: function(component, event, numberVal) {
        if (!(/^(-?\d*)((\.(\d{0,2})?)?)$/.test(numberVal))) {
            return false;
        }

        return true;
    },
    addOptionVal: function(component, event, nameVal, scoreVal, aliasVal,checkVal) {
        var QOption = component.get("v.lstSwitchQuestionOptions");
        var data = {
            'sobjectType': 'Question_Option__c',
            'Name': nameVal,
            'Name__c': nameVal,
            'Value__c': aliasVal,
            'Is_Score_Required__c': checkVal,
            'Score__c':scoreVal
            
        };
        QOption.push(data);
        component.set("v.lstSwitchQuestionOptions", QOption);
    },
    updateValues: function(component, event) {

        var QOption = component.get("v.lstSwitchQuestionOptions");
        for (var index = 0; index < QOption.length; index++) {
            if (index === 0) {
                QOption[index].Name__c = component.get("v.optionFirstName");
                QOption[index].Value__c = component.get("v.optionFirstAlias");
                QOption[index].Score__c = component.get("v.optionFirstscore");
                QOption[index].Is_Score_Required__c = component.get("v.optionFirstscoreCheck");
            } else if (index === 1) {
                QOption[index].Name__c = component.get("v.optionSecondName");
                QOption[index].Value__c = component.get("v.optionSecondAlias");
                QOption[index].Score__c = component.get("v.optionSecondscore");
                QOption[index].Is_Score_Required__c = component.get("v.optionSecondscoreCheck");
            }
        }
        component.set("v.lstSwitchQuestionOptions", QOption);

    }

})