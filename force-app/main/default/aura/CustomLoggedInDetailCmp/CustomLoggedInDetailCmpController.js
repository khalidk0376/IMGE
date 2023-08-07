({
	doInit: function(component, event, helper) {       
        helper.getTableData(component,false,false);
    },
    filterData : function (component, event, helper) {
        helper.getTableData(component,false,false);
    },
    updateColumnSorting: function (component, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');                
        component.set("v.sortedBy", fieldName);
        component.set("v.sortedDirection", sortDirection);
        helper.getTableData(component,false,false);  

        //helper.sortData(component, fieldName, sortDirection);
    },    
    nextDatas:function(component,event,helper){
        var next = true;
        var prev = false;
        var offset = component.get("v.offset");
        helper.getTableData(component,next,prev,offset); 
    },
    previousDatas:function(component,event,helper){
        var next = false;
        var prev = true;
        var offset = component.get("v.offset");
        helper.getTableData(component,next,prev,offset); 
    },
})