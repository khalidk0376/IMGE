({
    loadData: function(component, event, helper) {        
        helper.fetchData(component);        
        var getSelected = localStorage.getItem('selectedAccordiansAcc');
        if (getSelected) {
            component.set("v.activeSections", JSON.parse(getSelected));
        }
    helper.getRecordType(component); /** added Method for pass Record Type on BK-4977 by Shiv Raghav - 02-06-2020 */
    helper.getGoogleApiMapping(component); /* added method to fetch custom Metadata map values [BSM-371 by Garima Gupta] */
   },
    
    handleSectionToggle: function(component, event) {
        localStorage.setItem('selectedAccordiansAcc', JSON.stringify(component.find("accAccordion").get('v.activeSectionName')));
    },
    handleLoad: function(component, event) {
        
    },
    handleSubmit: function(component, event, helper) {
        event.preventDefault();
        if(!helper.validateAdd(component)){
            window._LtngUtility.toast('Error','error','Please fill all required fields.');
            return false;
        }
        
        
        if (component.get("v.isBPUpdated") && component.get("v.hasBpNumber")) {
            component.set("v.isSaveClick", true);
        } 
        else 
        {    
            var fields = event.getParam('fields');
            var shipAdd = component.get("v.shipAdd");
            var billAdd = component.get("v.billAdd");
            console.log('shipAdd: '+JSON.stringify(component.get("v.billAdd")));
            //Shipping
            fields.BillingStreet = component.get("v.searchKeyBill");
            fields.Billing_Address_Line_2__c = billAdd.billingAddLine2!=undefined?billAdd.billingAddLine2:'';
            fields.BillingCity = billAdd.billingCity!=undefined?billAdd.billingCity:'';
            fields.BillingCountryCode = billAdd.billingCountryCode!=undefined?billAdd.billingCountryCode:'';
            if (billAdd.billingCountryCode != 'NG'){
                fields.BillingStateCode = billAdd.billingStateCode!=undefined?billAdd.billingStateCode:''; 
            }
            fields.BillingPostalCode = billAdd.billingPostalCode!=undefined?billAdd.billingPostalCode:'';
            //Billing
            fields.ShippingStreet = component.get("v.searchKey");
            fields.Shipping_Address_2__c = shipAdd.shippingAddLine2==undefined?'':shipAdd.shippingAddLine2;
            fields.ShippingCity = shipAdd.shippingCity==undefined?'':shipAdd.shippingCity;
            fields.ShippingCountryCode = shipAdd.shippingCountryCode==undefined?'':shipAdd.shippingCountryCode;
            if (shipAdd.shippingCountryCode != 'NG'){
                fields.ShippingStateCode = shipAdd.shippingStateCode==undefined?'':shipAdd.shippingStateCode;
            }
            fields.ShippingPostalCode = shipAdd.shippingPostalCode==undefined?'':shipAdd.shippingPostalCode;
            
            //copy address
            if(fields.IsFromBillingAddress__c){
                fields.ShippingStreet = component.get("v.searchKeyBill");
                fields.Shipping_Address_2__c = fields.Billing_Address_Line_2__c;
                fields.ShippingCity = fields.BillingCity;
                fields.ShippingCountryCode = fields.BillingCountryCode;
                fields.ShippingStateCode = fields.BillingStateCode;
                fields.ShippingPostalCode = fields.BillingPostalCode;
                
                component.set("v.searchKey",component.get("v.searchKeyBill"));
                shipAdd.shippingAddLine2=fields.Billing_Address_Line_2__c;
                shipAdd.shippingCity=fields.BillingCity;
                shipAdd.shippingCountryCode=fields.BillingCountryCode;
                shipAdd.shippingStateCode=fields.BillingStateCode;
                shipAdd.shippingPostalCode=fields.BillingPostalCode;
                component.set("v.shipAdd",shipAdd);
            }
            else if(fields.IsFromShippingAddress__c){
                fields.BillingStreet = component.get("v.searchKey");
                fields.Billing_Address_Line_2__c = fields.Shipping_Address_2__c;
                fields.BillingCity = fields.ShippingCity;
                fields.BillingCountryCode = fields.ShippingCountryCode;
                fields.BillingStateCode = fields.ShippingStateCode;
                fields.BillingPostalCode = fields.ShippingPostalCode;
            }
            
            //time to 60 characters if searchKey greater than 60 chars.
            var add1='',add2 = fields.Billing_Address_Line_2__c,addArr,searchKey=fields.BillingStreet;
            if(searchKey && searchKey.length>60){
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
            
            component.set("v.searchKeyBill",add1);
            fields.BillingStreet = add1;
            fields.Billing_Address_Line_2__c = add2.substring(0,40);
            
            add1='',add2 = fields.Shipping_Address_2__c,addArr,searchKey=fields.ShippingStreet;
            if(searchKey && searchKey.length>60){
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
            var inactive = component.get("v.accountObj.Inactive__c");
            if(inactive == true){
                fields.Inactive__c = component.get("v.accountObj.Inactive__c");
            }
            
            else{
                add1 = searchKey;   
            }
            component.set("v.searchKey",add1);
            fields.ShippingStreet = add1;
            fields.Shipping_Address_2__c = add2.substring(0,40);
            
            fields.Simples_Nacional__c = component.get("v.accountObj.Simples_Nacional__c");
            fields.Organization_Business_Vol__c = component.get("v.accountObj.Organization_Business_Vol__c");
            fields.Organization_Size_In_Person__c = component.get("v.accountObj.Organization_Size_In_Person__c");
            fields.Employees__c = component.get("v.accountObj.Employees__c");
            fields.Industry__c = component.get("v.accountObj.Industry__c");
            fields.Accounting_Credit_Hold__c = component.get("v.accountObj.Accounting_Credit_Hold__c");
            shipAdd.shippingAddLine2 = fields.Shipping_Address_2__c;
            billAdd.billingAddLine2 = fields.Billing_Address_Line_2__c;
            component.set("v.shipAdd",shipAdd);
            component.set("v.billAdd",billAdd);
            /** BK-3828 - Rajesh Kumar on 14-04-2020  */
            if (fields.National_Classification__c == "" && component.get("v.hasNationalClassficationNull") == true ){
           // if (fields.National_Classification__c == ""){
                window._LtngUtility.toast('Warning','Warning','Please populate National Classification Field to Continue.');
            }
            else{
                component.set("v.showSpinner", true);
                component.find('editForm').submit(fields);
            }
            
            $A.get("e.c:refreshEvent").fire();
        } 
    },
    handleSuccess: function(component, event, helper) {
        //var refreshEvt = $A.get("e.c:refreshUpload");
        var recId = component.get('v.recordId');
        component.set('v.showSpinner', false);
        component.set("v.isEditForm", false);
        window._LtngUtility.toast('Success', 'success', 'Account has been successfully updated.');
        component.set("v.isBPUpdated", false);
        component.set("v.isSaveClick", false);
        component.set("v.response", "");
        //refreshEvt.fire();
        
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/" +component.get('v.recordId')
        });
        urlEvent.fire();
        location.reload();
        //$A.get('e.force:refreshView').fire();
        //$A.get('e.force:refreshView').fire();
    },
    handleError: function(component, event, helper) {
       
        event.preventDefault();
        component.set('v.showSpinner', false);
        //component.set("v.isEditForm", true);
        component.set("v.response", "");
        var strError =event.getParams().error;          
        //window._LtngUtility.handleError(strError);  
        // Display the message
        console.error(strError);       
    },
    onCancelClick: function(component, event, helper) {
        event.preventDefault();
        component.set('v.showSpinner', false);
        component.set("v.isEditForm", false);
        component.set("v.response", "");
    },
    // Google Address Auto complete Start
    handleBlur: function(component, event, helper) {
        window.setTimeout(
            $A.getCallback(function() {
                var searchLookup = component.find("searchLookup");
                $A.util.removeClass(searchLookup, 'slds-is-open');
                $A.util.addClass(searchLookup, 'slds-combobox-lookup');
                var searchLookupBilling = component.find("searchLookupBilling");
                $A.util.removeClass(searchLookupBilling, 'slds-is-open');
                $A.util.addClass(searchLookupBilling, 'slds-combobox-lookup');
            }), 500
        );
    },
    handleSelect: function(component, event, helper) {
        component.set("v.shipAdd",{});
        component.set("v.searchKey", event.currentTarget.getAttribute("data-record"));
        var searchLookup = component.find("searchLookup");
        $A.util.removeClass(searchLookup, 'slds-is-open');
        $A.util.addClass(searchLookup, 'slds-combobox-lookup');
        helper.displayOptionDetailsShip(component, event, event.currentTarget.getAttribute("data-placeid"));
    },
    handleSelectBill: function(component, event, helper) {
        component.set("v.billAdd",{});
        component.set("v.searchKeyBill", event.currentTarget.getAttribute("data-record"));
        var searchLookup = component.find("searchLookupBilling");
        $A.util.removeClass(searchLookup, 'slds-is-open');
        $A.util.addClass(searchLookup, 'slds-combobox-lookup');
        helper.displayOptionDetailsBill(component, event, event.currentTarget.getAttribute("data-placeid"));
    },
    keyPressController: function(component, event, helper) {
        event.getSource().set("v.validity", { valid: true, badInput: false });
        event.getSource().showHelpMessageIfInvalid();
        var prpActVal2 = event.getSource().get("v.value");
        var searchKey = component.get("v.searchKey");
        if(searchKey && searchKey.length>1){
            helper.openListbox(component, searchKey, "Ship");
            helper.displayOptionsLocation(component, searchKey, "Ship");
        }
        else{
            component.set("v.shipAdd",{});
        }
    },
    keyPressControllerBill: function(component, event, helper) {
        event.getSource().set("v.validity", { valid: true, badInput: false });
        event.getSource().showHelpMessageIfInvalid();
        var prpActVal2 = event.getSource().get("v.value");
        var searchKey = component.get("v.searchKeyBill");
        if(searchKey && searchKey.length>1){
            helper.openListbox(component, searchKey, "bill");
            helper.displayOptionsLocation(component, searchKey, "bill");    
        }
        else{
            component.set("v.billAdd",{});
        }
    },
    // Google Address Auto complete End
    setvalue: function(component, event, helper) {
        event.preventDefault();
        var fields = event.getParam('fields');
    },
    onBillingCountryChange: function(component, event, helper) {
        var val = event.getSource().get("v.value");
        
        helper.onControllerFieldChange(component, val, "Billing");
    },
    onShippingCountryChange: function(component, event, helper) {
        var val = event.getSource().get("v.value");        
        helper.onControllerFieldChange(component, val, "Shipping");
    },
    onFieldChange: function(component, event, helper) {
        component.set("v.isBPUpdated", true);
    },
    //copy from shipping address to billing address
    onCopyShippingAdd: function(component, event, helper) {
        component.set("v.isBPUpdated", true);
        var shipAdd = component.get("v.shipAdd");
        var billAdd = {};
        
        if(event.getParam("checked")){
            component.set("v.searchKeyBill",component.get("v.searchKey"));
            billAdd.billingAddLine2 = shipAdd.shippingAddLine2;
            billAdd.billingCity = shipAdd.shippingCity;
            billAdd.billingCountryCode = shipAdd.shippingCountryCode;
            billAdd.billingStateCode = shipAdd.shippingStateCode;
            billAdd.billingPostalCode = shipAdd.shippingPostalCode;
            component.set("v.billAdd",billAdd);
            helper.onControllerFieldChange(component,shipAdd.shippingCountryCode,'Billing')
        }
    },
    //copy from billing address to shipping address
    onCopyBillingAdd: function(component, event, helper) {
        component.set("v.isBPUpdated", true);
        var billAdd = component.get("v.billAdd");
        var shipAdd = {};
        console.log(event.getParam("checked"));
        if(event.getParam("checked")){
            component.set("v.searchKey",component.get("v.searchKeyBill"));
            shipAdd.shippingAddLine2 = billAdd.billingAddLine2;
            shipAdd.shippingCity = billAdd.billingCity;
            shipAdd.shippingCountryCode = billAdd.billingCountryCode;
            shipAdd.shippingStateCode = billAdd.billingStateCode;
            shipAdd.shippingPostalCode = billAdd.billingPostalCode;
            component.set("v.shipAdd",shipAdd);
            helper.onControllerFieldChange(component,billAdd.billingCountryCode,'Shipping')
        }
    },
    onResponseChange: function(component, event, helper) {
        
        component.set("v.response",event.getParam("response"));
        if (event.getParam("response") == "true") {            
            component.set("v.isBPUpdated", false);
            component.find("saveBtn").getElement().click();
            //component.find('editForm').submit();
        } 
        else{
            component.set("v.isSaveClick", false);
        }
    }
    
})