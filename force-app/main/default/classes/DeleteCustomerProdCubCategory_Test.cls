/**
 * Created/Modified By: Girikon(Pramod)
 * Created On:          12/20/2017
 * Description/Purpose: This test class covers the apex class : DeleteCustomerProdCubCategory
 * Methods:             DeleteCustomerProdCubCategory_DataInsert
 * Apex Class:          DeleteCustomerProdCubCategory
 **/

@isTest
public class DeleteCustomerProdCubCategory_Test 
{
  public static testMethod void DeleteCustomerProdCubCategory_DataInsert()
    {
         // Setup test data
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduserDSPCC@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing11', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduserDSPCC@testorg.com');
            insert u;
        System.runAs(u) 
        {
            Account acc1 = new Account();
            acc1.Name='acc1';
                      
            insert acc1;
            
            Contact con = new Contact(LastName='User',FirstName ='Test',AccountId=acc1.id);
            insert con;
            
            Event_Edition__c OEve = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today());
            insert OEve;
            System.assertEquals(OEve.Event_Code__c,'WOC17', 'Event Code');
            EventCurrecies__c eventCurrency = new EventCurrecies__c (Name='USD',Event_Edition__c=OEve.id);
            insert eventCurrency;
            System.assertEquals(eventCurrency.Name,'USD', 'Event Currency');
            OEve.EventCurrency__c = eventCurrency.id;
            update OEve;
            System.assert(OEve.EventCurrency__c != null, 'Event Currency');
            
            Product_Category__c TestPC1 = new Product_Category__c();
            TestPC1.name = 'testPC1Name';
            insert TestPC1;
            
            Product_Category__c TestPC2 = new Product_Category__c();
            TestPC2.ParentCatID__c = TestPC1.id;
            TestPC2.name = 'testPC2Name';
            insert TestPC2;
            
            Product_Category__c TestPC3 = new Product_Category__c();
            TestPC3.name = 'testPC3Name';
            TestPC3.ParentCatID__c = TestPC2.id;
            insert TestPC3;
            
            Event_Edition_Product_Category_Mapping__c TestEEPCM = new Event_Edition_Product_Category_Mapping__c();
            TestEEPCM.name = 'TsetName';
            TestEEPCM.Event_Edition__c = OEve.id;
            TestEEPCM.Product_Category__c = TestPC3.id;
            insert TestEEPCM;
            
            Event_Edition_Sub_Category_Mapping__c TestEESCM = new Event_Edition_Sub_Category_Mapping__c();
            TestEESCM.name = 'TestEESCMName';
            TestEESCM.Event_Edition__c = OEve.id;
            TestEESCM.Product_Category__c = TestPC3.id;
            TestEESCM.Event_Edition_Product_Category_Mapping__c = TestEEPCM.id;
            insert TestEESCM;
            
            Customer_Product_Category__c TestCPC = new Customer_Product_Category__c();
            TestCPC.name = 'TestCPCName';
            TestCPC.Contact__c = con.id;
            TestCPC.Event_Edition__c = OEve.id;
            TestCPC.Event_Edition_Product_Category_Mapping__c = TestEEPCM.id;
            TestCPC.User__c = u.id;
            insert TestCPC;
            
            Customer_Product_Sub_Category__c TestCPSC = new Customer_Product_Sub_Category__c();
            TestCPSC.name = 'TestCPSCName';
            TestCPSC.Contact__c = con.id;
            TestCPSC.Customer_Product_Category__c = TestCPC.id;
            TestCPSC.Event_Edition__c = OEve.id;
            TestCPSC.Event_Edition_Sub_Category_Mapping__c = TestEESCM.id;
            insert TestCPSC;
            
            Test.startTest();
                String strJSON = DeleteCustomerProdCubCategory.deleteCustomerProdSubCategory(TestEESCM.id);
              String strJSON1 = DeleteCustomerProdCubCategory.deleteCustomerProdCatCategory(TestEEPCM.id);
                //System.assert(strJSON  != null, 'Checking JSON');
          Test.stopTest();
        }
    }
}