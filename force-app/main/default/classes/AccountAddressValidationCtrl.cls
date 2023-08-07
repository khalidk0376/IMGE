/**
 * This AccountAddressValidationCtrl class used in 'AccountAddressValidation' vf page. It has the functionality to display records of accounts
 * based on event series and event editions. User choose event seties and the event edition will appear and choose event edition accounts will 
 * appear.
 * 
 * This class has another main functionality.i.e. User can validate the Accounts address, Tax and its contact address by clicking 'validate' buttons.
 * Internally a batch process call the api and validate.
 * 
 * @Author      : Sudip Halder
 * @Date        : 21/Dec/2017  
 * Test Class   : AccountAddressValidationCtrl_Test
 * BK-3758 - Modified By Rajesh Kr - 20-05-2020



 */
public without sharing class AccountAddressValidationCtrl {
    
    /**
     * Variables
     */
    public String selectedEventSeries           { get; set; }
    public String selectedEventEdition          { get; set; }
    public String selectedOption                { get; set; }
    public String selectedOptionDisplay         { get; set; }
    public String eventEditionDisplay           { get; set; }
    public String accSelectWarn                 { get; set; }
    public List <String> accountIds             { get; set; }
    public integer totalRecs                    { get; set; }
    public integer offsetSize                   { get; set; }
    public integer limitSize                    { get; set; }
    public integer pageNumber                   { get; set; }
    public List <Account> accList               { get; set; }
    public List <Id> allAccList                 { get; set; }
    public Boolean allAccDisplay                { get; set; }
    public Id batchProcessId                    { get; set; }
    public String batchProgress                 { get; set; }
    public String batchStatus                   { get; set; }
    public Boolean batchProcessEnabled          { get; set; }
    public Boolean backBtnDisplay               { get; set; }
    public AddressValidationTrncLog__c  trncLog { get; set; }
    public String accountName                   { get; set; }
    /**
     * Constructor
     */
    public AccountAddressValidationCtrl( ) {
        selectedEventSeries  = selectedEventEdition    = batchProgress        = '0';
        accSelectWarn        = selectedOptionDisplay   = '';
        totalRecs            = OffsetSize              = 0;
        limitSize            = 10;
        pageNumber           = 1;
        accountIds           = new  List <String> ( );
        batchStatus          = 'None';
        batchProcessEnabled  = true;
        backBtnDisplay       = allAccDisplay           = false;
    }
    /**
     * This method get the event series records
     * @Return SelectOption  - List of event series name and id
     */
    public List <SelectOption> getEventSeries( ) {
        List <SelectOption> eventSeriesOptions = new List <SelectOption> ( );
        List <Event_Series__c> eventSeries = [ SELECT id, Name FROM Event_Series__c order by Name ASC ];
        eventSeriesOptions.add( new SelectOption( '0', '-- Select Event Series --' ) );
        for( Event_Series__c series : eventSeries )
            eventSeriesOptions.add( new SelectOption( series.id, series.Name ) );
        return eventSeriesOptions;
    }
    /**
     * This method get event edition records
     * @Return SelectOption  - List of event edition name and id
     */
    public List <SelectOption> getEventEdition( ) {
        List <SelectOption> eventEditionOptions = new List <SelectOption> ( );
        List <Event_Edition__c> eventEdition;
        if( selectedEventSeries  != '0' )
            eventEdition = [ SELECT id, Name FROM Event_Edition__c where Part_of_Series__c = : selectedEventSeries order by name asc ];
        eventEditionOptions.add( new SelectOption( '0', '-- Select Event Edition --' ) );
        for( Event_Edition__c edition : eventEdition ) 
            eventEditionOptions.add( new SelectOption( edition.id, edition.Name ) );
        return eventEditionOptions;
    }
    /**
     * This method used if user change the event series and 
     * update the 'EventEditionDisplay' variable
     */
    public void evntSeriesChnge( ) {
        selectedEventEdition = '0';
        totalRecs            = 0;
        if( selectedEventSeries != '0' ) 
            EventEditionDisplay = 'show';
        else EventEditionDisplay = 'hide';  
        cancelSearchAccounts( );
        firstPage( );
    }
    
    public void evntEditionChnge( ) {
        cancelSearchAccounts( );
        totalAccounts( );
    }
    public void selectedOptionchng( ) {
        if( selectedEventEdition != '0' && totalRecs > 0 ) selectedOptionDisplay = 'show';
        else selectedOptionDisplay= 'hide';
    }
    /**
     * This method uued to fatch all accounts based on opportunities event edition 
     * @Return accList - List of accounts
     */
    public List <Account> getAccounts( ) {
        Map <Id, Account> accountMap;
        accList = new List <Account> ( );
        if( selectedEventEdition != '0' ) {
            if( accountName != NULL && accountName != '' ) {
                String accName = '%'+ accountName +'%';
                selectedOption = '';
                accountMap = new Map <Id, Account> ( [ SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingStateCode, BillingCountry, BillingCountryCode, Billing_Address_Line_2__c, Tax_Id__c, Address_Verified__c, All_Contact_Verified__c, Tax_ID_Verified__c FROM Account Where Id in ( SELECT AccountId FROM Opportunity  WHERE EventEdition__c =: selectedEventEdition ) AND Name Like : accName ORDER BY Name ASC  LIMIT : limitSize OFFSET : OffsetSize ] );
                for( Id i : accountMap.keySet( ) ) {
                    Account a =  accountMap.get( i ); 
                    accList.add( a );
                }
            } else {
                if( selectedOption != '' && selectedOption != null ) {
                    String soffsetSize = string.valueOf(offsetSize);
                    String slimitSize = string.valueOf(limitSize);
                    String query = 'SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingStateCode, BillingCountry, BillingCountryCode, Billing_Address_Line_2__c, Tax_Id__c, Address_Verified__c, All_Contact_Verified__c, Tax_ID_Verified__c FROM Account Where Id in ( SELECT AccountId FROM Opportunity  Where EventEdition__c =\''+ string.escapeSingleQuotes(selectedEventEdition)+'\' ) AND '+string.escapeSingleQuotes(selectedOption)+'= TRUE LIMIT '+string.escapeSingleQuotes(slimitSize)+' OFFSET '+string.escapeSingleQuotes(soffsetSize);
                    accList = ( list <Account> ) Database.query( query );
                } else {
                    accountMap = new Map <Id, Account> ([ SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingStateCode, BillingCountry, BillingCountryCode, Billing_Address_Line_2__c, Tax_Id__c, Address_Verified__c, All_Contact_Verified__c, Tax_ID_Verified__c FROM Account Where Id in ( SELECT AccountId FROM Opportunity  Where EventEdition__c =: selectedEventEdition ) LIMIT : limitSize OFFSET : OffsetSize ] );
                    for( Id i : accountMap.keySet( ) ) { 
                        Account a =  accountMap.get( i );
                        accList.add( a );
                    }
                }
            }
        }
        return accList;
    }
    public void searchAccounts( ) {
        String accountNameStr = Apexpages.currentPage( ).getParameters( ).get('AccounttNameString').escapeHtml4();
        System.debug( 'The search string is '+ accountNameStr );
        if( accountNameStr != '' ) {
            accountName = accountNameStr;   
            firstPage( );
        }
        else accountName = '';    
    }
    
    public void cancelSearchAccounts( ) {
        accountName = '';
    }
    /**
     * This method uued to fatch all accounts based on opportunities event edition 
     * @Return allAccList - List of accounts Id
     */
    public List <Id> getAllAccountsId( ) {
        Map <Id, Account> accountMap;
        allAccList = new List <Id> ( );
        accountMap = new Map <Id, Account> ( [ SELECT Id, Name FROM Account Where Id IN ( SELECT AccountId FROM Opportunity  WHERE EventEdition__c = : selectedEventEdition ) AND ( Address_Verified__c = FALSE OR All_Contact_verified__c = FALSE OR Tax_id_verified__c = FALSE ) LIMIT 10000 ] );
        for( Id i : accountMap.keySet( ) ) { 
            Account a =  accountMap.get( i );
            allAccList.add( a.Id ); 
        }
        allAccDisplay = true;
        return allAccList;
    }
    public void addAllAccountsIds( ) {
        if( allAccList.size() > 0 ) {
            accountIds.clear( );
            for( Id acc : allAccList )
                accountIds.add( String.valueOf( acc ) );
        }
    }
    
    public void totalAccounts( ) {
        Map <Id, Account> accountMap;
        List <Account> accList = new List<Account>( );
        if( selectedEventEdition != '0' ) {
            if( accountName != NULL && accountName != '' ) {
                String accName = '%'+ accountName +'%';
                accountMap = new Map <Id, Account> ([ SELECT Id FROM Account Where Id in ( SELECT AccountId FROM Opportunity  Where EventEdition__c =: selectedEventEdition ) AND Name Like : accName ] );
                for( Id i : accountMap.keySet( ) ) {
                    Account a =  accountMap.get( i );
                    accList.add( a ); }
                totalRecs = accList.size( );
            } else {
                accountMap = new Map <Id, Account> ([ SELECT Id FROM Account Where Id in ( SELECT AccountId FROM Opportunity  Where EventEdition__c =: selectedEventEdition ) ] );
                for( Id i : accountMap.keySet( ) ) {
                    Account a =  accountMap.get( i ); 
                    accList.add( a ); }
                totalRecs = accList.size( );
            }
        } else totalRecs = 0;
        firstPage( );
    }   
    public void selectedAccounts( ) {
        accountIds.clear( );
        String selectedStr =  Apexpages.currentPage( ).getParameters( ).get( 'selectedIDs' );
        if( String.isEmpty( selectedStr ) ) 
            accSelectWarn = 'false';
        else {
            String [] selectedAccount = selectedStr.split(',');
            for( String value : selectedAccount )
                accountIds.add( value.trim( ) );
            if( accountIds.size() > 0 )  
                accSelectWarn = 'true';
        }
    }
    
    public void reloadPopup( ) {
        accSelectWarn = '';
        allAccDisplay = false; 
    }
    
    public void continueValidate( ) {
        trncLog = new AddressValidationTrncLog__c( );
        insert trncLog;
        AccountAddressValidationBatch accAddValidBtch = new AccountAddressValidationBatch( accountIds, trncLog );
        batchProcessId = Database.executeBatch( accAddValidBtch, 1 );
        batchStatus = 'start';
        reloadPopup( );
    }
    public void batchProcess( ) {
        AsyncApexJob aaj;
        if( String.isNotEmpty( batchProcessId ) && batchStatus =='start' ) {
            aaj = [ SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE ID =: batchProcessId ];   
            try {
                Integer process = aaj.JobItemsProcessed;
                Integer tot = aaj.TotalJobItems;
                batchProgress = String.valueOf( ( process * 100 ) / tot ); 
            } catch( MathException mathError ) {
                 //BK-3754          
                 Utility.logsError(mathError.getMessage(), mathError.getCause(), mathError.getLineNumber(), mathError.getStackTraceString(), 'AccountAddressValidationCtrl' , 'Integration');
            }
            if( aaj.Status == 'Completed' )  { 
                batchStatus = 'stop';
                batchProcessEnabled = false;
                backBtnDisplay = true; }
        }
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
        if( offsetSize >= 2000 ) offsetSize = 2000 - 10;
    }
    public void lastPage( ) {
        offsetSize = totalrecs - math.mod( totalRecs, limitSize );
        if( math.mod( totalRecs, limitSize ) > 0 )  pageNumber = ( integer ) totalRecs / limitSize + 1;
        else pageNumber = ( integer ) totalRecs / limitSize; 
        if( offsetSize >= 2000 ) offsetSize = 2000 - 10;
        if( offsetSize == totalrecs ) offsetSize -= limitSize;
    }
    public boolean getPrev( ) {
        if( offsetSize == 0 ) return true;
        else return false;
    }
    public boolean getNxt( ) {
        //if( ( offsetSize + limitSize ) >= totalRecs ) return true;
        if( offsetSize >= 1990 ||  ( offsetSize + limitSize ) >= totalRecs ) 
            return true;
        else return false;
    }
    public List <SelectOption> getFilterOptions( ) {
      List <SelectOption> filterOptions = new List <SelectOption> ( );
      FilterOptions.add( new SelectOption( '','None' ) );
      FilterOptions.add( new SelectOption( 'Address_Verified__c','Verified Address' ) );
      FilterOptions.add( new SelectOption( 'All_Contact_Verified__c','Verified All Contacts' ) );
      FilterOptions.add( new SelectOption( 'Tax_ID_Verified__c','Verified Tax ID' ) );
      return filterOptions;
    }
    public void refreshTable( ) {
        backBtnDisplay = false;
        batchStatus    = 'None';
        batchProgress        = '0';
        accSelectWarn        = selectedOptionDisplay   = '';
        batchProcessEnabled  = true;
        backBtnDisplay       = allAccDisplay           = false;
    }
    public void resetOffset( ) {
        offsetSize           = 0;
        pageNumber           = 1;
        if( selectedOption != '' && selectedOption != null ) {
            totalRecs = Database.query( 'SELECT Id FROM Account Where Id in ( SELECT AccountId FROM Opportunity  Where EventEdition__c =: selectedEventEdition ) and '+ selectedOption +'=true ').size();
        } else {
            totalAccounts( );
        }
    }
}