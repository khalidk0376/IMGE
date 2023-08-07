/**
 * File:        updateClosedLost.cls
 * Project:     GAP
 * Date:        21/12/2018 2:24 PM
 * Created By: Rajesh Kumar
 * Test Class : updateClosedLost_Test
 * *************************************************************************
 * Description: UPDATE opportunity stage closed lost when opportunity amount should be zero.
 * *************************************************************************
 * History: Ticket " GGCW-2699
 **/

global class updateClosedLost{
  webservice static void updateClosedLostInOpp ( String sOppId){ 
    Map<ID, Opportunity> oppToUpdateAmt = new Map<ID, Opportunity>([SELECT Id, StageName ,Status__c FROM Opportunity WHERE Id = :sOppId]);
    if(oppToUpdateAmt.values().size()  > 0){
      for (Opportunity opp : oppToUpdateAmt.values()){
        opp.StageName = 'Closed Lost'; 
        opp.Reason_Lost__c = 'AR Cancel / Re-bill'; 
        
      }
      Utility.byPassClosedWon = true;
      update oppToUpdateAmt.values();
    }
  }
}