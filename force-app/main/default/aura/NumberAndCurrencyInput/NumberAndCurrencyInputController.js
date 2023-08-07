({
    doInit: function(component, event, helper) {
        var isEditQue = component.get("v.isEditQue");
        if (isEditQue === true) {
            component.set("v.description", component.get("v.objeditQues.Label__c"));
        }
        helper.getAllCurrencySymbol(component, event);
    },
    showHelpText: function(component, event, helper) {
        var helpText = component.get("v.isShowHelpText");
        if (helpText === false) {
            component.set("v.isShowHelpText", true);
        } else {
            component.set("v.isShowHelpText", false);
        }
    },
    hideModal: function(component, event, helper) {
        helper.crudModalEvent(component, event, true, false);
    },
    saveQues: function(component, event, helper) {
        var message;
        var qes = component.get("v.objCrteQues");
        var vQnaireId = component.get("v.QnaireId");
        var vSectionId = component.get("v.QuestnGroupId");
        var dropColNumber = component.get("v.dropColNumber");
        var vDragId = component.get("v.fieldType");
        var richTextId = component.find("qustNameRich");
        var qustnlabel = qes.Label__c;
        qustnlabel = helper.onlyReturnString(component, event, qustnlabel);
        if (!qustnlabel || qustnlabel.trim().length ===0) {
            message = "write your question";
            helper.showToast(component, event, message);
            return false;
        } else if (component.get("v.objCrteQues.Help_Text_Required__c") === true) {
            var helpText = component.find("helpTextInp");
            var helpTextValue = helpText.get("v.value");
            if (!helpTextValue) {
                message = "Enter help text.";
                helper.showToast(component, event, message);
                return false;
            }
        } else if (component.get("v.objCrteQues.Allow_Currency__c") === true) {
            var CurrencyId = component.find("CurrencyId");
            var CurrencyValue = CurrencyId.get("v.value");
            if (!CurrencyValue) {
                message = "Please select currency";
                helper.showToast(component, event, message);
                return false;
            }
        }

        if (qustnlabel.trim().length <= 10000) {
            helper.createQuestion(component, event, vQnaireId, vSectionId, vDragId, dropColNumber);
        } else {
            message = "Character's Length should not exceed 10000.";
            helper.showToast(component, event, message);
        }
    },
    saveEditQuesrecord: function(component, event, helper) {
        var message;
        var richTextId = component.find("qustNameRich");
        var qustnlabel = richTextId.get("v.value");
        qustnlabel = helper.onlyReturnString(component, event, qustnlabel);
        if (!qustnlabel || qustnlabel.trim().length ===0) {
            message = "write your question";
            helper.showToast(component, event, message);
            return false;
        } else if (component.get("v.objeditQues.Help_Text_Required__c") === true) {
            var helpText = component.find("helpTextInp");
            var helpTextValue = helpText.get("v.value");
            if (!helpTextValue) {
                message = "Enter help text.";
                helper.showToast(component, event, message);
                return false;
            }
        }
        if (component.get("v.objeditQues.Allow_Currency__c") === true) {
            var CurrencyId = component.find("CurrencyId");
            var CurrencyValue = CurrencyId.get("v.value");
            if (!CurrencyValue) {
                message = "Please select currency";
                helper.showToast(component, event, message);
                return false;
            }
        }
        
        if (qustnlabel.trim().length <= 10000 && qustnlabel.trim().length !==0) {
            helper.helperSaveEditQues(component, event);
        } else {
            message = "Character's Length should not exceed 10000";
            helper.showToast(component, event, message);
            return false;
        }
    },
    changeSelect: function(component, event, helper) {},
    showCurrency: function(component, event, helper) {

        var isShowCurrency = component.get("v.isShowCurrency");
        if (isShowCurrency === false) {
            component.set("v.isShowCurrency", true);
        } else {
            component.set("v.isShowCurrency", false);
        }

    },
    checkTextLenght: function(component, event, helper) {
        var target = event.getSource();
        var qustnlabel = target.get("v.value");
        if (!qustnlabel) {
            qustnlabel = helper.onlyReturnString(component, event, qustnlabel);
            if (qustnlabel.length > 10000) {
                var message = "Character's Length should not exceed 10000";
                helper.showToast(component, event, message);
                return false;

            }
        }
    }

})