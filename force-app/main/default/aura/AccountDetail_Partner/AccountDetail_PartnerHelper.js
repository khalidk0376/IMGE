({
    fetchData: function(component, pageNumber) {
        var pageSize = 10;
        var action = component.get("c.getRecords");
        action.setParams({ objName: "AccountPartner", fieldNames: 'Id, AccountToId, AccountTo.Name, Role, AccountFromId', compareWith: 'AccountFromId', recordId: component.get("v.recordId"), pageNumber: pageNumber, pageSize: pageSize });
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {
                var result = res.getReturnValue();
                var respartner = res.getReturnValue().recordList;
                for (var i = 0; i < respartner.length; i++) {
                    if (respartner[i].hasOwnProperty('AccountTo')) {
                        respartner[i].acLink = '/lightning/r/Account/' + respartner[i].AccountToId + '/view';
                        respartner[i].acName = respartner[i].AccountTo.Name;
                    }
                }
                component.set("v.data", respartner);
                component.set("v.PageNumber",pageNumber);
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