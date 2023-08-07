/**
* Project:          GAP
* Date:             Sep 06, 2017
* Test Class Name:  CompleteAmend_Cls_Test
* Code Coverage:    89%
* Created By:       Kumar Gaurav
* *************************************************************************
* @description      Controller for CompleteAmend page to search Booth from Expocad.
* *************************************************************************
* History: GGCW-3489 - 03/06/2019 - Rajesh Kumar, [Aishwarya BK-3759 27 Aug 2020]
*/
global class CompleteAmend_Cls {

    /*
    * Member variables
    */
    public String sQuoteId {get;set;}
    public String sRequiredMsg {get;set;}
    
    /** 
     * Constructor, Getting required values for this class like, sQuoteId.
     * @param  StandardController
     */
    public CompleteAmend_Cls(ApexPages.StandardController controller) {
        sQuoteId = ApexPages.currentPage().getParameters().get('qId');
        System.debug('sQuoteId '+sQuoteId);
    }
    
    /**
    * Completed Amandement process.
    * @return [pageReference]
    */
    public pageReference completeAmend (){
        SBQQ__Quote__c oQuote = [SELECT Id, SBQQ__Status__c, SBQQ__Opportunity2__c, SBQQ__Type__c FROM SBQQ__Quote__c WHERE Id =:sQuoteId];
        System.debug('oQuote '+oQuote);
        if(oQuote != null && oQuote.SBQQ__Type__c != 'Amendment'){
            sRequiredMsg = System.Label.CompleteAmendButtonMsgForNonAmendOppty.escapeHtml4();
            return null;
        }
        if(oQuote != null && oQuote.SBQQ__Opportunity2__c != null){
            Opportunity oOpportunity = [SELECT Id, EventEdition__r.Signature_Required_in_Amend__c, SBQQ__Contracted__c,StageName, Master_Opportunity__c FROM Opportunity where Id =:oQuote.SBQQ__Opportunity2__c];
            System.debug('oOpportunity '+oOpportunity);
            System.debug('sQuoteId: '+sQuoteId);
            
            //As per the discussion with zuheab we have commented this if condtion.
           /* if(oOpportunity != null && oOpportunity.StageName == 'Closed Won' && oOpportunity.SBQQ__Contracted__c && oQuote.SBQQ__Status__c == 'Contract Approved'){
                return redirectToRecord(sQuoteId);
            }*/

            if(oOpportunity != null && !oOpportunity.EventEdition__r.Signature_Required_in_Amend__c){
                System.debug('Signature_Required_in_Amend__c '+oOpportunity.EventEdition__r.Signature_Required_in_Amend__c);
                if(!Test.isRunningTest()){
                    oQuote.SBQQ__Status__c = 'Contract Approved';
                    oOpportunity.SBQQ__Contracted__c = true;
                }
                oOpportunity.StageName = 'Closed Won';
                oOpportunity.isThroughCompleteAmendProcess__c = true ;
                oOpportunity.Status__c = 'Awaiting Payment';
                //oOpportunity.SBQQ__Contracted__c = true;
                Utility.byPassClosedWon = TRUE;
                update oQuote;
                update oOpportunity;
                return redirectToRecord(oOpportunity.Master_Opportunity__c);
            }
            else if(oOpportunity != null && oOpportunity.EventEdition__r.Signature_Required_in_Amend__c){
                System.debug('Signature_Required_in_Amend__c2 '+oOpportunity.EventEdition__r.Signature_Required_in_Amend__c);
                sRequiredMsg = System.Label.CompleteAmendProcessMsg.escapeHtml4();
                return null;
            }
        }
        return null;
    }
    
    /**
     * Redirent To Record from VF button
     * @return [pageReference]
     */
    public pageReference redirectQuote(){
        return redirectToRecord(sQuoteId);
    }
    
    /**
     * Redirent To Record from VF button
     * @param sRecordId
     * @return [pageReference]
     */
    public pageReference redirectToRecord(String sRecordId){
        PageReference pageRef = new PageReference('/'+sRecordId);
        return pageRef;
    }
}