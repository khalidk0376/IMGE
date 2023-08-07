({  
    handleSave: function(component, event, helper) {
        var file =  component.find("fuploader");
        if(file.get("v.files") && file.get("v.files").length > 0 ){         
            component.set("v.spinner",true);
            helper.uploadHelper(component, event);
        } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Warning !",
                message: "Please Select a File.",
                type: "Warning"
            });
            toastEvent.fire();
        }
    },
    
    handleFilesChange: function(component, event, helper) {
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
        }
        component.set("v.fileName", fileName);
    },
    
    handleCancel: function(component, event, helper){	
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": '/'+component.get("v.parentId")
        });
        urlEvent.fire();
    }
})