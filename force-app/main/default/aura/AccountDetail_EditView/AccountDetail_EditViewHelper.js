({
    fetchUser: function(component) {
        var acc = component.get("v.accountObj");
        var action = component.get("c.getCurrentUserDtls");
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {
                var userDtls = res.getReturnValue();
                if (userDtls) {
                    if (userDtls.Profile.Name == 'System Administrator' || userDtls.Profile.Name == 'GE BA Administrator' || userDtls.Profile.Name == 'GE System Administrator' || userDtls.Profile.Name== 'Global SFDC Team Integration Users' ) {
                        $A.util.removeClass(component.find("summaryView"), "slds-hide");
                        $A.util.removeClass(component.find("interestLevelnatureOfBuisness"), "slds-hide");
                        $A.util.removeClass(component.find("sscView"), "slds-hide");
                        $A.util.removeClass(component.find("adminView"), "slds-hide");
                        $A.util.removeClass(component.find("accountTranslatedInfo"), "slds-hide");
                        $A.util.removeClass(component.find("accountaddInfo"), "slds-hide");
                    } else if (userDtls.Profile.Name == 'Sales' || userDtls.Profile.Name == 'Sales-Brasil' || userDtls.Profile.Name == 'Operations') {
                        $A.util.removeClass(component.find("summaryView"), "slds-hide");
                        $A.util.removeClass(component.find("interestLevelnatureOfBuisness"), "slds-hide");
                        $A.util.removeClass(component.find("accountaddInfo"), "slds-hide");
                        $A.util.removeClass(component.find("accountTranslatedInfo"), "slds-hide");
                    } else if (userDtls.Profile.Name == 'SSC Finance-Accounting') {
                        $A.util.removeClass(component.find("summaryView"), "slds-hide");
                        $A.util.removeClass(component.find("interestLevelnatureOfBuisness"), "slds-hide");
                        $A.util.removeClass(component.find("accountaddInfo"), "slds-hide");
                        $A.util.removeClass(component.find("accountTranslatedInfo"), "slds-hide");
                        $A.util.removeClass(component.find("sscView"), "slds-hide");
                    }


                    //check is address fields readonly
                    /*if(userDtls.Profile.Name == 'System Administrator' || userDtls.Profile.Name == 'GE BA Administrator' || userDtls.Profile.Name == 'GE System Administrator'|| userDtls.Profile.Name == 'SSC Finance-Accounting'|| userDtls.Profile.Name == 'SSC-R2R Accounting'){
                        component.set("v.isAddressNotEditable",false)
                    }*/

                    component.set("v.usrDtls", userDtls);


                    var AcObj = component.get("v.accountObj");
                    if (AcObj) {
                        if (AcObj.Business_Partner_Number__c != null && AcObj.Business_Partner_Number__c != "") {
                            component.set("v.hasBpNumber", true);                            
                            if (userDtls.Profile.Name == 'Sales' || userDtls.Profile.Name == 'Sales-Brasil') {
                                 /** BK-22296 - Danish on 26-07-2022  */
                                if(userDtls.Profile.Name == 'Sales-Brasil'){
                                 component.set('v.isBpNumberAndSalesBrasil',true);  
                                }
                              
                                component.set("v.isAddressDisabled",true);
                                component.set("v.hasBpNumberAndisSales", true);
                            } 
                            else {
                                component.set("v.hasBpNumberAndisSales", false);
                            }
                        }
                    }
                    /** BK-3828 - Rajesh Kumar on 14-04-2020  */
                    if (userDtls.Profile.Name == 'Sales-Brasil'){
                        component.set("v.hasNationalClassficationNull", true);
                    }

                    if(acc.Inactive__c){
                        component.set("v.hasBpNumberAndisSales", true);
                        component.set("v.isAddressDisabled",true);
                        component.set("v.isAccountCreditHold",true);
                    } else {
                        component.set("v.isAccountCreditHold",false);
                    }

                }
            } else {
                window._LtngUtility.handleErrors(res.getError());
            }
        });
        $A.enqueueAction(action);
    },
    fetchpicklistValues: function(component) {
        var action = component.get("c.getAccountPicklist");
        action.setCallback(this, function(res) {
            var resState = res.getState();
            if (resState === 'SUCCESS') {
                var responseResult = res.getReturnValue();
                component.set("v.meta", responseResult);
                this.fetchDependentPicklistValues(component, "Billing");
                this.fetchDependentPicklistValues(component, "Shipping");
            } else {
                window._LtngUtility.toast('Error', 'error', res.getError());
            }
        });
        $A.enqueueAction(action);
    },
    fetchData: function(component) {
        var action = component.get("c.getAcDetail");
        action.setParams({ recordId: component.get("v.recordId") })
        action.setCallback(this, function(res) {
            var resState = res.getState();
            if (resState === 'SUCCESS') {
                
                var responseResult = res.getReturnValue();

                component.set("v.accountObj", responseResult);
                component.set("v.searchKeyBill", responseResult.BillingStreet);
                component.set("v.searchKey", responseResult.ShippingStreet);              
                var shipAdd = {}; // = component.get("v.shipAdd");
                var billAdd = {}; // = component.get("v.billAdd");

                shipAdd.shippingAddLine1 = responseResult.ShippingStreet;
                shipAdd.shippingAddLine2 = responseResult.Shipping_Address_2__c;
                shipAdd.shippingCity = responseResult.ShippingCity;
                shipAdd.shippingCountryCode = responseResult.ShippingCountryCode;
                shipAdd.shippingStateCode = responseResult.ShippingStateCode;
                shipAdd.shippingPostalCode = responseResult.ShippingPostalCode;
                
                billAdd.billingAddLine1 = responseResult.BillingStreet;
                billAdd.billingAddLine2 = responseResult.Billing_Address_Line_2__c;
                billAdd.billingCity = responseResult.BillingCity;
                billAdd.billingCountryCode = responseResult.BillingCountryCode;
                billAdd.billingStateCode = responseResult.BillingStateCode;
                billAdd.billingPostalCode = responseResult.BillingPostalCode;

                component.set("v.billAdd", billAdd);
                component.set("v.shipAdd", shipAdd);

                this.fetchUser(component);
                this.fetchpicklistValues(component);
            } else {
                window._LtngUtility.toast('Error', 'error', res.getError());
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
    //Google Address auto complete
    displayOptionsLocation: function(component, searchKey, filterLoc) {
        var action = component.get("c.getAddressAutoComplete");
        var param = JSON.stringify({
            searchKey: searchKey
        })
        action.setParams({ parameters: param });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var options = JSON.parse(response.getReturnValue());
                var predictions = options.predictions;
                var addresses = [];
                if (predictions.length > 0) {
                    for (var i = 0; i < predictions.length; i++) {
                        var bc = [];
                        addresses.push({
                            value: predictions[i].types[0],
                            PlaceId: predictions[i].place_id,
                            locaval: bc,
                            label: predictions[i].description
                        });
                    }
                    if (filterLoc == "Ship") {
                        component.set("v.filteredOptions", addresses);
                    } else if (filterLoc == "bill") {
                        component.set("v.filteredOptionsBill", addresses);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    displayOptionDetailsShip: function(component, event, placeid) {
        var self = this,fillLoc='Ship';
        var googlePlaceApiMap = component.get("v.googleApiFieldMap");
        var shipAdd = component.get("v.shipAdd");        
        var searchKey = "";
        var district = '';
        
        searchKey = component.get("v.searchKey"); 

        var postalcode, country, state, street, route, city;
        var action1 = component.get("c.getAddressDetails");
        var param = JSON.stringify({ placeId: placeid });
        action1.setParams({ parameters: param });
        action1.setCallback(this, function(response) {
            var state = response.getState();
            let counISOCode = "";
            var countryLongName = "";
            if (state === "SUCCESS") {
                var options = JSON.parse(response.getReturnValue());
                console.log("response.getReturnValue()===",response.getReturnValue());
                var Addressdet = options.result;
                var key = "address_components";
                var o = Addressdet[key] // value2
                var GoogleApiMetadata;
                var stateOptions = {};
                for (var prop in o) {
                    //console.log(o[prop]);
                    for (var prop2 in o[prop].types) {
                        if (o[prop].types[prop2] == 'country') { 
                            counISOCode = o[prop].short_name;
                            console.log("counISOCode===",counISOCode);
                            if(googlePlaceApiMap.hasOwnProperty(counISOCode)){
                                GoogleApiMetadata = googlePlaceApiMap[o[prop].short_name];
                                //console.log('Country value ' +GoogleApiMetadata.State__c);
                            }
                            else{
                                GoogleApiMetadata = googlePlaceApiMap['Default'];
                            }
                            stateOptions = this.getStateOptionsOfCountryChangeByCode(component, o[prop].short_name, "Shipping");
                            //console.log("stateOptions===",stateOptions);
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
                for (var prop in o) {
                    for (var prop2 in o[prop].types) {
                        if (o[prop].types[prop2] == GoogleApiMetadata.State__c) {
                            let stateShortName = o[prop].short_name;
                            //console.log("stateShortName1===",stateShortName);
                            if(stateShortName == o[prop].long_name){
                                //console.log("stateShortName2===",stateShortName);
                                if(stateOptions.hasOwnProperty(stateShortName)){
                                    //console.log("stateShortName3===",stateShortName);
                                    stateShortName = stateOptions[stateShortName];
                                    //console.log("stateShortName4===",stateShortName);
                                }
                            }
                            searchKey = searchKey.replace(new RegExp(o[prop].long_name + ','), ",").trim();
                            searchKey = searchKey.replace(new RegExp(o[prop].short_name + ','), ",").trim();
                            shipAdd.shippingStateCode = stateShortName;
                            //console.log("stateShortName===",JSON.stringify(stateOptions));
                            //console.log("stateShortName===",stateShortName);
                            if(stateShortName.length>3 && counISOCode != "SA"){
                                shipAdd.shippingStateCode = '';
                            }
                        }
                        if (cityNodes.indexOf(o[prop].types[prop2]) != -1) {                            
                            searchKey = searchKey.replace(new RegExp(', '+o[prop].long_name+','), ",").trim();
                            searchKey = searchKey.replace(new RegExp(', '+o[prop].short_name+','), ",").trim();
                            searchKey = searchKey.replace(new RegExp(', '+o[prop].short_name+'$'), ",").trim();
                            shipAdd.shippingCity = o[prop].short_name; 
                        }
                        if (o[prop].types[prop2] == GoogleApiMetadata.Postal_Code__c) {
                            searchKey = searchKey.replace(new RegExp(o[prop].long_name + ','), ",").trim();
                            searchKey = searchKey.replace(new RegExp(o[prop].short_name + ','), ",").trim();
                            shipAdd.shippingPostalCode = o[prop].short_name; 
                        }
                        if (o[prop].types[prop2] == GoogleApiMetadata.District__c) {
                            searchKey = searchKey.replace(new RegExp(o[prop].long_name + ','), ",").trim();
                            searchKey = searchKey.replace(new RegExp(o[prop].short_name + ','), ",").trim();
                            district = o[prop].short_name; 
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
                            shipAdd.shippingCountryCode = o[prop].short_name;

                            this.loadStateOfCountryChangeByCode(component, o[prop].short_name, "Shipping");
                        }
                    }
                }
            }
            if(counISOCode == "SA"){
                var replacestring = shipAdd.shippingCity + " " + countryLongName;
                searchKey = searchKey.trim().replace(replacestring, "").trim();
                searchKey = searchKey.trim().replace(countryLongName, "").trim();
            }
            searchKey = searchKey.trim().replace(new RegExp("," + '$'), "");
            searchKey = searchKey.trim().replace(new RegExp("([, ]+)" + '$'), "").trim();
            //replace city
            searchKey = searchKey.trim().replace(new RegExp("([,][ ]?)"+shipAdd.shippingCity+ '$'), "").trim();
            //replace all commas from last
            searchKey = searchKey.trim().replace(new RegExp("([, ]+)" + '$'), "").trim();
            shipAdd.shippingAddLine1 = searchKey;

            //time to 60 characters if searchKey greater than 60 chars.
            var add1='',add2 = '',addArr;
            if(searchKey.length>60){                
                addArr = searchKey.split(' ');
                var totalLength=0;
                for(var i=0;i<addArr.length;i++){
                    totalLength = add1.length + addArr[i].length; 
                    if(add1.length<60 && totalLength<=60){
                       add1 = add1 + ' ' +addArr[i]; 
                    }
                    else{
                        add2 = add2 + ' ' +addArr[i];
                    }
                }
            }
            else{
                add1 = searchKey;
            }
            if(district != ''){
                if(add2 != ''){
                    add2 = add2 + ', ' +district;
                }
                else{
                    add2 = district;
                }
            }
            if(shipAdd.shippingAddLine2 == '' || shipAdd.shippingAddLine2 == null){
                shipAdd.shippingAddLine2 = add2;
            }
            
            component.set("v.shipAdd", shipAdd);
            component.set("v.searchKey", add1);
            component.set("v.isBPUpdated", true);
        });
        $A.enqueueAction(action1);
    },
    displayOptionDetailsBill: function(component, event, placeid) {
        var self = this;   
        var googlePlaceApiMap = component.get("v.googleApiFieldMap");
        var billAdd = component.get("v.billAdd");
        var searchKey = component.get("v.searchKeyBill");
        var district = '';

        var postalcode, country, state, street, route, city;
        var action1 = component.get("c.getAddressDetails");
        var param = JSON.stringify({ placeId: placeid });
        action1.setParams({ parameters: param });
        action1.setCallback(this, function(response) {
            var state = response.getState();
            let counISOCode = "";
            var countryLongName = "";
            if (state === "SUCCESS") {
                var options = JSON.parse(response.getReturnValue());
                var Addressdet = options.result;
                var key = "address_components";
                var o = Addressdet[key] // value2

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
                            stateOptions = this.getStateOptionsOfCountryChangeByCode(component, o[prop].short_name, "Billing");
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
                for (var prop in o) {
                    for (var prop2 in o[prop].types) {
                        if (o[prop].types[prop2] == GoogleApiMetadata.State__c) {
                            let stateShortName = o[prop].short_name;
                            //console.log("stateShortName1===",stateShortName);
                            if(stateShortName == o[prop].long_name){
                                //console.log("stateShortName2===",stateShortName);
                                if(stateOptions.hasOwnProperty(stateShortName)){
                                    //console.log("stateShortName3===",stateShortName);
                                    stateShortName = stateOptions[stateShortName];
                                }
                            }
                            searchKey = searchKey.replace(new RegExp(o[prop].long_name + ','), ",").trim();
                            searchKey = searchKey.replace(new RegExp(o[prop].short_name + ','), ",").trim();
                            billAdd.billingStateCode = stateShortName;
                            //console.log("stateShortName===",JSON.stringify(stateOptions));
                            //console.log("stateShortName===",stateShortName);
                            if(stateShortName.length>3 && counISOCode != "SA"){
                                billAdd.billingStateCode = '';
                            }
                        }
                        if (cityNodes.indexOf(o[prop].types[prop2]) != -1) {
                            searchKey = searchKey.replace(new RegExp(', '+o[prop].long_name+','), ",").trim();
                            searchKey = searchKey.replace(new RegExp(', '+o[prop].short_name+','), ",").trim();
                            searchKey = searchKey.replace(new RegExp(', '+o[prop].short_name+'$'), ",").trim();
                            billAdd.billingCity = o[prop].short_name;
                        }
                        if (o[prop].types[prop2] == GoogleApiMetadata.Postal_Code__c) {
                            searchKey = searchKey.replace(new RegExp(o[prop].long_name + ','), ",").trim();
                            searchKey = searchKey.replace(new RegExp(o[prop].short_name + ','), ",").trim();
                            billAdd.billingPostalCode = o[prop].short_name; 
                        }
                        if (o[prop].types[prop2] == GoogleApiMetadata.District__c) {
                            searchKey = searchKey.replace(new RegExp(o[prop].long_name + ','), ",").trim();
                            searchKey = searchKey.replace(new RegExp(o[prop].short_name + ','), ",").trim();
                            district = o[prop].short_name; 
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
                            
                            billAdd.billingCountryCode = o[prop].short_name;
                            this.loadStateOfCountryChangeByCode(component, o[prop].short_name, "Billing");
                        }
                    }
                }
            }
            if(counISOCode == "SA"){
                var replacestring = billAdd.billingCity + " " + countryLongName;
                searchKey = searchKey.trim().replace(replacestring, "").trim();
                searchKey = searchKey.trim().replace(countryLongName, "").trim();
            }
            searchKey = searchKey.trim().replace(new RegExp("," + '$'), "");
            searchKey = searchKey.trim().replace(new RegExp("([, ]+)" + '$'), "").trim();
            //replace city
            searchKey = searchKey.trim().replace(new RegExp("([,][ ]?)"+billAdd.billingCity+ '$'), "").trim();
            //replace all commas from last
            searchKey = searchKey.trim().replace(new RegExp("([, ]+)" + '$'), "").trim();

            billAdd.billingAddLine1 = searchKey;

            //time to 60 characters if searchKey greater than 60 chars.
            var add1='',add2 = '',addArr;
            if(searchKey.length>60){
                addArr = searchKey.split(' ');
                var totalLength=0;
                for(var i=0;i<addArr.length;i++){
                    totalLength = add1.length + addArr[i].length; 
                    if(add1.length<60 && totalLength<=60){
                       add1 = add1 + ' ' +addArr[i]; 
                    }
                    else{
                        add2 = add2 + ' ' +addArr[i];
                    }
                }
            }
            else{
                add1  = searchKey;
            }
            if(district != ''){
                if(add2 != ''){
                    add2 = add2 + ', ' +district;
                }
                else{
                    add2 = district;
                }
            }
            if(billAdd.billingAddLine2 == '' || billAdd.billingAddLine2 == null){
                billAdd.billingAddLine2 = add2;
            }
            
            component.set("v.billAdd", billAdd);
            component.set("v.searchKeyBill", add1);
            component.set("v.isBPUpdated", true);
        });
        $A.enqueueAction(action1);
    },
    loadStateOfCountryChangeByCode: function(component, val, type) {
        try {            
            if (type == "Shipping") {
                this.onControllerFieldChange(component, val, "Shipping");
            } else if (type == "Billing") {
                this.onControllerFieldChange(component, val, "Billing");
            }
        } 
        catch (e) {
            console.error(e);
        }
    },
    openListbox: function(component, searchKey, displayLoc) {
        if (displayLoc == "Ship") {
            var searchLookup = component.find("searchLookup");
            if (typeof searchKey === 'undefined' || searchKey.length < 3) {
                $A.util.addClass(searchLookup, 'slds-combobox-lookup');
                $A.util.removeClass(searchLookup, 'slds-is-open');
                return;
            }
            $A.util.addClass(searchLookup, 'slds-is-open');
            $A.util.removeClass(searchLookup, 'slds-combobox-lookup');
        } else if (displayLoc == "bill") {
            var searchLookup = component.find("searchLookupBilling");
            if (typeof searchKey === 'undefined' || searchKey.length < 3) {
                $A.util.addClass(searchLookup, 'slds-combobox-lookup');
                $A.util.removeClass(searchLookup, 'slds-is-open');
                return;
            }
            $A.util.addClass(searchLookup, 'slds-is-open');
            $A.util.removeClass(searchLookup, 'slds-combobox-lookup');
        }
    },
    clearComponentConfig: function(component) {
        var searchLookup = component.find("searchLookup");
        $A.util.addClass(searchLookup, 'slds-combobox-lookup');
        component.set("v.selectedOption", null);
        component.set("v.searchKey", null);
        var iconDirection = component.find("iconDirection");
        $A.util.removeClass(iconDirection, 'slds-input-has-icon_right');
        $A.util.addClass(iconDirection, 'slds-input-has-icon_left');
    },
    onControllerFieldChange: function(component, controllerValueKey, type) {

        var depnedentFieldMap = '';
        if (type == "Shipping") {
            depnedentFieldMap = component.get("v.depnedentFieldMapShip");
        }
        else{
            depnedentFieldMap = component.get("v.depnedentFieldMapBill");
        }

        var opts = [];
        opts.push({ label: '--Select--', value: '' });
        if (controllerValueKey) {
            //get all states from map by country code as key (controllerValueKey = country code)
            var ListOfDependentFields = depnedentFieldMap[controllerValueKey];
             if(ListOfDependentFields){
                 for (var i = 0; i < ListOfDependentFields.length; i++) {
                     opts.push({ label: ListOfDependentFields[i].split('__$__')[0], value: ListOfDependentFields[i].split('__$__')[1] });
                 }
             }
        }
        
        if (type == "Billing") {
            if (ListOfDependentFields.length == 0 || component.get("v.isAddressDisabled")) {
                component.find('billStateCode').set("v.disabled", true);
            } else {
                component.find('billStateCode').set("v.disabled", false);
            }
            component.find('billStateCode').set("v.options", opts);
            component.set("v.isBPUpdated", true);
        } 
        else if (type == "Shipping") {
            if (ListOfDependentFields.length == 0 || component.get("v.isAddressDisabled")) {
                component.find('shipStateCode').set("v.disabled", true);
            } else {
                component.find('shipStateCode').set("v.disabled", false);
            }
            component.find('shipStateCode').set("v.options", opts);
            component.set("v.isBPUpdated", true);
        }
    },
    getStateOptionsOfCountryChangeByCode: function(component, val, type) {
        var opts = {};
        try {
            var depnedentFieldMap = '';
            if (type == "Shipping") {
            depnedentFieldMap = component.get("v.depnedentFieldMapShip");
        }
            else if (type == "Billing"){
            depnedentFieldMap = component.get("v.depnedentFieldMapBill");
         }
            
            if (depnedentFieldMap != undefined) {
                var controllerValueKey = val;
                //console.log('controllerValueKey==',controllerValueKey);
                //console.log('depnedentFieldMap==',depnedentFieldMap);
                //console.log(depnedentFieldMap);
                if (controllerValueKey) {
                    var ListOfDependentFields = depnedentFieldMap[controllerValueKey];
                    //console.log('ListOfDependentFields==',ListOfDependentFields);
                     //console.log(ListOfDependentFields);
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
    fetchDependentPicklistValues: function(component, type) {
        var param = JSON.stringify({
            objApi: 'Account',
            contrfieldApiName: 'BillingCountryCode',
            depfieldApiName: 'BillingStateCode'
        });
        if (type == "Shipping") {
            param = JSON.stringify({
                objApi: 'Account',
                contrfieldApiName: 'ShippingCountryCode',
                depfieldApiName: 'ShippingStateCode'
            });
            component.set("v.shipStateLoading",true);
        }
        else{
            component.set("v.billStateLoading",true);
        }

        
        var action = component.get("c.getDependentMap");
        action.setParams({ parameters: param });
        action.setCallback(this, function(response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS") {
                //store the return response from server (map<string,List<string>>)                  
                // once set #StoreResponse to depnedentFieldMap attribute 
                var accObj = component.get("v.accountObj");
                
                var val = accObj.ShippingCountryCode;
                if (type == "Billing") {
                    val = accObj.BillingCountryCode;
                    component.set("v.billStateLoading",false);
                    component.set("v.depnedentFieldMapBill", response.getReturnValue());
                }
                else{
                    component.set("v.shipStateLoading",false);
                    component.set("v.depnedentFieldMapShip", response.getReturnValue());
                }
                if (!$A.util.isEmpty(val) && val != undefined) {
                    this.onControllerFieldChange(component, val, type);
                }
            } 
            else {
                window._LtngUtility.handleErrors(response.getError());
            }
        });
        $A.enqueueAction(action);

    },
    validateAdd:function(component){
        
        var searchKeyBill = component.get("v.searchKeyBill");
        var isValid = true;
        
        if($A.util.isEmpty(searchKeyBill)){
            isValid=false;
            component.find("inputFieldsBill").showHelpMessageIfInvalid();
        }
       
        if($A.util.isEmpty(component.find("inputFieldBillingCountry").get("v.value"))){
            isValid=false;
            component.find("inputFieldBillingCountry").showHelpMessageIfInvalid();
        }
        return isValid;
    },
    
   /** added Method for pass Record Type on BK-4977 By Shiv Raghav - 02-06-2020 */
    getRecordType:function(component){
        var recordId = component.get("v.recordId");
        var action = component.get("c.getRecordType");
        action.setParams({recordId : recordId});
        action.setCallback(this,function(resp){
            component.set( "v.defaultRecordType",resp.getReturnValue());
            
        });
        $A.enqueueAction(action);
    }
})