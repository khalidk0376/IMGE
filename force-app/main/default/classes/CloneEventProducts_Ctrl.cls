/**
* File:        CloneEventProducts_Ctrl.cls
* Project:     GAP
* Date:        June 15, 2017
* Created By:  Kumar Gaurav and Himanshu Jasuja
* Test Class:  test_CloneEventProducts_Ctrl

* *************************************************************************
* Description: Apex Controller to clone Event Edition's Products for another
               Event Edition.
* *************************************************************************
* History:
*/
//Ticket No. BK-14521 Updating API Version
public class CloneEventProducts_Ctrl{
    
    public CPQ_Product_Clone__c oCPQProdClone {get; set;}
    public Event_Edition__c oTargetEE {get; set;}
    public Event_Edition__c oSourceEE {get; set;}
    public String sCPQProdId {get; set;}
    public String isCloned {get; set;}
    public List<Product2> lstProdOfSourceEE{get;set;}
    public List<PriceBookEntry> lstStdPBEntry{get;set;}
    public List<PriceBookEntry> lstCustomPBEntry{get;set;}
    public List<SBQQ__ProductFeature__c> lstProdFeature{get;set;}
    public List<SBQQ__ProductOption__c> lstProdOption{get;set;}
    public List<SBQQ__ConfigurationRule__c> lstProdConf{get;set;}   
    public String query{get;set;}
    public List<Sobject> lstofSobj{get;set;}  
    public Map<String,String> mapOflabelVsObject{get;set;} 
    public String typeName{get;set;}
    public sObject obj {get;set;}
    public String sDynamicQuery{get;set;}

    

    public CloneEventProducts_Ctrl(){
        
        
        sCPQProdId = ApexPages.currentPage().getParameters().get('CPC_Id');
        System.debug('CPQ Prd Id : '+ sCPQProdId);      
        List<CPQ_Product_Clone__c> lstCPQProdClone =  [SELECT Id, Name, Event_Series__c, Price_Lookup_Table__c , Cloned__c, Source_Event_Edition__c, Target_Event_Edition__c FROM CPQ_Product_Clone__c WHERE id =: sCPQProdId];     
        if(lstCPQProdClone != null && lstCPQProdClone.size() > 0){
            oCPQProdClone = lstCPQProdClone.get(0);
        }
        
        List<Event_Edition__c> lstSourceEventEdition = [SELECT Id, Name, Start_Date__c, End_Date__c FROM Event_Edition__c WHERE Name =: oCPQProdClone.Source_Event_Edition__c ];
        List<Event_Edition__c> lstTargetEventEdition = [SELECT Id, Name, Start_Date__c, End_Date__c FROM Event_Edition__c WHERE Name =: oCPQProdClone.Target_Event_Edition__c ];
        if(lstSourceEventEdition != null && lstSourceEventEdition.size() > 0){
            oSourceEE = lstSourceEventEdition.get(0);
            System.debug('Source' +oSourceEE);
        }
        if(lstTargetEventEdition != null && lstTargetEventEdition.size() > 0){
            oTargetEE = lstTargetEventEdition.get(0);
            System.debug('Source' +oTargetEE);
        }
        isCloned = 'No';
        
         mapOflabelVsObject = new Map<String,String>();
            for(Schema.SObjectType f : Schema.getGlobalDescribe().Values() )
            {
                if(f.getDescribe().isCustom())
                {
                mapOflabelVsObject.put(f.getDescribe().getLabel(),f.getDescribe().getName());
                system.debug('mapOflabelVsObject::'+mapOflabelVsObject);
                }
            } 
            
            if(mapOflabelVsObject.containsKey(oCPQProdClone.Price_Lookup_Table__c)){
                                        
                typeName = mapOflabelVsObject.get(oCPQProdClone.Price_Lookup_Table__c);
                system.debug('typeName::'+typeName);
                Schema.SObjectType targetType = Schema.getGlobalDescribe().get(typeName);
                obj = targetType.newSObject();
            }
    }
   
