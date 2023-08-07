({
    getMatchMakingDetails: function(component, event, helper) 
    {
       	var eventId = component.get('v.eventId');
        var exhAccountID = component.get('v.exhAccountID');  
        // console.log('eventId'+eventId);
        // console.log('exhAccountID'+exhAccountID);
        // console.log('eventCode' +component.get('v.eventCode'));
        var action = component.get("c.med2MedDetails");
         action.setParams({
             eventId:eventId,
             accountId:exhAccountID
         });
            action.setCallback(this, function(res){
              console.log(action);
              var state = res.getState();
              //console.log('state',state);
              if (component.isValid() && state === "SUCCESS") { 
                  var MtchMakng =res.getReturnValue();
                  //console.log('test'+JSON.stringify(MtchMakng));
                  if(MtchMakng[0]){
                    component.set('v.supplyDist',MtchMakng[0].Are_you_a_manufacturer_supplying_to_Dist__c);
                    component.set('v.supplyngEndUser',MtchMakng[0].Are_you_a_manufacturer_supplying_to_End__c);
                    component.set('v.Distributor',MtchMakng[0].Are_you_a_distributor__c);
                  }
              }
              else
              {
					console.log('no records entered');          
              }
              
          });
         $A.enqueueAction(action);
    },
    saveMatchMakingDetails : function(component, event, helper)  {
        var eventId = component.get('v.eventId');
        var exhAccountID = component.get('v.exhAccountID');
        var action = component.get("c.MatchMaking"); // Calling Apex class controller 'MatchMakingCtrl' method
        var today = new Date();
        //console.log('today'+today);
        action.setParams({
            supplyDist:component.get('v.supplyDist'),
            supplyngEndUser:component.get('v.supplyngEndUser'),
            Distributor:component.get('v.Distributor'),
            AccountID:exhAccountID,
            eventId: eventId,
            lastModifiedDate:today
        });
        action.setCallback(this, function (response) {
            var state = response.getState(); //Checking response status
            //console.log('state',state);
            if (component.isValid() && state === "SUCCESS") {
                this.showNewToast(component,'SUCCESS : ','success','Your answer has been submitted.');
                var vActive = response.getReturnValue();
               console.log('testResult'+JSON.stringify(vActive));
               component.set('v.supplyDist',vActive[0].Are_you_a_manufacturer_supplying_to_Dist__c);
               component.set('v.supplyngEndUser',vActive[0].Are_you_a_manufacturer_supplying_to_End__c);
               component.set('v.Distributor',vActive[0].Are_you_a_distributor__c);
            }
            else
            {
                this.showNewToast(component,'ERROR : ','error','Your answer has not been submitted.');                  
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
     }
})