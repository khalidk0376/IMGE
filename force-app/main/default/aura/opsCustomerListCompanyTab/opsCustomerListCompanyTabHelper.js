({
    resetAllOnBoothChange: function(component){
        var boothContactInfo = component.get("v.wrapperList");
        var expoBooth = component.get("v.ExpocadBooth");  
        if(boothContactInfo)
        {
            boothContactInfo.address = '';
            boothContactInfo.boothConId = '';
            boothContactInfo.boothConInfoId = '';
            boothContactInfo.ccEmail = '';
            boothContactInfo.city = '';
            boothContactInfo.country = '';
            boothContactInfo.email = '';
            boothContactInfo.fax = '';
            boothContactInfo.firstname = '';
            boothContactInfo.isSubmitted = false;
            boothContactInfo.lastname = '';
            boothContactInfo.lastUpdatedByDate = '';
            boothContactInfo.lastUpdatedByName = '';
            boothContactInfo.po_box = '';
            boothContactInfo.state = '';
            boothContactInfo.telephone = '';
            boothContactInfo.website = '';
            boothContactInfo.zipcode = '';
            component.set('v.wrapperList' , boothContactInfo);
        }
        if(expoBooth)
        {
            expoBooth.Id = '';
            expoBooth.Booth_Number__c = '';
            expoBooth.Display_Name__c = '';
            expoBooth.Event_Code__c = '';
            expoBooth.Web_Description__c = '';
            expoBooth.Print_Description__c = '';
            expoBooth.FaceBook__c = '';
            expoBooth.Instagram__c = '';
            expoBooth.LinkedIn__c = '';
            expoBooth.YouTube__c = '';
            expoBooth.Twitter__c = '';
            component.set('v.ExpocadBooth' , expoBooth);
        }
    },
    fetchEventDetails : function(component) {
        var sEventCode = component.get("v.eventcode");// Getting values from Aura attribute variable.
        var action = component.get("c.getEventDetails"); //Calling Apex class controller 'getEventDetails' method
        action.setParams({
            sEventcode : sEventCode
        });
        action.setCallback(this, function(response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS")
            {
                component.set("v.Event_Setting", response.getReturnValue());// Adding values in Aura attribute variable.
            }
        });
        $A.enqueueAction(action);
        
    },
    //fetching contact or boothcontactinfo details
    fetchContactDetails : function(component) {
        var bid= component.get("v.boothId");
        var evntId= component.get("v.eventId");
        var accId = component.get("v.accountId");
        var action = component.get('c.getContactDetails');
        action.setParams({
            boothId : bid,
            eventId:evntId,
            accountId:accId,
            showLastModFromAgent:component.get('v.showAgentLastModified')
        });
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            
            if (state === "SUCCESS") 
            {
                var result = response.getReturnValue();
                //console.log('wrapperList'+JSON.stringify(response.getReturnValue()));
                //set response value in wrapperList attribute on component.
                if(result.boothConId != null)
                {
                    component.set("v.noContact", false); 
                    component.set('v.wrapperList', response.getReturnValue());
                    component.set('v.isAgent' , result.isAgent);
                    console.log('result.isAgent ' +result.isAgent);
                }
                else
                {
                    component.set("v.noContact", true);
                }
            }
            else
            {
                component.set("v.noContact", true); 
            }
        });
        $A.enqueueAction(action);
    },
    
    //fetching contact or boothcontactinfo details
    fetchExpocadBoothDetails : function(component,profilePackageSetting) {
        var bid = component.get("v.boothId");
        var accId = component.get("v.accountId");
        var action = component.get('c.getExpocadBoothDetails');
        action.setParams({
            boothId : bid,
            accountId : accId
        });
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                var result=response.getReturnValue();
                //console.log('fetchExpocadBoothDetails' +JSON.stringify(response.getReturnValue()));
                component.set('v.ExpocadBooth', response.getReturnValue());
                var webDesc=result.Web_Description__c;
                var printDesc=result.Print_Description__c;
                var webLimit=profilePackageSetting.Web_Description_Limit__c;
                var printLimit=profilePackageSetting.Print_Description_Limit__c;
                
                if(webDesc)
                {
                    webDesc = webDesc.replace(/<\/p><p>/g, ' ');
                    webDesc = webDesc.replace(/<br \/>/g, ' ');
                    webDesc = webDesc.replace(/&nbsp;/g, ' ');
                }
                
                if(printDesc)
                {
                    printDesc = printDesc.replace(/<\/p><p>/g, ' ');
                    printDesc = printDesc.replace(/<br \/>/g, ' ');
                    printDesc = printDesc.replace(/&nbsp;/g, ' ');
                }
                
                var domWeb=document.createElement("DIV");
                if(webDesc)
                {
                    domWeb.innerHTML=webDesc;
                }
                var plainTextWeb = '';
                if(domWeb.textContent || domWeb.innerText)
                {
                    plainTextWeb=(domWeb.textContent || domWeb.innerText);
                }
                var resWeb;
                var resWebLength=0;
                var msg='';
                if(plainTextWeb == ''){
                    msg=webLimit+' out of  '+webLimit+' words remaining';
                }
                else{
                    plainTextWeb = plainTextWeb.replace(/  +/g, ' ');
                    if (typeof plainTextWeb.trim !== 'function') {
                        plainTextWeb.trim = function()  {
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
                if(printDesc)
                {
                    domPrint.innerHTML=printDesc;
                }
                var plainTextPrint = '';
                if(domPrint.textContent || domPrint.innerText)
                {
                    plainTextPrint=(domPrint.textContent || domPrint.innerText);
                }
                var resPrint;
                var resPrintLength=0;
                var msg='';
                if(plainTextPrint == ''){
                    
                    msg=printLimit+' out of  '+printLimit+' words remaining';
                }
                else{
                    plainTextPrint = plainTextPrint.replace(/  +/g, ' ');
                    if (typeof plainTextWeb.trim !== 'function') {
                        plainTextWeb.trim = function() {
                            return this.replace(/^\s+|\s+$/g, ''); 
                        };
                    }
                    plainTextWeb = plainTextWeb.trim();
                    resPrint = plainTextPrint.split(" ");
                    resPrintLength=resPrint.length;
                    msg=printLimit-resPrintLength+' out of '+printLimit+' words remaining';
                }
                if((printLimit-resPrintLength)+1<=0)
                {
                    msg='You have reached the word limit for print description'; 
                }
                component.set("v.printCount" ,msg);
            }
            //this.fetchContactDetails(component);
            0    });
        $A.enqueueAction(action);
        
    },
    fecthPicklistValues : function(component,profilePackageSetting, profileOptionVisibility,loadType) {
        var action = component.get('c.getPickListValues');
        action.setParams({
            objectName : 'Contact',
            fieldName:'MailingCountryCode'
        });
        action.setCallback(this, function(response) {
            //store state of response
            var inputsel = component.find("InputSelectDynamic");
            var state = response.getState();
            if (state === "SUCCESS") {
                //console.log('fecthPicklistValues'+JSON.stringify(response.getReturnValue()));
                var opts=[];
                var result=response.getReturnValue();
                opts.push({"class": "optionClass", label: '-- Select Country --', value: ''});
                for(var i=0;i< result.length;i++){
                    opts.push({"class": "optionClass", label: result[i].split('__$__')[0], value: result[i].split('__$__')[1]});
                }
                inputsel.set("v.options", opts);
                this.fetchExpocadBoothDetails(component,profilePackageSetting,profileOptionVisibility,loadType);
            }
        });
        
        $A.enqueueAction(action);
    },
    updateExpocadBooth :function(component, event){
        var expoBooth = component.get("v.ExpocadBooth");
        //Calling the Apex Function
        var action = component.get("c.updateExpocadBooth");
        //Setting the Apex Parameter
        action.setParams({
            expoBooth : expoBooth
        });
        
        //Setting the Callback
        action.setCallback(this,function(response){
            //get the response state
            var state = response.getState();
            if(state == "SUCCESS"){
                window.setTimeout(
                    $A.getCallback(function() {
                        component.set("v.saveMessage", '');// Adding values in Aura attribute variable.
                    }), 4000
                );
                //console.log('updateExpocadBooth'+JSON.stringify(response.getReturnValue()));
            }  
        });      
        $A.enqueueAction(action);
    },
    fetchProfileOptionVisibility: function(component,loadType){
        var evntId= component.get("v.eventId");
        var action = component.get('c.getProfileOptionVisibility');
        action.setParams({
            eventId:evntId
        });
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                //set response value in wrapperList attribute on component.
                component.set('v.profileOption', response.getReturnValue());
                this.fetchProfilePackageSetting(component,response.getReturnValue(),loadType);
            }
        });
        $A.enqueueAction(action);
    },
    updateProfileDetails :function(component, event, helper) {
        //console.log('updateProfileDetails');
        var bid= component.get("v.boothId");
        var evntId= component.get("v.eventId"); 
        var boothcontactinfo = component.get("v.wrapperList");
        var boothcon={Event_Edition__c:evntId,Opportunity_Booth_Mapping__c:bid,Contact__c:boothcontactinfo.boothConId,First_Name__c:boothcontactinfo.firstname,Last_Name__c:boothcontactinfo.lastname,Address__c:boothcontactinfo.address,P_O_Box__c:boothcontactinfo.po_box,City__c:boothcontactinfo.city,State__c:boothcontactinfo.state,
                      Zip_Code__c:boothcontactinfo.zipcode, Country__c:boothcontactinfo.country,Telephone__c:boothcontactinfo.telephone,Fax__c:boothcontactinfo.fax, Email__c:boothcontactinfo.email,CC_Email__c:boothcontactinfo.ccEmail, Website__c:boothcontactinfo.website};
        
        if(boothcontactinfo.boothConInfoId)   
        {
            boothcon.Id= boothcontactinfo.boothConInfoId;   
        }  
        //Calling the Apex Function
        var action = component.get("c.createRecord");
        //Setting the Apex Parameter
        action.setParams({
            boothcontactinfo : boothcon
        });   
        //Setting the Callback
        action.setCallback(this,function(response){
            //get the response state
            var state = response.getState();
            //check if result is successfull
            if(state == "SUCCESS"){
                // console.log('updateProfileDetails123 '+response.getReturnValue());
                this.updateExpocadBooth(component);
                //Reset Form
                this.fetchContactDetails(component);
                component.set("v.noError", false);
                component.set('v.saveMessage', response.getReturnValue());
                //var newboothcontactinfo = {'sobjectType': 'BoothContactInfo__c' };
                //resetting the Values in the form
                //component.set("v.wrapperList",newboothcontactinfo);
                
            } 
            else{
                component.set("v.noError", true);
            } 
        });     
        $A.enqueueAction(action);
    },
    fetchProfilePackageSetting: function(component,profileOptionVisibility,loadType){
        var evntId= component.get("v.eventId");
        var bid= component.get("v.boothId");
        var accId = component.get("v.accountId");
        var action = component.get('c.getProfilePackageSetting');
        action.setParams({
            eventId:evntId,
            boothId:bid,
            accountId:accId
        });
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if(state === "SUCCESS"){
                var profilePackageSetting=response.getReturnValue();
                var noContact = component.get("v.noContact");
                component.set("v.profilePackageSetting",profilePackageSetting);
                
                if(profileOptionVisibility.Booth_Contact_Info__c && profilePackageSetting.Booth_Contact_Info__c && loadType=='onload' && noContact == false)
                {
                    this.fecthPicklistValues(component,profilePackageSetting, profileOptionVisibility,loadType);
                }
                if((!profileOptionVisibility.Booth_Contact_Info__c || !profilePackageSetting.Booth_Contact_Info__c) && loadType=='onload' && noContact == false)
                {
                    this.fetchExpocadBoothDetails(component,profilePackageSetting,profileOptionVisibility,loadType);
                }
                else if(loadType=='reset')
                {
                    this.fetchExpocadBoothDetails(component,profilePackageSetting,profileOptionVisibility,loadType);
                }
                this.fetchContactDetails(component);
            }
        });
        $A.enqueueAction(action);
    },
})