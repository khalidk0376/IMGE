({
    onLoad: function(component,event,helper) {
        var mailCode = new Map([['exhNoCon' , 'EWC'], ['exhShw' ,'EPSR' ] ,['conShw', 'CPSR'],['prfmBond', 'CPBR'],['stsNoDsn', 'BDSR'],['stsResmt', 'BDSR-CR'],['stsPndSalApv', 'BDSR-PSA']]);
        var mailCc = new Map([['exhNoCon' ,' '], ['exhShw' ,' ' ] ,['conShw', ' '],['prfmBond',' '],['stsNoDsn',' '],['stsResmt',' '],['stsPndSalApv',' ']]);    
        component.set('v.mailMapCode',mailCode); //map of Salesforce Email template code with component code 
        component.set('v.mailMapCc',mailCc); // map to contain CC Address with repect to mailCode 
        // var objEditor = component.get("v.objEditor");
        // objEditor("editor",""); 

    },
    waiting: function(component, event, helper) {
        component.set("v.isSpinner", true);// Adding values in Aura attribute variable. 
     },
    doneWaiting: function(component, event, helper) {
        component.set("v.isSpinner", false);// Adding values in Aura attribute variable. 
    },
    hideModelConfirm: function(component,event,helper) { 
        document.getElementById('modelConfirm').style.display = "none";
    },
    hideModelEmailTemplateEditor: function(component,event,helper) { 
        document.getElementById('modelEmailTemplateEditor').style.display = "none";
    },
    showModelEmailTemplateEditor: function(component,event,helper) {
        var emailField = component.find("emailcc");
        emailField.set("v.errors", [{message: null}]); 
        $A.util.removeClass(emailField, 'slds-has-error');
        var target = event.getSource().get("v.value");
        component.set('v.emailContentCode',target);
        helper.getMailContent(component,target);
        //document.getElementById('modelEmailTemplateEditor').style.display = "block"; 
    },
    // updateTemplate: function(component,event,helper) {
    //     var emailContent = component.get('v.emailContent');

    //     if(emailContent) {
    //        helper.updateEmailTemplate(component);      
    //     }

    // },
    updateTemplate: function(component,event,helper) {
        var emailContent = component.get('v.emailContent');
        var mailMapCc = component.get('v.mailMapCc');
        var emailContentCode = component.get("v.emailContentCode");
        var isValidEmail = true;
        var emailField = component.find("emailcc");
        var emailFieldValue = emailField.get("v.value");
        document.getElementById('modelEmailTemplateEditor').style.display = "none";
        
        //var regExpEmailformat = /^(([a-zA-Z0-9_\-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([a-zA-Z0-9\-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)(\s*,\s*|\s*$))*$/;
        var regExpEmailformat = /^(([a-zA-Z0-9_\-]+([a-zA-Z0-9_\-\.]+)+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([a-zA-Z0-9\-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)(\s*,\s*|\s*$))*$/;
        if(!$A.util.isEmpty(emailFieldValue) &&  emailFieldValue != ' ')
        {  
            if(emailFieldValue.match(regExpEmailformat) && emailContent)
            {
                emailField.set("v.errors", [{message: null}]);
                $A.util.removeClass(emailField, 'slds-has-error');
                isValidEmail = true;
                mailMapCc.set(emailContentCode, emailFieldValue);
                document.getElementById('modelEmailTemplateEditor').style.display = "none";
                helper.updateEmailTemplate(component);  
            }else
            {
                $A.util.addClass(emailField, 'slds-has-error');
                emailField.set("v.errors", [{message: "Please Enter a Valid Email Address"}]);
                isValidEmail = false;
            }   
        }
        else if(emailContent){
            mailMapCc.set(emailContentCode, emailFieldValue);
            document.getElementById('modelEmailTemplateEditor').style.display = "none";
            helper.updateEmailTemplate(component);
        }
        

    },
    mailExhNoCon: function(component,event,helper) { 
        //console.log('mailExhNoCon');
        helper.mailExhWithoutCon(component); 
    },
    mailExhShw: function(component,event,helper) {  
        //console.log('mailExhShw');
        helper.mailExhPreShwReminder(component);
    }, 
    mailConShw: function(component,event,helper) { 
        //console.log('mailConShw');
        helper.mailContPreShwReminder(component); 
    },
    mailPrfmBond: function(component,event,helper) { 
        console.log('mailPrfmBond');
        helper.mailPerformanceBondReminder(component) 
    },
    mailStsNoDsn: function(component,event,helper) {  
        //console.log('mailStsNoDsn');
        helper.mailContStatusReminder(component,'No Design','BDSR','stsNoDsn');  
    },
    mailStsResmt: function(component,event,helper) { 
        //console.log('mailStsResmt'); 
        helper.mailContStatusReminder(component,'Contractor Resubmit (Incomplete)','BDSR-CR','stsResmt'); 
    },
    mailStsPndSalApv: function(component,event,helper) {        
        //console.log('mailExhNoCon');
        helper.mailContStatusReminder(component,'Pending Sales Approval','BDSR-PSA','stsPndSalApv'); 
    }

})