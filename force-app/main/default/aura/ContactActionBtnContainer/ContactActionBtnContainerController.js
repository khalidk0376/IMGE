({
	doInit : function(component, event, helper) {
		helper.getConDetail(component);
	},	
	openNewOppModal : function(component, event, helper) {
		component.set("v.isOpenNewOppModal",true);
	},
	goToLink : function(component, event, helper) {
		var urlEvent = $A.get("e.force:navigateToURL");
	    urlEvent.setParams({
	      "url": "/apex/ValidateBlngContactAccntBlngAdd?contactId="+component.get("v.recordId")
	    });
	    urlEvent.fire();
	}
})