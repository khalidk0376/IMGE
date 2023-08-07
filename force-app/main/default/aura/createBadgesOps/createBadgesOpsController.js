({	
	scriptsLoaded: function(component) {
		$("#uploadBadgeIframe").attr("src", "/apex/c__uploadBadges?eventcode="+component.get("v.eventCode")+"&eventId="+component.get("v.eventId")+"&accountId="+component.get("v.accountId")+"&uType="+component.get("v.uType")+"");
	},
	OnloadData : function(component, event, helper) {
        /*Updated Regarding Ticket No.BK-3331*/
        window.addEventListener("message", $A.getCallback(function(event) {            
            var ifBoothsize= component.get("v.eventSettings.Allotment_By_Booth_Size__c");
            var ifBoothType= component.get("v.eventSettings.Allotment_By_Booth_Type__c");
            if((ifBoothsize==true)||(ifBoothsize==false)||(ifBoothType==false)){
                document.getElementById('modalBoothLimit').style.display = "block";
            }
            if(ifBoothType==true){
                document.getElementById('modalBoothLimitByType').style.display = "block";
            }
        }), false);
        
		helper.fetchBoothLimit(component);
		helper.fetchBooths(component);
		helper.fetchEventSettings(component);		
	},
	openModal:function(component, event, helper) {
		component.set("v.isViewDetail",true);
	},
	export:function(component,event,helper){
		var csv = helper.getCSV(component);
		
         if (csv == null){return;}
        
        // ####--code for create a temp. <a> html tag [link tag] for download the CSV file--####      
        var hiddenElement = document.createElement('a');
		//hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
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
	approveEditBadge:function(component, event, helper) {
		var accountId= component.get("v.accountId"); 		
		component.set("v.selectedBadge.Status__c",'Approved');
		component.set("v.selectedBadge.Account__c",accountId);
		//var msg = helper.validateBadges(component,component.get("v.selectedBadge"));
		var msg = 'Valid'; // to ByPass the Badge validation .
		if(msg ==='Valid')
		{
			helper.updateExhibitorBadgeFields(component);
		}else
		{
			component.set("v.message",msg);
		}		
		component.set("v.isViewDetail",true); 
	},
	rejectEditBadge:function(component, event, helper) {
		var accountId= component.get("v.accountId"); 
		component.set("v.selectedBadge.Status__c",'Rejected');
		component.set("v.selectedBadge.Account__c",accountId);
		helper.updateExhibitorBadgeFields(component);
	},
	approveBadge:function(component, event, helper) {
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
        }
        catch(e){
        	console.log(e.message);
        }
        if(badgelist.length>0){
        	helper.updateExhibitorBadgeStatus(component,badgelist,'Approved');
        }
	},
	rejectBadge:function(component, event, helper) {
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
        }
        catch(e){
        	console.log(e.message);
        }
        if(badgelist.length>0){
        	helper.updateExhibitorBadgeStatus(component,badgelist,'Rejected');
        }
	},
	showModalIncreaseLimit : function(component, event, helper) {
		// var boothSum= component.get("v.allBoothSummary");
		// if(boothSum)
		// {
		// 	var newlimit=0;
		// 	$(".newlimit").each(function(){ 
		// 		var $this = $(this);
		// 		var lmt= $this.attr("value");
		// 		if(lmt && !isNaN(lmt)) newlimit+=parseInt(lmt); 
		// 	});
		// 	boothSum.totBadges=parseInt(boothSum.totBadgesAllotment) + newlimit;
		// 	boothSum.totBadgesAllotment=boothSum.totBadges;
		// 	component.set("v.allBoothSummary",boothSum);
		// }
		document.getElementById('modalIncreaseLimit').style.display = "block";
	},
	hideModalIncreaseLimit : function(component, event, helper) {
		document.getElementById('modalIncreaseLimit').style.display = "none";
	},
    showModalBoothLimit : function(component, event, helper) {
        var ifBoothsize= component.get("v.eventSettings.Allotment_By_Booth_Size__c");
        var ifBoothType= component.get("v.eventSettings.Allotment_By_Booth_Type__c");
        
        if((ifBoothsize==true)||(ifBoothsize==false)||(ifBoothType==false))
        {
            document.getElementById('modalBoothLimit').style.display = "block";
        }
        if(ifBoothType==true)
        {
            document.getElementById('modalBoothLimitByType').style.display = "block";
        }
    },
	hideModalBoothLimit : function(component, event, helper) {
       
       document.getElementById('modalBoothLimit').style.display = "none";
        document.getElementById('modalBoothLimitByType').style.display = "none";
        
	},
	showModalCreateBadge : function(component, event, helper) {
		document.getElementById('modalCreateBadge').style.display = "block";
	},
	hideModalCreateBadge : function(component, event, helper) {
		document.getElementById('modalCreateBadge').style.display = "none";
	},
	showModalImportBadge : function(component, event, helper) {
		document.getElementById('modalImportBadge').style.display = "block";
	},
	hideModalImportBadge : function(component, event, helper) {
		document.getElementById('modalImportBadge').style.display = "none";
	},
	saveLimit : function(component, event, helper) {
		var newLimits=[];
		var counter=0;
		var isNegative=false;
		var boothsNos='';
		$(".newlimit").each(function(){ 
			var $this = $(this);
			var lmt= $this.attr("value");
			var bid= $this.attr("id");
			var tot= $this.attr("data-tot");
			var prev= $this.attr("data-prev");
			if(lmt && !isNaN(lmt))
			{	
				if(lmt<0)
				{
					isNegative=true;
				}
				else
				{
					if(prev)lmt=parseInt(lmt)+parseInt(prev);
					newLimits.push({Id:bid,Badge_Limit__c:lmt});
				}
			console.log('newLimits ' +JSON.stringify(newLimits));	
			} 
			if(tot<=0)
			{
				counter++;
				boothsNos+=boothsNos==''? $this.attr("data-booth"):','+$this.attr("data-booth");
			}
		});
		if(counter>0){
			component.set("v.message","Please update the initial badge allotment for booth: "+boothsNos+"  before increasing the limit.");
		}
		else
		{
			if(isNegative)
			{
				component.set("v.message","Please enter positive number.");
			}
			else
			{
				helper.saveLimits(component,newLimits);
			}
		}
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
		var dynamicCmp = component.find("selectBooths");
		var boothId=dynamicCmp.get("v.value");
		var boothIds;
		if(boothId){
			boothIds = [boothId];
		}
		helper.fetchBoothSummary(component,boothIds,"v.boothBadgeLimits");
	},
	validateNumber: function(component, event, helper) {
		//console.log(event.keyCode);
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
		//console.log(JSON.stringify(boothSum));
		component.set("v.allBoothSummary",boothSum);
	}, 
	onCheckChange: function(component, event, helper) {
		//console.log('sdadadad'+	component.get("v.isSaveandNew"));
	}, 
	createBadge: function(component, event, helper) {
		//console.log('boothLimit====');
		var eventId= component.get("v.eventId");
		var accountId= component.get("v.accountId");
		var newBadge=component.get("v.newBadge");
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
		//console.log('boothLimit--'+ JSON.stringify(newBadge));
		
		var msg='';
		component.set("v.message",msg);
		// Added for CCEN-737
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
            msg='Exhibitor name limit exceeded';
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
		if(msg)
		{
			component.set("v.message",msg);
		}
		else
		{
			let button = component.find('btnCreateBadge');
    		button.set('v.disabled',true);//CCEN-643 
			helper.saveExhBadge(component,newBadge);
		}
	},
})