({
	/* Modification Log----- 
    * Modified by : Girikon(Ashish)[CCEN-430] Dec 16 2018,
    **/
	onLoad: function(component,event,helper)
	{
		//helper.SetBoothMapId(component, event, helper);
		//helper.getStandDetails(component); 
    },
	scriptsLoaded: function(component, event, helper)
	{	
   	},
	showdataModal : function(component, event, helper)
	{
		document.getElementById('showdata').style.display = "block";
	},
	hideshowdataModal: function(component, event, helper)
	{
		document.getElementById('showdata').style.display = "none";
	},
	copytoclipboard: function(component, event, helper)
	{
		// var copydata ;
		//CopyToClipBoard.CopyData(component,"venueinfo"); 
		var textForCopy = component.find('venueinfo').getElement().textContent;
		//var textForCopy = component.find('venueinfo').getElement().textContent;
		//var textForCopy = document.getElementById('venueinfo').textContent;
		//alert(textForCopy);
        // calling common helper class to copy selected text value
		helper.copyTextHelper(component,event,textForCopy); 
	},
	BoothMapIdChange: function(component, event, helper)
	{ 
		var accId=component.get("v.childsingleBooth[0].Contact__r.AccountId");
		helper.getStandDetails(component);
		if(accId)
		{
			helper.FindSubcontractorsAndStandDetails(component, event, helper);
			helper.getStandDetails(component);
		}
	},
    loginAsUser:function(component, event, helper)
    {
        var BoothContactMappngId = event.getSource().get("v.value");
       	helper.getLoginCtrDetails(component, event , BoothContactMappngId);
    },
    handleClick: function(component, event, helper)
    {
        var ContId = event.getSource().get("v.value");
        console.log('testCintID',ContId);
        helper.sendEmail(component, event , ContId);
    },
    resetPassword: function(component, event, helper)
    {
         var sContId = event.getSource().get("v.value");
         helper.resetPassword(component, event , sContId);
    },
    showSpinner: function (component, event, helper) {
		component.set("v.Spinner", true); // Adding values in Aura attribute variable.
	},
})