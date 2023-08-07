/**
 * File:        ActivateContract_Handler.cls
 * Project:     GAP
 * Created Date: 10-06-2020
 * Created By:  Rajesh Kumar
 * Modified By:  Rajesh Kumar
 * Test Class: InvoiceHandlerFromQuote_Test
 * Coverage: 
 *
 * *************************************************************************
 * @description This class is using in Contract Object Trigger.
 * *************************************************************************
 * 
 * 
 * History:Ticket :BK-3756
 *
*/

public with sharing class ActivateContract_Handler {
    
    public static void activecontract(List<Contract> newContractLst , Map<Id, Contract> oldmapContract , Boolean isInsert, Boolean isAfter ){
        Map<Contract,id> mapOpptyContract = new Map<Contract,id>();
        set<id> contractIdsSet = new set<id>();
        for(Contract objCon : newContractLst){
            if(objCon.SBQQ__Quote__c !=null && objCon.Primary_Quote__c){
                contractIdsSet.add(objCon.id);
            }
            if(objCon.SBQQ__Opportunity__c != NULL){
                mapOpptyContract.put(objCon, objCon.SBQQ__Opportunity__c);
            }
        }
        
        // Activating Contract at insertion time
        if(!contractIdsSet.isEmpty()){
            List<Contract> lstToUpdateContract = new List<Contract>();
            Contract oContract ;
            for(Id id : contractIdsSet ){
                oContract = new Contract();
                oContract.id = id;
                oContract.Status = 'Activated';
                lstToUpdateContract.add(oContract);
            }
            if(!lstToUpdateContract.isEmpty()){
                if (!Schema.sObjectType.Contract.fields.Status.isUpdateable()){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Insufficient Access'));
                }
                update lstToUpdateContract;
            }
        }
        
        // Update Current Contract to Opportunity's Main Contract and Contract Number
        if(!mapOpptyContract.isEmpty()){
            List<Opportunity> lstToUpdateOppty =  new List<Opportunity>();
            Opportunity oOpportunity ;
            for(Contract oContract : mapOpptyContract.keySet()){
                oOpportunity = new Opportunity();
                oOpportunity.Id = mapOpptyContract.get(oContract);
                oOpportunity.Main_Contract__c = oContract.Id;
                oOpportunity.Contract_Number__c = oContract.ContractNumber;
                lstToUpdateOppty.add(oOpportunity);
            }
            if(!lstToUpdateOppty.isEmpty()){
                if (!Schema.sObjectType.Opportunity.fields.Main_Contract__c.isUpdateable() && !Schema.sObjectType.Opportunity.fields.Contract_Number__c.isUpdateable()){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Insufficient Access'));
                }
                update lstToUpdateOppty;
            }
        }
    }
}