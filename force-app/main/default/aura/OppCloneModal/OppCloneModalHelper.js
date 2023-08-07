({
	oppCloneRelated : function(component,recordId) {
		component.set("v.spinner", true);
		let param = JSON.stringify({oppId: component.get("v.oppObj.Id"),depfieldApiName:component.get("{!v.oppObj.Copy_Notes_Attachment_Activities__c}"),recordId:recordId});

		var action = component.get("c.invokeInsertOrUpdate");
        action.setParams({action:'opp_clone_related',parameters:param});
        action.setCallback(this, function(res) {
            component.set("v.spinner", false);
            var state = res.getState();
            if (state === "SUCCESS"){
                component.set("v.spinner",false);
                window._LtngUtility.toast('Success','success','New Opportunity has been created');        
                
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                  "recordId": recordId,
                  "slideDevName": "detail"
                });
                navEvt.fire();
            } 
            else {
                window._LtngUtility.handleErrors(res.getError());
            }
        });
        $A.enqueueAction(action);
    },
    /* added Method for pass Record Type on BK-4875 on RajesH kumar - 01-06-2020 */
    getRecordType:function(component){
        
        var action = component.get("c.getRecordType");
        action.setCallback(this,function(resp){
            component.set( "v.defaultRecordType",resp.getReturnValue());
        });
        $A.enqueueAction(action);
    },

    getDefaultEventCurrency : function(component,eventId) {        
        var action = component.get("c.getDefaultEventCurrency");        
        action.setParams({eventId : eventId });
        action.setCallback(this,function(resp){
            var state = resp.getState();
            if (state === "SUCCESS"){            
            component.set( "v.defaultCurrency",resp.getReturnValue());
            }
            else
            {
               window._LtngUtility.handleErrors(resp.getError());
            }
        });
        $A.enqueueAction(action);
    }
})