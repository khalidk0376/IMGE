/**
* Created By:  Girikon(Prashant)
* Created On:  10/10/2018
* @description : This test class covers the apex class "ExhibitorsWithoutContractorsCtrl" following methods:
               getExhibitors, getAccountContacts, getContactByID, getEventDetails, getServices, getAccount, getDuplicateContacts, createContactandMapping, 
                deleteTempAccount, getPicklistValues, getDependentMap,getDesignationInfo,getAggregateResult,PrefContractors

* Methods:  ExhibitorWithoutContractor
* Apex Class: ExhibitorsWithoutContractorsCtrl (93%) 
*
* Modification Log----- 
* Modified by   : 
* Modified On   : 
**/

@isTest
public class ExhibitorsWithoutContractorsCtrl_Test 
{
    /**
     * @description : For data setup and test methods.
     * @return
    */
    public static testmethod void exhibitorWithoutContractor()
    {
        Account a = new Account(Name='TstAccFrst' , BillingStreet='testStreet',BillingCity='test', BillingState='Delhi', BillingPostalCode='13245', BillingCountry='India');
        insert a;
        
        Account acc1=new account();
        acc1.name='abc';
        insert acc1;
        
        Contact sContact = new Contact(AccountId = a.Id, FirstName = 'Test', LastName = 'Name', Email = 'abc@test.com');
        insert sContact;
        System.AssertNotEquals(sContact, null, true);
         
        
        Event_Edition__c evntID = new Event_Edition__c(Name='TestName',Event_Currency__c='USD',Event_Code__c='XYZ');
        insert evntID;
        string evntId1=string.valueOf(evntID.Id);
        System.AssertNotEquals(evntID, null, true);
        
        list<Event_Edition__c> lstEE1=[SELECT Id, Name, Event_Code__c from Event_Edition__c LIMIT 1];
        string evntCode=lstEE1[0].Event_Code__c;
        
        Event_Settings__c evntSetting = new Event_Settings__c(Disable_this_information__c =  true, Event_Edition__c = evntID.Id);
        insert evntSetting;
        System.AssertNotEquals(evntSetting, null, true);
        
        String column = 'Opportunity__r.Account.Name';
        String order = 'asc';
        String searchText = 'test';
        String matchProductOption= 'test';
        
        TempAccount__c lstTmpAcc= new TempAccount__c(Name= 'TempAcc', CurrencyIsoCode = 'USD');
        string tempAccId=string.valueOf(LstTmpAcc.Id);
        
        List<ExpocadBooth__c> lstEBooth =[SELECT Id from ExpocadBooth__c];
        list<string> lstEBoothId = new list<string>();
        for(ExpocadBooth__c eb: lstEBooth)
        {
            lstEBoothId.add(string.valueOf(eb.id)); 
        }
        
        list<ContractorService__c> lstCS=[SELECT Id from ContractorService__c];
        list<string> lstCsIDS=new list<string>();
        for(ContractorService__c cs: lstCS)
        {
            lstCsIDS.add(string.valueOf(cs.Id));
            
        }
       
        
        
        ExhibitorsWithoutContractorsCtrl.ExhibitorsWrapper  objExhibitorsWrapper= ExhibitorsWithoutContractorsCtrl.getExhibitors(evntID.Id,column,order,searchText,5,0,matchProductOption);
        System.AssertNotEquals(objExhibitorsWrapper, null, true);
        
        list<account> lstAcc = ExhibitorsWithoutContractorsCtrl.getAccountContacts(evntID.Id,searchText);
        System.AssertNotEquals(lstAcc, null, true);
        
        Account sAcc = ExhibitorsWithoutContractorsCtrl.getAccount(evntCode,searchText);

        Contact lsContact = ExhibitorsWithoutContractorsCtrl.getContactByID(sContact.id);
        System.AssertNotEquals(lsContact, null, true);
        
        Event_Settings__c lsEventS = ExhibitorsWithoutContractorsCtrl.getEventDetails(evntID.Id);
        System.AssertNotEquals(lsEventS, null, true);
        
        list<ContractorService__c> lsContService = ExhibitorsWithoutContractorsCtrl.getServices(evntID.Id);
        System.AssertNotEquals(lsContService, null, true); 
        
        list<sObject> lstsObject2=ExhibitorsWithoutContractorsCtrl.getDuplicateContacts(sContact);
        System.AssertNotEquals(lstsObject2, null, true); 
        
        string objString1=ExhibitorsWithoutContractorsCtrl.createContactandMapping(sContact,evntId1,tempAccId,lstEBoothId,lstCsIDS);
        System.AssertNotEquals(objString1, null, true); 
        
        string objStr3=ExhibitorsWithoutContractorsCtrl.deleteTempAccount(tempAccId);
        System.AssertNotEquals(objStr3, null, true);
        
        map<string,sObject> mapStringSobject=ExhibitorsWithoutContractorsCtrl.createTempAccount(a);
        map<string,sObject> mapStringSobject2=ExhibitorsWithoutContractorsCtrl.createTempAccount(acc1);
        
        list<string> lstStr2=ExhibitorsWithoutContractorsCtrl.getPicklistValues('Account','billingCountryCode');
        Map<String,List<String>> objResults = ExhibitorsWithoutContractorsCtrl.getDependentMap('Account','billingCountryCode','billingStateCode');
         ExhibitorsWithoutContractorsCtrl.getDesignationInfo(evntID.id);
        ExhibitorsWithoutContractorsCtrl.getAggregateResult(evntID.id);
        ExhibitorsWithoutContractorsCtrl.PrefContractors(evntID.id,'');
        ExhibitorsWithoutContractorsCtrl.getDepndentCustomVal('AF');
      }
}