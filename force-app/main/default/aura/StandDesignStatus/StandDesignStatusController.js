({

	onLoad: function(component,event,helper) {
        helper.fetchPicklistValues(component,'Stand_Design__c','Booth_Design_Status__c','--Booth Design Status--','All',false);
        helper.fetchPicklistValues(component,'Stand_Design__c','Stand_Type__c','--Stand Type--','none',true);
        helper.getEventSetting(component, event, helper);
        helper.getStandDesignClone(component, event, helper);
        helper.getBaseUrl(component, event, helper);  
        helper.fetchUploadAttType(component);
        //var objEditor = component.get("v.objEditor");
        //objEditor("editor1","");
        
    },
    HandleChange: function(component, event, helper) {
        helper.DesignStatusEmailConList(component, event, helper);   
    },
    handleClick: function(component, event, helper) { 
        helper.SendEmailAndUpdateStatus(component, event, helper);
        helper.getStandDesignClone(component, event, helper);
        document.getElementById('DisclaimerBlock').style.display = "none";
    }, 
    PopUpClosedChanges: function(component,event,helper) {
        helper.ReInitialize(component, event, helper);
    }, 
    AccountIdChanges: function(component,event,helper) {
        var Accid=component.get("v.AccountId");
        helper.getStandDesignClone(component, event, helper);
        helper.getStandDetails(component, event, helper);
    },
    hideModal: function(component, event, helper) {
        document.getElementById('DisclaimerBlock').style.display = "none";
    },
    showModal: function(component, event, helper) {
        var isValidEmail = true;
        var emailField = component.find("emailcc");
        var emailFieldValue = emailField.get("v.value");
        
        var regExpEmailformat = /^(([a-zA-Z0-9_\-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([a-zA-Z0-9\-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)(\s*,\s*|\s*$))*$/;
        if(!$A.util.isEmpty(emailFieldValue)){
            if(emailFieldValue.match(regExpEmailformat)){
                emailField.set("v.errors", [{message: null}]);
                $A.util.removeClass(emailField, 'slds-has-error');
                isValidEmail = true;
                document.getElementById('DisclaimerBlock').style.display = "block";    
            }
            else{
                $A.util.addClass(emailField, 'slds-has-error');
                emailField.set("v.errors", [{message: "Please Enter a Valid Email Address"}]);
                isValidEmail = false;
            }  
        // rerender component 
        component.set('v.renderedComponent',false);
        setTimeout(() => {
            component.set('v.renderedComponent',true);
        }, 10); 
 
        }
        else {
                emailField.set("v.errors", [{message: null}]);
                $A.util.removeClass(emailField, 'slds-has-error');
                isValidEmail = true;
                document.getElementById('DisclaimerBlock').style.display = "block"; 
        }
    
    
        
    },
    showUploadModal: function(component, event, helper) {
        document.getElementById('UploadArea').style.display = "block";
        component.set("v.uploadAllowed",false);
        helper.setUploadAttType(component);
        var designType=component.get("v.designtype");
        if(designType){
            helper.uploadFiles(component,designType);  
        }
        
    },
    
    handleUploadFinished: function (component, event) {
        // Get the list of uploaded files
        var uploadedFiles = event.getParam("files");
        
        // Get the file name
        uploadedFiles.forEach(file => console.log(file.documentId)); 
        var action = component.get('c.prepareFileTitle');
        var filetype = component.get("v.uploadfiletype");
        var fileTitle = component.get('v.fileTitle');
        var part1 = fileTitle.substring(0,fileTitle.lastIndexOf('_')+1);
        var part2 = fileTitle.substring(fileTitle.lastIndexOf('_')+1);
        var sDesignRecordId = component.get('v.standDesignId'); 
        //alert(sDesignRecordId);
        // method name i.e. getEntity should be same as defined in apex class
        // params name i.e. entityType should be same as defined in getEntity method
        action.setParams({
        "recordId"  : uploadedFiles[0].documentId,
        "fileTitle" : part1+filetype+part2,
        "sdRecordId": sDesignRecordId,
        "filetype"  : filetype
        });
        //alert(part1+filetype+ part2);
        action.setCallback(this, function(a){
        var state = a.getState(); // get the response state
        if(state == 'SUCCESS') {
            //alert('File name updated');
        }
        else if (state === "INCOMPLETE") {
            // do something
        }
        else if (state === "ERROR") {
            var errors = response.getError();
            console.log(errors);
            if (errors) {
                if (errors[0] && errors[0].message) {
                    console.log("Error message: " + 
                             errors[0].message);
                }
            } else {
                console.log("Unknown error");
            }
        }
        });
        $A.enqueueAction(action);
    },
    
    // showUploadModal: function(component, event, helper) {
    //     var stdDetail = component.get("v.StandDetail");
    //     console.log('stdDetail==='+JSON.stringify(stdDetail));
    //     if(stdDetail.length>0)
    //     {
    //         document.getElementById('UploadArea').style.display = "block";
    //         component.set("v.uploadAllowed",false);
    //         helper.setUploadAttType(component); 
    //     }
    //     else{
    //         document.getElementById('errorMessage').style.display = "block";
    //     } 
    // },
    hideUploadModal: function(component, event, helper) {
        document.getElementById('UploadArea').style.display = "none";
        helper.getStandDesignClone(component, event, helper);
        helper.ReInitializeUploadModel(component);

    },
    closeMessage: function(component, event, helper) {
        document.getElementById('errorMessage').style.display = "none";
    },
    download: function(component,event,helper) {
        helper.downloadfile(component, event, helper); 
    },
    waiting: function(component, event, helper) {
        component.set("v.isSpinner", true);// Adding values in Aura attribute variable. 
     },
    doneWaiting: function(component, event, helper) {
        component.set("v.isSpinner", false);// Adding values in Aura attribute variable. 
     },
     getuploadfiletype: function(component, event, helper) {
		var uploadfiletype = event.currentTarget.value;
		//console.log('uploadfiletype>>'+uploadfiletype);
		component.set("v.uploadfiletype", uploadfiletype);// Adding values in Aura attribute variable.
    },
    DownloadAll: function(component, event, helper) {
        
        var AttchmentIds =[]; 
        var StandDesign = component.get("v.StandDesign"); 
            if(StandDesign.length>0){
            var DesignAttachmentTypes = StandDesign[0].DesignAttachmentTypes__r;
            component.set("v.NoAttachment",true); 
                for(var j=0;j<DesignAttachmentTypes.length;j++){

                    if(DesignAttachmentTypes[j].IsRejected__c == false)
                   { AttchmentIds.push(DesignAttachmentTypes[j].AttachmentId__c);}
                }
            }else{
                component.set("v.NoAttachment",true);
            }
            //console.log('id =>'+AttchmentIds);
            //helper.fetchAttachmentbody(component,AttchmentIds);
            helper.getAttachments(component,AttchmentIds);
             

    },
    saveAttcahment: function(component, event, helper) {
		var fileInput = component.find("inputFile").getElement();
		if(fileInput.files.length>0)
		{ 
            var msg = helper.checkFile(component,'inputFile');
            //console.log('msg' +msg);
			if(!msg){
				if(component.get("v.designtype") != 'none'){
                    //console.log('uploadfiletype == '+(component.get("v.uploadfiletype")));
                    if(!component.get("v.uploadfiletype")){    
                        component.set("v.message","Please select stand design attchment type.");    
                    }
                    else{
                        component.set("v.message",'');
                        component.set("v.customSpinner", true);// Adding values in Aura attribute variable.
                        helper.getEventSetting(component); 
                        //component.set("v.uploadAllowed",true);
                        window.setTimeout(
                            $A.getCallback(function() {
                                component.set("v.customSpinner", false);// Adding values in Aura attribute variable.
                                helper.checkStandDesign(component,event);
                            }), 5000
                        );

                        //helper.checkStandDesign(component,event);
                        //helper.uploadHelper(component, event,component.get("v.designtype"));
                    }
				}
				else{
                   
                    component.set("v.message","Please select stand type.");
				}	
			}
			else{
                //component.set("v.message","Please upload pdf file.");
                component.set("v.message",msg);
			}
		}
		else{
			component.set("v.message","Please select file to upload.");
		}
    },
    Stand_TypeChange: function(component, event, helper) {

        //console.log('designtype==============================='+component.get("v.designtype"));
        component.set("v.uploadfiletype",'');
        helper.setUploadAttType(component); 
        var designType=component.get("v.designtype");
        if(designType){
            helper.uploadFiles(component,designType);  
        }
    },
    selectRejected: function(component,event, helper){

        var checkCmp = component.find("devid");
        var checkReject = checkCmp.get("v.value");
        console.log('checkReject',checkReject);
        var status;
        //console.log('check ' +checkReject);
        if(checkReject){
            status = true;
        }else{
            status = false;
        }
        component.set("v.showReject", status);

    },
    // showModalRejectStandDesign: function(component,event,helper) {
    //     var target = event.getSource();
    //     var stdDsgAttID = target.get("v.value");
    //     component.set("v.toRejectVal",stdDsgAttID);
    //     //console.log(stdDsgID);
    //     document.getElementById('modalRejectStandDesign').style.display = "block";
    // },
    // hideModalRejectStandDesign: function(component,event,helper) { // Delete Stand Design And details
    //     document.getElementById('modalRejectStandDesign').style.display = "none";
    // },
    // rejectStandDesign : function(component, event, helper) {
    //     //console.log( 'stdDsgID == '+component.get("v.toDeleteVal"));
    //     var stdDesignAttID =component.get("v.toRejectVal");
    //     if(stdDesignAttID)
    //     {
    //         helper.rejectDesign(component,stdDesignAttID);
    //     }    
    //     document.getElementById('modalRejectStandDesign').style.display = "none";
    // },
    rejectStandDesign: function(component , event , helper)
    {
        var designAttchmntId = event.getSource().get("v.value");
        helper.rejectDesign(component , event , designAttchmntId);
    },
   
})