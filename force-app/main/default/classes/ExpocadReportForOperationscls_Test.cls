/**
* File:            ExpocadReportForOperationscls_Test
* Project:         GAP
* Date:            Aug 1, 2017
* Test Class For:  ExpocadReportForOperations_cls
* Code Coverage:   89%
* Created By:      Rajesh Kumar
* *************************************************************************
* Description:     Test class for ExpocadReportForOperations_cls class
* *************************************************************************
* History: Modified By Yash Gupta [10/23/2019]
*/

@isTest
private class ExpocadReportForOperationscls_Test {
    static testMethod void expocadReportForOperationscls() {
        PageReference pageRef = Page.vf_ExpocadReportPageForOperations;
        Test.setCurrentPage(pageRef); 
        Event_Series__c oevents = new Event_Series__c (Name = 'Vitafoods Europe' , Event_Edition_Pool__c = 'GHNN', Status__c = 'Active');
        insert oevents ;
        Event_Edition__c ee = new Event_Edition__c();
        ee.Name='Vitafoods Europe 2019';
        ee.Part_of_Series__c = oevents.Id;
        ee.Tab1__c='testt';
        ee.Tab7__c='ttttt';
        ee.Event_Edition_Status__c = 'Confirmed';
        insert ee;
        Operations_Team__c ot = new Operations_Team__c ( Event_Series__c= oevents.Id , Operations_Team_Description__c = 'Test girikon');
        insert ot;
        Operations_Team_Member__c otm = new Operations_Team_Member__c(Operations_Team__c = ot.Id,User_Name__c = UserInfo.getUserId());
        insert otm;
        System.assertEquals('Vitafoods Europe', oevents.name, 'true');
        ExpocadReportForOperations_cls expoR = new ExpocadReportForOperations_cls ();
        expoR.ErrorMessage = 'You are not a part of the Operation team of any of the shows.';
        expoR.geteventeditonname();
        expoR.geteventseriesname();
        expoR.changeEventSeries();
        expoR.changeEditionValue();
        expoR.getToLink();
    }
}