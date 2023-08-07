({
	loadData : function(component, event, helper) {
        var pageNumber = component.get("v.PageNumber"); 
		helper.getRecord(component,'Contact','AccountId');
		helper.getAccConRecord(component,pageNumber);
        var getSelected = localStorage.getItem('selectedAccordianAccInfo');
        if (getSelected) 
        { 
            component.set("v.activeSections",JSON.parse(getSelected));
        }
	   component.set('v.columns', [
            {label: 'Account Name', fieldName: 'accLink', type: 'url', typeAttributes: {label: { fieldName: 'Account' }, target: '_self'}},
            {label: 'Account Address Verified', fieldName: 'Is_Account_Address_Verified__c', type: 'boolean'},
            {label: 'Direct', fieldName: 'IsDirect', type: 'boolean'},
            {label: 'Last Modified By', fieldName: 'userLink', type: 'url', typeAttributes: {label: { fieldName: 'LastModifiedBy' }, target: '_self'}},
            {label: 'Last Modified Date', fieldName: 'LastModifiedDate', type: 'date', typeAttributes: {
                    day: 'numeric',
                    month: 'short',
                    year: 'numeric',
                    hour: '2-digit',
                    minute: '2-digit',
                    second: '2-digit',
                    hour12: true
                  }}
            ]);
       
	},
     handleSectionToggle: function(component, event) {
        localStorage.setItem('selectedAccordianAccInfo',JSON.stringify(component.find("oppAccordion").get('v.activeSectionName')));
    },
     handleNext: function(component, event, helper) {
        var pageNumber = component.get("v.PageNumber");  
        //var pageSize = component.find("pageSize").get("v.value");
        pageNumber++;
        helper.getAccConRecord(component, pageNumber);
    },
     handlePrev: function(component, event, helper) {
        var pageNumber = component.get("v.PageNumber");  
        //var pageSize = component.find("pageSize").get("v.value");
        pageNumber--;
        helper.getAccConRecord(component, pageNumber);
    }
})