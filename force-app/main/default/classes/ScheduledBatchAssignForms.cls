/*
 * Created By:  Aishwarya Kumar (Girikon)
 * Created on :  09/10/2019
 * Modified by : 
 * Modified On : 
 * Description: The purpose of this Schedulable class to Executing batch class of BatchAssignForms
 * Test Class:  scheduledBatchAssignForms_Test(100%)
*/
public class ScheduledBatchAssignForms implements Schedulable {
   public void execute(SchedulableContext schcon) {
      BatchAssignForms batch1 = new BatchAssignForms(); 
      database.executebatch(batch1,1);
   }
}