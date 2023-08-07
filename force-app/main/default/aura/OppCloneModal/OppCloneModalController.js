({
	doInit : function(component, event, helper) {	
        component.set("v.oppObj.Revenue_Estimate__c" , null );
        //helper.getQuoteDetail(component);	
        helper.getRecordType(component);	  /* added Method for pass Record Type on BK-4875 on RajesH kumar - 01-06-2020 */
        /*Added By Rajesh Kumar - BK-8275*/
        var val = component.get("v.oppObj.CurrencyIsoCode"); 
        component.set( "v.defaultCurrency",val);

	},
	closeModal : function(component, event, helper) {
		component.set("v.isOpenModal",false);
	},
    handleError:function(component, event, helper) {
        component.set("v.spinner",false);
    },
	handleSubmit: function(component, event, helper) {
        
        event.preventDefault();       // stop the form from submitting
        var fields = event.getParam('fields');        
        if(!$A.util.isEmpty(component.get("v.oppObj.Opportunity_Contact__c"))){
            fields.Opportunity_Contact__c = component.get("v.oppObj.Opportunity_Contact__c");
        }
        if(!$A.util.isEmpty(component.get("v.oppObj.Billing_Contact__c"))){
            fields.Billing_Contact__c     = component.get("v.oppObj.Billing_Contact__c");    
        }
        if (!$A.util.isEmpty(component.get("v.oppObj.Event_Edition_Currency__c"))) {
            fields.Event_Edition_Currency__c = component.get("v.oppObj.Event_Edition_Currency__c");
        }
        else {
            fields.CurrencyIsoCode = component.get("v.defaultCurrency");
        }
        if (!$A.util.isEmpty(component.get("v.oppObj.Id"))) {
            fields.Cloned_From_Opportunity__c = component.get("v.oppObj.Id");
        }
        component.set("v.spinner",true);
        component.find('editForm2').submit(fields);
    },
    
    handleSuccess: function(component, event,helper) {    	
        var payload = event.getParams().response;
        helper.oppCloneRelated(component,payload.id);
    },
    
    handleEventChange : function(component, event, helper) {       
        var val = event.getSource().get("v.value").join(",");        
        if (!$A.util.isEmpty(val)) {                       
            helper.getDefaultEventCurrency(component,val);
            $A.util.removeClass(component.find("EventEdition"), "slds-has-error");
            $A.util.removeClass(component.find("Event_Edition_Currency"), 'slds-hide');
        } 
        else {
            $A.util.addClass(component.find("Event_Edition_Currency"), 'slds-hide');
        }
    }   
  
})