({
	doInit: function(component, event, helper) {
        helper.fetchPickListVal(component, 'Matched_Product_Name__c', 'MatchProductPicklistOpts');
    },
    
    inlineEditMatchPrdtName : function(component,event,helper){  
        component.set("v.MatchPrdtnameEditMode", true);
        component.find("expoMatchPrdt").set("v.options" , component.get("v.MatchProductPicklistOpts"));
        setTimeout(function(){
            component.find("expoMatchPrdt").focus();
        }, 100);
    },
    
     onMatchPrdtNameChange : function(component,event,helper){
        component.set("v.showSaveCancelBtnOnMPNUpdate",true);
    }, 
    
    closeMatchPrdtName : function (component, event, helper) {
        component.set("v.MatchPrdtnameEditMode", false);
    },
    
    inlineEditProductType : function(component,event,helper){  
        component.set("v.productTypeEditMode", true);
        setTimeout(function(){
            component.find("ProductType").focus();
        }, 100);
    },
    
     onProductTypeChange : function(component,event,helper){
        component.set("v.showSaveCancelBtnOnMPNUpdate",true);
    }, 
    
    closeProductType : function (component, event, helper) {
        component.set("v.productTypeEditMode", false);
    }
})