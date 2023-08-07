({     
    doInit: function(component, event, helper) {
        var pageNumber = component.get("v.PageNumber");  
        var pageSize = component.find("pageSize").get("v.value"); 
        helper.getNoteList(component, pageNumber, pageSize);
    },               
    
    handleNext: function(component, event, helper) {
        var pageNumber = component.get("v.PageNumber");  
        var pageSize = component.find("pageSize").get("v.value");
        pageNumber++;
        helper.getNoteList(component, pageNumber, pageSize);
    },
    
    handlePrev: function(component, event, helper) {
        var pageNumber = component.get("v.PageNumber");  
        var pageSize = component.find("pageSize").get("v.value");
        pageNumber--;
        helper.getNoteList(component, pageNumber, pageSize);
    },
    
    onSelectChange: function(component, event, helper) {
        var page = 1
        var pageSize = component.find("pageSize").get("v.value");
        helper.getNoteList(component, page, pageSize);
    },
    
    //Mass action delete checkbox
    onCheck: function(component, event, helper) {
        var slctCheckRow = event.getSource().get("v.value");        
        //  var getCheckAllId = component.find("cboxRow");
    },
    
    deleteSlctd : function(component,event,helper) {
        var getCheckAllId = component.find("cboxRow");
        var selctedRec = [];
        if(getCheckAllId.length==undefined){
            if(getCheckAllId != undefined && getCheckAllId.get("v.value"))
                selctedRec.push(getCheckAllId.get("v.text")); 
        }
        else
        {        
            for (var i = 0; i < getCheckAllId.length ; i++) {
                if(getCheckAllId[i].get("v.value") == true )
                {
                    selctedRec.push(getCheckAllId[i].get("v.text")); 
                }
            }
        }
        if(selctedRec.length > 0){
            helper.deleteSelected(component,event,helper,selctedRec);   
        }
        else{
            window._LtngUtility.toast('Error','error','Select atleast a row for deletion');
        }
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
            var data = component.get("v.NoteListPagination")[index];
            
            component.set("v.NoteId",data.Id);
            component.set("v.EditForm.ParentId",data.ParentId);
            component.set("v.EditForm.Title",data.Title);
            component.set("v.EditForm.Content",data.Content);
            component.set("v.EditForm.IsPrivate",data.IsPrivate);
        }   
    },
    
    SaveEditrecord : function(component, event, helper){
        var parentId = component.get("v.EditForm.ParentId");
        var editTitle = component.get("v.EditForm.Title");
        var editBody = component.get("v.EditForm.Content");
        var editIsPrivate = component.get("v.EditForm.IsPrivate");
        var editAction = component.get("c.EditData");
        editAction.setParams({
            'NoteId':component.get("v.NoteId"),
            'ParentId' : component.get("v.recordId"),
            'Title' : editTitle,
            'Body' : editBody,
            'IsPrivate' : editIsPrivate
        });
        editAction.setCallback(this,function(data){
            var state = data.getState();
            if(state=='SUCCESS'){
                var EditRecord={'sobjectType':'ContentNote',
                                'ParentId' : '',
                                'Title' : '',
                                'Content' : '',
                                'IsPrivate' : '',
                               }; 
                component.set("v.EditForm",EditRecord);
                component.set("v.EditRecordmodal",false);
                window._LtngUtility.toast('Success', 'success', 'Note Edited successfully');
                var pageNumber = component.get("v.PageNumber");  
                var pageSize = component.find("pageSize").get("v.value"); 
                helper.getNoteList(component, pageNumber, pageSize);
            }
            else if(state=="ERROR"){
                window._LtngUtility.toast('Error','error','Something is wrong');
                component.set("v.EditRecordmodal",false);
            }
        });
        $A.enqueueAction(editAction);  
    },
    
    //Function to delete the record
    deleteNote: function(component, event, helper){
        
        var delNoteId = component.find("NtId").get("v.value");
        var ActionDel = component.get("c.deleteNotes");
        ActionDel.setParams({
            'DelNote':delNoteId,
        });
        var delac = JSON.stringify(ActionDel);
        ActionDel.setCallback(this,function(data){
            var state = data.getState();
            
            
            if(state =='SUCCESS'){
                window._LtngUtility.toast('Success', 'success', 'Note has been deleted successfully');
                var pageNumber = component.get("v.PageNumber");  
                var pageSize = component.find("pageSize").get("v.value"); 
                helper.getNoteList(component, pageNumber, pageSize);
            }
            else if(state=="ERROR"){
                window._LtngUtility.toast('Error','error','Something is wrong');
                component.set("v.EditRecordmodal",false);
            } 
        });
        $A.enqueueAction(ActionDel);  
    },
    
    // Function to show the new note modal
    newNote: function(component, event, helper){
        var getNewButtonValue = component.get("v.NewNoteModel");
        component.set("v.NewNoteModel",true);
    },
    
    //Close the note Modal
    cancelNoteModal: function(component, event, helper){
        var getNewButtonValue = component.get("v.NewNoteModel");
        component.set("v.NewNoteModel",false);
    },
    
    // Cancel edit record
    cancelEditRecord : function(component, event, helper) {
        var editModelId = component.get("v.EditRecordmodal");
        component.set("v.EditRecordmodal",false);
    },
    
    // Save new record in note
    saveRecords : function(component, event, helper){
        var titledata = component.get("v.NotesDetail.Title");
        var bodydata = component.get("v.NotesDetail.Content");
        var privatedata = component.get("v.NotesDetail.IsPrivate");
        var action = component.get("c.saveData");
        
        
        action.setParams({
            'ParentId' : component.get("v.recordId"),
            'Title' : titledata,
            'Body' : bodydata,
            'IsPrivate' : privatedata
        });
        action.setCallback(this,function(data){
            var state = data.getState();
            
            if(state=='SUCCESS'){
                var obj = data.getReturnValue();
                var newRecord={'sobjectType':'Note',
                               'ParentId' : '',
                               'Title' : '',
                               'Content' : '',
                               'IsPrivate' : '',
                              }; 
                component.set("v.NotesDetail",newRecord);
                component.set("v.NewNoteModel",false);
                window._LtngUtility.toast('Success', 'success', 'Note has been saved successfully');
                var pageNumber = component.get("v.PageNumber");  
                var pageSize = component.find("pageSize").get("v.value"); 
                helper.getNoteList(component, pageNumber, pageSize); 
            }
            else if(state=="ERROR"){
                window._LtngUtility.toast('Error','error','Something is wrong');
                component.set("v.NewNoteModel",false);
            }
        });
        $A.enqueueAction(action);
    },
    
    //Edit Note records
    editRecord : function(component, event, helper) {
        var editModelId = component.get("v.EditRecordmodal");
        component.set("v.EditRecordmodal",true);
        
     /*   var editRecordEvent = $A.get("e.force:editRecord");
        editRecordEvent.setParams({
            "recordId": component.get("v.Note.Id"),
        });
        editRecordEvent.fire();*/
    }
})