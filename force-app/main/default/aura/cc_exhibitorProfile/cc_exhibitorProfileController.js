({
    OnloadData : function(component, event, helper) {
        let fullUrl = window.location.href;
        var eventcode=helper.GetQS(fullUrl,'eventcode');
        if(eventcode){
            component.set("v.eventCode",eventcode);
        }
        helper.fetchEventDetails(component,eventcode);
        helper.fetchUserDetails(component);
        helper.fetchUserDetails(component,eventcode);
        helper.getUserType(component,eventcode);
    },
    goToHome:function(component, event, helper) {
        var url =window.location.href;
		if(url.includes('/s/')){
			window.location.href='/CustomerCenter/s/?eventcode='+component.get("v.eventCode");
		}
		else{
			window.location.href='home?eventcode='+component.get("v.eventCode");
		}
	}
})