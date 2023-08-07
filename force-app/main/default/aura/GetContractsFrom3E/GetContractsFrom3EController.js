({
    modalClose : function(component, event) {
        $A.get("e.force:closeQuickAction").fire();
    },
    startSync: function(component, event) {
        console.log('111111222111');
        console.log(component.get('v.recordId'));
        component.set('v.confirm',true);
    },

})