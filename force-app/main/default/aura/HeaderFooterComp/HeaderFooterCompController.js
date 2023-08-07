({
    doInit: function(component, event, helper) {
        var isEditQue = component.get("v.isEditQue");
        if (isEditQue === false) {
            helper.removeQuesValue(component, event);
        }
        
        helper.getBaseUrlHelper(component);
        var page = component.get("v.page") || 1;
        helper.getAllDocumentsHelper(component,page);
    },
    showModal2: function(component,event,helper){
        helper.showMoadalHelper(component);
    },
    hideModal2: function(component,event,helper){
        helper.closeMoadalHelper(component);
    },
    paginate : function(component, event, helper) {     
        var page = component.get("v.page") || 1;
        var direction = event.getSource().get("v.iconName");        
        page = direction === "utility:chevronleft" ? (page - 1) : (page + 1);
        helper.getAllDocumentsHelper(component, page);
    },
    selectedURL:function(component,event,helper){
        var ele = document.getElementsByClassName("radiobutton");   
        var docId = '';
        for(var i=0;i<ele.length;i++){            
            if(ele[i].checked){
                docId = ele[i].getAttribute('value');
            }
        }
        if(docId!=''){
            var mediaUrl = component.get("v.baseurl")+'/servlet/servlet.ImageServer?id='+docId+'&oid='+component.get("v.orgId");
            component.set("v.objCrteQues.Label__c",component.get("v.objCrteQues.Label__c")+'<img src="'+mediaUrl+'" width="100%"/>');

        }
        helper.closeMoadalHelper(component);
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
        var qustnlabel = qes.Label__c.trim();;
        //qustnlabel = helper.onlyReturnString(component, event, qustnlabel);
        /*if (!categoryValue) {
            message = "Select category!";
            helper.showToast(component, event, message);
            component.set("v.isShowbutton", false);
            return false;
        } else */
        if (!qustnlabel) {
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

        if (qustnlabel.trim().length <= 10000 && qustnlabel.trim().length !==0) {
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
    }
})