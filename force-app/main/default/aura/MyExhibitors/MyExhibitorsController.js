({
	scriptsLoaded: function (component, event, helper) {
		$(document).ready(function () {
			//$('[data-toggle="tooltip"]').tooltip(); 
		 
		});
    },
	cartOnloadData: function (component, event, helper)
	{
		var eventcode = helper.getUrlParameter(component,'eventcode'); // get eventcode from Url
		if(eventcode)
		{
			component.set("v.eventcode",eventcode);
		}
        helper.fetchEventDetails(component);
		helper.fetchExhibitors(component);
		helper.fetchAgents(component);
		helper.fetchContarctorStatus(component);
    },
	updateConStatus: function (component, event, helper) {
        var selectId = event.currentTarget.getAttribute("id");
    	var status = $('#' + selectId).find(":selected").val();
        var mapid = event.currentTarget.getAttribute("data-mid");
		component.set("v.mapId", mapid);// Adding values in Aura attribute variable.
		if (status) $("#modalchangestatus").show();
	},
	changeStatus: function (component, event, helper) {
		var mapid = component.get("v.mapId");
		var status = $('#' + mapid).find(":selected").val();
         //console.log('mapid ==== '+mapid+'   status ===== '+status);
		if (status) helper.updateConStatus(component, mapid, status);
		$("#modalchangestatus").hide();
	},
	showSpinner: function (component, event, helper)
	{
		component.set("v.Spinner", true); // Adding values in Aura attribute variable.
	},
	hideSpinner: function (component, event, helper)
	{
		component.set("v.Spinner", false);// Adding values in Aura attribute variable.
	},
	goToNewPage: function (component, event, helper)
	{
		var vEventCode = component.get("v.eventcode");
		window.open("subcontractors?eventcode=" + vEventCode);
	},
	hidemodalchangestatus: function (component, event, helper)
	{
		$("#modalchangestatus").hide();
	},
	showModalViewAll: function (component, event, helper)
	{
		//helper.fetchPavilionSpaceExhibitors(component); 
		var agentAccID = event.currentTarget.getAttribute("value");
		var agentAccName = event.currentTarget.getAttribute("data-name");
		var Agent =
		{
			type: "Agent",
			Id: agentAccID,
			Name: agentAccName
		};
		component.set("v.CurrentAgent", Agent);// Adding values in Aura attribute variable.
		helper.getAgentsbooths(component, agentAccID);
		// document.getElementById('modalViewAll').style.display = "block";	 
	},
	hideModalViewAll: function (component, event, helper)
	{
		document.getElementById('modalViewAll').style.display = "none";
	},
	onfilterExhibitor: function (component, event, helper)
	{
		helper.fetchPavilionSpaceExhibitors(component);
	},
	ExportData: function (component, event, helper) {
		//console.log('Exporting Data.......');
		var agent = component.get("v.CurrentAgent");
		var csv = helper.exportExhibitors(component);
		if (csv == null) {
			console.log('No Data to Export');
			return;
		}
		else 
		{
			if (navigator.msSaveBlob) 
			{
				var blob = new Blob([csv],{type: "text/csv;charset=utf-8;"});
				navigator.msSaveBlob(blob,  agent.Name + ' - Exhibitors.csv')
			} 
			else 
			{
				var hiddenElement = document.createElement('a');
				hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
				hiddenElement.target = '_blank'; // 
				hiddenElement.download = agent.Name + ' - Exhibitors.csv';  // CSV file Name* you can change it.[only name not .csv] 
				document.body.appendChild(hiddenElement); // Required for FireFox browser   
				hiddenElement.click(); // using click() js function to download csv file */
			    document.body.removeChild(hiddenElement);          
			} 
		}
	},
	goToHome:function(component, event, helper) {
        var url =window.location.href;
        let eventcode = component.get('v.eventcode');
		if(url.includes('/s/')){
			window.location.href='/CustomerCenter/s/?eventcode='+eventcode;
		}
		else{
			window.location.href='home?eventcode='+eventcode;
		}
	}
})