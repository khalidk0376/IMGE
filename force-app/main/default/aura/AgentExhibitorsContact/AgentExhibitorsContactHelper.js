({
	//Apex class : AgentOwnExhibitorsCtrl 
	fetchAgentExhContacts : function(component) {
		var sEventId = component.get("v.eventId");// Getting values from Aura attribute variable.
        var action = component.get("c.getAgentExhibitorsContact"); //Calling Apex class controller 'getEventDetails' method
        action.setParams({
            sEventId : sEventId
        });
        action.setCallback(this, function(response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS") 
            {
                //console.log('response.fetchAgentExhContacts>>>>>'+JSON.stringify(response.getReturnValue()));
                component.set("v.exhibitorContacts", response.getReturnValue());// Adding values in Aura attribute variable.
            }
        });
        $A.enqueueAction(action);
	},
	sendInvitation : function(component) {
		var exhCon = component.get("v.exhCon");// Getting values from Aura attribute variable.
		//console.log('>>>>exhCon>>'+JSON.stringify(exhCon));
        var action = component.get("c.createUser"); //Calling Apex class controller 'getEventDetails' method
        action.setParams({
			agentExhCon : exhCon
        });
        action.setCallback(this, function(response) {
            var state = response.getState(); //Checking response status
            if(component.isValid() && state === "SUCCESS") 
            {
                document.getElementById('Confirm').style.display = "block";	
				//console.log('response.fetchAgentExhContacts>>>>>'+JSON.stringify(response.getReturnValue()));
				component.set("v.exhibitorContacts", response.getReturnValue());// Adding values in Aura attribute variable.
            }
        });
        $A.enqueueAction(action);
    },
})