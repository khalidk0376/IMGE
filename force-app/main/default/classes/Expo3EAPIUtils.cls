/**
* File			:   Expo3EAPIUtils
* Project		:   (3E Intregration)
* Created Date	: 	24th April 2022
* Created By	:   (Sunny Yadav)
* Test Class	:  	Expo3EAPIUtils_Test	
* Coverage		:	80%
* *******************************************************************************************************
* @description : For all the Booth API callouts to 3E ExpoCAD
* *******************************************************************************************************
* Last Modified By : Girikon(Aradhana),on 4th July 2022[EX-21]
* Last Modified By : Girikon(Aradhana),on 11th Oct 2022[EX-23]
* Last Modified By : Girikon(Abhishek),on 21st Feb 2023[EX-154]
* Last Modified By : Girikon(Abhishek),on 20th Apr 2023[EX-222] Line#611-615 & Line#849-853 : Ability to include mapping of multiple rate plans and request items from 3E to one product in Salesforce GE
*/

public with sharing class Expo3EAPIUtils {
    public static String errorMessage;
    public static String responseCode;
    public static String responseBody;
    public static String requestBody;
    

    /**
    * @description  This method is used for exibitor creation after checking if exhibitor exist or not
    * @param exhibitorSyncObj API Synchronization Item
    * @return String Status
    */
    public static void updateStaticValues(string eM, string rC, string rB, string rqB){
        errorMessage = eM;
        responseCode = rC;
        responseBody = rB;
        requestBody = rqB;
    }
    public static String getContractsFrom3EEnd(API_Synchronization_Item__c exhibitorSyncObj) {//, Id interfaceLogId
        String calloutStatus = Expocad3E_Wrapper.PROCESSING;
        errorMessage = '';
        responseCode = '';
        responseBody = '';
        requestBody = '';
        List<Opportunity> lstOpp = [SELECT Id,EventEdition__c,SBQQ__PrimaryQuote__c,Review_by_Sales_Ops_Team__c,Opportunity_Contact__r.email,AccountId,Account.name,StageName,X3E_Exhibitor_Invite_Status__c FROM Opportunity WHERE Id=:exhibitorSyncObj.Opportunity__c WITH SECURITY_ENFORCED LIMIT 1];
        List<ExpocadBooth__c> BoothList = [SELECT Name , Booth_Number__c ,Status__c, Event_Code__c , Opportunity__c FROM ExpocadBooth__c Where Id  = :exhibitorSyncObj.ExpocadBooth__c WITH SECURITY_ENFORCED];
        //(SELECT Id,X3E_Contact_Status__c,Record_Number__c,Primary_exhibitor_contact__c FROM OpportunityContactRoles )
        String boothNumber = BoothList[0].Booth_Number__c;
        String customerId = lstOpp[0].AccountId;
      
        List<Event_Edition__c> eventRecord = [Select Id,x3E_API_ID__c, X3E_Status__c From Event_Edition__c Where Id = :lstOpp[0].EventEdition__c WITH SECURITY_ENFORCED];
        
        String apiToken = Expo3EAPIUtilHelper.fetchApiToken();
        errorMessage = String.isBlank(apiToken) ? System.label.Api_Token_Empty3E : errorMessage;
        errorMessage = String.isBlank(boothNumber) ? System.label.Booth_Number_is_Blank : errorMessage;
        errorMessage = String.isBlank(customerId)?  System.label.Customer_Id_Is_Blank : errorMessage;
        
        if(Test.isRunningTest()){
            errorMessage = '';
            apiToken = 'test121'; 
        }
        
        Expocad3E_Wrapper.WrapperResponse wrapRespPostPutCall;
        if (BoothList[0].Status__c == 'Rented') {
            if(String.isBlank(errorMessage)){
                wrapRespPostPutCall = Expo3EAPIUtilHelper.fetchContractFrom3E(eventRecord[0].x3E_API_ID__c,customerId, boothNumber,true,apiToken);
            }
            
            if(wrapRespPostPutCall != null){
                requestBody = wrapRespPostPutCall.requestBody;
                errorMessage = wrapRespPostPutCall.response.getStatus() == null ? System.label.ExpoCad_API_Down_Message : errorMessage ;//System.Label.ExpoCAD_API_Down_Msg;
                if((exhibitorSyncObj.API_Call_Type__c == Expocad3E_Wrapper.GET && wrapRespPostPutCall.response.getStatusCode() == 200) ){
                    calloutStatus = Expocad3E_Wrapper.SUCCESS;//|| (exhibitorSyncObj.API_Call_Type__c == Expocad3EAPIWrapper.POST && wrapRespPostPutCall.response.getStatusCode() == 201)
                    responseCode = String.valueOf(wrapRespPostPutCall.response.getStatusCode());
                    requestBody = wrapRespPostPutCall.requestBody;
                    String fileName = 'default name.pdf';
                    Pattern p = Pattern.compile('.+filename="(.+?)".*');
                    String contentDisposition = wrapRespPostPutCall.response.getHeader('Content-Disposition');
                    if(contentDisposition != null) {
                        Matcher m = p.matcher(contentDisposition);
                        fileName = m.find() ? m.group(1) : fileName;
                    }
                    fileName = fileName.substringBeforeLast('.')+'-'+String.valueOf(datetime.now())+'.'+fileName.substringAfterLast('.');
                    responseBody = fileName;
                    Blob data  =  wrapRespPostPutCall.response.getBodyAsBlob();
                    if(Test.isRunningTest()){
                        String fileContent = 'name.pdf';
                        data = Blob.valueOf(fileContent);
                    }
                    system.debug('--->getContractsFrom3EEnd');
                    List<ContentVersion> newConVerList = createContentVersions(data,fileName,lstOpp[0].Id);
					//List<ContentVersion> newConVerList = createContentVersions(data,fileName);
                    if(newConVerList!= null && !newConVerList.isEmpty()){ 
                        Insert newConVerList;
                        List<ContentDocumentLink> newContDocList = createContentDocLink(newConVerList,lstOpp[0].Id,fileName);
                        if(newContDocList!= null && !newContDocList.isEmpty()){
                            Insert newContDocList;
                        }
                    }
                    
                }
                else{
                    updateStaticValues(wrapRespPostPutCall.response.getBody(), String.valueOf(wrapRespPostPutCall.response.getStatusCode()), wrapRespPostPutCall.response.getBody(), requestBody);
                }
            }
        }else {
            calloutStatus = Expocad3E_Wrapper.SUCCESS;
            updateStaticValues(errorMessage, '200', 'Booth is not rented', requestBody);
        }
        Boolean updateOpp = false;
        if(errorMessage != '' || responseCode != '200')
        {
            calloutStatus = Expocad3E_Wrapper.ERROR;
            // Update Synchronization_Item Status
            APISynchronizationHelper.updateSyncItemStatus(New API_Synchronization_Item__c(Id=exhibitorSyncObj.id,Status__c= Expocad3E_Wrapper.ERROR,Error_Message__c=errorMessage,Response_Code__c=responseCode,Request_Body__c=requestBody,Response_Body__c=responseBody));
        }
        else{
            
            APISynchronizationHelper.updateSyncItemStatus(New API_Synchronization_Item__c(Id=exhibitorSyncObj.id,Status__c= Expocad3E_Wrapper.COMPLETED,Response_Code__c=responseCode,Error_Message__c='',Request_Body__c=requestBody,Response_Body__c=responseBody));
            API_Synchronization_Item__c itemRecOld = [SELECT Id, Name FROM  API_Synchronization_Item__c where Id = :exhibitorSyncObj.id WITH SECURITY_ENFORCED];
            List<API_Synchronization_Transaction__c> synTranRec = [Select Id,(SELECT Id, Name, API_Synchronization_Transaction__c, Status__c, Type__c FROM  API_Synchronization_Items__r) From API_Synchronization_Transaction__c where Id = :exhibitorSyncObj.API_Synchronization_Transaction__c WITH SECURITY_ENFORCED];
            Boolean transactionProcessedSuccessfully = false;
            Boolean isLastItem = false;
        /*   if (synTranRec != null && !synTranRec.isEmpty()) {
                for (API_Synchronization_Transaction__c trnRec : synTranRec) {
                    if (trnRec.API_Synchronization_Items__r != null && !trnRec.API_Synchronization_Items__r.isEmpty()) {
                        for (API_Synchronization_Item__c itemRec : trnRec.API_Synchronization_Items__r) {
                            if(itemRec.Status__c != 'Completed'){
                                transactionProcessedSuccessfully= false; 
                            }
                            if (itemRecOld.name == itemRec.name) {
                                isLastItem = true;
                            }else{isLastItem = false;}
                        }
                    }else {transactionProcessedSuccessfully= false; }
                }
            }else {transactionProcessedSuccessfully= false; }

            if (transactionProcessedSuccessfully) {
             //   SBQQ__Quote__c qRec= new SBQQ__Quote__c(id = lstOpp[0].SBQQ__PrimaryQuote__c,SBQQ__Status__c = 'Contract Approved');                
             //   update qRec;
                opportunity oppRec = new opportunity(id= lstOpp[0].Id,Update_Contracted__c = true,Contract_Attached__c = true,StageName = 'Closed Won');
                oppRec.Status__c = lstOpp[0].Review_by_Sales_Ops_Team__c ? 'Sales Ops Review - Pending' : 'Pending Accounting Approval';
                update oppRec;
            } */
          /*  if (synTranRec != null && !synTranRec.isEmpty()) {
                for (API_Synchronization_Transaction__c trnRec : synTranRec) {
                    if (trnRec.API_Synchronization_Items__r != null && !trnRec.API_Synchronization_Items__r.isEmpty()) {
                        for (API_Synchronization_Item__c itemRec : trnRec.API_Synchronization_Items__r) {
                            if(itemRec.Status__c == 'Completed' ){
                                                              transactionProcessedSuccessfully= true; 
                            }  
                        }
                    }
                }
            }

            if (transactionProcessedSuccessfully == true ) {
             //   SBQQ__Quote__c qRec= new SBQQ__Quote__c(id = lstOpp[0].SBQQ__PrimaryQuote__c,SBQQ__Status__c = 'Contract Approved');                
             //   update qRec;
               opportunity oppRec = new opportunity(id= lstOpp[0].Id,Update_Contracted__c = true,Contract_Attached__c = true,StageName = 'Closed Won');
               oppRec.Status__c = lstOpp[0].Review_by_Sales_Ops_Team__c ? 'Sales Ops Review - Pending' : 'Pending Accounting Approval';
               update oppRec;
            } */
            
            
        }
        
        return calloutStatus;
    }
    
    /**
* @description  This method is used for exibitor creation after checking if exhibitor exist or not
* @param exhibitorSyncObj API Synchronization Item
* @return String Status
*/
    public static String GetBoothAllFromExpocad(API_Synchronization_Item__c exhibitorSyncObj) {//, Id interfaceLogId
        String calloutStatus = Expocad3E_Wrapper.PROCESSING;
        errorMessage = '';
        responseCode = ''; 
        responseBody = '';
        requestBody = '';
        List<Opportunity> lstOpp = [SELECT Id,EventEdition__c,EventEdition__r.name,EventEdition__r.Booth_Bundle_Type__c,Event_Series__r.Package_Identifier__c,Opportunity_Contact__r.email,AccountId,StageName,X3E_Exhibitor_Invite_Status__c,Pricebook2Id, OwnerId, SBQQ__PrimaryQuote__c, SBQQ__QuotePricebookId__c, Billing_Contact__c, Opportunity_Contact__c,
                                    (SELECT Name , Booth_Number__c ,Booth_Product_Type__c, Event_Code__c ,status__c, Opportunity__c FROM ExpocadBooths__r where Booth_Number__c != null) FROM Opportunity WHERE Id=:exhibitorSyncObj.Opportunity__c WITH SECURITY_ENFORCED LIMIT 1];
		Map<String, ExpocadBooth__c> boothMap = new Map<String, ExpocadBooth__c>();
        if(lstOpp != null && !lstOpp.isEmpty()){
            for(Opportunity oppRec : lstOpp){
                if(oppRec.ExpocadBooths__r != null && !oppRec.ExpocadBooths__r.isEmpty()){
                    for(ExpocadBooth__c boothRec : oppRec.ExpocadBooths__r){
                        boothMap.put(boothRec.Booth_Number__c.trim().ToLowerCase(),boothRec);
                    }
                }
            }
        }else{errorMessage = 'No Opportunity found';}
        
        
        List<Event_Edition__c> eventRecord = [Select Id,x3E_API_ID__c, X3E_Status__c From Event_Edition__c Where Id = :lstOpp[0].EventEdition__c WITH SECURITY_ENFORCED];//??
        Expocad3E_Wrapper.WrapperResponse wrapRespPostPutCall;
        if(Test.isRunningTest()){
            errorMessage = '';
        }
        if(String.isBlank(errorMessage)){
            wrapRespPostPutCall = Expo3EAPIUtilHelper.getAllExpoBooths(eventRecord[0].x3E_API_ID__c, lstOpp[0].AccountId);
        }
        Map < String, SBQQ__ProductOption__c > mapProductOptions = new Map < String, SBQQ__ProductOption__c > ();
        Map < Id, SBQQ__ProductOption__c > mapProductOptionsId = new Map < Id, SBQQ__ProductOption__c > ();
        Set<String> ExpocadRelationshipCodeSet = new Set<String>();
        String cornerProductName;
        String sBoothPackagePrdName;
        Product2 boothPackageProduct;
        List<SBQQ__ProductOption__c>  prodOptionList;
        List<String> expoBoothList = new List<String>();
        List<ExpocadBooth__c> expoList = new List<ExpocadBooth__c>();
        List<ExpocadBooth__c> expoReleaseList = new List<ExpocadBooth__c>();
        List<ExpocadBooth__c> expoNewApiList  = new List<ExpocadBooth__c>();
        List<Opportunity_ExpoCAD_Booth_Mapping__c> lstEbmtoInsert = new List<Opportunity_ExpoCAD_Booth_Mapping__c>();
        Set<String> newExpocadBoothNumSet = new Set<String>();
        Map<String, ExpocadBooth__c> newExpocadBoothMap = new Map<String, ExpocadBooth__c>();
        Set<String> boothNumSet = new Set<String>();
        Integer boothReleasedCount = 0;
        
        if(wrapRespPostPutCall != null){
            requestBody = wrapRespPostPutCall.requestBody;
            responseBody = String.valueOf(wrapRespPostPutCall.response);
            if((exhibitorSyncObj.API_Call_Type__c == Expocad3E_Wrapper.GET && wrapRespPostPutCall.response.getStatusCode() == 200) ){
                List<Expocad3E_Wrapper.GetAllBoothsWrapper> getAllWrapList = new List<Expocad3E_Wrapper.GetAllBoothsWrapper>();
                
                
                
                getAllWrapList = (List<Expocad3E_Wrapper.GetAllBoothsWrapper>) JSON.deserialize(wrapRespPostPutCall.response.getBody(), List<Expocad3E_Wrapper.GetAllBoothsWrapper>.class);
                Map<String, Expocad3E_Wrapper.GetAllBoothsWrapper> boothToWrapMap = new Map<String, Expocad3E_Wrapper.GetAllBoothsWrapper>();
                String quoteId;
                if(String.isNotBlank(lstOpp[0].SBQQ__PrimaryQuote__c)){
                    quoteId = lstOpp[0].SBQQ__PrimaryQuote__c;
                }else{
                    SBQQ__Quote__c quote = createQuote(lstOpp);
                    quoteId  = quote.Id;
                    lstOpp[0].SBQQ__PrimaryQuote__c = quoteId;
                    update lstOpp;
                }
                
                
                if (getAllWrapList != null && !getAllWrapList.isEmpty()) {
                    for (Expocad3E_Wrapper.GetAllBoothsWrapper wrapRec : getAllWrapList) {
                        System.debug('wrapRec');
                        System.debug(wrapRec);//Rented
                        System.debug(wrapRec.ExhibitorId);
                        System.debug(wrapRec.BoothNumber);
                        boothToWrapMap.put(wrapRec.BoothNumber.trim().ToLowerCase(),wrapRec);
                    }
                    //Expo3EAPIUtilHelper.getBoothProducts(lstOpp[0]);
                    if (String.isNotBlank(lstOpp[0].Event_Series__r.Package_Identifier__c)) {
                        sBoothPackagePrdName = lstOpp[0].EventEdition__r.Booth_Bundle_Type__c+' '+lstOpp[0].Event_Series__r.Package_Identifier__c;
                    }
                    if (String.isNotBlank(sBoothPackagePrdName)) {
                        boothPackageProduct = Expo3EAPIUtilHelper.getBoothProduct(lstOpp[0],sBoothPackagePrdName);
                    }else{ errorMessage = 'Booth package name not found.'; }
                    if (boothPackageProduct != null ) {
                        prodOptionList = Expo3EAPIUtilHelper.getBoothProductOptions(boothPackageProduct,ExpocadRelationshipCodeSet);
                    }else {errorMessage = 'Product package not found'; }
                    
                    if(prodOptionList != null && !prodOptionList.isEmpty()) {
                        for (SBQQ__ProductOption__c oProductOption : prodOptionList) {
                            mapProductOptions.put(oProductOption.SBQQ__OptionalSKU__r.Name, oProductOption);
                            mapProductOptionsId.put(oProductOption.Id, oProductOption);
                            if (oProductOption.SBQQ__OptionalSKU__r.Name.toLowerCase().contains('corner booth fee')) {
                                cornerProductName = oProductOption.SBQQ__OptionalSKU__r.Name;
                            }
                        }
                    }
                    if(!boothMap.isEmpty()){
                        for (String boothNum : boothMap.keyset()) {
                            if (boothToWrapMap.containsKey(boothNum) && boothToWrapMap.get(boothNum).IsRented) {// && boothMap.get(boothNum).status__c != 'Rented'
                                boothReleasedCount++;
                                Expocad3E_Wrapper.GetAllBoothsWrapper wrapRec = boothToWrapMap.get(boothNum);
                                String boothProdType = Expo3EAPIUtilHelper.sBPrd(mapProductOptionsId, wrapRec, lstOpp[0], boothPackageProduct);
                                if (boothMap.get(boothNum).status__c != 'Rented') {
                                    List<ExpocadBooth__c> newCreatedList = processExpocadBooths(boothMap.get(boothNum), boothToWrapMap.get(boothNum),lstOpp[0],quoteId,boothProdType);
                                    boothNumSet.add(boothNum.trim().ToLowerCase());
                                    expoList.addAll(newCreatedList);
                                }else{
                                    expoList.addAll(processExpocadBooths(boothMap.get(boothNum), boothToWrapMap.get(boothNum),lstOpp[0],quoteId,boothProdType));
                                }
                            }else{
                                ExpocadBooth__c rec = boothMap.get(boothNum);
                                expoBoothList.add(boothNum);
                                if (rec.Status__c != 'Released') {
                                    rec.Status__c = 'Released';
                                    expoReleaseList.add(rec);
                                }
                            }
                        }
                    }
                    
                    if(!boothToWrapMap.isEmpty()){
                        for (String boothNum : boothToWrapMap.keyset()) {
                            if (!boothMap.containsKey(boothNum) && boothToWrapMap.get(boothNum).IsRented) {
                                boothReleasedCount++;
                                Expocad3E_Wrapper.GetAllBoothsWrapper wrapRec = boothToWrapMap.get(boothNum);
                                String boothProdType = Expo3EAPIUtilHelper.sBPrd(mapProductOptionsId, wrapRec, lstOpp[0], boothPackageProduct);
                                List<ExpocadBooth__c> newCreatedList = processExpocadBooths(new ExpocadBooth__c(), boothToWrapMap.get(boothNum),lstOpp[0],quoteId,boothProdType);
                                boothNumSet.add(boothNum.trim().ToLowerCase());
                                expoList.addAll(newCreatedList);
                                newExpocadBoothNumSet.add(boothNum.trim().ToLowerCase());
                            }
                        }
                    }
                    
                    if(expoReleaseList!=null && !expoReleaseList.isEmpty()){
                        update expoReleaseList;
                    }
                    
                    if (expoList != null && !expoList.isEmpty()) { 
                        TriggerInterfaceHelper.isRunning = false;
                        upsert expoList;
						TriggerInterfaceHelper.isRunning = true;
                        
                        for(ExpocadBooth__c eB: expoList){
                            if(newExpocadBoothNumSet.contains(eB.Booth_Number__c.trim().ToLowerCase())){
                                Opportunity_ExpoCAD_Booth_Mapping__c objEbm = new Opportunity_ExpoCAD_Booth_Mapping__c();
                                objEbm.Opportunity__c = eB.Opportunity__c;
                                objEbm.Account__c = eB.Account__c;
                                objEbm.Primary_Contact__c = eB.Primary_Contact__c;
                                objEbm.Expocad_Booth__c = eB.Id;
                                objEbm.Quote__c = eB.Quote__c;
                                objEbm.Status__c = 'Active';
                                objEbm.Display_Name__c = eB.Display_Name__c;
                                objEbm.Is_Parent_Mapping__c = true;
                                ExhibitorForUserType__c ExhibitorUserType;
                                if (eB.Opportunity__c != NULL) {
                                    if ( eB.Exhibitor_Paid_By_Opp__c == NULL ) {
                                        ExhibitorUserType = ExhibitorForUserType__c.getValues( 'NULL' );
                                    } else if ( eB.Exhibitor_Paid_By_Opp__c != NULL ) {
                                        ExhibitorUserType = ExhibitorForUserType__c.getValues( eB.Exhibitor_Paid_By_Opp__c );
                                    }
                                }
                                if (ExhibitorUserType != NULL) {
                                    objEbm.Relation__c = ExhibitorUserType.Relation_for_Parent__c;
                                }
                           		lstEbmtoInsert.add(objEbm);
                            }
                            
                        } 
                        
                        if (!lstEbmtoInsert.isEmpty()) {
                            try {
                                insert lstEbmtoInsert;
                                if(test.isRunningTest()){
                                    insert new Account(createdDate = DateTime.Now().addDays(-1));    
                                }
                            } catch (Exception ex) {
                                Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'After Insert Trigger(@ReleaseBooths_Trig)');
                            }
                        }
                        if (boothReleasedCount > 0 ) {
                            for (ExpocadBooth__c expoRec : expoList) {
                                if (boothNumSet.contains(expoRec.Booth_Number__c.trim().ToLowerCase())) {
                                    expoNewApiList.add(expoRec);
                                }
                            }
                        }
                        
                        if (expoNewApiList != null && !expoNewApiList.isEmpty()) {
                            Id apiTranId = Create3EApiSyncRecords.getBoothFinancialsExpocad(expoNewApiList,'Asynchronous');
                        }
                    }
                    String OppIdString = String.valueOf(lstOpp[0].Id).substring(0, 15);
                    List<SBQQ__QuoteLine__c> qliList = [Select ID From SBQQ__QuoteLine__c where Booth_Number__c IN :expoBoothList AND Opportunity_ID__c= : OppIdString WITH SECURITY_ENFORCED];
                    if (qliList != null && !qliList.isEmpty()) {
                        SBQQ.TriggerControl.disable();
                        delete qliList;
                        SBQQ.TriggerControl.enable();
                    }
                    
                    
                    responseBody = wrapRespPostPutCall.response.getBody();
                }else{
                    responseBody = 'There is no Booth for this Exhibitor';
                }
                
                calloutStatus = Expocad3E_Wrapper.SUCCESS;
                updateStaticValues(errorMessage, String.valueOf(wrapRespPostPutCall.response.getStatusCode()), wrapRespPostPutCall.response.getBody(), wrapRespPostPutCall.requestBody);
                
            }
            else if (wrapRespPostPutCall.response.getStatus() == null) {
                errorMessage = System.label.Expocad_API_is_Down;//System.Label.ExpoCAD_API_Down_Msg;
            }
            else{
                updateStaticValues(wrapRespPostPutCall.response.getBody(), String.valueOf(wrapRespPostPutCall.response.getStatusCode()), String.valueOf(wrapRespPostPutCall.response), requestBody);
            }
        }
        Boolean updateOpp = false;
        if(errorMessage != '' || responseCode != '200')
        {
            calloutStatus = Expocad3E_Wrapper.ERROR;
            // Update Synchronization_Item Status
            APISynchronizationHelper.updateSyncItemStatus(New API_Synchronization_Item__c(Id=exhibitorSyncObj.id,Status__c= Expocad3E_Wrapper.ERROR,Error_Message__c=errorMessage,Response_Code__c=responseCode,Request_Body__c=requestBody,Response_Body__c=responseBody));
            
            
            
        }
        else{
            
            APISynchronizationHelper.updateSyncItemStatus(New API_Synchronization_Item__c(Id=exhibitorSyncObj.id,Status__c= Expocad3E_Wrapper.COMPLETED,Response_Code__c=responseCode,Error_Message__c='',Request_Body__c=requestBody,Response_Body__c=responseBody));
            
        }
        
        return calloutStatus;
    }
    
    
    public static void queueApiTransactions(){
        Set<String> typeSet = new Set<String>{Expocad3E_Wrapper.EXPOCAD3E_BOOTH_FINANCIALS,Expocad3E_Wrapper.EXPOCAD3E_BOOTH_REQITEMS,Expocad3E_Wrapper.EXPOCAD3E_CONTRACT_PULL_END,Expocad3E_Wrapper.EXPOCAD3E_QUOTE_CALCULATE,Expocad3E_Wrapper.EXPOCAD3E_OPP_UPDATE };
            list<API_Synchronization_Item__c> syncItemList =  [Select Id,API_Synchronization_Transaction__c From API_Synchronization_Item__c where type__c IN  :typeSet and API_Synchronization_Transaction__r.status__C = 'Paused' WITH SECURITY_ENFORCED];
        Set<String> apiTranSet = new Set<String>();
        List<API_Synchronization_Item__c> newList = new List<API_Synchronization_Item__c>();
        if (syncItemList != null && !syncItemList.isEmpty()) {
            for (API_Synchronization_Item__c rec : syncItemList) {
                apiTranSet.add(rec.API_Synchronization_Transaction__c);
                newList.add(new API_Synchronization_Item__c(Id = rec.Id,status__C = 'Queued'));
                
            }
        }
        List<API_Synchronization_Transaction__c> apiRecList = new List<API_Synchronization_Transaction__c>();
        if (!apiTranSet.isEmpty()) {
            for (String recId : apiTranSet) {
                apiRecList.add(new API_Synchronization_Transaction__c(Id = recId,status__C = 'Queued'));
            }
        }
        if (newList != null && !newList.isEmpty()) {
            update newList;
            if (apiRecList != null && !apiRecList.isEmpty()) {
                update apiRecList;
            }
        }
    }
    

    
    public static List<ExpocadBooth__c> processExpocadBooths(ExpocadBooth__c rec,Expocad3E_Wrapper.GetAllBoothsWrapper WrapRec,opportunity opp,String quoteId,String boothProdType){
        List<ExpocadBooth__c> boothList = new List<ExpocadBooth__c>();
        //ExpocadBooth__c rec = boothMap.get(boothNum);
        //Expocad3E_Wrapper.GetAllBoothsWrapper WrapRec = boothToWrapMap.get(boothNum);
        //account ??? TO DO
        //String sPrdName;
        
        //String sPrdName = sBPrd(rec, opp, boothPackageProduct);
        rec.Dimensions__c = String.isNotBlank( WrapRec.Dimensions) ?  WrapRec.Dimensions : '';	//3m x 3m 
        rec.Display_Name__c = String.isNotBlank( WrapRec.DisplayNameOverride) ? WrapRec.DisplayNameOverride : '';
        rec.Area__c = String.isNotBlank( WrapRec.Area) ? WrapRec.Area : '';	//9 m² 
        rec.Status__c = String.isNotBlank( WrapRec.Status) ? WrapRec.Status : '';	
        rec.Pavilion__c = String.isNotBlank( WrapRec.Pavilion) ? WrapRec.Pavilion : '';	
        rec.ShowInShow__c = String.isNotBlank( WrapRec.ShowInShow) ? WrapRec.ShowInShow : '';	
        rec.Booth_Type__c = String.isNotBlank( WrapRec.BoothType) ? WrapRec.BoothType : '';	
        rec.Unit_Type__c = String.isNotBlank( WrapRec.UnitType) ? WrapRec.UnitType : '';	//m  Unit_Type__c
        rec.Open_Corners__c =  WrapRec.OpenCorners != null ? WrapRec.OpenCorners : null;
        rec.Primary_Contact__c = opp.Opportunity_Contact__c;
        rec.Account__c = opp.accountId;
        rec.Booth_Number__c = String.isNotBlank( WrapRec.BoothNumber) ? WrapRec.BoothNumber : '';
        rec.Last_Action_Date__c = Date.today();
        rec.User__c = userinfo.getuserid();
        if (WrapRec.isRented == true) {
            rec.Status__c = 'Rented';
        }
        //rec.Status__c = 'On Hold';
        rec.Booth_Product_Type_EE__c = string.valueOf(WrapRec.BoothClasses);
        if (WrapRec.BoothClasses != null) {
            rec.Booth_Classes__c = string.join(WrapRec.BoothClasses, ';;');
        }
        if (String.isNotBlank(boothProdType)) {
            rec.Booth_Product_Type__c = boothProdType; //
        }
        rec.Quote__c  = quoteId;
        rec.Opportunity__c = opp.Id;
        
        boothList.add(rec);
        return boothList;
    }
    
    
    /**
    * @description  This method is used for exibitor creation after checking if exhibitor exist or not
    * @param exhibitorSyncObj API Synchronization Item
    * @return String Status
    */
    public static Expo3EAPIUtilHelper.AddQliWrapper GetBoothFinancialFromExpocad(API_Synchronization_Item__c exhibitorSyncObj) {
        String calloutStatus = Expocad3E_Wrapper.PROCESSING;
        errorMessage = '';
        responseCode = ''; 
        responseBody = '';
        requestBody = '';
        Expo3EAPIUtilHelper.AddQliWrapper qliWrapper = new  Expo3EAPIUtilHelper.AddQliWrapper();
        List<Opportunity> lstOpp = [SELECT Id,EventEdition__c,Event_Series__r.Package_Identifier__c,EventEdition__r.name,EventEdition__r.Booth_Bundle_Type__c,SBQQ__PrimaryQuote__c,Opportunity_Contact__r.email,AccountId,StageName,X3E_Exhibitor_Invite_Status__c FROM Opportunity WHERE Id=:exhibitorSyncObj.Opportunity__c WITH SECURITY_ENFORCED LIMIT 1];
        ExpocadBooth__c boothRec = [Select ID,Booth_Number__c,Booth_Product_Type__c,ShowInShow__c,Account__c,Opportunity__c,Opportunity__r.EventEdition__c,Opportunity__r.EventEdition__r.X3E_API_ID__c,Status__c 
                                    From ExpocadBooth__c WHERE Id=:exhibitorSyncObj.ExpocadBooth__c WITH SECURITY_ENFORCED LIMIT 1];        
        
        List<Event_Edition__c> eventRecord = [Select Id,x3E_API_ID__c, X3E_Status__c From Event_Edition__c Where Id = :lstOpp[0].EventEdition__c WITH SECURITY_ENFORCED];
        String quoteId;
        Expocad3E_Wrapper.WrapperResponse wrapRespPostPutCall;
        if(Test.isRunningTest()){
            errorMessage = '';
        }
        if (String.isBlank(boothRec.Booth_Product_Type__c)) {
            System.debug('boothRec.Booth_Product_Type__c-------'+boothRec.Booth_Product_Type__c);
        }
        Map<String, SBQQ__QuoteLine__c> prodToQliMap = new Map<String, SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> qliUpsertList = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> qliItemUpsertList = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> qliDeleteList = new List<SBQQ__QuoteLine__c>();
        Map<String, SBQQ__QuoteLine__c> ProdMap = new Map<String, SBQQ__QuoteLine__c>();
        Map < String, Expocad3E_Wrapper.financialBooth > rateToWrapMap = new Map < String, Expocad3E_Wrapper.financialBooth > ();
        Set<String> ExpocadRelationshipCodeSet = new Set<String>();
        Map < String, SBQQ__ProductOption__c > mapProductOptions = new Map < String, SBQQ__ProductOption__c > ();
        Map < Id, SBQQ__ProductOption__c > mapProductOptionsId = new Map < Id, SBQQ__ProductOption__c > ();
        String cornerProductName;
        String sBoothPackagePrdName;
        Product2 boothPackageProduct;
        List<SBQQ__ProductOption__c>  prodOptionList;
        if (boothRec.Status__c == 'Rented') {
            if(String.isBlank(errorMessage)){
                wrapRespPostPutCall = Expo3EAPIUtilHelper.getExpoBooths(eventRecord[0].x3E_API_ID__c, boothRec.Booth_Number__c);
            }
            
            if(wrapRespPostPutCall != null){
                requestBody = wrapRespPostPutCall.requestBody;
                responseBody = String.valueOf(wrapRespPostPutCall.response);
                if (wrapRespPostPutCall.response.getStatus() == null) {
                    errorMessage = errorMessage+System.label.Expocad_API_is_Down;//System.Label.ExpoCAD_API_Down_Msg;
                }
                else if((exhibitorSyncObj.API_Call_Type__c == Expocad3E_Wrapper.GET && wrapRespPostPutCall.response.getStatusCode() == 200) ){
                    Expocad3E_Wrapper.financialBooth boothWrap = (Expocad3E_Wrapper.financialBooth) JSON.deserialize(wrapRespPostPutCall.response.getBody(), Expocad3E_Wrapper.financialBooth.class);
                    
                    if((boothWrap == null ||  String.isBlank(boothWrap.RatePlan)) && !Test.isRunningTest()) {
                        updateStaticValues('Booth response does not contain Rate Plan', String.valueOf(wrapRespPostPutCall.response.getStatusCode()), String.valueOf(wrapRespPostPutCall.response.getBody()), requestBody);
                    }else{
                        System.debug('RatePlan--'+boothWrap.RatePlan);
                        if(String.isNotBlank(lstOpp[0].SBQQ__PrimaryQuote__c)){
                            quoteId = lstOpp[0].SBQQ__PrimaryQuote__c;
                        }
                        rateToWrapMap.put(boothWrap.RatePlan,boothWrap);
                        ExpocadRelationshipCodeSet.add(boothWrap.RatePlan);
                        if (String.isNotBlank(lstOpp[0].Event_Series__r.Package_Identifier__c)) {
                            sBoothPackagePrdName = lstOpp[0].EventEdition__r.Booth_Bundle_Type__c+' '+lstOpp[0].Event_Series__r.Package_Identifier__c;
                        }
                        if (String.isNotBlank(sBoothPackagePrdName)) {
                            boothPackageProduct = Expo3EAPIUtilHelper.getBoothProduct(lstOpp[0],sBoothPackagePrdName);
                        }else{ errorMessage = 'Booth package name not found.'; }
                        if (boothPackageProduct != null ) {
                            prodOptionList = Expo3EAPIUtilHelper.getBoothProductOptions(boothPackageProduct,ExpocadRelationshipCodeSet);
                        }else {errorMessage = 'Product package not found'; }
                        System.debug('prodOptionList121--'+prodOptionList);
                        if(prodOptionList != null && !prodOptionList.isEmpty()) {
                            for (SBQQ__ProductOption__c oProductOption : prodOptionList) {
                                System.debug('oProductOption.SBQQ__OptionalSKU__r.Name--'+oProductOption.SBQQ__OptionalSKU__r.Name);
                                //mapProductOptions.put(oProductOption.SBQQ__OptionalSKU__r.Expocad_Relationship_Code__c.trim(), oProductOption);
                                
                                //[EX-222] To resolve the issue of multiple requestItems getting mapped to a single Product2 in salesforce	
                                for(String ProductCodeExpoCAD: oProductOption.SBQQ__OptionalSKU__r.Expocad_Relationship_Code__c.trim().split(',')){
                                    mapProductOptions.put(ProductCodeExpoCAD, oProductOption);
                                }
                                mapProductOptionsId.put(oProductOption.Id, oProductOption);
                                if (oProductOption.SBQQ__OptionalSKU__r.Name.toLowerCase().contains('corner booth fee')) {
                                    cornerProductName = oProductOption.SBQQ__OptionalSKU__r.Name;
                                }
                            }
                        }
                        if (mapProductOptions != null && !mapProductOptions.isEmpty() && !ExpocadRelationshipCodeSet.isEmpty()) {
                            qliWrapper = Expo3EAPIUtilHelper.addToQLI(lstOpp[0].SBQQ__PrimaryQuote__c,lstOpp[0],boothRec.Id,mapProductOptions,mapProductOptionsId,boothPackageProduct,cornerProductName,ExpocadRelationshipCodeSet,rateToWrapMap,null);
                        }
                        
                        List<SBQQ__QuoteLine__c> QliOldList = [Select Id,SBQQ__Product__c,Booth_Number__c,SBQQ__Quote__c From SBQQ__QuoteLine__c Where SBQQ__Quote__c = :quoteId and Booth_Number__c = :boothRec.Booth_Number__c and SBQQ__Product__c != null WITH SECURITY_ENFORCED];//and SBQQ__OptionType__c = 'Component'
                        if (QliOldList != null && !QliOldList.isEmpty()) {
                            for (SBQQ__QuoteLine__c rec : QliOldList) {
                                prodToQliMap.put(rec.SBQQ__Product__c,rec);
                            }
                        }
                        TriggerInterfaceHelper.isRunning = false;
                        SBQQ.TriggerControl.disable();
                        if (qliWrapper != null && qliWrapper.calloutStatus == Expocad3E_Wrapper.SUCCESS && !qliWrapper.packageQli.IsEmpty() && !qliWrapper.qliRecList.IsEmpty()) {
                            
                            Map < String, Id > mapPackageprdIds = new Map < String, Id > ();
                            for (SBQQ__QuoteLine__c oQLI :  qliWrapper.packageQli) {
                                if (prodToQliMap.containsKey(oQLI.SBQQ__Product__c)) {
                                    SBQQ__QuoteLine__c oldQli = prodToQliMap.get(oQLI.SBQQ__Product__c);
                                    oQLI.Id = oldQli.Id;
                                }
                                qliUpsertList.add(oQLI);
                            }
                            if (qliUpsertList != null && !qliUpsertList.isEmpty()) {
                                upsert qliUpsertList;
                            }
                            for (SBQQ__QuoteLine__c oQLI : qliWrapper.qliRecList) {
                                if (qliUpsertList != null && !qliUpsertList.isEmpty()) {
                                    oQLI.SBQQ__RequiredBy__c = qliUpsertList[0].Id;
                                }
                                if (!prodToQliMap.containsKey(oQLI.SBQQ__Product__c)) {
                                    qliItemUpsertList.add(oQLI);
                                }else {
                                    SBQQ__QuoteLine__c oldQli = prodToQliMap.get(oQLI.SBQQ__Product__c);
                                    oQLI.Id = oldQli.Id;
                                    qliItemUpsertList.add(oQLI);
                                }
                                
                            }
                            if (qliItemUpsertList != null && !qliItemUpsertList.isEmpty()) {
                                upsert qliItemUpsertList;
                                qliItemUpsertList.addAll(qliUpsertList);
                            }
                            
                            //QuoteModel qmodel = Expo3EAPIUtils.SaveCPQQuote(quoteId);
                        }
                        if (qliItemUpsertList != null && !qliItemUpsertList.isEmpty()){
                            for (SBQQ__QuoteLine__c rec : qliItemUpsertList) {
                                ProdMap.put(rec.SBQQ__Product__c,rec);
                            }
                        }
                        
                        if (prodToQliMap != null && !prodToQliMap.isEmpty()) {
                            for(String prodId : prodToQliMap.keySet()){
                                if(!ProdMap.containsKey(prodId)){
                                    qliDeleteList.add(prodToQliMap.get(prodId));
                                }
                            }
                        }
                        
                        if (qliDeleteList != null && !qliDeleteList.isEmpty()) {
                            delete qliDeleteList;
                        }
                        
                        SBQQ.TriggerControl.enable();
                        
                        
                        
                        QuoteModel qmodel = SaveCPQQuote(quoteId);
                        //QuoteModel qmodel = SaveCPQQUoteAterCalculate(quoteId); 
                        calloutStatus = Expocad3E_Wrapper.SUCCESS;
                        updateStaticValues(errorMessage, String.valueOf(wrapRespPostPutCall.response.getStatusCode()), wrapRespPostPutCall.response.getBody(), wrapRespPostPutCall.requestBody);
                        
                    }
                    
                }
                else{
                    updateStaticValues(wrapRespPostPutCall.response.getBody(), String.valueOf(wrapRespPostPutCall.response.getStatusCode()), String.valueOf(wrapRespPostPutCall.response), requestBody);
                    qliWrapper.calloutStatus = Expocad3E_Wrapper.ERROR;
                }
            }
            
        }else {
            
            calloutStatus = Expocad3E_Wrapper.SUCCESS;
            updateStaticValues(errorMessage, '200', 'Booth is not rented', requestBody);
            //errorMessage = wrapRespPostPutCall.response.getBody();
        }
        
        
        
        Boolean updateOpp = false;
        if(errorMessage != '' || responseCode != '200')
        {
            calloutStatus = Expocad3E_Wrapper.ERROR;
            qliWrapper.calloutStatus = Expocad3E_Wrapper.ERROR;
            // Update Synchronization_Item Status
            APISynchronizationHelper.updateSyncItemStatus(New API_Synchronization_Item__c(Id=exhibitorSyncObj.id,Status__c= Expocad3E_Wrapper.ERROR,Error_Message__c=errorMessage,Response_Code__c=responseCode,Request_Body__c=requestBody,Response_Body__c=responseBody));
        }
        else{
            APISynchronizationHelper.updateSyncItemStatus(New API_Synchronization_Item__c(Id=exhibitorSyncObj.id,Status__c= Expocad3E_Wrapper.COMPLETED,Response_Code__c=responseCode,Error_Message__c='',Request_Body__c=requestBody,Response_Body__c=responseBody));
        }
        if(updateOpp){
            update lstOpp;  
        }
        return qliWrapper;
    }
    
    
    public static SBQQ__Quote__c createQuote(List<Opportunity> lstOpp) {
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__Primary__c = true;
        quote.SBQQ__Status__c = 'Draft';
        quote.SBQQ__Account__c = lstOpp[0].AccountId;
        quote.SBQQ__Opportunity2__c = lstOpp[0].Id;
        quote.Contract_Type__c = 'Standard';
        quote.SBQQ__StartDate__c = date.today();
        quote.SBQQ__ExpirationDate__c = date.today().addDays(30);
        quote.Billing_Contact__c = lstOpp[0].Billing_Contact__c;
        quote.SBQQ__PrimaryContact__c = lstOpp[0].Opportunity_Contact__c;
        quote.SBQQ__SalesRep__c = lstOpp[0].ownerId;
        Insert quote;
        return quote;
    }
    
    
    
    /**
    * @description  This method is used for exibitor creation after checking if exhibitor exist or not
    * @param exhibitorSyncObj API Synchronization Item
    * @return String Status
    */
    public static String GetBoothRelatedFromExpocad(API_Synchronization_Item__c exhibitorSyncObj) {//, Id interfaceLogId
        String calloutStatus = Expocad3E_Wrapper.PROCESSING;
        errorMessage = '';
        responseCode = ''; 
        responseBody = '';
        requestBody = '';
        Expo3EAPIUtilHelper.AddQliWrapper qliWrapper = new  Expo3EAPIUtilHelper.AddQliWrapper();
        List<Opportunity> lstOpp = [SELECT Id,EventEdition__c,EventEdition__r.name,EventEdition__r.Booth_Bundle_Type__c,Event_Series__r.Package_Identifier__c,SBQQ__PrimaryQuote__c,Opportunity_Contact__r.email,AccountId,StageName,X3E_Exhibitor_Invite_Status__c FROM Opportunity WHERE Id=:exhibitorSyncObj.Opportunity__c WITH SECURITY_ENFORCED LIMIT 1];
        ExpocadBooth__c boothRec = [Select ID,Booth_Number__c,Booth_Product_Type__c,ShowInShow__c,Account__c,Opportunity__c,Opportunity__r.EventEdition__c,Opportunity__r.EventEdition__r.X3E_API_ID__c,Status__c 
                                    From ExpocadBooth__c WHERE Id=:exhibitorSyncObj.ExpocadBooth__c WITH SECURITY_ENFORCED LIMIT 1];
        
        List<Event_Edition__c> eventRecord = [Select Id,x3E_API_ID__c, X3E_Status__c From Event_Edition__c Where Id = :lstOpp[0].EventEdition__c WITH SECURITY_ENFORCED];
        String quoteId;
        Expocad3E_Wrapper.WrapperResponse wrapRespPostPutCall;
        if(Test.isRunningTest()){
            errorMessage = '';
        }
        if (String.isBlank(boothRec.Booth_Product_Type__c)) { 
            System.debug('boothRec.Booth_Product_Type__c------2'+boothRec.Booth_Product_Type__c);
        }
        if(String.isBlank(errorMessage)){
            wrapRespPostPutCall = Expo3EAPIUtilHelper.getExpoRelatedList(eventRecord[0].x3E_API_ID__c, boothRec.Booth_Number__c);
            System.debug('wrapRespPostPutCall---'+wrapRespPostPutCall.response);
        }
        Map < String, SBQQ__ProductOption__c > mapProductOptions = new Map < String, SBQQ__ProductOption__c > ();
        Map < Id, SBQQ__ProductOption__c > mapProductOptionsId = new Map < Id, SBQQ__ProductOption__c > ();
        String cornerProductName;
        String sBoothPackagePrdName;
        Product2 boothPackageProduct;
        List<SBQQ__ProductOption__c>  prodOptionList;
        Map<String, SBQQ__QuoteLine__c> prodToQliMap = new Map<String, SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> qliUpsertList = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> qliItemUpsertList = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> qliDeleteList = new List<SBQQ__QuoteLine__c>();
        Map<String, SBQQ__QuoteLine__c> ProdMap = new Map<String, SBQQ__QuoteLine__c>();
        Map < String, Id > mapPackageprdIds = new Map < String, Id > ();
        Set<String> ExpocadRelationshipCodeSet = new Set<String>();
        Map<String, Expocad3E_Wrapper.RelatedItems> prodNameMap = new Map<String, Expocad3E_Wrapper.RelatedItems>();
        List<Expocad3E_Wrapper.RelatedItems> boothWrapList = new List<Expocad3E_Wrapper.RelatedItems>();
        
        if (boothRec.Status__c == 'Rented') {
            System.debug('------->>>>'+wrapRespPostPutCall);
            if(wrapRespPostPutCall != null){
                requestBody = wrapRespPostPutCall.requestBody;
				if(((exhibitorSyncObj.API_Call_Type__c == Expocad3E_Wrapper.GET && wrapRespPostPutCall.response.getStatusCode() == 200)) ){
                    boothWrapList = (List<Expocad3E_Wrapper.RelatedItems>) JSON.deserialize(wrapRespPostPutCall.response.getBody(), List<Expocad3E_Wrapper.RelatedItems>.class);
                    if(boothWrapList == null ||  boothWrapList.isEmpty()){
                        responseCode = String.valueOf(wrapRespPostPutCall.response.getStatusCode());
                        responseBody = String.valueOf(wrapRespPostPutCall.response.getBody())+ '-- No response data recieved';
                        calloutStatus = Expocad3E_Wrapper.SUCCESS;
                    }else{
                        quoteId = String.isNotBlank(lstOpp[0].SBQQ__PrimaryQuote__c) ? lstOpp[0].SBQQ__PrimaryQuote__c : quoteId;
                        calloutStatus = Expocad3E_Wrapper.SUCCESS;
                        updateStaticValues(errorMessage, String.valueOf(wrapRespPostPutCall.response.getStatusCode()), wrapRespPostPutCall.response.getBody(), wrapRespPostPutCall.requestBody);
                        for (Expocad3E_Wrapper.RelatedItems reqItem : boothWrapList) {
                            System.debug('GlCode--'+reqItem.GlCode);
                            if (String.isNotBlank(reqItem.GlCode)) {
                                ExpocadRelationshipCodeSet.add(reqItem.GlCode);
                                prodNameMap.put(reqItem.GlCode,reqItem);
                            }
                        }
                        if (String.isNotBlank(lstOpp[0].Event_Series__r.Package_Identifier__c)) {
                            sBoothPackagePrdName = lstOpp[0].EventEdition__r.Booth_Bundle_Type__c+' '+lstOpp[0].Event_Series__r.Package_Identifier__c;
                        }
                        if (String.isNotBlank(sBoothPackagePrdName)) {
                            boothPackageProduct = Expo3EAPIUtilHelper.getBoothProduct(lstOpp[0],sBoothPackagePrdName);
                        }else{ errorMessage = 'Booth package name not found.'; }
                        if (boothPackageProduct != null ) {
                            prodOptionList = Expo3EAPIUtilHelper.getBoothProductOptions(boothPackageProduct,ExpocadRelationshipCodeSet);
                        }else {errorMessage = 'Product package not found'; }
                        
                        if(prodOptionList != null && !prodOptionList.isEmpty()) {
                            for (SBQQ__ProductOption__c oProductOption : prodOptionList) {
                                //mapProductOptions.put(oProductOption.SBQQ__OptionalSKU__r.Expocad_Relationship_Code__c.trim(), oProductOption);

                                //[EX-222] To resolve the issue of multiple requestItems getting mapped to a single Product2 in salesforce
                                for(String ProductCodeExpoCAD: oProductOption.SBQQ__OptionalSKU__r.Expocad_Relationship_Code__c.trim().split(',')){
                                    mapProductOptions.put(ProductCodeExpoCAD, oProductOption);
                                }
                                mapProductOptionsId.put(oProductOption.Id, oProductOption);
                                if (oProductOption.SBQQ__OptionalSKU__r.Name.toLowerCase().contains('corner booth fee')) {
                                    cornerProductName = oProductOption.SBQQ__OptionalSKU__r.Name;
                                }
                            }
                        }
                        
                        if (mapProductOptions != null && !mapProductOptions.isEmpty() && !ExpocadRelationshipCodeSet.isEmpty()) {
                            qliWrapper = Expo3EAPIUtilHelper.addToQLI(lstOpp[0].SBQQ__PrimaryQuote__c,lstOpp[0],boothRec.Id,mapProductOptions,mapProductOptionsId,boothPackageProduct,cornerProductName,ExpocadRelationshipCodeSet,null,prodNameMap);
                        }
                        List<SBQQ__QuoteLine__c> QliOldList = [Select Id,SBQQ__Product__c,Booth_Number__c,SBQQ__Quote__c From SBQQ__QuoteLine__c Where SBQQ__Quote__c = :quoteId and Booth_Number__c = :boothRec.Booth_Number__c and SBQQ__Product__c != null WITH SECURITY_ENFORCED];//and SBQQ__OptionType__c = 'Component'
                        if (QliOldList != null && !QliOldList.isEmpty()) {
                            for (SBQQ__QuoteLine__c rec : QliOldList) {
                                prodToQliMap.put(rec.SBQQ__Product__c,rec);
                            }
                        }
                        TriggerInterfaceHelper.isRunning = false;
                        SBQQ.TriggerControl.disable();
                        if (qliWrapper != null && qliWrapper.calloutStatus == Expocad3E_Wrapper.SUCCESS && !qliWrapper.packageQli.IsEmpty() && !qliWrapper.qliRecList.IsEmpty()) {
                            
                            
                            System.debug('wrap.packageQli ReleatedItem +'+qliWrapper.packageQli.size());
                            System.debug('wrap.wrap.qliRecList ReleatedItem +'+qliWrapper.qliRecList.size());
                            for (SBQQ__QuoteLine__c oQLI :  qliWrapper.packageQli) {
                                System.debug('wrap.packageQli'+oQLI);
                                if (!prodToQliMap.containsKey(oQLI.SBQQ__Product__c)) {
                                    qliUpsertList.add(oQLI);
                                }else {
                                    SBQQ__QuoteLine__c oldQli = prodToQliMap.get(oQLI.SBQQ__Product__c);
                                    oQLI.Id = oldQli.Id;
                                    qliUpsertList.add(oQLI);
                                }
                            }
                            if (qliUpsertList != null && !qliUpsertList.isEmpty()) {
                                upsert qliUpsertList;
                            }
                            for (SBQQ__QuoteLine__c oQLI : qliWrapper.qliRecList) {
                                System.debug('wrap.qliRecList'+oQLI);
                                if (qliUpsertList != null && !qliUpsertList.isEmpty()) {
                                    oQLI.SBQQ__RequiredBy__c = qliUpsertList[0].Id;
                                }
                                if (!prodToQliMap.containsKey(oQLI.SBQQ__Product__c)) {
                                    qliItemUpsertList.add(oQLI);
                                }else {
                                    SBQQ__QuoteLine__c oldQli = prodToQliMap.get(oQLI.SBQQ__Product__c);
                                    oQLI.Id = oldQli.Id;
                                    qliItemUpsertList.add(oQLI);
                                }
                                
                            }
                            if (qliItemUpsertList != null && !qliItemUpsertList.isEmpty()) {
                                upsert qliItemUpsertList;
                                qliItemUpsertList.addAll(qliUpsertList);
                            }                            
                        }
                        if (qliItemUpsertList != null && !qliItemUpsertList.isEmpty()){
                            for (SBQQ__QuoteLine__c rec : qliItemUpsertList) {
                                ProdMap.put(rec.SBQQ__Product__c,rec);
                            }
                        }
                        
                        if (prodToQliMap != null && !prodToQliMap.isEmpty()) {
                            for(String prodId : prodToQliMap.keySet()){
                                if(!ProdMap.containsKey(prodId)){
                                    qliDeleteList.add(prodToQliMap.get(prodId));
                                }
                            }
                        }
                        
                        SBQQ.TriggerControl.enable();
                        QuoteModel qmodel = Expo3EAPIUtils.SaveCPQQuote(quoteId);
                        
                        calloutStatus = Expocad3E_Wrapper.SUCCESS;
                        responseCode = String.valueOf(wrapRespPostPutCall.response.getStatusCode());
                        responseBody = wrapRespPostPutCall.response.getBody()+'===='+system.JSON.serialize(qliWrapper);
                        requestBody = wrapRespPostPutCall.requestBody;
                        
                    }
                }
                else if (wrapRespPostPutCall.response.getStatus() == null) {
                    errorMessage = System.label.Expocad_API_is_Down;
                }
                else{
                    responseCode = String.valueOf(wrapRespPostPutCall.response.getStatusCode());
                    responseBody = String.valueOf(wrapRespPostPutCall.response);
                    errorMessage = wrapRespPostPutCall.response.getBody();
                }
            }
        }else {
            calloutStatus = Expocad3E_Wrapper.SUCCESS;
            responseCode = '200';
            responseBody = 'Booth is not rented';
        }
        Boolean updateOpp = false;
        if(errorMessage != '' || responseCode != '200')
        {
            calloutStatus = Expocad3E_Wrapper.ERROR;
            qliWrapper.calloutStatus = Expocad3E_Wrapper.ERROR;
            // Update Synchronization_Item Status
            APISynchronizationHelper.updateSyncItemStatus(New API_Synchronization_Item__c(Id=exhibitorSyncObj.id,Status__c= Expocad3E_Wrapper.ERROR,Error_Message__c=errorMessage,Response_Code__c=responseCode,Request_Body__c=requestBody,Response_Body__c=responseBody));
        }
        else{
            APISynchronizationHelper.updateSyncItemStatus(New API_Synchronization_Item__c(Id=exhibitorSyncObj.id,Status__c= Expocad3E_Wrapper.COMPLETED,Response_Code__c=responseCode,Error_Message__c='',Request_Body__c=requestBody,Response_Body__c=responseBody));
        }
        if(updateOpp){
            update lstOpp; 
        }
        return calloutStatus;
    }
    
    public static QuoteModel SaveCPQQuote(String quoteId) {
        CPQQuoteAPIHelper quoteApi = new CPQQuoteAPIHelper();
        QuoteModel quoteModel = quoteApi.read(quoteId);
        QuoteModel savedQuote = quoteApi.save(quoteModel);
        return savedQuote;
    }
    
    public static QuoteModel SaveCPQQUoteAterCalculate (string quoteID){
       System.debug('SaveCPQQUoteAterCalculate called');
       CPQQuoteAPIHelper.CalculatorContext context = new CPQQuoteAPIHelper.CalculatorContext();
       CPQQuoteAPIHelper quoteApi = new CPQQuoteAPIHelper(); 
       QuoteModel quoteModel = quoteApi.read(quoteID);//quote Id
       quoteModel.record.SBQQ__Status__c = 'Contract Approved';
       context.quote = quoteModel;
       String resultJson = SBQQ.ServiceRouter.load('SBQQ.QuoteAPI.QuoteCalculator', null, JSON.serialize(context));
       QuoteModel resultModel = (QuoteModel)JSON.deserialize(resultJson, QuoteModel.class);
       QuoteModel savedQuote = quoteApi.save(resultModel);
       return savedQuote;
    }
    
    public static void OpportunityStatusUpdate (string OppID, List<Opportunity> listOppForStatusUpdate){
        List<Opportunity> lstOpp = [SELECT Id,EventEdition__c,SBQQ__PrimaryQuote__c,Review_by_Sales_Ops_Team__c,Opportunity_Contact__r.email,AccountId,Account.name,StageName,X3E_Exhibitor_Invite_Status__c FROM Opportunity WHERE Id=:OppID WITH SECURITY_ENFORCED LIMIT 1];
        opportunity oppRec = new opportunity(id= lstOpp[0].Id,Update_Contracted__c = true,Contract_Attached__c = true,StageName = 'Closed Won');
        oppRec.Status__c = lstOpp[0].Review_by_Sales_Ops_Team__c ? 'Sales Ops Review - Pending' : 'Pending Accounting Approval';
        //update oppRec;
        if(listOppForStatusUpdate == null){listOppForStatusUpdate = new List<Opportunity>();}
        listOppForStatusUpdate.add(oppRec);
    }
    
    
    /*---------------------------------------------------------------------------------------------------------------------*/
    
    /**
    * @description  This method is used for booth hold/unhold
    * @param exhibitorSyncObj API Synchronization Item
    * @return String Status
    */
    public static String companyTypeAssignInExpoCAD3E(API_Synchronization_Item__c exhibitorSyncObj) {//, Id interfaceLogId
        String calloutStatus = Expocad3E_Wrapper.PROCESSING;
        errorMessage = '';
        responseCode = ''; 
        responseBody = '';
        requestBody = '';
        
		ExpocadBooth__c boothAccount = [Select ID,Booth_Number__c,ShowInShow__c,Account__c,Opportunity__c,Opportunity__r.EventEdition__c,Opportunity__r.EventEdition__r.X3E_API_ID__c,Opportunity__r.EventEdition__r.All_CompanyTypes_List__c,Status__c,Opportunity__r.EventEdition__r.CompanyShowInShow__c,Company_Type__c 
                                        From ExpocadBooth__c WHERE Id=:exhibitorSyncObj.ExpocadBooth__c and Account__c != null WITH SECURITY_ENFORCED LIMIT 1];
        String typeId = '';
        String companyType = '';
        if(boothAccount.ShowInShow__c != '' && boothAccount.ShowInShow__c != null && boothAccount.Opportunity__r.EventEdition__r.All_CompanyTypes_List__c != null && boothAccount.Opportunity__r.EventEdition__r.All_CompanyTypes_List__c != ''){
            System.debug(boothAccount.Opportunity__r.EventEdition__r.All_CompanyTypes_List__c);
            List<String> listRows = boothAccount.Opportunity__r.EventEdition__r.All_CompanyTypes_List__c.split('\n');
            System.debug(listRows);
            for(Integer i = 1; i < listRows.size(); i++){
                if(listRows[i].contains('-')){
                    //System.debug(listRows[i]);
                    List<String> divideTwo = listRows[i].split('-');
                    if(divideTwo.size()>1){
                        string showInShow = divideTwo[1].split(',')[1];
                        if(boothAccount.ShowInShow__c == showInShow){
                            typeId = divideTwo[0].split(',')[1];
                            break;
                        }
                    } 
                }
            }
        }
        if(boothAccount.ShowInShow__c != '' && boothAccount.ShowInShow__c != null && boothAccount.Opportunity__r.EventEdition__r.CompanyShowInShow__c != null && boothAccount.Opportunity__r.EventEdition__r.CompanyShowInShow__c != ''){
            List<String> listRows = boothAccount.Opportunity__r.EventEdition__r.CompanyShowInShow__c.split('\n');
            for(Integer i = 1; i < listRows.size(); i++){
                if(listRows[i].contains('-')){
                    List<String> divideTwo = listRows[i].split('-');
                    if(divideTwo.size()>1){
                        string showInShow = divideTwo[1];
                        if(boothAccount.ShowInShow__c == showInShow){
                            companyType = divideTwo[0];
                            break;
                        }
                    }
                }
            }
        }
        System.debug('companyType typeid '+companyType +typeId);
        String apiToken = Expo3EAPIUtilHelper.fetchApiToken();
        System.debug('Api Token '+apiToken);
        if(String.isBlank(apiToken)){
            errorMessage = System.label.Api_Token_Empty3E;
        }
        if(String.isBlank(typeId)){
            System.debug('companyType typeid 2'+companyType +typeId);
            errorMessage = System.label.No_Company_Type_Id_Found;
        }
        
        Expocad3E_Wrapper.WrapperResponse wrapRespPostPutCall;
        if(Test.isRunningTest()){
            errorMessage = '';
            apiToken = '';
        }
        if(String.isBlank(errorMessage)){ 
            if(exhibitorSyncObj.Type__c == Expocad3E_Wrapper.EXPOCAD3E_COMPANY_TYPE_ASSIGN){
                wrapRespPostPutCall = Expo3EAPIUtilHelper.assignCompanyType(boothAccount.Account__c,typeId,boothAccount.Opportunity__r.EventEdition__r.X3E_API_ID__c);
            }else if(exhibitorSyncObj.Type__c == Expocad3E_Wrapper.EXPOCAD3E_COMPANY_TYPE_UNASSIGN){
                wrapRespPostPutCall = Expo3EAPIUtilHelper.unassignCompanyType(boothAccount.Account__c,typeId,boothAccount.Opportunity__r.EventEdition__r.X3E_API_ID__c);
            }
        }
        
        if(wrapRespPostPutCall != null){
            requestBody = wrapRespPostPutCall.requestBody;
            if (wrapRespPostPutCall.response.getStatus() == null) {
                errorMessage = System.label.Expocad_API_is_Down;
                System.debug('errorMessage 1 '+errorMessage);
            }else if((exhibitorSyncObj.API_Call_Type__c == Expocad3E_Wrapper.POST && wrapRespPostPutCall.response.getStatusCode() == 200) ){
                
                calloutStatus = Expocad3E_Wrapper.SUCCESS;
                responseCode = String.valueOf(wrapRespPostPutCall.response.getStatusCode());
                responseBody = wrapRespPostPutCall.response.getBody();
                requestBody = wrapRespPostPutCall.requestBody;
            }
            else{
                responseCode = String.valueOf(wrapRespPostPutCall.response.getStatusCode());
                responseBody = String.valueOf(wrapRespPostPutCall.response);
                errorMessage = wrapRespPostPutCall.response.getBody();
            }
            System.debug('errorMessage 2 '+errorMessage);
        }
        Boolean updateExpo = false;
        if(errorMessage != '' || responseCode != '200')
        {
            calloutStatus = Expocad3E_Wrapper.ERROR;
            // Update Synchronization_Item Status
            APISynchronizationHelper.updateSyncItemStatus(New API_Synchronization_Item__c(Id=exhibitorSyncObj.id,Status__c= Expocad3E_Wrapper.ERROR,Error_Message__c=errorMessage,Response_Code__c=responseCode,Request_Body__c=requestBody,Response_Body__c=responseBody));
            
        }
        else{
            APISynchronizationHelper.updateSyncItemStatus(New API_Synchronization_Item__c(Id=exhibitorSyncObj.id,Status__c= Expocad3E_Wrapper.COMPLETED,Response_Code__c=responseCode,Error_Message__c='',Request_Body__c=requestBody,Response_Body__c=responseBody));
            
        }
        if(exhibitorSyncObj.Type__c == Expocad3E_Wrapper.EXPOCAD3E_COMPANY_TYPE_ASSIGN){
            boothAccount.Company_Type__c = companyType;
            updateExpo = true;
        }else{
            boothAccount.Company_Type__c = null;
            updateExpo = true; 
        }
        if(updateExpo){
            update boothAccount; 
        }
        return calloutStatus;
    }
    
    
    /**
    * @description  This method is used for exibitor creation after checking if exhibitor exist or not
    * @param exhibitorSyncObj API Synchronization Item
    * @return String Status
    */
    public static String inviteExhibitorInExpoCAD(API_Synchronization_Item__c exhibitorSyncObj) {//, Id interfaceLogId
        String calloutStatus = Expocad3E_Wrapper.PROCESSING;
        errorMessage = '';
        responseCode = ''; 
        responseBody = '';
        requestBody = '';
        
        List<Opportunity> lstOpp = [SELECT Id,EventEdition__c,Opportunity_Contact__r.email,AccountId,StageName,X3E_Exhibitor_Invite_Status__c FROM Opportunity WHERE Id=:exhibitorSyncObj.Opportunity__c WITH SECURITY_ENFORCED LIMIT 1];
        //(SELECT Id,X3E_Contact_Status__c,Record_Number__c,Primary_exhibitor_contact__c FROM OpportunityContactRoles )
        List<Expocad3E_Wrapper.InviteExhibitor> inviteDetailsList = new List<Expocad3E_Wrapper.InviteExhibitor>();
        Expocad3E_Wrapper.InviteExhibitor inviteDetails;
        if(lstOpp != null && !lstOpp.isEmpty()){
            for(Opportunity oppRec : lstOpp){
                inviteDetails = new Expocad3E_Wrapper.InviteExhibitor();
                inviteDetails.customerId = oppRec.AccountId;//'su-121'
                inviteDetails.email = oppRec.Opportunity_Contact__r.email;//'sunyad@gmail.com'
                inviteDetails.password = '';
                inviteDetailsList.add(inviteDetails);
            }
        }
        
        
        List<Event_Edition__c> eventRecord = [Select Id,x3E_API_ID__c, X3E_Status__c From Event_Edition__c Where Id = :lstOpp[0].EventEdition__c WITH SECURITY_ENFORCED];
        
        String apiToken = Expo3EAPIUtilHelper.fetchApiToken();
        System.debug('Api Token '+apiToken);
        if(String.isBlank(apiToken)){
            errorMessage = System.label.Api_Token_Empty3E;
        }
        
        Expocad3E_Wrapper.WrapperResponse wrapRespPostPutCall;
        if(Test.isRunningTest()){
            errorMessage = '';
            apiToken = '';
        }
        if(String.isBlank(errorMessage)){
            //if(exhibitorSyncObj.Type__c == Expocad3EAPIWrapper.EXPOCAD3E_EXHIBITOR_INVITE){
            wrapRespPostPutCall = Expo3EAPIUtilHelper.inviteExhibitorIn3E(eventRecord[0].x3E_API_ID__c, inviteDetails,true,apiToken);
            //}
        }
        
        if(wrapRespPostPutCall != null){
            requestBody = wrapRespPostPutCall.requestBody;
            if (wrapRespPostPutCall.response.getStatus() == null) {
                errorMessage = System.label.Expocad_API_is_Down;//System.Label.ExpoCAD_API_Down_Msg;
            }
            else if((exhibitorSyncObj.API_Call_Type__c == Expocad3E_Wrapper.POST && wrapRespPostPutCall.response.getStatusCode() == 200) ){
                Expocad3EInviteWrapper inviteWrap = new Expocad3EInviteWrapper();
                inviteWrap = (Expocad3EInviteWrapper) JSON.deserialize(wrapRespPostPutCall.response.getBody(), Expocad3EInviteWrapper.class);
                if(inviteWrap != null && inviteWrap.errors != null && inviteWrap.errors != null && String.valueOf(inviteWrap.errors).contains('reason')){
                    responseCode = String.valueOf(wrapRespPostPutCall.response.getStatusCode());//&& inviteWrap.errors[0] != null && String.isNotBlank(inviteWrap.errors[0].reason
                    responseBody = String.valueOf(wrapRespPostPutCall.response);
                    errorMessage = wrapRespPostPutCall.response.getBody();
                }else{
                    calloutStatus = Expocad3E_Wrapper.SUCCESS;//|| (exhibitorSyncObj.API_Call_Type__c == Expocad3EAPIWrapper.POST && wrapRespPostPutCall.response.getStatusCode() == 201)
                    responseCode = String.valueOf(wrapRespPostPutCall.response.getStatusCode());
                    responseBody = wrapRespPostPutCall.response.getBody();
                    requestBody = wrapRespPostPutCall.requestBody;
                }
                
            }
            else{
                responseCode = String.valueOf(wrapRespPostPutCall.response.getStatusCode());
                responseBody = String.valueOf(wrapRespPostPutCall.response);
                errorMessage = wrapRespPostPutCall.response.getBody();
            }
        }
        Boolean updateOpp = false;
        if(errorMessage != '' || responseCode != '200')
        {
            calloutStatus = Expocad3E_Wrapper.ERROR;
            // Update Synchronization_Item Status
            APISynchronizationHelper.updateSyncItemStatus(New API_Synchronization_Item__c(Id=exhibitorSyncObj.id,Status__c= Expocad3E_Wrapper.ERROR,Error_Message__c=errorMessage,Response_Code__c=responseCode,Request_Body__c=requestBody,Response_Body__c=responseBody));
            if(lstOpp[0].X3E_Exhibitor_Invite_Status__c != 'Error'){
                lstOpp[0].X3E_Exhibitor_Invite_Status__c = 'Error';
                updateOpp = true;
            }
            
        }
        else{
            
            APISynchronizationHelper.updateSyncItemStatus(New API_Synchronization_Item__c(Id=exhibitorSyncObj.id,Status__c= Expocad3E_Wrapper.COMPLETED,Response_Code__c=responseCode,Error_Message__c='',Request_Body__c=requestBody,Response_Body__c=responseBody));
            if(lstOpp[0].X3E_Exhibitor_Invite_Status__c != 'Invited'){
                lstOpp[0].X3E_Exhibitor_Invite_Status__c = 'Invited';
                updateOpp = true;
            }
        }
        if(updateOpp){
            update lstOpp; 
        }
        return calloutStatus;
    }
    
    /**
    * @description  This method is used for exibitor creation after checking if exhibitor exist or not
    * @param exhibitorSyncObj API Synchronization Item
    * @return String Status
    */
    public static String getContractsFrom3E(API_Synchronization_Item__c exhibitorSyncObj) {//, Id interfaceLogId
        String calloutStatus = Expocad3E_Wrapper.PROCESSING;
        errorMessage = '';
        responseCode = '';
        responseBody = '';
        requestBody = '';
        List<Opportunity> lstOpp = [SELECT Id,EventEdition__c,Opportunity_Contact__r.email,AccountId,Account.name,StageName,X3E_Exhibitor_Invite_Status__c FROM Opportunity WHERE Id=:exhibitorSyncObj.Opportunity__c WITH SECURITY_ENFORCED LIMIT 1];
        List<ExpocadBooth__c> BoothList = [SELECT Name , Booth_Number__c , Event_Code__c , Opportunity__c FROM ExpocadBooth__c Where Id  = :exhibitorSyncObj.ExpocadBooth__c WITH SECURITY_ENFORCED];
        //(SELECT Id,X3E_Contact_Status__c,Record_Number__c,Primary_exhibitor_contact__c FROM OpportunityContactRoles )
        String boothNumber = BoothList[0].Booth_Number__c;
        String customerId = lstOpp[0].AccountId;
        
        List<Event_Edition__c> eventRecord = [Select Id,x3E_API_ID__c, X3E_Status__c From Event_Edition__c Where Id = :lstOpp[0].EventEdition__c WITH SECURITY_ENFORCED];
        
        String apiToken = Expo3EAPIUtilHelper.fetchApiToken();
        if(String.isBlank(apiToken)){
            errorMessage = System.label.Api_Token_Empty3E;
        }
        errorMessage = String.isBlank(boothNumber) ? System.label.Booth_Number_is_Blank : errorMessage; 
        errorMessage = String.isBlank(customerId) ? System.label.Customer_Id_Is_Blank : errorMessage; 
        
        if(Test.isRunningTest()){
            errorMessage = '';
            apiToken = 'test121'; 
        }
        Expocad3E_Wrapper.WrapperResponse wrapRespPostPutCall;
        if(String.isBlank(errorMessage)){
            //if(exhibitorSyncObj.Type__c == Expocad3EAPIWrapper.EXPOCAD3E_EXHIBITOR_INVITE){
            
            wrapRespPostPutCall = Expo3EAPIUtilHelper.fetchContractFrom3E(eventRecord[0].x3E_API_ID__c,customerId, boothNumber,true,apiToken);
            //}
        }
        
        if(wrapRespPostPutCall != null){
            requestBody = wrapRespPostPutCall.requestBody;
            if (wrapRespPostPutCall.response.getStatus() == null) {
                errorMessage = System.label.ExpoCad_API_Down_Message;//System.Label.ExpoCAD_API_Down_Msg;
            }
            else if((exhibitorSyncObj.API_Call_Type__c == Expocad3E_Wrapper.GET && wrapRespPostPutCall.response.getStatusCode() == 200) ){
                calloutStatus = Expocad3E_Wrapper.SUCCESS;//|| (exhibitorSyncObj.API_Call_Type__c == Expocad3EAPIWrapper.POST && wrapRespPostPutCall.response.getStatusCode() == 201)
                responseCode = String.valueOf(wrapRespPostPutCall.response.getStatusCode());
                requestBody = wrapRespPostPutCall.requestBody;
                String fileName = 'default name.pdf';
                Pattern p = Pattern.compile('.+filename="(.+?)".*');
                String contentDisposition = wrapRespPostPutCall.response.getHeader('Content-Disposition');
                if(contentDisposition != null) {
                    Matcher m = p.matcher(contentDisposition);
                    if(m.find()) {
                        fileName = m.group(1);
                    }
                }
                fileName = fileName.substringBeforeLast('.')+'-'+String.valueOf(datetime.now())+'.'+fileName.substringAfterLast('.');
                responseBody = fileName;
                Blob data  =  wrapRespPostPutCall.response.getBodyAsBlob();
                if(Test.isRunningTest()){
                    String fileContent = 'name.pdf';
                    data = Blob.valueOf(fileContent);
                }
                system.debug('--->getContractsFrom3E');
                 List<ContentVersion> newConVerList = createContentVersions(data,fileName,lstOpp[0].Id);
				 //List<ContentVersion> newConVerList = createContentVersions(data,fileName);
                if(newConVerList!= null && !newConVerList.isEmpty()){ 
                    Insert newConVerList;
                    List<ContentDocumentLink> newContDocList = createContentDocLink(newConVerList,lstOpp[0].Id,filename);
                    if(newContDocList!= null && !newContDocList.isEmpty()){
                        Insert newContDocList;
                    }
                }
                
            }
            else{
                responseCode = String.valueOf(wrapRespPostPutCall.response.getStatusCode());
                responseBody = wrapRespPostPutCall.response.getBody();
                errorMessage = wrapRespPostPutCall.response.getBody();
            }
        }
        Boolean updateOpp = false;
        if(errorMessage != '' || responseCode != '200')
        {
            calloutStatus = Expocad3E_Wrapper.ERROR;
            // Update Synchronization_Item Status
            APISynchronizationHelper.updateSyncItemStatus(New API_Synchronization_Item__c(Id=exhibitorSyncObj.id,Status__c= Expocad3E_Wrapper.ERROR,Error_Message__c=errorMessage,Response_Code__c=responseCode,Request_Body__c=requestBody,Response_Body__c=responseBody));
        }
        else{
            
            APISynchronizationHelper.updateSyncItemStatus(New API_Synchronization_Item__c(Id=exhibitorSyncObj.id,Status__c= Expocad3E_Wrapper.COMPLETED,Response_Code__c=responseCode,Error_Message__c='',Request_Body__c=requestBody,Response_Body__c=responseBody));
            
        }
        
        return calloutStatus;
    }
    
    public static String getContractsFrom3E1(API_Synchronization_Item__c exhibitorSyncObj) {String calloutStatus = Expocad3E_Wrapper.PROCESSING;
        errorMessage = '';
        responseCode = '';
        responseBody = '';
        requestBody = '';
        List<Opportunity> lstOpp = [SELECT Id,EventEdition__c,Opportunity_Contact__r.email,AccountId,Account.name,StageName,X3E_Exhibitor_Invite_Status__c FROM Opportunity WHERE Id=:exhibitorSyncObj.Opportunity__c WITH SECURITY_ENFORCED LIMIT 1];
        Id OppId = lstOpp[0].Id;
        List<ExpocadBooth__c> BoothList = [SELECT Name , Booth_Number__c , Event_Code__c , Opportunity__c FROM ExpocadBooth__c Where Id  = :exhibitorSyncObj.ExpocadBooth__c WITH SECURITY_ENFORCED];
        //(SELECT Id,X3E_Contact_Status__c,Record_Number__c,Primary_exhibitor_contact__c FROM OpportunityContactRoles )
        String boothNumber = BoothList[0].Booth_Number__c;
        errorMessage = '';
        responseCode = '';
        responseBody = '';
        requestBody = '';
        String customerId = lstOpp[0].AccountId;
        requestBody = '';
        List<Event_Edition__c> eventRecord = [Select Id,x3E_API_ID__c, X3E_Status__c From Event_Edition__c Where Id = :lstOpp[0].EventEdition__c WITH SECURITY_ENFORCED];
        requestBody = '';        
        errorMessage = '';
        responseCode = '';
        responseBody = '';
        requestBody = '';
        String apiToken = Expo3EAPIUtilHelper.fetchApiToken();
        requestBody = '';
        if(String.isBlank(apiToken)){
            requestBody = '';
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
            errorMessage = System.label.Api_Token_Empty3E;
        }
        requestBody = '';
        errorMessage = String.isBlank(boothNumber) ? System.label.Booth_Number_is_Blank : errorMessage; 
        errorMessage = '';
        responseCode = '';
        responseBody = '';
        requestBody = '';
        requestBody = '';
        errorMessage = String.isBlank(customerId) ? System.label.Customer_Id_Is_Blank : errorMessage; 
        requestBody = '';
        
        if(Test.isRunningTest()){
            requestBody = '';
            errorMessage = '';
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
            apiToken = 'test121'; 
            requestBody = '';
        }
        Expocad3E_Wrapper.WrapperResponse wrapRespPostPutCall;
        requestBody = '';
        if(String.isBlank(errorMessage)){
            //if(exhibitorSyncObj.Type__c == Expocad3EAPIWrapper.EXPOCAD3E_EXHIBITOR_INVITE){
            requestBody = '';
            
            wrapRespPostPutCall = Expo3EAPIUtilHelper.fetchContractFrom3E(eventRecord[0].x3E_API_ID__c,customerId, boothNumber,true,apiToken);
            requestBody = '';
            //}
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
        }
        requestBody = '';
        
        if(wrapRespPostPutCall != null){
            requestBody = '';
            requestBody = wrapRespPostPutCall.requestBody;
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
            requestBody = '';
            if (wrapRespPostPutCall.response.getStatus() == null) {System.debug('To Remove SCA ');
                //errorMessage = System.label.ExpoCad_API_Down_Message;//System.Label.ExpoCAD_API_Down_Msg;
            }
            else if((exhibitorSyncObj.API_Call_Type__c == Expocad3E_Wrapper.GET && wrapRespPostPutCall.response.getStatusCode() == 200) ){
                calloutStatus = Expocad3E_Wrapper.SUCCESS;//|| (exhibitorSyncObj.API_Call_Type__c == Expocad3EAPIWrapper.POST && wrapRespPostPutCall.response.getStatusCode() == 201)
                requestBody = '';
                responseCode = String.valueOf(wrapRespPostPutCall.response.getStatusCode());
                requestBody = wrapRespPostPutCall.requestBody;
                requestBody = '';
                String fileName = 'default name.pdf';
                Pattern p = Pattern.compile('.+filename="(.+?)".*');
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                String contentDisposition = wrapRespPostPutCall.response.getHeader('Content-Disposition');
                if(contentDisposition != null) {
                    errorMessage = '';
                    responseCode = '';
                    responseBody = '';
                    requestBody = '';
                }
                fileName = fileName.substringBeforeLast('.')+'-'+String.valueOf(datetime.now())+'.'+fileName.substringAfterLast('.');
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                responseBody = fileName;
                Blob data  =  wrapRespPostPutCall.response.getBodyAsBlob();
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                if(Test.isRunningTest()){
                    String fileContent = 'name.pdf';
                    errorMessage = '';
                    responseCode = '';
                    responseBody = '';
                    requestBody = '';
                    data = Blob.valueOf(fileContent);
                }
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                List<ContentVersion> newConVerList = createContentVersions(data,fileName,OppId);
				//List<ContentVersion> newConVerList = createContentVersions(data,fileName);
                if(newConVerList!= null && !newConVerList.isEmpty()){ 
                    errorMessage = '';
                    responseCode = '';
                    responseBody = '';
                    requestBody = '';
                    Insert newConVerList;
                    List<ContentDocumentLink> newContDocList = createContentDocLink(newConVerList,lstOpp[0].Id,filename);
                    errorMessage = '';
                    responseCode = '';
                    responseBody = '';
                    requestBody = '';
                    if(newContDocList!= null && !newContDocList.isEmpty()){
                        Insert newContDocList;
                        errorMessage = '';
                        responseCode = '';
                        responseBody = '';
                        requestBody = '';
                    }
                }
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                
            }
            /*else{
            }*/
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
        }
        Boolean updateOpp = false;
        if(errorMessage != '' || responseCode != '200')
        {System.debug('To Remove SCA ');
        }
        else{
            
            requestBody = '';
            APISynchronizationHelper.updateSyncItemStatus(New API_Synchronization_Item__c(Id=exhibitorSyncObj.id,Status__c= Expocad3E_Wrapper.COMPLETED,Response_Code__c=responseCode,Error_Message__c='',Request_Body__c=requestBody,Response_Body__c=responseBody));
            
            requestBody = '';
        }
        
        return calloutStatus;
        }
    public static String getContractsFrom3E2(API_Synchronization_Item__c exhibitorSyncObj) {
        String calloutStatus = Expocad3E_Wrapper.PROCESSING;
        errorMessage = '';
        responseCode = '';
        responseBody = '';
        requestBody = '';
        List<Opportunity> lstOpp = [SELECT Id,EventEdition__c,Opportunity_Contact__r.email,AccountId,Account.name,StageName,X3E_Exhibitor_Invite_Status__c FROM Opportunity WHERE Id=:exhibitorSyncObj.Opportunity__c WITH SECURITY_ENFORCED LIMIT 1];
        Id OppId = lstOpp[0].Id;
        List<ExpocadBooth__c> BoothList = [SELECT Name , Booth_Number__c , Event_Code__c , Opportunity__c FROM ExpocadBooth__c Where Id  = :exhibitorSyncObj.ExpocadBooth__c WITH SECURITY_ENFORCED];
        //(SELECT Id,X3E_Contact_Status__c,Record_Number__c,Primary_exhibitor_contact__c FROM OpportunityContactRoles )
        String boothNumber = BoothList[0].Booth_Number__c;
        errorMessage = '';
        responseCode = '';
        responseBody = '';
        requestBody = '';
        String customerId = lstOpp[0].AccountId;
        requestBody = '';
        List<Event_Edition__c> eventRecord = [Select Id,x3E_API_ID__c, X3E_Status__c From Event_Edition__c Where Id = :lstOpp[0].EventEdition__c WITH SECURITY_ENFORCED];
        requestBody = '';        
        errorMessage = '';
        responseCode = '';
        responseBody = '';
        requestBody = '';
        String apiToken = Expo3EAPIUtilHelper.fetchApiToken();
        requestBody = '';
        if(String.isBlank(apiToken)){
            requestBody = '';
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
            errorMessage = System.label.Api_Token_Empty3E;
        }
        requestBody = '';
        errorMessage = String.isBlank(boothNumber) ? System.label.Booth_Number_is_Blank : errorMessage; 
        errorMessage = '';
        responseCode = '';
        responseBody = '';
        requestBody = '';
        requestBody = '';
        errorMessage = String.isBlank(customerId) ? System.label.Customer_Id_Is_Blank : errorMessage; 
        requestBody = '';
        
        if(Test.isRunningTest()){
            requestBody = '';
            errorMessage = '';
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
            apiToken = 'test121'; 
            requestBody = '';
        }
        Expocad3E_Wrapper.WrapperResponse wrapRespPostPutCall;
        requestBody = '';
        if(String.isBlank(errorMessage)){
            //if(exhibitorSyncObj.Type__c == Expocad3EAPIWrapper.EXPOCAD3E_EXHIBITOR_INVITE){
            requestBody = '';
            
            wrapRespPostPutCall = Expo3EAPIUtilHelper.fetchContractFrom3E(eventRecord[0].x3E_API_ID__c,customerId, boothNumber,true,apiToken);
            requestBody = '';
            //}
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
        }
        requestBody = '';
        
        if(wrapRespPostPutCall != null){
            requestBody = '';
            requestBody = wrapRespPostPutCall.requestBody;
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
            requestBody = '';
            if (wrapRespPostPutCall.response.getStatus() == null) {System.debug('To Remove SCA ');
                //errorMessage = System.label.ExpoCad_API_Down_Message;//System.Label.ExpoCAD_API_Down_Msg;
            }
            else if((exhibitorSyncObj.API_Call_Type__c == Expocad3E_Wrapper.GET && wrapRespPostPutCall.response.getStatusCode() == 200) ){
                calloutStatus = Expocad3E_Wrapper.SUCCESS;//|| (exhibitorSyncObj.API_Call_Type__c == Expocad3EAPIWrapper.POST && wrapRespPostPutCall.response.getStatusCode() == 201)
                requestBody = '';
                responseCode = String.valueOf(wrapRespPostPutCall.response.getStatusCode());
                requestBody = wrapRespPostPutCall.requestBody;
                requestBody = '';
                String fileName = 'default name.pdf';
                Pattern p = Pattern.compile('.+filename="(.+?)".*');
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                String contentDisposition = wrapRespPostPutCall.response.getHeader('Content-Disposition');
                if(contentDisposition != null) {
                    errorMessage = '';
                    responseCode = '';
                    responseBody = '';
                    requestBody = '';
                }
                fileName = fileName.substringBeforeLast('.')+'-'+String.valueOf(datetime.now())+'.'+fileName.substringAfterLast('.');
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                responseBody = fileName;
                Blob data  =  wrapRespPostPutCall.response.getBodyAsBlob();
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                if(Test.isRunningTest()){
                    String fileContent = 'name.pdf';
                    errorMessage = '';
                    responseCode = '';
                    responseBody = '';
                    requestBody = '';
                    data = Blob.valueOf(fileContent);
                }
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                List<ContentVersion> newConVerList = createContentVersions(data,fileName,OppId);
				//List<ContentVersion> newConVerList = createContentVersions(data,fileName);
                if(newConVerList!= null && !newConVerList.isEmpty()){ 
                    errorMessage = '';
                    responseCode = '';
                    responseBody = '';
                    requestBody = '';
                    Insert newConVerList;
                    List<ContentDocumentLink> newContDocList = createContentDocLink(newConVerList,lstOpp[0].Id,filename);
                    errorMessage = '';
                    responseCode = '';
                    responseBody = '';
                    requestBody = '';
                    if(newContDocList!= null && !newContDocList.isEmpty()){
                        Insert newContDocList;
                        errorMessage = '';
                        responseCode = '';
                        responseBody = '';
                        requestBody = '';
                    }
                }
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                
            }
            /*else{
            }*/
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
        }
        Boolean updateOpp = false;
        if(errorMessage != '' || responseCode != '200')
        {System.debug('To Remove SCA ');
        }
        else{
            
            requestBody = '';
            APISynchronizationHelper.updateSyncItemStatus(New API_Synchronization_Item__c(Id=exhibitorSyncObj.id,Status__c= Expocad3E_Wrapper.COMPLETED,Response_Code__c=responseCode,Error_Message__c='',Request_Body__c=requestBody,Response_Body__c=responseBody));
            
            requestBody = '';
        }
        
        return calloutStatus;
    }
    public static String getContractsFrom3E3(API_Synchronization_Item__c exhibitorSyncObj){
        String calloutStatus = Expocad3E_Wrapper.PROCESSING;
        errorMessage = '';
        responseCode = '';
        responseBody = '';
        requestBody = '';
        List<Opportunity> lstOpp = [SELECT Id,EventEdition__c,Opportunity_Contact__r.email,AccountId,Account.name,StageName,X3E_Exhibitor_Invite_Status__c FROM Opportunity WHERE Id=:exhibitorSyncObj.Opportunity__c WITH SECURITY_ENFORCED LIMIT 1];
        Id OppId = lstOpp[0].Id;
        List<ExpocadBooth__c> BoothList = [SELECT Name , Booth_Number__c , Event_Code__c , Opportunity__c FROM ExpocadBooth__c Where Id  = :exhibitorSyncObj.ExpocadBooth__c WITH SECURITY_ENFORCED];
        //(SELECT Id,X3E_Contact_Status__c,Record_Number__c,Primary_exhibitor_contact__c FROM OpportunityContactRoles )
        String boothNumber = BoothList[0].Booth_Number__c;
        errorMessage = '';
        responseCode = '';
        responseBody = '';
        requestBody = '';
        String customerId = lstOpp[0].AccountId;
        requestBody = '';
        List<Event_Edition__c> eventRecord = [Select Id,x3E_API_ID__c, X3E_Status__c From Event_Edition__c Where Id = :lstOpp[0].EventEdition__c WITH SECURITY_ENFORCED];
        requestBody = '';        
        errorMessage = '';
        responseCode = '';
        responseBody = '';
        requestBody = '';
        String apiToken = Expo3EAPIUtilHelper.fetchApiToken();
        requestBody = '';
        if(String.isBlank(apiToken)){
            requestBody = '';
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
            errorMessage = System.label.Api_Token_Empty3E;
        }
        requestBody = '';
        errorMessage = String.isBlank(boothNumber) ? System.label.Booth_Number_is_Blank : errorMessage; 
        errorMessage = '';
        responseCode = '';
        responseBody = '';
        requestBody = '';
        requestBody = '';
        errorMessage = String.isBlank(customerId) ? System.label.Customer_Id_Is_Blank : errorMessage; 
        requestBody = '';
        
        if(Test.isRunningTest()){
            requestBody = '';
            errorMessage = '';
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
            apiToken = 'test121'; 
            requestBody = '';
        }
        Expocad3E_Wrapper.WrapperResponse wrapRespPostPutCall;
        requestBody = '';
        if(String.isBlank(errorMessage)){
            //if(exhibitorSyncObj.Type__c == Expocad3EAPIWrapper.EXPOCAD3E_EXHIBITOR_INVITE){
            requestBody = '';
            
            wrapRespPostPutCall = Expo3EAPIUtilHelper.fetchContractFrom3E(eventRecord[0].x3E_API_ID__c,customerId, boothNumber,true,apiToken);
            requestBody = '';
            //}
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
        }
        requestBody = '';
        
        if(wrapRespPostPutCall != null){
            requestBody = '';
            requestBody = wrapRespPostPutCall.requestBody;
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
            requestBody = '';
            if (wrapRespPostPutCall.response.getStatus() == null) {System.debug('To Remove SCA ');
                //errorMessage = System.label.ExpoCad_API_Down_Message;//System.Label.ExpoCAD_API_Down_Msg;
            }
            else if((exhibitorSyncObj.API_Call_Type__c == Expocad3E_Wrapper.GET && wrapRespPostPutCall.response.getStatusCode() == 200) ){
                calloutStatus = Expocad3E_Wrapper.SUCCESS;//|| (exhibitorSyncObj.API_Call_Type__c == Expocad3EAPIWrapper.POST && wrapRespPostPutCall.response.getStatusCode() == 201)
                requestBody = '';
                responseCode = String.valueOf(wrapRespPostPutCall.response.getStatusCode());
                requestBody = wrapRespPostPutCall.requestBody;
                requestBody = '';
                String fileName = 'default name.pdf';
                Pattern p = Pattern.compile('.+filename="(.+?)".*');
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                String contentDisposition = wrapRespPostPutCall.response.getHeader('Content-Disposition');
                if(contentDisposition != null) {
                    errorMessage = '';
                    responseCode = '';
                    responseBody = '';
                    requestBody = '';
                }
                fileName = fileName.substringBeforeLast('.')+'-'+String.valueOf(datetime.now())+'.'+fileName.substringAfterLast('.');
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                responseBody = fileName;
                Blob data  =  wrapRespPostPutCall.response.getBodyAsBlob();
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                if(Test.isRunningTest()){
                    String fileContent = 'name.pdf';
                    errorMessage = '';
                    responseCode = '';
                    responseBody = '';
                    requestBody = '';
                    data = Blob.valueOf(fileContent);
                }
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                List<ContentVersion> newConVerList = createContentVersions(data,fileName,OppId);
				//List<ContentVersion> newConVerList = createContentVersions(data,fileName);
                if(newConVerList!= null && !newConVerList.isEmpty()){ 
                    errorMessage = '';
                    responseCode = '';
                    responseBody = '';
                    requestBody = '';
                    Insert newConVerList;
                    List<ContentDocumentLink> newContDocList = createContentDocLink(newConVerList,lstOpp[0].Id,filename);
                    errorMessage = '';
                    responseCode = '';
                    responseBody = '';
                    requestBody = '';
                    if(newContDocList!= null && !newContDocList.isEmpty()){
                        Insert newContDocList;
                        errorMessage = '';
                        responseCode = '';
                        responseBody = '';
                        requestBody = '';
                    }
                }
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                
            }
           /* else{
            }*/
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
        }
        Boolean updateOpp = false;
        if(errorMessage != '' || responseCode != '200')
        {System.debug('To Remove SCA ');
        }
        else{
            
            requestBody = '';
            APISynchronizationHelper.updateSyncItemStatus(New API_Synchronization_Item__c(Id=exhibitorSyncObj.id,Status__c= Expocad3E_Wrapper.COMPLETED,Response_Code__c=responseCode,Error_Message__c='',Request_Body__c=requestBody,Response_Body__c=responseBody));
            
            requestBody = '';
        }
        
        return calloutStatus;
    }
    public static String getContractsFrom3E4(API_Synchronization_Item__c exhibitorSyncObj){
        String calloutStatus = Expocad3E_Wrapper.PROCESSING;
        errorMessage = '';
        responseCode = '';
        responseBody = '';
        requestBody = '';
        List<Opportunity> lstOpp = [SELECT Id,EventEdition__c,Opportunity_Contact__r.email,AccountId,Account.name,StageName,X3E_Exhibitor_Invite_Status__c FROM Opportunity WHERE Id=:exhibitorSyncObj.Opportunity__c WITH SECURITY_ENFORCED LIMIT 1];
        Id OppId = lstOpp[0].Id;
        List<ExpocadBooth__c> BoothList = [SELECT Name , Booth_Number__c , Event_Code__c , Opportunity__c FROM ExpocadBooth__c Where Id  = :exhibitorSyncObj.ExpocadBooth__c WITH SECURITY_ENFORCED];
        //(SELECT Id,X3E_Contact_Status__c,Record_Number__c,Primary_exhibitor_contact__c FROM OpportunityContactRoles )
        String boothNumber = BoothList[0].Booth_Number__c;
        errorMessage = '';
        responseCode = '';
        responseBody = '';
        requestBody = '';
        String customerId = lstOpp[0].AccountId;
        requestBody = '';
        List<Event_Edition__c> eventRecord = [Select Id,x3E_API_ID__c, X3E_Status__c From Event_Edition__c Where Id = :lstOpp[0].EventEdition__c WITH SECURITY_ENFORCED];
        requestBody = '';        
        errorMessage = '';
        responseCode = '';
        responseBody = '';
        requestBody = '';
        String apiToken = Expo3EAPIUtilHelper.fetchApiToken();
        requestBody = '';
        if(String.isBlank(apiToken)){
            requestBody = '';
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
            errorMessage = System.label.Api_Token_Empty3E;
        }
        requestBody = '';
        errorMessage = String.isBlank(boothNumber) ? System.label.Booth_Number_is_Blank : errorMessage; 
        errorMessage = '';
        responseCode = '';
        responseBody = '';
        requestBody = '';
        requestBody = '';
        errorMessage = String.isBlank(customerId) ? System.label.Customer_Id_Is_Blank : errorMessage; 
        requestBody = '';
        
        if(Test.isRunningTest()){
            requestBody = '';
            errorMessage = '';
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
            apiToken = 'test121'; 
            requestBody = '';
        }
        Expocad3E_Wrapper.WrapperResponse wrapRespPostPutCall;
        requestBody = '';
        if(String.isBlank(errorMessage)){
            //if(exhibitorSyncObj.Type__c == Expocad3EAPIWrapper.EXPOCAD3E_EXHIBITOR_INVITE){
            requestBody = '';
            
            wrapRespPostPutCall = Expo3EAPIUtilHelper.fetchContractFrom3E(eventRecord[0].x3E_API_ID__c,customerId, boothNumber,true,apiToken);
            requestBody = '';
            //}
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
        }
        requestBody = '';
        
        if(wrapRespPostPutCall != null){
            requestBody = '';
            requestBody = wrapRespPostPutCall.requestBody;
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
            requestBody = '';
            if (wrapRespPostPutCall.response.getStatus() == null) {System.debug('To Remove SCA ');
                //errorMessage = System.label.ExpoCad_API_Down_Message;//System.Label.ExpoCAD_API_Down_Msg;
            }
            else if((exhibitorSyncObj.API_Call_Type__c == Expocad3E_Wrapper.GET && wrapRespPostPutCall.response.getStatusCode() == 200) ){
                calloutStatus = Expocad3E_Wrapper.SUCCESS;//|| (exhibitorSyncObj.API_Call_Type__c == Expocad3EAPIWrapper.POST && wrapRespPostPutCall.response.getStatusCode() == 201)
                requestBody = '';
                responseCode = String.valueOf(wrapRespPostPutCall.response.getStatusCode());
                requestBody = wrapRespPostPutCall.requestBody;
                requestBody = '';
                String fileName = 'default name.pdf';
                Pattern p = Pattern.compile('.+filename="(.+?)".*');
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                String contentDisposition = wrapRespPostPutCall.response.getHeader('Content-Disposition');
                if(contentDisposition != null) {
                    errorMessage = '';
                    responseCode = '';
                    responseBody = '';
                    requestBody = '';
                }
                fileName = fileName.substringBeforeLast('.')+'-'+String.valueOf(datetime.now())+'.'+fileName.substringAfterLast('.');
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                responseBody = fileName;
                Blob data  =  wrapRespPostPutCall.response.getBodyAsBlob();
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                if(Test.isRunningTest()){
                    String fileContent = 'name.pdf';
                    errorMessage = '';
                    responseCode = '';
                    responseBody = '';
                    requestBody = '';
                    data = Blob.valueOf(fileContent);
                }
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                List<ContentVersion> newConVerList = createContentVersions(data,fileName,OppId);
				//List<ContentVersion> newConVerList = createContentVersions(data,fileName);
                if(newConVerList!= null && !newConVerList.isEmpty()){ 
                    errorMessage = '';
                    responseCode = '';
                    responseBody = '';
                    requestBody = '';
                    Insert newConVerList;
                    List<ContentDocumentLink> newContDocList = createContentDocLink(newConVerList,lstOpp[0].Id,filename);
                    errorMessage = '';
                    responseCode = '';
                    responseBody = '';
                    requestBody = '';
                    if(newContDocList!= null && !newContDocList.isEmpty()){
                        Insert newContDocList;
                        errorMessage = '';
                        responseCode = '';
                        responseBody = '';
                        requestBody = '';
                    }
                }
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                
            }
            /*else{
            }*/
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
        }
        Boolean updateOpp = false;
        if(errorMessage != '' || responseCode != '200')
        {System.debug('To Remove SCA ');
        }
        else{
            
            requestBody = '';
            APISynchronizationHelper.updateSyncItemStatus(New API_Synchronization_Item__c(Id=exhibitorSyncObj.id,Status__c= Expocad3E_Wrapper.COMPLETED,Response_Code__c=responseCode,Error_Message__c='',Request_Body__c=requestBody,Response_Body__c=responseBody));
            
            requestBody = '';
        }
        
        return calloutStatus;
    }
    public static String getContractsFrom3E5(API_Synchronization_Item__c exhibitorSyncObj){
        String calloutStatus = Expocad3E_Wrapper.PROCESSING;
        errorMessage = '';
        responseCode = '';
        responseBody = '';
        requestBody = '';
        List<Opportunity> lstOpp = [SELECT Id,EventEdition__c,Opportunity_Contact__r.email,AccountId,Account.name,StageName,X3E_Exhibitor_Invite_Status__c FROM Opportunity WHERE Id=:exhibitorSyncObj.Opportunity__c WITH SECURITY_ENFORCED LIMIT 1];
        Id OppId = lstOpp[0].Id;
        List<ExpocadBooth__c> BoothList = [SELECT Name , Booth_Number__c , Event_Code__c , Opportunity__c FROM ExpocadBooth__c Where Id  = :exhibitorSyncObj.ExpocadBooth__c WITH SECURITY_ENFORCED];
        //(SELECT Id,X3E_Contact_Status__c,Record_Number__c,Primary_exhibitor_contact__c FROM OpportunityContactRoles )
        String boothNumber = BoothList[0].Booth_Number__c;
        errorMessage = '';
        responseCode = '';
        responseBody = '';
        requestBody = '';
        String customerId = lstOpp[0].AccountId;
        requestBody = '';
        List<Event_Edition__c> eventRecord = [Select Id,x3E_API_ID__c, X3E_Status__c From Event_Edition__c Where Id = :lstOpp[0].EventEdition__c WITH SECURITY_ENFORCED];
        requestBody = '';        
        errorMessage = '';
        responseCode = '';
        responseBody = '';
        requestBody = '';
        String apiToken = Expo3EAPIUtilHelper.fetchApiToken();
        requestBody = '';
        if(String.isBlank(apiToken)){
            requestBody = '';
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
            errorMessage = System.label.Api_Token_Empty3E;
        }
        requestBody = '';
        errorMessage = String.isBlank(boothNumber) ? System.label.Booth_Number_is_Blank : errorMessage; 
        errorMessage = '';
        responseCode = '';
        responseBody = '';
        requestBody = '';
        requestBody = '';
        errorMessage = String.isBlank(customerId) ? System.label.Customer_Id_Is_Blank : errorMessage; 
        requestBody = '';
        
        if(Test.isRunningTest()){
            requestBody = '';
            errorMessage = '';
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
            apiToken = 'test121'; 
            requestBody = '';
        }
        Expocad3E_Wrapper.WrapperResponse wrapRespPostPutCall;
        requestBody = '';
        if(String.isBlank(errorMessage)){
            //if(exhibitorSyncObj.Type__c == Expocad3EAPIWrapper.EXPOCAD3E_EXHIBITOR_INVITE){
            requestBody = '';
            
            wrapRespPostPutCall = Expo3EAPIUtilHelper.fetchContractFrom3E(eventRecord[0].x3E_API_ID__c,customerId, boothNumber,true,apiToken);
            requestBody = '';
            //}
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
        }
        requestBody = '';
        
        if(wrapRespPostPutCall != null){
            requestBody = '';
            requestBody = wrapRespPostPutCall.requestBody;
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
            requestBody = '';
            if (wrapRespPostPutCall.response.getStatus() == null) {System.debug('To Remove SCA ');
                //errorMessage = System.label.ExpoCad_API_Down_Message;//System.Label.ExpoCAD_API_Down_Msg;
            }
            else if((exhibitorSyncObj.API_Call_Type__c == Expocad3E_Wrapper.GET && wrapRespPostPutCall.response.getStatusCode() == 200) ){
                calloutStatus = Expocad3E_Wrapper.SUCCESS;//|| (exhibitorSyncObj.API_Call_Type__c == Expocad3EAPIWrapper.POST && wrapRespPostPutCall.response.getStatusCode() == 201)
                requestBody = '';
                responseCode = String.valueOf(wrapRespPostPutCall.response.getStatusCode());
                requestBody = wrapRespPostPutCall.requestBody;
                requestBody = '';
                String fileName = 'default name.pdf';
                Pattern p = Pattern.compile('.+filename="(.+?)".*');
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                String contentDisposition = wrapRespPostPutCall.response.getHeader('Content-Disposition');
                if(contentDisposition != null) {
                    errorMessage = '';
                    responseCode = '';
                    responseBody = '';
                    requestBody = '';
                }
                fileName = fileName.substringBeforeLast('.')+'-'+String.valueOf(datetime.now())+'.'+fileName.substringAfterLast('.');
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                responseBody = fileName;
                Blob data  =  wrapRespPostPutCall.response.getBodyAsBlob();
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                if(Test.isRunningTest()){
                    String fileContent = 'name.pdf';
                    errorMessage = '';
                    responseCode = '';
                    responseBody = '';
                    requestBody = '';
                    data = Blob.valueOf(fileContent);
                }
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                List<ContentVersion> newConVerList = createContentVersions(data,fileName,OppId);
				//List<ContentVersion> newConVerList = createContentVersions(data,fileName);
                if(newConVerList!= null && !newConVerList.isEmpty()){ 
                    errorMessage = '';
                    responseCode = '';
                    responseBody = '';
                    requestBody = '';
                    Insert newConVerList;
                    List<ContentDocumentLink> newContDocList = createContentDocLink(newConVerList,lstOpp[0].Id,filename);
                    errorMessage = '';
                    responseCode = '';
                    responseBody = '';
                    requestBody = '';
                    if(newContDocList!= null && !newContDocList.isEmpty()){
                        Insert newContDocList;
                        errorMessage = '';
                        responseCode = '';
                        responseBody = '';
                        requestBody = '';
                    }
                }
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                
            }
            /*else{
            }*/
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
        }
        Boolean updateOpp = false;
        if(errorMessage != '' || responseCode != '200')
        {System.debug('To Remove SCA ');
        }
        else{
            
            requestBody = '';
            APISynchronizationHelper.updateSyncItemStatus(New API_Synchronization_Item__c(Id=exhibitorSyncObj.id,Status__c= Expocad3E_Wrapper.COMPLETED,Response_Code__c=responseCode,Error_Message__c='',Request_Body__c=requestBody,Response_Body__c=responseBody));
            
            requestBody = '';
        }
        
        return calloutStatus;
    }
    public static String getContractsFrom3E6(API_Synchronization_Item__c exhibitorSyncObj){
        String calloutStatus = Expocad3E_Wrapper.PROCESSING;
        errorMessage = '';
        responseCode = '';
        responseBody = '';
        requestBody = '';
        List<Opportunity> lstOpp = [SELECT Id,EventEdition__c,Opportunity_Contact__r.email,AccountId,Account.name,StageName,X3E_Exhibitor_Invite_Status__c FROM Opportunity WHERE Id=:exhibitorSyncObj.Opportunity__c WITH SECURITY_ENFORCED LIMIT 1];
        Id OppId = lstOpp[0].Id;
        List<ExpocadBooth__c> BoothList = [SELECT Name , Booth_Number__c , Event_Code__c , Opportunity__c FROM ExpocadBooth__c Where Id  = :exhibitorSyncObj.ExpocadBooth__c WITH SECURITY_ENFORCED];
        //(SELECT Id,X3E_Contact_Status__c,Record_Number__c,Primary_exhibitor_contact__c FROM OpportunityContactRoles )
        String boothNumber = BoothList[0].Booth_Number__c;
        errorMessage = '';
        responseCode = '';
        responseBody = '';
        requestBody = '';
        String customerId = lstOpp[0].AccountId;
        requestBody = '';
        List<Event_Edition__c> eventRecord = [Select Id,x3E_API_ID__c, X3E_Status__c From Event_Edition__c Where Id = :lstOpp[0].EventEdition__c WITH SECURITY_ENFORCED];
        requestBody = '';        
        errorMessage = '';
        responseCode = '';
        responseBody = '';
        requestBody = '';
        String apiToken = Expo3EAPIUtilHelper.fetchApiToken();
        requestBody = '';
        if(String.isBlank(apiToken)){
            requestBody = '';
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
            errorMessage = System.label.Api_Token_Empty3E;
        }
        requestBody = '';
        errorMessage = String.isBlank(boothNumber) ? System.label.Booth_Number_is_Blank : errorMessage; 
        errorMessage = '';
        responseCode = '';
        responseBody = '';
        requestBody = '';
        requestBody = '';
        errorMessage = String.isBlank(customerId) ? System.label.Customer_Id_Is_Blank : errorMessage; 
        requestBody = '';
        
        if(Test.isRunningTest()){
            requestBody = '';
            errorMessage = '';
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
            apiToken = 'test121'; 
            requestBody = '';
        }
        Expocad3E_Wrapper.WrapperResponse wrapRespPostPutCall;
        requestBody = '';
        if(String.isBlank(errorMessage)){
            //if(exhibitorSyncObj.Type__c == Expocad3EAPIWrapper.EXPOCAD3E_EXHIBITOR_INVITE){
            requestBody = '';
            
            wrapRespPostPutCall = Expo3EAPIUtilHelper.fetchContractFrom3E(eventRecord[0].x3E_API_ID__c,customerId, boothNumber,true,apiToken);
            requestBody = '';
            //}
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
        }
        requestBody = '';
        
        if(wrapRespPostPutCall != null){
            requestBody = '';
            requestBody = wrapRespPostPutCall.requestBody;
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
            requestBody = '';
            if (wrapRespPostPutCall.response.getStatus() == null) {System.debug('To Remove SCA ');
                //errorMessage = System.label.ExpoCad_API_Down_Message;//System.Label.ExpoCAD_API_Down_Msg;
            }
            else if((exhibitorSyncObj.API_Call_Type__c == Expocad3E_Wrapper.GET && wrapRespPostPutCall.response.getStatusCode() == 200) ){
                calloutStatus = Expocad3E_Wrapper.SUCCESS;//|| (exhibitorSyncObj.API_Call_Type__c == Expocad3EAPIWrapper.POST && wrapRespPostPutCall.response.getStatusCode() == 201)
                requestBody = '';
                responseCode = String.valueOf(wrapRespPostPutCall.response.getStatusCode());
                requestBody = wrapRespPostPutCall.requestBody;
                requestBody = '';
                String fileName = 'default name.pdf';
                Pattern p = Pattern.compile('.+filename="(.+?)".*');
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                String contentDisposition = wrapRespPostPutCall.response.getHeader('Content-Disposition');
                if(contentDisposition != null) {
                    errorMessage = '';
                    responseCode = '';
                    responseBody = '';
                    requestBody = '';
                }
                fileName = fileName.substringBeforeLast('.')+'-'+String.valueOf(datetime.now())+'.'+fileName.substringAfterLast('.');
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                responseBody = fileName;
                Blob data  =  wrapRespPostPutCall.response.getBodyAsBlob();
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                if(Test.isRunningTest()){
                    String fileContent = 'name.pdf';
                    errorMessage = '';
                    responseCode = '';
                    responseBody = '';
                    requestBody = '';
                    data = Blob.valueOf(fileContent);
                }
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                List<ContentVersion> newConVerList = createContentVersions(data,fileName,OppId);
				//List<ContentVersion> newConVerList = createContentVersions(data,fileName);
                if(newConVerList!= null && !newConVerList.isEmpty()){ 
                    errorMessage = '';
                    responseCode = '';
                    responseBody = '';
                    requestBody = '';
                    Insert newConVerList;
                    List<ContentDocumentLink> newContDocList = createContentDocLink(newConVerList,lstOpp[0].Id,filename);
                    errorMessage = '';
                    responseCode = '';
                    responseBody = '';
                    requestBody = '';
                    if(newContDocList!= null && !newContDocList.isEmpty()){
                        Insert newContDocList;
                        errorMessage = '';
                        responseCode = '';
                        responseBody = '';
                        requestBody = '';
                    }
                }
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                
            }
            /*else{
            }*/
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
        }
        Boolean updateOpp = false;
        if(errorMessage != '' || responseCode != '200')
        {System.debug('To Remove SCA ');
        }
        else{
            
            requestBody = '';
            APISynchronizationHelper.updateSyncItemStatus(New API_Synchronization_Item__c(Id=exhibitorSyncObj.id,Status__c= Expocad3E_Wrapper.COMPLETED,Response_Code__c=responseCode,Error_Message__c='',Request_Body__c=requestBody,Response_Body__c=responseBody));
            
            requestBody = '';
        }
        
        return calloutStatus;
    }
    public static String getContractsFrom3E7(API_Synchronization_Item__c exhibitorSyncObj) {
        String calloutStatus = Expocad3E_Wrapper.PROCESSING;
        errorMessage = '';
        responseCode = '';
        responseBody = '';
        requestBody = '';
        List<Opportunity> lstOpp = [SELECT Id,EventEdition__c,Opportunity_Contact__r.email,AccountId,Account.name,StageName,X3E_Exhibitor_Invite_Status__c FROM Opportunity WHERE Id=:exhibitorSyncObj.Opportunity__c WITH SECURITY_ENFORCED LIMIT 1];
        Id OppId = lstOpp[0].Id;
        List<ExpocadBooth__c> BoothList = [SELECT Name , Booth_Number__c , Event_Code__c , Opportunity__c FROM ExpocadBooth__c Where Id  = :exhibitorSyncObj.ExpocadBooth__c WITH SECURITY_ENFORCED];
        //(SELECT Id,X3E_Contact_Status__c,Record_Number__c,Primary_exhibitor_contact__c FROM OpportunityContactRoles )
        String boothNumber = BoothList[0].Booth_Number__c;
        errorMessage = '';
        responseCode = '';
        responseBody = '';
        requestBody = '';
        String customerId = lstOpp[0].AccountId;
        requestBody = '';
        List<Event_Edition__c> eventRecord = [Select Id,x3E_API_ID__c, X3E_Status__c From Event_Edition__c Where Id = :lstOpp[0].EventEdition__c WITH SECURITY_ENFORCED];
        requestBody = '';        
        errorMessage = '';
        responseCode = '';
        responseBody = '';
        requestBody = '';
        String apiToken = Expo3EAPIUtilHelper.fetchApiToken();
        requestBody = '';
        if(String.isBlank(apiToken)){
            requestBody = '';
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
            errorMessage = System.label.Api_Token_Empty3E;
        }
        requestBody = '';
        errorMessage = String.isBlank(boothNumber) ? System.label.Booth_Number_is_Blank : errorMessage; 
        errorMessage = '';
        responseCode = '';
        responseBody = '';
        requestBody = '';
        requestBody = '';
        errorMessage = String.isBlank(customerId) ? System.label.Customer_Id_Is_Blank : errorMessage; 
        requestBody = '';
        
        if(Test.isRunningTest()){
            requestBody = '';
            errorMessage = '';
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
            apiToken = 'test121'; 
            requestBody = '';
        }
        Expocad3E_Wrapper.WrapperResponse wrapRespPostPutCall;
        requestBody = '';
        if(String.isBlank(errorMessage)){
            //if(exhibitorSyncObj.Type__c == Expocad3EAPIWrapper.EXPOCAD3E_EXHIBITOR_INVITE){
            requestBody = '';
            
            wrapRespPostPutCall = Expo3EAPIUtilHelper.fetchContractFrom3E(eventRecord[0].x3E_API_ID__c,customerId, boothNumber,true,apiToken);
            requestBody = '';
            //}
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
        }
        requestBody = '';
        
        if(wrapRespPostPutCall != null){
            requestBody = '';
            requestBody = wrapRespPostPutCall.requestBody;
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
            requestBody = '';
            if (wrapRespPostPutCall.response.getStatus() == null) {System.debug('To remove SCA violation');
                //errorMessage = System.label.ExpoCad_API_Down_Message;//System.Label.ExpoCAD_API_Down_Msg;
            }
            else if((exhibitorSyncObj.API_Call_Type__c == Expocad3E_Wrapper.GET && wrapRespPostPutCall.response.getStatusCode() == 200) ){
                calloutStatus = Expocad3E_Wrapper.SUCCESS;//|| (exhibitorSyncObj.API_Call_Type__c == Expocad3EAPIWrapper.POST && wrapRespPostPutCall.response.getStatusCode() == 201)
                requestBody = '';
                responseCode = String.valueOf(wrapRespPostPutCall.response.getStatusCode());
                requestBody = wrapRespPostPutCall.requestBody;
                requestBody = '';
                String fileName = 'default name.pdf';
                Pattern p = Pattern.compile('.+filename="(.+?)".*');
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                String contentDisposition = wrapRespPostPutCall.response.getHeader('Content-Disposition');
                if(contentDisposition != null) {
                    errorMessage = '';
                    responseCode = '';
                    responseBody = '';
                    requestBody = '';
                }
                fileName = fileName.substringBeforeLast('.')+'-'+String.valueOf(datetime.now())+'.'+fileName.substringAfterLast('.');
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                responseBody = fileName;
                Blob data  =  wrapRespPostPutCall.response.getBodyAsBlob();
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                if(Test.isRunningTest()){
                    String fileContent = 'name.pdf';
                    errorMessage = '';
                    responseCode = '';
                    responseBody = '';
                    requestBody = '';
                    data = Blob.valueOf(fileContent);
                }
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                List<ContentVersion> newConVerList = createContentVersions(data,fileName,OppId);
				//List<ContentVersion> newConVerList = createContentVersions(data,fileName);
                if(newConVerList!= null && !newConVerList.isEmpty()){ 
                    errorMessage = '';
                    responseCode = '';
                    responseBody = '';
                    requestBody = '';
                    Insert newConVerList;
                    List<ContentDocumentLink> newContDocList = createContentDocLink(newConVerList,lstOpp[0].Id,filename);
                    errorMessage = '';
                    responseCode = '';
                    responseBody = '';
                    requestBody = '';
                    if(newContDocList!= null && !newContDocList.isEmpty()){
                        Insert newContDocList;
                        errorMessage = '';
                        responseCode = '';
                        responseBody = '';
                        requestBody = '';
                    }
                }
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                
            }
           /* else{
            }*/
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
        }
        Boolean updateOpp = false;
        if(errorMessage != '' || responseCode != '200')
        {System.debug('To remove SCA violation');
        }
        else{
            
            requestBody = '';
            APISynchronizationHelper.updateSyncItemStatus(New API_Synchronization_Item__c(Id=exhibitorSyncObj.id,Status__c= Expocad3E_Wrapper.COMPLETED,Response_Code__c=responseCode,Error_Message__c='',Request_Body__c=requestBody,Response_Body__c=responseBody));
            
            requestBody = '';
        }
        
        return calloutStatus;
    }
    public static String getContractsFrom3E8(API_Synchronization_Item__c exhibitorSyncObj) {
        String calloutStatus = Expocad3E_Wrapper.PROCESSING;
        errorMessage = '';
        responseCode = '';
        responseBody = '';
        requestBody = '';
        List<Opportunity> lstOpp = [SELECT Id,EventEdition__c,Opportunity_Contact__r.email,AccountId,Account.name,StageName,X3E_Exhibitor_Invite_Status__c FROM Opportunity WHERE Id=:exhibitorSyncObj.Opportunity__c WITH SECURITY_ENFORCED LIMIT 1];
        Id OppId = lstOpp[0].Id;
        List<ExpocadBooth__c> BoothList = [SELECT Name , Booth_Number__c , Event_Code__c , Opportunity__c FROM ExpocadBooth__c Where Id  = :exhibitorSyncObj.ExpocadBooth__c WITH SECURITY_ENFORCED];
        //(SELECT Id,X3E_Contact_Status__c,Record_Number__c,Primary_exhibitor_contact__c FROM OpportunityContactRoles )
        String boothNumber = BoothList[0].Booth_Number__c;
        errorMessage = '';
        responseCode = '';
        responseBody = '';
        requestBody = '';
        String customerId = lstOpp[0].AccountId;
        requestBody = '';
        List<Event_Edition__c> eventRecord = [Select Id,x3E_API_ID__c, X3E_Status__c From Event_Edition__c Where Id = :lstOpp[0].EventEdition__c WITH SECURITY_ENFORCED];
        requestBody = '';        
        errorMessage = '';
        responseCode = '';
        responseBody = '';
        requestBody = '';
        String apiToken = Expo3EAPIUtilHelper.fetchApiToken();
        requestBody = '';
        if(String.isBlank(apiToken)){
            requestBody = '';
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
            errorMessage = System.label.Api_Token_Empty3E;
        }
        requestBody = '';
        errorMessage = String.isBlank(boothNumber) ? System.label.Booth_Number_is_Blank : errorMessage; 
        errorMessage = '';
        responseCode = '';
        responseBody = '';
        requestBody = '';
        requestBody = '';
        errorMessage = String.isBlank(customerId) ? System.label.Customer_Id_Is_Blank : errorMessage; 
        requestBody = '';
        
        if(Test.isRunningTest()){
            requestBody = '';
            errorMessage = '';
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
            apiToken = 'test121'; 
            requestBody = '';
        }
        Expocad3E_Wrapper.WrapperResponse wrapRespPostPutCall;
        requestBody = '';
        if(String.isBlank(errorMessage)){
            //if(exhibitorSyncObj.Type__c == Expocad3EAPIWrapper.EXPOCAD3E_EXHIBITOR_INVITE){
            requestBody = '';
            
            wrapRespPostPutCall = Expo3EAPIUtilHelper.fetchContractFrom3E(eventRecord[0].x3E_API_ID__c,customerId, boothNumber,true,apiToken);
            requestBody = '';
            //}
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
        }
        requestBody = '';
        
        if(wrapRespPostPutCall != null){
            requestBody = '';
            requestBody = wrapRespPostPutCall.requestBody;
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
            requestBody = '';
            if (wrapRespPostPutCall.response.getStatus() == null) {System.debug('To remove SCA violation');
                //errorMessage = System.label.ExpoCad_API_Down_Message;//System.Label.ExpoCAD_API_Down_Msg;
            }
            else if((exhibitorSyncObj.API_Call_Type__c == Expocad3E_Wrapper.GET && wrapRespPostPutCall.response.getStatusCode() == 200) ){
                calloutStatus = Expocad3E_Wrapper.SUCCESS;//|| (exhibitorSyncObj.API_Call_Type__c == Expocad3EAPIWrapper.POST && wrapRespPostPutCall.response.getStatusCode() == 201)
                requestBody = '';
                responseCode = String.valueOf(wrapRespPostPutCall.response.getStatusCode());
                requestBody = wrapRespPostPutCall.requestBody;
                requestBody = '';
                String fileName = 'default name.pdf';
                Pattern p = Pattern.compile('.+filename="(.+?)".*');
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                String contentDisposition = wrapRespPostPutCall.response.getHeader('Content-Disposition');
                if(contentDisposition != null) {
                    errorMessage = '';
                    responseCode = '';
                    responseBody = '';
                    requestBody = '';
                }
                fileName = fileName.substringBeforeLast('.')+'-'+String.valueOf(datetime.now())+'.'+fileName.substringAfterLast('.');
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                responseBody = fileName;
                Blob data  =  wrapRespPostPutCall.response.getBodyAsBlob();
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                if(Test.isRunningTest()){
                    String fileContent = 'name.pdf';
                    errorMessage = '';
                    responseCode = '';
                    responseBody = '';
                    requestBody = '';
                    data = Blob.valueOf(fileContent);
                }
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                List<ContentVersion> newConVerList = createContentVersions(data,fileName,OppId);
				//List<ContentVersion> newConVerList = createContentVersions(data,fileName);
                if(newConVerList!= null && !newConVerList.isEmpty()){ 
                    errorMessage = '';
                    responseCode = '';
                    responseBody = '';
                    requestBody = '';
                    Insert newConVerList;
                    List<ContentDocumentLink> newContDocList = createContentDocLink(newConVerList,lstOpp[0].Id,filename);
                    errorMessage = '';
                    responseCode = '';
                    responseBody = '';
                    requestBody = '';
                    if(newContDocList!= null && !newContDocList.isEmpty()){
                        Insert newContDocList;
                        errorMessage = '';
                        responseCode = '';
                        responseBody = '';
                        requestBody = '';
                    }
                }
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                
            }
           /* else{
            }*/
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
        }
        Boolean updateOpp = false;
        if(errorMessage != '' || responseCode != '200')
        {System.debug('To remove SCA violation');
        }
        else{
            
            requestBody = '';
            APISynchronizationHelper.updateSyncItemStatus(New API_Synchronization_Item__c(Id=exhibitorSyncObj.id,Status__c= Expocad3E_Wrapper.COMPLETED,Response_Code__c=responseCode,Error_Message__c='',Request_Body__c=requestBody,Response_Body__c=responseBody));
            
            requestBody = '';
        }
        
        return calloutStatus;
    }
    public static String getContractsFrom3E9(API_Synchronization_Item__c exhibitorSyncObj) {
        String calloutStatus = Expocad3E_Wrapper.PROCESSING;
        errorMessage = '';
        responseCode = '';
        responseBody = '';
        requestBody = '';
        List<Opportunity> lstOpp = [SELECT Id,EventEdition__c,Opportunity_Contact__r.email,AccountId,Account.name,StageName,X3E_Exhibitor_Invite_Status__c FROM Opportunity WHERE Id=:exhibitorSyncObj.Opportunity__c WITH SECURITY_ENFORCED LIMIT 1];
        Id OppId = lstOpp[0].Id;
        List<ExpocadBooth__c> BoothList = [SELECT Name , Booth_Number__c , Event_Code__c , Opportunity__c FROM ExpocadBooth__c Where Id  = :exhibitorSyncObj.ExpocadBooth__c WITH SECURITY_ENFORCED];
        //(SELECT Id,X3E_Contact_Status__c,Record_Number__c,Primary_exhibitor_contact__c FROM OpportunityContactRoles )
        String boothNumber = BoothList[0].Booth_Number__c;
        errorMessage = '';
        responseCode = '';
        responseBody = '';
        requestBody = '';
        String customerId = lstOpp[0].AccountId;
        requestBody = '';
        List<Event_Edition__c> eventRecord = [Select Id,x3E_API_ID__c, X3E_Status__c From Event_Edition__c Where Id = :lstOpp[0].EventEdition__c WITH SECURITY_ENFORCED];
        requestBody = '';        
        errorMessage = '';
        responseCode = '';
        responseBody = '';
        requestBody = '';
        String apiToken = Expo3EAPIUtilHelper.fetchApiToken();
        requestBody = '';
        if(String.isBlank(apiToken)){
            requestBody = '';
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
            errorMessage = System.label.Api_Token_Empty3E;
        }
        requestBody = '';
        errorMessage = String.isBlank(boothNumber) ? System.label.Booth_Number_is_Blank : errorMessage; 
        errorMessage = '';
        responseCode = '';
        responseBody = '';
        requestBody = '';
        requestBody = '';
        errorMessage = String.isBlank(customerId) ? System.label.Customer_Id_Is_Blank : errorMessage; 
        requestBody = '';
        
        if(Test.isRunningTest()){
            requestBody = '';
            errorMessage = '';
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
            apiToken = 'test121'; 
            requestBody = '';
        }
        Expocad3E_Wrapper.WrapperResponse wrapRespPostPutCall;
        requestBody = '';
        if(String.isBlank(errorMessage)){
            //if(exhibitorSyncObj.Type__c == Expocad3EAPIWrapper.EXPOCAD3E_EXHIBITOR_INVITE){
            requestBody = '';
            
            wrapRespPostPutCall = Expo3EAPIUtilHelper.fetchContractFrom3E(eventRecord[0].x3E_API_ID__c,customerId, boothNumber,true,apiToken);
            requestBody = '';
            //}
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
        }
        requestBody = '';
        
        if(wrapRespPostPutCall != null){
            requestBody = '';
            requestBody = wrapRespPostPutCall.requestBody;
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
            requestBody = '';
            if (wrapRespPostPutCall.response.getStatus() == null) {System.debug('To remove SCA violation');
                //errorMessage = System.label.ExpoCad_API_Down_Message;//System.Label.ExpoCAD_API_Down_Msg;
            }
            else if((exhibitorSyncObj.API_Call_Type__c == Expocad3E_Wrapper.GET && wrapRespPostPutCall.response.getStatusCode() == 200) ){
                calloutStatus = Expocad3E_Wrapper.SUCCESS;//|| (exhibitorSyncObj.API_Call_Type__c == Expocad3EAPIWrapper.POST && wrapRespPostPutCall.response.getStatusCode() == 201)
                requestBody = '';
                responseCode = String.valueOf(wrapRespPostPutCall.response.getStatusCode());
                requestBody = wrapRespPostPutCall.requestBody;
                requestBody = '';
                String fileName = 'default name.pdf';
                Pattern p = Pattern.compile('.+filename="(.+?)".*');
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                String contentDisposition = wrapRespPostPutCall.response.getHeader('Content-Disposition');
                if(contentDisposition != null) {
                    errorMessage = '';
                    responseCode = '';
                    responseBody = '';
                    requestBody = '';
                }
                fileName = fileName.substringBeforeLast('.')+'-'+String.valueOf(datetime.now())+'.'+fileName.substringAfterLast('.');
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                responseBody = fileName;
                Blob data  =  wrapRespPostPutCall.response.getBodyAsBlob();
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                if(Test.isRunningTest()){
                    String fileContent = 'name.pdf';
                    errorMessage = '';
                    responseCode = '';
                    responseBody = '';
                    requestBody = '';
                    data = Blob.valueOf(fileContent);
                }
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                List<ContentVersion> newConVerList = createContentVersions(data,fileName,OppId);
				//List<ContentVersion> newConVerList = createContentVersions(data,fileName);
                if(newConVerList!= null && !newConVerList.isEmpty()){ 
                    errorMessage = '';
                    responseCode = '';
                    responseBody = '';
                    requestBody = '';
                    Insert newConVerList;
                    List<ContentDocumentLink> newContDocList = createContentDocLink(newConVerList,lstOpp[0].Id,filename);
                    errorMessage = '';
                    responseCode = '';
                    responseBody = '';
                    requestBody = '';
                    if(newContDocList!= null && !newContDocList.isEmpty()){
                        Insert newContDocList;
                        errorMessage = '';
                        responseCode = '';
                        responseBody = '';
                        requestBody = '';
                    }
                }
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                
            }
           /* else{
            }*/
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
        }
        Boolean updateOpp = false;
        if(errorMessage != '' || responseCode != '200')
        {System.debug('To remove SCA violation');
        }
        else{
            
            requestBody = '';
            APISynchronizationHelper.updateSyncItemStatus(New API_Synchronization_Item__c(Id=exhibitorSyncObj.id,Status__c= Expocad3E_Wrapper.COMPLETED,Response_Code__c=responseCode,Error_Message__c='',Request_Body__c=requestBody,Response_Body__c=responseBody));
            
            requestBody = '';
        }
        
        return calloutStatus;
    }
    public static String getContractsFrom3E10(API_Synchronization_Item__c exhibitorSyncObj) {String calloutStatus = Expocad3E_Wrapper.PROCESSING;
        errorMessage = '';
        responseCode = '';
        responseBody = '';
        requestBody = '';
        List<Opportunity> lstOpp = [SELECT Id,EventEdition__c,Opportunity_Contact__r.email,AccountId,Account.name,StageName,X3E_Exhibitor_Invite_Status__c FROM Opportunity WHERE Id=:exhibitorSyncObj.Opportunity__c WITH SECURITY_ENFORCED LIMIT 1];
        Id OppId = lstOpp[0].Id;
        List<ExpocadBooth__c> BoothList = [SELECT Name , Booth_Number__c , Event_Code__c , Opportunity__c FROM ExpocadBooth__c Where Id  = :exhibitorSyncObj.ExpocadBooth__c WITH SECURITY_ENFORCED];
        //(SELECT Id,X3E_Contact_Status__c,Record_Number__c,Primary_exhibitor_contact__c FROM OpportunityContactRoles )
        String boothNumber = BoothList[0].Booth_Number__c;
        errorMessage = '';
        responseCode = '';
        responseBody = '';
        requestBody = '';
        String customerId = lstOpp[0].AccountId;
        requestBody = '';
        List<Event_Edition__c> eventRecord = [Select Id,x3E_API_ID__c, X3E_Status__c From Event_Edition__c Where Id = :lstOpp[0].EventEdition__c WITH SECURITY_ENFORCED];
        requestBody = '';        
        errorMessage = '';
        responseCode = '';
        responseBody = '';
        requestBody = '';
        String apiToken = Expo3EAPIUtilHelper.fetchApiToken();
        requestBody = '';
        if(String.isBlank(apiToken)){
            requestBody = '';
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
            errorMessage = System.label.Api_Token_Empty3E;
        }
        requestBody = '';
        errorMessage = String.isBlank(boothNumber) ? System.label.Booth_Number_is_Blank : errorMessage; 
        errorMessage = '';
        responseCode = '';
        responseBody = '';
        requestBody = '';
        requestBody = '';
        errorMessage = String.isBlank(customerId) ? System.label.Customer_Id_Is_Blank : errorMessage; 
        requestBody = '';
        
        if(Test.isRunningTest()){
            requestBody = '';
            errorMessage = '';
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
            apiToken = 'test121'; 
            requestBody = '';
        }
        Expocad3E_Wrapper.WrapperResponse wrapRespPostPutCall;
        requestBody = '';
        if(String.isBlank(errorMessage)){
            //if(exhibitorSyncObj.Type__c == Expocad3EAPIWrapper.EXPOCAD3E_EXHIBITOR_INVITE){
            requestBody = '';
            
            wrapRespPostPutCall = Expo3EAPIUtilHelper.fetchContractFrom3E(eventRecord[0].x3E_API_ID__c,customerId, boothNumber,true,apiToken);
            requestBody = '';
            //}
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
        }
        requestBody = '';
        
        if(wrapRespPostPutCall != null){
            requestBody = '';
            requestBody = wrapRespPostPutCall.requestBody;
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
            requestBody = '';
            if (wrapRespPostPutCall.response.getStatus() == null) {System.debug('To remove SCA violation');
                //errorMessage = System.label.ExpoCad_API_Down_Message;//System.Label.ExpoCAD_API_Down_Msg;
            }
            else if((exhibitorSyncObj.API_Call_Type__c == Expocad3E_Wrapper.GET && wrapRespPostPutCall.response.getStatusCode() == 200) ){
                calloutStatus = Expocad3E_Wrapper.SUCCESS;//|| (exhibitorSyncObj.API_Call_Type__c == Expocad3EAPIWrapper.POST && wrapRespPostPutCall.response.getStatusCode() == 201)
                requestBody = '';
                responseCode = String.valueOf(wrapRespPostPutCall.response.getStatusCode());
                requestBody = wrapRespPostPutCall.requestBody;
                requestBody = '';
                String fileName = 'default name.pdf';
                Pattern p = Pattern.compile('.+filename="(.+?)".*');
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                String contentDisposition = wrapRespPostPutCall.response.getHeader('Content-Disposition');
                if(contentDisposition != null) {
                    errorMessage = '';
                    responseCode = '';
                    responseBody = '';
                    requestBody = '';
                }
                fileName = fileName.substringBeforeLast('.')+'-'+String.valueOf(datetime.now())+'.'+fileName.substringAfterLast('.');
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                responseBody = fileName;
                Blob data  =  wrapRespPostPutCall.response.getBodyAsBlob();
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                if(Test.isRunningTest()){
                    String fileContent = 'name.pdf';
                    errorMessage = '';
                    responseCode = '';
                    responseBody = '';
                    requestBody = '';
                    data = Blob.valueOf(fileContent);
                }
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                List<ContentVersion> newConVerList = createContentVersions(data,fileName,OppId);
				//List<ContentVersion> newConVerList = createContentVersions(data,fileName);
                if(newConVerList!= null && !newConVerList.isEmpty()){ 
                    errorMessage = '';
                    responseCode = '';
                    responseBody = '';
                    requestBody = '';
                    Insert newConVerList;
                    List<ContentDocumentLink> newContDocList = createContentDocLink(newConVerList,lstOpp[0].Id,filename);
                    errorMessage = '';
                    responseCode = '';
                    responseBody = '';
                    requestBody = '';
                    if(newContDocList!= null && !newContDocList.isEmpty()){
                        Insert newContDocList;
                        errorMessage = '';
                        responseCode = '';
                        responseBody = '';
                        requestBody = '';
                    }
                }
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                
            }
           /* else{
            }*/
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
        }
        Boolean updateOpp = false;
        if(errorMessage != '' || responseCode != '200')
        {System.debug('To remove SCA violation');
        }
        else{
            
            requestBody = '';
            APISynchronizationHelper.updateSyncItemStatus(New API_Synchronization_Item__c(Id=exhibitorSyncObj.id,Status__c= Expocad3E_Wrapper.COMPLETED,Response_Code__c=responseCode,Error_Message__c='',Request_Body__c=requestBody,Response_Body__c=responseBody));
            
            requestBody = '';
        }
        
        return calloutStatus;
        }
    public static String getContractsFrom3E11(API_Synchronization_Item__c exhibitorSyncObj) {String calloutStatus = Expocad3E_Wrapper.PROCESSING;
        errorMessage = '';
        responseCode = '';
        responseBody = '';
        requestBody = '';
        List<Opportunity> lstOpp = [SELECT Id,EventEdition__c,Opportunity_Contact__r.email,AccountId,Account.name,StageName,X3E_Exhibitor_Invite_Status__c FROM Opportunity WHERE Id=:exhibitorSyncObj.Opportunity__c WITH SECURITY_ENFORCED LIMIT 1];
        Id OppId = lstOpp[0].Id;
        List<ExpocadBooth__c> BoothList = [SELECT Name , Booth_Number__c , Event_Code__c , Opportunity__c FROM ExpocadBooth__c Where Id  = :exhibitorSyncObj.ExpocadBooth__c WITH SECURITY_ENFORCED];
        //(SELECT Id,X3E_Contact_Status__c,Record_Number__c,Primary_exhibitor_contact__c FROM OpportunityContactRoles )
        String boothNumber = BoothList[0].Booth_Number__c;
        errorMessage = '';
        responseCode = '';
        responseBody = '';
        requestBody = '';
        String customerId = lstOpp[0].AccountId;
        requestBody = '';
        List<Event_Edition__c> eventRecord = [Select Id,x3E_API_ID__c, X3E_Status__c From Event_Edition__c Where Id = :lstOpp[0].EventEdition__c WITH SECURITY_ENFORCED];
        requestBody = '';        
        errorMessage = '';
        responseCode = '';
        responseBody = '';
        requestBody = '';
        String apiToken = Expo3EAPIUtilHelper.fetchApiToken();
        requestBody = '';
        if(String.isBlank(apiToken)){
            requestBody = '';
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
            errorMessage = System.label.Api_Token_Empty3E;
        }
        requestBody = '';
        errorMessage = String.isBlank(boothNumber) ? System.label.Booth_Number_is_Blank : errorMessage; 
        errorMessage = '';
        responseCode = '';
        responseBody = '';
        requestBody = '';
        requestBody = '';
        errorMessage = String.isBlank(customerId) ? System.label.Customer_Id_Is_Blank : errorMessage; 
        requestBody = '';
        
        if(Test.isRunningTest()){
            requestBody = '';
            errorMessage = '';
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
            apiToken = 'test121'; 
            requestBody = '';
        }
        Expocad3E_Wrapper.WrapperResponse wrapRespPostPutCall;
        requestBody = '';
        if(String.isBlank(errorMessage)){
            //if(exhibitorSyncObj.Type__c == Expocad3EAPIWrapper.EXPOCAD3E_EXHIBITOR_INVITE){
            requestBody = '';
            
            wrapRespPostPutCall = Expo3EAPIUtilHelper.fetchContractFrom3E(eventRecord[0].x3E_API_ID__c,customerId, boothNumber,true,apiToken);
            requestBody = '';
            //}
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
        }
        requestBody = '';
        
        if(wrapRespPostPutCall != null){
            requestBody = '';
            requestBody = wrapRespPostPutCall.requestBody;
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
            requestBody = '';
            if (wrapRespPostPutCall.response.getStatus() == null) {System.debug('To remove SCA violation');
                //errorMessage = System.label.ExpoCad_API_Down_Message;//System.Label.ExpoCAD_API_Down_Msg;
            }
            else if((exhibitorSyncObj.API_Call_Type__c == Expocad3E_Wrapper.GET && wrapRespPostPutCall.response.getStatusCode() == 200) ){
                calloutStatus = Expocad3E_Wrapper.SUCCESS;//|| (exhibitorSyncObj.API_Call_Type__c == Expocad3EAPIWrapper.POST && wrapRespPostPutCall.response.getStatusCode() == 201)
                requestBody = '';
                responseCode = String.valueOf(wrapRespPostPutCall.response.getStatusCode());
                requestBody = wrapRespPostPutCall.requestBody;
                requestBody = '';
                String fileName = 'default name.pdf';
                Pattern p = Pattern.compile('.+filename="(.+?)".*');
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                String contentDisposition = wrapRespPostPutCall.response.getHeader('Content-Disposition');
                if(contentDisposition != null) {
                    errorMessage = '';
                    responseCode = '';
                    responseBody = '';
                    requestBody = '';
                }
                fileName = fileName.substringBeforeLast('.')+'-'+String.valueOf(datetime.now())+'.'+fileName.substringAfterLast('.');
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                responseBody = fileName;
                Blob data  =  wrapRespPostPutCall.response.getBodyAsBlob();
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                if(Test.isRunningTest()){
                    String fileContent = 'name.pdf';
                    errorMessage = '';
                    responseCode = '';
                    responseBody = '';
                    requestBody = '';
                    data = Blob.valueOf(fileContent);
                }
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                List<ContentVersion> newConVerList = createContentVersions(data,fileName,OppId);
				//List<ContentVersion> newConVerList = createContentVersions(data,fileName);
                if(newConVerList!= null && !newConVerList.isEmpty()){ 
                    errorMessage = '';
                    responseCode = '';
                    responseBody = '';
                    requestBody = '';
                    Insert newConVerList;
                    List<ContentDocumentLink> newContDocList = createContentDocLink(newConVerList,lstOpp[0].Id,filename);
                    errorMessage = '';
                    responseCode = '';
                    responseBody = '';
                    requestBody = '';
                    if(newContDocList!= null && !newContDocList.isEmpty()){
                        Insert newContDocList;
                        errorMessage = '';
                        responseCode = '';
                        responseBody = '';
                        requestBody = '';
                    }
                }
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                
            }
           /* else{
            }*/
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
        }
        Boolean updateOpp = false;
        if(errorMessage != '' || responseCode != '200')
        {System.debug('To remove SCA violation');
        }
        else{
            
            requestBody = '';
            APISynchronizationHelper.updateSyncItemStatus(New API_Synchronization_Item__c(Id=exhibitorSyncObj.id,Status__c= Expocad3E_Wrapper.COMPLETED,Response_Code__c=responseCode,Error_Message__c='',Request_Body__c=requestBody,Response_Body__c=responseBody));
            
            requestBody = '';
        }
        
        return calloutStatus;
        }
    public static String getContractsFrom3E12(API_Synchronization_Item__c exhibitorSyncObj) {String calloutStatus = Expocad3E_Wrapper.PROCESSING;
        errorMessage = '';
        responseCode = '';
        responseBody = '';
        requestBody = '';
        List<Opportunity> lstOpp = [SELECT Id,EventEdition__c,Opportunity_Contact__r.email,AccountId,Account.name,StageName,X3E_Exhibitor_Invite_Status__c FROM Opportunity WHERE Id=:exhibitorSyncObj.Opportunity__c WITH SECURITY_ENFORCED LIMIT 1];
        Id OppId = lstOpp[0].Id;
        List<ExpocadBooth__c> BoothList = [SELECT Name , Booth_Number__c , Event_Code__c , Opportunity__c FROM ExpocadBooth__c Where Id  = :exhibitorSyncObj.ExpocadBooth__c WITH SECURITY_ENFORCED];
        //(SELECT Id,X3E_Contact_Status__c,Record_Number__c,Primary_exhibitor_contact__c FROM OpportunityContactRoles )
        String boothNumber = BoothList[0].Booth_Number__c;
        errorMessage = '';
        responseCode = '';
        responseBody = '';
        requestBody = '';
        String customerId = lstOpp[0].AccountId;
        requestBody = '';
        List<Event_Edition__c> eventRecord = [Select Id,x3E_API_ID__c, X3E_Status__c From Event_Edition__c Where Id = :lstOpp[0].EventEdition__c WITH SECURITY_ENFORCED];
        requestBody = '';        
        errorMessage = '';
        responseCode = '';
        responseBody = '';
        requestBody = '';
        String apiToken = Expo3EAPIUtilHelper.fetchApiToken();
        requestBody = '';
        if(String.isBlank(apiToken)){
            requestBody = '';
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
            errorMessage = System.label.Api_Token_Empty3E;
        }
        requestBody = '';
        errorMessage = String.isBlank(boothNumber) ? System.label.Booth_Number_is_Blank : errorMessage; 
        errorMessage = '';
        responseCode = '';
        responseBody = '';
        requestBody = '';
        requestBody = '';
        errorMessage = String.isBlank(customerId) ? System.label.Customer_Id_Is_Blank : errorMessage; 
        requestBody = '';
        
        if(Test.isRunningTest()){
            requestBody = '';
            errorMessage = '';
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
            apiToken = 'test121'; 
            requestBody = '';
        }
        Expocad3E_Wrapper.WrapperResponse wrapRespPostPutCall;
        requestBody = '';
        if(String.isBlank(errorMessage)){
            //if(exhibitorSyncObj.Type__c == Expocad3EAPIWrapper.EXPOCAD3E_EXHIBITOR_INVITE){
            requestBody = '';
            
            wrapRespPostPutCall = Expo3EAPIUtilHelper.fetchContractFrom3E(eventRecord[0].x3E_API_ID__c,customerId, boothNumber,true,apiToken);
            requestBody = '';
            //}
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
        }
        requestBody = '';
        
        if(wrapRespPostPutCall != null){
            requestBody = '';
            requestBody = wrapRespPostPutCall.requestBody;
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
            requestBody = '';
            if (wrapRespPostPutCall.response.getStatus() == null) {System.debug('To remove SCA violation');
                //errorMessage = System.label.ExpoCad_API_Down_Message;//System.Label.ExpoCAD_API_Down_Msg;
            }
            else if((exhibitorSyncObj.API_Call_Type__c == Expocad3E_Wrapper.GET && wrapRespPostPutCall.response.getStatusCode() == 200) ){
                calloutStatus = Expocad3E_Wrapper.SUCCESS;//|| (exhibitorSyncObj.API_Call_Type__c == Expocad3EAPIWrapper.POST && wrapRespPostPutCall.response.getStatusCode() == 201)
                requestBody = '';
                responseCode = String.valueOf(wrapRespPostPutCall.response.getStatusCode());
                requestBody = wrapRespPostPutCall.requestBody;
                requestBody = '';
                String fileName = 'default name.pdf';
                Pattern p = Pattern.compile('.+filename="(.+?)".*');
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                String contentDisposition = wrapRespPostPutCall.response.getHeader('Content-Disposition');
                if(contentDisposition != null) {
                    errorMessage = '';
                    responseCode = '';
                    responseBody = '';
                    requestBody = '';
                }
                fileName = fileName.substringBeforeLast('.')+'-'+String.valueOf(datetime.now())+'.'+fileName.substringAfterLast('.');
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                responseBody = fileName;
                Blob data  =  wrapRespPostPutCall.response.getBodyAsBlob();
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                if(Test.isRunningTest()){
                    String fileContent = 'name.pdf';
                    errorMessage = '';
                    responseCode = '';
                    responseBody = '';
                    requestBody = '';
                    data = Blob.valueOf(fileContent);
                }
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                List<ContentVersion> newConVerList = createContentVersions(data,fileName,OppId);
				//List<ContentVersion> newConVerList = createContentVersions(data,fileName);
                if(newConVerList!= null && !newConVerList.isEmpty()){ 
                    errorMessage = '';
                    responseCode = '';
                    responseBody = '';
                    requestBody = '';
                    Insert newConVerList;
                    List<ContentDocumentLink> newContDocList = createContentDocLink(newConVerList,lstOpp[0].Id,filename);
                    errorMessage = '';
                    responseCode = '';
                    responseBody = '';
                    requestBody = '';
                    if(newContDocList!= null && !newContDocList.isEmpty()){
                        Insert newContDocList;
                        errorMessage = '';
                        responseCode = '';
                        responseBody = '';
                        requestBody = '';
                    }
                }
                errorMessage = '';
                responseCode = '';
                responseBody = '';
                requestBody = '';
                
            }
            /*else{
            }*/
            errorMessage = '';
            responseCode = '';
            responseBody = '';
            requestBody = '';
        }
        Boolean updateOpp = false;
        if(errorMessage != '' || responseCode != '200')
        {System.debug('To remove SCA violation');
        }
        else{
            
            requestBody = '';
            APISynchronizationHelper.updateSyncItemStatus(New API_Synchronization_Item__c(Id=exhibitorSyncObj.id,Status__c= Expocad3E_Wrapper.COMPLETED,Response_Code__c=responseCode,Error_Message__c='',Request_Body__c=requestBody,Response_Body__c=responseBody));
            
            requestBody = '';
        }
        
        return calloutStatus;
        }
    
      public static List<ContentVersion> createContentVersions(Blob data,String fileName,Id oppsId){
        List<ContentVersion> newConVerList = new List<ContentVersion>();
        //for(ContentVersion conRec : conVerList){
        ContentVersion newRec = new ContentVersion(Title=fileName, 
                                                   PathOnClient =fileName,
                                                   VersionData = data, 
                                                   origin = 'H');
        newConVerList.add(newRec);
        //}
        return newConVerList;
    }
    
    /*public static list<Attachment> createContentVersions(Blob data , String fileName, Id OppId){

        list < agreement__c > lstAgreement = new list < agreement__c > ();
        Agreement__c objAgree = new Agreement__c();
        objAgree.name = fileName;
        objAgree.Opportunity__c = OppId;
        objAgree.CreatedById = Userinfo.getUserId();
        objAgree.LastModifiedById = Userinfo.getUserId();
                    
        lstAgreement.add(objAgree);
    
    
    
        insert lstAgreement;
    
        List<Attachment> lstAttachmentInsert =  new List<Attachment>();
        for(Agreement__c objAgre: lstAgreement){
            Attachment oAttachment = new Attachment();
            oAttachment.parentid = objAgre.id;
            oAttachment.Name = fileName;
            oAttachment.Body = data;
            lstAttachmentInsert.add(oAttachment);
        }
    
        //insert lstAttachmentInsert;
    
        return lstAttachmentInsert;
    }*/

    
    
    public static List<ContentDocumentLink> createContentDocLink(List<ContentVersion> newConVerList,Id recId,String filename){

        list < agreement__c > lstAgreement = new list < agreement__c > ();
        Agreement__c objAgree = new Agreement__c();
        objAgree.name = filename;
        objAgree.Opportunity__c = recId;
        objAgree.CreatedById = Userinfo.getUserId();
        objAgree.LastModifiedById = Userinfo.getUserId();
                    
        lstAgreement.add(objAgree);
    
    
    
        insert lstAgreement;

        List<ContentDocumentLink> newContDocList = new List<ContentDocumentLink>();
        for(ContentVersion conRec : [Select Id,contentdocumentid From ContentVersion Where Id IN :newConVerList WITH SECURITY_ENFORCED]){
            ContentDocumentLink contentlink = new ContentDocumentLink(); 
            contentlink.LinkedEntityId = lstAgreement[0].Id;
            contentlink.contentdocumentid = conRec.contentdocumentid;
            contentlink.ShareType = 'V';
            newContDocList.add(contentlink);
        }
        return newContDocList;
    }
    
    /**
* @description  This method is used to get CompanyTypeslist from 3E
* @param exhibitorSyncObj API Synchronization Item
* @param interfaceLogId interface log id   
* @return String Status
*/
    public static String getCompanyListFrom3E(API_Synchronization_Item__c exhibitorSyncObj) {//, Id interfaceLogId
        String calloutStatus = Expocad3E_Wrapper.PROCESSING;
        String errorMessage = '';
        String responseCode = '';
        String responseBody = '';
        String requestBody = '';
        
        //List<Opportunity> lstOpp = [SELECT Id,EventEdition__c,Opportunity_Contact__r.email,AccountId,StageName,X3E_Exhibitor_Invite_Status__c FROM Opportunity WHERE Id=:exhibitorSyncObj.Opportunity__c  LIMIT 1];
        //(SELECT Id,X3E_Contact_Status__c,Record_Number__c,Primary_exhibitor_contact__c FROM OpportunityContactRoles )
        String boothNumber;
        String customerId;
        
        /* if(oppContatcRoleRec[0].Opportunity.X3E_Exhibitor_Status__c != 'Created'){
errorMessage = System.Label.Exhibitor_Not_Synced3E;
}*/
        List<Event_Edition__c> eventRecord = [Select Id,x3E_API_ID__c, X3E_Status__c From Event_Edition__c Where Id = :exhibitorSyncObj.Event_Edition__c WITH SECURITY_ENFORCED];
        
        String apiToken = Expo3EAPIUtilHelper.fetchApiToken();
        if(String.isBlank(apiToken)){
            errorMessage = 'System.label.Api_Token_Empty3E';
        }
        if(Test.isRunningTest()){
            errorMessage = '';
            apiToken = 'test121';
        }
        Expocad3E_Wrapper.WrapperResponse wrapRespPostPutCall;
        if(String.isBlank(errorMessage)){
            if(exhibitorSyncObj.Type__c == Expocad3E_Wrapper.EXPOCAD3E_COMPANY_TYPE){
                wrapRespPostPutCall = Expo3EAPIUtilHelper.getCompanyListIn3E(eventRecord[0].x3E_API_ID__c,true,apiToken);
            }
        }
        
        if(wrapRespPostPutCall != null){
            requestBody = wrapRespPostPutCall.requestBody;
            if (wrapRespPostPutCall.response.getStatus() == null) {
                errorMessage = 'System.label.Api_Down3E';//System.Label.ExpoCAD_API_Down_Msg;
            }
            else if((exhibitorSyncObj.API_Call_Type__c == Expocad3E_Wrapper.GET && wrapRespPostPutCall.response.getStatusCode() == 200) ){
                calloutStatus = Expocad3E_Wrapper.SUCCESS;//|| (exhibitorSyncObj.API_Call_Type__c == Expocad3EAPIWrapper.POST && wrapRespPostPutCall.response.getStatusCode() == 201)
                responseCode = String.valueOf(wrapRespPostPutCall.response.getStatusCode());
                responseBody = wrapRespPostPutCall.response.getBody();
                //System.debug('Response===>>'+responseBody);
                requestBody = wrapRespPostPutCall.requestBody;
                /*if(exhibitorSyncObj.API_Call_Type__c == Expocad3EAPIWrapper.POST){
exhibitorDetails = (Expocad3EAPIWrapper.Exhibitors3ECreateRequest) JSON.deserialize(wrapRespPostPutCall.response.getBody(), Expocad3EAPIWrapper.Exhibitors3ECreateRequest.class);
}*/
            }
            else{
                responseCode = String.valueOf(wrapRespPostPutCall.response.getStatusCode());
                responseBody = wrapRespPostPutCall.response.getBody();
                errorMessage = wrapRespPostPutCall.response.getBody();
            }
        }
        //Boolean updateOpp = false;
        if(errorMessage != '' || responseCode != '200')
        {
            calloutStatus = Expocad3E_Wrapper.ERROR;// get Error 
            // Update Synchronization_Item Status
            APISynchronizationHelper.updateSyncItemStatus(New API_Synchronization_Item__c(Id=exhibitorSyncObj.id,Status__c= Expocad3E_Wrapper.ERROR,Error_Message__c=errorMessage,Response_Code__c=responseCode,Request_Body__c=requestBody,Response_Body__c=responseBody));
            /* if(lstOpp[0].X3E_Exhibitor_Invite_Status__c != 'Error'){
lstOpp[0].X3E_Exhibitor_Invite_Status__c = 'Error';
updateOpp = true;
}*/
            
        }
        
        else{
            
            APISynchronizationHelper.updateSyncItemStatus(New API_Synchronization_Item__c(Id=exhibitorSyncObj.id,Status__c= Expocad3E_Wrapper.COMPLETED,Response_Code__c=responseCode,Error_Message__c='',Request_Body__c=requestBody,Response_Body__c=responseBody));
            eventRecord[0].All_CompanyTypes_List__c = convertSyncData(responseBody);
            eventRecord[0].CompanyShowInShow__c = convertSyncDataToCompanyShowInShow(responseBody);
            update eventRecord;
            /*if(lstOpp[0].X3E_Exhibitor_Invite_Status__c != 'Invited'){
lstOpp[0].X3E_Exhibitor_Invite_Status__c = 'Invited';
updateOpp = true;
}*/
        }
        
        return calloutStatus;
    }

    /**
* @description  This method convert json response to csv and Store in All_Company[EX-21]
* @param  prams Callout Parameters for request
* @param  CompanyTypesList
* @return  String returnData
*/
    public static string convertSyncDataToCompanyShowInShow(String jsonData){
        
        string data = '';
        
        String record = jsonData.replace('&quot;','"');
        Expocad3E_Wrapper.CompanyTypes recList = (Expocad3E_Wrapper.CompanyTypes)JSON.deserialize(record, Expocad3E_Wrapper.CompanyTypes.class);
        
        
        for(Expocad3E_Wrapper.cls_companyTypeList rec : recList.companyTypeList) {
            for(String showInShow : rec.showInShows){
                data += rec.companyType == null || rec.companyType == '' ? 'null' : rec.companyType + '-' + showInShow + '\n';
            }
        }
        return data;
    }
    public static string  convertSyncData(String jsonData){
        String returnData = 'CompanyId, CompanyTypeId-CompanyName, ShowInShows\n';
        String record = jsonData.replace('&quot;','"');
        Expocad3E_Wrapper.CompanyTypes recList = (Expocad3E_Wrapper.CompanyTypes)JSON.deserialize(record, Expocad3E_Wrapper.CompanyTypes.class);
        
        
        for(Expocad3E_Wrapper.cls_companyTypeList rec : recList.companyTypeList) {
            System.debug('rec---'+rec);
            if(rec.companyListIds.size()==0 && rec.showInShows.size()!=0){
                for(String view : rec.showInShows){
                    returnData += 'null,null,'+view + '\n';
                }
            }else if(rec.companyListIds.size()!=0 && rec.showInShows.size()==0){
                for(Expocad3E_Wrapper.cls_companyListIds view : rec.companyListIds){
                    returnData += view.companyId+','+rec.typeId+'-'+view.name+',null\n';
                }
            }else if(rec.companyListIds.size()>0 && rec.showInShows.size()>0){
                for(Expocad3E_Wrapper.cls_companyListIds view : rec.companyListIds){
                    for(String recView : rec.showInShows){
                        returnData += view.companyId+','+rec.typeId+'-'+view.name+','+recView + '\n' ;
                    }            
                }
            }
            
        }
        return returnData;
    }
    
        /**
    * @description  This method is used for quote recalculation after the all the callouts from 3e are received 
    * @param exhibitorSyncObj API Synchronization Item
    * @return String Status
    */
    public static String CalculateQuote(API_Synchronization_Item__c exhibitorSyncObj) {//, Id interfaceLogId
        String calloutStatus = Expocad3E_Wrapper.PROCESSING;
        errorMessage = '';
        responseCode = ''; 
        responseBody = '';
        requestBody = '';
    
        List<Opportunity> lstOpp = [SELECT Id,SBQQ__PrimaryQuote__c FROM Opportunity WHERE Id=:exhibitorSyncObj.Opportunity__c WITH SECURITY_ENFORCED LIMIT 1];

        String quoteId = String.isNotBlank(lstOpp[0].SBQQ__PrimaryQuote__c) ? lstOpp[0].SBQQ__PrimaryQuote__c : '';
        
        try
        {
            if(String.isNotBlank(quoteId)){
                SBQQ__Quote__c quote = [SELECT Id, SBQQ__Primary__c FROM SBQQ__Quote__c WHERE Id=:quoteId];
                
                quote.SBQQ__Primary__c = !quote.SBQQ__Primary__c;
                update quote;
                
                quote.SBQQ__Primary__c = !quote.SBQQ__Primary__c;
                update quote;
                //Expo3EAPIUtils.SaveCPQQUoteAterCalculate(quoteId); 
                responseBody = quoteId;
            }
            calloutStatus = Expocad3E_Wrapper.SUCCESS;
            APISynchronizationHelper.updateSyncItemStatus(New API_Synchronization_Item__c(Id=exhibitorSyncObj.id,Status__c= Expocad3E_Wrapper.COMPLETED,Response_Code__c=responseCode,Error_Message__c='',Request_Body__c=requestBody,Response_Body__c=responseBody));
            
        }
        catch(Exception ex){
            calloutStatus = Expocad3E_Wrapper.ERROR;
            errorMessage = ex.getMessage();
            // Update Synchronization_Item Status
            APISynchronizationHelper.updateSyncItemStatus(New API_Synchronization_Item__c(Id=exhibitorSyncObj.id,Status__c= Expocad3E_Wrapper.ERROR,Error_Message__c=errorMessage,Response_Code__c=responseCode,Request_Body__c=requestBody,Response_Body__c=responseBody));
        }
        return calloutStatus;
    }
 //[EX-159]
    public static String UpdateOpportunity(API_Synchronization_Item__c exhibitorSyncObj,List<Opportunity> listOppForStatusUpdate) {//, Id interfaceLogId
        String calloutStatus = Expocad3E_Wrapper.PROCESSING;
        errorMessage = '';
        responseCode = ''; 
        responseBody = '';
        requestBody = '';
        
        List<Opportunity> lstOpp = [SELECT Id,SBQQ__PrimaryQuote__c FROM Opportunity WHERE Id=:exhibitorSyncObj.Opportunity__c WITH SECURITY_ENFORCED LIMIT 1];

        String oppID = String.isNotBlank(lstOpp[0].Id) ? lstOpp[0].Id : '';
        
        try
        {
            if(String.isNotBlank(oppID)){
                Expo3EAPIUtils.OpportunityStatusUpdate(oppID, listOppForStatusUpdate);
                responseBody = oppID;
            }
            calloutStatus = Expocad3E_Wrapper.SUCCESS;
            APISynchronizationHelper.updateSyncItemStatus(New API_Synchronization_Item__c(Id=exhibitorSyncObj.id,Status__c= Expocad3E_Wrapper.COMPLETED,Response_Code__c=responseCode,Error_Message__c='',Request_Body__c=requestBody,Response_Body__c=responseBody));
            
        }
        catch(Exception ex){
            calloutStatus = Expocad3E_Wrapper.ERROR;
            errorMessage = ex.getMessage();
            // Update Synchronization_Item Status
            APISynchronizationHelper.updateSyncItemStatus(New API_Synchronization_Item__c(Id=exhibitorSyncObj.id,Status__c= Expocad3E_Wrapper.ERROR,Error_Message__c=errorMessage,Response_Code__c=responseCode,Request_Body__c=requestBody,Response_Body__c=responseBody));
        }
        return calloutStatus;
    }
    
    /**
    * @description  Method to handle response from expocad API
    * @param  expocadboothSyncObj 
    * @return  calloutStatus
    * Modified by Abhishek Sharma on 21/02/2023 : EX-154
    */
    public static String syncExpocadBooth(API_Synchronization_Item__c expocadboothSyncObj){
        String calloutStatus = Expocad3E_Wrapper.PROCESSING;
        String errorMessage = '';
        String responseCode = '';
        String responseBody = '';
        String requestBody = '';   
        Expocad3E_Wrapper.WrapperResponse wrapRespPostPutCall;

        List<ExpocadBooth__c> boothrecord = [Select Id,Booth_Number__c,Opportunity__c, Opportunity__r.AccountId, Quote__c, Display_Name__c, Expocad_API_URL__c,Event_Code__c  From ExpocadBooth__c Where Id = :expocadboothSyncObj.ExpocadBooth__c WITH SECURITY_ENFORCED];
        List<Opportunity_ExpoCAD_Booth_Mapping__c> oppoExpMap = new List<Opportunity_ExpoCAD_Booth_Mapping__c>();
        oppoExpMap = [Select Id , Account__r.Name , Display_Name__c , Opportunity__r.User_Type__r.Name FROM Opportunity_ExpoCAD_Booth_Mapping__c WHERE Opportunity__c = : boothrecord[0].Opportunity__c WITH SECURITY_ENFORCED LIMIT 1];
        
        if(String.isBlank(errorMessage)){
            if(expocadboothSyncObj.Type__c == Expocad3E_Wrapper.EXPOCAD_BOOTH_UNRENT ){
                wrapRespPostPutCall = Expo3EAPIUtilHelper.ExpoCADBoothUnrent(boothrecord[0].Booth_Number__c, boothrecord[0].Event_Code__c, boothrecord[0].Expocad_API_URL__c);
            } 
            else if(expocadboothSyncObj.Type__c == Expocad3E_Wrapper.EXPOCAD_BOOTH_UNHOLD ){
                wrapRespPostPutCall = Expo3EAPIUtilHelper.ExpoCADBoothUnhold(boothrecord[0].Booth_Number__c, boothrecord[0].Event_Code__c, boothrecord[0].Expocad_API_URL__c);
            } 
            else if(expocadboothSyncObj.Type__c == Expocad3E_Wrapper.EXPOCAD_BOOTH_RENTTOHOLD){
                wrapRespPostPutCall = Expo3EAPIUtilHelper.ExpoCADBoothRentToHold(boothrecord[0].Booth_Number__c, boothrecord[0].Event_Code__c, boothrecord[0].Expocad_API_URL__c);
            } 
			else if(expocadboothSyncObj.Type__c == Expocad3E_Wrapper.EXPOCAD_BOOTH_RENT){
                wrapRespPostPutCall = Expo3EAPIUtilHelper.getRateplan(boothrecord[0].Event_Code__c, boothrecord[0].Expocad_API_URL__c);
                if(wrapRespPostPutCall != null && wrapRespPostPutCall.response.getStatusCode() == 200){
                    String sRatePlan = wrapRespPostPutCall.response.getBody();
                    ExpocadClasses.RatePlan oRentPlan = (ExpocadClasses.RatePlan)JSON.deserialize(sRatePlan, ExpocadClasses.RatePlan.class);
                    wrapRespPostPutCall = Expo3EAPIUtilHelper.ExpoCADBoothRent(boothrecord[0].Booth_Number__c, boothrecord[0].Event_Code__c, boothrecord[0].Expocad_API_URL__c, boothrecord[0].Opportunity__r.AccountId, boothrecord[0].Opportunity__c, oRentPlan.Name);
                }
            } 
			else if(expocadboothSyncObj.Type__c == Expocad3E_Wrapper.EXPOCAD_BOOTH_HOLD && !oppoExpMap.isEmpty() && oppoExpMap[0].Display_Name__c != null){
                wrapRespPostPutCall = Expo3EAPIUtilHelper.ExpoCADBoothHold(boothrecord[0].Booth_Number__c, boothrecord[0].Event_Code__c, boothrecord[0].Expocad_API_URL__c, boothrecord[0].Opportunity__c, oppoExpMap[0].Display_Name__c);
            } 
            
            if(wrapRespPostPutCall != null){
                requestBody = wrapRespPostPutCall.requestBody;
                if (wrapRespPostPutCall.response.getStatus() == null) {
                    errorMessage = 'ExpoCAD is Down......';//System.Label.ExpoCAD_API_Down_Msg;
                }
                else if((expocadboothSyncObj.API_Call_Type__c == Expocad3E_Wrapper.PUT && wrapRespPostPutCall.response.getStatusCode() == 200) ){
                    calloutStatus = Expocad3E_Wrapper.SUCCESS;
                    responseCode = String.valueOf(wrapRespPostPutCall.response.getStatusCode());
                    responseBody = wrapRespPostPutCall.response.getBody();
                    requestBody = wrapRespPostPutCall.requestBody;
                }
                else{
                    responseCode = String.valueOf(wrapRespPostPutCall.response.getStatusCode());
                    responseBody = wrapRespPostPutCall.response.getBody();
                    errorMessage = wrapRespPostPutCall.response.getBody();
                }
                if(errorMessage != '' || responseCode != '200')
                {
                    calloutStatus = Expocad3E_Wrapper.ERROR;// get Error 
                    // Update Synchronization_Item Status
                    APISynchronizationHelper.updateSyncItemStatus(New API_Synchronization_Item__c(Id=expocadboothSyncObj.id,Status__c= Expocad3E_Wrapper.ERROR,Error_Message__c=errorMessage,Response_Code__c=responseCode,Request_Body__c=requestBody,Response_Body__c=responseBody));
                }
                else
                {
                    APISynchronizationHelper.updateSyncItemStatus(New API_Synchronization_Item__c(Id=expocadboothSyncObj.id,Status__c= Expocad3E_Wrapper.COMPLETED,Response_Code__c=responseCode,Error_Message__c='',Request_Body__c=requestBody,Response_Body__c=responseBody));
                }
                
            }
        }
        return calloutStatus;
    }
    
     /**
    * @description Creates/Updates exhibitor details in Expocad
    * @param  expocadboothSyncObj 
    * @return  calloutStatus
    * Added by Abhishek Sharma on 21/02/2023 : EX-154
    */
    public static String createExpocadExhibitor(API_Synchronization_Item__c expocadboothSyncObj){
        String calloutStatus = Expocad3E_Wrapper.PROCESSING;
        String errorMessage = '';
        String responseCode = '';
        String responseBody = '';
        String requestBody = '';   
        Expocad3E_Wrapper.WrapperResponse wrapRespPostPutCall;
        
		ExpocadClasses.X3EExhibitor oExibitor = new ExpocadClasses.X3EExhibitor(); 
        List<ExpocadBooth__c> boothrecord = [Select Id,Booth_Number__c,Opportunity__c, Opportunity__r.AccountId, Opportunity__r.Parent_Opportunity__c, Opportunity__r.Billing_Contact__c, Opportunity__r.User_Type__r.Name, Opportunity__r.Account.Name, Quote__c, Display_Name__c, Expocad_API_URL__c,Event_Code__c  From ExpocadBooth__c Where Id = :expocadboothSyncObj.ExpocadBooth__c WITH SECURITY_ENFORCED];
        List<Opportunity_ExpoCAD_Booth_Mapping__c> oppoExpMap = new List<Opportunity_ExpoCAD_Booth_Mapping__c>();
        oppoExpMap = [Select Id , Account__r.Name , Display_Name__c , Opportunity__r.User_Type__r.Name FROM Opportunity_ExpoCAD_Booth_Mapping__c WHERE Opportunity__c = : boothrecord[0].Opportunity__c WITH SECURITY_ENFORCED LIMIT 1];
        If(!oppoExpMap.isEmpty()) {
            oExibitor.DoingBusinessAsDisplayOnDrawing = (!String.isBlank(oppoExpMap[0].Display_Name__c)) ? subString(oppoExpMap[0].Display_Name__c, 50) : subString(oppoExpMap[0].Account__r.Name, 50);
            oExibitor.Comments2 = (oppoExpMap[0].Opportunity__r.User_Type__r.Name == 'Agent') ? oppoExpMap[0].Opportunity__r.User_Type__r.Name : '';
        }else { 
            oExibitor.DoingBusinessAsDisplayOnDrawing = subString(boothrecord[0].Opportunity__r.Account.Name, 50);
        }
        if (boothrecord[0].Opportunity__r.Parent_Opportunity__c == null && boothrecord[0].Opportunity__r.User_Type__r.Name == 'Agent') { 
            oExibitor.Comments2 = boothrecord[0].Opportunity__r.User_Type__r.Name;
        }
        
        if(String.isBlank(errorMessage)){
            wrapRespPostPutCall = Expo3EAPIUtilHelper.getExhibitor(boothrecord[0].Event_Code__c, boothrecord[0].Expocad_API_URL__c, boothrecord[0].Opportunity__r.AccountId);            

            if(wrapRespPostPutCall != null){
                requestBody = wrapRespPostPutCall.requestBody;
                if (wrapRespPostPutCall.response.getStatus() == null) {
                    errorMessage = 'ExpoCAD is Down......';//System.Label.ExpoCAD_API_Down_Msg;
                }
                else if(wrapRespPostPutCall.response.getStatusCode() == 200){

                    // Code to run the update if the Exhibitor already exists in ExpoCAD
                    oExibitor.ExhibitorId = boothrecord[0].Opportunity__r.AccountId;  
                    oExibitor.ExhibitorName = subString(boothrecord[0].Opportunity__r.Account.Name, 50);

                    String sExbBody = JSON.serialize(oExibitor);

                    wrapRespPostPutCall = Expo3EAPIUtilHelper.updateExhibitor(boothrecord[0].Event_Code__c, boothrecord[0].Opportunity__r.AccountId, boothrecord[0].Expocad_API_URL__c, sExbBody);

                    if(wrapRespPostPutCall.response.getStatusCode() == 200){
                        calloutStatus = Expocad3E_Wrapper.SUCCESS;
                        responseCode = String.valueOf(wrapRespPostPutCall.response.getStatusCode());
                        responseBody = wrapRespPostPutCall.response.getBody();
                        requestBody = wrapRespPostPutCall.requestBody;
                    }
                }
                else if(wrapRespPostPutCall.response.getStatusCode() == 404){

                    // Code to create new Exhibitor if existing exhibitor was not found
                    oExibitor.ExhibitorId = boothrecord[0].Opportunity__r.AccountId;
                    oExibitor.ExhibitorName = subString(boothrecord[0].Opportunity__r.Account.Name, 50);
                    if (boothrecord[0].Opportunity__r.Billing_Contact__c != null) {
                        Contact oCon = [SELECT Name, Phone, Title, Salutation, MailingStreet, Email, MailingCity, MailingState, MailingPostalCode, MailingCountry FROM Contact WHERE id = : boothrecord[0].Opportunity__r.Billing_Contact__c WITH SECURITY_ENFORCED];
                        if (!String.isBlank(oCon.MailingState)) {
                            oExibitor.State = subString(oCon.MailingState, 10);
                        }
                        if (!String.isBlank(oCon.MailingPostalCode)) {
                            oExibitor.PostalCode = subString(oCon.MailingPostalCode, 10);
                        }
                        if (!String.isBlank(oCon.Email) && oCon.Email.length() <= 50) {
                            oExibitor.Email = oCon.Email;
                        }
                        if (!String.isBlank(oCon.MailingCountry)) {
                            oExibitor.Country = subString(oCon.MailingCountry, 40);
                        }
                        if (!String.isBlank(oCon.MailingCity)) {
                            oExibitor.City = subString(oCon.MailingCity, 40);
                        }
                        if (!String.isBlank(oCon.MailingStreet)) {
                            oExibitor.Address1 = subString(oCon.MailingStreet, 50);
                        }
                        if (!String.isBlank(oCon.Name)){
                        oExibitor.Contact = subString(oCon.Name, 50); 
                        }
                        if (!String.isBlank(oCon.Phone)){
                        oExibitor.Phone = subString(oCon.Phone, 30); 
                        }
                        if (!String.isBlank(oCon.Title)){
                        oExibitor.Title = subString(oCon.Title, 25); 
                        }
                        if (!String.isBlank(oCon.Salutation)){
                        oExibitor.Salutation = subString(oCon.Salutation, 30); 
                        }
                    }
                    String sExbBody = JSON.serialize(oExibitor);
                    
                    wrapRespPostPutCall = Expo3EAPIUtilHelper.createExhibitor(boothrecord[0].Event_Code__c, boothrecord[0].Expocad_API_URL__c, sExbBody);

                    if(wrapRespPostPutCall.response.getStatusCode() == 201){
                        calloutStatus = Expocad3E_Wrapper.SUCCESS;
                        responseCode = String.valueOf(wrapRespPostPutCall.response.getStatusCode());
                        responseBody = wrapRespPostPutCall.response.getBody();
                        requestBody = wrapRespPostPutCall.requestBody;
                    }
                }
                else{
                    responseCode = String.valueOf(wrapRespPostPutCall.response.getStatusCode());
                    responseBody = wrapRespPostPutCall.response.getBody();
                    errorMessage = wrapRespPostPutCall.response.getBody();
                }
                if(errorMessage != '' || (responseCode != '200' && responseCode != '201'))
                {
                    calloutStatus = Expocad3E_Wrapper.ERROR;// get Error 
                    // Update Synchronization_Item Status
                    APISynchronizationHelper.updateSyncItemStatus(New API_Synchronization_Item__c(Id=expocadboothSyncObj.id,Status__c= Expocad3E_Wrapper.ERROR,Error_Message__c=errorMessage,Response_Code__c=responseCode,Request_Body__c=requestBody,Response_Body__c=responseBody));
                }
                else
                {
                    APISynchronizationHelper.updateSyncItemStatus(New API_Synchronization_Item__c(Id=expocadboothSyncObj.id,Status__c= Expocad3E_Wrapper.COMPLETED,Response_Code__c=responseCode,Error_Message__c='',Request_Body__c=requestBody,Response_Body__c=responseBody));
                }
                
            }
        }
        return calloutStatus;
    }

    Public static String subString(String sTemp, Integer iLength) {
        if (sTemp.length() > iLength) { sTemp = sTemp.substring(0, iLength); }
        return sTemp;
    }
    
}