({
    callScriptsLoaded : function(component, event) {        
        $( "#sortable" ).sortable({
            placeholder: "ui-state-highlight",
            cursor: "move",
            start: function(e, ui) {
                // creates a temporary attribute on the element with the old index
                $(this).attr('data-previndex', ui.item.index());
            },
            update: function(e, ui){
                var newIndex = ui.item.index();
                var oldIndex = $(this).attr('data-previndex');
                var lstQuestnGrp = component.get("v.lstQuestnGroup");
                // When section from top to bottom
                console.log(JSON.stringify(lstQuestnGrp));
                var upQOrder = newIndex;
				if(newIndex>oldIndex){
                    lstQuestnGrp[oldIndex].Sort_Order__c=newIndex;
                    for(var i=upQOrder;i>=oldIndex;i--){
                        if(lstQuestnGrp[i].Id!==lstQuestnGrp[oldIndex].Id){
                            upQOrder--;
							lstQuestnGrp[i].Sort_Order__c=upQOrder;
                            console.log(lstQuestnGrp[i]);
                        }
						
                    }
                }
                // When section from top to bottom
                else{
                    lstQuestnGrp[oldIndex].Sort_Order__c=newIndex;
					for(var j=upQOrder;j<=oldIndex;j++){
                        if(lstQuestnGrp[j].Id!==lstQuestnGrp[oldIndex].Id){
                            upQOrder++;
							lstQuestnGrp[j].Sort_Order__c=upQOrder;
                            console.log(lstQuestnGrp[j]);
						}
                    }
                }
                lstQuestnGrp.sort(function(a,b){
                    if (a.Sort_Order__c < b.Sort_Order__c)
                    	return -1;
                  	if (a.Sort_Order__c > b.Sort_Order__c)
                    	return 1;
                  	return 0;
                });
                
                console.log(JSON.stringify(lstQuestnGrp));
                component.set("v.lstQuestnGroup",lstQuestnGrp);
            }
        });
        $( "#sortable" ).disableSelection();
    },
    crudModalEvent: function(component, event, closeModel, isUpdateRecord) {
        var appEvent = $A.get("e.c:QFFieldModelCloseEvt");
        appEvent.setParams({ "closeModel": closeModel, "isUpdateRecord": isUpdateRecord, "modelName": "ReorderSection" });
        appEvent.fire();
    },
    getAllSections:function(component, event,qnaireId){
        var action = component.get("c.getQuestionGroups"); //Calling Apex class controller 'getAllQuestnGrpNameForQuesnnaire' method
        action.setParams({
            qnaireId: qnaireId
        });
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {
                component.set("v.lstQuestnGroup", res.getReturnValue());
                console.log(res.getReturnValue());
            } else {
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
    },
    updateSortedSections:function(component, event, lstQstnGrp){
        var action = component.get("c.updateQuestionGroupsSortingOrder"); //Calling Apex class controller 'getAllQuestnGrpNameForQuesnnaire' method
        action.setParams({
            lstUpdatedQstnGrp: lstQstnGrp
        });
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {
                component.set("v.lstQuestnGroup", res.getReturnValue());
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: 'Success',
                    message: "Successfully re-order sections",
                    duration: '500',
                    key: 'info_alt',
                    type: 'SUCCESS',
                    mode: 'dismissible'
                });
                toastEvent.fire();
                this.crudModalEvent(component, event, false, true);
            } else {
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