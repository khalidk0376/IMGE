({	
    loadData: function (component, event,helper) {
        component.set('v.columns', [
            {label: 'Nature of Business', fieldName: 'Nature_of_Business_value__c', type: 'text'},
            {label: 'Opportunity Name', fieldName: 'opplink', type: 'url', typeAttributes: {label: { fieldName: 'oppName' }, target: '_self'}}
        ]);
        helper.fetchData(component);
    }
})