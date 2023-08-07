/**
* File:        GoogleMapAccountAddressClass.cls
* Project:     GAP
* Date :       1/14/2019 
* Created By:  Yash Gupta
* Test Class:  GoogleMapAccountAddressClass_Test
* *************************************************************************
* @Description Controller of Account Address Google Map.
*
* *************************************************************************
* History: As per ticket no GGCW-1821, I have integrate google map page in to account skuid layout.
*  History: BK-3758 Modified By Rajesh Kumar - on 28-05-2020
*/

public class GoogleMapAccountAddressClass{
    
    /**
     * sAccountId
     * @description apex variable
     */
    public String sAccountId                               {  get;set; }

    /**
     * acc
     * @description apex variable
     */
    public Account acc                                     {  get;set; }

    /**
    * mapStateWithCode
    * @description apex variable
    */
    public Map<String, String> mapStateWithCode            {  get;set; }

    /**
    * lstAccount
    * @description apex variable
    */
    List<Account> lstAccount;

    /**
    * IsBool
    * @description apex variable
    */
    public boolean IsBool {  get;set; }

    /**
     * lstAccountLegalEntity
     * @description apex variable
     */
     public List<Account_Legal_Entity__c> lstAccountLegalEntity;
     
     /**
     * iCount
     * @description apex variable
     */
     public Integer iCount                                  {  get;set;  }
     
     
     /**
    * @description Constructor, Getting required parameters as well as initialize contact mailing state code into map also call a void method.
    */
    public GoogleMapAccountAddressClass() {
        sAccountId = ApexPages.currentPage().getParameters().get('id').escapeHtml4();
        lstAccount = new List<Account>();
        mapStateWithCode = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = contact.MailingStatecode.getDescribe();
        List<Schema.PicklistEntry> values = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry v : values){
            mapStateWithCode.put(v.getLabel(),v.getValue());
        }
        accountQry();
    }
    
    /**
     * @description Call this method at the time of page load.
     * @return Nothing
     */
    Public void accountQry(){
        if(String.IsNotBlank(sAccountId)){
            String sAccountQry = 'select id, BillingStreet, ShippingStreet, BillingCity, ShippingCity, BillingStateCode, ShippingStateCode, BillingCountryCode, ShippingCountryCode, BillingPostalCode, ShippingPostalCode, Billing_Address_Line_2__c, Shipping_Address_2__c, IsFromShippingAddress__c, IsFromBillingAddress__c, Inactive__c from Account Where Id IN (\''+String.escapeSingleQuotes(sAccountId)+'\') Limit 1';
            acc = Database.Query(sAccountQry);
            lstAccountLegalEntity = [select Id, Account__c, Business_Partner_Number__c, Legal_Entity__c from Account_Legal_Entity__c Where Account__c=:sAccountId];
            iCount = lstAccountLegalEntity.size();
            Map<String, AllowedProfiles__c> mapAllowProfiles = AllowedProfiles__c.getAll();
            String profileName = [Select Id, Profile.Name from User where Id=:UserInfo.getUserId()].Profile.Name;
            if(!acc.Inactive__c && (lstAccountLegalEntity.size() == 0 || (profileName == 'System Administrator' || profileName == 'GE System Administrator' || profileName == 'SSC Finance-Accounting' || profileName == 'GE BA Administrator'))) {
                IsBool = false;
            } else {
                IsBool = true;
            } 
        }
    }
    
    /**
     * @description This method is used to save account record.
     * @return Nothing
     */
    public void autoRedirect() {
        lstAccount.add(acc);
        if(lstAccount.size() > 0){
            update lstAccount;
        }
    }
}