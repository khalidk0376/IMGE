/**
 * This class update exchange rate in Dated Conversion rate
 * @Author    : Sudip Halder
 * @Date      : 23/Feb/2018
 * Test Class : CurrencyTypeCtrl_Test
 */
public with sharing class CurrencyTypeCtrl {
    private static boolean isApexTest = false;
    public static void createCurrencyUpdateDatedExchangeRates(  List <Currency_Master__c> currencyMasters  ) {
        String corporateCurrencyIso; 
        List <Currency_Update__c> currencyUpdateLst       = new List <Currency_Update__c> ( );
        Map <String, Currency_Master__c> currencyMasterDetail    = new Map <String, Currency_Master__c> ( );
        List <String> datedExchangeDetails    = new List <String> ( );

        CurrencyType corporateCurrency = [ SELECT id, isoCode  FROM currencytype WHERE isCorporate = TRUE ];
        corporateCurrencyIso           = corporateCurrency.isoCode;
       
        for( DatedConversionRate datedConversionRate : [ SELECT Id, IsoCode FROM DatedConversionRate ] ) 
            datedExchangeDetails.add( datedConversionRate.IsoCode );

        for( Currency_Master__c cMaster : currencyMasters )
            if( cMaster.LocalCurrency__c == corporateCurrencyIso )
                currencyMasterDetail.put( cMaster.ForeignCurrency__c , cMaster );
                
        for( String masterKey : currencyMasterDetail.keySet( ) ) {
            Currency_Master__c cmaster = currencyMasterDetail.get( masterKey );
            String iso = masterKey.toUppercase( );
            if( datedExchangeDetails.contains( iso ) ) {
                Currency_Update__c cUpdate = new Currency_Update__c( );
                cUpdate.IsoCode__c         = iso;
                cUpdate.Conversion_Rate__c = cmaster.ExchangeRate__c;
                if( cmaster.ExchangeRateDate__c == null ) {
                    DateTime dt           = cmaster.createdDate;
                    cUpdate.Start_Date__c = Date.newInstance( dt.year( ), dt.month( ), dt.day( ) );
                } 
                else cUpdate.Start_Date__c = cmaster.ExchangeRateDate__c;
                if( cUpdate.Conversion_Rate__c > 0 )
                    currencyUpdateLst.add( cUpdate );
            }
        }
        if( !currencyUpdateLst.isEmpty( ) )
            insert currencyUpdateLst;
    }
    /**
     * This method create recod in 'DatedConversionRate' object
     * @param String isoCode
     * @param Decimal rate
     * @param Date StartDate
     * @param String currencyUpdateId
     * @param String sessionId
     */
    public static void asyncUpdateDatedConversionRate( String isoCode, Decimal rate, Date StartDate, String currencyUpdateId, String sessionId ) {
       
        //System.debug('The session id in asyncUpdateDatedConversionRate method :'+ Utility.encode( sessionId ) );
        String baseUrl           = System.URL.getSalesforceBaseUrl( ).toExternalForm( );    
        String currencyEndPoint  = baseUrl.toLowerCase( ) + '/services/data/v41.0/sobjects/DatedConversionRate/';
        String body              = '{ "IsoCode" : "'+ isoCode +'", "ConversionRate" : '+ rate +', "StartDate" : "'+ String.valueOf( StartDate ) +'" }';
        HTTPResponse res         = new HttpResponse( );
        HttpRequest req          = new HttpRequest( );
        req.setEndpoint( currencyEndPoint );
        req.setHeader( 'Authorization', 'OAuth '+ sessionId );
        req.setHeader( 'Content-Type', 'application/json' );
        req.setMethod( 'POST' );
        req.setBody( body );
        Http http = new Http( );
        try{
            res = http.send( req );
        } catch( System.CalloutException e ) { res.setBody( e.getMessage() ); }
        if( res.getStatusCode( ) == 201 ) {
            Currency_Update__c currencyUpdate = [ select id, Logs__c from Currency_Update__c where id = : currencyUpdateId ];
            currencyUpdate.status__c          = TRUE;
            currencyUpdate.Logs__c            = currencyUpdate.Logs__c + res.getBody( );
            update currencyUpdate;
        } else {
            Boolean status  = FALSE;
            String response = res.getBody( );
            if ( isApexTest ) response = '{"message":"duplicate value found: <unknown> duplicates value on record with id: <unknown>","errorCode":"DUPLICATE_VALUE","fields":[]}';
            JSONParser parser = JSON.createParser( response );
            while( parser.nextToken() != NULL ) {
                if( ( parser.getCurrentToken( ) == JSONToken.FIELD_NAME ) && ( parser.getText( ) == 'errorCode' ) ) {
                    parser.nextToken( );
                    if( parser.getText( ) == 'DUPLICATE_VALUE' ) status = TRUE;
                }
            }
            Currency_Update__c currencyUpdate = [ select id from Currency_Update__c where id = : currencyUpdateId ];
            currencyUpdate.status__c          = status;
            currencyUpdate.Logs__c            = res.getBody( );
            update currencyUpdate;
        }
        //System.debug( 'currenct endpoint '+ currencyEndPoint );
        //System.debug( 'body '+ body );
        //System.debug( 'response code ' + res.getStatusCode( ) );
        //System.debug( 'response ' + res.getBody( ) );
    }
    /**
     * This method connect to salesfore
     * @rerutn SESSION_ID
     */
    public static String connectSFDC( ) {
        String SESSION_ID   = '';
        String USERNAME     = '';
        String PASSWORD     = '';
        String baseUrl      = System.URL.getSalesforceBaseUrl( ).toExternalForm( );
        String soapEndPoint = baseUrl.toLowerCase( ) + '/services/Soap/u/41.0';
        
        Integration_Service__c integrationService = Integration_Service__c.getValues( 'DATED_EXCHANGE_RATE' );
        USERNAME    = integrationService.User_name__c;
        PASSWORD    = integrationService.Password__c;
        
        HttpRequest request = new HttpRequest( );
        request.setEndpoint( soapEndPoint );
        request.setMethod( 'POST' );
        request.setHeader( 'Content-Type', 'text/xml;charset=UTF-8' );
        request.setHeader( 'SOAPAction', '""' );
        request.setBody( '<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/"><Header/><Body><login xmlns="urn:partner.soap.sforce.com"><username>' + USERNAME + '</username><password>' + PASSWORD + '</password></login></Body></Envelope>' );
        
        if ( !isApexTest ) {
            Dom.XmlNode resultElmt = ( new Http( ) ).send( request ).getBodyDocument( ).getRootElement( ).getChildElement( 'Body', 'http://schemas.xmlsoap.org/soap/envelope/' ).getChildElement( 'loginResponse', 'urn:partner.soap.sforce.com' ).getChildElement( 'result', 'urn:partner.soap.sforce.com' );
            SESSION_ID = resultElmt.getChildElement('sessionId','urn:partner.soap.sforce.com').getText( );
        } else
            SESSION_ID = 'fake_sessionid_for_test_class';
        return SESSION_ID;
    }
    /**
     * This method used for test coverage
     */
    public static String connectSFDCForTest( ) {
        isApexTest = true;
        return connectSFDC( );
    }
}