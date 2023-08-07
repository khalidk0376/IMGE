({
	fetchEventSettings: function (component) {
		var action = component.get("c.getEventSettings"); //get data from controller
		var eventId = component.get("v.eventId");
		action.setParams({
			eventId: eventId
		});
		action.setCallback(this, function (res) {
			var result = res.getReturnValue();
			//console.log('eventSettings------'+JSON.stringify(result));
			component.set("v.eventSettings", result);
			if (result.Badge_Nationality__c) {
				this.fetchPicklistValues(component, 'Exhibitor_Badge__c', 'Nationality__c', 'selectNation');
			}
			if (result.Badge_Age_Bracket__c) {
				this.fetchPicklistValues(component, 'Exhibitor_Badge__c', 'Age_Bracket__c', 'selectAgeBracket');
			}
			if (result.Badge_Country__c) {
				this.fetchPicklistValues(component, 'Exhibitor_Badge__c', 'Country__c', 'selectCountry');
			}
			if (result.Badge_Mobile_Number__c) {
				this.fetchPicklistValues(component, 'Exhibitor_Badge__c', 'Country_Code__c', 'selectCountryCode');
			}
   
		});
		$A.enqueueAction(action);
	},
	getCSV: function (component) {
		let Records = component.get('v.boothAggreResult.exhibitorBadgeList');
		//console.log('Records---'+JSON.stringify(Records));
		var csvStringResult;
		var counter;
		var keys;

		// store ,[comma] in columnDivider variabel for sparate CSV values and 
		// for start next line use '\n' [new line] in lineDivider varaible  
		var columnDivider = ',';
		var lineDivider = '\n';


		// check if "Records" parameter is null, then return from function
		if (Records == null || !Records.length) {
			return null;
		}

		var aggObj = component.get("v.boothAggreResult");

		// in the keys variable store fields API Names as a key 
		// these labels use in CSV file header  
		keys = ['Exhibitor_Name__c', 'First_Name__c', 'Last_Name__c', 'Job_Title__c', 'Address__c', 'City__c', 'Country__c', 'Nationality__c',
			'State__c', 'Status__c', 'Age_Bracket__c', 'Country_Code__c', 'Mobile_Number__c', 'Email__c', 'Opp_Booth_Mapping__c','Is_VIP'];
		var map = {
			'Exhibitor_Name__c': 'Company Name on Badge',
			'First_Name__c': 'First Name',
			'Last_Name__c': 'Last Name',
			'Job_Title__c': 'Job Title',
			'Address__c': 'Address',
			'City__c': 'City',
			'Country__c': 'Country',
			'Nationality__c': 'Nationality',
			'State__c': 'State',
			'Status__c': 'Status',
			'Age_Bracket__c': 'Age Bracket',
			'Country_Code__c': 'Country Code',
			'Mobile_Number__c': 'Mobile Number',
			'Email__c': 'Email',
			'Opp_Booth_Mapping__c': 'Booth Number',
			'Is_VIP':'VIP'			
		};

		csvStringResult = '';
		csvStringResult += keys.join(columnDivider);
		csvStringResult += lineDivider;

		for (var i = 0; i < Records.length; i++) {
			counter = 0;
			csvStringResult += '"' + aggObj.companyName + '",';
			Records[i].Opp_Booth_Mapping__c = Records[i].Opp_Booth_Mapping__r.Booth_Number__c;

			/**CCEN-652 **/
            if(Records[i].Is_VIP__c == true)
            {
                Records[i].Is_VIP = 'Yes';
			}else
			{
				Records[i].Is_VIP = 'No';
			}			
			//console.log('Records[i].ExpocadBooth__c'+Records[i].ExpocadBooth__c);
			for (var sTempkey in keys) {
				var skey = keys[sTempkey];
				if (counter > 0) {
					csvStringResult += columnDivider;
				}
				csvStringResult += '"' + Records[i][skey] + '"';
				counter++;
			} // inner for loop close 
			csvStringResult += lineDivider;
		} // outer main for loop close 

		var FinalcsvStringResult = csvStringResult.split('\n');
		FinalcsvStringResult[0] = '"Company",' + FinalcsvStringResult[0];


		FinalcsvStringResult[0] = FinalcsvStringResult[0].replace(/Exhibitor_Name__c|First_Name__c|Last_Name__c|Job_Title__c|Address__c|City__c|Country__c|Nationality__c|State__c|Status__c|Age_Bracket__c|Country_Code__c|Mobile_Number__c|Email__c|Opp_Booth_Mapping__c|Is_VIP/gi, function (matched) {
			return map[matched];
		});
		FinalcsvStringResult = FinalcsvStringResult.join('\n');
		return FinalcsvStringResult.replace(/undefined|FALSE/gi, '');

	},
	getSingleBadgeHelper: function (component, idStr) {
		component.set("v.isSpinner", true);
		var action = component.get("c.getSingleBadge");
		action.setParams({
			idStr: idStr
		});
		action.setCallback(this, function (res) {
			component.set("v.isSpinner", false);
			if (res.getState() === 'SUCCESS') {
				var objList = res.getReturnValue();
				if (objList.length > 0) {
					component.set("v.selectedBadge", objList[0]);
					if (objList[0].Status__c == 'Approved' || objList[0].Status__c == 'Rejected') {
						component.set("v.isConfirm", false);
					} else {
						component.set("v.isConfirm", true);
					}
				}
			} else {
				console.log(res.getReturnValue());
			}
			component.set("v.isViewDetail", false);
		});
		$A.enqueueAction(action);
	},
	updateExhibitorBadgeFields: function (component) {
		component.set("v.isSpinner", true);
		var action = component.get("c.updateBadgeAllFields");
		action.setParams({
			ebObj: component.get("v.selectedBadge")
		});
		action.setCallback(this, function (res) {
			component.set("v.isSpinner", false);
			if (res.getState() === 'SUCCESS') 
			{
				this.fetchBoothDetail(component);
				//alert('Updated!');
			} else {
				console.log(res.getReturnValue());
			}
			component.set("v.isViewDetail", false);
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
				this.fetchBoothDetail(component);
				//alert(badgeList.length+' Badge(s) are '+status)
			} else {
				console.log(res.getReturnValue());
			}
			component.set("v.isViewDetail", false);
		});
		$A.enqueueAction(action);
	},
	fetchBoothDetail: function (component,hidespinner) {
		if(hidespinner=='No' || !hidespinner)
        {
			component.set("v.isSpinner", true);
        }
		var dynamicCmp = component.find("boothDimensions");
		var boothId = dynamicCmp.get("v.value");
		var boothIds;
		if (boothId) {
			boothIds = [boothId];
		} else {
			boothIds = component.get("v.allBoothIds");
		}
		var action = component.get("c.getBoothAggregate"); //get data from controller
		var eventId = component.get("v.eventId");
		var accountId = component.get("v.accountId");
		var evntCode = component.get("v.eventCode");
		var uType = component.get("v.uType");
		action.setParams({
			eventCode: evntCode,
			accountId: accountId,
			boothIds: boothIds,
			eventId: eventId,
			uType: uType
		});
		action.setCallback(this, function (res) {
			//console.log('Records---'+JSON.stringify(res.getReturnValue()));
			component.set("v.isSpinner", false);
			if (res.getState() === 'SUCCESS') {
				//console.log('Records---'+JSON.stringify(res.getReturnValue()));
				component.set("v.boothAggreResult", res.getReturnValue());
			} else {
				console.log(res.getReturnValue());
			}
		});
		$A.enqueueAction(action);
	},
	fetchBoothLimit: function (component) {
		var action = component.get("c.getBoothSizeLimit"); //get data from controller
		var eventId = component.get("v.eventId");
		action.setParams({
			eventId: eventId
		});
		action.setCallback(this, function (res) {
			component.set("v.boothLimits", res.getReturnValue());
		});
		$A.enqueueAction(action);
	},
	fetchBooths: function (component,hidespinner) {
		var action = component.get("c.getBooths"); //get data from controller
		var accountId = component.get("v.accountId");
		var evntCode = component.get("v.eventCode"); 
		action.setParams({
			eventCode: evntCode,
			accId: accountId
		});
		action.setCallback(this, function (res) {
			//console.log('fetchBooths------'+JSON.stringify(res.getReturnValue()));
			var result = res.getReturnValue();
			component.set("v.allBooths", result);
			var opts = [];
			var boothIds = [];
			opts.push({
				label: '--All Booth--',
				value: ''
			});
			if (result && result.length > 0) 
			{
				for (var i = 0; i < result.length; i++) {
					boothIds.push(result[i].id);
					//	opts.push({label: result[i].displayName+'-'+boothNumber+' - ('+result[i].totArea +' '+result[i].unitType+')', value: result[i].id});
					opts.push({
						label: result[i].displayName + '-' + result[i].boothNumber + ' - (' + result[i].totArea + ' ' + result[i].unitType + ')',
						value: result[i].id
					});
				}
				component.find('boothDimensions').set("v.options", opts);
				component.find('selectBooths').set("v.options", opts);
			}
			component.set("v.allBoothIds", boothIds);
			this.fetchBoothSummary(component, boothIds, "v.boothSummary");
			this.fetchBoothSummary(component, boothIds, "v.allBoothSummary");
			this.fetchBoothDetail(component,hidespinner);
		});
		$A.enqueueAction(action);
	},
	fetchBoothSummary: function (component, boothIds, attribute) {
		var action = component.get("c.getBoothSummary"); //get data from controller
		var evntCode = component.get("v.eventCode");
		var eventId = component.get("v.eventId");
		var uType = component.get("v.uType");
		action.setParams({
			eventCode: evntCode,
			boothIds: boothIds,
			eventId: eventId,
			uType: uType
		});
		action.setCallback(this, function (res) {
			//console.log('fetchBoothSummary------'+JSON.stringify(res.getReturnValue()));
			var result = res.getReturnValue();
			if(res.getState() === 'SUCCESS')
			{
				if (attribute == "v.allBoothSummary") 
				{
				var boothSum = result;
				var newlimit = 0;
				$(".newlimit").each(function () {
					var $this = $(this);
					var lmt = $this.attr("value");
					if (lmt && !isNaN(lmt))
					{
						newlimit += parseInt(lmt);
					} 
				});
				boothSum.totBadges = parseInt(boothSum.totBadgesAllotment) + newlimit;
				boothSum.totBadgesAllotment = boothSum.totBadges;
				component.set("v.allBoothSummary", boothSum);
				} 
				else 
				{
					component.set(attribute, result);
				}
			}
			

			//var newBadge=component.get("v.newBadge");
			// /newBadge.Company_Name_on_Badge__c=res.getReturnValue().accountName;	
			//component.set("v.newBadge",newBadge);
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
					if(result[i].split('__$__')[0]!='None'){
						opts.push({label: result[i].split('__$__')[0], value: result[i].split('__$__')[1]});
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
				///component.set(attribute, opts);// Adding values in Aura attribute variable.
			}
		})
		$A.enqueueAction(action) 
	},
	saveExhBadge: function (component, newBadge) {
		var isSaveandNew = component.get("v.isSaveandNew");
		var evtId = component.get("v.eventId");
        var accId = component.get("v.accountId");
		var action = component.get("c.saveExhibitorBadge"); //get data from controller
		action.setParams({
			exhBadge: newBadge,
			eventId:evtId,
            accountId:accId
		});
		action.setCallback(this, function (res) {
			this.resetForm(component); 
			if(!isSaveandNew){
                document.getElementById('modalCreateBadge').style.display = "none";
                this.fetchBooths(component,'No');
            }
            else{ 
                this.fetchBooths(component,'Yes'); 
            }
            let button = component.find('btnCreateBadge');
			button.set('v.disabled',false); //CCEN-643 
			//console.log('saveExhBadge------'+JSON.stringify(res.getReturnValue()));
		});
		$A.enqueueAction(action);
	},
	saveLimits: function (component, newLimits) {
		var action = component.get("c.increaseBoothBadgeLimit"); //get data from controller
		action.setParams({
			expoBoothsMapping: newLimits
		});
		action.setCallback(this, function (res) {
			//console.log('saveLimits------'+JSON.stringify(res.getReturnValue()));
			this.fetchBooths(component);
			document.getElementById('modalIncreaseLimit').style.display = "none";
		});
		$A.enqueueAction(action);
	},
	resetForm: function (component) {
		component.set("v.newBadge", {
			'Address__c': '',
			'Age_Bracket__c': '',
			'Booth_Size__c': '',
			'City__c': '',
			'Country__c': '',
			'Email__c': '',
			'Event_Edition__c': '',
			'Exhibitor_Name__c': '',
			'First_Name__c': '',
			'Job_Title__c': '',
			'Last_Name__c': '',
			'Country_Code__c': '',
			'Mobile_Number__c': '',
			'Nationality__c': '',
			'State__c': '',
			'Status__c': 'Approved'
		});
	},
	validateBadges : function(component,badge) 
	{		
		var eventSettings =component.get("v.eventSettings");
		var newBadge = badge;
		var exbNameLimit=parseInt(eventSettings.Company_Name_on_Badge_Character_Limit__c);
		var fnameLimit=parseInt(eventSettings.Badge_FName_Character_Limit__c);
		var lnameLimit=parseInt(eventSettings.Badge_LName_Character_Limit__c);
		var jobTitleLimit=parseInt(eventSettings.Badge_JobTitle_Character_Limit__c);
		var cityLimit=parseInt(eventSettings.Badge_City_Character_Limit__c);
		var addLimit=parseInt(eventSettings.Badge_Address_Character_Limit__c);
		var emailLimit=parseInt(eventSettings.Badge_Email_Character_Limit__c);
		var mobLimit=parseInt(eventSettings.Badge_Mobile_Character_Limit__c);

		//var boothLimit =component.get("v.boothBadgeLimits");
		//console.log('newBadge--'+ JSON.stringify(newBadge));
		//console.log('eventSettings--'+ JSON.stringify(eventSettings));
		
		var msg='Valid';
		var rstmsg = '';
		component.set("v.message",rstmsg);
		
		if(eventSettings.Company_Name_on_Badge__c == true && !newBadge.Exhibitor_Name__c)
        {
            msg='Please enter exhibitor name';				
        }
        else if(eventSettings.Company_Name_on_Badge__c == true && ((newBadge.Exhibitor_Name__c).length > exbNameLimit))
        {
            msg='Exhibitor name limit exceed';
        }										
        else if(eventSettings.Badge_First_Name__c == true && !newBadge.First_Name__c)
        {
            msg='Please enter first name';
        }
        else if(eventSettings.Badge_First_Name__c == true && ((newBadge.First_Name__c).length > fnameLimit))
        {				
            msg='First name limit exceed';
        }						
        else if(eventSettings.Badge_Last_Name__c == true && !newBadge.Last_Name__c )
        {
            msg='Please enter last name';
        }
        else if(eventSettings.Badge_Last_Name__c == true && ((newBadge.Last_Name__c).length > lnameLimit))
        {
            msg='Last name limit exceed';
        }				
        else if(eventSettings.Badge_Job_Title__c == true && !newBadge.Job_Title__c)
        {
            msg='Please select job title';
        }
        else if(eventSettings.Badge_Job_Title__c == true && ((newBadge.Job_Title__c).length > jobTitleLimit))
        {
            msg='Job title limit exceed';
        }			
		else if(!newBadge.Nationality__c && eventSettings.Badge_Nationality__c == true)
		{
			msg='Please select nationality';
		}
        else if(!newBadge.Country__c && eventSettings.Badge_Country__c == true)
		{
           msg='Please select country';
		}
		else if(!newBadge.State__c && eventSettings.Badge_State__c == true)
		{
			msg='Please enter state';
		}		
        else if(eventSettings.Badge_City__c == true && !newBadge.City__c)
        {
            msg='Please enter city';
        }
        else if(eventSettings.Badge_City__c == true && ((newBadge.City__c).length > cityLimit))
        {
            msg='City limit exceed';
        }						
        if(eventSettings.Badge_Address__c == true && !newBadge.Address__c)
        {
            msg='Please enter address';
        }
        else if(eventSettings.Badge_Address__c == true && ((newBadge.Address__c).length > addLimit))
        {
            msg='Address limit exceed';
        }						
        else if(eventSettings.Badge_Mobile_Number__c == true && !eventSettings.Badge_Mobile_Number__c)
        {
            msg='Please enter mobile number';
        }
        else if(eventSettings.Badge_Mobile_Number__c == true && ((newBadge.Mobile_Number__c).length > mobLimit))
        {
            msg='Mobile limit exceed';
        }
        else if(eventSettings.Badge_Mobile_Number__c == true && !/^\d+$/.test(newBadge.Mobile_Number__c))
        {
            msg='Please enter numbers only :Mobile Number';
        }							            
        else if(eventSettings.Badge_Email__c == true && !/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,5})+$/.test(newBadge.Email__c))
        {
            msg='Please enter valid email address';        
        }
        else if(eventSettings.Badge_Email__c == true && ((newBadge.Email__c).length > emailLimit))
        {
            msg='Email limit exceed';            
        }				
		else if(!newBadge.Age_Bracket__c && eventSettings.Badge_Age_Bracket__c == true)
		{
			msg='Please select age bracket';
        }
		if(newBadge.Exhibitor_Name__c && eventSettings.Company_Name_on_Badge_ToUpperCase__c)
		{
			newBadge.Exhibitor_Name__c=(newBadge.Exhibitor_Name__c).toUpperCase();
		}
		if(newBadge.First_Name__c && eventSettings.Badge_FName_To_UpperCase__c)
		{
			newBadge.First_Name__c=(newBadge.First_Name__c).toUpperCase();
		}
		if(newBadge.Last_Name__c && eventSettings.Badge_LName_To_UpperCase__c)
		{
			newBadge.Last_Name__c=(newBadge.Last_Name__c).toUpperCase();
        }
        // var allValid = this.validateForm(component);
        // if(allValid != true)
        // {
        //     msg = 'Please fill all required fields !';
        // }        		
        return msg;		
	}
})