({
	onloadData : function(component, event, helper) {
		console.log('boothMapId'+component.get("v.boothMapId"));
		helper.fetchSubCon(component);
	},
	boothMapIdChanged: function(component, event, helper) {
		helper.fetchSubCon(component);
	},
	// ## function call on Click on the "Download As CSV" Button. 
    downloadCsv : function(component,event,helper){
        var tarUrl = window.location.origin + '/apex/c__AllContractorsReportExport?event=' +component.get("v.eventId") + '&compName=Subcontractors&reportName=Subcontractors' ;        
        window.location =  tarUrl;
    },
})