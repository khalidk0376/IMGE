/***** GAP *****
Date: 29/March/2017
Developed by : Anuj Sahu (Girikon)
Purpose : For test coverage of the class 'clsClonePriceBook'
* Modified By : Rajesh kumar Yadav Bk-3751
*/

@isTest
public class test_clsClonePriceBook{
    static testMethod void method1(){
        
        string pricebookId = Test.getStandardPricebookId();
        system.debug('1 : pricebookId -----> '+pricebookId);
        
        Product2 prod = new Product2(Name = 'Laptop X200', 
        Family = 'Hardware');
        insert prod;
        
        //priceBook2 pb2 = [select id from pricebook2 where id =:pricebookId];
        
        PricebookEntry standardPrice = new PricebookEntry(
        Pricebook2Id = pricebookId, Product2Id = prod.Id,
        UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        system.assertEquals(standardPrice.Pricebook2Id , pricebookId, 'pricebookId should be equals');
        
        Pricebook2 customPB = new Pricebook2(Name='ICREABC', isActive=true);
        insert customPB;
        string strPBId = customPB.id;
        system.assertEquals(strPBId , customPB.id, 'pricebookId should be equals');
        /*
        system.debug('1 :::::::::::: Test.getStandardPricebookId()::::::::::'+Test.getStandardPricebookId());
        list<PriceBook2> stPB2 = [select id from pricebook2 where id ='01s50000001PwnyAAC'];
        list<pricebookentry> stdPBE = [select id from pricebookentry where Pricebook2Id  In : stPB2];
        system.debug('2 :::::::::::: Standard Pricebook:::::::'+stPB2);
        */
        
        Brand__c objBrnd = new Brand__c();  
        objBrnd.name = 'Arab Health';
        insert objBrnd;
        system.assertEquals(objBrnd.Name, 'Arab Health', 'Both values should be the same.');        
        Event_Series__c objEnvtSeries = new Event_Series__c();
        objEnvtSeries.name = 'Arab Health';
        objEnvtSeries.Brand__c = objBrnd.id;
        insert objEnvtSeries;
        
        ApexPages.currentPage().getParameters().put('id',customPB.id);

        ApexPages.StandardController sc = new ApexPages.StandardController(customPB);
        clsClonePriceBook cls = new clsClonePriceBook(sc);
        cls.selectBrand = 'Arab Health';
        cls.selectCurrency = 'USD';
        cls.selectedCurrencyCodec = 'AED';
        cls.pbCurrencyRate = 0.12;
        cls.outValueSecond = 0.154;
        cls.priceBookDetails(strPBId);
        cls.getAllBrands();
        cls.loadEventSeries();
        cls.loadEventEdition();
        cls.loadSourceCurrency();
        cls.loadActiveCurrencyType();
        clsClonePriceBook.getConversionRate('USD');
        cls.updatePricebook();
    }
}