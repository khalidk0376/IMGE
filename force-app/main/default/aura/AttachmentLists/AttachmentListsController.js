({
    doInit: function(component, event, helper) {
        var pageNumber = component.get("v.PageNumber");  
        var pageSize = component.find("pageSize").get("v.value"); 
        helper.getAttachmentList(component, pageNumber, pageSize);
    },
    reloaddataAtt : function(component, event, helper){
        var pageNumber = component.get("v.PageNumber");  
        var pageSize = component.find("pageSize").get("v.value");
        var action = component.get("c.getAttachments");
        action.setParams({
            'parentId' : component.get("v.recordId"),
            "pageNumber": pageNumber,
            "pageSize": pageSize
        });
        action.setCallback(this, function(result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                var resultData = result.getReturnValue();
                component.set("v.TotalRecords", resultData.totalRecords+1);
            }
        });
        $A.enqueueAction(action);
    },
    handleNext: function(component, event, helper) {
        var pageNumber = component.get("v.PageNumber");  
        var pageSize = component.find("pageSize").get("v.value");
        pageNumber++;
        helper.getAttachmentList(component, pageNumber, pageSize);
    },
    
    handlePrev: function(component, event, helper) {
        var pageNumber = component.get("v.PageNumber");  
        var pageSize = component.find("pageSize").get("v.value");
        pageNumber--;
        helper.getAttachmentList(component, pageNumber, pageSize);
    },
    
    handleSelect: function (component, event , helper) {
        var selectedMenu = event.detail.menuItem.get("v.value");  
        var recId = event.getSource().get('v.value');
        var selectedMenuItemValue = event.getParam("value");
        var action = selectedMenuItemValue.substring(0,selectedMenuItemValue.indexOf('_'));
        var index=0;
        if(action=='Edit'){
            component.set("v.EditRecordmodal",true);
            index=selectedMenuItemValue.replace("Edit_","");
            var data = component.get("v.Attachments")[index];
            console.log('data.Id' +JSON.stringify(data.Id));
            component.set("v.AttachmentId",data.Id);
            component.set("v.EditForm.ParentId",data.ParentId);
            component.set("v.EditForm.Name",data.Name);
            component.set("v.EditForm.IsPrivate",data.IsPrivate);
            
        }  
    },
    
    onSelectChange: function(component, event, helper) {
        var page = 1
        var pageSize = component.find("pageSize").get("v.value");
        helper.getAttachmentList(component, page, pageSize);
    },
    
    // Cancel edit record
    cancelEditRecord : function(component, event, helper) {
        var editModelId = component.get("v.EditRecordmodal");
        component.set("v.EditRecordmodal",false);
    },
    
    //Edit Attachment records
    editRecord : function(component, event, helper) {
        
        var editModelId = component.get("v.EditRecordmodal");
        component.set("v.EditRecordmodal",true);
        
        var editRecordEvent = $A.get("e.force:editRecord");
        editRecordEvent.setParams({
            "recordId": component.get("v.attachment.Id"),
        });
        editRecordEvent.fire();
    }, 	
    
    SaveEditrecord : function(component, event, helper){
        var parentId = component.get("v.EditForm.ParentId");
        var editName = component.get("v.EditForm.Name");
        var editBody = component.get("v.EditForm.Body");
        var editIsPrivate = component.get("v.EditForm.IsPrivate");
        var editAction = component.get("c.editData");
        editAction.setParams({
            'attachmentId' :component.get("v.AttachmentId"),
            'parentId' : component.get("v.recordId"),
            'isPrivate' : editIsPrivate
        });
        editAction.setCallback(this,function(data){
            var state = data.getState();
            
            if(state=='SUCCESS'){
                var EditRecord={'sobjectType':'Attachment',
                                'ParentId' : '',
                                'Name' : '',
                                'Body' : '',
                                'IsPrivate' : ''
                               }; 
                
                //   component.set("v.EditForm",EditRecord);
                component.set("v.EditRecordmodal",false);
                window._LtngUtility.toast('Success', 'success', 'Attachment Edited successfully');
                var pageNumber = component.get("v.PageNumber");  
                var pageSize = component.find("pageSize").get("v.value"); 
                helper.getAttachmentList(component, pageNumber, pageSize);
            }
            else if(state=="ERROR"){
                window._LtngUtility.toast('Error','error','Something is wrong');
                component.set("v.EditRecordmodal",false);
            }
        });
        $A.enqueueAction(editAction);  
    },
    
    deleteAttachment: function(component, event, helper) {
        var attachmentId = event.target.getElementsByClassName('attachmentId')[0].value;
        var action = component.get("c.getAttachmentDel");
        action.setParams({
            'attachmentDelId' :attachmentId
        });
        action.setCallback(this, function(result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                var resultData = result.getReturnValue();
                var pageNumber = component.get("v.PageNumber");  
                var pageSize = component.find("pageSize").get("v.value"); 
                helper.getAttachmentList(component, pageNumber, pageSize);
            }
        });
        $A.enqueueAction(action);
    },
})