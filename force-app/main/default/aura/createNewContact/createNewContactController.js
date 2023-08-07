({    
	doInit : function(component, event, helper) {
        helper.fetchDependentPicklistValues(component);
	},
    handleAccountChange:function(component, event, helper) {
        let accId = component.find("fAcc").get("v.value");
        if(!$A.util.isEmpty(accId)){
         	helper.getAccountDetail(component,accId.toString());     
        }
        else{
            component.set("v.showFields",false);
        }
    },
    handleSubmit : function(component, event, helper) {
        event.preventDefault();       // stop the form from submitting       
        if(helper.validateFields(component)){
            var fields = event.getParam('fields');
            let conObj = component.get("v.contactObj")
            fields.MobilePhone = component.find("MobilePhone").get("v.value");
            fields.Phone = component.find("Phone").get("v.value");
            fields.FirstName = conObj.FirstName;
            fields.Email = conObj.Email;
            fields.Titile= conObj.Title;

            helper.fields = fields;
            component.find('contactRecordForm').submit(fields);
            component.set("v.spinner",true);
           /* component.set("v.showModal",true);
            if(helper.validateOtherFields(fields)){
                //component.find('contactRecordForm').submit(fields);
                component.set("v.spinner",true);
                component.set("v.showModal",true);
            }
            else{
                component.set("v.spinner",false);
            }*/
        }
	},
   /* saveModalData:function(component, event, helper){        
        event.preventDefault();        
        var conObj = component.get("v.contactObj");
        var fields = event.getParam('fields');
        if(fields.MailingStreet)
        {
            helper.fields.MailingStreet = fields.MailingStreet;
            helper.fields.MailingCity = fields.MailingCity;
            helper.fields.MailingPostalCode = fields.MailingPostalCode;
            helper.fields.MailingCountryCode = component.find("billingCountry").get("v.value");
            helper.fields.MailingStateCode = component.find("billingState").get("v.value");
        }
        else
        {
            helper.fields.MailingStreet = conObj.MailingStreet;
            helper.fields.MailingCity = conObj.MailingCity;
            helper.fields.MailingPostalCode = conObj.MailingPostalCode;
            helper.fields.MailingCountryCode = conObj.MailingCountryCode;
            helper.fields.MailingStateCode = conObj.MailingStateCode;
        }
        component.set("v.spinner",true);
        console.error(JSON.stringify(helper.fields));
        component.find('contactRecordForm').submit(helper.fields);
    },
    closeModal:function(component, event, helper){
        component.set("v.showModal",false);
    },*/
    
    handleError : function(component, event, helper) {      
        var strError = event.getParams().error;
        console.error(strError);
        window._LtngUtility.handleError(strError);
        component.set("v.spinner",false);                
         
	},
    handleSuccess : function(component, event, helper) {
        window._LtngUtility.toast('Success', 'success', 'Record was created!');
        var record = event.getParams();
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/lightning/r/Contact/"+record.response.id+"/view"
        });
        urlEvent.fire();
	},
    handleCancel : function(component, event, helper) {
    },
    onload : function(component, event, helper) {
		component.set("v.spinner",false);
    },
    onBillingCountryChange: function(component, event, helper) {
        var val = event.getSource().get("v.value"); // get selected controller field value
        var lab = '';
        for(var i=0;i<event.getSource().get("v.options").length;i++){
            if(event.getSource().get("v.options")[i].value==val){
                lab = event.getSource().get("v.options")[i].label;
            }
        }
        var controllerValueKey = lab+'__$__'+val;
        helper.onControllerFieldChange(component,val);	
    },
})