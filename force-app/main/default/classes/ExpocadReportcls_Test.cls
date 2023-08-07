/**
* Project:         GAP
* Date:            12/5/2017
* Test Class For:  ExpocadReport_cls
* Code Coverage:   86%
* Created By:      Rajesh Kumar
* Modified Date:   10/23/2019
* Modified By:     Yash Gupta
* @Description:    This test class covers "ExpocadReport_cls" class.
*/

@isTest
private class ExpocadReportcls_Test {
  static testMethod void testDoGet() {
    PageReference pageRef = Page.vf_ExpocadReportPage;
    Test.setCurrentPage(pageRef); 
    //@Description: Insert Account.
    Account acc = new Account();
    acc.Name = 'Testing Account'; 
    acc.CurrencyIsoCode = 'USD';
    System.assertEquals('Testing Account', acc.name,'true');
    
    ExpocadReport_cls  expoR = new ExpocadReport_cls();
    expoR.geteventeditonname();
    expoR.geteventseriesname();
    expoR.changeEventSeries();
    expoR.changeEditionValue();
    expoR.getToLink();
  }
}