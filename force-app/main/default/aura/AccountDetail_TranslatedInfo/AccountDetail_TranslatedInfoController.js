({
    doInit: function(component, event, helper) {
        helper.loadData(component);
    },
    handleLoad: function(component, event) {

    },
    handleSubmit: function(component, event, helper) {
        event.preventDefault();
        var editRecord = component.get("v.transLatedIdExists");
        if (editRecord == true) {
            var fields = event.getParam('fields');
            component.set("v.showSpinner", true);
            component.find('editFormUpdate').submit(fields);
        } else {
            var fields = event.getParam('fields');
            component.set("v.showSpinner", true);
            component.find('editFormNew').submit(fields);
        }
    },
    handleSuccessUpdate: function(component, event, helper) {
        component.set('v.showSpinner', false);
        window._LtngUtility.toast('Success', 'success', 'Account Translated  Address Information was successfully updated.'); 
    },
    handleSuccessNew: function(component, event, helper) {
        component.set('v.showSpinner', false);
        window._LtngUtility.toast('Success', 'success', 'Account Translated  Address Information was successfully created.'); 
    },
    handleCancel: function(component, event, helper) {
        helper.showHide(component);
        event.preventDefault();
    },
    onchangeEnableSave: function(component, event) {
        component.set("v.disabled", false);
    },
    editRecord: function(component) {
        var navigateEvent = $A.get("e.c:NavigateToPage");
        navigateEvent.setParams({ "isEditMode": true });
        navigateEvent.fire();
    }

})