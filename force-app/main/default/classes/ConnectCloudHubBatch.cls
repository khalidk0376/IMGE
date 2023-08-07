/**
 *  @Author      : Sudip Halder
 *  @Date        : 04/Oct/2017
 *  @Description : This batch class is called from 'ProductSyncToSapController' class. This class validate product in SAP by batch process.
 *  Test Class   : ProductSyncToSapController_Test
 */

public class ConnectCloudHubBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
   // global final String Query;
    public List<String> ProductsIds;
    public String CloudHubEndPoint           { get; set; }
    public String CloudHubClientId           { get; set; }
    public String CloudHubClientSecret       { get; set; }
                                             
    public ProductValidationTrncLog__c pvLog { get; set; }
    public Integer trncSuccessCount          { get; set; }
    public Integer trncFailureCount          { get; set; }
    public Integer SuccessCount              { get; set; }
    public Integer FailureCount              { get; set; }

    public ConnectCloudHubBatch( List <String> ProductsIds, String CloudHubEndPoint, String CloudHubClientId, String CloudHubClientSecret, ProductValidationTrncLog__c TrncLog ) {
        this.ProductsIds          = ProductsIds;
        this.CloudHubEndPoint     = CloudHubEndPoint;
        this.CloudHubClientId     = CloudHubClientId;
        this.CloudHubClientSecret = CloudHubClientSecret; 
        this.pvLog                = TrncLog;
        trncSuccessCount          = 0;
        trncFailureCount          = 0;
        SuccessCount              = 0;
        FailureCount              = 0;
    }
    
    public Database.QueryLocator start( Database.BatchableContext BC ) { return Database.getQueryLocator( [ SELECT Id, Name, ProductCode, Event_Edition__c, validated_in_sap__c, Product_Exist_in_sap__c FROM Product2 WHERE Id IN : ProductsIds ] ); }
    
    public void execute( Database.BatchableContext BC, List<Product2> scope ) {
        
        List <String> productCodeList = new List <String> ( );
        ProductSyncToSapController evntEdiObj = new ProductSyncToSapController( );
        Map <String,Product2> mapProduct = new Map <String,Product2> ( );
        List <product2> lstprdToUpdate = new List<product2> ( );
        List <SapSyncClasses.Results> rst = new List <SapSyncClasses.Results> ( );
        
        for( Integer i=0; i < scope.size(); i++ ) { productCodeList.add( scope[i].ProductCode ); mapProduct.put(scope[i].ProductCode, scope[i]); } 
        if( productCodeList.size() > 0 ) {
            HTTPResponse response =  evntEdiObj.connectCloudHub( CloudHubEndPoint, CloudHubClientId, CloudHubClientSecret, productCodeList );
            String sReturn = response.getBody( );
            system.debug('JSON Response: '+sReturn);
            response.getStatus( );
            if( sReturn == 'Read timed out' && response.getStatusCode() == 0 ) { pvLog.IsServerDown__c = true; pvLog.Error_ProductCodeWithErr__c = 'SAP Product Validation service  didnot respond. Please try again after sometime.'; update pvLog; } 
            else {
                SapSyncClasses SapSync = ( SapSyncClasses ) JSON.deserialize( sReturn, SapSyncClasses.class );
                for( SapSyncClasses.Messages msg : SapSync.Messages ) {
                    if( msg.MessageType == 'Success' ) { pvLog.Success_ProductCode__c += msg.MessageReference +','; }
                    if( msg.MessageType == 'ERROR' ) { pvLog.Error_ProductCodeWithErr__c += msg.MessageReference +' => '+  msg.MessageText +','; }
                }
                for( SapSyncClasses.Results rt : SapSync.Results ) {
                    boolean flag = false;
                    Product2 oTempPrd = mapProduct.get( rt.ProductCode );
                    if( rt.isValid ) { oTempPrd.validated_in_sap__c = true; flag = true; trncSuccessCount++; } else { trncFailureCount++; }
                    if( rt.ProductExists ) { oTempPrd.Product_Exist_in_sap__c = true; flag = true; }
                    if( flag ) { lstprdToUpdate.add( oTempPrd ); flag = false; }
                }
                if( lstprdToUpdate.size() > 0 ) { update lstprdToUpdate; }
            }
        }
    }
    
    public void finish( Database.BatchableContext BC ) {
        pvLog.Success_Transaction__c = trncSuccessCount;
        pvLog.Failure_Transaction__c = trncFailureCount;
        if(pvLog.IsServerDown__c == false) {
            update pvLog;      
        }
    }

}