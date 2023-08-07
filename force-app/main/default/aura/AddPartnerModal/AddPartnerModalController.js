({
	doInit : function(component, event, helper) {		
        //alert(component.get("v.recordId"));
		component.set("v.partnerObj",{sobjectType:'Partner',AccountFromId:component.get("v.recordId")});
		helper.getMetadata(component);
	},
	closeModal : function(component, event, helper) {
		component.set("v.isOpenModal",false);
	},	
	handleSubmit: function(component, event, helper) {
	   if(helper.validate(component)){
            helper.addPartner(component);   
       }
       else{
            window._LtngUtility.toast('Error!','error','Please update the invalid form entries and try again.');
       }
    },
	/*
    handleSuccess: function(component, event,helper) {    	
        var payload = event.getParams().response;
        component.set("v.spinner",false);
        window._LtngUtility.toast('Success','success','New Partner has been created');
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          "recordId": payload.id,
          "slideDevName": "detail"
        });
        navEvt.fire();
    }*/
})