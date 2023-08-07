/**
 * Created/Modified By: Girikon(Amish,Archit)
 * Created On:          9/6/2017
 * Description/Purpose: This class is used for getting the product price on Ops Admin
 * Methods:             getProductPrice, getCalclatedPriceRule
 * Test Class:          GetProductPrice_Test
 * History: BK-3758 Modified By Rajesh Kumar - on 28-05-2020
**/

public class GetProductPrice
{
    public class CalculatorContext { 
        public APIClassDefinitions.QuoteModel quote; 
    }
    //Method name is modified by Palla Kishore for the ticket BK-19606
    public Static List<ProductDetailWrapper> getProductPriceMethod(String ProductId, String PricebookObjName, String eventId, String Quantity)
    {   
        List<product2> productLst = [SELECT Id,Name,SBQQ__DefaultQuantity__c from product2 where id=:ProductID ];
        system.debug('===ProductLst: '+productLst);
        List<SBQQ__ProductFeature__c> featureList = [SELECT Id from SBQQ__ProductFeature__c where SBQQ__ConfiguredSKU__c IN: productLst ];
        system.debug('===featureList: '+featureList);
        //List<SBQQ__ProductOption__c>optionList = [SELECT Id,SBQQ__Required__c,SBQQ__OptionalSKU__r.Product_Image_Link__c,SBQQ__Feature__r.Name, SBQQ__ProductFamily__c, SBQQ__Quantity__c, SBQQ__Type__c, SBQQ__OptionalSKU__c,SBQQ__OptionalSKU__r.Name, SBQQ__ProductName__c from SBQQ__ProductOption__c where SBQQ__Feature__c IN: featureList AND SBQQ__ConfiguredSKU__c IN: productLst ];
        List<SBQQ__ProductOption__c>optionList = [SELECT Id,SBQQ__Required__c,SBQQ__OptionalSKU__r.Product_Image_Link__c,SBQQ__Feature__r.Name, SBQQ__ProductFamily__c, SBQQ__Quantity__c, SBQQ__Type__c, SBQQ__OptionalSKU__c,SBQQ__OptionalSKU__r.Name, SBQQ__ProductName__c from SBQQ__ProductOption__c where SBQQ__ConfiguredSKU__c IN: productLst ];
        system.debug('===optionList: '+optionList );
        
        //Getting data of PricebookObjName object in List 
        String query = 'SELECT id, Name, Product__c, Product__r.Name, Price__c From '+String.escapeSingleQuotes(PricebookObjName); //+' Where Product__c IN:'+productLst+' AND Product__c IN:'+optionList;
        List<SObject> priceBookObjList = Database.query(query);
        system.debug('===priceBookObjList: '+priceBookObjList );
        system.debug('===priceBookObjListSize: '+priceBookObjList.size() );
        
        List<ProductDetailWrapper> proWrapper=new List<ProductDetailWrapper>();
        
        if(priceBookObjList != null && priceBookObjList.size()>0)      
             {
             Integer optionCount;
             Integer productCount=0;
             if((optionList != null && optionList.size()>0) || (productLst != null && productLst.size()>0))      
             {  // This loop is for fetching the Prices as per the product IDs available in the products and Product Option
                for(Integer i=0;i<priceBookObjList.size();i++)
                {   system.debug('Counter=== :'+i);
                    
                    //Adding the product price of the main product
                    if((productCount<productLst.size()) && (String.valueOf(productLst[productCount].Id)==String.valueOf(priceBookObjList[i].get('Product__c'))))
                    {   
                        system.debug('Product=== '+String.valueOf(productLst[productCount].Id)+' == '+String.valueOf(priceBookObjList[i].get('Product__c'))); 
                        system.debug(productLst);                      
                        system.debug(productLst[productCount].SBQQ__DefaultQuantity__c);
                     /*   decimal steelBrickPrice=getCalclatedPriceRule(ProductID, Quantity , String.valueOf(priceBookObjList[i].get('Price__c')));
                        system.Debug(steelBrickPrice); */
                    /*   decimal steelBrickPrice=getCalclatedPriceRule(ProductID ,String.valueOf(productLst[productCount].SBQQ__DefaultQuantity__c)  ,String.valueOf(priceBookObjList[i].get('Price__c')));
                        system.Debug(steelBrickPrice); */
                        ProductDetailWrapper pDetail=new ProductDetailWrapper();
                       // pDetail.Price=String.valueOf(steelBrickPrice);                       
                        pDetail.ProductID=String.valueOf(priceBookObjList[i].get('Product__c'));
                        pDetail.ProductName=productLst[productCount].Name;//String.valueOf(priceBookObjList[i].get('Product__c'));
                        pDetail.Price=String.valueOf(priceBookObjList[i].get('Price__c'));
                        pDetail.Quantity = Quantity;
                        pDetail.PrimaryProduct = true;
                        ++productCount;
                        
                        proWrapper.add(pDetail); 
                    }
                    //else // To add the product price of SBQQ__ProductOption__c 
                    {
                        for(optionCount=0;optionCount<optionList.size();++optionCount)
                        {
                            if((optionCount<optionList.size()) && (String.valueOf(optionList[optionCount].SBQQ__OptionalSKU__c)==String.valueOf(priceBookObjList[i].get('Product__c'))))
                            {   
                                system.debug('Option=== '+String.valueOf(optionList[optionCount].SBQQ__OptionalSKU__c)+' == '+String.valueOf(priceBookObjList[i].get('Product__c')));
                              /*  decimal steelBrickPrice= getCalclatedPriceRule(String.valueOf(optionList[optionCount].SBQQ__OptionalSKU__c),String.valueOf(optionList[optionCount].SBQQ__Quantity__c),String.valueOf(priceBookObjList[i].get('Price__c')));
                                system.Debug(steelBrickPrice);
                               */ ProductDetailWrapper pDetail=new ProductDetailWrapper();
                                pDetail.ProductID=String.valueOf(priceBookObjList[i].get('Product__c'));
                                pDetail.ProductName=optionList[optionCount].SBQQ__OptionalSKU__r.Name;//String.valueOf(priceBookObjList[i].get('Product__c'));
                                pDetail.Feature=optionList[optionCount].SBQQ__Feature__r.Name;
                                pDetail.Type=optionList[optionCount].SBQQ__Type__c;
                                pDetail.Quantity=String.valueOf(1);
                                pDetail.ProductFamily=optionList[optionCount].SBQQ__ProductFamily__c;
                                pDetail.Price=String.valueOf(priceBookObjList[i].get('Price__c'));
                                //pDetail.Price=String.valueOf(steelBrickPrice);
                                pDetail.Required= optionList[optionCount].SBQQ__Required__c;
                                pDetail.imageURL=optionList[optionCount].SBQQ__OptionalSKU__r.Product_Image_Link__c ;
                                
                                pDetail.PrimaryProduct =false;
                                proWrapper.add(pDetail);
                                break;
                            }
                        }    
                    }//*/
                    
                }
             }
        }
       
        return proWrapper;
    }
    
    public static decimal getCalclatedPriceRule(string ProdId,String Quantity,String pricevalueDefault)
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
            if(ProdPrice == null)
            {                
                ProdPrice = decimal.valueOf(defaultPrice);
                
            }   
        }               
        return ProdPrice;
    }   
    
    //For creating the JSON string to send back the data to Skuid Page
    public class ProductDetailWrapper
    {
        public String ProductID{get;set;}
        public String ProductName{get;set;}
        public String Price{get;set;}
        public Boolean PrimaryProduct {get;set;}
        public String Feature{get;set;}
        public String Type{get;set;}
        public String Quantity{get;set;}
        public String ProductFamily{get;set;}
        public boolean Required{get;set;}
        public String imageURL{get;set;}
    }
}