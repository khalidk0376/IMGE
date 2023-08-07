/**
 * Display Account's address and tax error log
 * 
 * @Author      : Sudip Halder
 * @Date        : 12/Feb/2018
 * Test Class   : AddressValidationTrncDetailsCtrl_Test 
 */
public with sharing class AddressValidationTrncDetailsCtrl {
    /**
     * Variables
     */
    public integer offsetSize                   { get; set; }
    public integer totalRecs                    { get; set; }
    public integer pageNumber                   { get; set; }
    public integer limitSize                    { get; set; }
    /**
     * Constructor
     */
    public AddressValidationTrncDetailsCtrl( ) {
        totalRecs            = offsetSize              = 0;  
        pageNumber           = 1;
        limitSize            = 10;
    }
    
    public void totaTrncLogs( ) {
        List <AddressValidationTrncLog__c> trncLogList = [ SELECT ID From AddressValidationTrncLog__c ]; 
        totalRecs = trncLogList.size();
    }
    public List <AddressValidationTrncLog__c> getAddressValidationTrncLog( ) {
        List <AddressValidationTrncLog__c> trncLogList = [ SELECT ID, Name, Total_Account_Address_Validate__c, Total_Account_Address_Invalidate__c, Total_Account_Tax_Validate__c, Total_Account_Tax_Invalidate__c, Valid_Account_Address_ID__c, Invalid_Account_Address_ID__c, Valid_Account_Tax_ID__c, Invalid_Account_Tax_ID__c, Valid_Contact_Address_ID__c, Invalid_Contact_Address_ID__c FROM AddressValidationTrncLog__c ORDER BY Name DESC LIMIT : limitSize OFFSET : offsetSize ]; 
        return trncLogList;
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
        offsetSize = totalrecs - math.mod( totalRecs, limitSize );
        if( math.mod( totalRecs, limitSize ) > 0 )  pageNumber = ( integer ) totalRecs / limitSize + 1;
        else pageNumber = ( integer ) totalRecs / limitSize;
    }
    public boolean getprev( ) {
        if( offsetSize == 0 ) return true;
        else return false;
    }
    public boolean getnxt( ) {
        if( ( offsetSize + limitSize ) > totalRecs ) return true;
        else return false;
    }
    
}