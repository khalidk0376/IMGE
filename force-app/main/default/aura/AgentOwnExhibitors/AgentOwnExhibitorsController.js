({
	myAction: function (component, event, helper) {
		var eventcode = helper.getUrlParameter(component,'eventcode'); // get eventcode from Url
		if(eventcode)
		{
			component.set("v.eventcode",eventcode);
		}
		var activity = [{ label: 'Activity', value: '' }, { label: 'Has not logged in', value: 'NoLogin' }, { label: 'Missing required forms', value: 'MissingForms' },
		{ label: 'Missing required manuals', value: 'MissingManuals' }, { label: 'Missing Badges', value: 'MissingBadges' },
		{ label: 'Missing Exhibitor Profile', value: 'MissingExProfile' }, { label: 'Missing Stand Contractor', value: 'MissingContractor' }];
		var userTypes = [{ label: 'Customer Type', value: 'All' }, { label: 'Exhibitor', value: 'AOE' }, { label: 'Co-exhibitor', value: 'COEXH' }, { label: 'Individual Contract', value: 'INCONT' }];
		component.find('activity').set("v.options", activity);
		component.find('userTypes').set("v.options", userTypes);
		//opts.push({label: 'Dimensions', value: ''});    			

		helper.fetchEventDetails(component);
		//helper.fetchExhibitors(component);
		//helper.fetchBoothDimensions(component);
		helper.fetchAllAOECustomers(component);
		// helper.fetchNewExhibitors(component);
		helper.fetchsubAgents(component);
		window.setTimeout(
			$A.getCallback(function () {
				component.set("v.Spinner", false);// Adding values in Aura attribute variable.
			}), 10000
		);
	},
	showSpinner: function (component, event, helper) {
		component.set("v.Spinner", true); // Adding values in Aura attribute variable.			
	},
	hideSpinner: function (component, event, helper) {
		component.set("v.Spinner", false);// Adding values in Aura attribute variable.
	},
	scriptsLoaded: function (component, event, helper) {
		helper.getSelectedCount(component);
	},
	showmodalViewExhibitor: function (component, event, helper) {
		var accId = event.currentTarget.getAttribute("data-aid");
		var conId = event.currentTarget.getAttribute("data-cid");
		var bthId = event.currentTarget.getAttribute("data-bid");
		var boothNum = event.currentTarget.getAttribute("data-bno");
		var isMailSent = event.currentTarget.getAttribute("data-mail");
		var emailSentDate = event.currentTarget.getAttribute("data-mdate");
		var paidBy = event.currentTarget.getAttribute("data-paidBy");
		var uType = event.currentTarget.getAttribute("data-uType");

		component.set("v.paidBy", paidBy);
		component.set("v.emailSentDate", emailSentDate);
		component.set("v.isMailSent", isMailSent);
		component.set("v.contactId", conId);
		component.set("v.booth", { boothId: bthId, boothNumber: boothNum });
		helper.fetchAccountContacts(component, accId);
		helper.fetchBoothDetails(component, uType);
		helper.fetchRequiredForms(component, accId);
	},
	updateEmailTemplate: function (component, event, helper) {
		helper.updateEventContactMap(component);
	},
	selectAll: function (component, event, helper) {
		$(".chkChild").each(function () {
			var $this = $(this);
			if ($('.chkMaster').is(":checked")) {
				$this.attr("checked", true)
			}
			else {
				$this.attr("checked", false)
			}
		});
		helper.getSelectedCount(component);
	},
	sendEmailtoAllExhibitors: function (component, event, helper) {
		var conIds = [];
		if (component.get("v.contactId")) {
			conIds.push(component.get("v.contactId"));
		}
		else {
			$(".chkChild").each(function () {
				var $this = $(this);
				if ($this.is(":checked")) {
					conIds.push($this.attr("id"));
				}
			});
		}
		helper.sendWelcomeEmail(component, conIds);
		$('#modalConfirm').hide();
		component.set("v.contactId", '');
	},
	showModalConfirmResend: function (component, event, helper) {
		component.set("v.totalSelected", 1);
		$('#modalConfirm').show();
	},
	sendEmailtoExhibitor: function (component, event, helper) {
		// var conIds = [];
		// conIds.push(component.get("v.contactId"));
		// helper.sendWelcomeEmail(component,conIds);
		// $('#modalViewExhibitor').hide();

	},
	isNewExhChange: function (component, event, helper) {
		component.set("v.newExhibitors", $('#chkNewExh').is(":checked"));
		if (component.get('v.newExhibitors') == false && component.get('v.activityType') == '' && component.get('v.userType') == 'All' && component.get('v.standtype') == '' && component.get('v.searchText') == '') {
			component.set('v.showclearFilter', true);
		}
		else {
			component.set('v.showclearFilter', false);
		}
		helper.fetchAllAOECustomers(component);
	},
	missingBadgesChange: function (component, event, helper) {  // no need
		$("#btnsendmail").attr("disabled", true); $(".chkMaster").attr("checked", false);
		component.set("v.missingBadges", $('#chkMissingBadges').is(":checked"));
		component.set("v.newExhibitors", false); $('#chkNewExh').attr("checked", false);
		component.set("v.missingForms", false); $('#chkMissingForms').attr("checked", false);
		component.set("v.indContract", false); $('#chkIndContract').attr("checked", false);
		helper.fetchExhibitors(component);
	},
	missingFormChange: function (component, event, helper) { // no need
		$("#btnsendmail").attr("disabled", true); $(".chkMaster").attr("checked", false);
		component.set("v.missingForms", $('#chkMissingForms').is(":checked"));
		component.set("v.newExhibitors", false); $('#chkNewExh').attr("checked", false);
		component.set("v.missingBadges", false); $('#chkMissingBadges').attr("checked", false);
		component.set("v.indContract", false); $('#chkIndContract').attr("checked", false);
		helper.fetchExhibitors(component);
	},
	contractChange: function (component, event, helper) {  // no need
		$("#btnsendmail").attr("disabled", true); $(".chkMaster").attr("checked", false);
		component.set("v.indContract", $('#chkIndContract').is(":checked"));
		component.set("v.newExhibitors", false); $('#chkNewExh').attr("checked", false);
		component.set("v.missingBadges", false); $('#chkMissingBadges').attr("checked", false);
		component.set("v.missingForms", false); $('#chkMissingForms').attr("checked", false);
		helper.fetchExhibitors(component);
	},
	filterNew: function (component, event, helper) {
		$("#chkNewExh").attr("checked", true);
		component.set("v.newExhibitors", $('#chkNewExh').is(":checked"));
		helper.fetchExhibitors(component);
	},
	checkboxSelect: function (component, event, helper) {
		helper.getSelectedCount(component);
	},
	dimensionChange: function (component, event, helper) { //  No Need For this Methord
		$("#btnsendmail").attr("disabled", true); $(".chkMaster").attr("checked", false);
		helper.fetchExhibitors(component);
	},
	standtypeChange: function (component, event, helper) {
		$("#btnsendmail").attr("disabled", true); $(".chkMaster").attr("checked", false);
		if (component.get('v.newExhibitors') == false && component.get('v.activityType') == '' && component.get('v.userType') == 'All' && component.get('v.standtype') == '' && component.get('v.searchText') == '') {
			component.set('v.showclearFilter', true);
		}
		else {
			component.set('v.showclearFilter', false);
		}
		helper.fetchAllAOECustomers(component);
		//helper.fetchExhibitors(component);
	},
	hidemodalViewExhibitor: function (component, event, helper) {
		$('#modalViewExhibitor').hide();
	},
	showmodalSendEmail: function (component, event, helper) {
		$('#modalSendEmail').show();
	},
	hidemodalSendEmail: function (component, event, helper) {
		$('#modalSendEmail').hide();
	},
	showmodaldownloadreports: function (component, event, helper) {
		$('#modaldownloadreports').show();
	},
	hidemodaldownloadreports: function (component, event, helper) {
		$('#modaldownloadreports').hide();
	},
	downloadReports : function (component, event, helper) 
	{
		var reportType = event.target.getAttribute("data-id");
		var sEventCode = component.get("v.eventcode");
		var subAgentSelected = component.get("v.subAgentSelected");
		if(sEventCode && reportType)
		{
			var exportUrl = window.location.origin + '/CustomerCenter/apex/c__ExportAOEReports?eventId='+sEventCode+'&reportName='+reportType+'&accountId=';
			if(subAgentSelected && subAgentSelected.id !='')
			{
				exportUrl = exportUrl+subAgentSelected.id;
			}
			console.log(' Export Url : '+exportUrl);
			window.location =  exportUrl;
		}
		else{
			console.log('No valid record found.');
		}
		
	},
	showmodalpreviewemail: function (component, event, helper) {
		//helper.fetchEmailTemplate(component);
		$('#modalpreviewemail').show();
	},
	hidemodalpreviewemail: function (component, event, helper) {
		$('#modalpreviewemail').hide();
	},
	exportAllExh: function (component, event, helper) {
		helper.fetchExhibitorsReports(component, false, false, false, false);
	},
	exportExhMissingForms: function (component, event, helper) {
		helper.fetchExhibitorsReports(component, false, true, false, false);
	},
	exportExhMissingBadges: function (component, event, helper) {
		helper.fetchExhibitorsReports(component, true, false, false, false);
	},
	exportExhMissingManuals: function (component, event, helper) {
		helper.fetchExhibitorsReports(component, false, false, true, false);
	},
	exportBadgesInfo: function (component, event, helper) {
		helper.fetchExhibitorsReports(component, false, false, false, true);
	},
	closemsg: function (component, event, helper) {
		component.set("v.reportNotFound", false);
	},
	closeTopMsg: function (component, event, helper) {
		component.set("v.newExhTotal", 0);
	},
	hideModalConfirm: function (component, event, helper) {
		$('#modalConfirm').hide();
	},
	hideModalSelectSubAgent: function (component, event, helper) {
		$('#modalSelectSubAgent').hide();
	},
	showModalSelectSubAgent: function (component, event, helper) {
		$(".subAgentRadio").each(function () {
			var $this = $(this);
			if ($this.is(":checked")) {
				$this.attr("checked", false)
			}
		});
		component.set("v.isSubAgentSelected", false);
		$('#modalSelectSubAgent').show();
	},
	hideModalConfirmSubAgent: function (component, event, helper) {
		$('#modalConfirmSubAgent').hide();
		component.set("v.subAgentSelected", '');
	},
	showmodalConfirmSubAgent: function (component, event, helper) {
		$('#modalConfirmSubAgent').show();
	},
	selectSubAgent: function (component, event, helper) {
		component.set("v.isSubAgentSelected", true);
	},
	setSubAgent: function (component, event, helper) {
		$('#modalConfirmSubAgent').hide();
		$('#modalSelectSubAgent').hide();
		$(".subAgentRadio").each(function () {
			var $this = $(this);
			if ($this.is(":checked")) {
				//console.log('this.attr("id")=='+$this.attr("id"));
				//console.log('$this.attr("data-name")=='+$this.attr("data-name"));
				component.set("v.subAgentSelected", { name: $this.attr("data-name"), id: $this.attr("id") });
			}
		});
		component.set('v.onLoadStandType', true); 
		component.set("v.activityType", '');
		component.set("v.userType", 'All');
		component.set("v.standtype",'');
		component.set("v.newExhibitors", false);
		component.set('v.showclearFilter', true);
		component.set("v.searchText",'');		
		helper.fetchAllAOECustomers(component);
		// helper.fetchExhibitors(component);
		// helper.fetchNewExhibitors(component);
	},
	returnToExhibitor: function (component, event, helper) {		
		component.set("v.subAgentSelected", '');
		component.set("v.reportNotFound", false);
		component.set('v.onLoadStandType', true);
		component.set("v.isSubAgentSelected", false);
		component.set("v.activityType", '');
		component.set("v.userType", 'All');
		component.set("v.standtype",'');
		component.set("v.newExhibitors", false);
		component.set('v.showclearFilter', true);
		component.set("v.searchText",'');

		helper.fetchAllAOECustomers(component);
		// helper.fetchExhibitors(component);
		// helper.fetchNewExhibitors(component);
	},
	showModalConfirm: function (component, event, helper) {
		var counter = 0;
		$(".chkChild").each(function () {
			var $this = $(this);
			if ($this.is(":checked")) {
				counter++;
			}
		});
		component.set("v.totalSelected", counter);
		$('#modalConfirm').show();
	},
	searchAOE: function (component, event, helper) {
		//console.log('Text : '+component.get("v.searchText") );
		if (component.get('v.newExhibitors') == false && component.get('v.activityType') == '' && component.get('v.userType') == 'All' && component.get('v.standtype') == '' && component.get('v.searchText') == '') {
			component.set('v.showclearFilter', true);
		}
		else {
			component.set('v.showclearFilter', false);
		}

		helper.fetchAllAOECustomers(component);

		//helper.SearchCustomer(component,component.get("v.searchText"));

	},
	clearFilter: function (component, event, helper) {
		helper.fetchAllAOECustomers(component, false);
	},
	activityTypeChange: function (component, event, helper) {
		if (component.get('v.newExhibitors') == false && component.get('v.activityType') == '' && component.get('v.userType') == 'All' && component.get('v.standtype') == '' && component.get('v.searchText') == '') 
		{
			component.set('v.showclearFilter', true);
		}
		else 
		{
			component.set('v.showclearFilter', false);
		}
		helper.fetchAllAOECustomers(component);
	},
	userTypeChange: function (component, event, helper) {
		console.log( component.get('v.newExhibitors') +' , '+component.get('v.activityType') + ' , '+component.get('v.userType')+ ' , '+component.get('v.standtype') + ' , '+component.get('v.searchText'));
		if (component.get('v.newExhibitors') == false && component.get('v.activityType') == '' && component.get('v.userType') == 'All' && component.get('v.standtype') == '' && component.get('v.searchText') == '') {
			component.set('v.showclearFilter', true);
		}
		else {
			component.set('v.showclearFilter', false);
		}
		helper.fetchAllAOECustomers(component);
	},
	sortTableUnconventional: function (component, event, helper) {
		var n = event.currentTarget.getAttribute("data-index");
		//console.log('index>>>'+n);
		var table, rows, switching, i, x, y, shouldSwitch, dir, switchcount = 0;
		table = document.getElementById("exhTable");
		switching = true;
		//Set the sorting direction to ascending:
		dir = "asc";
		/*Make a loop that will continue until
		no switching has been done:*/
		while (switching) {
			//start by saying: no switching is done:
			switching = false;
			rows = table.getElementsByTagName("TR");
			/*Loop through all table rows (except the
			first, which contains table headers):*/
			for (i = 1; i < (rows.length - 1); i++) {
				//start by saying there should be no switching:
				shouldSwitch = false;
				/*Get the two elements you want to compare,
				one from current row and one from the next:*/
				x = rows[i].getElementsByTagName("TD")[n];
				y = rows[i + 1].getElementsByTagName("TD")[n];
				/*check if the two rows should switch place,
				based on the direction, asc or desc:*/
				if (dir == "asc") {
					if (x.innerHTML.toLowerCase() > y.innerHTML.toLowerCase()) {
						//if so, mark as a switch and break the loop:
						shouldSwitch = true;
						break;
					}
				} else if (dir == "desc") {
					if (x.innerHTML.toLowerCase() < y.innerHTML.toLowerCase()) {
						//if so, mark as a switch and break the loop:
						shouldSwitch = true;
						break;
					}
				}
			}
			if (shouldSwitch) {
				/*If a switch has been marked, make the switch
				and mark that a switch has been done:*/
				rows[i].parentNode.insertBefore(rows[i + 1], rows[i]);
				switching = true;
				//Each time a switch is done, increase this count by 1:
				switchcount++;
			} else {
				/*If no switching has been done AND the direction is "asc",
				set the direction to "desc" and run the while loop again.*/
				if (switchcount == 0 && dir == "asc") {
					dir = "desc";
					switching = true;
				}
			}
		}
	},
	sortTable: function (component, event, helper) {
		//Get index of currently clicked function
		var n = event.currentTarget.getAttribute("data-index");
		//Create a map of table index to key in fetched object
		var key_map = {
			"1": "accountName",
			"2": "boothNumber",
			"3": "dimensions",
			"4": "boothType",
			"5": "userType",
			"6": "emailSentDate"
		};
		//Get sorting key
		var sort_key = key_map[n];
		//Define ascending sort function
		var asc_sort_function = function (a, b) {
			if (a[sort_key] === null || a[sort_key] === undefined) {
				return -1;
			}
			if (b[sort_key] === null || b[sort_key] === undefined) {
				return 1;
			}
			if (a[sort_key] < b[sort_key]) {
				return -1;
			}
			if (a[sort_key] > b[sort_key]) {
				return 1;
			}
			return 0;
		}
		//define descending sort function
		var desc_sort_function = function (a, b) {
			if (a[sort_key] === null || a[sort_key] === undefined) {
				return 1;
			}
			if (b[sort_key] === null || b[sort_key] === undefined) {
				return -1;
			}
			if (a[sort_key] < b[sort_key]) {
				return 1;
			}
			if (a[sort_key] > b[sort_key]) {
				return -1;
			}
			return 0;
		}
		//Get current sorting order for clicked index
		var sorting_map = component.get("v.sortingMap");
		var sort_order = sorting_map[n];
		if (sort_order === 'asc') {
			var exhibitors = component.get("v.exhibitors");
			exhibitors.sort(asc_sort_function);
			component.set("v.exhibitors", exhibitors);
			sorting_map[n] = 'desc';
			component.set("v.sortingMap", sorting_map);
		}
		if (sort_order === 'desc') {
			var exhibitors = component.get("v.exhibitors");
			exhibitors.sort(desc_sort_function);
			component.set("v.exhibitors", exhibitors);
			sorting_map[n] = 'asc';
			component.set("v.sortingMap", sorting_map);
		}
	},
	showModalNewExhibitors: function (component, event, helper) {
		$('#modalNewExhibitors').show();
	},
	hideModalNewExhibitors: function (component, event, helper) {
		$('#modalNewExhibitors').hide();
	},
	showModalCustomerType: function (component, event, helper) {
		$('#modalCustomerType').show();
	},
	hideModalCustomerType: function (component, event, helper) {
		$('#modalCustomerType').hide();
	},

	showExhibitorQuickView: function (component, event, helper) {
		var accountId = event.currentTarget.getAttribute('data-aid');
		var accountName = event.currentTarget.getAttribute('data-aname');
		var exhibitorPaidBy = event.currentTarget.getAttribute('data-exhibitor-paidby');
		component.set("v.quickViewAccountId", accountId);
		component.set("v.quickViewAccountName", accountName);
		component.set("v.quickViewExhibitorPaidBy", exhibitorPaidBy);

		component.set("v.showExhibitorQuickView", true);
	},

	hideExhibitorQuickView: function (component, event, helper) {
		component.set("v.showExhibitorQuickView", false);
	},

	handleModalInModal: function (component, event, helper) {
		var typeOfEvent = event.getParam('type');
		// if (typeOfEvent === 'open') {
		// 	component.set("v.modalInModal", true);
		// }
		// if (typeOfEvent === 'close') {
		// 	component.set("v.modalInModal", false);
		// }
	},
	showExhibitorDisableTooltip: function (component, event, helper) {
		$('#modalManageDisable').show();
	},

	hideExhibitorDisableTooltip: function (component, event, helper) {
		$('#modalManageDisable').hide();
	},

	navigateToExhibitor : function (component, event, helper) {
		// let navURL = "/AgentOwnedExhibitorDetails?eventcode="+component.get("v.eventcode")+"&accid="+component.get("v.quickViewAccountId");
		let navURL = "agentownexhibitordetails?eventcode="+component.get("v.eventcode")+"&accid="+component.get("v.quickViewAccountId");
		window.open(navURL,"_parent");
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