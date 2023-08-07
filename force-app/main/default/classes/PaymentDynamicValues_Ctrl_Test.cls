/**
 * Created/Modified By: Girikon(Pramod, Archit)
 * Created On:          8/24/2017
 * Description/Purpose: This test class covers the apex class : PaymentDynamicValues_Ctrl
 * Methods:             PaymentDynamicValues_Ctrl_DataInsert
 * Apex Class:          PaymentDynamicValues_Ctrl, InvoicePaymentCtr
**/

@isTest
public class PaymentDynamicValues_Ctrl_Test {
    public static testMethod void PaymentDynamicValues_Ctrl_DataInsert()
    {
        CyberSourceCredential__c testCS = new CyberSourceCredential__c();
        testCS.name = 'CyberSourceTest';
        testCS.Username__c = 'testUsername';
        testCS.Password__c = 'testPassword';
        testCS.Source__c = 'testSource';
        testCS.CardType__c = 'testCardType';
        testCS.Url__c ='www.google.com';
        insert testCS;
        blng__Invoice__c invoiceObj;
        
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
        oEve.CurrencyIsoCode = eventCurrency.Name;
        update OEve;
        System.assert(OEve.EventCurrency__c != null, 'Event Currency');
        
        Merchant_Account_Master__c testMAM = new Merchant_Account_Master__c();
        testMAM.Name = 'testName';
        testMAM.Event_Edition__c = OEve.id;
        testMAM.Merchant__c = 'VISA';
        testMAM.Currency__c = OEve.CurrencyIsoCode;
        insert testMAM;
        
        Customer_Center_Cart_Master__c testCCCM = new Customer_Center_Cart_Master__c();
        testCCCM.Event_Edition__c = OEve.id;
        testCCCM.CurrencyIsoCode = eventCurrency.Name;
        insert testCCCM;
         Account acc1 = new Account();
            acc1.Name='acc1';              
            insert acc1;
          opportunity opp = new opportunity(Name='World of Concrete 2017',EventEdition__c=OEve.id,AccountId = acc1.id,Paid_Amount__c=10.00,Amount=20.00,CloseDate=System.Today(),StageName='Needs Assessment',CurrencyIsoCode=OEve.EventCurrency__r.Name);
            insert opp;
            System.assert(opp != null, 'opportunity');
             Order o = new Order(name='Test1',AccountId=acc1.id,EffectiveDate=system.today(),status='draft', OpportunityId = opp.id);
            insert o;
           
        invoiceObj = new blng__Invoice__c(blng__Order__c =o.id,blng__InvoiceDate__c=Date.today(),blng__Account__c=acc1.id);
            insert invoiceObj;
            
        ApexPages.currentPage().getParameters().put('conId',con.Id);
        ApexPages.currentPage().getParameters().put('eventCode',OEve.Event_Code__c);
        ApexPages.currentPage().getParameters().put('mCartId',testCCCM.id);
        ApexPages.currentPage().getParameters().put('ids',invoiceObj.id);
        ApexPages.currentPage().getParameters().put('eventId',OEve.id);
        ApexPages.currentPage().getParameters().put('contactId',con.Id);
            
        Test.startTest();
        PaymentDynamicValues_Ctrl payD = new PaymentDynamicValues_Ctrl();
        payD.populateDynamicValues();
        payD.returnCountryIsoCode('India');
        InvoicePaymentCtr invPay = new InvoicePaymentCtr();
        invPay.populateDynamicValues();
        invPay.returnCountryIsoCode('India');
        Test.stopTest();
        
        
    }

}