({
    doInit : function(component, event, helper) {
     //console.log('value of file id @@@');
     var pageUrl = window.location.href;
         var qString = pageUrl.split("#")[1];
         var fileid = qString.split("=")[1];
          component.set('v.selectedDocumentId',fileid);
  }
})