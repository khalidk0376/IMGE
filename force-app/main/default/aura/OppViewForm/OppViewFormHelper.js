({   
    fetchUser: function(component) {      
        var action = component.get("c.getCurrentUserDtls");
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {    
                var userDtls =res.getReturnValue();
                if(userDtls)
                {
                    //If Condition Added By Vaishnavi Rastogi for JIRA TICKET : BSM-345
                    if(userDtls.Profile.Name == 'System Administrator' || userDtls.Profile.Name == 'GE BA Administrator'  || userDtls.Profile.Name =='GE System Administrator' || userDtls.Profile.Name =='Sales-Brasil'){
                        component.set("v.isAdminSalesProfile",true);
                    }
                    if(userDtls.Profile.Name == 'System Administrator' || userDtls.Profile.Name == 'GE BA Administrator'  || userDtls.Profile.Name =='GE System Administrator' || userDtls.Profile.Name== 'Global SFDC Team Integration Users' ) 
                    {
                        
                        $A.util.removeClass(component.find("summary"), "slds-hide");
                        $A.util.removeClass(component.find("oppCon"), "slds-hide");
                        $A.util.removeClass(component.find("oppInfo"), "slds-hide");
                        $A.util.removeClass(component.find("bill"), "slds-hide"); 
                        $A.util.removeClass(component.find("event"), "slds-hide");
                        $A.util.removeClass(component.find("ssc"), "slds-hide");
                        $A.util.removeClass(component.find("admin"), "slds-hide");
                        // <!--EMEA-93 Modified By:- Palla Kishore -->
                        $A.util.removeClass(component.find("salesOps"), "slds-hide");
                        component.set("v.isAdminProfile",true);
                    }
                    else if(userDtls.Profile.Name == 'Sales' || userDtls.Profile.Name == 'Sales Brasil' || userDtls.Profile.Name == 'Sales-Brasil'|| userDtls.Profile.Name == 'Operations')
                    {
                        $A.util.removeClass(component.find("summary"), "slds-hide");
                        $A.util.removeClass(component.find("oppCon"), "slds-hide");
                        $A.util.removeClass(component.find("oppInfo"), "slds-hide");
                        $A.util.removeClass(component.find("bill"), "slds-hide");
                        $A.util.removeClass(component.find("event"), "slds-hide");
                        // <!--EMEA-93 Modified By:- Palla Kishore -->
                        $A.util.removeClass(component.find("salesOps"), "slds-hide");
                        component.set("v.isSales",true);
                    }
                    // Added by Palla kishore for the ticket BK-24718
                        else if(userDtls.Profile.Name =='Read Only' && component.get("v.isBrasilROConUpdateUser"))
                    {
                        $A.util.removeClass(component.find("summary"), "slds-hide");
                        $A.util.removeClass(component.find("oppCon"), "slds-hide");
                        $A.util.removeClass(component.find("oppInfo"), "slds-hide");
                        $A.util.removeClass(component.find("bill"), "slds-hide");
                        $A.util.removeClass(component.find("event"), "slds-hide");
                        // <!--EMEA-93 Modified By:- Palla Kishore -->
                        $A.util.removeClass(component.find("salesOps"), "slds-hide");
                        
                    }
                        else if(userDtls.Profile.Name == 'SSC Finance-Accounting') 
                        {
                            $A.util.removeClass(component.find("summary"), "slds-hide");
                            $A.util.removeClass(component.find("oppCon"), "slds-hide");
                            $A.util.removeClass(component.find("oppInfo"), "slds-hide");
                            $A.util.removeClass(component.find("bill"), "slds-hide");
                            $A.util.removeClass(component.find("event"), "slds-hide");
                            $A.util.removeClass(component.find("ssc"), "slds-hide");
                        }
                }
                this.fetchOpp(component); 
            }
            else 
            {
                window._LtngUtility.handleErrors(res.getError());
            }
            component.set("v.showSpinner",false);
        });
        $A.enqueueAction(action); 
    }, 
    
    fetchCurrency: function(component) {
        var oppId = component.get("v.oppDetails"); 
        var action = component.get("c.getEventCurrency");
        action.setParams({eventId:oppId.EventEdition__c});
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {    
                var currencies =res.getReturnValue();
                var evntcurr=[];
                for(var i=0;i<currencies.length;i++)
                {
                    evntcurr.push({'label': currencies[i].Name, 'value': currencies[i].Id});
                }
                component.set("v.eventCurrecies",evntcurr);
            }
            else 
            {
                window._LtngUtility.handleErrors(res.getError());
            }
        });
        $A.enqueueAction(action); 
    },
    
    updateCurrency: function(component) {
        var curr =component.get("v.selectedCurrency");
        if(curr)
        {
            var oppdtls={Id:component.get("v.recordId"),Event_Edition_Currency__c:curr};
            var action = component.get("c.updateOpportunity");
            action.setParams({oppDtls:oppdtls});
            action.setCallback(this, function(res) {
                var state = res.getState();
                if (state === "SUCCESS") { 
                    this.updateOpportunityAgain(component);
                    //$A.get('e.force:refreshView').fire();
                } 
                else 
                {
                    window._LtngUtility.toast('Error','error',$A.get("$Label.c.CurrencyUpdateMessage")); 
                }
            });
            $A.enqueueAction(action);  
        }
        else 
        {
            window._LtngUtility.toast('Error','error','Please select currecy.'); 
        }
        
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
                //refresh page view code added on 19/05/2019 by Mukesh
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": '/lightning/r/Opportunity/' + component.get("v.recordId") + '/view'
                });
                urlEvent.fire();
            } else {
                window._LtngUtility.toast('Error', 'error', $A.get("$Label.c.CurrencyUpdateMessage"));
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchOpp: function(component) {
        var oppId = component.get("v.recordId"); 
        var action = component.get("c.getRecord");
        action.setParams({recordId:oppId,objectName:'Opportunity',fields:'User_Type__c,User_Type__r.Name,EventEdition__c,Opportunity_Contact__c,Do_not_activate_Billing__c,Exhibitor_Paid_By__c,Agent_s_Opportunity__c,Billing_Contact__c,OwnerId,AccountId,Account.Name,StageName,Partner_Account__c,Event_Edition_Status__c,Review_by_Sales_Ops_Team__c '});
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") { 
                var oppDetails =res.getReturnValue();
                if(oppDetails.length>0)
                {
                    component.set("v.oppDetails",oppDetails[0]);  
                    var userType = component.get('v.oppDetails.User_Type__r.Name'); 
                    if(userType != null && (userType == 'Agent' || userType == 'Exhibitor'))
                    {
                        component.set("v.isParentOpportunity",true);                     
                    }
                }
            }
            else 
            {
                window._LtngUtility.handleErrors(res.getError());
            }
        });
        $A.enqueueAction(action); 
    }, 
    getUserAccess: function(component) {
        var action = component.get("c.getUserRecordAccess");
        action.setParams({recordId:component.get("v.recordId")});
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") { 
                var result= res.getReturnValue();
                if(result.length>0)
                {
                    component.set('v.usrAccess',result[0]);   
                }
            } 
            else 
            {
                window._LtngUtility.handleErrors(res.getError());
            }
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
     /* Added by Palla Kishore for the ticket BK-24718 */
    checkBrasilConSales:function(component){
        var action = component.get("c.checkBrasilContactUser");       
        action.setCallback(this,function(resp){
            component.set("v.isBrasilROConUpdateUser",resp.getReturnValue());
        });
        $A.enqueueAction(action);
    }
})