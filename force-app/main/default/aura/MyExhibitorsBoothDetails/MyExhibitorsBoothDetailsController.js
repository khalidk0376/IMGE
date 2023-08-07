({
	scriptsLoaded: function (component, event, helper) {
		$("#btnSave").attr("disabled", "disabled");
		$(document).ready(function () {
			var acc = document.getElementsByClassName("accordion");
			var i;
			for (i = 0; i < acc.length; i++) {
				acc[i].addEventListener("click", function () {
					component.set("v.message", "");
					this.classList.toggle("active");
					var panel = this.nextElementSibling;
					if (panel.style.maxHeight) {
						panel.style.maxHeight = null;
					} else {
						panel.style.maxHeight = panel.scrollHeight + "px";
					}
				});
			}
		});
		// $('#modalViewManualPdf').show();
	},
	cartOnloadData: function (component, event, helper) {
		console.clear();
        component.set("v.eventcode",helper.getUrlParameter(component,'eventcode'));
		component.set("v.mapid",helper.getUrlParameter(component,'mapid'));
		//component.set("v.accountId",helper.getUrlParameter(component,'accId'));
		helper.fetchEventDetails(component);
		helper.fetchBoothMap(component);
		helper.fetchOpenSides(component);
		helper.fetchUploadAttType(component);		
		component.set("v.styleborder", ""); // Adding values in Aura attribute variable.
	},
	showSpinner: function (component, event, helper) {
        // Commented below lines as per ticket BK-1762
		//if(!component.get("v.disableSpinner")) //to Disable Default Spinner when required
		//{
		//	component.set("v.Spinner", true); // Adding values in Aura attribute variable.
		//	
		//}
	},
	hideSpinner: function (component, event, helper) {
        // Commented below lines as per ticket BK-1762
		//component.set("v.Spinner", false); // Adding values in Aura attribute variable.
		//window.setTimeout(
		//	$A.getCallback(function() {
				//console.log('disableSpinner');
			//	component.set("v.disableSpinner", false);// Enable Defalut Spinner after a Sec delay.
			//}), 1500
		//);		 
	},
	readManuals: function (component, event, helper) {
		var sEventCode = component.get("v.eventcode"); // Getting values from Aura attribute variable.
		document.location = 'manuals?eventcode=' + sEventCode;
	},
	saveStandDetails: function (component, event, helper) {
		var standmap = component.get("v.exhibitorDtls"); // Getting values from Aura attribute variable.		
		var standDetails = component.get("v.standDetail"); // Getting values from Aura attribute variable.
        var erlDateTime = standDetails.Early_Access_Date_Time__c;
        var reqErlyAcces = standDetails.Require_Early_Access__c;
		var mid = component.get("v.mapid");
		var IsRigging = standDetails.IsRigging__c;
        console.log('erlDateTime'+erlDateTime);
        console.log('reqErlyAcces'+reqErlyAcces);           
       	if(erlDateTime==undefined)
        {
            erlDateTime='';
        }
        standDetails.Event_Edition__c = standmap.Event_Edition__c;
		standDetails.Opp_Booth_Mapping__c = standmap.Opp_Booth_Mapping__c;
		standDetails.Booth_Detail_Status__c = 'Submitted';
		standDetails.BoothContractorMapping__c = mid;

		standDetails.StandHeightNew = standDetails.StandHeight + standDetails.StandHeightDecimal;
		standDetails.RiggingHeightNew = standDetails.RiggingHeight + standDetails.RiggingHeightDecimal;
		
		var eventSettings = component.get("v.Event_Setting");
		var maxStandHeight = 1000;
		var maxRiggingHeight = 1000;
		if (eventSettings)
		{
			maxStandHeight = eventSettings.Cont_MyExhibitor_Detail_Tab_2_Max_Stand__c + eventSettings.Max_Stand_Height_Decimal__c;
			maxRiggingHeight = eventSettings.Cont_MyExhibitor_Detail_Tab2_Max_Rigging__c + eventSettings.Max_Rigging_Height_Decimal__c;
		}
		// console.log('maxStandHeight'+maxStandHeight);
		// console.log('maxRiggingHeight'+maxRiggingHeight); 
		if(standmap.Agent_Contact__r)
		{
			standDetails.Event_Edition__c=eventSettings.Event_Edition__c;
			standDetails.Agent_Account__c=standmap.Agent_Contact__r.AccountId;
		}		
		//console.log('dsdsds---'+JSON.stringify(standDetails));
		
		component.set("v.standDetail", standDetails); // Adding values in Aura attribute variable.
		
		if (parseFloat(standDetails.StandHeightNew) > parseFloat(maxStandHeight))
		{
			component.set("v.message", "Maximum stand height is : " + maxStandHeight + "m");
		} else if (parseFloat(standDetails.RiggingHeightNew) > parseFloat(maxRiggingHeight))
		{
			component.set("v.message", "Maximum rigging height is : " + maxRiggingHeight + "m");
       	}
         else if(reqErlyAcces==true && erlDateTime=='')
        {
            document.getElementById("requiredCheck").style.display = "none";
            document.getElementById("requireEarlyCheck").style.display = "block";
        }
          else if(reqErlyAcces==false && erlDateTime!='')
        {
            document.getElementById("requireEarlyCheck").style.display = "none";
            document.getElementById("requiredCheck").style.display = "block";
        }
        else {
          helper.saveStandDtls(component, event, helper);
		}

	},
	showSection: function (component, event) {
		component.set("v.message", "");
		var tabid = event.currentTarget.id;
		$(".section").each(function () {
			var $this = $(this);
			var id = $this.attr("id");
			if (id.indexOf(tabid) >= 0) {
				$('#' + id).show();
				var idLi = id.replace('div', '');
				$('#' + idLi).addClass("changecolor");
			} else {
				$('#' + id).hide();
				var idLi = id.replace('div', '');
				$('#' + idLi).removeClass("changecolor");
			}
		});
	},
	isRiggingChange: function (component, event) {
		var isRigging = event.currentTarget.value;
		//debugger;
		if (isRigging == "true") {
			component.set("v.NoRigging", "false");
		} else {
			component.set("v.NoRigging", "true");
			component.set("v.standDetail.RiggingHeight", '');
			component.set("v.standDetail.RiggingHeightDecimal", '');
		}
		var standDetails = component.get("v.standDetail"); // Getting values from Aura attribute variable.
		standDetails.IsRigging__c = isRigging;
		component.set("v.standDetail", standDetails); // Adding values in Aura attribute variable.
	},
	isDoubleDeckerChange: function (component, event) {
		var isDoubleDecker = event.currentTarget.value;
		var standDetails = component.get("v.standDetail"); // Getting values from Aura attribute variable.
		standDetails.IsDoubleDecker__c = isDoubleDecker;
		component.set("v.standDetail", standDetails); // Adding values in Aura attribute variable.
		//console.log(isRigging);
	},
	isheavyMachineChange: function (component, event) {
		var isHeavyMachine = event.currentTarget.value;
		var standDetails = component.get("v.standDetail"); // Getting values from Aura attribute variable.
		standDetails.Is_Heavy_Machinery__c = isHeavyMachine;
		component.set("v.standDetail", standDetails); // Adding values in Aura attribute variable.
	},
	isVehiclesChange: function (component, event) {
		var isVehicle = event.currentTarget.value;
		var standDetails = component.get("v.standDetail"); // Getting values from Aura attribute variable.
		standDetails.Is_Vehicles__c = isVehicle;
		component.set("v.standDetail", standDetails); // Adding values in Aura attribute variable.
	},
    requireErlyAcces:function (component, event){
        var isErlyRequiredAc = event.currentTarget.value;
		var standDetails = component.get("v.standDetail"); // Getting values from Aura attribute variable.
		standDetails.Require_Early_Access__c = isErlyRequiredAc;
		component.set("v.standDetail", standDetails); // Adding values in Aura attribute variable.
    },
	showmodalfiletype: function (component, event, helper) {		
		var desgintype = event.currentTarget.getAttribute("data-type");
		var title = 'Upload your ' + desgintype + ' Stand Design';
		component.set("v.uploadTitle", title); // Adding upload Title For UploadModel.
		component.set("v.designtype", desgintype); // Adding values in Aura attribute variable.
		helper.setUploadAttType(component);	
		component.set("v.disableSpinner", true);
		helper.fetchEventDetails(component);
		$('#modalfiletype').show();	
		//console.log('showmodalfiletype'+component.get("v.designtype"));
	},
	hidemodalfiletype: function (component, event, helper) {
		//component.set("v.message", " ");
		$('#modalfiletype').hide();
	},
	saveAttcahment: function (component, event, helper) {
		var fileInput = component.find("inputFile").getElement();	
		var evntStng = component.get("v.Event_Setting");
        var uploadlimit = 10;
            if(evntStng && evntStng.Stand_Design_limit__c)
            {
                uploadlimit = evntStng.Stand_Design_limit__c;
            }
		var standDesign = component.get("v.standDesign.DesignAttachmentTypes__r");
		var standDesignlength ;
		if(standDesign){
			standDesignlength = standDesign.length; 	
		}else
		{
			standDesignlength = 0;
		}
		if (fileInput.files.length > 0)
		{
			if(uploadlimit > standDesignlength)
			{
				if (helper.checkFile(component, 'inputFile')) {
					if (component.get("v.uploadfiletype")) {
						helper.checkStandDesign(component, event);
						//helper.uploadHelper(component, event,component.get("v.designtype"),'inputFile');
					} else {
						component.set("v.message", "Please select stand design attachment type.");
					}
				} else {
					component.set("v.message", "Please upload pdf file.");
				}
			
			}else {
				component.set("v.message", "you have already reached maximum upload limit : "+uploadlimit);
			}
		} else {
			component.set("v.message", "Please select file to upload.");
		}
	},
	handleFilesChange: function (component, event, helper) {
		var fileName = 'No File Selected..';
		if (event.getSource().get("v.files").length > 0) {
			fileName = event.getSource().get("v.files")[0]['name'];
		}
		component.set("v.fileName", fileName); // Adding values in Aura attribute variable.
	},
	getuploadfiletype: function (component, event, helper) {
		var uploadfiletype = event.currentTarget.value;
		//console.log('uploadfiletype>>'+uploadfiletype);
		component.set("v.uploadfiletype", uploadfiletype); // Adding values in Aura attribute variable.
	},
	handleFilesChangeNonComplex: function (component, event, helper) {
		if (helper.checkFile(component, 'noncomplex')) {
			//console.log('handleFilesChangeNonComplex');
			helper.uploadHelper(component, event, 'Non Complex', 'noncomplex');
		} else {
			alert('Please upload pdf file.');
		}
	},
	handleFilesChangeComplex1: function (component, event, helper) {
		if (helper.checkFile(component, 'complex1')) {
			helper.uploadHelper(component, event, 'Complex Stand 1', 'complex1');
		} else {
			alert('Please upload pdf file.');
		}
	},
	handleFilesChangeComplex2: function (component, event, helper) {
		if (helper.checkFile(component, 'complex2')) {
			helper.uploadHelper(component, event, 'Complex Stand 2', 'complex2');
		} else {
			alert('Please upload pdf file.');
		}
	},
	submitforApproval: function (component, event, helper) {
		//console.log('submitforApproval');
		var standDesign = component.get("v.standDesign"); // Getting values from Aura attribute variable.
		standDesign.Booth_Design_Status__c = 'Pending Review';
		standDesign.Booth_Design_Submitted_On__c = new Date();
		component.set("v.standDesign", standDesign); // Adding values in Aura attribute variable.
		helper.updateBoothDesign(component);
		$('#modalconfirmDesign').hide();
	},
	agreeAgreement: function (component, event, helper) {
		var mapDetails = component.get("v.standDesign"); // Getting values from Aura attribute variable.
		var Event_Setting = component.get("v.Event_Setting"); // Getting values from Aura attribute variable.
		console.log(Event_Setting.Is_Cont_MyExh_Tab_4_Signature_Visible__c);
		if (mapDetails.Signatory_Name__c || ! Event_Setting.Is_Cont_MyExh_Tab_4_Signature_Visible__c ) {
			helper.updateBoothDesign(component);
		} else {
			component.set("v.message", "Signatory Name Required.");
		}
	},
	agreeAgreementchange: function (component, event, helper) {
		//console.log('check!');
		var mapDetails = component.get("v.standDesign"); // Getting values from Aura attribute variable.
		var checked = document.getElementById("checkboxAgree").checked;
		//console.log(checked);
		if (checked == true) {
			mapDetails.Contractor_Agreement_CA__c = true;
			console.log(mapDetails.Contractor_Agreement_CA__c);
		} else {
			mapDetails.Contractor_Agreement_CA__c = false;
			console.log(mapDetails.Contractor_Agreement_CA__c);
		}
		component.set("v.standDesign", mapDetails); // Adding values in Aura attribute variable.
	},
	removeFile: function (component, event, helper) {
		var attId = event.currentTarget.getAttribute("data-aid");
		var standDesignRecID = event.currentTarget.getAttribute("data-sid");
		helper.deleteDesginFile(component, attId, standDesignRecID);
	},
	changeOpenSides: function (component, event, helper) {
		var openside = event.currentTarget.getAttribute("id");
		var standDetails = component.get("v.standDetail"); // Getting values from Aura attribute variable.
		standDetails.Open_Side__c = openside;
		component.set("v.standDetail", standDetails); // Adding values in Aura attribute variable.	
	},
	hidemodalconfirmDesign: function (component, event, helper) {
		$('#modalconfirmDesign').hide();
	},
	showmodalconfirmDesign: function (component, event, helper) {
		$('#modalconfirmDesign').show();
	},
	// open pop up  of manualpdf
	showModalViewManualPdf: function (component, event, helper) {
		var target = event.target;
		var indexNo = target.getAttribute("data-selected-Index");
		var arr = component.get("v.reqManualslist");
		if (!$A.util.isEmpty(indexNo)) {
			component.set("v.manualIndexNo", indexNo);
		}
		if (!$A.util.isEmpty(indexNo) && !$A.util.isEmpty(arr)) {
			// modify by Aishwarya BK-4682 on 09-06-2020
			if (!$A.util.isEmpty(arr[indexNo].Manual_Permission__r.Manuals__r.Uploaded_Attachment_Id__c)) {
				if (arr[indexNo].Is_Agree__c) {
					$("#btnSave").attr("disabled", "disabled");
				}
				var attId = arr[indexNo].Manual_Permission__r.Manuals__r.Uploaded_Attachment_Id__c.toString();
				//var fileid = attId.match(/00P/);
				if(attId.match(/00P/)){
					component.set("v.checkAttachment", true);
				}
				else{
					component.set("v.checkAttachment", false);
				}
				console.log('checking attachment'+component.get("v.checkAttachment"));
				component.set("v.manualContentId", arr[indexNo].Manual_Permission__r.Manuals__r.Content_Version_Id__c);
				component.set("v.manualAttachmentId", arr[indexNo].Manual_Permission__r.Manuals__r.Uploaded_Attachment_Id__c);
				component.set("v.manualAttachmentName", arr[indexNo].Manual_Permission__r.Manuals__r.Uploaded_Attachment_Name__c);
				var manualAction={Id: arr[indexNo].Id,Is_Viewed__c:true};
				if ((arr[indexNo].Manual_Permission__r.Manuals__r.Allow_Submit_After_Deadline__c == false) && ($A.localizationService.formatDate(new Date(), "YYYY-MM-DD") > arr[indexNo].Manual_Permission__r.Manuals__r.Deadline__c)) {
					//
				}
				else if(!arr[indexNo].Is_Viewed__c){
					helper.updateUsrManualAct(component, event,manualAction,indexNo);
				}
				$('#modalViewManualPdf').show();
			}
			if ((arr[indexNo].Manual_Permission__r.Manuals__r.Allow_Submit_After_Deadline__c == true) && ($A.localizationService.formatDate(new Date(), "YYYY-MM-DD") > arr[indexNo].Manual_Permission__r.Manuals__r.Deadline__c)) {
				component.set("v.expiredManual", false);
				if (arr[indexNo].Is_Agree__c) {
					component.set("v.selManualAgree", true);
				} else {
					component.set("v.selManualAgree", false);
				}
			} else if ((arr[indexNo].Manual_Permission__r.Manuals__r.Allow_Submit_After_Deadline__c == false) && ($A.localizationService.formatDate(new Date(), "YYYY-MM-DD") > arr[indexNo].Manual_Permission__r.Manuals__r.Deadline__c)) {
				component.set("v.expiredManual", true);
			}
		}
	},
	agreeContentCheckBox: function (component, event, helper) {
		if($("#agreeContent").prop("checked")){
			$("#btnSave").removeAttr("disabled");         
		}
		else{
			$("#btnSave").attr("disabled", "disabled");
		}
	},
	agreeContentSaveBtn: function (component, event, helper) {
		var manualIndexNo = component.get("v.manualIndexNo");
		var arr = component.get("v.reqManualslist");
		var manualAction={Id: arr[manualIndexNo].Id,Is_Agree__c:true};
		helper.updateUsrManualAct(component, event,manualAction,manualIndexNo);
	},
	hideModalViewManualPdf: function (component, event, helper) {
		$('#modalViewManualPdf').hide();
	},
    handleChange:  function (component, event, helper) {
        var BtnID= event.currentTarget.id;
        if(BtnID==='requireEarlyAccessYes')
        {
             component.set("v.disDateTime", false);
             component.set("v.standDetail.Require_Early_Access__c", true);
        }
       	else if(BtnID==='requireEarlyAccessNo')
        {
            component.set("v.disDateTime", true);
            component.set("v.standDetail.Require_Early_Access__c", false);
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
	},
    	goToStandContractor:function(component, event, helper) {
        var url =window.location.href;
        let eventcode = component.get('v.eventcode');
		if(url.includes('/s/')){
			window.location.href='/CustomerCenter/s/standcontractors?eventcode='+eventcode;
		}
		else{
			window.location.href='standcontractor?eventcode='+eventcode;
		}
	},
    goToMyExhibitors:function(component, event, helper) {
        var url =window.location.href;
        let eventcode = component.get('v.eventcode');
		if(url.includes('/s/')){
			window.location.href='/CustomerCenter/s/myexhibitors?eventcode='+eventcode;
		}
		else{
			window.location.href='MyExhibitors?eventcode='+eventcode;
		}
	}
})