/**
 * Created/Modified By: Girikon(Archit)
 * Created On:          9/21/2017
 * Description/Purpose: This test class covers the apex class : GenerateMainInvoicePDFCtrl
 * Methods:             GenerateInvoicePDF_DataInsert
 * Apex Class:          GenerateMainInvoicePDFCtrl
**/

@isTest
public class GenerateMainInvoicePDFCtrl_Test 
{
    public static testMethod void GenerateInvoicePDF_DataInsert()
    {
            // Setup test data
            // This code runs as the system user
            Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
            User u = new User(Alias = 'standt', Email='usergenmainind@testorg.com', 
              EmailEncodingKey='UTF-8', LastName='Testing11', LanguageLocaleKey='en_US', 
              LocaleSidKey='en_US', ProfileId = p.Id, 
              TimeZoneSidKey='America/Los_Angeles', UserName='usergenmainind@testorg.com');
            insert u;
            System.runAs(u){
            Account acc1 = new Account();
            acc1.Name='acc1';

            insert acc1;
            Contact con = new Contact();
            con.LastName = 'testLastName';
            con.FirstName = 'testFirstName';
            con.Email = 'test@gmail.com';
            con.Phone = '2012012012';
            con.AccountId =acc1.id;
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

            Product2 prd = new Product2(Name = 'Booth Package WOC',Family = 'Booth',Number_of_Corners__c = 0,Booth_Type__c='esc', Booth_Class__c='fsdf', Event_Edition_Pool__c = 'WOC', Event_Edition__c = OEve.Id);
            insert prd;
        
            Customer_Center_Cart_Master__c testCCCM = new Customer_Center_Cart_Master__c();
            testCCCM.Event_Edition__c = OEve.id;
            testCCCM.Is_checked_out__c = false;
            testCCCM.Final_Amount__c=100.00;            
            testCCCM.Total_Amount__c =100.00;
            testCCCM.Invoice_Tax__c = 10000;
            testCCCM.Total_Tax_Amount__c = 500;
            insert testCCCM;
            
            Customer_Center_Cart__c CCCart = new Customer_Center_Cart__c();
            CCCart.Customer_Center_Cart_Master__c = testCCCM.Id;
            CCCart.Event_Edition__c = OEve.id;
            CCCart.Contact__c = con.id;
            CCCart.Product__c = prd.id;
            CCCart.Tax_Rate__c = 30;
            CCCart.Rate__c = 100;
            CCCart.Price__c = 200;
            CCCart.Quantity__c = 1000;
            insert CCCart;

            System.assert(OEve.EventCurrency__c != null, 'Event Currency');
            opportunity opp = new opportunity(Name='World of Concrete 2017',EventEdition__c=OEve.id,AccountId = acc1.id,Paid_Amount__c=10.00,Amount=20.00,CloseDate=System.Today(),StageName='Needs Assessment',CurrencyIsoCode=OEve.EventCurrency__r.Name);
            insert opp;
            
            Order o = new Order(name='Test1',AccountId=acc1.id,EffectiveDate=system.today(),status='draft', OpportunityId = opp.id);
            insert o;
            blng__Invoice__c   invoiceObj = new blng__Invoice__c(blng__Order__c =o.id,blng__InvoiceDate__c=Date.today(),blng__Account__c=acc1.id);
            insert invoiceObj;
                
            opp.StageName='Closed Won';
            update opp;
            System.assert(opp.StageName =='Closed Won', 'StageName is Clsoed Won');
            ApexPages.currentPage().getParameters().put('mCartId',testCCCM.id);
            ApexPages.currentPage().getParameters().put('paymentType','Invoice');
            ApexPages.currentPage().getParameters().put('conId',con.id);
            ApexPages.currentPage().getParameters().put('uId',u.id);
            ApexPages.currentPage().getParameters().put('eventCode','WOC17');
            ApexPages.currentPage().getParameters().put('eventId',OEve.id);
            ApexPages.currentPage().getParameters().put('InvId',invoiceObj.id);
            ApexPages.currentPage().getParameters().put('isInvoice','true');
            ApexPages.currentPage().getParameters().put('isDisplay','true'); 
            ApexPages.currentPage().getParameters().put('isReceipt','true');
            ApexPages.currentPage().getParameters().put('checkInsert','true');
            ApexPages.currentPage().getParameters().put('transID','true');
    		ApexPages.currentPage().getParameters().put('refId','true');
            ApexPages.currentPage().getParameters().put('appAmount','2.0');
            Test.startTest();
            GenerateMainInvoicePDFCtrl obj = new GenerateMainInvoicePDFCtrl();
            obj.getOnlyInoviecData();
            obj.getReceiptInvoiceData();
            obj.getDisplayInvoiceData();
            
            obj.getMainData();
            Test.stopTest();
        }
    }
}