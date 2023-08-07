/**
 * Created/Modified By: Girikon(Archit)
 * Created On:          11/9/2017
 * Description/Purpose: This test class covers the apex class : CaptureProductTaxCtrl
 * Methods:             CaptureProductTaxCtrlTest, CaptureProductTaxCtrlTest2
 * Apex Class:          CaptureProductTaxCtrl
**/

@isTest
public class CaptureProductTaxCtrl_Test{
    public static testMethod void CaptureProductTaxCtrlTest()
    {
        /****** Setup test data ******/
         String json = '{'+
                '  \"Header\": {'+
                '    \"Systems\": {'+
                '      \"CallingApplication\": \"SFDC-GE\",'+
                '      \"MessageDate\": \"2017-04-04\"'+
                '    }'+
                '  },'+
                '  \"Content\": {'+
                '    \"Transaction\": {'+
                '      \"MetaData\": {'+
                '        \"Customer\": {'+
                '          \"CustomerNumber\": \"BP010101010101\",'+
                '          \"CustomerNumberType\": \"BP\",'+
                '          \"CustomerEmail\": \"mulesoft@informa.com\"'+
                '        },'+
                '        \"AddressGroup\": {'+
                '          \"BillTo\": {'+
                '            \"PersonName\": {'+
                '              \"Prefix\": \"Mr.\",'+
                '              \"FirstNames\": \"Guan\",'+
                '              \"LastName\": \"Carlos\"'+
                '            },'+
                '            \"Address\": {'+
                '              \"Organisation\": \"Informa\",'+
                '              \"Department\": \"Global Support\",'+
                '              \"AddressLine1\": \"Schimmelt 32\",'+
                '              \"AddressLine2\": \"\",'+
                '              \"City\": \"Eindhoven\",'+
                '              \"State\": \"\",'+
                '              \"PostalCode\": \"5611 ZX\",'+
                '              \"Country\": \"NL\",'+
                '              \"PhoneNumber\": \"3161234567890\",'+
                '              \"PhoneExtension\": \"x1234\",'+
                '              \"FaxNumber\": \"3161234567899\"'+
                '            }'+
                '          },'+
                '          \"ShipTo\": {'+
                '            \"PersonName\": {'+
                '              \"Prefix\": \"Mr.\",'+
                '              \"FirstNames\": \"Guan\",'+
                '              \"LastName\": \"Carlos\"'+
                '            },'+
                '            \"Address\": {'+
                '              \"Organisation\": \"Informa\",'+
                '              \"Department\": \"Global Support\",'+
                '              \"AddressLine1\": \"Schimmelt 32\",'+
                '              \"AddressLine2\": \"\",'+
                '              \"City\": \"Eindhoven\",'+
                '              \"State\": \"\",'+
                '              \"PostalCode\": \"5611 ZX\",'+
                '              \"Country\": \"NL\",'+
                '              \"PhoneNumber\": \"3161234567890\",'+
                '              \"PhoneExtension\": \"x1234\",'+
                '              \"FaxNumber\": \"3161234567899\"'+
                '            }'+
                '          }'+
                '        },'+
                '        \"Currency\": \"GBP\"'+
                '      },'+
                '      \"CartItems\": ['+
                '        {'+
                '          \"CartItem\": {'+
                '            \"Quantity\": 1,'+
                '            \"Price\": 5535,'+
                '            \"ItemData\": {'+
                '              \"ProductCode\": \"I12345\"'+
                '            }'+
                '          }'+
                '        }'+
                '      ]'+
                '    }'+
                '  }'+
                '}';
        Account acc1 = new Account();
        acc1.Name='acc1';
        acc1.BillingCity ='Dallas' ;
        acc1.BillingCountry='USA';
        acc1.BillingPostalCode='75068';
        acc1.BillingState='Texas';
        acc1.BillingStreet='water well street';              
        insert acc1;
        System.assertNotEquals(acc1, null,'account should not be null');
        
        Contact con1 = new Contact(LastName='User',FirstName ='Test',AccountId=acc1.id, MailingCountry='USA');
        insert con1;
        System.assertNotEquals(con1, null,'Contact should not be null');
        
        Event_Edition__c  OEve = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today(),Payment_Schedule__c='10-40-50',X50_Cutoff_Date__c=Date.today(),Cutoff_Date_1__c=Date.today(),Cutoff_Date_2__c=Date.today(),CutoffDate_3__c=Date.today(),Year__c='2018');
        insert OEve;
        System.assertEquals(OEve.Event_Code__c, 'WOC17','Not a valid Event Edition');
        
