/**
* Project:     GAP
* Date:        Jan 21, 2017
* Test Class:  AddOrReplaceBooth_Test
* Created By:  Kumar Gaurav
* *************************************************************************
* Description: Controller to Add or Replace Booths for Closed Opportunity.
* *************************************************************************
* History:
* 17/12/2018 : Modified By Avinash Shukla for Jira Ticket GGCW-2741
* 21/01/2019 : Modified By Avinash Shukla for Jira Ticket GGCW-2580
* 24/04/2019 : Modified By Avinash Shukla for Jira Ticket GGCW-3255, Adding MPN functionality here for MPN : GGCW-3001-- GGCW-3006.
* 17/04/2020 : Test Coverage 86% [Rajeev Mishra(Girikon) BK-4032]
* 22/02/2023 : Modified By Abhishek Sharma for Jira Ticket EX-154  
*/

Public class AddOrReplaceBooth {
    
    /*
    * Member variables
    */
    public Boolean isLightingEnv;
    Public boolean isCornerCheck;
    Public boolean avoidCornerCheck;
    public String sBoothID {get; set;}
    public ExpocadClasses.Booth oExpoBooth {get; set;}
    public Opportunity oOpportunity {get; set;}
    public Boolean isShowMsg {get; set;}
    public String sShowMsg {get; set;}
    public String sHost {get; set;}
    public Id opptyId {get; set;}
    //Modified By Avinash GGCW-2741
    public List<ExpocadBooth__c> lstReferencedBN {get; set;}
    private ApexPages.StandardController stdController;
    public List <SBQQ__QuoteLine__c> lstQLI {get; set;}
    public Map <Id, List <SBQQ__QuoteLine__c>> mapPackageQLI {get; set;}
    public map <Id, SBQQ__QuoteLine__c> mapPackage {get; set;}
    public Id qliToAddBN {get; set;}
    public Boolean isProfileAccess {get; set;}
    public Map <Id, String> mapPackageVsMatchedPrdName {get; set;}
    public String sFPBoothProductType {get; set;}
    //Adding Rajesh Kr BK-3873
    public List<string> lstresult {get;set;}
    //Adding MPN functionality here for MPN : GGCW-3001-- GGCW-3006 : on 24 April 2019
    Public Map<String, Booth_Product_Type_Configuration__c> bptTpMpnConfig {get; set;}
    API_Detail__mdt apiMappings;
    public String API3EFloorplanToken {get; set;} 
    
    /**
    * Constructor, Getting required values for this class like, Opportunity.
    */
    public AddOrReplaceBooth(ApexPages.StandardController controller) {
        
        //Adding MPN functionality here for MPN : GGCW-3001-- GGCW-3006.
        bptTpMpnConfig = new Map<String, Booth_Product_Type_Configuration__c>();
        bptTpMpnConfig = Utility.mapBoothProductType();
        lstresult = new List<string>();
        this.stdController = controller;
        isLightingEnv = Utility.isLightning(ApexPages.currentPage().getURL());
        //Modified By Avinash GGCW-2741
        lstReferencedBN = new list<ExpocadBooth__c>();
        isShowMsg = isProfileAccess = avoidCornerCheck = isCornerCheck = false;
        sHost = URL.getSalesforceBaseUrl().toExternalForm();
        opptyId = apexpages.currentpage().getparameters().get('id');
        String sourcePage = apexpages.currentpage().getparameters().get('src');
        Application_Bypass__c oProfilePermission = Application_Bypass__c.getInstance();
        if (oProfilePermission.Booth_Replace_Permission__c ) {  isProfileAccess = True;  }
        if (!String.isBlank(opptyId)) {
            List <Opportunity> lstOppo = [SELECT Id, Parent_Opportunity__c, StageName, AccountId, Account.Name, EventEdition__r.X3E_Status__c, EventEdition__r.X3E_Domain__c, EventEdition__r.X3E_API_ID__c, EventEdition__r.Event_Code__c, User_Type__r.Name, Corner_Validation__C , Exhibitor_Paid_by__c, Event_Series__r.Package_Identifier__c, EventEdition__r.Name, SBQQ__PrimaryQuote__c, EventEdition__r.Expocad_API_Url__c, EventEdition__r.Corner_Configuration_Check__c, EventEdition__r.Booth_Product_Type__c, EventEdition__r.Product_Type_Order__c FROM Opportunity WHERE Id = : opptyId];
            apiMappings =  [Select API_End_Point__c,API_Method__c,Password__c from API_Detail__mdt Where API_3rd_Party_Name__c=:Expocad3E_Wrapper.EXPOCAD3E and MasterLabel =:'GetFloorplanApiTokenExpo3E' limit 1];
            if (lstOppo != null && lstOppo.size() > 0) {
                oOpportunity = lstOppo.get(0);
                API3EFloorplanToken = apiMappings.Password__c;                    
            }
        }
        for (ExpocadBooth__c rBooth : [SELECT Id, Booth_Number__c, Dimensions__c, Status__c, Area__c, Pavilion__c, IsrentedByExhibitor__c, IsUnrentedByExhibitor__c FROM ExpocadBooth__c WHERE Opportunity__c = : oOpportunity.Id AND Status__c = 'Released' AND IsUnrentedByExhibitor__c = true  LIMIT 1000]) { lstReferencedBN.add(rBooth); }
    }
    
    /**
    * Added By Avinash - GGCW-2741 - 17/12/2018
    * [CheckAndRedirect Method is called on page load and based on condition redirected to another page]
    * @return [Pagereference]
    */
    public void checkCornerValidation() {
        
        //Adding opportunity query to check for corner validation everytime a new booth is selected.
        List<Opportunity> opp = [SELECT Id, Corner_Validation__C FROM Opportunity WHERE Id = : opptyId];
        Set<String> setExbToAvoidCornerChk =  new Set<String> {'exhibitor paid by agent', 'subagent paid by subagent', 'subagent paid by exhibitor', 'exhibitor paid by exhibitor'};
            if (oOpportunity.Exhibitor_Paid_by__c != NULL && setExbToAvoidCornerChk.contains(oOpportunity.Exhibitor_Paid_by__c.toLowerCase())) {   avoidCornerCheck = true;  } else if (!opp.get(0).Corner_Validation__C) {  avoidCornerCheck = true; } else if (opp.get(0).Corner_Validation__C) { avoidCornerCheck = false; }
    }
    
    /**
    * @description Getting Expocad booth details, Adding all matched product packages in a List/Map by comparing Area and Corner .
    */
    public void checkFloorBooth() {
        try {
            checkCornerValidation();
            sShowMsg = '';
            isShowMsg = false;
            mapPackageVsMatchedPrdName = new Map <Id, String>();
            sBoothID = apexpages.currentpage().getparameters().get('floorBoothId');
            String sAPIUrl = oOpportunity.EventEdition__r.Expocad_API_Url__c + '/booths?boothNumber=' + sBoothID.deleteWhitespace() + '&databaseName=' + oOpportunity.EventEdition__r.Event_Code__c;
            sAPIUrl = sAPIUrl.replace(' ', '%20');
            HttpResponse res = new ExpocadResponses().request(sAPIUrl, 'GET', '');
            system.debug('test_Response'+res);
            String sReturn = res.getBody();
            system.debug('sReturn'+sReturn);
            if (res.getStatus() == null) { sShowMsg = System.Label.ExpoCAD_API_Down_Msg; isShowMsg = true; } else if (!String.isBlank(sReturn)) {
                oExpoBooth = (ExpocadClasses.Booth) JSON.deserialize(sReturn, ExpocadClasses.Booth.class);
                if (oExpoBooth.IsOnHold) { sShowMsg = System.Label.Booth_Is_Already_Held_Msg; isShowMsg = true; }else if (oExpoBooth.IsRented) { sShowMsg = System.Label.Booth_Is_Already_Rent_Msg; isShowMsg = true; }
            }
            
            if (!isShowMsg) {
                lstQLI = new List <SBQQ__QuoteLine__c> ();
                mapPackage = new map <Id, SBQQ__QuoteLine__c> ();
                mapPackageQLI = new Map <Id, List <SBQQ__QuoteLine__c>> ();
                for (SBQQ__QuoteLine__c oQLI : [SELECT Id, SBQQ__ProductName__c, SBQQ__RequiredBy__c, SBQQ__RequiredBy__r.Id, SBQQ__ProductCode__c, SBQQ__Quote__c, SBQQ__Quantity__c, Booth_Number__c, Booth__c, SBQQ__NetTotal__c, SBQQ__ListPrice__c, SBQQ__PackageTotal__c, SBQQ__Product__r.Corner_Configuration__c, SBQQ__Product__r.ExpoCAD_Booth_Product__c, SBQQ__Product__r.ExpoCAD_Product__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = : oOpportunity.SBQQ__PrimaryQuote__c ORDER BY SBQQ__Number__c ASC LIMIT 5000]) {
                    //Updated this as part of EX-154 to allow Booth products of type 'Smart Event Package' for replace booth functionality on Opportunity booth tab
                    if (oQLI.SBQQ__RequiredBy__c == null && (oQLI.SBQQ__ProductName__c.toLowerCase().contains('booth package') 
                                                             || oQLI.SBQQ__ProductName__c.toLowerCase().contains('smart event package'))) {
                        mapPackageQLI.put(oQLI.Id, new List <SBQQ__QuoteLine__c> ());
                        mapPackage.put(oQLI.Id, oQLI);
                    } else if (oQLI.SBQQ__RequiredBy__c != null) {
                        if (mapPackageQLI.containsKey(oQLI.SBQQ__RequiredBy__r.Id)) {
                            mapPackageQLI.get(oQLI.SBQQ__RequiredBy__r.Id).add(oQLI);
                        }
                    }
                }
                if (!mapPackage.isEmpty()) {
                    Double boothquantity = getQuantity(oExpoBooth.Area);
                    Boolean inlineExist;
                    Boolean cornerExist;
                    Boolean cornerProductExist;
                    Boolean isCornerCheck;
                    Boolean areaMatch;
                    for (Id packageId : mapPackage.keySet()) {
                        inlineExist = cornerExist = cornerProductExist = isCornerCheck = areaMatch = false;
                        Set <String> setCornerConfiguration ;
                        for (SBQQ__QuoteLine__c oTempQLI : mapPackageQLI.get(packageId)) {
                            if (oTempQLI.SBQQ__ProductName__c.toLowerCase().contains('corner booth fee')) {
                                cornerProductExist = true;
                                if (oTempQLI.SBQQ__Quantity__c == oExpoBooth.OpenCorners) {
                                    cornerExist = true;
                                }
                            } else if (oTempQLI.SBQQ__Product__r.ExpoCAD_Booth_Product__c && oTempQLI.SBQQ__Quantity__c == boothquantity) {
                                inlineExist = true;
                                areaMatch = true;
                                mapPackageVsMatchedPrdName.put(packageId, oTempQLI.SBQQ__ProductName__c);
                                if (oOpportunity.EventEdition__r.Corner_Configuration_Check__c) {
                                    setCornerConfiguration = new Set <String>();
                                    if (oTempQLI.SBQQ__Product__r.Corner_Configuration__c != NULL) {
                                        for (String sTempCornerConfValue : oTempQLI.SBQQ__Product__r.Corner_Configuration__c.split(';')) {
                                            setCornerConfiguration.add(sTempCornerConfValue.toLowerCase());
                                        }
                                    }
                                    isCornerCheck = setCornerConfiguration.isEmpty() || setCornerConfiguration.contains(oExpoBooth.BoothType.toLowerCase());
                                } else {
                                    isCornerCheck = TRUE ;
                                }
                            }
                        }
                        //GGCW-2580: Modified By Avinash Shukla
                        If(avoidCornerCheck && areaMatch) { lstQLI.add(mapPackage.get(packageId)); lstQLI.addAll(mapPackageQLI.get(packageId)); }
                        else {
                            if (inlineExist && (!isCornerCheck || ((oExpoBooth.OpenCorners == 0 && !cornerProductExist) || (oExpoBooth.OpenCorners != 0 && cornerExist)))) {
                                lstQLI.add(mapPackage.get(packageId)); lstQLI.addAll(mapPackageQLI.get(packageId)); }
                        }
                    }
                }
            }
        } catch (exception ex) {
            Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'checkFloorBooth(@AddOrReplaceBooth.cls)');
        }
    }
    
    /**
    * converting String value to double.
    * @param sQuantity
    * @return Double
    */
    public Double getQuantity(String sQuantity) {
        String sTempQuantity = sQuantity.substringBefore(' ');
        sTempQuantity = sTempQuantity.trim();
        return Double.valueof(sTempQuantity);
    }
    
    /**
    * Adding/Replacing booths for matched product package.
    * @return PageReference
    */
    public PageReference addOrReplace() {
        try {
            // Bypass Closed Won validation for Opportunity and Quote Update for Profile except System Administrator.
            Utility.byPassClosedWon = True ;
            SBQQ__QuoteLine__c oQLIToUpdate = new SBQQ__QuoteLine__c();
            SBQQ__QuoteLine__c mainQLI = new SBQQ__QuoteLine__c();
            List <SBQQ__QuoteLine__c> lstToUpdate = new List <SBQQ__QuoteLine__c> ();
            List <ExpocadBooth__c> lstEB = new List <ExpocadBooth__c> ();
            String sDisplayName ;
            String sResult ;
            if (qliToAddBN != null) {
                system.debug('test_qliToAddBN'+qliToAddBN);
                system.debug('test'+oExpoBooth);
                String sMatchedProductName = '';
                if (mapPackageVsMatchedPrdName.size() > 0) { sMatchedProductName = mapPackageVsMatchedPrdName.get(qliToAddBN) == null ? mapPackageVsMatchedPrdName.get(qliToAddBN) : ''; }
                ExpocadBooth__c oExpocad = getEB(oExpoBooth, '', '');
                oQLIToUpdate = mapPackage.get(qliToAddBN);
                String sBoothNoToRelease = oQLIToUpdate.Booth_Number__c;
                oQLIToUpdate.Booth_Number__c = oExpocad.Booth_Number__c;
                oQLIToUpdate.Open_Corners__c = oExpocad.Open_Corners__c;
                oQLIToUpdate.Booth__c = true;
                oQLIToUpdate.Show_In_Show__c = oExpocad.ShowInShow__c;
                oQLIToUpdate.Booth_Pavilion__c = oExpocad.Pavilion__c;
                oQLIToUpdate.Booth_Type__c = oExpocad.Booth_Type__c;
                oQLIToUpdate.Booth_Classes__c = oExpocad.Booth_Classes__c;
                lstToUpdate.add(oQLIToUpdate);
                for (SBQQ__QuoteLine__c otempQLI : mapPackageQLI.get(qliToAddBN)) {
                    otempQLI.Booth_Number__c = oExpocad.Booth_Number__c;
                    otempQLI.Open_Corners__c = oExpocad.Open_Corners__c;
                    otempQLI.Booth__c = true;
                    if (otempQLI.SBQQ__Product__r.ExpoCAD_Booth_Product__c) { otempQLI.Line_Description__c = oExpocad.Booth_Number__c + '-' + oExpocad.Booth_Type__c; }
                    otempQLI.Show_In_Show__c = oExpocad.ShowInShow__c;
                    otempQLI.Booth_Pavilion__c = oExpocad.Pavilion__c;
                    otempQLI.Booth_Type__c = oExpocad.Booth_Type__c;
                    otempQLI.Booth_Classes__c = oExpocad.Booth_Classes__c;
                    
                    lstToUpdate.add(otempQLI);
                    if (otempQLI.SBQQ__RequiredBy__c == null && !otempQLI.SBQQ__ProductName__c.toLowerCase().contains('corner booth fee')) {  mainQLI = otempQLI; }
                }
                if (!lstToUpdate.isEmpty()) {
                    if (!String.isBlank(sBoothNoToRelease)) {
                        for (ExpocadBooth__c oEB : [SELECT Id, Matched_Product_Name__c, Display_Name__c, Booth_Product_Type_EE__c FROM ExpocadBooth__c WHERE Quote__c = : oOpportunity.SBQQ__PrimaryQuote__c AND Status__c = 'Rented' AND Booth_Number__c = : sBoothNoToRelease]) { oExpocad = getEB(oExpoBooth, '', ''); oExpocad.Id = oEB.Id; lstEB.add(oExpocad); sDisplayName = oEB.Display_Name__c ; }
                        sResult = ExpocadResponses.SyncUnRent(sBoothNoToRelease, oOpportunity.Id, oOpportunity.SBQQ__PrimaryQuote__c, oOpportunity.EventEdition__r.Event_Code__c, oOpportunity.EventEdition__r.Expocad_API_Url__c, '');
                    }
                    
                    update lstToUpdate;
                    if (!lstEB.isEmpty()) { 
                        /*if (!String.isBlank(sDisplayName)) { 
						sResult = ExpocadResponses.SyncUpdateDisplay(oQLIToUpdate.Booth_Number__c, oOpportunity.Id, oOpportunity.SBQQ__PrimaryQuote__c, oOpportunity.EventEdition__r.Event_Code__c, oOpportunity.EventEdition__r.Expocad_API_Url__c, sDisplayName); } */
                        update lstEB; 
                    } else {
                        ApexPages.StandardController sc = new ApexPages.StandardController(new SBQQ__Quote__c());
                        BoothSelectionCtrl oBsc = new BoothSelectionCtrl(sc);
                        oBsc.oOpportunity = oOpportunity;
                        oBsc.getBoothProducts();
                        oExpoBooth.BoothClass = sFPBoothProductType;
                        String sPrdName = BoothSelectionCtrl.sBPrd(oExpoBooth, oOpportunity, oBsc.boothPackageProduct);
                        oExpocad = getEB(oExpoBooth, sPrdName, sFPBoothProductType);
                        insert oExpocad;
                    }
                    //Modified by Abhishek Sharma on 22/02/2023 : EX-154       
                    //ExpocadResponses.asyncRENT(oQLIToUpdate.Booth_Number__c, oOpportunity.Id, oOpportunity.SBQQ__PrimaryQuote__c, oOpportunity.EventEdition__r.Event_Code__c, '' , isReplaceBooth); 
                    
                    ExpocadBooth__c oBooth = new ExpocadBooth__c(Id=oExpocad.Id, Booth_Number__c= oExpocad.Booth_Number__c, Opportunity__c = oExpocad.Opportunity__c);
                    Boolean isReplaceBooth = true;
                    Create3EApiSyncRecords.syncBooth(oBooth, 'Asynchronous',Expocad3E_Wrapper.EXPOCAD_BOOTH_RENT, isReplaceBooth,'');
                    
                    return this.returnToPT();
                }
            }
        } catch (exception ex) {
            Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'addOrReplace(@AddOrReplaceBooth.cls)');
        }
        return null;
    }
    
    /**
    * Type Casting Booth Detials parameter in ExpocadBooth__c Object.
    * @param  oExpoBooth [ExpocadClasses.Booth ref]
    * @param  sPrdName   [Selected Product Name By User]
    * @return ExpocadBooth__c
    */
    public ExpocadBooth__c getEB(ExpocadClasses.Booth oExpoBooth, String sPrdName, String sBoothPrdName) {
        ExpocadBooth__c oExpocad = new ExpocadBooth__c();
        oExpocad.Account__c = oOpportunity.AccountId;
        oExpocad.Booth_Number__c = oExpoBooth.BoothNumber;
        oExpocad.Last_Action_Date__c = Date.today();
        oExpocad.User__c = userinfo.getuserid();
        oExpocad.Status__c = 'Rented';
        oExpocad.Area__c = oExpoBooth.Area;
        oExpocad.Booth_Type__c = oExpoBooth.BoothType;
        oExpocad.Dimensions__c = oExpoBooth.Dimensions;
        oExpocad.Open_Corners__c = oExpoBooth.OpenCorners;
        oExpocad.Unit_Type__c = oExpoBooth.UnitType;
        //Adding MPN functionality here for MPN : GGCW-3001-- GGCW-3006. for Exhibtior's Opportunity.
        //Modified BY Avinash Shukla 24/04/2019
        If(!String.isBlank(sBoothPrdName)) {
            If(oOpportunity.User_Type__r.Name == 'Exhibitor' && oOpportunity.Parent_Opportunity__c == null) {
                //This is exhibitor's opportunity.
                if (!bptTpMpnConfig.isEmpty()) {
                    If(bptTpMpnConfig.containsKey(sBoothPrdName) && bptTpMpnConfig.get(sBoothPrdName).Matched_Product_Name__c != NULL) {
                        oExpocad.Matched_Product_Name__c = bptTpMpnConfig.get(sBoothPrdName).Matched_Product_Name__c;
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
            oExpocad.Booth_Product_Type_EE__c = sBoothPrdName;
            oExpocad.Booth_Product_Type__c = sPrdName;
            
        }
        oExpocad.Quote__c = oOpportunity.SBQQ__PrimaryQuote__c;
        oExpocad.Opportunity__c = oOpportunity.Id;
        oExpocad.ShowInShow__c = oExpoBooth.ShowInShow;
        oExpocad.Pavilion__c = oExpoBooth.Pavilion;
        if (oExpoBooth.BoothClasses != null) {
            oExpocad.Booth_Classes__c = string.join(oExpoBooth.BoothClasses, ';;');
        }
        return oExpocad;
    }
    
    /**
    * returns to a current Opportunity.
    * @return PageReference
    */
    public pageReference returnToPT() {
        pageReference pg = new pageReference('/' + oOpportunity.Id);
        return pg;
    }
    
    /**
    * set oExpoBooth and lstQLI to null and refresh page.
    * @return pageReference
    */
    public pageReference selectAnotherBooth() {
        oExpoBooth = null;
        lstQLI = null;
        return null;
    }
    
    public List <SelectOption> getBoothProductType() {
        List <SelectOption> lstSelectOption = new List <SelectOption> ();
        if (oOpportunity != null) {
            String sBoothType = oOpportunity.EventEdition__r.Booth_Product_Type__c;
            if (!String.isBlank(sBoothType)) { Set<String> setBPT = new Set<String>(sBoothType.split(';')); Set<String> setPTO = new Set<String>(); if (!String.isBlank(oOpportunity.EventEdition__r.Product_Type_Order__c)) { setPTO.addAll(oOpportunity.EventEdition__r.Product_Type_Order__c.split(';;')); for (String sPTO : oOpportunity.EventEdition__r.Product_Type_Order__c.split(';;')) { if (setBPT.contains(sPTO)) { lstSelectOption.add(new SelectOption(sPTO, sPTO)); } } }
                                              for (String sBPT : sBoothType.split(';')) {
                                                  if (!setPTO.contains(sBPT)) {
                                                      lstSelectOption.add(new SelectOption(sBPT, sBPT));
                                                  }
                                              }
                                             } else {
                                                 lstSelectOption.add(new SelectOption('No Product Type', 'No Product Type'));
                                             }
        }
        return lstSelectOption;
    }
    
}