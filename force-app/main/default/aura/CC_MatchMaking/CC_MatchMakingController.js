({
    loadMatchValues : function(component, event, helper) {
		helper.getMatchMakingDetails(component,event,helper);
    },
    saveDetails : function(component, event, helper)
    {
        var supplyDist = component.get('v.supplyDist');
        var supplyngEndUser = component.get('v.supplyngEndUser');
        var Distributor = component.get('v.Distributor');
       	// console.log('supplyDist',supplyDist);
        // console.log('supplyngEndUser',supplyngEndUser);
        // console.log('Distributor',Distributor);
        helper.saveMatchMakingDetails(component,event);
    },
    closeToast : function (component, event, helper) {
        component.set("v.msgbody","");
    },
    showSpinner: function (component, event, helper) {
		component.set("v.Spinner", true); // Adding values in Aura attribute variable.
	},
	hideSpinner: function (component, event, helper) {
		component.set("v.Spinner", false); // Adding values in Aura attribute variable.
	},
    removeDetails:function(component,event,helper)
    {
        component.set('v.supplyDist','');
        component.set('v.supplyngEndUser','');
        component.set('v.Distributor','');
    }
})