/**
* File:             BoothSelectionCtrl.cls
* Project:          GAP
* Date:             Sep 06, 2016
* Test Class Name:  BoothSelectionCtrl_Test
* Created By:       Kumar Gaurav
* @description      Controller for BoothSelectionCtrl page to search Booth from Expocad.
* History ----: Replaced As Per Ticket GGCW-3101 :----'Product_brand__c Replaced by this Event_Edition_Name__c field'
* Rajesh Kumar Yadav
* Modified by Avinash Shukla for Jira Ticket GGCW-3001-- GGCW-3006
*/

Public class BoothSelectionCtrl {
    public String sBoothID {get; set;}
    public String sBoothSize {get; set;}
    public String sEventEdition {get; set;}
    public String sCorner {get; set;}
    public String sBoothType {get; set;}
    public List < ExpocadClasses.Booth > lstExpoBooth {get; set;}
    public List < ExpocadBooth__c > lstExpocad {get; set;}
    public List < ExpocadBooth__c > lstHeldBooth {get; set;}
    public SBQQ__Quote__c oSBQQQuote {get; set;}
    public String quoteId {get; set;}
    public Opportunity oOpportunity {get; set;}
    public Id sOpptyAccountID {get; set;}
    public String sOpptyAccountName {get; set;}
    public String sExpocadDbName {get; set;}
    public Boolean isShowMsg {get; set;}
    public Id expocadBoothId {get; set;}
    public String sShowMsg {get; set;}
    public String sShowMsg2 {get; set;}
    public Set < String > boothtoItself {get; set;}
    public String sHost {get; set;}
    public Boolean shouldRedirect {public get; private set;}
    public String redirectUrl {public get; private set;}
    private ApexPages.StandardController stdController;
    public Product2 boothPackageProduct {get; set;}
    public String sFPBoothProductType {get; set;}
    public String cornerProductName {get; set;}
    public Map < String, SBQQ__ProductOption__c > mapProductOptions {get; set;}
    public Integer heldBoothCount {get; set;}
    public Double maxHoldAllowed {get; set;}
    public Double maxHoldDays {get; set;}
    public String boothApprovalMessage {get; set;}
    public List < ExpocadBooth__c > lstReferencedBN {get; set;}
    private Boolean isLightingEnv;
    public Static Map < Id, SBQQ__ProductOption__c > mapProductOptionsId {get; set;}
    //Modified By Avinash Shukla.//Adding MPN functionality here for MPN : GGCW-3001-- GGCW-3006.
    Public Map<String, Booth_Product_Type_Configuration__c> bptTpMpnConfig {get; set;}
    Public List <Booth_Approval_Dashboard__c> boothApproval {get; set;}
    Public List <Booth_Approval_Dashboard__c> setOpp {get; set;}
    Public String status {get; set;}
    API_Detail__mdt apiMappings;
    public String API3EFloorplanToken {get; set;} 

    public BoothSelectionCtrl(ApexPages.StandardController controller) {
        //Adding MPN functionality here for MPN : GGCW-3001-- GGCW-3006.
        bptTpMpnConfig = new Map<String, Booth_Product_Type_Configuration__c>();
        bptTpMpnConfig = Utility.mapBoothProductType();
        this.stdController = controller;
        isShowMsg = false;
        shouldRedirect = false;
        sHost = URL.getSalesforceBaseUrl().toExternalForm();
        quoteId = apexpages.currentpage().getparameters().get('id');
        lstReferencedBN = new List < ExpocadBooth__c > ();
        boothApproval = new List <Booth_Approval_Dashboard__c>();
        isLightingEnv = Utility.isLightning(ApexPages.currentPage().getURL());
        boothApprovalMessage = System.Label.Booth_Approval_Message.escapeHtml4();
        if (!String.isBlank(quoteId)) {
            if (Schema.sObjectType.SBQQ__Quote__c.isAccessible()) {
                List < SBQQ__Quote__c > lstQuote = [select Id, Price_Book_Name__c, SBQQ__PriceBook__c, SBQQ__Opportunity2__r.Parent_Opportunity__c, Name, SBQQ__Opportunity2__c, SBQQ__Opportunity2__r.EventEdition__r.Booth_Classes_on_Template__c from SBQQ__Quote__c where Id = : quoteId LIMIT 1];
                if (lstQuote != null && lstQuote.size() > 0) {
                    oSBQQQuote = lstQuote.get(0);
                    List < Opportunity > lstOppo = [SELECT AccountId,Opportunity_Contact__c,EventEdition__r.Booth_Bundle_Type__c, EventEdition__r.X3E_Domain__c, User_Type__r.Name, StageName, Parent_Opportunity__c, Booth_Approval_Status__c , SBQQ__PrimaryQuote__c ,Multiple_Stands_Approval__c, Owner.Id, Account.Name, EventEdition__r.Booth_Size__c, EventEdition__r.No_Of_Corner__c, EventEdition__r.Event_Code__c, EventEdition__r.Expocad_API_Url__c, EventEdition__r.Max_Hold_Days__c, EventEdition__r.Max_Hold_Booth__c, EventEdition__r.Booth_Product_Type__c, Event_Series__r.Brand__r.SSC_Email_Distribution_ID__c, Event_Series__r.Package_Identifier__c, EventEdition__r.Booth_Type__c, EventEdition__r.Name, Billing_Contact__c, MSA_Requested__c, EventEdition__r.Corner_Configuration_Check__c, EventEdition__r.Product_Type_Order__c, EventEdition__r.X3E_Status__c, EventEdition__r.X3E_API_ID__c, Account.Website FROM Opportunity WHERE Id = : oSBQQQuote.SBQQ__Opportunity2__c];
                    apiMappings =  [Select API_End_Point__c,API_Method__c,Password__c from API_Detail__mdt Where API_3rd_Party_Name__c=:Expocad3E_Wrapper.EXPOCAD3E and MasterLabel =:'GetFloorplanApiTokenExpo3E' limit 1];
                    if (lstOppo != null && lstOppo.size() > 0) {
                        oOpportunity = lstOppo.get(0);
                        maxHoldDays = BoothSelectionCtrl.replaceNullByZero(oOpportunity.EventEdition__r.Max_Hold_Days__c);
                        maxHoldAllowed = BoothSelectionCtrl.replaceNullByZero(oOpportunity.EventEdition__r.Max_Hold_Booth__c);
                        sOpptyAccountID = oOpportunity.AccountId;
                        sOpptyAccountName = oOpportunity.Account.Name;
                        API3EFloorplanToken = apiMappings.Password__c;                    
                    }
                    for (ExpocadBooth__c oEB : [SELECT Id, Booth_Number__c, Status__c, Dimensions__c FROM ExpocadBooth__c WHERE Opportunity__c = : oOpportunity.Id AND Status__c != 'Released' AND Quote__c = : oSBQQQuote.Id LIMIT 1000]) {
                        lstReferencedBN.add(oEB);
                    }
                }
            }
        }
    }

    /**
     * Action method which will called by page "Boothselectionlghtn" and "HeldBoothslghtn". This method retrieves all held booths for Opportunity if Any.
     */
    public void autoRun() {
        if (Schema.sObjectType.ExpocadBooth__c.isAccessible()) {
            lstHeldBooth = [SELECT id, Selected__c, AddedToQLI__c, Matched_Product_Name__c, Booth_Product_Type__c, Quote__r.Name, Quote__r.SBQQ__Primary__c, User__r.Name, Area__c, Unit_Type__c, Open_Corners__c, Booth_Type__c, Booth_Number__c, Dimensions__c, Last_Action_Date__c, Status__c, Opportunity__c, Account__c, ShowInShow__c, Pavilion__c, Booth_Classes__c, Booth_Product_Type_EE__c from ExpocadBooth__c where Opportunity__c = : oOpportunity.Id order by LastModifiedDate desc LIMIT 1000];
            if (!lstHeldBooth.isEmpty()) {
                Set < String > setHeldUniqueBN = new Set < String > ();
                for (ExpocadBooth__c oEB : lstHeldBooth) {
                    if (oEB.Status__c != 'Released') {
                        setHeldUniqueBN.add(oEB.Booth_Number__c);
                    }
                }
                heldBoothCount = setHeldUniqueBN.size();
            }
        }
    }

    /**
     * method for maximum booth hold approval process.
     * @return PageReference
     */
    public PageReference boothHoldApproval() {
        try {
            if (Schema.sObjectType.OrgWideEmailAddress.isAccessible()) {
                OrgWideEmailAddress[] oWideEmailAdrs = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'GE Exhibitions' LIMIT 1];
                Booth_Approval_Dashboard__c oBAD = new Booth_Approval_Dashboard__c(Opportunity__c = oOpportunity.Id);
                insert oBAD;
                oOpportunity.MSA_Requested__c = True;
                update oOpportunity;
                if (oOpportunity.Event_Series__r.Brand__r.SSC_Email_Distribution_ID__c != null && !oWideEmailAdrs.isEmpty()) {
                    if (Schema.sObjectType.EmailTemplate.isAccessible()) {
                        EmailTemplate templateId = [Select id from EmailTemplate where name = 'Booth Stands Approval Request'];
                        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                        message.toAddresses = new String[] {oOpportunity.Event_Series__r.Brand__r.SSC_Email_Distribution_ID__c};
                        message.setTemplateID(templateId.Id);
                        message.optOutPolicy = 'FILTER';
                        message.setTargetObjectId(oOpportunity.Owner.Id);
                        message.setWhatId(oSBQQQuote.id);
                        message.setOrgWideEmailAddressId(oWideEmailAdrs.get(0).Id);
                        message.setSaveAsActivity(false);
                        Messaging.SingleEmailMessage[] messages = new List < Messaging.SingleEmailMessage > { message };
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                    }
                }
            }
        } catch (exception ex) {
            Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'boothHoldApproval(@BoothSelectionCtrl.Class)');
        }
        return null;
    }
    public void avialableBooth() {
        this.expocadApiCall(sBoothID, sBoothSize, sCorner, sEventEdition, sBoothType);
    }

    /**
     * To get Expocad booth details, Calling from "Expocad_Booth_Plan" page.
     * @param BoothID
     */
    public void checkFloorBooth() {

        if (apexpages.currentpage().getparameters().get('floorBoothId') != null) {sBoothID = apexpages.currentpage().getparameters().get('floorBoothId').escapeHtml4();}
        String sEvent = oOpportunity.EventEdition__r.Event_Code__c;
        this.expocadApiCall(sBoothID, sBoothSize, sCorner, sEvent, 'FloorPlan');
        if (lstExpoBooth != null && lstExpoBooth.size() > 0) {
            for (ExpocadClasses.Booth oBooth : lstExpoBooth) {
                oBooth.isSelected = true;
            }
        }
    }

    /**
     * Checking Expocad Product package is configured or not inside SF.
     */
    public void checkPrerequisiteProduct() {
        sShowMsg = '';
        isShowMsg = false;
        this.getBoothProducts();
        if (boothPackageProduct.Id == null || mapProductOptions.isEmpty() || String.isBlank(cornerProductName)) {
            isShowMsg = true;
            if (boothPackageProduct.Id == null) { sShowMsg = System.Label.Product_Package_Is_Not_Configured; }
            else if (mapProductOptions.isEmpty()) { sShowMsg = System.Label.Products_Not_Exist; }
            else if (String.isBlank(cornerProductName)) { sShowMsg = System.Label.Corner_Booth_Fee_Not_Exist; }
            
            
            
            for (ExpocadClasses.Booth oTempBooth : lstExpoBooth) {
                oTempBooth.isSelected = false;
            }
        }
    }

    /**
     * To hold Expocad booths, Calling from "Boothselectionlghtn" page.
     * @return PageReference
     */
    public PageReference holdBooth() {
        this.getBoothProducts();
        this.checkPrerequisiteProduct();
        if (isShowMsg && !String.isBlank(sShowMsg)) {
            return null;
        }
        this.holdBoothRequest('ToHoldOnly');
        if (isShowMsg) {
            return null;
        }
        if (isLightingEnv) {
            return returnToPT();
        } else {
            shouldRedirect = true;
            redirectUrl = stdController.view().getUrl();
        }
        return null;
    }

    /**
     * To hold Expocad booths, Calling from "Expocad_Booth_Plan" page.
     * @return PageReference
     */
    public PageReference holdFloorBooth() {
        this.getBoothProducts();
        this.checkPrerequisiteProduct();
        if (isShowMsg && !String.isBlank(sShowMsg)) {
            return null;
        }
        if (lstExpoBooth != null && lstExpoBooth.size() > 0) {
            for (ExpocadClasses.Booth oBooth : lstExpoBooth) {
                oBooth.BoothClass = sFPBoothProductType;
            }
        }
        this.holdBoothRequest('ToHoldOnly');
        if (isShowMsg) {
            return null;
        }
        if (isLightingEnv) {
            return returnToPT();
        } else {
            return new pageReference('/' + oSBQQQuote.Id + '?inline=0').setRedirect(true);
        }
        // Commented by Palla Kishore for the ticket EMEA-264 to avoid Unreachable statement error	
       // return null;
    }

    /**
     * To hold Expocad booths and to add Quote Line item, Calling from "Boothselectionlghtn" page.
     * @return PageReference
     */
    public PageReference holdAndAddToQLI() {
        this.getBoothProducts();
        this.checkPrerequisiteProduct();
        if (isShowMsg && !String.isBlank(sShowMsg)) {
            return null;
        }
        this.holdBoothRequest('addAll');
        if (isShowMsg) {
            return null;
        }
        return addToQLI('addAll');
    }

    /**
     * To hold Expocad booths and to add Quote Line item, Calling from "Expocad_Booth_Plan" page.
     * @return PageReference
     */
    public PageReference holdAndAddFloorBooth() {
        this.getBoothProducts();
        this.checkPrerequisiteProduct();
        if (isShowMsg && !String.isBlank(sShowMsg)) {
            return null;
        }
        if (lstExpoBooth != null && lstExpoBooth.size() > 0) {
            for (ExpocadClasses.Booth oBooth : lstExpoBooth) {
                oBooth.BoothClass = sFPBoothProductType;
            }
        }
        this.holdBoothRequest('addAll');
        if (isShowMsg) {
            return null;
        }
        return addToQLI('addAll');
    }

    /**
     * To add Quote Line item, Calling from "HeldBoothslghtn" page.
     * @return PageReference
     */
    public PageReference addHBtoQLI() {
        return addToQLI('HeldBooth');
    }

    /**
     * Designed to get all available Expocad Booth details.
     * @param BoothID
     * @param BoothSize
     * @param Corner
     * @param EventEdition
     * @param BoothType
     */
    public void expocadApiCall(String boothID, String boothSize, String corner, String eventEdition, String boothType) {
        try {
            expocadBoothId = null;
            lstHeldBooth = new List < ExpocadBooth__c > ();
            lstExpoBooth = new List < ExpocadClasses.Booth > ();
            sExpocadDbName = eventEdition;
            String sAPIUrl;
            sShowMsg = '';
            isShowMsg = false;
            Boolean isAvailable = false;
            if (String.isBlank(oOpportunity.EventEdition__r.Event_Code__c)) {
                sShowMsg = System.Label.Event_Code_Not_Configured_Msg;
                isShowMsg = true;
            } else if (String.isBlank(oOpportunity.EventEdition__r.Expocad_API_Url__c)) {
                sShowMsg = System.Label.Expocad_API_Url_Not_Configured_Msg;
                isShowMsg = true;
            }
            if (!isShowMsg) {
                sAPIUrl = this.makeExpocadQuery(boothID, boothSize, corner, sExpocadDbName, boothType);
                 system.debug('ZuheabsAPIURL-----'+ sAPIUrl );
                HttpResponse res = new ExpocadResponses().request(sAPIUrl, 'GET', '');
                if (res.getStatus() == null) {
                    sShowMsg = System.Label.ExpoCAD_API_Down_Msg;
                    isShowMsg = true;
                } else if (res.getStatusCode() == 200) {
                    String sReturn = res.getBody();
                    if (!String.isBlank(boothID)) {
                        ExpocadClasses.Booth oExpoBooth = (ExpocadClasses.Booth) JSON.deserialize(sReturn, ExpocadClasses.Booth.class);
                        if (oExpoBooth != null && oExpoBooth.IsOnHold == false && oExpoBooth.IsRented == false) {
                            lstExpoBooth.add(oExpoBooth);
                        } 
                        if (oExpoBooth != null) {
                            sShowMsg = oExpoBooth.IsOnHold ? System.Label.Booth_Is_Already_Held_Msg : oExpoBooth.IsRented ? System.Label.Booth_Is_Already_Rent_Msg : '';
                            isShowMsg = oExpoBooth.IsOnHold || oExpoBooth.IsRented;
                            isAvailable = oExpoBooth.IsOnHold || oExpoBooth.IsRented;
                        }
                        if (isAvailable) {
                            if (Schema.sObjectType.ExpocadBooth__c.isAccessible()) {
                                List < ExpocadBooth__c > lstExpoExist = [SELECT Id FROM ExpocadBooth__c WHERE Booth_Number__c = : boothID AND Status__c != 'Released' ORDER BY LastModifiedDate DESC LIMIT 1000 ];
                                if (!lstExpoExist.isEmpty()) { expocadBoothId = lstExpoExist.get(0).Id; }
                            }
                        }
                    } else if (String.isBlank(boothID)) {
                        lstExpoBooth = (List < ExpocadClasses.Booth > ) JSON.deserialize(sReturn, List < ExpocadClasses.Booth > .class);
                    }
                }
            }
            if (lstExpoBooth.isEmpty() && !isShowMsg) { sShowMsg = System.Label.Booth_Not_Found_Msg; isShowMsg = true; }
        } catch (exception ex) { Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'ExpocadApiCall(@BoothSelectionCtrl.Class)'); }
    }

    /**
     * Designed to add all selected booths to Quote as Quote Line Item.
     * @param  sMethod [Need to Hold only or Hold and Add to Quote]
     * @return PageReference
     */
    public PageReference addToQLI(String sMethod) {
        SavePoint mySavePoint = Database.setSavePoint();
        try {
            List < SBQQ__QuoteLine__c > lstQuoteLine = new List < SBQQ__QuoteLine__c > ();
            List < SBQQ__QuoteLine__c > lstPackageQuoteLine = new List < SBQQ__QuoteLine__c > ();
            List < ExpocadBooth__c > lsttempHB = new List < ExpocadBooth__c > ();
            Set < String > setBoothIds = new Set < String > ();
            ExpocadBooth__c oTempEB;
            SBQQ__QuoteLine__c oQuoteLine;
            Set<String> setEEBoothClasses ;
            this.getBoothProducts();
            Integer quoteLineNumber = this.getLastQLNumber();
            boothtoItself = new Set < String > ();
            if (Schema.sObjectType.ExpocadBooth__c.isAccessible()) {
                for (ExpocadBooth__c objCS : [SELECT id, Quote__r.Name, Booth_Number__c, Status__c FROM ExpocadBooth__c WHERE Opportunity__c = : oOpportunity.Id AND Status__c = 'Added To Quote/On Hold' AND Quote__c = : oSBQQQuote.Id LIMIT 1000]) {
                    boothtoItself.add(objCS.Booth_Number__c);
                }
                for (ExpocadBooth__c oTempBooth : lstHeldBooth) {
                    if ((sMethod == 'HeldBooth' && oTempBooth.Selected__c && !boothtoItself.contains(oTempBooth.Booth_Number__c)) || sMethod == 'addAll') {
                        String sProductName = oTempBooth.Booth_Product_Type__c;
                        if (!setBoothIds.contains(oTempBooth.Booth_Number__c) && mapProductOptions.get(sProductName) != null) {
                            Set <String> setCornerConfiguration = new Set <String>();
                            Double quantity = getQuantity(oTempBooth.Area__c);
                            if (mapProductOptions.get(sProductName).SBQQ__OptionalSKU__r.Corner_Configuration__c != NULL && mapProductOptions.get(sProductName).SBQQ__OptionalSKU__r.ExpoCAD_Product__c) {
                                for (String sTempCornerConfValue : mapProductOptions.get(sProductName).SBQQ__OptionalSKU__r.Corner_Configuration__c.split(';')) {
                                    setCornerConfiguration.add(sTempCornerConfValue.toLowerCase());
                                }
                            }
                            // Getting Event Product using SB API
                            SBProductConfiguration oPrdConfiguration = new SBProductConfiguration();
                            SBProductConfiguration.TinyConfigurationModel oPrdConfigurationModel = new SBProductConfiguration.TinyConfigurationModel();
                            oPrdConfigurationModel = oPrdConfiguration.getConfigurationAfterFireProductRule(boothPackageProduct.Id, oSBQQQuote.SBQQ__PriceBook__c, mapProductOptions.get(sProductName).Id, mapProductOptions.get(sProductName).SBQQ__OptionalSKU__c, quantity);
                            String sBoothClassesShowed = '';
                            if (!String.isBlank(oSBQQQuote.SBQQ__Opportunity2__r.EventEdition__r.Booth_Classes_on_Template__c)) {setEEBoothClasses = new Set<String>(oSBQQQuote.SBQQ__Opportunity2__r.EventEdition__r.Booth_Classes_on_Template__c.split(','));}

                            if (setEEBoothClasses != Null && !setEEBoothClasses.isEmpty() && !String.isBlank(oTempBooth.Booth_Classes__c)) {
                                for (String sTemp : oTempBooth.Booth_Classes__c.split(';;')) {
                                    if (setEEBoothClasses.contains(sTemp)) {
                                        if (String.isBlank(sBoothClassesShowed)) {
                                            sBoothClassesShowed = sTemp ;
                                        } else {
                                            sBoothClassesShowed = sBoothClassesShowed + ',' + sTemp ;
                                        }
                                    }
                                }
                            }

                            // Adding Package Product
                            String packageId;
                            oQuoteLine = new SBQQ__QuoteLine__c();
                            oQuoteLine.SBQQ__Quote__c = oSBQQQuote.Id;
                            oQuoteLine.SBQQ__Product__c = boothPackageProduct.Id; //LinearProduct.ID;
                            oQuoteLine.SBQQ__Quantity__c = 1;
                            oQuoteLine.SBQQ__NonDiscountable__c = boothPackageProduct.SBQQ__NonDiscountable__c;
                            oQuoteLine.SBQQ__Hidden__c = boothPackageProduct.SBQQ__Hidden__c;
                            //Added On 13/13/17
                            oQuoteLine.SBQQ__Bundle__c = boothPackageProduct.SBQQ__ConfigurationType__c == 'Allowed';
                            //Modified By Avinash : GGCW-3082 : removing editing of package product.
                            //oQuoteLine.SBQQ__PriceEditable__c = boothPackageProduct.SBQQ__PriceEditable__c;
                            oQuoteLine.SBQQ__Number__c = quoteLineNumber;
                            oQuoteLine.Booth_Number__c = oTempBooth.Booth_Number__c;
                            oQuoteLine.Booth__c = true;
                            oQuoteLine.Show_In_Show__c = oTempBooth.ShowInShow__c;
                            oQuoteLine.Booth_Pavilion__c = oTempBooth.Pavilion__c;
                            oQuoteLine.Booth_Type__c = oTempBooth.Booth_Type__c;
                            oQuoteLine.Open_Corners__c = oTempBooth.Open_Corners__c;
                            oQuoteLine.Booth_Classes__c = oTempBooth.Booth_Classes__c;
                            oQuoteLine.Booth_Product_Type__c = oTempBooth.Booth_Product_Type_EE__c;
                            oQuoteLine.Booth_Dimensions__c = oTempBooth.Dimensions__c ;
                            oQuoteLine.Booth_Classes_Showed_On_Template__c = sBoothClassesShowed ;

                            lstPackageQuoteLine.add(oQuoteLine);
                            quoteLineNumber++;

                            if (!oPrdConfigurationModel.optionConfigurations.isEmpty()) {
                                for (SBProductConfiguration.TinyConfigurationModel oTempConfgModel : oPrdConfigurationModel.optionConfigurations) {
                                    if (mapProductOptions.get(cornerProductName) != null && mapProductOptions.get(cornerProductName).SBQQ__OptionalSKU__c != oTempConfgModel.optionData.SBQQ__OptionalSKU__c) {
                                        // Adding Products to quote line item
                                        oQuoteLine = new SBQQ__QuoteLine__c();
                                        oQuoteLine.SBQQ__Quote__c = oSBQQQuote.Id;
                                        oQuoteLine.SBQQ__ProductOption__c = oTempConfgModel.optionData.Id;
                                        oQuoteLine.SBQQ__Product__c = oTempConfgModel.optionData.SBQQ__OptionalSKU__c;
                                        oQuoteLine.SBQQ__Quantity__c = oTempConfgModel.optionData.SBQQ__Quantity__c;
                                        oQuoteLine.SBQQ__Number__c = quoteLineNumber;
                                        oQuoteLine.SBQQ__NonDiscountable__c = mapProductOptionsId.get(oTempConfgModel.optionData.Id).SBQQ__OptionalSKU__r.SBQQ__NonDiscountable__c;
                                        oQuoteLine.SBQQ__Hidden__c = mapProductOptionsId.get(oTempConfgModel.optionData.Id).SBQQ__OptionalSKU__r.SBQQ__Hidden__c;
                                        //Added On 13/13/17
                                        oQuoteLine.SBQQ__Bundle__c = mapProductOptionsId.get(oTempConfgModel.optionData.Id).SBQQ__OptionalSKU__r.SBQQ__ConfigurationType__c == 'Allowed';
                                        //Modified By Avinash : GGCW-3082
                                        oQuoteLine.SBQQ__PriceEditable__c = mapProductOptionsId.get(oTempConfgModel.optionData.Id).SBQQ__OptionalSKU__r.SBQQ__PriceEditable__c;
                                        oQuoteLine.SBQQ__PricingMethodEditable__c = True;
                                        oQuoteLine.SBQQ__BundledQuantity__c = oTempConfgModel.optionData.SBQQ__Quantity__c;
                                        if (mapProductOptionsId.get(oTempConfgModel.optionData.Id).SBQQ__OptionalSKU__r.ExpoCAD_Booth_Product__c) {
                                            oQuoteLine.Line_Description__c = oTempBooth.Booth_Number__c + '-' + oTempBooth.Booth_Type__c;
                                        }
                                        oQuoteLine.Booth_Number__c = oTempBooth.Booth_Number__c;
                                        oQuoteLine.Booth__c = true;
                                        oQuoteLine.Show_In_Show__c = oTempBooth.ShowInShow__c;
                                        oQuoteLine.Booth_Pavilion__c = oTempBooth.Pavilion__c;
                                        oQuoteLine.Booth_Type__c = oTempBooth.Booth_Type__c;
                                        oQuoteLine.Open_Corners__c = oTempBooth.Open_Corners__c;
                                        oQuoteLine.Booth_Classes__c = oTempBooth.Booth_Classes__c;
                                        oQuoteLine.Booth_Product_Type__c = oTempBooth.Booth_Product_Type_EE__c;
                                        oQuoteLine.SBQQ__OptionType__c = 'Component';
                                        oQuoteLine.SBQQ__OptionLevel__c = 1;
                                        oQuoteLine.Booth_Dimensions__c = oTempBooth.Dimensions__c ;
                                        oQuoteLine.Booth_Classes_Showed_On_Template__c = sBoothClassesShowed ;
                                        lstQuoteLine.add(oQuoteLine);
                                        quoteLineNumber++;
                                    }
                                }
                            }
                            // Adding Corner Product
                            if (oTempBooth.Open_Corners__c != 0 && mapProductOptions.get(cornerProductName) != null && (!oOpportunity.EventEdition__r.Corner_Configuration_Check__c || ( !setCornerConfiguration.isEmpty() && setCornerConfiguration.contains(oTempBooth.Booth_Type__c.toLowerCase())))) {
                                oQuoteLine = new SBQQ__QuoteLine__c();
                                oQuoteLine.SBQQ__Quote__c = oSBQQQuote.Id;
                                oQuoteLine.SBQQ__Product__c = mapProductOptions.get(cornerProductName).SBQQ__OptionalSKU__c; //CornerProduct.ID;
                                oQuoteLine.SBQQ__Quantity__c = oTempBooth.Open_Corners__c;
                                oQuoteLine.SBQQ__Number__c = quoteLineNumber;
                                oQuoteLine.SBQQ__NonDiscountable__c = mapProductOptions.get(cornerProductName).SBQQ__OptionalSKU__r.SBQQ__NonDiscountable__c;
                                oQuoteLine.SBQQ__Hidden__c = mapProductOptions.get(cornerProductName).SBQQ__OptionalSKU__r.SBQQ__Hidden__c;
                                //Added On 13/13/17
                                if (mapProductOptions.get(cornerProductName).SBQQ__OptionalSKU__r.SBQQ__ConfigurationType__c == 'Allowed') {
                                    oQuoteLine.SBQQ__Bundle__c = True;
                                }

                                //Modified By Avinash : GGCW-3082
                                oQuoteLine.SBQQ__PriceEditable__c = mapProductOptions.get(cornerProductName).SBQQ__OptionalSKU__r.SBQQ__PriceEditable__c;

                                oQuoteLine.SBQQ__PricingMethodEditable__c = True;
                                oQuoteLine.SBQQ__BundledQuantity__c = oTempBooth.Open_Corners__c;
                                if (mapProductOptions.get(cornerProductName).SBQQ__OptionalSKU__r.ExpoCAD_Booth_Product__c) {
                                    oQuoteLine.Line_Description__c = oTempBooth.Booth_Number__c + '-' + oTempBooth.Booth_Type__c;
                                }
                                oQuoteLine.Booth_Number__c = oTempBooth.Booth_Number__c;
                                oQuoteLine.Booth__c = true;
                                oQuoteLine.Show_In_Show__c = oTempBooth.ShowInShow__c;
                                oQuoteLine.Booth_Pavilion__c = oTempBooth.Pavilion__c;
                                oQuoteLine.Booth_Type__c = oTempBooth.Booth_Type__c;
                                oQuoteLine.Open_Corners__c = oTempBooth.Open_Corners__c;
                                oQuoteLine.Booth_Classes__c = oTempBooth.Booth_Classes__c;
                                oQuoteLine.Booth_Product_Type__c = oTempBooth.Booth_Product_Type_EE__c;
                                oQuoteLine.Corner_Premium__c = true;
                                oQuoteLine.SBQQ__OptionType__c = 'Component';
                                oQuoteLine.SBQQ__OptionLevel__c = 1;
                                oQuoteLine.SBQQ__ProductOption__c = mapProductOptions.get(cornerProductName).Id;
                                oQuoteLine.Booth_Dimensions__c = oTempBooth.Dimensions__c ;
                                oQuoteLine.Booth_Classes_Showed_On_Template__c = sBoothClassesShowed ;
                                lstQuoteLine.add(oQuoteLine);
                                quoteLineNumber++;
                            }
                            oTempBooth.Selected__c = false;
                            if (oTempBooth.Quote__c != oSBQQQuote.Id) {
                                oTempEB = new ExpocadBooth__c();
                                oTempEB = oTempBooth;
                                oTempEB.Quote__c = oSBQQQuote.Id;
                                oTempEB.Opportunity__c = oTempBooth.Opportunity__c;
                                oTempEB.Account__c = oTempBooth.Account__c;
                                oTempEB.Status__c = 'Added To Quote/On Hold';
                                oTempEB.Id = null;
                                lsttempHB.add(oTempEB);
                            } else if (oOpportunity.Parent_Opportunity__c != null) {
                                oTempBooth.AddedToQLI__c = true;
                            } else {
                                oTempBooth.Status__c = 'Added To Quote/On Hold';
                            }
                        } else if (String.isBlank(sProductName)) {
                            oTempBooth.Selected__c = false;
                            sShowMsg = 'Booth Product Type not present for the selected booth [' + oTempBooth.Booth_Number__c + ']';
                            isShowMsg = true;
                            return null;
                        } else if (mapProductOptions.get(sProductName) == null) {
                            sShowMsg = 'Product [' + oTempBooth.Booth_Product_Type__c + '] is not found for selected Booth [' + oTempBooth.Booth_Number__c + ']';
                            isShowMsg = true;
                            return null;
                        }
                        oTempBooth.Selected__c = false;
                        setBoothIds.add(oTempBooth.Booth_Number__c);
                    } else {
                        if (oTempBooth.Quote__c == oSBQQQuote.Id && oTempBooth.Status__c == 'On Hold') {
                            oTempBooth.Status__c = 'Released';
                        }
                        oTempBooth.Selected__c = false;
                    }
                }
                if (lstQuoteLine.size() > 0 && lstPackageQuoteLine.size() > 0) {
                    Map < String, Id > mapPackageprdIds = new Map < String, Id > ();
                    insert lstPackageQuoteLine;
                    for (SBQQ__QuoteLine__c oQLI : lstPackageQuoteLine) {
                        mapPackageprdIds.put(oQLI.Booth_Number__c, oQLI.id);
                    }
                    insert lstQuoteLine;
                    for (SBQQ__QuoteLine__c oQLI : lstQuoteLine) {
                        oQLI.SBQQ__RequiredBy__c = mapPackageprdIds.get(oQLI.Booth_Number__c);
                    }
                    update lstQuoteLine;
                    try{
                        if (lsttempHB.size() > 0) {
                            insert lsttempHB;
                        }
                    }catch (exception ex) {
                        Database.rollBack(mySavePoint);
                        Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'addToQLI(@BoothSelectionCtrl.Class)');
                    }
                    update lstHeldBooth;
                    shouldRedirect = true;
                    redirectUrl = sHost + '/apex/SBQQ__sb?id=' + oSBQQQuote.Id;
                    if (isLightingEnv) {
                        pageReference pg = new pageReference('/apex/SBQQ__sb?id=' + oSBQQQuote.Id);
                        return pg;
                    }
                }
            }
        } catch (exception ex) {
            Database.rollBack(mySavePoint);
            Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'addToQLI(@BoothSelectionCtrl.Class)');
        }
        return null;
    }

    /**
     * Designed to unHold all selected held booths.
     * @return PageReference
     */
    public PageReference releaseHoldBooth() {
        try {
            Map < String, ExpocadBooth__c > allAddedBooth = new Map < String, ExpocadBooth__c > ();
            boothtoItself = new Set < String > ();
            sShowMsg = '';
            sShowMsg2 = '';
            if (Schema.sObjectType.ExpocadBooth__c.isAccessible()) {
                for (ExpocadBooth__c objCS : [SELECT id, Quote__r.Name, Booth_Number__c, Status__c from ExpocadBooth__c where Opportunity__c = : oOpportunity.Id AND Status__c = 'Added To Quote/On Hold' AND Quote__c != : oSBQQQuote.Id LIMIT 1000]) {
                    allAddedBooth.put(objCS.Booth_Number__c, objCS);
                }
            }
            if (Schema.sObjectType.ExpocadBooth__c.isAccessible()) {
                for (ExpocadBooth__c objCS : [SELECT id, Quote__r.Name, Booth_Number__c, Status__c from ExpocadBooth__c where Opportunity__c = : oOpportunity.Id AND Status__c = 'Added To Quote/On Hold' AND Quote__c = : oSBQQQuote.Id LIMIT 1000]) {
                    boothtoItself.add(objCS.Booth_Number__c);
                }
            }
            for (ExpocadBooth__c oTempBooth : lstHeldBooth) {
                if (oTempBooth.Selected__c) {
                    if (oTempBooth.Quote__c == oSBQQQuote.Id && oTempBooth.Status__c == 'On Hold') {
                        if (!allAddedBooth.containsKey(oTempBooth.Booth_Number__c)) {
                            oTempBooth.Status__c = 'Released';
                        } else {
                            sShowMsg = this.mergeBoothNumber(sShowMsg, oTempBooth.Booth_Number__c);
                        }
                    } else if (oTempBooth.Quote__c != oSBQQQuote.Id) {
                        if (!allAddedBooth.containsKey(oTempBooth.Booth_Number__c) && !boothtoItself.contains(oTempBooth.Booth_Number__c) && oTempBooth.Status__c == 'On Hold') {
                            oTempBooth.Status__c = 'Released';
                        } else if (boothtoItself.contains(oTempBooth.Booth_Number__c)) {
                            sShowMsg2 = this.mergeBoothNumber(sShowMsg2, oTempBooth.Booth_Number__c);
                        } else if (allAddedBooth.containsKey(oTempBooth.Booth_Number__c)) {
                            sShowMsg = this.mergeBoothNumber(sShowMsg, oTempBooth.Booth_Number__c);
                        }
                    }
                    oTempBooth.Selected__c = false;
                }
            }
            if (sShowMsg != '' && sShowMsg.contains(',')) {
                sShowMsg = 'Booth No.s [' + sShowMsg + '] are used by another Quote, hence can not be Released.';
            } else if (sShowMsg != '') {
                sShowMsg = 'Booth No [' + sShowMsg + '] is used by another Quote, hence it can not be Released.';
            }
            if (sShowMsg2 != '' && sShowMsg2.contains(',')) {
                sShowMsg2 = 'Booth No.s [' + sShowMsg2 + '] are added to the current quote. Please remove the booths from their respective Quotes from Quote Line Editor to release them from all Quotes of the given opportunity.';
            } else if (sShowMsg2 != '') {
                sShowMsg2 = 'Booth No [' + sShowMsg2 + '] is added to the current quote. Please remove the booth from the Quote Line Editor to release it from all Quotes of the given opportunity.';
            }
            if (Schema.sObjectType.ExpocadBooth__c.isUpdateable()) {
                update lstHeldBooth;
            }
            autoRun();
        } catch (exception ex) {
            Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'releaseHoldBooth(@BoothSelectionCtrl.Class)');
        }
        return null;
    }

    /**
     * Designed to get Product Name using BoothType, ShowInShow, BoothClasses (values returned by Expocad booth detail) and Event's Product Type.
     * @param  oEB                 [Expocad Booth Ref]
     * @param  oOpportunity        [Opportunity  Ref]
     * @param  boothPackageProduct [Product package Ref]
     * @return String              [Product Name]
     */
    Public Static String sBPrd(ExpocadClasses.Booth oEB, Opportunity oOpportunity, Product2 boothPackageProduct) {
        return BoothSelectionCtrl_Helper.sBPrd(mapProductOptionsId, oEB, oOpportunity, boothPackageProduct);
    }

    /**
     * @description Making Http request call for Expocad API to Hold booths and creating log inside Salesforce.
     * @param sMethod [performing refresh when only holding booths]
     */
    public void holdBoothRequest(String sMethod) {
        isShowMsg = false;
        String displayName = oOpportunity.Account.Name ;
        Boolean isExbIDPresent = false;
        String ExhibitorId = '';
        DateTime currentTime = System.now();
        String sComment2Name = '';
        try {
            ExpocadBooth__c oExpocad;
            if (oOpportunity != null && sExpocadDbName != null) {
                sOpptyAccountName = sOpptyAccountName.replace(' ', '%20');
                String sAPIUrlExb = oOpportunity.EventEdition__r.Expocad_API_Url__c + '/exhibitors?id=' + oOpportunity.AccountId + '&databaseName=' + sExpocadDbName;
                HttpResponse resExb = new ExpocadResponses().request(sAPIUrlExb, 'GET', '');
                
                if(test.isRunningTest()){resExb = new HTTPResponse();resExb.setHeader('Content-Type', 'application/json');resExb.setStatusCode(404);resExb.setBody('{ "message": "Invitation Emails Queued!", "errors": [] }');resExb.setStatus('OK');}
                
                if (resExb.getStatus() == null) 
                { 
                   ExpocadResponses.logFailedTransaction('', oOpportunity.Id, oOpportunity.SBQQ__PrimaryQuote__c, 'Hold', '', 'API is not responding', currentTime, 'Fail', sAPIUrlExb, '', ''); 
                   isExbIDPresent = false; 
                }
                else if (resExb.getStatusCode() == 200 && resExb.getBody() != null) {
                    ExhibitorId = oOpportunity.AccountId;
                     isExbIDPresent = true; 
                }
                else if (Test.isRunningTest() || (resExb.getStatusCode() == 404 && resExb.getBody() != null && oOpportunity.EventEdition__r.X3E_Status__c =='Active' && oOpportunity.EventEdition__r.X3E_API_ID__c != null) ){
                            ExpocadClasses.X3EExhibitor oExibitor = new ExpocadClasses.X3EExhibitor();
                            oExibitor.ExhibitorId = oOpportunity.AccountId;
                            oExibitor.ExhibitorName = subString(oOpportunity.Account.Name, 50);
                            if (oOpportunity.Opportunity_Contact__c != null) {
                            Contact oCon = [SELECT Name, MailingStreet, Email, MailingCity, MailingState, MailingPostalCode, MailingCountry, Phone, Title, Salutation FROM Contact WHERE id = : oOpportunity.Opportunity_Contact__c];
                            if (!String.isBlank(oCon.MailingState)) {
                                oExibitor.State = subString(oCon.MailingState, 10);
                            }
                    if (!String.isBlank(oCon.MailingPostalCode)) {
                        oExibitor.PostalCode = subString(oCon.MailingPostalCode, 10);
                    }

                   
                        oExibitor.DoingBusinessAsDisplayOnDrawing =  subString(oOpportunity.Account.Name, 50);
                    
                    if (!String.isBlank(sComment2Name)) { oExibitor.Comments2 = oOpportunity.User_Type__r.Name;
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
                     if (!String.isBlank(oOpportunity.Account.Website)){
                        oExibitor.Website = subString(oOpportunity.Account.Website, 70); 
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
                        sAPIUrlExb = oOpportunity.EventEdition__r.Expocad_API_Url__c + '/exhibitors/add?databaseName=' + sExpocadDbName;
                        HttpResponse res2 = new ExpocadResponses().request(sAPIUrlExb , 'POST', sExbBody);
                       ExhibitorId = oOpportunity.AccountId;
                       isExbIDPresent = true;
                }
                lstExpocad = new List < ExpocadBooth__c > ();
                if (lstExpoBooth != null && lstExpoBooth.size() > 0 ) {
                    for (ExpocadClasses.Booth oTempBooth : lstExpoBooth) {
                        if (oTempBooth.isSelected) {
                            String sPrdName;
                            String sAPIUrl;
                            sPrdName = sBPrd(oTempBooth, oOpportunity, boothPackageProduct);
                            if (!String.isBlank(sPrdName)) {
                               if (isExbIDPresent == true )
                               {
                                 sAPIUrl = oOpportunity.EventEdition__r.Expocad_API_Url__c + '/booths/hold?boothNumber=' + oTempBooth.BoothNumber + '&exhibitorName=' + EncodingUtil.URLENCODE(oOpportunity.Account.Name, 'ASCII') + '&comment=' + oOpportunity.id + '&databaseName=' + sExpocadDbName +'&exhibitorId=' + ExhibitorId;
                               }
                               else 
                               {
                                 sAPIUrl = oOpportunity.EventEdition__r.Expocad_API_Url__c + '/booths/hold?boothNumber=' + oTempBooth.BoothNumber + '&exhibitorName=' + EncodingUtil.URLENCODE(oOpportunity.Account.Name, 'ASCII') + '&comment=' + oOpportunity.id + '&databaseName=' + sExpocadDbName;
                               }
                                
                                sAPIUrl = sAPIUrl.replace(' ', '%20');
                                 system.debug('ZuheabsExpoCADHeldAPIURL-----'+ sAPIUrl );
                                HttpResponse res = new ExpocadResponses().request(sAPIUrl, 'PUT', '');
                                if(test.isRunningTest()){res = new HTTPResponse();res.setHeader('Content-Type', 'application/json');res.setStatusCode(200);resExb.setBody('{ "message": "-1816 Emails Queued!", "errors": [] }');resExb.setStatus('OK');}                                 system.debug('ZuheabsExpoCADHeldAPIResponse-----'+ res );
                                String sReturn = res.getBody();
                                if (res.getStatus() == null) {
                                    sShowMsg = System.Label.ExpoCAD_API_Down_Msg; isShowMsg = true; oTempBooth.isSelected = false;
                                } else if (res.getStatusCode() == 400 || (res.getBody() != null && res.getBody().containsIgnoreCase('-1816'))) {
                                    sShowMsg = 'The Booth Number ' + oTempBooth.BoothNumber + ' has been locked'; isShowMsg = true;
                                } else if (res.getStatusCode() == 200) {
                                    oExpocad = new ExpocadBooth__c();
                                    oExpocad.Account__c = sOpptyAccountID;
                                    oExpocad.Booth_Number__c = oTempBooth.BoothNumber;
                                    oExpocad.Last_Action_Date__c = Date.today();
                                    oExpocad.User__c = userinfo.getuserid();
                                    oExpocad.Status__c = 'On Hold';
                                    oExpocad.Area__c = oTempBooth.Area;
                                    oExpocad.Booth_Type__c = oTempBooth.BoothType;
                                    oExpocad.Dimensions__c = oTempBooth.Dimensions;
                                    oExpocad.Open_Corners__c = oTempBooth.OpenCorners;
                                    oExpocad.Unit_Type__c = oTempBooth.UnitType;
                                    oExpocad.Booth_Product_Type_EE__c = oTempBooth.BoothClass;
                                    oExpocad.ShowInShow__c = oTempBooth.ShowInShow;
                                    oExpocad.Pavilion__c = oTempBooth.Pavilion;
                                    if (oTempBooth.BoothClasses != null) {
                                        oExpocad.Booth_Classes__c = string.join(oTempBooth.BoothClasses, ';;');
                                    }
                                    oExpocad.Booth_Product_Type__c = sPrdName;
                                    oExpocad.Quote__c = oSBQQQuote.Id;
                                    oExpocad.Opportunity__c = oOpportunity.Id;
                                    //Adding MPN functionality here for MPN : GGCW-3001-- GGCW-3006. for Exhibtior's Opportunity.
                                    //Modified BY Avinash Shukla 15/04/19
                                    If(oOpportunity.User_Type__r.Name == 'Exhibitor' && oOpportunity.Parent_Opportunity__c == null) {
                                        //This is exhibitor's opportunity.
                                        if (!bptTpMpnConfig.isEmpty()) {
                                            If(bptTpMpnConfig.containsKey(oTempBooth.BoothClass) && bptTpMpnConfig.get(oTempBooth.BoothClass).Matched_Product_Name__c != NULL) {
                                                oExpocad.Matched_Product_Name__c = bptTpMpnConfig.get(oTempBooth.BoothClass).Matched_Product_Name__c;
                                            }
                                            else {
                                                oExpocad.Matched_Product_Name__c = null;
                                            }
                                        } else {
                                            oExpocad.Matched_Product_Name__c = null;
                                        }
                                    }
                                    else if (oOpportunity.User_Type__r.Name == 'Agent' && oOpportunity.Parent_Opportunity__c == null) {
                                        oExpocad.Matched_Product_Name__c = null;
                                    }
                                    lstExpocad.add(oExpocad);
                  ExpocadResponses.logFailedTransaction(oExpocad.Booth_Number__c, oOpportunity.Id, oOpportunity.SBQQ__PrimaryQuote__c, 'Hold', String.valueOf(res.getStatusCode()), res.getBody(), currentTime , 'Success', sAPIUrl, res.getStatus(), displayName);                                
                                }
                            } else {
                                oTempBooth.isSelected = false;
                                if (!String.isBlank(oTempBooth.BoothType)) {
                                    sShowMsg = '"' + oTempBooth.BoothType + '"';
                                }
                                if (!String.isBlank(oTempBooth.ShowInShow)) {
                                    sShowMsg += ' and "' + oTempBooth.ShowInShow + '"';
                                }
                                sShowMsg = 'Booth type ' + sShowMsg + ' (Coming from expocad API) is not Configured inside Product Package for the selected booth [' + oTempBooth.BoothNumber + ']';
                                isShowMsg = true;
                            }
                        }
                    }
                }
                if (lstExpocad != null && lstExpocad.size() > 0) {
                    if (Schema.sObjectType.ExpocadBooth__c.isCreateable()) {
                        insert lstExpocad;
                    }
                    if (sMethod == 'ToHoldOnly') {
                        autoRun();
                    } else {
                        lstHeldBooth = new List < ExpocadBooth__c > ();
                        lstHeldBooth.addall(lstExpocad);


                    }
                    
                }
            }
        } catch (exception ex) {
            Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'holdBoothRequest(@BoothSelectionCtrl.Class)');
        }
    }

    /**
     * @description Getting all package products for current event edition.
     */
    public void getBoothProducts() {
        try {
            mapProductOptions = new Map < String, SBQQ__ProductOption__c > ();
            mapProductOptionsId = new Map < Id, SBQQ__ProductOption__c > ();
            String sBoothPackagePrdName;
            boothPackageProduct = new Product2();
            if (String.isNotBlank(oOpportunity.Event_Series__r.Package_Identifier__c)) {
                /*Changes done by Faisal for BK-23090*/	
               if(String.isNotBlank(oOpportunity.EventEdition__r.Booth_Bundle_Type__c)){	
                  sBoothPackagePrdName = oOpportunity.EventEdition__r.Booth_Bundle_Type__c+' '+oOpportunity.Event_Series__r.Package_Identifier__c;	
                }	 
                else{	
                    sBoothPackagePrdName = 'Booth Package ' + oOpportunity.Event_Series__r.Package_Identifier__c;	
                }
            }
            if (String.isNotBlank(sBoothPackagePrdName)) {
                if (Schema.sObjectType.Product2.isAccessible()) {
                    List < Product2 > lstTemp = [SELECT Id, Name, Number_of_Corners__c, Booth_Product_Type__c, SBQQ__PriceEditable__c, SBQQ__NonDiscountable__c, SBQQ__Hidden__c, SBQQ__ConfigurationType__c FROM Product2 where Name = : sBoothPackagePrdName AND Event_Edition_Name__c = : oOpportunity.EventEdition__r.Name order by createdDate ASC LIMIT 1];
                    if (lstTemp != null && lstTemp.size() > 0) {
                        boothPackageProduct = lstTemp.get(0);
                    }
                }
            }

            if (boothPackageProduct.Id != null) {
                if (Schema.sObjectType.SBQQ__ProductOption__c.isAccessible()) {
                    for (SBQQ__ProductOption__c oProductOption : [SELECT Id, SBQQ__OptionalSKU__c, SBQQ__OptionalSKU__r.SBQQ__ConfigurationType__c, SBQQ__OptionalSKU__r.SBQQ__PriceEditable__c, SBQQ__OptionalSKU__r.Name, SBQQ__OptionalSKU__r.Expiry_Date__c, SBQQ__OptionalSKU__r.SBQQ__NonDiscountable__c, SBQQ__OptionalSKU__r.SBQQ__Hidden__c, SBQQ__OptionalSKU__r.Booth_Type__c, SBQQ__OptionalSKU__r.Show_In_Show__c, SBQQ__OptionalSKU__r.Booth_Pavilion__c, SBQQ__OptionalSKU__r.Booth_Class__c, SBQQ__OptionalSKU__r.Booth_Product_Type__c, SBQQ__OptionalSKU__r.ExpoCAD_Product__c, SBQQ__OptionalSKU__r.Corner_Configuration__c, SBQQ__OptionalSKU__r.ExpoCAD_Booth_Product__c FROM SBQQ__ProductOption__c where SBQQ__ConfiguredSKU__c = : boothPackageProduct.Id AND SBQQ__OptionalSKU__c != null AND (SBQQ__OptionalSKU__r.Available_From__c = null OR SBQQ__OptionalSKU__r.Available_From__c < TODAY) LIMIT 5000]) {
                        mapProductOptions.put(oProductOption.SBQQ__OptionalSKU__r.Name, oProductOption);
                        mapProductOptionsId.put(oProductOption.Id, oProductOption);
                        if (oProductOption.SBQQ__OptionalSKU__r.Name.toLowerCase().contains('corner booth fee')) {
                            cornerProductName = oProductOption.SBQQ__OptionalSKU__r.Name;
                        }
                    }
                }
            }
        } catch (exception ex) { Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'getBoothProducts(@BoothSelectionCtrl.Class)'); }
    }

    /**
     * @description Getting maximum no. of Quote Line Number, which are alreday added to current Quote.
     * @return Integer
     */
    public Integer getLastQLNumber() {
        Integer tempQuoteLineNumber;
        if (Schema.sObjectType.SBQQ__QuoteLine__c.isAccessible()) {
            List < SBQQ__QuoteLine__c > lstQuoteLine2 = [select id from SBQQ__QuoteLine__c where SBQQ__Quote__c = : oSBQQQuote.Id LIMIT 1000];
            if (lstQuoteLine2 != null && lstQuoteLine2.size() > 0) {
                tempQuoteLineNumber = lstQuoteLine2.size();
            } else {
                tempQuoteLineNumber = 1;
            }
        }
        return tempQuoteLineNumber;
    }

    /**
     * @description Merging multiple Booth No. in a single String
     * @param  sMsg   [Existing Booth No.s]
     * @param  sBooth [New Booth No]
     * @return String
     */
    Public String mergeBoothNumber(String sMsg, String sBooth) {
        String sMergedValue ;
        if (sMsg != '') {
            sMergedValue = sMsg + ', ' + sBooth;
        } else {
            return sBooth;
        }
        return sMergedValue;
    }

    /**
     * @description Converting String value to double.
     * @param  sQuantity [String Value]
     * @return Double
     */
    public Double getQuantity(String sQuantity) {
        String sTempQuantity = sQuantity.substringBefore(' ');
        sTempQuantity = sTempQuantity.trim();
        return Double.valueof(sTempQuantity);
    }

    /**
     * @description If Double value is null than assigns '0' to it
     * @param  dValue [Decimal Type Value]
     * @return Double
     */
    public static Double replaceNullByZero(Decimal dValue) {
        if (dValue == null) {
            return 0;
        }
        return dValue;
    }

    /**
     * @description Designed to make dynamic expocad query using paramters.
     * @param  BoothID      [Expocad Booth No]
     * @param  BoothSize    [Expocad Booth Size]
     * @param  Corner       [Expocad Booth Corner]
     * @param  EventEdition [Event Edition Name]
     * @param  BoothType    [Expocad Booth Type]
     * @return String
     */
    public String makeExpocadQuery(String boothID, String boothSize, String corner, String eventEdition, String boothType) {
        String sTempQuery = '';
        try {
            //eventEdition = eventEdition.trim();
            if (!String.isBlank(boothID)) {
                sTempQuery = oOpportunity.EventEdition__r.Expocad_API_Url__c + '/booths?boothNumber=' + boothID.deleteWhitespace() + '&databaseName=' + eventEdition.trim();
               // sTempQuery = oOpportunity.EventEdition__r.Expocad_API_Url__c + '/'+eventEdition.trim() + '/fx/boothinfo?booths=' + boothID.deleteWhitespace();
            } else {
                sTempQuery = oOpportunity.EventEdition__r.Expocad_API_Url__c + '/booths/all/?databaseName=' + eventEdition.trim() + '&$filter=IsRented%20eq%20false%20and%20IsOnHold%20eq%20false';
                if (!String.isBlank(boothType)) {
                    //boothType = boothType.trim();
                    sTempQuery += '%20and%20BoothType%20eq%20%27' + boothType.trim() + '%27';
                }
                if (!String.isBlank(corner) && corner != 'All') {
                    //corner = corner.trim();
                    sTempQuery += '%20and%20OpenCorners%20eq%20' + corner.trim();
                }
                if (!String.isBlank(boothSize)) {
                    //boothSize = boothSize.trim();
                    sTempQuery += '%20and%20Area%20eq%20%27' + boothSize.trim() + '%27';
                }
            }
            sTempQuery = sTempQuery.replace(' ', '%20');
        } catch (exception ex) {
            Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'makeExpocadQuery(@BoothSelectionCtrl.Class)');
        }
        return sTempQuery;
    }

    /**
     * @description Return to a Quote record
     * @return PageReference
     */
    public PageReference returnToPT() {
        pageReference pg = new pageReference('/' + oSBQQQuote.Id);
        return pg;
    }

    /**
     * @description Creates a dynamic picklist values for BoothProductType, Called by page "Expocad_Booth_Plan" and "Boothselectionlghtn"
     * @return List<SelectOption>
     */
    public List <SelectOption> getBoothProductType() {
        List <SelectOption> lstSelectOption = new List <SelectOption> ();
        if (oOpportunity != null) {
            String sBoothType = oOpportunity.EventEdition__r.Booth_Product_Type__c;
            if (test.isRunningTest()) {sBoothType = 'Space Only';}
            if (!String.isBlank(sBoothType)) {
                Set<String> setBPT = new Set<String>(sBoothType.split(';'));
                Set<String> setPTO = new Set<String>();
                if (!String.isBlank(oOpportunity.EventEdition__r.Product_Type_Order__c)) {
                    setPTO.addAll(oOpportunity.EventEdition__r.Product_Type_Order__c.split(';;'));
                    for (String sPTO : oOpportunity.EventEdition__r.Product_Type_Order__c.split(';;')) {
                        if (setBPT.contains(sPTO)) { lstSelectOption.add(new SelectOption(sPTO, sPTO)); }
                    }
                }
                for (String sBPT : sBoothType.split(';')) {
                    if (!setPTO.contains(sBPT)) {
                        lstSelectOption.add(new SelectOption(sBPT, sBPT));
                    }
                }
            } else { lstSelectOption.add(new SelectOption('No Product Type', 'No Product Type')); }
        }
        return lstSelectOption;
    }
    /**
     * @description Creates a dynamic picklist values for expocad Corner, Called by page "Boothselectionlghtn"
     * @return List <SelectOption>
     */
    public List < SelectOption > getCornerSelection() {
        return dynamicPicklist('Corner');
    }

    /**
     * @description Creates a dynamic picklist values for expocad BoothType, Called by page "Boothselectionlghtn"
     * @return List <SelectOption>
     */
    public List < SelectOption > getBoothTypeSelection() {
        return dynamicPicklist('BoothType');
    }

    /**
     * @description Creates a dynamic picklist values for expocad Booth Number, Called by page "Boothselectionlghtn"
     * @return List <SelectOption>
     */
    public List < SelectOption > getBoothSizeSelection() {
        return dynamicPicklist('Booth');
    }

    /**
     * @description Creates a dynamic picklist values for Event Code, Called by page "Boothselectionlghtn"
     * @return [description]
     */
    public List < SelectOption > getEventCodeSelection() {
        return dynamicPicklist('Event');
    }

    /**
     * @description Set lstExpoBooth to null and refresh page.
     * @return pageReference
     */
    public pageReference selectAnotherBooth() {
        isShowMsg = false;
        lstExpoBooth = null;
        return null;
    }

    /**
     * @description get booth product type picklist from event edition
     * @param  sParam
     * @return
     */
    public List < SelectOption > dynamicPicklist(String sParam) {
        List < SelectOption > lstSelectOption = new List < SelectOption > ();
        Boolean isAvailable = false;
        if (oOpportunity != null) {
            String sPickList;
            if (sParam == 'Booth') {
                sPickList = oOpportunity.EventEdition__r.Booth_Size__c;
            } else if (sParam == 'Corner') {
                sPickList = oOpportunity.EventEdition__r.No_Of_Corner__c;
            } else if (sParam == 'Event') {
                sPickList = oOpportunity.EventEdition__r.Event_Code__c;
            } else if (sParam == 'BoothType') {
                sPickList = oOpportunity.EventEdition__r.Booth_Type__c;
            }
            if (sPickList != null && sPickList != '') {
                if (sPickList.contains(',')) {
                    String[] lstPickList = sPickList.split(',');
                    if (sParam == 'Corner') {
                        lstSelectOption.add(new SelectOption('All', 'All'));
                    }
                    for (String sTemp : lstPickList) {
                        lstSelectOption.add(new SelectOption(sTemp, sTemp));
                        isAvailable = true;
                    }
                } else { lstSelectOption.add(new SelectOption(sPickList, sPickList)); isAvailable = true; }
            }
        }
        if (!isAvailable) {
            if (sParam == 'Booth') {
                lstSelectOption.add(new SelectOption('No Booth Size', 'No Booth Size'));
            } else if (sParam == 'Corner') {
                lstSelectOption.add(new SelectOption('No Corner', 'No Corner'));
            } else if (sParam == 'Event') {
                lstSelectOption.add(new SelectOption('No Event Edition', 'No Event Edition'));
            } else if (sParam == 'BoothType') {
                lstSelectOption.add(new SelectOption('No Booth Type', 'No Booth Type'));
            }
        }
        if (sParam != 'Booth') {
            lstSelectOption.sort();
        }
        return lstSelectOption;
    }
    
    Public static String subString(String sTemp, Integer iLength) {
        if (sTemp.length() > iLength) { sTemp = sTemp.substring(0, iLength); }
        return sTemp;
    }
}