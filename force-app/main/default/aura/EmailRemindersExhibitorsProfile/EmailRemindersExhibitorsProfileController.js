({
    onLoad: function(component,event,helper) {
        var objEditor = component.get("v.objEditor");
            console.log('objEditor ====== '+objEditor);
            if(objEditor){
                 objEditor("editor","");  
            }		
    },
    waiting: function(component, event, helper) {
        component.set("v.isSpinner", true);// Adding values in Aura attribute variable. 
     },
    doneWaiting: function(component, event, helper) {
        component.set("v.isSpinner", false);// Adding values in Aura attribute variable. 
    },
    showModelEmailTemplateEditor: function(component,event,helper) {
        helper.getMailContent(component);
        //document.getElementById('modelEmailTemplateEditor').style.display = "block";
    },
    showConfirm: function(component,event,helper) {
        document.getElementById('modelConfirmmail').style.display = "block";
    },
    hideModelEmailTemplateEditor: function(component,event,helper) { 
        document.getElementById('modelConfirmmail').style.display = "none";
        document.getElementById('modelEmailTemplateEditor').style.display = "none";
        document.getElementById('modelSent').style.display = "none";
    },
    mailExhNoPro: function(component,event,helper) {
        //document.getElementById('modelSent').style.display = "block";
        helper.mailExhWithoutPro(component);
    },
    updateTemplate: function(component,event,helper) {
        helper.updateEmailTemplate(component);
    }
    
})