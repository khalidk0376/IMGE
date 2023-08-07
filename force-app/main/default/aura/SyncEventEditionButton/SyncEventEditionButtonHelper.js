({
    showToast : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type":'error',
            "title": "Error!",
            "message": "Please choose Previous year event edition to continue."
        });
        toastEvent.fire();
        $A.get("e.force:closeQuickAction").fire();
    }
})