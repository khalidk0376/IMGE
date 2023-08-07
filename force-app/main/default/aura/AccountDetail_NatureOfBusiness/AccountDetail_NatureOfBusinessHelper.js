({
    fetchData: function(component) {
        var action = component.get("c.getNatureOfBusiness");
        action.setParams({ recordId: component.get("v.recordId") });
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {
                var resNatureOfBusiness = res.getReturnValue();
                for (var i = 0; i < resNatureOfBusiness.length; i++) {
                    if (resNatureOfBusiness[i].Opportunity__c) {
                        resNatureOfBusiness[i].opplink = '/lightning/r/Opportunity/' + resNatureOfBusiness[i].Opportunity__c + '/view';
                    }
                    if (resNatureOfBusiness[i].hasOwnProperty('Opportunity__r')) {
                        if(resNatureOfBusiness[i].Opportunity__r.Name){
                            resNatureOfBusiness[i].oppName = resNatureOfBusiness[i].Opportunity__r.Name;    
                        }
                    }
                }
                component.set("v.data", resNatureOfBusiness);
            } else {
                window._LtngUtility.handleErrors(res.getError());
            }
        });
        $A.enqueueAction(action);
    }
})