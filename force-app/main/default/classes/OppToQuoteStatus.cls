/**
 * File:        OppToQuoteStatus.cls
 * Project:     GAP
 * Date:        21th Feb 2018
 * Test Class : QuoteStatusChanges_test
 * Created By:  Abdul Qadir
 * Modified By:  Rajesh Kumar [21/12/2018]
 * *************************************************************************
 * @Description Contract Lost-When oppty is closed lost, nothing happens to the quote, all the quotes on the oppty should go to "Contract Lost" Status
   Accounting Approved-When SSC approves an Oppty the oppty goes to Closed Won- Awaiting Payment, at that time the Quote Status should go to Accounting Approved
   JIRA Ticket: GGCW-1572
 * *************************************************************************
 * History: Updated Code due to getting 101 error 
 * Ticket No.-BK-14522 Updating API Version
 */ 
public class OppToQuoteStatus implements Queueable, Database.AllowsCallouts {    
    //@Description Variable Declaration
    Set<Id> newOppLst{ get; set; }
    Map<Id, SBQQ__Quote__c> mapQuote = new Map<Id, SBQQ__Quote__c>();
    //@Description  Constructor
    public OppToQuoteStatus( Set <Id> newOppLst){
        this.newOppLst = newOppLst;
    }

    
    //@Description Void type method that is used to update SBQQ__Quote__c status.
    public void execute(QueueableContext context) {
        if(newOppLst.size() > 0 && newOppLst != null){
            mapQuote = new Map<Id, SBQQ__Quote__c>([select id,SBQQ__Status__c,SBQQ__Primary__c , SBQQ__Opportunity2__r.StageName, SBQQ__Opportunity2__r.IsCreatedByReviewProcess__c, SBQQ__Opportunity2__r.Manual_Contract__c ,SBQQ__Opportunity2__r.IsThroughDcousign__c, SBQQ__Opportunity2__r.Status__c from SBQQ__Quote__c where SBQQ__Opportunity2__c IN : newOppLst]);
        }

        if(mapQuote.size() > 0){            for(SBQQ__Quote__c tempQuote : mapQuote.values()){                if(tempQuote.SBQQ__Opportunity2__r.StageName =='Closed Lost' && tempQuote.SBQQ__Status__c !='Contract Lost'){                    tempQuote.SBQQ__Status__c ='Contract Lost';

                } else if(tempQuote.SBQQ__Opportunity2__r.StageName == 'Closed Won' && tempQuote.SBQQ__Opportunity2__r.Status__c == 'Awaiting Payment' && tempQuote.SBQQ__Primary__c && !tempQuote.SBQQ__Opportunity2__r.IsCreatedByReviewProcess__c && !tempQuote.SBQQ__Opportunity2__r.IsThroughDcousign__c && tempQuote.SBQQ__Status__c !='Accounting Approved' && !tempQuote.SBQQ__Opportunity2__r.Manual_Contract__c){
                    tempQuote.SBQQ__Status__c ='Accounting Approved';
                }
            }
        }

        if(mapQuote.size() > 0){   Utility.byPassClosedWon = true;      update mapQuote.values();
        }
    }
}