/*
 * Created By:  Aishwarya Kumar (Girikon)
 * Created on :  09/10/2019
 * Modified by : 
 * Modified On :  [Aishwarya BK-3759 27 Aug 2020]
 * Description: The purpose of this Schedulable class to Executing batch class of BatchAssignManuals
 * Test Class:  scheduledBatchAssignManuals_Test(100%)
*/

public class ScheduledBatchAssignManuals implements Schedulable {
   public void execute(SchedulableContext schcon) {
      BatchAssignManuals batch1 = new BatchAssignManuals(); 
      database.executebatch(batch1,1);
   }
}