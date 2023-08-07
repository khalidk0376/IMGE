({
    doInit: function(component, event, helper) {
        window.onscroll = function() {};
        console.log('do init method called in child');
        var  eventCode = component.get("v.eventEditionCode");
        //console.log('value of eventCode#####',eventCode);
        var uploadfilevalidMap = new Map();
        component.set("v.validmap",uploadfilevalidMap);
        var signMap = new Map();
        component.set("v.SigMap",signMap);
        var checkDataMap =new Map();
        component.set("v.checkDataMap",checkDataMap);
      	var vQnaireId = component.get("v.recordId");
        var recordId = component.get("v.recordId");
        if((vQnaireId==undefined || vQnaireId==null || vQnaireId=='null' || vQnaireId=='') && (recordId==undefined ||recordId==null || recordId=='null'||recordId=='')){
            component.set("v.Spinner", false);
            component.set("v.recordId",helper.getParameterByName('Id'));
            recordId = helper.getParameterByName('Id');
            if(recordId==undefined ||recordId==null || recordId=='null'||recordId==''){
            	return;    
            }
        }
       //console.log('recordId===='+component.get("v.recordId"));
       //console.log('AccId===='+component.get("v.AccId"));
        if(vQnaireId!=undefined && vQnaireId!=null && vQnaireId!='null' && vQnaireId!=''){
            component.set("v.recordId",recordId);
            component.set("v.QnaireId",recordId);
        }else{
            component.set("v.QnaireId",component.get("v.recordId"));
        }     
      //  console.log('vQnaireId======'+vQnaireId);
       // console.log('recordId======'+recordId);
        helper.backtoFormHelper(component);
        helper.getQuestionnaireRecord(component, event);
        helper.getQuesCategory(component, event);
        helper.getFormName(component);
    },
 
    nextSection:function(component,event,helper){        
        var isValid1 = helper.validateForm(component);
        var isValid2 = helper.validateForm2(component);
        var isValidLookupField = component.get("v.isLookupFiledValid");
        //console.log(isValid1+','+isValid2+','+isValidLookupField);
		if(isValid1 && isValid2 && isValidLookupField){
            //Save filled form value
            helper.saveQuestionResponseHelper(component);    
			//code to get next section questions
            var detailtemp = [];
            var questionSection=component.get("v.lstQuesGroup");
            var sectionNo= component.get("v.keepSectionNo");
            var vQnaireId = component.get("v.QnaireId");
            var vSectionId = questionSection[sectionNo+1].Question_Group__c;
            helper.getAllQuestion(component, event, vQnaireId, vSectionId);
            component.set("v.disablePrevSection",true);
            var length=questionSection.length-1;
            sectionNo = sectionNo+1;
            document.documentElement.scrollTop = 0;
            if(sectionNo<length){
                component.set("v.keepSectionNo",sectionNo);
            }
            if(sectionNo===length){
                component.set("v.keepSectionNo",sectionNo);
                component.set("v.disableNextSection",false);
            }
        }
        else
        {
            helper.showNewToast(component,'ERROR : ','error','Please update the invalid form entries and try again.');
        }
    },
     goToNewPage: function(component, event, helper) {
        var idsToDelete =component.get("v.SigMap");
        var newIdsToDelete =component.get("v.listNewAttchIds"); 
        idsToDelete.forEach(function(value, key) {
            console.log(key + ' = ' + value);
            var newAttchLst = value.substr(35);
            newIdsToDelete.push(newAttchLst);
            console.log('newIdsToDelete'+newIdsToDelete);
        });	
        helper.deleteOldAttchmntIds(component)
        window.history.back();
        //window.open("https://ws10devpro-globalexhibitions.cs90.force.com/forms?eventcode=tocesb", "_self");
	},
     
    previousSection:function(component,event,helper){
        var detailtemp = [];
        var questionSection=component.get("v.lstQuesGroup");
        var sectionNo= component.get("v.keepSectionNo");
        var vQnaireId = component.get("v.QnaireId");
        sectionNo = sectionNo-1;
        var vSectionId = questionSection[sectionNo].Question_Group__c;
        component.set("v.disableNextSection",true);
        
        component.set("v.keepSectionNo",sectionNo);
        document.body.scrollTop = 0;
        document.documentElement.scrollTop = 0;
        if(sectionNo===0){
            component.set("v.disablePrevSection",false);
        }

        var tempResponseList = component.get("v.tempResponseList");
        tempResponseList.pop();
        component.set("v.tempResponseList",tempResponseList);
        console.log('Click Previous');
        console.log(tempResponseList);

        helper.getAllQuestion(component, event, vQnaireId, vSectionId);
    },
    saveResponseClick:function(component,event,helper){
       
        var isValid1 = helper.validateForm(component);
        var isValid2 = helper.validateForm2(component);
        var isValid3 = helper.validateForm3(component);
   		// Added regarding ticket [CCEN-679] for make required Upload Media File. 
        var mapVal = component.get('v.validmap');
        var isValid4 = true;
        var isValid5 = true;
        for(var val of mapVal.keys())
		{
        //console.log('map== '+val);
        //console.log('val== '+mapVal.get(val));
            if(mapVal.get(val) == false)
            {
                isValid4 = false;
                document.getElementById(val).style.display = "block";
            }

        }
        var isValidLookupField = component.get("v.isLookupFiledValid");
       	var responseUrl=component.get("v.response");
        //var checkImageData = component.get("v.checkData");
     	var SignMapVal = component.get("v.SigMap");
        var checkData = component.get("v.checkDataMap");
      	var listSignIds=component.get("v.listAttchIds");
        var data = component.get("v.lstQQuesnnaire.sectionList");
        for(var i=0;i<data.length;i++)
        {
            if(data[i].sectionColNumber=='0' || data[i].sectionColNumber=='1'){
               if(data[i].col1Questions.lstQuestn!=undefined){
                    for(var j=0 ; j<data[i].col1Questions.lstQuestn.length ; j++)
                    {
                        var signType =data[i].col1Questions.lstQuestn[j].Type__c;
                        if(signType == 'Signature')
                        {
                            var Required =data[i].col1Questions.lstQuestn[j].Required__c;
                            console.log('1'+Required);
                            for(var k=0 ; k<data[i].col1Questions.lstQuestn[j].Question_Questionnaires__r.length ; k++)
                            {
                                var quanaire =data[i].col1Questions.lstQuestn[j].Question_Questionnaires__r[k].Question__c;
                                var responseSign=data[i].col1Questions.lstQuestn[j].Question_Questionnaires__r[k].responseValue1;
                                console.log('responseSign'+responseSign);
                                console.log('responseUrl'+responseUrl);
                                if(responseSign =='' && Required == true && SignMapVal.get(quanaire)==undefined && checkData.has(quanaire)==false)
                                {
                                    var isValid5 = false;
                                }
                                if(SignMapVal.has(quanaire)==true && SignMapVal.get(quanaire)!=undefined && checkData.has(quanaire)==true)
                                {
                                    var checkImage =checkData.get(quanaire);
                                    if(signType == 'Signature' && Required == true && checkImage== false)
                                    {
                                       	var isValid5 = false;
                                        document.getElementById("signatureUpload").style.display = "block";
                                    }
                                  	else
                                    {
                                        console.log('lstValue'+data[i].col1Questions.lstQuestn[j].Question_Questionnaires__r[k].responseValue1);
                                        var oldLstValues=data[i].col1Questions.lstQuestn[j].Question_Questionnaires__r[k].responseValue1
                                        var oldAttchLst = oldLstValues.substr(35);
                                        listSignIds.push(oldAttchLst);
                                        data[i].col1Questions.lstQuestn[j].Question_Questionnaires__r[k].responseValue1 = SignMapVal.get(quanaire);    
                                        console.log('lstValue'+data[i].col1Questions.lstQuestn[j].Question_Questionnaires__r[k].responseValue1);
                                        document.getElementById("signatureUpload").style.display = "none";
                                    }
                                }
                            }
                        }
                    }
                }
            }
            if(data[i].sectionColNumber=='2'){
               if(data[i].col1Questions.lstQuestn!=undefined){
                   for(var j=0 ; j<data[i].col1Questions.lstQuestn.length ; j++)
                    {
                        var signType=data[i].col1Questions.lstQuestn[j].Type__c;
                        if(signType == 'Signature')
                        {
                            var Required =data[i].col1Questions.lstQuestn[j].Required__c;
                            console.log('1'+Required);
                            for(var k=0 ; k<data[i].col1Questions.lstQuestn[j].Question_Questionnaires__r.length ; k++)
                            {
                                var quanaire =data[i].col1Questions.lstQuestn[j].Question_Questionnaires__r[k].Question__c;
                                var responseSign=data[i].col1Questions.lstQuestn[j].Question_Questionnaires__r[k].responseValue1;
                                console.log('responseSign'+responseSign);
                                if(responseSign =='' && Required == true && SignMapVal.get(quanaire)==undefined && checkData.has(quanaire)==false)
                                {
                                    var isValid5 = false;
                                }
                                if(SignMapVal.has(quanaire)==true && SignMapVal.get(quanaire)!=undefined && checkData.has(quanaire)==true)
                                {
                                    var checkImage =checkData.get(quanaire);
                                    if(signType == 'Signature' && Required ==true && checkImage== false)
                                    {
                                        var isValid5 = false;
                                        document.getElementById("signatureUpload").style.display = "block";
                                    }
                                   	else
                                    {
                                        console.log('lstValue'+data[i].col1Questions.lstQuestn[j].Question_Questionnaires__r[k].responseValue1);
                                        var oldLstValues=data[i].col1Questions.lstQuestn[j].Question_Questionnaires__r[k].responseValue1
                                        var oldAttchLst = oldLstValues.substr(35);
                                        listSignIds.push(oldAttchLst);
                                        data[i].col1Questions.lstQuestn[j].Question_Questionnaires__r[k].responseValue1 = SignMapVal.get(quanaire);    
                                        console.log('lstValue'+data[i].col1Questions.lstQuestn[j].Question_Questionnaires__r[k].responseValue1);
                                        document.getElementById("signatureUpload").style.display = "none";
                                    }
                                }
                            }
                        }
                    } 
                }
               if(data[i].col2Questions.lstQuestn!=undefined){
                    for(var j=0 ; j<data[i].col2Questions.lstQuestn.length ; j++)
                    {
                        var signType=data[i].col2Questions.lstQuestn[j].Type__c;
                        if(signType == 'Signature')
                        { 
                            var Required =data[i].col2Questions.lstQuestn[j].Required__c;
                            console.log('1'+Required);
                            for(var k=0 ; k<data[i].col2Questions.lstQuestn[j].Question_Questionnaires__r.length ; k++)
                            {
                                var quanaire =data[i].col2Questions.lstQuestn[j].Question_Questionnaires__r[k].Question__c;
                                var responseSign=data[i].col2Questions.lstQuestn[j].Question_Questionnaires__r[k].responseValue1;
                                console.log('responseSign'+responseSign);
                                if(responseSign =='' && Required == true && SignMapVal.get(quanaire)==undefined && checkData.has(quanaire)==false)
                                {
                                    	var isValid5 = false;
                                }
                                if(SignMapVal.has(quanaire)==true && SignMapVal.get(quanaire)!=undefined && checkData.has(quanaire)==true)
                                {
                                    var checkImage =checkData.get(quanaire);
                                   if(signType == 'Signature' && Required ==true && checkImage== false)
                                    {
                                      	var isValid5 = false;
                                        document.getElementById("signatureUpload").style.display = "block";
                                    }
                                   	else
                                    {
                                        console.log('lstValue'+data[i].col2Questions.lstQuestn[j].Question_Questionnaires__r[k].responseValue1);
                                        var oldLstValues=data[i].col2Questions.lstQuestn[j].Question_Questionnaires__r[k].responseValue1
                                        var oldAttchLst = oldLstValues.substr(35);
                                        listSignIds.push(oldAttchLst);
                                        data[i].col2Questions.lstQuestn[j].Question_Questionnaires__r[k].responseValue1 = SignMapVal.get(quanaire);    
                                        console.log('lstValue'+data[i].col2Questions.lstQuestn[j].Question_Questionnaires__r[k].responseValue1);
                                        document.getElementById("signatureUpload").style.display = "none";
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            if(data[i].sectionColNumber=='3'){
              if(data[i].col1Questions.lstQuestn!=undefined){
                    for(var j=0 ; j<data[i].col1Questions.lstQuestn.length ; j++)
                    {
                        var signType=data[i].col1Questions.lstQuestn[j].Type__c;
                        if(signType == 'Signature')
                        {
                            var Required =data[i].col1Questions.lstQuestn[j].Required__c;
                            console.log('1'+Required);
                            for(var k=0 ; k<data[i].col1Questions.lstQuestn[j].Question_Questionnaires__r.length ; k++)
                            {
                                var quanaire =data[i].col1Questions.lstQuestn[j].Question_Questionnaires__r[k].Question__c;
                                var responseSign=data[i].col1Questions.lstQuestn[j].Question_Questionnaires__r[k].responseValue1;
                                console.log('responseSign'+responseSign);
                                if(responseSign =='' && Required == true && SignMapVal.get(quanaire)==undefined && checkData.has(quanaire)==false)
                                {
                                    	var isValid5 = false;
                                }
                                if(SignMapVal.has(quanaire)==true && SignMapVal.get(quanaire)!=undefined && checkData.has(quanaire)==true)
                                {
                                    var checkImage =checkData.get(quanaire);
                                    if(signType == 'Signature' && Required ==true && checkImage== false)
                                    {
                                        var isValid5 = false;
                                        document.getElementById("signatureUpload").style.display = "block";
                                    }
                                   	else
                                    {
                                        console.log('lstValue'+data[i].col1Questions.lstQuestn[j].Question_Questionnaires__r[k].responseValue1);
                                        var oldLstValues=data[i].col1Questions.lstQuestn[j].Question_Questionnaires__r[k].responseValue1
                                        var oldAttchLst = oldLstValues.substr(35);
                                        listSignIds.push(oldAttchLst);
                                        data[i].col1Questions.lstQuestn[j].Question_Questionnaires__r[k].responseValue1 = SignMapVal.get(quanaire);    
                                        console.log('lstValue'+data[i].col1Questions.lstQuestn[j].Question_Questionnaires__r[k].responseValue1);
                                        document.getElementById("signatureUpload").style.display = "none";
                                    }
                                }
                            }
                        }
                    }
                }
                if(data[i].col2Questions.lstQuestn!=undefined){
                    for(var j=0 ; j<data[i].col2Questions.lstQuestn.length ; j++)
                    {
                        var signType=data[i].col2Questions.lstQuestn[j].Type__c;
                        if(signType == 'Signature')
                        {
                            var Required =data[i].col2Questions.lstQuestn[j].Required__c;
                            console.log('1'+Required);
                            for(var k=0 ; k<data[i].col2Questions.lstQuestn[j].Question_Questionnaires__r.length ; k++)
                            {
                                var quanaire =data[i].col2Questions.lstQuestn[j].Question_Questionnaires__r[k].Question__c;
                                var responseSign=data[i].col2Questions.lstQuestn[j].Question_Questionnaires__r[k].responseValue1;
                                console.log('responseSign'+responseSign);
                                if(responseSign =='' && Required == true && SignMapVal.get(quanaire)==undefined && checkData.has(quanaire)==false)
                                {
                                    	var isValid5 = false;
                                }
                                if(SignMapVal.has(quanaire)==true && SignMapVal.get(quanaire)!=undefined && checkData.has(quanaire)==true)
                                {
                                    var checkImage =checkData.get(quanaire);
                                    if(signType == 'Signature' && Required ==true && checkImage== false)
                                    {
                                        var isValid5 = false;
                                        document.getElementById("signatureUpload").style.display = "block";
                                    }
                                   	else
                                    {
                                        console.log('lstValue'+data[i].col2Questions.lstQuestn[j].Question_Questionnaires__r[k].responseValue1);
                                        var oldLstValues=data[i].col2Questions.lstQuestn[j].Question_Questionnaires__r[k].responseValue1
                                        var oldAttchLst = oldLstValues.substr(35);
                                        listSignIds.push(oldAttchLst);
                                        data[i].col2Questions.lstQuestn[j].Question_Questionnaires__r[k].responseValue1 = SignMapVal.get(quanaire);    
                                        console.log('lstValue'+data[i].col2Questions.lstQuestn[j].Question_Questionnaires__r[k].responseValue1);
                                        document.getElementById("signatureUpload").style.display = "none";
                                    }
                                }
                            }
                        }
                    }
                }
                if(data[i].col3Questions.lstQuestn!=undefined){
                    for(var j=0 ; j<data[i].col3Questions.lstQuestn.length ; j++)
                    {
                        var signType=data[i].col3Questions.lstQuestn[j].Type__c;
                        if(signType == 'Signature')
                        {
                            var Required =data[i].col2Questions.lstQuestn[j].Required__c;
                            console.log('1'+Required);
                            for(var k=0 ; k<data[i].col2Questions.lstQuestn[j].Question_Questionnaires__r.length ; k++)
                            {
                                var quanaire =data[i].col2Questions.lstQuestn[j].Question_Questionnaires__r[k].Question__c;
                                var responseSign=data[i].col2Questions.lstQuestn[j].Question_Questionnaires__r[k].responseValue1;
                                console.log('responseSign'+responseSign);
                                if(responseSign =='' && Required == true && SignMapVal.get(quanaire)==undefined && checkData.has(quanaire)==false)
                                {
                                    	var isValid5 = false;
                                }
                                if(SignMapVal.has(quanaire)==true && SignMapVal.get(quanaire)!=undefined && checkData.has(quanaire)==true)
                                {
                                    var checkImage =checkData.get(quanaire);
                                    if(signType == 'Signature' && Required ==true && checkImage== false)
                                    {
                                        var isValid5 = false;
                                        document.getElementById("signatureUpload").style.display = "block";
                                    }
                                  	else
                                    {
                                        console.log('lstValue'+data[i].col2Questions.lstQuestn[j].Question_Questionnaires__r[k].responseValue1);
                                        var oldLstValues=data[i].col2Questions.lstQuestn[j].Question_Questionnaires__r[k].responseValue1
                                        var oldAttchLst = oldLstValues.substr(35);
                                        listSignIds.push(oldAttchLst);
                                        data[i].col2Questions.lstQuestn[j].Question_Questionnaires__r[k].responseValue1 = SignMapVal.get(quanaire);    
                                        console.log('lstValue'+data[i].col2Questions.lstQuestn[j].Question_Questionnaires__r[k].responseValue1);
                                        document.getElementById("signatureUpload").style.display = "none";
                                    }
                                }
                            }
                        }
                    }
                }
            }
         
        }
    if(isValid1 && isValid2 && isValidLookupField && isValid3 && isValid4 && isValid5)
        {      
            component.set("v.islastSection",true);
            helper.saveQuestionResponseHelper(component);  
        }
        else
        {
            // if(isValid4 == false)
            //  {
            //     helper.showNewToast(component,"Error:",'error','Please upload All required Media files which indicating with * !');
            //  }else
            //  {
                helper.showNewToast(component,'ERROR : ','error','Please update the invalid form entries and try again.');           
        }
     },
    handleLookupValidationInfoEvent:function(component,event,helper){
        component.set("v.isLookupFiledValid",true);
        var lookupValues = component.get("v.lookupValues");        
        var isValid = event.getParam("isValid");
        var questionId = event.getParam("questionId");
        for(var i=0;i<lookupValues.length;i++)
        {
            if(lookupValues[i].questionId==questionId){
                lookupValues.splice(i,1);
            }                
        }
        lookupValues.push({questionId:questionId,isValid:isValid});
        component.set("v.lookupValues",lookupValues);
        for(var i=0;i<lookupValues.length;i++)
        {
            if(!lookupValues[i].isValid){
                component.set("v.isLookupFiledValid",false);
            }
        }
        //console.log(lookupValues);
    },
    handleLookupValueEvent:function(component, event, helper){
        
        var qid = event.getParam("questionId"),fval = event.getParam("responseText");
        //var lstQuestion = component.get("v.lstQQuesnnaire");
        var sectionList = component.get("v.lstQQuesnnaire.sectionList");

        if (sectionList !== undefined  && sectionList.length > 0)
        {
            //section looping
            for(var i=0;i<sectionList.length;i++)
            {
                if(sectionList[i].sectionColNumber=='0' || sectionList[i].sectionColNumber=='1')
                {
                    if(sectionList[i].col1Questions.lstQuestn.length>0)
                    {
                        for(var j=0;j<sectionList[i].col1Questions.lstQuestn.length;j++)
                        {
                            if(sectionList[i].col1Questions.lstQuestn[j].Type__c==='Lookup' && sectionList[i].col1Questions.lstQuestn[j].Id==qid)
                            {
                                sectionList[i].col1Questions.lstQuestn[resIndex].Question_Questionnaires__r[0].responseValue1 = fval;
                            }
                        }
                    }
                }
                
                if(sectionList[i].sectionColNumber=='2'){
                    if(sectionList[i].col1Questions.lstQuestn.length>0){
                        for(var j=0;j<sectionList[i].col1Questions.lstQuestn.length;j++)
                        {
                            if(sectionList[i].col1Questions.lstQuestn[j].Type__c==='Lookup' && sectionList[i].col1Questions.lstQuestn[j].Id==qid)
                            {
                                sectionList[i].col1Questions.lstQuestn[resIndex].Question_Questionnaires__r[0].responseValue1 = fval;
                            }
                        }
                    }

                    if(sectionList[i].col2Questions.lstQuestn.length>0){
                        for(var j=0;j<sectionList[i].col2Questions.lstQuestn.length;j++)
                        {
                            if(sectionList[i].col2Questions.lstQuestn[j].Type__c==='Lookup' && sectionList[i].col2Questions.lstQuestn[j].Id==qid)
                            {
                                sectionList[i].col2Questions.lstQuestn[resIndex].Question_Questionnaires__r[0].responseValue1 = fval;
                            }
                        }
                    }
                }

                if(sectionList[i].sectionColNumber=='3'){
                    if(sectionList[i].col1Questions.lstQuestn.length>0){
                        for(var j=0;j<sectionList[i].col1Questions.lstQuestn.length;j++)
                        {
                            if(sectionList[i].col1Questions.lstQuestn[j].Type__c==='Lookup' && sectionList[i].col1Questions.lstQuestn[j].Id==qid)
                            {
                                sectionList[i].col1Questions.lstQuestn[resIndex].Question_Questionnaires__r[0].responseValue1 = fval;
                            }
                        }
                    }

                    if(sectionList[i].col2Questions.lstQuestn.length>0){
                        for(var j=0;j<sectionList[i].col2Questions.lstQuestn.length;j++)
                        {
                            if(sectionList[i].col2Questions.lstQuestn[j].Type__c==='Lookup' && sectionList[i].col2Questions.lstQuestn[j].Id==qid)
                            {
                                sectionList[i].col2Questions.lstQuestn[resIndex].Question_Questionnaires__r[0].responseValue1 = fval;
                            }
                        }
                    }
                    if(sectionList[i].col3Questions.lstQuestn.length>0){
                        for(var j=0;j<sectionList[i].col3Questions.lstQuestn.length;j++)
                        {
                            if(sectionList[i].col3Questions.lstQuestn[j].Type__c==='Lookup' && sectionList[i].col3Questions.lstQuestn[j].Id==qid)
                            {
                                sectionList[i].col3Questions.lstQuestn[resIndex].Question_Questionnaires__r[0].responseValue1 = fval;
                            }
                        }
                    }
                }
            }            
        }
    },
    
    getCurrentLocation: function(component, event, helper) {
        var questionId = event.getSource().get("v.value");
        
        //GeoBtn_0_col1Questions_2
        console.log(event.getSource().get("v.name"));
        try{
            var arr = event.getSource().get("v.name").split("_");
            var index,branchingIndex,sectionIndex,col='';
            if(arr.length==5){
                index = parseInt(arr[1], 10);
                branchingIndex = parseInt(arr[2], 10);
                sectionIndex = parseInt(arr[4], 10);
                col = arr[3];
            }
            else
            {
                index = parseInt(arr[1], 10);
                branchingIndex = 0;
                sectionIndex = parseInt(arr[3], 10);
                col = arr[2];   
            }

            
            var listsect = component.get("v.lstQQuesnnaire.sectionList");
            var listquestions = [];
            
            if(col=="col1Questions"){
                listquestions = listsect[sectionIndex].col1Questions;
            }
            else if(col=="col2Questions"){
                listquestions = listsect[sectionIndex].col2Questions;
            }
            else if(col=="col3Questions"){
                listquestions = listsect[sectionIndex].col3Questions;
            }
            console.log('index::'+index+',sectionIndex::'+sectionIndex+',col::'+col)
            if (navigator.geolocation) {
                
                navigator.geolocation.getCurrentPosition(function(position) {
                    
                    //listquestions[index].Lat = position.coords.latitude;
                    //listquestions[index].Lng = position.coords.longitude;
                    console.log(JSON.stringify(listquestions));

                    if(listquestions.lstQuestn[index].Question_Questionnaires__r[0].branchingQuestnQuetnnaire!=undefined)
                    {
                        listquestions.lstQuestn[index].Question_Questionnaires__r[0].branchingQuestnQuetnnaire[branchingIndex].responseValue1 = position.coords.latitude;
                        listquestions.lstQuestn[index].Question_Questionnaires__r[0].branchingQuestnQuetnnaire[branchingIndex].responseValue2 = position.coords.longitude;
                    }
                    else
                    {
                        listquestions.lstQuestn[index].Question_Questionnaires__r[0].responseValue1 = position.coords.latitude;
                        listquestions.lstQuestn[index].Question_Questionnaires__r[0].responseValue2 = position.coords.longitude;    
                    }

                    if(col=="col1Questions"){
                        listsect[sectionIndex].col1Questions = listquestions;
                    }
                    else if(col=="col2Questions"){
                        listsect[sectionIndex].col2Questions = listquestions;
                    }
                    else if(col=="col3Questions"){
                        listsect[sectionIndex].col3Questions = listquestions;
                    }
                    component.set("v.lstQQuesnnaire.sectionList", listsect);
                });
            } else {
                helper.showNewToast(component,'Error: ', 'error', 'Geo Location is not supported');
            }
        }
        catch(e)
        {
            console.log(e);
        }
    },
    
    checkboxOption : function(component, event, helper){
        try
        {
            var mainQuestionOptionId ="";
            var arr = event.getSource().get("v.name").split("_");
            var index = parseInt(arr[1], 10);
            var col = arr[2];
            var sectionIndex = arr[3];
            var branchingIndex=-1;

            if(arr.length>4){
                branchingIndex = arr[4];
            }

            var listsect = component.get("v.lstQQuesnnaire.sectionList");
            var listquestions = [];

            if(col=="col1Questions"){
                listquestions = listsect[sectionIndex].col1Questions;
            }
            else if(col=="col2Questions"){
                listquestions = listsect[sectionIndex].col2Questions;
            }
            else if(col=="col3Questions"){
                listquestions = listsect[sectionIndex].col3Questions;
            }
            var qstnOptionData;
            if(arr.length==4){
                qstnOptionData = listquestions.lstQuestn[index].Question_Options__r;
                if (event.getSource().get("v.checked")) {
                    mainQuestionOptionId =qstnOptionData[0].Id;
                    listquestions.lstQuestn[index].Question_Questionnaires__r[0].responseValue1='true';
                }
                if (!event.getSource().get("v.checked")) {
                    mainQuestionOptionId =qstnOptionData[1].Id;
                    listquestions.lstQuestn[index].Question_Questionnaires__r[0].responseValue1='false';
                }
                if (listquestions.lstQuestn[index].Question_Questionnaires__r[0].Is_Allow_Branching__c === true) {            
                    helper.setOptionBranching(component, event, mainQuestionOptionId, index,col,sectionIndex);
                }
            }
            else
            {   
                if(event.getSource().get("v.checked")) {
                    listquestions.lstQuestn[index].Question_Questionnaires__r[0].branchingQuestnQuetnnaire[branchingIndex].responseValue1='true';
                }
                if(!event.getSource().get("v.checked")) {
                    listquestions.lstQuestn[index].Question_Questionnaires__r[0].branchingQuestnQuetnnaire[branchingIndex].responseValue1='false';
                }
            }
        }
        catch(e)
        {
            console.log(e);
        }
    },
    
    setPicklistScore: function(component, event, helper) {
        try
        {
            var selctedOptionId = event.getSource().get("v.value");
            var index = parseInt(event.getSource().get("v.label").split("_")[1], 10);
            var col = event.getSource().get("v.label").split("_")[2];
            var sectionIndex = event.getSource().get("v.label").split("_")[3];
            
            var listsect = component.get("v.lstQQuesnnaire.sectionList");
            
            var listquestions = [];
            if(col=="col1Questions"){
                listquestions = listsect[sectionIndex].col1Questions;    
            }
            else if(col=="col2Questions"){
                listquestions = listsect[sectionIndex].col2Questions;    
            }
            else if(col=="col3Questions"){
                listquestions = listsect[sectionIndex].col3Questions;    
            }
            
            if (listquestions.lstQuestn[index].Question_Questionnaires__r[0].Is_Allow_Branching__c === true) {            
                helper.setOptionBranching(component, event, selctedOptionId, index,col,sectionIndex);
            }
        }
        catch(e)
        {
            console.log(e);
        }
    },
    sendBackToTemplate:function(component,event,helper){
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.QnaireId"),
            "slideDevName": "detail",
            "isredirect": true
        });
        navEvt.fire();
    },
    
   //CCEN 747 **// Starts
    handleCloseModelEvent:function(component,event,helper){
        var responseId = event.getParam("responseId");
        var response =  event.getParam("responseValue");
       	var vQnaireId = component.get("v.QnaireId");
        var vSectionId = component.get("v.selTabId");
        var closeModel = event.getParam("closeModel");
       	var isUpdateRecord = event.getParam("isUpdateRecord");
        var modelName = event.getParam("modelName");
        var checkData = event.getParam("checkData");
 		var signData = event.getParam("signData");
       	if(signData!=undefined && signData!="")
        {
         	var image = new Image();
            image.id = "pic"+component.get("v.questionId");
            image.src = signData;
            image.width=200;
            document.getElementById("sig_"+component.get("v.questionId")).innerHTML='';
            document.getElementById("sig_"+component.get("v.questionId")).appendChild(image);
            var SignMapVal = component.get("v.SigMap");
           	SignMapVal.set(responseId,response);
            component.set("v.SigMap",SignMapVal);
            var checkDataMap= component.get("v.checkDataMap");
            checkDataMap.set(responseId,checkData);
            component.set("v.checkDataMap",checkDataMap);
            component.set("v.response",response);
             
        }
		//close modal when click on modal close icon of date
        if (closeModel === true && modelName === "Signature") {
            component.set("v.showSign", false);
            component.set("v.isShowSignatureModal", false);
        }  if (isUpdateRecord === true && modelName === "Signature") {
           	helper.getAllQuestion(component, event, vQnaireId, vSectionId);
            component.set("v.isShowSignatureModal", false);
        } 
        //CCEN 747 Ends
    },
    nullify: function(comp, ev, hel) {
        var target = ev.getSource();
        target.set("v.value", "");
    },    
    nullifyDate: function(comp, ev, hel) {
        var target = ev.getSource();
        target.set("v.value", "");
    },
    
    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true);
    },
    
    // this function automatic call by aura:doneWaiting event 
    hideSpinner: function(component, event, helper) {
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.Spinner", false);
    },
    
    getCharLimit: function(component, event, helper) {
        var ctarget = event.currentTarget;
        var id_str = ctarget.dataset.value;
        component.set("v.richTextCharLimit", parseInt(id_str, 10));
    },        
    showSignModel: function(component, event, helper) {
        var questionId = event.getSource().get("v.value");
        component.set("v.questionId",questionId);
        component.set('v.showSign', true);
    },  
    closeToast: function(component, event, helper) {
        component.set("v.msgbody",'');
        component.set("v.msgtype",'');
    }
})