({
	deleteModalEvent :function(component,event,close,isRecordDeleting){
        var appEvent = $A.get("e.c:QFDeleteModalEvt");
        // Optional: set some data for the event (also known as event shape)
        // A parameter’s name must match the name attribute
        // of one of the event’s <aura:attribute> tags
        appEvent.setParams({"closeDeleteModel" : close,"deleteRecord":isRecordDeleting});
        appEvent.fire();
    },
    deleteSectionHelper : function(component,event,secId,questionaryId){
        var action = component.get("c.deleteSectionWithQuestionsAndQstnQustnry"); 
        action.setParams({ 
            sectionId : secId,
            questionaryId:questionaryId
        });
        action.setCallback(this,function(res){
            var state = res.getState(); 
            if(state === "SUCCESS"){
                this.deleteModalEvent(component,event,true,true);
            }
            else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error :",
                    "mode": "sticky",
                    "message": res.getError()[0].message
                });
                toastEvent.fire();
            } 
        });        
        $A.enqueueAction(action);
    }
})