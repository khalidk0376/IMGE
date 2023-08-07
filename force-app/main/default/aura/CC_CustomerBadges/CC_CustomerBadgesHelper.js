({
    getUserType: function (component) {
        var sEventCode = component.get("v.eventCode");
        var sEventId = component.get("v.eventId");
        var action = component.get("c.getCurrentUserType"); //Calling Apex class controller 'getCurrentUserType' method
        action.setParams({
            "eventId": sEventId,
            "eventCode": sEventCode
        });
        action.setCallback(this, function(res) {
            var state = res.getState();
            //console.log('state' +state); //Checking response status
            if (component.isValid() && state === "SUCCESS") {
                var result = res.getReturnValue();
                //console.log('result ' +JSON.stringify(result));
                component.set("v.currentUser", result.User_Type__r.Name); 
            }
        });
        $A.enqueueAction(action);
    },
    getUrlParam: function(component) {
        var url = window.location.href;
        var allParams = url.split("?")[1];
        var paramArray = allParams.split("&");
        for (var i = 0; i < paramArray.length; i++) {
          var curentParam = paramArray[i];
          if (curentParam.split("=")[0] == "eventcode") {
            component.set("v.eventCode", curentParam.split("=")[1]);
          }
        }        
        this.getUserType(component);
        this.fetchEventIdAccountId(component, component.get("v.eventCode"));
    },
    fetchEventIdAccountId: function(component, eventCode) {
    var action = component.get("c.getEventIdAccountId");
    action.setParams({ eventCode: eventCode });
    action.setCallback(this, function(a) {
        if (a.getState() == "SUCCESS") {
            console.log('success');
        var data = a.getReturnValue();
        component.set("v.eventId", data.sEventId);
        component.set("v.accountId", data.sAccountId);
        component.set("v.showData", true);
        }
    });
    $A.enqueueAction(action);
    }
})