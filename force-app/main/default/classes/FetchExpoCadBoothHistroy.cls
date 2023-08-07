/*
    Created By		: Girikon( Faisal Khan )
    Created On		: 03/13/2023
    @description 	: This class is user in fetchExpoCadBoothHistroy LWC component to display the ExpocadBooth History in Opportunity Booth Tab.
    Test Class      : fetchExpoCadBoothHistroy_Test
    Modified By		: 
*/
public with sharing class FetchExpoCadBoothHistroy {
    
    @AuraEnabled(cacheable=true)
    public static List<ExpocadBooth__history> fetchhistory(String OppId){
        List<ExpocadBooth__history> expocadhistory=new List<ExpocadBooth__history>();
        expocadhistory = [Select Id,createdById,createdby.Name,CreatedDate,parent.Quote__r.SBQQ__Opportunity2__c,parent.Quote__r.SBQQ__Primary__c,field,OldValue,NewValue,parent.Booth_Number__c,parent.Name,parentId from Expocadbooth__history where parent.Quote__r.SBQQ__Opportunity2__c=:OppId and (Field='Created' OR Field='Status__c' OR Field = 'Booth_Number__c') and parent.Quote__r.SBQQ__Primary__c=true ORDER BY CreatedDate DESC];
        System.debug('expocad history'+expocadhistory);
        return expocadhistory;
    }

}