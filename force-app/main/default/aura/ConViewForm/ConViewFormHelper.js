({
	fetchUser: function(component) {
        var action = component.get("c.getCurrentUserDtls");
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {    
            	var userDtls =res.getReturnValue();
              	if(userDtls)
              	{
                    if(userDtls.Profile.Name == 'System Administrator' || userDtls.Profile.Name == 'GE BA Administrator' || userDtls.Profile.Name =='GE System Administrator' || userDtls.Profile.Name== 'Global SFDC Team Integration Users') 
	              	{
						$A.util.removeClass(component.find("summary"), "slds-hide");
						$A.util.removeClass(component.find("address"), "slds-hide");
						$A.util.removeClass(component.find("admin"), "slds-hide");
	              	}
	              	else if(userDtls.Profile.Name == 'Sales' || userDtls.Profile.Name == 'Sales Brasil' || userDtls.Profile.Name == 'Sales-Brasil' || userDtls.Profile.Name == 'Operations' ) 
	              	{
						$A.util.removeClass(component.find("summary"), "slds-hide");
                        $A.util.removeClass(component.find("address"), "slds-hide");
	              	}
                    else if(userDtls.Profile.Name == 'SSC Finance-Accounting') 
                    {
                        $A.util.removeClass(component.find("summary"), "slds-hide");
                        $A.util.removeClass(component.find("address"), "slds-hide");
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
})