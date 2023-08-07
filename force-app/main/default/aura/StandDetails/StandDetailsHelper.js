({
    getStandDetails: function(component, event, helper)
    {
        //console.log('getStandDetailsCtr ......');
        var sEventId = component.get("v.EventEditionID");// Getting values from Aura attribute variable.
        var boothContMapping=component.get("v.childsingleBooth[0]");
        var agntID; 
        if(boothContMapping.Agent_Contact__c)
        {
            agntID = boothContMapping.Agent_Contact__r.AccountId;
        }
        var AccId1=component.get("v.AccountId");
        var BthID1=component.get("v.BoothID");
        
        //console.log('AccountId ==== '+AccId1 +'BoothID ===  '+BthID1);
        
        if(AccId1){
            var action = component.get("c.getStandDetailsCtr"); //Calling Apex class controller 'getStandDetailsCtr' method
            action.setParams({
                sAccId: AccId1,
                sBthID:BthID1,
                sEventId:sEventId,
                agentId:agntID
            });
            action.setCallback(this, function(res)
            {            
                var state = res.getState();
                if (state === "SUCCESS") 
                {   
                    try{
                        var data=res.getReturnValue();
                        console.log('data>>>>>'+JSON.stringify(data));
                        if(data.length>0)
                        {
                            if(data[0].IsRigging__c == true)
                            { 
                                component.set("v.NoRigging",false);
                                if(data[0].Rigging_Height__c)
                                {
                                    var riggHeight = data[0].Rigging_Height__c.toString().split('.');                                
                                    //console.log(riggHeight);
                                    if(riggHeight[0])
                                    {
                                        data[0].RiggingHeight= riggHeight[0].toString();
                                        
                                    }
                                    if(riggHeight[1])
                                    {
                                        data[0].RiggingHeightDecimal= '.'+riggHeight[1].toString();
                                    }
                                }                                
                            }  
                            if(data[0].Stand_Height__c){
                                var standHeight = data[0].Stand_Height__c.toString().split('.');
                                data[0].StandHeight=  standHeight[0].toString();
                                if(standHeight.length>1)
                                {
                                    data[0].StandHeightDecimal= '.'+standHeight[1].toString();
                                }
                            }
                            if(!data[0].Amount__c){ 
                                data[0].Amount__c='';
                            }
                            if(!data[0].Receipt__c){ 
                                data[0].Receipt__c=''; 
                            }
                            if(data[0].IsReceived__c == true)
                            { 
                                data[0].isReceivedYes=true; 
                            }
                            else
                            {
                                data[0].isReceivedNo=true; 
                            }
                            if(data[0].Require_Early_Access__c== true)
                            {
                                data[0].requireEarlyAccessYes=true;
                            }
                            else
                            {
                                component.set("v.disDateTime", true);
                                data[0].requireEarlyAccessNo=true;
                            }
                           component.set("v.StandDetail",data);
                        }
                        else{
                            component.set("v.StandDetail[0]",{Amount__c:'',requireEarlyAccessYes:false,requireEarlyAccessNo:false,isReceivedYes:false,isReceivedNo:false,Receipt__c:'',Riggering_Options__c:''});
                            
                        }
                    }
                    catch(err) 
                    {
                        console.log('There Was A error :- '+ err.message);
                    }
                    
                }
            });
            $A.enqueueAction(action);
        } 
    },
    fetchEventDetails : function(component) {
        var sEventId = component.get("v.EventEditionID");// Getting values from Aura attribute variable.
        var booth=component.get("v.childsingleBooth[0]");
        //console.log('sEventId>>>>>'+sEventId);
        //console.log('booth>>>>>'+JSON.stringify(booth));
        var action = component.get("c.getEventDetails"); //Calling Apex class controller 'getEventDetails' method
        action.setParams({
            sEventId : sEventId
        });
        action.setCallback(this, function(response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === "SUCCESS") 
            {
                var vActive = response.getReturnValue();
                component.set("v.eventSettings",vActive);
                //console.log('eventSettings>>>>>'+JSON.stringify(vActive));
                //console.log('id = '+vActive.Name +'-----value='+vActive.Cont_MyExhibitor_Detail_Tab2_Max_Rigging__c);
                var eCode=vActive.Event_Edition__r.Event_Code__c;
                
                if(!booth.IsManagedbyAgent__c)
                {
                    document.getElementById("linkMapIt").href="https://www.expocad.com/host/fx/informa/"+eCode+"/exfx.html?zoomto="+booth.Opp_Booth_Mapping__r.Booth_Number__c+"#floorplan"; 
                }
                this.Setmaxheight(component,"MaxRiggingHeight",vActive.Cont_MyExhibitor_Detail_Tab2_Max_Rigging__c);
                this.Setmaxheight(component,"MaxstandHeight",vActive.Cont_MyExhibitor_Detail_Tab_2_Max_Stand__c);
                //this.getStandDetails(component);
                this.setDecimalVal(component,"maxstandHeightDecimal");
                this.setDecimalVal(component,"maxRiggingHeighDecimal");
            }
        });
        $A.enqueueAction(action);
    },
    
    // This Function is used to set maximum value in Stand/Rigging Height picklists
    
    Setmaxheight : function(component , componentName , maxvalue) {
        var opts=[];        	
        for(var i=1;i<=maxvalue ;i++){
            opts.push({label: i, value: i });
        }
        component.find(componentName).set("v.options",opts);
    },	
    setDecimalVal : function(component , componentName ) {
        var opts=[];        	
        for(var i=0;i<10 ;i++){
            opts.push({label: '.'+i, value: '.'+i});
        }
        component.find(componentName).set("v.options",opts);
    },
    
    SaveStandDetailAndSendEmail: function(component, event, helper)
    {
        var boothContMapping=component.get("v.childsingleBooth[0]");
        var action = component.get("c.saveStandDetailCtr"); //Calling Apex class controller 'SaveStandDetailCtr' method
        var StndDtailData=component.get("v.StandDetail[0]");
        var StndDtail =  StndDtailData;
        
        delete StndDtail.Amount__c;
        delete StndDtail.IsReceived__c;
        //delete StndDtail.isReceivedNo ;
        delete StndDtail.Receipt__c;
        if(StndDtailData.IsRigging__c == true)
        {
            delete StndDtail.Riggering_Options__c; 
        }else
        {
            StndDtail.Riggering_Options__c = ''; 
        }  
       	StndDtail.BoothContractorMapping__c=boothContMapping.Id;
        var AccId1=component.get("v.AccountId");        
        var eEId1=component.get("v.EventEditionID");
        var boothId1=component.get("v.BoothID");
        var BoothStatus1='Edited Stand Details';        
        if(boothContMapping.Agent_Contact__c)
        {
            StndDtail.Agent_Account__c = boothContMapping.Agent_Contact__r.AccountId;
            StndDtail.Event_Edition__c = eEId1;
        }
        if(StndDtail.IsRigging__c == true)
        {
            StndDtail.Rigging_Height__c= StndDtail.newRiggingHeight;
        }
        StndDtail.Stand_Height__c=  StndDtail.newStandHeight;
        //StndDtail.ExpocadBooth__c = boothId1;
        //StndDtail.Account__c = AccId1;
        //console.log('===BCMId '+boothContMappingId);
        //console.log('StndDtail----->>>>'+JSON.stringify(StndDtail));
        action.setParams({
            oStndDtail:StndDtail,
            sAccId:AccId1,
            eEId:eEId1, 
            sBoothId:boothId1,
            sBoothStatus:BoothStatus1,
            boothContMappingId:boothContMapping.Id 
            
        });
        action.setCallback(this, function(res)
        {            
            var state = res.getState();
            if (state === "SUCCESS")
            {                   
                component.set("v.msgcolor","green");           
                component.set("v.message",res.getReturnValue());
                this.getStandDetails(component);
                
            }else
            {
                //alert('Error!'); 
            }
        }); 
        $A.enqueueAction(action); 
    },
    SaveStandDetail: function(component, event, helper) {
        var boothContMapping=component.get("v.childsingleBooth[0]");
        var action = component.get("c.savePerformanceBond"); //Calling Apex class controller 'savePerformanceBond' method
        var StndDtailData=component.get("v.StandDetail[0]");
       	var agntID; 
        var standDateTime = new Date();
        console.log('standDateTime',standDateTime);
        if(boothContMapping.Agent_Contact__c)
        {
            agntID = boothContMapping.Agent_Contact__r.AccountId;
        }
        if(!StndDtailData.IsRigging__c)
        {
            StndDtailData.Riggering_Options__c= '';
        }        
        var StndDtail ={
            Id                          : StndDtailData.Id,                     
            Amount__c                   : StndDtailData.Amount__c,
            IsReceived__c               : StndDtailData.IsReceived__c,
            Receipt__c                  : StndDtailData.Receipt__c,
            IsRigging__c                : StndDtailData.IsRigging__c,
            Riggering_Options__c        : StndDtailData.Riggering_Options__c,
            BoothContractorMapping__c   : boothContMapping.Id,
            Early_Access_Cost__c        : StndDtailData.Early_Access_Cost__c,
            Early_Access_Date_Time__c   : StndDtailData.Early_Access_Date_Time__c,
            Require_Early_Access__c     : StndDtailData.Require_Early_Access__c,
            Agent_Account__c            : agntID,
            Event_Edition__c            : eEId1
        }; 
        if(!StndDtailData.Riggering_Options__c)
        {
            delete StndDtail.IsRigging__c; 
        }
        var AccId1=component.get("v.AccountId");
        var eEId1=component.get("v.EventEditionID");
        var boothId1=component.get("v.BoothID");
        var BoothStatus1='Edited Stand Details';
        
        
        action.setParams({
            oStndDtail:StndDtail,
            sAccId:AccId1,
            eEId:eEId1,
            sBoothId:boothId1,
            sBoothStatus:BoothStatus1
            
        });
        action.setCallback(this, function(res) {
            //debugger;
            var state = res.getState();
            if (state === "SUCCESS") {   
                //alert(res.getReturnValue()); 
                document.getElementById("requiredCheck").style.display = "none";
                document.getElementById("requireEarlyCheck").style.display = "none";
                this.getStandDetails(component);
                component.set("v.msgcolor","green");           
                //component.set("v.message",res.getReturnValue());
                component.set("v.msg",res.getReturnValue());
                
            }
        });
        $A.enqueueAction(action);
    },
    ChangeStndDtailRecrd: function(component, event, helper) {
        //debugger;
        //var BtnPressed = event.getSource();
        //var BtnID = BtnPressed.get('v.Id');
        var BtnID= event.currentTarget.id;
        if(BtnID==='requireEarlyAccessYes')
        {
            component.set("v.disDateTime", false);
            component.set("v.StandDetail[0].Require_Early_Access__c", true);
        }
       	else if(BtnID === 'requireEarlyAccessNo')
        {
            component.set("v.disDateTime", true);
            component.set("v.StandDetail[0].Require_Early_Access__c", false);
        }
        if(BtnID === 'IsHeavyMachineryYes')
        {
            component.set("v.StandDetail[0].Is_Heavy_Machinery__c", true);
        }
        else if(BtnID === 'IsHeavyMachineryNo')
        {
            component.set("v.StandDetail[0].Is_Heavy_Machinery__c", false);
        }
            else if(BtnID === 'IsVehiclesYes')
            {
                component.set("v.StandDetail[0].Is_Vehicles__c", true);
            }
                else if(BtnID === 'IsVehiclesNo')
                {
                    component.set("v.StandDetail[0].Is_Vehicles__c", false);
                }
                    else if(BtnID === 'IsDDYes')
                    {
                        component.set("v.StandDetail[0].IsDoubleDecker__c", true);   
                    }
                        else if(BtnID === 'IsDDNo')
                        {
                            component.set("v.StandDetail[0].IsDoubleDecker__c", false);
                        }
                            else if(BtnID === 'isRiggingYes')
                            {
                                component.set("v.StandDetail[0].IsRigging__c", true);
                                component.set("v.NoRigging",false);
                            }
                                else if(BtnID === 'isRiggingNo')
                                {
                                    component.set("v.StandDetail[0].IsRigging__c", false);
                                    component.set("v.StandDetail[0].RiggingHeight", '');
                                    component.set("v.StandDetail[0].RiggingHeightDecimal", '');
                                    component.set("v.StandDetail[0].Riggering_Options__c", '');
                                    component.set("v.NoRigging",true);
                                }
                                    else if(BtnID === 'isReceivedYes')
                                    {
                                        component.set("v.StandDetail[0].IsReceived__c", true);
                                    }
                                        else if(BtnID === 'isReceivedNo')
                                        {
                                            component.set("v.StandDetail[0].IsReceived__c", false);
                                        }
        
    },
    fetchPicklistValues : function (component, objName, field ,componentName  ) {
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
                for(var i=0;i< result.length;i++){
                    opts.push({label: result[i].split('__$__')[1], value: result[i].split('__$__')[0]});
                }
                component.find(componentName).set("v.options",opts); // Adding values in Aura attribute variable..
            }
        })
        $A.enqueueAction(action)
    },
    ReInitialize: function(component, event, helper) {
        component.set("v.AccountId",'');
        component.set("v.StandDetail",'');
        
    },
    
})