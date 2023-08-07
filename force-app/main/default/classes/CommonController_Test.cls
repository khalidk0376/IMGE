/**
* Date:      21/8/2019
* Test Class For:  CommonController
* Code Coverage:   91%
* Created By:      Yash Gupta
* Modified Date:   10/23/2019
* Modified By:     Yash Gupta
* *************************************************************************
* @Description:    This test class covers "CommonController" class.
* *************************************************************************
*/

@IsTest
public with sharing class CommonController_Test {
    @isTest static void test1(){
        //@Description: Insert Account.
        Account acc = new Account();
        acc.Name = 'Testing Account'; 
        acc.CurrencyIsoCode = 'USD';
        insert acc;
        System.assertEquals('Testing Account', acc.name,'true');
        Test.startTest();
        CommonController.getUserRecordAccess(Userinfo.getUserId());
        CommonController.getOrderList(acc.Id);
        CommonController.isCreateable('Contact', 'Email');
        CommonController.isUpdateable('Contact', 'Email');
       // CommonController.getReviewTeamMembList();
        CommonController.getRecordCount('Opportunity','Name!=Null');
        // CommonController.getDeclinedOptions();
        //CommonController.convertToOppBtnCondition('recordId');
        Test.stopTest();
    }
}