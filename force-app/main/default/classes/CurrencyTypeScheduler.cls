/**
 * This class is insert/update record to 'Dated Conversion rate'
 * @Author    : Sudip Halder
 * @Date      : 26-Apr-2018
 * Test Class : CurrencyTypeCtrl_Test
 */

global class CurrencyTypeScheduler implements Schedulable, Database.AllowsCallouts, Database.batchable<sObject>, Database.Stateful {
    /**
     * Variables
     */ 
    public String sessionId { get; set; }
    /**
     * Constructor
     */
    public CurrencyTypeScheduler( ) { 
           system.debug('Constructor Being Called');//Added by Palla Kishore for the ticket BK-19604
    }
    /**
     * Scheduler execute method
     */
    global void execute( SchedulableContext SC ) {
        //System.debug('The scheduler execute ');
        CurrencyTypeScheduler currTypeBatch = new CurrencyTypeScheduler( );
        Database.executeBatch( currTypeBatch, 1);
    }
    /**
     * Batch class start method
     */
    global Database.QueryLocator start( Database.BatchableContext BC ) { 
        System.debug('The batch start ');
        sessionId = CurrencyTypeCtrl.connectSFDC( );
        System.debug('The session is : ' + Utility.encode( sessionId ) );
        return Database.getQueryLocator( [ SELECT Id, IsoCode__c, Conversion_Rate__c, Start_Date__c FROM Currency_Update__c WHERE status__c = FALSE ORDER BY createddate ] );  
    }
    /**
     * Batch class execute method
     */
    global void execute( Database.BatchableContext BC, List <Currency_Update__c> scope ) {
        System.debug('The batch execute ');
        for( Currency_Update__c cUpdate : scope ) 
            CurrencyTypeCtrl.asyncUpdateDatedConversionRate( cUpdate.IsoCode__c, cUpdate.Conversion_Rate__c, cUpdate.Start_Date__c, cUpdate.id, sessionId );
    }
  /**
     * Batch class finish method
     */
    global void finish( Database.BatchableContext BC ) {
         // Added by Palla Kishore for the ticket Bk-19604
           system.debug('Batch job completed successfully');
    }
}