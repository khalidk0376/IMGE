({	
	scriptsLoaded: function(component) {
		$("#uploadBadgeIframe").attr("src", "/CustomerCenter/apex/c__uploadBadges?eventcode="+component.get("v.eventCode")+"&eventId="+component.get("v.eventId")+"&accountId="+component.get("v.accountId")+"");
	},
	OnloadData : function(component, event, helper) {
		var eventcode = helper.getUrlParameter(component,'eventcode'); // get eventcode from Url
		if(eventcode)
		{	
			component.set("v.eventCode",eventcode);
		}
		
		helper.fetchBoothLimit(component);
		helper.fetchBooths(component);
		helper.fetchEventSettings(component);
		helper.getTemplateId(component);
		helper.getUserType(component); 
		helper.checkFileAttached(component); // BK-9812
		//helper.med2medDetails(component);
	},
	openModal:function(component, event, helper) {
		component.set("v.isViewDetail",true);
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
	hideModal:function(component, event, helper) {
		component.set("v.isViewDetail",false);
	},
	confirmEdit:function(component, event, helper) {
		component.set("v.isConfirm",true);
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
	updateExhibitorBadge:function(component, event, helper) {
		// if(helper.validateForm(component)){
		// 	var accountId= component.get("v.accountId");
		// 	component.set("v.selectedBadge.Account__c",accountId);
		// 	helper.updateExhibitorBadgeFields(component);
		// 	component.set("v.isViewDetail",true);
		// }
		// else
		// {
		// 	formTab.showToast(component,'error','Please fill all required fields');
		// }
		var editmsg = 	helper.validateBadges(component,component.get("v.selectedBadge"));
		//console.log('editmsg '+editmsg);
		if(editmsg === 'Valid')
		{
			var accountId= component.get("v.accountId");
			component.set("v.selectedBadge.Account__c",accountId);
			helper.updateExhibitorBadgeFields(component);
			component.set("v.isViewDetail",true);
		}
		else
		{
			formTab.showToast(component,'error',editmsg);
		}
	},	
	showModalIncreaseLimit : function(component, event, helper) {		
		document.getElementById('modalIncreaseLimit').style.display = "block";
	},
	hideModalIncreaseLimit : function(component, event, helper) {
		document.getElementById('modalIncreaseLimit').style.display = "none";
	},
	showModalBoothLimit : function(component, event, helper) {
        var isBoothsize= component.get("v.eventSettings.Allotment_By_Booth_Size__c");
        var isBoothType= component.get("v.eventSettings.Allotment_By_Booth_Type__c");
        if((isBoothsize==true)||((isBoothsize==false)&&(isBoothType==false)))
        {
            document.getElementById('modalBoothLimit').style.display = "block";
        }
        if(isBoothType==true)
        {
             document.getElementById('modalBoothTypeLimit').style.display = "block";
        }
	},
	hideModalBoothLimit : function(component, event, helper) {
		document.getElementById('modalBoothLimit').style.display = "none";
        document.getElementById('modalBoothTypeLimit').style.display = "none";
	},
	showModalCreateBadge : function(component, event, helper) {
		document.getElementById('modalCreateBadge').style.display = "block";
	},	
	hideModalCreateBadge : function(component, event, helper) {
		document.getElementById('modalCreateBadge').style.display = "none";
	},
	showBadgeDeleteAlert : function(component, event, helper) {
		component.set("v.selectedBadgeId",event.getSource().get("v.value"));
		document.getElementById('modalBadgeDeleteAlert').style.display = "block";
	},
	hideBadgeDeleteAlert : function(component, event, helper) {
		document.getElementById('modalBadgeDeleteAlert').style.display = "none";
	},
	showModalImportBadge : function(component, event, helper) {
		document.getElementById('modalImportBadge').style.display = "block";
	},
	hideModalImportBadge : function(component, event, helper) {
		document.getElementById('modalImportBadge').style.display = "none";
	},
	deleteBadge : function(component, event, helper) {
		document.getElementById('modalBadgeDeleteAlert').style.display = "none";
		formTab.showSpinner(component);
		var badgeId = component.get("v.selectedBadgeId");
		var action = component.get("c.deleteSelectedBadge");        
		action.setParams({badgeId:badgeId});
        action.setCallback(this, function(res) {
        	formTab.hideSpinner(component);
            helper.fetchBooths(component);
        });
        $A.enqueueAction(action);
	}, 
	boothOnchange : function(component, event, helper) {
		var dynamicCmp = component.find("boothDimensions");
		var boothId=dynamicCmp.get("v.value");
		var boothIds;
		if(boothId){
			boothIds = [boothId];
        }
		else{
			boothIds = component.get("v.allBoothIds");
		}
		helper.fetchBoothSummary(component,boothIds,"v.boothSummary");
		helper.fetchBoothDetail(component);
	},
	boothSizeOnchange : function(component, event, helper) {		
		var boothId=event.getSource().get("v.value");
		var boothIds;
		if(boothId){
			boothIds = [boothId];
		}
		helper.fetchBoothSummary(component,boothIds,"v.boothBadgeLimits");
	},
	validateNumber: function(component, event, helper) {
		var e=event;
		if (e.which != 8 && e.which != 0 && (e.which < 48 || e.which > 57)) {
			event.preventDefault();
		}
	}, 
	onLimitChange: function(component, event, helper) {
		var boothSum= component.get("v.allBoothSummary");
		var newlimit=0;
		$(".newlimit").each(function(){ 
			var $this = $(this);
			var lmt= $this.attr("value");
			if(lmt && !isNaN(lmt)) newlimit+=parseInt(lmt); 
		});
		boothSum.totBadges=parseInt(boothSum.totBadgesAllotment) + newlimit;
		component.set("v.allBoothSummary",boothSum);
	}, 
	onCheckChange: function(component, event, helper) {
		//console.log('sdadadad'+	component.get("v.isSaveandNew"));
	}, 
	createBadge: function(component, event, helper) {
		var eventId= component.get("v.eventId");
		var accountId= component.get("v.accountId");
		var newBadge=component.get("v.newBadge");
        //console.log('newBadge--'+ JSON.stringify(newBadge));
		var eventSettings =component.get("v.eventSettings");
		newBadge.Event_Edition__c=eventId;
		newBadge.Account__c=accountId;
		
		var exbNameLimit=parseInt(eventSettings.Company_Name_on_Badge_Character_Limit__c);
		var fnameLimit=parseInt(eventSettings.Badge_FName_Character_Limit__c);
		var lnameLimit=parseInt(eventSettings.Badge_LName_Character_Limit__c);
		var jobTitleLimit=parseInt(eventSettings.Badge_JobTitle_Character_Limit__c);
		var cityLimit=parseInt(eventSettings.Badge_City_Character_Limit__c);
		var addLimit=parseInt(eventSettings.Badge_Address_Character_Limit__c);
		var emailLimit=parseInt(eventSettings.Badge_Email_Character_Limit__c);
		var mobLimit=parseInt(eventSettings.Badge_Mobile_Character_Limit__c);

		var boothLimit =component.get("v.boothBadgeLimits");
		//console.log('boothLimit--'+ JSON.stringify(boothLimit));
		//console.log('newBadge--'+ JSON.stringify(newBadge));
		
		var msg='';
		component.set("v.message",msg);
		// added for CCEN-737
		if(!newBadge.Opp_Booth_Mapping__c)
		{
			msg='Please select booth';
		}
		else if(boothLimit.totBadgesUsed >= boothLimit.totBadgesAllotment)
		{
			msg='Badges limit reached. 0 out of '+boothLimit.totBadgesAllotment+' badges are available';
		}		
		else if(eventSettings.Company_Name_on_Badge__c == true && !newBadge.Exhibitor_Name__c)
        {
            msg='Please enter exhibitor Company name';	 			
        }
        else if(eventSettings.Company_Name_on_Badge__c == true && ((newBadge.Exhibitor_Name__c).length > exbNameLimit))
        {
            msg='Exhibitor Company name limit exceeded';
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
        	helper.saveExhBadge(component,newBadge);	
        }
		else{
			formTab.showToast(component,'error',msg);		
		}		
	},
    /*Regarding Ticket BK-2188 //Commented as per ticket BK-2895
    handleChange:function(component, event, helper) {
        var medValues = component.get("v.medValues");
        var eventId= component.get("v.eventId");
		var accountId= component.get("v.accountId");
       	var today = new Date();
        //console.log('today'+today);
        component.set('v.isSpinner',true);
        var action = component.get('c.med2MedMatching');
        action.setParams({
            medValues:medValues,
            AccountID:accountId,
            eventId:eventId,
            lastModifiedDate:today
        });
        action.setCallback(this, function (res) {
          
           var state = res.getState()
           var result=res.getReturnValue();
           if (component.isValid() && state === 'SUCCESS') {
               //console.log('result'+JSON.stringify(result));
               component.set('v.medValues',result[0].Badge_Form__c);
               component.set('v.isSpinner',false); 
           }
        });
        $A.enqueueAction(action)
    },*/
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
		var accountId18 = component.get("v.accountId18");
		//console.log('==========18ID'+accountId18);
		//var eventId = component.get("v.eventId");
		var eventSettings  = component.get("v.eventSettings"); 
		var eventcode = eventSettings.Event_Edition__r.Event_Edition_Code__c;
		var visitBaseurl = $A.get("$Label.c.GES_Visit_URL");
		var urlEvent = $A.get("e.force:navigateToURL");
		//BK-12603
		if(!accountId18){
			urlEvent.setParams({
			"url": visitBaseurl + 'eec=' + eventcode + '&acc=' + accountId 
			});
		}	
		else{
			urlEvent.setParams({
				"url": visitBaseurl + 'eec=' + eventcode + '&acc=' + accountId18 
			});
		}
		urlEvent.fire(); 
	},
    
})