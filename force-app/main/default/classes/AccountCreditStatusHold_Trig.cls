/**
* File:         AccountCreditStatusHold_Trig.cls
* Project:      GAP
* Created Date: 01/04/2020
* Created By:   Adarsh Sharma
* Test Class:   AccountCreditStatusHold_Test
* Coverage:     87%
*
* ***************************************************************************************************************
* @description : This handler is the conversion of AccountCreditStatusHold Trigger in Trigger Management App.
This Handler updates pagelayout when account credit status is hold.
* ***************************************************************************************************************
*/

public class AccountCreditStatusHold_Trig implements TriggerInterface_Account.Runnable {
    
    Map<String, Id> typeMap = New Map<String, Id>();
    set<Id> sAccountId = new set<Id>();
    List<contact> lstconRecordType = new List<Contact>();
    Set<Id> accToMakeInactive = new Set<Id>();
    List<contact> conToMakeInactive = new List<Contact>();
    
    public void run(TriggerInterface_Account.Trig trig) {
        
        if (trig.isAfter && trig.isUpdate) {
            
            for(RecordType rt: [Select DeveloperName, Id From RecordType Where sObjectType = 'contact']) {
                typeMap.put(rt.DeveloperName, rt.Id);
            }
            
            for (Account oAcc : trig.newList) {
                // Condition is added by Palla Kishore for the ticket BK-22224
                if(trig.oldMap.get(oAcc.Id).Accounting_Credit_Hold__c != oAcc.Accounting_Credit_Hold__c){
                    sAccountId.add(oAcc.id);
                }
                //  Modified by Palla Kishore for the ticket BK-22224
                if(trig.oldMap.get(oAcc.Id).Inactive__c != oAcc.Inactive__c && oAcc.Inactive__c == true) {
                    accToMakeInactive.add(oAcc.Id);    
                }
            }
            
            if (sAccountId != null && sAccountId.size() > 0) {
                List<contact> lstcontact = [SELECT Id , Name , Email , RecordTypeId , Account.Accounting_Credit_Hold__c, Inactive__c FROM CONTACT Where AccountId = : sAccountId];
                if (lstcontact.size() > 0) {
                    for (contact ocon : lstcontact) {
                        if (ocon.Account.Accounting_Credit_Hold__c == 'Hold') {
                            System.debug('trigger called 1');
                            ocon.RecordTypeid = typeMap.get('Contact_Account_is_hold'); 
                            lstconRecordType.add(ocon);
                        }
                        else{
                            ocon.RecordTypeid = typeMap.get('Contact_Account_is_unhold');
                             System.debug('trigger called 2');
                            lstconRecordType.add(ocon);
                        }
                    }
                }
                if ( lstconRecordType.size() > 0 && lstconRecordType != null ){Update lstconRecordType;
                                                                              }
            }
            /* BK-3090 [Adarsh] To make Direct contacts to the account inactive if account to that contact is inactive   */
            if(!accToMakeInactive.isEmpty()) {
                List<contact> lstcontact = [SELECT Id , Name ,AccountId, Inactive__c FROM CONTACT Where AccountId IN : accToMakeInactive];
                for(contact con : lstcontact) {
                    con.Inactive__c = true;
                    conToMakeInactive.add(con);
                }
                if(!conToMakeInactive.isEmpty()) {
                    update conToMakeInactive;
                }
            }
        }
        //merged code after Assigned BK-23
        if( trig.isBefore && trig.isUpdate ){
            
            set<Id> acctsWithNewAddresses = new set<Id>();
            for (Integer i = 0; i < trig.newList.size(); i++) {
                
                if ((trig.oldList[i].BillingCity!= trig.newList[i].BillingCity)
                    
                    
                    || (trig.oldList[i].BillingCountry!= trig.newList[i].BillingCountry)
                    
                    || (trig.oldList[i].BillingPostalCode!= trig.newList[i].BillingPostalCode)
                    
                    || (trig.oldList[i].BillingState!= trig.newList[i].BillingState)
                    
                    || (trig.oldList[i].BillingStreet!= trig.newList[i].BillingStreet))
                {
                    acctsWithNewAddresses.add(trig.oldList[i].id);
                    
                }
            }
            
            List<Contact> updatedContacts = new List<Contact>();
            for (Contact c : [SELECT id,Address_Verified__c FROM contact WHERE accountId in :acctsWithNewAddresses]) {
                
                c.Address_Verified__c = false;
                updatedContacts.add(c);
            }
            
            if(!updatedContacts.isEmpty()){update updatedContacts;
                                          }
            
            try{
                for (Account oaccount : trig.newList){
                    Account oldAccountVal = trig.oldMap.get(oaccount.Id);
                    if((oldAccountVal.IsFromBillingAddress__c != oaccount.IsFromBillingAddress__c) && oaccount.IsFromBillingAddress__c){
                        oaccount.ShippingStreet = oaccount.BillingStreet;
                        oaccount.Shipping_Address_2__c = oaccount.Billing_Address_Line_2__c;
                        oaccount.ShippingCity = oaccount.BillingCity;
                        oaccount.ShippingStateCode = oaccount.BillingStateCode;
                        oaccount.ShippingCountryCode = oaccount.BillingCountryCode;
                        oaccount.ShippingPostalCode = oaccount.BillingPostalCode;
                        oaccount.IsFromShippingAddress__c = false;
                    }
                    else if((oldAccountVal.IsFromShippingAddress__c != oaccount.IsFromShippingAddress__c) && oaccount.IsFromShippingAddress__c){
                        oaccount.BillingStreet = oaccount.ShippingStreet ;
                        oaccount.Billing_Address_Line_2__c = oaccount.Shipping_Address_2__c;
                        oaccount.BillingCity = oaccount.ShippingCity; 
                        oaccount.BillingStateCode = oaccount.ShippingStateCode;
                        oaccount.BillingCountryCode = oaccount.ShippingCountryCode;
                        oaccount.BillingPostalCode = oaccount.ShippingPostalCode;
                        oaccount.IsFromBillingAddress__c = false;
                    }
                }
            }
            catch(exception ex){Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'AccountTeam Trigger (@IsInsert && IsAfter)');
                               }
        }
    }
}