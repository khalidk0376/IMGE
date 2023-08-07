({
	doInit : function(component, event, helper) {
        var url_string = window.location.href;
        var url = new URL(url_string);
        component.set("v.eventCode",url.searchParams.get("eventCode"));
        component.set("v.eventId",url.searchParams.get("eventId"));
        component.set("v.exhAccountID",url.searchParams.get("exhAccountID"));
        component.set("v.boothId",url.searchParams.get("boothId"));
	}
})