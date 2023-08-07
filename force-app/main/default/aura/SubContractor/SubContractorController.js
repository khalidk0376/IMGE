({
	scriptsLoaded: function(component, event, helper) {
		$(document).ready(function(){
			//$('[data-toggle="tooltip"]').tooltip();   
		});
    },
	cartOnloadData : function(component, event, helper) {
		var eventcode = helper.getUrlParameter(component,'eventcode'); // get eventcode from Url
		if(eventcode)
		{
			component.set("v.eventcode",eventcode);
		}
		helper.fetchEventDetails(component);
		helper.fetchExhibitors(component);
		helper.fetchContarctorStatus(component);
		helper.fetchServices(component); 
		helper.fetchBoothsMap(component);
		helper.fetchCountries(component);
	},
	updateConStatus : function(component, event, helper) {
		var status = $('#selectStatus').find(":selected").val();
		var mapid= event.currentTarget.getAttribute("data-mid"); 
		if(status)helper.updateConStatus(component,mapid,status);
	},
	showSpinner: function(component, event, helper) {
		component.set("v.Spinner", true); 
	},
	hideSpinner : function(component,event,helper){
		component.set("v.Spinner", false);
	},
	showAddContractor: function(component, event, helper) {	
		component.set("v.newContact", {'FirstName':'','LastName':'','Phone':'','Ext':'','AccountName':'','Fax':'','Email':'','AccountId':'','TempAccountId':'','MobilePhone':''});
		component.set("v.message",'');
		component.set("v.AccountName", '');
		component.set("v.Country",'');
		var vBooth =event.currentTarget.getAttribute("value");
		component.set("v.BoothNumber", vBooth);
		document.getElementById('modalCont').style.display = "block";	
	},
	showUpdateContractor: function(component, event, helper) {
		helper.fetchCountries(component);
		component.set("v.message",'');
		component.set("v.AccountName", '');
		var sID=event.currentTarget.getAttribute("value");
		var mapping = component.set("v.MappingId",sID);
		helper.getExistvalue(component,sID);

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
		document.getElementById('EditmodalCont').style.display = "block";	
	},
	hideAddContactModal: function(component, event, helper) {
		document.getElementById('modalCont').style.display = "none";
		document.getElementById('EditmodalCont').style.display = "none";
		//helper.deleteAccount(component);	
	},
	hideConSuccessModal: function(component, event, helper) {
		helper.fetchBoothsMap(component);
		document.getElementById('modalContactSuccess').style.display = "none";
		component.set("v.newContact", "");	
	  },
	inviteContact: function(component, event, helper) {
		var AccountName= component.get("v.AccountName");
		var Country= component.get("v.Country");
    	var services = [] ;
    	$(".chkbxs").each(function(){
		    var $this = $(this);
		    if($this.is(":checked")){
		        services.push($this.attr("id"));
		    }
		});
		var BoothNumber= component.get("v.BoothNumber");
		var eventSetting= component.get("v.Event_Setting");
		var newcon=component.get("v.newContact");
		var msg='';
		if(!AccountName)
    	{ 
			msg='Please enter company name';
			document.getElementById('modalCont').style.display = "block";
		}
		else if(!newcon.FirstName)
    	{ 
			msg='Please enter first name';
			document.getElementById('modalCont').style.display = "block";
		}
		else if(!newcon.LastName)
    	{ 
			msg='Please enter last name';
			document.getElementById('modalCont').style.display = "block";
		}
		else if(!newcon.MobilePhone)
    	{ 
			msg='Please enter mobile number';
			document.getElementById('modalCont').style.display = "block";
		}
		else if( !/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(newcon.Email))
    	{ 
			msg='Please enter valid email address';
			document.getElementById('modalCont').style.display = "block";
		}
		else if(!Country)
    	{ 
			msg='Please select country';
			document.getElementById('modalCont').style.display = "block";
		}
		if(msg){
    		component.set("v.message",msg);
    	}
		if(newcon.LastName != null && newcon.LastName != '' && newcon.FirstName != null && newcon.FirstName != '' && newcon.Email != null && newcon.Email != '' && newcon.MobilePhone != null && newcon.MobilePhone != '' && AccountName != null && AccountName != '' && Country != null && Country != '')
		{
			helper.createContactHelper(component,services,eventSetting,newcon,BoothNumber,AccountName,Country);	
			document.getElementById('modalContactSuccess').style.display = "block";	
			document.getElementById('modalCont').style.display = "none";
		}
	},
	UpdateSuContractor : function(component, event, helper) {
		var msg='';
    	var services = [] ;
    	$(".chkServices").each(function(){
		    var $this = $(this);
		    if($this.is(":checked")){
		        services.push($this.attr("id"));
		    }
		});
		//var newcon=component.get("v.editSubCont");
		var AccountName=component.get("v.AccountName");
		var Firstname1=component.get("v.firstName");
		var LastName=component.get("v.lastName");
		var MobilePhone=component.get("v.MobilePhone");
		var Email=component.get("v.Email");
		var Country=component.get("v.Country");
		var ContId=component.get("v.sTempCon");
		var AccId=component.get("v.sTempAcc");
		var vMapID = component.get("v.MappingId");

		if(!AccountName)
    	{ 
			msg='Please enter company name';
		}
		else if(!Firstname1)
    	{ 
			msg='Please enter first name';
		}
		else if(!LastName)
    	{ 
			msg='Please enter last name';
		}
		else if(!MobilePhone)
    	{ 
			msg='Please enter mobile number';
		}
		else if( !/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(Email))
    	{ 
			msg='Please enter valid email address';
		}
		else if(!Country)
    	{ 
			msg='Please select country';
		}
		if(msg){
			component.set("v.message",msg);
		}
		else{
			helper.updateCon(component,services,AccountName,Firstname1,LastName,Email,MobilePhone,Country,ContId,AccId,vMapID);
			
			document.getElementById('EditmodalCont').style.display = "none";	
			
		}	
	},
	
	deleteCon : function(component, event, helper) {
		var sID=event.currentTarget.getAttribute("value");
		helper.deleteValue(component,sID); 
		helper.fetchBoothsMap(component); 
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
})