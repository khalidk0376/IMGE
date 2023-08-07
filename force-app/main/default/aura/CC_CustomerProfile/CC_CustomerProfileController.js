({
    loadBoothValues : function(component,event, helper) {
        helper.getUserType(component);
        helper.loadBooths(component,event);
    },
    getPicklistValue : function(cmp) {
        var booth = cmp.find("oppBoothID").get("v.value");
        //console.log('booth ' +booth);
        cmp.set('v.boothId',booth);
    },
    closeMessage : function(cmp)
    {
        cmp.set('v.showMessage', false);
    }
})