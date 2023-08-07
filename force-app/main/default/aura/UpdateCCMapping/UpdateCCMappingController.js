({
	doInit: function(component, event, helper) {
       
    },
    
    inlineuserTypeEditMode : function(component,event,helper){  
        component.set("v.inlineuserTypeEditMode", true);   
        component.set("v.isOpenUserTypeModal", true); 
    },
    
    closeModal :function(component,event,helper){          
        component.set("v.isOpenUserTypeModal", false);                
    }
})