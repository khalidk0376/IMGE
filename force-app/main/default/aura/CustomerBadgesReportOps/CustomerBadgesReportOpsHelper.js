({
	fetchEventSettings : function(component) {
        var action = component.get("c.getEventSettings");//get data from controller
		var eventId= component.get("v.eventId");
        action.setParams({
            eventId: eventId
        });
        action.setCallback(this, function(res) {
			var result=res.getReturnValue();
			//console.log('eventSettings------'+JSON.stringify(result));
			component.set("v.eventSettings", result);
			if(result.Badge_Nationality__c)
			{
				this.fetchPicklistValues(component,'Exhibitor_Badge__c','Nationality__c','selectNation');	
			}
			if(result.Badge_Age_Bracket__c)
			{
				this.fetchPicklistValues(component,'Exhibitor_Badge__c','Age_Bracket__c','selectAgeBracket');
			}
			if(result.Badge_Country__c)
			{
				this.fetchPicklistValues(component,'Exhibitor_Badge__c','Country__c','selectCountry');
			}
			if(result.Badge_Mobile_Number__c)
			{
				this.fetchPicklistValues(component,'Exhibitor_Badge__c','Country_Code__c','selectCountryCode');
			}
			component.set("v.isSpinner", false);// Adding values in Aura attribute variable. 
        });
        $A.enqueueAction(action);
	},
	fetchAggBoothBadges : function(component) {
		
		var pageNumber 	= 	component.get("v.PageNumber");  
		var pageSize	=	component.get("v.pageSize"); 
		var sEventId	= 	component.get("v.eventId");
		var status 		= 	component.get("v.selectedValue"); 

        var action = component.get("c.getExhibitorBadgeAggregate");//get data from controller		
        action.setParams({
			sEventId : sEventId,
			pageNumber:pageNumber, 
			pageSize : pageSize,
			status	: status
        });   
        action.setCallback(this, function(res) {        
			if(res.getState()==='SUCCESS')
			{	
				var result = res.getReturnValue();	 		
				//console.log('boothAggreResult ==== '+ JSON.stringify(result.aggregateResult));
				component.set("v.boothAggreResult",result.aggregateResult);	
				component.set("v.PageNumber", result.pageNumber);
                component.set("v.TotalRecords", result.totalRecords);
                component.set("v.RecordStart", result.recordStart);
                component.set("v.RecordEnd", result.recordEnd);
                component.set("v.TotalPages", Math.ceil(result.totalRecords / pageSize));
        	}
			else
			{
        		console.log(res.getReturnValue());
			}
			component.set("v.isSpinner", false);// Adding values in Aura attribute variable. 
        });
        $A.enqueueAction(action);
	},
	fetchAccBadges : function(component,sAccId) 
	{	
        var action = component.get("c.getAccountBadges");//get data from controller
		var sEventId= component.get("v.eventId");
        action.setParams({			
			sAccId  :sAccId,
			sEventId : sEventId
        });        
        action.setCallback(this, function(res) {        
			if(res.getState()==='SUCCESS')
			{				
				//console.log('MAP ==== '+ JSON.stringify( res.getReturnValue()));
				component.set("v.accBadges",res.getReturnValue());
				this.pushBadgesToList(component,res.getReturnValue());	
        	}
			else
			{
        		console.log(res.getReturnValue());
			}
			component.set("v.isSpinner", false);// Adding values in Aura attribute variable. 
        });
        $A.enqueueAction(action); 
	},
	// fetched data from new custom object [CCEN-737]
	pushBadgesToList : function(component,listbadges)
	{
		var mapBadges = new Map();
		var expoBooths = [];
		var opts = [];
		if(listbadges)
		{	
			opts.push({label: 'All Booths#',value:'All'});			
			for(let i=0 ; i<listbadges.length ; i++)
			{
				mapBadges.set(listbadges[i].Id,listbadges[i]);					
				if(!expoBooths.includes(listbadges[i].Opp_Booth_Mapping__r.Booth_Number__c))
				{
					expoBooths.push(listbadges[i].Opp_Booth_Mapping__r.Booth_Number__c);
					opts.push({label:listbadges[i].Opp_Booth_Mapping__r.Booth_Number__c+' - '+listbadges[i].Account__r.Name,
								 value: listbadges[i].Opp_Booth_Mapping__r.Booth_Number__c});
				}
			}
			//console.log('expoBooths == '+ JSON.stringify(opts));
			component.set("v.accBooths",opts); 									
		}
		component.set("v.mapAccBadges",mapBadges); 
		component.set("v.isSpinner", false);// Adding values in Aura attribute variable. 
	},
	filterOnBooth : function(component,mapVal,boothNo)
	{
		if(mapVal && boothNo)
		{
			var listVal = [];
			for(var val of mapVal.values())
			{
				if(boothNo  === 'All')
				{
					listVal.push(val);
				}
				else if(val.Opp_Booth_Mapping__r.Booth_Number__c === boothNo)
				{
					listVal.push(val);
				}				
			}
		}
		component.set("v.accBadges",listVal); 
		component.set("v.isSpinner", false);// Adding values in Aura attribute variable. 
	},
	fetchPicklistValues : function (component, objName, field,attribute) {
        var action = component.get('c.getPicklistValues');
        action.setParams({
            objApi:objName,
            fieldName:field
        });
		action.setCallback(this, function (res) 
		{
            var state = res.getState()
            var result=res.getReturnValue();
            if (component.isValid() && state === 'SUCCESS') {
                var opts=[];      	
                opts.push({label: '--Select--', value:''});
				for(var i=0;i< result.length;i++){
					if(result[i] != 'None__$__None')
					{
						opts.push({label: result[i].split('__$__')[0], value: result[i].split('__$__')[1]});
					}					
				}
				//component.find(attribute).set("v.options",opts); 
                if(field=='Country__c'){
                    component.set("v.countryPicklist",opts);
                }
                if(field=='Age_Bracket__c'){
                    component.set("v.ageBracketPicklist",opts);
                }
                if(field=='Nationality__c'){
                    component.set("v.nationalityPicklist",opts);
				}
				if(field=='Country_Code__c'){
                    component.set("v.countryCodePicklist",opts);
                }				
				component.set("v.isSpinner", false);// Adding values in Aura attribute variable. 
            }
        })
        $A.enqueueAction(action)
	},
	updateExhibitorBadgeStatus:function(component,badgeList,status,sendEmail,notes){
		if(badgeList.length==0)
		{ return;}		
		var action = component.get("c.updateExhibitorBadge");
        action.setParams({ 
			idStr: badgeList,
			status: status,
			sendEmail:sendEmail,
			notes : notes
		});
		action.setCallback(this, function(res)
		{        	
			if(res.getState()==='SUCCESS')
			{
				this.fetchAggBoothBadges(component);
				formTab.showToast(component,'success','Badges have been updated successfully.');
        	}
			else
			{
        		console.log('ERROR = '+res.getState());
			}
			component.set('v.isViewAccBadgesDetail',false);
			component.set("v.isMassApproveConfirm",false);
			component.set("v.isMassRejectConfirm",false);
			component.set("v.RejectNote"," ");
			component.set("v.ApproveNote"," ");
			component.set("v.isSpinner", false);// Adding values in Aura attribute variable. 
        });
        $A.enqueueAction(action);
	},
	updateSingleBadgeFields:function(component,selectedBadge,sendRejectMail,RejectNote){	
		//JSON.stringify('selectedBadge === '+selectedBadge)			
		var action = component.get("c.updateBadgeAllFields");
		action.setParams({
			ebObj: selectedBadge,
			sendEmail:sendRejectMail,
			notes:RejectNote
		});
        action.setCallback(this, function(res) {        	
			if(res.getState()==='SUCCESS')
			{
				var exhAcc = component.get("v.currentAccount");
				this.fetchAccBadges(component,exhAcc.Id);
				this.fetchAggBoothBadges(component);
				formTab.showToast(component,'success','Badge have been updated successfully!');
				//console.log(res.getReturnValue());
        	}
        	else{
        		console.log('ERROR = '+res.getReturnValue());
        	}
			//component.set("v.isViewAccBadgesDetail",false);
			component.set("v.isSingleEditBadge",false);
			component.set("v.isMassApproveConfirm",false);
			component.set("v.isMassRejectConfirm",false);
			component.set("v.isSpinner", false);// Adding values in Aura attribute variable. 
        });
        $A.enqueueAction(action);
	},
	massBadgeReminder : function(component) 
	{
		var action = component.get("c.massBadgesEmailReminder");//get data from controller
		var sEventId= component.get("v.eventId");
        action.setParams({						
			sEventId : sEventId
        });        
        action.setCallback(this, function(res) {        
			if(res.getState()==='SUCCESS')
			{				
				//console.log('Response == '+ JSON.stringify( res.getReturnValue()));				
				formTab.showToast(component,'success','Emails Are Sent successfully!');
        	}
			else
			{
        		console.log(res.getReturnValue());
			}
			component.set("v.isSpinner", false);// Adding values in Aura attribute variable. 
        });
        $A.enqueueAction(action); 
	},
	validateBadges : function(component,badge) 
	{		
		var eventSettings =component.get("v.eventSettings");
		var newBadge = badge;
		var exbNameLimit=parseInt(eventSettings.Company_Name_on_Badge_Character_Limit__c);
		var fnameLimit=parseInt(eventSettings.Badge_FName_Character_Limit__c);
		var lnameLimit=parseInt(eventSettings.Badge_LName_To_UpperCase__c);
		var jobTitleLimit=parseInt(eventSettings.Badge_JobTitle_Character_Limit__c);
		var cityLimit=parseInt(eventSettings.Badge_City_Character_Limit__c);
		var addLimit=parseInt(eventSettings.Badge_Address_Character_Limit__c);
		var emailLimit=parseInt(eventSettings.Badge_Email_Character_Limit__c);
		var mobLimit=parseInt(eventSettings.Badge_Mobile_Character_Limit__c);

		//var boothLimit =component.get("v.boothBadgeLimits");
		
		var msg='Valid';
		//component.set("v.message",msg);
		
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
        else if(eventSettings.Badge_Email__c == true && !/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(newBadge.Email__c))
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
		/*	
		var allValid = component.find('newBadgeField').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
		*/
        return msg;		
	},
	updateMassCheckBox : function(component,event) 
	{
		var ele = component.get("v.isMassSelected");
		var allchecks = component.find('badge_row');			
		if (ele) 
		{	
			if(allchecks.length)//incase of Single Record
			{
				for(var i = 0; i < allchecks.length; i++)
				{					
					allchecks[i].set("v.checked",true);
				}
			}else
			{				
				allchecks.set("v.checked",true);
			}					
		} else 
		{
			if(allchecks.length)//incase of Single Record
			{
				for (var i = 0; i < allchecks.length; i++)
				{
					allchecks[i].set("v.checked",false);
				}
			}else
			{
				allchecks.set("v.checked",false);
			}	
		}
	}
})