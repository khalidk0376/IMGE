({
	fetchSubCon : function(component) {
        component.set("v.isSpinner", true);
        var eventId = component.get("v.eventId");
        var boothMapId = component.get("v.boothMapId");
        var action = component.get("c.getSubcontactor"); 
        action.setParams({
            sEventId : eventId,
            boothMapId:boothMapId
        });
        action.setCallback(this, function(response) {
            var state = response.getState(); //Checking response status
            //console.log('state==='+state);
            if (component.isValid() && state === "SUCCESS") 
            {
                //console.log('fetchSubcon'+JSON.stringify(response.getReturnValue()));
                component.set("v.SubContractors", response.getReturnValue());// Adding values in Aura attribute variable.
            }
            component.set("v.isSpinner", false);
        });
        $A.enqueueAction(action);
    }
})