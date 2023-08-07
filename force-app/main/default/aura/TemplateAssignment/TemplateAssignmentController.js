({
    doInit:function(component, event, helper){
        var tempIdWithName= component.get("v.tempNameWithId");
        var tempName=tempIdWithName.split("~")[1];
        component.set("v.templateId",tempIdWithName.split("~")[0]);
        component.set("v.tempNameWithId",tempName);
    },
    hideModal: function(component, event, helper) {
        helper.crudModalEvent(component, event, true, false);
    },
    searchLocation:function(component, event, helper) {
        var message;
        var searchValue=component.get("v.searchValue");
        if(!!searchValue){
            helper.searchLocations(component, event,searchValue);
        }else{
            message='Please enter value in field.';
            helper.showToast(component, event, message,'Alert','error');
            var lstLoc=[];
            component.set("v.lstLocations",lstLoc);
        }
    },
    searchLocationOnEnter:function(component, event, helper) {
        var message;
        if(event.which == 13){
            var searchValue=component.get("v.searchValue");
            if(!!searchValue){
                helper.searchLocations(component, event,searchValue);
            }else{
                message='Please enter value in field.';
                helper.showToast(component, event, message,'Alert','error');
                var lstLoc=[];
                component.set("v.lstLocations",lstLoc);
            }
        }
        
    },
    getSelectId:function(component, event, helper){
        var lstLocationIds=component.get("v.lstLocationsIds");
        var locationId = event.target.id;
        var checked = event.target.checked;
        if(checked){
            lstLocationIds.push(locationId);
        }
        else{
            var index = lstLocationIds.indexOf(locationId);
            lstLocationIds.splice(index, 1);
        }
        var CurrentPage = component.get("v.CurrentPage");
        var allpages = component.get("v.allPages");
        allpages["Page"+CurrentPage].lstLocationsIds = lstLocationIds;
        allpages["Page"+CurrentPage].CallNextPageApi = true;
        component.set("v.allPages",allpages);
        component.set("v.lstLocationsIds",lstLocationIds);
        component.set("v.itemsSelected",lstLocationIds.length);
    },
    showSelectedLocations:function(component, event, helper){
        var allLocationData=component.get("v.lstLocations");
        var allSelectedLocationIds=component.get("v.lstLocationsIds");
        var lstSelectedLocations=component.get("v.selectedLocations");
        var includeChildrenIds=component.get("v.includeChildrenIds");
        var lstSelectedParentLocations=component.get("v.selectedParentLocations");
        if(allSelectedLocationIds.length>0){
            // When include children are checked
            if(includeChildrenIds.length>0){
                for(var i=0; i< allLocationData.length;i++){
                    if(allSelectedLocationIds.indexOf(allLocationData[i].Id)!==-1){
                        allLocationData[i].isSelected=true;
                        if(lstSelectedParentLocations.indexOf(allLocationData[i])===-1){
                            lstSelectedParentLocations.push(allLocationData[i]);
                        }
                    }
                    else{
                        allLocationData[i].isSelected=false;
                    }
                }
                for(var i=0; i< allLocationData.length;i++){
                    if(includeChildrenIds.indexOf(allLocationData[i].Id)!==-1){
                        allLocationData[i].includeChildren=true;
                    }
                }
                component.set("v.selectedParentLocations",lstSelectedParentLocations);
                helper.getChildrenLocations(component, event,includeChildrenIds,lstSelectedLocations);
            }
            else{
                // When only parent are selected i.e no include children are selected
                component.set("v.selectedLocations",[]);
                var arrparentIds = [];
                var CurrentPage = component.get("v.CurrentPage");
                var allpages = component.get("v.allPages");
                
                /*if(lstSelectedParentLocations.length>0){
                    for(var parentIndex=0;parentIndex<lstSelectedParentLocations.length;parentIndex++){
                        if(arrparentIds.indexOf(lstSelectedParentLocations[parentIndex].Id) === -1){
                        	lstSelectedLocations.push(lstSelectedParentLocations[parentIndex]);
                            arrparentIds.push(lstSelectedParentLocations[parentIndex].Id);
                        }
                    }
                }*/
                
                for(var i=0;i<CurrentPage;i++){
                    var pagedata = allpages["Page"+i];
                    for(var j=0;j<pagedata.Items.length;j++)
                    {
                        if(pagedata.Items[j].isSelected){
                            lstSelectedLocations.push(pagedata.Items[j]);
                            arrparentIds.push(pagedata.Items[j].Id);
                        }
                    }
                }
                
                
                
                for(var i=0; i<allLocationData.length;i++){
                    if(allSelectedLocationIds.indexOf(allLocationData[i].Id)!==-1){
                        allLocationData[i].isSelected=true;
                        if(arrparentIds.indexOf(allLocationData[i].Id) === -1){
                        	lstSelectedLocations.push(allLocationData[i]);
                            arrparentIds.push(allLocationData[i].Id);
                        }
                    }
                    else{
                        allLocationData[i].isSelected=false;
                    }
                }
                
                
                CurrentPage++;
                component.set("v.CurrentPage",CurrentPage);
                
                var page = {
                    "page" : CurrentPage,
                    "Items" : lstSelectedLocations,
                    "includeChildrenIds" : component.get("v.includeChildrenIds"),
                    "lstLocationsIds" : component.get("v.lstLocationsIds"),
                    "lstParentLocationData":component.get("v.selectedParentLocations"),
                    "CallNextPageApi": false,
                    "NoIncludeChildren":true
                }
                allpages["Page"+CurrentPage] = page;
                component.set("v.allPages",allpages);
                
                component.set("v.selectedLocations",lstSelectedLocations);
                component.set("v.itemsSelected",lstSelectedLocations.length);
                
                component.set("v.NoIncludeChildren",true);
                component.set("v.lstLocations",[]);
                component.set("v.showNextButton",false);
                component.set("v.showSaveButton",true);
            }
        }
        else{
            if(includeChildrenIds.length>0){
                helper.getChildrenLocations(component, event,includeChildrenIds,lstSelectedLocations);
            }
            else{
                var message='Please select location.';
                helper.showToast(component, event, message,'Alert','error');
                return false;
            }
            
        }
        component.set("v.showSearchBar",false);
        component.set("v.showBackButton",true);
    },
    showPreviousLocations:function(component, event, helper){
        component.set("v.NoIncludeChildren",false);
        component.set("v.selectedLocations",[]);
        var CurrentPage = component.get("v.CurrentPage");
        CurrentPage--;
        component.set("v.CurrentPage",CurrentPage);
        var allPages = component.get("v.allPages");
        var pagedata = allPages["Page"+CurrentPage];
        pagedata.CallNextPageApi = false;
        component.set("v.allPages",allPages);
        component.set("v.lstLocations",pagedata.Items);
        component.set("v.includeChildrenIds",pagedata.includeChildrenIds);
        component.set("v.lstLocationsIds",pagedata.lstLocationsIds);
        
        if(CurrentPage===0){
            component.set("v.showBackButton",false);
            component.set("v.showSearchBar",true);
        }
        component.set("v.showNextButton",true);
        component.set("v.showSaveButton",false);
        component.set("v.itemsSelected",pagedata.lstLocationsIds.length);
        //component.set("v.itemsSelected","0");
    },
    deleteLocation:function(component, event, helper){
        var deleteLocationIndex=event.getSource().get("v.value");
        var selectedLocations=component.get("v.selectedLocations");
        var CurrentPage = component.get("v.CurrentPage");
        var allPages = component.get("v.allPages");
        //console.log('allPages:='+JSON.stringify(allPages));
        
        //if(allPages["Page"+CurrentPage].Items!=undefined){
            var allLocationData=allPages["Page"+CurrentPage].Items;
            var lstLocationIds=allPages["Page"+CurrentPage].lstLocationsIds;
            for(var i=0;i<allLocationData.length;i++){
                if(selectedLocations[deleteLocationIndex].Id.indexOf(allLocationData[i].Id)!==-1){
                    allLocationData[i].isSelected=false;
                    allLocationData.splice(i, 1);
                }
            }
            allPages["Page"+CurrentPage].Items=allLocationData;
            for(var j=0;j<=CurrentPage;j++){
                var index=allPages["Page"+j].lstLocationsIds.indexOf(selectedLocations[deleteLocationIndex].Id);
                if(index != -1){
                    allPages["Page"+j].lstLocationsIds.splice(index, 1);
                }
            }
            component.set("v.allPages",allPages);
            component.set("v.lstLocations",allLocationData)
            selectedLocations.splice(deleteLocationIndex, 1);
            component.set("v.selectedLocations",selectedLocations);
            component.set("v.selectedParentLocations",selectedLocations);
            component.set("v.itemsSelected",selectedLocations.length);
    },
    includeChildren:function(component, event, helper){
        var event=event.getSource();
        var checked=event.get("v.checked");
        var locationId=event.get("v.name");
        var includeChildrenIds=component.get("v.includeChildrenIds");
        if(checked){
            includeChildrenIds.push(locationId);
        }
        else{
            var index = includeChildrenIds.indexOf(locationId);
            includeChildrenIds.splice(index, 1);
        }
        var CurrentPage = component.get("v.CurrentPage");
        var allpages = component.get("v.allPages");
        allpages["Page"+CurrentPage].includeChildrenIds = includeChildrenIds;
        allpages["Page"+CurrentPage].CallNextPageApi = true;
        component.set("v.allPages",allpages);
        component.set("v.includeChildrenIds",includeChildrenIds);
    },
    saveSelectedLocations:function(component, event, helper){
        var saveSelectedLocations = component.get("v.selectedLocations");
        helper.selectedLocationsToBeSave(component, event,saveSelectedLocations);
    }
})