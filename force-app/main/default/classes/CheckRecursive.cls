/**
 * Project:     GAP
 * Date:        16/1/2018
 * Created By:  Kumar
 * Test class : checkRecursive_Test
 * *************************************************************************
 * Description : Here, we have checked recursive flow using this class.
 * *************************************************************************
 * History : create field 'autoPopulate' by Sudip (GGCW-2103)
 */
public Class CheckRecursive{
    @TestVisible private static boolean run = true;
    @TestVisible private static boolean runForOLI = true;
    @TestVisible private static boolean invoiceTriggerOnce = true;
    @TestVisible private static boolean taxCalculation = true;
    @TestVisible private static boolean autoPopulate = true; // GGCW-2103
    public static boolean runOnce(){
        if(run){
            run=false;
            return true;
        }else{
            return run;
        }
    }
    
    public static boolean runOnceForOLI(){
        if(runForOLI){
            runForOLI=false;
            return true;
        }else{
            return runForOLI;
        }
    }
    
    public static boolean runOnceForInvoice(){
        if(invoiceTriggerOnce){
            invoiceTriggerOnce = false;
            return true;
        }else{
            return invoiceTriggerOnce;
        }
    }
    
    public static boolean runtaxCalculation(){
        if(runForOLI){
            runForOLI=false;
            return true;
        }else{
            return runForOLI;
        }
    }
    // GGCW-2103    
    public static boolean runAutoPopulate( ) {
        if( autoPopulate ) {
            autoPopulate = False;
            return True;
        } else {
            return autoPopulate;
        }
    }
}