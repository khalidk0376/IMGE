({    
    backtoFormHelper:function(component, event) {
        var action = component.get("c.backButtonRender");  
        action.setCallback(this,function(res){
            component.set("v.BackToForm",res.getReturnValue());
        });
        $A.enqueueAction(action);   
    },   
    
    approvedStatus:function(component) {        
        var action = component.get("c.selectApprovedStatus");
        
        action.setParams({"questionaryId":component.get("v.recordId"),"sAccountId":component.get("v.AccId")});
        action.setCallback(this,function(res){
            component.set("v.approveStatus",res.getReturnValue());
            console.log('JSON========'+JSON.stringify(res.getReturnValue()));
            if(res.getReturnValue()){
                this.disabledFields(component);
            }
        });
        $A.enqueueAction(action);   
    },
    
    getQuestionnaireRecord: function(component, event) {
        var vQnaireId = component.get("v.recordId");
        var vSectionId = '';       
        var self = this;
        self.getTempRecord(component, event, vQnaireId);
        
        //check is merge section or not
        var action = component.get("c.isMergeSection");        
        action.setParams({"qnaireId":component.get("v.recordId")});
        action.setCallback(this,function(res){
            var state = res.getState();
            //console.log(JSON.stringify(res.getReturnValue()));
            if(state=='SUCCESS'){
                component.set("v.isMergeAllSection",res.getReturnValue());
                
                if(res.getReturnValue()==true){
                    self.getAllQuesGroupRecord(component, event, vQnaireId, "");
                }else{
                    self.getQuesGroupRecord(component, event, vQnaireId, "");
                }
            }else{
                self.showNewToast(component,'ERROR : ','error',res.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },
    getParameterByName: function(name) {
        name = name.replace(/[\[\]]/g, "\\$&");
        var url = window.location.href;
        var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)");
        var results = regex.exec(url);
        if (!results) return null;
        if (!results[2]) return '';
        return decodeURIComponent(results[2].replace(/\+/g, " "));
    },
    
    testHelper:function(resObj,lstQuestion){
        var return_arr=[];
        var data;
        var lstUnderbranchingResponseOption =[];
        var lstUnderbranchingResponseOption2 =[];
        
        if (lstQuestion !== undefined && lstQuestion !== null && lstQuestion.lstQuestn!=undefined && lstQuestion.lstQuestn.length>0)
        {
            //start response code//
            for (var resIndex = 0; resIndex < lstQuestion.lstQuestn.length; resIndex++)
            {
                lstQuestion.lstQuestn[resIndex].Question_Questionnaires__r[0].responseValue1 = '';
                lstQuestion.lstQuestn[resIndex].Question_Questionnaires__r[0].responseValue2 = '';
                lstQuestion.lstQuestn[resIndex].Question_Questionnaires__r[0].comment = '';
                lstQuestion.lstQuestn[resIndex].Question_Questionnaires__r[0].attachment = '';
                
                if(lstQuestion.lstQuestn[resIndex].Type__c=='Number')
                {
                    if(lstQuestion.lstQuestn[resIndex].Decimal_value__c==0){
                        lstQuestion.lstQuestn[resIndex].Question_Questionnaires__r[0].patterns = '^[0-9]*$';
                        lstQuestion.lstQuestn[resIndex].Question_Questionnaires__r[0].messages ='Please enter valid format in number and not accept decimal point';
                    }
                    if(lstQuestion.lstQuestn[resIndex].Decimal_value__c==1){
                        lstQuestion.lstQuestn[resIndex].Question_Questionnaires__r[0].patterns = '^(?!0\\d|$)\\d*(\\.\\d{1,1})?$';
                        lstQuestion.lstQuestn[resIndex].Question_Questionnaires__r[0].messages ='Please enter valid format in number and accept only 1 decimal point';
                    }
                    if(lstQuestion.lstQuestn[resIndex].Decimal_value__c==2){
                        lstQuestion.lstQuestn[resIndex].Question_Questionnaires__r[0].patterns = '^(?!0\\d|$)\\d*(\\.\\d{1,2})?$';
                        lstQuestion.lstQuestn[resIndex].Question_Questionnaires__r[0].messages ='Please enter valid format in number and accept only 2 decimal points';
                    }
                    if(lstQuestion.lstQuestn[resIndex].Decimal_value__c==3){
                        lstQuestion.lstQuestn[resIndex].Question_Questionnaires__r[0].patterns = '^(?!0\\d|$)\\d*(\\.\\d{1,3})?$';
                        lstQuestion.lstQuestn[resIndex].Question_Questionnaires__r[0].messages ='Please enter valid format in number and accept only 3 decimal points';
                    }
                    if(lstQuestion.lstQuestn[resIndex].Decimal_value__c==4){
                        lstQuestion.lstQuestn[resIndex].Question_Questionnaires__r[0].patterns = '^(?!0\\d|$)\\d*(\\.\\d{1,4})?$';
                        lstQuestion.lstQuestn[resIndex].Question_Questionnaires__r[0].messages ='Please enter valid format in number and accept only 4 decimal point';
                    }                    
                }
                
                if(lstQuestion.lstQuestn[resIndex].Type__c=='Switch')
                {
                    lstQuestion.lstQuestn[resIndex].Question_Questionnaires__r[0].responseValue1 = lstQuestion.lstQuestn[resIndex].Question_Options__r[1].Value__c;
                    lstUnderbranchingResponseOption2.push(lstQuestion.lstQuestn[resIndex].Question_Options__r[1].Id);
                }
                
                if(lstQuestion.lstQuestn[resIndex].Type__c=='Slider'){
                    lstQuestion.lstQuestn[resIndex].Question_Questionnaires__r[0].responseValue1 = lstQuestion.lstQuestn[resIndex].Question_Questionnaires__r[0].Default_Value__c;
                }
                
                if(lstQuestion.lstQuestn[resIndex].Type__c=='Checkbox'){                    
                    lstQuestion.lstQuestn[resIndex].Question_Questionnaires__r[0].responseValue1 = 'false';
                    lstUnderbranchingResponseOption2.push(lstQuestion.lstQuestn[resIndex].Question_Options__r[1].Id);
                }
                if(lstQuestion.lstQuestn[resIndex].Question_Questionnaires__r[0].Question__r.Type__c=='Picklist'){
                    var lstQuestionOptions = lstQuestion.lstQuestn[resIndex].Question_Options__r;
                    if(lstQuestionOptions !== undefined && lstQuestionOptions.length>0){
                        //lstUnderbranchingResponseOption2.push(lstQuestionOptions[0].Id);
                    }
                }
                
                if(lstQuestion.lstQuestn[resIndex].Question_Options__r!=undefined)
                {
                    for(var ind=0; ind< lstQuestion.lstQuestn[resIndex].Question_Options__r.length;ind++)
                    {
                        lstQuestion.lstQuestn[resIndex].Question_Options__r[ind].label=lstQuestion.lstQuestn[resIndex].Question_Options__r[ind].Name__c;
                        lstQuestion.lstQuestn[resIndex].Question_Options__r[ind].value=lstQuestion.lstQuestn[resIndex].Question_Options__r[ind].Name__c;
                    }
                }
            }
            
            // Set responses to questions                        
            for(var ind=0;ind<resObj.length;ind++)
            {  
                
                
                if(resObj[ind].Answer__c==undefined){
                    resObj[ind].Answer__c='';
                }
                data = resObj[ind].Answer__c;
                for (var resIndex = 0; resIndex < lstQuestion.lstQuestn.length; resIndex++)
                {
                    if(lstQuestion.lstQuestn[resIndex].Id==resObj[ind].Question__c)
                    {
                        if(lstQuestion.lstQuestn[resIndex].Question_Questionnaires__r[0].Question__r.Type__c=='GPS Location')
                        {
                            lstQuestion.lstQuestn[resIndex].Question_Questionnaires__r[0].responseValue1 = resObj[ind].Answer__c.split(' ')[0];
                            lstQuestion.lstQuestn[resIndex].Question_Questionnaires__r[0].responseValue2 = resObj[ind].Answer__c.split(' ')[1];
                        }                                    
                        else if(lstQuestion.lstQuestn[resIndex].Question_Questionnaires__r[0].Question__r.Type__c=='Switch'){
                            lstQuestion.lstQuestn[resIndex].Question_Questionnaires__r[0].responseValue1 = data;                                        
                            if(data === 'true'){
                                lstUnderbranchingResponseOption.push(lstQuestion.lstQuestn[resIndex].Question_Options__r[0].Id);
                            }
                            else{
                                lstUnderbranchingResponseOption.push(lstQuestion.lstQuestn[resIndex].Question_Options__r[1].Id);
                            }
                        }
                            else if(lstQuestion.lstQuestn[resIndex].Question_Questionnaires__r[0].Question__r.Type__c=='Checkbox'){                            
                                lstQuestion.lstQuestn[resIndex].Question_Questionnaires__r[0].responseValue1 = data;                                        
                                if(data === 'true'){                                            
                                    lstUnderbranchingResponseOption.push(lstQuestion.lstQuestn[resIndex].Question_Options__r[0].Id);
                                }
                                else{
                                    lstUnderbranchingResponseOption.push(lstQuestion.lstQuestn[resIndex].Question_Options__r[1].Id);
                                }     
                            }
                                else if(lstQuestion.lstQuestn[resIndex].Question_Questionnaires__r[0].Question__r.Type__c=='Picklist'){
                                    lstQuestion.lstQuestn[resIndex].Question_Questionnaires__r[0].responseValue1 = data;
                                    var lstQuestionOptions = lstQuestion.lstQuestn[resIndex].Question_Options__r;
                                    if(lstQuestionOptions !== undefined && lstQuestionOptions.length>0){
                                        for(var optionIndex =0;optionIndex<lstQuestionOptions.length;optionIndex++){                                                
                                            if(data ===lstQuestionOptions[optionIndex].Id) {
                                                lstUnderbranchingResponseOption.push(lstQuestionOptions[optionIndex].Id);
                                            }
                                        }
                                    }
                                }
                                    else
                                    {
                                        lstQuestion.lstQuestn[resIndex].Question_Questionnaires__r[0].responseValue1 = resObj[ind].Answer__c;
                                        lstQuestion.lstQuestn[resIndex].Question_Questionnaires__r[0].responseValue2 = '';
                                    }
                        
                        if(resObj[ind].Comment__c!=undefined)
                            lstQuestion.lstQuestn[resIndex].Question_Questionnaires__r[0].comment = resObj[ind].Comment__c;
                        
                        // set Attachment response
                        if(resObj[ind].Attachments!=undefined)
                        {
                            for(var i=0;i<resObj[ind].Attachments.totalSize;i++)
                            {
                                if(lstQuestion.lstQuestn[resIndex].Question_Questionnaires__r[0].attachment==''){
                                    lstQuestion.lstQuestn[resIndex].Question_Questionnaires__r[0].attachment = resObj[ind].Attachments.records[i].Name;
                                }
                                else{                                                
                                    lstQuestion.lstQuestn[resIndex].Question_Questionnaires__r[0].attachment = lstQuestion.lstQuestn[resIndex].Question_Questionnaires__r[0].attachment +', '+ resObj[ind].Attachments.records[i].Name;   
                                }
                            }
                        }
                    }
                }
            }                       
        }
        
        if(lstUnderbranchingResponseOption.length==0){
            lstUnderbranchingResponseOption = lstUnderbranchingResponseOption2
        }
        
        return_arr[0] = lstQuestion;
        return_arr[1] = lstUnderbranchingResponseOption;
        return return_arr;
    },
    getQuestionResponsesHelper:function(component,event,lstQQuesnnaire,vSectionId){
        //console.log('AccIdhelper===='+component.get("v.questionId"));
        //console.log('sectionId===='+vSectionId);
        //console.log('questionnaireId===='+component.get("v.recordId"));
        component.set("v.Spinner", true);
        var self = this;
        var data;
        var action = component.get("c.getQuestionResponses"); 
        action.setParams({"questionnaireId":component.get("v.recordId"),"sectionId":vSectionId,"sAccountId":component.get("v.AccId") });
        action.setCallback(this,function(res){
            component.set("v.Spinner", false);
            var state = res.getState();
            //console.log('testReturnValue'+res.getReturnValue());
            if (state === "SUCCESS") {
                try{
                    
                    var obj = JSON.parse(res.getReturnValue().responses);  
                    
                    var lstQDynLogic = res.getReturnValue().lstQDynLogic;
                    //console.log('JSON==='+JSON.stringify(res.getReturnValue().lstQDynLogic));
                    component.set("v.lstQDynLogicMain", obj);
                    
                    var res_and_ques = [];
                    var sectionList  =  lstQQuesnnaire.sectionList;
                    //console.log(sectionList);
                    for(var i=0;i<sectionList.length;i++)
                    {
                        if(sectionList[i].sectionColNumber=='0' || sectionList[i].sectionColNumber=='1'){
                            if(sectionList[i].col1Questions.lstQuestn!=undefined){
                                res_and_ques = self.testHelper(obj,sectionList[i].col1Questions);                                
                                lstQQuesnnaire.sectionList[i].col1Questions = res_and_ques[0];
                                //console.log(' lstQQuesnnaire.sectionList[i].col1Questions'+ JSON.stringify(lstQQuesnnaire.sectionList[i].col1Questions));
                                self.setQuestionBranching(component,event,lstQQuesnnaire,vSectionId,'col1',i,res_and_ques[1]);
                            }
                        }
                        
                        if(sectionList[i].sectionColNumber=='2'){
                            if(sectionList[i].col1Questions.lstQuestn.length>0){
                                res_and_ques = self.testHelper(obj,sectionList[i].col1Questions);
                                lstQQuesnnaire.sectionList[i].col1Questions = res_and_ques[0];                            
                                self.setQuestionBranching(component,event,lstQQuesnnaire,vSectionId,'col1',i,res_and_ques[1]);
                            }
                            
                            if(sectionList[i].col2Questions.lstQuestn.length>0){
                                res_and_ques = self.testHelper(obj,sectionList[i].col2Questions);   
                                lstQQuesnnaire.sectionList[i].col2Questions = res_and_ques[0];
                                self.setQuestionBranching(component,event,lstQQuesnnaire,vSectionId,'col2',i,res_and_ques[1]);
                            }
                        }
                        
                        if(sectionList[i].sectionColNumber=='3'){
                            if(sectionList[i].col1Questions.lstQuestn!=undefined){
                                res_and_ques = self.testHelper(obj,sectionList[i].col1Questions);
                                lstQQuesnnaire.sectionList[i].col1Questions = res_and_ques[0];
                                self.setQuestionBranching(component,event,lstQQuesnnaire,vSectionId,'col1',i,res_and_ques[1]);
                            }
                            if(sectionList[i].col2Questions.lstQuestn!=undefined){
                                res_and_ques = self.testHelper(obj,sectionList[i].col2Questions);
                                lstQQuesnnaire.sectionList[i].col2Questions = res_and_ques[0];                                
                                self.setQuestionBranching(component,event,lstQQuesnnaire,vSectionId,'col2',i,res_and_ques[1]);
                            }
                            if(sectionList[i].col3Questions.lstQuestn!=undefined){
                                res_and_ques = self.testHelper(obj,sectionList[i].col3Questions);                                
                                lstQQuesnnaire.sectionList[i].col3Questions = res_and_ques[0];
                                self.setQuestionBranching(component,event,lstQQuesnnaire,vSectionId,'col3',i,res_and_ques[1]);
                            }
                        }
                    }
                    //console.log("testlstQQuesnnaire"+JSON.stringify(lstQQuesnnaire));
                    component.set("v.lstQQuesnnaire",lstQQuesnnaire);
                    this.approvedStatus(component);
                }
                catch(e){
                    //self.showNewToast(component,'ERROR : ','error',e);
                    console.log('Error: '+e);
                }
            } 
            else {
                self.showNewToast(component,'ERROR : ','error',res.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },    
    getQuesGroupRecord: function(component, event, vQnaireId, type) {
        var action = component.get("c.getAllQuestnGrpNameForQuesnnaire"); //Calling Apex class controller 'getAllQuestnGrpNameForQuesnnaire' method
        action.setParams({
            sQnaireId: vQnaireId
        });
        action.setCallback(this, function(res) {            
            var state = res.getState();
            if (state === "SUCCESS") {
                //console.log(JSON.stringify(res.getReturnValue()));
                component.set("v.lstQuesGroup", res.getReturnValue());
                var lstQGroup = component.get("v.lstQuesGroup");
                //alert(lstQGroup.length);
                if(lstQGroup.length>1){
                    component.set("v.disableNextSection",true);
                }
                else{
                    component.set("v.disableNextSection",false);
                }
                if (type === "delete section") {
                    component.set("v.selTabId", lstQGroup[0].Question_Group__c);
                    this.getAllQuestion(component, event, vQnaireId, component.get("v.selTabId"));
                } else if (type === "change") {
                    this.getAllQuestion(component, event, vQnaireId, component.get("v.selTabId"));
                } else {
                    component.set("v.selTabId", lstQGroup[0].Question_Group__c);
                    this.getAllQuestion(component, event, vQnaireId, component.get("v.selTabId"));
                }
            } 
            else {
                this.showNewToast(component,"Error:",'error',res.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },
    getAllQuesGroupRecord: function(component, event, vQnaireId, type) {
        this.getAllQuestion(component, event, vQnaireId, '');//set section id empty if want to get all section
    },
    getAllQuestion: function(component, event, vQnaireId, vSectionId) {
        var self = this;
        
        var action = component.get("c.getQuestnsForAllQuesGroup"); //Calling Apex class controller 'getQuestnForQuesGroup' method
        action.setParams({
            qnaireId: vQnaireId,
            sectionId: vSectionId,
        });
        action.setCallback(this, function(res) {
            
            var state = res.getState();
            if (state === "SUCCESS") {
                this.setButtonColors(component,res.getReturnValue().Questionnaire);
                
                //component.set("v.lstQQuesnnaire",res.getReturnValue());
                //console.log('JSON============'+JSON.stringify(res.getReturnValue()));                
                self.getQuestionResponsesHelper(component,event,res.getReturnValue(),vSectionId);
                
            } else {
                self.showNewToast(component,"Error: ",'error',res.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },    
    setQuestionBranching: function(component, event, lstQQuesnnaire, vSectionId,col,i,lstUnderbranchingResponseOption) {
        //console.log('Helper Is Called');
        var lstQDynLogic = component.get("v.lstQDynLogicMain");
        var lst_Question_Questionnaires = [];
        var Obj_Question_Questionnaires = component.get("v.Obj_Question_Questionnaires");
        var isRemove = false;            
        var lstQuestnOption =lstUnderbranchingResponseOption;
        
        if (lstQQuesnnaire !== undefined && lstQQuesnnaire !== null && lstQQuesnnaire.sectionList!=undefined && lstQQuesnnaire.sectionList.length>0) 
        {               
            var question = [];
            try
            {
                if(col=='col1'){
                    question = lstQQuesnnaire.sectionList[i].col1Questions.lstQuestn;
                }
                else if(col=='col2'){
                    question = lstQQuesnnaire.sectionList[i].col2Questions.lstQuestn;
                }
                    else if(col=='col3'){
                        question = lstQQuesnnaire.sectionList[i].col3Questions.lstQuestn;
                    }
                
                //console.log(question);
                
                if (lstQDynLogic !== undefined && lstQDynLogic !== null && lstQDynLogic.length > 0) {
                    for (var indexQDynLogic = 0; indexQDynLogic < lstQDynLogic.length; indexQDynLogic++) {
                        for (var indexQue = 0; indexQue < question.length; indexQue++) {
                            var questionQuestnnnaire = question[indexQue].Question_Questionnaires__r;
                            question[indexQue].Question_Questionnaires__r[0].branchingQuestnQuetnnaire = [];
                            for (var indeQQnnaire = 0; indeQQnnaire < questionQuestnnnaire.length; indeQQnnaire++) {
                                if (lstQDynLogic[indexQDynLogic].Show_Question_Questionnaire__c === questionQuestnnnaire[indeQQnnaire].Id) {
                                    isRemove = true;
                                    Obj_Question_Questionnaires = questionQuestnnnaire[indeQQnnaire];
                                    if (question[indexQue].Question_Options__r !== undefined) {
                                        Obj_Question_Questionnaires.QuestionOptions = question[indexQue].Question_Options__r;
                                    } else {
                                        Obj_Question_Questionnaires.QuestionOptions = [];
                                    }
                                    if (lstQDynLogic[indexQDynLogic].Question_Questionnaire__r.Question__r.Type__c === 'Picklist' || lstQDynLogic[indexQDynLogic].Question_Questionnaire__r.Question__r.Type__c === 'Switch' || lstQDynLogic[indexQDynLogic].Question_Questionnaire__r.Question__r.Type__c === 'Checkbox') {
                                        Obj_Question_Questionnaires.isShowQuestion = false;
                                    }
                                    else{
                                        Obj_Question_Questionnaires.isShowQuestion = true;
                                    }
                                    Obj_Question_Questionnaires.MainQuestionId = lstQDynLogic[indexQDynLogic].Question_Questionnaire__r.Question__c;
                                    
                                    question.splice(indexQue, 1);
                                }
                            }
                        }
                        
                        lst_Question_Questionnaires.push(Obj_Question_Questionnaires);
                    }
                    //console.log('Helper Is Called - 4');
                    //Default setting for switch and checkbox question.  
                    if(lstQuestnOption !== undefined && lstQuestnOption.length>0){                                
                        for(var varDynLogic=0; varDynLogic<lstQDynLogic.length;varDynLogic++ ){                                    
                            if(lstQuestnOption.indexOf(lstQDynLogic[varDynLogic].Question_Option__c)!==-1){
                                for(var varQuestn =0;varQuestn<lst_Question_Questionnaires.length;varQuestn++ ){                                            
                                    if(lst_Question_Questionnaires[varQuestn].Id===lstQDynLogic[varDynLogic].Show_Question_Questionnaire__c){                                                
                                        lst_Question_Questionnaires[varQuestn].isShowQuestion =true;
                                    }
                                }
                            }
                        }
                    }
                    //console.log('Helper Is Called - 5');
                    var lstQuestionsId = [];
                    if (isRemove === true) {
                        for (var indexQueResult = 0; indexQueResult < question.length > 0; indexQueResult++) {
                            var questnId = question[indexQueResult].Id;
                            //var questionSecondOptionId = question[indexQueResult].Question_Options__r[1].Id;
                            for (var indexQQnnaire = 0; indexQQnnaire < lst_Question_Questionnaires.length > 0; indexQQnnaire++) {
                                if (lst_Question_Questionnaires[indexQQnnaire].MainQuestionId === questnId) {                                    
                                    var branchingQuestionQuestnnnaire = question[indexQueResult].Question_Questionnaires__r[0].branchingQuestnQuetnnaire;
                                    if (lstQuestionsId.indexOf(lst_Question_Questionnaires[indexQQnnaire].Id) === -1) {
                                        branchingQuestionQuestnnnaire.push(lst_Question_Questionnaires[indexQQnnaire]);
                                    }
                                    lstQuestionsId.push(lst_Question_Questionnaires[indexQQnnaire].Id);
                                    question[indexQueResult].Question_Questionnaires__r[0].branchingQuestnQuetnnaire = branchingQuestionQuestnnnaire;
                                }
                            }
                        }
                    }
                    //console.log('Helper Is Called - 6');
                } 
                
                if(col=='col1'){
                    lstQQuesnnaire.sectionList[i].col1Questions.lstQuestn = this.sortListQuestionQuestionnaire(component, event, question);
                }
                else if(col=='col2'){
                    lstQQuesnnaire.sectionList[i].col2Questions.lstQuestn = this.sortListQuestionQuestionnaire(component, event, question);
                }
                    else if(col=='col3'){
                        lstQQuesnnaire.sectionList[i].col3Questions.lstQuestn = this.sortListQuestionQuestionnaire(component, event, question);
                    }  
            }
            catch(e){
                console.log(e);
            }           
        } 
        else 
        {
            //console.log('testquestiot'+JSON.Stringfy(lstQQuesnnaire));
            component.set("v.lstQQuesnnaire", lstQQuesnnaire);
        }        
    },
    sortListQuestionQuestionnaire: function(component, event, arrayQQuesnnaire) {
        var done = false;
        while (!done) {
            done = true;
            for (var i = 1; i < arrayQQuesnnaire.length; i += 1) {
                if (arrayQQuesnnaire[i - 1].Question_Questionnaires__r[0].Question_Order__c > arrayQQuesnnaire[i].Question_Questionnaires__r[0].Question_Order__c) {
                    done = false;
                    var tmp = arrayQQuesnnaire[i - 1];
                    arrayQQuesnnaire[i - 1] = arrayQQuesnnaire[i];
                    arrayQQuesnnaire[i] = tmp;
                }
            }
        }
        return arrayQQuesnnaire;
    }, 
    getQuesCategory: function(component, event, vQnaireId, vSectionId) {        
        var action = component.get("c.getQueCategory"); //Calling Apex class controller 'getQueCategory' method
        action.setCallback(this, function(res) {            
            var state = res.getState();
            //console.log('test1'+JSON.stringify(res.getReturnValue()));
            if (state === "SUCCESS") {
                component.set("v.lstQuesCategory", res.getReturnValue());
            } else {
                this.showNewToast(component,"Error:",'error',res.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },    
    setOptionBranching: function(component, event, selctedOptionId, index,col,sectionIndex) {
        try
        {
            var listsect = component.get("v.lstQQuesnnaire.sectionList");
            var mainQuestion = [];//component.get("v.lstQQuesnnaire.sectionList."+col+".lstQuestn");
            if(col=="col1Questions"){
                mainQuestion = listsect[sectionIndex].col1Questions.lstQuestn;
            }
            else if(col=="col2Questions"){
                mainQuestion = listsect[sectionIndex].col2Questions.lstQuestn;
            }
                else if(col=="col3Questions"){
                    mainQuestion = listsect[sectionIndex].col3Questions.lstQuestn;
                }
            //console.log(mainQuestion);
            
            var mainQuestionBranching = mainQuestion[index].Question_Questionnaires__r[0].branchingQuestnQuetnnaire;
            //console.log(mainQuestion[index].Question_Questionnaires__r[0]);
            //console.log(mainQuestionBranching);
            
            if (mainQuestionBranching !== undefined) {
                for (var indexMBranching = 0; indexMBranching < mainQuestionBranching.length; indexMBranching++) {
                    mainQuestionBranching[indexMBranching].isShowQuestion = false;
                }
                var lstAddScore = []; //list for which want to count score in branching question.
                var lstRemoveScore = []; //list for which not count score in branching question.
                mainQuestion[index].Question_Questionnaires__r[0].branchingQuestnQuetnnaire = mainQuestionBranching;
                if (selctedOptionId !== undefined && selctedOptionId !== null && selctedOptionId.length > 0) {
                    var lstQDynLogic = component.get("v.lstQDynLogicMain");
                    
                    var questnniareId = mainQuestion[index].Question_Questionnaires__r[0].Id;
                    
                    //remove question which is not set in Question option
                    for (var branchingQuestnQuetnnaireIndex = 0; branchingQuestnQuetnnaireIndex < mainQuestionBranching.length; branchingQuestnQuetnnaireIndex++) 
                    {
                        for (var indexMainQDynLogic = 0; indexMainQDynLogic < lstQDynLogic.length; indexMainQDynLogic++) 
                        {                            
                            if (lstQDynLogic[indexMainQDynLogic].Show_Question_Questionnaire__c === mainQuestionBranching[branchingQuestnQuetnnaireIndex].Id &&
                                lstQDynLogic[indexMainQDynLogic].Question_Questionnaire__c === questnniareId &&
                                selctedOptionId === lstQDynLogic[indexMainQDynLogic].Question_Option__c) 
                            {
                                
                                mainQuestionBranching[branchingQuestnQuetnnaireIndex].isShowQuestion = true;
                                if (lstRemoveScore.indexOf(mainQuestionBranching[branchingQuestnQuetnnaireIndex].Question__c) > -1) 
                                {
                                    var alredyAddInRemvePoint = lstRemoveScore.indexOf(mainQuestionBranching[branchingQuestnQuetnnaireIndex].Question__c);
                                    lstRemoveScore.splice(alredyAddInRemvePoint, 1);
                                }
                                lstAddScore.push(mainQuestionBranching[branchingQuestnQuetnnaireIndex].Question__c);
                            } 
                            else 
                            {
                                if (lstAddScore.indexOf(mainQuestionBranching[branchingQuestnQuetnnaireIndex].Question__c) === -1 && lstRemoveScore.indexOf(mainQuestionBranching[branchingQuestnQuetnnaireIndex].Question__c) === -1) {
                                    lstRemoveScore.push(mainQuestionBranching[branchingQuestnQuetnnaireIndex].Question__c);
                                }
                            }
                        }
                    }
                    mainQuestion[index].Question_Questionnaires__r[0].branchingQuestnQuetnnaire = mainQuestionBranching;
                } else {
                    for (var scorebranchgQuestnQnaireIndex = 0; scorebranchgQuestnQnaireIndex < mainQuestionBranching.length; scorebranchgQuestnQnaireIndex++) {
                        lstRemoveScore.push(mainQuestionBranching[scorebranchgQuestnQnaireIndex].Question__c);
                    }
                }
                
                if(col=="col1Questions"){
                    listsect[sectionIndex].col1Questions.lstQuestn = mainQuestion;
                }
                else if(col=="col2Questions"){
                    listsect[sectionIndex].col2Questions.lstQuestn = mainQuestion;
                }
                    else if(col=="col3Questions"){
                        listsect[sectionIndex].col3Questions.lstQuestn = mainQuestion;
                    }
                component.set("v.lstQQuesnnaire.sectionList", listsect);
            }
        }
        catch(e){
            console.log('Error: '+e);
        }
    },
    
    showNewToast: function(component,title,type, message) {
        var toastEvent = $A.get("e.force:showToast");
        if(toastEvent!=undefined){
            toastEvent.setParams({
                title: title,
                message: message,
                duration: '5000',
                type: type,
                mode: 'dismissible'
            });
            toastEvent.fire();
        }
        else{
            component.set("v.msgbody",message);
            component.set("v.msgtype",type);
            window.setTimeout($A.getCallback(function() {
                component.set("v.msgbody",'');
                component.set("v.msgtype",'');
            }), 5000);
        }
    },
    saveQuestionResponseHelper:function(component)
    {
        //console.log('TestAcc'+component.get("v.AccId")) ;
        var self = this;
        var resp=[];
        var sectionList = component.get("v.lstQQuesnnaire.sectionList");
        for(var i=0;i<sectionList.length;i++)
        {
            if(sectionList[i].sectionColNumber=='0' || sectionList[i].sectionColNumber=='1'){
                if(sectionList[i].col1Questions.lstQuestn!=undefined){
                    resp = resp.concat(sectionList[i].col1Questions.lstQuestn);
                }
            }
            
            if(sectionList[i].sectionColNumber=='2'){
                if(sectionList[i].col1Questions.lstQuestn!=undefined){
                    resp = resp.concat(sectionList[i].col1Questions.lstQuestn);
                }
                if(sectionList[i].col2Questions.lstQuestn!=undefined){
                    resp = resp.concat(sectionList[i].col2Questions.lstQuestn);
                }
            }
            
            if(sectionList[i].sectionColNumber=='3'){
                if(sectionList[i].col1Questions.lstQuestn!=undefined){
                    resp = resp.concat(sectionList[i].col1Questions.lstQuestn);
                }
                if(sectionList[i].col2Questions.lstQuestn!=undefined){
                    resp = resp.concat(sectionList[i].col2Questions.lstQuestn);
                    
                }
                if(sectionList[i].col3Questions.lstQuestn!=undefined){
                    resp = resp.concat(sectionList[i].col3Questions.lstQuestn);
                }
            }
        }
        
        resp = JSON.stringify(resp);
        console.log('resp===================================='+resp);
        var action = component.get("c.saveQuestionResponse");
        component.set("v.Spinner",true);
        var resp = resp.replace(/__c/g, "");
        resp = resp.replace(/__r/g, "r");
        //console.log('resp1===================================='+resp);
        action.setParams({"JSONResponse":resp,"questionaryId":component.get("v.recordId"),"eventEditiId":component.get("v.eventEditionId"),"sAccountId":component.get("v.AccId")});
        action.setCallback(this,function(res){            
            var state = res.getState();
            if (state === "SUCCESS") {
                //this.deleteOldAttchmntIds(component);
                component.set("v.Spinner",false);
                self.showNewToast(component,'SUCCESS : ','success','Your response has been submitted');
                if(component.get("v.BackToForm")==true){
                    window.history.back();
                }
            } 
            else {
                self.showNewToast(component,'ERROR : ','error',res.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },
    validateForm:function(component)
    {
        var ele = component.find('inputFields');
        try{            
            if(ele instanceof Array)
            {
                var allValid = component.find('inputFields').reduce(function (validSoFar, inputCmp) 
                 { 
                    if(inputCmp.get("v.isValid")==undefined)
                      {//return true;
                       }
                       inputCmp.showHelpMessageIfInvalid();
                       if(inputCmp!=null && inputCmp.get('v.validity')!=undefined){
                         return validSoFar && inputCmp.get('v.validity').valid;    
                       }else{
                        return validSoFar;
                        }
             }, true);
                
                if (allValid){
                    return true;
                }
                else{
                    return false;
                }
            }
            else if(ele != undefined && ele != null){
                ele.showHelpMessageIfInvalid();                
                return ele.get('v.validity').valid;
            }
                else{
                    return true; 
                }     
        }
        catch(e)
        {
            console.log('Error: '+e);
        }   
    },
    validateForm2:function(component)
    {
        var isValid = true;
        try{   
            var ele = component.find('inputRadioFields');
            if(ele instanceof Array)
            {
                
                for(var i=0;i<ele.length;i++){
                    var obj = ele[i];
                    if(!obj.checkValidity()){
                        //obj.set("v.validity",{"isvalid":false});
                        $A.util.addClass(obj,"slds-has-error");
                        isValid = false;
                    }
                    else
                    {
                        $A.util.removeClass(obj,"slds-has-error");
                    }
                }
            }
            else if(ele != undefined)
            {
                if(!ele.checkValidity()){
                    $A.util.addClass(ele,"slds-has-error");                    
                    isValid = false;
                }
                else
                {
                    $A.util.removeClass(ele,"slds-has-error");
                }
            }
            
            ele = component.find('inputRichtextFields');
            if(ele instanceof Array)
            {
                for(var i=0;i<ele.length;i++){
                    var obj = ele[i];
                    if(obj.get("v.class")==true && $A.util.isEmpty(obj.get("v.value"))){
                        obj.set("v.valid",false);
                        isValid = false;                        
                    }else{
                        obj.set("v.valid",true);
                    }
                }    
            }
            else if(ele != undefined)
            {
                if(ele.get("v.class")==true && ele.get("v.value")==''){
                    ele.set("v.valid",false);
                    isValid = false;
                }
                else
                {
                    ele.set("v.valid",true);
                }
            }
            //ele = component.find('inputDateFields');
            ele =  document.getElementById('inputDateFields');
           
            console.log('eleDate'+ele);
            if(ele instanceof Array)
            {
                for(var i=0;i<ele.length;i++){
                    var obj = ele[i];                    
                    if(obj.get("v.required")==true && $A.util.isEmpty(obj.get("v.value"))){
                        obj.set("v.errors",[{message:"Please enter valid date"}]);
                        isValid = false;
                    }else{
                        obj.set("v.errors",null);
                    }
                }
            }
            else if(ele != undefined)
            {
                /*
                if(component.find('inputDateFields').get("v.required")==true && $A.util.isEmpty(component.find('inputDateFields').get("v.value"))){
                    component.find('inputDateFields').set("v.errors",[{message:"Please enter valid date"}]);
                    isValid = false;
                }
                else
                {
                    component.find('inputDateFields').set("v.errors",null);
                }
                */
                if(document.getElementById('inputDateFields').get("v.required")==true && $A.util.isEmpty(document.getElementById('inputDateFields').get("v.value"))){
                    document.getElementById('inputDateFields').set("v.errors",[{message:"Please enter valid date"}]);
                    isValid = false; 
                }
                else
                {
                    document.getElementById('inputDateFields').set("v.errors",null);
                }
            }
            
            //ele = component.find('inputDateTimeFields');
            ele = document.getElementById('inputDateTimeFields');
            
            if(ele instanceof Array)
            {
                for(var i=0;i<ele.length;i++){
                    var obj = ele[i];
                    if(obj.get("v.required")==true && $A.util.isEmpty(obj.get("v.value"))){
                        obj.set("v.errors",[{message:"Please enter valid date and time"}]);
                        isValid = false;
                    }else{
                        obj.set("v.errors",null);
                    }
                }
            }
            else if(ele != undefined)
            {
                /*
                if(component.find('inputDateTimeFields').get("v.required")==true && $A.util.isEmpty(component.find('inputDateTimeFields').get("v.value"))){
                    component.find('inputDateTimeFields').set("v.errors",[{message:"Please enter valid date and time"}]);
                    isValid = false;
                }
                else{
                    component.find('inputDateTimeFields').set("v.errors",null);
                }*/
                if(document.getElementById('inputDateTimeFields').get("v.required")==true && $A.util.isEmpty(document.getElementById('inputDateTimeFields').get("v.value"))){
                    document.getElementById('inputDateTimeFields').set("v.errors",[{message:"Please enter valid date and time"}]);
                    isValid = false;
                }
                else{
                    document.getElementById('inputDateTimeFields').set("v.errors",null);
                }
            }
            var eve = $A.get("e.c:validateLookupFieldEvt");
            eve.fire();
            return isValid;
        }
        catch(e){
            console.log('Error: '+e);
        }
    },
    validateForm3:function(component)
    {
        try{
            var elechk= component.find('checkBox');
            var rtn = true;
            if(elechk instanceof Array){
                for(var i=0;i<elechk.length;i++)
                {
                    var obj = elechk[i];   
                    if(obj.get("v.required")==true)
                    {
                        if(!obj.get("v.checked")==true)
                        {
                            rtn = false;
                        }
                    }
                }
                return rtn;
            }         
            else if(elechk != undefined)
            {
                if(elechk.get("v.required")==true)        
                {
                    if(elechk.get("v.checked")==true)
                    {
                        return rtn;
                    }  
                    else{
                        return false;
                    }     
                }
                return true
            } 
                else {
                    return true;
                }
        }
        catch(e)
        {
            console.log('Error: '+e);
        } 
    },
    
    validateAll : function(component,event,helper){
    },
    
    disabledFields:function(component){
        setTimeout(function(){
            var ele = component.find('inputFields');
            var sgnVal = component.find('signBttn');
            try
            {         
                //field type 1   
                if(ele instanceof Array)
                {
                    for(var i=0;i<ele.length;i++){
                        var obj = ele[i];
                        obj.set("v.disabled",true);
                    }
                }
                else if(ele != undefined && ele != null){                              
                    ele.set('v.disabled',true);
                }
                
                // sign  Disable 
                
                //field type 1   
                if(sgnVal instanceof Array)
                {
                    for(var i=0;i<sgnVal.length;i++){
                        var obj = sgnVal[i];
                        obj.set("v.disabled",true);
                    }
                }
                else if(sgnVal != undefined && sgnVal != null){                              
                    sgnVal.set('v.disabled',true);
                }
                //field type 2
                ele = component.find('inputRadioFields');
                if(ele instanceof Array)
                {
                    for(var i=0;i<ele.length;i++){
                        ele[i].set("v.disabled",true);
                    }
                }
                else if(ele != undefined)
                {
                    ele.set("v.disabled",true);
                }
                
                //field type 3
                ele = component.find('inputRichtextFields');
                if(ele instanceof Array)
                {
                    for(var i=0;i<ele.length;i++){
                        ele[i].set("v.disabled",true);
                    }    
                }
                else if(ele != undefined)
                {
                    ele.set("v.disabled",true);
                }
                
                //field type 4
                ele = component.find('inputDateFields');
                if(ele instanceof Array)
                {
                    for(var i=0;i<ele.length;i++){                    
                        ele[i].set("v.disabled",true);
                    }
                }
                else if(ele != undefined)
                {
                    component.find('inputDateFields').set("v.disabled",true);
                }
                
                //field type 5
                ele = component.find('inputDateTimeFields');
                if(ele instanceof Array)
                {
                    for(var i=0;i<ele.length;i++){                    
                        ele[i].set("v.disabled",true);
                    }
                }
                else if(ele != undefined)
                {
                    component.find('inputDateTimeFields').set("v.disabled",true);
                }
                
                
                //disabled checkbox
                var x = document.querySelectorAll("input[type='checkbox']");
                for(var i=0;i<x.length;i++){
                    x[i].disabled = true;
                }
            }
            catch(e)
            {
                console.log('Error: '+e);
            }
        },1000)
    },
    getTempRecord: function(component, event, vQnaireId) {        
        var action = component.get("c.getTemplateRecord"); //Calling Apex class controller 'getTemplateRecrod' method
        action.setParams({
            qnaireId: vQnaireId
        });
        action.setCallback(this, function(res) {            
            var state = res.getState();
            if (state === "SUCCESS") {
                if (res.getReturnValue().is_Published__c === true) {
                    component.set("v.disablePublishButton",true);
                } 
                component.set("v.objQnaire", res.getReturnValue());
                component.set("v.QnaireName", component.get("v.objQnaire.Name"));
            } else {
                this.showNewToast(component,"Error:",'error',res.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },
    setButtonColors: function(component,obj)
    {
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
    },
    deleteOldAttchmntIds: function(component)
    {
        var newIdsToDelete =component.get("v.listNewAttchIds");
        var listSignIds=component.get("v.listAttchIds"); 
        var allAttList = newIdsToDelete.concat(listSignIds);
        var action = component.get("c.delAttchmntListIds");
        action.setParams({
            newIdsToDelete: allAttList
        });
        action.setCallback(this,function(res){  
            var state = res.getState();
            if (state === "SUCCESS")
            {
                component.set("v.listNewAttchIds",[]);
                component.set("v.listAttchIds",[]); 
            }
        });
        $A.enqueueAction(action);
    }, //CCEN 747 Ends
    //BK-6779
    getFormName:function(component){
        var action = component.get("c.getFormName");
        action.setParams({"questionaryId":component.get("v.recordId")});
        action.setCallback(this,function(resp){
            component.set( "v.FormName",resp.getReturnValue());
        });
        $A.enqueueAction(action);
    }
})