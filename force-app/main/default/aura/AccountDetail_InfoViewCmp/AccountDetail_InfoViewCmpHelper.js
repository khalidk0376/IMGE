({
    fetchUser: function(component) {
        var action = component.get("c.getCurrentUserDtls");
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {    
                var userDtls =res.getReturnValue();
                if(userDtls)
                {
                    if(userDtls.Profile.Name == 'System Administrator' || userDtls.Profile.Name == 'GE BA Administrator' || userDtls.Profile.Name == 'GE System Administrator' || userDtls.Profile.Name== 'Global SFDC Team Integration Users') 
                    {
                        $A.util.removeClass(component.find("summaryView"), "slds-hide");
                        $A.util.removeClass(component.find("interestLevelnatureOfBuisness"), "slds-hide");
                        $A.util.removeClass(component.find("sscView"), "slds-hide");
                        $A.util.removeClass(component.find("adminView"), "slds-hide");
                        $A.util.removeClass(component.find("accountTranslatedInfo"), "slds-hide");
                        $A.util.removeClass(component.find("accountaddInfo"), "slds-hide");
                    }
                    
                    else if(userDtls.Profile.Name == 'Sales' || userDtls.Profile.Name == 'Sales-Brasil' || userDtls.Profile.Name == 'Operations') 
                    {
                        $A.util.removeClass(component.find("summaryView"), "slds-hide");
                        $A.util.removeClass(component.find("interestLevelnatureOfBuisness"), "slds-hide");
                        $A.util.removeClass(component.find("accountaddInfo"), "slds-hide");
                        $A.util.removeClass(component.find("accountTranslatedInfo"), "slds-hide");
                    }
                        else if(userDtls.Profile.Name == 'SSC Finance-Accounting') 
                        {
                            $A.util.removeClass(component.find("summaryView"), "slds-hide");
                            $A.util.removeClass(component.find("interestLevelnatureOfBuisness"), "slds-hide");
                            $A.util.removeClass(component.find("accountaddInfo"), "slds-hide");
                            $A.util.removeClass(component.find("accountTranslatedInfo"), "slds-hide");
                            $A.util.removeClass(component.find("sscView"), "slds-hide");
                        }
                    component.set("v.usrDtls",userDtls);
                    console.log('User Profile : ' + userDtls.Profile.Name)
                }
                
            }
            else 
            {
                window._LtngUtility.handleErrors(res.getError());
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
                var credit = JSON.stringify(responseResult.Credit_Status__c);
                component.set("v.AcDetails", responseResult);
            } else {
                window._LtngUtility.toast('Error', 'error', res.getError());
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
})