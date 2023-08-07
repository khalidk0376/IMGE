/**
 * Created By: Girikon(Archit )
 * Created On: 07/20/2017
 * Modified by :  
 * Modified On: 
 * Description/Purpose: This class is called through the SKUID page: DisplayProductsOnCommunity
 *                      This Class is for fetching the Prices as per the product IDs available in the products and Product Option using the dynamic Pricebook object
 * Test Class:  GetProductPriceOnCustomerPortal_Test(85%)
**/

Global class GetProductPriceOnCustomerPortal
{
    global class CalculatorContext { 
        public APIClassDefinitions.QuoteModel quote; 
    }
    // Getting the Product Price on Customer Portal 
    webservice static string getProductPriceOnCustomerPortal(String ProductId, String priceBookId, String priceBookName, String eventId, String Quantity)
    {  
        List<product2> productLst = [SELECT Id,Name,SBQQ__DefaultQuantity__c from product2 where id=:ProductID ];
        List<SBQQ__ProductOption__c>optionList = [SELECT Id,SBQQ__Required__c,SBQQ__OptionalSKU__r.Product_Image_Link__c,SBQQ__Feature__r.Name, SBQQ__ProductFamily__c, SBQQ__Quantity__c, SBQQ__Type__c, SBQQ__OptionalSKU__c,SBQQ__OptionalSKU__r.Name, SBQQ__ProductName__c from SBQQ__ProductOption__c where SBQQ__Required__c=true AND SBQQ__ConfiguredSKU__c IN: productLst ];
        set <Id> setIds = new Set<Id>();
        if(optionList != null && optionList.size()>0) 
        {
            for(Integer i=0;i<optionList.size();i++)
            {
                setIds.add(optionList[i].SBQQ__OptionalSKU__c);
            }
        }
        List<Pricebook2> priceBookList=[select id, name from Pricebook2 where id=:priceBookId];
        List <PricebookEntry> pBEntryListMainProduct = [Select Product2Id, Pricebook2Id, UnitPrice from PricebookEntry where Product2Id IN:productLst AND Pricebook2Id IN:priceBookList];
        system.debug('pBEntryListMainProduct === '+pBEntryListMainProduct );
        List <PricebookEntry> pBEntryListCompulsoryProduct  = [Select Product2Id, Pricebook2Id, UnitPrice from PricebookEntry where Product2Id IN:setIds AND Pricebook2Id IN:priceBookList];
         
        //Getting data of PricebookObjName object in List 
        String query = 'SELECT id, Name, Product__c, Product__r.Name, Active__c,Advance__c,Late__c,Standard_Cutoff__c,Description__c, Advance_Cutoff__c, Advance_Price__c, Min_Size__c, Max_Size__c, Late_Price__c, Price__c From '+String.escapeSingleQuotes(priceBookName)+' where Product__r.ID =\''+String.escapeSingleQuotes(ProductId)+'\''; // Product__r.ID IN '+optionID+' OR
        List<SObject> priceBookObjList = Database.query(query);
        system.debug('===priceBookObjListSize: '+priceBookObjList.size() ); //*/
        
        List<ProductDetailWrapper> proWrapper=new List<ProductDetailWrapper>();
        
        // If the product is available in Custom Pricebook
        if(priceBookObjList.size() >0)
        {
            for(Integer i=0;i<priceBookObjList.size();i++) {
                ProductDetailWrapper pDetail=new ProductDetailWrapper();
                pDetail.ProductID=String.valueOf(priceBookObjList[i].get('Product__c'));
                pDetail.ProductName=productLst[0].Name;  pDetail.Price=String.valueOf(priceBookObjList[i].get('Price__c')); //Price from the Custom Pricebook
                pDetail.Advance=Boolean.valueOf(priceBookObjList[i].get('Advance__c'));   pDetail.Late=Boolean.valueOf(priceBookObjList[i].get('Late__c'));
                pDetail.AdvancePrice = String.valueOf(priceBookObjList[i].get('Advance_Price__c'));  pDetail.LatePrice = String.valueOf(priceBookObjList[i].get('Late_Price__c'));
                pDetail.AdvanceCuttoffDate = Date.valueOf(priceBookObjList[i].get('Advance_Cutoff__c')); pDetail.StandardCuttoffDate = Date.valueOf(priceBookObjList[i].get('Standard_Cutoff__c'));
                pDetail.MinSize = String.valueOf(priceBookObjList[i].get('Min_size__c'));  pDetail.MaxSize = String.valueOf(priceBookObjList[i].get('Max_size__c'));
                pDetail.Description = String.valueOf(priceBookObjList[i].get('Description__c')); pDetail.PrimaryProduct = true;
                proWrapper.add(pDetail); 
            }
        }
        else //IF the product is not available in Custom Pricebook
        {
              if(priceBookList != null && priceBookList.size()>0)      
                 {
                 Integer optionCount;
                 Integer productCount=0;
                 if((optionList != null && optionList.size()>0) || (productLst != null && productLst.size()>0))      
                 {  
                       //Adding the product price of the main product
                        if (pBEntryListMainProduct.size()>0 &&pBEntryListMainProduct!=null)
                        {
                            if((productCount<productLst.size()) && (String.valueOf(productLst[productCount].Id)==String.valueOf(pBEntryListMainProduct[0].Product2Id)))
                            {   
        
                                ProductDetailWrapper pDetail=new ProductDetailWrapper();       
                                pDetail.ProductID=String.valueOf(pBEntryListMainProduct[0].Product2Id);
                                pDetail.ProductName=productLst[productCount].Name;
                                pDetail.Price=String.valueOf(pBEntryListMainProduct[0].UnitPrice);
                                pDetail.PrimaryProduct = true;
                                ++productCount;
                                proWrapper.add(pDetail); 
                            }
                        }
                        // To add the product price of SBQQ__ProductOption__c 
                        if(optionList != null && optionList.size()>0) 
                        {
                            for (Integer i=0;i<pBEntryListCompulsoryProduct.size();i++)
                            {
                                for(optionCount=0;optionCount<optionList.size();optionCount++)
                                {
                                    if((optionCount<optionList.size()) && (String.valueOf(optionList[optionCount].SBQQ__OptionalSKU__c)==String.valueOf(pBEntryListCompulsoryProduct[i].Product2Id)))
                                    {   
                                        ProductDetailWrapper pDetail=new ProductDetailWrapper();
                                        pDetail.ProductID=optionList[optionCount].SBQQ__OptionalSKU__c;
                                        pDetail.ProductName=optionList[optionCount].SBQQ__OptionalSKU__r.Name;
                                        pDetail.Feature=optionList[optionCount].SBQQ__Feature__r.Name;
                                        pDetail.Type=optionList[optionCount].SBQQ__Type__c;
                                        pDetail.Quantity=String.valueOf(optionList[optionCount].SBQQ__Quantity__c);
                                        pDetail.ProductFamily=optionList[optionCount].SBQQ__ProductFamily__c;
                                        pDetail.Price=String.valueOf(pBEntryListCompulsoryProduct[i].UnitPrice);
                                        pDetail.Required= optionList[optionCount].SBQQ__Required__c;
                                        pDetail.imageURL=optionList[optionCount].SBQQ__OptionalSKU__r.Product_Image_Link__c ;
                                        
                                        pDetail.PrimaryProduct =false;
                                        proWrapper.add(pDetail);
                                    }
                                }
                            }    
                        }
                 }
            }
               
        }
        system.debug('==='+proWrapper);
        String JSONString = JSON.serialize(proWrapper);
        system.debug('JsonString: '+JSONString );
        return JSONString; 
    }
    
    //Method while the products will be added to the cart
    webservice static string getProductPriceOnCustomerPortalForAddtoCart(String ProductId, String priceBookId, String priceBookName, String eventId, String Quantity)
    {  
        List<product2> productLst = [SELECT Id,Name,SBQQ__DefaultQuantity__c from product2 where id=:ProductID ];
        List<SBQQ__ProductOption__c>optionList = [SELECT Id,SBQQ__Required__c,SBQQ__OptionalSKU__r.Product_Image_Link__c,SBQQ__Feature__r.Name, SBQQ__ProductFamily__c, SBQQ__Quantity__c, SBQQ__Type__c, SBQQ__OptionalSKU__c,SBQQ__OptionalSKU__r.Name, SBQQ__ProductName__c from SBQQ__ProductOption__c where SBQQ__Required__c=true AND SBQQ__ConfiguredSKU__c IN: productLst ];
        set <Id> setIds = new Set<Id>();
        if(optionList != null && optionList.size()>0) 
        {
            for(Integer i=0;i<optionList.size();i++)
            {
                setIds.add(optionList[i].SBQQ__OptionalSKU__c);
            }
        }
        List<Pricebook2> priceBookList=[select id, name from Pricebook2 where id=:priceBookId];
        List <PricebookEntry> pBEntryListMainProduct = [Select Product2Id, Pricebook2Id, UnitPrice from PricebookEntry where Product2Id IN:productLst AND Pricebook2Id IN:priceBookList];
        system.debug('pBEntryListMainProduct === '+pBEntryListMainProduct );
        List <PricebookEntry> pBEntryListCompulsoryProduct  = [Select Product2Id, Pricebook2Id, UnitPrice from PricebookEntry where Product2Id IN:setIds AND Pricebook2Id IN:priceBookList];
         
        //Getting data of PricebookObjName object in List 
        String query = 'SELECT id, Name, Product__c, Product__r.Name, Active__c,Advance__c,Late__c,Standard_Cutoff__c, Advance_Cutoff__c, Advance_Price__c, Min_Size__c, Max_Size__c, Late_Price__c, Price__c From '+string.escapeSingleQuotes(priceBookName)+' where Product__r.ID =\''+string.escapeSingleQuotes(ProductId)+'\''; // Product__r.ID IN '+optionID+' OR
        List<SObject> priceBookObjList = Database.query(query);
       // system.debug('===priceBookObjListSize: '+priceBookObjList.size() ); 
        
        List<ProductDetailWrapper> proWrapper=new List<ProductDetailWrapper>();
        /*
        // If the product is available in Custom Pricebook
        if(priceBookObjList.size() >0 ||(optionList != null && optionList.size()>0))
        {
            Integer optionCount;
            for(Integer i=0;i<priceBookObjList.size();i++)
            {
                ProductDetailWrapper pDetail=new ProductDetailWrapper();
                pDetail.ProductID=String.valueOf(priceBookObjList[i].get('Product__c'));
                pDetail.ProductName=productLst[0].Name;
                pDetail.Advance=Boolean.valueOf(priceBookObjList[i].get('Advance__c'));
                pDetail.Late=Boolean.valueOf(priceBookObjList[i].get('Late__c'));
                pDetail.AdvancePrice = String.valueOf(priceBookObjList[i].get('Advance_Price__c'));
                pDetail.LatePrice = String.valueOf(priceBookObjList[i].get('Late_Price__c'));
                pDetail.AdvanceCuttoffDate = Date.valueOf(priceBookObjList[i].get('Advance_Cutoff__c'));
                pDetail.StandardCuttoffDate = Date.valueOf(priceBookObjList[i].get('Standard_Cutoff__c'));
                pDetail.MinSize = String.valueOf(priceBookObjList[i].get('Min_size__c'));
                pDetail.MaxSize = String.valueOf(priceBookObjList[i].get('Max_size__c'));
                pDetail.Price=String.valueOf(priceBookObjList[i].get('Price__c')); //Default standard Price from the Custom Pricebook
                if(pDetail.Advance==true && pDetail.AdvanceCuttoffDate > Date.today())
                    pDetail.Price=pDetail.AdvancePrice; //If the advance is checked,then advance price
                if(pDetail.Late==true)
                    pDetail.Price=pDetail.LatePrice; //If late is checked, then late price
                pDetail.PrimaryProduct = true;
                proWrapper.add(pDetail); 
            }
            //else // To add the product price of SBQQ__ProductOption__c 
                if(optionList != null && optionList.size()>0) 
                {
                    for (Integer i=0;i<pBEntryListCompulsoryProduct.size();i++)
                    {
                        for(optionCount=0;optionCount<optionList.size();optionCount++)
                        {
                            if((optionCount<optionList.size()) && (String.valueOf(optionList[optionCount].SBQQ__OptionalSKU__c)==String.valueOf(pBEntryListCompulsoryProduct[i].Product2Id)))
                            {   
                                
                                decimal steelBrickPrice= getCalclatedPriceRule(String.valueOf(optionList[optionCount].SBQQ__OptionalSKU__c),'1',String.valueOf(pBEntryListCompulsoryProduct [i].UnitPrice));
                                system.Debug(steelBrickPrice);
                                
                                ProductDetailWrapper pDetail=new ProductDetailWrapper();
                                pDetail.ProductID=optionList[optionCount].SBQQ__OptionalSKU__c;
                                pDetail.ProductName=optionList[optionCount].SBQQ__OptionalSKU__r.Name;
                                pDetail.Feature=optionList[optionCount].SBQQ__Feature__r.Name;
                                pDetail.Type=optionList[optionCount].SBQQ__Type__c;
                                pDetail.Quantity=String.valueOf(optionList[optionCount].SBQQ__Quantity__c);
                                pDetail.ProductFamily=optionList[optionCount].SBQQ__ProductFamily__c;
                                //pDetail.Price=String.valueOf(pBEntryListCompulsoryProduct[i].UnitPrice);
                                pDetail.Price=String.valueOf(steelBrickPrice);
                                pDetail.Required= optionList[optionCount].SBQQ__Required__c;
                                pDetail.imageURL=optionList[optionCount].SBQQ__OptionalSKU__r.Product_Image_Link__c ;
                                pDetail.PrimaryProduct =false;
                                proWrapper.add(pDetail);
                            }
                        }
                    }    
                }
        }
        else //IF the product is not available in Custom Pricebook
        { */
            if(priceBookList != null && priceBookList.size()>0)      
             {
             Integer optionCount;
             Integer productCount=0;
             if((optionList != null && optionList.size()>0) || (productLst != null && productLst.size()>0))      
             {  
                //Adding the product price of the main product
                if (pBEntryListMainProduct.size()>0 &&pBEntryListMainProduct!=null)
                {
                    if((productCount<productLst.size()) && (String.valueOf(productLst[productCount].Id)==String.valueOf(pBEntryListMainProduct[0].Product2Id)))
                    {   
                        decimal steelBrickPrice=getCalclatedPriceRule(ProductID ,Quantity,String.valueOf(pBEntryListMainProduct[productCount].UnitPrice));
                        system.Debug(steelBrickPrice);
                        ProductDetailWrapper pDetail=new ProductDetailWrapper();       
                        pDetail.ProductID=String.valueOf(pBEntryListMainProduct[0].Product2Id);
                        pDetail.ProductName=productLst[productCount].Name;
                        //pDetail.Price=String.valueOf(pBEntryListMainProduct[0].UnitPrice);
                        pDetail.Price=String.valueOf(steelBrickPrice);
                        pDetail.PrimaryProduct = true;
                        ++productCount;
                        
                        proWrapper.add(pDetail); 
                    }
                }
                //else // To add the product price of SBQQ__ProductOption__c 
                if(optionList != null && optionList.size()>0) 
                {
                    for (Integer i=0;i<pBEntryListCompulsoryProduct.size();i++)
                    {
                        for(optionCount=0;optionCount<optionList.size();optionCount++)
                        {
                            if((optionCount<optionList.size()) && (String.valueOf(optionList[optionCount].SBQQ__OptionalSKU__c)==String.valueOf(pBEntryListCompulsoryProduct[i].Product2Id)))
                            {   
                                decimal steelBrickPrice= getCalclatedPriceRule(String.valueOf(optionList[optionCount].SBQQ__OptionalSKU__c),'1',String.valueOf(pBEntryListCompulsoryProduct [i].UnitPrice));
                                system.Debug(steelBrickPrice);
                                
                                ProductDetailWrapper pDetail=new ProductDetailWrapper();
                                pDetail.ProductID=optionList[optionCount].SBQQ__OptionalSKU__c;
                                pDetail.ProductName=optionList[optionCount].SBQQ__OptionalSKU__r.Name;
                                pDetail.Feature=optionList[optionCount].SBQQ__Feature__r.Name;
                                pDetail.Type=optionList[optionCount].SBQQ__Type__c;
                                pDetail.Quantity=String.valueOf(optionList[optionCount].SBQQ__Quantity__c);
                                pDetail.ProductFamily=optionList[optionCount].SBQQ__ProductFamily__c;
                                //pDetail.Price=String.valueOf(pBEntryListCompulsoryProduct[i].UnitPrice);
                                pDetail.Price=String.valueOf(steelBrickPrice);
                                pDetail.Required= optionList[optionCount].SBQQ__Required__c;
                                pDetail.imageURL=optionList[optionCount].SBQQ__OptionalSKU__r.Product_Image_Link__c ;
                                
                                pDetail.PrimaryProduct =false;
                                proWrapper.add(pDetail);
                               
                            }
                        }
                    }    
                }
            
             }
            //}
        
        }
        system.debug('==='+proWrapper);
        String JSONString = JSON.serialize(proWrapper);
        system.debug(JSONString );
        return JSONString;
    }
    // getting the product details 
    public static map<string,string> getProductDetails(String sEventcode)
    {  
        map<string,string> mapProduct= new map<string,string>();
        mapProduct.put('ProductID',null);
        mapProduct.put('Price','0'); 
        String priceBookId;
        String productId;
        String priceBookName;
        String Quantity ='1';
        list<Event_Edition__c> eventEdition = [SELECT Id,Name,Event_Price_Book__c  from Event_Edition__c where Event_Code__c=:sEventcode order by createddate desc limit 1 ];  
        if(eventEdition.size()>0)
        {
            priceBookId=eventEdition[0].Event_Price_Book__c;
            if(!String.isBlank(priceBookId))
            {
                List<product2> productLst = [SELECT Id,Name,SBQQ__DefaultQuantity__c from product2 where EAC_Fee__c=true order by createddate desc limit 1];
                if(productLst.size()>0)    
                {
                    productId=productLst[0].Id;
                    //this has to de defind as per event edition   
                    List<Pricebook2> priceBookList=[select id, name from Pricebook2 where id=:priceBookId ]; 
                    if(priceBookList.size()>0)     
                    {
                        List <PricebookEntry> pBEntryListMainProduct = [Select Product2Id, Pricebook2Id, UnitPrice from PricebookEntry where Product2Id IN:productLst AND Pricebook2Id IN:priceBookList order by createddate desc limit 1];
                        system.debug('pBEntryListMainProduct === '+pBEntryListMainProduct );
                        if(pBEntryListMainProduct.size()>0 )     
                        {
                            decimal steelBrickPrice=getCalclatedPriceRule(ProductID ,Quantity,String.valueOf(pBEntryListMainProduct[0].UnitPrice));
                            system.Debug(steelBrickPrice);
                            mapProduct.put('ProductID',ProductID);
                            mapProduct.put('Price',string.valueOf(steelBrickPrice));
                        }
                    }
                }
            }
        }
        return mapProduct;
    }
    //Calculating the price rule 
    public static  decimal getCalclatedPriceRule(string ProdId,String Quantity,String pricevalueDefault)
    {
        Quantity=Quantity.trim();
        System.Debug('ProdId:'+ProdId);
        System.Debug('Quantity:'+Quantity);
        System.Debug('Default price:'+pricevalueDefault);
        String defaultPrice = pricevalueDefault.trim();
        Decimal ProdPrice=0.0;
        
        // STEP 1: LOAD DUMMY QUOTE 
        String startingQuoteJson='{"record":{"attributes":{"type":"SBQQ__Quote__c"},"Id":"x0x0x00000000xxxxx","CurrencyIsoCode":"USD","Name":"X0X0"},"lineItems":[]}';
        APIClassDefinitions.QuoteModel qm = (APIClassDefinitions.QuoteModel)JSON.deserialize(startingQuoteJson, APIClassDefinitions.QuoteModel.class); 
        
        // STEP 2: ADD LINEITEM DATA WITH QUANTITY
        SBQQ__QuoteLine__c ql=new SBQQ__QuoteLine__c(SBQQ__Quote__c = 'x0x0x00000000xxxxx', SBQQ__Product__c = ProdId, SBQQ__Quantity__c = Integer.valueOf(Quantity));
        APIClassDefinitions.QuoteLineModel qlm=new APIClassDefinitions.QuoteLineModel();
        qlm.record=ql;
        qm.lineItems.add(qlm);
        
        // STEP 3: SET UP A CONTEXT 
        CalculatorContext context = new CalculatorContext(); 
        context.quote = qm; 
        
        // STEP 4: CALCULATE
        String resultJson;
        if(!Test.isRunningTest())
        {
            resultJson = SBQQ.ServiceRouter.load('SBQQ.QuoteAPI.QuoteCalculator', null, JSON.serialize(context)); 
            APIClassDefinitions.QuoteModel resultModel = (APIClassDefinitions.QuoteModel)JSON.deserialize(resultJson, APIClassDefinitions.QuoteModel.class); 
            ProdPrice = resultModel.lineItems[0].record.SBQQ__ListPrice__c;
            System.Debug('ProdPrice :'+ProdPrice );
            if(ProdPrice == null) {        ProdPrice = decimal.valueOf(defaultPrice);
                
            }   
        }               
        return ProdPrice;
    }   
    
    //For creating the JSON string to send back the data to Skuid Page
    global class ProductDetailWrapper
    {
        public String ProductID{get;set;}
        public String ProductName{get;set;}
        public String Price{get;set;}
        public String StandardPrice{get;set;}
        public Date AdvanceCuttoffDate{get;set;}
        public Date StandardCuttoffDate{get;set;}
        public String AdvancePrice{get;set;}
        public String LatePrice{get;set;}
        public String MinSize{get;set;}
        public String MaxSize{get;set;}
        public Boolean PrimaryProduct {get;set;}
        public String Feature{get;set;}
        public String Type{get;set;}
        public String Quantity{get;set;}
        public String ProductFamily{get;set;}
        public boolean Required{get;set;}
        public boolean Advance{get;set;}
        public boolean Late{get;set;}
        public String imageURL{get;set;}
        public String Description{get;set;}
    }
}