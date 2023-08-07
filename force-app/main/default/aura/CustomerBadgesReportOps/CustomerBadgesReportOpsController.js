({
	onLoad : function(component, event, helper) 
	{
		//component.set('v.eventId','a1S1F00000013ZIUAY');
		//console.log('EVENT ID === '+ component.get('v.eventId'));
		helper.fetchAggBoothBadges(component);
		helper.fetchEventSettings(component);
		var opts = [
            { value: "All", label: "All", selected:true },
            { value: "Not Submitted", label: "Not Submitted" },            
			{ value: "Submitted", label: "Submitted" },
			{ value: "All VIP", label: "All VIP" },
			{ value: "VIP Pending Review", label: "VIP Pending Review" }     
        ];
        component.set("v.options", opts);		
	},
	scriptsLoaded: function(component, event, helper)
	{
	},
	waiting: function(component, event, helper) {
        component.set("v.isSpinner", true);// Adding values in Aura attribute variable. 
     },
    doneWaiting: function(component, event, helper) { 
        component.set("v.isSpinner", false);// Adding values in Aura attribute variable. 
	},
	sendBadgeReminderEmail : function(component, event, helper) 
	{
		helper.massBadgeReminder(component);
	},
	exportBadges : function(component, event, helper)  // CCEN-671
	{
		var tarUrl = window.location.origin + '/apex/c__ExportBadgesVF?reportName=AllBadges&eventId=' +component.get("v.eventId");  
        window.location =  tarUrl;
	},
	exportExhibitorsWithoutBadges : function(component, event, helper)   // CCEN-671
	{
		var tarUrl = window.location.origin + '/apex/c__ExportBadgesVF?reportName=ExhibitorsWithoutBadges&eventId=' +component.get("v.eventId");  
        window.location =  tarUrl;
	},
	onChangeFunction : function(component, event, helper) 
	{
		component.set("v.PageNumber",1);
		helper.fetchAggBoothBadges(component); 		
	},
	onBoothChange : function(component, event, helper) 
	{
		var sBoothNo = component.get('v.selectedBooth');
		var mapBadges = component.get('v.mapAccBadges');
		//console.log(' bth == '+sBoothNo);
		helper.filterOnBooth(component,mapBadges,sBoothNo);
		component.set("v.isMassSelected",false);
		helper.updateMassCheckBox(component,event);
	},
	showAccBadgesDetailModal : function(component, event, helper) 
	{
		var target = event.getSource();
		var exAccNameID = target.get("v.value");
		if(exAccNameID)
		{
			var accID 	= exAccNameID.split('##')[0];
			var accName = exAccNameID.split('##')[1];
			//console.log('Account ID == '+accID +' NAme'+ accName); 
			component.set('v.isViewAccBadgesDetail',true);
			var customer = {Name:accName,Id:accID};
			component.set("v.currentAccount",customer);	
			component.set("v.isMassSelected",false);	 
			helper.fetchAccBadges(component,accID);
		}else
		{
			console.log('Data Incomplete!')
		}		
	},
	massCheck : function(component,event,helper) 
	{
		helper.updateMassCheckBox(component,event);
	},
	hideAccBadgesDetailModal : function(component,event,helper) 
	{
		component.set('v.isViewAccBadgesDetail',false);
	},
	showMassApproveConfirmModal:function(component, event, helper){
		var badgelist = [];
		var ele = component.find('badge_row');
        try{            
            if(ele instanceof Array)
            {
				for(var i=0;i<ele.length;i++)
				{
					if(ele[i].get("v.checked"))
					{
            			badgelist.push(ele[i].get("v.value"))
            		}
            	}
            }
			else{
            	badgelist.push(ele.get("v.value"));
			}
			component.set("v.toMassApproveBadgesIds",badgelist);
        }
		catch(e)
		{
        	console.log(e.message);
		}
		if(badgelist.length>0)
		{
			//console.log('Approved == '+ JSON.stringify(badgelist) );
			component.set("v.sendApproveMail",true);
			component.set("v.ApproveNote",' ');
			component.set("v.isMassApproveConfirm",true);        	
        }
	},
	sideMassRejectConfirmModal:function(component, event, helper) {
		var badgelist = [];
		var ele = component.find('badge_row');
        try{            
            if(ele instanceof Array)
            {
            	for(var i=0;i<ele.length;i++){
            		if(ele[i].get("v.checked")){
            			badgelist.push(ele[i].get("v.value"))
            		}
            	}
            }
            else{
            	badgelist.push(ele.get("v.value"));
			}
			component.set("v.toMassRejectBadgesIds",badgelist);
        }
		catch(e)
		{
        	console.log(e.message);
        }
		if(badgelist.length>0)
		{
			//console.log('Rejected == '+ JSON.stringify(badgelist) );
			component.set("v.sendRejectMail",true);
			component.set("v.RejectNote",' ');
			component.set("v.isMassRejectConfirm",true);
        	//helper.updateExhibitorBadgeStatus(component,badgelist,'Rejected');
        }
	},
	openBadgeEditModal:function(component, event, helper) {
		var badgeId 	= event.getSource().get("v.value");		
		var mapBadge 	= component.get("v.mapAccBadges");
		var singleBadge = mapBadge.get(badgeId);
		if(singleBadge)
		{
			if(singleBadge.Status__c=='Approved' || singleBadge.Status__c=='Rejected')
			{
				component.set("v.isBadgeEditable",false);	
        	}
			else
			{
				component.set("v.isBadgeEditable",true);	
			}
		}
		component.set("v.selectedBadge",singleBadge);
		component.set("v.isSingleEditBadge",true);					
	},
	hideSingleBadgeEditModal:function(component, event, helper) {				
		component.set("v.isSingleEditBadge",false);
		component.set("v.isViewAccBadgesDetail",true);
	},
	confirmEdit:function(component, event, helper) {
		component.set("v.isBadgeEditable",true);
	},
	approveSingleEditBadge:function(component, event, helper)
	{			
		//var msg = helper.validateBadges(component,component.get("v.selectedBadge"));
		var msg = 'Valid'; // to ByPass the Badge validation .
		if(msg == 'Valid')
		{
			component.set("v.sendApproveMail",true);
			component.set("v.ApproveNote",' ');
			component.set("v.isMassApproveConfirm",true);
		}else
		{
			//console.log('msg == '+msg);
			formTab.showToast(component,'error',msg);
		}
	},
	rejectSingleEditBadge:function(component, event, helper)
	{	
		component.set("v.sendRejectMail",true);
		component.set("v.RejectNote",' ');		
		component.set("v.isMassRejectConfirm",true);
	},
	hideMassApproveConfirmModal :function(component, event, helper)
	{
		component.set("v.isMassApproveConfirm",false);
	},
	hideMassRejectConfirmModal	:function(component, event, helper)
	{
		component.set("v.isMassRejectConfirm",false);
	},
	MassApproveBadges :function(component, event, helper)
	{
		if(component.get("v.isSingleEditBadge"))
		{
			var singleBadge = component.get("v.selectedBadge");
			singleBadge.Status__c = 'Approved';	
			var sendApproveMail =  component.get("v.sendApproveMail"); 
			var ApproveNote =  component.get("v.ApproveNote");	
			helper.updateSingleBadgeFields(component,singleBadge,sendApproveMail,ApproveNote);
		}else
		{
			var badgelist =  component.get("v.toMassApproveBadgesIds");
			var sendApproveMail =  component.get("v.sendApproveMail");
			var ApproveNote =  component.get("v.ApproveNote");
			helper.updateExhibitorBadgeStatus(component,badgelist,'Approved',sendApproveMail,ApproveNote);	
		}			
	},
	MassRejectBadges :function(component, event, helper)
	{
		if(component.get("v.isSingleEditBadge"))
		{
			var singleBadge = component.get("v.selectedBadge");
			singleBadge.Status__c = 'Rejected';	
			var sendRejectMail =  component.get("v.sendRejectMail");
			var RejectNote =  component.get("v.RejectNote");
			helper.updateSingleBadgeFields(component,singleBadge,sendRejectMail,RejectNote);
		}else
		{
			var badgelist =  component.get("v.toMassRejectBadgesIds");
			var sendRejectMail =  component.get("v.sendRejectMail");
			var RejectNote =  component.get("v.RejectNote");
			helper.updateExhibitorBadgeStatus(component,badgelist,'Rejected',sendRejectMail,RejectNote);
		}
		
	},    
    handleNext: function(component, event, helper) {
        var pageNumber = component.get("v.PageNumber");  
        pageNumber++;
        component.set("v.PageNumber",pageNumber);
		helper.fetchAggBoothBadges(component);
    },     
    handlePrev: function(component, event, helper) {
        var pageNumber = component.get("v.PageNumber");  
        pageNumber--;
        component.set("v.PageNumber",pageNumber);  		
		helper.fetchAggBoothBadges(component);
    },
    onSelectChange: function(component, event, helper) {
        var pageSize = component.find("pageSize").get("v.value");
        component.set("v.PageNumber",1);  
        component.set("v.pageSize",pageSize);  		
		helper.fetchAggBoothBadges(component);
	},
	// showVIP: function(component, event, helper) {
    //     var checkCmp = component.find("devid");
    //     var checkVIP = checkCmp.get("v.value");
    //     var status;
    //     //console.log('check ' +checkVIP);
    //     if(checkVIP){
    //         status = true;
    //     }else{
    //         status = false;
    //     }
    //     component.set("v.checkVIP", status); 		
	// 	helper.fetchAggBoothBadges(component);
    // },

})