/**
 * File:           RemovedCoExhibitorClosedLostTrigger.tgr
 * Project:        GAP
 * Date:           14/12/2018
 * Created By:     Rajesh Kumar
 * Modified Date:  8th March 2019
 * Modified By:    Yash Gupta,[Aishwarya BK-16730 28 July 2021]
 * Test Class:     RemovedCoExhibitorClosedLost_Test
  ************************************************************************
  Description: After udpate this trigger call a  method from  BoothSelectionHlpr class.
  ************************************************************************
 * History: As per ticket no [GGCW-3005]
 *          Modified by Avinash Shukla on 15/04/19 : GGCW-3005
 */
trigger RemovedCoExhibitorClosedLostTrigger on Opportunity_ExpoCAD_Booth_Mapping__c (After update, After insert) {
  RemovedCoExhibitorClosedLost_class objRemovecoExh = new RemovedCoExhibitorClosedLost_class(Trigger.new, Trigger.oldMap, Trigger.isInsert, Trigger.isupdate, Trigger.isBefore, Trigger.isAfter);
    objRemovecoExh.removedCoExhibitor();
    objRemovecoExh.mapOfParentEbm();
    //objRemovecoExh.updatedisplayName();
    Set<String> setOppExpoIds = new Set<String>();
    for(Opportunity_ExpoCAD_Booth_Mapping__c oppExpo : Trigger.New){
        setOppExpoIds.add(oppExpo.Id);
    }
    if(!setOppExpoIds.isEmpty() && setOppExpoIds.size()>0 && trigger.isInsert){
        updateCoExhBadges.updateCoExhibitorBadges(setOppExpoIds);
    }
}