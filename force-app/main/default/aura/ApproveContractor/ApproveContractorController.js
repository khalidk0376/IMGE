({
    onLoadData : function(component, event, helper) {
        helper.getOrgType(component);
        var opts = [
            { value: "New", label: "New", selected:true },
            { value: "All Approve", label: "All" },            
            { value: "Approved", label: "Approved" },
            { value: "Rejected", label: "Rejected" }
        ];
        component.set("v.options", opts);
        helper.fetchBoothMaps(component);
        var mapColSortOrdr = new Map([['Customer','asc'],['Type','asc'],['ExhibitingName','asc'],['Booth','asc'],['BoothProductType','asc'],['ContractorCompany','asc'],['Contact','asc'],['DateSubmitted','asc'],['DateApproved','asc'],['Status','asc']]); 
        component.set("v.mapColOdr", mapColSortOrdr);
        var scrollFunc = component.get("v.scrollFunc");
      	window.onscroll = function() 
        {
            var tabat = component.get("v.tabCssAtts");
            if(tabat){
                for(var i=0;i<tabat.length;i++)
                {
                    if(tabat[i].tabId == component.get("v.selTabId2"))
                    {
                        CopyToClipBoard.ScrollFunction(tabat[i].hraderId,tabat[i].tabledataId,tabat[i].tableId,340,45,true,component.get("v.isSandbox"));
                    }
                }         
            }
        };
        // window.onscroll = function() {
        //     if(component.find('fields_type_box_1')==undefined){
        //         return;
        //     }
        //     var _top = 35;             
        //     if (document.body.scrollTop >  315|| document.documentElement.scrollTop >315) {
        //         var questnLfPanel = component.get("v.questnLfPanel");
        //         if (!questnLfPanel) {
        //             var LftWidth = component.find('fields_type_box_1').getElement().offsetWidth;                    
        //             var styleVal = 'width :inherit;height :40px;';                    
        //             styleVal = styleVal + ' transform: translate3d(0px, -315px, 0px);background:#fafaf9;z-index:100;';
                   
        //             component.set("v.questnLfPanelStyleValue", styleVal);
        //             component.set("v.questnLfPanel", " slds-is-fixed");
        //      }
        //     } else {
        //         var questnLfPanelVal = component.get("v.questnLfPanel");
        //         if (questnLfPanelVal === " slds-is-fixed") {
        //             component.set("v.questnLfPanel", "");
        //             component.set("v.questnLfPanelStyleValue", "background-color:#fafaf9");                   
        //             //component.set("v.questionBuilderleftbox", 'height :' + (win_height - 117) + 'px;');   
        //         }
        //     }
        // }                            
        
    },
    sortContractor: function(component, event, helper)
    {
        var columnName = event.currentTarget.id;
        var mapColSortOrdr = component.get("v.mapColOdr");
        var odr = mapColSortOrdr.get(columnName);
        if(odr === 'asc')
        {
            odr = 'desc';
        }else
        {
            odr = 'asc';
        }
        component.set("v.sortingOrder",odr); 
        component.set("v.sortingColumn",columnName);  
        mapColSortOrdr.set(columnName,odr);
        component.set("v.mapColOdr", mapColSortOrdr);
        helper.sortData(component,columnName,odr);
        //console.log('columnName =='+columnName   + ' Oder  === '+mapColSortOrdr.get(columnName));
    },
    scriptsLoaded: function(component, event, helper)
	{ 
    
    },
    
    showApproveModal : function(component, event, helper)
    {
        if(!component.get("v.dependentFieldMap"))  // to load only first time
        {
            helper.fetchDependentPicklistValues(component,'Account','billingCountrycode', 'BillingStatecode');
        }        
        document.getElementById('approveModal').style.display = "block";
        var target = event.getSource();
        var vSId = target.get("v.value");
        helper.singleRecord(component, event, vSId);
        component.set("v.clickContact", false);
        component.set("v.clickAccount", false);
        component.set("v.existingCons",null);	
        component.set("v.existingAcc",null);
    },
    hideApproveModal : function(component, event, helper) {
        document.getElementById('approveModal').style.display = "none";	
    },
    showConfirm : function(component, event, helper)
    {   
        var bthMapping = component.get("v.singleBooth"); 
       	if(bthMapping[0].TempContact__r)
        {
            var countryField = component.find("ctrlCountryField");
           
            if(helper.validateEditFeilds(component) == true)
            {
                if(countryField)
                {
                    var countryFieldValue = countryField.get("v.value");
                    if(!$A.util.isEmpty(countryFieldValue))
                    {
                        countryField.set("v.errors", [{message: null}]);
                        $A.util.removeClass(countryField, 'slds-has-error');
                        helper.fetchDuplicateAccount(component);
                    }
                    else
                    {
                        $A.util.addClass(countryField, 'slds-has-error');
                        countryField.set("v.errors", [{message: "Complete this field."}]);
                    }
                }
                else
                {
                  helper.fetchDuplicateContact(component); // ERROR 
                }
            } 
        }
        else  // incase if Exiting Contacts 
        {
            //console.log('ELSE DISPLAY');
            document.getElementById('Confirm').style.display = "block"; 
            document.getElementById('approveModal').style.display = "none";
        }               
    },
    showConfirmClose : function(component, event, helper) {
        document.getElementById('Confirm').style.display = "none";
    },
    approveContractor : function(component, event, helper) {
        //console.log(event.target.value);
        document.getElementById('Confirm').style.display = "none";
        var singleBth = component.get("v.singleBooth"); 
        var vSId = event.target.value;
        helper.approvalprocess(component, event, vSId, singleBth);
        helper.fetchBoothMaps(component);	
        //document.getElementById('InfoMSG').style.display = "block";
    },
    rejectContractor : function(component, event, helper) {
        //console.log(event.target.value);
        document.getElementById('approveModal').style.display = "none";	
        var vSId = event.target.value;
        component.set("v.sendRejectMail",true);
        component.set("v.RejectNote",'');
        document.getElementById('rejectionNoteModel').style.display = "block";
    },
    RejectAndMail :function(component, event, helper)
    {        
        var siglBth = component.get("v.singleBooth"); 
        if(siglBth)
        {
            helper.rejectprocess(component, event,siglBth[0].Id);
            //formTab.showToast(component,'success','Emails Are Sent successfully!');
        }
        document.getElementById('rejectionNoteModel').style.display = "none";        
    },
    hideRejectConModal:function(component, event, helper)
    {
        document.getElementById('rejectionNoteModel').style.display = "none";
    },
    onChangeFunction : function (component, event,helper){
        var vSelectOtn = component.get("v.selectedValue");
        helper.getContractorbyStatus(component, event, vSelectOtn);
    },
    hideMSGModal : function(component, event, helper)
    {
        document.getElementById('InfoMSG').style.display = "none";	
    },
    showSpinner: function(component, event, helper) {
        component.set("v.Spinner", true); // Adding values in Aura attribute variable.
    },
    hideSpinner : function(component,event,helper){
        component.set("v.Spinner", false);// Adding values in Aura attribute variable.
    },
    // ## function call on Click on the "Download As CSV" Button. 
    downloadCsv : function(component,event,helper){
        var tarUrl = window.location.origin + '/apex/c__AllContractorsReportExport?event=' +component.get("v.EventId") + '&compName=Contractor_SalesForce_Approvals&reportName=Contractor_SalesForce_Approvals' ;
     
        if(component.get("v.selectedValue") != ''){
            tarUrl = tarUrl + '&selectedValue='+component.get("v.selectedValue");
        }
        
        window.location =  tarUrl;
    },
    showModalViewAll: function(component, event, helper) {
        var agentAccID = event.currentTarget.getAttribute("data-id");
        var agentAccName = event.currentTarget.getAttribute("data-Name");
        var Agent =
		{
			type: "Agent",
			Id: agentAccID,
			Name: agentAccName
		};
		component.set("v.CurrentAgent", Agent);// Adding values in Aura attribute variable.
        //console.log('agentAccID============  '+agentAccID+ ' agentAccName '+agentAccName);
        //component.set("v.Spinner", true); 
        helper.fetchPavilionSpaceExhibitors(component);
    },
    onfilterExhibitor: function (component, event, helper) {
        helper.fetchPavilionSpaceExhibitors(component);
    },
    hideViewAll: function(component, event, helper) {
        document.getElementById('Agent_Exhibitormodel').style.display = "none";
    },
    inputContact: function(component, event, helper) {
        component.set("v.clickContact", true);
    },
    inputAccount: function(component, event, helper) {
        component.set("v.clickAccount", true);
        helper.fetchPicklistValues(component , 'Account','billingCountryCode','ctrlCountryField','--Select--');
        // helper.fetchDependentPicklistValues(component,'Account','billingCountrycode', 'BillingStatecode');
        var val = component.find('ctrlCountryField').get("v.value"); // get selected controller field value
        var lab = component.find('ctrlCountryField').get("v.label");
        var controllerValueKey = lab+'__$__'+val;
        helper.onControllerFieldChange(component,val);

    },
    onCountryChange: function(component, event, helper){
        // var val = event.getSource().get("v.value"); // get selected controller field value
        // var lab = event.getSource().get("v.label");
        var val = component.find('ctrlCountryField').get("v.value"); // get selected controller field value
        var lab = component.find('ctrlCountryField').get("v.label");
        var controllerValueKey = lab+'__$__'+val;
        helper.onControllerFieldChange(component,val);
    },
})