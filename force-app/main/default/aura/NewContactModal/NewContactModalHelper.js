({
    getAccountDetail: function(component) {
        component.set("v.spinner", true);
        let param = JSON.stringify({ accountId: component.get("v.accountId") });
        var action = component.get("c.invoke");
        action.setParams({ action: 'get_account', parameters: param });
        action.setCallback(this, function(res) {
            component.set("v.spinner", false);
            var state = res.getState();
            if (state === "SUCCESS") {
                let obj = res.getReturnValue();
                component.set("v.recordTypeId", obj.con_record_type_id);

                component.set("v.accountObj", obj.accObj);
                var conObj = component.get("v.contactObj");
                if (conObj.Id != null && conObj.Id != undefined) {
                    if (conObj.Contact_Type__c) {
                        conObj.Contact_Type__c = conObj.Contact_Type__c.split(';');
                    }
                    conObj.AccountId = obj.accObj.Id;
                    component.set("v.contactObj", conObj);
                    component.set("v.searchKey", conObj.MailingStreet);
                } else {

                    var billingAccObj=obj.accObj.Billing_Address_Line_2__c;
                   	if (billingAccObj!= null  || billingAccObj!= undefined) {
                        billingAccObj = billingAccObj.trim();
                        component.set("v.contactObj", {
                            AccountId: obj.accObj.Id,
                            MailingStreet: obj.accObj.BillingStreet+', ' +billingAccObj,
                            MailingCity: obj.accObj.BillingCity,
                            MailingCountryCode: obj.accObj.BillingCountryCode,
                            MailingStateCode: obj.accObj.BillingStateCode,
                            MailingPostalCode: obj.accObj.BillingPostalCode
                        });
                        //alert('obj.accObj.BillingStateCode If: '+obj.accObj.BillingStateCode);
                        component.set("v.searchKey",obj.accObj.BillingStreet+', ' +billingAccObj);
                    } else {
                       component.set("v.contactObj", {
                            AccountId: obj.accObj.Id,
                            MailingStreet: obj.accObj.BillingStreet,
                            MailingCity: obj.accObj.BillingCity,
                            MailingCountryCode: obj.accObj.BillingCountryCode,
                            MailingStateCode: obj.accObj.BillingStateCode,
                            MailingPostalCode: obj.accObj.BillingPostalCode
                        });
                       // alert('obj.accObj.BillingStateCode else: '+obj.accObj.BillingStateCode);
                        component.set("v.searchKey", obj.accObj.BillingStreet);
                    }

                }

                component.set("v.meta", obj.meta);
                this.fetchDependentPicklistValues(component);
            } else {
                window._LtngUtility.handleErrors(res.getError());
            }
        });
        $A.enqueueAction(action);
    },
    getGoogleApiMapping : function(component) {
        var action = component.get("c.getGoogleApiMetaData");
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {
               component.set("v.googleApiFieldMap" , res.getReturnValue());
               //console.log('GoogleApi Map ' +JSON.stringify(res.getReturnValue()));
            } else {
                window._LtngUtility.handleErrors(res.getError());
            }
        });
        $A.enqueueAction(action);
    },
    fetchDependentPicklistValues: function(component) {
        component.set("v.isLoading", true);
        let param = JSON.stringify({
            objApi: 'Contact',
            contrfieldApiName: 'MailingCountryCode',
            depfieldApiName: 'MailingStateCode'
        });
        var action = component.get("c.getDependentMap");
        action.setParams({ parameters: param });
        action.setCallback(this, function(response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS") {
                //store the return response from server (map<string,List<string>>)                  
                // once set #StoreResponse to depnedentFieldMap attribute 
                component.set("v.depnedentFieldMap", response.getReturnValue());
                var accObj = component.get("v.accountObj");

                var val = accObj.BillingCountryCode;
                var lab = '';
                for (var i = 0; i < response.getReturnValue().length; i++) {
                    if (response.getReturnValue()[i].value == val) {
                        lab = response.getReturnValue()[i].label;
                    }
                }
                var controllerValueKey = lab + '__$__' + val;
                if (!$A.util.isEmpty(val) && val != undefined) {
                    this.onControllerFieldChange(component, val);
                }
                component.set("v.isLoading", false);
            } else {
                window._LtngUtility.handleErrors(res.getError());
            }
        });
        $A.enqueueAction(action);
    },
    onControllerFieldChange: function(component, controllerValueKey) {
        var depnedentFieldMap = component.get("v.depnedentFieldMap");
        var opts = [];
        opts.push({ label: '--Select--', value: '' });
        //console.log(depnedentFieldMap);
        if (controllerValueKey) {
            var ListOfDependentFields = depnedentFieldMap[controllerValueKey];
           // console.log(ListOfDependentFields);
            if(ListOfDependentFields){
                for (var i = 0; i < ListOfDependentFields.length; i++) {
                    opts.push({ label: ListOfDependentFields[i].split('__$__')[0], value: ListOfDependentFields[i].split('__$__')[1] });
                }
            }
        }
        if (ListOfDependentFields && ListOfDependentFields.length == 0) {
            component.find('billingState').set("v.disabled", true);
        } else {
            component.find('billingState').set("v.disabled", false);
        }
        component.find('billingState').set("v.options", opts);
    },
    createNewContact: function(component) {
        component.set("v.spinner", true);
        var conObj = component.get("v.contactObj");
        //console.log('conObj'+conObj.Contact_Type__c);
        
        if (conObj.Contact_Type__c != undefined && !$A.util.isEmpty(conObj.Contact_Type__c)) {
            conObj.Contact_Type__c = conObj.Contact_Type__c.join(';');
        }
        if(conObj.MailingCountryCode=='NG'){
            conObj.MailingStateCode = null;
        }
        let param = JSON.stringify({ cont_obj: conObj });
        var action = component.get("c.invokeInsertOrUpdate");
        action.setParams({ action: 'set_contact', parameters: param });
        action.setCallback(this, function(res) {
            component.set("v.spinner", false);
            var state = res.getState();
            if (state === "SUCCESS") {
               // console.log('state'+state);
                //console.log('success'+conObj.Id);
                if (conObj.Id == null || conObj.Id == undefined) {
                    window._LtngUtility.toast('Success', 'success', 'New contact has been created');
                } else {
                    window._LtngUtility.toast('Success', 'success', 'Contact has been updated');
                }
                component.set("v.isOpenModal", false);
                if (component.get("v.isRedirect")) {
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": res.getReturnValue(),
                        "slideDevName": "detail"
                    });
                    navEvt.fire();
                } else {
                    $A.get("e.c:refreshEvent").fire();
                }
            } else {
                if (conObj.Contact_Type__c != undefined && !$A.util.isEmpty(conObj.Contact_Type__c)) {
                    conObj.Contact_Type__c = conObj.Contact_Type__c.split(';');
                }
                window._LtngUtility.handleErrors(res.getError());
            }
        });
        $A.enqueueAction(action);
    },
    validate: function(component) {
        var conObj = component.get("v.contactObj");
        var sPhone = conObj.Phone;
        var sMobilePhone = conObj.MobilePhone;
        sPhone = typeof sPhone === 'undefined' ? '' : sPhone.trim();
        sMobilePhone = typeof sMobilePhone === 'undefined' ? '' : sMobilePhone.trim();

        var regex1 = /^[0-9- ()#+]*$/;
        var regex12 = /^[0-9- ()#+]*$/;

        var filter = /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;
        var sMinimumSevenDigit = /^(?:[\D]*[0-9][\D]*){0,7}$/;
        var sMinimumSevenDigit1 = /^(?:[\D]*[0-9][\D]*){0,7}$/;


        var rege = /[^a-zA-Z]/;
        var specialChar = /^[- ()#+]*$/;

        /*Get all Custom labels*/
        window.$Label = window.$Label || {};

        var BusinessPhoneMessage = $A.get("{!$Label.c.BusinessPhoneMessage}");
        var MobilePhoneMessage = $A.get("{!$Label.c.MobilePhoneMessage}");

        var str = '';

        if (sMobilePhone !== '' && (!regex12.test(sMobilePhone) || sMinimumSevenDigit1.test(sMobilePhone))) {
            window._LtngUtility.toast('Error!', 'error', MobilePhoneMessage);
            component.find('mobilePhoneFields').set("v.validity", { valid: false, badInput: true })
            return false;
        } else if (sPhone !== '' && (!rege.test(sPhone) || sMinimumSevenDigit.test(sPhone) || specialChar.test(sPhone) || sPhone.includes("@") || sPhone.includes("!") || sPhone.includes("_") || sPhone.includes("%") || sPhone.includes("$") || sPhone.includes("*") || sPhone.includes(",") || sPhone.includes(".") || sPhone.includes("?") || sPhone.includes("<") || sPhone.includes(">") || sPhone.includes("=") || sPhone.includes("/") || sPhone.includes("|") || sPhone.includes("{") || sPhone.includes("}") || sPhone.includes("[") || sPhone.includes("]") || sPhone.includes("~") || sPhone.includes("`") || sPhone.includes(";") || sPhone.includes(":") || sPhone.includes("^") || sPhone.includes("&") || sPhone.includes("\\"))) {
            window._LtngUtility.toast('Error!', 'error', BusinessPhoneMessage);
            component.find('phoneFields').set("v.validity", { valid: false, badInput: true })
            return false;
        }

        return true;
    },
    //Google Address auto complete
    displayOptionsLocation: function(component, searchKey) {
        var action = component.get("c.invoke");
        var param = JSON.stringify({
            searchKey: searchKey
        })
        action.setParams({ action: 'get_addresses', parameters: param });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var options = JSON.parse(response.getReturnValue());
                //console.log('test1' + response.getReturnValue());
                var predictions = options.predictions;
                var addresses = [];
                if (predictions.length > 0) {
                    for (var i = 0; i < predictions.length; i++) {
                        var bc = [];
                        /*for(var j=0;j<predictions[i].terms.length;j++){
                            bc.push(predictions[i].terms[j].offset , predictions[i].terms[j].value );
                        }*/
                        addresses.push({
                            value: predictions[i].types[0],
                            PlaceId: predictions[i].place_id,
                            locaval: bc,
                            label: predictions[i].description
                        });
                    }
                    component.set("v.filteredOptions", addresses);
                }
            }
        });
        $A.enqueueAction(action);
    },
    displayOptionDetails: function(component, event, placeid) {
        var self = this;
        var searchKey = component.get("v.searchKey");
        var district = '';
        var googlePlaceApiMap = component.get("v.googleApiFieldMap");
        var postalcode, country, state, street, route, city;
        var action1 = component.get("c.invoke");
        var param = JSON.stringify({ placeId: placeid });
        action1.setParams({ action: 'get_address_detail', parameters: param });
        action1.setCallback(this, function(response) {
            var state = response.getState();
            let counISOCode = "";
            var countryLongName = "";
            if (state === "SUCCESS") {
                var options = JSON.parse(response.getReturnValue());
                var Addressdet = options.result;
                var key = "address_components";
                var o = Addressdet[key];
                var GoogleApiMetadata;
                var stateOptions = {};
                for (var prop in o) {
                    //console.log(o[prop]);
                    for (var prop2 in o[prop].types) {
                        if (o[prop].types[prop2] == 'country') { 
                            counISOCode = o[prop].short_name;
                            if(googlePlaceApiMap.hasOwnProperty(counISOCode)){
                                GoogleApiMetadata = googlePlaceApiMap[o[prop].short_name];
                                //console.log('Country value ' +GoogleApiMetadata.State__c);
                            }
                            else{
                                GoogleApiMetadata = googlePlaceApiMap['Default'];
                            }
                            stateOptions = this.getStateOptionsOfCountryChangeByCode(component, o[prop].short_name);
                        }
                    }
                }
                var googleApiCity = GoogleApiMetadata.City__c;
                var cityNodes = [];
                if( googleApiCity.includes(',') ){
                    cityNodes = googleApiCity.split(',');
                    //console.log('cityNodes ' +cityNodes);
                }
                else{
                    cityNodes.push(googleApiCity);
                }
                
                //reset address fields
                component.set("v.contactObj.MailingStateCode", "");
                component.set("v.contactObj.MailingCity", "");
                component.set("v.contactObj.MailingPostalCode", "");
                component.set("v.contactObj.MailingCountryCode", "");
                console.log(o);
                for (var prop in o) {
                    //console.log(o[prop]);
                    for (var prop2 in o[prop].types) {
                        if (o[prop].types[prop2] == GoogleApiMetadata.State__c) {
                            let stateShortName = o[prop].short_name;
                            //console.log("stateShortName1===",stateShortName);
                            if(stateShortName == o[prop].long_name){
                               // console.log("stateShortName2===",stateShortName);
                                if(stateOptions.hasOwnProperty(stateShortName)){
                                   // console.log("stateShortName3===",stateShortName);
                                    stateShortName = stateOptions[stateShortName];
                                }
                            }
                            searchKey = searchKey.replace(new RegExp(o[prop].long_name + ','), ",").trim();
                            searchKey = searchKey.replace(new RegExp(o[prop].short_name + ','), ",").trim();
                            component.set("v.contactObj.MailingStateCode", stateShortName);
                            //console.log("stateShortName===",JSON.stringify(stateOptions));
                           // console.log("stateShortName===",stateShortName);
                            if(stateShortName.length>3 && counISOCode != "SA"){
                                component.set("v.contactObj.MailingStateCode", "");
                            }
                        }
                        //console.log(o[prop].types[prop2]);
                        if (cityNodes.indexOf(o[prop].types[prop2]) != -1) {
                            //console.log(searchKey+'==='+o[prop].long_name+'==='+o[prop].short_name);
                            searchKey = searchKey.replace(new RegExp(', '+o[prop].long_name+','), ",").trim();
                            searchKey = searchKey.replace(new RegExp(', '+o[prop].short_name+','), ",").trim();
                            searchKey = searchKey.replace(new RegExp(', '+o[prop].short_name+'$'), ",").trim();
                            component.set("v.contactObj.MailingCity", o[prop].long_name);
                        }

                        if (o[prop].types[prop2] == GoogleApiMetadata.Country__c) {
                            countryLongName = o[prop].long_name;                                    
                            searchKey = searchKey.replace(new RegExp(', '+o[prop].long_name + '$'), ",").trim();
                            searchKey = searchKey.replace(new RegExp(', '+o[prop].short_name + '$'), ",").trim();
                            
                            //only for USA
                            if(o[prop].short_name=='US'){
                                searchKey = searchKey.replace(new RegExp(', USA$'), "").trim();
                            }
                            else if(o[prop].short_name=='GB'){
                                searchKey = searchKey.replace(new RegExp(', UK$'), "").trim();
                            }

                            component.set("v.contactObj.MailingCountryCode", o[prop].short_name);
                            this.loadStateOfCountryChangeByCode(component, o[prop].short_name);
                        }
                        if (o[prop].types[prop2] == GoogleApiMetadata.Postal_Code__c) {
                            searchKey = searchKey.replace(new RegExp(o[prop].long_name + ','), ",").trim();
                            searchKey = searchKey.replace(new RegExp(o[prop].short_name + ','), ",").trim();
                            component.set("v.contactObj.MailingPostalCode", o[prop].short_name);
                        }
                        if (o[prop].types[prop2] == GoogleApiMetadata.District__c) {
                            searchKey = searchKey.replace(new RegExp(o[prop].long_name + ','), ",").trim();
                            searchKey = searchKey.replace(new RegExp(o[prop].short_name + ','), ",").trim();
                            district = o[prop].short_name; 
                        }
                    }
                }
            }
            var city = component.get("v.contactObj.MailingCity");
            if(counISOCode == "SA"){
                var replacestring = city + " " + countryLongName;
                searchKey = searchKey.trim().replace(replacestring, "").trim();
                searchKey = searchKey.trim().replace(countryLongName, "").trim();
            }
            searchKey = searchKey.trim().replace(new RegExp("([, ]+)" + '$'), "").trim();
            
            //replace city
            searchKey = searchKey.trim().replace(new RegExp("([,][ ]?)"+city+ '$'), "").trim();
            
            //replace all commas from last
            searchKey = searchKey.trim().replace(new RegExp("([, ]+)" + '$'), "").trim();

            if(district != ''){
                searchKey = searchKey + ', ' +district;
            }

            component.set("v.searchKey", searchKey);
        });
        $A.enqueueAction(action1);
    },
    loadStateOfCountryChangeByCode: function(component, val) {
        try {
            var lab = '';
            var options = component.get("v.depnedentFieldMap");
            if (options != undefined) {
                for (var i = 0; i < options.length; i++) {
                    if (options[i].value == val) {
                        lab = options[i].label;
                    }
                }
                var controllerValueKey = lab + '__$__' + val;
                this.onControllerFieldChange(component, val);
            }
        } catch (e) {
            console.error(e);
        }
    },
    getStateOptionsOfCountryChangeByCode: function(component, val) {
        var opts = {};
        try {
            var depnedentFieldMap = component.get("v.depnedentFieldMap");
            if (depnedentFieldMap != undefined) {
                var controllerValueKey = val;
               // console.log('controllerValueKey==',controllerValueKey);
                //console.log('depnedentFieldMap==',depnedentFieldMap);
                //console.log(depnedentFieldMap);
                if (controllerValueKey) {
                    var ListOfDependentFields = depnedentFieldMap[controllerValueKey];
                   // console.log('ListOfDependentFields==',ListOfDependentFields);
                    // console.log(ListOfDependentFields);
                    if(ListOfDependentFields){
                        for (var i = 0; i < ListOfDependentFields.length; i++) {
                            opts[ListOfDependentFields[i].split('__$__')[0]] = ListOfDependentFields[i].split('__$__')[1];
                        }
                    }
                }
            }
        } catch (e) {
            console.error(e);
        }
        return opts;
    },
    openListbox: function(component, searchKey) {
        var searchLookup = component.find("searchLookup");
        if (typeof searchKey === 'undefined' || searchKey.length < 3) {
            $A.util.addClass(searchLookup, 'slds-combobox-lookup');
            $A.util.removeClass(searchLookup, 'slds-is-open');
            return;
        }
        $A.util.addClass(searchLookup, 'slds-is-open');
        $A.util.removeClass(searchLookup, 'slds-combobox-lookup');
    },
    clearComponentConfig: function(component) {
        var searchLookup = component.find("searchLookup");
        $A.util.addClass(searchLookup, 'slds-combobox-lookup');
        //component.set("v.selectedOption", null);
        component.set("v.searchKey", null);
        var iconDirection = component.find("iconDirection");
        $A.util.removeClass(iconDirection, 'slds-input-has-icon_right');
        $A.util.addClass(iconDirection, 'slds-input-has-icon_left');
    },
})