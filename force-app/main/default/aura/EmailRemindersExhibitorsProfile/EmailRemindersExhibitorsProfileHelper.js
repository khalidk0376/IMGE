({
	getMailContent : function(component) {
		var emailCode = 'EWSP';
		var evntId = component.get('v.eventId');
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
				var objEditor = component.get("v.objEditor");
				if(objEditor)
				{
					objEditor('', res.getReturnValue().Content__c); 
				}
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
	var objEditor = component.get("v.objEditor");
	if(objEditor)
	{
		var content = objEditor('editor','' ,'getData');
		if(content)
		{
			evtTmp.Content__c=content;
		}
	}
	
	var action = component.get("c.updateEmailContent");
	//console.log('emailContent==='+JSON.stringify(evtTmp)); 
	action.setParams({
		evtTmp: evtTmp
	});
	action.setCallback(this, function(res) {
		var state = res.getState();
		if (state === "SUCCESS") {
			//console.log(res.getReturnValue());
			document.getElementById('modelEmailTemplateEditor').style.display = "none";
			this.getMailContent(component);					
		}
	});
	$A.enqueueAction(action); 

	},
	mailExhWithoutPro:function(component) {
		var evntId = component.get('v.eventId');
		var action = component.get("c.mailExhibitorswithoutProfiles");
		action.setParams({
		evntId: evntId
		});
		action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {
				console.log('Mailed!');
				document.getElementById('modelSent').style.display = "block"; 
				console.log(res.getReturnValue());
			}
		});
        $A.enqueueAction(action); 

	}
})