({
    loadData: function(component, event, helper) { 
        component.set('v.saveMessage','');
       console.log('sdadadsda  ' +component.get("v.boothId"));
        //helper.fetchContactDetails(component);
        helper.fetchProfileOptionVisibility(component,'onload');
        window.setTimeout(
            $A.getCallback(function() {
             component.set("v.Spinner", false);// Adding values in Aura attribute variable.
            }), 10000
           ); 
    },
    loadOnBoothData: function(component, event, helper) { 
        console.log('sdadadsda123  ' +component.get("v.boothId"));
        component.set('v.saveMessage','');
        helper.resetAllOnBoothChange(component);
        helper.fetchProfileOptionVisibility(component,'onload');
        window.setTimeout(
            $A.getCallback(function() {
             component.set("v.Spinner", false);// Adding values in Aura attribute variable.
            }), 10000
           ); 
    },
    scriptsLoaded: function(component, event, helper) {
        helper.fetchEventDetails(component);
    },
    updateProfileDtls :function(component, event, helper) {
        var profileOpt = component.get("v.profileOption");
        var profilePackage = component.get("v.profilePackageSetting");
        var emailField = component.find("email1");
        var ccEmailField = component.find("emailcc");
        var emailFieldValue = "";
        var ccEmailFieldValue = "";
        if(profileOpt.Booth_Contact_Info__c && profilePackage.Booth_Contact_Info__c)
        {
            emailFieldValue = emailField.get("v.value");
            ccEmailFieldValue = ccEmailField.get("v.value");
        }
        var webLimitFieldValue ="";
        var printLimitFieldValue = "";
        var webLimitField = component.find("webDesc");
        if(profileOpt.Web_Description__c && profilePackage.Web_Description__c)
        {
            webLimitFieldValue = webLimitField.get("v.value");
        }
        var printLimitField = component.find("printDesc");
        if(profileOpt.Print_Description__c && profilePackage.Print_Description__c)
        {
            printLimitFieldValue = printLimitField.get("v.value");
        }
        var webCount = component.get('v.webCount');
        var printCount = component.get('v.printCount');
        var msg = false;
        component.set("v.message","");
        if(!$A.util.isEmpty(webLimitFieldValue) && msg == false)
        {
            if(webCount == 'You have reached the word limit for web description')
            {
                component.set('v.reachedWebLimit', false);
                msg =true;
            }
            else
            {
                msg =false;
                component.set('v.reachedWebLimit', true);
            }
        }
        if(!$A.util.isEmpty(printLimitFieldValue) && msg == false)
        {
            if(printCount == 'You have reached the word limit for print description') 
            {
                component.set('v.reachedPrintLimit', false);
                msg =true;
            }
            else
            {
                msg =false;
                component.set('v.reachedPrintLimit', true);
            }
        }
        if((!$A.util.isEmpty(emailFieldValue) || !$A.util.isEmpty(ccEmailFieldValue)) && msg == false)
        {
            var isValidEmail = 0;
            var isCCValidEmail = 0;
            var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
            var ccRegExpEmailformat = /^(([a-zA-Z0-9_\-]+([a-zA-Z0-9_\-\.]+))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([a-zA-Z0-9\-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)(\s*,\s*|\s*$))*$/;
            //var ccRegExpEmailformat = /^(([a-zA-Z0-9_\-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([a-zA-Z0-9\-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)(\s*,\s*|\s*$))*$/;
            //var ccRegExpEmailformat = /^(|([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5}){1,25})+([,|.](([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5}){1,25})+)*$/;
            if(!$A.util.isEmpty(emailFieldValue) &&  emailFieldValue != ' ')
            {
                if(emailFieldValue.match(regExpEmailformat))
                {
                    emailField.set("v.errors", [{message: null}]);
                    $A.util.removeClass(emailField, 'slds-has-error');
                    msg = false;
                    isValidEmail = 1;    
                }
                else
                {
                    $A.util.addClass(emailField, 'slds-has-error');
                    emailField.set("v.errors", [{message: "Please Enter a Valid Email Address"}]);
                    msg = true;
                    isValidEmail = 2; 
                } 
            }
            if(!$A.util.isEmpty(ccEmailFieldValue) && ccEmailFieldValue != '') 
            {
                if(ccEmailFieldValue.match(ccRegExpEmailformat))
                {
                    ccEmailField.set("v.errors", [{message: null}]);
                    $A.util.removeClass(ccEmailField, 'slds-has-error');
                    msg = false;
                    isCCValidEmail = 1;
                }
                else
                {
                    $A.util.addClass(ccEmailField, 'slds-has-error');
                    ccEmailField.set("v.errors", [{message: "Please Enter a Valid Email Address"}]);
                    msg = true;
                    isCCValidEmail = 2;
                } 
            }
            if(isValidEmail === 2 || isCCValidEmail === 2)
            {
                msg = true;
            }
            if(isValidEmail === 0 && isCCValidEmail === 1)
            {
                msg = false;
                //helper.updateProfileDetails(component);
            } 
            else if(isValidEmail === 1 && isCCValidEmail === 0)
            {
                msg = false;
                //helper.updateProfileDetails(component);
            } 
            else if(isValidEmail === 1 && isCCValidEmail === 1)
            {
                msg =false;
                //helper.updateProfileDetails(component);
            } 
        }
        if(msg == false)
        {
            helper.updateProfileDetails(component);
        }
        // else{
        //     console.log('dasdsadsadsa');
        //     helper.updateProfileDetails(component);
        // }
    }, 
    showSpinner: function(component, event, helper) {
        component.set("v.Spinner", true);// Adding values in Aura attribute variable. 
    },
    hideSpinner : function(component,event,helper){
       component.set("v.Spinner", false);// Adding values in Aura attribute variable.
    },  
    resetChanges: function(component,event,helper){
        helper.resetAllOnBoothChange(component);
        helper.fetchProfileOptionVisibility(component,'reset');
        //helper.fetchContactDetails(component);
    }, 
    updateWordCount : function(component,event){
        var webWord = component.get('v.ExpocadBooth.Web_Description__c');
        var webLimit= component.get('v.profilePackageSetting.Web_Description_Limit__c');
        var printWord = component.get('v.ExpocadBooth.Print_Description__c');
        var printLimit= component.get('v.profilePackageSetting.Print_Description_Limit__c');
        if(webWord)
        {
            webWord = webWord.replace(/<\/p><p>/g, ' ');
            webWord = webWord.replace(/<br \/>/g, ' ');
            webWord = webWord.replace(/&nbsp;/g, ' ');
        }

        if(printWord)
        {
            printWord = printWord.replace(/<\/p><p>/g, ' ');
            printWord = printWord.replace(/<br \/>/g, ' ');
            printWord = printWord.replace(/&nbsp;/g, ' ');
        }

        var domWeb=document.createElement("DIV");
        if(webWord)
        {
            domWeb.innerHTML=webWord;
        }
        var plainTextWeb = '';
        if(domWeb.textContent || domWeb.innerText)
        {
            plainTextWeb = (domWeb.textContent || domWeb.innerText);
        }
        var resWeb;
        var resWebLength=0;
        var msg='';
        if(plainTextWeb == '')
        {
            msg=webLimit+' out of  '+webLimit+' words remaining';
        }
        else
        {
            plainTextWeb = plainTextWeb.replace(/  +/g, ' ');
            if (typeof plainTextWeb.trim !== 'function') 
            {
                plainTextWeb.trim = function()  
                {
                    return this.replace(/^\s+|\s+$/g, ''); 
                };
            }
            plainTextWeb = plainTextWeb.trim();
            resWeb = plainTextWeb.split(' ');
            resWebLength=resWeb.length;
            msg=webLimit-resWebLength+' out of  '+webLimit+' words remaining';
        }
        if((webLimit-resWebLength)+1<=0)
        { 
            msg='You have reached the word limit for web description';
        }

        component.set("v.webCount" ,msg);

        var domPrint=document.createElement("DIV");
        if(printWord)
        {
            domPrint.innerHTML=printWord;
        }
        var plainTextPrint = '';
        if(domPrint.textContent || domPrint.innerText)
        {
            plainTextPrint = (domPrint.textContent || domPrint.innerText);
        }
        var resPrint;
        var resPrintLength=0;
        var msgPrint='';
        if(plainTextPrint == '')
        {
            msgPrint=printLimit+' out of  '+printLimit+' words remaining';
        }
        else{
            plainTextPrint = plainTextPrint.replace(/  +/g, ' ');
            if (typeof plainTextPrint.trim !== 'function') 
            {
                plainTextPrint.trim = function()  
                {
                    return this.replace(/^\s+|\s+$/g, ''); 
                };
            }
            plainTextPrint = plainTextPrint.trim();
            resPrint = plainTextPrint.split(' ');
            resPrintLength=resPrint.length;
            msgPrint=printLimit-resPrintLength+' out of  '+printLimit+' words remaining';
        }
        if((printLimit-resPrintLength)+1<=0)
        { 
            msgPrint='You have reached the word limit for print description';
        }

        component.set("v.printCount" ,msgPrint);
    }

})