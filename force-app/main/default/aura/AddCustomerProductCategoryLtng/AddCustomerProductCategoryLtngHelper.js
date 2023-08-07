({
	fetchEventDetails: function (component) {

		var sEventCode = component.get("v.eventcode"); // Getting values from Aura attribute variable.
		//console.log('sEventCode>>>>>'+sEventCode);
		var action = component.get("c.getEventDetails"); //Calling Apex class controller 'getEventDetails' method
		action.setParams({
			sEventcode: sEventCode
		});
		action.setCallback(this, function (response) {
			var state = response.getState(); //Checking response status
			if (component.isValid() && state === "SUCCESS") {
				var vActive = response.getReturnValue();
				// console.log('fetchEventDetails' + JSON.stringify(response.getReturnValue()));
				//var vale =  response.getReturnValue();
				component.set("v.Event_Setting", response.getReturnValue()); // Adding values in Aura attribute variable.                            
			}
		});
		$A.enqueueAction(action);
		/**/
	},
	fetchPackageInformation: function (component, event) {
		var action1 = component.get("c.packageInformation");
		action1.setParams({
			eventId: component.get("v.eventId"),
			accountId: component.get("v.AccountId"),
			uId: component.get("v.uId"),
			contactId: component.get("v.ContactId"),
			expoId: component.get("v.expoId")
		});
		action1.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {

				//console.log("out value: " + JSON.stringify(response.getReturnValue()));
				component.set("v.totalProdCatCount", response.getReturnValue());
				// for column 3

			} else {
				var errors = response.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
						console.log("Error message: " +
							errors[0].message);
					}
				} else {
					console.log("Unknown error");
				}
			}
		});
		$A.enqueueAction(action1);
	},
	//on init render third column
	fetchSelectedValues: function (component) {
		var selectedValueList = component.get("v.wrapSelectedCheckbox"); // wrapSelectedCheckbox
        var l2List = component.get("v.WrapEEPCMAndchild");
		var wrapperlist = component.get("v.wrapperlist");
		//console.log('wrapperlist--'+JSON.stringify(wrapperlist));
        var firstTime = true;
		for (var index = 0; index < wrapperlist.length; index++) {
			for (var innerIndex = 0; innerIndex < wrapperlist[index].listWrapEEPCMAndchild.length; innerIndex++) {
				for (var InnerInrIndex = 0; InnerInrIndex < wrapperlist[index].listWrapEEPCMAndchild[innerIndex].listWrapEESCMValuesANDCheckbox.length; InnerInrIndex++) {
					if (wrapperlist[index].listWrapEEPCMAndchild[innerIndex].listWrapEESCMValuesANDCheckbox[InnerInrIndex].isFakeL3 == true) {
						if (wrapperlist[index].listWrapEEPCMAndchild[innerIndex].listWrapEESCMValuesANDCheckbox[InnerInrIndex].isFakeL3Checked == true) {
							selectedValueList.push(wrapperlist[index].listWrapEEPCMAndchild[innerIndex].listWrapEESCMValuesANDCheckbox[InnerInrIndex]);
                            if(firstTime ==true){
                                firstTime = false; 
                                //l2List.push(wrapperlist[index].listWrapEEPCMAndchild); itemWrapEEPCMAndchild.EEPCMObj.Id
                                component.set("v.WrapEEPCMAndchild", wrapperlist[index].listWrapEEPCMAndchild);    
								component.find("accordion").set("v.activeSectionName", wrapperlist[index].listWrapEEPCMAndchild[innerIndex].EEPCMObj.Id);
							}
						}
					} else if (wrapperlist[index].listWrapEEPCMAndchild[innerIndex].listWrapEESCMValuesANDCheckbox[InnerInrIndex].isFakeL3 == false && wrapperlist[index].listWrapEEPCMAndchild[innerIndex].listWrapEESCMValuesANDCheckbox[InnerInrIndex].isChecked === true) {
						selectedValueList.push(wrapperlist[index].listWrapEEPCMAndchild[innerIndex].listWrapEESCMValuesANDCheckbox[InnerInrIndex]);
						if(firstTime ==true){
                           	firstTime = false;
                          	//l2List.push(wrapperlist[index].listWrapEEPCMAndchild);
                            component.set("v.WrapEEPCMAndchild", wrapperlist[index].listWrapEEPCMAndchild);    
                        	component.find("accordion").set("v.activeSectionName", wrapperlist[index].listWrapEEPCMAndchild[innerIndex].EEPCMObj.Id);
						}
					}
				}
			}
		}
		component.set("v.wrapSelectedCheckbox", selectedValueList);
		component.set("v.selectedCategories", selectedValueList);

		this.fetchLastModified(component);
        
	},

	uncheckCheckbox: function (component, event, objectSelected) {
		//console.log('objectSelected-' + JSON.stringify(objectSelected));
		var wrapperlist = component.get("v.wrapperlist");
		for (var index = 0; index < wrapperlist.length; index++) {
			// objectSelected.ObjEESCM.Id;
			for (var innerIndex = 0; innerIndex < wrapperlist[index].listWrapEEPCMAndchild.length; innerIndex++) {
				for (var InnerInrIndex = 0; InnerInrIndex < wrapperlist[index].listWrapEEPCMAndchild[innerIndex].listWrapEESCMValuesANDCheckbox.length; InnerInrIndex++) {
					if (objectSelected.isFakeL3 == true && wrapperlist[index].listWrapEEPCMAndchild[innerIndex].listWrapEESCMValuesANDCheckbox[InnerInrIndex].isFakeL3 == true) {
						if (wrapperlist[index].listWrapEEPCMAndchild[innerIndex].listWrapEESCMValuesANDCheckbox[InnerInrIndex].fakeL3Value === objectSelected.fakeL3Value) {
							wrapperlist[index].listWrapEEPCMAndchild[innerIndex].listWrapEESCMValuesANDCheckbox[InnerInrIndex].isFakeL3Checked = false;
							component.set("v.showCol2L3", false);
							component.set("v.showCol2L3", true);
							//console.log('show and hide');
							break;
						}

					} else if (objectSelected.isFakeL3 == false && wrapperlist[index].listWrapEEPCMAndchild[innerIndex].listWrapEESCMValuesANDCheckbox[InnerInrIndex].isFakeL3 == false && wrapperlist[index].listWrapEEPCMAndchild[innerIndex].listWrapEESCMValuesANDCheckbox[InnerInrIndex].ObjEESCM.Id === objectSelected.ObjEESCM.Id) {
						wrapperlist[index].listWrapEEPCMAndchild[innerIndex].listWrapEESCMValuesANDCheckbox[InnerInrIndex].isChecked = false;
						component.set("v.showCol2L3", false);
						component.set("v.showCol2L3", true);
						//console.log('show and hide');
						break;
					}

				}
			}
		}
	},
	saveCick: function (component, event, objectSelected) {
		var selectedList = component.get("v.wrapSelectedCheckbox");
		var totalProdCatCount = component.get("v.totalProdCatCount"); // !$A.util.isEmpty(selectedList) && !$A.util.isEmpty(totalProdCatCount) &&
		//console.log('selectedList-' + selectedList);
		//console.log('totalProdCatCount-' + totalProdCatCount);
		if (!$A.util.isEmpty(selectedList) && !$A.util.isEmpty(totalProdCatCount) && selectedList.length > totalProdCatCount) {
			component.set("v.exceedLimit", true);
		} else {
			component.set("v.exceedLimit", false);
            //console.log('here ======'+JSON.stringify(component.get("v.wrapSelectedCheckbox")));
			var action = component.get("c.saving");
			action.setParams({
				listSelected: JSON.stringify(component.get("v.wrapSelectedCheckbox")), // AccountId  uId  ContactId  eventId  expoId
				accountId: component.get("v.AccountId"),
				eventId: component.get("v.eventId"),
				expoId: component.get("v.expoId")
			});
			action.setCallback(this, function (response) {
				var state = response.getState();
				if (state === "SUCCESS") {
					$('#modalCategory').hide();
					//console.log("From server: " + JSON.stringify(response.getReturnValue()));
					//component.set("v.selectedCategories", selectedList);
					component.set("v.wrapSelectedCheckbox", []);
					component.set("v.selectedCategories", []);
					this.fetchCategoriesData(component,event);
				} else {
					var errors = response.getError();
					if (errors) {
						if (errors[0] && errors[0].message) {
							console.log("Error message: " +
								errors[0].message);
						}
					} else {
						console.log("Unknown error");
					}
				}
			});
			$A.enqueueAction(action);
		}
	},
	changeL1Css: function (component, event, indexVar) {
		//console.log('change css');
		var elements = component.find('testli');
		for (var i = 0; i < elements.length; i++) {
			var val = elements[i].getElement().getAttribute('data-index');

			if (val != indexVar) {
				$A.util.removeClass(elements[i], "SelectL1");
			} else {
				$A.util.addClass(elements[i], "SelectL1");
			}
		}

	},
	deleteSelectedCategories: function (component,catId,subCatId,Refresh) {
		var action = component.get("c.deleteCategories"); //Calling Apex class controller 'getEventDetails' method
		action.setParams({
			catId:catId,
			subCatId: subCatId
		});
		action.setCallback(this, function (response) {
			var state = response.getState(); //Checking response status
			if (component.isValid() && state === "SUCCESS") {
				var result = response.getReturnValue();    
				//console.log(result);				
				if(Refresh)
				{	
					component.set("v.wrapSelectedCheckbox",[]);
					this.fetchCategoriesData(component);
				}
			}
		});
		$A.enqueueAction(action);
	},
	fetchCategoriesData: function (component) {
		var action = component.get("c.fetchClassValue");
		// console.log('eventId ======='+component.get("v.eventId"));
		// console.log('eventcode ======='+component.get("v.eventcode"));
		// console.log('expoId ======='+component.get("v.expoId"));
		// console.log('AccountId ======='+component.get("v.AccountId"));
		// console.log('uId ======='+component.get("v.uId"));
		// console.log('ContactId ======='+component.get("v.ContactId"));
		action.setParams({
			eventId: component.get("v.eventId"),
			accountId: component.get("v.AccountId"),
			uId: component.get("v.uId"),
			contactId: component.get("v.ContactId"),
			expoId: component.get("v.expoId")
		});
		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				//console.log("From server: " + JSON.stringify(response.getReturnValue()));
				component.set("v.wrapperlist", response.getReturnValue());
				// for column 3
				this.fetchSelectedValues(component);
			} else {
				var errors = response.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
						console.log("Error message: " +
							errors[0].message);
					}
				} else {
					console.log("Unknown error");
				}
			}
		});
		$A.enqueueAction(action);
	},
	fetchLastModified: function(component)
	{
		var action = component.get("c.fetchLastModifiedofUser");
		//console.log('eventId ' +component.get("v.eventId"));
		//console.log('AccountId ' +component.get("v.AccountId"));
		//console.log('expoId ' +component.get("v.expoId"));
		action.setParams({
			eventId: component.get("v.eventId"),
			accountId: component.get("v.AccountId"),
			expoId: component.get("v.expoId")
		});
		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") 
			{
				//console.log("From server123: " + JSON.stringify(response.getReturnValue()));
				var userId = $A.get("$SObjectType.CurrentUser.Id");
				console.log('userId'+JSON.stringify(userId));
				component.set('v.currentUserId', userId);
				var result = response.getReturnValue();

				if(result && result !='')
				{
					component.set("v.lastModifiedByDate", result[0].LastModifiedDate);
					component.set('v.lastModifiedByName', result[0].LastModifiedBy.Name);
					component.set("v.contactName", result[0].LastModifiedBy.ContactId);
					component.set("v.lastModifiedUserId", result[0].LastModifiedBy.Id);
				}
				else
				{
					component.set("v.lastModifiedByDate", '');
					component.set('v.lastModifiedByName', '');
					component.set("v.contactName", '');
				}
				
			} 
			else 
			{
				var errors = response.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
						console.log("Error message: " +
							errors[0].message);
					}
				} else {
					console.log("Unknown error");
				}
			}
		});
		$A.enqueueAction(action);
	}

})