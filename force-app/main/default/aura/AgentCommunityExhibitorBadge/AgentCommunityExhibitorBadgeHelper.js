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
			var now = new Date();
            var day = ("0" + now.getDate()).slice(-2);
            var month = ("0" + (now.getMonth() + 1)).slice(-2);
            var today = now.getFullYear() + "-" + (month) + "-" + (day);
			if(result.Badge_Deadline__c)
			{
				if(result.Badge_Deadline__c<today)
				{
                    component.set("v.isExpired", true);
                }
            }
		});
		$A.enqueueAction(action);
	},
    fetchBadgesStatus: function (component) {
        component.set("v.isSpinner",true);
		var action = component.get("c.getBadgesStatusCCMap");
		let eventId = component.get('v.eventId');
		let accountId = component.get('v.accountId');
		action.setParams({
			accountId: accountId,
			eventEditionId: eventId
		});
		action.setCallback(this, function (response) {
            let totalBadges = 0;
            let remainingBadges = 0;
			if (response.getState() === 'SUCCESS') {
                console.log('badgesStatusMap' +JSON.stringify(response.getReturnValue()));
                component.set('v.badgesStatusMap', response.getReturnValue());
                var additionalBadges = component.get('v.badgesStatusMap.additionalBadges');
                var fixedAgentBadges = component.get('v.eventSettings.Agent_Badge_limit__c');
                if(fixedAgentBadges)
                {
                    totalBadges = parseInt(fixedAgentBadges);
                    if(additionalBadges)
                    {
                        totalBadges+= parseInt(additionalBadges);
                    }
                }
                else{
                    totalBadges = 0;
                }
                component.set('v.totalBadges', totalBadges);
                remainingBadges = totalBadges - parseInt(component.get('v.badgesStatusMap.submitted'));
                component.set('v.remainingBadges', remainingBadges);
                component.set("v.isSpinner",false);
                
            } 
            else {
                component.set('v.totalBadges', totalBadges);
                component.set('v.remainingBadges', remainingBadges);
                component.set('v.badgesStatusMap.submitted', 0);
			}
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
				if(component.find(attribute)!=undefined){
				component.find(attribute).set("v.options", opts);
				}
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
    saveAgentBadge : function(component,newBadge) 
    {
        // Added regarding ticket [CCEN-577]
        var eventSettings  = component.get("v.eventSettings");
        console.log(' eventSettings === '+ JSON.stringify(eventSettings) );
        var evtId = component.get("v.eventId");
        var accId = component.get("v.accountId");
        var isSaveandNew = component.get("v.isSaveandNew");
        if(eventSettings)
        {
            if(eventSettings.Approval_Not_Required__c && !newBadge.Is_VIP__c)//CCEN-661 
            {
                newBadge.Status__c = 'Approved';
            }
            else{
                newBadge.Status__c = 'Pending'; 
            }
        }
        
        console.log(' newBadge === '+ JSON.stringify(newBadge) );
        var action = component.get("c.saveAgentBadge");//get data from controller
        action.setParams({
            agentBadge:newBadge,
            eventId:evtId,
            accountId:accId
        });
        action.setCallback(this, function(res) {
            this.resetForm(component);
            if(!isSaveandNew){
                document.getElementById('modalCreateBadge').style.display = "none";
                this.fetchBadgesStatus(component);
            }
            else{
                this.fetchBadgesStatus(component); 
            }
            let button = component.find('btnCreateBadge');
            button.set('v.disabled',false); //CCEN-643 
            console.log('saveExhBadge------'+JSON.stringify(res.getReturnValue())); 
        });
        $A.enqueueAction(action);
    },
	// saveAgentBadge: function (component, newBadge) {
	// 	var isSaveandNew = component.get("v.isSaveandNew");
	// 	var action = component.get("c.saveAgentBadge"); //get data from controller
	// 	action.setParams({
	// 		agentBadge: newBadge
	// 	});
	// 	action.setCallback(this, function (res) {
	// 		this.resetForm(component);
	// 		if (!isSaveandNew) {
	// 			document.getElementById('modalCreateBadge').style.display = "none";
    //         }
    //         //console.log('returnvalue'+res.getReturnValue());
	// 		this.fetchBadgesStatus(component);
	// 		let button = component.find('btnCreateBadge');
	// 		button.set('v.disabled', false); //CCEN-643 
	// 	});
	// 	$A.enqueueAction(action);
	// },
	getCSV:function(component){
        var Records = component.get('v.badgesStatusMap.agentBadgeList');
        var badgesStatusMapping = component.get('v.badgesStatusMap');
        //console.log('Records---'+JSON.stringify(Records));
        var csvStringResult;
        var counter; 
        var keys; 
        
        // store ,[comma] in columnDivider variabel for sparate CSV values and 
        // for start next line use '\n' [new line] in lineDivider varaible  
        var columnDivider = ',';
        var lineDivider =  '\n';
        
        // check if "Records" parameter is null, then return from function
        if (Records == null || !Records.length) {
            return null;
        }
        
        var isVipAllowed = component.get("v.eventSettings.Allow_VIP_Badges__c");
      	// in the keys variable store fields API Names as a key 
        // these labels use in CSV file header
        if(isVipAllowed==true)  
        {
            keys = ['Account_Name__c','First_Name__c','Last_Name__c','Job_Title__c','Address__c','City__c','Country__c','Nationality__c',
                    'State__c','Status__c','Age_Bracket__c','Country_Code__c','Mobile_Number__c','Email__c','Is_VIP__c']; 
        }
        else
        {
            keys = ['Account_Name__c','First_Name__c','Last_Name__c','Job_Title__c','Address__c','City__c','Country__c','Nationality__c',
                    'State__c','Status__c','Age_Bracket__c','Country_Code__c','Mobile_Number__c','Email__c'];  
        }
        
        if(isVipAllowed==true)
        {
            var map = {
                'Account_Name__c':'Company Name on Badge',
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
                'Email__c':'Email',
                'Is_VIP__c':'VIP'
                //'Matchmaking__c':'Would you like to add this staff to the free matchmaking programme?'
            };  
        }
        else
        {
            var map = {
                'Account_Name__c':'Company Name on Badge',
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
                'Email__c':'Email'
                //'Matchmaking__c':'Would you like to add this staff to the free matchmaking programme?'
            }; 
        }
        
        csvStringResult = '';
        csvStringResult += keys.join(columnDivider);
        csvStringResult += lineDivider;
        
        for(var i=0; i < Records.length; i++){   
            counter = 0;
            csvStringResult += '"'+badgesStatusMapping.companyName+'",';
            csvStringResult+=''
            
            /**CCEN-652 **/
            
            if(Records[i].Is_VIP__c == true)
            {
                Records[i].Is_VIP__c = 'Yes';
            }else
            {
                Records[i].Is_VIP__c = 'No';
            }
            
            
            
            //console.log('Records[i].ExpocadBooth__c'+Records[i].ExpocadBooth__c);
            for(var sTempkey in keys){
                var skey = keys[sTempkey];
                if(counter > 0){ 
                    csvStringResult += columnDivider; 
                }               
                csvStringResult += '"'+ Records[i][skey]+'"';                
                counter++;
            }// inner for loop close 
            csvStringResult += lineDivider;
        }// outer main for loop close 
        
        var FinalcsvStringResult = csvStringResult.split('\n');
        FinalcsvStringResult[0] = '"Company",'+FinalcsvStringResult[0];
        
        
        FinalcsvStringResult[0] = FinalcsvStringResult[0].replace(/Account_Name__c|First_Name__c|Last_Name__c|Job_Title__c|Address__c|City__c|Country__c|Nationality__c|State__c|Status__c|Age_Bracket__c|Country_Code__c|Mobile_Number__c|Email__c|AgentEventEditionMapping__c|Is_VIP__c/gi, function(matched){
            return map[matched];
        });
        FinalcsvStringResult= FinalcsvStringResult.join('\n');
        return FinalcsvStringResult.replace(/undefined|FALSE/gi,'');
        
    },
    getTemplateId:function(component){
        var evntCode= component.get("v.eventCode");
        var action = component.get("c.getDocumentId");  
        action.setParams({
            evntCode:evntCode
        });
        action.setCallback(this, function(res) {
            component.set("v.tempateId",res.getReturnValue());
        });
        $A.enqueueAction(action);        
    },
    resetForm : function(component){
        component.set("v.newBadge",{'Is_VIP__c':false,'Address__c':'','Age_Bracket__c':'','City__c':'','Country__c':'','Email__c':'','Event_Edition__c':'','Account_Name__c':component.get('v.badgesStatusMap.companyName'),'First_Name__c':'','Job_Title__c':'','Last_Name__c':'','Country_Code__c':'','Mobile_Number__c':'','Nationality__c':'','State__c':'','Status__c':'Approved'});
        component.set("v.isSaveandNew", false);
    },
    getSingleBadgeHelper:function(component,idStr){
        component.set("v.isSpinner",true);
        var action = component.get("c.getSingleBadge");
        action.setParams({idStr:idStr});
        action.setCallback(this, function(res) {
            component.set("v.isSpinner",false);
            if(res.getState()==='SUCCESS'){
                //console.log('get return ' +JSON.stringify(res.getReturnValue()));
                var objList = res.getReturnValue();
                if(objList.length>0){
                    component.set("v.selectedBadge",objList[0]);        			
                    if(objList[0].Status__c=='Approved' || objList[0].Status__c=='Rejected'){
                        component.set("v.isConfirm",false);	
                    }
                    else{
                        component.set("v.isConfirm",true);	
                    }


                }
            }
            else{
                //console.log(res.getReturnValue());
            }
            component.set("v.isViewDetail",false);
        });
        $A.enqueueAction(action);
    },
    updateExhibitorBadgeFields:function(component){		
        component.set("v.isSpinner",true);
		var eventSettings  = component.get("v.eventSettings");
        var updateBadge = component.get("v.selectedBadge");
        //console.log('evnt setting ' +eventSettings.Approval_Not_Required__c);
		if(eventSettings)
        {
            if(eventSettings.Approval_Not_Required__c && !updateBadge.Is_VIP__c)//CCEN-661 
            {
                updateBadge.Status__c = 'Approved';
            }
            else{
                updateBadge.Status__c = 'Pending'; 
            }
        }
        var action = component.get("c.updateBadgeAllFields");
        action.setParams({ebObj: updateBadge});
        action.setCallback(this, function(res) {
            component.set("v.isSpinner",false);
            if(res.getState()==='SUCCESS'){
                this.fetchBadgesStatus(component);
                formTab.showToast(component,'success','Badge have been updated successfully.');
                component.set("v.isEditBadge",false);
            }
            else{
                formTab.showToast(component,'error',res.getError()[0].message);
            }        	
        });
        $A.enqueueAction(action);
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
        
        var msg='Valid';
        
        
        if(eventSettings.Company_Name_on_Badge__c == true && !newBadge.Account_Name__c)
        {
            msg='Please enter exhibitor Company name';				
        }
        else if(eventSettings.Company_Name_on_Badge__c == true && ((newBadge.Account_Name__c).length > exbNameLimit))
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
        var allValid = this.validateForm(component);
        if(allValid != true)
        {
            msg = 'Please fill all required fields !';
        }        		
        return msg;		
    },
    validateForm : function(component)
    {
        var feildCmp = component.find('inputField');
        //console.log('feildCmp '+feildCmp);
        if(feildCmp.length)
        {
            var allValid = component.find('inputField').reduce(function (validSoFar, inputCmp)
                                                               {
                                                                   inputCmp.showHelpMessageIfInvalid();
                                                                   return validSoFar && inputCmp.get('v.validity').valid;
                                                               }, true);
            return allValid;
        }else
        {
            return feildCmp.get('v.validity').valid;
        }
    },
    getUserType: function (component) {
        var sEventCode = component.get("v.eventCode");
        var action = component.get("c.getCurrentUserType"); //Calling Apex class controller 'getCurrentUserType' method
        action.setParams({
            eventId: sEventCode
        });
        action.setCallback(this, function (response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS") {
                var result = response.getReturnValue();
                //var usertype = result.User_Type__r.Name;
                // console.log('success');
                // console.log('sEventCode',sEventCode);
                // console.log('se')
                // console.log('usertype ===== '+JSON.stringify(result,null,4));
                component.set("v.currentUser", result); 
            }
        });
        $A.enqueueAction(action);
    },
    //BK-9812
    checkFileAttached:function(component){
        var evntCode= component.get("v.eventCode");
        var action = component.get("c.checkFileId");  
        action.setParams({
            evntCode:evntCode
        });
        action.setCallback(this, function(res) {
            component.set("v.isFile",res.getReturnValue());
        });
        $A.enqueueAction(action);         
    }
})