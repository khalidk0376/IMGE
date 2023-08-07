/*
 * Created By:  Aishwarya Kumar (Girikon)
 * Created/Last Modified On :  28 June 2021
 * Description: The purpose of this Schedulable class to Executing batch class of BatchAssignTotalBadgesVisitGES
 * Test Class:  SchdBatchAssignTotalBadgesVisit_Test(100%)
*/
public class ScheduledBatchAssignTotalBadgesVisitGES implements Schedulable {
   public void execute(SchedulableContext schcon) {
      BatchAssignTotalBadgesVisitGES batch1 = new BatchAssignTotalBadgesVisitGES(); 
      Database.executebatch(batch1,1);
   }
}