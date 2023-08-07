/**
* Project:     GAP
* Date:        9/8/2017
* Created By:  Abdul Kadir
* Test Class:  BlngContactAccntBlngAddController_Test
* *************************************************************************
* Description: This class calls billing address API to validate the Account billing  Addess.
* *************************************************************************
 * History: 
 * 18/7/2018 : Modified by Kumar for Jira Ticket GGCW-2172,[Aishwarya BK-3759 27 Aug 2020]
*/

public with sharing class BlngContactAccntBlngAddController{
    public string contactId          { get; set; }
    public string stopReload         { get; set; }
    public string errorMsg           { get; set; }
    public Account account           { get; set; }
    public List <String> trancLog    { get; set; }    
    public List <Account> accountLst { get; set; }
    
    public BlngContactAccntBlngAddController(){
        stopReload='continue';
        trancLog = new List <String> ();
        accountLst = new  List <Account> ( );
    }
   
  /**
   * @description This method will redirect to contact .
   * @param 
   * @return pageReference
   */
    public PageReference back2Contact(){
        contactId = ApexPages.currentPage().getParameters().get('contactId');
        PageReference pg=new PageReference('/'+contactId);
        return pg;
        
    }
    
    /**
     * @description This method will calls billing address APIs.
     * @return pageReference
     */

    public PageReference validateAccountBillingAddress( ) {
        //Ticket GGCW-2068     
        String callVerb                 = 'POST';
        String integrationServiceName   = 'VALIDATE_CUSTOMER';        
        Contact priOrBillingContact;
        String integrationUrl           = '';
        String integrationUsername      = '';
        String integrationPassword      = '';
        //String directAccount            = '';
        Boolean addressVerified         = False;
        integrationUrl                  = IntegrationSettingsHelper.getEndpointFromSettings( integrationServiceName );
        integrationUsername             = IntegrationSettingsHelper.getUsernameFromSettings( integrationServiceName );
        integrationPassword             = IntegrationSettingsHelper.getPasswordFromSettings( integrationServiceName );
        String contactId                = ApexPages.currentPage( ).getParameters( ).get( 'contactId' );
        List <Account> updateAccList    = new List <Account> ( );
        List <Error_Log__c> errorLogs   = new List <Error_Log__c> ( );
        
        try {
            if( String.isNotBlank( contactId ) ) {                
                
                List <String> accIds = new List <String> ( );
                priOrBillingContact = [ SELECT Id, Email, Phone, Title, Name, FirstName, LastName, AccountId,MailingStreet, MailingCity, MailingPostalCode, MailingState, MailingCountry, Fax,Address_Verified__c FROM Contact WHERE Id = : contactId  LIMIT 1 ];
                for( AccountContactRelation accConRelation : [ SELECT AccountId, IsDirect From AccountContactRelation WHERE ContactId = : contactId ] ) {
                    accIds.add( accConRelation.AccountId );
                    //if( accConRelation.IsDirect )
                    //    directAccount = accConRelation.AccountId;
                }
                //Modified By Kumar : GGCW-2172 [Added one more Field to the Query i.e BillingStateCode]
                if( accIds.size( ) > 0 )
                    accountLst = [ SELECT Id, Name, BillingStreet, Billing_Address_Line_2__c, BillingCity, BillingState, BillingPostalCode, BillingCountry, Phone, Fax, blng__BillToContact__c, Tax_Id__c, BillingCountryCode, BillingStateCode FROM Account WHERE ID IN : accIds ];
            }
        } 
        catch (Exception eek) {            errorMsg = eek.getMessage( ) + '--' + eek.getStackTraceString( ); stopReload = 'stop'; return null; 
        }
        if( accountLst.size( ) > 0 && priOrBillingContact != null ) {
            for( Account acc : accountLst ) {

                ValidateCustomerAddressRequest vCustomerRequest = new ValidateCustomerAddressRequest( acc, priOrBillingContact );
                String validateCustomerPayload                  = ValidateCustomerAddressRequest.serializeToString( vCustomerRequest );
                String response = '';
                try {
                    response = OutboundCallHelper.makeClientIdTypeHttpRequest(integrationUrl, callVerb, validateCustomerPayload, integrationUsername, integrationPassword);
                } 
                catch (InformaExceptions.InformaHttpException eek) {
                    insert new Error_Log__c( Service_Source__c = 'Integration', Source_Name__c = integrationServiceName, Description__c = eek.getMessage() + ' ' + eek.getStackTraceString() );
                    errorMsg = eek.getMessage()+'--'+eek.getStackTraceString();                    stopReload='stop';                    return null; 
                }
                System.debug( 'The JSON response is : '+ response );
                
                try{
                    ValidateCustomerResponse customerResponse = ValidateCustomerResponse.parse(response);
                    if( customerResponse.Header != null && ( String.isBlank( customerResponse.Header.Systems.MessageStatus ) || customerResponse.Header.Systems.MessageStatus == 'OK' || customerResponse.Header.Systems.MessageStatus == 'UPDATED' ) ) {                        acc.Address_Verified__c = TRUE;
                    } else {
                        String errorString = '';
                        for( ValidateCustomerResponse.Message message: customerResponse.Messages ) {                            errorString += ' [' + message.MessageType + ' ::' + message.MessageText +' :'+message.MessageID+ '] '; 
                        }
                        acc.Address_Verified__c = FALSE;
                        Error_Log__c error = new Error_Log__c( Service_Source__c = 'Integration', Source_Name__c = integrationServiceName, Description__c = errorString, Affected_Object__c = 'Account', Affected_Object_Details__c = acc.Id ); 
                        errorMsg = errorString; 
                        stopReload='stop'; 
                        errorLogs.add( error );
                        return null;   // comment here sudip
                    }
                } catch( Exception eek ) {
                    errorMsg   = eek.getMessage( ) + '--' + eek.getStackTraceString( );
                    stopReload = 'stop';
                    return null;
                } 
               updateAccList.add( acc );
            }
            
        }
        
        for( Account acc : accountLst )
            if( acc.Tax_Id__c != null ) 
                accountTaxValidate( acc.Id );
        
        if( errorLogs.size( ) > 0 )
            insert errorLogs;
        
        for( Account acc : updateAccList ) {
            if( ! acc.Address_Verified__c ) {
                priOrBillingContact.Address_Verified__c = FALSE;
                break;
            }else priOrBillingContact.Address_Verified__c = TRUE;
        }
        
        update updateAccList;        update priOrBillingContact; 

        return new PageReference( '/'+priOrBillingContact.Id );
    }
    
    @future(callout=true)
    public static void accountTaxValidate( String accountId ) {        new VATValidationController( ).createVATValidationCallout( accountId );
    }
    
    public String validateAccountBillingAddress( String accountId ) {
        
        String callVerb                = 'POST';
        String integrationServiceName  = 'VALIDATE_CUSTOMER';
        String errorRes                = '';
        Contact priOrBillingContact;
        String integrationUrl           = '';
        String integrationUsername      = '';
        String integrationPassword      = '';
        Boolean addressVerified         = false;
        Account accnt                   = null;
        List <Contact> accContact       = new List <Contact> ( );
        List <Contact> contact2Update   = new List <Contact> ( );
        integrationUrl                  = IntegrationSettingsHelper.getEndpointFromSettings( integrationServiceName );
        integrationUsername             = IntegrationSettingsHelper.getUsernameFromSettings( integrationServiceName );
        integrationPassword             = IntegrationSettingsHelper.getPasswordFromSettings( integrationServiceName );
        
        try {
            if( String.isNotBlank( accountId ) ) {
                //Modified By Kumar : GGCW-2172 [Added one more Field to the Query i.e BillingStateCode]
                accnt = [ SELECT Id, Name, ( SELECT Id, Email, Phone, Title, Name, FirstName, LastName, AccountId, MailingStreet, MailingCity, MailingPostalCode, MailingState, MailingCountry, Fax,Address_Verified__c FROM Contacts ), Address_Verified__c, BillingStreet,Billing_Address_Line_2__c,BillingCity, BillingState, BillingPostalCode, BillingCountry, Phone, Fax, blng__BillToContact__c,Tax_Id__c,BillingCountryCode, BillingStateCode FROM Account WHERE Id = :accountId LIMIT 1 ];
                if( accnt != null ) for( contact con : accnt.contacts ) accContact.add( con );
            }
        } catch( Exception eek ){ errorMsg = eek.getMessage( ) +'--'+ eek.getStackTraceString( ); stopReload = 'stop'; }
        
        for( contact con :accContact ) {
            ValidateCustomerAddressRequest vCustomerRequest = new ValidateCustomerAddressRequest( accnt, con );
            String validateCustomerPayload = ValidateCustomerAddressRequest.serializeToString( vCustomerRequest );
            String response = '';
            try {
                response = OutboundCallHelper.makeClientIdTypeHttpRequest( integrationUrl, callVerb, validateCustomerPayload, integrationUsername, integrationPassword );
            } catch( InformaExceptions.InformaHttpException eek ) { insert new Error_Log__c( Service_Source__c = 'Integration', Source_Name__c = integrationServiceName, Description__c = eek.getMessage() + ' ' + eek.getStackTraceString()); errorMsg = eek.getMessage()+'--'+eek.getStackTraceString();stopReload='stop'; }            
            try{
                ValidateCustomerResponse customerResponse = ValidateCustomerResponse.parse(response);
                if( customerResponse.Header != null && ( String.isBlank( customerResponse.Header.Systems.MessageStatus ) || customerResponse.Header.Systems.MessageStatus == 'OK' || customerResponse.Header.Systems.MessageStatus == 'UPDATED' ) ) {                    con.Address_Verified__c = true; accnt.Address_Verified__c = true; contact2Update.add( con );
                } else {
                    System.debug(LoggingLevel.ERROR, 'BlngContactAccntBlngAddController.validateCustomer() error response from the server ' + customerResponse.Messages);
                    errorRes = accnt.Id+'/'+accnt.Name+'/' + customerResponse.Header.Systems.MessageStatus;
                    String errorString = '';
                    for(ValidateCustomerResponse.Message message: customerResponse.Messages) {                        errorString += ' [' + message.MessageType + ' ' + message.MessageText + '] '; 
                    }                    
                    con.Address_Verified__c = false;                    insert new Error_Log__c(Service_Source__c = 'Integration', Source_Name__c = integrationServiceName, Description__c = errorString, Affected_Object__c = 'Account', Affected_Object_Details__c = account.Id); errorMsg = errorString; stopReload='stop';                        
                }
            } catch ( Exception eek ) {
                errorMsg = eek.getMessage()+'--'+eek.getStackTraceString();         
                stopReload='stop';
            }
        }
       
        if( accnt.Tax_Id__c != null ) {            VATValidationController obj = new VATValidationController( );            PageReference pg=  obj.createVATValidationCallout( accnt.Id );
        }
        if(!contact2Update.isEmpty()) update contact2Update;
        if( accnt != null ) update accnt;
      return errorRes;
    }
    
}