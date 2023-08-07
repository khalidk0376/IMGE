({
	helperOnloadData : function(component) {
		var sEventCode = component.get("v.eventcode");
        var customName = component.get("v.customPageName");

        if(customName =='custompage1'){
            customName = 'Custom Page 1';
        }
        if(customName =='custompage2'){
            customName = 'Custom Page 2';
        }
        if(customName =='custompage3'){
            customName = 'Custom Page 3';
        }
        
        var action = component.get("c.getCustomSettings"); //Calling Apex class controller 'EventDetailMethod' method
        action.setParams({
            sEventcode : sEventCode,
            customName : customName
        });
        action.setCallback(this, function(response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS")
            {
                component.set("v.Custom_Setting", response.getReturnValue());// Adding values in Aura attribute variable.
            }
            
        });
        $A.enqueueAction(action);
	},
	fetchEventDetails : function(component, event, helper) {
        var sEventCode = component.get("v.eventcode");
        
       
        var action = component.get("c.getEventDetails"); //Calling Apex class controller 'EventDetailMethod' method
        action.setParams({
            sEventcode : sEventCode
        });
        action.setCallback(this, function(response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS")
            {
                component.set("v.Event_Setting", response.getReturnValue());// Adding values in Aura attribute variable.

                var data  =  response.getReturnValue()
                var currentPage = component.get('v.customPageName');
               
                // change page title dynamically 
                if(currentPage=='custompage1'){
                    document.title =data.Custom_1_Title__c;
                }
                else if(currentPage=='custompage2'){
                    document.title =data.Custom_2_Title__c;
                }
                else if(currentPage=='custompage3'){
                    document.title =data.Custom_3_Title__c;
                }
                else{
                    document.title ='Custom Pages ';
                }
            }
        });
        $A.enqueueAction(action);
    },
    GetQS : function(component, url, key) {
        var Qs = url.split('?')[1].replace(/^\s+|\s+$/g, '');
        var a = "";
        if (Qs !== "") {
            let qsArr = Qs.split("&");
            for (let i = 0; i < qsArr.length; i++)
                if (qsArr[i].split("=")[0] === key)
                    a = qsArr[i].split("=")[1];
        }
        return a;
    }
})