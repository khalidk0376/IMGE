({
	getMetadata : function(component) {
		component.set("v.spinner",true);
		let param = JSON.stringify({oppId: ''});
		var action = component.get("c.invoke");
        action.setParams({action:'get_partner_field',parameters:param});
        action.setCallback(this, function(res) {            
        	component.set("v.spinner",false);
            var state = res.getState();
            if (state === "SUCCESS"){              	
                component.set("v.options",res.getReturnValue().meta);            } 
            else {
                window._LtngUtility.handleErrors(res.getError());
            }
        });
        $A.enqueueAction(action);
	},
    addPartner : function(component) {
        component.set("v.spinner",true);
        let param = JSON.stringify({partner_obj: component.get("v.partnerObj")});
        var action = component.get("c.invokeInsertOrUpdate");
        action.setParams({action:'add_partner',parameters:param});
        action.setCallback(this, function(res) {            
            component.set("v.spinner",false);
            var state = res.getState();
            if (state === "SUCCESS"){                               
                window._LtngUtility.toast('Success','success','New Partner has been created');
                component.set("v.isOpenModal",false);
                var evtRefreshParterList = $A.get("e.c:refreshEvent");
                evtRefreshParterList.fire();
            }else {
                window._LtngUtility.handleErrors(res.getError());
            }
        });
        $A.enqueueAction(action);
    },
    validate:function(component){
        if($A.util.isEmpty(component.get("v.partnerObj.AccountToId"))){
            var evt = $A.get("e.c:LookupValidationEvent");
            evt.setParam({isValid:false});
            evt.fire();
            return false;    
        }
        else{
            return true;
        }
    }
})