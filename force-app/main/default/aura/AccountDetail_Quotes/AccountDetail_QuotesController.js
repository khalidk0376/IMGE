({	
    doInit: function (component, event,helper) {
        var recordId = component.get("v.recordId");
        if(recordId.substring(0, 3)=='003')
        {
            component.set("v.objectName","Contact");
        }
        else if(recordId.substring(0, 3)=='001'){
            component.set("v.objectName","Account");
        }
    },
    
})