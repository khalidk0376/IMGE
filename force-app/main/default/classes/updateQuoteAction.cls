/**
    * File:        updateQuoteAction .cls
    * Project:     GAP
    * Date:        12/14/2017
    * Created By:  Abdul Kadir
    * Test class   updateQuoteAction_test.cls
    * *************************************************************************
    * Description: This class provide utility methods to update non primary quotes on the opportunity after Closed Won.
    * *************************************************************************
    * History:
    * Modified By Rajesh Kumar on 21 - jan - 2019 :  GGCW-2017 
    */
public class updateQuoteAction {
    @future 
    public static void updateQuoteAttachAggrement(String OppId){ 
        Map<Id,SBQQ__Quote__c > mapQuoteList =  new Map<Id ,SBQQ__Quote__c >([select id, SBQQ__Opportunity2__c,SBQQ__Primary__c,SBQQ__Opportunity2__r.StageName  from SBQQ__Quote__c where SBQQ__Opportunity2__c  = : OppId and SBQQ__Primary__c = false ]);
        if (mapQuoteList != null && mapQuoteList.size() > 0){
            for(SBQQ__Quote__c quoteObj : mapQuoteList.values() ){
                quoteObj.SBQQ__Status__c='Quote Rejected';
            }
        }
        if(mapQuoteList.values().size() > 0){
            Update mapQuoteList.values();
        }
    }
}