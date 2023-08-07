({
    customPaymentRenderFields:function(component){
        var CustomPaymentcheck = component.get("v.CustomPayment");        
        if(CustomPaymentcheck == true){
            component.set("v.OnCustomCheckCheckBox", false);
            component.set("v.PaymentScheduleCheckBox", false);
            component.set("v.DefaultPaymentSchedule25", false);
            component.set("v.CustomPaymentCheckBox", true);
            component.set("v.PaymentSchedule", false);
            component.set("v.PaymentSchedule2", false);
            
            var totaNoPayment=component.get("v.TotalNoofPayment");
            if(totaNoPayment){
                this.renderInputFields(component);    
            }
            
        }else{
            component.set("v.OnCustomCheckCheckBox", true);
            component.set("v.PaymentScheduleCheckBox", false);
            component.set("v.DefaultPaymentSchedule25", false);
            component.set("v.CustomPaymentCheckBox", false);
            component.set("v.PaymentSchedule", false);
            component.set("v.PaymentSchedule2", false);
            component.set("v.NoofPayment1", false);
            component.set("v.NoofPayment2", false);
            component.set("v.NoofPayment3", false);
            component.set("v.NoofPayment4", false);
            component.set("v.NoofPayment5", false);
            component.set("v.NoofPayment6", false);
            component.set("v.NoofPayment7", false);
            component.set("v.NoofPayment8", false);
            component.set("v.NoofPayment9", false);
            component.set("v.NoofPayment10", false);
            component.set("v.NoofPayment11", false);
            component.set("v.NoofPayment12", false); 
        }
        
    },
    getOppRecordDetail:function(component){
        var action = component.get("c.getallDataRecord");
        action.setParams({"recordIdget":component.get("v.recordId")});
        action.setCallback(this,function(res){
            if(res.getState()==="SUCCESS")
            {
                var obj = res.getReturnValue();  
                component.set("v.TotalNoofPayment",obj.Total_No_of_payment__c);
                component.set("v.PaymentSchedule",obj.Payment_Schedules__c); 
                component.set("v.PaymentSchedule2",obj.Payment_Schedule_2__c);
                component.set("v.CustomPayment",obj.Custom_Payment__c);
                component.set("v.EventStartDate",obj.Event_Edition_Start_Date__c);
                
                if(obj.Custom_Payment__c){
                    this.customPaymentRenderFields(component); 
                    this.renderInputFields(component);
                }
                
                else if(obj.Payment_Schedules__c){
                    this.renderPaymentSchedulejs(component); 
                }
                
                    else if(obj.Payment_Schedule_2__c){
                        this.renderPaymentSchedule2js(component); 
                    }
                
                
                component.set("v.QuotedPaymentSchedule",obj.Quoted_Payment_Schedule__c)
                component.set("v.EventCutoffDate",obj.Event_Cutoff_DateF__c);
                component.set("v.EventCutoffDate1",obj.Event_Cutoff_Date_1_F__c);
                component.set("v.EventCutoffDate2",obj.Event_Cutoff_Date2F__c); 
                component.set("v.EventCutoffDate3",obj.Event_Cutoff_Date_3_F__c); 
                
                
                component.set("v.DefaultPaymentSchedule",obj.Event_Payment_ScheduleFor__c);
                component.set("v.CustomDueDate",obj.Start_Date__c);
                component.set("v.DueDate1",obj.Milestone_1_Delivery_Date__c)
                component.set("v.DueDate2",obj.Milestone_2_Delivery_Date__c);
                component.set("v.DueDate3",obj.Milestone_3_Delivery_Date__c);
                component.set("v.DueDate4",obj.Milestone_4_Delivery_Date__c); 
                component.set("v.DueDate5",obj.Milestone_5_Delivery_Date__c);
                component.set("v.DueDate6",obj.Milestone_6_Delivery_Date__c);
                component.set("v.DueDate7",obj.Milestone_7_Delivery_Date__c);
                component.set("v.DueDate8",obj.Milestone_8_Delivery_Date__c);
                component.set("v.DueDate9",obj.Milestone_9_Delivery_Date__c);
                component.set("v.DueDate10",obj.Milestone_10_Delivery_Date__c);
                component.set("v.DueDate11",obj.Milestone_11_Delivery_Date__c);
                component.set("v.DueDate12",obj.Milestone_12_Delivery_Date__c);
                component.set("v.AmountDue1",obj.Milestone_1_Amount__c);
                component.set("v.AmountDue2",obj.Milestone_2_Amount__c);
                component.set("v.AmountDue3",obj.Milestone_3_Amount__c);
                component.set("v.AmountDue4",obj.Milestone_4_Amount__c);
                component.set("v.AmountDue5",obj.Milestone_5_Amount__c);
                component.set("v.AmountDue6",obj.Milestone_6_Amount__c);
                component.set("v.AmountDue7",obj.Milestone_7_Amount__c);
                component.set("v.AmountDue8",obj.Milestone_8_Amount__c);
                component.set("v.AmountDue9",obj.Milestone_9_Amount__c);
                component.set("v.AmountDue10",obj.Milestone_10_Amount__c);
                component.set("v.AmountDue11",obj.Milestone_11_Amount__c);
                component.set("v.AmountDue12",obj.Milestone_12_Amount__c);
                component.set("v.CurrencyCode",obj.CurrencyIsoCode);
                component.set("v.TotalAmount",obj.Amount);
                
            }
            else{
                window._LtngUtility.handleErrors(res.getError());
            }
        });
        $A.enqueueAction(action);
    },  
    
    validateUsrProfile : function(component, event, helper){
        var getProfile = component.get("c.validateLoggedInUsr");
        getProfile.setParams({
            "recordIdget":component.get("v.recordId")
        });
        getProfile.setCallback(this,function(data){
            var state = data.getState();
            var responseResult = data.getReturnValue();
            if(state=='SUCCESS'){
                component.set("v.ProfileToEdit", responseResult);
            } 
        });
        $A.enqueueAction(getProfile);
    },
    PaymentSchedulejshelper : function (component){
        var PaymentSchedule = component.get("v.PaymentSchedule");
        var PaymentSchedule2 = component.get("v.PaymentSchedule2");
        var customPaymentcheck = component.get("v.CustomPayment");
        var DefaultPaymentSchedule = component.get("v.DefaultPaymentSchedule");
        var QuotedPaymentSchedule = component.get("v.QuotedPaymentSchedule");
        var EventCutoffDate1 = component.get("v.EventCutoffDate1");
        var EventCutoffDate2 = component.get("v.EventCutoffDate2");
        var EventCutoffDate3 = component.get("v.EventCutoffDate3");
        if(PaymentSchedule == true && PaymentSchedule2 == false && customPaymentcheck == false){
            var action = component.get("c.saveData");
            var fields  = {'sobjectType':'Opportunity',
                           'Id' : component.get("v.recordId") ,   
                           'Payment_Schedules__c' : component.get("v.PaymentSchedule") 
                          }; 
            
            action.setParams({
                'fields' : fields
            });
            action.setCallback(this,function(data){
                var state = data.getState();
                var response = JSON.stringify(data.getReturnValue());
                if(state=='SUCCESS'){
                    window._LtngUtility.toast('Success', 'success', 'Opportunity has been Updated Successfully');
                    this.getOppRecordDetail(component);
                }
                else if(state=="ERROR"){
                    window._LtngUtility.handleErrors(data.getError());
                }
            });
            $A.enqueueAction(action);
        }
        
        else if(PaymentSchedule == false && PaymentSchedule2 == true && customPaymentcheck == false){
            var action = component.get("c.saveData");
            var fields  = {'sobjectType':'Opportunity',
                           'Id' : component.get("v.recordId") ,   
                           'Payment_Schedule_2__c' : component.get("v.PaymentSchedule2") 
                          }; 
            
            action.setParams({
                'fields' : fields
            });
            action.setCallback(this,function(data){
                var state = data.getState();
                var response = JSON.stringify(data.getReturnValue());
                if(state=='SUCCESS'){
                    window._LtngUtility.toast('Success', 'success', 'Opportunity has been Updated Successfully');
                    this.getOppRecordDetail(component);
                }
                else if(state=="ERROR"){
                    window._LtngUtility.handleErrors(data.getError());
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    saveRecordsTotalnoPayment : function(component){
        var CusDueDate = component.get("v.CustomDueDate");       
        var TotalNoofPayment = component.get("v.TotalNoofPayment");
        var PaymentSchedule = component.get("v.PaymentSchedule");
        var PaymentSchedule2 = component.get("v.PaymentSchedule2");      
        var expirationDate = component.find("expdate").get("v.value");        
        if((CusDueDate == null || TotalNoofPayment == null) && PaymentSchedule == false && PaymentSchedule2 == false){
            window._LtngUtility.toast('Error','error',' "Due Date" or "Total Number of payment" can not be vacant');
        }
        
        else{                           
            var action = component.get("c.saveData");
            var fields  = {'sobjectType':'Opportunity',
                            'Id' : component.get("v.recordId") ,   
                            'Payment_Schedules__c' : component.get("v.PaymentSchedule") , 
                            'Payment_Schedule_2__c' : component.get("v.PaymentSchedule2") ,
                            'Custom_Payment__c' : component.get("v.CustomPayment") ,
                            'Event_Payment_ScheduleFor__c' : component.get("v.DefaultPaymentSchedule"),
                            'Total_No_of_payment__c' : component.get("v.TotalNoofPayment"),
                            'Start_Date__c' : component.get("v.CustomDueDate") 
                            }; 
                
            action.setParams({
                'fields' : fields
            });
            action.setCallback(this,function(data){
                var state = data.getState();
                var response = JSON.stringify(data.getReturnValue());
                if(state=='SUCCESS'){
                    window._LtngUtility.toast('Success', 'success', 'Opportunity has been Updated Successfully');
                    this.getOppRecordDetail(component);
                }
                else if(state=="ERROR"){
                    window._LtngUtility.handleErrors(data.getError());
                }
            });
            $A.enqueueAction(action);   
        }
    },

    saveRecordsAmountClick : function(component){
        var CusDueDate = component.get("v.CustomDueDate");     
        var TotalNoofPayment = component.get("v.TotalNoofPayment");
        var PaymentSchedule = component.get("v.PaymentSchedule");
        var PaymentSchedule2 = component.get("v.PaymentSchedule2");
        
        if((CusDueDate != null || TotalNoofPayment != null) && PaymentSchedule == false && PaymentSchedule2 == false){
            var action = component.get("c.saveData");
            var fields  = {'sobjectType':'Opportunity',
                           'Id' : component.get("v.recordId") ,   
                           'Payment_Schedules__c' : component.get("v.PaymentSchedule") , 
                           'Payment_Schedule_2__c' : component.get("v.PaymentSchedule2") ,
                           'Custom_Payment__c' : component.get("v.CustomPayment") ,
                           'Event_Payment_ScheduleFor__c' : component.get("v.DefaultPaymentSchedule"),
                           'Total_No_of_payment__c' : component.get("v.TotalNoofPayment") ,
                           'Start_Date__c' : component.get("v.CustomDueDate") ,
                           'Milestone_1_Delivery_Date__c' : component.get("v.DueDate1") ,
                           'Milestone_2_Delivery_Date__c' : component.get("v.DueDate2") ,
                           'Milestone_3_Delivery_Date__c' : component.get("v.DueDate3") ,
                           'Milestone_4_Delivery_Date__c' : component.get("v.DueDate4") , 
                           'Milestone_5_Delivery_Date__c' : component.get("v.DueDate5") ,
                           'Milestone_6_Delivery_Date__c' : component.get("v.DueDate6") ,
                           'Milestone_7_Delivery_Date__c' : component.get("v.DueDate7") ,
                           'Milestone_8_Delivery_Date__c' : component.get("v.DueDate8") ,
                           'Milestone_9_Delivery_Date__c' : component.get("v.DueDate9") ,
                           'Milestone_10_Delivery_Date__c' : component.get("v.DueDate10") ,
                           'Milestone_11_Delivery_Date__c' : component.get("v.DueDate11") ,
                           'Milestone_12_Delivery_Date__c' : component.get("v.DueDate12") ,
                           'Milestone_1_Amount__c' : component.get("v.AmountDue1") ,
                           'Milestone_2_Amount__c' : component.get("v.AmountDue2") ,
                           'Milestone_3_Amount__c' : component.get("v.AmountDue3") ,
                           'Milestone_4_Amount__c' : component.get("v.AmountDue4") ,
                           'Milestone_5_Amount__c' : component.get("v.AmountDue5") ,
                           'Milestone_6_Amount__c' : component.get("v.AmountDue6") ,
                           'Milestone_7_Amount__c' : component.get("v.AmountDue7") ,
                           'Milestone_8_Amount__c' : component.get("v.AmountDue8") ,
                           'Milestone_9_Amount__c' : component.get("v.AmountDue9") ,
                           'Milestone_10_Amount__c' : component.get("v.AmountDue10") ,
                           'Milestone_11_Amount__c' : component.get("v.AmountDue11") ,
                           'Milestone_12_Amount__c' : component.get("v.AmountDue12") 
                          }; 
            
            action.setParams({
                'fields' : fields
            });
            action.setCallback(this,function(data){
                var state = data.getState();
                var response = JSON.stringify(data.getReturnValue());
                if(state=='SUCCESS'){
                    this.getOppRecordDetail(component);
                    //window._LtngUtility.toast('Success', 'success', 'Opportunity has been Updated Successfully');
                }
                else if(state=="ERROR"){
                    window._LtngUtility.handleErrors(data.getError());
                }
            });
            $A.enqueueAction(action);
        }   
    },
    
    renderInputFields:function(component){
        var varTotalNoofPayment = component.get("v.TotalNoofPayment");
        if(varTotalNoofPayment == 1){
            component.set("v.NoofPayment1", true);component.set("v.NoofPayment2", false);component.set("v.NoofPayment3", false);component.set("v.NoofPayment4", false);
            component.set("v.NoofPayment5", false);component.set("v.NoofPayment6", false);component.set("v.NoofPayment7", false);component.set("v.NoofPayment8", false);
            component.set("v.NoofPayment9", false);component.set("v.NoofPayment10", false);component.set("v.NoofPayment11", false);component.set("v.NoofPayment12", false);
        }else if(varTotalNoofPayment == 2){
            component.set("v.NoofPayment1", false);component.set("v.NoofPayment2", true);component.set("v.NoofPayment3", false);component.set("v.NoofPayment4", false);
            component.set("v.NoofPayment5", false);component.set("v.NoofPayment6", false);component.set("v.NoofPayment7", false);component.set("v.NoofPayment8", false);
            component.set("v.NoofPayment9", false);component.set("v.NoofPayment10", false);component.set("v.NoofPayment11", false);component.set("v.NoofPayment12", false);
        }
            else if(varTotalNoofPayment == 3){
                component.set("v.NoofPayment1", false);component.set("v.NoofPayment2", false);component.set("v.NoofPayment3", true);component.set("v.NoofPayment4", false);
                component.set("v.NoofPayment5", false);component.set("v.NoofPayment6", false);component.set("v.NoofPayment7", false);component.set("v.NoofPayment8", false);
                component.set("v.NoofPayment9", false);component.set("v.NoofPayment10", false);component.set("v.NoofPayment11", false);component.set("v.NoofPayment12", false);
            }
                else if(varTotalNoofPayment == 4){
                    component.set("v.NoofPayment1", false);component.set("v.NoofPayment2", false);component.set("v.NoofPayment3", false);component.set("v.NoofPayment4", true);
                    component.set("v.NoofPayment5", false);component.set("v.NoofPayment6", false);component.set("v.NoofPayment7", false);component.set("v.NoofPayment8", false);
                    component.set("v.NoofPayment9", false);component.set("v.NoofPayment10", false);component.set("v.NoofPayment11", false);component.set("v.NoofPayment12", false);
                }
                    else if(varTotalNoofPayment == 5){
                        component.set("v.NoofPayment1", false);component.set("v.NoofPayment2", false);component.set("v.NoofPayment3", false);component.set("v.NoofPayment4", false);
                        component.set("v.NoofPayment5", true);component.set("v.NoofPayment6", false);component.set("v.NoofPayment7", false);component.set("v.NoofPayment8", false);
                        component.set("v.NoofPayment9", false);component.set("v.NoofPayment10", false);component.set("v.NoofPayment11", false);component.set("v.NoofPayment12", false);
                    }
                        else if(varTotalNoofPayment == 6){
                            component.set("v.NoofPayment1", false);component.set("v.NoofPayment2", false);component.set("v.NoofPayment3", false);component.set("v.NoofPayment4", false);
                            component.set("v.NoofPayment5", false);component.set("v.NoofPayment6", true);component.set("v.NoofPayment7", false);component.set("v.NoofPayment8", false);
                            component.set("v.NoofPayment9", false);component.set("v.NoofPayment10", false);component.set("v.NoofPayment11", false);component.set("v.NoofPayment12", false);
                        }
                            else if(varTotalNoofPayment == 7){
                                component.set("v.NoofPayment1", false);component.set("v.NoofPayment2", false);component.set("v.NoofPayment3", false);component.set("v.NoofPayment4", false);
                                component.set("v.NoofPayment5", false);component.set("v.NoofPayment6", false);component.set("v.NoofPayment7", true);component.set("v.NoofPayment8", false);
                                component.set("v.NoofPayment9", false);component.set("v.NoofPayment10", false);component.set("v.NoofPayment11", false);component.set("v.NoofPayment12", false);
                            }
                                else if(varTotalNoofPayment == 8){
                                    component.set("v.NoofPayment1", false);component.set("v.NoofPayment2", false);component.set("v.NoofPayment3", false);component.set("v.NoofPayment4", false);
                                    component.set("v.NoofPayment5", false);component.set("v.NoofPayment6", false);component.set("v.NoofPayment7", false);component.set("v.NoofPayment8", true);
                                    component.set("v.NoofPayment9", false);component.set("v.NoofPayment10", false);component.set("v.NoofPayment11", false);component.set("v.NoofPayment12", false);
                                }else if(varTotalNoofPayment == 9){
                                    component.set("v.NoofPayment1", false);component.set("v.NoofPayment2", false);component.set("v.NoofPayment3", false);component.set("v.NoofPayment4", false);
                                    component.set("v.NoofPayment5", false);component.set("v.NoofPayment6", false);component.set("v.NoofPayment7", false);component.set("v.NoofPayment8", false);
                                    component.set("v.NoofPayment9", true);component.set("v.NoofPayment10", false);component.set("v.NoofPayment11", false);component.set("v.NoofPayment12", false);
                                }
                                    else if(varTotalNoofPayment == 10){
                                        component.set("v.NoofPayment1", false);component.set("v.NoofPayment2", false);component.set("v.NoofPayment3", false);component.set("v.NoofPayment4", false);
                                        component.set("v.NoofPayment5", false);component.set("v.NoofPayment6", false);component.set("v.NoofPayment7", false);component.set("v.NoofPayment8", false);
                                        component.set("v.NoofPayment9", false);component.set("v.NoofPayment10", true);component.set("v.NoofPayment11", false);component.set("v.NoofPayment12", false);
                                    }else if(varTotalNoofPayment == 11){
                                        component.set("v.NoofPayment1", false);component.set("v.NoofPayment2", false);component.set("v.NoofPayment3", false);component.set("v.NoofPayment4", false);
                                        component.set("v.NoofPayment5", false);component.set("v.NoofPayment6", false);component.set("v.NoofPayment7", false);component.set("v.NoofPayment8", false);
                                        component.set("v.NoofPayment9", false);component.set("v.NoofPayment10", false);component.set("v.NoofPayment11", true);component.set("v.NoofPayment12", false);
                                    }else if(varTotalNoofPayment == 12){
                                        component.set("v.NoofPayment1", false);component.set("v.NoofPayment2", false);component.set("v.NoofPayment3", false);component.set("v.NoofPayment4", false);
                                        component.set("v.NoofPayment5", false);component.set("v.NoofPayment6", false);component.set("v.NoofPayment7", false);component.set("v.NoofPayment8", false);
                                        component.set("v.NoofPayment9", false);component.set("v.NoofPayment10", false);component.set("v.NoofPayment11", false);component.set("v.NoofPayment12", true);
                                    }else if(varTotalNoofPayment == 0){
                                        component.set("v.NoofPayment1", false);component.set("v.NoofPayment2", false);component.set("v.NoofPayment3", false);component.set("v.NoofPayment4", false);
                                        component.set("v.NoofPayment5", false);component.set("v.NoofPayment6", false);component.set("v.NoofPayment7", false);component.set("v.NoofPayment8", false);
                                        component.set("v.NoofPayment9", false);component.set("v.NoofPayment10", false);component.set("v.NoofPayment11", false);component.set("v.NoofPayment12", false); 
                                    }else if(varTotalNoofPayment > 12){
                                        component.set("v.NoofPayment1", false);component.set("v.NoofPayment2", false);component.set("v.NoofPayment3", false);component.set("v.NoofPayment4", false);
                                        component.set("v.NoofPayment5", false);component.set("v.NoofPayment6", false);component.set("v.NoofPayment7", false);component.set("v.NoofPayment8", false);
                                        component.set("v.NoofPayment9", false);component.set("v.NoofPayment10", false);component.set("v.NoofPayment11", false);component.set("v.NoofPayment12", false); 
                                        window._LtngUtility.toast('Error','error','Total no of payment should be less than or equal to 12.');
                                    }
        },
    
    renderPaymentSchedulejs : function(component){
        var PaymentSchedulecheck = component.get("v.PaymentSchedule");
        if(PaymentSchedulecheck == true){
            component.set("v.OnCustomCheckCheckBox", true);
            component.set("v.PaymentScheduleCheckBox", true);
            component.set("v.DefaultPaymentSchedule25", false);
            component.set("v.PaymentSchedule2", false);
            component.set("v.CustomPayment", false);
            component.set("v.CustomPaymentCheckBox", false);
            component.set("v.NoofPayment1", false);component.set("v.NoofPayment2", false);component.set("v.NoofPayment3", false);component.set("v.NoofPayment4", false);
            component.set("v.NoofPayment5", false);component.set("v.NoofPayment6", false);component.set("v.NoofPayment7", false);component.set("v.NoofPayment8", false);
            component.set("v.NoofPayment9", false);component.set("v.NoofPayment10", false);component.set("v.NoofPayment11", false);component.set("v.NoofPayment12", false); 
        }else{
            component.set("v.OnCustomCheckCheckBox", true);
            component.set("v.PaymentScheduleCheckBox", false);
            component.set("v.DefaultPaymentSchedule25", false);
            component.set("v.PaymentSchedule2", false);
            component.set("v.CustomPayment", false);
            component.set("v.CustomPaymentCheckBox", false);
            component.set("v.NoofPayment1", false);component.set("v.NoofPayment2", false);component.set("v.NoofPayment3", false);component.set("v.NoofPayment4", false);
            component.set("v.NoofPayment5", false);component.set("v.NoofPayment6", false);component.set("v.NoofPayment7", false);component.set("v.NoofPayment8", false);
            component.set("v.NoofPayment9", false);component.set("v.NoofPayment10", false);component.set("v.NoofPayment11", false);component.set("v.NoofPayment12", false); 
        }  
    },
    
    renderPaymentSchedule2js :function(component){
        var PaymentSchedule2check = component.get("v.PaymentSchedule2");
        if(PaymentSchedule2check == true){
            
            component.set("v.OnCustomCheckCheckBox", true);
            component.set("v.PaymentSchedule2CheckBox", true);
            component.set("v.PaymentScheduleCheckBox", false);
            component.set("v.DefaultPaymentSchedule25", false);
            component.set("v.PaymentSchedule", false);
            component.set("v.CustomPayment", false);
            component.set("v.CustomPaymentCheckBox", false);
            component.set("v.NoofPayment1", false);component.set("v.NoofPayment2", false);component.set("v.NoofPayment3", false);component.set("v.NoofPayment4", false);
            component.set("v.NoofPayment5", false);component.set("v.NoofPayment6", false);component.set("v.NoofPayment7", false);component.set("v.NoofPayment8", false);
            component.set("v.NoofPayment9", false);component.set("v.NoofPayment10", false);component.set("v.NoofPayment11", false);component.set("v.NoofPayment12", false); 
            
        }else{
            component.set("v.OnCustomCheckCheckBox", true);
            component.set("v.PaymentSchedule2CheckBox", false);
            component.set("v.PaymentScheduleCheckBox", false);
            component.set("v.DefaultPaymentSchedule25", false);
            component.set("v.PaymentSchedule", false);
            component.set("v.CustomPayment", false);
            component.set("v.CustomPaymentCheckBox", false);
            component.set("v.NoofPayment1", false);component.set("v.NoofPayment2", false);component.set("v.NoofPayment3", false);component.set("v.NoofPayment4", false);
            component.set("v.NoofPayment5", false);component.set("v.NoofPayment6", false);component.set("v.NoofPayment7", false);component.set("v.NoofPayment8", false);
            component.set("v.NoofPayment9", false);component.set("v.NoofPayment10", false);component.set("v.NoofPayment11", false);component.set("v.NoofPayment12", false); 
        }
    },
})