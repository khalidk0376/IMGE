({
    Init: function(component, event, helper) {
        component.set('v.openBranchingModal', true);
        helper.doInit(component, event, helper);
    },
    erase: function(component, event, helper) {
        helper.eraseHelper(component);
        component.set('v.checkImage',false);
    },
     checkImage: function(component, event, helper) {
      component.set('v.checkImage',true);
    },
    save: function(component, event, helper) {
        helper.saveHelper(component, event, helper);
    },    
	saveSignatureModal:function(component, event, helper){
        var checkData=component.get('v.checkImage');
      	helper.saveHelper(component, event, true, false,checkData);    
    },
    hideModal:function(component, event, helper){
         var checkData=component.get('v.checkImage');
        helper.crudModalEvent(component, event, true, false,checkData);    
    }
})