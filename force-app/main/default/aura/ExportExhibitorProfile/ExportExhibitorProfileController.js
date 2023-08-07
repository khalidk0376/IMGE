({
	accountData : function(component, event, helper)  
	{
        
		var tarUrl = window.location.origin + '/apex/c__ExhibitorProfileVF?reportName=ExhibitorProfile&eventId=' +component.get("v.eventId");  
        window.location =  tarUrl;
	},
    scriptsLoaded: function(component, event, helper)  
	{
	}
})