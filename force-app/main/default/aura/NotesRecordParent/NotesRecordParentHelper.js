({
    //Fetch the notes to the component
    
  /*  doInit: function(component, event, helper) {
        var pageNumber = component.get("v.PageNumber");  
        var pageSize = component.find("pageSize").get("v.value"); 
        helper.getNoteList(component, pageNumber, pageSize);
    },     */
    EditNoteId : null,
    getNoteList: function(component, pageNumber, pageSize) {
        var action = component.get("c.getNoteData");
        action.setParams({
            "ParentId": component.get("v.recordId"),
            "pageNumber": pageNumber,
            "pageSize": pageSize
        });
        action.setCallback(this, function(result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                var resultData = result.getReturnValue();
                component.set("v.NoteListPagination", resultData.notesList);
                component.set("v.PageNumber", resultData.pageNumber);
                component.set("v.TotalRecords", resultData.totalRecords);
                component.set("v.RecordStart", resultData.recordStart);
                component.set("v.RecordEnd", resultData.recordEnd);
                component.set("v.TotalPages", Math.ceil(resultData.totalRecords / pageSize));
            }
        });
        $A.enqueueAction(action);
    },   
    
    deleteSelected : function(component,event,helper,selctedRec){ 
        var action = component.get("c.delSlctRec");
        action.setParams({
            "slctRec": selctedRec
        });
        action.setCallback(this, function(response){
            var state =  response.getState();
            if(state === "SUCCESS") {
                component.set("v.NoteListPagination",response.getReturnValue());
                window._LtngUtility.toast('Success', 'success', 'Selected Notes has been deleted successfully');
            	var pageNumber = component.get("v.PageNumber");  
                var pageSize = component.find("pageSize").get("v.value"); 
                this.getNoteList(component, pageNumber, pageSize);      
                $A.get("e.force:refreshView").fire();
            } 
            else if (state=="ERROR") {
                console.log(action.getError()[0].message);
            }
        });
        $A.enqueueAction(action);   
    },
})