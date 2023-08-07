({
    loadData: function(component, event, helper) {
        /* Added by Palla Kishore for the ticket EMEA-72  */
        helper.checkSalesOpsUser(component);
        /* Added by Palla Kishore for the ticket BK-22267  */
        helper.checkSalesOpsExtraUser(component);
        /* Added by Palla Kishore for the ticket BK-22308  */
        helper.checkBrasilSalesOps(component);
        /* Added by Palla Kishore for the ticket BK-24718  */
        helper.checkBrasilConSales(component);
        helper.fetchOpp(component);
        helper.getAllExhibPaidPicklist(component,event); //BK-2636
        helper.getRecordType(component); /** added Method for pass Record Type on BK-4875 on RajesH kumar - 01-06-2020 */
        component.set("v.showSpinner", true);
    },
    
    handleSectionToggle: function(component, event) {
        localStorage.setItem('selectedAccordiansOpp', JSON.stringify(component.find("oppAccordion").get('v.activeSectionName')));
    },
    
    handleLoad: function(component, event) {
        component.set("v.showSpinner", false);
    },
    
    isBarterChecked: function(component, event, helper){
        var checkCmp = event.getSource().get("v.value");
        
        if(checkCmp){
            helper.isBarterCheckedmodal(component, event, helper);
            component.set("v.IsbarterValue", checkCmp);
            
        }
        else {
            component.set("v.IsbarterValue", checkCmp);
            component.set("v.showBarterPopup",false);
        }  
    },
    
    isRefreshed: function(component, event, helper) {
        window.location.reload();
    },
    
    closepopup: function(component, event, helper){
        component.set("v.showBarterPopup",false);
        $A.get('e.force:refreshView').fire();
    },
    
    handleSubmit: function(component, event, helper) {
        event.preventDefault(); // stop the form from submitting
        var fields = event.getParam('fields');
        fields.Opportunity_Contact__c = component.get("v.oppDetails.Opportunity_Contact__c");
        fields.Billing_Contact__c = component.get("v.oppDetails.Billing_Contact__c");
        fields.Operations_Contact__c = component.get("v.oppDetails.Operations_Contact__c");
        fields.Operation_Contact_2__c = component.get("v.oppDetails.Operation_Contact_2__c");
        fields.Nota_Fiscal__c = component.get("v.oppDetails.Nota_Fiscal__c");
        fields.Marketing_Contact__c = component.get("v.oppDetails.Marketing_Contact__c");
        fields.Legal_Representative_1__c = component.get("v.oppDetails.Legal_Representative_1__c");
        fields.Agreement_Contact__c = component.get("v.oppDetails.Agreement_Contact__c");
        fields.Safety_Contact__c = component.get("v.oppDetails.Safety_Contact__c");
        fields.Legal_Representative_2__c = component.get("v.oppDetails.Legal_Representative_2__c");
        fields.MarkitMkr_Contact__c = component.get("v.oppDetails.MarkitMkr_Contact__c");
        fields.Local_Representative__c = component.get("v.oppDetails.Local_Representative__c");
        fields.Witness_Contact__c = component.get("v.oppDetails.Witness_Contact__c");
        //fields.recordTypeId = component.get("v.defaultRecordType");
        var isBarterCheckedBox = component.get("v.IsbarterValue");
        if(isBarterCheckedBox == true){
            fields.Is_Barter_Opportunity__c = isBarterCheckedBox;
        }
        
        if (isSales == true && opp.stagename != "Closed Won") {
            fields.Exhibitor_Paid_By__c = component.get("v.picklist_Values_Selected"); //BK-2636 
        }        
        //Updated by Rajesh Kumar yadav related ticket BK-2374
        if (!$A.util.isEmpty(component.get("v.selectedCurrency"))) {
            fields.CurrencyIsoCode = component.get("v.selectedCurrency");
        }
        fields.OwnerId = component.get("v.oppDetails.OwnerId");
        if (component.get("v.probability")) {
            fields.Probability = component.get("v.probability");
        }
        var isSales = component.get("v.isReadOnlyforSales");
        var opp = component.get("v.oppDetails");
        if (isSales == true && opp.stagename != "Closed Lost") {
            fields.Exhibitor_Paid_By__c = component.get("v.picklist_Values_Selected");
        }
        component.find('editForm').submit(fields);
    },
    handleSuccess: function(component, event, helper) {
        component.set('v.showSpinner', false);
        component.set("v.isEditForm", false);
        $A.get("e.c:refreshEvent").fire();
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": '/lightning/r/Opportunity/' + component.get("v.recordId") + '/view'
        });
        urlEvent.fire();
        window._LtngUtility.toast('Success', 'success', 'Opportunity has been updated');
    },
    handleError: function(component, event, helper) {
        component.set('v.showSpinner', false);
        //console.log(event.getParams());
        var strError = event.getParams().error;
        if (strError.error) {
            if (strError.error.body.errorCode == 'QUERY_TOO_COMPLICATED') {
                window.location = '/lightning/r/Opportunity/' + component.get("v.recordId") + '/view'
            } else {
                try {
                    window._LtngUtility.handleError(event.getParams().error);
                } catch (err) {
                    console.log(err);
                }
            }
        } 
        //Commentted code for the ticket BK-10969 on 8-12-2021 - Rajesh Kr But We need to test in UAT and wait for 15 day or more for final round of testing...
        //If failed any other funcationality then we will modify code from source.
        else {
            try {
                window._LtngUtility.handleError(event.getParams().error);
            } catch (err) {
                console.log(err);
            }
        }
    },
    handleCancel: function(component, event, helper) {
        component.set("v.isEditForm", false);
        event.preventDefault();
        console.log('test inside handlecancel');
        //window.location='/lightning/r/Opportunity/'+component.get("v.recordId")+'/view'
    },
    showModal: function(component, event, helper) {
        helper.fetchCurrency(component);
        component.set('v.isOpen', true);
    },
    closeModal: function(component, event, helper) {
        component.set('v.isOpen', false);
    },
    saveCurrency: function(component, event, helper) {
        helper.uapdateCurrency(component);
    },
    onStageChange: function(component, event, helper) {
        var stagename = event.getParam("value");
        if (stagename == 'Discover') {
            component.set("v.probability", "10");
        } else if (stagename == 'Customize') {
            component.set("v.probability", "30");
        } else if (stagename == 'Proposal Sent') {
            component.set("v.probability", "50");
        } else if (stagename == 'Proposal Approved') {
            component.set("v.probability", "60");
        } else if (stagename == 'Contract Sent') {
            component.set("v.probability", "70");
        } else if (stagename == 'Closed Won') {
            component.set("v.probability", "100");
        } else if (stagename == 'Closed Booked') {
            component.set("v.probability", "100");
        } else if (stagename == 'Closed Lost') {
            component.set("v.probability", "0");
        }
    }       
})