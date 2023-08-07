({ // 1
    onInit: function (component, event, helper) {
        var boothId = 'boothId';

        helper.fetchEventDetails(component);
        helper.fetchExistingAttach(component);
        helper.getBaseUrl(component, event);
        console.info("parentId =-" + component.get("v.parentId"));
        //console.info("eventcode =-"+component.get("v.eventcode"));  
    },
    showmodalfiletype: function (component, event, helper) {
        //console.log('showmodalfiletype');
        $('#modalfiletype').show();

    },
    hidemodalfiletype: function (component, event, helper) {
        $('#modalfiletype').hide();
    },
    showSpinner: function (component, event, helper) {
        component.set("v.Spinner", true); // Adding values in Aura attribute variable. 
    },
    hideSpinner: function (component, event, helper) {
        component.set("v.Spinner", false); // Adding values in Aura attribute variable.
    },
    saveAttcahment: function (component, event, helper) {
        var fileInput = component.find("inputFile").getElement();
        console.log('save attachment -- -check');
        if (fileInput.files.length > 0) {
            // //Validate uploaded file extensions.
            if (helper.checkFile(component, 'inputFile')) {
                console.log('checked -- valid extensio');
                component.set("v.showMessage", false);
                //Method is used to upload the attchment file.
                helper.uploadHelper(component, 'inputFile');
            } else {
                component.set("v.showMessage", true);
                component.set("v.message", "File type must be JPG,JPEG,EPS,PDF or AI ");
            }
        } else {
            component.set("v.showMessage", true);
            component.set("v.message", "Please select file to upload.");
        }
    },
    handleFilesChange: function (component, event, helper) {
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
        }
        component.set("v.fileName", fileName); // Adding values in Aura attribute variable.
    },
    getuploadfiletype: function (component, event, helper) {
        var uploadfiletype = event.currentTarget.value;
        //console.log('uploadfiletype>>'+uploadfiletype);
        component.set("v.uploadfiletype", uploadfiletype); // Adding values in Aura attribute variable.
    },
    downloadFile: function (component, event, helper) {
        //console.log('downloading');
        var url = '/CustomerCenter/servlet/servlet.FileDownload?file=' + component.get("v.attachmentId");
        //console.log('url-'+url);
        window.location.href = url;
    },
    // used to download
    downloadUploadedFile: function (component, event, helper) {
        var sfdcBaseUrl = component.get('v.sfdcBaseurl');
        //console.log('downloading up -- attachId ='+component.get("v.attachmentId"));
        var url = sfdcBaseUrl + '/CustomerCenter/servlet/servlet.FileDownload?file=' + component.get("v.attachmentId");
        //console.log('url-'+url);
        var anchor = document.createElement('a');
        anchor.setAttribute("type", "hidden"); // make it hidden if needed
        anchor.href = sfdcBaseUrl + '/servlet/servlet.FileDownload?file=' + component.get("v.attachmentId");
        anchor.download = true;
        anchor.setAttribute("download", "text.Pdf");
        anchor.click();
    },


    /*
     * window.open(url, 'Download');
     */
})