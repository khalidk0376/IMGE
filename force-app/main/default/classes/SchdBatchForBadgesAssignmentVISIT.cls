/*
 * Created By:  Aishwarya Kumar (Girikon)
 * Created/Last Modified On : [Aishwarya IMCC-4743 16 Nov 2022]
 * Description: The purpose of this Schedulable class to Execute batch BatchForBadgesAssignmentVISIT
 * Test Class:  SchdBatchForBadgesAssignmentVISIT_Test(100%)
*/
public class SchdBatchForBadgesAssignmentVISIT implements Schedulable {
   public void execute(SchedulableContext schcon) {
      BatchForBadgesAssignmentVISIT batch1 = new BatchForBadgesAssignmentVISIT(); 
      Database.executebatch(batch1,1);
   }
}