        EventCurrecies__c eventCurrency = new EventCurrecies__c (Name='USD',Event_Edition__c=OEve.id);
        insert eventCurrency;
        System.assertEquals(eventCurrency.Name,'USD', 'Event Currency');
        
        Product2 prd = new Product2(Name = 'Booth Package WOC',Family = 'Booth',Number_of_Corners__c = 0,Booth_Type__c='esc', Booth_Class__c='fsdf', Event_Edition_Pool__c = 'WOC', Product_Brand__c = 'World of Concrete 2017');
        insert prd;
        
        Customer_Center_Cart_Master__c testCCCM = new Customer_Center_Cart_Master__c();
        testCCCM.Event_Edition__c = OEve.id;
        testCCCM.CurrencyIsoCode = eventCurrency.Name;
        testCCCM.Contact__c = con1.Id;
        insert testCCCM;
        
        Customer_Center_Cart__c CCCart = new Customer_Center_Cart__c();
        CCCart.Customer_Center_Cart_Master__c = testCCCM.Id;
        CCCart.Event_Edition__c = OEve.id;
        CCCart.Contact__c = con1.id;
        CCCart.Product__c = prd.id;
        CCCart.Tax_Rate__c = 30;
        CCCart.Rate__c = 100;
        CCCart.Price__c = 200;
        CCCart.Quantity__c = 1000;
        insert CCCart;
        
        Integration_Settings__c ISetting = new Integration_Settings__c();
        ISetting.Name = 'Customer';
        ISetting.Password__c = 'a15A5CFC34214c72826e267B43cEd176';
        ISetting.Endpoint__c = 'https://uat-ux-sapintegration-informags.eu.cloudhub.io/api/v1.0/services/customer';
        ISetting.Username__c = 'a502f90975bc48d3ac813afa26d11a46';
        insert ISetting;
        
