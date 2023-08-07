({
    getOrgType:function(component){
        //isSandbox  
        var action = component.get("c.isSandbox");
      action.setCallback(this, function(res) {
          component.set("v.isSandbox",res.getReturnValue());
      });
      $A.enqueueAction(action);        
    },
	fetchEventDetails : function(component) {
		var eId = component.get("v.eventId");
        var action = component.get("c.getEventDetails"); //Calling Apex class controller 'EventDetailMethod' method
        action.setParams({
            eventId : eId
        });
        action.setCallback(this, function(response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS")
            {
                component.set("v.Event_Setting", response.getReturnValue());// Adding values in Aura attribute variable.
            }
        });
        $A.enqueueAction(action);
	}, 
	fetchExhibitors : function(component) {
        component.set("v.isSpinner", true);
        var pageNumber = component.get("v.PageNumber");  
        var pageSize=component.get("v.pageSize");  ;
		var eId = component.get("v.eventId");
		var order = component.get("v.sortingOrder");
		var column = component.get("v.sortingColumn");
		var srchWord = component.get("v.searchKeyword");
		
		var action = component.get("c.getExhibitors"); //Calling Apex class controller 'getSingleApprovalRequest' method
        action.setParams({
			eventId: eId,
			column:column,
			order:order,
			srchText:srchWord,
            pageNumber:pageNumber,
            pageSize : pageSize,
            matchProductOption : component.get("v.selectedMatchProductOption"),
        });
        action.setCallback(this, function(res) {
            component.set("v.isSpinner", false);
            var state = res.getState();
            if (state === "SUCCESS") {
                var result = res.getReturnValue();
				component.set("v.isSpinner",false);
                component.set("v.exhibitorsData", result.lstExpocadBooth);
                component.set("v.PageNumber", result.pageNumber);
                component.set("v.TotalRecords", result.totalRecords);
                component.set("v.RecordStart", result.recordStart);
                component.set("v.RecordEnd", result.recordEnd);
                component.set("v.TotalPages", Math.ceil(result.totalRecords / pageSize));               
                var scrollFunc = component.get("v.scrollFunc"); 
                var tabat = component.get("v.tabCssAtts");
                if(tabat){
                    for(var i=0;i<tabat.length;i++)
                    {
                        if(tabat[i].tabId == component.get("v.selTabId1"))
                        {
                            CopyToClipBoard.ScrollFunction(tabat[i].hraderId,tabat[i].tabledataId,tabat[i].tableId,255,45,true,component.get("v.isSandbox"));
                        }  
                    }  
                }        
            }
            else
            {
                console.log("Error..");
            }
        });
        $A.enqueueAction(action);
	},
	fetchServices : function(component) {
		var eId = component.get("v.eventId");
        var action = component.get("c.getServices"); //Calling Apex class controller 'EventDetailMethod' method
        action.setParams({
            eventId : eId
        });
        action.setCallback(this, function(response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS")
            {
                component.set("v.services", response.getReturnValue());// Adding values in Aura attribute variable.
            }
        });
        $A.enqueueAction(action);
	},
	fetchAccountContacts : function(component,srctxt) {
		var eId = component.get("v.eventId");
		var action = component.get("c.getAccountContacts"); //Calling Apex class controller 'EventDetailMethod' method
		
        action.setParams({
            sEventcode : eId,
            srchText : srctxt
        });
        action.setCallback(this, function(response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS")
            {
                component.set("v.accs", response.getReturnValue());// Adding values in Aura attribute variable.
            }
        });
        $A.enqueueAction(action);
	},
    fetchPreferredContractor:function(component ,srctxt) {
        var evntId = component.get("v.eventId");
		var action = component.get("c.PrefContractors"); //Calling Apex class controller 'EventDetailMethod' method
		action.setParams({
            EventCode : evntId,
            srchText:srctxt
        });
        action.setCallback(this, function(response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS")
            {
                if(response.getReturnValue().length>0)
                {
                     component.set("v.preferredContAccs", response.getReturnValue());
                }
                else
                {
                    console.log('empty');
                      component.set("v.preferredContAccs",null);
                  
                }
            }
        });
        $A.enqueueAction(action);
    },
    fetchAccount : function(component,srctxt)
    {
        var action = component.get("c.getAccount"); //Calling Apex class controller 'EventDetailMethod' method
        action.setParams({
            sEventcode : '',//As it is not event dependent
            srchText : srctxt
        });
        action.setCallback(this, function(response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS") 
            {
                var acc=response.getReturnValue();
                if(acc)
                {
                    $('#addCompany').prop('disabled', true);
                }
                else
                {
                    $('#addCompany').prop('disabled', false);
                }
                component.set("v.srchAcc", acc);// Adding values in Aura attribute variable.
            }
        });
        $A.enqueueAction(action);
	},
	fetchContactById : function(component,cid) {
        var action = component.get("c.getContactByID"); //Calling Apex class controller 'EventDetailMethod' method
        action.setParams({
            contactId : cid
        });
        action.setCallback(this, function(response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS")
            {
                var newcon=component.get("v.newContact");
                newcon.Id=response.getReturnValue().Id;
		    	newcon.FirstName=response.getReturnValue().FirstName;
		    	newcon.LastName=response.getReturnValue().LastName;
				newcon.Phone=response.getReturnValue().Phone;
				newcon.MobilePhone=response.getReturnValue().MobilePhone;
		    	newcon.Email=response.getReturnValue().Email;
		    	newcon.MobilePhone=response.getReturnValue().MobilePhone;
				component.set("v.newContact",newcon);
				component.set("v.FirstName", false);
                component.set("v.LastName", false);
                component.set("v.Email", false);
                component.set("v.Phone", false);
                component.set("v.MobilePhone", false);
                if(newcon.FirstName){
                    component.set("v.FirstName", true);
                }
                if(newcon.LastName){
                    component.set("v.LastName", true);
                }
                if(newcon.Email){
                    component.set("v.Email", true);
                }
                if(newcon.Phone){
                    component.set("v.Phone", true);
                }
                if(newcon.MobilePhone){
                    component.set("v.MobilePhone", true);
                }
		    	document.getElementById('modalAddContact').style.display = "block";
            }
        });
        $A.enqueueAction(action);
	},
	fetchDuplicateContact : function(component,services) {
		var action = component.get("c.getDuplicateContacts"); //Calling Apex class controller 'EventDetailMethod' method
        action.setParams({
            con : component.get("v.newContact")
        });
        action.setCallback(this, function(response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS")
            {
				if(response.getReturnValue().length)
				{
					component.set("v.existingCons",response.getReturnValue());
					// Enable Button here !
					$('#btninvite').each(function(){$(this).val('').removeAttr("disabled");});
				}
				else{
					this.createContactHelper(component,services); 
				}
            }
        });
        $A.enqueueAction(action);
	},
	createContactHelper : function(component,services) {
		var boothIds = [];
		boothIds.push(component.get("v.selectedBooth").Id);
		var newCon= component.get("v.newContact");
		newCon.Contact_Type__c='Stand Contractor';
		var eId = component.get("v.eventId");
        var action = component.get("c.createContactandMapping"); //Calling Apex class controller 'EventDetailMethod' method
        action.setParams({ 
            con : newCon,
            sEventId:eId,
            tempAccount:newCon.TempAccountId,
            lstBoothIds:boothIds,
            lstServices:services
        });
        action.setCallback(this, function(response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS")
            {
				$('#btninvite').each(function(){$(this).val('').removeAttr("disabled");});
				
				$('#modalAddContact').hide();
                $('#ccountryRelatedToISD').hide();
				if(response.getReturnValue()=='success')
				{
					//if(services.length>0 && newCon.FirstName)
					$('#modalContactSuccess').show();
					$('#modalCont').hide();
					this.fetchExhibitors(component);
				}
				else if(response.getReturnValue()=='error'){
					$('#modalAlreadyExists').show();
					var con=newCon;
            		if(con.TempAccountId)this.deleteAccount(component);
				}
            }
        });
        $A.enqueueAction(action);
	},
	deleteAccount : function(component) {
		var con=component.get("v.newContact");
		if(con.TempAccountId){
			var action = component.get("c.deleteTempAccount"); //Calling Apex class controller 'EventDetailMethod' method
			action.setParams({
				tempAccId : con.TempAccountId
			});
			action.setCallback(this, function(response) {
				var state = response.getState(); //Checking response status
				if (component.isValid() && state === "SUCCESS") 
				{
				}
			});
			$A.enqueueAction(action);
		}
	},
	resetContact : function(component) {
		var newcon=component.get("v.newContact");
		newcon.FirstName='';
		newcon.LastName='';
		newcon.Phone='';
		newcon.PhoneCountryCode='';
		newcon.PhoneStateCode='';
		newcon.Ext='';
		newcon.AccountName='';
		newcon.MobilePhone='';
		newcon.MobilePhoneCountryCode='';
		newcon.MobilePhoneStateCode='';
		newcon.Email='';
		newcon.AccountId='';
		newcon.Id='';
    	component.set("v.newContact",newcon);
    	$(".chkbx").each(function(){
		    var $this = $(this);
		    if($this.is(":checked")){
		       $this.attr("checked",false)
		    }
		});
		$("#btnno").attr("checked",true);
		// component.set("v.isForAllBooth",'No');
		component.set("v.existingCons",null);
	},
	fetchPicklistValues : function (component, objName, field ,componentName,deafultValue ) {
        var action = component.get('c.getPicklistValues');
        action.setParams({
            objApi:objName,
            fieldName:field
        });
        action.setCallback(this, function (res) {
            var state = res.getState()
            var result=res.getReturnValue();                       
            if (component.isValid() && state === 'SUCCESS') {
                var opts=[];    
                if(deafultValue) 
                {
                    opts.push({label: deafultValue, value:'All'});
                }   
                for(var i=0;i< result.length;i++){
                    opts.push({label: result[i].split('__$__')[0], value: result[i].split('__$__')[1]});
                }              
                // Adding values in Aura attribute variable. 
                var Cmp = component.find(componentName);
                if(Cmp)
                {
                    Cmp.set("v.options",opts); // Adding values in Aura attribute variable.
                } 
                
                              
            }
        })
        $A.enqueueAction(action)
	},
    fetchRealtedIsdValues: function (component,ccountryCode,componentName,deafultValue) {
       var action = component.get('c.getDepndentCustomVal');
        action.setParams({
            cCountryCode:ccountryCode,
        });
        action.setCallback(this, function (res) {
            var state = res.getState()
            var result=res.getReturnValue();
            if (component.isValid() && state === 'SUCCESS') {
                if(result.length>0)
                {
                   var Cmp = component.find(componentName);
                    if(Cmp)
                    {
                        Cmp.set("v.value",result); // Adding values in Aura attribute variable.
                    } 
                }
                else
                {
                   var Cmp = component.find(componentName);
                    if(Cmp)
                    {
                        Cmp.set("v.value",deafultValue); // Adding values in Aura attribute variable.
                    }  
                }
            }
        })
        $A.enqueueAction(action)  
    },
     fetchCoutryNameRealtedIsdValues: function (component,cCountryName,componentName,deafultValue) {
       var action = component.get('c.getCountryRelatdCode');
        action.setParams({
            cCountryName:cCountryName,
        });
        action.setCallback(this, function (res) {
            var state = res.getState()
            var result=res.getReturnValue();
            if (component.isValid() && state === 'SUCCESS') {
                if(result)
                {
                   var Cmp = component.find(componentName);
                    if(Cmp)
                    {
                        Cmp.set("v.value",result); // Adding values in Aura attribute variable.
                    } 
                }
                else
                {
                   var Cmp = component.find(componentName);
                    if(Cmp)
                    {
                        Cmp.set("v.value",deafultValue); // Adding values in Aura attribute variable.
                    }  
                }
            }
        })
        $A.enqueueAction(action)  
    },
	onControllerFieldChange: function(component,controllerValueKey) {   
		
		var depnedentFieldMap = component.get("v.depnedentFieldMap");
		var opts=[];       
		opts.push({label: '--Select--', value: ''});
         
        if (controllerValueKey) {
            var ListOfDependentFields = depnedentFieldMap[controllerValueKey];
            
            if(ListOfDependentFields.length > 0){
            	component.set("v.hasNoState" , false); 
				
    			for(var i=0;i< ListOfDependentFields.length;i++){
     				opts.push({label: ListOfDependentFields[i].split('__$__')[0], value: ListOfDependentFields[i].split('__$__')[1]});
				}
				//component.find('billingState').set("v.options",opts); // Adding values in Aura attribute variable.
            }else{
                component.set("v.hasNoState" , true); 
            }  
            
        } else {
            component.set("v.hasNoState" , true);
        }
        var Cmp = component.find('billingState');
        if(Cmp)
        {
            Cmp.set("v.options",opts); // Adding values in Aura attribute variable.
        } 
	},
	fetchDependentPicklistValues : function(component,objApi,contrfieldApiName,depfieldApiName) {
		component.set("v.isSpinner", true);
		var action = component.get("c.getDependentMap"); //Calling Apex class controller 'EventDetailMethod' method
	   action.setParams({
		   objApi : objApi,
		   contrfieldApiName : contrfieldApiName,
		   depfieldApiName : depfieldApiName
	   });
	   action.setCallback(this, function(response) {
		   var state = response.getState(); //Checking response status
		   if (component.isValid() && state === "SUCCESS") 
		   {
				//store the return response from server (map<string,List<string>>)  
				var StoreResponse = response.getReturnValue();
				// once set #StoreResponse to depnedentFieldMap attribute 
                component.set("v.depnedentFieldMap",StoreResponse);
                component.set("v.dataLoadedOnce",true);
		   }
		   component.set("v.isSpinner", false);
	   });
	   $A.enqueueAction(action);
   }, 
   createAccountHelper : function(component ,cuntryCode) {
		var action = component.get("c.createTempAccount"); //Calling Apex class controller 'EventDetailMethod' method
		action.setParams({
			acc : component.get("v.newAccount")
		}); 
		action.setCallback(this, function(response) {
			var state = response.getState(); //Checking response status
			if (component.isValid() && state === "SUCCESS") 
			{
				var tempAccount = response.getReturnValue();
				if(tempAccount.success)
				{
					component.set("v.message",'');
					this.resetContact(component);
					var con=component.get("v.newContact");
					con.AccountName=tempAccount.success.Name;
					con.TempAccountId=tempAccount.success.Id;
					component.set("v.newContact",con);
					
					this.resetAccount(component);
					this.fetchRealtedIsdValues(component ,cuntryCode ,'InputPhoneIsd1','-ISD-');
					this.fetchRealtedIsdValues(component ,cuntryCode ,'InputMobileIsd1','-ISD-');
					document.getElementById('modalCompany').style.display = "none";
					//document.getElementById('modalAddContact').style.display = "block";
					document.getElementById('ccountryRelatedToISD').style.display = "block";
				}
				else
				{
					component.set("v.existingAcc", {Name:tempAccount.error.Name});
					//component.set("v.isWarnOpen",true);
					//component.set("v.message",'Company already exists. Please click the cancel button below and search through the list of exhibitors.<a onclick="test()">Select</a>');
				}	
			}
		});
		$A.enqueueAction(action);
	},
	resetAccount : function(component) {
		var newcom=component.get("v.newAccount");
		newcom.Name ='';
		newcom.BillingStreet='';
		newcom.BillingPostalCode ='';
		newcom.BillingCity='';
		newcom.BillingCountry='';
		newcom.BillingState='';
		component.set("v.newAccount",newcom);
		component.set("v.hasNoState" , true);
    	$('#srchCompany').val('');
	},
    convertArrayOfObjectsToCSV : function(component,objectRecords){
        // declare variables
        var csvStringResult, counter, keys, columnDivider, lineDivider;
       
        // check if "objectRecords" parameter is null, then return from function
        if (objectRecords == null || !objectRecords.length) {
            return null;
         }
        // store ,[comma] in columnDivider variabel for sparate CSV values and 
        // for start next line use '\n' [new line] in lineDivider varaible  
        columnDivider = ',';
        lineDivider =  '\n';
 
        // in the keys valirable store fields API Names as a key 
        // this labels use in CSV file header  
        var map = new Map();
        map.put('Opportunity__r.Account.Name' , 'EXHIBITOR Name');
        map.put('Display_Name__c','Exhibiting Name');
        map.put('Opportunity__r.Operations_Contact__r.Email' , 'EMAIL');        
        map.put('Opportunity__r.Operations_Contact__r.Phone' , 'PHONE NUMBER');
        map.put('Opportunity__r.Operations_Contact__r.MobilePhone','MOBILE NUMBER');
        map.put('Booth_Number__c','STAND#');
        map.put('Matched_Product_Name__c','BOOTH PRODUCT TYPE');
        keys= Array.from(map.keys());
        csvStringResult = '';       
        csvStringResult += Array.from(map.values()).join(columnDivider);
        csvStringResult += lineDivider;
        for(var i=0; i < objectRecords.length; i++){   
            counter = 0;
            keys.forEach(function(skey){
              	 var subKeys=[];
                 var cellVal=objectRecords[i];
                 if(skey.includes('.') ){
                     subKeys = skey.split('.');   
                 }
                 
                 if(subKeys.length > 0){
                     for(var z=0; z<subKeys.length;z++){
                     	 cellVal=cellVal[subKeys[z]]; 
                     }
                 }else{
                     cellVal=objectRecords[i][skey];
                 }
                  if(counter > 0){ 
                      
                      csvStringResult += columnDivider; 
                   }   
               
               csvStringResult += '"'+ cellVal+'"'; 
               
               counter++;  
            });
             // inner for loop close 
             csvStringResult += lineDivider;
          }// outer main for loop close 
       // return the CSV formate String 
        return csvStringResult.replace(/undefined|FALSE/gi,'');        
    },
    
    //BK -2173

    getDesignationInfos: function(component) {
        
        var action = component.get("c.getDesignationInfo"); 
        var eventId = component.get("v.eventId"); 
        action.setParams({ sEventId:eventId});
        action.setCallback(this, function(res)
        {
            var state = res.getState();
            if (state === "SUCCESS")
            {                     
                component.set("v.designationInfo", res.getReturnValue());
            }else
            {                 
                console.log('ERROR!');
            }
        });
        
        $A.enqueueAction(action); 
    },
    
    getAggregateResults: function(component) {
        var action = component.get("c.getAggregateResult"); 
        var eventId = component.get("v.eventId");
        action.setParams({ sEventId:eventId});
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") { 
              component.set("v.aggregateResults", res.getReturnValue());
            }
            else
            {
                component.set("v.isSpinner", false);// Adding values in Aura attribute variable.   
                var errors = res.getError();
                if (errors) {
                if (errors[0] && errors[0].message) {
                    console.log("Error message: " + errors[0].message);
                }
                }
            } 
        });
        $A.enqueueAction(action); 
    },
    
    scrollFun: function(component){
          var sticky = 350;
        window.onscroll = function() {
            var mapTableDataWidth = new Map([['exhBoothNum','100'],['exhOppAccName','100'],['exhOppContEmail','100'],['exhOppContPhone','100'],['exhOppContMobile','100'],['exhNum','100'],['exhBoothTyp','100'],['exhNote','100'],['exhDesignate','100']]);                             
            if (window.pageYOffset > sticky)
            {

                document.getElementById("myHeader").classList.add("sticky");
                
       
                for(var key of mapTableDataWidth.keys())
		        {
                    try
                    {
                        var wdth = document.getElementById(key);
                        mapTableDataWidth.set(key,wdth.offsetWidth);
                    } catch(err) 
                    {
                        console.log('ERR :- '+err.message);
                    }                    
                }
       
				var mapFinalWidth = new Map([['Opportunity__r.Account.Name','exhBoothNum'],['Display_Name__c','exhOppAccName'],['Opportunity__r.Operations_Contact__r.Email','exhOppContEmail'],['Opportunity__r.Operations_Contact__r.Phone','exhOppContPhone'],['Opportunity__r.Operations_Contact__r.MobilePhone','exhOppContMobile'],['Booth_Number__c','exhNum'],['Matched_Product_Name__c','exhBoothTyp'],['thNotes','exhNote'],['thHead','exhDesignate']]);
				for(var key of mapFinalWidth.keys())
		        {
                    try
                    {    var width = mapFinalWidth.get(key);
                     	mapFinalWidth.set(key,mapTableDataWidth.get(width));
                     document.getElementById(key).style.width  = mapFinalWidth.get(key)+"px"; 
                    } catch(err) 
                    {
                        console.log('ERR :- '+err.message);
                    }                    
                }                 
                  
            }else 
            {
                document.getElementById("myHeader").classList.remove("sticky");
            }
        };   
    },
    
      fetchMatchProductOptionsPicklistValues : function (component, objName, field ,componentName,deafultValue ) {
        var action = component.get('c.getPicklistValues');
        action.setParams({
            objApi:objName,
            fieldName:field
        });
        action.setCallback(this, function (res) {
            var state = res.getState()
            var result=res.getReturnValue();                       
            if (component.isValid() && state === 'SUCCESS') {
                var opts=[];    
                if(deafultValue) 
                {
                    opts.push({label: deafultValue, value:'All'});
                }   
                for(var i=0;i< result.length;i++){
                    opts.push({label: result[i].split('__$__')[0], value: result[i].split('__$__')[1]});
                }
                component.set('v.matchingProductOptions', opts);
                              
            }
        })
        $A.enqueueAction(action)
	},
    
})