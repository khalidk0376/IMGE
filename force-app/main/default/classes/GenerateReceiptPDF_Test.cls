/**
 * Created/Modified By: Girikon(Archit)
 * Created On:          9/9/2017 
 * Description/Purpose: This test class covers the apex class : GenerateReceiptPDF 
 * Methods:             GenerateReceiptPDF_DataInsert
 * Apex Class:          GenerateReceiptPDF 
**/

@isTest
public class GenerateReceiptPDF_Test {
    public static testMethod void GenerateReceiptPDF_DataInsert()
    {
        // Setup test data
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='standardforyouser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing11', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standardforyouser@testorg.com');
        insert u;
        
        Contact con = new Contact();
        con.LastName = 'testLastName';
        con.FirstName = 'testFirstName';
       
        con.Email = 'test@gmail.com';
        con.Phone = '2012012012';
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
        
        Customer_Center_Cart_Master__c testCCCM = new Customer_Center_Cart_Master__c();
        testCCCM.Event_Edition__c = OEve.id;
        testCCCM.Is_checked_out__c = false;
        testCCCM.Final_Amount__c=200;
        insert testCCCM;
        
        Customer_Center_Cart__c testCCC = new Customer_Center_Cart__c();
        testCCC.name='testName';
        testCCC.Customer_Center_Cart_Master__c = testCCCM.id;
        testCCC.Event_Edition__c=OEve.id;
        testCCC.Quantity__c=4;
        insert testCCC;
        
        Customer_Transaction_Detail__c testCTD = new Customer_Transaction_Detail__c();
        //testCTD.name = 'TestName';
        testCTD.Customer_Center_Cart_Master__c = testCCCM.id;
        testCTD.CurrencyIsoCode = eventCurrency.Name;
        testCTD.Applied_Amount__c = 25.0;
        testCTD.Contact__c = con.id;
        testCTD.User__c = u.id;
        insert testCTD;
        
        ApexPages.currentPage().getParameters().put('mCartId',testCCCM.id);       
        ApexPages.currentPage().getParameters().put('transId',testCTD.id);
        ApexPages.currentPage().getParameters().put('refId','12121212');       
        ApexPages.currentPage().getParameters().put('ccNum','123654789321456');
        ApexPages.currentPage().getParameters().put('ccExp','12/12');
        ApexPages.currentPage().getParameters().put('appAmount','100');
        ApexPages.currentPage().getParameters().put('conId',con.id);
        
        Test.startTest();
            GenerateReceiptPDF obj = new GenerateReceiptPDF();
            obj.url = 'Event_Arab_Health_2017';
            obj.totalQuantity =0;
            obj.getData();
            //GenerateReceiptPDF.GenerateReceiptPDF();
        Test.stopTest();
    }
}