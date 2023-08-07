({
    onLoad : function(component, event, helper) {
        helper.getOrgType(component);
        helper.fetchMatchProductOptionsPicklistValues(component,'Event_Edition__c','Matched_Product_Name__c','v.matchingProductOptions',''); 
        helper.fetchExhibitors(component);
        helper.fetchEventDetails(component); 
        helper.fetchServices(component); 
        helper.getAggregateResults(component);
        helper.getDesignationInfos(component);        
        window.onscroll = function() 
        {
            var tabat = component.get("v.tabCssAtts");
            if(tabat){
            for(var i=0;i<tabat.length;i++)
            {
                if(tabat[i].tabId == component.get("v.selTabId1"))
                {
                    CopyToClipBoard.ScrollFunction(tabat[i].hraderId,tabat[i].tabledataId,tabat[i].tableId,255,45,true,component.get("v.isSandbox"));
                }  
            }  
        }          
        };                        
    }, 
    menu: function(component, event, helper) {
        var maindiv=event.currentTarget.getAttribute("id");
        var subdiv=event.currentTarget.getAttribute("data-id");        
        $('#'+subdiv).slideToggle('500');
        $('#'+maindiv).find('i').toggleClass('fa-plus-square fa-minus-square')
    }, 
    mousehover: function(component, event, helper) {
        var conId= event.currentTarget.getAttribute("data-con");
        $('#'+conId).show();
    },
    mouseOut: function(component, event, helper) {
        var conId= event.currentTarget.getAttribute("data-con");
        $('#'+conId).hide();
    },
    hideAlreadyExistsModal: function() {
        $('#modalAlreadyExists').hide();
    },
    showAddContactModal: function(component, event, helper)
    { 
        var cCountryName = event.currentTarget.getAttribute("data-coun");
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
        $('#btninvite').each(function(){$(this).val('').removeAttr("disabled");});
    },
    showAddContractor: function(component, event, helper)
    {        
        helper.fetchAccountContacts(component); 
        helper.fetchPreferredContractor(component);
        var expBooth=component.get("v.selectedBooth");
        expBooth.Id=event.currentTarget.getAttribute("value");
        expBooth.Booth_Number__c=event.currentTarget.getAttribute("name");
        component.set("v.selectedBooth",expBooth);
        component.set("v.FirstName", false);
        component.set("v.LastName", false);
        component.set("v.Email", false);
        component.set("v.Phone", false);
        component.set("v.message",'');
        document.getElementById('modalCont').style.display = "block";	
    },
    hideContractorsModal: function(component, event, helper) {
        document.getElementById('modalCont').style.display = "none";
    },
    sortContractor:function(component,event,helper) {
        var columnName = event.currentTarget.id;
        var sortingOrder = component.get("v.sortingOrder");
        var oldSortingColumnName = component.get("v.sortingColumn");
        if(columnName!=oldSortingColumnName && sortingOrder=='asc'){            
            sortingOrder='desc';
        }
        else if(columnName!=oldSortingColumnName && sortingOrder=='desc'){
            sortingOrder='asc';
        }
            else if(columnName==oldSortingColumnName && sortingOrder=='asc'){
                sortingOrder='desc';
            }
                else if(columnName==oldSortingColumnName && sortingOrder=='desc'){
                    sortingOrder='asc';
                }
        component.set("v.sortingOrder",sortingOrder);
        component.set("v.sortingColumn",columnName);
        helper.fetchExhibitors(component);
    },
    srchExhibitor: function(component, event, helper) {
        if(component.get("v.searchKeyword").length>2 || component.get("v.searchKeyword").length==0)
        {
            component.set("v.PageNumber",1);  
            helper.fetchExhibitors(component);
        }
    },
    srchKeyContact: function(component, event, helper)
    {
        helper.fetchAccountContacts(component,event.target.value); 
        helper.fetchPreferredContractor(component , event.target.value);
    },
    selectExisting: function(component, event, helper) {
        $('#srchCompanyContact').val(component.get("v.existingAcc").Name);
        helper.fetchAccountContacts(component,component.get("v.existingAcc").Name); 
        document.getElementById('modalCompany').style.display = "none";
    },
    selectContact: function(component, event, helper) {
       	var cCountryName = event.currentTarget.getAttribute("data-coun");
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
    hideAddContactModal: function(component, event, helper)
    {
      	document.getElementById('ccountryRelatedToISD').style.display = "none";
        document.getElementById('modalAddContact').style.display = "none";
        helper.deleteAccount(component);	
    },
    hideConSuccessModal: function(component, event, helper) {
        document.getElementById('modalContactSuccess').style.display = "none";	
    },
    inviteContact: function(component, event, helper) {
        var services = [] ;
            
        $(".chkbx").each(function(){
            var $this = $(this);
            if($this.is(":checked")){
                services.push($this.attr("id"));
            }
        });
        var eventSetting= component.get("v.Event_Setting");
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
        else if((newcon.MobilePhoneCountryCode=='' || newcon.MobilePhoneStateCode=='' || ((newcon.MobilePhone).length <=4) ||  !newcon.MobilePhone) && (Mobile == false))
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
        
        else if(((newcon.PhoneStateCode !='' || newcon.Ext != '' || newcon.Phone)  && (Phone == false)) && (newcon.Phone && ((newcon.Phone).length<=4) || (newcon.PhoneStateCode==''  || !newcon.Phone) || ((newcon.Phone != '' && !phonepattern.test(newcon.Phone)) || (newcon.PhoneStateCode !='' && !phonepattern.test(newcon.PhoneStateCode)) || (newcon.Ext !='' && !phonepattern.test(newcon.Ext)))))
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
        else
        {
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
            console.log(newcon.Phone +'#########'+newcon.MobilePhone);
            
            $('#btninvite').each(function()
            {
                $(this).val('')
                .attr('disabled','disabled');
            });
            if(newcon.Id)
            {
    			helper.createContactHelper(component,services);
            }
            else{ 
                helper.fetchDuplicateContact(component,services);
            }
        }
    },
    showRegComModal: function(component, event, helper)
    {
        if(component.get("v.dataLoadedOnce") == false)
        {
            helper.fetchPicklistValues(component,'Account','billingCountryCode','billingCountry','--Select--');
            helper.fetchDependentPicklistValues(component,'Account','BillingCountrycode', 'BillingStatecode');
        }        
        helper.resetAccount(component);
        component.set("v.message",'');
        document.getElementById('modalCompany').style.display = "block";	
    },
    hideRegComModal: function(component, event, helper) {
        document.getElementById('modalCompany').style.display = "none";	
        document.getElementById('srchCompany').value = '';
        component.set("v.srchAcc",null);
        //component.set("v.isWarnOpen",false);
        $('#addCompany').prop('disabled', false);
    },
    onBillingCountryChange: function(component, event, helper) {
        var val = event.getSource().get("v.value"); // get selected controller field value
        var lab = event.getSource().get("v.label");
        var controllerValueKey = lab+'__$__'+val;
      	helper.onControllerFieldChange(component,val);	
    },
    srchKeyCompany: function(component, event, helper) {
        component.set("v.disableSpinner", true);
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
    selectAccount: function(component, event, helper) {
        //component.set("v.isWarnOpen",true);
        document.getElementById('srchCompany').value = component.get("v.srchAcc").Name;
        component.set("v.srchAcc",null);
        $('#addCompany').prop('disabled', true);
    },
    addCompany: function(component, event, helper) {
        var newcom=component.get("v.newAccount");
        var msg='';
        var cuntryCode =component.find("billingCountry").get("v.value");
        console.log('cuntryCode',cuntryCode);
        component.set('v.cCountryCode',cuntryCode);
        if(!newcom.Name){
            msg='Company name required';
        }
        else if(!newcom.BillingCountry ){
            msg='Country required';
        }
            else if(!newcom.BillingCity){
                msg='City required';
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
    // ## function call on Click on the "Download As CSV" Button. 
    downloadCsv : function(component,event,helper){
        var mpn = component.get("v.selectedMatchProductOption"); 
        var tarUrl = window.location.origin + '/apex/c__AllContractorsReportExport?event=' +component.get("v.eventId") + '&compName=ExhibitorsWithoutContractors&reportName=Exhibitors_without_contractors&mpn='+mpn;
        if(component.get("v.searchKeyword") != '')
        {
            tarUrl = tarUrl + '&search='
            +component.get("v.searchKeyword");
        }
        else
        {
            tarUrl = tarUrl + '&search= ';   
        }
        window.location =  tarUrl;
        }, 
    hideAddNotes : function(component, event, helper) {
        document.getElementById('modalAddNotes').style.display = "none";
        helper.fetchExhibitors(component);
        component.set("v.PrntPopupclosed", true); 
    },
    
    showAddNotes : function(component, event, helper) {
        document.getElementById('txtNotes').value ='';
        var expBooth=component.get("v.selectedBooth");
        expBooth.Id=event.currentTarget.getAttribute("value");
        expBooth.Booth_Number__c=event.currentTarget.getAttribute("name");
        expBooth.Account = event.currentTarget.getAttribute("data-acc");
        component.set("v.selectedBooth",expBooth);
        component.set("v.selectedBooth",expBooth);
        component.set("v.message",'');
        document.getElementById('modalAddNotes').style.display = "block";
    },  
        
    handleNext: function(component, event, helper) {
        var pageNumber = component.get("v.PageNumber");  
        pageNumber++;
        component.set("v.PageNumber",pageNumber);  
        helper.fetchExhibitors(component);
    },
     
    handlePrev: function(component, event, helper) {
        var pageNumber = component.get("v.PageNumber");  
        pageNumber--;
        component.set("v.PageNumber",pageNumber);  
        helper.fetchExhibitors(component);
    },
    onSelectChange: function(component, event, helper) {
        var pageSize = component.find("pageSize").get("v.value");
        component.set("v.PageNumber",1);  
        component.set("v.pageSize",pageSize);  
        helper.fetchExhibitors(component); 
    },
    //BK -2173
    selectChangeEventMatchProductName: function(component, event, helper) {
        helper.fetchPicklistValues(component,'Event_Edition__c','Matched_Product_Name__c','v.matchingProductOptions','');
        var items = event.getParam("values");        
        var data='';
        for (var i = 0; i < items.length; i++) {
            data+=data==''?items[i]: ','+items[i]; 
        }
        if(data)
        {
            component.set("v.selectedMatchProductOption", data); 
             helper.fetchExhibitors(component);
        }
        else
        {
            component.set("v.selectedMatchProductOption", "All"); 
             helper.fetchExhibitors(component);
        }
    }
    //Call by aura:waiting event
    /*handleShowSpinner: function(component, event, helper) {
        component.set("v.isSpinner", true); 
    },
     
    //Call by aura:doneWaiting event 
    handleHideSpinner : function(component,event,helper){
        component.set("v.isSpinner", false);
    }*/
   
})