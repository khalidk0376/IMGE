({
	GetOpportunity: function(component, event, helper) {
        var action = component.get("c.getOpportunityCtr"); //Calling controller Apex class's  'GetContactsCtr' method
        var AccountId= component.get("v.AccountId");
        var utype= component.get("v.uType");
        // console.log('AccountId>>>'+AccountId);
        var EventId= component.get("v.EventId");
        action.setParams({
            sAccountId:AccountId,
            sEventId: EventId,
            suType : utype
        });
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {                
                component.set("v.OppWrapper", res.getReturnValue());
                //console.log(JSON.stringify(res.getReturnValue()));
                //console.log(component.get("v.OppWrapper"));
            }
        });
        $A.enqueueAction(action);
    },
    SendEmail: function(component, event, helper) {
        var action = component.get("c.sendEmails"); //Calling controller Apex class's  'GetContactsCtr' method
        var ConId=event.getSource().get("v.value");
        var EventId= component.get("v.EventId");
        //console.log('ConId========='+ConId);
        //console.log('EventId========='+EventId);
        action.setParams({
            sContactId: ConId,
            sEventId : EventId
        });
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS")
            {         
                console.log('Email response is SUCCESS');
            }
        });
        $A.enqueueAction(action);
    },
    resetPassword: function(component, event, helper) {
        var action = component.get("c.resetPasswords"); //Calling controller Apex class's  'resetPassword' method
        var ConId=event.getSource().get("v.value");
        //console.log('ConId========='+ConId);
        action.setParams({
            sContactId: ConId,
        });
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS")
            {         
                console.log('Reset Password email send');
            }
        });
        $A.enqueueAction(action);
    }
})