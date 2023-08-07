({
    fetchData : function(component,pageNumber) {
        var pageSize = 10;
        var action = component.get("c.getRecords");
        action.setParams({ objName: "Account_Associations__c", fieldNames: 'Id, Name, Active__c, Expiry_Date__c, Chamber__c, Association_Product__c, Association_Product_EE__c, Association__r.Name, Event_Series__c, Member_Status__c', compareWith: 'Account__c', recordId: component.get("v.recordId"), pageNumber: pageNumber, pageSize: pageSize });
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {    
                var result = res.getReturnValue();
                var resAcAs =res.getReturnValue().recordList;
                for(var i=0;i<resAcAs.length;i++){
                    if(resAcAs[i].hasOwnProperty('Association__r')){
                        resAcAs[i].association = resAcAs[i].Association__r.Name;
                    }
                }
                component.set("v.data", resAcAs);
                component.set("v.TotalRecords", result.totalRecords);
                component.set("v.RecordStart", result.recordStart);
                component.set("v.RecordEnd", result.recordEnd);
                component.set("v.TotalPages", Math.ceil(result.totalRecords / pageSize));
                component.set("v.showSpinner", false);
            }
            else 
            {
                window._LtngUtility.handleErrors(res.getError());
            }
        });
        $A.enqueueAction(action); 
    }
})