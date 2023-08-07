({
    GetQS: function(url, key) {
        var a = "";
        if(url.includes('?'))
        {
            var Qs = url.split('?')[1].replace(/^\s+|\s+$/g, '');
            if (Qs !== "") {
                let qsArr = Qs.split("&");
                for (let i = 0; i < qsArr.length; i++)
                    if (qsArr[i].split("=")[0] === key)
                        a = qsArr[i].split("=")[1];
            }
            return a;
        }
    },
    fetchEventDetails: function(component,eventcode) {
        var action = component.get("c.getRecords");
        action.setParams({ objName: 'Event_Settings__c',fieldNames:'Id,Exhibitor_Directory_Title__c,Event_Edition__c,Welcome_Text_Exhibitor_Profile__c',compareWith:'Event_Edition__r.Event_Code__c',recordId:eventcode,pageNumber:1,pageSize:1});
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {
                var result =res.getReturnValue().recordList[0];
                component.set("v.eventSettings",result);
            } 
        });
        $A.enqueueAction(action);
    },
    fetchUserDetails: function(component) {
        var action = component.get("c.getCurrentUserDtls");
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {
                var result =res.getReturnValue();
                component.set("v.userDetails",result);
            } 
        });
        $A.enqueueAction(action);
    },
    getUserType : function (component,eventcode) {
        var sEventCode = eventcode;
        var action = component.get("c.getCurrentUserType"); //Calling Apex class controller 'getCurrentUserType' method
        action.setParams({
            eventId: sEventCode
        });
        action.setCallback(this, function (response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.currentUser", result); 
            }
        });
        $A.enqueueAction(action);
        
    }
})