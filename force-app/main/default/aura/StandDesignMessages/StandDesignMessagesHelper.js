({
	fetchStandDesignMessages: function(component, event, helper) {
        var action = component.get("c.getStandDesignMessagesCtr"); //Calling Apex class controller 'getStandDesignMessagesCtr' method
        
        var boothMapId=component.get("v.childsingleBooth[0]"); 
        //console.log('BoothMap ' +boothMapId.Id);
        action.setParams({
			boothMapId: boothMapId.Id	
        });
        action.setCallback(this, function(res) { 
            var state = res.getState();
            //console.log('State ' +state);
            if (state === "SUCCESS") {     
                component.set("v.StandDesignMessages", res.getReturnValue());
                //console.log('StandDesignMessages==='+JSON.stringify(res.getReturnValue())); 
                this.fetchEmailContent(component,res.getReturnValue());
                
            }
        }); 
        $A.enqueueAction(action);
    },
    fetchEmailContent: function(component,returnValue) {
        
        var map = new Map();
        for(var i =0 ;i<returnValue.length;i++ )
        {
            map.set(returnValue[i].Id,returnValue[i]);
        }
        component.set("v.emailContentMap" , map);
    },
    forwardEmailConHelper: function(component, event, helper){
        var stdHistory = component.get("v.emailContent");
        //var objEditor = component.get("v.objEditorMsg");
        // if(stdHistory)
        // {
        //     stdHistory.Content__c = objEditor("editor3","","getData");
        // }
        //console.log('stdHistory '+JSON.stringify(stdHistory));
        var action = component.get("c.forwardEmailToContractor"); //Calling Apex class controller 'forwardEmailToContractor' method.
        action.setParams({
            stdHistory : stdHistory
        });
        action.setCallback(this, function(res) { 
            var state = res.getState();
            //console.log('State ' +state);
            if (state === "SUCCESS") {      
                console.log('Email Sent Successfully ');
            }
            else{
                console.log('Email Not Sent Successfully ');
            }
        }); 
        $A.enqueueAction(action);
    },
    // ReInitialize: function(component) {
    //     var objEditor = component.get("v.objEditorMsg");
    //     //objEditor("","","");
    // },
   
})