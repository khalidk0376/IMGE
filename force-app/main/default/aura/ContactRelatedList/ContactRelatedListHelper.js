({
	getAccountDetail : function(component) {
		component.set("v.spinner", true);
		let param = JSON.stringify({accountId: component.get("v.recordId")});
		var action = component.get("c.invoke");
        action.setParams({action:'get_account',parameters:param});
        action.setCallback(this, function(res) {
            component.set("v.spinner", false);
            var state = res.getState();
            if (state === "SUCCESS"){     
            	console.log(JSON.stringify(res.getReturnValue().accObj));
                component.set("v.profile", res.getReturnValue().profile);
                component.set("v.accObj", res.getReturnValue().accObj);
                component.set("v.meta", res.getReturnValue().meta);
            } 
            else {
                window._LtngUtility.handleErrors(res.getError());
            }
        });
        $A.enqueueAction(action);
	},
	addAccountContactRelation: function(component) {
		component.set("v.spinner", true);
		var obj = component.get("v.relatedObj");
		if(!$A.util.isEmpty(obj.Roles)&& obj.Roles!=null && obj.Roles!=undefined){
			obj.Roles = obj.Roles.join(';');
		}

		let param = JSON.stringify({acc_con_rel_obj: obj});
		var action = component.get("c.invokeInsertOrUpdate");
        action.setParams({action:'add_acc_con_rel_obj',parameters:param});
        action.setCallback(this, function(res) {            
        	if(!$A.util.isEmpty(obj.Roles)&& obj.Roles!=null && obj.Roles!=undefined){
        		obj.Roles = obj.Roles.split(';');
        	}
            component.set("v.spinner", false);            
            var state = res.getState();
            
            if (state === "SUCCESS"){            	
            	component.set("v.isOpenRelationModal",false);
                var appEvent = $A.get("e.c:refreshEvent");                
                appEvent.fire();
                window._LtngUtility.toast('Success','success','Account Contact Relationship record created');
            } 
            else {
                window._LtngUtility.handleErrors(res.getError());
            }
        });
        $A.enqueueAction(action);
	},
    validate:function(component){
        var isValid = true;
        if($A.util.isEmpty(component.get("v.parentId"))){
            isValid = false;
        }
        if($A.util.isEmpty(component.get("v.relatedObj.ContactId"))){
            isValid = false;
        }
        if(!isValid){
            var evt = $A.get("e.c:LookupValidationEvent");
            evt.setParam({isValid:false});
            evt.fire();
        }
        return isValid;
    }
})