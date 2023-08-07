({	
    doInit : function(component, event, helper) {    
        if(component.get("v.UpdateUserTypeAccess.Tab2") || component.get("v.UpdateUserTypeAccess.Tab6"))
        {            
            helper.fetchExpoOppMappingData(component,event, helper);      
        }
        if(component.get("v.UpdateUserTypeAccess.Tab3"))
        {
            helper.fetchExpoCadData(component,event, helper);    
        }
        if(component.get("v.UpdateUserTypeAccess.Tab5"))
        {
            helper.fetchCCMappingData(component,event, helper);      
        }
    },
    
    closeModal : function(component, event, helper) {
        component.set("v.isOpenModal",false);
    },
    
    handleLoad: function(cmp, event, helper) {
        cmp.set('v.showSpinner', false);
    },
    
    handleSubmit: function(cmp, event, helper) {          
        cmp.set('v.showSpinner', true);
    },
    
    handleError: function(cmp, event, helper) {      
        cmp.set('v.showSpinner', false);          
    },
    
    handleSuccess: function(cmp, event, helper) {        
        cmp.set('v.showSpinner', false); 
        window._LtngUtility.toast(
            "Success",
            "success",
            "Records Updated Successfully..."
        );  
        cmp.set("v.showSaveCancelBtnFisrtTab",false);
    },
    
    showHideAgentOppField : function(component, event, helper) {
        component.set('v.showSaveCancelBtnFisrtTab', true);
        var ExhibitorPaidByValue = component.find("ExhibitorPaidBy").get("v.value");
        if((ExhibitorPaidByValue == "Individual Contract") || (ExhibitorPaidByValue == "SubAgent Paid By Exhibitor") || (ExhibitorPaidByValue == "SubAgent Paid By Subagent") )
        {
            component.set("v.showHideAgentoppField", true); 
        }    
        else
        {
            component.set("v.showHideAgentoppField", false);  
        }
    },
    
    SaveExpoCadRecords : function(component, event, helper) {
        component.set('v.showSpinner', true);
        var action = component.get("c.updateExpocadRecords");
        action.setParams({
            'ExpocadRecords': component.get("v.ExpocadRecordsList")
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS" && component.isValid()) {
                component.set("v.ExpocadRecordsList", response.getReturnValue());
                component.set("v.showSaveCancelBtnOnMPNUpdate",false);
                component.set('v.showSpinner', false);  
                window._LtngUtility.toast(
                    "Success",
                    "success",
                    "Records Updated Successfully..."
                );              
            }
        });
        $A.enqueueAction(action);        
    },
    
    SaveExpoMappingRecords : function(component, event, helper) {
        component.set('v.showSpinner', true);
        var UpdatereturnVal = component.get("v.singleOppExpoMapping"); 
        var action = component.get("c.updateOppMappingRecords");
        action.setParams({
            'OppMapping': component.get("v.oppMappingRecordsList")
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS" && component.isValid()) {                   
                component.set("v.oppMappingRecordsList", response.getReturnValue());
                component.set("v.showSaveCancelBtn",false);
                component.set('v.showSpinner', false);           			
                window._LtngUtility.toast(
                    "Success",
                    "success",
                    "Records Updated Successfully..."
                );       
            }    
        });
        $A.enqueueAction(action);        
    },
    
    SaveCCMappingRecords : function(component, event, helper) {
        component.set('v.showSpinner', true);
        
        var action = component.get("c.updateCCMappingRecords");
        action.setParams({
            'CCMapingRecords': component.get("v.CCMappingUpdateRecordsList")
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS" && component.isValid()) {                   
                component.set("v.CCMappingUpdateRecordsList", response.getReturnValue());
                component.set("v.showSaveCancelBtnOnCCMappingUpdate",false);
                component.set('v.showSpinner', false);  
                /*var isOperationProfile = component.get("v.isBAAdminProfile");
                if(isOperationProfile == true) {
                    component.set('v.isOpenModal',false);
                }*/
                window._LtngUtility.toast(
                    "Success",
                    "success",
                    "Records Updated Successfully..."
                );       
            }
        });
        $A.enqueueAction(action);        
    },
    
    updateComment2onExbhitor : function(component, event, helper) {
        component.set('v.showSpinner', true);
        
        var action = component.get("c.AsyncupdateComment2onExbhitor");
        action.setParams({
            'SelectedRelation': component.get("v.ExpocadRelationValue"),
            'oppId' : component.get("v.oppId")
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS" && component.isValid()) {                                       
                component.set('v.showSpinner', false);  
                window._LtngUtility.toast(
                    "Success",
                    "success",
                    "Records Updated Successfully..."
                );       
            }
        });
        $A.enqueueAction(action);        
    },
    
    showPushbutton : function(component, event, helper) {      
        component.set('v.showPushButton', true);
    }    
})