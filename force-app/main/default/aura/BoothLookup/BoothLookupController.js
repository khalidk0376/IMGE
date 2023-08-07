({
	doInit : function(component, event, helper) {
        //helper.getAllBooth(component);
    }, 
	closeModal : function(component, event, helper) {
		component.set("v.isOpenModal",false);
	},
    openModal : function(component, event, helper) {
        component.set("v.isOpenModal",true);
        helper.getAllBooth(component,'');
    },
    searchBooth:function(component, event, helper) {
        if(event.getSource().get("v.value").length>1){
            helper.getAllBooth(component,event.getSource().get("v.value"));    
        }
        else{
            helper.getAllBooth(component,'');       
        }
    }
})