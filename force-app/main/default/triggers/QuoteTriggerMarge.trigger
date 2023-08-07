/**
 * File:        QuoteTriggerMerge .tgr
 * Project:     GAP
 * Date:        16/1/2018 1:54 PM
 * Created By:  Rajesh Kumar
 * Test Class:  -----
 * Modified By:  Rajesh Kumar
 * *************************************************************************
 * Description: We have merged all trigger to Quote Object.
 * 
 * *************************************************************************
 * History: 
 */
trigger QuoteTriggerMarge on SBQQ__Quote__c ( before insert, before update, after update ) {
    system.debug('test data');
    if(!Utility.isRebookInProcess && !Utility.isAmendmentProcess && Trigger.isBefore && !Utility.quoteTriggerMargeisFirstTimeBefore){
        Utility.quoteTriggerMargeisFirstTimeBefore = true;
        RelatedlistQuote reltdLstQut = new RelatedlistQuote( Trigger.new, Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate, Trigger.isBefore, Trigger.isAfter );
        reltdLstQut.quoteRelatedList();
        QuoteCurrency qtCur = new QuoteCurrency( Trigger.new, Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate, Trigger.isBefore, Trigger.isAfter );
        qtCur.currencyConversion();  
    }

    if (!Utility.isRebookInProcess && !Utility.isAmendmentProcess && Trigger.isAfter && !Utility.quoteTriggerMargeisFirstTime){
        Utility.quoteTriggerMargeisFirstTime = true;
        ReleaseBooths rlsBooths = new ReleaseBooths( Trigger.new, Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate, Trigger.isBefore, Trigger.isAfter );
        rlsBooths.boothRelease(); 
        Set<Id> setQuoteOppIds = new Set<Id>();
        for(SBQQ__Quote__c quote: Trigger.newMap.values()){
            SBQQ__Quote__c oldQuote = Trigger.OldMap.get(quote.Id);
            if (oldQuote.SBQQ__Status__c != quote.SBQQ__Status__c && quote.SBQQ__Status__c == 'Contract Approved' && quote.SBQQ__Primary__c &&  !quote.IsCreatedByReviewProcess__c && !quote.Manual__c && !quote.isThroughDcousign__c ){
                setQuoteOppIds.add(quote.SBQQ__Opportunity2__c);
            }
        }
        if (setQuoteOppIds.size() > 0){
            UpdateContractAttachAndContract_Class objContractMethod = new UpdateContractAttachAndContract_Class();
            objContractMethod.updateContractAttachAndContractMethod(setQuoteOppIds);
        }
       
    }
}