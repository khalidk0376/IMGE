({
	getQuoteDetail : function(component) {
		component.set("v.spinner", true);
		let param = JSON.stringify({oppId: component.get("v.oppId")});

		var action = component.get("c.invoke");
        action.setParams({action:'get_quote',parameters:param});
        action.setCallback(this, function(res) {
            component.set("v.spinner", false);
            var state = res.getState();
            if (state === "SUCCESS"){
                let quoteCount = parseInt(res.getReturnValue(),10); 
                if(quoteCount>0){   
	                component.set("v.isQuoteExist", true);
	            }
            } 
            else {
                window._LtngUtility.handleErrors(res.getError());
            }
        });
        $A.enqueueAction(action);
    },

    /* added Method for pass Record Type on BK-4977 on RajesH kumar - 02-06-2020 */	

    getRecordTypeQuote:function(component){
        
        var action = component.get("c.getRecordTypeQuote");
        action.setCallback(this,function(resp){
            component.set( "v.defaultRecordType",resp.getReturnValue());
            
        });
        $A.enqueueAction(action);
    },

    getCurrentUserProfileName:function(component){
        var action = component.get("c.getCurrentUserProfileName");
        action.setCallback(this,function(resp){
            component.set( "v.CurrentProfileName",resp.getReturnValue());
        });
        $A.enqueueAction(action);
    }

})