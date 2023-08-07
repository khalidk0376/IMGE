({
	getAccDetail : function(component) {		
		let param = JSON.stringify({accountId: component.get("v.recordId")});
		var action = component.get("c.invoke");
        action.setParams({action:'get_account',parameters:param});
        action.setCallback(this, function(res) {            
            var state = res.getState();
            if (state === "SUCCESS"){               
                component.set("v.accObj",res.getReturnValue().accObj);
                component.set("v.isAllowProfile",res.getReturnValue().is_allow);
                component.set("v.loggedInUserProfile",res.getReturnValue().profile);
                component.set("v.loggedInUserRole",res.getReturnValue().IsUserRole);
            } 
            else {
                window._LtngUtility.handleErrors(res.getError());
            }
        });
        $A.enqueueAction(action);
	},
    getAccDetailReLoad : function(component) {        
        let param = JSON.stringify({accountId: component.get("v.recordId")});
        var action = component.get("c.invoke");
        action.setParams({action:'get_account',parameters:param});
        action.setCallback(this, function(res) {            
            var state = res.getState();
            if (state === "SUCCESS"){
                component.set("v.accObj",res.getReturnValue().accObj);
                component.set("v.isAllowProfile",res.getReturnValue().is_allow);
                component.set("v.loggedInUserProfile",res.getReturnValue().profile);
                component.set("v.loggedInUserRole",res.getReturnValue().IsUserRole);

            } 
            else {
                window._LtngUtility.handleErrors(res.getError());
            }
        });
        $A.enqueueAction(action);
    }     
})