        Integration_Settings__c ISetting2 = new Integration_Settings__c();
        ISetting2.Name = 'TAX_CALCULATION';
        ISetting2.Password__c = 'a15A5CFC34214c72826e267B43cEd176';
        ISetting2.Endpoint__c = 'https://uat-ux-sapintegration-informags.eu.cloudhub.io/api/v1.0/services/taxcalculation';
        ISetting2.Username__c = 'a502f90975bc48d3ac813afa26d11a46';
        insert ISetting2;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(200,json));
            ApexPages.currentPage().getParameters().put('eventId',OEve.id);
            ApexPages.currentPage().getParameters().put('mCartId',testCCCM.id);
            CaptureProductTaxCtrl capProduct = new CaptureProductTaxCtrl();
            capProduct.CaptureProductTax();
            capProduct.CaptureProductTax();
            CaptureProductTaxCtrl.responseJson ='';
            capProduct.Quantity =0;
            capProduct.Tax = 0;
            capProduct.TaxRates = 0;
            capProduct.doDirectRequest ='';
            capProduct.ProductCode ='';
            capProduct.Price = 0;
            string countryName = 'USA';
            capProduct.returnCountryIsoCode(countryName);
            capProduct.returnCountryIsoCode('ABC');
        Test.stopTest();
    }
    
    public static testMethod void CaptureProductTaxCtrlTest2()
    {
        /****** Setup test data ******/
        Account acc1 = new Account();
        acc1.Name='acc1';
        acc1.BillingCity ='Dallas' ;
        acc1.BillingCountry='USA';
        acc1.BillingPostalCode='75068';
        acc1.BillingState='Texas';
        acc1.BillingStreet='water well street';              
        insert acc1;
        
        Contact con1 = new Contact(LastName='User',FirstName ='Test',AccountId=acc1.id, MailingCountry='INDIA');
        insert con1;
        System.assertEquals(con1.AccountId, acc1.id,'Contact should be inserted');
        
        Event_Edition__c  OEve = new Event_Edition__c(Name='World of Concrete 2017',Event_Code__c='WOC17',End_Date__c=System.Today(),Start_Date__c=System.Today(),Payment_Schedule__c='10-40-50',X50_Cutoff_Date__c=Date.today(),Cutoff_Date_1__c=Date.today(),Cutoff_Date_2__c=Date.today(),CutoffDate_3__c=Date.today(),Year__c='2017');
        insert OEve;
        System.assertEquals(OEve.Event_Code__c, 'WOC17','Not a valid Event Edition');
        
        EventCurrecies__c eventCurrency = new EventCurrecies__c (Name='USD',Event_Edition__c=OEve.id);
        insert eventCurrency;
        System.assertEquals(eventCurrency.Name,'USD', 'Event Currency');
        
        opportunity opp = new opportunity();
        opp.Name='World of Concrete 2017';
        opp.EventEdition__c=OEve.id;
        opp.AccountId = acc1.id;
        opp.Paid_Amount__c=10.00;
        opp.Amount=20.00;
        opp.CloseDate=System.Today();
        opp.StageName='Needs Assessment';
        opp.CurrencyIsoCode=OEve.EventCurrency__r.Name;
        insert opp;
        
        Product2 prd = new Product2(Name = 'Booth Package WOC',Family = 'Booth',Number_of_Corners__c = 0,Booth_Type__c='esc', Booth_Class__c='fsdf', Event_Edition_Pool__c = 'WOC', Product_Brand__c = 'World of Concrete 2017');
        insert prd;
        
        Customer_Center_Cart_Master__c testCCCM = new Customer_Center_Cart_Master__c();
        testCCCM.Event_Edition__c = OEve.id;
        testCCCM.CurrencyIsoCode = eventCurrency.Name;
        testCCCM.Contact__c = con1.Id;
        insert testCCCM;
        
        Customer_Center_Cart__c CCCart = new Customer_Center_Cart__c();
        CCCart.Customer_Center_Cart_Master__c = testCCCM.Id;
        CCCart.Event_Edition__c = OEve.id;
        CCCart.Contact__c = con1.id;
        CCCart.Product__c = prd.id;
        CCCart.Tax_Rate__c = 30;
        CCCart.Rate__c = 100;
        CCCart.Price__c = 200;
        CCCart.Quantity__c = 1000;
        insert CCCart;
        
        Integration_Settings__c ISetting = new Integration_Settings__c();
        ISetting.Name = 'Customer';
        ISetting.Password__c = 'a15A5ccffCFC34214c72826e267B43cEd176';
        ISetting.Endpoint__c = 'https://uat-ux-sapintegration-informags.eu.cloudhub.io/api/v2.0/services/customer';
        ISetting.Username__c = 'a502f90975bc48d3DDFHFDDac813afa26d11a46';
        insert ISetting;
        
        Integration_Settings__c ISetting2 = new Integration_Settings__c();
        ISetting2.Name = 'TAX_CALCULATION';
        ISetting2.Password__c = 'a15A5CFC34214c72826eRRGGFGFGG267B43cEd176';
        ISetting2.Endpoint__c = 'https://uat-ux-sapintegration-informags.eu.cloudhub.io/api/v3.0/services/taxcalculation';
        ISetting2.Username__c = 'a502f90975bc48d3ac81SGHGHJJ3afa26d11a46';
        insert ISetting2;
           
        Test.startTest();
            ApexPages.currentPage().getParameters().put('eventId',OEve.id);
            ApexPages.currentPage().getParameters().put('mCartId',testCCCM.id);
            CaptureProductTaxCtrl capProduct = new CaptureProductTaxCtrl();
            capProduct.CaptureProductTax();
            //CaptureProductTaxCtrl.responseJson ='';
            capProduct.Quantity =0;
            capProduct.Tax = 0;
            capProduct.TaxRates = 0;
            capProduct.doDirectRequest ='';
            capProduct.ProductCode ='';
            capProduct.Price = 0;
            string countryName = 'USA';
        Test.stopTest();
    }

}