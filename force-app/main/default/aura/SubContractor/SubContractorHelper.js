({
	fetchEventDetails : function(component) {
		var sEventCode = component.get("v.eventcode");
        var action = component.get("c.getEventDetails");
        action.setParams({
            sEventcode : sEventCode
        });
        action.setCallback(this, function(response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS") 
            {
            	//console.log('fetchEventDetails'+JSON.stringify(response.getReturnValue()));
                component.set("v.Event_Setting", response.getReturnValue());// Adding values in Aura attribute variable.
            }
        });
        $A.enqueueAction(action);
	},
	fetchExhibitors : function(component) {
		var sEventCode = component.get("v.eventcode");
        var action = component.get("c.getExhibitors"); 
        action.setParams({
            sEventcode : sEventCode
        });
        action.setCallback(this, function(response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS") 
            {
                //console.log('fetchExhibitors'+JSON.stringify(response.getReturnValue()));
                //component.set("v.boothmap", response.getReturnValue());// Adding values in Aura attribute variable.
            }
        });
        $A.enqueueAction(action);
    },
	updateConStatus : function(component,mid,sts) {
        var sEventCode = component.get("v.eventcode");
        //console.log(sEventCode+mid+sts);
        //this.fetchExhibitors(component);
        var action = component.get("c.updateStatus"); 
        action.setParams({
			sEventcode : sEventCode,
			mapId:mid,
			status:sts
        });
        action.setCallback(this, function(response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS") 
            {
                //console.log('fetchExhibitors'+JSON.stringify(response.getReturnValue()));
                component.set("v.boothmap", response.getReturnValue());// Adding values in Aura attribute variable.
            }
        });
        $A.enqueueAction(action);
    },
	fetchContarctorStatus : function(component) {
        var action = component.get("c.getContartorStatus");
            action.setCallback(this, function(response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS") 
            {
				var opts=[];        	
				for(var i=0;i< response.getReturnValue().length;i++){
					opts.push({label: response.getReturnValue()[i].split('__$__')[1], value: response.getReturnValue()[i].split('__$__')[0]});
				}
                component.set("v.lstStatus", opts);
                //console.log('fetchContarctorStatus'+JSON.stringify( component.get("v.lstStatus")));
                //component.set("v.Event_Setting", response.getReturnValue());// Adding values in Aura attribute variable.
            }
        });
        $A.enqueueAction(action);
	},
	fetchServices : function(component) {
		var sEventCode = component.get("v.eventcode");
        var action = component.get("c.getServices"); //Calling Apex class controller 'EventDetailMethod' method
        action.setParams({
            sEventcode : sEventCode
        });
        action.setCallback(this, function(response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS") 
            {
            	//console.log('fetchServices'+JSON.stringify(response.getReturnValue()));
                component.set("v.services", response.getReturnValue());// Adding values in Aura attribute variable.
            }
        });
        $A.enqueueAction(action);
    },
    createContactHelper : function(component,services,event,sCon,BoothNumber,AccountName,Country) {
        //console.log('component.get("v.newContact")'+JSON.stringify(component.get("v.newContact")));
		var sEvent = event;
        var action = component.get("c.createSubConMapping"); //Calling Apex class controller 'EventDetailMethod' method
        action.setParams({
            con : sCon,
            eventId:sEvent.Event_Edition__c,
            tempAcc:sCon.TempAccountId,
            lstServices:services,
            boothId:BoothNumber,
            accName:AccountName,
            country:Country
        });	
        action.setCallback(this, function(response) { 
            var state = response.getState(); //Checking response status 
            if (component.isValid() && state === "SUCCESS") 
            {
                component.set("v.newContact", ""); 
                component.set("v.Country", '');  
                $(".chkbxs").each(function(){
                    var $this = $(this);
                    if($this.is(":checked")){
                        $this.attr("checked",false)
                    }
                });
				if(response.getReturnValue()=='success')
				{
					this.fetchExhibitors(component);
                }
                document.getElementById('modalContactSuccess').style.display = "block";	
            }
        });
        $A.enqueueAction(action);
    },
    fetchBoothsMap : function(component) {
		var sEventCode = component.get("v.eventcode");
        var action = component.get("c.getBoothsMapping"); //Calling Apex class controller 'EventDetailMethod' method
        action.setParams({
            sEventcode : sEventCode
        });
        action.setCallback(this, function(response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS") 
            {
            	//console.log('fetchBoothsMap'+JSON.stringify(response.getReturnValue()));
            	var custs = [];
                var conts = response.getReturnValue();
                for(var key in conts){
                	var data=key;
                	var bothMaps=conts[key];
                	if(bothMaps.length)bothMaps[0].tot=bothMaps.length;
                    custs.push({value:bothMaps, boothId:data[1],booth:data[0]});
                }
                component.set("v.lstbooths", custs);
            }
        });
        $A.enqueueAction(action);
    },
    getExistvalue : function(component, sBoothId) {
        //console.log('sBoothId======='+sBoothId);
        component.set("v.MobilePhone", '');  
        component.set("v.Country", '');  
        component.set("v.Email", '');  
        var action = component.get("c.getSubContractor"); //Calling Apex class controller 'sUpdateSubContact' method
        action.setParams({
            sMapId : sBoothId
        });
        action.setCallback(this, function(response) {
        var state = response.getState(); //Checking response status
        if (component.isValid() && state === "SUCCESS") 
        {
            //console.log('editSubCont'+JSON.stringify(response.getReturnValue()));
            var vData = response.getReturnValue();
            component.set("v.AccountName", vData[0].TempContact__r.TempAccount__r.Name); 
            component.set("v.firstName", vData[0].TempContact__r.FirstName__c);  
            component.set("v.lastName", vData[0].TempContact__r.LastName__c);  
            component.set("v.Phone", vData[0].TempContact__r.Phone__c);  
            component.set("v.MobilePhone", vData[0].TempContact__r.MobilePhone__c);  
            component.set("v.Country", vData[0].TempContact__r.TempAccount__r.Country__c);  
            component.set("v.Email", vData[0].TempContact__r.Email__c); 
            component.set("v.sTempCon", vData[0].TempContact__c);
            component.set("v.sTempAcc", vData[0].TempContact__r.TempAccount__c);          
        }
        });
        $A.enqueueAction(action);
    },
    updateCon : function(component, services,accName,fName,lName,email,mobile,country,conId,accId,mapId) {
        
        var action = component.get("c.updateContact"); //Calling Apex class controller 'EventDetailMethod' method
        action.setParams({
            lstServices:services,
            accName:accName,
            fName:fName,
            lName:lName, 
            email:email, 
            mobile:mobile,
            country:country,
            conId:conId,
            accId:accId,
            mapId:mapId
        });
        action.setCallback(this, function(response) { 
            var state = response.getState(); //Checking response status 
            if (component.isValid() && state === "SUCCESS") 
            {
                document.getElementById('EditmodalCont').style.display = "none";	
                document.getElementById('modalContactSuccess').style.display = "block";	
            }
        });
        $A.enqueueAction(action);
    },
    deleteValue : function(component, sBoothId) {
        var action = component.get("c.sDeleteRecord"); //Calling Apex class controller 'sUpdateSubContact' method
        action.setParams({
            sBoothId : sBoothId
        });
        action.setCallback(this, function(response) {
        var state = response.getState(); //Checking response status
        if (component.isValid() && state === "SUCCESS") 
        {
           // console.log('editSubCont'+JSON.stringify(response.getReturnValue()));
        }
        });
        $A.enqueueAction(action);
    },
    fetchCountries : function(component) {
        var action = component.get("c.getCountries"); //Calling Apex class controller 'EventDetailMethod' method
        action.setCallback(this, function(response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS") 
            {
				//console.log('fetchCountries'+JSON.stringify(response.getReturnValue()));
				var opts=[];    
				opts.push({label: '--Select--', value: ''});    	
				for(var i=0;i< response.getReturnValue().length;i++){
					opts.push({label: response.getReturnValue()[i].split('__$__')[1], value: response.getReturnValue()[i].split('__$__')[1]});
				}
                component.find('billingCountry').set("v.options", opts);
                component.find('billingCountryUp').set("v.options", opts);  
            }
        });
        $A.enqueueAction(action);
    },
    getUrlParameter : function (component,parameterName)
    {
        var url=window.location.href;
        //console.log('url : '+url);
        var allParams=url.split('?')[1];
        var paramArray = allParams.split('&');
        var val;
        for(var i=0;i<paramArray.length;i++)
        {
        	var curentParam = paramArray[i];
            //console.log('curentParam : '+curentParam);
        	if(curentParam.split('=')[0]== parameterName)
            {
                //console.log('Code ' + curentParam.split('=')[1]);
                val = curentParam.split('=')[1];
        		//component.set("v.accountId",curentParam.split('=')[1]);
        	}
        }
        return val;
    }
})