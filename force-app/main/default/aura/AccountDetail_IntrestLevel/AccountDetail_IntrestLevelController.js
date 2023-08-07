({	
	loadData: function (component, event,helper) {
    	component.set('v.columns', [
            {label: 'Interest L1', fieldName: 'l1Value', type: 'text'},
            {label: 'Interest L2', fieldName: 'l2Value', type: 'text'},
            {label: 'Interest L3', fieldName: 'l3Value', type: 'text'},
            {label: 'Opportunity Name', fieldName: 'opplink', type: 'url', typeAttributes: {label: { fieldName: 'oppName' }, target: '_self'}}
        ]);
        helper.fetchData(component);
    },
    handleNext: function(component, event, helper){
        component.set("v.showSpinner",true);
        var offset = component.get("v.offSetValue");
        offset = offset + 10;
        component.set("v.offSetValue",offset);
        helper.fetchData(component);
    },
    handlePrev: function(component, event, helper){
        component.set("v.showSpinner",true);
        var offset = component.get("v.offSetValue");
        if(offset >= 10) { offset = offset - 10; }
        component.set("v.offSetValue",offset);
        helper.fetchData(component);
    }
    
})