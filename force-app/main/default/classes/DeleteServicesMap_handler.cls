/**
 * File:        DeleteServicesMap_handler.cls
 * Project:     GAP
 * Created Date: 11-06-2020
 * Created By:  Rajesh Kumar
 * Modified By:  Rajesh Kumar
 * Test Class: trgDeleteServicesMap_Test
 * Coverage: 
 *
 * *************************************************************************
 * @description This class is using in trgDeleteServicesMap trigger.
 * *************************************************************************
 * 
 * 
 * History:Ticket :BK-3756
 *
*/

public with sharing class DeleteServicesMap_handler {
    List<BoothContractorMapping__c> newBoothContractorMappingLst          {get;set;}
    Map<Id,BoothContractorMapping__c>  oldmapBoothContractorMappingLst {get;set;}
    Boolean isdelete                                            {get;set;}
    Boolean isUpdate                                            {get;set;}
    Boolean isAfter                                             {get;set;}
    Boolean isBefore                                            {get;set;}

    public DeleteServicesMap_handler(List<BoothContractorMapping__c> newBoothContractorMappingLst, Map<Id, BoothContractorMapping__c > oldmapBoothContractorMappingLst, Boolean isDelete,Boolean isUpdate,Boolean isAfter , Boolean isBefore) {
        this.newBoothContractorMappingLst         = newBoothContractorMappingLst;
        this.oldmapBoothContractorMappingLst      = oldmapBoothContractorMappingLst;
        this.isdelete                       = isDelete;
        this.isupdate                       = isupdate;
        this.isAfter                        = isAfter;
        this.isBefore                       = isBefore;
    }

    public void trgDeleteServicesMap(){
        if(isdelete){
           delete [SELECT Id FROM CustomerContractorService__c where BoothContractorMapping__c IN :oldmapBoothContractorMappingLst.keySet()];
        }
       
        if(isUpdate){
           Boolean callHandler = false;
           for(BoothContractorMapping__c bcm: newBoothContractorMappingLst){
                if(bcm.ContractorRequestStatus__c != null && bcm.ContractorRequestStatus__c !='' && bcm.ContractorRequestStatus__c == 'Accepted' && (oldmapBoothContractorMappingLst.get(bcm.id).ContractorRequestStatus__c != bcm.ContractorRequestStatus__c)) {
                   callHandler = true;
                }
            }
            if(callHandler == true){
               AssignFormsManualsToStandContractor handler = new AssignFormsManualsToStandContractor();
               // Modified by Palla Kishore for the ticket BK-19606
               handler.assignFormsManualsToStandContractorMethod(newBoothContractorMappingLst);
            }
        }    
    }
}