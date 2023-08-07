({
	loadData : function(component, event, helper) {	
        var pageNumber = component.get("v.PageNumber"); 
         var columns;
         {
           columns=[
                {label: 'Event Edition', fieldName: 'eventLink', type: 'url', typeAttributes: {label: { fieldName: 'Event' }, target: '_self'}},
                {label: 'Event Series', fieldName: 'seriesLink', type: 'url', typeAttributes: {label: { fieldName: 'Series' }, target: '_self'}},
                {label: 'Status', fieldName: 'Status__c', type: 'boolean'}
            ];
        }
        component.set('v.columns',columns );
        helper.fetchData(component,pageNumber);
	},
     handleNext: function(component, event, helper) {
        var pageNumber = component.get("v.PageNumber");  
        //var pageSize = component.find("pageSize").get("v.value");
        pageNumber++;
        helper.fetchData(component, pageNumber);
    },
     handlePrev: function(component, event, helper) {
        var pageNumber = component.get("v.PageNumber");  
        //var pageSize = component.find("pageSize").get("v.value");
        pageNumber--;
        helper.fetchData(component, pageNumber);
    }
})