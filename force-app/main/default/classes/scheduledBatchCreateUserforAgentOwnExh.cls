/*
 * Created By:  Mahesh Kumar (Girikon)
 * Created on :  08/10/2018
 * Modified by : 
 * Modified On : [Aishwarya BK-3759 27 Aug 2020]
 * Description: The purpose of this Schedulable class to Executing batch class of BatchCreateUserforAgentOwnExh.
 * Test Class:  scheduledBatchCrteUsrforAgtOwnExh_Test(100%)
*/
public class scheduledBatchCreateUserforAgentOwnExh implements Schedulable {
   public void execute(SchedulableContext schcon) {
      BatchCreateUserforAgentOwnExh batchCreateuser = new BatchCreateUserforAgentOwnExh(); 
      database.executebatch(batchCreateuser,1);
   }
}