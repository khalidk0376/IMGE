({
    loadData: function(component, event, helper) {
        var pageNumber = component.get("v.PageNumber");
        component.set('v.columns', [
            { label: 'Partner Account', fieldName: 'acLink', type: 'url', typeAttributes: { label: { fieldName: 'acName' }, target: '_self' } },
            { label: 'Role', fieldName: 'Role', type: 'text' },
        ]);
        helper.fetchData(component, pageNumber);
    },
    handleNext: function(component, event, helper) {
        component.set("v.showSpinner", true);
        var pageNumber = component.get("v.PageNumber");
        pageNumber++;
        helper.fetchData(component, pageNumber);
    },
    handlePrev: function(component, event, helper) {
        component.set("v.showSpinner", true);
        var pageNumber = component.get("v.PageNumber");
        pageNumber--;
        helper.fetchData(component, pageNumber);
    },
    handleRefresh : function(component,event,helper){
        var pageNumber = component.get("v.PageNumber");
        helper.fetchData(component, pageNumber);
    }
})