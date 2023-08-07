({
	doInit : function(component, event, helper) {
        var url_string = window.location.href;
        var url = new URL(url_string);
        var c = url.searchParams.get("recordId");
        component.set("v.recordId",c);
	}
})