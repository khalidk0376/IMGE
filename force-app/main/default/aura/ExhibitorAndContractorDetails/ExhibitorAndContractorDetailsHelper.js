({
    FindSubcontractorsAndStandDetails : function(component, event, helper) {
    var action = component.get("c.findSubcontractors");	//Calling Apex class controller 'FindSubcontractors' method
    var BoothMapId=component.get("v.ChildBoothMapID");
    var AccId=component.get("v.childsingleBooth[0].Contact__r.AccountId"); 
    var BoothId=component.get("v.childsingleBooth[0].Opp_Booth_Mapping__c");
    action.setParams({
        mapId:BoothMapId,
        accId:AccId,
        boothId:BoothId
    });
    action.setCallback(this, function(res) {
        var state = res.getState();
        if (state === "SUCCESS") {               
        var data=res.getReturnValue();
            //console.log('#############'+JSON.stringify(data.lstBoothMapList));
            component.set("v.SubConList", data.lstBoothMapList);
        }
    });
    $A.enqueueAction(action);
    },
    getStandDetails: function(component) {
        //debugger;
        var AccId1=component.get("v.childsingleBooth[0].Contact__r.AccountId");
        var BthID1=component.get("v.childsingleBooth[0].Opp_Booth_Mapping__c");
        var boothContMapping=component.get("v.childsingleBooth[0]");
        var agntID; 
        if(boothContMapping.Agent_Contact__c)
        {
            agntID = boothContMapping.Agent_Contact__r.AccountId;  
        }
        //console.log(AccId1 +' ================= '+BthID1);
        if(AccId1){
            //console.log('26756729364572463796478451674728638');
            var action = component.get("c.getStandDetailsCtr"); //Calling Apex class controller 'getStandDetailsCtr' method
            action.setParams({
                sAccId: AccId1,
                sBthID:BthID1,
                sEventId:boothContMapping.Event_Edition__c,
                agentId:agntID
            });
            action.setCallback(this, function(res)
            {                
                var state = res.getState();
                //console.log('state = == '+state);
                if (state === "SUCCESS") {                
                    var data=res.getReturnValue();  
                    //console.log('#######################################################'+data[0].Stand_Height__c);                
                    component.set("v.StndDetails",data);
                }
            });
            $A.enqueueAction(action);
        } 
    },
    getLoginCtrDetails: function(component,event,BoothContactMappngId)
    {
        console.log('BoothContactMappngId'+BoothContactMappngId);
       	var AccId=component.get("v.childsingleBooth[0].Contact__r.AccountId"); 
         console.log('AccId'+AccId);
         var boothContMapping=component.get("v.childsingleBooth[0]");
         var action = component.get("c.getloginDetail");
        console.log('action'+action);
         action.setParams({
                eventId: boothContMapping.Event_Edition__c,
                accountId:AccId,
                boothContactMappngId:BoothContactMappngId,
            });	
        action.setCallback(this, function(res)
        {
            console.log('test');
          var state = res.getState();
          console.log('state'+state);
          if(state==="SUCCESS")
          {
            var data=res.getReturnValue();  
            console.log('#######################################################'+JSON.stringify(data)); 
              if(data)
              {
                  var networkID = data.sNetworkid;
                  var orgID = data.sOrgId;
                  var baseurl = data.baseUrl;
                  var UserId= data.userInfo.Id;
                  var redirectLink =  '/servlet/servlet.su?oid='+orgID+'&retURL= '+'&sunetworkid='+networkID+'&sunetworkuserid='+UserId;
                  var url = baseurl+redirectLink; 
                  console.log('url ===== '+url);
                  window.open(url,"_blank");
              }
          }
        });
         $A.enqueueAction(action);
    },
    sendEmail : function(component, event, ContId)
    {
        console.log(ContId);
		var boothContMapping=component.get("v.childsingleBooth[0]");
        var action = component.get("c.sendEmails");
        action.setParams({
            	sContactId:ContId,		
                sEventId: boothContMapping.Event_Edition__c
            });	
        action.setCallback(this, function(res)
        {
            //console.log('test');
            var state = res.getState();
            console.log('state'+state);
            if(state==="SUCCESS"){
              this.showNewToast(component,'Success','Success','Mail has been Sent Succesfully');
            }
            else{
              this.showNewToast(component,'Error','Error',' Mail has not been Sent');
            }
        });
         $A.enqueueAction(action);        
    },
    resetPassword: function(component, event, sContId)
    {
        //console.log(sContId);
        var action = component.get("c.resetPasswords");
        action.setParams({
            	sContactId:sContId,		
            });	
        action.setCallback(this, function(res)
        {
            console.log('test');
            var state = res.getState();
            console.log('state'+state);
            if(state==="SUCCESS"){
                 this.showNewToast(component,'Success','Success','Password Sent Succesfully');
            }
            else{
                this.showNewToast(component,'Error','Error',' Password has not been Sent');
            }
        });
         $A.enqueueAction(action);
    },
     showNewToast: function(component,title,type, message) {
		var toastEvent = $A.get("e.force:showToast");
        if(toastEvent!=undefined){
            toastEvent.setParams({
                title: title,
                message: message,
                duration: '5000',
                type: type,
                mode: 'dismissible'
            });
            toastEvent.fire();
        }
        else{
            component.set("v.msgbody",message);
            component.set("v.msgtype",type);
            window.setTimeout($A.getCallback(function() {
                component.set("v.msgbody",'');
                component.set("v.msgtype",'');
            }), 5000);
        }
     },
     copyTextHelper : function(component,event,text) {
        // Create an hidden input
        var hiddenInput = document.createElement("input");
        // passed text into the input
        hiddenInput.setAttribute("value", text);
        // Append the hiddenInput input to the body
        document.body.appendChild(hiddenInput);
        // select the content
        hiddenInput.select();
        // Execute the copy command
        document.execCommand("copy");
        // Remove the input from the body after copy text
        document.body.removeChild(hiddenInput); 
        // store target button label value
        var orignalLabel = event.getSource().get("v.label");
        // change button icon after copy text
        event.getSource().set("v.iconName" , 'utility:check');
        // change button label with 'copied' after copy text 
        event.getSource().set("v.label" , 'copied');
        
        // set timeout to reset icon and label value after 700 milliseconds 
        setTimeout(function(){ 
            event.getSource().set("v.iconName" , 'utility:copy_to_clipboard'); 
            event.getSource().set("v.label" , orignalLabel);
        }, 700);
        
    }
})