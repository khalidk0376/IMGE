({
    getQuesCategory: function(component, event) {
        var action = component.get("c.getQuenaireCategory"); //Calling Apex class controller 'getQuenaireCategory' method
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {
                var opts =[];
                var res = res.getReturnValue();
                for(var i=0;i<res.length;i++)
                {
                    if(res[i]!='')
                    opts.push({label:res[i],value:res[i]})
                }
                component.set("v.lstQuenaireCategory", opts);
                console.log(res);
                console.log(opts);
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
    getAllCommunity:function(component){
        var action = component.get("c.getCommunities");
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {
                var opts =[];
                var res = res.getReturnValue();
                for(var i=0;i<res.length;i++)
                {
                    if(res[i]!='')
                    opts.push({label:res[i].label,value:res[i].value})
                }
                component.set("v.lstCommunity", opts);
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
        getCreateTemplate: function(component, event) {
            component.set("v.Spinner", true);
            var selColumnNo = component.get("v.selColumnNo");
            var sectionName = component.get("v.sectionName");
    
            var action = component.get("c.createQnaire"); //Calling Apex class controller 'createQnaire' method
            var vQuesnaire = component.get("v.objQuesnaire");
            action.setParams({ oQnaire: vQuesnaire,sectionName:sectionName, colnum:selColumnNo});
    
            action.setCallback(this, function(res) {
                component.set("v.Spinner", false);
                var state = res.getState();
                console.log('state'+state);
                if (state === "SUCCESS") {
                    component.set("v.QnaireId", res.getReturnValue());
                    var vQnaireId = component.get("v.QnaireId");
                    if (vQnaireId !== undefined && vQnaireId !== "" && vQnaireId.length !== 0) {                    
                        console.log('vQnaireId'+vQnaireId);
                        //changes regarding ticketno.BK-1841
                        var evt = $A.get("e.force:navigateToComponent");
                        evt.setParams({
                            componentDef : "c:TemplateTab",
                            componentAttributes: {
                                tempId : vQnaireId
                            }
                        });
                        evt.fire();
                        //ends here..
                        /*var urlEvent = $A.get("e.force:navigateToURL");
                        urlEvent.setParams({
                            "url": window.location.href + '?tempId=' + vQnaireId
                        });
                       	alert(urlEvent);
                        urlEvent.fire();*/
                        
                    /*var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": vQnaireId,
                        "slideDevName": "detail",
                        "isredirect": true
                    });
                    navEvt.fire();*/
                }
            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error :",
                    "message": res.getError()[0]
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    showToast: function(component, event, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: 'Alert',
            message: message,
            duration: ' 5000',
            key: 'info_alt',
            type: 'error',
            mode: 'dismissible'
        });
        toastEvent.fire();
    },
    getSingleQuestnnaireRecord: function(component, event, questnnaireRecordId) {
        component.set("v.Spinner", true);
        var action = component.get("c.getQnaireRecord");
        action.setParams({ qnaireId: questnnaireRecordId });
        action.setCallback(this, function(res) {
            component.set("v.Spinner", false);
            var state = res.getState();
            if (state === "SUCCESS") {
                var questnIre = res.getReturnValue();
                questnIre.Name = questnIre.Name + '_clone';
                component.set("v.objQuesnaire", questnIre);
            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error :",
                    "message": res.getError()[0]
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    saveTemplateCloneRecord: function(component, event) {
        component.set("v.Spinner", true);
        var oQuesnaire = component.get("v.objQuesnaire");
        var action = component.get("c.saveQnaireCloneRecord");
        action.setParams({ oQnaire: oQuesnaire });
        action.setCallback(this, function(res) {
            component.set("v.Spinner", false);
            var state = res.getState();
            if (state === "SUCCESS") {
                component.set("v.lstQuestionnaire", res.getReturnValue());
                component.set("v.isCloneTemplate", false);
            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error :",
                    "message": res.getError()[0]
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    
   deleteFormRecord : function(component, event, helper) {
        var target = event.getSource();
        var vQnnaireId = target.get("v.value");
        var action = component.get("c.delteFormRecordById");		
        action.setParams({oQnaire:vQnnaireId});
        action.setCallback(this, function(res) {
        	component.set("v.lstQuestionnaire", res.getReturnValue());
        });
        $A.enqueueAction(action);
       
	},
    searchTemplateRecord: function(component, event, page) {
        this.getQuestnnaireRecord(component, event, page);
    },
    getQuestnnaireRecord: function(component, event, page) {
        component.set("v.Spinner", true);
        // get the select option (drop-down) values.   
        var recordToDisply = component.get("v.recordToDisply");
        var searchValue = component.get("v.searchValue");
        var sortOrder = component.get("v.sortOrder");
        var selectCategory = component.get("v.selectCategory");
        var action = component.get("c.getListQnaireRecord"); //Calling Apex class controller 'getListQnaireRecord' method
        action.setParams({            
            sortOrder: sortOrder,
            selectCategory: selectCategory,
            searchValue: searchValue,
            pageNumber: page,
            recordToDisply: recordToDisply
        });
        action.setCallback(this, function(res) {
            component.set("v.Spinner", false);
            var state = res.getState();
            if (state === "SUCCESS") {
                // store the response return value (wrapper class insatance)  
                var result = res.getReturnValue();
                component.set("v.lstQuestionnaire", result.lstQuestionnaire);
                component.set("v.page", result.page);
                component.set("v.total", result.total);
                component.set("v.pages", Math.ceil(result.total / recordToDisply));
                //component.set("v.lstQuestionnaire", res.getReturnValue());
            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error :",
                    "message": res.getError()[0]
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }

})