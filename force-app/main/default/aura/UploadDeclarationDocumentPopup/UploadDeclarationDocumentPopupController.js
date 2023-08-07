({
    closeDocuModal : function(component, event, helper) {
		component.set("v.isOpenDocuModal",false);
		component.set("v.response","false");		
		
        var refrEvent = $A.get("e.c:refreshEvent");
        refrEvent.setParams({
            "response": "false"
        });
        refrEvent.fire();
        
        if(component.get("v.isBpNumberPopUp") == true){
			
			//component.set("v.isEditForm",false);
		}
	}, 
	closeDocuModalOk: function(component, event, helper) {
		component.set("v.response","true");
        var refrEvent = $A.get("e.c:refreshEvent");
	    refrEvent.setParams({
	      "response": "true"
	    });
	    refrEvent.fire();
		
	  //component.set("v.isBpNumberPopUp",false);
   		
    },
    OpenPopUpModel: function(component, event, helper) {
	   var acId = component.get("v.recordId");
        var urlEvent = $A.get("e.force:navigateToURL");
	    urlEvent.setParams({
	      "url": "/apex/Upload_Declaration_Document?oppid="+acId
	    });
	    urlEvent.fire();
    }
})