/**
* File:        SBProductConfiguration.cls
* Project:     GAP
* Date:        Aug 27, 2017
* Created By:  Kumar Gaurav
* *************************************************************************
* Description: Returns All valid Products after applying Product Rule.
* *************************************************************************
* History:
* Test Class : BoothSelectionCtrl_Test
*/ 
public class SBProductConfiguration { 
    //Public  Product2 packagePrd; 
    Public  SBQQ__ProductOption__c[] optionList;
    Public  SBQQ__Quote__c quoteRec; 
    Public  TinyQuoteModel tinyQuote;
    List<TinyConfigurationModel> optionConfigurations ;
 
    /** 
     * These configuration attributes are initialized with everything about them already set except for the product they 
     * target, which is set in a later method that also inserts them into the database. 
     * 
     * This case is demonstrate that configuration attributes work in the context of the API. 
     */ 

    Public class ProductLoadContext { 
        public Id pricebookId; 
        public String currencyCode; 
    } 
 
    Public class ConfigLoadContext { 
        public TinyQuoteModel quote; 
        public TinyProductModel parentProduct; // Only required if the configuration must inherit Configuration Attribute values from its parent. 
    } 
 
    Public class LoadRuleRunnerContext { 
        public TinyQuoteModel quote; 
        public String[] dynamicOptionSkus; 
        public TinyConfigurationModel configuration; 
        public TinyProductModel parentProduct; // Only required if the configuration must inherit Configuration Attributes from the parent. 
    } 
 
    Public class ValidationContext { 
        public TinyQuoteModel quote; 
        public TinyConfigurationModel configuration; 
        public Id upgradedAssetId; 
        public String event; 
    } 
 
    // ============ MODEL CLASSES ========= 
 
    Public class TinyProductModel { 
        public Product2 record; 
        public String currencyCode; 
        public TinyOptionModel[] options; 
        public TinyFeatureModel[] features; 
        public TinyConfigurationModel configuration; 
        public TinyConfigAttributeModel[] configurationAttributes; 
        public TinyConfigAttributeModel[] inheritedConfigurationAttributes; 
        public TinyConstraintModel[] constraints; 
    } 
 
    Public class TinyConstraintModel { 
        public SBQQ__OptionConstraint__c record; 
        public Boolean priorOptionExists; 
    } 
 
    Public class TinyOptionModel { 
        public SBQQ__ProductOption__c record; 
        public Map<String,String> externalConfigurationData; 
        public Boolean configurable; 
        public Boolean configurationRequired; 
        public Boolean quantityEditable; 
        public Boolean priceEditable; 
        public Decimal productQuantityScale; 
        public Boolean priorOptionExists; 
        public Set<Id> dependentIds; 
        public Map<String,Set<Id>> controllingGroups; 
        public Map<String,Set<Id>> exclusionGroups; 
        public String reconfigureDimensionWarning; 
        public Boolean hasDimension; 
        public Boolean isUpgrade; 
        public String dynamicOptionKey; 
    } 
 
    Public class TinyConfigAttributeModel { 
        public String name; 
        public String targetFieldName; // Corresponds directly to SBQQ__ConfigurationAttribute__c.SBQQ__TargetField__c 
        public Decimal displayOrder; // Corresponds directly to SBQQ__ConfigurationAttribute__c.SBQQ__DisplayOrder__c 
        public String columnOrder; // Corresponds directly to SBQQ__ConfigurationAttribute__c.SBQQ__ColumnOrder__c 
        public Boolean required; // Corresponds directly to SBQQ__ConfigurationAttribute__c.SBQQ__Required__c 
        public Id featureId; // Corresponds directly to SBQQ__ConfigurationAttribute__c.SBQQ__Feature__c 
        public String position; // Corresponds directly to SBQQ__ConfigurationAttribute__c.SBQQ__Position__c 
        public Boolean appliedImmediately; // Corresponds directly to SBQQ__ConfigurationAttribute__c.SBQQ__AppliedImmediately__c 
        public Boolean applyToProductOptions; // Corresponds directly to SBQQ__ConfigurationAttribute__c.SBQQ__ApplyToProductOptions__c 
        public Boolean autoSelect; // Corresponds directly to SBQQ__ConfigurationAttribute__c.SBQQ__AutoSelect__c 
        public String[] shownValues; // Corresponds directly to SBQQ__ConfigurationAttribute__c.SBQQ__ShownValues__c 
        public String[] hiddenValues; // Corresponds directly to SBQQ__ConfigurationAttribute__c.SBQQ__HiddenValues__c 
        public Boolean hidden; // Corresponds directly to SBQQ__ConfigurationAttribute__c.SBQQ__Hidden__c 
        public String noSuchFieldName; // If no field with the target name exists, the target name is stored here. 
        public Id myId; // Corresponds directly to SBQQ__ConfigurationAttribute__c.Id 
    } 
 
