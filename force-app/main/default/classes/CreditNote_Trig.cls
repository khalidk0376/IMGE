/**
 * File:        CreditNote_Trig.cls
 * Project:     GAP
 * Created Date: 10-06-2020
 * Created By:  Rajesh Kumar
 * Modified By:  Rajesh Kumar
 * Test Class: CreditNoteTrigger_Test
 * Coverage: 
 *
 * *************************************************************************
 * @description This class is using in "Trigger Management app" Trigger.
 * *************************************************************************
 * History:Ticket :BK-3756
 *
*/
public without sharing class CreditNote_Trig implements TriggerInterface_Credit_Note.Runnable {
    Set<Id> setInvoiceIds = new Set<Id>();
    Set<String> setLegalEntityCode = new Set<String>();
    public void run(TriggerInterface_Credit_Note.Trig trig){
        for(blng__CreditNote__c oCreditNote : trig.newList){
            if(oCreditNote.blng__RelatedInvoice__c != NULL){
                setInvoiceIds.add(oCreditNote.blng__RelatedInvoice__c);
            } 
        }
        if(!setInvoiceIds.isEmpty()){
            Map<String, blng__LegalEntity__c> mapLegalEntityByCode;
            List<blng__Invoice__c> lstInvoicesToUpdate;
            List<blng__Invoice__c> lstInvoices = [SELECT Id, Credit_Number_SFDC__c, LegalEntityCode__c FROM blng__Invoice__c WHERE ID IN: setInvoiceIds];
            if(lstInvoices != NULL && lstInvoices.size() > 0){
                lstInvoicesToUpdate = new List<blng__Invoice__c>();
                for(blng__Invoice__c oInvoice : lstInvoices){
                    if(!String.isBlank(oInvoice.LegalEntityCode__c)){
                        setLegalEntityCode.add(oInvoice.LegalEntityCode__c);
                    }
                }
                
                if(!setLegalEntityCode.isEmpty()){
                    List<blng__LegalEntity__c> lstLegalEntity = [SELECT Id, Credit_Number_Prefix__c, Latest_Credit_Number__c, Legal_Entity_Code__c FROM blng__LegalEntity__c WHERE Legal_Entity_Code__c IN: setLegalEntityCode AND Credit_Number_Prefix__c != NULL AND Latest_Credit_Number__c != NULL FOR UPDATE];
                    if(lstLegalEntity != NULL && lstLegalEntity.size() > 0){
                        mapLegalEntityByCode = new Map<String, blng__LegalEntity__c>();
                        for(blng__LegalEntity__c oLegalEntity : lstLegalEntity){
                            mapLegalEntityByCode.put(oLegalEntity.Legal_Entity_Code__c, oLegalEntity);
                        }
                    }
                }
                for (blng__Invoice__c oInvoice: lstInvoices) {  
                    if(mapLegalEntityByCode != NULL && mapLegalEntityByCode.Size() > 0 && !String.isBlank(oInvoice.LegalEntityCode__c) && mapLegalEntityByCode.containsKey(oInvoice.LegalEntityCode__c)){
                        blng__LegalEntity__c oTempLegalEntity = mapLegalEntityByCode.get(oInvoice.LegalEntityCode__c);
                        String sPrefix = oTempLegalEntity.Credit_Number_Prefix__c;
                        String sLatestNo = oTempLegalEntity.Latest_Credit_Number__c;
                        Integer iLatestNo = Integer.ValueOf(sLatestNo);
                        String sPadedNo = String.ValueOf(iLatestNo+1).leftPad(sLatestNo.length(),'0');
                        String sInvoiceNoSFDC = sPrefix+'-'+sPadedNo;
                        oInvoice.Credit_Number_SFDC__c = sInvoiceNoSFDC ;
                        oTempLegalEntity.Latest_Credit_Number__c = sPadedNo;
                        mapLegalEntityByCode.put(oInvoice.LegalEntityCode__c, oTempLegalEntity);
                        lstInvoicesToUpdate.add(oInvoice);
                    }
                }
                if(mapLegalEntityByCode != NULL && mapLegalEntityByCode.Size() > 0){
                    update mapLegalEntityByCode.Values();
                }
                if(lstInvoicesToUpdate != NULL && lstInvoicesToUpdate.Size() > 0){
                    update lstInvoicesToUpdate ;
                }
            }           
        }
    }
}