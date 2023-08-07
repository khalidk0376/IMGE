({
    sortData: function(component, fieldName, sortDirection, table) {
        var data = [];
        if (table === 1) {
            data = component.get("v.oppMappingRecordsInactive");
        } else {
            data = component.get("v.oppMappingRecordsActive");
        }
        var key = function(a) {
            return a[fieldName];
        };
        var reverse = sortDirection == "asc" ? 1 : -1;
        data.sort(function(a, b) {
            var a = key(a) ? key(a).toLowerCase() : "";
            var b = key(b) ? key(b).toLowerCase() : "";
            return reverse * ((a > b) - (b > a));
        });
        if (table === 1) {
            component.set("v.oppMappingRecordsInactive", data);
        } else {
            component.set("v.oppMappingRecordsActive", data);
        }
    },
    moveCCDataUpdate: function(component, event, helper) {
        var notSelectedInactive = false;
        var notSelectedActive = false;
        var notSelectedAny = false;
        component.set("v.showSpinner", true);
        var activeBoothSelected = component.get("v.selectedActiveId");
        var inactiveBoothSelected = component.get("v.selectedInactiveId");
        if (activeBoothSelected == undefined || activeBoothSelected == null) {
            notSelectedActive = true;
        }
        if (inactiveBoothSelected == undefined || inactiveBoothSelected == null) {
            notSelectedInactive = true;
        }
        if (notSelectedInactive == true && notSelectedActive == true) {
            notSelectedAny = true;
        }
        if (notSelectedAny) {
            component.set("v.showSpinner", false);
            window._LtngUtility.toast(
                "Error",
                "error",
                "Please select released and rented booth to perform action."
            );
            return;
        } else if (notSelectedActive) {
            component.set("v.showSpinner", false);
            window._LtngUtility.toast(
                "Error",
                "error",
                "Please select rented booth to move data."
            );
            return;
        } else if (notSelectedInactive) {
            component.set("v.showSpinner", false);
            window._LtngUtility.toast(
                "Error",
                "error",
                "Please select released booth to move data from."
            );
            return;
        }
        var action = component.get("c.moveAndUpdateCCObjects");
        action.setParams({
            inactiveBoothSelected: inactiveBoothSelected,
            activeBoothSelected: activeBoothSelected
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                component.set("v.showSpinner", false);        
                window._LtngUtility.toast(
                    "Success",
                    "success",
                    "Data has been moved successfully."
                );                 
                var selectedRowsIds = [];
                var InActTable = component.find("tableInactive");
                var ActTable = component.find("tableActive");
                if(InActTable){
                    InActTable.set("v.selectedRows", selectedRowsIds);            
                }  
                if(ActTable){
                    ActTable.set("v.selectedRows", selectedRowsIds);            
                }                  
            }
        });
        $A.enqueueAction(action);
    }
});