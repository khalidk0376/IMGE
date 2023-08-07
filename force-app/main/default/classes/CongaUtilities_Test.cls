/**
 * Project:         GAP
 * Date:            2/20/2017
 * Created By:      Abdul Kadir
 * Test Class For:  CongaUtilities.cls
 * Code Coverage:   87%
 * *************************************************************************
 * @description  CongaUtilities class
 * *************************************************************************
 * History:
 */
//Ticket No. BK-14521 Updating API Version 
@isTest
public class CongaUtilities_Test {
    static testmethod void billingAddressCheck() {
        Account acc = new Account();
        acc.name = 'TestAccount';
        acc.BillingStreet = '456 Zepplin Avenue';
        acc.BillingCity = 'Las Vegas';
        acc.BillingState = 'Delhi';
        acc.BillingPostalCode = '110025';
        acc.BillingCountry = 'India';
        acc.Phone = '1234567890';
        acc.Fax = '1234567890';
        insert acc;
        System.assertEquals('TestAccount', acc.name, 'Error');


        Contact con = new Contact();
        con.Email = 'test.test@gmail.com';
        con.Phone = '1234567890';
        con.MobilePhone='1234567891';
        con.Title = 'Mr.';
        con.FirstName = 'TestFN';
        con.LastName = 'testLN';
        con.AccountId = acc.Id;
        con.MailingStreet = 'TestStreet';
        con.MailingCity = 'Las Vegas';
        con.MailingPostalCode = '89131';
        con.MailingState = 'Delhi';
        con.MailingCountry = 'India';
        con.Fax = '1234567890';
        insert con;

        Contact con1 = new Contact();
        con1.Email = 'test2.test@gmail.com';
        con1.Phone = '1234567890';
        con1.MobilePhone='1234567891';
        con1.Title = 'Mr.';
        con1.FirstName = 'TestFN2';
        con1.LastName = 'testLN2';
        con1.AccountId = acc.Id;
        con1.MailingStreet = 'TestStreet';
        con1.MailingState = 'Delhi';
        con1.MailingCountry = 'India';
        con1.Fax = '1234567890';
        insert con1;

        CongaUtilities.isBillingAddressNull(con.Id);
        CongaUtilities.isBillingAddressNull(con1.Id);
        
    }
    static testmethod void testForNationalTemplate() {
        Pricebook2 pb = new Pricebook2(Name = 'TestPricebook');
        insert pb;
        Event_Edition__c ee = new Event_Edition__c();
        ee.Name = 'TestEvent';
        ee.Tab1__c = 'tab1';
        ee.Tab4__c = 'tab4';
        ee.Tab7__c = 'tab7';
        ee.Tab8__c = 'Tab8__c';
        // sudip edit
        ee.Payment_Schedule__c  = '25-25-25-25';
        ee.X50_Cutoff_Date__c = date.today();
        ee.Cutoff_Date_1__c = date.today().addDays(1);
        ee.Cutoff_Date_2__c = date.today().addDays(2);
        ee.Cutoff_Date_3__c = date.today().addDays(3);
        ee.Event_Price_Book__c = pb.Id;
        insert ee;
        
         Product2 prodObj = new Product2(Name = 'testProd', validated_in_sap__c=true);
        insert prodObj;
        
        SBQQ__Localization__c localObj= new SBQQ__Localization__c(SBQQ__Product__c=prodObj.id,SBQQ__Text__c='testvalue',SBQQ__APIName__c ='Name',SBQQ__Language__c='pt_BR');
        insert localObj;
        
        List < Country_locales__c > cl = new List < Country_locales__c > ();
        cl.add(new Country_locales__c(Name = 'Brasil', locale__c = 'pt-BR'));
        cl.add(new Country_locales__c(Name = 'USA', locale__c = 'en-US'));
        insert cl;

        APXTConga4__Conga_Template__c ct = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'test');
        insert ct;

        National_Contract_Template__c nct = new National_Contract_Template__c();
        nct.Event_Edition__c = ee.Id;
        nct.Conga_Template__c = ct.Id;
        nct.Term_Conditions__c = ct.Id;
        insert nct;

        Account acct = new Account(Name = 'testAccount', CurrencyIsoCode = 'EUR');
        insert acct;
        System.assertEquals('testAccount', acct.name,'Error');
        
