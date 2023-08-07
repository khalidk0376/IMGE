({   
    fetchExpoOppMappingData: function (cmp,event,helper) {
        var action = cmp.get("c.getAllOppMapping");
        action.setParams({
            "opp": cmp.get("v.oppObj")          
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();                    
                cmp.set("v.oppMappingRecordsList", data.expocad_Mapping);
                cmp.set("v.oppMappingRecordsInactive",data.inactiveMapping);
                cmp.set("v.oppMappingRecordsActive",data.activeMapping);
            }
            // error handling when state is "INCOMPLETE" or "ERROR"
        });
        $A.enqueueAction(action);
    },

   fetchExpoCadData: function (cmp,event,helper) {
        var action = cmp.get("c.getAllExpocadRecords");
        
        action.setParams({
            "opp": cmp.get("v.oppObj")          
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();                    
                cmp.set("v.ExpocadRecordsList", data);
            }
            // error handling when state is "INCOMPLETE" or "ERROR"
        });
        $A.enqueueAction(action);
    },
    
    fetchCCMappingData : function (cmp,event,helper) {
        var action = cmp.get("c.getAllCCMappingRecords");
        
        action.setParams({
            "opp": cmp.get("v.oppObj")          
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();                    
                cmp.set("v.CCMappingUpdateRecordsList", data);
            }
            // error handling when state is "INCOMPLETE" or "ERROR"
        });
        $A.enqueueAction(action);
    }
})