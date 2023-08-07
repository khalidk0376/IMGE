({
	doInit : function(component, event, helper) {
        var url_string = window.location.href;
        var url = new URL(url_string);        
        component.set("v.eventId",url.searchParams.get("eventId"));
        component.set("v.eventName",url.searchParams.get("eventName"));
        document.title = component.get("v.eventName");
	}
})