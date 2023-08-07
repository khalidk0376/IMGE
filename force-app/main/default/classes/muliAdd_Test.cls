/**
 * @Author      : 
 * @Date        : 
 * Apex Class : 
 * * Modified By : Rajesh kumar Yadav Bk-3751
 */
@isTest
private class muliAdd_Test {
    static testMethod void method1(){
        WorkOrder_Team__c wtTeam= new WorkOrder_Team__c();
        wtTeam.Team_Member__c = userInfo.getUserId();
        wtTeam.CurrencyIsoCode = 'USD';
        insert wtTeam;
        system.assertEquals(wtTeam.CurrencyIsoCode, 'USD', 'Both values should be the same.');
        Test.StartTest();
       	PageReference pageRef = Page.MultipleTeamsToAdd;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(wtTeam.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(wtTeam);
        MultiAdd addMultipleTeam = new MultiAdd(sc);
        addMultipleTeam.selectedRowIndex = '2';
        addMultipleTeam.Add();
        addMultipleTeam.Del();
        addMultipleTeam.cancel();
        addMultipleTeam.Save();
        Test.StopTest();
    }
}