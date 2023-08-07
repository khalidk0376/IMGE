({
    getData : function(cmp) {
        var action = cmp.get('c.getOpportunities');           
        var accountId= cmp.get("v.geRecordNumber");
        action.setParams({ AccountId : accountId });
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set('v.mydata', response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
        }));
        $A.enqueueAction(action);
    }
})