({
    doInit : function(component, event, helper) {       
        component.set("v.contactObj",{});         
        //component.set("v.isOpenInOtherReasonPopUp", component.find("inactiveId").get("v.value")); 
        //component.set("v.inactiveReasonvalue", component.find("inactivereasonId").get("v.value"));       
        
        helper.getContactDetail(component);
        var getSelected = localStorage.getItem('selectedAccordiansCon');
        if (getSelected) 
        { 
            component.set("v.activeSections",JSON.parse(getSelected));
        }
         helper.getRecordType(component);
         helper.getGoogleApiMapping(component);
    },
    handleSectionToggle: function(component, event) {
        localStorage.setItem('selectedAccordiansCon',JSON.stringify(component.find("accordionCon").get('v.activeSectionName')));
    },
    handleSubmit: function(component, event, helper) {
        event.preventDefault(); // stop the form from submitting
        if (helper.validate(component)) {
            var fields = event.getParam('fields');
            fields.MailingStreet = component.get("v.searchKey");
            fields.MailingCity = component.get("v.contactObj.MailingCity");
            //console.log('Contact Address: '+JSON.stringify(component.get("v.contactObj")));
            fields.MailingCountryCode = component.get("v.contactObj.MailingCountryCode");
            
            if(component.get("v.contactObj.MailingCountryCode")!=undefined && component.get("v.contactObj.MailingCountryCode")!='NG'){
                fields.MailingStateCode = component.get("v.contactObj.MailingStateCode");                
            }
            if(component.find("inactiveId").get("v.value")){
                fields.Inactive__c = component.find("inactiveId").get("v.value");
                fields.Inactive_Reason__c = component.find("inactivereasonId")!=undefined?component.find("inactivereasonId").get("v.value"):null;
                //   fields.Inactive_Additional_Reason__c = component.get("v.contactObj.Inactive_Additional_Reason__c");
            }
            fields.MailingPostalCode = component.get("v.contactObj.MailingPostalCode");
            component.find('editFormContact').submit(fields);
            component.set("v.spinner", true);
        }
        else{
            window._LtngUtility.toast('Error','error','Fill all required fields'); 
        }
    },
    handleError: function(component, event) {
        window._LtngUtility.handleError(event.getParams().error);
        component.set("v.spinner",false);
    },
    handleLoad: function(component, event, helper) {
        component.set("v.spinner",false);
        //component.find("name-input").focus();
    },
    handleSuccess: function (component, event,helper) { 
        component.set('v.spinner', false); 
        window._LtngUtility.toast('Success','success','Contact details has been updated'); 
        component.set("v.isEditForm",false);
    },
    handleCancel: function (component, event,helper) { 
        component.set("v.isEditForm",false);
        event.preventDefault();
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
    // Google Address Auto complete Start
    handleBlur:function(component,event,helper){        
        window.setTimeout(
            $A.getCallback(function() {
                var conObj = component.get("v.contactObj");
                // console.log('Contact Address: '+JSON.stringify(conObj));
                if(conObj){
                    conObj.MailingStreet = component.get("v.searchKey");
                }                
                component.set("v.contactObj",conObj);
                var searchLookup = component.find("searchLookup");        
                $A.util.removeClass(searchLookup, 'slds-is-open');
                $A.util.addClass(searchLookup, 'slds-combobox-lookup');        
            }), 500
        );
    },
    handleSelect:function(component,event,helper){        
        //console.log(event.currentTarget.getAttribute("data-placeid"));
        component.set("v.searchKey",event.currentTarget.getAttribute("data-record"));
        component.set("v.contactObj.MailingStreet",event.currentTarget.getAttribute("data-record"));
        var searchLookup = component.find("searchLookup");        
        $A.util.removeClass(searchLookup, 'slds-is-open');
        $A.util.addClass(searchLookup, 'slds-combobox-lookup');        
        helper.displayOptionDetails(component,event,event.currentTarget.getAttribute("data-placeid"));
    },
    keyPressController: function (component, event, helper) {
        event.getSource().set("v.validity",{valid:true, badInput :false});
        event.getSource().showHelpMessageIfInvalid();
        var prpActVal2 = event.getSource().get("v.value");        
        var searchKey = component.get("v.searchKey");
        if(searchKey && searchKey.length>1){
            helper.openListbox(component, searchKey);
            helper.displayOptionsLocation(component, searchKey);
        }
        else if(searchKey && searchKey.length==0){
            component.set("v.contactObj.MailingStateCode", "");
            component.set("v.contactObj.MailingCity", "");
            component.set("v.contactObj.MailingPostalCode", "");
            component.set("v.contactObj.MailingCountryCode", "");
        }
        
    },
    // Google Address Auto complete End
    // BK-2008 - Added by Himanshu 
    onInactiveCheckboxChange : function(component, event, helper) {          
        component.set("v.isOpenInOtherReasonPopUp", component.find("inactiveId").get("v.value"));        
    },
    
    onInactiveReasonchange: function(component, event, helper) {        
        component.set("v.inactiveReasonvalue", component.find("inactivereasonId").get("v.value"));       
    },    
    // BK-2008 - Added by Himanshu 
})