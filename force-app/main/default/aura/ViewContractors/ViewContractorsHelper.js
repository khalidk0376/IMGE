({
    getOrgType:function(component){
        //isSandbox  
        var action = component.get("c.isSandbox");
      action.setCallback(this, function(res) {
          component.set("v.isSandbox",res.getReturnValue()); 
      });
      $A.enqueueAction(action);        
  },
    filterContractor:function(component) {
        component.set("v.isSpinner", true);// Adding values in Aura attribute variable. 
      	console.log('boothDesignStatus',component.get("v.selectedValue2"));
        var pageSize=component.get("v.pageSize");  ;
        var action = component.get("c.getAllFilterContractor"); //Calling Apex class controller 'getContractorbyfilterCtr' method
        action.setParams({  
          boothDesignStatus: component.get("v.selectedValue2"),
          sStatus: component.get("v.selectedValue"),
          riggedOption: component.get("v.selectedRiggedOption"),
          searchTearm:component.get("v.searchTearm"),
          bDblDckrStatus: component.get("v.isDoubleDecker"),
          bCA:component.get("v.isCA"),
          pbs:component.get("v.isPBS"),
          pbns:component.get("v.isPBNS"),
          sme:component.get("v.isSME"),
          isAllAgt:component.get("v.isAllAgt"),
          isAgtPvnSpc:component.get("v.isAgtPvnSpc"),
          sEventId:component.get("v.EventId"),
          column:'',//component.get("v.sortingColumn"),
          order:'',//component.get("v.sortingOrder"),
          pageNumber:component.get("v.PageNumber"),
          pageSize : pageSize 
        });
        action.setCallback(this, function(res) {
            var result=res.getReturnValue();
           	//console.log('data-------'+JSON.stringify(result));
            var state = res.getState();
            //console.log("state"+state);
            if (state === "SUCCESS")
            {             
                //component.set("v.wrapperList", result.lstWrapper); 
                // let testData = this.formatRecord(component, result.lstWrapper);
                //  let tes = [];
                //  for(let i=0;i<30;i++){
                //      tes.push(testData[0]);
                //  }
                component.set("v.wrapperList", this.formatRecord(component, result.lstWrapper));
                component.set("v.PageNumber", result.pageNumber);
                component.set("v.TotalRecords", result.totalRecords);
                component.set("v.RecordStart", result.recordStart);
                component.set("v.RecordEnd", result.recordEnd);
                component.set("v.TotalPages", Math.ceil(result.totalRecords / pageSize));
                component.set("v.isSpinner", false);// Adding values in Aura attribute variable. 
                //var scrollFunc = component.get("v.scrollFunc"); 
                //console.log('scrollFunc == '+scrollFunc);     
                var tabat = component.get("v.tabCssAtts");
                if (tabat) {
                    for (var i = 0; i < tabat.length; i++) {
                        if (tabat[i].tabId == component.get("v.selTabVal")) {
    
                            CopyToClipBoard.ScrollFunction(tabat[i].hraderId, tabat[i].tabledataId, tabat[i].tableId, 355, 48, true, component.get("v.isSandbox"));
                        }
                    }
                }
            } 
            else
            {
             component.set("v.isSpinner", false);// Adding values in Aura attribute variable.   
                var errors = res.getError();
                if (errors) {
                if (errors[0] && errors[0].message) {
                    console.log("Error message: " + errors[0].message);
                }
                }
            } 
        });
        $A.enqueueAction(action);
    },
    formatRecord : function(component,wraper) // to ittrate record and format before display
    {
        if(wraper)
        {
            for(var i=0;i<wraper.length;i++)
            {
                var dsndt = wraper[i].dBoothDsnSbmttdOn;
                if(!dsndt)
                {
                    wraper[i].dBoothDsnSbmttdOn = ' ';
                }
                if(!wraper[i].contractorPhone)
                {
                    wraper[i].contractorPhone = '';
                }
                if(!wraper[i].exhibOpeartionTel)
                {
                    wraper[i].exhibOpeartionTel = '';
                }
                if(!wraper[i].contContactMobile)
                {
                    wraper[i].contContactMobile = '';
                }               
                if(!wraper[i].boolRigHgt)
                {
                    wraper[i].boolRigHgt = '';
                }
                 if(!wraper[i].boolStdHgt)
                {
                    wraper[i].boolStdHgt = '';
                }
                if(!wraper[i].bvchle)
                {
                    wraper[i].bvchle = '';
                }
                if(!wraper[i].serlyaccDte_Time)
                {
                    wraper[i].serlyaccDte_Time = '';
                }
                if(!wraper[i].serlyAccCost)
                {
                    wraper[i].serlyAccCost = ' ';
                }
                if(wraper[i].strExhibitor)          // For Exhibitor Name
                {
                    wraper[i].strExhibitor = this.capitalizeFirstLetter(wraper[i].strExhibitor); 
                }
                if(wraper[i].exhibitingName)        // For Exhibiting Name
                {
                    wraper[i].exhibitingName = this.capitalizeFirstLetter(wraper[i].exhibitingName);
                }
                if(wraper[i].contractorCompany)     // For Contractor Name
                {
                    wraper[i].contractorCompany = this.capitalizeFirstLetter(wraper[i].contractorCompany);
                }
                if(wraper[i].agentName)     // For Contractor Name
                {
                    wraper[i].agentName = this.capitalizeFirstLetter(wraper[i].agentName);
                }else
                {
                    wraper[i].agentName = ' ';
                }
                if(wraper[i].isSelfManaged == true)
                {
                    wraper[i].contractorCompany = ' ';
                }
                
                try
                {
                    wraper[i].performanceBondAmount  = parseFloat(wraper[i].performanceBondAmount);
                }
                catch(err) 
                {
                    console.log('There Was A error With  BTHID while parsing performanceBondAmount :-  '+wraper[i].sId+ '   And ERR Msg :-   '+ err.message);
                    wraper[i].performanceBondAmount  = parseFloat('0');
                }
            }
            return wraper;
        }
        else{return}
    },
    capitalizeFirstLetter :function (string) 
    {
        var val= '';
        if(string)
        {
            val = string.charAt(0).toUpperCase() + string.slice(1);  
        }
        return val;
    },
    singleRecord: function(component, event, vSingleId) {
        var action = component.get("c.getSingleApprovalRequest"); //Calling Apex class controller 'getSingleApprovalRequest' method
        var target = event.getSource();
        var vSId = target.get("v.value");
        action.setParams({
            singleId: vSId
        });
        action.setCallback(this, function(res)
        {
            var state = res.getState();
            if (state === "SUCCESS") {
                component.set("v.isSpinner", false);// Adding values in Aura attribute variable.
                document.getElementById('confirm').style.display = "block";
                var data = res.getReturnValue();
                if(data && data.length>0)
                {
                    component.set("v.singleBooth", data);// Adding values in Aura attribute variable.
                    if(data[0].Contact__r!=undefined && data[0].Contact__r!=null)
                    {
                      component.set("v.PrntAccountId", data[0].Contact__r.AccountId);
                    }
                    component.set("v.PrntEventEditionId", data[0].Event_Edition__c);
                    component.set("v.PrntBoothId", data[0].Opp_Booth_Mapping__c);
                }
                //console.log('data-------'+JSON.stringify(res.getReturnValue()));
            }else
            {
                component.set("v.isSpinner", false);// Adding values in Aura attribute variable.
                console.log('Some Error occurred !');
            } 
        });
        $A.enqueueAction(action);
    },
    getDesignationInfos: function(component) {
        var action = component.get("c.getDesignationInfo"); 
        var EventId = component.get("v.EventId");
        action.setParams({ sEventId:EventId});
        action.setCallback(this, function(res)
        {
            var state = res.getState();
            if (state === "SUCCESS")
            {                
                component.set("v.designationInfo", res.getReturnValue());
            }else
            {
                console.log('ERROR!');
            }
            //console.log('designationInfo ------- : '+JSON.stringify(res.getReturnValue()));
        });
        $A.enqueueAction(action); 
    },
    getAggregateResults: function(component) {
        var action = component.get("c.getAggregateResult"); 
        var EventId = component.get("v.EventId");
        action.setParams({ sEventId:EventId});
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") { 
                //console.log('aggregateResults ' +JSON.stringify(res.getReturnValue()));                
              component.set("v.aggregateResults", res.getReturnValue());
            }
            else
            {
                component.set("v.isSpinner", false);// Adding values in Aura attribute variable.   
                var errors = res.getError();
                if (errors) {
                if (errors[0] && errors[0].message) {
                    console.log("Error message: " + errors[0].message);
                }
                }
            } 
        });
        $A.enqueueAction(action); 
    },
   loadTabs: function(component, event, helper) {
       // //debugger;;      
        var tab = event.getSource();
        var tabId = tab.get('v.id');
       if(tabId === 'tab2' || tabId === 'tab3' || tabId === 'tab4' || tabId === 'tab5'|| tabId === 'tab6' || tabId === 'tab7'){
         component.set("v.clonePrntAccountId", component.get("v.PrntAccountId"));
       }
   },  
   fetchPicklistValues : function (component, objName, field,attribute,defaultValue) {
        var action = component.get('c.getPicklistValues');
        action.setParams({
            objApi:objName,
            fieldName:field
        });
        action.setCallback(this, function (res) {
            var state = res.getState()
            var result=res.getReturnValue();
            if (component.isValid() && state === 'SUCCESS') {
                var opts=[];    
                if(defaultValue) 
                {
                    opts.push({label: defaultValue, value:'All'});
                }   
                for(var i=0;i< result.length;i++){
                    opts.push({label: result[i].split('__$__')[0], value: result[i].split('__$__')[1]});
                }
                component.set(attribute, opts);// Adding values in Aura attribute variable.
            }
        })
        $A.enqueueAction(action)
    },
   exportData: function(component,event,helper){
        // get the Records [WrapperList] list from 'ViewContractor.cmp' component 
        var wrapperList = component.get("v.wrapperList");
        var Records ; //final list 
        // check if "Records" parameter is null, then return from function
            if(wrapperList == null || !wrapperList.length) {
                return null;
            }else{
                Records = wrapperList;
                for(var i = 0;i<Records.length;i++){
                    if(Records[i].isSelfManaged){
                        Records[i].contractorCompany = 'Self Managed';  
                    }
                }
            }
           // declare variables
        var csvStringResult;
        var counter; 
        var keys; 
        
       // store ,[comma] in columnDivider variabel for sparate CSV values and 
        // for start next line use '\n' [new line] in lineDivider varaible  
        var columnDivider = ',';
        var lineDivider =  '\n';

       
        // check if "Records" parameter is null, then return from function
        if (Records == null || !Records.length) { 
            return null;
         }

        // in the keys variable store fields API Names as a key 
        // these labels use in CSV file header  
        keys = ['strExhibitor','exhibitingName','exhibitorPhone','exhibitorEmail','strBooth','contractorCompany','isReceived','performanceBondAmount','contractorEmail','boolRigging','boolDblDckr','boolHevyMachin','dBoothDsnSbmttdOn',
                'boolCA','sBoothStatus','sContrctorStatus','sRcntNote','sreqErlyAcc','serlyaccDte_Time','serlyAccCost','contractorPhone','exhibOpeartionCon','exhibOpeartionEmail','exhibOpeartionMobile','exhibOpeartionTel','contContactName','contContactMobile','contContactTel','contContactEmail','exhUsername','conUsername','bStand','bRigg','bvchle','blenght','bwidth'];
    	var map = {
           'strExhibitor' : 'EXHIBITOR',
           'exhibitingName':'Exhibiting Name',
           'strBooth' : 'BOOTH#',
           'contractorCompany' : 'CONTRACTOR COMPANY',
           'isReceived' : 'PERFORMANCE BOND SUBMITTED',
           'performanceBondAmount' : 'PERFORMANCE BOND AMOUNT',
           'boolRigging' : 'RIGGING',
           'boolDblDckr' : 'DOUBLE DECKER',
           'boolHevyMachin' : 'HEAVY MACHINERY',
           'dBoothDsnSbmttdOn' : 'BOOTH DESIGN SUBMITTED ON',
           'boolCA' : 'CA',
           'sBoothStatus' : 'BOOTH STATUS',
           'sContrctorStatus' : 'DESIGNATION STATUS',
           'sRcntNote' : 'NOTES',          
           'contractorEmail':'CONTRACTOR EMAIL',
           'exhibitorPhone':'EXHIBITOR PHONE',
           'exhibitorEmail':'EXHIBITOR EMAIL',
           'sreqErlyAcc':'REQUIRED EARLY ACCESS?',
           'serlyaccDte_Time':'EARLY ACCESS DATE/TIME',
       	   'serlyAccCost':'EARLY ACCESS COST', 
           'contractorPhone':'CONTRACTOR PHONE',
           'exhibOpeartionCon':'EXHIBITOR OPERATION CONTACT',
           'exhibOpeartionEmail':'EXHIBITOR OPERATION EMAIL',
           'exhibOpeartionMobile':'EXHIBITOR OPERATION MOBILE',
           'exhibOpeartionTel':'EXHIBITOR OPERATION TELEPHONE',
           'contContactName':'CONTRACTOR CONTACT NAME',
           'contContactMobile':'CONTRACTOR CONTACT MOBILE',
           'contContactTel':'CONTRACTOR CONTACT TELEPHONE',
           'contContactEmail':'CONTRACTOR CONTACT EMAIL', 
           'exhUsername':'EXHIBITOR USERNAME',  
           'conUsername':'CONTRACTOR USERNAME',
           'bStand':'STAND HEIGHT',
           'bRigg':'RIGGING HEIGHT',
           'bvchle':'VEHICLE',
           'blenght':'LENGTH',
           'bwidth':'WIDTH', 
      };
        
        csvStringResult = '';
        csvStringResult += keys.join(columnDivider);
        csvStringResult += lineDivider;
 
        for(var i=0; i < Records.length; i++){   
            counter = 0;
           
             for(var sTempkey in keys) {
                var skey = keys[sTempkey] ;  
 
              // add , [comma] after every String value,. [except first]
                  if(counter > 0){ 
                      csvStringResult += columnDivider; 
                   }   
               
               csvStringResult += '"'+ Records[i][skey]+'"'; 
               
               counter++;
 
            } // inner for loop close 
             csvStringResult += lineDivider;
          }// outer main for loop close 
       
       var FinalcsvStringResult = csvStringResult.split('\n');
       FinalcsvStringResult[0] = FinalcsvStringResult[0].replace(/strExhibitor|exhibitingName|strBooth|contractorCompany|isReceived|performanceBondAmount|boolRigging|boolDblDckr|boolHevyMachin|dBoothDsnSbmttdOn|boolCA|sBoothStatus|sContrctorStatus|sRcntNote|contractorEmail|exhibitorPhone|exhibitorEmail|sreqErlyAcc|serlyaccDte_Time|serlyAccCost|contractorPhone|exhibOpeartionCon|exhibOpeartionEmail|exhibOpeartionMobile|exhibOpeartionTel|contContactName|contContactMobile|contContactTel|contContactEmail|exhUsername|conUsername|bStand|bRigg|bvchle|blenght|bwidth/gi, function(matched){
           return map[matched];
       });
      FinalcsvStringResult= FinalcsvStringResult.join('\n');
       console.log('FinalcsvStringResult'+FinalcsvStringResult);
        return FinalcsvStringResult.replace(/undefined|FALSE/gi,'');
        //return FinalcsvStringResult.replace(/FALSE/gi,'');
       
       // return the CSV formate String 
        //return csvStringResult;        
  },
  sortData: function (component, fieldName, sortDirection)
  {
    //console.log('fieldName ==== '+ fieldName +' sortDirection === '+sortDirection);
    var data = component.get("v.wrapperList");
    var reverse = sortDirection !== 'asc';
   	data.sort(this.sortBy(fieldName, reverse))
   	component.set("v.wrapperList", data);
  },
  sortBy: function (field, reverse, primer) {
    var key = primer ?
    function(x) {return primer(x[field])} :
    function(x) {return x[field]};
    reverse = !reverse ? 1 : -1;
    return function (a, b) {
    return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
    }
  },
  toggleColumnCheck: function(component,event,helper){
    var allColumns = localStorage.getItem('allColumns'); 
      console.log('allColumns',allColumns);
    if (allColumns) 
    { 
        //localStorage.removeItem('allColumns');
        component.set("v.tableColumns",JSON.parse(allColumns)); 
       
    }
    else 
    {	
        
        var columns=[{column:'CUSTOMER',visible:true},{column:'TYPE',visible:true},{column:'EXHIBITOR NAME',visible:true},{column:'AGENT NAME',visible:true},{column:'BOOTH#',visible:true},{column:'MATCHED PRODUCT NAME',visible:true},{column:'CONTRACTOR COMPANY',visible:true},{column:'PERFORMANCE BOND SUBMITTED',visible:true},{column:'PERFORMANCE BOND AMOUNT',visible:true},{column:'RIGGING',visible:true},{column:'DOUBLE DECKER',visible:true},{column:'HEAVY MACHINERY',visible:true},{column:'VEHICLE',visible:true},{column:'BOOTH DESIGN SUBMITTED ON',visible:true},{column:'CA',visible:true},{column:'BOOTH STATUS',visible:true},{column:'DESIGNATION STATUS',visible:true},{column:'NOTES',visible:true},{column:'Require Early Access?',visible:true},
                     {column:'Early Access Date/Time',visible:true},{column:'Early Access Cost',visible:true},{column:'CONTRACTOR MOBILE NUMBER',visible:true}, {column:'EXHIBITOR OPERATION CONTACT',visible:true},{column:'EXHIBITOR OPERATIONS EMAIL',visible:true},
                     {column:'EXHIBITOR OPERATIONS MOBILE NO',visible:true},{column:'EXHIBITOR OPERATIONS TEL',visible:true},
                     {column:'CONTRACTOR CONTACT NAME',visible:true},{column:'CONTRACTOR CONTACT TEL',visible:true},
                     {column:'CONTRACTOR CONTACT MOBILE',visible:true},
                     {column:'CONTRACTOR CONTACT EMAIL',visible:true},{column:'EXHIBITOR USERNAME',visible:true},{column:'CONTRACTOR USERNAME',visible:true},{column:'STAND HEIGHT',visible:true},{column:'RIGGING HEIGHT',visible:true},{column:'LENGTH',visible:true},{column:'WIDTH',visible:true}];   
        component.set("v.tableColumns",columns);
        console.log('testCols',component.get("v.tableColumns"));
    }
  },
  deleteContractor: function(component ,bthConMapID ,rejectionReason ) {
      //console.log(bthConMapID);
    var action = component.get("c.deleteStandContractor");      
    action.setParams({ 
        bthConMapID:bthConMapID,
        rejectReason:rejectionReason
    });
    action.setCallback(this, function(res) { 
        var state = res.getState();
         console.log('state = '+state);
        var result= res.getReturnValue();
        if (state === "SUCCESS") {                
            console.log('result = '+result);
           this.filterContractor(component);
           this.getAggregateResults(component);
           this.getDesignationInfos(component);
        }else{
            console.log('some error occurred !');
        }
    });
    $A.enqueueAction(action); 
    },
    deleteDesignDetails: function(component ,bthConMapID ) {
        //console.log(bthConMapID);
      var action = component.get("c.deleteStandDesignAndStandDetail");      
      action.setParams({ bthConMapID:bthConMapID});
      action.setCallback(this, function(res) { 
          var state = res.getState();
          var result= res.getReturnValue();
          if (state === "SUCCESS") {                
              //console.log('result = '+result);getAggregateResults
              this.filterContractor(component);
              this.getAggregateResults(component);
              this.getDesignationInfos(component);
          }else{
              console.log('some error occurred !');
          }
      });
      $A.enqueueAction(action); 
    },
    fetchPavilionSpaceExhibitors: function (component) {

        var srchTxt = component.get("v.searchText");
        var sEventId = component.get("v.EventId");
        var Agent = component.get("v.CurrentAgent");
        //console.log(Agent.Id + '      fetchPavilionSpaceExhibitors    ' + srchTxt);
        var action = component.get("c.getAgentBooths"); //Calling Apex class controller 'EventDetailMethod' method
        action.setParams({
            sEventId: sEventId,
            accid: Agent.Id,
            srchText: srchTxt
        });
        action.setCallback(this, function (response) { 
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS") {
                var result = response.getReturnValue();
                //console.log('fetchPavilionSpaceExhibitors'+JSON.stringify(response.getReturnValue()));
                component.set("v.AgentsExhibitors",result);// Adding values in Aura attribute variable.Agents-Exhibitors
                document.getElementById('Agent_Exhibitormodel').style.display = "block";
            }
            else {
                component.set("v.AgentsExhibitors", []);
                console.log('Some Error Occured!');
            }
        });
        $A.enqueueAction(action);
    },    
    adjustHeader :function (component)
    {
        //get width of the NOT fixed header spans
        var a = $("span#tid").width();                 
    }
})