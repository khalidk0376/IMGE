/**
 * Created/Modified By: Girikon(Archit)
 * Created On:          9/9/2017
 * Last Modified On:    8/26/2018
 * Last Modified By:    Amish
 * Description/Purpose: This test class covers the apex class : showProductCategory
 * Methods:             showProductCategoryDataInsert
 * Apex Class:          showProductCategory
**/

@isTest
public class ShowProductCategory_Test 
{
    public static testMethod void showProductCategoryDataInsert()
    {
        // Setup test data
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser11@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing11', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduserNapali1@testorg.com');
            insert u;
            Event_Edition__c oEve;
        System.runAs(u) 
        {
            Account acc1 = new Account();
            acc1.Name='acc1';              
            insert acc1;
            
            Contact con = new Contact(LastName='User',FirstName ='Test',AccountId=acc1.id);
            insert con;
            
            oEve = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today());
            insert oEve;
            System.assertEquals(oEve.Event_Code__c,'WOC17', 'Event Code');
            EventCurrecies__c eventCurrency = new EventCurrecies__c (Name='USD',Event_Edition__c=oEve.id);
            insert eventCurrency;
            System.assertEquals(eventCurrency.Name,'USD', 'Event Currency');
            oEve.EventCurrency__c = eventCurrency.id;
            update oEve;
            System.assert(oEve.EventCurrency__c != null, 'Event Currency');
            
            Levels_Master__c testPC1 = new Levels_Master__c();         
            testPC1.LevelValue__c = 'testPC1Name';
            testPC1.Level_Name__c='L1';
            insert testPC1;
            
            Levels_Master__c testPC2 = new Levels_Master__c();
            testPC2.Mapped_To_Level__c = testPC1.id;
            testPC2.Level_Name__c='L2';
            testPC2.LevelValue__c = 'testPC2Name';
            insert testPC2;
            
            Levels_Master__c testPC3 = new Levels_Master__c();
            testPC3.LevelValue__c = 'testPC3Name';
            testPC3.Mapped_To_Level__c = testPC2.id;
            testPC3.Level_Name__c = 'L3';
            insert testPC3;
            
            Event_Edition_Product_Category_Mapping__c testEEPCM = new Event_Edition_Product_Category_Mapping__c();
            testEEPCM.name = 'TsetName3';
            testEEPCM.Event_Edition__c = oEve.id;
            testEEPCM.Levels_Master__c = testPC3.id;
            insert testEEPCM;
            
            Event_Edition_Sub_Category_Mapping__c testEESCM = new Event_Edition_Sub_Category_Mapping__c();
            testEESCM.name = 'TestEESCMName';
            testEESCM.Event_Edition__c = oEve.id;
            testEESCM.Levels_Master__c = testPC3.id;
            testEESCM.Event_Edition_Product_Category_Mapping__c = testEEPCM.id;
            insert testEESCM;
                                  
            Customer_Product_Category__c testCPC = new Customer_Product_Category__c();
            testCPC.name = 'TestCPCName';
            testCPC.Account__c = acc1.id;
            testCPC.Event_Edition__c = oEve.id;
            testCPC.Event_Edition_Product_Category_Mapping__c = testEEPCM.id;
            testCPC.User__c = u.id;
            insert testCPC;
            
            Customer_Product_Sub_Category__c testCPSC = new Customer_Product_Sub_Category__c();
            testCPSC.name = 'TestCPSCName';
            testCPSC.Account__c = acc1.id;
            testCPSC.Customer_Product_Category__c = testCPC.id;
            testCPSC.Event_Edition__c = oEve.id;
            testCPSC.Event_Edition_Sub_Category_Mapping__c = testEESCM.id;
            insert testCPSC;
            
            ApexPages.currentPage().getParameters().put('eventId',oEve.id);
            ApexPages.currentPage().getParameters().put('conId',con.id);
            ApexPages.currentPage().getParameters().put('uId',u.id);
      
            ApexPages.currentPage().getParameters().put('label',testPC1.LevelValue__c);
            ApexPages.currentPage().getParameters().put('category',testPC2.LevelValue__c);
            ApexPages.currentPage().getParameters().put('eeId',testEEPCM.id);
      
            ApexPages.currentPage().getParameters().put('selectedCat',testPC2.id);
            ApexPages.currentPage().getParameters().put('notSelectedCat',testPC3.id);
            
            Test.startTest();
                showProductCategory.findCategories('test');
                showProductCategory obj = new showProductCategory();
                obj.populateL3();
                obj.saveCategories();
            
                Event_Edition_Product_Category_Mapping__c testEEPCM2 = new Event_Edition_Product_Category_Mapping__c();
                testEEPCM2.name = 'TsetName2';
                testEEPCM2.Event_Edition__c = oEve.id;
                testEEPCM2.Levels_Master__c = testPC2.id;
                insert testEEPCM2;
            
                obj.saveCategories();
            Test.stopTest();
            
        }
    }
}