({
	onLoad : function(component, event, helper) 
  {
    component.set("v.eventcode",helper.getUrlParameter(component,'eventcode'));
    var aoeAccId = helper.getUrlParameter(component,'accid');
    var accId18 = helper.getUrlParameter(component,'accid'); //BK-12603
    if(aoeAccId)
    {
      aoeAccId = (aoeAccId.length > 15) ? aoeAccId.substring(0,15):aoeAccId; // To get salesforce Id  
    }
    component.set("v.AOEAccountID",aoeAccId);
    component.set("v.accountId18",accId18);
    // var eventcode = component.get("v.eventcode");
    // var aoeAccId = component.get("v.AOEAccountID");
    // console.log('eventcode : '+ eventcode + 'aoeAccId '+ aoeAccId);
    helper.fetchEventDetails(component);
    helper.fetchAccountDetails(component);
    helper.fetchReadOrWriteMode(component);
  },
	goToHome:function(component, event, helper) {
    var url =window.location.href;
    let eventcode = component.get('v.eventcode');
    if(url.includes('/s/'))
    {
			window.location.href='/CustomerCenter/s/?eventcode='+eventcode;
		}
		else{
			window.location.href='home?eventcode='+eventcode;
		}
	},
  goToMyAOE:function(component, event, helper) 
  {
    var url =window.location.href;
    let eventcode = component.get('v.eventcode');
    if(url.includes('/s/'))
    {
			window.location.href='/CustomerCenter/s/agentownexhibitors?eventcode='+eventcode;
		}
		else{
			window.location.href='home?eventcode='+eventcode;
		}
	}
})