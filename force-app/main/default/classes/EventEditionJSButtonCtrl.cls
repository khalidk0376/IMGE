/*
Description     : fetching opportunity count by using EventEditionId and passing this count to Close All Opportunities Javascript button
Created Date    : 01/09/2020
Author          :
Button name		: 'Close All Opportunities' on Event Edition
*/
global class EventEditionJSButtonCtrl {
    webservice static Integer fetchOppCount(Id EventEditionId){
        Integer oppCount = [SELECT count() FROM Opportunity WHERE EventEdition__c =:EventEditionId AND StageName NOT IN ('Closed Won','Closed Booked','Closed Lost')]; 
        system.debug('Open Opportunity Count ::: ' + oppCount );
        return oppCount;
    }
}