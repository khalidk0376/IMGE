/**
* File:        SyncEventEdition_test.cls
* Project:     GAP
* Date:        26/11/2019
* Created By:  Adarsh Sharma
* For Class:   SyncEventEdition.cls
* Coverage:    91%
* *************************************************************************
* Description: Sync present event Edition from previous event edition.
* *************************************************************************
*/
@isTest
public class SyncEventEdition_test {
    static testMethod void syncEventEdtn (){
        Account acc1 = new Account();
        acc1.Name='acc1';
        acc1.BillingCity ='Dallas' ;
        acc1.BillingCountry='USA';
        acc1.BillingPostalCode='75068';
        acc1.BillingState='Texas';
        acc1.BillingStreet='water well street';              
        insert acc1;
        
        Contact con = new Contact(LastName='User',FirstName ='Test1',AccountId=acc1.id, Contact_Type__c = 'Primary Contact');
        insert con;
        
        Event_Series__c evntSeries = new Event_Series__c( name='World of Concrete' );
        evntSeries.Status__c = 'Active';
        insert evntSeries;
        
        Event_Edition__c  sOEve1 = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today(),Payment_Schedule__c='10-40-50',X50_Cutoff_Date__c=Date.today(),Cutoff_Date_1__c=Date.today(),Cutoff_Date_2__c=Date.today(),CutoffDate_3__c=Date.today());
        sOEve1.Event_Edition_Status__c = 'Confirmed';
        sOEve1.Event_Edition_Code__c = 'WOC17';
        sOEve1.Part_of_Series__c = evntSeries.Id;
        insert sOEve1;
        Event_Edition__c  sOEve2 = new Event_Edition__c(Name='World of Concrete 2018',Event_Code__c='WOC18',End_Date__c=System.Today(),Start_Date__c=System.Today(),Payment_Schedule__c='10-40-50',X50_Cutoff_Date__c=Date.today(),Cutoff_Date_1__c=Date.today(),Cutoff_Date_2__c=Date.today(),CutoffDate_3__c=Date.today());
        sOEve2.Event_Edition_Status__c= 'Confirmed';
        sOEve2.Previous_Event_Edition__c = sOEve1.Id;
        sOEve2.Event_Edition_Code__c = 'WOC18';
        sOEve2.Part_of_Series__c = evntSeries.Id;
        insert sOEve2;
        System.assertEquals(sOEve2.Event_Code__c, 'WOC18', 'This event edition must be World of concrete 2018');
        SyncEventEdition syncObj = new SyncEventEdition();
        SyncEventEdition.syncPresentEventEdition(sOEve2.Id, evntSeries.id);
        SyncEventEdition.syncPresentEventEditionLtng(sOEve2.Id);
    }
}