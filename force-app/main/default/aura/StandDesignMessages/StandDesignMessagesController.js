({
	onLoad: function(component,event,helper) {           
        
        // if(!component.get("v.Cmploaded"))
        // {
        //     var objEditor1 = component.get("v.objEditorMsg");
        //     objEditor1("editor3","");
        //     component.set("v.Cmploaded",true);            
        // }
        helper.fetchStandDesignMessages(component,event,helper);
        
    },
    showModelEmailContent: function(component,event,helper) {  
        
        var contentid = event.target.getAttribute("data-id");
        //console.log('contentid = '+ contentid);
        var map = component.get("v.emailContentMap");
        component.set("v.emailContent", map.get(contentid));
        document.getElementById('modelEmailContent').style.display = "block"; 
    },
    hideModelEmailContent: function(component,event,helper) { 
        document.getElementById('modelEmailContent').style.display = "none";
    },
    // PopUpClosedChanges: function(component,event,helper) {
    //     helper.ReInitialize(component);
    // },
    showModelEmailForward: function(component,event,helper) {  

        var target = event.getSource();
        var contentid = target.get("v.value");
        //console.log('contentid = '+ contentid);
        var map = component.get("v.emailContentMap");
        //var objEditor = component.get("v.objEditorMsg");
        //console.log(JSON.stringify(map.get(contentid).Content__c));
        //objEditor("",map.get(contentid).Content__c,"");        
        component.set("v.emailContent", map.get(contentid));
        document.getElementById('modelEmailForward').style.display = "block"; 
    },
    hideModelEmailForward: function(component,event,helper) { 
        document.getElementById('modelEmailForward').style.display = "none";
        helper.fetchStandDesignMessages(component,event,helper);
    },
    waiting: function(component, event, helper) {
        component.set("v.isSpinner", true);// Adding values in Aura attribute variable. 
    },
    doneWaiting: function(component, event, helper) {
        component.set("v.isSpinner", false);// Adding values in Aura attribute variable. 
    },
    forwardEmail: function(component, event, helper){
        var isValidEmail = true;
        var emailtoField = component.find("emailto");
        var emailtoFieldValue = emailtoField.get("v.value");
        var regExpEmailformat = /^(([a-zA-Z0-9_\-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([a-zA-Z0-9\-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)(\s*,\s*|\s*$))*$/;
        if(!$A.util.isEmpty(emailtoFieldValue))
        {
            if(!$A.util.isEmpty(emailtoFieldValue) &&  emailtoFieldValue != ' ')
            {
                if(emailtoFieldValue.match(regExpEmailformat))
                {
                    emailtoField.set("v.errors", [{message: null}]);
                    $A.util.removeClass(emailtoField, 'slds-has-error');
                    isValidEmail = true;
                    helper.forwardEmailConHelper(component, event, helper);
                }
                else
                {
                    $A.util.addClass(emailtoField, 'slds-has-error');
                    emailtoField.set("v.errors", [{message: "Please Enter a Valid Email Address"}]);
                    isValidEmail = false; 
                } 
            }
        }
        else if($A.util.isEmpty(emailtoFieldValue))
        {
            $A.util.addClass(emailtoField, 'slds-has-error');
            emailtoField.set("v.errors", [{message: "Please Enter a Valid Email Address"}]);
        }
    }
})