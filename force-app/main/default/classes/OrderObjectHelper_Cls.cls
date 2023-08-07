/**
 * File:        ActivateOrder.cls
 * Project:     GAP
 * Date:        13/7/2017
 * Created By:  Kumar Gaurav
 * *************************************************************************
 * Description: Order Object trigger Handler class.
 * *************************************************************************
 * History: 
 */
public class OrderObjectHelper_Cls {
    @future(callout=true)
    public static void createCustomerCallout(String strOrderId){
        CreateCustomerController oCreateCustomerController =  new CreateCustomerController();
        try{
            oCreateCustomerController.createCustomerCallout(strOrderId);
        }
        catch (exception ex) {  Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'createCustomerCallout(@OrderObjectHelper_Cls.Class)'); }
    }
}