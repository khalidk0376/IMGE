({
	OnloadData: function (component, event, helper) {
		if (!component.get("v.eventcode")) {
			var url = window.location.href;
			var eventcode = helper.GetQS(component,url,'eventcode');
			component.set("v.eventcode",eventcode);
		}
		if (!component.get("v.customPageName")) {
			var url = window.location.href;
			var allParams = url.split('/')[5];
			var customPage = allParams.split('?')[0];
			if(customPage == 'custompage1')
			{
			  component.set("v.customPageName", customPage);
			}
			else if(customPage == 'custompage2'){
			  component.set("v.customPageName", customPage);
			}
			else if(customPage == 'custompage3'){
				component.set("v.customPageName", customPage);
			  }
	   }

	

		helper.helperOnloadData(component);
		helper.fetchEventDetails(component);
	},
	gotohome: function (component, event, helper) {
		var custPageName = component.get("v.customPageName");
		var eventCode = component.get("v.eventcode");
		if(custPageName == 'Custom Page 1' || custPageName == 'Custom Page 2' || custPageName == 'Custom Page 3'){
			window.location.href = "/CustomerCenter/home?eventcode=" + eventCode;
		}
		else if (custPageName == 'custompage1' || custPageName == 'custompage2' || custPageName == 'custompage3')
		window.location.href = "/CustomerCenter/s/?eventcode=" + eventCode;
	}
})