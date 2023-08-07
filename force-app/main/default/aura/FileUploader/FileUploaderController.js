({
    onLoad: function(component, event, helper) {
       console.log('Load'); 
       helper.fetchAttchments(component);
    },    
    doSave: function(component, event, helper) {
        if (component.find("fileId").get("v.files").length > 0) {
            helper.uploadHelper(component, event);
            
        } else { 
            helper.showToast(component, 'Please select a valid file','Alert!','alert');
        }
    },
    handleFilesChange: function(component, event, helper) {
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
        }
        component.set("v.fileName", fileName);
        if (component.find("fileId").get("v.files").length > 0) {
            helper.uploadHelper(component, event);
        } else {
            helper.showToast(component, 'Please select a valid file','Alert!','alert');
        }
    },
    download: function(component,event,helper) {
        helper.downloadfile(component, event, helper); 
    },
    closeToast: function(component, event, helper) {
        component.set("v.msgbody",'');
        component.set("v.msgtype",'');
    }
})