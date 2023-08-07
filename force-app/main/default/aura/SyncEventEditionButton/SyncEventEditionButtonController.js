({
    doInit: function(component, event, helper) {
        component.set("v.Spinner",true);
        var eventEditionId = component.get("v.recordId");
        var getEventEdition = component.get("c.syncPresentEventEditionLtng");
        
        getEventEdition.setParams({
            'evntEdtn' : component.get("v.recordId")
        });
        getEventEdition.setCallback(this,function(data){
            var state = data.getState();
            if(state=='SUCCESS'){ 
                component.set("v.Spinner",false);
                var respose = data.getReturnValue();
                if(respose){
                    setTimeout(function(){
                        window.location.reload();
                    },2000);
                } 
            }  
            else if (state === "ERROR") {
                helper.showToast(component, event, helper);
            }
        });
        $A.enqueueAction(getEventEdition);
    }
})