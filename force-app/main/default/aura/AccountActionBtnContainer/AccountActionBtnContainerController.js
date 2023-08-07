({
	doInit : function(component, event, helper) {
		helper.getAccDetail(component);
	},	
	validateAddress:function(component, event, helper) {
		var urlEvent = $A.get("e.force:navigateToURL");
	    urlEvent.setParams({
	      "url": "/apex/ValidateCustomer?acctId="+component.get("v.recordId")
	    });
	    urlEvent.fire();
	},
	validateTax:function(component, event, helper) {
		var urlEvent = $A.get("e.force:navigateToURL");
	    urlEvent.setParams({
	      "url": "/apex/VATValidation?acctId="+component.get("v.recordId")
	    });
	    urlEvent.fire();
	},
	openNewOppModal : function(component, event, helper) {
		component.set("v.isOpenNewOppModal",true);
	},
    openUploadDocModal : function(component, event, helper) {
		component.set("v.isOpenDocModal",true);
	},
	openPartnerModal: function(component, event, helper) {
		component.set("v.isOpenAddParnerModal",true);
	},
	handleButtonRender : function(component, event, helper) {
		window.setTimeout(
            $A.getCallback(function() { 
                helper.getAccDetailReLoad(component);
            }), 1000
        ); 
    }
})