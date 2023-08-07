({
    scriptsLoaded: function(component, event, helper) {
        $(document).ready(function(){
            //$('[data-toggle="tooltip"]').tooltip();   
        });
    },
    menu: function(component, event, helper) {
        var maindiv=event.currentTarget.getAttribute("id");
        var subdiv=event.currentTarget.getAttribute("data-id");
        $('#'+subdiv).slideToggle('500');
        $('#'+maindiv).find('i').toggleClass('fa-plus-square fa-minus-square')
    },
    cartOnloadData : function(component, event, helper) { 
         var eventcode = helper.getUrlParameter(component,'eventcode'); // get eventcode from Url
         console.log('value of event code in onload ',eventcode);
		if(eventcode)
		{
			component.set("v.eventcode",eventcode);
        }
        console.log('value of event codeafter set ',component.get('v.eventcode'));
        helper.getUserType(component);
        helper.fetchEventDetails(component); 
        helper.fetchServices(component); 
        helper.fetchAccountContacts(component);  
        helper.fetchBoothsMap(component); 
        helper.onControllerFieldChange(component,'');
        helper.fetchPavillionBoothsMap(component);
        helper.fetchPavilionSpaceExhibitors(component,'onload');
        helper.fetchPreferredContractor(component);
        helper.fetchPicklistValues(component , 'Account','billingCountryCode','billingCountry','--Select--');
        //helper.fetchPicklistValues(component , 'Account','billingStateCode','billingState','--Select--');
        //helper.fetchPicklistValues(component , 'TempContact__c','Country_Code__c','InputPhoneIsd','-ISD-');
        //helper.fetchPicklistValues(component , 'TempContact__c','Country_Code__c','InputMobileIsd','-ISD-');
        helper.fetchDependentPicklistValues(component,'Account','BillingCountrycode', 'BillingStatecode');
        helper.setNotificationMessage(component);
    },
    showAddContractor: function(component, event, helper) {
        
        if(event.currentTarget.getAttribute("data-name")=='agent')
        {
            component.set("v.isAgent",true); 
        }
        else
        {
            component.set("v.isAgent",false);
            var expBooth=component.get("v.selectedBooth");
            expBooth.Id=event.currentTarget.getAttribute("value");
            expBooth.Booth_Number__c=event.currentTarget.getAttribute("name");
            component.set("v.selectedBooth",expBooth);
        }
        
        component.set("v.message",'');
        document.getElementById('modalCont').style.display = "block";	
    },
    hideAddContractor: function(component, event, helper) {
        document.getElementById('modalCont').style.display = "none";	
    },
    showmodalCancelSelf: function(component, event, helper) {
        component.set("v.removeCon",{mapId:event.currentTarget.getAttribute("value"),name:event.currentTarget.getAttribute("name")});
        $('#modalCancelSelf').show();	
    },
    hidemodalCancelSelf: function(component, event, helper) {
        $('#modalCancelSelf').hide();	
    },
    showRegComModal: function(component, event, helper) {
        component.set("v.message",'');
        helper.resetAccount(component);
        document.getElementById('modalCompany').style.display = "block";	
    },
    onBillingCountryChange: function(component, event, helper) {
        var val = event.getSource().get("v.value"); // get selected controller field value
        var lab = event.getSource().get("v.label");
        var controllerValueKey = lab+'__$__'+val;
        //console.log('Country ==  '+val);
        helper.onControllerFieldChange(component,val);	
    },
    hideRegComModal: function(component, event, helper) {
        document.getElementById('modalCompany').style.display = "none";	
        document.getElementById('srchCompany').value = '';
        component.set("v.srchAcc",null);
        //component.set("v.isWarnOpen",false);
        $('#addCompany').prop('disabled', false);
    },
    showAddContactModal: function(component, event, helper) {
        var cCountryName = event.currentTarget.getAttribute("data-coun");
        console.log('cCountryName',cCountryName)
        helper.fetchCoutryNameRealtedIsdValues(component , cCountryName,'InputPhoneIsd','-ISD-');
        helper.fetchCoutryNameRealtedIsdValues(component , cCountryName,'InputMobileIsd','-ISD-');
        helper.resetContact(component);
        var newcon=component.get("v.newContact");
        newcon.AccountId=event.currentTarget.getAttribute("data-id");
        newcon.AccountName=event.currentTarget.getAttribute("data-name");
        component.set("v.newContact",newcon);
        component.set("v.FirstName", false);
        component.set("v.LastName", false);
        component.set("v.Email", false);
        component.set("v.Phone", false);
        component.set("v.MobilePhone", false);
        component.set("v.message",'');
        document.getElementById('modalAddContact').style.display = "block";	
    },
    hideAddContactModal: function(component, event, helper) {
        document.getElementById('ccountryRelatedToISD').style.display = "none";
        document.getElementById('modalAddContact').style.display = "none";
        helper.deleteAccount(component);	
    },
    hideConSuccessModal: function(component, event, helper) {
        document.getElementById('modalContactSuccess').style.display = "none";	
    },
    changeContact: function(component, event, helper) {
        component.set("v.removeCon",{mapId:event.currentTarget.getAttribute("value"),name:event.currentTarget.getAttribute("name")});
        //console.log('>>>>>'+JSON.stringify(component.get("v.removeCon")));
        document.getElementById('modalRemoveContarctor').style.display = "block";	
    },
    hideRemoveConModal: function(component, event, helper) {
        document.getElementById('modalRemoveContarctor').style.display = "none";	
    },
    hideAlreadyExistsModal: function(component, event, helper) {
        $('#modalAlreadyExists').hide();
    },
    showEditServicesModal: function(component, event, helper) {
        var boothid= event.currentTarget.getAttribute("data-id").replace('E__','');
        var mapid= event.currentTarget.getAttribute("data-mid");
        $('#hdnmapId').val(mapid);
        var boothsMap = component.get("v.lstbooths");
        
        var selectedServices=[];
        for(var i=0;i<boothsMap.length;i++)
        {
            for(var k=0;k<boothsMap[i].value.length;k++)
            {
                if(boothsMap[i].value[k].Id==mapid && boothsMap[i].value[k].CustomerContractorServices__r)
                {
                    for(var j=0;j<boothsMap[i].value[k].CustomerContractorServices__r.length;j++)
                    {
                        //console.log('selected>>>>>>>'+boothsMap[i].value.CustomerContractorServices__r[j].ContractorService__c);
                        selectedServices.push(boothsMap[i].value[k].CustomerContractorServices__r[j].ContractorService__c);
                    }
                }
            }
        }
        //console.log('selectedServices'+JSON.stringify(selectedServices));
        $(".chkServices").each(function(){
            var $this = $(this);
            if(selectedServices.indexOf($this.attr("id"))>=0)
            {
                $this.attr("checked",true);
            }
            else{
                $this.attr("checked",false);
            }
        });
        document.getElementById('modalEditServices').style.display = "block";	
    },
    hideEditServicesModal: function(component, event, helper) {
        $('#modalEditServices').hide();
    },
    handleChange: function (component, event) {
        var isforAll = event.target.value;
        component.set("v.isForAllBooth",isforAll);
    },
    srchKeyContact: function(component, event, helper) {
        helper.fetchAccountContacts(component,event.target.value); 
        helper.fetchPreferredContractor(component , event.target.value);
    },
    srchKeyCompany: function(component, event, helper) {
        if(event.target.value!='')
        {
            helper.fetchAccount(component,event.target.value);
            var newcom=component.get("v.newAccount"); 
            newcom.Name=event.target.value;
            component.set("v.newAccount",newcom); 
        }
        else{
            component.set("v.srchAcc",null);
            //component.set("v.isWarnOpen",false);
            $('#addCompany').prop('disabled', false);
        }
    },
    hideResult: function(component, event, helper) {
        component.set("v.srchAcc",null);
    },
    selectAccount: function(component, event, helper) {
        //component.set("v.isWarnOpen",true);
        component.set("v.message","Company already exists. Please click the cancel button below and search through the list of contractors.");
        document.getElementById('srchCompany').value = component.get("v.srchAcc").Name;
        component.set("v.srchAcc",null);
        $('#addCompany').prop('disabled', true);
    },
    selectContact: function(component, event, helper) {
        var cCountryName = event.currentTarget.getAttribute("data-coun");
        //console.log('cCountryName',cCountryName)
        helper.fetchCoutryNameRealtedIsdValues(component , cCountryName,'InputPhoneIsd','-ISD-');
        helper.fetchCoutryNameRealtedIsdValues(component , cCountryName,'InputMobileIsd','-ISD-');
        helper.resetContact(component);
        var conId= event.currentTarget.getAttribute("data-con");
        var msg='';
        component.set("v.message",msg);
        helper.fetchContactById(component,conId);
        var newcon=component.get("v.newContact");
        newcon.AccountId=event.currentTarget.getAttribute("data-aid");
        newcon.AccountName=event.currentTarget.getAttribute("data-name");
        component.set("v.newContact",newcon);
    },
    inviteContact: function(component, event, helper) {
        
        var services = [] ;
        $(".checkboxServices").each(function(){
            var $this = $(this);
            if($this.is(":checked")){
                services.push($this.attr("id"));
            }
        });
        var eventSetting= component.get("v.Event_Setting");
        //console.log('event edition c' +eventSetting);
        
        var newcon=component.get("v.newContact");
        var Mobile = component.get("v.MobilePhone");
        var Phone = component.get("v.Phone");
        var msg='';
        var phonepattern = /^[-\+\#\s\(\)\./0-9]*$/;
        var emailpattern = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,15})+$/;
        
        if(!newcon.FirstName)
        {
            msg='Please enter first name.'; 
        }
        else if(!newcon.LastName)
        { 
            msg='Please enter last name.';
        }
        else if((newcon.MobilePhoneCountryCode=='' || newcon.MobilePhoneStateCode=='' || ((newcon.MobilePhone).length <=4) || !newcon.MobilePhone) && (Mobile == false))
        {
            msg='Please enter a valid Mobile number.';
        }
        else if(newcon.MobilePhone != '' && ((newcon.MobilePhone).length <=4))
        {
            msg='Please enter a valid Mobile number.';
        }
        else if((newcon.MobilePhone != '' && !phonepattern.test(newcon.MobilePhone)) || (newcon.MobilePhoneStateCode !='' && !phonepattern.test(newcon.MobilePhoneStateCode)))
        {
            msg='Please enter a valid Mobile number.';
        }
        // else if(((newcon.PhoneCountryCode !='' || newcon.PhoneStateCode !='' || newcon.Ext != '' || newcon.Phone)  && (Phone == false))  && (newcon.Phone && ((newcon.Phone).length<=4) || (newcon.PhoneCountryCode=='' || newcon.PhoneStateCode==''  || !newcon.Phone ) || ((newcon.Phone != '' && !phonepattern.test(newcon.Phone)) || (newcon.PhoneStateCode !='' && !phonepattern.test(newcon.PhoneStateCode)) || (newcon.Ext !='' && !phonepattern.test(newcon.Ext)))))
        else if(((newcon.PhoneStateCode !='' || newcon.Ext != '' || newcon.Phone)  && (Phone == false))  && (newcon.Phone && ((newcon.Phone).length<=4) || ( newcon.PhoneStateCode==''  || !newcon.Phone ) || ((newcon.Phone != '' && !phonepattern.test(newcon.Phone)) || (newcon.PhoneStateCode !='' && !phonepattern.test(newcon.PhoneStateCode)) || (newcon.Ext !='' && !phonepattern.test(newcon.Ext)))))
        {
            msg = 'Please enter a valid Phone number.';
        }
        else if(!newcon.Email)
        {
            msg='Please enter valid email address.';
        }
        else if (newcon.Email != '' && !emailpattern.test(newcon.Email))
        {
            msg='Please enter valid email address.';
        }
        else if (!services.length && !eventSetting.Disable_this_information__c)
        {
            msg='Please select services.';
        }
        else{
            msg='';
        }
        if(msg){
            component.set("v.message",msg);
        }
        else{
           	var strMobilePhone =newcon.MobilePhone;
            var strPhone =newcon.Phone; 
            if(strMobilePhone.includes('+') || strPhone.includes('+'))
            {
                if(strMobilePhone!=null){
                   var mob=strMobilePhone.replace(newcon.MobilePhoneCountryCode,'');
                   newcon.MobilePhone=mob; 
                }
               	if(strPhone!=null){
                  var phone = strPhone.replace(newcon.PhoneCountryCode,'');
                  newcon.Phone=phone;
                }
           }
          	if(newcon.PhoneCountryCode &&(newcon.Phone=='' || newcon.Phone==null)){
                newcon.Phone='';
            }else{
                var ph=newcon.Ext==''?newcon.Phone:newcon.Phone+'-'+newcon.Ext;
                ph = newcon.PhoneStateCode==''?ph:newcon.PhoneStateCode+ph;
                ph = newcon.PhoneCountryCode==''?ph:newcon.PhoneCountryCode+ph;
                newcon.Phone = ph;
            }
            var mb = newcon.MobilePhoneStateCode==''?newcon.MobilePhone:newcon.MobilePhoneStateCode+newcon.MobilePhone;
            mb = newcon.MobileCountryStateCode==''?mb:newcon.MobilePhoneCountryCode+mb;
            newcon.MobilePhone = mb;  
            console.log(newcon.Phone +' ######## '+newcon.MobilePhone);
            if(newcon.Id)
            {
               helper.createContactHelper(component,services);
            }else{
               helper.fetchDuplicateContact(component,services);
            }
        }
    },
    addCompany: function(component, event, helper) {
        var newcom=component.get("v.newAccount");
        var msg='';
        var cuntryCode =component.find("billingCountry").get("v.value");
        //console.log('countryCode',cuntryCode);
        //console.log(JSON.stringify(newcom));
        //Commented based on CCEN-731
        if(!newcom.Name || !newcom.BillingCity || !newcom.BillingCountry ){
        //if(!newcom.Name)
        //{
            msg='All required fields are required.';
        }
        else if(newcom.BillingStreet.length>60){
                    msg='Only 60 characters are allowed to enter in Address Field';
                }
        else{
            msg='';
        }
        
        if(msg){
            component.set("v.message",msg);
        }
        else{
            helper.createAccountHelper(component,cuntryCode);
        }
    },
    removeContractor: function(component, event, helper) {
        helper.removeContactHelper(component);
    },
    mousehover: function(component, event, helper) {
        var conId= event.currentTarget.getAttribute("data-con");
        $('#'+conId).show();
    },
    mouseOut: function(component, event, helper) {
        var conId= event.currentTarget.getAttribute("data-con");
        $('#'+conId).hide();
    },
    saveUpdatedServices: function(component, event, helper) {
        var services = [] ;
        $(".chkServices").each(function(){
            var $this = $(this);
            if($this.is(":checked")){
                services.push($this.attr("id"));
            }
        });
        helper.updateContractorServices(component,services,$('#hdnmapId').val());
    },
    selectExisting: function(component, event, helper) {
        $('#srchCompanyContact').val(component.get("v.existingAcc").Name);
        helper.fetchAccountContacts(component,component.get("v.existingAcc").Name); 
        document.getElementById('modalCompany').style.display = "none";
    },
    buildMyStand: function(component, event, helper) 
    {
        component.set("v.isAgent",false);
        helper.resetContact(component);
        helper.resetAccount(component);
        var expBooth=component.get("v.selectedBooth");
        expBooth.Id=event.currentTarget.getAttribute("data-bid");
        expBooth.Booth_Number__c=event.currentTarget.getAttribute("data-bname");
        component.set("v.selectedBooth",expBooth);
        var services = [];
        helper.createContactHelper(component,services);
    },
    showModalViewAll: function(component, event, helper) {
        component.set("v.Spinner", true); 
        helper.fetchPavilionSpaceExhibitors(component);
    },
    hideModalViewAll: function(component, event, helper) {
        document.getElementById('modalViewAll').style.display = "none";	
    },
    showSpinner: function(component, event, helper) {
        //component.set("v.Spinner", true); // Adding values in Aura attribute variable.
    },
    hideSpinner : function(component,event,helper){
        //component.set("v.Spinner", false);// Adding values in Aura attribute variable.
    },
    onfilterExhibitor:function(component,event,helper) {
        helper.fetchPavilionSpaceExhibitors(component);
    },
    ExportData:function(component,event,helper) {
        //console.log('Exporting Data.......');	
        var agent =  component.get("v.currentUser");	
        var csv = helper.exportExhibitors(component);
        if (csv == null)
        {
            console.log('No Data to Export');
            return;
        }
        else
        {
            if (navigator.msSaveBlob) 
            {
                var blob = new Blob([csv],{type: "text/csv;charset=utf-8;"});
                navigator.msSaveBlob(blob, agent.SFContactID__r.Account.Name+' - Exhibitors.csv')
            } 
            else 
            {
                var hiddenElement = document.createElement('a');
                hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
                hiddenElement.target = '_blank'; // 
                hiddenElement.download = agent.SFContactID__r.Account.Name+' - Exhibitors.csv';  // CSV file Name* you can change it.[only name not .csv] 
                document.body.appendChild(hiddenElement); // Required for FireFox browser   
                hiddenElement.click(); // using click() js function to download csv file */
                document.body.removeChild(hiddenElement);          
            }  
        }
    },
    goToHome:function(component, event, helper) {
        var url =window.location.href;
        let eventcode = component.get('v.eventcode');
		if(url.includes('/s/')){
			window.location.href='/CustomerCenter/s/?eventcode='+eventcode;
		}
		else{
			window.location.href='home?eventcode='+eventcode;
		}
	}
    // hideNotification : function(component, event, helper){
    //     component.set("v.showNotificationMessage",false);
    // } 
})