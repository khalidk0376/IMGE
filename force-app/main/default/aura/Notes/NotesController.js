({
	onLoad: function(component,event,helper) {
        helper.fetchNotes(component, event, helper);
    },
    PopUpClosedChanges: function(component,event,helper) {
        // console.log('PopUpClosedChanges');
    },
    BoothIDChange: function(component,event,helper) {
        helper.fetchNotes(component, event, helper);        
    },
    saveNewNote: function(component,event,helper) {
        var note=component.get("v.newnote");
        note.Note__c=document.getElementById('txtNotes').value;
        if(note.Note__c)
        {
            helper.saveNotes(component, event, helper);        
        }
        else{
            alert('Enter Note.');
        }      
    }
})