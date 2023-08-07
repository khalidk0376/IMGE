({
	onLoad: function(component,event,helper) {
        helper.getBaseUrl(component, event, helper);
        helper.getStandDesign(component, event, helper);
        
    },
    download: function(component,event,helper) {
        helper.downloadfile(component, event, helper);
    },
    handleClick: function(component,event,helper) {
        helper.SubmitDesign(component, event, helper);
    },
    PopUpClosedChanges: function(component,event,helper) {
        //debugger;
        helper.ReInitialize(component, event, helper);
    },
    AccountIdChanges: function(component,event,helper) {
        //debugger;
        var Accid=component.get("v.AccountId");
        helper.getStandDesignClone(component, event, helper);
    },
    waiting: function(component, event, helper) {
        document.getElementById("Accspinner").style.display = "block";
     },
     
    doneWaiting: function(component, event, helper) {
       document.getElementById("Accspinner").style.display = "none";
     }    

})