    Public class TinyFeatureModel { 
        public SBQQ__ProductFeature__c record; 
        public String instructionsText; 
        public Boolean containsUpgrades; 
    } 
 
    Public class TinyConfigurationModel { 
        public Id configuredProductId; 
        public Id optionId; 
        public SBQQ__ProductOption__c optionData; // Editable data about the option in question, such as quantity or discount 
        public SBQQ__ProductOption__c configurationData; 
        public SBQQ__ProductOption__c inheritedConfigurationData; 
        public TinyConfigurationModel[] optionConfigurations; 
        public Boolean configured; 
        public Boolean changedByProductActions; 
        public Boolean isDynamicOption; 
        public Boolean isUpgrade; 
        public Set<Id> disabledOptionIds; 
        public Set<Id> hiddenOptionIds; 
        public Decimal listPrice; 
        public Boolean priceEditable; 
        public String[] validationMessages; 
        public String dynamicOptionKey; 
    } 
 
    Public class TinyQuoteModel { 
        public SBQQ__Quote__c record; 
        public TinyQuoteLineModel[] lineItems; 
        public TinyQuoteLineGroupModel[] lineItemGroups; 
 
        public Integer nextKey; 
        public Boolean applyAdditionalDiscountLast; 
        public Boolean applyPartnerDiscountFirst; 
        public Boolean channelDiscountsOffList; 
        public Decimal customerTotal; 
        public Decimal netTotal; 
        public Decimal netNonSegmentTotal; 
    } 
 
    Public class TinyQuoteLineModel { 
        public SBQQ__QuoteLine__c record; 
        public Decimal renewalPrice; 
        public Boolean amountDiscountProrated; 
        public Integer parentGroupKey; 
        public Integer parentItemKey; 
        public Integer key; 
        public Boolean upliftable; 
        public String configurationType; 
        public String configurationEvent; 
        public Boolean reconfigurationDisabled; 
        public Boolean descriptionLocked; 
        public Boolean productQuantityEditable; 
        public Decimal productQuantityScale; 
        public String dimensionType; 
        public Boolean productHasDimensions; 
        public Decimal targetCustomerAmount; 
        public Decimal targetCustomerTotal; 
    } 
 
    Public class TinyQuoteLineGroupModel { 
        public SBQQ__QuoteLineGroup__c record; 
        public Decimal netNonSegmentTotal; 
        public Integer key; 
    }
 
    Public  void setUpTinyQuote(Id PriceBookId) {
        System.debug('setUpTinyQuote Started ');
        quoteRec = new SBQQ__Quote__c(SBQQ__PricebookId__c = PriceBookId); 
        tinyQuote = new TinyQuoteModel(); 
        tinyQuote.record = quoteRec; 
    } 
 
    Public  TinyProductModel loadProductUsingProductAPI(Id productId, Id PriceBookId) {
        System.debug('loadProductUsingProductAPI Started ');
        ProductLoadContext context = new ProductLoadContext(); 
        context.currencyCode = null; 
        context.pricebookId = PriceBookId; 
        String pJson = SBQQ.ServiceRouter.load('ProductAPI.ProductLoader', productId, JSON.serialize(context));
        System.Debug('pJson :: '+pJson);
        TinyProductModel pModel = (TinyProductModel)JSON.deserialize(pJson, TinyProductModel.class); 
        return pModel; 
    } 
    
