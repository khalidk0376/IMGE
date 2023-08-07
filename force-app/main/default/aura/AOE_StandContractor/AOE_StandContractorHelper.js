({
    getUserType: function (component) {
        var sEventCode = component.get("v.eventcode");
        var action = component.get("c.getCurrentUserType"); //Calling Apex class controller 'getCurrentUserType' method
        action.setParams({
            sEventcode: sEventCode
        });
        action.setCallback(this, function (response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS") {
                var result = response.getReturnValue();
                var usertype = result.User_Type__r.Name;
                //console.log('usertype ===== '+usertype);
                component.set("v.currentUser", result); 
                if (usertype == 'Agent Owned Exhibitor' || usertype == 'Agent')
                {
                    //component.set("v.isAgentOwnExhibitor", true);// Adding values in Aura attribute variable.
                }
            }
        });
        $A.enqueueAction(action);
        
    },
    fetchEventDetails: function (component) {
        var sEventCode = component.get("v.eventcode");
        var action = component.get("c.getEventDetails"); //Calling Apex class controller 'getEventDetails' method
        action.setParams({
            sEventcode: sEventCode
        });
        action.setCallback(this, function (response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS")
            {
                //console.log('fetchEventDetails'+JSON.stringify(response.getReturnValue()));
                component.set("v.Event_Setting", response.getReturnValue());// Adding values in Aura attribute variable.
            }else
            {
                console.log('state : '+state);
            }
        });
        $A.enqueueAction(action);
    },
    fetchAccountContacts: function (component, srctxt) {
        var sEventCode = component.get("v.eventcode");
        var action = component.get("c.getAccountContacts"); //Calling Apex class controller 'getAccountContacts' method
        action.setParams({
            sEventcode: sEventCode,
            srchText: srctxt
        });
        action.setCallback(this, function (response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS") {
                //console.log('fetchAccountContacts'+JSON.stringify(response.getReturnValue()));
                component.set("v.accs", response.getReturnValue());// Adding values in Aura attribute variable.
                //console.log(JSON.stringify(component.get("v.accs")));
            }
        });
        $A.enqueueAction(action);
    },
    fetchAccount: function (component, srctxt) {
        var sEventCode = component.get("v.eventcode");
        var action = component.get("c.getAccount"); //Calling Apex class controller 'getAccount' method
        action.setParams({
            sEventcode: sEventCode,
            srchText: srctxt
        });
        action.setCallback(this, function (response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS") {
                var acc=response.getReturnValue();
                //console.log('fetchAccount'+JSON.stringify(acc));
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
    fetchServices: function (component) {
        var sEventCode = component.get("v.eventcode");
        var action = component.get("c.getServices"); //Calling Apex class controller 'getServices' method
        action.setParams({
            sEventcode: sEventCode
        });
        action.setCallback(this, function (response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS") {
                //console.log('fetchServices'+JSON.stringify(response.getReturnValue()));
                component.set("v.services", response.getReturnValue());// Adding values in Aura attribute variable.
            }
        });
        $A.enqueueAction(action);
    },
    fetchBoothsMap: function (component)
    {
        component.set("v.Spinner", true);
        var sEventCode = component.get("v.eventcode");
        var aoeACCId = component.get("v.AOEAccountID");
        var action = component.get("c.getAOEBoothsMapping"); //Calling Apex class controller 'getAOEBoothsMapping' method
        action.setParams({
            sEventcode: sEventCode,
            accId : aoeACCId
        });
        action.setCallback(this, function (response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS")
            {
                //console.log('fetchBoothsMap ====   '+JSON.stringify(response.getReturnValue()));
                var custs = [];
                var conts = response.getReturnValue();
                //console.log('lastUpdateObj  ==== '+JSON.stringify(conts));
                var lastUpdateObj = {UpdateDate:new Date(), UpdateName:" ",isactive:false};
                for (var key in conts) 
                {
                    var data = key.split('_$_');
                    var bothMaps = conts[key];
                    if (bothMaps && bothMaps.length)
                    {
                        bothMaps[0].tot = bothMaps.length;
                        if(lastUpdateObj.isactive == false && bothMaps[0])
                        {
                            lastUpdateObj.UpdateDate =  bothMaps[0].CreatedDate;
                            lastUpdateObj.UpdateName =  bothMaps[0].CreatedBy.Name;
                            lastUpdateObj.isactive   =  true;
                        }
                        for(var j=0;j<bothMaps.length;j++)
                        {
                            if(lastUpdateObj.UpdateDate < bothMaps[j].CreatedDate)
                            {
                                lastUpdateObj.UpdateDate =  bothMaps[j].CreatedDate;
                                lastUpdateObj.UpdateName =  bothMaps[j].CreatedBy.Name;
                            }
                        }
                    }
                    var producttype = data[2];
                    var boothproductType = producttype;
                    if(producttype && (producttype.indexOf('Pavilion Space') != -1 && producttype.indexOf('Space Only') == -1) || (producttype.includes('Pavilion Space') && !producttype.includes('Space Only')))
                    {
                        boothproductType = 'Pavilion Space';
                    }
                    custs.push({ value: bothMaps, boothId: data[1], booth: data[0], boothType: boothproductType });
                    
                }
                console.log('lastUpdateObj  ==== '+JSON.stringify(lastUpdateObj)); 
                component.set("v.modificationDetails", lastUpdateObj);
                component.set("v.lstbooths", custs);  //Used for CCEN-336
                //console.log('fetchBoothsMap'+custs.length);                
            }else
            {
                console.log('state : '+state);
            }
            component.set("v.Spinner", false);
        });
        $A.enqueueAction(action);
    },
    fetchDuplicateContact: function (component, services) {
        //console.log('fetchDuplicateContact called');
        //console.log('fetchDuplicateContact'+JSON.stringify(component.get("v.newContact")));
        var action = component.get("c.getDuplicateContacts"); //Calling Apex class controller 'getDuplicateContacts' method
        action.setParams({
            con: component.get("v.newContact")
        });
        action.setCallback(this, function (response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS") {
                //console.log('fetchDuplicateContact'+JSON.stringify(response.getReturnValue()));
                if (response.getReturnValue().length) {
                    //console.log('duplicate contact found'); 
                    component.set("v.existingCons", response.getReturnValue());
                }
                else {
                    this.createContactHelper(component, services);
                }
            }
        });
        $A.enqueueAction(action);
    },
    createContactHelper: function (component, services) {
        var boothIds = [];
        var ForAllBooth = component.get("v.isForAllBooth");
        //console.log('ForAllBooth'+ForAllBooth);
        if (ForAllBooth == 'Yes') {
            var booths = component.get("v.lstbooths");
            //console.log('booths'+JSON.stringify(booths));
            for (var i = 0; i < booths.length; i++) {
                if (!booths[i].value.length) {
                    //console.log('boothid>>>>if>>>'+booths[i].boothId);
                    boothIds.push(booths[i].boothId);
                }
            }
            if(boothIds.indexOf(component.get("v.selectedBooth").Id) < 0)
            {
                boothIds.push(component.get("v.selectedBooth").Id);
            }
        }
        else {
            boothIds.push(component.get("v.selectedBooth").Id);
        }
        //console.log('booths'+JSON.stringify(boothIds));
        //console.log('component.get("v.newContact")'+JSON.stringify(component.get("v.newContact")));
        var newCon = component.get("v.newContact");
        var sEvent = component.get("v.Event_Setting");        
        var action = component.get("c.createContactandMapping"); //Calling Apex class controller 'createContactandMapping' method
        action.setParams({
            con: newCon,
            sEventId: sEvent.Event_Edition__c,
            tempAccount: newCon.TempAccountId,
            lstBoothIds: boothIds,
            lstServices: services            
        });
        action.setCallback(this, function (response)
        {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS")
            {
                $('#modalAddContact').hide();
                //console.log('response.getReturnValue() ' +JSON.stringify(response.getReturnValue()));
                if (response.getReturnValue() == 'success')
                {
                    if (services.length > 0 && newCon.FirstName && newCon.FirstName)
                    {
                        $('#modalContactSuccess').show();
                    }                                                      
                    $('#modalCont').hide();
                    this.fetchBoothsMap(component);
                }
                else if (response.getReturnValue() == 'error')
                {
                    $('#modalAlreadyExists').show();
                    var con = newCon;
                    if (con.TempAccountId) this.deleteAccount(component);
                }
                //console.log('createContactHelper' + JSON.stringify(response.getReturnValue()));
                this.fetchPavillionBoothsMap(component);
            }else
            {
                console.log('Error !');
            }
        });
        $A.enqueueAction(action);
    },
    createAccountHelper: function (component) {
        var sEventCode = component.get("v.eventcode");
        //console.log('createAccountHelper'+JSON.stringify(component.get("v.newAccount")));
        var action = component.get("c.createTempAccount"); //Calling Apex class controller 'createTempAccount' method
        action.setParams({
            acc: component.get("v.newAccount")
        });
        action.setCallback(this, function (response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS") {
                //console.log('createAccountHelper'+JSON.stringify(response.getReturnValue()));
                var tempAccount = response.getReturnValue();
                if (tempAccount.success) {
                    component.set("v.message", '');
                    this.resetContact(component);
                    var con = component.get("v.newContact");
                    con.AccountName = tempAccount.success.Name;
                    con.TempAccountId = tempAccount.success.Id;
                    component.set("v.newContact", con);
                    
                    this.fetchPicklistValues(component , 'TempContact__c','Country_Code__c','InputPhoneIsd','-ISD-');
					this.fetchPicklistValues(component , 'TempContact__c','Country_Code__c','InputMobileIsd','-ISD-');
                    this.resetAccount(component);
                    document.getElementById('modalCompany').style.display = "none";
                    document.getElementById('modalAddContact').style.display = "block";
                    component.set("v.FirstName", false);
                    component.set("v.LastName", false);
                    component.set("v.Email", false);
                    component.set("v.Phone", false);
                    component.set("v.MobilePhone", false);
                }
                else {
                    component.set("v.existingAcc", { Name: tempAccount.error.Name });
                    //component.set("v.isWarnOpen",true);
                    //component.set("v.message",'Company already exists. Please click the cancel button below and search through the list of exhibitors.<a onclick="test()">Select</a>');
                }
            }
        });
        $A.enqueueAction(action);
    },
    fetchContactById: function (component, cid) 
    {
        var action = component.get("c.getContactByID"); //Calling Apex class controller 'getContactByID' method
        action.setParams({
            sId: cid
        });
        action.setCallback(this, function (response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS") {
                //console.log('fetchContactById'+JSON.stringify(response.getReturnValue()));
                var newcon = component.get("v.newContact");
                newcon.Id = response.getReturnValue().Id;
                newcon.FirstName = response.getReturnValue().FirstName;
                newcon.LastName = response.getReturnValue().LastName;
                newcon.Phone = response.getReturnValue().Phone;
                newcon.MobilePhone = response.getReturnValue().MobilePhone;
                newcon.Email = response.getReturnValue().Email;
                component.set("v.newContact", newcon);
                component.set("v.FirstName", false);
                component.set("v.LastName", false);
                component.set("v.Email", false);
                component.set("v.Phone", false);
                component.set("v.MobilePhone", false);
                if(newcon.FirstName)
                {
                    component.set("v.FirstName", true);
                }
                if(newcon.LastName)
                {
                    component.set("v.LastName", true);
                }
                if(newcon.Email)
                {
                    component.set("v.Email", true);
                }
                if(newcon.Phone)
                {
                    component.set("v.Phone", true);
                }
                if(newcon.MobilePhone)
                {
                    component.set("v.MobilePhone", true);
                }
                document.getElementById('modalAddContact').style.display = "block";
            }
        });
        $A.enqueueAction(action);
    },
    removeContactHelper: function (component) {
        var remCon = component.get("v.removeCon");
        //console.log(JSON.stringify(component.get("v.removeCon")));
        var action = component.get("c.removeContact"); //Calling Apex class controller 'removeContact' method
        action.setParams({
            sMapId: remCon.mapId
        });
        action.setCallback(this, function (response)
        {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS") {
                this.fetchBoothsMap(component);
                $('#modalRemoveContarctor').hide();
                $('#modalCancelSelf').hide();
                //console.log('removeContactHelper'+JSON.stringify(response.getReturnValue()));
            }
        });
        $A.enqueueAction(action);
    },
    updateContractorServices: function (component, services, mapid) {
        var sEvent = component.get("v.Event_Setting");
        var action = component.get("c.updateServices"); //Calling Apex class controller 'updateServices' method
        action.setParams({
            sMapId: mapid,
            sEventId: sEvent.Event_Edition__c,
            lstServices: services
        });
        action.setCallback(this, function (response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS")
            {
                //console.log('updateContractorServices'+JSON.stringify(response.getReturnValue()));
                this.fetchBoothsMap(component);
                $('#modalEditServices').hide();
            }
        });
        $A.enqueueAction(action);
    },
    deleteAccount: function (component) {
        var con = component.get("v.newContact");
        var action = component.get("c.deleteTempAccount"); //Calling Apex class controller 'deleteTempAccount' method
        action.setParams({
            tempAccId: con.TempAccountId
        });
        action.setCallback(this, function (response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS") {
                //console.log('deleteAccount'+JSON.stringify(response.getReturnValue()));
            }
        });
        $A.enqueueAction(action);
    },
    fetchPicklistValues: function (component, objName, field, componentName, deafultValue) {
        var action = component.get('c.getPicklistValues'); //Calling Apex class controller 'getPicklistValues' method
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
        $A.enqueueAction(action)
    },
    fetchDependentPicklistValues: function (component, objApi, contrfieldApiName, depfieldApiName) {
        
        var action = component.get("c.getDependentMap"); //Calling Apex class controller 'getDependentMap' method
        action.setParams({
            objApi: objApi,
            contrfieldApiName: contrfieldApiName,
            depfieldApiName: depfieldApiName
        });
        action.setCallback(this, function (response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS") {
                //store the return response from server (map<string,List<string>>)  
                var StoreResponse = response.getReturnValue();
                // once set #StoreResponse to depnedentFieldMap attribute 
                component.set("v.depnedentFieldMap", StoreResponse);               
            }
        });
        $A.enqueueAction(action);
    },
    onControllerFieldChange: function (component, controllerValueKey) {
        
        var depnedentFieldMap = component.get("v.depnedentFieldMap");
        var opts = [];
        opts.push({ label: '--Select--', value: '' });
        
        if (controllerValueKey) {
            var ListOfDependentFields = depnedentFieldMap[controllerValueKey];
            
            if (ListOfDependentFields.length > 0) {
                component.set("v.hasNoState", false);
                
                for (var i = 0; i < ListOfDependentFields.length; i++) {
                    opts.push({ label: ListOfDependentFields[i].split('__$__')[0], value: ListOfDependentFields[i].split('__$__')[1] });
                }
                //component.find('billingState').set("v.options",opts); // Adding values in Aura attribute variable.
            } else {
                component.set("v.hasNoState", true);
            }
            
        } else {
            component.set("v.hasNoState", true);
        }
        var Cmp = component.find('billingState');
        if(Cmp)
        {
            Cmp.set("v.options",opts); // Adding values in Aura attribute variable.
        } 
    },
    resetContact: function (component) {
        var newcon = component.get("v.newContact");
        newcon.FirstName = '';
        newcon.LastName = '';
        newcon.Phone = '';
        newcon.PhoneCountryCode = '';
        newcon.PhoneStateCode = '';
        newcon.Ext = '';
        newcon.AccountName = '';
        newcon.MobilePhone = '';
        newcon.MobilePhoneCountryCode = '';
        newcon.MobilePhoneStateCode = '';
        newcon.Email = '';
        newcon.TempAccountId = ''; // TempAccountId must be blank [CCEN-667]
        newcon.AccountId = '';
        newcon.Id = '';
        component.set("v.newContact", newcon);
        $(".chkbx").each(function () {
            var $this = $(this);
            if ($this.is(":checked")) {
                $this.attr("checked", false)
            }
        });
        $("#btnno").attr("checked", true);
        component.set("v.isForAllBooth", 'No');
        component.set("v.existingCons", null);
        
    },
    resetAccount: function (component) {
        var newcom = component.get("v.newAccount");
        newcom.Name = '';
        newcom.BillingStreet = '';
        newcom.BillingPostalCode = '';
        newcom.BillingCity = '';
        newcom.BillingCountry = '';
        newcom.BillingState = '';
        component.set("v.newAccount", newcom);
        $('#srchCompany').val('');
    }
})