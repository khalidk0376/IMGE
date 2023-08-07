({
	onInit: function (component, event, helper) {
		helper.fetchPackageInformation(component, event);
		helper.fetchEventDetails(component,event);
		helper.fetchCategoriesData(component,event);
		// console.log('eventId ======='+component.get("v.eventId"));
		// console.log('eventcode ======='+component.get("v.eventcode"));
		// console.log('expoId ======='+component.get("v.expoId"));
		// console.log('AccountId ======='+component.get("v.AccountId"));
		// console.log('uId ======='+component.get("v.uId"));
		// console.log('ContactId ======='+component.get("v.ContactId"));
	},
	// L1Clicked: function (component, event, helper) {
	// 	console.log('L1Clicked');

	// },
	// set event edition on cmp attribute 
	L1ClickedHtml: function (component, event, helper) {
		//console.log('L1ClickedL1ClickedHtml');
		var target = event.target;
		var indexVar = target.getAttribute("data-index");
		var dataEle = target.getAttribute("data-selected-item");
		helper.changeL1Css(component, event, indexVar);
		//console.log('indexVar-' + indexVar);
		//console.log('dataEle-' + JSON.stringify(dataEle));
		var wrapperlistCmp = component.get("v.wrapperlist");
		//console.log('dataEle-' + JSON.stringify(wrapperlistCmp[indexVar]));
		//console.log(' wrapperlistCmp[indexVar].listWrapEEPCMAndchild-' + JSON.stringify( wrapperlistCmp[indexVar].listWrapEEPCMAndchild));
		component.set("v.WrapEEPCMAndchild", wrapperlistCmp[indexVar].listWrapEEPCMAndchild);
	},
	showSpinner: function (component, event, helper) {
		component.set("v.Spinner", true); // Adding values in Aura attribute variable.
	},
	hideSpinner: function (component, event, helper) {
		component.set("v.Spinner", false); // Adding values in Aura attribute variable.
	},
	setScriptLoaded: function (component, event, helper) {
		//console.log('seyscriptloaded');
		// $('#modalfiletype').show();
	},
	openPopUp: function (component, event, helper) { 
		//$('#modalCategory').show();
		document.getElementById("modalCategory").style.display = "block";
	},
	hidemodalCategory: function (component, event, helper) {
		//$('#modalCategory').hide();
		document.getElementById("modalCategory").style.display = "none";
	},
	handleSectionToggle: function (component, event, helper) {
		//console.log('sectionToggle index-' + event.getSource().get("v.name"));
	},
	// fetch l3
	l2EEProdCatMapgClick: function (component, event, helper) {
		function isIE() {
			var ua = navigator.userAgent;
			/* MSIE used to detect old browsers and Trident used to newer ones*/
			var is_ie = ua.indexOf("MSIE ") > -1 || ua.indexOf("Trident/") > -1;
			
			return is_ie; 
		}
		var target;
		if (isIE()){
			//console.log('it is internet explorer');
			target = event.currentTarget;
		}
		else{
			//console.log('it is not internet explorer');
			target = event.target;
		}
		
		var idInnerSpan = target.getAttribute("data-idSpan");
		if (idInnerSpan === 'innerSpan') {

		} else {
			//console.log('L2 clicked ');
			var LTwoEEProdCatMapgId = target.getAttribute("data-LTwoEEProdCatMapgId");
			//var LTwoEEProdCatMapgId = document.getElementById("LTwoEEProdCatMapgId").getAttribute('data-LTwoEEProdCatMapgId');
			//console.log('LTwoEEProdCatMapgId-' + LTwoEEProdCatMapgId);
			var pcmIndex = target.getAttribute("data-indexValue");
			//var pcmIndex = document.getElementById("LTwoEEProdCatMapgId").getAttribute('data-indexValue');
			//console.log('pcmIndex-' + pcmIndex);
			var listpcm = component.get("v.WrapEEPCMAndchild");
			//console.log('pcm clicked-' + JSON.stringify(listpcm[pcmIndex]));
			component.set("v.WrapEESCMValuesANDCheckbox", listpcm[pcmIndex].listWrapEESCMValuesANDCheckbox);
			component.set("v.showCol2L3", true);
			// if l2 dont have l3 , WrapEEPCMAndchild have empty listWrapEESCMValuesANDCheckbox	
			var listWrapEESCMValuesANDCheckbox = component.get("v.WrapEESCMValuesANDCheckbox");
			/*
			isTrue="{!v.showFakeL3}">
			 isFakeL3  isFakeL3Checked 
			*/
			if (listWrapEESCMValuesANDCheckbox.length === 0) {
				//console.log('show fake L3');
				component.set("v.showFakeL3", true);
			}
		}
	},

	checkBoxClicked: function (component, event, helper) {
		//console.log('checkBoxClicked-');
		var indexNo = event.getSource().get("v.name"); // id of eescm		
		var listCurrentWrapL3 = component.get("v.WrapEESCMValuesANDCheckbox");
		var scmObj = listCurrentWrapL3[indexNo];

		//console.log('indexNo-' + indexNo);
		//console.log('scmObj-' + JSON.stringify(scmObj));
		var dublicateSelected = false;
		//  add object to select list 
		var listSelected = component.get("v.wrapSelectedCheckbox");
		//console.log('listSelected-' + JSON.stringify(listSelected));
		//console.log('scmObj.isChecked-' + JSON.stringify(scmObj.isChecked));
		if ((scmObj.isFakeL3 == false && scmObj.isChecked == true) || (scmObj.isFakeL3 == true && scmObj.isFakeL3Checked == true)) {
			if (listSelected.length > 0) {
				//console.log('length-' + listSelected.length);
				for (var index = 0; index < listSelected.length; index++) {
					// avoid dublicate object  in selected list
					if (scmObj.isFakeL3 === true && listSelected[index].isFakeL3 === true) {
						if (listSelected[index].fakeL3Value === scmObj.fakeL3Value) {
							dublicateSelected = true;
							break;
						}
					} else if (scmObj.isFakeL3 == false && listSelected[index].isFakeL3 == false && scmObj.ObjEESCM.Id === listSelected[index].ObjEESCM.Id) {
						dublicateSelected = true;
						break;
					}
				}
				if (dublicateSelected === false) {
					listSelected.push(scmObj);
					component.set("v.col3Show", false);
					component.set("v.wrapSelectedCheckbox", listSelected);
					//console.log('component.get("v.wrapSelectedCheckbox")-' + component.get("v.wrapSelectedCheckbox"));
					if (listSelected.length > 0) {
						component.set("v.col3Show", true);
					}
				}


			} else { // in case wrapSelectedCheckbox list has no value
				listSelected.push(scmObj);
				component.set("v.col3Show", false);
				component.set("v.wrapSelectedCheckbox", listSelected);
				//console.log('component.get("v.wrapSelectedCheckbox")-' + JSON.stringify(component.get("v.wrapSelectedCheckbox")));
				//console.log('listSelected.length-' + listSelected.length);
				if (listSelected.length > 0) {
					component.set("v.col3Show", true);
				}
			}
		}
		//console.log('145');
		// if the check box is unchecked ,remove element from selected list 
		if ((scmObj.isFakeL3 == false && scmObj.isChecked == false) || (scmObj.isFakeL3 == true && scmObj.isFakeL3Checked == false)) {
			//console.log('148 listSelected.length-' + listSelected.length);
			for (var index = 0; index < listSelected.length; index++) {
				// avoid dublicate in selected list  
				if (scmObj.isFakeL3 == true && listSelected[index].isFakeL3 == true) {
					//console.log('152');
					if (scmObj.fakeL3Value == listSelected[index].fakeL3Value) {
						//console.log('154');
						listSelected.splice(index, 1);
						component.set("v.wrapSelectedCheckbox", listSelected);
					}
				} else if (scmObj.isFakeL3 == false && listSelected[index].isFakeL3 == false && scmObj.ObjEESCM.Id === listSelected[index].ObjEESCM.Id) {
					//console.log(' 159 removing element listSelected.length -' + listSelected.length);

					listSelected.splice(index, 1);
					// component.set("v.col3Show", false);
					component.set("v.wrapSelectedCheckbox", listSelected);
					//console.log('after removing element listSelected.length -' + listSelected.length);
					// component.set("v.col3Show", true);
				}
				//console.log('167');
			}
		}
		//component.set("v.selectedCategories", listSelected);
	},
	fakeL3Clicked: function (component, event, helper) {
		//console.log('fakeL3Clicked');

	},
	removeSelectedCheckbox: function (component, event, helper) {
		//console.log('removeSelectedCheckbox');
		// wrapSelectedCheckbox  data-indexValue
		var listSelected = component.get("v.wrapSelectedCheckbox");
		var target = event.target;
		var indexNo = target.getAttribute("data-indexValue");
		var objectSelected = listSelected[indexNo];
		listSelected.splice(indexNo, 1);
		component.set("v.wrapSelectedCheckbox", listSelected);
		helper.uncheckCheckbox(component, event, objectSelected);
		var catId = target.getAttribute("data-catId");
		var subCatId = target.getAttribute("data-subCatId");
		if(catId || subCatId)
		{
			var listSelectedCat = component.get("v.selectedCategories");
			//listSelectedCat.splice(indexNo, 1);
			component.set("v.selectedCategories", listSelectedCat);
			helper.deleteSelectedCategories(component, catId,subCatId,false);
		}
	},
	removeSelectedCategories: function (component, event, helper) {
		var listSelected = component.get("v.selectedCategories");
		var target = event.target;
		var indexNo = target.getAttribute("data-indexValue");
		var catId = target.getAttribute("data-catId");
		var subCatId = target.getAttribute("data-subCatId");
		var objectSelected = listSelected[indexNo];
		//listSelected.splice(indexNo, 1);
		component.set("v.selectedCategories", listSelected);
		var listSelectedCat = component.get("v.wrapSelectedCheckbox");
		//listSelectedCat.splice(indexNo, 1);
		component.set("v.wrapSelectedCheckbox", listSelectedCat);
		if(catId || subCatId)
		{
			helper.deleteSelectedCategories(component, catId,subCatId,true);
		}
		helper.uncheckCheckbox(component, event, objectSelected);
	},
	saveClicked: function (component, event, helper) {
		//helper.saveCick(component, event);
		helper.checkAndSave(component);
	},
	cancelClicked: function (component, event, helper) {
		$('#modalfiletype').hide();
	},

})