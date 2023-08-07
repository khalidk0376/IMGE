({
	onLoad : function(component, event, helper) {
		helper.fetchAgentExhContacts(component);
	},
	InviteContact : function(component, event, helper) {
		var conId= event.currentTarget.getAttribute("data-cid");
		var agentConId= event.currentTarget.getAttribute("data-id");
		var agnId= event.currentTarget.getAttribute("data-aid");
		var sEventId = component.get("v.eventId");// Getting values from Aura attribute variable.
		component.set("v.exhCon",{Id:agentConId,AgentContactId__c:agnId,ExhibitorContactId__c:conId,EventEdition__c:sEventId,IsUserCreated__c:true});
		helper.sendInvitation(component);
	},
	showConfirm : function(component, event, helper) {
		document.getElementById('Confirm').style.display = "block";	
	},
	hideConfirm : function(component, event, helper) {
		document.getElementById('Confirm').style.display = "none";
	},
})