        Contact ocontact = new Contact();
        ocontact.Email = 'test.test@gmail.com';
        ocontact.Phone = '1234567890';
        ocontact.FirstName = 'TestFN';
        ocontact.LastName = 'testLN';
        ocontact.AccountId = acct.Id;
        ocontact.MailingStreet = 'TestStreet';
        ocontact.MailingCity = 'Delhi';
        ocontact.MailingPostalCode = '110025';
        ocontact.MailingState = 'Delhi';
        ocontact.MailingCountry = 'India';
        ocontact.Fax = '1234567890';
        ocontact.Address_Verified__c = false;
        insert ocontact;
        Opportunity oppty = new Opportunity(Name = 'testOpp', EventEdition__c = ee.Id);
        oppty.AccountId = acct.Id;
        oppty.StageName = 'Discover';
        oppty.CloseDate = date.today();
        oppty.custom_Payment__c=false;
        insert oppty;

        SBQQ__Quote__c qtObj = new SBQQ__Quote__c();
        qtObj.SBQQ__Account__c = acct.Id;
        qtObj.SBQQ__Status__c = 'Draft';
        qtObj.SBQQ__Type__c = 'Quote';
        qtObj.SBQQ__StartDate__c = date.today();
        qtObj.Alternate_Currency2__c = 'EUR';
        qtObj.SBQQ__Opportunity2__c = oppty.Id;
        qtObj.Billing_Contact__c = ocontact.Id;
        qtObj.CurrencyIsoCode='BRL';
        insert qtObj;
        
       
        
        SBQQ__QuoteLine__c qlObj = new SBQQ__QuoteLine__c();
        qlObj.SBQQ__Quote__c = qtObj.Id;
        qlObj.SBQQ__Product__c = prodObj.Id;
        qlObj.Product_Local_Name__c='';
        insert qlObj;
        
        Test.startTest();
        Map<Id,SBQQ__QuoteLine__c> prodIdQuoteLineMap =new Map<Id,SBQQ__QuoteLine__c> ();
        prodIdQuoteLineMap.put(qlObj.SBQQ__Product__c, qlObj);
        
