({
    //Apex class : MyExhibitorsCtrl 
    fetchEventDetails: function (component) {
        var sEventCode = component.get("v.eventcode"); // Getting values from Aura attribute variable.
        //console.log('sEventCode>>>>>'+sEventCode);
        component.set("v.Spinner", true);// Enable Defalut Spinner after a Sec delay.
        var action = component.get("c.getEventDetails"); //Calling Apex class controller 'getEventDetails' method
        action.setParams({
            sEventcode: sEventCode
        });
        action.setCallback(this, function (response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS") {
                var vActive = response.getReturnValue();
                //console.log('fetchEventDetails'+JSON.stringify(response.getReturnValue()));
                //var vale =  response.getReturnValue();
                component.set("v.Event_Setting", response.getReturnValue()); // Adding values in Aura attribute variable.
                component.set("v.step1", vActive.Contractor_MyExhibitor_Detail_Tab_1__c);
                component.set("v.step2", vActive.Contractor_MyExhibitor_Detail_Tab_2__c);
                component.set("v.step3", vActive.Contractor_MyExhibitor_Detail_Tab_3__c);
                component.set("v.step4", vActive.Contractor_MyExhibitor_Detail_Tab_4__c);
                this.Setmaxheight(component, "MaxRiggingHeight", vActive.Cont_MyExhibitor_Detail_Tab2_Max_Rigging__c);
                this.Setmaxheight(component, "MaxstandHeight", vActive.Cont_MyExhibitor_Detail_Tab_2_Max_Stand__c);
                this.SetDecimalVal(component, "MaxstandHeightDecimal");
                this.SetDecimalVal(component, "MaxRiggingHeighDecimal");

                if (vActive.Contractor_MyExhibitor_Detail_Tab_1__c)
                {
                    // setTimeout(function(){
                    //     this.fetchManuals(component);
                    // }, 1000);
                } else
                {
                    component.set("v.checkManuals", true);
                    $("#steps").css({
                        'border-left': '3px solid #7d7d7d'
                    });
                }
            }
        	component.set("v.Spinner", false);   
        });
        $A.enqueueAction(action);
    },
    fetchBoothMap: function (component) {
        component.set("v.Spinner", true);// Enable Defalut Spinner after a Sec delay.//BK-1762
        var mid = component.get("v.mapid"); // Getting values from Aura attribute variable.
        //console.log('mapid>>>>>'+mid);
        var action = component.get("c.getExhibitorMapbyId"); //Calling Apex class controller 'getExhibitorMapbyId' method
        action.setParams({
            mapId: mid
        });
        action.setCallback(this, function (response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS")
            {
                //console.log('getExhibitorMapbyId'+JSON.stringify(response.getReturnValue()));
                var result = response.getReturnValue();
                var standmap = {
                    Open_Side__c: ''
                };
                if(result.Opp_Booth_Mapping__r && result.Opp_Booth_Mapping__r.Expocad_Booth__r)
                {
                    if (result.Opp_Booth_Mapping__r.Expocad_Booth__r.Open_Corners__c == 1)
                    {
                        standmap.Open_Side__c = 'One Side Open Stand';
                    } else if (result.Opp_Booth_Mapping__r.Expocad_Booth__r.Open_Corners__c == 2)
                    {
                        standmap.Open_Side__c = 'Two Side Open Stand';
                    } else if (result.Opp_Booth_Mapping__r.Expocad_Booth__r.Open_Corners__c == 3)
                    {
                        standmap.Open_Side__c = 'Three Side Open Stand';
                    } else if (result.Opp_Booth_Mapping__r.Expocad_Booth__r.Open_Corners__c == 4)
                    {
                        standmap.Open_Side__c = 'Island Booth (4 sides)';
                    }
                }
                
                //console.log('standmap===='+JSON.stringify(standmap));
                component.set("v.standDetail", standmap); // Adding values in Aura attribute variable.
                component.set("v.exhibitorDtls", result); // Adding values in Aura attribute variable.
                component.set("v.accountId",result.Contact__r.AccountId)
                //console.log('exhibitorDtls ====== '+ JSON.stringify(result));
                this.fetchStandDetails(component);
                this.fetchStandDesign(component);
                this.fetchReqManuals(component);
                this.fetchManuals(component);
            }
        	component.set("v.Spinner", false);    
        });
        
        $A.enqueueAction(action);
    },
    updateBoothDesign: function (component)
    {
        component.set("v.Spinner", true);// Enable Defalut Spinner after a Sec delay.//BK-1762
        var standDesign = component.get("v.standDesign"); // Getting values from Aura attribute variable.
        var action = component.get("c.updateStandDesign"); //Calling Apex class controller 'updateStandDesign' method
        action.setParams({
            standdesign: standDesign
        });
        action.setCallback(this, function (response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS") {
                //console.log('updateBoothDesign'+JSON.stringify(response.getReturnValue()));
                this.fetchStandDesign(component);
            }
            component.set("v.Spinner", false);// Enable Defalut Spinner after a Sec delay.
        });        
        $A.enqueueAction(action);
    },
    deleteDesginFile: function (component, attId, standDesignRecID) {
        component.set("v.Spinner", true);// Enable Defalut Spinner after a Sec delay.//BK-1762
        var action = component.get("c.deleteFile"); //Calling Apex class controller 'deleteFile' method
        action.setParams({
            attId: attId,
            designRecID: standDesignRecID
        });
        action.setCallback(this, function (response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS") {
                //console.log('deleteDesginFile'+JSON.stringify(response.getReturnValue()));
                this.fetchStandDesign(component);
            }
            component.set("v.Spinner", false);
        });        
        $A.enqueueAction(action);
    },
    fetchStandDetails: function (component) {
        component.set("v.Spinner", true);// Enable Defalut Spinner after a Sec delay.//BK-1762
        var mid = component.get("v.mapid"); // Getting values from Aura attribute variable.
        var exhibitorDtls = component.get("v.exhibitorDtls");
        //console.log('Agent  =============== '+exhibitorDtls.Agent_Contact__r.AccountId);
        var AgentId;
        if(exhibitorDtls.Agent_Contact__c)
        {
            AgentId = exhibitorDtls.Agent_Contact__r.AccountId;
        }
        var action = component.get("c.getStandDetail"); //Calling Apex class controller 'getStandDetail' method
        action.setParams({
            boothId: exhibitorDtls.Opp_Booth_Mapping__c,
            accId: exhibitorDtls.Contact__r.AccountId,
            eventCode: component.get("v.eventcode"),
            agentId:AgentId
        });
        action.setCallback(this, function (response) {
            var state = response.getState(); //Checking response status            
            console.log('fetchStandDetails : '+JSON.stringify(response.getReturnValue()));
            if (component.isValid() && state === "SUCCESS")
            {
                var result = response.getReturnValue();
                if(result.Id)
                {
                    component.set("v.isStandDetail", true);
                    if (result.Rigging_Height__c > 0) {
                        var riggHeight = result.Rigging_Height__c.toString().split('.');
                        result.RiggingHeight = riggHeight[0].toString();
                        if (riggHeight.length > 1)
                        {
                            result.RiggingHeightDecimal = '.' + riggHeight[1].toString();
                        }
                    }
                    if (result.Stand_Height__c > 0)
                    {
                        var standHeight = result.Stand_Height__c.toString().split('.');
                        result.StandHeight = standHeight[0].toString();
                        if (standHeight.length > 1)
                        {
                            result.StandHeightDecimal = '.' + standHeight[1].toString();
                        }
                    }
                    // result.RiggingHeight= result.Rigging_Height__c.toString();
                    // result.StandHeight=  result.Stand_Height__c.toString();
                    component.set("v.standDetail", result); // Adding values in Aura attribute variable.
                    component.set("v.NoRigging", !result.IsRigging__c); //setting value of NoRigging Aura attribute
                }
                
            }
            component.set("v.Spinner", false);
        });
        
        $A.enqueueAction(action);
    },

    fetchStandDesign: function (component) {
        component.set("v.Spinner", true);// Enable Defalut Spinner after a Sec delay.//BK-1762
        var mid = component.get("v.mapid"); // Getting values from Aura attribute variable.
        var exhibitorDtls = component.get("v.exhibitorDtls"); // Getting values from Aura attribute variable.
        //console.log('Agent  =============== '+exhibitorDtls.Agent_Contact__r.AccountId);
        var AgentId;
        if(exhibitorDtls.Agent_Contact__c)
        {
            AgentId = exhibitorDtls.Agent_Contact__r.AccountId;
        }
        //console.log(exhibitorDtls.ExpocadBooth__c +' bth '+exhibitorDtls.Contact__r.AccountId+' acc  '+AgentId );
        var action = component.get("c.getStandDesign"); //Calling Apex class controller 'getStandDesign' method
        action.setParams({
            boothId: exhibitorDtls.Opp_Booth_Mapping__c,
            accId: exhibitorDtls.Contact__r.AccountId,
            eventCode: component.get("v.eventcode"),
            agentId:AgentId
        });

        action.setCallback(this, function (response) {
            var state = response.getState(); //Checking response status
            var result = response.getReturnValue();
            console.log('fetchStandDesign-----------------'+JSON.stringify(response.getReturnValue()));

            if (component.isValid() && state === "SUCCESS" && result.Stand_Type__c)
            {
                //console.log('component.isValid() && state === "SUCCESS"');
                if (result.Stand_Type__c == 'Non Complex')
                {
                    $('#acc1').click();
                    $('#pan1').css({"max-height": "1000px","overflow-y": "auto"});
                } else if (result.Stand_Type__c == 'Complex Stand 1')
                {
                    $('#acc2').click();
                    $('#pan2').css({"max-height": "1000px","overflow-y": "auto"});
                } else if (result.Stand_Type__c == 'Complex Stand 2')
                {
                    $('#acc3').click();
                    $('#pan3').css({"max-height": "1000px","overflow-y": "auto"});
                }
                if (result.Booth_Design_Status__c == 'Tentative Approval')
                {
                    component.set("v.isStandDesign", true);
                }
                component.set("v.isAgree", result.Contractor_Agreement_CA__c);
                if(result.DesignAttachmentTypes__r)
                {
                    var dsn = [];
                    for(var i = 0;i<result.DesignAttachmentTypes__r.length;i++)
                    {
                        if(result.DesignAttachmentTypes__r[i].IsRejected__c = false)
                        {
                            
                        }
                    }
                }
                component.set("v.standDesign", result); // Adding values in Aura attribute variable.
            } else {
                component.set("v.standDesign", null);
            }
            this.showSection(component);
            component.set("v.Spinner", false);
        });
        $A.enqueueAction(action);
    },

    fetchManuals: function (component) {
        component.set("v.Spinner", true);// Enable Defalut Spinner after a Sec delay.//BK-1762
        var eventCode = component.get("v.eventcode"); // Getting values from Aura attribute variable.
        var accountId = component.get("v.accountId"); // Getting values from Aura attribute variable.
        var exhibitorDtls = component.get("v.exhibitorDtls");
        var action = component.get("c.checkManuals"); //Calling Apex class controller 'checkManuals' method
        
        action.setParams({
            sEventcode: eventCode,
            contactId:exhibitorDtls.Contact__c,
            accountId :accountId
        });
        action.setCallback(this, function (response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS") {
                //console.log('fetchManuals=========='+JSON.stringify(response.getReturnValue()));
                component.set("v.checkManuals", response.getReturnValue());
               this.showSection(component);
            }
            component.set("v.Spinner", false);
        });
        $A.enqueueAction(action);
    },
    fetchReqManuals: function (component) {
        component.set("v.Spinner", true);// Enable Defalut Spinner after a Sec delay.//BK-1762
        var hostnm = window.location.hostname;
        component.set("v.hostnm", hostnm);
        var accountId = component.get("v.accountId"); // Getting values from Aura attribute variable.
        var exhibitorDtls = component.get("v.exhibitorDtls");
        var eventCode = component.get("v.eventcode"); // Getting values from Aura attribute variable.
        var action = component.get("c.fetchReqManuals"); //Calling Apex class controller 'checkManuals' method
        action.setParams({
            sEventcode: eventCode,
            contactId:exhibitorDtls.Contact__c,
            accountId :accountId
        });
        action.setCallback(this, function (response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS")
            {
                //console.log('fetchReqManuals=========='+JSON.stringify(response.getReturnValue()));
                component.set("v.reqManualslist", response.getReturnValue());
            }
            component.set("v.Spinner", false);
        });
        $A.enqueueAction(action);
    },
    saveStandDtls: function (component) {
        //component.set("v.Spinner", true);// Enable Defalut Spinner after a Sec delay.//BK-1762
        var standDetails = component.get("v.standDetail"); // Getting values from Aura attribute variable.
        var exhibitorDtls = component.get("v.exhibitorDtls"); // Getting values from Aura attribute variable.
       	standDetails.Account__c = exhibitorDtls.Contact__r.AccountId;
        // standDetails.ExpocadBooth__c = exhibitorDtls.ExpocadBooth__c;
        // standDetails.Agent_Account__c = exhibitorDtls.Agent_Contact__r.Account.Id;
        // standDetails.Event_Edition__c = exhibitorDtls.Event_Edition__c; 
        standDetails.Rigging_Height__c = standDetails.RiggingHeightNew;
        standDetails.Stand_Height__c = standDetails.StandHeightNew;
       // console.log('saveStandDtls=========='+JSON.stringify(standDetails));

        var action = component.get("c.updateStandDetails"); //Calling Apex class controller 'updateStandDetails' method        
        action.setParams({
            standDetail: standDetails
        });
        action.setCallback(this, function (response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('saveStandDtls  result =========='+JSON.stringify(result));
                document.getElementById("requiredCheck").style.display = "none";
                document.getElementById("requireEarlyCheck").style.display = "none";
                component.set("v.isStandDetail", true);
                // result.RiggingHeight= result.Rigging_Height__c.toString();
                // result.StandHeight=  result.Stand_Height__c.toString();
                //component.set("v.standDetail", result);// Adding values in Aura attribute variable.
                this.showSection(component);
            }
            component.set("v.Spinner", false);
        });
        $A.enqueueAction(action); 
    },
    fetchOpenSides: function (component) {
        component.set("v.Spinner", true);// Enable Defalut Spinner after a Sec delay.//BK-1762
        var action = component.get("c.getOpenSides"); //Calling Apex class controller 'getOpenSides' method.
        action.setCallback(this, function (response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS") {
                var opts = [];
                for (var i = 0; i < response.getReturnValue().length; i++) {
                    opts.push({
                        label: response.getReturnValue()[i].split('__$__')[1],
                        value: response.getReturnValue()[i].split('__$__')[0]
                    });
                }
                component.set("v.lstOpenSide", opts); // Adding values in Aura attribute variable.
            }
            component.set("v.Spinner", false);
        });
        $A.enqueueAction(action);
    },
    fetchUploadAttType: function (component) {
        var action = component.get("c.getStandDesignAttTypes"); //Calling Apex class controller 'getOpenSides' method.
        action.setCallback(this, function (response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS") {
                //console.log('fetchManuals=========='+JSON.stringify(response.getReturnValue()));
                //component.set("v.standDesignAttachments", response.getReturnValue());// Adding values in Aura attribute variable.
                component.set("v.standDesignAttachmentsList", response.getReturnValue()); // Adding values in Aura attribute variable.

            }
        });
        $A.enqueueAction(action);
    },
    // This Function is used to set maximum value in Stand/Rigging Height picklists
    Setmaxheight: function (component, componentName, maxvalue) {
        var opts = [];
        for (var i = 1; i <= maxvalue; i++) {
            opts.push({
                label: i,
                value: i
            });
        }
        component.find(componentName).set("v.options", opts);
    },
    SetDecimalVal: function (component, componentName) {
        var opts = [];
        for (var i = 0; i < 10; i++) {
            opts.push({
                label: '.' + i,
                value: '.' + i
            });
        }
        component.find(componentName).set("v.options", opts);
    },
    //This function is uses to show the current tab section
    showSection: function (component) {
        component.set("v.message", "");
        var checkManuals = component.get("v.checkManuals"); // Getting values from Aura attribute variable.
        var isDesign = component.get("v.isStandDesign"); // Getting values from Aura attribute variable.
        var isDetail = component.get("v.isStandDetail"); // Getting values from Aura attribute variable.
        var vStep1 = component.get("v.step1"); // Getting values from Aura attribute variable.
        var vStep3 = component.get("v.step3"); // Getting values from Aura attribute variable.
        var vStep4 = component.get("v.step4"); // Getting values from Aura attribute variable.
        $(".section").each(function () {
            var $this = $(this);
            var id = $this.attr("id");
            $('#' + id).hide();
        });
        if (!checkManuals && vStep1) {
            $('#divreadandagree').show();
        } else if (!isDetail) {
            $('#divfilldetails').show();
        } else if (!isDesign) {
            $('#divuploaddesign').show();
        } else {
            $('#divagreement').show();
        }
    },
    //Validate uploaded file(i.e Pdf)
    checkFile: function (component, inputFile) {
        var fileInput = component.find("inputFile").getElement();
        var file = fileInput.files[0];
        if (file.name.indexOf('pdf') > 0) {
            return true;
        } else {
            return false;
        }
    },
    MAX_FILE_SIZE: 4456448, //Max file size 4.25(4250000) MB  
    CHUNK_SIZE: 750000, //Chunk Max size 250Kb  
    //Method is used to upload the attchment file.
    uploadHelper: function (component, event, standType, inputId) {
        // start/show the loading spinner   
        // get the selected files using aura:id [return array of files]
        //var fileInput = component.find(inputId).get("v.files");
        //var file = fileInput[0];
        var fileInput = component.find("inputFile").getElement();
        var file = fileInput.files[0];
        var self = this;
        // check the selected file size, if select file size greter then MAX_FILE_SIZE,
        // then show a alert msg to user,hide the loading spinner and return from function  
        if (file.size > self.MAX_FILE_SIZE) {
            //alert('Alert : File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size);
            var filesize = (file.size * 0.00000095367432).toFixed(2);
            if (filesize == 4.25) {
                filesize = 4.26;
            }
            var msg = 'Alert : File size cannot exceed ' + (self.MAX_FILE_SIZE * 0.00000095367432).toFixed(2) + ' Mb.\n'; // + ' Selected file size: ' + filesize +' Mb';
            component.set("v.message", msg);
            // component.set("v.showLoadingSpinner", false);
            // component.set("v.fileName", 'Alert : File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size);
            return;
        }

        // create a FileReader object 
        var objFileReader = new FileReader();
        // set onload function of FileReader object   
        objFileReader.onload = $A.getCallback(function () {
            var fileContents = objFileReader.result;
            var base64 = 'base64,';
            var dataStart = fileContents.indexOf(base64) + base64.length;

            fileContents = fileContents.substring(dataStart);
            // call the uploadProcess method 
            self.uploadProcess(component, file, fileContents, standType);
        });

        objFileReader.readAsDataURL(file);
    },
    //Method is used the devide the file in a fixed size .
    uploadProcess: function (component, file, fileContents, standType) {
        // set a default size or startpostiton as 0 
        var startPosition = 0;
        // calculate the end size or endPostion using Math.min() function which is return the min. value   
        var endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);

        // start with the initial chunk, and set the attachId(last parameter)is null in begin
        this.uploadInChunk(component, file, fileContents, startPosition, endPosition, '', standType);
    },
    //Method is used to upload the attchment file in parts.
    uploadInChunk: function (component, file, fileContents, startPosition, endPosition, attachId, standType)
    {
        component.set("v.disableSpinner", true);
        var eventSettings = component.get("v.Event_Setting");
        var accountId = component.get("v.accountId"); // Getting values from Aura attribute variable.
        var standmap = component.get("v.exhibitorDtls"); 
        var mapid = component.get("v.mapid"); // Getting values from Aura attribute variable.
        var filetype = component.get("v.uploadfiletype"); // Getting values from Aura attribute variable.
        var exhibitorDtls = component.get("v.exhibitorDtls"); // Getting values from Aura attribute variable.
        //console.log('exhibitorDtls'+JSON.stringify(exhibitorDtls));
        var boothNumber;
        if(exhibitorDtls.Opp_Booth_Mapping__r )
        {
            boothNumber=exhibitorDtls.Opp_Booth_Mapping__r.Booth_Number__c
        }
        else{
            boothNumber='Agent Pavilion Space'; // [CCEN-430]
        }
        //console.log('boothNumber'+JSON.stringify(boothNumber));
        // call the apex method 'saveChunk'
        var getchunk = fileContents.substring(startPosition, endPosition);
        var  AgentID
        if(standmap.Agent_Contact__c)
        {AgentID = standmap.Agent_Contact__r.AccountId;}
        var action = component.get("c.saveChunk"); //Calling Apex class controller 'saveChunk' method
        action.setParams({
            sMapId: mapid,            
            accountId :accountId,
            fileName: file.name,
            base64Data: encodeURIComponent(getchunk),
            contentType: file.type,
            fileId: attachId,
            standType: standType,
            boothId: exhibitorDtls.Opp_Booth_Mapping__c,
            boothCode: boothNumber,
            uploadFileType: filetype,
            eventId:eventSettings.Event_Edition__c,
            agentId:AgentID
        });

        // set call back 
        action.setCallback(this, function (response) {
            // store the response / Attachment Id   
            attachId = response.getReturnValue();
            var state = response.getState();
            //Checking response status
            if (state === "SUCCESS") {
                // update the start position with end postion
                startPosition = endPosition;
                endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
                // check if the start postion is still less then end postion 
                // then call again 'uploadInChunk' method , 
                // else, diaply alert msg and hide the loading spinner
                if (startPosition < endPosition) {
                    this.uploadInChunk(component, file, fileContents, startPosition, endPosition, attachId, standType);
                } else {
                    //alert('Your file is uploaded successfully'+attachId);
                    // console.log(attachId);
                    $('#modalfiletype').hide();
                    this.fetchStandDetails(component);
                    this.fetchStandDesign(component);
                }
                // handel the response errors        
            } else if (state === "INCOMPLETE") {
                alert("From server: " + response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        component.set("v.disableSpinner", false);//BK-1762
        // enqueue the action
        $A.enqueueAction(action);
    },
    setUploadAttType: function (component) {
        var standDesignAttachments = component.get("v.standDesignAttachmentsList"); // Getting values from Aura attribute variable.
        if (standDesignAttachments) {
            var designtype = component.get("v.designtype");
            var tempstandDesignAttachments = [];
            for (var i = 0; i < standDesignAttachments.length; i++) {

                if (standDesignAttachments[i].Design_Category__c && standDesignAttachments[i].Design_Category__c.includes(designtype)) {
                    tempstandDesignAttachments.push(standDesignAttachments[i]);
                }
            }
            //console.log('tempstandDesignAttachments = '+tempstandDesignAttachments);
            component.set("v.standDesignAttachments", tempstandDesignAttachments);
        }
    },
    checkStandDesign: function (component, event) {
        var exhibitorDtls = component.get("v.exhibitorDtls"); // Getting values from Aura attribute variable.
        var action = component.get("c.getStandDesign"); //Calling Apex class controller 'getStandDesign' method
        action.setParams({
            boothId: exhibitorDtls.Opp_Booth_Mapping__c,
            accId: exhibitorDtls.Contact__r.AccountId
        });
        action.setCallback(this, function (response) {
            var state = response.getState(); //Checking response status
            var result = response.getReturnValue();
            console.log('fetchStandDesign-----------------'+JSON.stringify(response.getReturnValue()));
            if (state === "SUCCESS") 
            {
                var evntStng = component.get("v.Event_Setting");
                var uploadlimit = 10;
                if(evntStng && evntStng.Stand_Design_limit__c)
                {
                    uploadlimit = evntStng.Stand_Design_limit__c;
                }
                if(result)
                {
                    var standDesign = result.DesignAttachmentTypes__r;
                    var standDesignlength ;
                    if(standDesign){
                        standDesignlength = standDesign.length; 	
                    }else
                    {
                        standDesignlength = 0;
                    }
                    if (result.Stand_Type__c) {
                        if (result.Stand_Type__c == component.get("v.designtype")) {
                            //if(evntStng.Stand_Design_limit__c && evntStng.Stand_Design_limit__c > standDesignlength)
                            if( uploadlimit > standDesignlength)
                            {   component.set("v.message", "");
                                this.uploadHelper(component, event, component.get("v.designtype"), 'inputFile');
                            }else
                            {
                                component.set("v.message", "you have already reached maximum upload limit : "+uploadlimit);
                            }
                        } else {
                            component.set("v.message", "Data has been changed from background, please refresh this page to continue.");
                        }
                    } else {
                        this.uploadHelper(component, event, component.get("v.designtype"), 'inputFile');
                    }

                } else {
                    this.uploadHelper(component, event, component.get("v.designtype"), 'inputFile');
                }
            }
        });
        $A.enqueueAction(action);
    },
    //CCEN-335
    updateUsrManualAct: function (component, event,manualAction,indexno) {
        component.set("v.Spinner", true); //BK-1762
        var action = component.get("c.updateUserManualAction");
        action.setParams({
            userManualAction: manualAction
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if(manualAction.Is_Agree__c)
                {
                    component.get("v.reqManualslist")[indexno].Is_Agree__c = true;
                    $('#modalViewManualPdf').hide();
                }
                else if(manualAction.Is_Viewed__c)
                {
                    component.get("v.reqManualslist")[indexno].Is_Viewed__c = true;
                }
                component.set("v.reqManualslist", component.get("v.reqManualslist"));
                this.fetchManuals(component);
            } else {
                console.log("error");
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            component.set("v.Spinner", false);
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