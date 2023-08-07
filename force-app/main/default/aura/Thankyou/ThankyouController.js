({
	doInit : function(component, event, helper) {
		component.set("v.qid",helper.getParameterByName('qid'));
	},
	downloadResponse : function(component, event, helper) {
		//component.set("v.downloadLink",'https://girikonformbuilder-developer-edition.na50.force.com/DownloadResponsePDF?qnaireId=' + component.get('v.qid'));
		component.find("download-link").getElement().click();		
	}
})