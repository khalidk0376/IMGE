({
	getOppBoothDetails: function(component, event) {
        var action = component.get("c.getOppBoothDetails");
        component.set("v.isSpinner",true);
        action.setParams({accountId:component.get("v.accountId"),eventId:component.get("v.eventId")});
        action.setCallback(this, function(res) {
            component.set("v.isSpinner",false);
            var state = res.getState();
            if (state === "SUCCESS") {
                component.set("v.oppList",res.getReturnValue());
            }
            else{
                alert("Error: "+res.getError()[0].message)
            }
        });
        $A.enqueueAction(action);
    },
    
    getParameter:function(pname){ 
    	var url = new URL(window.location.href);
		return url.searchParams.get(pname);
    }
    
})