   //Dynamic method for all objects
    public String dynamicQuery(String sobjectApiName){
        String commaSepratedFields = '';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(sobjectApiName).getDescribe().fields.getMap();

        for(String fieldName : fieldMap.keyset()){
            if(commaSepratedFields == null || commaSepratedFields == ''){
                commaSepratedFields = fieldName;
            }else{
                commaSepratedFields = commaSepratedFields + ', ' + fieldName;
            }
        }
        
        return commaSepratedFields;
    
    }
    
    
    public void clonePrdwithRealted(){
        Savepoint cSavePoint = Database.setSavepoint();     
        try{    
        String sDynamicQuery;
        if(!String.isBlank(sCPQProdId)){ 
            if(oCPQProdClone != null){
                if(!oCPQProdClone.Cloned__c){                   
                    if(oSourceEE != null){
                        if(oTargetEE != null){
                            sDynamicQuery = this.dynamicQuery('Product2');                          
                            query = 'SELECT ' + sDynamicQuery + ' FROM Product2 WHERE Event_Edition__r.Name =\''+oCPQProdClone.Source_Event_Edition__c+'\' Limit 5000';
                            System.debug('DynamicQueryProd'+query);
                            lstProdOfSourceEE = Database.query(query);
                            system.debug('lstProdOfSourceEE:'+lstProdOfSourceEE);
                         
                            if(lstProdOfSourceEE != null && lstProdOfSourceEE.size() > 0){
                                Map<Id, Product2> mapClonedPrdwithSourcePrdId = new Map<Id, Product2>();
                                Product2 oClonedPrdInstance ;
                                String sTargetYeartoReplace = String.valueof(oCPQProdClone.Target_Event_Edition__c.right(4));
                                String sSourceYeartoReplace = String.valueof(oCPQProdClone.Source_Event_Edition__c.right(4));
                                System.debug('sTargetYeartoReplace : '+ sTargetYeartoReplace);
                                
                                for(Product2 oPrd : lstProdOfSourceEE){
                                    oClonedPrdInstance = new Product2();
                                    oClonedPrdInstance = oPrd.clone(false, false, false, false);

                                    if(!String.isBlank(oClonedPrdInstance.ProductCode)){
                                        oClonedPrdInstance.ProductCode = oClonedPrdInstance.ProductCode.replace(sSourceYeartoReplace,sTargetYeartoReplace);
                                    }
                                    //if(oCPQProdClone.Target_Event_Edition__c != ''){
                                        //  oClonedPrdInstance.Event_Edition__c = oCPQProdClone.Target_Event_Edition__c;
                                    //}
                                      
                                    if(oPrd.Start_Date__c != null){
                                          oClonedPrdInstance.Start_Date__c = oTargetEE.Start_Date__c;
                                    }
                                      
                                    
                                    if(oPrd.End_Date__c != null){
                                        oClonedPrdInstance.End_Date__c = oTargetEE.End_Date__c;
                                    }                                    
                                    if(oPrd.Event_Edition_WOC__c != null){
                                        oClonedPrdInstance.Event_Edition_WOC__c = oPrd.Event_Edition_WOC__c.replace(sSourceYeartoReplace,sTargetYeartoReplace); 
                                    }
                                        
                                    if(oPrd.Event_Edition_LFSC__c != null){
                                         oClonedPrdInstance.Event_Edition_LFSC__c = oPrd.Event_Edition_LFSC__c.replace(sSourceYeartoReplace,sTargetYeartoReplace);     
                                    }
                                       
                                        
                                    if(oPrd.Event_Edition_TISE__c != null){
                                        oClonedPrdInstance.Event_Edition_TISE__c = oPrd.Event_Edition_TISE__c.replace(sSourceYeartoReplace,sTargetYeartoReplace);
                                    }
                                        
                                        
                                    if(oPrd.Event_Edition_TOC__c != null){
                                         oClonedPrdInstance.Event_Edition_TOC__c = oPrd.Event_Edition_TOC__c.replace(sSourceYeartoReplace,sTargetYeartoReplace); 
                                    }
                                        
                                    if(oPrd.Event_Edition_GHNN__c != null){
                                        oClonedPrdInstance.Event_Edition_GHNN__c = oPrd.Event_Edition_GHNN__c.replace(sSourceYeartoReplace,sTargetYeartoReplace);                                                                       
                                    }
                                        
                                    oClonedPrdInstance.Cloned__c = true;
                                    mapClonedPrdwithSourcePrdId.put(oPrd.Id, oClonedPrdInstance);
                                }
                                
                                System.debug('mapClonedPrdwithSourcePrdId : '+mapClonedPrdwithSourcePrdId.values());
                                if(mapClonedPrdwithSourcePrdId.values() != null && mapClonedPrdwithSourcePrdId.values().size()>0){
                                    System.debug('Size Before insert Cloned Product : '+mapClonedPrdwithSourcePrdId.values().size());          
                                    Insert mapClonedPrdwithSourcePrdId.values();
                                    System.debug('Size After insert Cloned Product : '+mapClonedPrdwithSourcePrdId.values().size());
                                    system.debug('After insert Cloned Product : '+mapClonedPrdwithSourcePrdId.values());
                                    oCPQProdClone.Cloned__c = true;
                                    update oCPQProdClone;
                                    
                                    
                                   //StandardPriceBookEntry 
                                    
                                     List<PriceBookEntry> lstStdPBEntryClone = new List<PriceBookEntry>();
                                     PriceBookEntry oClonedPBEInstance ;
                                     sDynamicQuery = this.dynamicQuery('PriceBookEntry');                                                                                                                    
                                     query = 'SELECT ' + sDynamicQuery + ' FROM PriceBookEntry WHERE Product2Id IN :lstProdOfSourceEE AND Pricebook2.IsStandard = true';                                                                         
                                     System.debug('DynamicQueryEntry::'+query);
                                     lstStdPBEntry = Database.query(query);
                                     system.debug('lstStdPBEntry::'+lstStdPBEntry);

                                    if(lstStdPBEntry != null && lstStdPBEntry.size() > 0){ for(PriceBookEntry oPBE : lstStdPBEntry){oClonedPBEInstance = oPBE.clone(false, false, false, false);  if(mapClonedPrdwithSourcePrdId.containskey(oPBE.Product2Id)){ oClonedPBEInstance.Product2Id = mapClonedPrdwithSourcePrdId.get(oPBE.Product2Id).id ;lstStdPBEntryClone.add(oClonedPBEInstance);
                                            }                                       
                                        }
                                    }
                                    if(!lstStdPBEntryClone.isEmpty()){
                                        Insert lstStdPBEntryClone ;
                                        system.debug('lstStdPBEntryClone::'+lstStdPBEntryClone);
                                    }
                                    
                                    //CustomPriceBookEntry
                                    
                                     List<PriceBookEntry> lstCustomPBEntryClone = new List<PriceBookEntry>();                                     
                                     sDynamicQuery = this.dynamicQuery('PriceBookEntry');                          
                                     query = 'SELECT ' + sDynamicQuery + ' FROM PriceBookEntry WHERE Product2Id IN :lstProdOfSourceEE AND Pricebook2.IsStandard = false';                               
                                     System.debug('DynamicQueryCustom::'+query);
                                     lstCustomPBEntry = Database.query(query);
                                     system.debug('lstCustomPBEntry::'+lstCustomPBEntry);
                                        if(lstCustomPBEntry != null && lstCustomPBEntry.size() > 0){for(PriceBookEntry oPBE : lstCustomPBEntry){ oClonedPBEInstance = oPBE.clone(false, false, false, false); if(mapClonedPrdwithSourcePrdId.containskey(oPBE.Product2Id)){ oClonedPBEInstance.Product2Id = mapClonedPrdwithSourcePrdId.get(oPBE.Product2Id).id ;lstCustomPBEntryClone.add(oClonedPBEInstance);
                                                }   
                                            }
                                        }
                                        if(!lstCustomPBEntryClone.isEmpty()){
                                            Insert lstCustomPBEntryClone ;
                                            system.debug('lstCustomPBEntryClone::'+lstCustomPBEntryClone);
                                        }
                                    
                               
                                    //ProductFeature
                                    
                                    Map<Id,SBQQ__ProductFeature__c> mapClonedFeatureId = new Map<Id,SBQQ__ProductFeature__c>();
                                    SBQQ__ProductFeature__c oClonedFeatureInstance ;
                                    sDynamicQuery = this.dynamicQuery('SBQQ__ProductFeature__c');
                                    query = 'SELECT ' + sDynamicQuery + ' FROM SBQQ__ProductFeature__c WHERE SBQQ__ConfiguredSKU__c IN :lstProdOfSourceEE limit 5000';
                                    lstProdFeature = Database.query(query);
                                    system.debug('lstProdFeature::'+lstProdFeature);
                                    for(SBQQ__ProductFeature__c oProductFeature : lstProdFeature){
                                        oClonedFeatureInstance = new SBQQ__ProductFeature__c();
                                        oClonedFeatureInstance = oProductFeature.clone(false, false, false, false);
                                        oClonedFeatureInstance.ownerId = userinfo.getuserid();                                        
                                        if(mapClonedPrdwithSourcePrdId.containskey(oProductFeature.SBQQ__ConfiguredSKU__c)){
                                            oClonedFeatureInstance.SBQQ__ConfiguredSKU__c = mapClonedPrdwithSourcePrdId.get(oProductFeature.SBQQ__ConfiguredSKU__c).Id; 
                                            mapClonedFeatureId.put(oProductFeature.Id, oClonedFeatureInstance);
                                        }
                                    }
                                    if(!mapClonedFeatureId.isEmpty()){
                                        Insert mapClonedFeatureId.values();
                                        system.debug('Features:: '+mapClonedFeatureId.values().size());
                                        system.debug('FeaturesValues::'+mapClonedFeatureId.values());
                                    }
                               
                               
                                   //ProductOption

                                    Map<Id,SBQQ__ProductOption__c> mapClonedProductOptionId = new Map<Id,SBQQ__ProductOption__c>();
                                    SBQQ__ProductOption__c oClonedProductOptionInstance ;
                                    sDynamicQuery = this.dynamicQuery('SBQQ__ProductOption__c');
                                    query = 'SELECT ' + sDynamicQuery + ' FROM SBQQ__ProductOption__c WHERE SBQQ__ConfiguredSKU__c IN :lstProdOfSourceEE limit 5000';
                                    lstProdOption = Database.query(query);
                                    system.debug('lstProdOption::'+lstProdOption);
                                    
                                    for(SBQQ__ProductOption__c oProductOption : lstProdOption){
                                                                        
                                        oClonedProductOptionInstance = new SBQQ__ProductOption__c();
                                        oClonedProductOptionInstance = oProductOption.clone(false, false, false, false);
                                        oClonedProductOptionInstance.ownerId = userinfo.getuserid();
                                        
                                        if(mapClonedPrdwithSourcePrdId.containskey(oProductOption.SBQQ__ConfiguredSKU__c)){
                                            oClonedProductOptionInstance.SBQQ__ConfiguredSKU__c = mapClonedPrdwithSourcePrdId.get(oProductOption.SBQQ__ConfiguredSKU__c).Id;                                            
                                        }
                                        else{
                                            oClonedProductOptionInstance.SBQQ__ConfiguredSKU__c = null;
                                        }
                                        if(mapClonedPrdwithSourcePrdId.containskey(oProductOption.SBQQ__OptionalSKU__c)){
                                            oClonedProductOptionInstance.SBQQ__OptionalSKU__c = mapClonedPrdwithSourcePrdId.get(oProductOption.SBQQ__OptionalSKU__c).id;                                              
                                        }
                                        else{
                                            oClonedProductOptionInstance.SBQQ__OptionalSKU__c = null;
                                        }
                                        if(mapClonedFeatureId.containskey(oProductOption.SBQQ__Feature__c)){
                                            oClonedProductOptionInstance.SBQQ__Feature__c = mapClonedFeatureId.get(oProductOption.SBQQ__Feature__c).Id;                                            
                                        }
                                        if(oClonedProductOptionInstance.SBQQ__ConfiguredSKU__c != null && oClonedProductOptionInstance.SBQQ__OptionalSKU__c != null){                                           
                                            mapClonedProductOptionId.put(oProductOption.Id, oClonedProductOptionInstance);
                                        }                   
                                    }
                                    if(!mapClonedProductOptionId.isEmpty()){
                                        Insert mapClonedProductOptionId.values();
                                        System.debug('Options::'+mapClonedProductOptionId.values().size());
                                        system.debug('OptionsValues::'+mapClonedProductOptionId.values());
                                    }
                                    
                                    //Configuration Rules
                                                                        
                                    Map<Id,SBQQ__ConfigurationRule__c> mapClonedProductConfigRulesId = new Map<Id,SBQQ__ConfigurationRule__c>();
                                    SBQQ__ConfigurationRule__c oClonedConfigurationRuleInstance ;                                    
                                    sDynamicQuery = this.dynamicQuery('SBQQ__ConfigurationRule__c');
                                    query = 'SELECT ' + sDynamicQuery + ' FROM SBQQ__ConfigurationRule__c WHERE SBQQ__Product__c IN :lstProdOfSourceEE limit 5000';
                                    lstProdConf = Database.query(query);
                                    system.debug('lstProdConf::'+lstProdConf);
                                    for(SBQQ__ConfigurationRule__c oProdConfigRules :lstProdConf){
                                                                        
                                        oClonedConfigurationRuleInstance = new SBQQ__ConfigurationRule__c();
                                        oClonedConfigurationRuleInstance = oProdConfigRules.clone(false, false, false, false);                                        
                                        if(mapClonedPrdwithSourcePrdId.containskey(oProdConfigRules.SBQQ__Product__c)){
                                            oClonedConfigurationRuleInstance.SBQQ__Product__c = mapClonedPrdwithSourcePrdId.get(oProdConfigRules.SBQQ__Product__c).Id;
                                        }
                                        else{
                                            oClonedConfigurationRuleInstance.SBQQ__Product__c = null;
                                        }
                                        if(mapClonedFeatureId.containskey(oProdConfigRules.SBQQ__ProductFeature__c)){
                                            oClonedConfigurationRuleInstance.SBQQ__ProductFeature__c = mapClonedFeatureId.get(oProdConfigRules.SBQQ__ProductFeature__c).Id;
                                        }
                                        else{
                                            oClonedConfigurationRuleInstance.SBQQ__ProductFeature__c = null;
                                        }
                                        if(oClonedConfigurationRuleInstance.SBQQ__Product__c != null && oClonedConfigurationRuleInstance.SBQQ__ProductFeature__c != null){
                                            mapClonedProductConfigRulesId.put(oProdConfigRules.Id, oClonedConfigurationRuleInstance);
                                        }
                                    }
                                    if(!mapClonedProductConfigRulesId.isEmpty()){
                                        Insert mapClonedProductConfigRulesId.values();
                                        System.debug('Configure:'+mapClonedProductConfigRulesId.values().size());
                                        system.debug('ConfigureValues:'+mapClonedProductConfigRulesId.values());
                                    }
                                    
                                    //SobjectPricebookTable
                                    
                                        Map<Id,sObject> mapClonedSobj = new Map<Id,sObject>();                                      
                                        SObjectType objType = Schema.getGlobalDescribe().get(typeName);
                                        Map<String,Schema.SObjectField> mfields = objType.getDescribe().fields.getMap();
                                        
                                        sDynamicQuery = this.dynamicQuery(typeName);                                        
                                        query = 'SELECT ' + sDynamicQuery + ' FROM '+ typeName +' WHERE Product__c IN :lstProdOfSourceEE limit 5000';
                                        lstofSobj = Database.query(query);
                                        system.debug('lstofSobj::'+lstofSobj);
                                        system.debug('lstofSobj::'+lstofSobj.size());
                                        for(sObject oICRE :lstofSobj){ obj = oICRE.clone(false, false, false, false);if(obj.get('ownerId') != null){obj.put('ownerId', userinfo.getuserid());
                                              } 
                                           
                                             if(mapClonedPrdwithSourcePrdId.containsKey(String.ValueOf(oICRE.get('Product__c')))){
                                                system.debug('****'+String.ValueOf(oICRE.get('Product__c')));
                                                obj.put('Product__c',mapClonedPrdwithSourcePrdId.get(String.ValueOf(oICRE.get('Product__c'))).id); 
                                            }                                               
                                                                                                                                         
                                            if(mfields.containsKey('Start_Date__c')){
                                                  obj.put('Start_Date__c',oTargetEE.Start_Date__c); 
                                              }
                                                
                                            if(mfields.containsKey('End_Date__c')){
                                                  obj.put('End_Date__c',oTargetEE.End_Date__c); 
                                              }    
                                                                                                                               
                                               mapClonedSobj.put(oICRE.Id, obj);
                                            
                                                                                   
                                        }
                                        if(!mapClonedSobj.isEmpty()){
                                            Insert mapClonedSobj.values(); 
                                            system.debug('sboj::'+mapClonedSobj.values().size());
                                            system.debug('sobjcon::'+mapClonedSobj.values());
                                         }                                                                       
                                  
                                    
                                    
                                    //Clone Progress
                                    List<CPQ_Clone_Progress__c> lstCloneProgess = new List<CPQ_Clone_Progress__c>();
                                    CPQ_Clone_Progress__c oCloneProgess ;
                                    for(Id oSourceProductId : mapClonedPrdwithSourcePrdId.keySet()){
                                        oCloneProgess = new CPQ_Clone_Progress__c();
                                        oCloneProgess.CPQ_Product_Clone__c = oCPQProdClone.Id;
                                        oCloneProgess.Source_Product__c = oSourceProductId ;
                                        oCloneProgess.Target_Product__c = mapClonedPrdwithSourcePrdId.get(oSourceProductId).Id;
                                        lstCloneProgess.add(oCloneProgess);
                                    }
                                    if(!lstCloneProgess.isEmpty()){
                                        Insert lstCloneProgess;
                                        System.debug('lstCloneProgess: '+lstCloneProgess.size());
                                        system.debug('lstCloneProgessValues: '+lstCloneProgess);
                                    }
                                    isCloned = 'Yes';
                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Products/Packages for the Event Edition '+ oCPQProdClone.Target_Event_Edition__c +' are cloned successfully'));
                                }   
                            }
                            else {
                                isCloned = 'Yes';
                                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Source Event Edition '+ oCPQProdClone.Source_Event_Edition__c +' has no products to clone.'));
                            }
                        }
                        else {
                            isCloned = 'Yes';
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Target Event Edition ['+ oCPQProdClone.Target_Event_Edition__c +'] does not exist in system.'));
                        }
                    }
                    else {
                        isCloned = 'Yes';
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Source Event Edition ['+ oCPQProdClone.Source_Event_Edition__c +'] does not exist in system.'));
                    }
                }
                else{
                    isCloned = 'Yes';
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Products/Packages for the Event Edition '+ oCPQProdClone.Target_Event_Edition__c +' already exist.'));
                }
            }
          } 
        }
         catch(Exception e){ 
                isCloned = 'Yes';
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage())); 
                Database.rollback(cSavePoint);              
            }                    
        }
    
     
   //Delete the Cloned Products
    public void deleteRecord(){
         system.debug('oTargetEE.Name::::'+ oTargetEE.Name);   
         List<Product2> lstPrd = [SELECT Id, Name ,Event_Edition__c, Event_Edition_Pool__c FROM product2 WHERE Event_Edition__c =: oTargetEE.Name AND Cloned__c = true]; 
         system.debug('lstPrd::::'+lstPrd );
         query = 'SELECT id FROM '+ typeName +' WHERE Product__c IN :lstPrd limit 5000';
         if(lstPrd != null && lstPrd.size() > 0){
            lstofSobj = Database.query(query);
        }                     
         List<CPQ_Clone_Progress__c> lstCloneProg  = [SELECT Id, Name FROM CPQ_Clone_Progress__c WHERE CPQ_Product_Clone__c = :oCPQProdClone.Id]; 
         system.debug('lstCloneProg::::'+ lstCloneProg);
        if(lstPrd !=null && lstPrd.size() > 0  && lstCloneProg  !=null && lstCloneProg.size() > 0){
            List<SBQQ__ProductFeature__c> lstProdFeature = [SELECT Id FROM SBQQ__ProductFeature__c WHERE SBQQ__ConfiguredSKU__c IN :lstPrd ];
            List<SBQQ__ProductOption__c> lstprodOption = [SELECT Id FROM SBQQ__ProductOption__c  WHERE SBQQ__ConfiguredSKU__c IN :lstPrd ];
            List<SBQQ__ConfigurationRule__c> oProdConfigRules  = [SELECT Id, Name FROM SBQQ__ConfigurationRule__c WHERE SBQQ__Product__c IN :lstPrd];         
            oCPQProdClone.Cloned__c = false;
            Savepoint oSavePoint = Database.setSavepoint();
            try{
                delete oProdConfigRules;
                delete lstprodOption;
                delete lstProdFeature;
                delete lstCloneProg;
                delete lstPrd;
                delete lstofSobj;
                isCloned = 'Yes';
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'The cloned Products/Packages for the Event Edition '+ oCPQProdClone.Target_Event_Edition__c + ' has been deleted successfully'));          
                system.debug('deletelstPrd::::'+lstPrd);
                update oCPQProdClone;
              
            }
            catch(Exception e){
                isCloned = 'Yes';
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
                system.debug('Messagedelete::::'+e.getMessage());
                Database.rollback(oSavePoint);      
            }        
        }
        else if(lstCloneProg!=null && lstCloneProg.size()> 0){
            oCPQProdClone.Cloned__c = false;
            delete lstCloneProg;
            isCloned = 'Yes';
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'The cloned Products/Packages for the Event Edition '+ oCPQProdClone.Target_Event_Edition__c + ' has been deleted successfully'));          
            system.debug('deletelstPrd::::'+lstPrd);
            update oCPQProdClone;       
        }
        else{
            isCloned = 'Yes';
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Products/Packages for the Event Edition '+ oCPQProdClone.Target_Event_Edition__c +' already deleted.'));
        }     
    }   
    
    public pageReference cancelRecord(){
        PageReference pageRef = new PageReference('/'+oCPQProdClone.id); 
        pageRef.setRedirect(true);
        return pageRef;
    }
 
}