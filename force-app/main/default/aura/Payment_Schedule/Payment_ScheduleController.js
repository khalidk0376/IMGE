({
    doInit: function(component, event ,helper) {
        helper.validateUsrProfile(component, event, helper);
        helper.getOppRecordDetail(component);
    },
    onchangeSave:function(component, event ,helper){        
        var d = new Date();
        var  month = '' + (d.getMonth() + 1);
        var day = '' + d.getDate();
        var year = d.getFullYear();
        if (month.length < 2) 
            month = '0' + month;
        if (day.length < 2) 
            day = '0' + day;
       // return [year, month, day].join('-');
        component.set('v.CustomDueDate', [year, month, day].join('-'));
        helper.saveRecordsTotalnoPayment(component, event ,helper);
        helper.renderInputFields(component);
        
    }, 
    
    dueDateClick:function(component, event ,helper){
        var eventEditionStartDate = component.get("v.EventStartDate");
        var totalPayment = component.get("v.TotalNoofPayment");
        var due1 = component.get("v.DueDate1")
        var due2 = component.get("v.DueDate2");
        var due3 = component.get("v.DueDate3");
        var due4 = component.get("v.DueDate4"); 
        var due5 = component.get("v.DueDate5");
        var due6 = component.get("v.DueDate6");
        var due7 = component.get("v.DueDate7");
        var due8 = component.get("v.DueDate8");
        var due9 = component.get("v.DueDate9");
        var due10 = component.get("v.DueDate10");
        var due11 = component.get("v.DueDate11");
        var due12 = component.get("v.DueDate12");
        // Modified by Avinash Shukla for BK-3502 , Added condition for allowing due date population when event edition start date is null.      
        var ProfileForEdit = component.get("v.ProfileToEdit");
        if(ProfileForEdit == 'Sales' || ProfileForEdit == 'Sales-Brazil' || ProfileForEdit == 'Sales-Brasil'  ){
            if((totalPayment == 1 && due1 <= eventEditionStartDate) || eventEditionStartDate === undefined){
                helper.saveRecordsAmountClick(component, event ,helper);      
            }
            else if((totalPayment == 2 && due1 <= eventEditionStartDate && due2 <= eventEditionStartDate) || eventEditionStartDate === undefined){
                helper.saveRecordsAmountClick(component, event ,helper);      
            }
                else if((totalPayment == 3 && due1 <= eventEditionStartDate && due2 <= eventEditionStartDate && due3 <= eventEditionStartDate) || eventEditionStartDate === undefined){
                    helper.saveRecordsAmountClick(component, event ,helper);      
                }
                    else if((totalPayment == 4 && due1 <= eventEditionStartDate && due2 <= eventEditionStartDate && due3 <= eventEditionStartDate && due4 <= eventEditionStartDate) || eventEditionStartDate === undefined){
                        helper.saveRecordsAmountClick(component, event ,helper);      
                    }
                        else if((totalPayment == 5 && due1 <= eventEditionStartDate && due2 <= eventEditionStartDate && due3 <= eventEditionStartDate && due4 <= eventEditionStartDate &&
                                due5 <= eventEditionStartDate) || eventEditionStartDate === undefined){
                            helper.saveRecordsAmountClick(component, event ,helper);      
                        }
                            else if((totalPayment == 6 && due1 <= eventEditionStartDate && due2 <= eventEditionStartDate && due3 <= eventEditionStartDate && due4 <= eventEditionStartDate &&
                                    due5 <= eventEditionStartDate && due6 <= eventEditionStartDate ) || eventEditionStartDate === undefined){
                                helper.saveRecordsAmountClick(component, event ,helper);      
                            }
                                else if((totalPayment == 7 && due1 <= eventEditionStartDate && due2 <= eventEditionStartDate && due3 <= eventEditionStartDate && due4 <= eventEditionStartDate &&
                                        due5 <= eventEditionStartDate && due6 <= eventEditionStartDate && due7 <= eventEditionStartDate ) || eventEditionStartDate === undefined){
                                    helper.saveRecordsAmountClick(component, event ,helper);      
                                }
                                    else if((totalPayment == 8 && due1 <= eventEditionStartDate && due2 <= eventEditionStartDate && due3 <= eventEditionStartDate && due4 <= eventEditionStartDate &&
                                            due5 <= eventEditionStartDate && due6 <= eventEditionStartDate && due7 <= eventEditionStartDate && due8 <= eventEditionStartDate) || eventEditionStartDate === undefined){
                                        helper.saveRecordsAmountClick(component, event ,helper);      
                                    }
                                        else if((totalPayment == 9 && due1 <= eventEditionStartDate && due2 <= eventEditionStartDate && due3 <= eventEditionStartDate && due4 <= eventEditionStartDate &&
                                                due5 <= eventEditionStartDate && due6 <= eventEditionStartDate && due7 <= eventEditionStartDate && due8 <= eventEditionStartDate &&
                                                due9 <= eventEditionStartDate) || eventEditionStartDate === undefined){
                                            helper.saveRecordsAmountClick(component, event ,helper);      
                                        }
                                            else if((totalPayment == 10 && due1 <= eventEditionStartDate && due2 <= eventEditionStartDate && due3 <= eventEditionStartDate && due4 <= eventEditionStartDate &&
                                                    due5 <= eventEditionStartDate && due6 <= eventEditionStartDate && due7 <= eventEditionStartDate && due8 <= eventEditionStartDate &&
                                                    due9 <= eventEditionStartDate && due10 <= eventEditionStartDate) || eventEditionStartDate === undefined){
                                                helper.saveRecordsAmountClick(component, event ,helper);      
                                            }
                                                else if((totalPayment == 11 && due1 <= eventEditionStartDate && due2 <= eventEditionStartDate && due3 <= eventEditionStartDate && due4 <= eventEditionStartDate &&
                                                        due5 <= eventEditionStartDate && due6 <= eventEditionStartDate && due7 <= eventEditionStartDate && due8 <= eventEditionStartDate &&
                                                        due9 <= eventEditionStartDate && due10 <= eventEditionStartDate && due11 <= eventEditionStartDate) || eventEditionStartDate === undefined){
                                                    helper.saveRecordsAmountClick(component, event ,helper);      
                                                }
                                                    else if((totalPayment == 12 && due1 <= eventEditionStartDate && due2 <= eventEditionStartDate && due3 <= eventEditionStartDate && due4 <= eventEditionStartDate &&
                                                            due5 <= eventEditionStartDate && due6 <= eventEditionStartDate && due7 <= eventEditionStartDate && due8 <= eventEditionStartDate &&
                                                            due9 <= eventEditionStartDate && due10 <= eventEditionStartDate && due11 <= eventEditionStartDate && due12 <= eventEditionStartDate) || eventEditionStartDate === undefined){
                                                        helper.saveRecordsAmountClick(component, event ,helper);      
                                                    }   
                                                        else{
                                                            console.log('Event Start Date Value ::: ' + eventEditionStartDate);
                                                            var toastEvent = $A.get("e.force:showToast");
                                                            toastEvent.setParams({
                                                                title : 'Error',
                                                                message:'Check all the due dates, you cannot give any due date after Event Start Date',
                                                                duration:'6000',
                                                                type: 'error'
                                                            });
                                                            toastEvent.fire();  
                                                        }
        }
        else if(ProfileForEdit == 'System Administrator' || ProfileForEdit == 'GE BA Administrator' || ProfileForEdit == 'GE System Administrator' || ProfileForEdit == 'SSC Finance-Accounting' || ProfileForEdit == 'Operations' ){
            helper.saveRecordsAmountClick(component, event ,helper);
        }
        helper.renderInputFields(component);
    },
    
    amountClick:function(component, event ,helper){
        helper.saveRecordsAmountClick(component, event ,helper);   
        helper.renderInputFields(component);
    },
    
    PaymentSchedulejs : function(component, event ,helper) {
        helper.renderPaymentSchedulejs(component);
        helper.PaymentSchedulejshelper(component);
        helper.getOppRecordDetail(component);
    },
    PaymentSchedule2js : function(component, event ,helper) {
        helper.renderPaymentSchedule2js(component);
        helper.PaymentSchedulejshelper(component);
        helper.getOppRecordDetail(component);
    },
    CustomPaymentjs : function(component, event ,helper) {
        helper.customPaymentRenderFields(component);
        var d = new Date();
       // var d = new Date(date),
          var  month = '' + (d.getMonth() + 1);
           var day = '' + d.getDate();
           var year = d.getFullYear();
        
        if (month.length < 2) 
            month = '0' + month;
        if (day.length < 2) 
            day = '0' + day;
        
       // return [year, month, day].join('-');
        component.set('v.CustomDueDate', [year, month, day].join('-'));
    },
    
    TotalNoofPaymentjs : function(component, event ,helper) {
        helper.renderInputFields(component);
    },
})