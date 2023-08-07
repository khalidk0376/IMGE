({
	onLoad: function(component,event,helper) {
        component.set("v.message",'');component.set("v.msg",'');
        helper.fetchPicklistValues(component,'Stand_Detail__c','Riggering_Options__c','RiggeringOptions');
        helper.fetchPicklistValues(component,'Stand_Detail__c','Open_Side__c','OpenSide');
        var Accid=component.get("v.AccountId");
       //console.log('EventEditionID '+component.get("v.EventEditionID"));
        if(Accid)
        {
            helper.getStandDetails(component);
        }
        helper.fetchEventDetails(component); 
    },
    TabChanged:function(component,event,helper) {
       // console.log('Changed!!');
        component.set("v.message",'');component.set("v.msg",''); 
        //helper.ReInitialize(component, event, helper); 
    },
    PopUpClosedChanges: function(component,event,helper) 
    { 
        component.set("v.message",'');
        component.set("v.msg",'');
        component.set("v.AccountId",'');
        //helper.ReInitialize(component, event, helper);
    },
    childsingleBoothChange: function(component,event,helper) {
        var booth=component.get("v.childsingleBooth[0]");
        if(booth)
        {
            helper.fetchEventDetails(component); 
        }  
     },
    AccountIdChanges: function(component,event,helper) {
        component.set("v.message",'');component.set("v.msg",'');
        var Accid=component.get("v.AccountId");
        //console.log('Accid : '+Accid);
        if(Accid)
        {
            helper.getStandDetails(component);
        }
    },
    SaveAndEmail: function(component,event,helper) {
        component.set("v.message","");
        document.getElementById('modalConfirmSave').style.display = "none";
        var standDetails=component.get("v.StandDetail[0]");
        
        standDetails.newStandHeight=standDetails.StandHeight+standDetails.StandHeightDecimal;
        standDetails.newRiggingHeight=standDetails.RiggingHeight+standDetails.RiggingHeightDecimal;
        //console.log('standDetails>>>>>'+JSON.stringify(standDetails));
        if(standDetails)
        {
            var eventSettings= component.get("v.eventSettings");
            var maxStandHeight=1000; var maxRiggingHeight=1000;
            if(eventSettings)
            {
                maxStandHeight=eventSettings.Cont_MyExhibitor_Detail_Tab_2_Max_Stand__c+eventSettings.Max_Stand_Height_Decimal__c;
			    maxRiggingHeight=eventSettings.Cont_MyExhibitor_Detail_Tab2_Max_Rigging__c+eventSettings.Max_Rigging_Height_Decimal__c;
            }

            if((!standDetails.newStandHeight || standDetails.newStandHeight<=0) || (!standDetails.newStandHeight || parseFloat(standDetails.newStandHeight)>parseFloat(maxStandHeight)))
            {
                component.set("v.msgcolor","red");
                component.set("v.message","Maximum stand height is : "+maxStandHeight+"m");
            }
            else if((standDetails.IsRigging__c && !standDetails.newRiggingHeight) ||(standDetails.IsRigging__c &&  standDetails.newRiggingHeight<=0) ||(standDetails.IsRigging__c &&  parseFloat(standDetails.newRiggingHeight) > parseFloat(maxRiggingHeight)))
            {
                component.set("v.msgcolor","red");
                component.set("v.message","Maximum rigging height is : "+maxRiggingHeight +"m");
            }
            else
            {     
                helper.SaveStandDetailAndSendEmail(component,event,helper);
            }
        }  
    }, 
    SaveAndUpdate: function(component,event,helper) {
        document.getElementById('modalConfirmSave1').style.display = "none";
        var StndDtailData=component.get("v.StandDetail[0]");
        var erlDateTime = StndDtailData.Early_Access_Date_Time__c;
        var reqErlyAcces = StndDtailData.Require_Early_Access__c;
        var amount = StndDtailData.Amount__c;
         var date2 = component.find('erlyAccessDateTime').get('v.value');
        console.log('reqErlyAcces',date2);
       
        console.log('erlDateTime',erlDateTime);
        var re = /^\d+(\.\d{1,2})?$/
        console.log('re',re);
        if(erlDateTime==undefined)
        {
            console.log('undefined');
            erlDateTime='';
		}
        if(!amount || re.test(amount))
        {
            if(reqErlyAcces==true && erlDateTime=='')
            {
                console.log('test1');
                document.getElementById("requiredCheck").style.display = "none";
                document.getElementById("requireEarlyCheck").style.display = "block";
            }
            else if(reqErlyAcces==false && erlDateTime!='')
            {
                console.log('test2');
                document.getElementById("requireEarlyCheck").style.display = "none";
                document.getElementById("requiredCheck").style.display = "block";
            }
            else{
            
                console.log('save');
                helper.SaveStandDetail(component,event,helper); 
            }
        }
        else
        {   
            component.set("v.msgcolor","Red");
            component.set("v.msg","Amount is not Correct!"); 
        }
       
    },
    handleChange: function(component,event,helper) {
        helper.ChangeStndDtailRecrd(component,event,helper);
    },
    waiting: function(component, event, helper) {
        document.getElementById("Accspinner").style.display = "block";
     },
    doneWaiting: function(component, event, helper) {
       document.getElementById("Accspinner").style.display = "none";
     },
     hidemodalConfirmSave: function(component, event, helper) {
        document.getElementById('modalConfirmSave').style.display = "none";
    },
    showmodalConfirmSave: function(component, event, helper) {
        document.getElementById('modalConfirmSave').style.display = "block";
    },
    hidemodalConfirmSave1: function(component, event, helper) {
        document.getElementById('modalConfirmSave1').style.display = "none";
    },
    showmodalConfirmSave1: function(component, event, helper) {
        document.getElementById('modalConfirmSave1').style.display = "block";
    },
    // standHeightchange : function(component, event, helper) {
    //    console.log('standHeightchange');
    //    helper.setDecimalVal(component,"maxstandHeightDecimal");
    // },
    // riggingHeighchange : function(component, event, helper) {
    //    console.log('riggingHeighchange');
    //    helper.setDecimalVal(component,"maxRiggingHeighDecimal");
    // },
})