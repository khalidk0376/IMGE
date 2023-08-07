({
    getOrgType:function(component){
        //isSandbox  
        var action = component.get("c.isSandbox");
      action.setCallback(this, function(res) {
          component.set("v.isSandbox",res.getReturnValue());
      });
      $A.enqueueAction(action);        
    },
	fetchBoothMaps : function(component) {        
        var eventId = component.get("v.EventId");
        var selectedValue = component.get("v.selectedValue");
        //console.log('selectedValue ' + selectedValue);
        var action = component.get("c.getAllContractor"); //Calling Apex class controller 'getAllContractor' method
        action.setParams({
            sEventId : eventId,
            sStatus: selectedValue 
        });
        action.setCallback(this, function(response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS") 
            {
                // console.log('fetchBoothMaps'+JSON.stringify(response.getReturnValue()));
                this.createBthMaplist(component,response.getReturnValue());        
                component.set("v.boothMap", response.getReturnValue());// Adding values in Aura attribute variable.               
            }
        });
        $A.enqueueAction(action);
    },
    createBthMaplist: function(component, DataList)
    {
        var bthmpList = [];
        if(DataList && DataList.length)
        {    
                    
            for(var i=0;i<DataList.length;i++)
            {
                try{
                    var BoothCmp =
                    {
                        Id                          : DataList[i].Id,
                        DateSubmitted               : DataList[i].CreatedDate,
                        DateApproved                : '',                                        
                        Customer                    : '',
                        Type                        : '',
                        ExhibitingName              : '',
                        Booth                       : '',
                        BoothProductType            : '',
                        ContractorCompany           : '',
                        Contact                     : '',                   
                        Status                      : '',
                        AgentName                   : '',
                        AgentAccId                  : '',
                        IsAgentManaged              : DataList[i].IsManagedbyAgent__c,
                        IsTmpAcc                    : false,
                        IsTmpCon                    : false,
                        IsApproved                  : false
                    };
                    if(DataList[i].Approval_Date__c)
                    {
                        BoothCmp.DateApproved =  DataList[i].Approval_Date__c;
                    }
                    if(DataList[i].IsManagedbyAgent__c == true)
                    {
                        BoothCmp.Customer = this.capitalizeFirstLetter(DataList[i].Agent_Contact__r.Account.Name);
                        BoothCmp.AgentName = DataList[i].Agent_Contact__r.Account.Name;
                        BoothCmp.AgentAccId = DataList[i].Agent_Contact__r.AccountId;
                        BoothCmp.Type = 'Agent';
                        BoothCmp.BoothProductType = 'Agent Pavilion Space';
                        BoothCmp.ExhibitingName = this.capitalizeFirstLetter(DataList[i].Agent_Contact__r.Account.Name);
                    }else
                    {
                        BoothCmp.Customer           = this.capitalizeFirstLetter(DataList[i].Opp_Booth_Mapping__r.Opportunity__r.Account.Name)
                        BoothCmp.Type               = DataList[i].Opp_Booth_Mapping__r.Opportunity__r.User_Type__r.Name;
                        BoothCmp.ExhibitingName     = this.capitalizeFirstLetter(DataList[i].Opp_Booth_Mapping__r.Display_Name__c);
                        BoothCmp.Booth              = DataList[i].Opp_Booth_Mapping__r.Booth_Number__c;                        
                        if(!DataList[i].Opp_Booth_Mapping__r.Display_Name__c)
                        {
                            BoothCmp.ExhibitingName = this.capitalizeFirstLetter(DataList[i].Opp_Booth_Mapping__r.Opportunity__r.Account.Name);
                        }
                        if(DataList[i].Opp_Booth_Mapping__r.Expocad_Booth__r.Matched_Product_Name__c)
                        {
                            BoothCmp.BoothProductType   = DataList[i].Opp_Booth_Mapping__r.Expocad_Booth__r.Matched_Product_Name__c;
                        }
                    }
                    if(DataList[i].Approved__c == false && DataList[i].Status__c == 'Rejected')
                    {                        
                        BoothCmp.Status             = 'Rejected';
                    }else
                    {
                        if(DataList[i].Approved__c == true)
                        {
                            BoothCmp.IsApproved = true;
                            BoothCmp.Status             = 'Approved'; 
                        }else
                        {
                            BoothCmp.Status             = 'New';
                        }                                                
                    }

                    if(!DataList[i].Contact__r && DataList[i].TempContact__r)
                    {
                        if(DataList[i].TempContact__r.Name__c)
                        {
                            BoothCmp.IsTmpCon             = true;
                            BoothCmp.Contact              = this.capitalizeFirstLetter(DataList[i].TempContact__r.Name__c);
                        }
                        if(DataList[i].TempContact__r.Account__r && DataList[i].TempContact__r.Account__r.Name)
                        {
                            BoothCmp.ContractorCompany    = this.capitalizeFirstLetter(DataList[i].TempContact__r.Account__r.Name);
                        }else
                        {
                            if(DataList[i].TempContact__r.TempAccount__r && DataList[i].TempContact__r.TempAccount__r.Name)
                            {
                                BoothCmp.IsTmpAcc             = true;
                                BoothCmp.ContractorCompany    = this.capitalizeFirstLetter(DataList[i].TempContact__r.TempAccount__r.Name);
                            }
                        }
                    }else 
                    {
                        BoothCmp.Contact                = this.capitalizeFirstLetter(DataList[i].Contact__r.Name);
                        BoothCmp.ContractorCompany      = this.capitalizeFirstLetter(DataList[i].Contact__r.Account.Name);
                    }
                    bthmpList.push(BoothCmp);
                }
                catch(err) 
                {
                    console.log('There Was A error While Parsing BTHID :-  '+DataList[i].Id+ '   And ERR Msg :-   '+ err.message);
                }
            }            
        }
        //console.log(' LIST DATA  :-   '+ JSON.stringify(bthmpList)); 
        component.set("v.allContractorData",bthmpList);
    },
    capitalizeFirstLetter :function (string) 
    {
        var val= '';
        if(string)
        {
            val = string.charAt(0).toUpperCase() + string.slice(1);  
        }
        return val;
    },
    singleRecord: function(component, event, vSingleId) {
        var action = component.get("c.getSingleApprovalRequest"); //Calling Apex class controller 'getSingleApprovalRequest' method
        action.setParams({
            singleId: vSingleId
        });
        action.setCallback(this, function(res)
        {
            var state = res.getState();
            if (state === "SUCCESS") {
                var data = res.getReturnValue();
                component.set("v.singleBooth", data);// Adding values in Aura attribute variable.
               //console.log('data'+JSON.stringify(res.getReturnValue()));     
            } 
        });
        $A.enqueueAction(action);
    },
    approvalprocess : function(component, event, vSingleId, singleBth) {
        var action = component.get("c.updateTmpAccountContact"); //Calling Apex class controller 'getapproveContractor' method
        //console.log('vSingleId===='+vSingleId);
        var requestedBy= 'Exhibitor';
        action.setParams({
            sIds: vSingleId,
            singleBth: singleBth
        });
        action.setCallback(this, function(res)
        {
            var state = res.getState();
            if (state === "SUCCESS") {
                //console.log('success');
                var data = res.getReturnValue();
                component.set("v.StatusMSG", data);
                document.getElementById('InfoMSG').style.display = "block";
                //alert(data);
            } 
        });
        $A.enqueueAction(action);
    },
    rejectprocess : function(component, event, vSingleId)
    {
        var sendmail    = component.get("v.sendRejectMail");
        var notes       = component.get("v.RejectNote");
        
        var action = component.get("c.rejectContarctor"); //Calling Apex class controller 'rejectContarctor' method  [CCEN-421]      
        action.setParams({
            sIds: vSingleId,
            notes: notes,
            sendMail:sendmail
        });
        action.setCallback(this, function(res)
        {
            var state = res.getState();
            if (state === "SUCCESS")
            {   
                //console.log(res.getReturnValue()); 
                formTab.showToast(component,'success',res.getReturnValue());  
            }else
            {
                console.log('Error state = ' +state );
            }
            this.fetchBoothMaps(component);
        });        
        $A.enqueueAction(action);
    },
    getContractorbyStatus: function(component, event, selectedValue) {
        var eventId = component.get("v.EventId");  
        //console.log( 'selectedValue == '+selectedValue ) ;        
        var action = component.get("c.getAllContractor"); //Calling Apex class controller 'getAllContractor' method
        action.setParams({
            sEventId    : eventId,
            sStatus     : selectedValue    
        });       
        action.setCallback(this, function(res)
        {
            var state = res.getState();
            if (state === "SUCCESS") {   
                //console.log('getContractorbyStatus =  '+JSON.stringify(res.getReturnValue()));  
                this.createBthMaplist(component,res.getReturnValue());        
                component.set("v.boothMap", res.getReturnValue());                
            }else
            {
                console.log('state = ' +state );
            }
        });
        $A.enqueueAction(action);
    },
    fetchPavilionSpaceExhibitors: function (component) {
        var srchTxt = component.get("v.searchText");
        var sEventId = component.get("v.EventId");
        var Agent = component.get("v.CurrentAgent");
        //console.log(Agent.Id + '      fetchPavilionSpaceExhibitors    ' + srchTxt);
        var action = component.get("c.getAgentBooths"); //Calling Apex class controller 'getAgentBooths' method
        action.setParams({
            sEventId: sEventId,
            accid: Agent.Id,
            srchText: srchTxt
        });
        action.setCallback(this, function (response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS") {
                var result = response.getReturnValue();
                //console.log('fetchPavilionSpaceExhibitors'+JSON.stringify(response.getReturnValue()));
                component.set("v.AgentsExhibitors",result);// Adding values in Aura attribute variable.Agents-Exhibitors
                document.getElementById('Agent_Exhibitormodel').style.display = "block";
            }
            else {
                component.set("v.AgentsExhibitors", []);
                console.log('Some Error Occured!');
            }
        });
        $A.enqueueAction(action);
    },
    sortData: function (component, fieldName, sortDirection) {
  
      //console.log('fieldName ==== '+ fieldName +' sortDirection === '+sortDirection);
      var data = component.get("v.allContractorData"); //Calling Apex class controller 'allContractorData' method
      var reverse = sortDirection !== 'asc';
      data.sort(this.sortBy(fieldName, reverse))
      component.set("v.allContractorData", data);
    },
    sortBy: function (field, reverse, primer) {
      var key = primer ?
      function(x) {return primer(x[field])} :
      function(x) {return x[field]};
      reverse = !reverse ? 1 : -1;
      return function (a, b) {
      return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
      }
    },
    fetchDependentPicklistValues : function(component,objApi,contrfieldApiName,depfieldApiName) {
        component.set("v.Spinner", true);
        var action = component.get("c.getDependentStateMap"); //Calling Apex class controller 'getDependentStateMap' method [CCEN-682]
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
                //console.log('result ' +JSON.stringify(response.getReturnValue()));
                var StoreResponse = response.getReturnValue();
                // once set #StoreResponse to depnedentFieldMap attribute 
                component.set("v.dependentFieldMap",StoreResponse);
           }
           component.set("v.Spinner", false);
       });
       $A.enqueueAction(action);
    }, 
    onControllerFieldChange: function (component, controllerValueKey) {
        var dependentFieldMap = component.get("v.dependentFieldMap");
        var opts = [];
        opts.push({ label: '--Select--', value: '' });
        
        if (controllerValueKey && dependentFieldMap != null) {

            var ListOfDependentFields = dependentFieldMap[controllerValueKey];
            
            if (ListOfDependentFields && ListOfDependentFields.length > 0)
            {
                component.set("v.hasNoState", false);
                for (var i = 0; i < ListOfDependentFields.length; i++)
                {
                    opts.push({ label: ListOfDependentFields[i].split('__$__')[0], value: ListOfDependentFields[i].split('__$__')[1] });
                }
            } else 
            {
                component.set("v.hasNoState", true);
            }            
        } else {
            component.set("v.hasNoState", true);
        }
        var Cmp = component.find('dptStateField');
        if(Cmp)
        {
            Cmp.set("v.options",opts); // Adding values in Aura attribute variable.
        } 
    },
    fetchPicklistValues: function (component, objName, field, componentName, deafultValue) {
        var action = component.get('c.getPicklistValues'); //Calling Apex class controller 'getPicklistValues' method [CCEN-682]
        action.setParams({
            objApi: objName,
            fieldName: field 
        });
        action.setCallback(this, function (res) {
            var state = res.getState()
            var result = res.getReturnValue(); 
            //console.log('adadadad--s'+JSON.stringify(result));
            if (component.isValid() && state === 'SUCCESS') {
                var opts = [];
                opts.push({ label: deafultValue, value: '' });
                for (var i = 0; i < result.length; i++) {
                    opts.push({ label: result[i].split('__$__')[0], value: result[i].split('__$__')[1] });
                }
                var Cmp = component.find(componentName);
                if(Cmp)
                {
                    Cmp.set("v.options",opts); // Adding values in Aura attribute variable.
                }
            }
        })
        $A.enqueueAction(action);
    },
    fetchDuplicateContact : function(component) {
        component.set("v.existingAcc", null);
        var bthMapping = component.get("v.singleBooth");
        var newCon = component.get("v.newContact");
        newCon.FirstName = bthMapping[0].TempContact__r.FirstName__c;
        newCon.LastName = bthMapping[0].TempContact__r.LastName__c;
        newCon.Phone = bthMapping[0].TempContact__r.Phone__c;
        newCon.MobilePhone = bthMapping[0].TempContact__r.MobilePhone__c;
        newCon.Email = bthMapping[0].TempContact__r.Email__c;
        component.set("v.newContact", newCon);
        var action = component.get("c.getDuplicateContacts"); //Calling Apex class controller 'getDuplicateContacts' method [CCEN-682]
        action.setParams({
            con : newCon
        });
        action.setCallback(this, function(response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS")
            {
                if(response.getReturnValue().length)
                {
                    component.set("v.existingCons",response.getReturnValue());
                }
                else{
                    document.getElementById('Confirm').style.display = "block"; 
                    document.getElementById('approveModal').style.display = "none";
                }
            }
        });
        $A.enqueueAction(action);
    },
    fetchDuplicateAccount : function(component) 
    {
        var bthMapping = component.get("v.singleBooth");
        var eventId = component.get("v.EventId");
        var duplicateAccName = bthMapping[0].TempContact__r.TempAccount__r.Name;
        var action = component.get("c.getDuplicateAccount"); //Calling Apex class controller 'getDuplicateAccount' method [CCEN-682]
        action.setParams({
            sEventcode : eventId,
            srchText : duplicateAccName
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue(); //Checking response status
            if (component.isValid() && state === "SUCCESS")
            {
                if(result)
                {
                    component.set("v.existingAcc",response.getReturnValue());
                }
                else{
                    this.fetchDuplicateContact(component);
                }
            }
            else{
                this.fetchDuplicateContact(component);
            }
        });
        $A.enqueueAction(action);
    },
    validateEditFeilds : function(component) 
    {
        var clickAcc = component.get("v.clickAccount");
		var feildCmp = component.find('editReqFeilds');
        var allValid = false;
        var addValid = false;
        if(clickAcc){
            var adreessFild = component.find('ediAddFeild');
            var val = adreessFild.get("v.value");
            if(val.length>60){
                document.getElementById('moreThen60').style.display ="block"; 
            }
            else{
                document.getElementById('moreThen60').style.display = "none"; 
                addValid=true; 
            }
        }
		if(feildCmp)
        {
            if(feildCmp.length)
            {
                allValid = component.find('editReqFeilds').reduce(function (validSoFar, inputCmp)
                {
                    inputCmp.showHelpMessageIfInvalid();
                    return validSoFar && inputCmp.get('v.validity').valid;
                }, true);
            }else
            {
                allValid = feildCmp.get('v.validity').valid;
            }
        }
       	else
        {
            allValid = true;
        }		
        
        if(allValid ==true && clickAcc==true){
            return addValid;
        }
        else{
            return allValid
        }
    }
})