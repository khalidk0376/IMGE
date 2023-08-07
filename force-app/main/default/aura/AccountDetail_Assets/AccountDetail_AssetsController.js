({	
    loadData: function (component, event,helper) {
        var pageNumber = component.get("v.PageNumber");
        var recordId = component.get("v.recordId");
        var columns;
        columns=[
            {label: 'Event Edition', fieldName: 'eeurl', type: 'url', typeAttributes: {label: { fieldName: 'eename' }, target: '_self'}},
            {label: 'Product', fieldName: 'url', type: 'url', typeAttributes: {label: { fieldName: 'Name' }, target: '_self'}},
            {label: 'Quantity', fieldName: 'Quantity', type: 'number',cellAttributes: { alignment: 'left' }},
            {label: 'Price (Sold Price)', fieldName: 'Price_Sold_Price__c', type: 'currency', cellAttributes: { alignment: 'left' }}
        ];
        component.set('v.columns',columns );
        helper.fetchData(component,pageNumber);
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
    }
})