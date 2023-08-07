/**
 * File:        DocuSignStatusAutomateProcess_Trig.cls 
 * Project:     GAP
 * Created Date: 31-03-2020
 * Created By:  Rajesh Kumar
 * Modified By:  Rajesh Kumar
 * Test Class: 
 * Coverage: 
 *
 * *************************************************************************
 * @description.
 * *************************************************************************
 * History:Ticket :BK-3636
 *
*/
public with sharing class DocuSignStatusAutomateProcess_Trig implements TriggerInterface_DocuSign_Status.Runnable {
    
    Set<id> oppIds = new Set<id>();
    List<SBQQ__QuoteDocument__c> lstQtDoc = new List<SBQQ__QuoteDocument__c>();
    set<id> quoteIds = new set<id>();
    Set<id> docusignStatusIds = new Set<id>();
    public void run(TriggerInterface_DocuSign_Status.Trig trig){
    
        for(dsfs__DocuSign_Status__c objDS : trig.newList){
            
            if(String.IsNotBlank(objDS.dsfs__Envelope_Status__c)){
                quoteIds.add(objDS.Quote__c);
                docusignStatusIds.add(objDS.Id);
            }
        }
        
        if(trig.isAfter && trig.isInsert){
            if (!quoteIds.isEmpty()){
                SBQQ__QuoteDocument__c quoteDoc =  new SBQQ__QuoteDocument__c();
                List<SBQQ__Quote__c> lstquote = [select id,name,SBQQ__Opportunity2__c,template__c,Total__c from SBQQ__Quote__c where Id IN :quoteIds];
                if(!lstquote.isEmpty()){
                    for(SBQQ__Quote__c obj : lstquote){
                        quoteDoc.Name = 'Doc-'+ obj.name + '-'+system.now();
                        quoteDoc.SBQQ__Quote__c = obj.id;
                        quoteDoc.SBQQ__Opportunity__c = obj.SBQQ__Opportunity2__c;
                        quoteDoc.sbqq__template__c = obj.template__c;
                        quoteDoc.SBQQ__SignatureStatus__c = 'Sent';
                        quoteDoc.Conga__c  = true;
                        quoteDoc.Manual__c = false;
                        quoteDoc.SBQQ__ListAmount__c = obj.Total__c;
                        quoteDoc.SBQQ__NetAmount__c = obj.Total__c;
                        for (String stemp : docusignStatusIds){
                            quoteDoc.DocuSign_Status__c = stemp;
                        }
                        lstQtDoc.add(quoteDoc);
                    }
                }
            }
            if(lstQtDoc.size()>0){
                insert lstQtDoc;
            }
        }
        
        if(trig.isAfter && trig.isUpdate){
            
            Map<Id , SBQQ__QuoteDocument__c> mapQuoteDocList = new  Map<Id , SBQQ__QuoteDocument__c> ([select id,name,SBQQ__Quote__c,SBQQ__Quote__r.SBQQ__Status__c,SBQQ__Opportunity__c, SBQQ__Template__c , Reason_Declined__c , SBQQ__SignatureStatus__c from SBQQ__QuoteDocument__c  where DocuSign_Status__c  IN : docusignStatusIds ]);
            
            if (!mapQuoteDocList.isEmpty()){
                for(SBQQ__QuoteDocument__c objQt : mapQuoteDocList.values()){ 
                    for(dsfs__DocuSign_Status__c obj : trig.newList){
                        
                        if(obj.dsfs__Envelope_Status__c !='Voided'){
                            
                            if(obj.dsfs__Envelope_Status__c == 'Delivered'){
                                
                                objQt.SBQQ__SignatureStatus__c = 'Delivered';
                            }
                            if(obj.dsfs__Envelope_Status__c =='Completed'){
                                
                                objQt.SBQQ__SignatureStatus__c = 'Completed';
                                
                                oppIds.add(objQt.SBQQ__Opportunity__c);
                            
                            }

                            /**
                             * @Discription Added code for contract declined
                             */
                            
                            if(obj.dsfs__Envelope_Status__c =='Declined'){
                                objQt.SBQQ__SignatureStatus__c = 'Declined';
                                objQt.Reason_Declined__c =  obj.dsfs__Declined_Reason__c;
                            }
                            
                        }
                        else {
                            objQt.SBQQ__SignatureStatus__c = 'Voided';
                        }
                    }
                }

            }
            
            if(mapQuoteDocList.values().size() > 0 ){
                update mapQuoteDocList.values();
            }

            /**
             * Call Queueable class 
             */
            if(oppIds.size() > 0 ){
                System.enqueueJob(new UpdateQuoteDocReleaseBooth(oppIds)); 
            }
        }
    
    }
}