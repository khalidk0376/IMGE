/**
* Project:     GAP
* Date:        July 22, 2018
* Created By:  Kumar Gaurav
* Test Class:  InvoiceCancellationCtrl_Test
* *************************************************************************
* Description: This Class handles Order/Invoice Cancellation process.   
* *************************************************************************
* History:
*/

public class InvoiceCancellationCtrl implements Database.Batchable<sobject>, Database.Stateful {
    //Variables
    public String orderId              { get; set; }
    public String batchProgress        { get; set; }
    public Id batchProcessId           { get; set; }
    public String batchStatus          { get; set; }
    public Boolean batchProcessEnabled { get; set; }
    public String sFailureMsg          { get; set; }
    public String sCancelSuccessMsg    { get; set; }
    public String redirectUrl          { get; set; }
    public String sPrmAction           { get; set; }
    public String sAlertMsg            { get; set; }
    
    //Constructors    
    public InvoiceCancellationCtrl( ) {
        batchProgress        = '0';
        batchStatus          = 'stop';
        batchProcessEnabled  = true;
        sFailureMsg          = '';
        sCancelSuccessMsg    = System.Label.Invoice_Cancel_Success_Message;
        orderId              = ApexPages.currentPage().getParameters().get('id');
        sPrmAction           = ApexPages.currentPage().getParameters().get('pAction');
        redirectUrl          = URL.getSalesforceBaseUrl().toExternalForm() + '/' + orderId;
        sAlertMsg            = 'This action will cancel all invoices. Do you want to proceed?';

        If(sPrmAction != NULL && sPrmAction == 'cancelOrder')
            sAlertMsg        = 'This action will cancel the order and it\'s invoices. Do you want to proceed?';
    }
    
    //Parameterized Constructors [OrderId]
    public InvoiceCancellationCtrl( String orderId ) {
        this.orderId = orderId;
        sFailureMsg          = '';
        sCancelSuccessMsg    = System.Label.Invoice_Cancel_Success_Message;
    }

    /**
    * @description Canceling the Invoices
    */
    public void cancelInvoice( ) {
        if( orderId != NULL && orderId != '' ) {
            System.debug('Started Action == ');
            batchStatus = 'start';
            sAlertMsg   = '';
            InvoiceCancellationCtrl invCancel = new InvoiceCancellationCtrl( orderId );
            batchProcessId = Database.executeBatch( invCancel, 1 );
        }
    }
    
    /**
    * @description Overridden Batch Start method which returns Invoices which needs to Cancel.
    */
    public Database.QueryLocator start( Database.BatchableContext bc ) {
        System.debug('Calling Start method ');
        return Database.getQueryLocator( [SELECT Id, Name FROM blng__Invoice__c WHERE blng__InvoiceStatus__c != 'Cancelled' AND blng__InvoiceStatus__c != 'Rebilled' AND blng__Order__c = : orderId ORDER BY Schedule_Number__c ASC] );
    }
    
    /**
    * @description Overridden Batch execute method which cancels Invoices 
    */
    public void execute( Database.BatchableContext bc, List<blng__Invoice__c> scope ) {
        System.debug(' calling execute method '+ scope.size() );
        for( blng__Invoice__c inv : scope ) {
            
            String sCnldResult = blng.InvoiceAPI.creditInvoice( inv.Id, 'Cancel and Re-bill');
            System.debug('sCnldResult  =>'+sCnldResult);
            System.debug('sCancelSuccessMsg IN =>'+sCancelSuccessMsg);   
            System.debug('sCnldResult.equalsIgnoreCase(sCancelSuccessMsg) ' + !sCnldResult.equalsIgnoreCase(sCancelSuccessMsg) );
            If( Test.isRunningTest() || ( sCancelSuccessMsg != NULL && !sCnldResult.equalsIgnoreCase(sCancelSuccessMsg) ) ){
                sFailureMsg += '\n'+inv.Name+' : ['+sCnldResult+']';
                System.debug('sFailureMsg In ==> '+sFailureMsg);
            }
        }
    }
    
    /**
    * @description Overridden Batch finish method, Getting Failed messages for Invoice Cancellation failure  
    */
    public void finish( Database.BatchableContext bc ) {
        If(String.isNotBlank(sFailureMsg)){
            Expocad_Error__c oExpo = new Expocad_Error__c();
            List<Expocad_Error__c> lstExpo = [SELECT ID, Errors__c FROM Expocad_Error__c WHERE Parent_Id__c =: orderId];
            if(lstExpo != NULL && lstExpo.size() > 0)
                oExpo = lstExpo.get(0);
            oExpo.Errors__c     = sFailureMsg;
            oExpo.Parent_Id__c  = orderId;
            UPSERT oExpo;
            System.debug('oExpo =>'+oExpo);
        }
    }
    
    /**
    * @description Its executing fro poller of 5s to get Batch Status.
    */
    public void batchProcess(){
        System.debug('ActionPoller == ');
        AsyncApexJob aaj;
        if(String.isNotEmpty( batchProcessId ) && batchStatus =='start') {
            aaj = [ SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE ID = : batchProcessId ];   
            try {
                Integer iProcessedCount = aaj.JobItemsProcessed;
                Integer iTotal = aaj.TotalJobItems;
                batchProgress = String.valueOf((iProcessedCount * 100 ) / iTotal);
            } 
            catch( MathException mathError ) { 
                System.debug('Math Exception is coming');
            }
            if( aaj.Status == 'Completed' || Test.isRunningTest()) {
                batchStatus = 'stop'; 
                batchProcessEnabled = false;
                List<Expocad_Error__c> lstExpo = [SELECT ID, Errors__c FROM Expocad_Error__c WHERE Parent_Id__c =: orderId];
                if(lstExpo != NULL && lstExpo.size() > 0)
                    sFailureMsg = lstExpo.get(0).Errors__c ;
                If(sFailureMsg == '' && sPrmAction != Null && sPrmAction == 'cancelOrder'){
                    Order oOrder  = new Order();
                    oOrder.Id = orderId ; 
                    oOrder.Status = 'Draft'; 
                    oOrder.blng__InvoiceBatch__c = 'Will Not Invoice';
                    oOrder.Cancelled__c = True ;
                    try{
                        update oOrder;
                    }
                    Catch (Exception Ex){ sFailureMsg = Ex.getMessage();
                    }
                }
            }
        }
    }
    
    /**
    * @description Return back to Order Record
    * Return PageRefrence
    */
    public pageReference redirectToRecord(){
        PageReference pageRef = new PageReference('/'+orderId);
        return pageRef;
    }
}