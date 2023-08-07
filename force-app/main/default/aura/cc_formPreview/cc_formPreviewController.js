({
    doInit: function(component, event, helper) {
      
        var sPageURL = decodeURIComponent(window.location.search.substring(1)); //You get the whole decoded URL of the page.
        var sURLVariables = sPageURL.split('&'); //Split by & so that you get the key value pairs separately in a list
        var sParameterName;
        var i;
        var eventcode;
        var id ;
        var userid;
        var accountId;

        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('='); //to split the key from the value.
            if (sParameterName[0] === 'eventcode') {
                 sParameterName[1] === undefined ? 'Not found' : sParameterName[1];
                eventcode = sParameterName[1];
                component.set('v.eventEditionCode',eventcode);
            }
            if (sParameterName[0] === 'Id') {
                sParameterName[1] === undefined ? 'Not found' : sParameterName[1];
                id = sParameterName[1];
                component.set('v.QnaireId',id);
                component.set('v.recordId',id);
        	}
             if (sParameterName[0] === 'accId') {
                sParameterName[1] === undefined ? 'Not found' : sParameterName[1];
                accountId = sParameterName[1];
                component.set('v.AccId',accountId); // Get Account id from url parameter [STL-276]
        	}
        }

        userid = $A.get("$SObjectType.CurrentUser.Id");

        var result;
        var data;
        // fetch account id 
        var action1 = component.get('c.getRecords'); 
        action1.setParams({
            objName :'User',
            fieldNames :'Id,AccountId',
            compareWith:'Id',
            recordId:userid,
            pageNumber:1,
            pageSize:1

        });
        action1.setCallback(this, function(a){
            var state = a.getState(); // get the response state
            var containsAccountId = component.get('v.AccId');
            if(state == 'SUCCESS') {
                result = a.getReturnValue();
                data=result.recordList[0];
                if(!containsAccountId)
                {
                    component.set('v.AccId',data.AccountId);
                }
            }
        });

        // fetch event edition id
        var action2 = component.get('c.getRecords'); 
        action2.setParams({
            objName :'Event_Edition__c',
            fieldNames :'Id,Event_Code__c',
            compareWith:'Event_Code__c',
            recordId:eventcode,
            pageNumber:1,
            pageSize:1

        });
        action2.setCallback(this, function(a){
            var state = a.getState(); // get the response state
            if(state == 'SUCCESS') {
                console.log('return value',a.getReturnValue());
                result = a.getReturnValue();
                data=result.recordList[0];
               component.set('v.eventEditionId',data.Id);
                component.set('v.callChild',true);
            }
        });
        $A.enqueueAction(action1);
        $A.enqueueAction(action2);
    }
})