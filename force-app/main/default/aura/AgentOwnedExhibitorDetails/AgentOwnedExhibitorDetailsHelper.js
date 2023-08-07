({
    fetchAccountDetails: function (component) {
        var sAccid = component.get("v.AOEAccountID");
        var action = component.get("c.getAccountDetails"); //Calling Apex class controller 'getAccountDetails' method
        action.setParams({
            sAccID: sAccid
        });
        action.setCallback(this, function (response) 
        {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS") 
            {
                //console.log('accDetails' + JSON.stringify(response.getReturnValue()));
                component.set("v.accDetails", response.getReturnValue());// Adding values in Aura attribute variable.
            } else {
                console.log('state : ' + state);
            }
        });
        $A.enqueueAction(action);
    },
    fetchEventDetails: function (component) 
    {
        var sEventCode = component.get("v.eventcode");
        var action = component.get("c.getEventDetails"); //Calling Apex class controller 'getEventDetails' method
        action.setParams({
            sEventcode: sEventCode
        });
        action.setCallback(this, function (response) {
            var result = response.getReturnValue();
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS") {
                //console.log('fetchEventDetails'+JSON.stringify(response.getReturnValue()));
                component.set("v.eventSetting", result); // Adding values in Aura attribute variable.
                component.set("v.eventId", result.Event_Edition__c);                
            } else {
                console.log('state : ' + state);
            }
        });
        $A.enqueueAction(action);
    },
    fetchReadOrWriteMode: function (component) {
        var sEventCode = component.get("v.eventcode");
        var sAccid = component.get("v.AOEAccountID");
        var action = component.get("c.getExhibitorType"); //Calling Apex class controller 'getEventDetails' method
        action.setParams({
            accId: sAccid,
            sEventCode: sEventCode
        });
        action.setCallback(this, function (response) {
            var result = response.getReturnValue();
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS") {
                let resultArray;                
                if(result)
                {                    
                    resultArray = result.split(',');
                    if(resultArray && resultArray.length>1)
                    {
                        var usrType =resultArray[0];
                        var exhType = resultArray[1];  
                        var parentExhType =resultArray[2];                        
                        if(usrType == 'Co-Exhibitor')
                        {
                            if(parentExhType == 'Exhibitor Paid by Agent'|| parentExhType == 'SubAgent Paid By Subagent')
                            {
                                component.set('v.isReadOnly',false);
                            }
                        }
                        else if(exhType == 'Exhibitor Paid by Agent' || exhType == 'SubAgent Paid By Subagent')
                        {                          
                            component.set('v.isReadOnly',false);
                        }
                    }
                }
            } else {
                console.log('state : ' + state);
            }
        });
        $A.enqueueAction(action);
    },
	goToHome:function(component, event, helper) {
        var url =window.location.href;
        let eventcode = component.get('v.eventcode');
		if(url.includes('/s/')){
			window.location.href='/CustomerCenter/s/?eventcode='+eventcode;
		}
		else{
			window.location.href='home?eventcode='+eventcode;
		}
    },
    goToMyAOE:function(component, event, helper) 
    {
        var url =window.location.href;
        let eventcode = component.get('v.eventcode');
		if(url.includes('/s/')){
			window.location.href='/CustomerCenter/s/agentownexhibitors?eventcode='+eventcode;
		}
		else{
			window.location.href='AgentOwnExhibitors?eventcode='+eventcode;
		}
	},
    getUrlParameter : function (component,parameterName)
    {
        var url=window.location.href;
        console.log('url : '+url);
        var allParams=url.split('?')[1];
        var paramArray = allParams.split('&');
        var val;
        for(var i=0;i<paramArray.length;i++)
        {
        	var curentParam = paramArray[i];
            //console.log('curentParam : '+curentParam);
        	if(curentParam.split('=')[0]== parameterName)
            {
                //console.log('Code ' + curentParam.split('=')[1]);
                val = curentParam.split('=')[1];
        		//component.set("v.accountId",curentParam.split('=')[1]);
        	}
        }
        return val;
    }
})