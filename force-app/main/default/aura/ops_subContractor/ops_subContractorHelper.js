// eslint-disable-next-line no-unused-expressions
({
    // eslint-disable-next-line consistent-return
    GetQS: function(url, key) {
        var a = "";
        if(url.includes('#'))
        {
            // eslint-disable-next-line vars-on-top
            var Qs = url.split('#')[1].replace(/^\s+|\s+$/g, '');
            if (Qs !== "") {
                let qsArr = Qs.split("&");
                for (let i = 0; i < qsArr.length; i++)
                    if (qsArr[i].split("=")[0] === key)
                        a = qsArr[i].split("=")[1];
            }
            return a;
        }
        window.location.href='/lightning/n/ops_customer_centre';
    },
    fetchPicklist: function(component,eId) {
        var action = component.get("c.getRecords");
        action.setParams({ objName: 'Event_Edition__c',fieldNames:'Id,Name',compareWith:'Id',recordId:eId,pageNumber:1,pageSize:1});
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {
                // eslint-disable-next-line vars-on-top
                var result =res.getReturnValue().recordList[0];
                component.set("v.eventName",result.Name);
            } 
        });
        // eslint-disable-next-line no-undef
        $A.enqueueAction(action);
    }
})