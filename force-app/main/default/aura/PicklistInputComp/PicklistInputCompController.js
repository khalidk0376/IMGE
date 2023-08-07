({
    doInit: function(component, event, helper) {
        var isEditQue = component.get("v.isEditQue");
        if (isEditQue === true) {
            component.set("v.description", component.get("v.objeditQues.Label__c"));
        }
        var PL = component.get("v.productList");
        var product = {
            name: "",
            alias: "",
            isEditOption: false,
            score: ""
        };
        PL.push(product);
        component.set("v.productList", PL);
    },
    showHelpText: function(component, event, helper) {
        var helpText = component.get("v.isShowHelpText");
        if (helpText === false)
            component.set("v.isShowHelpText", true);
        else
            component.set("v.isShowHelpText", false);
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
        var qustnlabel = qes.Label__c;
        qustnlabel = helper.onlyReturnString(component, event, qustnlabel);
        var lstquestionOptions = component.get("v.productList")
        if (!qustnlabel || qustnlabel.trim().length === 0) {
            message = "write your question";
            helper.showToast(component, event, message);
            return false;
        } else if (component.get("v.objCrteQues.Help_Text_Required__c") === true) {
            //var helpText = component.find("helpTextInp");
            var helpTextValue = component.get("v.objCrteQues.Help_Text__c");
            if (!helpTextValue) {
                message = "Enter help text.";
                helper.showToast(component, event, message);
                return false;
            }
        }
        if (component.get("v.objCrteQues.Is_Weight_Required__c")) {
            var weightValule = component.get("v.objCrteQues.Weight__c");
            if (!weightValule) {
                message = "Please enter Weight value.";
                helper.showToast(component, event, message);
                return false;
            } else if (isNaN(weightValule)) {
                message = "Weight should be number";
                helper.showToast(component, event, message);
                return false;
            }
        }
        if (lstquestionOptions.length <= 1) {
            message = "Create question options.";
            helper.showToast(component, event, message);
            return false;
        }

        if (qustnlabel.trim().length <= 10000 && qustnlabel.trim().length !== 0) {
            var lstOptions = [];
            for (var i = 0; i < lstquestionOptions.length - 1; i++) {
                lstOptions.push(lstquestionOptions[i]);
            }
            if (lstOptions.length < 2) {
                helper.showToast(component, event, 'Atleast Create 2 options.');
                return false;
            }
            helper.createQuestion(component, event, vQnaireId, vSectionId, vDragId, dropColNumber, lstOptions);
        } else {
            message = "Character's Length should not exceed 10000.";
            helper.showToast(component, event, message);
        }
    },
    saveEditQuesrecord: function(component, event, helper) {
        var message;
        var richTextId = component.find("qustNameRich");
        var qustnlabel = richTextId.get("v.value");
        if (!qustnlabel || qustnlabel.trim().length === 0) {
            message = "write your question";
            helper.showToast(component, event, message);
            return false;
        } else if (component.get("v.objeditQues.Help_Text_Required__c") === true) {
            var helpTextValue = component.get("v.objeditQues.Help_Text__c");
            helpTextValue = helpTextValue.trim();
            if (!helpTextValue) {
                message = "Enter help text.";
                helper.showToast(component, event, message);
                return false;
            }
        }
        if (component.get("v.objeditQues.Is_Weight_Required__c")) {
            var weightValule = component.get("v.objeditQues.Weight__c");
            if (isNaN(weightValule)) {
                message = "Weight should be number";
                helper.showToast(component, event, message);
                return false;
            }
        }
        var lstQuesOptions = component.get("v.objeditQues.Question_Options__r")
        if (!lstQuesOptions || lstQuesOptions.length < 2) {
            helper.showToast(component, event, 'Atleast Create 2 options.');
            return false;
        }
        if (qustnlabel.trim().length <= 10000 && qustnlabel.trim().length !== 0) {
            helper.helperSaveEditQues(component, event);
        } else {
            message = "Character's Length should not exceed 10000.";
            helper.showToast(component, event, message);
            return false;
        }
    },
    addOptions: function(component, event, helper) {
        var PL = component.get("v.productList");
        var product = {
            name: "",
            alias: "",
            isEditOption: false,
            score: ""
        };
        PL.push(product);
        component.set("v.productList", PL);
        for (var i = 0; i < PL.length - 1; i++) {
            if (PL[i].name === '' || PL[i].name === null) {
                var message = "write your option";
                helper.showToast(component, event, message);
                PL.splice(i, 1);
                component.set("v.productList", PL);
                return false;
            } else if (isNaN(PL[i].score)) {
                var messageScore = "Score should be number";
                helper.showToast(component, event, messageScore);
                PL.splice(i, 1);
                component.set("v.productList", PL);
                return false;
            }
        }
    },
    enableEditOption: function(component, event, helper) {
        var indexValue = parseInt(event.getSource().get("v.name").replace("Edit_", ""), 10);
        var prodlist = component.get("v.productList");
        prodlist[indexValue].isEditOption = true;
        component.set("v.productList", prodlist);
    },
    updateEditOptionOnClientSide: function(component, event, helper) {
        var indexValue = parseInt(event.getSource().get("v.name").replace("Name_", "").replace("Alias_", "").replace("Score_", ""), 10);
        var prodlist = component.get("v.productList");
        prodlist[indexValue].isEditOption = false;
        component.set("v.productList", prodlist);
    },
    deleteOption: function(component, event, helper) {
        var indexValue = parseInt(event.getSource().get("v.name").replace("Del_", ""), 10);
        var prodlist = component.get("v.productList");
        prodlist.splice(indexValue, 1);
        component.set("v.productList", prodlist);
    },
    addOptionsInEdit: function(component, event, helper) {
        var name = component.find('optnEditName').get("v.value");
        var alias = ""; //component.find('optnEditAlias').get("v.value");
        var score = component.find('optnEditScore').get("v.value");
        if (name === '' || name === null) {
            var message = "Write your option";
            helper.showToast(component, event, message);
            return false;
        }
        if (isNaN(score)) {
            var messageScore = "Score should be number";
            helper.showToast(component, event, messageScore);
            return false;
        }
        helper.saveEditOption(component, event, name, alias, score);
    },
    deleteOptionInEdit: function(component, event, helper) {
        var optionId = event.getSource().get("v.name");
        helper.deleteOptionInEdit(component, event, optionId);
    },
    editOptionInEdit: function(component, event, helper) {
        var optionId = event.getSource().get("v.name");
        var data = component.get("v.objeditQues");
        if (data.Question_Options__r != null) {
            for (var i = 0; i < data.Question_Options__r.length; i++) {
                if (data.Question_Options__r[i].Id === optionId) {
                    data.Question_Options__r[i].isEditOption = true;
                } else {
                    data.Question_Options__r[i].isEditOption = false;
                }
            }
        }
        component.set("v.objeditQues", data);
    },
    updateEditOptionInEdit: function(component, event, helper) {
        var optionId = event.getSource().get("v.name");
        var data = component.get("v.objeditQues");
        if (data.Question_Options__r != null) {
            for (var i = 0; i < data.Question_Options__r.length; i++) {
                if (data.Question_Options__r[i].Id === optionId) {
                    helper.updateOptionInEdit(component, event, data.Question_Options__r[i]);
                }
            }
        }
    },
    checkTextLength: function(component, event, helper) {
        var target = event.getSource();
        var qustnlabel = target.get("v.value");
        qustnlabel = helper.onlyReturnString(component, event, qustnlabel);
        if (qustnlabel.length > 10000) {
            var message = "Character's Length should not exceed 10000";
            helper.showToast(component, event, message);
            return false;

        }
    }
})