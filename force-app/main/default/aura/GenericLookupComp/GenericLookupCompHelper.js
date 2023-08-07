({
    getDatas : function(component,serachKey) {
        component.set("v.spinner", true);
        var fieldValue = component.get("v.queryFieldValues");
        if(Array.isArray(fieldValue)){
            fieldValue = fieldValue.toString();
        }
        var param = JSON.stringify({
            objectName: component.get("v.objectName"),
            searchKey:serachKey,
            fieldName:component.get("v.queryFields"),
            fieldValue:fieldValue
        });
        var action = component.get("c.invoke");
        action.setParams({action: 'lookup',parameters:param});
        action.setCallback(this, function(res) {
            component.set("v.spinner", false);
            var state = res.getState();
            if (state === "SUCCESS"){
                console.log(res.getReturnValue());                
                component.set("v.lookupData", res.getReturnValue());
                var obj = res.getReturnValue();
                // alert('profile.UserLicense.name' + JSON.stringify(res.getReturnValue(obj)));
                var resultreturn = JSON.stringify(res.getReturnValue());
                console.log('resultreturn' + resultreturn);
            } 
            else {
                window._LtngUtility.handleErrors(res.getError());
            }
        });
        $A.enqueueAction(action);
    },
})