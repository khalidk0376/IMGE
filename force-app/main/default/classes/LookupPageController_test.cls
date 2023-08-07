/*
 * Files:LookupPageController_test,LookupPageController
*Created By 
*Date :
*Discription - 
* Modified By : Rajesh kumar Yadav Bk-3751
*/
@isTest
public class LookupPageController_test {
    static testMethod void unitTest1(){
        	Account a = new account();
        	a.Name = 'test';
        	insert a;
            Contact con = new Contact(firstname='test1',lastName='test1');
            insert con;
            Contact con1 = new Contact(firstname='test1',lastName='test1');
            insert con1;
           system.assertEquals(con1.firstname, 'test1', 'Both values should be the same.');
            PageReference pageRef = Page.customlookupPage;
            pageRef.getParameters().put('accountId', a.Id);
            Test.setCurrentPage(pageRef);
            
        LookupPageController temp = new LookupPageController();
        temp.searchvalue=con.LastName;
        temp.getRecords();
        temp.onkeyupAction();
        temp.searchAction();
        
        
        PageReference pageRef1 = Page.customlookupPage;
            pageRef1.getParameters().put('parentId', a.Id);
            Test.setCurrentPage(pageRef1);
            
        LookupPageController temp1 = new LookupPageController();
      
        
    }

}