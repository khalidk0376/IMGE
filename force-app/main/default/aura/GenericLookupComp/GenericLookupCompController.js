({
    doInit : function(component, event, helper) {
        helper.getDatas(component,'');
    },
    searchContact : function(component, event, helper) {
        if(component.get("v.searchKey").length>2){
            helper.getDatas(component,component.get("v.searchKey"));	
        }
        else if(component.get("v.searchKey").length==0){
            helper.getDatas(component,'');	
        }
    },	
    selectLookup : function(component, event, helper) {
        component.set("v.selectedItem",event.getSource().get("v.value"));
        component.set("v.selectedItemId",event.getSource().get("v.value").Id);
        component.set("v.isOpenModal",false);
    },
    closeModal : function(component, event, helper) {
        component.set("v.isOpenModal",false);
    },
    // this function is automatically called by aura:waiting event  
    showSpinner: function(component, event, helper) {
       // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
   },
    // this function is automatically called by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
     // make Spinner attribute to false for hide loading spinner    
       component.set("v.Spinner", false);
    }
})