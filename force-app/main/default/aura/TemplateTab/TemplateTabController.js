({
    doInit: function(component, event, helper) {
            //BK-6789 Start
            let fullUrl = window.location.href;
            if (fullUrl.indexOf("#") > -1) {
                let id=fullUrl.split("#tempId=")[1];
                component.set("v.tempId", id);
            }
            // BK-6789 end
        //changes regarding ticketno.BK-1841
        var tempId = component.get("v.tempId");
        //ends here..
        var previewId = helper.getParameterByName(component, 'previewTemp');        
        if (tempId !== undefined && tempId !== "" && tempId !== null) {
            component.set("v.QnaireId", tempId);
            component.set("v.activeTab", "createTemplate");
        }
        if (previewId !== undefined && previewId !== "" && previewId !== null) {
            component.set("v.QnaireId", previewId);
            component.set("v.activeTab", "previewTemplate");
        }
        var recordId = component.get("v.recordId");        
        if(recordId !== undefined && recordId !=="" && recordId !== null){
            component.set("v.QnaireId", recordId);
            component.set("v.activeTab", "createTemplate")
        }
    },
    handleApplicationEvent: function(component, event, helper) {

        var vCompName = event.getParam("compName");
        var vQnaireId = event.getParam("QuesnaireId");
        component.set("v.QnaireId", vQnaireId);
        component.set("v.activeTab", vCompName);
    }

})