({
	scriptsLoaded: function (component) {
		$("#uploadBadgeIframe").attr("src", "/CustomerCenter/apex/c__agentBulkUploadBadges?eventcode=" + component.get("v.eventCode") + "&eventId=" + component.get("v.eventId") + "&accountId=" + component.get("v.accountId") + "&uType=" + component.get("v.uType") + "");
	},
    OnloadData : function(component, event, helper) {
        console.log('accountId ' +component.get("v.accountId"));
		console.log('eventId ' +component.get("v.eventId"));
		console.log('eventCode ' +component.get("v.eventCode"));
		helper.fetchEventSettings(component);
		helper.getUserType(component);
		helper.fetchBadgesStatus(component);
		helper.getTemplateId(component);
		helper.checkFileAttached(component); //BK-9812
	},
	createBadge: function(component, event, helper) {
		var eventId= component.get("v.eventId");
		var accountId= component.get("v.accountId");
		var newBadge=component.get("v.newBadge");
		var agentEEMappingId = component.get("v.badgesStatusMap.eventEditionMappingId");
		var eventSettings =component.get("v.eventSettings");
		newBadge.Event_Edition__c=eventId;
		var exbNameLimit=parseInt(eventSettings.Company_Name_on_Badge_Character_Limit__c);
		var fnameLimit=parseInt(eventSettings.Badge_FName_Character_Limit__c);
		var lnameLimit=parseInt(eventSettings.Badge_LName_Character_Limit__c);
		var jobTitleLimit=parseInt(eventSettings.Badge_JobTitle_Character_Limit__c);
		var cityLimit=parseInt(eventSettings.Badge_City_Character_Limit__c);
		var addLimit=parseInt(eventSettings.Badge_Address_Character_Limit__c);
		var emailLimit=parseInt(eventSettings.Badge_Email_Character_Limit__c);
		var mobLimit=parseInt(eventSettings.Badge_Mobile_Character_Limit__c);
		//var boothLimit =component.get("v.boothBadgeLimits");
		//console.log('boothLimit--'+ JSON.stringify(boothLimit));
		//console.log('newBadge--'+ JSON.stringify(newBadge));
		var totalBadgesAlloted = component.get('v.totalBadges');
		var totalBadgesUsed = component.get('v.badgesStatusMap.submitted');
		var msg='';
		component.set("v.message",msg);
		if(totalBadgesUsed >= totalBadgesAlloted)
		{
			msg='Badges limit reached. 0 out of '+totalBadgesAlloted+' badges are available';
		}
		else if(agentEEMappingId){
			newBadge.AgentEventEditionMapping__c = agentEEMappingId;
		}
		else if(eventSettings.Company_Name_on_Badge__c == true && !newBadge.Account_Name__c)
        {
            msg='Please enter Agent Company name';	 			
        }
        else if(eventSettings.Company_Name_on_Badge__c == true && ((newBadge.Account_Name__c).length > exbNameLimit))
        {
            msg='Agent Company name limit exceeded';
        }										
        else if(eventSettings.Badge_First_Name__c == true && !newBadge.First_Name__c)
        {
            msg='Please enter first name';
        }
        else if(eventSettings.Badge_First_Name__c == true && ((newBadge.First_Name__c).length > fnameLimit))
        {				
            msg='First name limit exceeded';
        }						
        else if(eventSettings.Badge_Last_Name__c == true && !newBadge.Last_Name__c )
        {
            msg='Please enter last name';
        }
        else if(eventSettings.Badge_Last_Name__c == true && ((newBadge.Last_Name__c).length > lnameLimit))
        {
            msg='Last name limit exceeded';
        }				
        else if(eventSettings.Badge_Job_Title__c == true && !newBadge.Job_Title__c)
        {
            msg='Please select job title';
        }
        else if(eventSettings.Badge_Job_Title__c == true && ((newBadge.Job_Title__c).length > jobTitleLimit))
        {
            msg='Job title limit exceeded';
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
            msg='City limit exceeded';
        }						
        if(eventSettings.Badge_Address__c == true && !newBadge.Address__c)
        {
            msg='Please enter address';
        }
        else if(eventSettings.Badge_Address__c == true && ((newBadge.Address__c).length > addLimit))
        {
            msg='Address limit exceeded';
        }						
        else if(eventSettings.Badge_Mobile_Number__c == true && !eventSettings.Badge_Mobile_Number__c)
        {
            msg='Please enter mobile number';
        }
        else if(eventSettings.Badge_Mobile_Number__c == true && ((newBadge.Mobile_Number__c).length > mobLimit))
        {
            msg='Mobile limit exceeded';
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
            msg='Email limit exceeded';            
        }				
		else if(!newBadge.Age_Bracket__c && eventSettings.Badge_Age_Bracket__c == true)
		{
			msg='Please select age bracket';
        }
		if(newBadge.Account_Name__c && eventSettings.Company_Name_on_Badge_ToUpperCase__c)
		{
			newBadge.Account_Name__c=(newBadge.Account_Name__c).toUpperCase();
		}
		if(newBadge.First_Name__c && eventSettings.Badge_FName_To_UpperCase__c)
		{
			newBadge.First_Name__c=(newBadge.First_Name__c).toUpperCase();
		}
		if(newBadge.Last_Name__c && eventSettings.Badge_LName_To_UpperCase__c)
		{
			newBadge.Last_Name__c=(newBadge.Last_Name__c).toUpperCase();
		} 		
		var feildCmp = component.find('newBadgeField');
		if(feildCmp.length)
        {
			var allValid = component.find('newBadgeField').reduce(function (validSoFar, inputCmp) {
				inputCmp.showHelpMessageIfInvalid();
				return validSoFar && inputCmp.get('v.validity').valid;
			}, true);
		}else
		{
			var allValid = feildCmp.get('v.validity').valid;
		}	
        if(allValid && !msg){
        	let button = component.find('btnCreateBadge');
    		button.set('v.disabled',true); //CCEN-643 
        	helper.saveAgentBadge(component,newBadge);	
        }
		else{
			formTab.showToast(component,'error',msg);		
		}		
	},
    showModalBoothLimit: function (component, event, helper) {
		var ifBoothsize = component.get("v.eventSettings.Allotment_By_Booth_Size__c");
		var ifBoothType = component.get("v.eventSettings.Allotment_By_Booth_Type__c");
		if ((ifBoothsize == true) || (ifBoothsize == false) || (ifBoothType == false)) {
			document.getElementById('modalBoothLimit').style.display = "block";
		}
	},
	hideModalBoothLimit: function (component, event, helper) {
		document.getElementById('modalBoothLimit').style.display = "none";
    },
    showModalCreateBadge: function (component, event, helper) {
		component.set('v.newBadge.Account_Name__c',component.get('v.badgesStatusMap.companyName'));
		component.set('v.newBadge.Is_VIP__c',false);
		document.getElementById('modalCreateBadge').style.display = "block";
	},
	hideModalCreateBadge: function (component, event, helper) {
		document.getElementById('modalCreateBadge').style.display = "none";
	},
	showModalImportBadge: function (component, event, helper) {
		document.getElementById('modalImportBadge').style.display = "block";
	},
	hideModalImportBadge: function (component, event, helper) {
		document.getElementById('modalImportBadge').style.display = "none";
	},
	openBadgeEditModal:function(component, event, helper) {
		var badgeId = event.getSource().get("v.value");
		component.set("v.isEditBadge",true);		
		helper.getSingleBadgeHelper(component,badgeId);
	},
	hideBadgeEditModal:function(component, event, helper) {				
		component.set("v.isEditBadge",false);
		component.set("v.isViewDetail",true);
	},
	showBadgeDeleteAlert : function(component, event, helper) {
		component.set("v.selectedBadgeId",event.getSource().get("v.value"));
		document.getElementById('modalBadgeDeleteAlert').style.display = "block";
	},
	hideBadgeDeleteAlert : function(component, event, helper) {
		document.getElementById('modalBadgeDeleteAlert').style.display = "none";
	},
	export:function(component,event,helper){
		var csv = helper.getCSV(component);
		//console.log('csv=='+csv);
         if (csv == null){return;}
        // ####--code for create a temp. <a> html tag [link tag] for download the CSV file--####     
        var hiddenElement = document.createElement('a');
		hiddenElement.href = "data:text/csv;charset=UTF-8,%EF%BB%BF" + encodeURI(csv)  ;
        hiddenElement.target = '_self'; // 
        hiddenElement.download = 'Badges Report.csv';  // CSV file Name* you can change it.[only name not .csv] 
        document.body.appendChild(hiddenElement); // Required for FireFox browser
        hiddenElement.click(); // using click() js function to download csv file
	},
	updateAgentBadge:function(component, event, helper) {
		var editmsg = 	helper.validateBadges(component,component.get("v.selectedBadge"));
		//console.log('editmsg '+editmsg);
		if(editmsg === 'Valid')
		{
			var agentEEMappingId = component.get("v.badgesStatusMap.eventEditionMappingId");
			component.set("v.selectedBadge.AgentEventEditionMapping__c",agentEEMappingId);
			helper.updateExhibitorBadgeFields(component);
			component.set("v.isViewDetail",true);
		}
		else
		{
			formTab.showToast(component,'error',editmsg);
		}
	},
	deleteBadge : function(component, event, helper) {
		component.set("v.isSpinner",true);
		document.getElementById('modalBadgeDeleteAlert').style.display = "none";
		formTab.showSpinner(component);
		var badgeId = component.get("v.selectedBadgeId");
		var action = component.get("c.deleteSelectedBadge");        
		action.setParams({badgeId:badgeId});
        action.setCallback(this, function(res) {
			component.set("v.isSpinner",false);
        	formTab.hideSpinner(component);
            helper.fetchBadgesStatus(component);
        });
        $A.enqueueAction(action);
	},
	goToHome:function(component, event, helper) {
		var url =window.location.href;
		if(url.includes('/s/')){
			window.location.href='/CustomerCenter/s/?eventcode='+component.get("v.eventCode");
		}
		else{
			window.location.href='home?eventcode='+component.get("v.eventCode");
		}
	},  
	//BK-9188
	NavigatetoGESVisit:function(component, event, helper) {

		//var eventcode = component.get("v.eventCode");
		var accountId = component.get("v.accountId"); 
		//var eventId = component.get("v.eventId");
		var eventSettings  = component.get("v.eventSettings");
		var eventcode = eventSettings.Event_Edition__r.Event_Edition_Code__c;
		var visitBaseurl = $A.get("$Label.c.GES_Visit_URL");
		var urlEvent = $A.get("e.force:navigateToURL");
		urlEvent.setParams({
		  "url": visitBaseurl + 'eec=' + eventcode + '&acc=' + accountId 

		});
		urlEvent.fire();
	},
})