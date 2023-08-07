({
	handleNavigation : function(component, event, helper) {
		var evtAttrib = event.getParam("isEditMode");
        component.set("v.isEditForm",evtAttrib);
	}
})