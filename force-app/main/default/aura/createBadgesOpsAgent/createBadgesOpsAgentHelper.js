({
	fetchEventSettings: function (component) {
		var action = component.get("c.getEventSettings"); //get data from controller
		var eventId = component.get("v.eventId");
		action.setParams({
			eventId: eventId
		});
		action.setCallback(this, function (res) {
			var result = res.getReturnValue();
			component.set("v.eventSettings", result);
			if (result.Badge_Nationality__c) {
				this.fetchPicklistValues(component, 'Agent_Badges__c', 'Nationality__c', 'selectNation');
			}
			if (result.Badge_Age_Bracket__c) {
				this.fetchPicklistValues(component, 'Agent_Badges__c', 'Age_Bracket__c', 'selectAgeBracket');
			}
			if (result.Badge_Country__c) {
				this.fetchPicklistValues(component, 'Agent_Badges__c', 'Country__c', 'selectCountry');
			}
			if (result.Badge_Mobile_Number__c) {
				this.fetchPicklistValues(component, 'Agent_Badges__c', 'Country_Code__c', 'selectCountryCode');
			}

		});
		$A.enqueueAction(action);
	},
	fetchBadgesStatus: function (component) {
		var action = component.get("c.getBadgesStatusMap");
		let eventId = component.get('v.eventId');
		let accountId = component.get('v.accountId');
		action.setParams({
			accountId: accountId,
			eventEditionId: eventId
		});
		action.setCallback(this, function (response) {
			if (response.getState() === 'SUCCESS') {
				component.set('v.badgesStatusMap', response.getReturnValue());
				let additionalBadges = component.get('v.badgesStatusMap.additionalBadges');
				let baseBadges = component.get('v.eventSettings.Agent_Badge_limit__c');
				let submittedBadges = parseInt(component.get('v.badgesStatusMap.submitted'));
				
				if(additionalBadges === undefined || isNaN(additionalBadges)){
					component.set('v.badgesStatusMap.additionalBadges',0);
					additionalBadges = 0;
				}
				if(baseBadges === undefined || isNaN(baseBadges)){
					component.set('v.eventSettings.Agent_Badge_limit__c',0);
					baseBadges = 0;
				}
				if(submittedBadges === undefined || isNaN(submittedBadges)){
					component.set('v.badgesStatusMap.submitted',0);
					submittedBadges = 0;
				}

				let totalBadges = parseInt(additionalBadges) + parseInt(baseBadges);
				component.set('v.totalBadges', totalBadges);
				component.set('v.remainingBadges', totalBadges - submittedBadges);
					
			} else {
				console.log('some error occured while fetching badges status map');
			}
		});
		$A.enqueueAction(action);
	},
	updateBadgesLimit: function (component) {
		var action = component.get("c.increaseBadgeLimit");
		let newAdditionalLimit = parseInt(component.get('v.additionalBadgeInput')) + parseInt(component.get('v.badgesStatusMap.additionalBadges'));
		let eventMappingId = component.get('v.badgesStatusMap.eventEditionMappingId');
		console.log('Event mapping id-->',eventMappingId);
		action.setParams({
			newLimit: newAdditionalLimit,
			eventEditionMappingId: eventMappingId
		});
		action.setCallback(this, function (response) {
			if (response.getState() === 'SUCCESS') {
				component.set('v.successMessage',true);
				component.set('v.message', 'New limit successfully updated');
				this.fetchBadgesStatus(component);
				setTimeout(function(){
					document.getElementById('modalIncreaseLimit').style.display = "none";
					component.set('v.additionalBadgeInput',0);
					component.set('v.message', '');
					component.set('v.successMessage',false);
				},2000);
			} else {
				console.log('status------->',response.getState());
			}
		});
		$A.enqueueAction(action);
	},
	getCSV: function (component) {
		let badges = component.get('v.badgesStatusMap.agentBadgeList');
		var csvStringResult;
		var counter;
		var keys;

		// store ,[comma] in columnDivider variabel for sparate CSV values and 
		// for start next line use '\n' [new line] in lineDivider varaible  
		var columnDivider = ',';
		var lineDivider = '\n';


		// check if "badges" parameter is null, then return from function
		if (badges == null || !badges.length) {
			return null;
		}

		// in the keys variable store fields API Names as a key 
		// these labels use in CSV file header  
		keys = ['Account_Name__c','First_Name__c','Last_Name__c','Job_Title__c','Address__c','City__c','Country__c','Nationality__c','State__c','Status__c','Age_Bracket__c','Country_Code__c','Mobile_Number__c','Email__c','Is_VIP__c'];
		var map = {
			'Account_Name__c' : 'Company Name on Badge',
			'First_Name__c' : 'First Name',
			'Last_Name__c' : 'Last Name',
			'Job_Title__c' : 'Job Title',
			'Address__c' : 'Address',
			'City__c' : 'City',
			'Country__c' : 'Country',
			'Nationality__c' : 'Nationality',
			'State__c' : 'State',
			'Status__c' : 'Status',
			'Age_Bracket__c' : 'Age Bracket',
			'Country_Code__c' : 'Country Code',
			'Mobile_Number__c' : 'Mobile Number',
			'Email__c' : 'Email',
			'Is_VIP__c' : 'VIP'
		};

		csvStringResult = '';
		csvStringResult += keys.join(columnDivider);
		csvStringResult += lineDivider;

		for (var i = 0; i < badges.length; i++) {
			counter = 0;
			if (badges[i].Is_VIP__c == true) {
				badges[i].Is_VIP__c = 'Yes';
			} else {
				badges[i].Is_VIP__c = 'No';
			}
			for (var sTempkey in keys) {
				var skey = keys[sTempkey];
				if (counter > 0) {
					csvStringResult += columnDivider;
				}
				csvStringResult += '"' + badges[i][skey] + '"';
				counter++;
			} // inner for loop close 
			csvStringResult += lineDivider;
		} // outer main for loop close 

		var FinalcsvStringResult = csvStringResult.split('\n');


		FinalcsvStringResult[0] = FinalcsvStringResult[0].replace(/Account_Name__c|First_Name__c|Last_Name__c|Job_Title__c|Address__c|City__c|Country__c|Nationality__c|State__c|Status__c|Age_Bracket__c|Country_Code__c|Mobile_Number__c|Email__c|Is_VIP__c/gi, function (matched) {
			return map[matched];
		});
		FinalcsvStringResult = FinalcsvStringResult.join('\n');
		return FinalcsvStringResult.replace(/undefined|FALSE/gi, '');

	},
	getSingleBadgeHelper: function (component, idStr) {
		let badgesList = component.get('v.badgesStatusMap.agentBadgeList');
		function findBadge(badge) { return badge.Id === idStr; }
		let requiredBadge = badgesList.find(findBadge);

		if (requiredBadge) {
			component.set("v.selectedBadge", requiredBadge);
			if (requiredBadge.Status__c == 'Approved' || requiredBadge.Status__c == 'Rejected') {
				component.set("v.isConfirm", false);
			} else {
				component.set("v.isConfirm", true);
			}
		}
		component.set("v.isViewDetail", false);
	},
	updateExhibitorBadgeFields: function (component) {
		component.set("v.isSpinner", true);
		var action = component.get("c.updateBadgeAllFields");
		action.setParams({
			ebObj: component.get("v.selectedBadge")
		});
		action.setCallback(this, function (res) {
			component.set("v.isSpinner", false);
			if (res.getState() === 'SUCCESS') {
				this.fetchBadgesStatus(component);
			}
			component.set("v.isEditBadge", false);
			component.set("v.isViewDetail", true);
		});
		$A.enqueueAction(action);
	},
	updateExhibitorBadgeStatus: function (component, badgeList, status) {
		if (badgeList.length == 0) {
			return;
		}
		component.set("v.isSpinner", true);
		var action = component.get("c.updateExhibitorBadge");
		action.setParams({
			idStr: badgeList,
			status: status
		});
		action.setCallback(this, function (res) {
			component.set("v.isSpinner", false);
			if (res.getState() === 'SUCCESS') {
				this.fetchBadgesStatus(component);
			} else {
				console.log(res.getReturnValue());
			}
			component.set("v.isViewDetail", false);
		});
		$A.enqueueAction(action);
	},
	fetchPicklistValues: function (component, objName, field, attribute) {
		var action = component.get('c.getPicklistValues');
		action.setParams({
			objApi: objName,
			fieldName: field
		});
		action.setCallback(this, function (res) {
			var state = res.getState()
			var result = res.getReturnValue();
			if (component.isValid() && state === 'SUCCESS') {
				var opts = [];
				opts.push({
					label: '--Select--',
					value: ''
				});
				for (var i = 0; i < result.length; i++) {
					if (result[i].split('__$__')[0] != 'None') {
						opts.push({ label: result[i].split('__$__')[0], value: result[i].split('__$__')[1] });
					}
				}
				component.find(attribute).set("v.options", opts);
				if (field == 'Country__c') {
					component.set("v.countryPicklist", opts);
				}
				if (field == 'Age_Bracket__c') {
					component.set("v.ageBracketPicklist", opts);
				}
				if (field == 'Nationality__c') {
					component.set("v.nationalityPicklist", opts);
				}
				if (field == 'Country_Code__c') {
					component.set("v.countryCodePicklist", opts);
				}
			}
		})
		$A.enqueueAction(action)
	},
	saveAgentBadge: function (component, newBadge) {
		var isSaveandNew = component.get("v.isSaveandNew");
		var action = component.get("c.saveAgentBadge"); //get data from controller
		action.setParams({
			agentBadge: newBadge
		});
		action.setCallback(this, function (res) {
			this.resetForm(component);
			if (!isSaveandNew) {
				document.getElementById('modalCreateBadge').style.display = "none";
			}
			this.fetchBadgesStatus(component);
			let button = component.find('btnCreateBadge');
			button.set('v.disabled', false); //CCEN-643 
		});
		$A.enqueueAction(action);
	},
	saveLimits: function (component, newLimits) {
		var action = component.get("c.increaseBoothBadgeLimit"); //get data from controller
		action.setParams({
			expoBoothsMapping: newLimits
		});
		action.setCallback(this, function (res) {
			this.fetchBooths(component);
			document.getElementById('modalIncreaseLimit').style.display = "none";
		});
		$A.enqueueAction(action);
	},
	resetForm: function (component) {
		component.set("v.newBadge", {
			'Account_Name__c': component.get('v.badgesStatusMap.companyName'),
			'Address__c': '',
			'Age_Bracket__c': '',
			'AgentEventEditionMapping__c': '',
			'City__c': '',
			'Country__c': '',
			'Country_Code__c': '',
			'Email__c': '',
			'First_Name__c': '',
			'Is_VIP__c': false,
			'Job_Title__c': '',
			'Last_Name__c': '',
			'Mobile_Number__c': '',
			'Nationality__c': '',
			'State__c': '',
			'Status__c': 'Approved'
		});
	}
})