/**
* Project:     GE-CRM IOM
* Date:        21/04/2023
* Created By:  Ansh
* Test Class:  EventEditionBillingSchedule_Test(100%)
* *************************************************************************
* @description Class for Lightning component "iomEventEditionBillingSchedule" on Opportunity .
* *************************************************************************
* Ticket No: GECI-1461
*/
public with sharing class EventEditionBillingScheduleController {

    /**
    * @description to fetch edition payment schedule details for opportunity
    * @param opportunityId Opportunity Id
    * @return opportunity edition payment schedule detail
    */
    @AuraEnabled(cacheable=true)
    public static Opportunity getPaymentSchedule(Id opportunityId) {
        Opportunity opp = [SELECT Custom_Payment__c,EventEdition__r.Payment_Schedule__c,EventEdition__r.X50_Cutoff_Date__c,EventEdition__r.Cutoff_Date_1__c,EventEdition__r.Cutoff_Date_2__c,EventEdition__r.Cutoff_Date_3__c FROM Opportunity WHERE Id = :opportunityId WITH SECURITY_ENFORCED];
        return opp;
    }
}