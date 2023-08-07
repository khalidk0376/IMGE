/**
 * This batch class used call 'BlngContactAccntBlngAddController' class to validate account address, related contact address and also validate the Tax.
 * If validation is success then update Account's certain fields to which account is got validated and which is not
 * 
 * @Author      : Sudip Halder
 * @Date        : 21/Dec/2017  
 * Test Class   : AccountAddressValidationBatch_Test
 */
public class AccountAddressValidationBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    
    public List <String> accountIds;
    public AddressValidationTrncLog__c  trncLog { get; set; }
    public Set<String> errors                   { get; set; }
    /**
     * Constructor
     */
    public AccountAddressValidationBatch( List <String> accountIds, AddressValidationTrncLog__c trncLog ) { 
        this.accountIds = accountIds;
        this.trncLog    = trncLog;
        errors          = new Set <String> ( );
    }
    
    /*
    public AccountAddressValidationBatch( ) { }
        //BK-3753 - EmptyStatementBlock Violation Reported so I am commented this block as of now.
    */
    
    public Database.QueryLocator start( Database.BatchableContext bc ) { 
        return Database.getQueryLocator( [ SELECT Id FROM Account WHERE Id IN : accountIds ] );  
    }
    public void execute( Database.BatchableContext bc, List <Account> scope ) { 
        for( Account acc : scope ) {
            if( !Test.isRunningTest( ) ) {
                BlngContactAccntBlngAddController accAddCtrl = new BlngContactAccntBlngAddController( );
                String  error = accAddCtrl.validateAccountBillingAddress( acc.Id ); 
                errors.add( error );    
            }
            
        }
    }
    public void finish( Database.BatchableContext bc ) {
        
        List <string> errLst = new List <string> ( );
        errLst.addAll( errors );
        String err = String.join(errLst, ';');
        boolean checked;
        
        String accAddressValid   = '';
        String accAddressInvalid = '';
        String conAddressValid   = '';
        String conAddressInvalid = '';
        String accTaxValid       = '';
        String accTaxInvalid     = '';
        List <Account> accList   = New List <Account> ( );
        
        for( Account acc : [ SELECT Id, Address_Verified__c, Tax_ID_Verified__c, ( SELECT Address_Verified__c FROM Contacts ) From Account WHERE Id IN : accountIds ] ) {
            checked = false;
            for( Contact con : acc.Contacts) {
                if( con.Address_Verified__c == false ) { 
                    checked = true; break; 
                } 
            }
            if( !checked )
                acc.All_Contact_Verified__c = true; accList.add( acc );
            if( acc.Address_Verified__c ==  true ) {
                accAddressValid = recordIdsConcate( accAddressValid, acc.Id );
            }
            if( acc.Address_Verified__c ==  false ){
                accAddressInvalid = recordIdsConcate( accAddressInvalid, acc.Id );
            }   
            if( acc.Tax_ID_Verified__c ==  true ) {
                accTaxValid = recordIdsConcate( accTaxValid, acc.Id );            
            }
            if( acc.Tax_ID_Verified__c ==  false ) {
                accTaxInvalid = recordIdsConcate( accTaxInvalid, acc.Id );
            }
            for( Contact con1 : acc.Contacts ) {
                if( con1.Address_Verified__c ==  true ) {
                    conAddressValid = recordIdsConcate( conAddressValid, con1.Id );              
                }
                if( con1.Address_Verified__c ==  false ) {
                    conAddressInvalid = recordIdsConcate( conAddressInvalid, con1.Id );    
                }
            }
        } 
        if( !accList.isEmpty( ) ) {
            update accList;   
        }
        trncLog.Valid_Account_Address_ID__c         = accAddressValid;
        //trncLog.Invalid_Account_Address_ID__c       = accAddressInvalid;
        trncLog.Invalid_Account_Address_ID__c       = err;
        trncLog.Valid_Account_Tax_ID__c             = accTaxValid;
        trncLog.Invalid_Account_Tax_ID__c           = accTaxInvalid;
        trncLog.Valid_Contact_Address_ID__c         = conAddressValid;
        trncLog.Invalid_Contact_Address_ID__c       = conAddressInvalid;
        update trncLog;
        
    }

    public Integer countNumber( String str ) {
        List <String> lst = new List <String> ( );
        if( str != NULL && str != '' ) {
          lst.addAll( str.split(',') );  
        }
        return lst.size( );
    }    
    public String recordIdsConcate( String originalString, String newString ) {
        if( !String.isBlank( originalString ) && !String.isBlank( newString ) ) {
            return originalString+', '+ newString;
        } else {
          return newString;  
        } 
    }
}