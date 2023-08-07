({
    loadData: function(component, event, helper) {
        var pageNumber = component.get("v.PageNumber");
        var recordId = component.get("v.recordId");
        var columns;
        columns = [
            { label: 'Account Line Item', fieldName: 'Name', type: 'text' },
            { label: 'Active', fieldName: 'Active__c', type: 'boolean' },
            { label: 'Association', fieldName: 'association', type: 'text' },
            { label: 'Event Series', fieldName: 'Event_Series__c', type: 'text' },
            { label: 'Expiry Date', fieldName: 'Expiry_Date__c', type: 'date' },
            { label: 'Member Status', fieldName: 'Member_Status__c', type: 'text' },
            { label: 'Chamber', fieldName: 'Chamber__c', type: 'text' }
        ];
        component.set('v.columns', columns);
        helper.fetchData(component, pageNumber);
    },
    handleNext: function(component, event, helper) {
        component.set("v.showSpinner", true);
        var pageNumber = component.get("v.PageNumber");
        //var pageSize = component.find("pageSize").get("v.value");
        pageNumber++;
        helper.fetchData(component, pageNumber);
    },
    handlePrev: function(component, event, helper) {
        component.set("v.showSpinner", true);
        var pageNumber = component.get("v.PageNumber");
        //var pageSize = component.find("pageSize").get("v.value");
        pageNumber--;
        helper.fetchData(component, pageNumber);
    }
})