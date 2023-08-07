/**
* File:         GenericProductCtrl
* Project:      Event Setup Project
* Created Date: 7th April 2021
* Created By:   Deepak(Girikon) [ESP-90]
* Test Class:   GenericProductCtrl_Test
* Coverage:     100%
* *******************************************************************************************************
* @description : To Add Generic Product On Prospecting Event
* *******************************************************************************************************
* Last Modified By :   
*/
public with sharing class GenericProductCtrl {
    /**
    * @description : get custom metadata records to add generic products.    
    * @return : List<Generic_Product__mdt>
    **/
    @AuraEnabled
    public static List<Generic_Product__mdt> getGenericProductsCustomMetaData(){
        List<Generic_Product__mdt> lstGenericProducts = [SELECT Id,MasterLabel, QualifiedApiName, Product_Name__c, Product_Family__c, Event_Product_Type__c, Product_Description__c, Standard_Unit__c  FROM Generic_Product__mdt Where Active__c=true];
        return  lstGenericProducts;
    }

    /**
    * @description : get custom metadata records to add generic products and Status of Product Addedd or Not.    
    * @param eventId       
    * @return : GVSUpdateResponse
    **/
    @AuraEnabled
    public static GVSUpdateResponse getGenericProductsCustomMetaDataAndStatus(String eventId){
        GVSUpdateResponse resp = new GVSUpdateResponse();
        resp.lstGenericProducts = getGenericProductsCustomMetaData();
        if(Schema.sObjectType.Event_Edition__c.isAccessible()){
            List<Event_Edition__c> eventEditions = [Select Generic_Products_Created__c From Event_Edition__c Where Id=:eventId];
            if(!eventEditions.isEmpty()){
                resp.isProductsCreated = eventEditions[0].Generic_Products_Created__c;
            }
        }
        return  resp;
    }

    /**
    * @description : to create generic products and PBEs.    
    * @param requestString
    **/
    @AuraEnabled
    public static void createProductsAndPBEs(String requestString){
        try{
            WrapRequestSaveProduct requestdata = (WrapRequestSaveProduct)System.JSON.deserialize(requestString, WrapRequestSaveProduct.class);
            List<Generic_Product__mdt> lstGenericProducts = getGenericProductsCustomMetaData();
            List<Pricebook2> lstPricebook = [Select Id From Pricebook2 Where IsStandard=true WITH SECURITY_ENFORCED];
            String standardPBId = (Test.isRunningTest()?(Test.getStandardPricebookId()):(lstPricebook[0].Id));
            List<Product2> genericProds = new List<Product2>();
            List<String> curtencies = requestdata.currencies.split(',');
            Integer index = 0;
            for(Generic_Product__mdt gp : lstGenericProducts){
                index++;
                Product2 prod = new Product2();
                prod.Name = gp.Product_Name__c;
                prod.IsActive = true;
                prod.CurrencyIsoCode = curtencies[0];
                prod.ProductCode = 'GE' + requestdata.eventEditionName.right(2)+requestdata.eventEditionPool+'GEN.'+index;
                prod.Family = gp.Product_Family__c;
                prod.Event_Product_Type__c = gp.Event_Product_Type__c;
                prod.Description = gp.Product_Description__c;
                prod.Prospecting_Generic_Product__c = true;
                if(requestdata.brand != ''){prod.Brand__c = requestdata.brand;}
                prod.Event_Edition_Pool__c = requestdata.eventEditionPool;
                prod.Product_Brand__c = requestdata.eventEditionName;
                prod.Standard_Unit__c = gp.Standard_Unit__c;
                prod.SBQQ__QuantityEditable__c = true;
                prod.SBQQ__DefaultQuantity__c = 1;
                prod.Event_Edition__c = requestdata.eventEditionId;
                prod.Mapped_Event_Edition__c = requestdata.eventEditionId;
                prod.SBQQ__SubscriptionPricing__c = null;
                prod.SBQQ__PriceEditable__c = true;
                prod.SBQQ__ChargeType__c = 'One-Time';
                genericProds.add(prod);
            }
            if(!genericProds.isEmpty() && Schema.sObjectType.Product2.isCreateable()){
                insert genericProds;
                createPBES(genericProds, standardPBId, curtencies);
                createPBES(genericProds, requestdata.eventPriceBookId, curtencies);
            }
        }
        catch(Exception ex){
            System.debug(LoggingLevel.DEBUG, ex.getMessage() + '  ' + ex.getStackTraceString());
        }
    }

    /**
    * @description : to create PBEs.    
    * @param prods   
    * @param pbId 
    * @param currencies
    **/
    private static void createPBES(List<Product2> prods, String pbId, List<String> currencies){
        List<PricebookEntry> pbes = new List<PricebookEntry>();
        for(Product2 prod : prods){
            for(String strCurrency : currencies){
                PricebookEntry pbe = new PricebookEntry();
                pbe.UnitPrice = 0;
                pbe.Product2Id = prod.Id;
                pbe.Pricebook2Id = pbId;
                pbe.IsActive = true;
                pbe.CurrencyIsoCode = strCurrency;
                pbes.add(pbe);
            }
        }
        if(!pbes.isEmpty() && Schema.sObjectType.PricebookEntry.isCreateable()){
            insert pbes;
        }
    }

    /**
    * @description : add value to Global Value Set.    
    * @param requestData request data 
    * @return : GVSUpdateResponse 
    **/
    @AuraEnabled
    public static GVSUpdateResponse addValueToPicklistWithGVS(String requestData){
        Boolean isSuccess = true;
        GVSUpdateResponse respObj = new GVSUpdateResponse();
        try{
            WrapRequest requestObj = (WrapRequest)System.JSON.deserialize(requestData, WrapRequest.class);
            HttpRequest req = new HttpRequest();
            Http httpreq = new Http();
            if(requestObj.isAddGVS){
                req.setHeader('Content-Type', 'application/json');      
                req.setEndpoint('callout:Event_Setup' + Label.Tooling_API_Query_End_Point + 'select+id+from+globalvalueset+Where+developername=\''+requestObj.gvsName+'\'');
                req.setMethod('GET');
                HttpResponse res  = httpreq.send(req);
                GVSQueryResponse gsvResp = (GVSQueryResponse)System.JSON.deserialize(res.getBody(), GVSQueryResponse.class);
                retriveValueSetDetail(gsvResp, requestObj.gvsValue);
            }

            if(requestObj.isCreateDependency){
                req = new HttpRequest();
                req.setHeader('Content-Type', 'application/json');      
                req.setEndpoint('callout:Event_Setup' + Label.Tooling_API_Query_End_Point + 'SELECT+Id,NameSpacePrefix,+DeveloperName,+TableEnumOrId,Metadata+FROM+CustomField+WHERE+TableEnumOrId+=+\''+requestObj.objectApiName+'\'+and+DeveloperName=\''+requestObj.fieldDeveloperName+'\'');
                req.setMethod('GET');
                httpreq = new Http();
                HttpResponse res  = httpreq.send(req);
                respObj.fieldDetail = res.getBody();
            }
        }
        catch(Exception ex){
            isSuccess = false;
            respObj.errorMessage = ex.getMessage() + '  ' + ex.getStackTraceString();
        }
        respObj.isSuccess = isSuccess;
        return respObj;
    }

    /**
    * @description : update field dependency 
    * @param fieldURL Global Value Set Name  
    * @param requestBody Value to be added to Global Value Set  
    * @return : Boolean 
    **/
    @AuraEnabled
    public static Boolean createDependency(String fieldURL, String requestBody){
        HttpRequest req = new HttpRequest();
        req.setBody(requestBody);
        req.setHeader('Content-Type', 'application/json');      
        req.setEndpoint('callout:Event_Setup' + fieldURL +'?_HttpMethod=PATCH');
        req.setMethod('POST');
        Http httpreq = new Http();
        httpreq.send(req);
        return true;
    }

    /**
    * @description : retrive existing values of Global Value Set.    
    * @param gsvResp Global Value Set Name  
    * @param gvsValue Value to be added to Global Value Set 
    **/
    private static void retriveValueSetDetail(GVSQueryResponse gsvResp, String gvsValue){
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type', 'application/json');      
        req.setEndpoint('callout:Event_Setup' + gsvResp.records.get(0).attributes.url);
        req.setMethod('GET');
        Http httpreq = new Http();
        HttpResponse res  = httpreq.send(req);
        GVSDetailResponse gsvDetailResp = (GVSDetailResponse)System.JSON.deserialize(res.getBody().replaceAll('"default":', '"defaultKeyWord":'), GVSDetailResponse.class);

        GVSUpdateRequest gsvUpdateReq = new GVSUpdateRequest();
        gsvUpdateReq.fullName = gsvDetailResp.fullName;
        gsvUpdateReq.metadata = new GVSDetailMetadata();
        gsvUpdateReq.metadata.customValue = gsvDetailResp.metadata.customValue;
        gsvUpdateReq.metadata.masterLabel = gsvDetailResp.metadata.masterLabel;
        gsvUpdateReq.metadata.sorted = false;
        for(GVSDetailValues val : gsvUpdateReq.metadata.customValue){
            if(val.isActive == null)
            {
                val.isActive = true;
            }
        }
        updateValueSet(gsvResp, gvsValue, gsvUpdateReq);
    }

    /**
    * @description : add value to Global Value Set.    
    * @param gsvResp Global Value Set Name  
    * @param gvsValue Value to be added to Global Value Set 
    * @param gsvUpdateReq request data to update Global Value Set 
    **/
    private static void updateValueSet(GVSQueryResponse gsvResp, String gvsValue, GVSUpdateRequest gsvUpdateReq){
        GVSDetailValues gsvValueObj = new GVSDetailValues();
        gsvValueObj.color = null;
        gsvValueObj.defaultKeyWord = false;
        gsvValueObj.description = null;
        gsvValueObj.isActive = true;
        gsvValueObj.urls = null;
        gsvValueObj.label = gvsValue;
        gsvValueObj.valueName = gvsValue;
        gsvUpdateReq.metadata.customValue.add(gsvValueObj);
        String requestBody = JSON.serialize(gsvUpdateReq).replaceAll('"defaultKeyWord":', '"default":');
        HttpRequest req = new HttpRequest();
        req.setBody(requestBody);
        req.setHeader('Content-Type', 'application/json');      
        req.setEndpoint('callout:Event_Setup' + gsvResp.records.get(0).attributes.url+'?_HttpMethod=PATCH');
        req.setMethod('POST');
        Http httpreq = new Http();
        httpreq.send(req);
    }

    private class GVSattributes{
        private String type;
        private String url;
    }

    private class GVSDetail{
        private GVSattributes attributes;
        private String id;
    }

    private class GVSQueryResponse{
        private Integer size;
        private Integer totalSize;
        private Boolean done;
        private String entityTypeName;
        private List<GVSDetail> records;
    }

    private class GVSDetailResponse{
        private GVSattributes attributes;
        private String fullName;
        private String id;
        private String developerName;
        private String masterLabel;
        private String description;
        private String namespacePrefix;
        private String manageableState;
        private GVSDetailMetadata metadata;
    }

    private class GVSUpdateRequest{
        private String fullName;
        private GVSDetailMetadata metadata;
    }

    private class GVSDetailMetadata{
        private List<GVSDetailValues> customValue;
        private String description;
        private String masterLabel;
        private Boolean sorted;
        private String urls;
    }

    private class GVSDetailValues{
        private String color;
        private Boolean defaultKeyWord;
        private String description;
        private Boolean isActive;
        private String label;
        private String urls;
        private String valueName;
    }

    private class WrapRequest{
        private String gvsName;
        private String gvsValue;
        private Boolean isCreateDependency;
        private Boolean isAddGVS;
        private String objectApiName;
        private String fieldDeveloperName;
    }

    private class WrapRequestSaveProduct{
        private String eventEditionId;
        private String eventEditionName;
        private String eventEditionPool;
        private String brand;
        private String currencies;
        private String eventPriceBookId;
    }

    /**
    * @description : to return response for value set addition.    
    **/
    public class GVSUpdateResponse{
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public String fieldDetail;
        @AuraEnabled public String errorMessage;
        @AuraEnabled public List<Generic_Product__mdt> lstGenericProducts;
        @AuraEnabled public Boolean isProductsCreated;
    }
}