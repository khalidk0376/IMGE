({
    modalClose : function(component, event) {
        $A.get("e.force:closeQuickAction").fire();
    },
    startSync: function(component, event) {
        var action = component.get("c.getCompanyTypeList");
        action.setParams({
            eventEditionId:component.get('v.recordId')
        });
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {                
                var response = res.getReturnValue();
                if(response){
                    component.set('v.confirm',true);
                }else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        'title': "Error!",
                        'type': 'error',
                        'message': "CompanyType Setup Required checkbox should be selected to proceed."
                    });
                    toastEvent.fire();
                }
            }
        });
        $A.enqueueAction(action);

        //console.log(component.get('v.recordId'));
        //component.set('v.confirm',true);
    },

})