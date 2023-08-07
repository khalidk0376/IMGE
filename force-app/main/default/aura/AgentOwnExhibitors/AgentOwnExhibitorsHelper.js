({
	//Apex class : AgentOwnExhibitorsCtrl 
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
                var result=response.getReturnValue();
                //console.log('response.fetchEventDetails>>>>>'+JSON.stringify(result));
                component.set("v.eventSetting", result);// Adding values in Aura attribute variable.
                var opts=[]; 
                if(result.Event_Edition__r.Matched_Product_Name__c)
                {
                    var boothTypes =result.Event_Edition__r.Matched_Product_Name__c.split(';');
                   	//console.log('shdvc'+boothTypes);
				    opts.push({label: 'Stand Type', value: ''});    	 
				    for(var i=0;i< boothTypes.length;i++)
                    {
					   opts.push({label: boothTypes[i], value: boothTypes[i]});
				    }				     
                }   
                //component.find('standtype').set("v.options", opts);
                this.fetchEventContactMap(component);
               
            }
        });
        $A.enqueueAction(action);
    },
    fetchsubAgents : function(component) {
        var sEventCode = component.get("v.eventcode");// Getting values from Aura attribute variable.
        var action = component.get("c.getSubAgents"); //Calling Apex class controller 'getEventDetails' method
        action.setParams({
            sEventcode : sEventCode
        });
        action.setCallback(this, function(response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS") 
            {
                var result=response.getReturnValue();
                //console.log('response.fetchsubAgents>>>>>'+JSON.stringify(result));
                component.set("v.subAgents", response.getReturnValue());// Adding values in Aura attribute variable.
            }
        });
        $A.enqueueAction(action); 
    },
    // fetchExhibitors : function(component) {
    //     var isNewExh=component.get("v.newExhibitors");// Getting values from Aura attribute variable.
    //     var isMisBadges=component.get("v.missingBadges");// Getting values from Aura attribute variable.
    //     var isMisForms=component.get("v.missingForms");// Getting values from Aura attribute variable.
    //     var stype=component.get("v.standtype");// Getting values from Aura attribute variable.
    //     var sdimension=component.get("v.dimension");// Getting values from Aura attribute variable.
    //     var sEventCode = component.get("v.eventcode");// Getting values from Aura attribute variable.
    //     var subAgentSelected = component.get("v.subAgentSelected");// Getting values from Aura attribute variable.
    //     var isIndCon = component.get("v.indContract"); //CCEN-601
    //     var accId;
    // console.log(stype);
    //     if(subAgentSelected)
    //     {
    //         accId=subAgentSelected.id;
    //     }
    //     //console.log('isNewExh>>'+isNewExh);     
    //     var action = component.get("c.getExhibitors"); //Calling Apex class controller 'getExhibitors' method
    //     action.setParams({
    //         sEventcode : sEventCode,
    //         accountId : accId, 
    //         standType:stype,
    //         dimensions:sdimension,
    //         isNewExhibitors:isNewExh,
    //         isMissingBadges:isMisBadges,
    //         isMissingForms:isMisForms,
    //         isMissingManuals:false,
    //         isIndContract:isIndCon
    //     });
    //     action.setCallback(this, function(response) { 
    //         var state = response.getState(); //Checking response status
    //         console.log('test'+JSON.stringify(response.getReturnValue()));
            
    //         if (component.isValid() && state === "SUCCESS") 
    //         {   
    //             var result = response.getReturnValue();
    //             console.log('response.fetchExhibitors>>>>>'+JSON.stringify(result));
    //             component.set("v.exhibitors", result);// Adding values in Aura attribute variable.
                
    //         }
    //     }); 
    //     $A.enqueueAction(action);  
    // },
    fetchAllAOECustomers : function(component, chkFilter) 
    {
        var subAgentAccId;
        var activityType = component.get("v.activityType");// Getting values from Aura attribute variable.
        var userType = component.get("v.userType");
        var eventcode = component.get("v.eventcode");
        var standType = component.get('v.standtype');
        var newExh = component.get('v.newExhibitors');
        var searchWord = component.get('v.searchText');
        //console.log('activityType'+activityType);

        if(chkFilter == false)
        {
            activityType = '';// Getting values from Aura attribute variable.
            userType = 'All';// Getting values from Aura attribute variable.   
            standType = '';
            newExh = false;
            searchWord = '';
            component.set('v.showclearFilter' , true);
            component.set('v.newExhibitors', false);
            component.set('v.activityType', '');
            component.set("v.userType", 'All');
            component.set('v.standtype','');
            component.set('v.searchText', '');

        }
        if(component.get("v.subAgentSelected.id"))
        {
            subAgentAccId = component.get("v.subAgentSelected.id");// Getting values from Aura attribute variable.
        }

        var action = component.get("c.getAllCustomers"); //Calling Apex class controller 'getAllCustomers' method
        action.setParams({
            sEventcode  :   eventcode,
            activity    :   activityType,
            usertype    :   userType,
            subAgentAccId: subAgentAccId,
            standType: standType,
            newExh: newExh,
            searchWord: searchWord
        });
        action.setCallback(this, function(response) { 
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS") 
            {
                var opts =[];
                opts.push({label: 'Stand Type', value: ''});
                var result = response.getReturnValue();
                //console.log('response.fetchAccountContacts>>>>>'+JSON.stringify(result)); 
                component.set("v.exhibitors", result);// Adding values in Aura attribute variable.
                component.set("v.AllExhibitors", result);// Adding values in Aura attribute variable in main Atribute. 
                var duplicate = false;
                var checkStandType = component.get('v.onLoadStandType');
                if(checkStandType == true)
                {
                    for(var i=0;i<result.length;i++)
                    {
                        for(var j=0;j<opts.length;j++)
                        {
                            if(result[i].boothType == opts[j].value)
                            {
                                duplicate = true;
                            }
                            if(opts[j].value == 'null' && !result[i].boothType) 
                            {
                                duplicate = true;
                            } 
                        }
                        if(duplicate == false)
                        {
                            //console.log('result[i].boothType ' +result[i].boothType);
                            if(result[i].boothType)
                            {
                                opts.push({label: result[i].boothType, value: result[i].boothType});
                            }
                            else{
                                opts.push({label: 'None', value: 'null'});
                            }
                        }
                        duplicate = false;
                    }
                    component.set('v.onLoadStandType', false); 
                    //console.log('standtype' +JSON.stringify(opts));
                    component.find('standtype').set("v.options", opts);     
                }
                // Reset Checkbox
                $(".chkChild").each(function(){
                    var $this = $(this);
                    if($this.is(":checked")){
                        $this.attr("checked",false) 
                     }
                }); 
                this.getSelectedCount(component);
            }
            else
            {
                console.log('ERROR!'+JSON.stringify(response.getReturnValue()));
            }
        });
        $A.enqueueAction(action);
    },
    fetchAccountContacts : function(component,accid) {
        var eventSetting = component.get("v.eventSetting");// Getting values from Aura attribute variable.
        //console.log('sEventCode>>>>>'+sEventCode);
        var action = component.get("c.getAccccountContacts"); //Calling Apex class controller 'getAccccountContacts' method
        action.setParams({
            accId : accid,
            eventId:eventSetting.Event_Edition__c
        });
        action.setCallback(this, function(response) { 
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS") 
            {
                //console.log('response.fetchAccountContacts>>>>>'+JSON.stringify(response.getReturnValue()));
                component.set("v.accountContacts", response.getReturnValue());// Adding values in Aura attribute variable.
                $('#modalViewExhibitor').show();
            }else
            {
                console.log('ERROR!');
            }
        });
        $A.enqueueAction(action);
    },
    fetchEventContactMap : function(component,accid) {
        var eventSetting = component.get("v.eventSetting");// Getting values from Aura attribute variable.
        var action = component.get("c.getContactEventEditionMapping"); //Calling Apex class controller 'getContactEventEditionMapping' method
        action.setParams({
            eventId:eventSetting.Event_Edition__c
        });
        action.setCallback(this, function(response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS") 
            {                
                var result = response.getReturnValue();
                //console.log('response.fetchEventContactMap>>>>>'+JSON.stringify(result));
                if(result.User_Type__r && result.User_Type__r.Name=='Agent')
                {
                    var eventsetting = component.get("v.eventSetting");
                    let isChange = false;
                    if(!result.Agent_Email_Body_Content_1__c && eventsetting.Exhibitor_Email_Content1__c){
                        result.Agent_Email_Body_Content_1__c = eventsetting.Exhibitor_Email_Content1__c;
                        isChange = true;
                    }
                    if(!result.Agent_Email_Body_Content_2__c && eventsetting.Exhibitor_Email_Content2__c)
                    {
                        result.Agent_Email_Body_Content_2__c = eventsetting.Exhibitor_Email_Content2__c;
                        isChange = true;
                    }
                    component.set("v.eventContactMap", result);
                    if(isChange)
                    {
                        this.updateEventContactMap(component);
                    }                    
                }
                component.set("v.eventContactMap", result);// Adding values in Aura attribute variable.
            }
        });
        $A.enqueueAction(action);
    },
   updateEventContactMap : function(component) {
        var eventContactMap = component.get("v.eventContactMap");// Getting values from Aura attribute variable.
        var action = component.get("c.updateContactEventEditionMapping"); //Calling Apex class controller 'updateContactEventEditionMapping' method
        action.setParams({
            eventConMap:eventContactMap
        });
        action.setCallback(this, function(response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS") 
            {
                //console.log('response.updateEventContactMap>>>>>'+JSON.stringify(response.getReturnValue()));
            }
        });
        $A.enqueueAction(action);
    },
    sendWelcomeEmail : function(component,conIds) {
        //console.log('conIds>>>>>'+JSON.stringify(conIds));
        var eventSetting = component.get("v.eventSetting");// Getting values from Aura attribute variable.
        console.log('conIds ' +conIds+ ' eventSetting.Event_Edition__c ' +eventSetting.Event_Edition__c);
        var action = component.get("c.sendEmailtoExhibitors"); //Calling Apex class controller 'updateContactEventEditionMapping' method
        action.setParams({
            lstConIds:conIds,
            eventId:eventSetting.Event_Edition__c
        });
        action.setCallback(this, function(response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS") 
            {                
                this.fetchAllAOECustomers(component);
                //console.log('response.sendWelcomeEmail>>>>>'+JSON.stringify(response.getReturnValue()));
            }
        });
        $A.enqueueAction(action);
    },
    fetchBoothDetails : function(component,uType) {
        var booth = component.get("v.booth");// Getting values from Aura attribute variable.
        var sEventCode = component.get("v.eventcode");// Getting values from Aura attribute variable.
        var action = component.get("c.getBoothDetails"); //Calling Apex class controller 'updateContactEventEditionMapping' method
        action.setParams({
            boothId:booth.boothId,
            sEventCode:sEventCode,
            uType:uType
        });
        action.setCallback(this, function(response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS") 
            {
                component.set("v.expocadbooth",response.getReturnValue());
                //console.log('response.fetchBoothDetails>>>>>'+JSON.stringify(response.getReturnValue()));
            }
        });
        $A.enqueueAction(action);
    },
    fetchBoothDimensions : function(component) {  // No Need!
        var action = component.get("c.getBoothDimensions"); //Calling Apex class controller 'updateContactEventEditionMapping' method
        action.setCallback(this, function(response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS") 
            {
                //console.log('response.fetchBoothDetails>>>>>'+JSON.stringify(response.getReturnValue()));
                var opts=[];    
				opts.push({label: 'Dimensions', value: ''});    	
				for(var i=0;i< response.getReturnValue().length;i++){
					opts.push({label: response.getReturnValue()[i].Dimensions__c, value: response.getReturnValue()[i].Dimensions__c});
				}
                component.find('dimension').set("v.options", opts); 
                component.find('dimension2').set("v.options", opts); 
            }            
        });
        $A.enqueueAction(action);
    },/* 
    fetchNewExhibitors : function(component) {
        var sEventCode = component.get("v.eventcode");// Getting values from Aura attribute variable.
        //console.log('isNewExh>>'+isNewExh);     
        var accId;
        var subAgentSelected = component.get("v.subAgentSelected");// Getting values from Aura attribute variable.
        if(subAgentSelected)
        {
            accId=subAgentSelected.id;
        }
        var action = component.get("c.getExhibitors"); //Calling Apex class controller 'getExhibitors' method
        action.setParams({
            sEventcode : sEventCode,
            accountId:accId,
            standType:'',
            dimensions:'',
            isNewExhibitors:true,
            isMissingBadges:false,
            isMissingForms:false,
            isMissingManuals:false,
            isIndContract:false
        });
        action.setCallback(this, function(response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS") 
            {   
                //console.log('response.fetchNewExhibitors>>>>>'+JSON.stringify(response.getReturnValue().length));
                component.set("v.newExhTotal", response.getReturnValue().length);// Adding values in Aura attribute variable.
                //component.set("v.newExhTotal",'10');// Adding values in Aura attribute variable.
            }
        }); 
        $A.enqueueAction(action);  
    },*/
    fetchRequiredForms : function(component,accid) {
        var eventSetting = component.get("v.eventSetting");// Getting values from Aura attribute variable.
        var action = component.get("c.getRequiredForms"); //Calling Apex class controller 'getAccccountContacts' method
        action.setParams({
            accId : accid,
            eventId:eventSetting.Event_Edition__c
        });
        action.setCallback(this, function(response) { 
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS") 
            {
                component.set("v.requiredForms",response.getReturnValue());
                //console.log('response.fetchRequiredForms>>>>>'+JSON.stringify(response.getReturnValue()));
            }
        });
        $A.enqueueAction(action);
    },
    getSelectedCount : function(component) {
        var counter=0;
        $(".chkChild").each(function(){
            var $this = $(this);
			if( $this.is(":checked")){
				counter++;
			 }
        });
        if(counter>0)
        {
            $("#btnsendmail").attr("disabled", false);
        }
        else
        {
            $("#btnsendmail").attr("disabled", true);
            $('.chkMaster').attr("checked",false);
        }
    },
    fetchExhibitorsReports : function(component,isMisBadges,isMisForms,isMisManuals,isBadgeReport) {
        component.set("v.reportNotFound",false);
        var sEventCode = component.get("v.eventcode");// Getting values from Aura attribute variable.
       //console.log('isNewExh>>'+isNewExh);  
        var accId;
        var subAgentSelected = component.get("v.subAgentSelected");// Getting values from Aura attribute variable.
        var exportUrl = window.location.origin + '/apex/c__ExportAOEReports?eventId='+sEventCode+'&accountId=';
        this.downloadReportFile(exportUrl,isMisBadges,isMisForms,isMisManuals,isBadgeReport);
        // if(subAgentSelected)
        // {
        //     accId=subAgentSelected.id;
        //     exportUrl+= accId;
        // }   
        // var action = component.get("c.getExhibitors"); //Calling Apex class controller 'getExhibitors' method
        // action.setParams({
        //     sEventcode : sEventCode,
        //     accountId:accId,
        //     standType:'',
        //     dimensions:'',
        //     isNewExhibitors:false,
        //     isMissingBadges:isMisBadges,
        //     isMissingForms:isMisForms,
        //     isMissingManuals:isMisManuals,
        //     isIndContract:false
        // });
        // action.setCallback(this, function(response) {
        //     var state = response.getState(); //Checking response status
        //     if (component.isValid() && state === "SUCCESS") 
        //     {   
        //         //console.log('response.fetchExhibitorsReports>>>>>'+JSON.stringify(response.getReturnValue()));
        //         if(response.getReturnValue().length>0)
        //         {
        //             this.downloadReportFile(exportUrl,isMisBadges,isMisForms,isMisManuals,isBadgeReport);
        //         }
        //         else{
        //             component.set("v.reportNotFound",true);
        //         }
                
        //     }
        // }); 
        // $A.enqueueAction(action); 
    },
    convertArrayOfObjectsToCSV : function(component,isMisBadges,isMisForms,isMisManuals,isBadgeReport,objectRecords){
        // declare variables
        var csvStringResult, counter, keys, columnDivider, lineDivider,columns;
    
        // check if "objectRecords" parameter is null, then return from function
        if (objectRecords == null || !objectRecords.length) {
            return null;
        }
        // store ,[comma] in columnDivider variabel for sparate CSV values and 
        // for start next line use '\n' [new line] in lineDivider varaible  
        columnDivider = ',';
        lineDivider =  '\n';

        // in the keys valirable store fields API Names as a key 
        // this labels use in CSV file header  
        keys = ['accountName','boothNumber','fName','lName','email','agentCompany','agentName','requiredForms','requiredManuals','badges','badgesAlloted','badgesCompleted'];
        columns = ['Company Name','Stand','First Name','Last Name','Email','Agent Company','Agent Name','Required Forms','Required Manuals','Badges','Badges Alloted','Badges Completed'];
        if(isMisBadges)
        {
            keys = ['accountName','boothNumber','fName','lName','email','agentCompany','agentName'];
            columns = ['Company Name','Stand','First Name','Last Name','Email','Agent Company','Agent Name']; 
        }
        else if(isMisForms)
        {
            keys = ['accountName','boothNumber','fName','lName','email','agentCompany','agentName','requiredForms'];
            columns = ['Company Name','Stand','First Name','Last Name','Email','Agent Company','Agent Name','Required Forms']; 
        }
        else if(isMisManuals)
        {
            keys = ['accountName','boothNumber','fName','lName','email','agentCompany','agentName','requiredManuals'];
            columns = ['Company Name','Stand','First Name','Last Name','Email','Agent Company','Agent Name','Required Manuals']; 
        }
        else if(isBadgeReport)
        {
            keys = ['Exhibitor_Name__c','Job_Title__c','First_Name__c','Last_Name__c','Mobile_Number__c','Email__c','Age_Bracket__c','Address__c','City__c','State__c','Country__c','Nationality__c','Status__c'];//,'Booth_Size__c'
            columns = ['Exhibitor Name','Job Title','First Name','Last Name','Mobile Number','Email','Age Bracket','Address','City','State','Country','Nationality','Status']; //,'Booth Size'
        }
        csvStringResult = ''; 
        csvStringResult += columns.join(columnDivider);
        csvStringResult += lineDivider;

        for(var i=0; i < objectRecords.length; i++){   
            counter = 0;
            for(var sTempkey in keys) {
                var skey = keys[sTempkey] ;  
                // add , [comma] after every String value,. [except first]
                if(counter > 0){ 
                    csvStringResult += columnDivider; 
                }   
                if(objectRecords[i][skey])
                {
                    csvStringResult += '"'+ objectRecords[i][skey]+'"'; 
                }
                counter++;
            } // inner for loop close 
            csvStringResult += lineDivider;
        }// outer main for loop close 
        // return the CSV formate String 
        return csvStringResult;        
    },
    downloadReportFile : function(exportUrl,isMisBadges,isMisForms,isMisManuals,isBadgeReport){
        var filename='AllExhibitors';
        if(isMisBadges)
        {
            filename='ExhibitorsMissingBadges';  
        }
        else if(isMisForms)
        {
            filename='ExhibitorsMissingForms';  
        }
        else if(isMisManuals)
        {
            filename='ExhibitorsMissingManuals';  
        }
        else if(isBadgeReport)
        {
            filename='ExhibitorsBadgeInformation';  
        }
        exportUrl+='&reportName=' + filename;
		window.location =  exportUrl;
    },
    SearchCustomer : function(component,serchText)
    {
        var exhibitorList = component.get("v.AllExhibitors");
        //console.log('exhibitorList'+JSON.stringify(exhibitorList));
        var searchAccName = serchText.toLowerCase();
        var exhibitorList2 = [];
        if(serchText)
        {
            for(var i=0;i<exhibitorList.length;i++)
            {
                var exhibitorAccName = exhibitorList[i].accountName.toLowerCase();
                if(exhibitorAccName.includes(searchAccName))
                {
                    //console.log('exhibitors'+JSON.stringify(exhibitorList2));
                    exhibitorList2.push(exhibitorList[i]);
                }
            }
            component.set('v.exhibitors',exhibitorList2);
        }
        else
        {   
            this.fetchAllAOECustomers(component);
        }
        
        // exhibitorList2 = exhibitorList.filter(
        //     function(value) 
        //     {            
        //         return serchText === value.accountName;
        //         //return value.accountName.toString().indexOf(serchText) > -1
        //     });
        // console.log('response  >>>'+JSON.stringify(exhibitorList2)); 

    },
    changeNewExh : function(component, chk)
    {
        var exhibitorList = component.get("v.AllExhibitors");
        var newExh = [];
        if(chk)
        {
            for(var i=0;i<exhibitorList.length;i++)
            {
                if(exhibitorList[i].isMailSent == false)
                {
                    newExh.push(exhibitorList[i]);
                }
            }
            component.set('v.exhibitors',newExh);
        }
        else
        {

        }
        
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