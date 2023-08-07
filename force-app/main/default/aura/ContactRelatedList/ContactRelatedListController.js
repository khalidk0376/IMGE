({
	doInit:function(component, event, helper) {
		component.set("v.relatedObj",{sobjectType:'AccountContactRelation',AccountId:component.get("v.recordId")});
		component.set("v.contactObj",{sobjectType:'Contact'});
		component.set("v.parentId","");
		helper.getAccountDetail(component);
	},
	openNewContactModal : function(component, event, helper) {
		component.set("v.isOpenNewContactModal",true);
	},
	closeModal: function(component, event, helper) {
		component.set("v.isOpenRelationModal",false);
	},
	openRelationModal: function(component, event, helper) {
		component.set("v.parentId","");
		component.set("v.relatedObj",{sobjectType:'AccountContactRelation',AccountId:component.get("v.recordId")});
		component.set("v.isOpenRelationModal",true);
	},
	submitForm:function(component, event, helper) {
		if(helper.validate(component)){
			helper.addAccountContactRelation(component);	
		}
		else{
			window._LtngUtility.toast('Error!','error','Please update the invalid form entries and try again.');
		}
	}
})