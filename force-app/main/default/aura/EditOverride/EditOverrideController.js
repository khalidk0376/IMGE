({
    redirect : function( component, event, helper ) {
        var value = component.find("recid").get("v.value");
        var eUrl= $A.get("e.force:navigateToURL");
        eUrl.setParams({ "url": '/' +value });
        eUrl.fire( );
    }
})