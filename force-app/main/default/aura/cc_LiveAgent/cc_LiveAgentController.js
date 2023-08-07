({
	doInit : function(component, event, helper) {
        console.log('OnLoad!!!');
       
    },
    scriptsLoaded:function(component, event, helper) {
       console.log('Script Load!!!');
        var chtBttonId =$A.get("{!$Label.c.Live_Agent_IDs}");
        var deplymntUrl =$A.get("{!$Label.c.Live_Agent_URLs}");
        var OrgId =$A.get("{!$Label.c.Live_Agent_OrgId}");
        let fullUrl = window.location.href;
        var eId=helper.GetQS(fullUrl,'eventcode');
        console.log('....123'+eId)
        
        var action = component.get("c.agentEventDetails");
        action.setParams({ 
            code:eId
        });
        action.setCallback(this, function(res) {
            var state = res.getState();
            var data = res.getReturnValue();
            console.log('data44',data);
            console.log('state5',state);
            if (state === "SUCCESS") {
                if(data){
                    component.set('v.liveAgentBooleanVal',data);
                    liveagent.init(deplymntUrl.split(',')[1]+'/chat', chtBttonId.split(',')[1], OrgId);
                    if (!window._laq) { window._laq = []; }
                    window._laq.push(function(){
                        liveagent.showWhenOnline(chtBttonId.split(',')[0], document.getElementById('liveagent_button_online_5732J000000L3nq'));
                        // liveagent.showWhenOffline(chtBttonId.split(',')[0], document.getElementById('liveagent_button_offline_5732J000000L3nq'));
                    });
                }
                else{
                    component.set('v.liveAgentBooleanVal',data);
                }
            }
            
        });
        $A.enqueueAction(action);  
     
    }
    /*
    handleLiveAgentButtonClick:function(component, event, helper) {
         var chtBttonId =$A.get("{!$Label.c.Live_Agent_IDs}");
         liveagent.startChat(chtBttonId.split(',')[0])   
    }
    */
})