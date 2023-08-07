/**
 * Created/Modified By: Girikon(Rajeev) // BK-2354
 * Created On:          Sep 13 2019
 * Description/Purpose: Test class for PreferredContractorCtrl
 * Class:          PreferredContractorCtrl
 * Last Modified By : [Aishwarya BK-3037 Dec 11 2019]
**/

@isTest
public class PreferredContractorCtrl_Test {

    static testMethod  void multiMethod()
    {
        Account testAccount = new Account();
        testAccount.Name='Test Account' ;
        testAccount.Type = 'Stand Contractor';
        testAccount.Inactive__c = False;
        insert testAccount;
        
        Account testacc = new Account();
        testacc.Name='test' ;
        insert testacc;
        
        Event_Edition__c evntEdtn = new Event_Edition__c(Name='TestName',Event_Currency__c='USD',Event_Code__c='XYZ', Preferred_Contractors__c=testacc.id);
        insert evntEdtn;
        string evntId1=string.valueOf(evntEdtn.Id);
        System.AssertNotEquals(evntEdtn, null,'Event Edition not equal null');
        
        Test.StartTest(); 
            PageReference pageRef = Page.PrefferredContractorPage; // Add your VF page Name here
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('Id',evntId1);
            PreferredContractorCtrl testAccPlanobj = new PreferredContractorCtrl();
            testAccPlanobj.getDeselectedValues();
            testAccPlanobj.getSelectedValues();
            testAccPlanobj.searchText='sur';
           
            testAccPlanobj.save();
            testAccPlanobj.getDeselect();
            testAccPlanobj.getSelect();
            testAccPlanobj.srch();
            testAccPlanobj.cancel();
            testAccPlanobj.searchText='';
            testAccPlanobj.srch();
        Test.StopTest();
    }
}