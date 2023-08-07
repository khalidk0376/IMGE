({
	loadData: function (component, event,helper) {                 
        component.set("v.showSpinner",true); 
        helper.checkSalesOpsUser(component);
        helper.checkBrasilConSales(component);
        helper.fetchOpp(component);     
        helper.fetchUser(component);
    	helper.getUserAccess(component);       
        var getSelected = localStorage.getItem('selectedAccordiansOpp');
        if (getSelected) 
        { 
            component.set("v.activeSections",JSON.parse(getSelected));
        }
    },
    
    handleSectionToggle: function(component, event) {
        localStorage.setItem('selectedAccordiansOpp',JSON.stringify(component.find("oppAccordion").get('v.activeSectionName')));
    },
    
    editRecord: function (component, event,helper) { 
        console.log('oppViewForm');
    	if(component.get("v.usrAccess").HasEditAccess)
    	{
    		component.set("v.isEditForm",true);//         
    	}
    	else
    	{
    		 window._LtngUtility.toast('Error','error','You have no access to edit this record.');
    	}	
    },
    handleError: function(component,event,helper){    
        component.set('v.showSpinner', false);    
        window._LtngUtility.handleError(event.getParams().error);
    },
    showModal: function (component, event,helper) { 
        helper.fetchCurrency(component);
        component.set('v.isOpen', true); 
    },
    closeModal: function (component, event,helper) { 
        component.set('v.isOpen', false); 
    },
    saveCurrency: function (component, event,helper) { 
          helper.updateCurrency(component); 
    },
})