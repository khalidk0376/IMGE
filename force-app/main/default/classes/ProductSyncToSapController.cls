/**
 * This ProductSyncToSapController class used in 'ProductSyncToSap' vf page. It has the functionality to display records of products
 * based on event series and event editions. User choose event seties and the event edition will appear and choose event edition products will 
 * appear. user can also filter the products based on the records are sync to SAP or not.
 * 
 * This class has another main functionality.i.e. user can sync the products with SAP by clicking 'Sync all to SAP' or 'Sync Selected to SAP' buttons.
 * Internally a batch process call the api and validate the products.
 * 
 * @Author      : Sudip Halder
 * @Date        : 21/Sep/2017  
 * Test Class   : ProductSyncToSapController_Test
 */
public with sharing class ProductSyncToSapController {
    
    //Variables
    public integer offsetSize                  { get; set; }
    public integer limitSize                   { get; set; }
    public integer totalRecord                 { get; set; }
    public integer pageNumber                  { get; set; }
    public String cloudHubEndPoint             { get; set; }
    public String cloudHubClientId             { get; set; }
    public String cloudHubClientSecret         { get; set; }
    public Boolean LockScreen                  { get; set; }
    public Id batchProcessId                   { get; set; }
    public Boolean batchProcessInit            { get; set; }
    public Boolean batchProcessEnabled         { get; set; }
    public String batchTaskComplete            { get; set; }
    public Integer batchItems                  { get; set; }
    public Integer totalItems                  { get; set; }
    public Integer mod                         { get; set; }
    public String selectedEventSeries          { get; set; }
    public String selectedEventEdition         { get; set; }
    public Boolean filterProducts              { get; set; }
    public String EventEditionDisplay          { get; set; }
    public String trancLogId                   { get; set; }
    public Boolean trancLogSts                 { get; set; }
    public ProductValidationTrncLog__c trncLog { get; set; }
    public String productName                  { get; set; }
    //Constructor
    public ProductSyncToSapController(  ) {
        offsetSize           = 0;
        totalRecord          = 0;
        limitSize            = 15;
        selectedEventSeries  = '0';
        selectedEventEdition = '0';
        pageNumber           = 1;
        batchItems           = 0;
        totalItems           = 0;
        mod                  = 1;
        //checkBatchRunning( );
        trancLogSts          = false;
        Integration_Settings__c integrationSettings = Integration_Settings__c.getValues('VALIDATE_PRODUCT');
        cloudHubEndPoint     = String.valueOf( integrationSettings.Endpoint__c );
        cloudHubClientId     = integrationSettings.Username__c;
        cloudHubClientSecret = integrationSettings.Password__c;
        batchProcessInit     = false;
        batchProcessEnabled  = true;
        batchTaskComplete    = 'none';
    }
    
    public ProductValidationTrncLog__c getProductSyncTrncLogDetailsById( ) {
        ProductValidationTrncLog__c trncLog = new ProductValidationTrncLog__c( );
        if( trancLogId != null ) 
            trncLog = [ SELECT Id, Name, Success_Transaction__c, Success_ProductCode__c, Failure_Transaction__c, Error_ProductCodeWithErr__c, IsServerDown__c FROM ProductValidationTrncLog__c WHERE id =:trancLogId ];    
        return trncLog;
    }
    public void checkBatchRunning( ) {
        Boolean check = false;
        List <AsyncApexJob> aajList = [ Select id ,Status, ApexClass.Name from AsyncApexJob WHERE ApexClass.Name = 'ConnectCloudHubBatch'  ORDER BY CreatedDate DESC ];
        for( AsyncApexJob aaj : aajList ) if( aaj.Status != 'Completed' && aaj.Status != 'Aborted' )   check = true;
        if( check ) LockScreen = true;
        else LockScreen = false;
    }
    public List <SelectOption> getEventSeries( ) {
        List <SelectOption> eventSeriesOptions = new List <SelectOption> ( );
        List <Event_Series__c> eventSeries = [ SELECT id, Name FROM Event_Series__c Where Status__c = 'Active' order by name asc ];
        eventSeriesOptions.add(new SelectOption( '0','-- Select Event Series --' ) );
        for( Event_Series__c series : eventSeries ) 
            eventSeriesOptions.add( new SelectOption( series.id, series.Name ) );
        return eventSeriesOptions;
    }
    public void evntSeriesChnge( ) {
        selectedEventEdition = '0';
        productName          = '';
        offsetSize           = 0;
        totalProducts( );
        if( selectedEventSeries != '0') EventEditionDisplay = 'show';
        else EventEditionDisplay= 'hide';
    }
    public void evntEditionChnge( ) {
        productName    = '';
        filterProducts = false;
        firstPage( );
        totalProducts( );
    }
    public List<SelectOption> getEventEdition( ) {
        List<SelectOption> eventEditionOptions = new List<SelectOption>();
        List<Event_Edition__c> eventEdition;
        if(selectedEventSeries  != '0' ) {
            eventEdition = [ SELECT id, Name FROM Event_Edition__c where Part_of_Series__c = : selectedEventSeries ];    
        }
        eventEditionOptions.add( new SelectOption('0','-- Select Event Edition --') );
        for(Event_Edition__c edition : eventEdition ) 
            eventEditionOptions.add( new SelectOption( edition.id, edition.Name ) );
        return eventEditionOptions;
    }
    public List <Product2> getProducts( ) {
       List <Product2> products = new List <Product2> ( );
       if( Schema.SObjectType.Product2.isQueryable() && 
           Schema.SObjectType.Product2.fields.ID.isAccessible( ) &&
           Schema.SObjectType.Product2.fields.Name.isAccessible( ) &&
           Schema.SObjectType.Product2.fields.ProductCode.isAccessible( ) &&
           Schema.SObjectType.Product2.fields.Family.isAccessible( ) &&
           Schema.SObjectType.Product2.fields.Event_Edition__c.isAccessible( ) &&
           Schema.SObjectType.Product2.fields.validated_in_sap__c.isAccessible( ) &&
           Schema.SObjectType.Product2.fields.Event_Edition__c.isAccessible( ) ) {
              
              if( productName != NULL && productName != '' ) {
                  String pName = '%'+ productName +'%';
                  products = [ SELECT ID, Name, ProductCode, Family, Event_Edition__r.Name, validated_in_sap__c FROM Product2 WHERE (NOT (name LIKE 'Booth Package%') ) AND validated_in_sap__c = : filterProducts  AND  Event_Edition__c = : selectedEventEdition AND Name LIKE : pName ORDER BY Name ASC LIMIT : limitSize OFFSET : offsetSize ];   
              } else {
                  products = [ SELECT ID, Name, ProductCode, Family, Event_Edition__r.Name, validated_in_sap__c FROM Product2 WHERE (NOT (name LIKE 'Booth Package%') ) AND validated_in_sap__c = : filterProducts  AND  Event_Edition__c = : selectedEventEdition ORDER BY Name ASC LIMIT : limitSize OFFSET : offsetSize ];
              }
          }
        System.debug('products' + products);
       return products;
    }
    
    public void totalProducts( ) {
        Map <Id, Product2> productMap;
        List <Product2> prodList = new List <Product2> ( );
        if( productName != NULL && productName != '' ) {
            String pName = '%'+ productName +'%';
            productMap = new Map <Id, Product2> ( [ SELECT Id FROM Product2 WHERE ( NOT ( Name LIKE 'Booth Package%' ) ) AND Name LIKE : pName  AND validated_in_sap__c = : filterProducts  AND  Event_Edition__c = : selectedEventEdition ] ); 
        } else {
            productMap = new Map <Id, Product2> ( [ SELECT Id FROM Product2 WHERE ( NOT ( Name LIKE 'Booth Package%' ) ) AND validated_in_sap__c = : filterProducts  AND  Event_Edition__c = : selectedEventEdition ] );
        }
        System.debug('productMap.keySet( )' +productMap.keySet());
        System.debug('productMap.keySet( )' +productMap.keySet().size());
        for( Id i : productMap.keySet( ) ) { 
            Product2 prod = productMap.get( i ); 
            prodList.add( prod ); 
        }
        totalRecord = prodList.size( );
    }
    
    public void searchProducts( ) {
        String productNameStr = Apexpages.currentPage( ).getParameters( ).get('productNameString');
        if( productNameStr != '' ) {
            productName = productNameStr;   
            firstPage( );
        }
        else productName = '';
    }
    public void cancelSearchProducts( ) {
        productName = '';
    }
    public void reload( ) {
        batchProcessInit    = false;
        batchProcessEnabled = true;
        batchTaskComplete   = 'none';
        batchItems          = 0;
    }
    public void productFilter( ) {
        String status =  Apexpages.currentPage().getParameters().get('filterStatus');
        filterProducts = Boolean.valueOf( status );
        firstPage( );
        productName = '';
    }
    public void firstPage( ) {
        offsetSize = 0;
        pageNumber = 1;
    }
    public void previous( ) {
        offsetSize = offsetSize - limitSize;
        pageNumber -= 1;
    }
    public void next( ) {
        offsetSize = offsetSize + limitSize;
        pageNumber += 1;
    }
    public void lastPage( ) {
        offsetSize = totalRecord - math.mod( totalRecord, limitSize );
        if( math.mod( totalRecord, limitSize ) > 0 )  pageNumber = ( integer ) totalRecord / limitSize + 1;
        else pageNumber = ( integer ) totalRecord / limitSize;
    }
    public boolean getprev( ) {
        if( offsetSize == 0 ) return true;
        else return false;
    }
    public boolean getnxt( ) {
        if( ( offsetSize + limitSize ) > totalRecord ) return true;
        else return false;   
    }
    public void syncToSap( ) {        
        String slctEvnStr =  Apexpages.currentPage().getParameters().get('selectedIDs');
        String [] slctEvnnames = slctEvnStr.split(',');
        List<String> eventEditionNames = new List<String>();
        for( String value : slctEvnnames ) {
            eventEditionNames.add( value.trim() );
            Integer totRec = eventEditionNames.size();
            totalItems = totRec;    
            mod =  Math.mod(totRec, 4);
            
        }
        if( eventEditionNames.size( ) > 0 ) {
            ProductValidationTrncLog__c trncLog = new ProductValidationTrncLog__c( Success_ProductCode__c = '', Error_ProductCodeWithErr__c = '' );
            insert trncLog;
            trancLogId = trncLog.id;
            if( trancLogId != null ) {
               trancLogSts = true; 
            } 
            ConnectCloudHubBatch cloudHubBatch = new ConnectCloudHubBatch( eventEditionNames, CloudHubEndPoint, CloudHubClientId, CloudHubClientSecret, trncLog );   
            batchProcessId = Database.executeBatch( cloudHubBatch, 4 );
            batchProcessInit = true;
        }
    }   
    
    public void batchProcess() {
        
        ProductValidationTrncLog__c  trnLog =  getProductSyncTrncLogDetailsById();
        if( trnLog.IsServerDown__c ) {
                System.abortJob(batchProcessId);
                batchProcessEnabled = false;
                batchTaskComplete  = 'Aborted';
        } else {
            AsyncApexJob aaj;
            if( String.isNotEmpty( batchProcessId ) && batchProcessInit ) {
                aaj = [ SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE ID =: batchProcessId ];
                try {
                    Integer process = aaj.JobItemsProcessed;
                    Integer tot = aaj.TotalJobItems;
                    batchTaskComplete = String.valueOf( ( process * 100 ) / tot );    
                    if( process < tot) {
                        batchItems = process * 4;
                    }else if(process == tot) {
                        if(mod != 0) {
                            batchItems +=  mod;
                        } else
                            batchItems = process * 4;
                    }   
                } catch( MathException mathError ) {
                    batchTaskComplete = 'Initial';
                }
            }
            if( aaj.Status == 'Completed' ) {
                batchProcessEnabled = false;
            }    
        }
    }
    
    public HttpResponse connectCloudHub( String endpoint, String clientId, String clientSecret, List<String> productCode ) {
        
        HTTPResponse res = new HttpResponse();
        String url  = endpoint + '?client_id=' + String.escapeSingleQuotes( clientId ) + '&client_secret=' + String.escapeSingleQuotes( clientSecret );
        String body = '';
        String systemsStr = '{ "Systems": { "CallingApplication": "SFDC-GE", "MessageDate": "2017-04-13" } }';
        String productsStr = '';
        String productCodeStr = '';
        for( String code : productCode ) {
           productCodeStr = productCodeStr + '{ "ProductCode": "'+ code +'" },';
        }
        productCodeStr = productCodeStr.removeEnd(',');
        productsStr = ' "Products": [' + productCodeStr + ']';
        body = ' { "Header": '+ systemsStr + ',' + productsStr + '}'; 
       
        System.debug('The body is ==> '+ body);
        
        HttpRequest req = new HttpRequest(); 
        req.setMethod( 'POST' );
        req.setEndpoint( url );
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(20000);
        req.setBody(body);
        Http http = new Http();
        try {
            res = http.send(req);    
        } catch( System.CalloutException e ) {
            res.setBody( e.getMessage() );
        }
        return res;
    }
    
    public void checkSeriesAndEventId( ) {
        System.debug('the event series '+selectedEventSeries);
        system.debug('the event edition '+selectedEventEdition);
    }
    
    public void syncAllToSap( ) {
        List<Product2> productAll;
        List<String> eventEditionNames = new List<String>();
        
        if( selectedEventEdition != '0' ){    
            productAll = [ SELECT ID FROM Product2 WHERE (NOT (name LIKE 'Booth Package%') )  AND  Event_Edition__c =:selectedEventEdition ORDER BY CreatedDate DESC ];
        }
        for( Product2 p2 : productAll ) {
            eventEditionNames.add( p2.Id );
            Integer totRec = eventEditionNames.size( );
            totalItems     = eventEditionNames.size( );
            mod            =  Math.mod( totRec, 4 );
        }
        if( eventEditionNames.size( ) > 0 ) {
            
            ProductValidationTrncLog__c trncLog = new ProductValidationTrncLog__c( Success_ProductCode__c = '', Error_ProductCodeWithErr__c = '' );
            insert trncLog;
            trancLogId = trncLog.id;
            if( trancLogId != null ) {
               trancLogSts = true; 
            } 
           
            ConnectCloudHubBatch cloudHubBatch = new ConnectCloudHubBatch( eventEditionNames, CloudHubEndPoint, CloudHubClientId, CloudHubClientSecret, trncLog );   
            batchProcessId = Database.executeBatch( cloudHubBatch, 4 );
            batchProcessInit = true;
        }
    }
   
}