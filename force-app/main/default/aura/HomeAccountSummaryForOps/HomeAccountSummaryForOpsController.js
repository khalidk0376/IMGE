({
	doInit : function(component, event, helper) {		
		var eventCode = helper.getParameter("eventcode");
		if(eventCode!=null && eventCode!=undefined && eventCode!=''){
			component.set("v.eventCode",eventCode);	
		}
		
		helper.getOppBoothDetails(component);
	}
})