({
    GetQS: function(url, key) {
        var a = "";
        if(url.includes('#'))
        {
            var Qs = url.split('#')[1].replace(/^\s+|\s+$/g, '');
            if (Qs !== "") {
                let qsArr = Qs.split("&");
                for (let i = 0; i < qsArr.length; i++)
                    if (qsArr[i].split("=")[0] === key)
                        a = qsArr[i].split("=")[1];
            }
            return a;
        }
    },
    fetchPicklist: function(component,eId) {
        var action = component.get("c.getRecords");
        action.setParams({ objName: 'Event_Edition__c',fieldNames:'Id,Name',compareWith:'Id',recordId:eId,pageNumber:1,pageSize:1});
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {
                var result =res.getReturnValue().recordList[0];
                component.set("v.eventName",result.Name);
            } 
        });
        $A.enqueueAction(action);
    },
    getcustomerBadgesChk: function(component,eId) {
        var action = component.get("c.getEventEditionSettings");
        action.setParams({ Id: eId});
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {               
                var result =res.getReturnValue();
                
                var checkBooth =result.Allotment_By_Booth_Size__c;
                var checkMatched =result.Allotment_By_Booth_Type__c;
                if(!checkBooth && !checkMatched){
                }else{
                    if(checkBooth){
                    component.set("v.chkBadgeValueBooth",true);
                    component.set("v.chkFlagBooth",true);
                   component.set("v.chkMatchedDisabled",true);
                }else{
                    component.set("v.chkBoothDisabled",true);
                    component.set("v.chkFlagMatch",true);
            		component.set("v.chkBadgeValueMatched",true);
                }
                }
            } 
        });
        $A.enqueueAction(action);
    }
})