({
    doInit : function(component, event, helper) {
        
    },
    
    navigate:function(component, event, helper){
        var idx = event.currentTarget.id;
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": idx
        });
        navEvt.fire();    
    },
    
    openModel: function(component, event, helper) {
        // Set isModalOpen attribute to true
        component.set("v.isOpenModal", true);
    },
    
    closeModel: function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.isOpenModal", false);
    },
    submitDetails: function(component, event, helper) {
        var editAction = component.get("c.updateOpp");
        var oppType = component.get("v.oppObj.Type");
        var oppEventEdition = component.get("v.oppObj.EventEdition__c");
        var OppEEReviewBySalesOps = component.get("v.oppObj.Review_by_Sales_Ops_Team__c");
        var closeddate = component.get("v.oppObj.CloseDate");
        // Condition is modified by Palla Kishore for the ticket BK-20449
        if (oppType == null && oppEventEdition != null && OppEEReviewBySalesOps == true && closeddate > '2021-01-01'){
            window._LtngUtility.toast('Error','error','Please update the Opportunity Type field with the correct value.'); 
       }
        else{
            editAction.setParams({
                'oppId':component.get("v.oppObj.Id")
            });
            component.set("v.spinner", true);        
            editAction.setCallback(this,function(data){
                component.set("v.spinner", false);
                var state = data.getState();
                if(state=='SUCCESS'){                
                    window._LtngUtility.toast('Success', 'success', 'Opportunity is recall successfully');
                    $A.get('e.force:refreshView').fire();
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": "/lightning/r/Opportunity/"+component.get("v.oppObj.Id")+'/view?hshd='+new Date()
                    });
                    urlEvent.fire();
                }
                else if(state=="ERROR"){
                    window._LtngUtility.toast('Error','error','Something is wrong ');  
                }
            });
            $A.enqueueAction(editAction);  
        }
         
    }
})