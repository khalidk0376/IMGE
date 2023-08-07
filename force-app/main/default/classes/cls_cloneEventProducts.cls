//Purpose : To clone products on the basis of Event Editions

public class cls_cloneEventProducts{
    String sourceEventEdition;
    String targetEventEdition;
    String eventId;
    
    
    public List<CPQ_Product_Clone__c> lstCPQProdClone { get; set; }
    
    public cls_cloneEventProducts(){
        // constructor
        system.debug('Constructor Being Called'); // Added by Palla Kishore for the ticket BK-19604
    }
    
    public void eventProductsSearch(){
    
    sourceEventEdition = ApexPages.currentPage().getParameters().get('sourceEventEdition');
    targetEventEdition = ApexPages.currentPage().getParameters().get('targetEventEdition');
    eventId = ApexPages.currentPage().getParameters().get('eventId');
    
     lstCPQProdClone = new List<CPQ_Product_Clone__c>();
     lstCPQProdClone = [Select id,name,Event_Series__c,Cloned__c,Source_Event_Edition__c,Target_Event_Edition__c From CPQ_Product_Clone__c Where id =:eventId];
        
        
                
        if(!lstCPQProdClone[0].Cloned__c){
            if(ApexPages.currentPage().getParameters() != null && ApexPages.currentPage().getParameters().size() > 0){

                List<Event_Edition__c> lstEventEdition = [select id,name,Start_Date__c,End_Date__c 
                                                        from Event_Edition__c where Name =:lstCPQProdClone[0].Target_Event_Edition__c];
                
                System.debug('------ lstCPQProdClone: '+ lstCPQProdClone);
                
                List<Product2> lstProd = [Select Booth_Number__c,Booth_Product_Type__c,Booth_Sq_Ft__c,Brand__c,
                                    CreatedById,CreatedDate,Credit_Deferred_Revenue__c,Credit_Revenue__c,CurrencyIsoCode,Deliverables__c,
                                    Department_Description__c,Description,Description_GS__c,Digital_Program_Exception__c,Display_Size__c,
                                    End_Date__c,Event_Area__c,Event_Edition_GHNN_filter__c,Event_Edition_GHNN__c,Event_Edition_LFSC__c,
                                    Event_Edition_Pool__c,Event_Edition_TISE_filter__c,Event_Edition_TISE__c,Event_Edition_WOC_filter__c,
                                    Event_Edition_WOC__c,Event_Ops_Category__c,Event_Product_Type_Filter__c,Event_Product_Type__c,
                                    Expired_filter__c,Expired__c,Expiry_Date__c,ExpoCAD_Product__c,Family,FamilyOfProduct__c,
                                    Family_GS__c,GL_Code__c,GL_Distribution_Scheme__c,Id,Internal_SB_Code__c,IsActive,
                                    IsDeleted,Is_Bundle_Billing__c,LastModifiedById,LastModifiedDate,LastReferencedDate,
                                    LastViewedDate,Marketing_Services_Required__c,Mgmt_Rpt_Code__c,Mgmt_Rpt_Description__c,
                                    Min_Units__c,Name,Note1__c,Number_of_Corners__c,ProductCode,ProductFamily__c,Product_Brand__c,
                                    Product_Life__c,Product_Specs__c,ResourceID__c,SBQQ__AssetAmendmentBehavior__c,SBQQ__AssetConversion__c,
                                    SBQQ__BatchQuantity__c,SBQQ__BillingFrequency__c,SBQQ__BillingType__c,SBQQ__BlockPricingField__c,SBQQ__ChargeType__c,
                                    SBQQ__Component__c,SBQQ__CompoundDiscountRate__c,SBQQ__ConfigurationEvent__c,SBQQ__ConfigurationFieldSet__c,
                                    SBQQ__ConfigurationFields__c,SBQQ__ConfigurationFormTitle__c,SBQQ__ConfigurationType__c,
                                    SBQQ__ConfigurationValidator__c,SBQQ__ConfiguredCodePattern__c,SBQQ__ConfiguredDescriptionPattern__c,
                                    SBQQ__CostEditable__c,SBQQ__CostSchedule__c,SBQQ__CustomConfigurationPage__c,SBQQ__CustomConfigurationRequired__c,
                                    SBQQ__CustomerCommunityAvailability__c,SBQQ__DefaultPricingTable__c,SBQQ__DefaultQuantity__c,
                                    SBQQ__DescriptionLocked__c,SBQQ__DiscountCategory__c,SBQQ__DiscountSchedule__c,SBQQ__DynamicPricingConstraint__c,
                                    SBQQ__ExcludeFromMaintenance__c,SBQQ__ExcludeFromOpportunity__c,SBQQ__ExternallyConfigurable__c,
                                    SBQQ__GenerateContractedPrice__c,SBQQ__HasConfigurationAttributes__c,SBQQ__Hidden__c,
                                    SBQQ__HidePriceInSearchResults__c,SBQQ__IncludeInMaintenance__c,SBQQ__NewQuoteGroup__c,
                                    SBQQ__NonDiscountable__c,SBQQ__NonPartnerDiscountable__c,SBQQ__Optional__c,SBQQ__OptionLayout__c,
                                    SBQQ__OptionSelectionMethod__c,SBQQ__PriceEditable__c,SBQQ__PricingMethodEditable__c,
                                    SBQQ__PricingMethod__c,SBQQ__ProductPictureID__c,SBQQ__QuantityEditable__c,SBQQ__QuantityScale__c,
                                    SBQQ__ReconfigurationDisabled__c,SBQQ__RenewalProduct__c,SBQQ__SortOrder__c,SBQQ__Specifications__c,
                                    SBQQ__SubscriptionBase__c,SBQQ__SubscriptionCategory__c,SBQQ__SubscriptionConversion__c,
                                    SBQQ__SubscriptionPercent__c,SBQQ__SubscriptionPricing__c,SBQQ__SubscriptionTarget__c,
                                    SBQQ__SubscriptionTerm__c,SBQQ__SubscriptionType__c,SBQQ__Taxable__c,SBQQ__TaxCode__c,
                                    SBQQ__TermDiscountLevel__c,SBQQ__TermDiscountSchedule__c,SBQQ__UpgradeCredit__c,
                                    SBQQ__UpgradeRatio__c,SBQQ__UpgradeSource__c,SBQQ__UpgradeTarget__c,SB_Internal_Code__c,
                                    Standard_Unit__c,Stand_UM__c,Start_Date__c,SystemModstamp,Tax_Category__c,
                                    Video_Digital_Product__c,
                                    (Select id,CurrencyIsoCode,Name,SBQQ__MinOptionCount__c,SBQQ__Number__c,SBQQ__ConfiguredSKU__c from SBQQ__Features__r)
                                    FROM Product2 
                                    WHERE Product_Brand__c =:sourceEventEdition];
                
                System.debug('----- List Of Products: ' + lstProd.size());
                System.debug('----- List Of Products: ' + lstProd);
                
                if(lstProd != null && lstProd.size() > 0){
                    //List<Product2> lstCloneProduct = new List<Product2>();
                    String targetYearString;
                    Map<Id, Product2> mapIdProd = new Map<Id, Product2>();
                    
                    for(Product2 eachProd : lstProd){
                        Product2 objProd = new Product2();
                        objProd = eachProd.clone(false, false, false, false);
                        
                        if(lstCPQProdClone[0].Target_Event_Edition__c !='')
                            targetYearString = string.valueof(lstCPQProdClone[0].Target_Event_Edition__c.right(4));
                        
                        if(objProd.ProductCode != null && objProd.ProductCode !='')
                            objProd.ProductCode = objProd.ProductCode.substring(0, objProd.ProductCode.length()-4) + targetYearString;
                        
                        if(lstCPQProdClone[0].Event_Series__c != '')
                            objProd.Brand__c = lstCPQProdClone[0].Event_Series__c;
                        
                        if(lstCPQProdClone[0].Target_Event_Edition__c != '')
                            objProd.Product_Brand__c = lstCPQProdClone[0].Target_Event_Edition__c;
                        
                        if(lstEventEdition !=null && lstEventEdition.size()>0){
                            if(lstEventEdition[0].Start_Date__c != null)
                            objProd.Start_Date__c = lstEventEdition[0].Start_Date__c;
                            
                            if(lstEventEdition[0].End_Date__c != null)
                            objProd.End_Date__c = lstEventEdition[0].End_Date__c;
                        }
                        
                        if(lstCPQProdClone[0].Target_Event_Edition__c!=''){
                            objProd.Event_Edition_WOC__c =lstCPQProdClone[0].Target_Event_Edition__c;
                        }
                        
                        mapIdProd.put(eachProd.Id, objProd);
                    }
                    
                    if(mapIdProd.values() != null && mapIdProd.values().size()>0){
                        try{
                            //if(!lstCPQProdClone[0].Cloned__c){
                                insert mapIdProd.values();
                            system.debug('values' + mapIdProd.values());
                                lstCPQProdClone[0].Cloned__c = true;
                                update lstCPQProdClone;
                                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Products/Packages for the Event Edition '+ lstCPQProdClone[0].Target_Event_Edition__c +' are cloned successfully'));
                            
                                system.debug('I am here-------!!!!');
                           // }
                            /*else{
                                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Products/Packages for the Event Edition '+ lstCPQProdClone[0].Target_Event_Edition__c +' already exists'));
                            
                                system.debug('I am here-------@@@@@');
                            }*/
                        }
                        catch(exception ex){
                            system.debug('exception--->'+ex.getlineNumber());
                        }
                    }
                   
                   //standard pricebook entries
                   if(mapIdProd.values() != null && mapIdProd.values().size()>0){ 
                       List<PriceBookEntry> lstPriceBookEntry = [Select Id, Product2Id,IsActive, Product2.Name, ProductCode, UnitPrice, Pricebook2Id,Pricebook2.isActive, UseStandardPrice 
                                                            from PriceBookEntry 
                                                            WHERE Product2Id IN :lstProd AND Pricebook2.IsStandard = true];
                        List<PriceBookEntry> lstPriceBookEntryClone = new List<PriceBookEntry>();
                        if(lstPriceBookEntry != null && lstPriceBookEntry.size() > 0){
                            for(PriceBookEntry eachPriceBookEntry : lstPriceBookEntry){ 
                                PriceBookEntry objPriceBookEntry = new PriceBookEntry();
                                objPriceBookEntry = eachPriceBookEntry.clone(false, false, false, false);
                                /*if(mapIdProd!=null && mapIdProd.size()>0 && mapIdProd.get(eachPriceBookEntry.Product2Id).Id !=null && mapIdProd.get(eachPriceBookEntry.Product2Id).Id !=''){
                                    objPriceBookEntry.Product2Id = mapIdProd.get(eachPriceBookEntry.Product2Id).Id;
                                }*/
                                objPriceBookEntry.Product2Id =  mapIdProd!=null&& mapIdProd.size()>0 &&  mapIdProd.containskey(eachPriceBookEntry.Product2Id)?mapIdProd.get(eachPriceBookEntry.Product2Id).id:null ;lstPriceBookEntryClone.add(objPriceBookEntry);
                            }
                            
                            if(lstPriceBookEntryClone!=null && lstPriceBookEntryClone.size()>0){
                                try{
                                    insert lstPriceBookEntryClone;}
                                catch(exception ex){                                 
                                   //BK-3754          
                                        Utility.logsError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'cls_cloneEventProducts' , 'Integration');
                                }
                            }
                        }
                        
                       //custom pricebook entries
                       List<PriceBookEntry> lstPriceBookEntryCustom = [Select Id, Product2Id,IsActive, Product2.Name, ProductCode, UnitPrice, Pricebook2Id, UseStandardPrice 
                                                            from PriceBookEntry 
                                                            WHERE Product2Id IN :lstProd AND Pricebook2.IsStandard = false];
                        List<PriceBookEntry> lstPriceBookEntryCustomClone = new List<PriceBookEntry>();
                        if(lstPriceBookEntry != null && lstPriceBookEntry.size() > 0){
                            for(PriceBookEntry eachPriceBookEntry : lstPriceBookEntryCustom){
                                PriceBookEntry objPriceBookEntry = new PriceBookEntry();
                                objPriceBookEntry = eachPriceBookEntry.clone(false, false, false, false);
                                /*if(mapIdProd!=null && mapIdProd.size()>0 && mapIdProd.containskey(eachPriceBookEntry.Product2Id)){
                                    objPriceBookEntry.Product2Id = mapIdProd.get(eachPriceBookEntry.Product2Id).Id;
                                }*/
                                objPriceBookEntry.Product2Id =  mapIdProd!=null&& mapIdProd.size()>0 &&  mapIdProd.containskey(eachPriceBookEntry.Product2Id)?mapIdProd.get(eachPriceBookEntry.Product2Id).id:null ;
                                lstPriceBookEntryCustomClone.add(objPriceBookEntry);
                            }
                            
                            if(lstPriceBookEntryClone!=null && lstPriceBookEntryClone.size()>0){
                                try{
                                    insert lstPriceBookEntryCustomClone;
                                }
                                catch(exception ex){
                                    Utility.logsError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'cls_cloneEventProducts' , 'Integration');}
                           //BK - 3754
                            }
                        }
                    
                    }
                    // Insert Features for the Products
                    map<id,SBQQ__ProductFeature__c> mapIdFeature = new map<id,SBQQ__ProductFeature__c>();
                    
                    list<SBQQ__ProductFeature__c> lstProductFeatureClone = new list<SBQQ__ProductFeature__c>();
                    for(SBQQ__ProductFeature__c eachFeature : [Select CreatedById,CreatedDate,CurrencyIsoCode,Id,IsDeleted,LastModifiedById,LastModifiedDate,
                                                                LastReferencedDate,LastViewedDate,Name,Product_Brand__c,SBQQ__Category__c,SBQQ__ConfigurationFieldSet__c,SBQQ__ConfiguredSKU__c,
                                                                SBQQ__DiscountSchedule__c,SBQQ__DynamicProductFilterFieldSet__c,SBQQ__DynamicProductLookupFieldSet__c,SBQQ__MaxOptionCount__c,
                                                                SBQQ__MinOptionCount__c,SBQQ__Number__c,SBQQ__OptionSelectionMethod__c,SystemModstamp 
                                                                from SBQQ__ProductFeature__c where SBQQ__ConfiguredSKU__c IN :lstProd]){
                                                                
                        SBQQ__ProductFeature__c objFeatures = new SBQQ__ProductFeature__c ();
                        objFeatures = eachFeature.clone(false, false, false, false);
                        objFeatures.SBQQ__ConfiguredSKU__c = mapIdProd.get(eachFeature.SBQQ__ConfiguredSKU__c).id;
                        lstProductFeatureClone.add(objFeatures);
                        
                        mapIdFeature.put(eachFeature.id, objFeatures);
                    }
                    
                    /*if(lstProductFeatureClone!=null && lstProductFeatureClone.size()>0){
                        insert lstProductFeatureClone;
                    }*/
                    
                    if(mapIdFeature != null && mapIdFeature.size() > 0 && mapIdFeature.values().size()>0){
                        try{
                            insert mapIdFeature.values();
                        }
                        catch(exception ex){
                            system.debug('exception--->'+ex.getlineNumber());
                        }
                    }
                    
                    // Insert Options for the Products
                    list<SBQQ__ProductOption__c> lstProductOptionsClone = new list<SBQQ__ProductOption__c>();
                    for(SBQQ__ProductOption__c eachProdOptions : [Select CreatedById,CreatedDate,CurrencyIsoCode,End_Date__c,Event_Area__c,Event_Edition_GHNN_filter__c,Event_Edition_Pool__c,
                                                                    Event_Edition_TISE_filter__c,Event_Edition_WOC_filter__c,Event_Edition__c,Event_Product_Type_Filter__c,
                                                                    Event_Product_Type__c,Expired_filter__c,Expired__c,FamilyOfProduct__c,Id,Internal_SB_Code__c,IsDeleted,
                                                                    LastModifiedById,LastModifiedDate,Name,Product_Specs__c,SBQQ__AppliedImmediatelyContext__c,
                                                                    SBQQ__AppliedImmediately__c,SBQQ__Bundled__c,SBQQ__ComponentCodePosition__c,SBQQ__ComponentCode__c,
                                                                    SBQQ__ComponentDescriptionPosition__c,SBQQ__ComponentDescription__c,SBQQ__ConfiguredSKU__c,SBQQ__DefaultPricingTable__c,
                                                                    SBQQ__DiscountAmount__c,SBQQ__DiscountedByPackage__c,SBQQ__DiscountSchedule__c,SBQQ__Discount__c,
                                                                    SBQQ__ExistingQuantity__c,SBQQ__Feature__c,SBQQ__MaxQuantity__c,SBQQ__MinQuantity__c,SBQQ__Number__c,
                                                                    SBQQ__OptionalSKU__c,SBQQ__PriceEditable__c,SBQQ__ProductCode__c,SBQQ__ProductConfigurationType__c,
                                                                    SBQQ__ProductDescription__c,SBQQ__ProductFamily__c,SBQQ__ProductName__c,SBQQ__ProductQuantityScale__c,
                                                                    SBQQ__ProductSubscriptionPricing__c,SBQQ__QuantityEditable__c,SBQQ__Quantity__c,SBQQ__QuoteLineVisibility__c,
                                                                    SBQQ__RenewalProductOption__c,SBQQ__Required__c,SBQQ__Selected__c,SBQQ__SubscriptionScope__c,SBQQ__System__c,
                                                                    SBQQ__Type__c,SBQQ__UnitPrice__c,SBQQ__UpliftedByPackage__c,Specifications__c,Start_Date__c,SystemModstamp,
                                                                    UOM__c from SBQQ__ProductOption__c  where SBQQ__ConfiguredSKU__c IN :lstProd]){
                        
                        SBQQ__ProductOption__c objOptions = new SBQQ__ProductOption__c();
                        objOptions = eachProdOptions.clone(false, false, false, false);
                        objOptions.SBQQ__ConfiguredSKU__c = mapIdProd.get(eachProdOptions.SBQQ__ConfiguredSKU__c).id;
                        objOptions.SBQQ__OptionalSKU__c = mapIdProd.get(eachProdOptions.SBQQ__OptionalSKU__c).id;   
                        objOptions.SBQQ__Feature__c =mapIdFeature != null && mapIdFeature.size() > 0 && mapIdFeature.containsKey(eachProdOptions.SBQQ__Feature__c) ? 
                                                mapIdFeature.get(eachProdOptions.SBQQ__Feature__c).id : null;
                        lstProductOptionsClone.add(objOptions);                    
                    }
                    
                    if(lstProductOptionsClone!=null && lstProductOptionsClone.size()>0){
                        try{
                            insert lstProductOptionsClone;
                        }
                        catch(exception ex){
                            system.debug('exception--->'+ex.getlineNumber());
                        }
                    }
                    
                    system.debug('mapIdFeature------->'+mapIdFeature.values().size());
                    
                    // Insert Config Rules for the Products
                    
                    list<SBQQ__ConfigurationRule__c> lstProductConfigRulesClone = new list<SBQQ__ConfigurationRule__c>();
                    for(SBQQ__ConfigurationRule__c eachProdConfigRules :[select CreatedById,CreatedDate,CurrencyIsoCode,Id,IsDeleted,LastModifiedById,
                                                                        LastModifiedDate,Name,SBQQ__Active__c,SBQQ__AscendingNestedLevel__c,SBQQ__DescendingActionNesting__c,
                                                                        SBQQ__DescendingNestedLevel__c,SBQQ__ProductFeature__c,SBQQ__ProductRule__c,SBQQ__Product__c,
                                                                        SBQQ__RuleEvaluationEvent__c,SBQQ__RuleType__c,SystemModstamp 
                                                                        from SBQQ__ConfigurationRule__c WHERE SBQQ__Product__c IN :lstProd]){
                                                                        
                        SBQQ__ConfigurationRule__c objConfigRules = new SBQQ__ConfigurationRule__c();
                        objConfigRules = eachProdConfigRules.clone(false, false, false, false);
                        objConfigRules.SBQQ__Product__c = mapIdProd.get(eachProdConfigRules.SBQQ__Product__c).id;
                        
                        objConfigRules.SBQQ__ProductFeature__c = mapIdFeature != null && mapIdFeature.size() > 0 && mapIdFeature.containsKey(eachProdConfigRules.SBQQ__ProductFeature__c) ? 
                                                mapIdFeature.get(eachProdConfigRules.SBQQ__ProductFeature__c).id : null;
                        
                        lstProductConfigRulesClone.add(objConfigRules);
                    }
                    
                    if(lstProductConfigRulesClone!=null && lstProductConfigRulesClone.size()>0){
                        try{
                            insert lstProductConfigRulesClone;
                        }
                        catch(exception ex){
                            system.debug('exception--->'+ex.getlineNumber());
                        }
                        system.debug('config rules list----->'+lstProductConfigRulesClone);
                    }
                }
                else{
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'No Products/Packages found for '+ lstCPQProdClone[0].Source_Event_Edition__c));
                }
            }
        }
        else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Products/Packages for the Event Edition '+ lstCPQProdClone[0].Target_Event_Edition__c +' already exists'));
        }   
    }

     public pageReference cancelRecord(){
        PageReference pageRef = new PageReference('/'+lstCPQProdClone[0].id);
        pageRef.setRedirect(true);
        return pageRef;
    }
}