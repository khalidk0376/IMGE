/**
 * Created/Modified By: Girikon(Archit)
 * Created On:          8/24/2017 
 * Description/Purpose: This test class covers the apex class : PaymentConfirmation_Ctrl 
 * Methods:             PaymentConfirmation_Ctrl_DataInsert
 * Apex Class:          PaymentConfirmation_Ctrl, PaymentInvoiceConfirmationCtr
**/

@isTest
public class PaymentConfirmation_Ctrl_Test {
     public static testMethod void PaymentConfirmation_Ctrl_DataInsert()
    {
        // Setup test data
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser11@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing11', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduserkimalt1@testorg.com');
        insert u;
        System.runAs(u) 
        {    
            Contact con = new Contact();
            con.LastName = 'testLastName';
            con.FirstName = 'testFirstName';
            con.MailingStreet = 'testMailingStreet';
            con.MailingCity = 'testMailingCity';
            con.MailingCountry = 'USA';
            con.MailingState = 'Texas';
            con.MailingPostalCode = '201000';
            con.Email = 'test@gmail.com';
            con.Phone = '2012012012';
            insert con; 
            
             Integration_Service__c testCS = new Integration_Service__c();
            testCS.name = 'Cybersource';
            testCS.User_Name__c= 'testUsername';
            testCS.Password__c = 'testPassword';
            testCS.End_Point_Url__c= 'www.google.com';
            insert testCS;
            
            Event_Edition__c OEve = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today());
            insert OEve;
            System.assertEquals(OEve.Event_Code__c,'WOC17', 'Event Code');
            EventCurrecies__c eventCurrency = new EventCurrecies__c (Name='USD',Event_Edition__c=OEve.id);
            insert eventCurrency;
            System.assertEquals(eventCurrency.Name,'USD', 'Event Currency');
            OEve.EventCurrency__c = eventCurrency.id;
            oEve.CurrencyIsoCode = eventCurrency.Name;
            update OEve;
            System.assert(OEve.EventCurrency__c != null, 'Event Currency');
            
            Customer_Center_Cart_Master__c testCCCM = new Customer_Center_Cart_Master__c();
            testCCCM.Event_Edition__c = OEve.id;
            testCCCM.CurrencyIsoCode = eventCurrency.Name;
            insert testCCCM;
            
            Customer_Transaction_Detail__c testCTD = new Customer_Transaction_Detail__c();
            //testCTD.name = 'TestName';
            testCTD.Customer_Center_Cart_Master__c = testCCCM.id;
            testCTD.CurrencyIsoCode = eventCurrency.Name;
            testCTD.Applied_Amount__c = 25.0;
            testCTD.Contact__c = con.id;
            testCTD.User__c = u.id;
            insert testCTD;
            
            Email_Templates__c testET = new Email_Templates__c();
            testET.name = 'test email template';
            testET.Template_Code__c = 'ORDINV';
            testET.Content__c = 'testContent';
            testET.Subject__c = 'Test Template';
            testET.CurrencyIsoCode = eventCurrency.Name;
            insert testET;
            
            Event_Edition_Email_Template__c testEEET = new Event_Edition_Email_Template__c();
            testEEET.Event_Edition__c = OEve.id;
            testEEET.Subject__c = 'Test Template';
            testEEET.Email_Template__c = testET.id;
            testEEET.Email_Template_Code__c = 'ORDINV';
            testEEET.Content__c = 'test email template';
            insert testEEET;
             Account acc1 = new Account();
            acc1.Name='acc1';              
            insert acc1;
            opportunity opp = new opportunity(Name='World of Concrete 2017',EventEdition__c=OEve.id,AccountId = acc1.id,Paid_Amount__c=10.00,Amount=20.00,CloseDate=System.Today(),StageName='Needs Assessment',CurrencyIsoCode=OEve.EventCurrency__r.Name);
            insert opp;
            System.assert(opp != null, 'opportunity');
            Order o = new Order(name='Test1',AccountId=acc1.id,EffectiveDate=system.today(),status='draft', OpportunityId = opp.id);
            insert o;
           
            blng__Invoice__c invoiceObj = new blng__Invoice__c(blng__Order__c =o.id,blng__InvoiceDate__c=Date.today(),blng__Account__c=acc1.id);
            insert invoiceObj;
            
            CyberSource_Transaction_Log__c ctl = new CyberSource_Transaction_Log__c();
            ctl.Invoice__c = invoiceObj.Id;
            ctl.Customer_Center_Cart_Master__c =testCCCM.Id; 
            insert ctl;
            
            CyberSourceCredential__c oc = new CyberSourceCredential__c(); 
            oc.Name = 'CyberSourceTest';
            oc.CardType__c = 'VISA';
            oc.password__c = 'o5gXfifvSKndciK';
            oc.Source__c = 'GEGB157';
            oc.Url__c = 'https://paymentservicestest.informa.com';
            oc.Username__c = 'girikon';
            insert oc;
            
            ApexPages.currentPage().getParameters().put('id',testCCCM.Id);
            ApexPages.currentPage().getParameters().put('Eventcode',OEve.Event_Code__c);
            ApexPages.currentPage().getParameters().put('eventCode',OEve.Event_Code__c);
            ApexPages.currentPage().getParameters().put('InvoiceId',invoiceObj.Id);
            ApexPages.currentPage().getParameters().put('decision','ACCEPT');
            ApexPages.currentPage().getParameters().put('decision','NOT ACCEPT');
            ApexPages.currentPage().getParameters().put('req_card_expiry_date','01-2014');
            ApexPages.currentPage().getParameters().put('req_bill_to_forename','Test');
            ApexPages.currentPage().getParameters().put('contactId','Test');
            ApexPages.currentPage().getParameters().put('paymentType','Test');
            MAP<string, string> testMap = new MAP<string, string>();
            testMap.put('decision','ACCEPT');
            testMap.put('payment_token','0120120120');
            testMap.put('req_card_expiry_date','01-2014');
            testMap.put('id',testCCCM.id);
            testMap.put('req_bill_to_forename','testtempV');
            
            Test.startTest();
                PaymentConfirmation_Ctrl obj = new PaymentConfirmation_Ctrl();
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                obj.params = testMap;
                obj.autoRun();
                obj.sendPDFEmail(OEve.Event_Code__c,testCTD);
                obj.Chckvalues('decision');
                obj.call();
                obj.updateCyberSourceLog(testCCCM.Id,'Approved');
            
            
                PaymentInvoiceConfirmationCtr obj1 = new PaymentInvoiceConfirmationCtr();
                obj1.htmlThankyou ='';
                obj1.isShowButton = false;
                obj1.attachmentId = '';
                obj1.paidAmount = 2.0;
                obj1.showPaymentErrorMsg =false;
                obj1.paymentSuccess =false;
                obj1.params = testMap;
                obj1.autoRun();
                obj1.sendPDFEmail(OEve.Event_Code__c,con.Id);
                obj1.Chckvalues('decision');
                obj1.updateCyberSourceLog(invoiceObj.Id,'Approved');
                obj1.Chckvalues('decision');
                obj1.autoRun();
            Test.stopTest();
        }
        
    }

}