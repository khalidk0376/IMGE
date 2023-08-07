({
    //method to fetch all existing Files on sObject record.
    getExistingFiles : function(component){
        //get sObject Id
        var sObjectId = component.get("v.sObjectId");
        
        //invoke Controller method to get All attached Files
        var action = component.get("c.getAllFilesOnsObjectRecord");
        action.setParams({
            sObjectId : sObjectId
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var existingFilesArr = response.getReturnValue();
                if(existingFilesArr != null && existingFilesArr != undefined && existingFilesArr.length > 0){
                    //  component.set("v.sObjectAttachedFiles", existingFilesArr);
                }
            }
        });
        $A.enqueueAction(action);
    },
     /* BK-22967 By Faisal Khan on 01-09-2022 */
    getAccountName : function(component,event){
        var action = component.get("c.getAccountName");
        var recordId = component.get('v.sObjectId');
         action.setParams({recordId : recordId});
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var AccountName = response.getReturnValue();
                component.set("v.accountName",AccountName);
            }
            
        });
        $A.enqueueAction(action);
        
    },
    
    
    //method invoked after uploading a File on sObject
    handleUploadFinished : function(component, event) {
        var uploadedFileArr = [];
        debugger;
        var test = 'test';
                // this.updateDocumentName(component,test);
        //get all attached files on sObject
        var sObjectAttachedFiles = component.get("v.sObjectAttachedFiles");
        var sObjectAttachedFilesArr = [];
        var AccountName = component.get("v.accountName");
         var today =  $A.localizationService.formatDate(new Date(), "YYYY MM DD, hh:mm:ss");
        if(sObjectAttachedFiles != null && sObjectAttachedFiles != undefined && sObjectAttachedFiles.length > 0){
            [].forEach.call(sObjectAttachedFiles, function(file) {
                //get all attached files on sObject in an Array
                sObjectAttachedFilesArr.push({'Id' : file.Id,
                                              'Title': 'Doc_'+AccountName+'_'+ today});
            });
        }
        
        //get uploaded Files
        var uploadedFiles = event.getParam("files");
        [].forEach.call(uploadedFiles, function(file) {
            //get all uploaded files in an array
          //  this.updateDocumentName(component,file.documentId);
           var action = component.get("c.updateCurrentDoc");
        action.setParams({
            docId : file.documentId,
            userName : AccountName
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){}
            
        });
        $A.enqueueAction(action);
       
            uploadedFileArr.push({'Id' : file.documentId,
                                  'Name': 'Doc_'+AccountName+'_'+today});
            
            //get all uploaded files in an array to display on the UI
            sObjectAttachedFilesArr.push({'Id' : file.documentId,
                                          'Title': 'Doc_'+AccountName+'_'+ today});
        });
        
        //set all existing and uploaded Files in an attribute used to display on the UI
        component.set("v.sObjectAttachedFiles", sObjectAttachedFilesArr);
        
        //get all uploaded Files on different clicks/drops.
        var filesUploadedPreviously = component.get('v.uploadedFiles');
        if(filesUploadedPreviously != null && filesUploadedPreviously != undefined && filesUploadedPreviously.length > 0){
            [].forEach.call(filesUploadedPreviously, function(file) {
                uploadedFileArr.push({'Id' : file.Id,
                                      'Name': 'Document_'+AccountName+'_'+ today
                                     });
            });
        }
        
        //set all uploaded files in an array
        component.set("v.uploadedFiles",uploadedFileArr);
        
    },
    
    
    
    //method to handle cancelFileUpload to clear all uploaded Files from sObject
    handleCancelUpload : function(component){
        //get all uploaded Files
        var uploadedFiles = component.get("v.uploadedFiles");
        var uploadedFileIdArr = [];
        if(uploadedFiles != null && uploadedFiles != undefined && uploadedFiles.length > 0){
            [].forEach.call(uploadedFiles, function(file) {
                //get all uploaded File Ids in an Array
                uploadedFileIdArr.push(file.Id);
            });
        }
        
        //get sObject record Id
        var sObjectId = component.get("v.sObjectId");
        var sObjectName = component.get("v.sObjectName");
        
        //controller method to delete all uploaded Files on Cancel 
        var action = component.get("c.deleteFiles");
        action.setParams({
            filesIdArrStr : JSON.stringify(uploadedFileIdArr)
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            
            //helper method for navigation
            this.navigateToRecordDetailPage(component, sObjectId, sObjectName);
        });
        $A.enqueueAction(action);
    },
    
    //method to handle Save
    handleSaveClick : function(component){
        //get sObject Id
        var sObjectId = component.get("v.sObjectId");
        var sObjectName = component.get("v.sObjectName");
        //helper method for navigation
        if(component.get("v.sObjectAttachedFiles") != ''){
        this.navigateToRecordDetailPage(component, sObjectId, sObjectName);
        }else{
            window._LtngUtility.toast('Error','error','Please select one File in order to Save or Else Press Cancel'); 
        }
    },
    
    //method to handle the navigation
    navigateToRecordDetailPage : function(component, sObjectId, sObjectName) {
        
        var navService = component.find("navService");
        
        //set the pageRefernce attributes to generate URL
        var pageReference = {
            type: "standard__app",
            attributes: {
                
                pageRef: {
                    type: "standard__recordPage",
                    attributes: {
                        recordId: sObjectId,
                        objectApiName: sObjectName,
                        actionName: "view"
                    }
                }
            }
        };
        
        //lightning navigation method to generate URL
        navService.generateUrl(pageReference)
        .then($A.getCallback(function(url) {
            //navigate to the generated URL
            window.location.href = url;
        }), $A.getCallback(function(error) {
            window.location.href = "/" + sObjectId;
        }));
    },
    updateDocumentName : function(component,docId){
        var action = component.get("c.updateCurrentDoc");
        action.setParams({
            docId : docId
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){}
            
        });
        $A.enqueueAction(action);
        
    }    
})