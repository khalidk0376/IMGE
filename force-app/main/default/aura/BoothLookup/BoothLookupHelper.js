({
	getAllBooth : function(component,searchKey) {	
		component.set("v.spinner",true)	;
		let param = JSON.stringify({oppId: component.get("v.recordId"),searchKey:searchKey});
		var action = component.get("c.invoke");
        action.setParams({action:'get_booth',parameters:param});
        action.setCallback(this, function(res) {            
        	component.set("v.spinner",false)	;
            var state = res.getState();
            if (state === "SUCCESS"){    
            	//alert(JSON.stringify(res.getReturnValue()));
                component.set("v.booths",res.getReturnValue());
            } 
            else {
                window._LtngUtility.handleErrors(res.getError());
            }
        });
        $A.enqueueAction(action);
	},
})