({
	loadData : function(component, event, helper) {
		 
	},
    editRecord : function(component, event, helper) {
        component.set("v.showSpinner",true);
		component.set("v.isEditForm",true);
	},
    handleLoad: function(component, event, helper) {
		 component.set("v.showSpinner",false);
	},
    handleSubmit: function(component, event, helper) {
		
	},
    handleSuccess: function(component, event, helper) {
		component.set("v.isEditForm",false);
	},
    handleCancel: function(component, event, helper) {
		component.set("v.isEditForm",false);
	}
})