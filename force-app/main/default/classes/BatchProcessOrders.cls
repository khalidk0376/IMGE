/**
* File:        BatchProcessOrders.cls
* Project:     GAP
* Date:        Aug 21, 2017
* Test Class:  BatchProcessOrders_Test
* Created By:  Bangash
* *************************************************************************
* Description: Batch to schedule Order activation.
* *************************************************************************
* History:
*/

public class BatchProcessOrders implements Database.Batchable<sObject>, Schedulable
{
    public static Integer BATCH_SIZE = 1;
    private String SOQL = null;
    public BatchProcessOrders()     
    {
        SOQL =  'select id , OrderNumber, Opportunity.Name, Ready_to_Activate__c, LastModifiedDate  from order ';
        SOQL += ' where status = \'Draft\' and opportunity.stageName in (  \'Closed Won\', \'Closed Booked\') ';
        SOQL += ' and SBQQ__PriceCalcStatus__c = \'Completed\' ';
        SOQL += ' and ( opportunity.status__c = \'Accounting Approved\' or opportunity.status__c = \'Awaiting Payment\') ';
        SOQL += ' and Create_Customer_Result__c = \'Success\' ';
        SOQL += ' and Tax_Error_Count__c = 0 ';
        SOQL += ' and Ready_to_Activate__c = false ';
        SOQL += ' and main_order__c  = true';
        SOQL += ' and opportunity.Do_not_activate_order_for_FOC_quote__c = False';
        system.debug('SOQL = ' + SOQL);
    }    

    public Database.QueryLocator start(Database.BatchableContext BC)         
    {
            return Database.getQueryLocator(SOQL);        
    }
         
    public void execute(Database.BatchableContext BC, List<Order> scope) {
        system.debug('Execute Started');
        if (scope != null) {
            // OrderHelper.ActivateOrders(List<Order>scope);
            system.debug('Scope is not empty');
            for (Order ord : (List<Order>)scope) {
                ord.Ready_to_Activate__c = true;
                ord.Activate_Time_Trigger__c = ord.LastModifiedDate - 0.03800;
            }
            
            try{
                update scope;
            }
            catch (exception ex) {
                Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'execute(@BatchProcessOrders.Class)');
            } 
        }
        
    }

    public void finish(Database.BatchableContext BC) {
        // Added by Palla Kishore for the ticket Bk-19604
        system.debug('Batch job completed successfully');
    }
    
    public void execute(SchedulableContext ctx)
    {
        Database.executeBatch(new BatchProcessOrders(), 1);
    }
    
}