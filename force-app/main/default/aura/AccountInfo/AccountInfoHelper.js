({
	getRecord: function(component) { 
 		var conId = component.get("v.recordId"); 
        var action = component.get("c.getRecord");
        action.setParams({recordId:conId,objectName:'Contact',fields:'AccountId'});
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {    
            	var recordDtls =res.getReturnValue();
                if(recordDtls.length>0)
                {
                    component.set("v.recordDtls",recordDtls[0]);
                }
            }
            else 
            {
                window._LtngUtility.handleErrors(res.getError());
            }
        });
        $A.enqueueAction(action); 
    },
    getAccConRecord: function(component,pageNumber) { 
        component.set("v.showSpinner", true);
        var pageSize=5;
        var conId = component.get("v.recordId"); 
        var action = component.get("c.getRecords");
        action.setParams({
            objName:'AccountContactRelation',
            fieldNames:'Id,AccountId,Account.Name, ContactId, IsDirect, IsActive, StartDate, EndDate, CurrencyIsoCode, IsDeleted, CreatedDate, CreatedById, LastModifiedDate,LastModifiedById, LastModifiedBy.Name, SystemModstamp, Is_Account_Address_Verified__c ',
            compareWith:'ContactId',
            recordId:conId,
            pageNumber:pageNumber,
            pageSize:pageSize
        });
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {   
                var result=res.getReturnValue();
                console.log('test'+JSON.stringify(result));
                var recordDtls =result.recordList;
                
                if(recordDtls.length>0)
                {
                    for(var i=0;i<recordDtls.length;i++)
                    {
                        if (recordDtls[i].hasOwnProperty('Account')) {recordDtls[i].Account=recordDtls[i].Account.Name}
                        if (recordDtls[i].hasOwnProperty('LastModifiedBy')) {recordDtls[i].LastModifiedBy=recordDtls[i].LastModifiedBy.Name}
                        recordDtls[i].accLink = '/lightning/r/Account/' + recordDtls[i].AccountId + '/view';
                        recordDtls[i].userLink = '/lightning/r/User/' + recordDtls[i].LastModifiedById + '/view';
                    }
                    component.set("v.relatedAcc",recordDtls);
                    component.set("v.PageNumber", result.pageNumber);
                	component.set("v.TotalRecords", result.totalRecords);
                	component.set("v.RecordStart", result.recordStart);
                	component.set("v.RecordEnd", result.recordEnd);
                	component.set("v.TotalPages", Math.ceil(result.totalRecords / pageSize));
                }
            }
            else 
            {
                window._LtngUtility.handleErrors(res.getError());
            }
            component.set("v.showSpinner", false);
        });
        $A.enqueueAction(action); 
    },
})