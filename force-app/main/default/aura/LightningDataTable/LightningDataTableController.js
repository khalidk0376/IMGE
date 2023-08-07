({
	init : function(component, event, helper) {
        console.log(component.get("v.profile"));
        helper.getTableData(component,false,false);
	},
    handleRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        if(action.name=='edit'){            
            helper.getDetailData(component,'FirstName,LastName,Email,Title,Contact_Type__c,AccountId,MobilePhone,Phone,MailingCity,MailingCountryCode,MailingStateCode,MailingPostalCode,MailingStreet',row.Id);
        }
        else if(action.name=='delete'){
            helper.deleteContact(component,row);
        }
            else if(action.name=='viewFile'){
                helper.openFile(component,'Id',row.Id);                
            }
    },
    updateColumnSorting: function (cmp, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        cmp.set("v.sortedBy", fieldName);
        cmp.set("v.sortedDirection", sortDirection);
        helper.sortData(cmp, fieldName, sortDirection);
    },
    handleSaveEdition:function(component,event,helper){
        var draftValues = event.getParam('draftValues');
        helper.handleSubmit(component,draftValues);
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
    }
})