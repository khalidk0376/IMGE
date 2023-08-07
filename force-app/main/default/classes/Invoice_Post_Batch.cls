/**
* File:        Invoice_Post_Batch
* Project:     GAP
* Date:        Oct 12, 2020
* Created By:  Shiv Raghav Sharma
* Test Class : Invoice_Post_Batch_Test
* *************************************************************************
* Description: Batch Class for Post invoices and it will be shcedule for every 30 mints.
* ************************************************************************* 
*/

public class Invoice_Post_Batch implements Database.Batchable<sObject>,Database.stateful,Schedulable {
    private String query = null;
    public String FaliedrecordsidWithError='';
    list<blng__Invoice__c> listTobeUpdate = new list<blng__Invoice__c>();
    public Database.QueryLocator start(Database.BatchableContext BC) { 
        query = 'Select id, blng__InvoiceStatus__c from blng__Invoice__c where (BA_review_Required__c = false OR (BA_review_Required__c = true AND BA_approved__c = true)) AND Invoice_Heirarchy__c = \'Child Invoice\' AND blng__Order__c != NULL AND blng__InvoiceDate__c = TODAY AND blng__InvoiceStatus__c = \'Draft\' AND Invoice_Line_Error__c=0';        
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<blng__Invoice__c> listofInvoices) {
        if(listofInvoices.size() > 0) 
        {     
            System.debug('listofInvoices Size' + listofInvoices.size() + '------------listofInvoices===='+ listofInvoices);             
            try { 
                for(blng__Invoice__c inv : listofInvoices)
                {  
                    inv.blng__InvoiceStatus__c = 'Posted' ;
                    listTobeUpdate.add(inv);
                }
                
                Database.SaveResult[] UpdateList = Database.update(listTobeUpdate,false);   
                
                for(Integer i=0;i<UpdateList.size();i++)
                {                      
                    if (!UpdateList[i].isSuccess()) {                                                                                               
                        FaliedrecordsidWithError  += listTobeUpdate.get(i).id +', ';
                    }                    
                }                
                
            } catch(Exception ex) {                
                Utility.logsError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'Invoice Post Batch' , 'Post Invoice'); 
            }            
        }        
    }
    
    public void finish(Database.BatchableContext BC) {
        System.debug('Invoice posted batch run successfully');
        if(FaliedrecordsidWithError != null && !String.isBlank(FaliedrecordsidWithError))
        {
            try{
                Error_Log__c errorLog = new Error_Log__c();
                errorLog.Service_Source__c = 'Batch';
                errorLog.Source_Name__c = 'Batch Name : Invoice_Post_Batch finish Error Log ' ;
                errorLog.Description__c =  FaliedrecordsidWithError;
                insert errorLog ;
            }
            catch(Exception ex) {
                System.debug('Falied Error logs' + ex);
            }
            
        }
    }    
    //@description  Scheduled Method which will initiate this Batch Job
    public void execute(SchedulableContext ctx)
    {
        Database.executeBatch(new Invoice_Post_Batch());
    }
}