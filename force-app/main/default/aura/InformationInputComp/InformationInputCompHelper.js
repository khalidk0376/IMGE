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
    createQuestion: function(component, event, vQnaireId, vSectionId, vDragId, colNumber, colorCode, textcolor) {
        var vQues = component.get("v.objCrteQues");
        vQues.Type__c = vDragId;
        vQues.Label__c = component.get('v.description').trim();
        vQues.Label__c = this.removePTag(component, event, vQues.Label__c);
        var vQnaireName = component.get("v.QnaireName");
        var action = component.get("c.createQuestnAndQuestnQnaire"); //Calling Apex class controller 'createQueQnaire' method
        var vQuesOrder = '2';
        action.setParams({
            qnaireId: vQnaireId,
            qGroupId: vSectionId,
            question: vQues,
            qnaireName: vQnaireName,
            qOrder: vQuesOrder,
            colNumber: colNumber,
            colorCode: colorCode,
            textColor:textcolor
        });
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
        vQues.Label__c = this.removePTag(component, event, vQues.Label__c);
        var action = component.get("c.saveEditQuesRecord"); //Calling Apex class controller 'saveEditQuesRecord' method
        action.setParams({
            oQues: vQues,
            qnaireId: vQnaireId,
            sectionId: vSectionId
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
    }
})