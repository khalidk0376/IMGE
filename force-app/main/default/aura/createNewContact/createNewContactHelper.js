({
    fields:{},
    getAccountDetail: function(component,accountId) {
        component.set("v.spinner", true);
        let param = JSON.stringify({ accountId: accountId });
        var action = component.get("c.invoke");
        action.setParams({ action: 'get_account', parameters: param });
        action.setCallback(this, function(res) {
            component.set("v.showFields",true);
            component.set("v.spinner", false);
            var state = res.getState();
            if (state === "SUCCESS") {
                let obj = res.getReturnValue();
                component.set("v.recordTypeId", obj.con_record_type_id);
                var conObj = component.get("v.contactObj");
                if (conObj.Id != null && conObj.Id != undefined) {                   
                    component.set("v.contactObj", conObj);
                    component.set("v.contactObj.MailingStreet", conObj.MailingStreet);
                } else {
                    
                    var billingAccObj=obj.accObj.Billing_Address_Line_2__c;
                    if (billingAccObj!= null  || billingAccObj!= undefined) {
                        billingAccObj = billingAccObj.trim();
                        component.set("v.contactObj", {
                            MailingStreet: obj.accObj.BillingStreet+', ' +billingAccObj,
                            MailingCity: obj.accObj.BillingCity,
                            MailingCountryCode: obj.accObj.BillingCountryCode,
                            MailingStateCode: obj.accObj.BillingStateCode,
                            MailingPostalCode: obj.accObj.BillingPostalCode
                        });
                        component.set("v.contactObj.MailingStreet",obj.accObj.BillingStreet+', ' +billingAccObj);
                    } else {
                        component.set("v.contactObj", {
                            AccountId: obj.accObj.Id,
                            MailingStreet: obj.accObj.BillingStreet,
                            MailingCity: obj.accObj.BillingCity,
                            MailingCountryCode: obj.accObj.BillingCountryCode,
                            MailingStateCode: obj.accObj.BillingStateCode,
                            MailingPostalCode: obj.accObj.BillingPostalCode
                        });
                        component.set("v.contactObj.MailingStreet", obj.accObj.BillingStreet);
                    }
                    
                }
                
                component.set("v.meta", obj.meta);                
            } else {
                window._LtngUtility.handleErrors(res.getError());
            }
        });
        $A.enqueueAction(action);
    },
    validateFields:function(cmp){
        var allValid = cmp.find('inputFields').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        
        if (!allValid) {
            window._LtngUtility.toast('Error', 'error', 'Please update the invalid form entries and try again.');
        }        
        return allValid;
    },
    validateOtherFields:function(fields){
        
        var sFirstName = fields.FirstName;
        var sLastName = fields.LastName;
        var sEmail = fields.Email;
        var sPhone = fields.Phone;
        var sMobilePhone = fields.MobilePhone;
        
        /*Trim all fields of contact*/
        sFirstName = typeof sFirstName === 'undefined' ? '': sFirstName.trim();
        sLastName = typeof sLastName === 'undefined' ? '': sLastName.trim();
        sEmail = typeof sEmail === 'undefined' ? '': sEmail.trim();
        sPhone = typeof sPhone === 'undefined' ? '': sPhone.trim();
        sMobilePhone = typeof sMobilePhone === 'undefined' ? '': sMobilePhone.trim();
        
        var regex1 = /^[0-9- ()#+]*$/;
        var regex12 = /^[0-9- ()#+]*$/;
        var filter = /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;
        var sMinimumSevenDigit = /^(?:[\D]*[0-9][\D]*){0,7}$/;
        var sMinimumSevenDigit1 = /^(?:[\D]*[0-9][\D]*){0,7}$/;
        
        
        var rege = /[^a-zA-Z]/;
        var specialChar = /^[- ()#+]*$/;
        
        var BusinessPhoneMessage = $A.get("{!$Label.c.BusinessPhoneMessage}");
        var MobilePhoneMessage = $A.get("{$Label.c.MobilePhoneMessage}");
        var FirstNameCharacterMessage = $A.get("{$Label.c.FirstNameCharacterMessage}");
        var LastNameCharacterMessage = $A.get("{$Label.c.LastNameCharacterMessage}");
        
        
        var str = '';
        var sAplphabets = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"];
        
        for(let i = 0; i < sAplphabets.length; i++){
            if(!$A.util.isEmpty(sPhone) && (sPhone.startsWith(sAplphabets[i]) || sPhone.endsWith(sAplphabets[i])) && !sMinimumSevenDigit.test(sPhone) || sPhone.includes(sAplphabets[i])){
                window._LtngUtility.toast('Error', 'error', BusinessPhoneMessage);
                return false;
            } 
        }
        
        if(sFirstName === ''){
            window._LtngUtility.toast('Error', 'error', FirstNameMessage);            
            return false;
        } else if(sFirstName!=='' && sFirstName.length > 40){
            window._LtngUtility.toast('Error', 'error', FirstNameCharacterMessage);            
            return false;
        } else if(sLastName === ''){
            window._LtngUtility.toast('Error', 'error', LastNameMessage);
            return false;
        } else if(sLastName !=='' && sLastName.length > 80){
            window._LtngUtility.toast('Error', 'error', LastNameCharacterMessage);
            return false;
        }else if(!$A.util.isEmpty(sPhone) && (!rege.test(sPhone) || sMinimumSevenDigit.test(sPhone) || specialChar.test(sPhone) || sPhone.includes("@") || sPhone.includes("!") || sPhone.includes("_") || sPhone.includes("%") || sPhone.includes("$") || sPhone.includes("*") || sPhone.includes(",") || sPhone.includes(".") || sPhone.includes("?") || sPhone.includes("<") || sPhone.includes(">") || sPhone.includes("=") || sPhone.includes("/") || sPhone.includes("|") || sPhone.includes("{") || sPhone.includes("}") || sPhone.includes("[") || sPhone.includes("]") || sPhone.includes("~") || sPhone.includes("`") || sPhone.includes(";") || sPhone.includes(":") || sPhone.includes("^") || sPhone.includes("&") || sPhone.includes("\\"))){
            window._LtngUtility.toast('Error', 'error', BusinessPhoneMessage);
            return false;
        } else if(!$A.util.isEmpty(sMobilePhone) && (!regex12.test(sMobilePhone) || sMinimumSevenDigit1.test(sMobilePhone))){
            window._LtngUtility.toast('Error', 'error', MobilePhoneMessage);
            return false;
        }  
        return true;
    },
    
    onControllerFieldChange: function(component, controllerValueKey) {
        var depnedentFieldMap = component.get("v.depnedentFieldMap");
        var opts = [];
        opts.push({ label: '--Select--', value: '' });
        if (controllerValueKey) {
            var ListOfDependentFields = depnedentFieldMap[controllerValueKey];
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
                component.set("v.isLoading", false);
            } else {
                window._LtngUtility.handleErrors(res.getError());
            }
        });
        $A.enqueueAction(action);
    },
})