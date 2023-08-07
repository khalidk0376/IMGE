({
    loadBooths: function(component,event) 
    {
        var eventId = component.get("v.eventId");
        var exhAccountID = component.get("v.exhAccountID");
        //console.log('eventId ' +eventId);
        //console.log('exhAccountID ' +exhAccountID);
        var action = component.get("c.getOppBoothDetailsForExhProfile"); 
        var opt = [];
        action.setParams({
            accountId : exhAccountID,
            eventId : eventId
        });
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            var state = response.getState(); //Checking response status
            if (component.isValid() && result.length>0 && state === "SUCCESS")
            {
                //console.log('response.getReturnValue() '+JSON.stringify(result));
                for(var i=0;i<result.length;i++)
                {
                    opt.push({id: result[i].boothId, label: result[i].accountName+' - '+result[i].boothName})
                }
                //console.log('opt  ' +opt);
                component.set("v.options", opt); // Adding values in Aura attribute variable for options in picklist.
                component.set("v.boothId", opt[0].id);
                this.fetchProfileOptionVisibility(component,event);
            }
            else
            {
                component.set('v.noBooth',true);
            }
        });
        $A.enqueueAction(action);
      
    },

    fetchProfileOptionVisibility: function(component,event) 
    {
        var eventId = component.get("v.eventId");
        var action = component.get("c.getProfileOptionVisibility"); 
        action.setParams({
            eventId : eventId
        });
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            //console.log('resultProfileOptionVisibility ' +JSON.stringify(result));
            var state = response.getState();
            if(state === "SUCCESS")
            {
                component.set('v.profileOptionVisibilty' ,result);
                this.fetchProfilePackageSetting(component,event);
            }
        });
        $A.enqueueAction(action);
    },
    fetchProfilePackageSetting: function(component,event)
    {
        var eventId = component.get("v.eventId");
        var boothId = component.get("v.boothId");
        var accountId = component.get("v.exhAccountID");
        var action = component.get("c.getProfilePackageSetting"); 
        action.setParams({
            eventId : eventId,
            boothId : boothId,
            accountId : accountId
        });
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            //console.log('resultProfilePackageSetting ' +JSON.stringify(result));
            var state = response.getState();
            if(state === "SUCCESS")
            {
                component.set('v.profilePackageSetting' ,result);
            }
        });
        $A.enqueueAction(action);
    },
    getUserType : function(component,event)
    {
        var eventId = component.get("v.eventId");
        var action = component.get("c.getCurrentUserType"); 
        action.setParams({
            eventId : eventId
        });
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            //console.log('resultCurrentUserType ' +JSON.stringify(result));
            var state = response.getState();
            if(state === "SUCCESS")
            {
                component.set('v.userType' ,result);
            }
        });
        $A.enqueueAction(action);
    }

})