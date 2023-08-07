({
	fetchData : function(component) {
		var action = component.get("c.getBpNumberRecords");
		action.setParams({  recordId : component.get("v.recordId") });
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {    
            	var resBpNumber =res.getReturnValue();
              	for(var i=0;i<resBpNumber.length;i++){
                    resBpNumber[i].Legal_Entity_DBA=resBpNumber[i].Legal_Entity__r.DBA__c;
                    resBpNumber[i].Legal_Entity_Informa_Branch = resBpNumber[i].Legal_Entity__r.Informa_Branch__c;
                    resBpNumber[i].Legal_Entity_Name=resBpNumber[i].Legal_Entity__r.Name;
                }
                component.set("v.data",resBpNumber);
            }
            else 
            {
                window._LtngUtility.handleErrors(res.getError());
            }
        });
        $A.enqueueAction(action); 
	}
})