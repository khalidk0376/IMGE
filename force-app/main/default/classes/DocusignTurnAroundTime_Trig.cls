/**
 * File:        DocusignTurnAroundTime_Trig.cls 
 * Project:     GAP
 * Created Date: 31-03-2020
 * Created By:  Rajesh Kumar
 * Modified By:  Rajesh Kumar
 * Test Class: DocusignTurnAroundTime_Test 
 * Coverage: 
 *
 * *************************************************************************
 * @description  we have tracking turn tround time from docusign status..
 * *************************************************************************
 * History:Ticket :BK-3636 - BK-9782 on Rajesh Kr - 06-04-2021-Rajesh Kr -16-04-2021
 *
*/

public with sharing class DocusignTurnAroundTime_Trig implements TriggerInterface_QuoteDocument.Runnable {
    public List<Quote_Template_TAT__c> lstQuoteDocs = new List <Quote_Template_TAT__c >();
    public Set<Id> setQDocIds = new Set<Id>();
    public Map <id, id> quoteOppIdsMap = new Map <id, id> ();
    public List < ContentDocumentLink > lstInsertContentDocumentLink  = new List <ContentDocumentLink> ();
    public void run(TriggerInterface_QuoteDocument.Trig trig){
        
        if (trig.isInsert) {
            for (SBQQ__QuoteDocument__c oQuoteDoc: trig.newList) {
                if (oQuoteDoc.SBQQ__SignatureStatus__c == 'Sent') {
                    Quote_Template_TAT__c qTat = new Quote_Template_TAT__c();
                    qTat.name = oQuoteDoc.name;
                    qTat.Opportunity__c = oQuoteDoc.SBQQ__Opportunity__c;
                    qTat.Document_Sent_Date__c=system.now();
                    qTAT.Document_Signed_Date__c = system.now();
                    qTat.Document_Status__c='Sent';
                    qTAT.Quote_Document__c = oQuoteDoc.Id;
                    lstQuoteDocs.add(qTat);
                }          
            }
        }
        else if (trig.isUpdate){

            for (SBQQ__QuoteDocument__c oQuoteDoc: trig.newList) {
                setQDocIds.add(oQuoteDoc.Id);
                if (trig.oldmap.get(oQuoteDoc.Id).SBQQ__SignatureStatus__c != oQuoteDoc.SBQQ__SignatureStatus__c && oQuoteDoc.SBQQ__SignatureStatus__c == 'Completed' && oQuoteDoc.SBQQ__Template__c == 'Contract' ) { 
                    quoteOppIdsMap.put(oQuoteDoc.Id, oQuoteDoc.SBQQ__Opportunity__c);}
            }
            
            
            List < Quote_Template_TAT__c > lstTAT = [SELECT Id, Name, Document_Sent_Date__c,Document_Declined_Date__c, Document_Delivered_Date__c,Document_Signed_Date__c,Opportunity__c , Quote_Document__c from Quote_Template_TAT__c WHERE Quote_Document__c IN:setQDocIds AND Document_Status__c = 'Sent' Order By Createddate Desc LIMIT 1];

            for (SBQQ__QuoteDocument__c oQuoteDoc : trig.newList) { 
                if (trig.oldmap.get(oQuoteDoc.id).SBQQ__SignatureStatus__c != oQuoteDoc.SBQQ__SignatureStatus__c) {
                    Quote_Template_TAT__c qTat = new Quote_Template_TAT__c();
                    qTat.name = oQuoteDoc.name;
                    qTat.Opportunity__c = oQuoteDoc.SBQQ__Opportunity__c;
                    qTat.Document_Status__c = oQuoteDoc.SBQQ__SignatureStatus__c;
                    qTAT.Document_Signed_Date__c = system.now();
                    qTAT.Quote_Document__c = oQuoteDoc.Id;
                    if (!lstTAT.isEmpty()) {
                        for (Quote_Template_TAT__c oQuoteTAT : lstTAT ) {
                            if (oQuoteTAT.Document_Sent_Date__c != null) {
                                qTAT.Document_Sent_Date__c = oQuoteTAT.Document_Signed_Date__c;
                            }
                        }
                    }
                    System.debug(qTAT.Document_Signed_Date__c + ' teetetet' + qTAT.Document_Sent_Date__c);
                    qTAT.TAT__c = decimal.valueof((qTAT.Document_Signed_Date__c.getTime() / 1000 / 60 / 60) - (qTAT.Document_Sent_Date__c.getTime() / 1000 / 60 / 60));
                    
                    /**
                    * Added code for updated reason declined comment in TAT.
                    */
                    
                    if (oQuoteDoc.SBQQ__SignatureStatus__c == 'Declined'){
                        qTAT.Reason_Declined__c = oQuoteDoc.Reason_Declined__c;
                    }
                    lstQuoteDocs.add(qTat);
                }
            }
        }
        if (!lstQuoteDocs.isEmpty()) {
            insert lstQuoteDocs;
        }
    }
}