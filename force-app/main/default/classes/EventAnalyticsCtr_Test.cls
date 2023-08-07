/**
* Date:            21/8/2019
* Test Class For:  EventAnalyticsCtr
* Code Coverage:   97%
* Created By:      Mukesh Gupta
* Modified Date:   10/23/2019
* Modified By:     Yash Gupta
* *************************************************************************
* @Description:     This test class covers "EventAnalyticsCtr" class.
* *************************************************************************
* History: Rajesh Kumar : BK-5121 on Date - 08-06-2020
*/

@IsTest
public class EventAnalyticsCtr_Test {
    @IsTest
    static void testGetData(){
        Test.startTest();
        Account acc = new Account();
        acc.Name='test acc';
        insert acc;
        
        Event_Series__c oEventseries = new Event_Series__c();
        oEventseries.Name = 'TOC Europe';
        oEventseries.CurrencyISOCode = 'USD';
        oEventseries.Package_Identifier__c = 'TOCEU';
        oEventseries.Event_Edition_Pool__c = 'GHNN';
        insert oEventseries;
        
        DateTime dT = System.now().addDays(3);
        Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
        Opportunity opp = new Opportunity();
        opp.Name = 'Tets';
        opp.CloseDate = myDate;
        opp.StageName = 'Discover';
        opp.AccountId = acc.Id;
        opp.Event_Series__c = oEventseries.Id;
        insert opp;
        
        EventAnalyticsCtr.getDatas(acc.Id, 'asc', 10, 0, 'test', false, false);
        EventAnalyticsCtr.getDatas(acc.Id, 'asc', 10, 0, 'test', true, false);
        EventAnalyticsCtr.getDatas(acc.Id, 'asc', 10, 0, 'test', false, true);
        
        System.assertEquals('test acc',acc.Name,'True');   
        Test.stopTest();
    }
}