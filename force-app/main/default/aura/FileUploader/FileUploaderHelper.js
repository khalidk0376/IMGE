({
    MAX_FILE_SIZE: 4500000, //Max file size 4.5 MB 
    CHUNK_SIZE: 750000,      //Chunk Max size 750Kb 
    
    uploadHelper: function(component, event) {
        // start/show the loading spinner   
        component.set("v.showLoadingSpinner", true);
        // get the selected files using aura:id [return array of files]
        var fileInput = component.find("fileId").get("v.files");
        // get the first file using array index[0]  
        var file = fileInput[0];
        var self = this;
        // check the selected file size, if select file size greter then MAX_FILE_SIZE,
        // then show a alert msg to user,hide the loading spinner and return from function  
        if (file.size > self.MAX_FILE_SIZE) {
            component.set("v.showLoadingSpinner", false);
            component.set("v.fileName", 'Alert : File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size);
            return;
        }
 
        // create a FileReader object 
        var objFileReader = new FileReader();
        // set onload function of FileReader object   
        objFileReader.onload = $A.getCallback(function() {
            var fileContents = objFileReader.result;
            var base64 = 'base64,';
            var dataStart = fileContents.indexOf(base64) + base64.length;
 
            fileContents = fileContents.substring(dataStart);
            // call the uploadProcess method 
            self.uploadProcess(component, file, fileContents);
        });
 
        objFileReader.readAsDataURL(file);
    },
    uploadProcess: function(component, file, fileContents) {
        // set a default size or startpostiton as 0 
        var startPosition = 0;
        // calculate the end size or endPostion using Math.min() function which is return the min. value   
        var endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
 		
        // start with the initial chunk, and set the attachId(last parameter)is null in begin
        this.uploadInChunk(component, file, fileContents, startPosition, endPosition, '');
    	
    },
 
    uploadInChunk: function(component, file, fileContents, startPosition, endPosition, attachId) {
        // call the apex method 'saveChunk'
        
        var getchunk = fileContents.substring(startPosition, endPosition);
        var action = component.get("c.saveChunk");
        //var fileDescrption = component.get("v.questnQuestnnaireId")+'~'+component.get("v.contactId")+'~'+component.get("v.formId");
        action.setParams({
            questionId: component.get("v.questionId"),
            questionerId:component.get("v.questionerId"),
            accountId:component.get("v.AccountId"),
            fileName: file.name,
            base64Data: encodeURIComponent(getchunk),
            contentType: file.type,
            fileId: attachId,
            fileDescription: 'fileDescrption'           
        });
 
        // set call back 
        action.setCallback(this, function(response) {
            // store the response / Attachment Id   
            attachId = response.getReturnValue();
            var state = response.getState();
            if (state === "SUCCESS") {
                // update the start position with end postion
                startPosition = endPosition;
                endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
                // check if the start postion is still less then end postion 
                // then call again 'uploadInChunk' method , 
                // else, diaply alert msg and hide the loading spinner
                if (startPosition < endPosition) {
                    this.uploadInChunk(component, file, fileContents, startPosition, endPosition, attachId);
                } else {
                    this.showToast(component,'SUCCESS : ','success','Your file is uploaded succesfully');
                    this.fetchAttchments(component); 
                 //Added regarding ticket [CCEN-679]. 
                    var questionId  =  component.get('v.questionId');
                    //var required  =  component.get('v.required');
                    var uploadvalidmap  =  component.get('v.Uploadvalidmap');                                                         
                    uploadvalidmap.set(questionId,true);
                    component.set('v.Uploadvalidmap',uploadvalidmap);
                    //var dcm = document.getElementById(questionId);
                    if(document.getElementById(questionId))
                    {
                        document.getElementById(questionId).style.display = "none";
                    }
                    component.set("v.showLoadingSpinner", false);
                }
                // handel the response errors        
            } else if (state === "INCOMPLETE") {
                this.showToast(component, "From server: " + response.getReturnValue(),'Alert!','Alert');
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        this.showToast(component, event,errors[0].message,'Alert!','Alert');
                    }
                } 
            }
        });
        // enqueue the action
        $A.enqueueAction(action);
    },
    downloadfile : function (component, event, helper){   
        var attachmentId = event.target.getAttribute("data-id");
        var sfdcBaseUrl  = component.get('v.sfdcBaseurl');
        var downloadUrl =  '/servlet/servlet.FileDownload?file='+ attachmentId;  
        window.open(downloadUrl,'_blank');
    },    
    showToast: function(component,title,type, message) {
        var toastEvent = $A.get("e.force:showToast"); 
        if(toastEvent!=undefined){
            toastEvent.setParams({
                title: title,
                message: message,
                duration: '5000',
                type: type,
                mode: 'dismissible'
            });
            toastEvent.fire();
        }
        else{
            component.set("v.msgbody",message);
            component.set("v.msgtype",type);
            window.setTimeout($A.getCallback(function() {
                component.set("v.msgbody",'');
                component.set("v.msgtype",'');
            }), 5000);
        }
    },
    
    fetchAttchments : function(component) {
		//var sEventCode = component.get("v.eventcode");//Getting values from Aura attribute variable.
        var action = component.get("c.getAttcahments");//Calling Apex class controller 'getEventDetails' method.
        console.log('Att.....');
        action.setParams({
            questionId: component.get("v.questionId"),
            questionerId:component.get("v.questionerId"),
            accountId:component.get("v.AccountId"),
        });
        action.setCallback(this, function(response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS") 
            {
                //console.log('fetchEventDetails'+JSON.stringify(response.getReturnValue()));
                var result = response.getReturnValue();
                component.set("v.Attchments", response.getReturnValue());// Adding values in Aura attribute variable.

                var questionId  =  component.get('v.questionId');
                var required  =  component.get('v.required');
                var uploadvalidmap  =  component.get('v.Uploadvalidmap');
                var valid = false;
                if(result)
                {
                    if(result.length>0)
                    {
                        valid = true;
                    }  
                }
                if(required == false)
                {
                    valid = true;
                }
                uploadvalidmap.set(questionId,valid);
                component.set('v.Uploadvalidmap',uploadvalidmap);
            }
        });
        $A.enqueueAction(action); 
	},

})