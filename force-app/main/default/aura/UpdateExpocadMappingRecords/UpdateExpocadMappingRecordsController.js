({
	doInit: function(component, event, helper) {
        helper.fetchPickListVal(component, 'Relation__c', 'relationPicklistOpts');
    },
    
    inlineEditRelation : function(component,event,helper){  
        component.set("v.ralationEditMode", true);
        component.find("expoRelation").set("v.options" , component.get("v.relationPicklistOpts"));
        setTimeout(function(){
            component.find("expoRelation").focus();
        }, 100);
    },
    
    inlineRelatedOppEditMode : function(component,event,helper){  
        component.set("v.RelatedOppEditMode", true);  
        component.set("v.isOpenOpportunityModal", true);                
    },
    
     onRelationChange : function(component,event,helper){
        component.set("v.showSaveCancelBtn",true);
        var relationvalue =  component.find("expoRelation").get("v.value");
        if(relationvalue == 'Agent')
        {
            alert("If related opportunity already exist , please fill in related opportunity value");
        }
        else
        {
            var UpdatereturnVal = component.get("v.singleOppExpoMapping");
            UpdatereturnVal.Related_Opportunity__c = '';
            UpdatereturnVal.Related_Opportunity__r = '';
            component.set("v.singleOppExpoMapping" , UpdatereturnVal);   

        }
    }, 
    
    closeRelationBox : function (component, event, helper) {
        component.set("v.ralationEditMode", false);
    },
    
    closeModal : function (component, event, helper) {
        component.set("v.isOpenOpportunityModal", false);
    }
    
})