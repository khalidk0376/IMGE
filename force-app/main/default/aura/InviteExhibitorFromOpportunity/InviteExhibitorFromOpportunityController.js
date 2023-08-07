({
    modalClose : function(component, event) {
        $A.get("e.force:closeQuickAction").fire();
    },
    startSync: function(component, event) {
        console.log('111111222111');
        console.log(component.get('v.recordId'));
        component.set('v.confirm',false);
        component.set('v.startSync',true);
    },
    getOpportunityProbability : function(component, event) {
        var action = component.get("c.getOpportunitiesprobability");
        action.setParams({ eventId : component.get('v.recordId') }); 

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.OpportunityProbability",response.getReturnValue());
                component.set('v.confirm',true);
                
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
    }

})