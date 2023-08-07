({
	// getStandDesign: function(component, event, helper) {
    //     var action = component.get("c.getStandDesignCtr"); //Calling Apex class controller 'getStandDesignCtr' method
    //     var AccId1=component.get("v.AccountId");
    //     var BthID1=component.get("v.BoothID");
    //     console.log("AccountId---" +AccId1);
    //     console.log("BoothID---" +BthID1);
    //     action.setParams({
    //         sAccId: AccId1,
    //         sBthID:BthID1
    //     });
    //     action.setCallback(this, function(res) {
    //         var state = res.getState();
    //         if (state === "SUCCESS") {                
    //             component.set("v.StandDesign", res.getReturnValue());
    //             //console.log('getStandDesign==='+JSON.stringify(res.getReturnValue()));
    //         }
    //     });
    //     $A.enqueueAction(action);
    // },
    getEventSetting: function(component, event, helper) {
        var action = component.get("c.getEventDetails"); 
        var sEventId=component.get("v.EventEditionID");
        action.setParams({
            sEventId: sEventId
        });
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {                
                component.set("v.EventSetting", res.getReturnValue());
                //console.log('EventSetting==='+JSON.stringify(res.getReturnValue()));
            }
        });
        $A.enqueueAction(action);
    },
    getStandDetails: function(component, event, helper)
    {
        var boothContMapping=component.get("v.childsingleBooth[0]");
        var agntID; 
        if(boothContMapping.Agent_Contact__c)
        {
            agntID = boothContMapping.Agent_Contact__r.AccountId;
        }
        var AccId1=component.get("v.AccountId");
        var BthID1=component.get("v.BoothID");
        var action = component.get("c.getStandDetailsCtr"); //Calling Apex class controller 'getStandDetailsCtr' method
        action.setParams({
            sAccId: AccId1,
            sBthID:BthID1,
            sEventId: boothContMapping.Event_Edition__c,
            agentId:agntID
        });
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS")
            {                
                //console.log('getStandDetail==='+JSON.stringify(res.getReturnValue()));
                component.set("v.StandDetail", res.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
   rejectDesign: function(component , event , designAttchmntId)
   {
        var AccId1=component.get("v.AccountId");
        var BthID1=component.get("v.BoothID");
        var boothContMapping=component.get("v.childsingleBooth[0]");
        var agntID; 
        if(boothContMapping.Agent_Contact__c)
        {
            agntID = boothContMapping.Agent_Contact__r.AccountId;
        }
       var action = component.get("c.designRejected"); //Calling controller Apex class's  'GetContactsCtr' method
       action.setParams({
           attchmntId: designAttchmntId,
           sBthID:BthID1,
           sAccId:AccId1,
           sEventId:boothContMapping.Event_Edition__c,
           agentId:agntID
        });
      action.setCallback(this, function(res) {
              console.log('test',action);
             console.log(res.getState());
            var state = res.getState();
           
            if (state === "SUCCESS")
            {         
               console.log('SUCCESS' ,JSON.stringify(res.getReturnValue()));
             	  component.set("v.StandDesign", res.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	}  ,       
    getStandDesignClone: function(component, event, helper) {
        
        var AccId1=component.get("v.AccountId");
        var BthID1=component.get("v.BoothID");
        var boothContMapping=component.get("v.childsingleBooth[0]");
        var agntID; 
        if(boothContMapping.Agent_Contact__c)
        {
            agntID = boothContMapping.Agent_Contact__r.AccountId;
        }
      
        if(AccId1){
            var action = component.get("c.getStandDesignCtr"); //Calling Apex class controller 'getStandDesignCtr' method
            console.log('getStandDesignClone',action);
            action.setParams({
            sAccId: AccId1,
            sBthID:BthID1,
            sEventId: boothContMapping.Event_Edition__c,
            agentId:agntID
        });
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") { 
               // console.log('rslt', JSON.stringify(res.getReturnValue()));
                component.set("v.StandDesign", res.getReturnValue());
                var Results = res.getReturnValue();
                //console.log('StandDesign =='+JSON.stringify(res.getReturnValue()));
                if(Results)
                {
                    if(Results.length > 0){
                    //console.log(Results.Stand_Type__c);
                        if(Results[0].Stand_Type__c){
                            //console.log('=========================>>'+Results[0].Stand_Type__c);
                            component.set("v.designtype",Results[0].Stand_Type__c);
                            component.set("v.hasStand_Type",true); 
                         }else{
                            component.set("v.hasStand_Type",false);
                            component.set("v.designtype",'');
                         }
                        
                        //this.getStandDesignAttachment(component, event, helper);  
                        //handler.setStandDesignAttachment(component,Results);   
                        this.setStandDesignAttachment(component,Results);   //BK-15225             
                        }else{
                        component.set("v.hasStand_Type",false);
                        component.set("v.NoAttachment",true);
                        component.set("v.designtype",'');
                    }

                }
                //console.log('StandDesignStatus++++++++++++++++++++++++++++++++++++++++++++++'+JSON.stringify(res.getReturnValue()));
            }else{
                component.set("v.hasStand_Type",false);
                component.set("v.NoAttachment",true);
                component.set("v.designtype",'');
            }        
        });
        $A.enqueueAction(action);
        }        
    },

    setStandDesignAttachment: function(component,Results ) { 
        var count =0;
        if(Results && Results.length >0)
        {
            var DesignAttachmentTypes = Results[0].DesignAttachmentTypes__r;
            if(DesignAttachmentTypes){
            for(var j=0;j<DesignAttachmentTypes.length;j++){
                if(DesignAttachmentTypes[j].IsRejected__c == false)
                {
                    count = count+1;
                }
            }
        }
            if(count > 0)
            {
                component.set("v.NoAttachment",false);
            }
            else
            {
                component.set("v.NoAttachment",true);
            }      
        }

    },
    // getStandDesignAttachment: function(component, event, helper) {
    //     var action = component.get("c.getStandDesignCtr"); //Calling Apex class controller 'getStandDesignCtr' method
    //     var AccId1=component.get("v.AccountId");
    //     var BthID1=component.get("v.BoothID");
    //     //console.log("AccountId---" +AccId1);
    //     //console.log("BoothID---" +BthID1);
    //     action.setParams({
    //         sAccId: AccId1,
    //         sBthID:BthID1
    //     });
    //     action.setCallback(this, function(res) {
    //         var state = res.getState();
    //         if (state === "SUCCESS") {       
    //             var Results = res.getReturnValue();
    //             var noAttachReject;
    //             var count =0;
    //             //console.log(JSON.stringify(res.getReturnValue()));
                
    //             if(Results.length >0){
    //                 var DesignAttachmentTypes = Results[0].DesignAttachmentTypes__r;   
    //                 for(var j=0;j<DesignAttachmentTypes.length;j++){
    //                     if(DesignAttachmentTypes[j].IsRejected__c == false)
    //                     {
    //                         count = count+1;
    //                     }
    //                 }
    //                 if(count > 0)
    //                 {
    //                     component.set("v.NoAttachment",false);
    //                 }
    //                 else
    //                 {
    //                     component.set("v.NoAttachment",true);
    //                 }      
    //             }
    //         }
    //     });
    //     $A.enqueueAction(action);
    // },

    fetchUploadAttType : function(component) {
        var action = component.get("c.getStandDesignAttTypes");//Calling Apex class controller 'getOpenSides' method.
            action.setCallback(this, function(response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS") 
            {
                component.set("v.standDesignAttachmentsList", response.getReturnValue());// Adding values in Aura attribute variable.
            }
        });
        $A.enqueueAction(action);
    },
    fetchAttachmentbody : function(component,attachment,maxIndex,minIndex) {

		var attachmentid = [];
		//console.log('fetchAttachmentbody');
		for(var i = minIndex ; i<maxIndex ;i++){
			attachmentid.push(attachment[i]);
		}
        //console.log('maxIndex = '+maxIndex+' || minIndex = '+minIndex + 'attachmentid = '+attachmentid);
        
        var action = component.get("c.getAttachmentbody");//Calling Apex class controller 'getAttachmentbody' method.
        var resultval;   
        action.setParams({
            attachmentid :attachmentid

        });
            action.setCallback(this, function(response) { 
                 
            var state = response.getState(); //Checking response status 
            if (component.isValid() && state === "SUCCESS") 
            {
                try{ 
				
                resultval = response.getReturnValue();
                //console.log(JSON.stringify(response.getReturnValue()));
				var attachmentBody = component.get("v.attachmentBody");
				 if(resultval && resultval.length>0 )   
					{	//console.log('resultval');
                        if(attachmentBody)
                        { //console.log('attachmentBody');
                            for(var i=0 ; i<resultval.length ;i++)
                            {
                                attachmentBody.push({attName: resultval[i].attName,attEncodedBody:resultval[i].attEncodedBody}) ;                                
                            }                        
                        }
                        else
                        {   //console.log('attachmentBody = 1');
                            var body = []; 
                            body =  resultval;
                            attachmentBody = body;
                        }
                        component.set("v.attachmentBody",attachmentBody);   
					}
				
				minIndex = maxIndex;
                maxIndex = Math.min(attachment.length, minIndex + 3);
				//console.log('maxIndex = '+maxIndex+' || minIndex = '+minIndex);
				if (maxIndex > minIndex) 
				{
                    //console.log('fetchAttachmentbody');
                    this.fetchAttachmentbody(component, attachment, maxIndex, minIndex);
                } 
				else
				{
					//console.log('createZipTodownload');
				  this.createZipTodownload(component,component.get("v.attachmentBody"));
                }
                }catch(err) {console.log('err : '+err );}

            }
			else
			{
                console.log('Some Error Occured!');
            }

        });
        $A.enqueueAction(action);
    },
    getAttachments : function(component,AttchmentIds) { 
        var  maxIndex = maxIndex = Math.min(AttchmentIds.length,3);
        var minIndex = 0;
        //console.log('maxIndex = '+maxIndex+' || minIndex = '+minIndex);
        component.set("v.attachmentBody",null);
        this.fetchAttachmentbody(component,AttchmentIds,maxIndex,minIndex);
    },
    saveFile : function(blob, filename) {     // to download Zip file   
        if (window.navigator.msSaveOrOpenBlob) {
            window.navigator.msSaveOrOpenBlob(blob, filename);
        } 
        else 
        {
            const a = document.createElement('a');
            document.body.appendChild(a);
            const url = window.URL.createObjectURL(blob);
            a.href = url;
            a.target = '_blank';
            a.download = filename;
            a.click();
            setTimeout(() => {
                window.URL.revokeObjectURL(url);
                document.body.removeChild(a);
            }, 0);
        }
    },
    createZipTodownload : function(component,Attachments) { // to create Zip using js.lib
        var zip = new JSZip();
        var files = Attachments; 
        var self = this;
        for (var i = 0; i < files.length; i++)  
        {
            var f = files[i];
            //console.log(f.attName);   
            zip.file(f.attName, f.attEncodedBody,{base64: true});
        } 
        //console.log('Start');
        zip.generateAsync({type:"blob"}).then(function (content) {
            //console.log('Stop');
            try {
                self.saveFile(content,'standDesign.zip');
                component.set("v.NoAttachment",false);
               } catch (e) {
                //console.log(e);
                component.set("v.NoAttachment",false);
               }                       
        }); 
      
    },
    DesignStatusEmailConList: function(component, event, helper) {
        var action = component.get("c.returnStandDesignStatusData"); //Calling Apex class controller 'ReturnStandDesignStatusData' method
        var AccId=component.get("v.AccountId");
        var Status=component.find("mySelect").get("v.value");
        var EventId=component.get("v.EventEditionID");
        var BoothID=component.get("v.BoothID");
        var childsingleBooth = component.get("v.childsingleBooth[0]");
        var agntID; 
        if(childsingleBooth.Agent_Contact__c)
        {
            agntID = childsingleBooth.Agent_Contact__r.AccountId;
        }
        action.setParams({
            sAccIdDes: AccId,
            sBoothStatusDes:Status,
            boothId1:BoothID,
            eEId1:EventId,
            agentId:agntID

        });
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") 
            {  
                var ReturnWrappr=res.getReturnValue();              
                component.set("v.EmailTempName1",ReturnWrappr.emailTempName);
                component.set("v.EmailContent1",ReturnWrappr.emailContent);
                component.set("v.ccStatusSubject",ReturnWrappr.emailSubject);
                //var objEditor = component.get("v.objEditor");
                //objEditor("",ReturnWrappr.EmailContent,"");
                component.set("v.BoothContractorMapping",ReturnWrappr.BoothConMapWrpr);
            }
        }); 
        $A.enqueueAction(action);
    }, 
    SendEmailAndUpdateStatus: function(component, event, helper) {
        var action = component.get("c.updateRecordAndSendEmail"); //Calling Apex class controller 'UpdateRecordAndSendEmail' method
        var AccId=component.get("v.AccountId");
        //var objEditor = component.get("v.objEditor");
        //var emailContent = objEditor("editor1","","getData");
        var mailContent = component.find("contentEditor").get("v.value");
        var Status=component.find("mySelect").get("v.value");
        var EventId=component.get("v.EventEditionID");
        var BoothID=component.get("v.BoothID");
        var childsingleBooth = component.get("v.childsingleBooth[0]");
        var ccEmail = component.get("v.ccEmail");
        var mailSubject = component.get("v.ccStatusSubject");
        var mapId = childsingleBooth.Id;
        var agntID; 
        console.log('Status : '+Status);
        console.log('Content : '+mailContent);
        if(childsingleBooth.Agent_Contact__c)
        {
            agntID = childsingleBooth.Agent_Contact__r.AccountId;
        }        
        action.setParams({
            sAccIdDes: AccId,
            sBoothStatusDes:Status, 
            boothId1:BoothID,
            eEId1:EventId,
            sMapId:mapId,
            emailContent:mailContent,
            emailSubject:mailSubject,
            mailInCC:ccEmail,
            agentId:agntID
        });
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {  
                
                var EmailSentStatus=res.getReturnValue();
                this.getStandDesignClone(component);
                console.log('*** '+EmailSentStatus);
            }
        });
        $A.enqueueAction(action); 
    },
    getBaseUrl : function (component, event, helper) {
        var action = component.get('c.getBaseUrl')
        action.setCallback(this, function (response) {
            var state = response.getState()
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue()
                component.set('v.sfdcBaseurl', result)
            }
        })
        $A.enqueueAction(action)
    },
    fetchPicklistValues : function (component, objName, field,default_label,default_value,hasAuraID) {
        var action = component.get('c.getPicklistValues');
        action.setParams({
            objApi:objName,
            fieldName:field
        });
        action.setCallback(this, function (res) {
            var state = res.getState()
            var result=res.getReturnValue();
            if (component.isValid() && state === 'SUCCESS') {
                var opts=[];      	
                opts.push({label: default_label, value:default_value});
				for(var i=0;i< result.length;i++){
					opts.push({label: result[i].split('__$__')[0], value: result[i].split('__$__')[1]});
                }
                if(hasAuraID){
                    component.find('Stand_Type').set("v.options",opts); // Adding values in Aura attribute variable.
                }
                else{
                component.set("v.StatusList", opts);// Adding values in Aura attribute variable.
                }
            }
        })
        $A.enqueueAction(action)
    },
    downloadfile : function (component, event, helper){
        if(event.target.getAttribute("data-id"))
        {
              var attachmentId = event.target.getAttribute("data-id");
        }
      	else
        {
             var attachmentId =event.getSource().get("v.value");
        }
        var sfdcBaseUrl  = component.get('v.sfdcBaseurl');
        //var downloadUrl =  sfdcBaseUrl + '/servlet/servlet.FileDownload?file='+ attachmentId; 
        var downloadUrl =  sfdcBaseUrl + '/sfc/servlet.shepherd/document/download/'+ attachmentId +'?operationContext=s1'; 
        window.open(downloadUrl,'_blank');//to open the link in new tab
        /*var anchor = document.createElement('a');
        anchor.href = sfdcBaseUrl+'/servlet/servlet.FileDownload?file='+ attachmentId;
        anchor.download = true;
        anchor.click();*/
    },
    ReInitialize: function(component, event, helper) {
        component.set("v.AccountId",'');
        component.set("v.StandDesign",'');
        component.set("v.BoothContractorMapping",'');
        //component.set("v.uploadAllowed",false);
        component.set("v.EmailTempName1",'');
        component.set("v.selectedValue",'All'); 
        component.set("v.EmailContent1",'');
        component.set("v.BoothID",'');
        //var objEditor = component.get("v.objEditor");
        //objEditor("","","");
    },


    // attchment upload -->

    //reset all upload model
    ReInitializeUploadModel: function(component) {
        
        component.set("v.message",'');
        component.set("v.uploadfiletype",'');
        //component.set("v.designtype",'');
        //component.find("inputFile").getElement().value= '';
        //component.find("uploadFileInput").getElement().value= '';
        var lng = component.get("v.standDesignAttachments").length;
        for(var i=0 ;i<lng;i++){
            document.getElementById('standDesign'+i).checked = false;
        }

    },
    MAX_FILE_SIZE:  4456448, //Max file size 4.25 MB (4250000) 
    CHUNK_SIZE: 750000,      //Chunk Max size 750Kb 
    //Validate uploaded file(i.e Pdf)
    checkFileLimit : function(component,standDesign) {

        var evntStng = component.get("v.EventSetting");
        //var standDesign = component.get("v.StandDesign");
        var standDesignAtt;
        if(standDesign && standDesign.length>0)
        {
            standDesignAtt = standDesign[0].DesignAttachmentTypes__r; 
        }
        var msg;
        var standDesignlength = 0;
        if(standDesignAtt && standDesignAtt.length >0)
        {
            for(var i =0;i<standDesignAtt.length;i++ )
            {
               if(!standDesignAtt[i].IsRejected__c)
               {
                standDesignlength++;
               } 
            }
        }
        var uploadlimit = 10;
        // if(evntStng.Stand_Design_limit__c)
        // {
        //     uploadlimit = evntStng.Stand_Design_limit__c;
        // } 
        if(evntStng && evntStng.Stand_Design_limit__c)
        {
            uploadlimit = evntStng.Stand_Design_limit__c;
        }    
        if(uploadlimit <= standDesignlength)
        {
            msg = "you have already reached maximum upload limit : "+uploadlimit;
            return msg;
        }

    },
    checkFile : function(component,inputFile) 
    {
        var fileInput = component.find("inputFile").getElement();
        var file = fileInput.files[0];
        var self = this;
        // var evntStng = component.get("v.EventSetting");
        // var standDesign = component.get("v.StandDesign");
        // var standDesignAtt;
        // if(standDesign && standDesign.length>0)
        // {
        //     standDesignAtt = standDesign[0].DesignAttachmentTypes__r;
        // }
         var msg;
        // var standDesignlength = 0;
        // if(standDesignAtt && standDesignAtt.length >0)
        // {
        //     for(var i =0;i<standDesignAtt.length;i++ )
        //     {
        //        if(!standDesignAtt[i].IsRejected__c)
        //        {
        //         standDesignlength++;
        //        } 
        //     }
        // }
        // var uploadlimit = 10;
        // if(evntStng.Stand_Design_limit__c)
        // {
        //     uploadlimit = evntStng.Stand_Design_limit__c;
        // }    
        // if(uploadlimit > standDesignlength)
        // {
       // var msg = this.checkFileLimit(component,component.get("v.StandDesign"));
        //if(!msg)
       // {
            if(file.name.indexOf('pdf')>0)
            {
                if (file.size > self.MAX_FILE_SIZE) {
                    //component.set("v.message",'Alert : File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size);
                // component.set("v.showLoadingSpinner", false);
                var filesize = (file.size*0.00000095367432).toFixed(2);
                if(filesize == 4.25){
                    filesize = 4.26 ;
                }
                msg = 'Alert : File size cannot exceed ' + (self.MAX_FILE_SIZE*0.00000095367432).toFixed(2)+ ' Mb.\n' ;// + ' Selected file size: ' +filesize +' Mb';
                    return msg;
                }
                return msg ;
            }
            else{
                msg = 'Please upload pdf file.'; 
                return msg;
            }
        //}else
       // {
        //  msg = "you have already reached maximum upload limit : "+uploadlimit;
         //   return msg;
        //}    
    },

    //Method is used to upload the attchment file.
    uploadHelper: function(component, event,standType) {
        // start/show the loading spinner   
        // get the selected files using aura:id [return array of files]
        //var file = fileInput[0];
        var fileInput = component.find("inputFile").getElement();
    	var file = fileInput.files[0];
        var self = this;
        // check the selected file size, if select file size greter then MAX_FILE_SIZE,
        // then show a alert msg to user,hide the loading spinner and return from function  
        if (file.size > self.MAX_FILE_SIZE) {
            component.set("v.message",'Alert : File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size);
           // component.set("v.showLoadingSpinner", false);
            return;
        }
        component.set("v.uploadAllowed",true);
        // create a FileReader object 
        var objFileReader = new FileReader();
        // set onload function of FileReader object   
        objFileReader.onload = $A.getCallback(function() {
            var fileContents = objFileReader.result;
            var base64 = 'base64,';
            var dataStart = fileContents.indexOf(base64) + base64.length;
 
            fileContents = fileContents.substring(dataStart);
            // call the uploadProcess method 
            self.uploadProcess(component, file, fileContents,standType);
        });
 
        objFileReader.readAsDataURL(file);
    },
    //Method is used the devide the file in a fixed size .
    uploadProcess: function(component, file, fileContents,standType) {
        // set a default size or startpostiton as 0 
        var startPosition = 0;
        // calculate the end size or endPostion using Math.min() function which is return the min. value   
        var endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
 
        // start with the initial chunk, and set the attachId(last parameter)is null in begin
        this.uploadInChunk(component, file, fileContents, startPosition, endPosition, '',standType);
    },

    //Aish

    

    uploadFiles: function(component, standType) {
        var childsingleBooth = component.get("v.childsingleBooth[0]");// Getting values from Aura attribute variable.
        var  agentId;
        if(childsingleBooth.Agent_Contact__c)
        {
            agentId = childsingleBooth.Agent_Contact__r.AccountId;
        }
        //console.log('agentId ==== '+agentId);
        var sEventId=component.get("v.EventEditionID");
        var filetype = component.get("v.uploadfiletype");// Getting values from Aura attribute variable.
        var BoothID = component.get("v.BoothID"); // Getting values from Aura attribute variable.
        var accountid = component.get("v.AccountId"); // Getting values from Aura attribute variable.
        //console.log('accountid ='+accountid);

        // call the apex method 'saveStandDesignFiles'
        //alert(filetype);
        var action = component.get("c.saveStandDesignFiles");  //Calling Apex class controller 'saveStandDesignFiles' method
        action.setParams({
			sMapId: childsingleBooth.Id,
            standType:standType,
            boothId:BoothID,
            uploadFileType:filetype,
            accountid : accountid,
            eventId:sEventId,
            agentId:agentId
        });
 
        // set call back 
        action.setCallback(this, function(response) {
            // store the response / Attachment Id   
            let responseValue  = response.getReturnValue();
            var state = response.getState();
            //Checking response status
            if (state === "SUCCESS")
            {
                var recordList = responseValue.split('#');
                component.set('v.standDesignId',recordList[0]);
                component.set('v.fileTitle',recordList[1]);
				console.log(responseValue);
                // handel the response errors        
            } else if (state === "INCOMPLETE") {
                //alert("From server: " + response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.log(errors);
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message : " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        // enqueue the action
        $A.enqueueAction(action);
    },

    /*commented BK-10223
     //Method is used to upload the attchment file in parts.
    uploadInChunk: function(component, file, fileContents, startPosition, endPosition, attachId,standType) {
        var childsingleBooth = component.get("v.childsingleBooth[0]");// Getting values from Aura attribute variable.
        var  agentId;
        if(childsingleBooth.Agent_Contact__c)
        {
            agentId = childsingleBooth.Agent_Contact__r.AccountId;
        }
        //console.log('agentId ==== '+agentId);
        var sEventId=component.get("v.EventEditionID");
        var filetype = component.get("v.uploadfiletype");// Getting values from Aura attribute variable.
        var BoothID = component.get("v.BoothID"); // Getting values from Aura attribute variable.
        var accountid = component.get("v.AccountId"); // Getting values from Aura attribute variable.
        //console.log('accountid ='+accountid);

        // call the apex method 'saveChunk'
        var getchunk = fileContents.substring(startPosition, endPosition);
        var action = component.get("c.saveChunk");  //Calling Apex class controller 'saveChunk' method
        action.setParams({
            sMapId: childsingleBooth.Id,            
            base64Data: encodeURIComponent(getchunk),
            contentType: file.type,
            fileId: attachId,
            standType:standType,
            boothId:BoothID,
            uploadFileType:filetype,
            accountid : accountid,
            eventId:sEventId,
            agentId:agentId
        });
 
        // set call back 
        action.setCallback(this, function(response) {
            // store the response / Attachment Id   
            attachId = response.getReturnValue();
            var state = response.getState();
            //Checking response status
            if (state === "SUCCESS")
            {
                // update the start position with end postion
                startPosition = endPosition;
                endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
                // check if the start postion is still less then end postion 
                // then call again 'uploadInChunk' method , 
                // else, diaply alert msg and hide the loading spinner
                if (startPosition < endPosition) {
                    this.uploadInChunk(component, file, fileContents, startPosition, endPosition, attachId,standType);
                } else {
                    //alert('Your file is uploaded successfully'+attachId);
                    //console.log('attachId = '+attachId);
                    this.getStandDesignClone(component);
                    //this.fetchUploadAttType(component); 
                    this.ReInitializeUploadModel(component);
                     $('#UploadArea').hide();
                    
                }
                // handel the response errors        
            } else if (state === "INCOMPLETE") {
                alert("From server: " + response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message : " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        // enqueue the action
        $A.enqueueAction(action);
    }, */

    setUploadAttType : function(component) { 
        var standDesignAttachments = component.get("v.standDesignAttachmentsList");// Getting values from Aura attribute variable.
        if(standDesignAttachments.length>0){
           var designtype =  component.get("v.designtype");
           //console.log('designtype============================'+designtype);
           var tempstandDesignAttachments = []; 
            for(var i= 0; i<standDesignAttachments.length ; i++){
                
                if( standDesignAttachments[i].Design_Category__c && standDesignAttachments[i].Design_Category__c.includes(designtype)){
                    tempstandDesignAttachments.push(standDesignAttachments[i]); 
                }
            }
              //console.log('tempstandDesignAttachments = '+tempstandDesignAttachments);
             component.set("v.standDesignAttachments",tempstandDesignAttachments);
        }
    }, 
    checkStandDesign : function(component,event) {
        var AccId1=component.get("v.AccountId");
        var BthID1=component.get("v.BoothID");
        var boothContMapping=component.get("v.childsingleBooth[0]");
        var agntID; 
        if(boothContMapping.Agent_Contact__c)
        {
            agntID = boothContMapping.Agent_Contact__r.AccountId;
        }
        var action = component.get("c.getStandDesignCtr"); //Calling Apex class controller 'getStandDesignCtr' method
        action.setParams({
        sAccId: AccId1,
        sBthID:BthID1,
        sEventId: boothContMapping.Event_Edition__c,
        agentId:agntID
        });
        action.setCallback(this, function(response) {
            var state = response.getState(); //Checking response status
            //console.log('fetchStandDesign-----------------'+JSON.stringify(response.getReturnValue()));
            var designType=component.get("v.designtype");
            //console.log('designType=='+designType);
            if (state === "SUCCESS") {
                var result=response.getReturnValue();

                if((result.length==0 || result[0].Stand_Type__c == designType ))
                {
                    var msg = this.checkFileLimit(component,result);
                    if(!msg)
                    {
                        component.set("v.message","");
                        this.uploadHelper(component, event,designType);
                    }else
                    {
                        component.set("v.message",msg);  
                    }
                }
                else
                { 
                    component.set("v.message","Data has been changed from background, please refresh this page to continue.");
                    component.set("v.isSpinner", false);// Adding values in Aura attribute variable.
                }
            }
            else{
                this.uploadHelper(component, event,designType);
            }
        });
        $A.enqueueAction(action); 
    },
    // rejectDesign: function(component, stdDesignAttID) {
    //     var action = component.get("c.rejectDesignAttachmentCtr"); //Calling Apex class controller 'rejectDesignAttachmentCtr' method
    //     action.setParams({ stdDesignAttID:stdDesignAttID});
    //     console.log("stdDesignAttID---" +stdDesignAttID);
    //     action.setCallback(this, function(res) {
    //         var state = res.getState();
    //         if (state === "SUCCESS") {                
    //             this.getStandDesignClone(component);
    //         }
    //     });
    //     $A.enqueueAction(action);
    // },
      
})