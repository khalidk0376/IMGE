({
	doInit : function(component, event, helper) {		
		component.set("v.changeRequestObj",{
            Account__c:component.get("v.oppObj.AccountId"),
            Opportunity__c:component.get("v.oppObj.Id"),
            Event_Edition__c:component.get("v.oppObj.EventEdition__c")
        });
	},
    showRequiredFields: function(component, event, helper){
        $A.util.removeClass(component.find("Type_of_Change"), "none");
        $A.util.removeClass(component.find("Booth_Number"), "none");
        $A.util.removeClass(component.find("Original_Sponsorship_Type"), "none");
        $A.util.removeClass(component.find("Current_Digital_Product"), "none");
        $A.util.removeClass(component.find("Current_Publishing_Product"), "none");        
    },
    handleTypeChange : function(component, event, helper) {        
        component.set("v.selectedType",event.getSource().get("v.value"));
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
        if(helper.validate(component)){
            component.set("v.spinner",true);
            component.find('Change_Request_Form').submit(fields);    
        }
    },
    handleSuccess: function(component, event,helper) {    	
        var payload = event.getParams().response;
        component.set("v.spinner",false);
        window._LtngUtility.toast('Success','success','Change request has been been submitted');
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          "recordId": payload.id,
          "slideDevName": "detail"
        });
        navEvt.fire();
    }
})