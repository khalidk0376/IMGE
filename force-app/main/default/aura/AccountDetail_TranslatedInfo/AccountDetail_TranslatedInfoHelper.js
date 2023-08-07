({
    loadData : function(component) {
        var action = component.get("c.getaccTranslatedDetail");
        action.setParams({  recordId : component.get("v.parentId") });
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {    
                var resATF =res.getReturnValue();
                if(resATF !== null){
                    component.set("v.translatedAddressId",resATF.Id);    
                    component.set("v.transLatedIdExists",true);    
                    console.log('Translated Info Record === ' + JSON.stringify(resATF));
                }
            }
            else 
            {
                window._LtngUtility.handleErrors(res.getError());
            }
        });
        $A.enqueueAction(action); 
    }
})