({
    
    doInit: function(component, event, helper) {
        var pageNumber = component.get("v.PageNumber");  
        var pageSize = component.find("pageSize").get("v.value"); 
        helper.getAttachmentList(component, pageNumber, pageSize);
        helper.getProfileName(component);
    },
    reloaddataAtt : function(component, event, helper){
        var pageNumber = component.get("v.PageNumber");  
        var pageSize = component.find("pageSize").get("v.value");
        var action = component.get("c.getAttachments");
        action.setParams({
            'ParentId' : component.get("v.recordId"),
            "pageNumber": pageNumber,
            "pageSize": pageSize
        });
        action.setCallback(this, function(result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                console.log('Test data');
                var resultData = result.getReturnValue();
                component.set("v.TotalRecords", resultData.totalRecords+1);
            }
        });
        $A.enqueueAction(action);
    },
    handleNext: function(component, event, helper) {
        var pageNumber = component.get("v.PageNumber");  
        var pageSize = component.find("pageSize").get("v.value");
        pageNumber++;
        helper.getAttachmentList(component, pageNumber, pageSize);
    },
    
    handlePrev: function(component, event, helper) {
        var pageNumber = component.get("v.PageNumber");  
        var pageSize = component.find("pageSize").get("v.value");
        pageNumber--;
        helper.getAttachmentList(component, pageNumber, pageSize);
    },
    
    onSelectChange: function(component, event, helper) {
        var page = 1
        var pageSize = component.find("pageSize").get("v.value");
        helper.getAttachmentList(component, page, pageSize);
    },
    
    deleteAttachment: function(component, event, helper) {
        var attachmentId = event.target.getElementsByClassName('attachmentId')[0].value;
        var action = component.get("c.getAttachmentDel");
        action.setParams({
            'AttachmentDelId' :attachmentId
        });
        action.setCallback(this, function(result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                var resultData = result.getReturnValue();
                var pageNumber = component.get("v.PageNumber");  
                var pageSize = component.find("pageSize").get("v.value"); 
                helper.getAttachmentList(component, pageNumber, pageSize);
            }
        });
        $A.enqueueAction(action);
    },
    
})