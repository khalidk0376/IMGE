({
	getTemplatesHelper  : function(component){
		component.set("v.isShowSpinner",true);		
		var action = component.get("c.getTemplates");
        action.setParams({qid:component.get("v.selectedTemplate")});
		action.setCallback(this,function(a){
			component.set("v.isShowSpinner",false);
            var obj = a.getReturnValue();
            component.set("v.template",obj);
            
            var nextbtncolor = obj.Next_Button_Color__c;
            if(nextbtncolor!=undefined && nextbtncolor.split('_').length==3){
                component.set("v.buttonBorderColor",nextbtncolor.split('_')[0]);
                component.set("v.buttonBGColor",nextbtncolor.split('_')[1]);
                component.set("v.buttonTextColor",nextbtncolor.split('_')[2]);
            }
            
            var prevbtncolor = obj.Previous_Button_Color__c;
            if(prevbtncolor!=undefined && prevbtncolor.split('_').length==3){
                component.set("v.buttonNextBorderColor",prevbtncolor.split('_')[0]);
                component.set("v.buttonNextBGColor",prevbtncolor.split('_')[1]);
                component.set("v.buttonNextTextColor",prevbtncolor.split('_')[2]);
            }
            
            var submitbtncolor = obj.Submit_Button_Color__c;
            if(submitbtncolor!=undefined && submitbtncolor.split('_').length==3){
                component.set("v.buttonPrevBorderColor",submitbtncolor.split('_')[0]);
                component.set("v.buttonPrevBGColor",submitbtncolor.split('_')[1]);
                component.set("v.buttonPrevTextColor",submitbtncolor.split('_')[2]);
            }
            
            if(obj.Is_Customize_Buttons__c!=undefined)
            component.set("v.isCustomButton",obj.Is_Customize_Buttons__c);
            if(obj.Buttons_Position__c!=undefined)
            component.set("v.buttonPosition",obj.Buttons_Position__c);                
            if(obj.Button_Alignment__c!=undefined)
            component.set("v.float",obj.Button_Alignment__c);

            if(obj.Button_Alignment__c!=undefined)
            component.set("v.buttonNextLabel",obj.Next_Button_Label__c);
            if(obj.Previous_Button_Label__c!=undefined)
            component.set("v.buttonPrevLabel",obj.Previous_Button_Label__c);
            if(obj.Submit_Button_Label__c!=undefined)
            component.set("v.buttonSubmitLabel",obj.Submit_Button_Label__c);
            component.set("v.isOpenSectionColorModal",true);
        })
        $A.enqueueAction(action);
	},
	getSectionsHelper  : function(component){
		component.set("v.isShowSpinner",true);
		var options=[];
		var action = component.get("c.getSections");
		action.setParams({qid:component.get("v.selectedTemplate")});
		action.setCallback(this,function(a){
			component.set("v.isShowSpinner",false);
            var datas = JSON.parse(a.getReturnValue());
        	for(var i=0;i<datas.length;i++)
        	{
        		options.push({label:datas[i].sectionName,value:datas[i].Question_Group__c})
        	}
        	component.set("v.sectionList",options);
        })
        $A.enqueueAction(action);
	},

    submitConfigData:function(component){
        component.set("v.isShowSpinner",true);

        var nextbtncolor = component.get("v.buttonBorderColor")+'_'+component.get("v.buttonBGColor")+'_'+component.get("v.buttonTextColor");
        var prevbtncolor = component.get("v.buttonNextBorderColor")+'_'+component.get("v.buttonNextBGColor")+'_'+component.get("v.buttonNextTextColor");
        var submitbtncolor = component.get("v.buttonPrevBorderColor")+'_'+component.get("v.buttonPrevBGColor")+'_'+component.get("v.buttonPrevTextColor");

        var options={
            "qid":component.get("v.selectedTemplate"),
            "alignment":component.get("v.float"),
            "nextButonLabel":component.get("v.buttonNextLabel"),
            "prevButonLabel":component.get("v.buttonPrevLabel"),
            "submitButonLabel":component.get("v.buttonSubmitLabel"),
            "nextButonColor":nextbtncolor,
            "prevButonColor":prevbtncolor,
            "submitButonColor":submitbtncolor,
            "isCutomize":component.get("v.isCustomButton"),
            "buttonPosition":component.get("v.buttonPosition")
        };

        var action = component.get("c.setAppData");
        action.setParams({datas:JSON.stringify(options)});

        action.setCallback(this,function(a){
            component.set("v.isOpenSectionColorModal",false);
            component.set("v.isShowSpinner",false);
            var datas = JSON.parse(a.getReturnValue());
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'Success!',
                message: 'Button configuration has been saved!',
                type: 'success',
            });
            toastEvent.fire();
            
            var appEvent = $A.get("e.c:QFFieldModelCloseEvt");            
            if(appEvent!=undefined){
                appEvent.setParams({"modelName": "customButton" });
                appEvent.fire();
            }
        })
        $A.enqueueAction(action);
    }
})