/**
* Class Name: AddContractandOrderOnPayment_class cls
* Created By : Rajesh Kumar 
* Created Date : 14/02/2019
* Test Class: --Test Class :   PaymentHandlerTest
* **************************************************************************************************************************
* @description  This class is used to do the functionality of Process builder "Add Contract to Payments" AND "Order on Payments". 
* Modified By: Shiv Raghav Sharma 3/April/2019 - GRQ -> GRQ0289311 but @rajesh is updated class for test code coverage.
  @description  - we have updated code as per the code coverage. 02/05/2019 - Rajesh
* **************************************************************************************************************************
**/

public without sharing class AddContractandOrderOnPayment_class {

    List<blng__Payment__c> lstPayment{ get; set; }
    Set<Id> setInvoiceId = new Set<Id>();
    Map<Id, blng__Payment__c> oldPayment{ get; set; }  
    List<blng__Payment__c> lstPaymentUpdate{ get; set; }  
    public AddContractandOrderOnPayment_class (List<blng__Payment__c> lstPayment , Map<Id, blng__Payment__c> oldPayment){
        this.lstPayment = lstPayment;        
        this.oldPayment =  oldPayment;
        lstPaymentUpdate = new List<blng__Payment__c>();
    } 
    public void addOrderfromInvoice (){  
        
        if(lstPayment.Size() > 0) 
        {
            for(blng__Payment__c oPayment : lstPayment) {   
                if(oPayment.blng__Invoice__c != Null && (oPayment.Order_from_Invoice__c == null || oPayment.RelatedContract__c == null )){
                    setInvoiceId.add(oPayment.blng__Invoice__c);
                }
            } 
            
            if(setInvoiceId.size() > 0 )    {
                map<id,blng__Payment__c> mapOfInvoices = new map<id,blng__Payment__c>([select Id , blng__Invoice__r.blng__Order__c , blng__Invoice__c , RelatedContract__c , Order_from_Invoice__c ,blng__Invoice__r.blng__Order__r.ContractId from blng__Payment__c where blng__Invoice__c IN: setInvoiceId]);
                for(blng__Payment__c oPayment : mapOfInvoices.values()) {   
                    if(mapOfInvoices.containsKey(oPayment.Id))
                    {
                        if((mapOfInvoices.get(oPayment.Id).blng__Invoice__r.blng__Order__c != null && oPayment.Order_from_Invoice__c == null ) || (mapOfInvoices.get(oPayment.Id).blng__Invoice__r.blng__Order__r.ContractId != null && oPayment.RelatedContract__c == null))
                        {
                            oPayment.Order_from_Invoice__c = mapOfInvoices.get(oPayment.Id).blng__Invoice__r.blng__Order__c;
                            oPayment.RelatedContract__c = mapOfInvoices.get(oPayment.Id).blng__Invoice__r.blng__Order__r.ContractId;
                            lstPaymentUpdate.add(oPayment);
                        }
                    }                    
                }
                if (lstPaymentUpdate.size() > 0){  update lstPaymentUpdate; }
            }
        }
    } 
}