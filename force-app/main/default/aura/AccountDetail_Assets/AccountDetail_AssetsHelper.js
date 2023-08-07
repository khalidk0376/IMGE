({
    fetchData: function(component, pageNumber) {
        var pageSize = 10;
        var action = component.get("c.getRecords");
        action.setParams({ objName: "Asset", fieldNames: 'Id, Name, Event_Edition__r.Name, Product2.Name, Price_Sold_Price__c, Quantity', compareWith: 'AccountId', recordId: component.get("v.recordId"), pageNumber: pageNumber, pageSize: pageSize });
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {
                var result = res.getReturnValue();
                var resAsset = res.getReturnValue().recordList;
                for (var i = 0; i < resAsset.length; i++) {
                    if (resAsset[i].hasOwnProperty("Event_Edition__r")) {
                        resAsset[i].eeurl = '/lightning/r/Event_Edition__c/' + resAsset[i].Event_Edition__r.Id + '/view';
                        resAsset[i].eename = resAsset[i].Event_Edition__r.Name;
                    }
                    resAsset[i].url = '/lightning/r/Asset/' + resAsset[i].Id + '/view';
                    resAsset[i].rcName = resAsset[i].Name;
                }

                component.set("v.data", resAsset);
                component.set("v.TotalRecords", result.totalRecords);
                component.set("v.RecordStart", result.recordStart);
                component.set("v.RecordEnd", result.recordEnd);
                component.set("v.TotalPages", Math.ceil(result.totalRecords / pageSize));
                component.set("v.showSpinner", false);
            } else {
                window._LtngUtility.handleErrors(res.getError());
            }
        });
        $A.enqueueAction(action);
    }
})