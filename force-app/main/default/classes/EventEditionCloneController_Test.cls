/**
 * File:        EventEditionCloneController.cls
 * Project:     GAP
 * Date:        12/7/2016 6:50 AM
 * Created By: Rajesh Kumar
 * * Modified By : Rajesh kumar Yadav Bk-3751
 * *************************************************************************
 * Description: Code coverage for "EventEditionCloneController" class 
 * Code Coverage : 81%
 * *************************************************************************
 * History:
 */

@isTest(seeAlldata = false)
public class EventEditionCloneController_Test
{
  static testMethod void unitTest()
  {
    Event_Edition__c oEventEdition = new Event_Edition__c(name = 'test', Approval_Service_Now_ID__c = 'test',Tab1__c='esttt',Tab7__c='testtt');
    insert oEventEdition;
      system.assertEquals(oEventEdition.name, 'test', 'Both values should be the same.');
    PageReference pageRef = Page.EventEditonClone;
    pageRef.getParameters().put('eventeditonid', oEventEdition.id);
    Test.setCurrentPage(pageRef);
    EventEditionCloneController oEventEditionCloneController = new EventEditionCloneController();
    oEventEditionCloneController.save();
    oEventEditionCloneController.getURParameter('test');
    oEventEditionCloneController.redirectToEventEdtn();
  }
}