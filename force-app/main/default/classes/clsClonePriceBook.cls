/***** GAP *****
Date: 22/March/2017
#71 Ankit Gupta : Girikon
Purpose : Used to clone pricebook according wrt to specific currency, bind up with a VF page 'clonePriceBook'.
Test Class : test_clsClonePriceBook
Modified By Himanshu Jasuja : BK-3746 on 22- 05-2020
History: BK-3758 Modified By Rajesh Kumar - on 28-05-2020 : Remove System.debug and commented code
*/

public with sharing class clsClonePriceBook{
     public String priceBookID;
    public List<Pricebook2> priceBookRecords = new List<Pricebook2>();
    public List<CurrencyType> lstCurrencyType;
    public String pbName {get;set;}
    public String pbDesc {get;set;}
    public Boolean pbStatus {get;set;}
    public String selectedCurrencyCode { get; set; }
    public String selectedCurrencyCodec {get;set;}   
    public decimal pbCurrencyRate {get;set;}
    public Boolean flagValue {get;set;}
    public String selectBrand { get; set; }
    public String selectEventSeries { get; set; }
    public String selectEventEdition { get; set; }
    //public String selectProduct { get; set; }
    public String selectCurrency { get; set; }
    public String selectedSourceCurrency {get;set;}
    public List<SelectOption> options {get;set;}
    public List<SelectOption> currencyCodes  { get; set; }
    public List<SelectOption> lstEventSeries {get;set;}
    public List<SelectOption> lstEventEdition {get;set;}
    //public List<SelectOption> lstProducts {get;set;} Commented bcz it is not used in class.
    public List<SelectOption> SelectDefault {get;set;}
    public decimal outValueSecond {get;set;}
    Map<String, PricebookEntry> objMap1;
    Map<String, CurrencyType> objMap2;
    
    public clsClonePriceBook(ApexPages.StandardController controller)
    {
        //priceBookID = '01s50000001TpbpAAC';
        priceBookID = ApexPages.currentPage().getParameters().get('id').escapeHtml4(); // getting current id of pricebook, holding it in priceBookID
        if(priceBookID!=null || priceBookID != '')
        {
            SelectDefault =  new List<SelectOption>();
            SelectDefault.add(new SelectOption('Select','Select'));
            lstEventSeries = new List<SelectOption>();
            lstEventEdition = new List<SelectOption>();
            currencyCodes =  new List<SelectOption>();
            options = new List<SelectOption>();
            options.add(new SelectOption('Select','Select'));
            objMap1 = new Map<String, PricebookEntry>();
            objMap2 = new Map<String, CurrencyType>();
            flagValue = false;
            priceBookDetails(priceBookID); //calling getPriceBookDetails method
        }
    }
    
    // Method used for getting records of pricebook according to pricebookID
    public void priceBookDetails(String priceBookID)
    {   
        string priceBookQuery = 'SELECT Id, name, description, ISActive From Pricebook2 where ID = \''+String.escapeSingleQuotes(priceBookID)+ '\''; 
        priceBookRecords = Database.Query(priceBookQuery);
        if(priceBookRecords !=null && priceBookRecords.size() > 0)
        {
            pbName = priceBookRecords.get(0).name;
            pbDesc = priceBookRecords.get(0).description;
            pbStatus = priceBookRecords.get(0).ISActive;
        }
    }
    
    //Method used for populate all Brands   
    public List<selectOption> getAllBrands()
    {  
        List<SelectOption> brandOptions = new List<SelectOption>();
        brandOptions.add(new SelectOption('Select','Select'));
       
        for(Brand__c objBrand: [SELECT id, Name FROM Brand__c limit 1000])
        {
            brandOptions.add(new SelectOption(string.ValueOf(objBrand.id),string.ValueOf(objBrand.Name)));             
        }
        return brandOptions;
    }
    
    //Method used for populate all Eventseries depend with Brands
    public PageReference loadEventSeries() {
        if(lstEventSeries !=null && lstEventSeries.size()>0)  {      lstEventSeries.clear();  }
        if(lstEventEdition !=null && lstEventEdition.size()>0){     lstEventEdition.clear(); }
        if(currencyCodes !=null && currencyCodes.size()>0)  {     currencyCodes.clear();selectEventEdition =''; }
        if(options !=null && options.size()>0)  {
            options.clear();
            selectEventEdition ='';
        } 
        for(Event_Series__c objEventSeries: [SELECT id, Name FROM Event_Series__c where Brand__c =:selectBrand])  {       lstEventSeries.add(new SelectOption(string.ValueOf(objEventSeries.id),string.ValueOf(objEventSeries.Name)));             
        }
        return null;
    }
    
    //Method used for populate all EventEdition depend with Eventseries
    public PageReference loadEventEdition()
    {
        if(lstEventEdition !=null && lstEventEdition.size()>0)   {      lstEventEdition.clear();  }
        if(currencyCodes !=null && currencyCodes.size()>0)  {   currencyCodes.clear();     }
        for(Event_Edition__c objEventEdition: [SELECT Name FROM Event_Edition__c where Part_of_Series__c =:selectEventseries]) {    lstEventEdition.add(new SelectOption(string.ValueOf(objEventEdition.Name),string.ValueOf(objEventEdition.Name)));             
        }
        return null;
    }
    
    //Method used for populate all Source Currency depands on pricebookId and selected event edition
    //public PageReference getSourceCurrency() SourceCurrency
    public PageReference loadSourceCurrency()
    {
        Map<String,SelectOption> mapCountry = new Map<String,SelectOption>();
        if(currencyCodes !=null && currencyCodes.size()>0){      currencyCodes.clear();     }
        if(options !=null && options.size()>0)    {     options.clear(); flagValue = false;     } 
        objMap1.clear();
        for(PricebookEntry objPricebookEntry: [SELECT Id, ProductCode,Name,CurrencyIsoCode  FROM PricebookEntry WHERE Pricebook2Id =:priceBookID and product2.Product_Brand__c =: selectEventEdition ])
        {   
            objMap1.put(objPricebookEntry.CurrencyIsoCode, objPricebookEntry);            mapCountry.put(objPricebookEntry.CurrencyIsoCode,new SelectOption(string.ValueOf(objPricebookEntry.CurrencyIsoCode),string.ValueOf(objPricebookEntry.CurrencyIsoCode)));
        }
        currencyCodes = mapCountry.values();
        return null;
    }
    
   
    
    //Method used for populate all active currency of org and bind them in a pick list
    public PageReference loadActiveCurrencyType()
    {
        Map<String,SelectOption> mapTarget = new Map<String,SelectOption>();
        if(options !=null && options.size()>0) {   options.clear();  }
        
        options.add(new SelectOption('Select','Select'));  
       
        for(CurrencyType objCurrencyType: [SELECT IsoCode FROM CurrencyType WHERE IsActive = true])
        {   
            if(!objMap1.containsKey(objCurrencyType.IsoCode))
            {
                mapTarget.put(string.ValueOf(objCurrencyType.IsoCode),new SelectOption(string.ValueOf(objCurrencyType.IsoCode),string.ValueOf(objCurrencyType.IsoCode)));
            }
            if(mapTarget.size()>0)
            {
                options = mapTarget.values();
                flagValue = false;
            }   
            else
            {
                flagValue = true;
            }   
        }
        
        return null;        
    }
    
    //Remote Methid used for get Conversion Rate depends on Currency Code
    
    @RemoteAction
    public static decimal getConversionRate(String selectedIsoCode)
    {
        system.Debug('selected IsoCode: ' + selectedIsoCode);
        decimal datas;
        
        for(CurrencyType objCurrencyType : [SELECT ConversionRate FROM CurrencyType WHERE IsActive = true and IsoCode=:selectedIsoCode])
        {
            datas = objCurrencyType.ConversionRate;
        }
        return datas;
    }
    
    // Action Method use for update price book
    public PageReference updatePricebook() 
    {
        list<PricebookEntry>getCurrencycode= new List<PricebookEntry>();
        list<decimal>getUnitPrice = new list<decimal>();
        list<decimal>setUnitPrice = new list<decimal>();
        
        getCurrencycode = [SELECT id,name, CurrencyIsoCode From PricebookEntry  WHERE Pricebook2Id =:priceBookID AND isActive = true  and CurrencyIsoCode=:selectedCurrencyCode and product2.Product_Brand__c =:selectEventEdition];
        if(getCurrencycode !=null && getCurrencycode.size()>0)  {       ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Pricebook already cloned for selected currency '+ selectedCurrencyCode + ', select another currency for clone.'));
        }
        else
        {
            // Insertion of price book products
            List<string> productId = new List<string>();
            Pricebook2 standardPB = new Pricebook2();
            if(!Test.isRunningTest()){
                standardPB = [select id from Pricebook2 where isStandard = true];
            }
            else{
                standardPB = new Pricebook2(Name='ICRE', isActive=true);
                insert standardPB;
            }
            
           
            List<PricebookEntry> lstPricebookEntryCreate = new List<PricebookEntry>();  
            PricebookEntry standardPrice;
            for(PricebookEntry objPBEproducts:[SELECT Id, ProductCode,Name,CurrencyIsoCode,product2id,Pricebook2Id,unitprice  FROM PricebookEntry WHERE Pricebook2Id =:priceBookID AND isActive = true and product2.Product_Brand__c =:selectEventEdition and CurrencyIsoCode=:selectedSourceCurrency])
            {
                PricebookEntry pbe = new PricebookEntry(Pricebook2Id = objPBEproducts.Pricebook2Id, Product2Id = objPBEproducts.Product2Id, UnitPrice = (objPBEproducts.unitprice*pbCurrencyRate), IsActive = true, UseStandardPrice = false, CurrencyIsoCode = selectedCurrencyCode);
                
                standardPrice = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = objPBEproducts.Product2Id, UnitPrice = (objPBEproducts.unitprice*pbCurrencyRate), IsActive = true, UseStandardPrice = false,CurrencyIsoCode = selectedCurrencyCode);
                lstPricebookEntryCreate.add(pbe);
            }
            if(standardPrice!=null ){                try{ insert standardPrice;} catch(exception e){system.debug('ex'+e);}
            }
            Database.SaveResult[] srList = Database.insert(lstPricebookEntryCreate,false);
            List<PricebookEntry>objpbeProdDel;
            for(Database.SaveResult sr : srList) 
            {
                if (sr.isSuccess()) 
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Price Book products cloned in selected currency code: ' + selectedCurrencyCode));
                }
                else 
                {
                    for(Database.Error err : sr.getErrors()) 
                    {
                      ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, err.getMessage()));
                    }
                }
            } 
        }
        return null;
    } 
}