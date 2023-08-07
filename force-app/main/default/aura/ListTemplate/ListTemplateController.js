({
    doInit: function(component, event, helper) {
        window.onscroll = function() {};
        helper.getQuesCategory(component, event);
        helper.getAllCommunity(component);
        var page = component.get("v.page") || 1;
        helper.getQuestnnaireRecord(component, event,page);
    },
    hideModal: function(component, event, helper) {
        component.set("v.isShowCreateModal", false);
        component.set("v.isCloneTemplate", false);
    },
    handleClick: function(component, event, helper) {
        
    },
    openShareTemp:function(component, event, helper){
        var vQnnaireIdAndName=event.getSource().get("v.value");
        component.set("v.templateIdAndName",vQnnaireIdAndName);
        component.set("v.openShareTemplate",true);
    },
    showCreateModal: function(component, event, helper) {
        component.set("v.isShowCreateModal", true);
        /* var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "Questionnaire__c",
            "defaultFieldValues": {
                'Version__c' : '1'
            }
        });
        createRecordEvent.fire();*/
    },
    saveQQuesnaireRecrod: function(component, event, helper) {
        var inputCmp = component.find('fieldId');
        inputCmp.showHelpMessageIfInvalid();
        var allValid = inputCmp.get('v.validity').valid;
        // alert(1);
        
        /*var allValid = component.find('fieldId').reduce(function(validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && !inputCmp.get('v.validity').valueMissing;
        }, true);*/
        if (allValid) {
            component.set("v.objQuesnaire.isMerge__c",true);
            component.set("v.objQuesnaire.Community_URL__c",'https://'+window.location.host+'/formbuilder/s/');
            //component.find("mergefieldid").get("v.checked")
            helper.getCreateTemplate(component, event);
        } 
        else {
            helper.showToast(component, event, 'Please update the invalid form entries and try again.');
        }
    },
    delete1 : function(component, event, helper) 
    {
        let isTrue = confirm('Are you sure?');
        if(isTrue)
        {
            helper.deleteFormRecord(component,event,helper);        
        } 
    },
    
    callEditTemplate: function(component, event, helper) {
        var target = event.getSource();
        var vQnnaireId = target.get("v.value");
        //changes regarding ticketno.BK-1841
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:TemplateTab",
            componentAttributes: {
                tempId : vQnnaireId
            }
        });
        evt.fire();
        //ends here..
        /*
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": window.location.href+'?tempId=' + vQnnaireId
        });
        urlEvent.fire();
    	alert(vQnnaireId+','+window.location.href + '?tempId=' + vQnnaireId);*/
        
        /*var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": vQnnaireId,
            "slideDevName": "detail",
            "isredirect": true
        });
        navEvt.fire();*/

    },
    cloneTemplate: function(component, event, helper) {
        component.set("v.isCloneTemplate", true);
        var templateId = event.getSource().get("v.value");
        helper.getSingleQuestnnaireRecord(component, event, templateId);
        //alert(templateId);
    },
    saveCloneTemplate: function(component, event, helper) {
        var allValid = component.find('fieldId').reduce(function(validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && !inputCmp.get('v.validity').valueMissing;
        }, true);
        if (allValid) {
            helper.saveTemplateCloneRecord(component, event);
        } else {
            helper.showToast(component, event, 'Please update the invalid form entries and try again.');
        }
    },
    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        //component.set("v.Spinner", true);
    },

    // this function automatic call by aura:doneWaiting event 
    hideSpinner: function(component, event, helper) {
        // make Spinner attribute to false for hide loading spinner    
        //component.set("v.Spinner", false);
    },
    showTemplateReocrd: function(component, event, helper) {
        var page =  1;
        helper.searchTemplateRecord(component, event,page);
    },
    navigate: function(component, event, helper) {
        // this function call on click on the previous page button  
        var page = component.get("v.page") || 1;
        // get the previous button label  
        var direction = event.getSource().get("v.label");
        // set the current page,(using ternary operator.)  
        page = direction === "Previous Page" ? (page - 1) : (page + 1);
        // call the helper function
        helper.getQuestnnaireRecord(component, event, page);

    },
    changeSortOrderASC : function(component, event, helper) {
        var page =  1;
        component.set("v.sortOrder","DESC");
        helper.getQuestnnaireRecord(component, event,page);
    },
    changeSortOrderDESC : function(component, event, helper) {
        var page =  1;
        component.set("v.sortOrder","ASC");
        helper.getQuestnnaireRecord(component, event,page);
    },
    redirectPreview: function(component, event, helper) {
        var target = event.getSource();
        var communityURL = target.get("v.value");
        window.open("https://"+window.location.host+"/c/FormPreviewApp.app?Id="+communityURL);
        
        /*var target = event.getSource();
        var communityURL = target.get("v.value");
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": communityURL
        });
        urlEvent.fire();*/
    },
    handleCloseModelEvent: function(component, event, helper) {
        var closeModel = event.getParam("closeModel");
        var isUpdateRecord = event.getParam("isUpdateRecord");
        var modelName = event.getParam("modelName");
        if(modelName==='shareTemp'){
            component.set("v.openShareTemplate",false);
        }
        if(modelName==='brandingModal'){
            component.set("v.openBrandingModal",false);
        }
    },
    showBrandingModal:function(component, event, helper) {
        component.set("v.openBrandingModal",true);
    }
})