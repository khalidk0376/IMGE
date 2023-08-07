({	getDefaultEventCurrency : function(component,eventId) {
        var action = component.get("c.getDefaultEventCurrency");
        action.setParams({eventId : eventId.join(",")});
        action.setCallback(this,function(resp){
            component.set( "v.defaultCurrency",resp.getReturnValue());
            //alert(resp.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    validate:function(component){
        var isFromAccount = component.get("v.isFromAc");
        var isvalid = true;
        if($A.util.isEmpty(component.find("EventEdition").get("v.value"))){
            isvalid = false;
            $A.util.addClass(component.find("EventEdition"),"slds-has-error");
        }
        if($A.util.isEmpty(component.get("v.oppObj.CloseDate"))){
            isvalid = false;
            $A.util.addClass(component.find("CloseDate"),"slds-has-error");
        }
        if(isFromAccount == true){
            if($A.util.isEmpty(component.get("v.oppObj.Opportunity_Contact__c"))){
                isvalid = false;
                var evt = $A.get("e.c:LookupValidationEvent");        
                evt.setParam({isValid:false});
                evt.fire();
            }
        }
        else{
            if($A.util.isEmpty(component.get("v.conId"))){
                isvalid = false;
                var evt = $A.get("e.c:LookupValidationEvent");        
                evt.setParam({isValid:false});
                evt.fire();
            }
        }
        if(!isvalid){
            window._LtngUtility.toast('Error!','error','Please update the invalid form entries and try again.');
        }
        return isvalid; 
    }
})