        CongaUtilities temp = new CongaUtilities();
        temp.cutoffDates(qtObj.Id,oppty.custom_Payment__c);
        temp.CountryLocale('Brasil');
        temp.CurrencyFormat(25.0);
        temp.getProductLocalName(prodIdQuoteLineMap);
        //oppty.Is_Barter_Opportunity__c=true;
       // update oppty;
        temp.cutoffDates(qtObj.Id,oppty.custom_Payment__c);
        DeliveryDateUtilities deliveryObj = new DeliveryDateUtilities();
        deliveryObj.deliveryDates(qtObj.Id,oppty.custom_Payment__c);
         Test.stopTest();
    }
     static testmethod void testForcustomPayment() {
        Pricebook2 pb = new Pricebook2(Name = 'TestPricebook');
        insert pb;
        Event_Edition__c ee = new Event_Edition__c();
        ee.Name = 'TestEvent';
        ee.Tab1__c = 'tab1';
        ee.Tab4__c = 'tab4';
        ee.Tab7__c = 'tab7';
        ee.Tab8__c = 'Tab8__c';
        ee.Payment_Schedule__c = '25-25-25-25';
        ee.X50_Cutoff_Date__c = date.today();
        ee.Cutoff_Date_1__c = date.today().addDays(1);
        ee.Cutoff_Date_2__c = date.today().addDays(2);
        ee.Cutoff_Date_3__c = date.today().addDays(3);
        ee.Event_Price_Book__c = pb.Id;
        ee.Invoice_to_be_issued_before__c = 1;
        insert ee;
         blng__LegalEntity__c legalentity = new blng__LegalEntity__c(Name = 'Test LegalEntity' , blng__Active__c = true ,blng__Country__c = 'USA', Legal_Entity_Code__c = 'AE006');
        insert legalentity;
        
        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', Package_Identifier__c = 'WOC', Event_Edition_Pool__c = 'WOC', Active_VAT_Tax_Alt_Currency__c = True, VAT_Tax_Alt_Currency__c = 'ZAR' , Legal_Entity__c = legalentity.id);
        insert oEventseries;
       
        Product2 prodObj = new Product2(Name = 'testProd', validated_in_sap__c=true);
        insert prodObj;
        
        SBQQ__Localization__c localObj= new SBQQ__Localization__c(SBQQ__Product__c=prodObj.id,SBQQ__Text__c='testvalue',SBQQ__APIName__c ='Name',SBQQ__Language__c='pt_BR');
        insert localObj;
        
        List < Country_locales__c > cl = new List < Country_locales__c > ();
        cl.add(new Country_locales__c(Name = 'Brasil', locale__c = 'pt-BR'));
        cl.add(new Country_locales__c(Name = 'USA', locale__c = 'en-US'));
        insert cl;

        APXTConga4__Conga_Template__c ct = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'test');
        insert ct;

        National_Contract_Template__c nct = new National_Contract_Template__c();
        nct.Event_Edition__c = ee.Id;
        nct.Conga_Template__c = ct.Id;
        nct.Term_Conditions__c = ct.Id;
        insert nct;

        Account acct = new Account(Name = 'testAccount', CurrencyIsoCode = 'EUR');
        insert acct;
        System.assertEquals('testAccount', acct.name,'Error');
        
        Contact ocontact = new Contact();
        ocontact.Email = 'test.test@gmail.com';
        ocontact.Phone = '1234567890';
        ocontact.MobilePhone='1234567891';
        ocontact.FirstName = 'TestFN';
        ocontact.LastName = 'testLN';
        ocontact.AccountId = acct.Id;
        ocontact.MailingStreet = 'TestStreet';
        ocontact.MailingCity = 'Delhi';
        ocontact.MailingPostalCode = '110025';
        ocontact.MailingState = 'Delhi';
        ocontact.MailingCountry = 'India';
        ocontact.Fax = '1234567890';
        ocontact.Address_Verified__c = false;
        insert ocontact;

        Opportunity oppty = new Opportunity(Name = 'testOpp', EventEdition__c = ee.Id);
        oppty.AccountId = acct.Id;
        oppty.StageName = 'Discover';
        oppty.CloseDate = date.today();
        oppty.Opportunity_Contact__c=ocontact.Id;
        oppty.custom_Payment__c=true;
         oppty.Event_Series__c = oEventseries.Id;
        oppty.Milestone_1_Delivery_Date__c=System.today();
        oppty.Milestone_2_Delivery_Date__c=System.today().addDays(30);
        oppty.Milestone_3_Delivery_Date__c=System.today().addDays(60);
        oppty.Milestone_4_Delivery_Date__c=System.today().addDays(90);
        oppty.Milestone_5_Delivery_Date__c=System.today().addDays(120);
        oppty.Milestone_6_Delivery_Date__c=System.today().addDays(150);
        oppty.Milestone_7_Delivery_Date__c=System.today().addDays(180);
        oppty.Milestone_8_Delivery_Date__c=System.today().addDays(210);
        oppty.Milestone_9_Delivery_Date__c=System.today().addDays(240);
        oppty.Milestone_10_Delivery_Date__c=System.today().addDays(270);
        oppty.Milestone_11_Delivery_Date__c=System.today().addDays(300);
        oppty.Milestone_12_Delivery_Date__c=System.today().addDays(330);
        oppty.Milestone_1_Amount__c = 200.00;
        oppty.Milestone_2_Amount__c = 200.00;
        oppty.Milestone_3_Amount__c = 200.00;
        oppty.Milestone_4_Amount__c = 200.00;
        oppty.Milestone_5_Amount__c = 200.00;
        oppty.Milestone_6_Amount__c = 200.00;
        oppty.Milestone_7_Amount__c = 200.00;
        oppty.Milestone_8_Amount__c = 200.00;
        oppty.Milestone_9_Amount__c = 200.00;
        oppty.Milestone_10_Amount__c = 200.00;
        oppty.Milestone_11_Amount__c = 200.00;
        oppty.Milestone_12_Amount__c = 200.00;
        oppty.Milestone_1_Percent__c = 8.2; oppty.Milestone_2_Percent__c = 8.3; oppty.Milestone_3_Percent__c = 8.2;
        oppty.Milestone_4_Percent__c = 8.2; oppty.Milestone_5_Percent__c = 8.3; oppty.Milestone_6_Percent__c = 8.3;
        oppty.Milestone_7_Percent__c = 8.2; oppty.Milestone_8_Percent__c = 8.3; oppty.Milestone_9_Percent__c = 8.3;
        oppty.Milestone_10_Percent__c = 8.2; oppty.Milestone_11_Percent__c = 8.3; oppty.Milestone_12_Percent__c = 8.3;
        insert oppty;

        SBQQ__Quote__c qtObj = new SBQQ__Quote__c();
        qtObj.SBQQ__Account__c = acct.Id;
        qtObj.SBQQ__Status__c = 'Draft';
        qtObj.SBQQ__Type__c = 'Quote';
        qtObj.SBQQ__StartDate__c = date.today();
        qtObj.Alternate_Currency2__c = 'EUR';
        qtObj.SBQQ__Opportunity2__c = oppty.Id;
        qtObj.Billing_Contact__c = ocontact.Id;
        qtObj.CurrencyIsoCode='BRL';
         
        insert qtObj;
         
        
        SBQQ__QuoteLine__c qlObj = new SBQQ__QuoteLine__c();
        qlObj.SBQQ__Quote__c = qtObj.Id;
        qlObj.SBQQ__Product__c = prodObj.Id;
        qlObj.Product_Local_Name__c='';
        qlObj.SBQQ__NetPrice__c =5000.00;
         
        //qlObj.SBQQ__EffectiveQuantity__c=5;
        insert qlObj;
        
        Test.startTest();
        Map<Id,SBQQ__QuoteLine__c> prodIdQuoteLineMap =new Map<Id,SBQQ__QuoteLine__c> ();
        prodIdQuoteLineMap.put(qlObj.SBQQ__Product__c, qlObj);
        
        CongaUtilities temp = new CongaUtilities();
        temp.cutoffDates(qtObj.Id,oppty.custom_Payment__c);
        temp.CountryLocale('Brasil');
        temp.CurrencyFormat(25.0);
        temp.getProductLocalName(prodIdQuoteLineMap);
        DeliveryDateUtilities deliveryObj = new DeliveryDateUtilities();
         deliveryObj.customPayments(qtObj.Id);
        deliveryObj.deliveryDates(qtObj.Id,oppty.custom_Payment__c);
         Test.stopTest();
    }
    static testmethod void testForcustomPayment1() {
        Pricebook2 pb = new Pricebook2(Name = 'TestPricebook');
        insert pb;
        Event_Edition__c ee = new Event_Edition__c();
        ee.Name = 'TestEvent';
        ee.Tab1__c = 'tab1';
        ee.Tab4__c = 'tab4';
        ee.Tab7__c = 'tab7';
        ee.Tab8__c = 'Tab8__c';
        ee.Payment_Schedule__c = '25-25-25-25';
        ee.X50_Cutoff_Date__c = date.today();
        ee.Cutoff_Date_1__c = date.today().addDays(1);
        ee.Cutoff_Date_2__c = date.today().addDays(2);
        ee.Cutoff_Date_3__c = date.today().addDays(3);
        ee.Event_Price_Book__c = pb.Id;
        insert ee;
         blng__LegalEntity__c legalentity = new blng__LegalEntity__c(Name = 'Test LegalEntity' , blng__Active__c = true ,blng__Country__c = 'USA', Legal_Entity_Code__c = 'AE006');
        insert legalentity;
        
        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', Package_Identifier__c = 'WOC', Event_Edition_Pool__c = 'WOC', Active_VAT_Tax_Alt_Currency__c = True, VAT_Tax_Alt_Currency__c = 'ZAR' , Legal_Entity__c = legalentity.id);
        insert oEventseries;
       
        Product2 prodObj = new Product2(Name = 'testProd', validated_in_sap__c=true);
        insert prodObj;
        
        SBQQ__Localization__c localObj= new SBQQ__Localization__c(SBQQ__Product__c=prodObj.id,SBQQ__Text__c='testvalue',SBQQ__APIName__c ='Name',SBQQ__Language__c='pt_BR');
        insert localObj;
        
        List < Country_locales__c > cl = new List < Country_locales__c > ();
        cl.add(new Country_locales__c(Name = 'Brasil', locale__c = 'pt-BR'));
        cl.add(new Country_locales__c(Name = 'USA', locale__c = 'en-US'));
        insert cl;

        APXTConga4__Conga_Template__c ct = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'test');
        insert ct;

        National_Contract_Template__c nct = new National_Contract_Template__c();
        nct.Event_Edition__c = ee.Id;
        nct.Conga_Template__c = ct.Id;
        nct.Term_Conditions__c = ct.Id;
        insert nct;

        Account acct = new Account(Name = 'testAccount', CurrencyIsoCode = 'EUR');
        insert acct;
        System.assertEquals('testAccount', acct.name,'Error');
        
        Contact ocontact = new Contact();
        ocontact.Email = 'test.test@gmail.com';
        ocontact.Phone = '1234567890';
        ocontact.MobilePhone='1234567891';
        ocontact.FirstName = 'TestFN';
        ocontact.LastName = 'testLN';
        ocontact.AccountId = acct.Id;
        ocontact.MailingStreet = 'TestStreet';
        ocontact.MailingCity = 'Delhi';
        ocontact.MailingPostalCode = '110025';
        ocontact.MailingState = 'Delhi';
        ocontact.MailingCountry = 'India';
        ocontact.Fax = '1234567890';
        ocontact.Address_Verified__c = false;
        insert ocontact;

        Opportunity oppty = new Opportunity(Name = 'testOpp', EventEdition__c = ee.Id);
        oppty.AccountId = acct.Id;
        oppty.StageName = 'Discover';
        oppty.CloseDate = date.today();
        oppty.Opportunity_Contact__c=ocontact.Id;
        oppty.custom_Payment__c=true;
         oppty.Event_Series__c = oEventseries.Id;
        oppty.Milestone_1_Delivery_Date__c=System.today();
        oppty.Milestone_2_Delivery_Date__c=System.today().addDays(30);
        oppty.Milestone_3_Delivery_Date__c=System.today().addDays(60);
        oppty.Milestone_4_Delivery_Date__c=System.today().addDays(90);
        oppty.Milestone_5_Delivery_Date__c=System.today().addDays(120);
        oppty.Milestone_6_Delivery_Date__c=System.today().addDays(150);
        oppty.Milestone_7_Delivery_Date__c=System.today().addDays(180);
        oppty.Milestone_8_Delivery_Date__c=System.today().addDays(210);
        oppty.Milestone_9_Delivery_Date__c=System.today().addDays(240);
        oppty.Milestone_10_Delivery_Date__c=System.today().addDays(270);
        oppty.Milestone_11_Delivery_Date__c=System.today().addDays(300);
        oppty.Milestone_12_Delivery_Date__c=System.today().addDays(330);
        oppty.Milestone_1_Amount__c = 00.00;
        oppty.Milestone_2_Amount__c = 200.00;
        oppty.Milestone_3_Amount__c = 200.00;
        oppty.Milestone_4_Amount__c = 200.00;
        oppty.Milestone_5_Amount__c = 200.00;
        oppty.Milestone_6_Amount__c = 200.00;
        oppty.Milestone_7_Amount__c = 200.00;
        oppty.Milestone_8_Amount__c = 200.00;
        oppty.Milestone_9_Amount__c = 200.00;
        oppty.Milestone_10_Amount__c = 200.00;
        oppty.Milestone_11_Amount__c = 200.00;
        oppty.Milestone_12_Amount__c = 200.00;
        oppty.Milestone_1_Percent__c = 8.2; oppty.Milestone_2_Percent__c = 8.3; oppty.Milestone_3_Percent__c = 8.2;
        oppty.Milestone_4_Percent__c = 8.2; oppty.Milestone_5_Percent__c = 8.3; oppty.Milestone_6_Percent__c = 8.3;
        oppty.Milestone_7_Percent__c = 8.2; oppty.Milestone_8_Percent__c = 8.3; oppty.Milestone_9_Percent__c = 8.3;
        oppty.Milestone_10_Percent__c = 8.2; oppty.Milestone_11_Percent__c = 8.3; oppty.Milestone_12_Percent__c = 8.3;
        oppty.Total_No_of_payment__c = 11;
        insert oppty;

        SBQQ__Quote__c qtObj = new SBQQ__Quote__c();
        qtObj.SBQQ__Account__c = acct.Id;
        qtObj.SBQQ__Status__c = 'Draft';
        qtObj.SBQQ__Type__c = 'Quote';
        qtObj.SBQQ__StartDate__c = date.today();
        qtObj.Alternate_Currency2__c = 'EUR';
        qtObj.SBQQ__Opportunity2__c = oppty.Id;
        qtObj.Billing_Contact__c = ocontact.Id;
        qtObj.CurrencyIsoCode='BRL';
         
        insert qtObj;
         
        
        SBQQ__QuoteLine__c qlObj = new SBQQ__QuoteLine__c();
        qlObj.SBQQ__Quote__c = qtObj.Id;
        qlObj.SBQQ__Product__c = prodObj.Id;
        qlObj.Product_Local_Name__c='';
        qlObj.SBQQ__NetPrice__c =5000.00;
         
        //qlObj.SBQQ__EffectiveQuantity__c=5;
        insert qlObj;
        
        Test.startTest();
        Map<Id,SBQQ__QuoteLine__c> prodIdQuoteLineMap =new Map<Id,SBQQ__QuoteLine__c> ();
        prodIdQuoteLineMap.put(qlObj.SBQQ__Product__c, qlObj);
        
        CongaUtilities temp = new CongaUtilities();
        temp.cutoffDates(qtObj.Id,oppty.custom_Payment__c);
        temp.CountryLocale('Brasil');
        temp.CurrencyFormat(25.0);
        temp.getProductLocalName(prodIdQuoteLineMap);
        DeliveryDateUtilities deliveryObj = new DeliveryDateUtilities();
         deliveryObj.customPayments(qtObj.Id);
         Test.stopTest();
    }
    static testmethod void testForcustomPaymentImmediatePaymentNull() {
        Pricebook2 pb = new Pricebook2(Name = 'TestPricebook');
        insert pb;
        Event_Series__c es=new Event_Series__c(Name='Test');
        es.Local_Country__c='Brasil';
        es.Company_Country__c='United Kingdom';
        insert es;
        
        Event_Edition__c ee = new Event_Edition__c();
        ee.Name = 'TestEvent';
        ee.Tab1__c = 'tab1';
        ee.Tab4__c = 'tab4';
        ee.Tab7__c = 'tab7';
        ee.Tab8__c = 'Tab8__c';
        ee.Part_of_Series__c=es.Id;
        ee.X50_Cutoff_Date__c = date.today();
        ee.Event_Price_Book__c = pb.Id;
        insert ee;
        
         Product2 prodObj = new Product2(Name = 'testProd', validated_in_sap__c=true);
        insert prodObj;
        
        SBQQ__Localization__c localObj= new SBQQ__Localization__c(SBQQ__Product__c=prodObj.id,SBQQ__Text__c='testvalue',SBQQ__APIName__c ='Name',SBQQ__Language__c='pt_BR');
        insert localObj;
        
        List < Country_locales__c > cl = new List < Country_locales__c > ();
        cl.add(new Country_locales__c(Name = 'Brasil', locale__c = 'pt-BR'));
        cl.add(new Country_locales__c(Name = 'USA', locale__c = 'en-US'));
        insert cl;

        APXTConga4__Conga_Template__c ct = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'test');
        insert ct;

        National_Contract_Template__c nct = new National_Contract_Template__c();
        nct.Event_Edition__c = ee.Id;
        nct.Conga_Template__c = ct.Id;
        nct.Term_Conditions__c = ct.Id;
        insert nct;

        Account acct = new Account(Name = 'testAccount', CurrencyIsoCode = 'EUR');
        insert acct;
        System.assertEquals('testAccount', acct.name,'Error');
        
        Contact ocontact = new Contact();
        ocontact.Email = 'test.test@gmail.com';
        ocontact.Phone = '1234567890';
        ocontact.MobilePhone='1234567891';
        ocontact.FirstName = 'TestFN';
        ocontact.LastName = 'testLN';
        ocontact.AccountId = acct.Id;
        ocontact.MailingStreet = 'TestStreet';
        ocontact.MailingCity = 'Delhi';
        ocontact.MailingPostalCode = '110025';
        ocontact.MailingState = 'Delhi';
        ocontact.MailingCountry = 'India';
        ocontact.Fax = '1234567890';
        ocontact.Address_Verified__c = false;
        insert ocontact;

        Opportunity oppty = new Opportunity(Name = 'testOpp', EventEdition__c = ee.Id);
        oppty.AccountId = acct.Id;
        oppty.StageName = 'Discover';
        oppty.CloseDate = date.today();
        oppty.Opportunity_Contact__c=ocontact.Id;
        oppty.custom_Payment__c=true;
        oppty.Milestone_1_Delivery_Date__c=System.today().addDays(41);
        oppty.Milestone_2_Delivery_Date__c=System.today().addDays(45);
        oppty.Milestone_3_Delivery_Date__c=System.today().addDays(60);
        oppty.Milestone_4_Delivery_Date__c=System.today().addDays(90);
        oppty.Milestone_5_Delivery_Date__c=System.today().addDays(120);
        oppty.Milestone_6_Delivery_Date__c=System.today().addDays(150);
        oppty.Milestone_7_Delivery_Date__c=System.today().addDays(180);
        oppty.Milestone_8_Delivery_Date__c=System.today().addDays(210);
        oppty.Milestone_9_Delivery_Date__c=System.today().addDays(240);
        oppty.Milestone_10_Delivery_Date__c=System.today().addDays(270);
        oppty.Milestone_11_Delivery_Date__c=System.today().addDays(300);
        oppty.Milestone_12_Delivery_Date__c=System.today().addDays(330);
        oppty.Milestone_1_Amount__c = 200.00;
        oppty.Milestone_2_Amount__c = 200.00;
        oppty.Milestone_3_Amount__c = 200.00;
        oppty.Milestone_4_Amount__c = 200.00;
        oppty.Milestone_5_Amount__c = 200.00;
        oppty.Milestone_6_Amount__c = 200.00;
        oppty.Milestone_7_Amount__c = 200.00;
        oppty.Milestone_8_Amount__c = 200.00;
        oppty.Milestone_9_Amount__c = 200.00;
        oppty.Milestone_10_Amount__c = 200.00;
        oppty.Milestone_11_Amount__c = 200.00;
        oppty.Milestone_12_Amount__c = 200.00;
        oppty.Milestone_1_Percent__c = 8.2; oppty.Milestone_2_Percent__c = 8.3; oppty.Milestone_3_Percent__c = 8.2;
        oppty.Milestone_4_Percent__c = 8.2; oppty.Milestone_5_Percent__c = 8.3; oppty.Milestone_6_Percent__c = 8.3;
        oppty.Milestone_7_Percent__c = 8.2; oppty.Milestone_8_Percent__c = 8.3; oppty.Milestone_9_Percent__c = 8.3;
        oppty.Milestone_10_Percent__c = 8.2; oppty.Milestone_11_Percent__c = 8.3; oppty.Milestone_12_Percent__c = 8.3;
        oppty.Total_No_of_payment__c = 12;
        insert oppty;

        SBQQ__Quote__c qtObj = new SBQQ__Quote__c();
        qtObj.SBQQ__Account__c = acct.Id;
        qtObj.SBQQ__Status__c = 'Draft';
        qtObj.SBQQ__Type__c = 'Quote';
        qtObj.SBQQ__StartDate__c = date.today();
        qtObj.Alternate_Currency2__c = 'EUR';
        qtObj.SBQQ__Opportunity2__c = oppty.Id;
        qtObj.Billing_Contact__c = ocontact.Id;
        qtObj.CurrencyIsoCode='BRL';
        insert qtObj;
        
        SBQQ__QuoteLine__c qlObj = new SBQQ__QuoteLine__c();
        qlObj.SBQQ__Quote__c = qtObj.Id;
        qlObj.SBQQ__Product__c = prodObj.Id;
        qlObj.Product_Local_Name__c='';
        qlObj.SBQQ__NetPrice__c =5000.00;
        insert qlObj;
        
        Test.startTest();
        Map<Id,SBQQ__QuoteLine__c> prodIdQuoteLineMap =new Map<Id,SBQQ__QuoteLine__c> ();
        prodIdQuoteLineMap.put(qlObj.SBQQ__Product__c, qlObj);
        
        CongaUtilities temp = new CongaUtilities();
        temp.cutoffDates(qtObj.Id,oppty.custom_Payment__c);
        DeliveryDateUtilities deliveryObj = new DeliveryDateUtilities();
        //deliveryObj.deliveryDates(qtObj.Id,oppty.custom_Payment__c);
        // oppty.Is_Barter_Opportunity__c=true;
        update oppty;
        //  deliveryObj.deliveryDates(qtObj.Id,oppty.custom_Payment__c);
        Test.stopTest();
    }
    
     static testmethod void testForNegativeCases() {
        Pricebook2 pb = new Pricebook2(Name = 'TestPricebook');
        insert pb;
        Event_Edition__c ee = new Event_Edition__c();
        ee.Name = 'TestEvent';
        ee.Tab1__c = 'tab1';
        ee.Tab4__c = 'tab4';
        ee.Tab7__c = 'tab7';
        ee.Tab8__c = 'Tab8__c';
        // sudip edit
        ee.Payment_Schedule__c  = '25-25-25-25';
        ee.X50_Cutoff_Date__c = date.today();
        ee.Cutoff_Date_1__c = date.today().addDays(1);
        ee.Cutoff_Date_2__c = date.today().addDays(2);
        ee.Cutoff_Date_3__c = date.today().addDays(3);
        ee.Event_Price_Book__c = pb.Id;
        insert ee;
        
         Product2 prodObj = new Product2(Name = 'testProd', validated_in_sap__c=true);
        insert prodObj;
        
        SBQQ__Localization__c localObj= new SBQQ__Localization__c(SBQQ__Product__c=prodObj.id,SBQQ__Text__c='testvalue',SBQQ__APIName__c ='Name',SBQQ__Language__c='pt_BR');
        insert localObj;
        
        List < Country_locales__c > cl = new List < Country_locales__c > ();
        cl.add(new Country_locales__c(Name = 'Brasil', locale__c = 'pt-BR'));
        cl.add(new Country_locales__c(Name = 'USA', locale__c = 'en-US'));
        insert cl;

        APXTConga4__Conga_Template__c ct = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'test');
        insert ct;

        National_Contract_Template__c nct = new National_Contract_Template__c();
        nct.Event_Edition__c = ee.Id;
        nct.Conga_Template__c = ct.Id;
        nct.Term_Conditions__c = ct.Id;
        insert nct;

        Account acct = new Account(Name = 'testAccount', CurrencyIsoCode = 'EUR');
        insert acct;
        System.assertEquals('testAccount', acct.name,'Error');
        
        Contact ocontact = new Contact();
        ocontact.Email = 'test.test@gmail.com';
        ocontact.Phone = '1234567890';
        ocontact.FirstName = 'TestFN';
        ocontact.LastName = 'testLN';
        ocontact.AccountId = acct.Id;
        ocontact.MailingStreet = 'TestStreet';
        ocontact.MailingCity = 'Delhi';
        ocontact.MailingPostalCode = '110025';
        ocontact.MailingState = 'Delhi';
        ocontact.MailingCountry = 'India';
        ocontact.Fax = '1234567890';
        ocontact.Address_Verified__c = false;
        insert ocontact;
        Opportunity oppty = new Opportunity(Name = 'testOpp', EventEdition__c = ee.Id);
        oppty.AccountId = acct.Id;
        oppty.StageName = 'Discover';
        oppty.CloseDate = date.today();
        oppty.custom_Payment__c=false;
        oppty.Is_Barter_Opportunity__c = false;
        insert oppty;

        SBQQ__Quote__c qtObj = new SBQQ__Quote__c();
        qtObj.SBQQ__Account__c = acct.Id;
        qtObj.SBQQ__Status__c = 'Draft';
        qtObj.SBQQ__Type__c = 'Quote';
        qtObj.SBQQ__StartDate__c = date.today();
        qtObj.Alternate_Currency2__c = 'EUR';
        qtObj.SBQQ__Opportunity2__c = oppty.Id;
        qtObj.Billing_Contact__c = ocontact.Id;
        qtObj.CurrencyIsoCode='BRL';
        insert qtObj;
        
       
        
        SBQQ__QuoteLine__c qlObj = new SBQQ__QuoteLine__c();
        qlObj.SBQQ__Quote__c = qtObj.Id;
        qlObj.SBQQ__Product__c = prodObj.Id;
        qlObj.Product_Local_Name__c='';
        insert qlObj;
        
        Test.startTest();
        Map<Id,SBQQ__QuoteLine__c> prodIdQuoteLineMap =new Map<Id,SBQQ__QuoteLine__c> ();
        prodIdQuoteLineMap.put(qlObj.SBQQ__Product__c, qlObj);
        
        CongaUtilities temp = new CongaUtilities();
        temp.cutoffDates(qtObj.Id,oppty.custom_Payment__c);
        temp.CountryLocale('Brasil');
        temp.CurrencyFormat(25.0);
        temp.getProductLocalName(prodIdQuoteLineMap);
        //oppty.Is_Barter_Opportunity__c=true;
       // update oppty;
        temp.cutoffDates(qtObj.Id,oppty.custom_Payment__c);
        DeliveryDateUtilities deliveryObj = new DeliveryDateUtilities();
        deliveryObj.deliveryDates(qtObj.Id,oppty.custom_Payment__c);
         Test.stopTest();
    }
   
}