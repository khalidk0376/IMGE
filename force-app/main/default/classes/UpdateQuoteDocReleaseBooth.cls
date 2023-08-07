/**
* File:        UpdateQuoteDocReleaseBooth .cls
* Project:     GAP
* Date:        31/01/2019
* Created By:  Rajesh Kumar
* Test class   UpdateQuoteDocReleaseBooth_test.cls
* *************************************************************************
* Description: This class used to updating Quote And Quote Document Status and Release Booth from Expocad.
* *************************************************************************
* History:
*/
   
public class UpdateQuoteDocReleaseBooth implements Queueable , Database.AllowsCallouts {

    set<id> setoppIds = new set<id>();
    public UpdateQuoteDocReleaseBooth (set<ID> OppIds){
        this.setoppIds = OppIds;
    }

    public void execute(QueueableContext context) {
        //Added by Abdul Kadir to update 'Quote Status on the "non Primary Quotes" is not changing to "Quote Rejected" on Closing won the Oppty'.
        List<ExpocadBooth__c> lstExpocadBoothUpdate = new List<ExpocadBooth__c>();
        Map<Id,SBQQ__Quote__c > mapQuoteList =  new Map<Id ,SBQQ__Quote__c >([select id, SBQQ__Opportunity2__c,SBQQ__Primary__c,SBQQ__Opportunity2__r.StageName, (select id , Name ,Status__c from ExpocadBooths__r)  from SBQQ__Quote__c where SBQQ__Opportunity2__c IN : setoppIds and SBQQ__Primary__c = false ]);
        if (mapQuoteList.size() > 0){   for(SBQQ__Quote__c quoteObj : mapQuoteList.values() ){     quoteObj.SBQQ__Status__c='Quote Rejected';        for (ExpocadBooth__c oEb : quoteObj.ExpocadBooths__r){  oEb.Status__c = 'Released';  lstExpocadBoothUpdate.add(oEb);  }  } }
        if(mapQuoteList.size() > 0){    Update mapQuoteList.values();   Map<Id,SBQQ__QuoteDocument__c > mapQuoteDocument =  new Map<Id ,SBQQ__QuoteDocument__c>([select id, SBQQ__SignatureStatus__c, SBQQ__Template__c , SBQQ__Quote__r.SBQQ__Status__c  from SBQQ__QuoteDocument__c where SBQQ__Quote__c IN : mapQuoteList.keyset()]);    if (mapQuoteDocument != null && mapQuoteDocument.values().size() > 0){  for (SBQQ__QuoteDocument__c oQuoteDocument : mapQuoteDocument.values()){  if (oQuoteDocument.SBQQ__Quote__r.SBQQ__Status__c == 'Quote Rejected'){  oQuoteDocument.SBQQ__SignatureStatus__c = 'Voided';   }  }
            }

            if (mapQuoteDocument.size() > 0){ update mapQuoteDocument.values(); }
        }

        if (lstExpocadBoothUpdate.size() > 0 ){ update lstExpocadBoothUpdate; }
    
    }
}