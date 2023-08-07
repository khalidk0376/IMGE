({
	init : function(component,recordId) {
		component.set("v.spinner", true);
		let param = JSON.stringify({oppId: component.get("v.oppObj.Id")});
		var action = component.get("c.invokeInsertOrUpdate");
        action.setParams({action:'',parameters:param});
        action.setCallback(this, function(res) {
            component.set("v.spinner", false);
            var state = res.getState();
            if (state === "SUCCESS"){
                component.set("v.spinner",false);
                window._LtngUtility.toast('Success','success','Change request has been been submitted');
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                  "recordId": recordId,
                  "slideDevName": "detail"
                });
                navEvt.fire();
            } 
            else {
                window._LtngUtility.handleErrors(res.getError());
            }
        });
        $A.enqueueAction(action);
	},
    validate:function(component){
        var selected = component.get("v.selectedType");
        var isvalid = true;
        //alert(component.find("Type_of_Change").get("v.value"));
        
        if($A.util.isEmpty(component.find("Type_of_Change").get("v.value")))
        {
            isvalid = false;            
            $A.util.addClass(component.find("Type_of_Change"),"slds-has-error");
        }
        
        if(selected=='Booth' && $A.util.isEmpty(component.find("Booth_Number").get("v.value"))){
            isvalid = false;
            $A.util.addClass(component.find("Booth_Number"),"slds-has-error");
        }
        else if(selected=='Sponsorship' && $A.util.isEmpty(component.find("Original_Sponsorship_Type").get("v.value"))){
            isvalid = false;
            $A.util.addClass(component.find("Original_Sponsorship_Type"),"slds-has-error");
        }
        else if(selected=='Digital' && $A.util.isEmpty(component.find("Current_Digital_Product").get("v.value"))){
            isvalid = false;
            $A.util.addClass(component.find("Current_Digital_Product"),"slds-has-error");
        }
        else if(selected=='Publishing' && $A.util.isEmpty(component.find("Current_Publishing_Product").get("v.value"))){
            isvalid = false;
            $A.util.addClass(component.find("Current_Publishing_Product"),"slds-has-error");   
        }
        else if(selected=='Non Product' && $A.util.isEmpty(component.find("Comments").get("v.value"))){
            isvalid = false;
            $A.util.addClass(component.find("Comments"),"slds-has-error");   
        }
        if(!isvalid){
            window._LtngUtility.toast('Error!','error','Please update the invalid form entries and try again.');
        }
        return isvalid; 
    }
})