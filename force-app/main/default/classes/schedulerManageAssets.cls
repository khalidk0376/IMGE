public class schedulerManageAssets implements Schedulable{

    public static String sched = '0 0 * * * ?';  

    public static String scheduleAssets() {
        schedulerManageAssets SC = new schedulerManageAssets(); 
        return System.schedule('Schedular Managing Assets Job', sched, SC);
    }

    public void execute(SchedulableContext sc) {

        btchCls_createAssestsForEventEditions b1 = new btchCls_createAssestsForEventEditions();
        ID batchprocessid = Database.executeBatch(b1,50);           
    }
}