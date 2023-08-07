({
	getMailContent : function(component,code) {
		var mailCode = component.get('v.mailMapCode');
		var mailMapCc = component.get('v.mailMapCc');
		var evntId = component.get('v.eventId');
		var emailCode = mailCode.get(code);
		var action = component.get("c.getEmailContent");
		action.setParams({
            evntId: evntId,
            emailCode:emailCode
		});
		action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {
				//console.log('emailContent==='+JSON.stringify(res.getReturnValue()));                
				component.set("v.emailContent", res.getReturnValue());
				// var objEditor = component.get("v.objEditor");
				// objEditor('', res.getReturnValue().Content__c); 
				component.set("v.ccEmail",mailMapCc.get(code));
				document.getElementById('modelEmailTemplateEditor').style.display = "block"; 
			}else
			{
				console.log('Some Error Occured!');	
			}
        });
        $A.enqueueAction(action); 
	},
	updateEmailTemplate : function(component) {
		var evtTmp = component.get("v.emailContent");
		// var objEditor = component.get("v.objEditor");
		// var content = objEditor('editor','' ,'getData');
		 var content1 = component.find("contentEditor").get("v.value");
		evtTmp.Content__c=content1;
		var emailContentCode = component.get("v.emailContentCode");
		var action = component.get("c.updateEmailContent");
		//console.log('emailContent==='+JSON.stringify(evtTmp)); 
		action.setParams({
            evtTmp: evtTmp
		});
		action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {
				
				document.getElementById('modelEmailTemplateEditor').style.display = "none";
				//this.getMailContent(component,emailContentCode);					
			}
		});
        $A.enqueueAction(action); 
	},
	mailExhWithoutCon :function(component) {
		var evntId = component.get('v.eventId');
		var mailMapCc = component.get('v.mailMapCc');
		var ccAddress = mailMapCc.get('exhNoCon');
		var action = component.get("c.mailExhibitorswithoutContractor");
		action.setParams({
		evntId: evntId,
		ccAddress : ccAddress
		});
		action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {
				console.log('Mailed!');
				document.getElementById('modelConfirm').style.display = "block"; 
				console.log(res.getReturnValue());
			}
		});
        $A.enqueueAction(action); 

	},
	mailExhPreShwReminder :function(component) {
		var evntId = component.get('v.eventId');
		var mailMapCc = component.get('v.mailMapCc');
		var ccAddress = mailMapCc.get('exhShw');
		var action = component.get("c.exhibitorPreShowReminder");
		action.setParams({
		evntId: evntId,
		ccAddress : ccAddress
		});
		action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {
				console.log('Mailed!');
				document.getElementById('modelConfirm').style.display = "block"; 
				console.log(res.getReturnValue());
			}
		});
        $A.enqueueAction(action); 
	},
	mailContPreShwReminder :function(component) {
		var evntId = component.get('v.eventId');
		var mailMapCc = component.get('v.mailMapCc');
		var ccAddress = mailMapCc.get('conShw');
		var action = component.get("c.contractorPreShowReminder");
		action.setParams({
		evntId: evntId,
		ccAddress : ccAddress
		});
		action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {
				console.log('Mailed!');
				document.getElementById('modelConfirm').style.display = "block"; 
				console.log(res.getReturnValue()); 
			}
		});
        $A.enqueueAction(action); 
	},
	mailContStatusReminder :function(component,dsnStatus,tmpCode,mapCode) {
		var evntId = component.get('v.eventId');
		var mailMapCc = component.get('v.mailMapCc');
		var ccAddress = mailMapCc.get(mapCode);
		var action = component.get("c.contractorStatusReminder");
		action.setParams({
			evntId	  : evntId,
			dsnStatus     : dsnStatus,
			tmpCode	  : tmpCode,
			ccAddress 	  : ccAddress
			
		});
		action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {
				console.log('Mailed!');
				document.getElementById('modelConfirm').style.display = "block"; 
				console.log(res.getReturnValue());
			}
		});
        $A.enqueueAction(action); 
	},
	mailPerformanceBondReminder :function(component) {
		var evntId = component.get('v.eventId');
		var mailMapCc = component.get('v.mailMapCc');
		var ccAddress = mailMapCc.get('prfmBond');
		var action = component.get("c.contractorPerformanceBondReminder");
		action.setParams({ 
			evntId	  : evntId,
			ccAddress     : ccAddress			
		});
		action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {
				console.log('Mailed!');
				console.log(res.getReturnValue());
				document.getElementById('modelConfirm').style.display = "block"; 
			}
			else{
				console.log('Some Error Occured!');
			}
		});
        $A.enqueueAction(action); 
	}
})