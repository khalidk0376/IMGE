({
	doInit : function(component, event, helper) {
        var url_string = window.location.href;
        var url = new URL(url_string);
        component.set("v.uType",url.searchParams.get("uType"));
        component.set("v.eventId",url.searchParams.get("eventId"));
        component.set("v.exhAccountID",url.searchParams.get("exhAccountID"));
        component.set("v.eventCode",url.searchParams.get("eventCode"));        
	}
})