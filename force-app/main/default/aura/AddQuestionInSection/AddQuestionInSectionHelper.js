({
	crudModalEvent: function(component, event, closeModel, isUpdateRecord) {
        var appEvent = $A.get("e.c:QFFieldModelCloseEvt");
        // Optional: set some data for the event (also known as event shape)
        // A parameter’s name must match the name attribute
        // of one of the event’s <aura:attribute> tags
        appEvent.setParams({ "closeModel": closeModel, "isUpdateRecord": isUpdateRecord, "modelName": "AddQstnSection" });
        appEvent.fire();
    },
    saveQuestnInSectn:function(component,event, selectedSectionId,qstnQnaireId,targetCol) {

        var action=component.get("c.saveQstnInSection");
		action.setParams({
            qquaireId: qstnQnaireId,
            selectedSectionId:selectedSectionId,
            targetCol:'col'+targetCol
        });
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {
                
				if(res.getReturnValue()===false){
                	this.showToast(component, event,"Info!", 'Question is already in this section.',"info");
                    this.crudModalEvent(component, event, false, true);
				}
				else{
                    this.showToast(component, event,"Success!", 'Question has been moved successfully.',"success");
                    this.crudModalEvent(component, event, false, true);
                }
                
            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error :",
                    "type": "error",
                    "message": res.getError()[0].message
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    showToast: function(component, event, title,message,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            duration: ' 5000',
            key: 'info_alt',
            type: type,
            mode: 'dismissible'
        });
        toastEvent.fire();
    }
})