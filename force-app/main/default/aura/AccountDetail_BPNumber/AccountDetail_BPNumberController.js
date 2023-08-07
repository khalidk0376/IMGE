({	
    loadData: function (component, event,helper) {
        component.set('v.columns', [
            {label: 'ACCOUNT LEGAL ENTITY NAME', fieldName: 'Name', type: 'text'},
            {label: 'BUSINESS PARTNER NUMBER', fieldName: 'Business_Partner_Number__c', type: 'text'},
            {label: 'Active', fieldName: 'Active__c', type: 'boolean'},
            {label: 'DBA', fieldName: 'Legal_Entity_DBA', type: 'text'},
            {label: 'INFORMA BRANCH', fieldName: 'Legal_Entity_Informa_Branch', type: 'text'},
            {label: 'LEGAL ENTITY NAME', fieldName: 'Legal_Entity_Name', type: 'text'}
        ]);
        helper.fetchData(component);
    }
})