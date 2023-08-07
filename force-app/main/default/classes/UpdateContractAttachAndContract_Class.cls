/**
 * File:          UpdateContractAttachAndContract_Class
 * Project:       GAP
 * Date:          27/12/2018
 * Test Class :   UpdateContractAttachAndContract_Test
 * Created By:    Rajesh Kumar
 * Modified By:   Rajesh Kumar
 
 * *************************************************************************
 * @Description  Update Contract check box on Opp
 * *************************************************************************
 * History: Modified By Rajesh Kumar [GGCW-2760]
 */
public without sharing class UpdateContractAttachAndContract_Class {
    
    //@Description Variables Declaration
    Map<Id, Opportunity> mapOppty = new Map<Id, Opportunity>();
    public void updateContractAttachAndContractMethod ( Set <Id> setOppId) {
        mapOppty = new Map<Id, Opportunity>();
        String sOppIds = '';
        for(String str : setOppId){ sOppIds = sOppIds!=''?sOppIds+','+'\''+str+'\'':'\''+str+'\''; } 
        if(String.IsNotBlank(sOppIds)){
            String sOppQry = 'SELECT Id, Opportunity_Contact__r.Id , Contract_Attached__c , SBQQ__Contracted__c , CurrencyIsoCode , Event_Edition_Currency__c, Billing_Contact__r.Account.BillingCountryCode , StageName , SBQQ__PrimaryQuote__c , isThroughDcousign__c, SBQQ__PrimaryQuote__r.SBQQ__Status__c ,SBQQ__PrimaryQuote__r.SBQQ__Primary__c , SBQQ__PrimaryQuote__r.IsCreatedByReviewProcess__c , SBQQ__PrimaryQuote__r.Manual__c FROM Opportunity WHERE Id IN ('+sOppIds+')';
            system.debug('sOppQry: '+sOppQry);
            List<Opportunity> lstOpp = Database.Query(sOppQry);
            if(lstOpp.size() > 0 && lstOpp != null){
                for(Opportunity sOpp: lstOpp){mapOppty.put(sOpp.Id, sOpp);}
            }
        }
        
        if (mapOppty.size() > 0){
            for(Opportunity oOpp : mapOppty.values()){
                if( oOpp.SBQQ__PrimaryQuote__r.SBQQ__Status__c == 'Contract Approved' && oOpp.SBQQ__PrimaryQuote__r.SBQQ__Primary__c &&  !oOpp.SBQQ__PrimaryQuote__r.IsCreatedByReviewProcess__c && !oOpp.SBQQ__PrimaryQuote__r.Manual__c && !oOpp.SBQQ__Contracted__c && !oOpp.Contract_Attached__c && !oOpp.isThroughDcousign__c ) {
                    //Fixing After/Before Update values for Opportunity Trigger. BK-2992 Avinash Shukla
                    //oOpp.SBQQ__Contracted__c = true;
                    oOpp.Update_Contracted__c = true;
                    oOpp.Contract_Attached__c = true;
                }
            }
        }
        
        if (mapOppty.Size() > 0 ){
            update mapOppty.values();
        }
    }
}