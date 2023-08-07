({
  
	getExistingFiles : function (component, event, helper){
		helper.getExistingFiles(component);
        helper.getAccountName(component);
	},
	
	handleUploadFinished : function (component, event, helper) {
        helper.handleUploadFinished(component, event);
    },

    handleCancelUpload : function(component, event, helper){
	helper.handleCancelUpload(component);
    },

    handleSaveClick : function(component, event, helper){
	helper.handleSaveClick(component);
    },
    closeDocuModal : function(component, event, helper) {
		component.set("v.isOpenDocuModal",false);
		component.set("v.response","false");		
		
        var refrEvent = $A.get("e.c:refreshEvent");
        refrEvent.setParams({
            "response": "false"
        });
        refrEvent.fire();
        
        if(component.get("v.isMultipleFileUploadPopUp") == true){
			
			//component.set("v.isEditForm",false);
		}
	}
})