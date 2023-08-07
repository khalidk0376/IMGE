({
    fetchEventDetails: function (component) {

        var sEventCode = component.get("v.eventcode"); // Getting values from Aura attribute variable.
        //console.log('sEventCode>>>>>'+sEventCode);
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
            }
        });
        $A.enqueueAction(action);
        /**/
    },
    getBaseUrl: function (component, event) {
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
    fetchExistingAttach: function (component) {
        //console.log('fetchExistingAttach'+component.get("v.parentId"));
        var action = component.get("c.fetchExistingAttachment"); //Calling Apex class controller 'getEventDetails' method 
        action.setParams({
            parentId: component.get("v.parentId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS") {
                //console.log('successfully fetched attch');  
                      
                if (!$A.util.isEmpty(response.getReturnValue())) {
                    component.set("v.existingAttach", response.getReturnValue());
                    component.set("v.showUploadedName", true); // boolean condition
                    component.set("v.attachmentId", response.getReturnValue().Id);
                    component.set("v.uploadedFileName", response.getReturnValue().Title);
                    //component.set("v.uploadedFileName", response.getReturnValue().Name);
                    //showUploadedName  uploadedFileName
                    //console.log(' returned existingAttach-'+ JSON.stringify( response.getReturnValue()));
                    //console.log('name-'+response.getReturnValue().Name +' ,showUploadedName-'+component.get("v.showUploadedName"));
                }
                else{
                    component.set("v.uploadedFileName", '');
                    component.set("v.attachmentId", '');
                    component.set("v.showUploadedName", false);
                    component.set("v.existingAttach", '');
                }

            }
        });
        $A.enqueueAction(action);
    },
    // fetch param from url 
    getURLParameter: function (param) {
        var result = decodeURIComponent((new RegExp('[?|&]' + param + '=' + '([^&;]+?)(&|#|;|$)').exec(location.search) || [, ""])[1].replace(/\+/g, '%20')) || null;
        //console.log('Param ' + param + ' from URL = ' + result);
        return result;
    },
    //Validate uploaded file extensions.
    checkFile: function (component, inputFile) {
        var fileInput = component.find("inputFile").getElement();
        var file = fileInput.files[0];
        if ((file.name.indexOf('pdf') > 0) || (file.name.indexOf('jpg') > 0) || (file.name.indexOf('jpeg') > 0) || (file.name.indexOf('eps') > 0) || (file.name.indexOf('ai') > 0) || (file.name.indexOf('PDF') > 0) || (file.name.indexOf('JPG') > 0) || (file.name.indexOf('JPEG') > 0) || (file.name.indexOf('EPS') > 0) || (file.name.indexOf('AI') > 0)) {
            return true;
        } else {
            return false;
        }
    },
    // MAX_FILE_SIZE: 5000000, //Max file size 5 MB
    MAX_FILE_SIZE: 4456448, //Max file size 4.25 MB (4250000) 
    CHUNK_SIZE: 750000, //Chunk Max size 750Kb 

    //Method is used to upload the attchment file.
    uploadHelper: function (component, inputId) {
        // start/show the loading spinner   
        // get the selected files using aura:id [return array of files]
        var fileInput = component.find("inputFile").getElement();
        var file = fileInput.files[0];
        //console.log('size of file -' + file.size);

        var self = this;
        // check the selected file size, if select file size greter then MAX_FILE_SIZE,
        // then show a alert msg to user,hide the loading spinner and return from function  
        if (file.size > self.MAX_FILE_SIZE) {
            //console.log('large file self.MAX_FILE_SIZE--'+self.MAX_FILE_SIZE);
            component.set("v.message", 'Alert : File size cannot exceed 4.25 MB');
            component.set("v.showMessage", true);

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
            self.uploadProcess(component, file, fileContents);
        });

        objFileReader.readAsDataURL(file);
    },

    uploadProcess: function (component, file, fileContents) {
        // set a default size or startpostiton as 0 
        var startPosition = 0;
        // calculate the end size or endPostion using Math.min() function which is return the min. value   
        var endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);

        // start with the initial chunk, and set the attachId(last parameter)is null in begin
        this.uploadInChunk(component, file, fileContents, startPosition, endPosition, '');
    },


    uploadInChunk: function (component, file, fileContents, startPosition, endPosition, attachId) {
        // call the apex method 'saveChunk'
        var getchunk = fileContents.substring(startPosition, endPosition);
        var action = component.get("c.saveChunk");
        action.setParams({
            parentId: component.get("v.parentId"),
            fileName: file.name,
            base64Data: encodeURIComponent(getchunk),
            contentType: file.type,
            fileId: attachId
        });

        // set call back 
        action.setCallback(this, function (response) {
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
                   // console.info('your File is uploaded successfully');
                    // call del method
                    // console.log('deltg other Attachment except-'+attachId);
                    /* BK-15072
                    var act = component.get("c.delPreviousAttachment");
                    act.setParams({
                        attachId: attachId,
                        parentId: component.get("v.parentId")
                    });
                    act.setCallback(this, function (response) {
                        var state = response.getState(); 
                        if (state === "SUCCESS") {
                            //console.log('sucefly delete other attch');
                        } else {
                            //console.log('cant del attchment : server error');
                        }
                    });
                    $A.enqueueAction(act);
                    */


                    // call del method

                    component.set("v.showLoadingSpinner", false);
                    component.set("v.uploadedFileName", file.name);
                    //console.info("fileName info-"+component.get("v.uploadedFileName")+"  --file.name-"+ file.name);
                    component.set("v.showUploadedName", true);
                    component.set("v.attachmentId", attachId);
                    $('#modalfiletype').hide();
                }
                // handel the response errors        
            } else {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        //console.log("Error message: " + errors[0].message);
                        component.set("v.showMessage", true);
                        component.set("v.message", "File type must be JPG,JPEG,EPS,PDF or AI ");
                    }
                }

            }
        });
        // enqueue the action
        $A.enqueueAction(action);
    }



})