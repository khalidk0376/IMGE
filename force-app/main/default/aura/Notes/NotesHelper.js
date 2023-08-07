({ 
    //Apex class : ApproveContractorCtrl 
	fetchNotes: function(component, event, helper) {
        
        var action = component.get("c.getNotes"); //Calling Apex class controller 'getNotes' method
        var BthId=component.get("v.BoothID"); //Getting values from Aura attribute variable.
        var AccId=component.get("v.AccountId");//Getting values from Aura attribute variable.
        //console.log('BthId---'+BthId+'AccId---'+AccId);
        action.setParams({
            sBoothId:BthId,
            sAccId:AccId
        });
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") { 
                component.set("v.notes",res.getReturnValue());//Adding values to Aura attribute variable.
                //console.log('fetchNotes'+JSON.stringify(res.getReturnValue()));
            }
        });
        $A.enqueueAction(action); 
    },
    saveNotes: function(component, event, helper) {
        var note=component.get("v.newnote");// Getting values from Aura attribute variable.
        var BthId=component.get("v.BoothID");// Getting values from Aura attribute variable.
        var AccId=component.get("v.AccountId");// Getting values from Aura attribute variable.
        note.Opp_Booth_Mapping__c=BthId;
        note.Account__c=AccId;
        var action = component.get("c.saveNote"); //Calling Apex class controller 'saveNote' method
        action.setParams({
            sNote:note
        });
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") { 
                document.getElementById('txtNotes').value='';
                component.set("v.notes",res.getReturnValue());//Adding values to Aura attribute variable.
                //console.log('saveNotes'+JSON.stringify(res.getReturnValue()));
            }
        });
        $A.enqueueAction(action); 
    },
        ReInitialize: function(component, event, helper) {
            
        component.set("v.AccountId",'');//Adding values to Aura attribute variable.
        component.set("v.BoothID",'');//Adding values to Aura attribute variable.
        component.set("v.childsingleBooth",null);//Adding values to Aura attribute variable.
        component.set("v.notes",null);//Adding values to Aura attribute variable.
    }
})