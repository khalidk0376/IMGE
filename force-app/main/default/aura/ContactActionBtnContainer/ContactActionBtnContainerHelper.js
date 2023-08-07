({
	getConDetail : function(component) {		
		let param = JSON.stringify({recordId: component.get("v.recordId")});
		var action = component.get("c.invoke");
        action.setParams({action:'get_con_detail',parameters:param});
        action.setCallback(this, function(res) {            
            var state = res.getState();
            if (state === "SUCCESS"){    
                var obj = res.getReturnValue();                  
                component.set("v.conObj",obj.con_obj[0]);
                component.set("v.profileName",obj.profile);
            } 
            else {
                window._LtngUtility.handleErrors(res.getError());
            }
        });
        $A.enqueueAction(action);
	}    
})