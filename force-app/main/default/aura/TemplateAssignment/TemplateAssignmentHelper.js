({
    crudModalEvent: function(component, event, closeModel, isUpdateRecord) {
        var vDragId = "shareTemp";
        var appEvent = $A.get("e.c:QFFieldModelCloseEvt");
        appEvent.setParams({ "closeModel": closeModel, "isUpdateRecord": isUpdateRecord, "modelName": vDragId });
        appEvent.fire();
    },
    searchLocations:function(component, event,value){
        var action = component.get("c.searchUserType");
        action.setParams({
            searchValue: value
        });
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {
                component.set("v.lstLocations",[]);
                component.set("v.selectedLocations",[]);
                component.set("v.selectedParentLocations",[]);
                component.set("v.includeChildrenIds",[]);
                component.set("v.CurrentPage",0);
                component.set("v.itemsSelected",0);
                component.set("v.lstLocationsIds",[]);
                component.set("v.allPages",[]);
                var data=JSON.parse(res.getReturnValue());
                component.set("v.startSearch",true);
                var lstLocation=component.get("v.lstLocations");
                if(data.length>0){
                    for(var i=0;i<data.length;i++){
                        var locations={Id:data[i].Id,
                                       isSelected:false,
                                       includeChildren:false,
                                       name:data[i].Name};
                        lstLocation.push(locations);
                    }
                }
                var allpages = {};
                var page = {
                    "page" : 0,
                    "Items" : lstLocation,
                    "includeChildrenIds" : [],
                    "lstLocationsIds" : [],
                }
                allpages["Page0"] = page;
                component.set("v.allPages",allpages);
                component.set("v.lstLocations",lstLocation);
                component.set("v.showNextButton",true);
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
    getChildrenLocations:function(component, event, locationIds,lstSelectedLocations) {
        var allpages = component.get("v.allPages");
        var CurrentPage = component.get("v.CurrentPage");
        var isCallApi = allpages["Page"+CurrentPage].CallNextPageApi;
        CurrentPage++;
        component.set("v.CurrentPage",CurrentPage);
        
        if(!isCallApi){
            var pagedata = allpages["Page"+CurrentPage];
            if(pagedata.NoIncludeChildren)
            {
                component.set("v.selectedLocations",pagedata.Items);
                component.set("v.itemsSelected",pagedata.Items.length);
                component.set("v.NoIncludeChildren",true);
                component.set("v.lstLocations",[]);
                component.set("v.showNextButton",false);
                component.set("v.showSaveButton",true);
            }
            else{
                component.set("v.includeChildrenIds",pagedata.includeChildrenIds);
                component.set("v.lstLocationsIds",pagedata.lstLocationsIds);
                component.set("v.itemsSelected",pagedata.lstLocationsIds.length);
                component.set("v.NoIncludeChildren",false);
                var allSelectedLocationIds=component.get("v.lstLocationsIds");
                var allLocationData = pagedata.Items;
                var lstSelectedParentLocations=component.get("v.selectedParentLocations");
                for(var i=0; i< allLocationData.length;i++){
                    if(allSelectedLocationIds.indexOf(allLocationData[i].Id)!==-1){
                        allLocationData[i].isSelected=true;
                        if(lstSelectedParentLocations.indexOf(allLocationData[i])===-1){
                            lstSelectedParentLocations.push(allLocationData[i]);
                        }
                    }
                }
                var includeChildrenIds=component.get("v.includeChildrenIds");
                for(var i=0; i< allLocationData.length;i++){
                    if(includeChildrenIds.indexOf(allLocationData[i].Id)!==-1){
                        allLocationData[i].includeChildren=true;
                    }
                }
                component.set("v.selectedParentLocations",lstSelectedParentLocations);
                component.set("v.lstLocations",allLocationData);
                component.set("v.showNextButton",true);
                component.set("v.showSaveButton",false);
            }
        }
        else{
            var action = component.get("c.fetchChildernLocationData");
            action.setParams({
                lstLocationIds: locationIds
            });
            action.setCallback(this, function(res) {
                var state = res.getState();
                if (state === "SUCCESS") {
                    component.set("v.lstLocations",[]);
                    var data=res.getReturnValue();
                    var lstLocation=component.get("v.lstLocations");
                    if(data.length>0){
                        for(var i=0;i<data.length;i++){
                            var locations={Id:data[i].Id,
                                           isSelected:false,
                                           includeChildren:false,
                                           name:data[i].rkl__Node_Name__c};
                            lstSelectedLocations.push(locations);
                        }
                        var allpages = component.get("v.allPages");
                        var page = {
                            "page" : CurrentPage,
                            "Items" : lstSelectedLocations,
                            "includeChildrenIds" : [],
                            "lstLocationsIds" : [],
                            "CallNextPageApi": false,
                            "NoIncludeChildren":false
                        }
                        allpages["Page"+CurrentPage] = page;
                        component.set("v.allPages",allpages);
                        
                        component.set("v.lstLocations",lstSelectedLocations);
                        component.set("v.NoIncludeChildren",false);
                        component.set("v.includeChildrenIds",[]);
                        component.set("v.lstLocationsIds",[]);
                        component.set("v.itemsSelected","0");
                        component.set("v.selectedLocations",[]);
                    }
                    else{
                        if(component.get("v.selectedParentLocations").length===0){
                            this.showToast(component, event, 'No children found on selected loaction . Please select any location to share','Alert','error');
                            component.set("v.showSaveButton",false);
                            component.set("v.showNextButton",false);
                            return false;
                        }
                        else{
                            component.set("v.selectedLocations",component.get("v.selectedParentLocations"));
                            component.set("v.showNextButton",false);
                            component.set("v.NoIncludeChildren",true);
                            component.set("v.showSaveButton",true);
                            component.set("v.itemsSelected",component.get("v.selectedLocations").length);
                            
                            var allpages = component.get("v.allPages");
                            var page = {
                                "page" : CurrentPage,
                                "Items" : component.get("v.selectedParentLocations"),
                                "includeChildrenIds" : [],
                                "lstLocationsIds" : [],
                                "CallNextPageApi": false,
                            	"NoIncludeChildren":true
                            }
                            allpages["Page"+CurrentPage] = page;
                            component.set("v.allPages",allpages);
                            
                            this.showToast(component, event, 'No children found on selected loaction . This is the final list of location to share.','Alert','error');
                        }
                        
                    	
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
        }
    },
    showToast: function(component, event, message,title,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            duration: '5000',
            type: type,
            mode: 'dismissible'
        });
        toastEvent.fire();
    },
    selectedLocationsToBeSave:function(component, event, saveSelectedLocations) {
        var templateId= component.get("v.templateId");
        var action = component.get("c.saveShareLocationData");
        action.setParams({
            lstLocations: saveSelectedLocations,
            templateId:templateId
        });
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {
                if(res.getReturnValue()===true){
                    this.showToast(component, event, 'Template has been shared successfully','Success','success');
                    this.crudModalEvent(component, event, true, false);
                }
                else{
                    this.showToast(component, event, 'No contacts found in location','Success!','error');
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
    }
})