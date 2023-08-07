({
	doInit : function(cmp, event, helper) {
		helper.fetchUser(cmp);
		var getSelected = localStorage.getItem('selectedAccordiansCon');
		if (getSelected) 
		{ 
		cmp.set("v.activeSections",JSON.parse(getSelected));
		}
	},
	handleSectionToggle: function(cmp, event) {
		localStorage.setItem('selectedAccordiansCon',JSON.stringify(cmp.find("accordionCon").get('v.activeSectionName')));
	},
	editRecord: function (cmp, event,helper) { 
		cmp.set("v.isEditForm",true);
	}
    /*openModel: function(component, event, helper) {
      // for Display Model,set the "isOpen" attribute to "true"
      component.set("v.isOpen", true);
   },*/
})