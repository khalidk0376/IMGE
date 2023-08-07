/*Created By: Girikon(Mukesh Gupta[STL-216])
Created On: 7 Oct, 2019
@description : This is the test class for apex class- OPSCustomerListCtr
Methods: getTest
Apex Class: OPSCustomerListCtr_Test
Modification log --

*/

@isTest
public class OPSCustomerListCtr_Test {
    @IsTest
    private static void getTest() {
        Test.startTest();
        Account acc = new Account();
        acc.Name='test acc';
        insert acc;
        System.assertEquals('test acc',acc.Name,'True');
        
        DateTime dT = System.now().addDays(3);
        Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
        Opportunity opp = new Opportunity();
        opp.Name = 'Tets';
        opp.Amount=34.4;
        opp.CloseDate = myDate;
        opp.StageName = 'Discover';
        opp.AccountId = acc.Id;
        insert opp;
        
        //@Description: Insert Event Edition.
        Event_Edition__c eventEdition = new Event_Edition__c();
        eventEdition.Name = 'Testing Event Edition';
        eventEdition.Tab1__c = 'Tab1';
        eventEdition.Tab4__c = 'Tab4';
        eventEdition.Tab8__c = 'Tab8';
        insert eventEdition;
        
        OPSCustomerListCtr.getGenericObjectRecord('','searchValue',eventEdition.Id,10,false,false,0,'','ASC');
                OPSCustomerListCtr.getGenericObjectRecord('test','searchValue',eventEdition.Id,10,false,false,0,'Name','ASC');

        Test.stopTest();
    }
}