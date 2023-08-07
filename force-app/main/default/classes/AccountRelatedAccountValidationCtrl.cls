/**
 * File:        AccountRelatedAccountValidationCtrl
 * Date:        10/)7/2018
 * Created By : Sudip Halder
 * Test Class : AccountRelatedAccountValidation_Test
 * *************************************************************************
 * Description: This class calls billing address API to validate the Account billing  Addess.
 * *************************************************************************
 * History: 
 * 18/7/2018  : Modified by Kumar for Jira Ticket GGCW-2172
 * 11/10/2018 : Adding System debug.
 * 03/14/2019 : Modifield by Mukesh Gupta[] set contactId property in constructor.
 */
public class AccountRelatedAccountValidationCtrl implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    
    /* Variables */
    public string contactId            { get; set; }
    public string errorMsg             { get; set; }
    public string error                { get; set; }
    public List <Account> accountLst   { get; set; }
    public String callVerb             { get; set; }
    public String serviceName          { get; set; }
    public String integrationUrl       { get; set; }
    public String integrationUsername  { get; set; }
    public String integrationPassword  { get; set; }
    public Id batchProcessId           { get; set; }
    public String batchProgress        { get; set; }
    public Contact billingContact      { get; set; }
    public List <String> accIds        { get; set; }
    public Boolean batchProcessEnabled { get; set; }
    public String batchStatus          { get; set; }
    public String redirectUrl          { get; set; }
    
    /* Constructor */
    public AccountRelatedAccountValidationCtrl( ) {
        batchProgress = '0';
        batchStatus   = 'init';
        error         = '';
        contactId     = '';
        redirectUrl   = '';
        contactId     = ApexPages.currentPage( ).getParameters( ).get( 'contactId' );
    }
    public AccountRelatedAccountValidationCtrl( List <String> accIds, Contact billingContact, String contactId ) {
        errorMsg                 = '';
        this.accIds              = accIds;
        this.billingContact      = billingContact;
        this.callVerb            = 'POST';
        this.serviceName         = 'VALIDATE_CUSTOMER';
        this.integrationUrl      = IntegrationSettingsHelper.getEndpointFromSettings( serviceName );
        this.integrationUsername = IntegrationSettingsHelper.getUsernameFromSettings( serviceName );
        this.integrationPassword = IntegrationSettingsHelper.getPasswordFromSettings( serviceName );
        accountLst               = new List <Account> ( );
        this.contactId           = contactId;
        
    }
    public void validateAccountBillingAddress( ) {
        //contactId   = ApexPages.currentPage( ).getParameters( ).get( 'contactId' );
        redirectUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + contactId;
        
        if( String.isNotBlank( contactId ) ) { 
            List <Contact> contacts = [ SELECT Id, Email, Phone, Title, Name, FirstName, LastName, AccountId,MailingStreet, MailingCity, MailingPostalCode, MailingState, MailingCountry, Fax,Address_Verified__c FROM Contact WHERE Id = : contactId ];
            List <String> accIds = new List <String> ( );
            if( contacts.size( ) > 0 ) {
                for( AccountContactRelation accConRel : [ SELECT AccountId From AccountContactRelation WHERE ContactId = : contactId ] ) {
                    accIds.add( accConRel.AccountId );
                }
            }
            if( accIds.size( ) > 0 && contacts.size( ) > 0 ) {
                batchStatus         = 'start';
                batchProcessEnabled = TRUE;
                AccountRelatedAccountValidationCtrl accAddValidBtch = new AccountRelatedAccountValidationCtrl( accIds, contacts[ 0 ], contactId );
                batchProcessId = Database.executeBatch( accAddValidBtch, 1 );
            }
        }
    }
    public Database.QueryLocator start( Database.BatchableContext bc ) {
        //Modified By Kumar : GGCW-2172 [Added one more Field to the Query i.e BillingStateCode]
        return Database.getQueryLocator( [ SELECT Id, Name, BillingStreet, Billing_Address_Line_2__c, BillingCity, BillingState, BillingPostalCode, BillingCountry, Phone, Fax, blng__BillToContact__c, Tax_Id__c, BillingCountryCode, BillingStateCode FROM Account WHERE ID IN : accIds ] );
    }
    public void execute( Database.BatchableContext bc, List <Account> scope ) {
        for( Account acc : scope ) {
            ValidateCustomerAddressRequest vCustomerRequest = new ValidateCustomerAddressRequest( acc, billingContact );
            System.debug('vCustomerRequest === ' + vCustomerRequest);
            String validateCustomerPayload = ValidateCustomerAddressRequest.serializeToString( vCustomerRequest );
            System.debug('validateCustomerPayload === ' + validateCustomerPayload);
            String response = '';
            try {
                response = OutboundCallHelper.makeClientIdTypeHttpRequest( integrationUrl, callVerb, validateCustomerPayload, integrationUsername, integrationPassword );
                System.debug('response === ' + response);
            } 
            catch(System.CalloutException ex) {
             //BK-3754  
                Utility.logsError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'AccountRelatedAccountValidationCtrl' , 'Integration');
            }
            ValidateCustomerResponse customerResponse = ValidateCustomerResponse.parse( response );
            if( customerResponse.Header != null && ( String.isBlank( customerResponse.Header.Systems.MessageStatus ) || customerResponse.Header.Systems.MessageStatus == 'OK' || customerResponse.Header.Systems.MessageStatus == 'UPDATED' ) ) {
                acc.Address_Verified__c = TRUE;
            } else {
                for( ValidateCustomerResponse.Message message: customerResponse.Messages ) {
                    errorMsg += '[ <a href="/'+ acc.Id +'" target="_blank">' + acc.Name +'</a> : ' + message.MessageType + ' ::' + message.MessageText +' ] <br></br>';
                }
                acc.Address_Verified__c = FALSE;
            }
            accountLst.add( acc );
            if( acc.Tax_Id__c != null ) {
                new VATValidationController( ).createVATValidationCallout( acc.Id );
            }
        }
    }
    public void finish( Database.BatchableContext bc ) {
        for( Account acc : accountLst ){
            if( ! acc.Address_Verified__c ) {
                billingContact.Address_Verified__c = FALSE;
                break;
            } else {
                billingContact.Address_Verified__c = TRUE;
            }
        }
        Database.update( accountLst, FALSE );
        update billingContact;
        List <Expocad_Error__c> lstExpo = [ SELECT ID, Errors__c FROM Expocad_Error__c WHERE Parent_Id__c = : billingContact.Id ];
        
        if( String.isNotBlank( errorMsg ) || Test.isRunningTest()) {
            Expocad_Error__c oExpo = new Expocad_Error__c( );
            if( lstExpo != NULL && lstExpo.size( ) > 0 ) {
                oExpo = lstExpo.get( 0 );
            }
            oExpo.Errors__c     = errorMsg;
            oExpo.Parent_Id__c  = contactId;
            upsert oExpo;
        } else {
            if( lstExpo != NULL && lstExpo.size( ) > 0 ) {
                Delete lstExpo;
            }
        }
    }
    public void batchProcess( ) {
        AsyncApexJob aaj;
        if( String.isNotEmpty( batchProcessId ) && batchStatus == 'start' ) {   
            aaj = [ SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE ID =: batchProcessId ];
            try {
                Integer process = aaj.JobItemsProcessed;
                Integer tot     = aaj.TotalJobItems;
                batchProgress   = String.valueOf( ( process * 100 ) / tot );
            } 
            catch( MathException ex ){
              //BK-3754   
                Utility.logsError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'AccountRelatedAccountValidationCtrl' , 'Integration');
            }
            if( aaj.Status == 'Completed' ) {
                batchProcessEnabled = false;
                batchStatus         = 'stop';
                List <Expocad_Error__c> lstExpo = [ SELECT ID, Errors__c FROM Expocad_Error__c WHERE Parent_Id__c =: contactId ];
                if( lstExpo != NULL && lstExpo.size() > 0 ) { error = lstExpo.get(0).Errors__c ; }
            }
        }
    }
    public pageReference back2Contact( ) {
        PageReference pageRef = new PageReference('/'+contactId);
        return pageRef;
    }
}