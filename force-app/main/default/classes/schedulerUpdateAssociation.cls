global class schedulerUpdateAssociation implements Schedulable{

    public static String sched = '0 0 * * * ?';  

    global static String updateAssociations() {
        schedulerUpdateAssociation SC = new schedulerUpdateAssociation(); 
        return System.schedule('Update Association Job', sched, SC);
    }

    global void execute(SchedulableContext sc) {

        btch_updateAssociation b1 = new btch_updateAssociation();
        ID batchprocessid = Database.executeBatch(b1,50);           
    }
}