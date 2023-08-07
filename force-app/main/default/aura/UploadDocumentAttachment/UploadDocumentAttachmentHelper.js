({
    /*// Fetch the accounts from the Apex controller
    getAttachmentList: function(component) {
        var action = component.get('c.getAttachments');
        action.setParams ({'ParentId' : component.get("v.recordId")
                          });
        // Set up the callback
        var self = this;
        action.setCallback(this, function(actionResult) {
            component.set('v.Attachments', actionResult.getReturnValue());
        });
        $A.enqueueAction(action);
        
    } */
    getAttachmentList: function(component, pageNumber, pageSize) {
        var action = component.get("c.getAttachments");
        action.setParams({
    		'ParentId' : component.get("v.recordId"),
            "pageNumber": pageNumber,
            "pageSize": pageSize
        });
        action.setCallback(this, function(result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                var resultData = result.getReturnValue();
                component.set("v.Attachments", resultData.attachmentList);
                component.set("v.PageNumber", resultData.pageNumber);
                component.set("v.TotalRecords", resultData.totalRecords);
                component.set("v.RecordStart", resultData.recordStart);
                component.set("v.RecordEnd", resultData.recordEnd);
                component.set("v.TotalPages", Math.ceil(resultData.totalRecords / pageSize));
            }
        });
        $A.enqueueAction(action);
    },
    
    getProfileName: function(component) {
        
        var action = component.get("c.getProfileName");
        action.setCallback(this, function(result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                var resultData = result.getReturnValue();
                component.set("v.isEnableProfile",resultData.profile);
            }
        });
        $A.enqueueAction(action);
    }
})