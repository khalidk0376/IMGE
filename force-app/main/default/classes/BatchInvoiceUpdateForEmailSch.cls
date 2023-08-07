/**
* File:        BatchInvoiceUpdateForEmailSch 
* Project:     GAP
* Date:        13-09-2019
* Created By:  Rajesh Kr 
* Test Class : BatchInvoiceUpdateForEmail_Test
*************************************************************************
* Description: Batch Class for updating invoice for Email processing.
* ************************************************************************* 
*/

public class BatchInvoiceUpdateForEmailSch implements Schedulable {
    public Void execute(SchedulableContext context){
        BatchInvoiceUpdateForEmail obj = new BatchInvoiceUpdateForEmail ();
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(obj,200);
    }

}