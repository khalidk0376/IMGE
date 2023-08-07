({
    fetchOpp: function(component) {
        var oppId = component.get("v.recordId");
        var action = component.get("c.getAllDatas");
        action.setParams({ recordId: oppId, objectName: 'Opportunity', fields: 'User_Type__c,User_Type__r.Name, EventEdition__c,Nota_Fiscal__c,Opportunity_Contact__c,Safety_Contact__c ,Legal_Representative_2__c,MarkitMkr_Contact__c,Local_Representative__c,Do_not_activate_Billing__c,Exhibitor_Paid_By__c,Agent_s_Opportunity__c,Billing_Contact__c,Operations_Contact__c, Marketing_Contact__c , Operation_Contact_2__c ,Legal_Representative_1__c,Witness_Contact__c ,Agreement_Contact__c ,OwnerId, AccountId,Account.Name,StageName,Partner_Account__c,Is_Barter_Opportunity__c,recordTypeId,Cloned_From_Opportunity__c,Event_Edition_Status__c,Review_by_Sales_Ops_Team__c,Declaration_Document_Uploaded__c,Customer_Tier__c,Mixed_Supply__c' });
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {
                var obj = res.getReturnValue();
                var userDtls = obj.userDetail;
                var oppdtls = obj.oppDetail[0];               
                component.set("v.probability", obj.oppDetail[0].Probability)
                component.set("v.oppDetails", obj.oppDetail[0]);
                component.set("v.IsDoNotActivateBilling", obj.allowProfile);
                component.set("v.picklist_Values_Selected", oppdtls.Exhibitor_Paid_By__c);
                //Component.set("v.ClonedFromOpporunity" , oppdtls.Cloned_From_Opportunity__c);
                var allowProfile = obj.allowProfile;
                var primaryQuote = obj.primaryQuote;
                var primaryQuoteProducts = obj.primaryQuoteProducts;
                if (oppdtls.StageName != 'Discover') {
                    component.set("v.isReadOnlyBarter", true);
                }
                if ((allowProfile.length == 0 || userDtls.Profile.Name == 'SSC Finance-Accounting') && primaryQuote.length > 0 && primaryQuoteProducts.length > 0) {
                    component.set("v.revenueEstimateDisabled", true);
                } else if (allowProfile.length > 0 && userDtls.Profile.Name != 'SSC Finance-Accounting') {
                    component.set("v.revenueEstimateDisabled", false);
                } else if ((allowProfile.length == 0 || userDtls.Profile.Name == 'SSC Finance-Accounting') && primaryQuote.length > 0 && primaryQuoteProducts.length == 0) {
                    component.set("v.revenueEstimateDisabled", false);
                } else if ((allowProfile.length == 0 || userDtls.Profile.Name == 'SSC Finance-Accounting') && primaryQuote.length == 0 && primaryQuoteProducts.length == 0) {
                    component.set("v.revenueEstimateDisabled", false);
                }
                if (userDtls) {  
                    if (userDtls.Profile.Name == 'System Administrator' || userDtls.Profile.Name == 'GE BA Administrator' || userDtls.Profile.Name == 'GE System Administrator' || userDtls.Profile.Name== 'Global SFDC Team Integration Users') {
                        $A.util.removeClass(component.find("summary"), "slds-hide");
                        $A.util.removeClass(component.find("oppCon"), "slds-hide");
                        $A.util.removeClass(component.find("oppInfo"), "slds-hide");
                        $A.util.removeClass(component.find("bill"), "slds-hide");
                        $A.util.removeClass(component.find("event"), "slds-hide");
                        $A.util.removeClass(component.find("ssc"), "slds-hide");
                        $A.util.removeClass(component.find("admin"), "slds-hide");
                    } else if (userDtls.Profile.Name == 'Sales' || userDtls.Profile.Name == 'Sales Brasil' || userDtls.Profile.Name == 'Sales-Brasil' || userDtls.Profile.Name == 'Operations') {
                        $A.util.removeClass(component.find("summary"), "slds-hide");
                        $A.util.removeClass(component.find("oppCon"), "slds-hide");
                        $A.util.removeClass(component.find("oppInfo"), "slds-hide");
                        $A.util.removeClass(component.find("bill"), "slds-hide");
                        $A.util.removeClass(component.find("event"), "slds-hide");
                        component.set("v.isStatusReadOnly", true);
                    }  else if(userDtls.Profile.Name =='Read Only' && component.get("v.isBrasilROConUpdateUser")) {
                        $A.util.removeClass(component.find("summary"), "slds-hide");
                        $A.util.removeClass(component.find("oppCon"), "slds-hide");
                        $A.util.removeClass(component.find("oppInfo"), "slds-hide");
                        $A.util.removeClass(component.find("bill"), "slds-hide");
                        $A.util.removeClass(component.find("event"), "slds-hide");
                        component.set("v.isReadOnlyBrasilConUpdateUser", true);
                        
                    } else if (userDtls.Profile.Name == 'SSC Finance-Accounting') {
                        $A.util.removeClass(component.find("summary"), "slds-hide");
                        $A.util.removeClass(component.find("oppCon"), "slds-hide");
                        $A.util.removeClass(component.find("oppInfo"), "slds-hide");
                        $A.util.removeClass(component.find("bill"), "slds-hide");
                        $A.util.removeClass(component.find("event"), "slds-hide");
                        $A.util.removeClass(component.find("ssc"), "slds-hide");
                    }
                    
                    if ((userDtls.Profile.Name == 'Sales' || userDtls.Profile.Name == 'Sales Brasil' || userDtls.Profile.Name == 'Sales-Brasil') &&
                        (oppdtls.StageName == 'Closed Lost' || oppdtls.StageName == 'Closed Won' || oppdtls.StageName == 'Closed Booked' 
                         || oppdtls.StageName == 'Discover' || oppdtls.StageName == 'Customize' || oppdtls.StageName == 'Proposal Sent'
                         || oppdtls.StageName == 'Proposal Approved' || oppdtls.StageName == 'Contract Sent')) {
                        component.set("v.isReadOnlyEventEditionforSales", true);
                    }
                    
                    if (userDtls.Profile.Name == 'System Administrator' || userDtls.Profile.Name == 'GE BA Administrator' || userDtls.Profile.Name == 'GE System Administrator' || userDtls.Profile.Name =='Sales-Brasil' || userDtls.Profile.Name == 'SSC Finance-Accounting') {
                        component.set("v.isAdminProfile", true);
                    }else{
                        component.set("v.isNonAdminProfile", true);
                    }
                    // Added by Palla Kishore for the ticket BK-24173
                   if (userDtls.Profile.Name == 'System Administrator' || userDtls.Profile.Name == 'GE BA Administrator' || userDtls.Profile.Name == 'GE System Administrator' || userDtls.Profile.Name =='Sales-Brasil') {
					component.set("v.isAddressValidationBRProfiles", true);
                   }
                    if(oppdtls.StageName == 'Closed Lost' || oppdtls.StageName == 'Closed Won' || oppdtls.StageName == 'Closed Booked')
                    { 
                       if(userDtls.Profile.Name == 'Sales' && !component.get("v.isSalesOpsUser") ) 
                        {
                            component.set("v.isReadOnlyforSales", true); 
                        }
                         // Added by Palla Kishore for the ticket BK-22267
                       else if(userDtls.Profile.Name == 'Sales' && component.get("v.isSalesOpsUser") && component.get("v.isSalesOpsExPermissions") ) 
                        {
                            component.set("v.isReadOnlyforSalesOpsExPermissions", true); 
                        }
                        else if(userDtls.Profile.Name == 'Sales' && component.get("v.isSalesOpsUser") ) 
                        { 
                            component.set("v.isReadOnlyforSalesOps", true); 
                        }  
                        
                        else if((userDtls.Profile.Name == 'Sales Brasil' || userDtls.Profile.Name == 'Sales-Brasil') && !component.get("v.isBrasilSalesOpsUser"))
                        {
                            component.set("v.isReadOnlyforSalesBrasil", true);
                            if (oppdtls.StageName == 'Closed Lost' && oppdtls.Exhibitor_Paid_By__c == '' || oppdtls.Exhibitor_Paid_By__c == undefined) {
                                component.set("v.isNewPickLIstForSales", true);
                            }
                        }
                        else if((userDtls.Profile.Name == 'Sales Brasil' || userDtls.Profile.Name == 'Sales-Brasil') && component.get("v.isBrasilSalesOpsUser"))
                        {
                              component.set("v.isReadOnlyforBrasilSalesOps", true); 
                            if (oppdtls.StageName == 'Closed Lost' && oppdtls.Exhibitor_Paid_By__c == '' || oppdtls.Exhibitor_Paid_By__c == undefined) {
                                component.set("v.isNewPickLIstForSales", true);
                            }
                            
                        }
                        else if(userDtls.Profile.Name == 'Operations' || userDtls.Profile.Name == 'Operations Team')
                        {
                           component.set("v.isReadOnlyforOprations", true);                             
                        }
                        else if(userDtls.Profile.Name == 'SSC Finance-Accounting' || userDtls.Profile.Name == 'SSC-R2R Accounting'){
                                component.set("v.isReadOnlyforSSC", true);                             
                       }
                    }
                }
            } else {
                window._LtngUtility.handleErrors(res.getError());
            }
        });
        $A.enqueueAction(action);
    },
    
    //BK-2636
    getAllExhibPaidPicklist: function(component,event){
        var action = component.get("c.getAllExhibPaidByValues");
        action.setCallback(this,function(res){
            var state = res.getState();
            if (state === "SUCCESS"){
                var resPicklist = res.getReturnValue();
                if(resPicklist){
                    component.set("v.picklist_Values",resPicklist);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchCurrency: function(component) {
        var oppId = component.get("v.oppDetails");
        var action = component.get("c.getEventCurrency");
        action.setParams({ eventId: oppId.EventEdition__c });
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {
                var currencies = res.getReturnValue();
                var evntcurr = [];
                for (var i = 0; i < currencies.length; i++) {
                    evntcurr.push({ 'label': currencies[i].Name, 'value': currencies[i].Name });
                }
                component.set("v.eventCurrecies", evntcurr);
            } else {
                window._LtngUtility.handleErrors(res.getError());
            }
        });
        $A.enqueueAction(action);
    },
    
    uapdateCurrency: function(component) {
        var curr = component.get("v.selectedCurrency");
        if (curr) {
            var oppdtls = { Id: component.get("v.recordId"), CurrencyIsoCode: curr };
            var action = component.get("c.updateOpportunity");
            action.setParams({ oppDtls: oppdtls });
            action.setCallback(this, function(res) {
                var state = res.getState();
                if (state === "SUCCESS") {
                    this.updateOpportunityAgain(component);
                } else {
                    window._LtngUtility.toast('Error', 'error', $A.get("$Label.c.CurrencyUpdateMessage"));
                }
            });
            $A.enqueueAction(action);
        } else {
            window._LtngUtility.toast('Error', 'error', 'Please select currecy.');
        }
    },
    
    isBarterCheckedmodal: function(component, event, helper){
        component.set("v.showBarterPopup",true);
    },
    
    refreshView: function(component, event, helper) {
        var action = component.get('c.OppEditForm');
        action.setCallback(component,
                           function(response) {
                               var state = response.getState();
                               if (state === 'SUCCESS'){
                                   $A.get('e.force:refreshView').fire();
                               } 
                           }
                          );
        $A.enqueueAction(action);
    },
    
    updateOpportunityAgain: function(component) {
        var oppdtls = { Id: component.get("v.recordId") };
        var action = component.get("c.updateOpportunity");
        action.setParams({ oppDtls: oppdtls });
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {
                $A.get('e.force:refreshView').fire();
                component.set('v.isOpen', false);
            } else {
                window._LtngUtility.toast('Error', 'error', $A.get("$Label.c.CurrencyUpdateMessage"));
            }
        });
        $A.enqueueAction(action);
    },
    /** added Method for pass Record Type on BK-4875 on RajesH kumar - 01-06-2020 */
    getRecordType:function(component){
        var recordId = component.get("v.recordId");
        var action = component.get("c.getRecordType");
        action.setParams({recordId : recordId});
        action.setCallback(this,function(resp){
            component.set( "v.defaultRecordType",resp.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    /* Added by Palla Kishore for the ticket EMEA-72 */
    checkSalesOpsUser:function(component){
        var action = component.get("c.checkSalesOpsUser");       
        action.setCallback(this,function(resp){
            component.set("v.isSalesOpsUser",resp.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    
     /* Added by Palla Kishore for the ticket BK-22267 */
    checkSalesOpsExtraUser:function(component){
        var action = component.get("c.checkSalesOpsExtraUser");       
        action.setCallback(this,function(resp){
            component.set("v.isSalesOpsExPermissions",resp.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    
    /* Added by Palla Kishore for the ticket BK-22308 */
    checkBrasilSalesOps:function(component){
        var action = component.get("c.checkBrasilSalesOpsUser");       
        action.setCallback(this,function(resp){
            component.set("v.isBrasilSalesOpsUser",resp.getReturnValue());
        });
        $A.enqueueAction(action);
    },
     /* Added by Palla Kishore for the ticket BK-24718 */
    checkBrasilConSales:function(component){
        var action = component.get("c.checkBrasilContactUser");       
        action.setCallback(this,function(resp){
            component.set("v.isBrasilROConUpdateUser",resp.getReturnValue());
        });
        $A.enqueueAction(action);
    }
})