    public string dynamicQuery(string SobjectApiName){
        String commaSepratedFields = '';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();

        for(String fieldName : fieldMap.keyset()){
            if(commaSepratedFields == null || commaSepratedFields == ''){
                commaSepratedFields = fieldName;
            }else{
                commaSepratedFields = commaSepratedFields + ', ' + fieldName;
            }
        }
        return commaSepratedFields;
    }
    
    public void setupDummyOption(Id prdOptionId, Id selectedPrdId, Decimal PrdQuantity){   
        SBQQ__ProductOption__c tempOptionData;
        optionConfigurations = new List<TinyConfigurationModel>();
        String sDynamicQuery = dynamicQuery('SBQQ__ProductOption__c');
        String query = 'SELECT ' + String.escapeSingleQuotes(sDynamicQuery) + ' FROM SBQQ__ProductOption__c WHERE Id =\''+String.escapeSingleQuotes(prdOptionId)+'\'';
        List<SBQQ__ProductOption__c> lstOption = Database.query(query);
        if(!lstOption.isEmpty()){
            tempOptionData = lstOption.get(0);
            tempOptionData.SBQQ__Selected__c = True;
            tempOptionData.SBQQ__Quantity__c =  PrdQuantity;
            // Initialized Dummy ConfigurationModel
            TinyConfigurationModel oTempConfgModel = new TinyConfigurationModel();
            oTempConfgModel.configuredProductId = selectedPrdId;
            oTempConfgModel.optionId = prdOptionId;
            oTempConfgModel.configured = false;
            oTempConfgModel.changedByProductActions = false;
            oTempConfgModel.isDynamicOption = false;
            oTempConfgModel.isUpgrade = false;
            oTempConfgModel.priceEditable = false;
            oTempConfgModel.optionData=tempOptionData;
            oTempConfgModel.configurationData = new SBQQ__ProductOption__c();
            oTempConfgModel.optionConfigurations = new List<TinyConfigurationModel>();
            oTempConfgModel.validationMessages = new List<String>();
            optionConfigurations.add(oTempConfgModel);
            System.debug('OptionConfigurations Size ::: '+optionConfigurations.size());
        }
    }
 
    public TinyConfigurationModel getConfigurationAfterFireProductRule(Id PrdPackageId, Id PriceBookId, Id SelectedPrdOption, Id SelectedProduct, Decimal SelectedPrdQuantity) {
        //packagePrd = [SELECT Id, Name, IsActive, SBQQ__ConfigurationType__c FROM Product2 WHERE Id=: PrdPackageId];
        this.setUpTinyQuote(PriceBookId);
        this.setupDummyOption(SelectedPrdOption, SelectedProduct, SelectedPrdQuantity);
        TinyProductModel parentModel = this.loadProductUsingProductAPI(PrdPackageId, PriceBookId); 
        System.Debug('ParentModel PreSelected optionConfigurations size :: '+parentModel.configuration.optionConfigurations.size());
        System.Debug('Dummy optionConfigurations size :: '+optionConfigurations.size());
        // Adding dummy OptionConfiguration for selected Product
        parentModel.configuration.optionConfigurations.addAll(optionConfigurations);
        System.Debug('ParentModel after dummy adding optionConfigurations size :: '+parentModel.configuration.optionConfigurations.size());

        ValidationContext context = new ValidationContext(); 
        context.quote = tinyQuote; 
        context.configuration = parentModel.configuration; 
        // context.event = 'Always';
        context.event = 'Edit';
        System.debug('Final ValidationContext :: '+ JSON.serialize(parentModel.configuration)); 
        
        // Run the context through the validator and confirm that Product Rule is applied
        String resultJson = SBQQ.ServiceRouter.load('ConfigAPI.ConfigurationValidator', '', JSON.serialize(context)); 
        TinyConfigurationModel resultModel = (TinyConfigurationModel)JSON.deserialize(resultJson, TinyConfigurationModel.class); 
        System.Debug('OptionConfigurations size after Product Rule applied :: '+resultModel.optionConfigurations.size());
        System.Debug('resultJson :: '+resultJson);
        return resultModel;
    }
}