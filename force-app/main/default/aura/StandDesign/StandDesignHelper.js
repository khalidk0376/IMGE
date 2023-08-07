({
    getStandDesign: function(component, event, helper) {
        var action = component.get("c.getStandDesignCtr"); //Calling Apex class controller 'getStandDesignCtr' method
        var AccId1=component.get("v.AccountId");
        var BthID1=component.get("v.BoothID");
        action.setParams({
            AccId: AccId1,
            BthID:BthID1
        });
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") { 
                var StndDsign=res.getReturnValue();
                component.set("v.StandDesign",StndDsign);
                //console.log(JSON.stringify(res.getReturnValue()));
            }
        });
        $A.enqueueAction(action);
    },
    getStandDesignClone: function(component, event, helper) {
        //debugger;
        var AccId1=component.get("v.AccountId");
        var BthID1=component.get("v.BoothID");
        if(AccId1){
            var action = component.get("c.getStandDesignCtr"); //Calling Apex class controller 'getStandDesignCtr' method
            
            //console.log('AccId1++++++++++++++++++++++++++++++++++++'+AccId1);
            //console.log('BthID1++++++++++++++++++++++++++++++++++++'+BthID1);
            action.setParams({
                AccId: AccId1,
                BthID:BthID1
            });
            action.setCallback(this, function(res) {
                var state = res.getState();
                if (state === "SUCCESS") {                
                var data=res.getReturnValue();
                    component.set("v.StandDesign",data);
                    //console.log(JSON.stringify(res.getReturnValue()));
                }
            });
            $A.enqueueAction(action);
        }
        
    },
    getBaseUrl : function (component, event, helper) {
        //debugger;
        var action = component.get('c.getBaseUrl')
        action.setCallback(this, function (response) {
            var state = response.getState()
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue()
                component.set('v.sfdcBaseurl', result)
            }
        })
        $A.enqueueAction(action)
    },
    
    downloadfile : function (component, event, helper){   
        var attachmentId = event.target.getAttribute("data-id");
        var sfdcBaseUrl  = component.get('v.sfdcBaseurl');
        var downloadUrl =  sfdcBaseUrl + '/servlet/servlet.FileDownload?file='+ attachmentId; 
       /* var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": downloadUrl
            });
            urlEvent.fire();*/
        //window.location.href = downloadUrl; to open the link in the same tab
        window.open(downloadUrl,'_blank');//to open the link in new tab
    },
    SubmitDesign : function (component, event, helper) {
        //debugger;
        var action = component.get('c.SubmitDesignCtr') ////Calling Apex class controller 'SubmitDesignCtr' method
        var target = event.getSource();
        var AccId1 = target.get("v.value");
        //console.log('AccId1+++++++++++++++++'+AccId1);
        action.setParams({
            AccId: AccId1
        });
        /*action.setCallback(this, function (res) {
            var state = res.getState()
            if (component.isValid() && state === 'SUCCESS') {
                var result = res.getReturnValue()
                component.set('v.sfdcBaseurl', result)
            }
        })*/
        $A.enqueueAction(action)
    },
    ReInitialize: function(component, event, helper) {
        component.set("v.AccountId",'');
        component.set("v.StandDesign",'');
        component.set("v.BoothID",'');
    }
})