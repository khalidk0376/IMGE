/**
 * This ProductSyncToSapController class used in 'ProductSyncToSap' vf page. 
 * @Author      : Sudip Halder
 * @Date        : 25/Sep/2017 
 * Apex Classes : ProductSyncToSapController, ConnectCloudHubBatch   
 */
@IsTest
public class ProductSyncToSapController_Test {
    
    public TestMethod static void testProductSyncToSapController( ) { 
        Event_Series__c evntSeries = new Event_Series__c( name='test series' );
        insert evntSeries;
        Event_Series__c series = [ Select Id, Name From Event_Series__c Limit 1 ];
        System.assertEquals( evntSeries.name, series.name, 'Here value is not same');
        
        Event_Edition__c evntEdition = new Event_Edition__c( name='Test Edition' );
        evntEdition.Part_of_Series__c = evntSeries.id;
        evntEdition.Event_Currency__c = 'USD';
        evntEdition.Event_Code__c     = 'TestEdition';
        insert evntEdition;
        Event_Edition__c edition = [ Select id, name From Event_Edition__c Limit 1 ];
        System.assertEquals( evntEdition.name, edition.name, 'Here value is not same');
        
        Product2 product = new Product2( name='test product', ProductCode = 'P001', Family = 'test', validated_in_sap__c = false );
        product.Event_Edition__c = evntEdition.Id;
        Product2 product1 = new Product2( name='test product1', ProductCode = 'P002', Family = 'test', validated_in_sap__c = false );
        product1.Event_Edition__c = evntEdition.Id;
        
        insert product;
        insert product1;
        
        String ids = 'P001,P002';
        PageReference pg = Page.ProductSyncToSap;
        pg.getParameters( ).put( 'selectedIDs', ids ); 
        pg.getParameters( ).put( 'filterStatus', 'true' );
        
        test.setCurrentPageReference( pg );
        Integration_Settings__c temp = new Integration_Settings__c( Name='VALIDATE_PRODUCT', Endpoint__c='https://test.cloudhub.com/productvalidation', Username__c='testuser', Password__c='testPass' );
        insert temp;
        Test.startTest( );
        ProductSyncToSapController prodSyncSapObj = new ProductSyncToSapController( );
        prodSyncSapObj.checkBatchRunning( );
        prodSyncSapObj.CloudHubEndPoint = String.valueOf( temp.Endpoint__c );
        prodSyncSapObj.CloudHubClientId = temp.Username__c;
        prodSyncSapObj.CloudHubClientSecret = temp.Password__c;
        prodSyncSapObj.getEventSeries( );
        prodSyncSapObj.selectedEventSeries = series.id;
        prodSyncSapObj.evntSeriesChnge( );
        prodSyncSapObj.getEventEdition( );
        prodSyncSapObj.selectedEventEdition = edition.Id;
        prodSyncSapObj.getProducts( );
        prodSyncSapObj.firstPage( );
        prodSyncSapObj.previous( );
        prodSyncSapObj.next( );
        prodSyncSapObj.lastPage( );
        prodSyncSapObj.getprev( );
        prodSyncSapObj.getnxt( );
        prodSyncSapObj.reload( );
        prodSyncSapObj.checkSeriesAndEventId( );
        prodSyncSapObj.evntEditionChnge( );
        prodSyncSapObj.productName = 'test';
        prodSyncSapObj.getProducts( );
        prodSyncSapObj.totalProducts( );
        
        prodSyncSapObj.searchProducts( );
        prodSyncSapObj.cancelSearchProducts( );
        List<String> pcode = new List<String>( );
        pcode.add( 'P001' );
        pcode.add( 'P002' );
        
        Test.setMock( HttpCalloutMock.class, new ConnectCloudHubMock( ) );
        prodSyncSapObj.syncToSap( );
        prodSyncSapObj.syncAllToSap( );
        prodSyncSapObj.connectCloudHub( prodSyncSapObj.CloudHubEndPoint, prodSyncSapObj.CloudHubClientId, prodSyncSapObj.CloudHubClientSecret, pcode );
        prodSyncSapObj.batchProcess( );
        prodSyncSapObj.productFilter( );
        
        Test.stopTest( );                
    }
}