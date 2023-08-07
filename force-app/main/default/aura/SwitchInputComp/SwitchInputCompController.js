({
    doInit: function(component, event, helper) {
        var isEditQue = component.get("v.isEditQue");
        if (isEditQue === false) {
            helper.removeQuesValue(component, event);

        } else {
            var qes = component.get("v.objCrteQues");
            component.set("v.lstSwitchQuestionOptions", qes.Question_Options__r);
            var QOption = component.get("v.lstSwitchQuestionOptions");
            for (var index = 0; index < QOption.length; index++) {
                if (index === 0) {
                    component.set("v.optionFirstName", QOption[index].Name__c);
                    component.set("v.optionFirstAlias", QOption[index].Value__c);
                    component.set("v.optionFirstscore", QOption[index].Score__c);
                    component.set("v.optionFirstscoreCheck", QOption[index].Is_Score_Required__c);
                } else if (index === 1) {
                    component.set("v.optionSecondName", QOption[index].Name__c);
                    component.set("v.optionSecondAlias", QOption[index].Value__c);
                    component.set("v.optionSecondscore", QOption[index].Score__c);
                    component.set("v.optionSecondscoreCheck", QOption[index].Is_Score_Required__c);
                }
            }

        }

    },
    hideModal: function(component, event, helper) {
        helper.crudModalEvent(component, event, true, false);
    },
    saveQues: function(component, event, helper) {
        var message;
        component.set("v.isShowbutton", true);
        var qes = component.get("v.objCrteQues");
        var vQnaireId = component.get("v.QnaireId");
        var vSectionId = component.get("v.QuestnGroupId");
        var dropColNumber = component.get("v.dropColNumber");
        var vDragId = component.get("v.fieldType");
        var qustnlabel = qes.Label__c.trim();

        qustnlabel = helper.onlyReturnString(component, event, qustnlabel);
        if (!qustnlabel || qustnlabel.trim().length === 0) {
            message = "write your question";
            helper.showToast(component, event, message);
            component.set("v.isShowbutton", false);
            return false;
        } else if (component.get("v.objCrteQues.Help_Text_Required__c") === true) {
            var helpText = component.find("helpTextInp");
            var helpTextValue = helpText.get("v.value");
            if (!helpTextValue) {
                message = "Enter help text.";
                helper.showToast(component, event, message);
                component.set("v.isShowbutton", false);
                return false;
            }
        }
        if(qes.Weight__c !== undefined && qes.Weight__c !==0){
            if (!helper.checkNumber(component, event, qes.Weight__c)) {
                message = "Enter Weight in number(only 2 decimal point).";
                helper.showToast(component, event, message);
                component.set("v.isShowbutton", false);
                return false;
            }
        }
       
       
        var optionFirstName = component.get("v.optionFirstName");
        var optionSecondName = component.get("v.optionSecondName");
        var optionSecondAlias = component.get("v.optionSecondAlias");
        var optionFirstAlias = component.get("v.optionFirstAlias");
        
        
        var optionFirstscoreCheck = component.get("v.optionFirstscoreCheck");
        var optionSecondscoreCheck = component.get("v.optionSecondscoreCheck");
        
        var optionSecondscore = component.get("v.optionSecondscore");
        var optionFirstsorce = component.get("v.optionFirstscore");
        if (!optionFirstName) {
            message = "Enter option name .";
            helper.showToast(component, event, message);
            component.set("v.isShowbutton", false);
            return false;
        }
        if (!optionFirstAlias) {
            message = "Enter alias.";
            helper.showToast(component, event, message);
            component.set("v.isShowbutton", false);
            return false;
        }
        /*if (!optionFirstsorce) {
            message = "Enter score.";
            helper.showToast(component, event, message);
            component.set("v.isShowbutton", false);
            return false;
        } */ 
        if(optionFirstscoreCheck===true){
            
            if(!optionFirstsorce && optionFirstsorce !==0){
                message = "Enter score.";
                helper.showToast(component, event, message);
                component.set("v.isShowbutton", false);
                return false;
            }
            else if (!helper.checkNumber(component, event, optionFirstsorce)) {
                message = "Enter score in number (only 2 decimal point).";
                helper.showToast(component, event, message);
                component.set("v.isShowbutton", false);
                return false;
            }
        }
        
        
        if (!optionSecondName) {
            message = "Enter option name .";
            helper.showToast(component, event, message);
            component.set("v.isShowbutton", false);
            return false;
        }
        if (!optionSecondAlias) {
            message = "Enter alias.";
            helper.showToast(component, event, message);
            component.set("v.isShowbutton", false);
            return false;
        }
        if(optionSecondscoreCheck===true){
            
            if(!optionSecondscore && optionSecondscore !==0){
                message = "Enter score.";
                helper.showToast(component, event, message);
                component.set("v.isShowbutton", false);
                return false;
            }
            else if (!helper.checkNumber(component, event, optionSecondscore)) {
                message = "Enter score in number(only 2 decimal point).";
                helper.showToast(component, event, message);
                component.set("v.isShowbutton", false);
                return false;
            }
        }
        

        if (qustnlabel.trim().length <= 10000 && qustnlabel.trim().length !== 0) {
            var isEditQue = component.get("v.isEditQue");
            if (isEditQue === false) {
                
                helper.addOptionVal(component, event, optionFirstName, optionFirstsorce, optionFirstAlias,optionFirstscoreCheck);
                helper.addOptionVal(component, event, optionSecondName, optionSecondscore, optionSecondAlias,optionSecondscoreCheck);
            } else {
                helper.updateValues(component, event);
            }

            helper.SaveQuestion(component, event);
        } else {
            message = "Character's Length should not exceed 10000.";
            helper.showToast(component, event, message);
            component.set("v.isShowbutton", false);
        }
    },
    checkTextLength: function(component, event, helper) {
        var target = event.getSource();
        var qustnlabel = target.get("v.value");
        qustnlabel = helper.onlyReturnString(component, event, qustnlabel);
        if (!qustnlabel) {

            if (qustnlabel.length > 10000) {
                var message = "Character's Length should not exceed 10000";
                helper.showToast(component, event, message);
                return false;

            }
        }
    },
    disableEnableScore:function(component, event, helper){
        var value=event.getSource().getLocalId();
        var checked=component.find(value).get("v.checked");
        var inputId=value+'Input';
        if(checked===true){
            component.find(inputId).set("v.disabled",false)
        }
        else{
            component.find(inputId).set("v.disabled",true)
        }
    }
})