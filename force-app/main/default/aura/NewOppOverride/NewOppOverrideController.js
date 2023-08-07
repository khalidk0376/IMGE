({
    doInit: function(component, event, helper) {
        var firstDay = new Date();
        firstDay.setDate(firstDay.getDate()+30);
        component.set("v.oppObj", { sobjectType: 'Opportunity',CloseDate:firstDay.getFullYear()+'-'+(("0" + (firstDay.getMonth() + 1)).slice(-2))+'-'+(("0"+firstDay.getDate()).slice(-2))});
    },
    closeModal: function(component, event, helper) {        
        component.set("v.isOpenModal", false);
        history.go(-1);
    },
    showRequiredFields: function(component, event, helper) {
        $A.util.removeClass(component.find("EventEdition"), "none");
    },
    handleExhibitorChange: function(component, event, helper) {
        var val = event.getSource().get("v.value");
        if (val == 'SubAgent Paid By Subagent' || val == 'Individual Contract' || val == 'SubAgent Paid By Exhibitor') {
            $A.util.removeClass(component.find("Agent_s_Opportunity"), 'slds-hide');
        } else {
            $A.util.addClass(component.find("Agent_s_Opportunity"), 'slds-hide');
        }
    },
    handleDateChange: function(component, event, helper) {
        var val = event.getSource().get("v.value");
        if (!$A.util.isEmpty(val)) {
            $A.util.removeClass(component.find("CloseDate"), "slds-has-error");
        }
    },
    handleEventChange: function(component, event, helper) {
        var val = event.getSource().get("v.value");
        if (!$A.util.isEmpty(val)) {
            helper.getDefaultEventCurrency(component,val);
            $A.util.removeClass(component.find("EventEdition"), "slds-has-error");
            $A.util.removeClass(component.find("Event_Edition_Currency"), 'slds-hide');
        } else {
            $A.util.addClass(component.find("Event_Edition_Currency"), 'slds-hide');
        }
    },
    handleError: function(component, event, helper) {
        component.set("v.spinner", false);
        window._LtngUtility.handleError(event.getParams().error);
    },
    handleSubmit: function(component, event, helper) {        
        event.preventDefault(); // stop the form from submitting
        if (helper.validate(component)) {

            var fields = event.getParam('fields');
            var isFromAccount = component.get("v.isFromAc");
            if (isFromAccount == true) {
                if (!$A.util.isEmpty(component.get("v.oppObj.Opportunity_Contact__c"))) {
                    fields.Opportunity_Contact__c = component.get("v.oppObj.Opportunity_Contact__c");
                }
            } else {
                if (!$A.util.isEmpty(component.get("v.conId"))) {
                    fields.Opportunity_Contact__c = component.get("v.conId");
                }
            }
            if (!$A.util.isEmpty(component.get("v.oppObj.Billing_Contact__c"))) {
                fields.Billing_Contact__c = component.get("v.oppObj.Billing_Contact__c");
            }
            
            if (!$A.util.isEmpty(component.get("v.oppObj.Event_Edition_Currency__c"))) {
                fields.Event_Edition_Currency__c = component.get("v.oppObj.Event_Edition_Currency__c");
            }
            else {
                 fields.CurrencyIsoCode = component.get("v.defaultCurrency");
            }
            if (!$A.util.isEmpty(component.get("v.oppObj.CloseDate"))) {
                fields.CloseDate = component.get("v.oppObj.CloseDate");
            }
            if (!$A.util.isEmpty(component.get("v.oppObj.Operations_Contact__c"))) {
                fields.Operations_Contact__c = component.get("v.oppObj.Operations_Contact__c");
            }
            //alert(fields.Event_Edition_Currency__c);            
            component.find('editForm2').submit(fields);
            component.set("v.spinner", true);
        }

    },
    validateForm: function(component, event, helper) {
        helper.validate(component);
    },
    handleSuccess: function(component, event, helper) {
        var payload = event.getParams().response;
        component.set("v.spinner", false);
        window._LtngUtility.toast('Success', 'success', 'New Opportunity has been created');
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": payload.id,
            "slideDevName": "detail"
        });
        navEvt.fire();
    }
})