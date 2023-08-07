({
	doInit:function(component, event, helper) {
		console.log('setpup screen loaded');
		
		var algin = [
		{label:"Top Left",value:"top-left"},
		{label:"Top Center",value:"top-center"},
		{label:"Top Right",value:"top-right"},
		{label:"Bottom Left",value:"bottom-left"},
		{label:"Botton Center",value:"bottom-center"},
		{label:"Bottom Right",value:"bottom-right"}
		];
		component.set("v.allginmentList",algin);

		helper.getTemplatesHelper(component);
		//component.set("v.sectionList",[{label:"None",value:""}]);
	},
	submitFormData : function(component, event, helper) {
		helper.submitConfigData(component);
	},
	alignmentChange: function(component, event, helper) {
		var align = component.get("v.buttonAllignment");
		
		if(align.indexOf('top')>=0){
			component.set("v.buttonPosition","Top");
		}else{
			component.set("v.buttonPosition","Bottom");
		}

		if(align=='top-center' || align=='bottom-center'){
			component.set("v.float","slds-align_absolute-center slds-float_none slds-p-around_small");
		}
		else if(align=='top-right' || align=='bottom-right'){
			component.set("v.float","slds-float_right slds-p-around_small");
		}
		else if(align=='top-left' || align=='bottom-left'){
			component.set("v.float","slds-float_left slds-p-around_small");
		}
	},
	checkboxChange : function(component, event, helper) {
		component.set("v.isCustomButton",event.getSource().get("v.checked"));
	},
	templateChange : function(component, event, helper) {
		helper.getSectionsHelper(component);
	},

	sectionChange : function(component, event, helper) {
	
	},

	colorSetupButton : function(component, event, helper) {
		component.set("v.isOpenSectionColorModal",true);
	},
	
	hideModal : function(component,event,helper){
		component.set("v.isOpenSectionColorModal",false);
		var appEvent = $A.get("e.c:QFFieldModelCloseEvt");            
        if(appEvent!=undefined)
        {
            appEvent.setParams({"modelName": "customButton" });
            appEvent.fire();   
        }
	},

	mapAnswerToObjectFields : function(component, event, helper) {
	
	}

})