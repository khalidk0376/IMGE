({
	getOppDetail : function(component) {		
		let param = JSON.stringify({oppId: component.get("v.recordId"),recordId: component.get("v.recordId")});
		var action = component.get("c.invoke");
        var objValue = component.get("v.oppObj");
        action.setParams({action:'get_opportunity',parameters:param});
        action.setCallback(this, function(res) {            
            var state = res.getState();
            if (state === "SUCCESS"){                
                component.set("v.oppObj",res.getReturnValue().opp_obj);
                //alert(res.getReturnValue().is_allow);
                component.set("v.isEnableProfile",res.getReturnValue().is_allow);
                component.set("v.isOppLineItem",res.getReturnValue().lstOpportunityLineItem);
                component.set("v.isCheckProfile",res.getReturnValue().isCheckProfile);
                component.set("v.sscbrasil", res.getReturnValue().sscbrasil);
                var inactVal = res.getReturnValue().inactive__c;
                component.set("v.inActive",res.getReturnValue().inactive__c);
              //  component.set("v.accId",res.getReturnValue().accId);
             //   console.log("accId" + res.getReturnValue().accId);
                let obj = component.get("v.oppObj");
                if(obj.EventEdition__r != null){
                	component.set("v.renderButton",obj.EventEdition__r.Enabled_for_IOM_Billing__c);
                }
                if(obj.IOM_Sync_Status__c=='Complete'){
                   component.set("v.renderCancelButton",true);  
                }
               
                
               // let renderButtonc = component.get("v.renderButton");
               // alert("renderButtonc==>" + renderButtonc);
                
                if(res.getReturnValue().access!=undefined && res.getReturnValue().access.length>0){
                    component.set("v.accessObj",res.getReturnValue().access[0]);    
                }
                this.getAmendTeamMember(component);
            } 
            else {
                window._LtngUtility.handleErrors(res.getError());
            }
            
        });
        $A.enqueueAction(action);
	},

    getUserTypeButtonAccess : function(component)
    {      
       var action = component.get("c.getUserTypeButtonAccess");
        
        action.setCallback(this, function(res) {            
            var state = res.getState();                        
            if (state === "SUCCESS"){
                component.set("v.UpdateUserTypeAccess" , res.getReturnValue());
            } 
            else {
                window._LtngUtility.handleErrors(res.getError());
            }
        });
        $A.enqueueAction(action);
    },
    /* BK-4175 - Modified By Rajesh Kr on 26-05-2020 */
    closeWonToZeroAmountHelper : function(component) {
        component.set("v.spinner",true);
        var obj = component.get("v.oppObj");
        // Modified By Palla Kishore for the ticket BK-27444
        var param = JSON.stringify({opp_obj: {sobjectType:'Opportunity',Id:obj.Id,Status__c:'Awaiting Payment',StageName:'Closed Won',Do_not_activate_Billing__c:true, Forecast_Category__c:'Closed Won'}});
        var action = component.get("c.invokeInsertOrUpdate");
        action.setParams({action:'set_opp',parameters:param});
        action.setCallback(this, function(res) {            
            var state = res.getState();
            component.set("v.spinner",false);            
            if (state === "SUCCESS"){
                obj.StageName='Closed Won';
                component.set("v.oppObj",obj);
                window._LtngUtility.toast('Success','success','Updated');
                $A.get('e.force:refreshView').fire();
            } 
            else {
                window._LtngUtility.handleErrors(res.getError());
            }
        });
        $A.enqueueAction(action);
    },
    cancelOpps : function(component) {
        component.set("v.spinner",true);
        var obj = component.get("v.oppObj");
        var param = JSON.stringify({opp_obj: {sobjectType:'Opportunity',Id:obj.Id,Reason_Lost__c:'AR Cancel / Re-bill',StageName:'Closed Lost'}});
        var action = component.get("c.invokeInsertOrUpdate");
        action.setParams({action:'set_opp',parameters:param});
        action.setCallback(this, function(res) {            
            component.set("v.spinner",false);
            var state = res.getState();
            component.set("v.isResubmitForAccApprovalModal",false);            
            if (state === "SUCCESS"){
                obj.StageName='Closed Won';
                obj.Status__c='Pending Accounting Approval';
                component.set("v.oppObj",obj);
                window._LtngUtility.toast('Success','success','Updated');
            } 
            else {
                window._LtngUtility.handleErrors(res.getError());
            }
        });
        $A.enqueueAction(action);
    },
    
    reSubmitHelper : function(component) {
        component.set("v.spinner",true);
        var obj = component.get("v.oppObj");
        var param = JSON.stringify({opp_obj: {sobjectType:'Opportunity',Id:obj.Id,Status__c:'Pending Accounting Approval',StageName:'Closed Won'}});
        var action = component.get("c.invokeInsertOrUpdate");
        action.setParams({action:'Resubmit_Approval',parameters:param});
        action.setCallback(this, function(res) {            
            component.set("v.spinner",false);
            var state = res.getState();
            component.set("v.isResubmitForAccApprovalModal",false);            
            if (state === "SUCCESS"){
                obj.StageName='Closed Won';
                obj.Status__c='Pending Accounting Approval';               
                component.set("v.oppObj",obj);
                window._LtngUtility.toast('Success','success','Updated');
            } 
            else {
                window._LtngUtility.handleErrors(res.getError());
            }
        });
        $A.enqueueAction(action);
    },
    /** Palla Kishore - 22-10-2021 : EMEA-24 --> */
    reSubmitToSalesOppHelper : function(component) {
        component.set("v.spinner",true);
        var obj = component.get("v.oppObj");
        var param = JSON.stringify({opp_obj: {sobjectType:'Opportunity',Id:obj.Id,Status__c:'Sales Ops Review - Pending',StageName:'Closed Won'}});
        var action = component.get("c.invokeInsertOrUpdate");
        action.setParams({action:'Resubmit_Approval',parameters:param});
        action.setCallback(this, function(res) {            
            var state = res.getState();
            component.set("v.spinner",false);            
            if (state === "SUCCESS"){              
             //   obj.StageName='Closed Won';
             //   obj.Status__c='Sales Ops Review - Pending';               
             //   component.set("v.oppObj",obj);
                window._LtngUtility.toast('Success','success','Updated');
                 $A.get('e.force:refreshView').fire();
            } 
            else {
                window._LtngUtility.handleErrors(res.getError());
            }
        });
        $A.enqueueAction(action);
    },

    getAmendTeamMember : function(component) {        
        let param = JSON.stringify({recordId: component.get("v.oppObj.Event_Series__c")});
        var action = component.get("c.invoke");
        action.setParams({action:'get_amend_team_member',parameters:param});
        action.setCallback(this, function(res) {            
            var state = res.getState();
            if (state === "SUCCESS"){                   
                if(res.getReturnValue().length>0){
                    component.set("v.isAmendTeamMember",true);
                }
                else{
                    component.set("v.isAmendTeamMember",false);   
                }
            } 
            else {
                window._LtngUtility.handleErrors(res.getError());
            }
        });
        $A.enqueueAction(action);
    },
    
})