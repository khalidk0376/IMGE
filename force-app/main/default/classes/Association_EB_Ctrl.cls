/**
* Project:     GAP
* Date:        Jan 09, 2017
* Created By:  Kumar Gaurav
* Test Class:  Association_EB_Ctrl_Test
* *************************************************************************
* Description: Controller for PurchasedBoothslghtn page for Association Process
* *************************************************************************
* History:  Modified By Sudip for Jira Tickets GGCW-2079, GGCW-2080 on 26/06/2018
* History ----: Replaced As Per Ticket GGCW-3101 :----'Product_brand__c Replaced by this Event_Edition_Name__c field'
* Rajesh Kumar Yadav
* History:https://informa-ge-sfdc.atlassian.net/browse/BK-3006 
* Rajesh Kumar Yadav Only SCA Work.
*/

public without sharing class Association_EB_Ctrl {
    
    /*
* Member variables
*/
    public List<ExpocadBooth__c> lstHeldBooth {get; set;}
    public List<ExpocadBooth__c> lstHeldBoothtoUpdate {get; set;}
    public Opportunity oOpportunity {get; set;}
    public Boolean isShowMsg {get; set;}
    private ApexPages.StandardController stdController;
    public transient List<Contact> lstExistingContact {get; set;}
    public Id selectedAccountId {get; set;}
    public Id selectedContactId {get; set;}
    public String sOpptyName {public get; public set;}
    public String sOpptyName2 {public get; public set;}
    public String sOpptyName3 {public get; public set;}
    public String sDisplayName {public get; public set;}
    public transient SavePoint mySavePoint {public get; private set;}
    public opportunity relatedOppty {public get; private set;}
    public Account oAccount {get; set;}
    public Contact oContact {get; set;}
    public Contact oContact2 {get; set;}
    public SBQQ__Quote__c objQuote {get; set;}
    public Boolean shouldRedirect {get; set;}
    public String redirectUrl {get; set;}
    public transient Map<Id, Account> mapExistingAccount {get; set;}
    public transient Map<ID, Contact> mapExistingContact {get; set;}
    public Integer mapExistingContactSize {get; set;}
    public ExpocadClasses.Booth oExpoBooth {get; set;}
    private Boolean isLightingEnv ;
    public String sHost {get; set;}
    public Map<String, SBQQ__ProductOption__c> mapProductOptions {get; set;}
    public Map<Id, SBQQ__ProductOption__c> mapProductOptionsId {get; set;}
    public Product2 boothPackageProduct {get; set;}
    public String cornerProductName {get; set;}
    public String lbl_View_Floorplan_Button_Validation_NoExb_Message {get; set;}
    public String lbl_Create_Related_Opportunity_Button_Validation_Message {get; set;}
    public String lbl_Confirm_Message_to_Create_Related_Opportunity {get; set;}
    public String sEBDisplayName {get; set;}
    public integer limitSize   { get; set; }
    public integer offsetSize  { get; set; }
    public integer totalRecs   { get; set; }
    public integer pageNumber  { get; set; }
    public String accountName  { get; set; }
    public String sShowMsg     { get; set; }
    
    public String exhibitorPaidAcc { get; set; }
    
    /**
* @description Constructor, Getting required values for this class like, Opportunity, Existing accounts and Held Booths.
*/
    public Association_EB_Ctrl(ApexPages.StandardController controller) {
        this.stdController = controller;
        oAccount = new Account();
        oContact = new Contact();
        oContact2 = new Contact();
        isShowMsg = false;
        shouldRedirect = false;
        sHost = URL.getSalesforceBaseUrl().toExternalForm();
        isLightingEnv = Utility.isLightning(ApexPages.currentPage().getURL());
        mapExistingContactSize = OffsetSize = totalRecs = 0;
        Id opptyId = apexpages.currentpage().getparameters().get('id');
        lbl_View_Floorplan_Button_Validation_NoExb_Message = System.Label.View_Floorplan_Button_Validation_NoExb_Message.escapeHtml4();
        lbl_Create_Related_Opportunity_Button_Validation_Message = System.Label.Create_Related_Opportunity_Button_Validation_Message.escapeHtml4();
        lbl_Confirm_Message_to_Create_Related_Opportunity = System.Label.Confirm_Message_to_Create_Related_Opportunity.escapeHtml4();
        pageNumber = 1;
        LimitSize = 10;
        accountName = sShowMsg = exhibitorPaidAcc = '';
        
        if (!String.isBlank(opptyId)) {
            // Modified by Avinash : GGCW-2690.
            List < Opportunity > lstOppo = [SELECT Id, Event_Edition_Currency__c, AccountId, Amount, Opportunity_Contact__c, Multiple_Stands_Approval__c, Owner.Id, Account.Name, EventEdition__r.Booth_Size__c, EventEdition__r.No_Of_Corner__c, CurrencyIsoCode, EventEdition__r.Start_Date__c, EventEdition__r.Event_Code__c, EventEdition__r.Booth_Product_Type__c, Event_Series__r.Brand__r.SSC_Email_Distribution_ID__c, Event_Series__r.Package_Identifier__c, EventEdition__r.Booth_Type__c, EventEdition__r.Name,EventEdition__r.Booth_Bundle_Type__c, EventEdition__c, Event_Series__c, Billing_Contact__c, MSA_Requested__c, Parent_Opportunity__c, EventEdition__r.Expocad_API_Url__c, SBQQ__PrimaryQuote__c, Exhibitor_Paid_by__c, Agent_s_Opportunity__c, StageName FROM Opportunity WHERE Id = : opptyId];
            if (lstOppo != null && lstOppo.size() > 0) {
                oOpportunity = lstOppo.get(0);
                sEBDisplayName = oOpportunity.Account.Name.replace('\'', '\\\'');
            }
        }
        
        /*String sSoqlQueryString = 'SELECT id, Display_Name__c, Selected__c, Booth_Product_Type__c, Quote__r.Name,Quote__r.SBQQ__Primary__c, User__r.Name, Area__c, Unit_Type__c, Open_Corners__c, Booth_Type__c, Booth_Number__c, Dimensions__c, Last_Action_Date__c, Status__c, Opportunity__c, Account__c, Related_Opportunity__c, Related_Opportunity__r.Name, Opportunity__r.Name, ShowInShow__c, Pavilion__c, Booth_Classes__c, Primary_Contact__r.Name,Primary_Contact__c, BoothContact__r.Name, Booth_Product_Type_EE__c from ExpocadBooth__c where (Status__c = \'Rented\' OR Status__c = \'Rent\') AND ';
if (oOpportunity.Parent_Opportunity__c != null) {
sSoqlQueryString += 'Related_Opportunity__c =\'' + opptyId + '\'';
} else {
sSoqlQueryString += 'Opportunity__c =\'' + opptyId + '\'';
}
sSoqlQueryString += ' order by LastModifiedDate desc LIMIT 1000'; 
lstHeldBooth  = Database.query(sSoqlQueryString);*/
        
        lstHeldBooth = [SELECT id, Display_Name__c, Selected__c, Booth_Product_Type__c, Quote__r.Name,Quote__r.SBQQ__Primary__c, User__r.Name, Area__c, Unit_Type__c, Open_Corners__c, Booth_Type__c, Booth_Number__c, Dimensions__c, Last_Action_Date__c, Status__c, Opportunity__c, Account__c, Related_Opportunity__c, Related_Opportunity__r.Name, Opportunity__r.Name, ShowInShow__c, Pavilion__c, Booth_Classes__c, Primary_Contact__r.Name,Primary_Contact__c, BoothContact__r.Name, Booth_Product_Type_EE__c from ExpocadBooth__c where (Status__c = 'Rented' OR Status__c = 'Rent') AND ( Related_Opportunity__c = : opptyId OR Opportunity__c = : opptyId ) order by LastModifiedDate desc LIMIT 1000];
        system.debug('lstHeldBooth==' + lstHeldBooth);
        //mapExistingAccount = new Map < ID, account > ([SELECT Id, Name, Brand__c, BillingCity, BillingState, Type, Owner.Name, Count_of_Won_Opportunities__c, LastViewedDate FROM Account ORDER BY LastViewedDate ASC NULLS LAST LIMIT 2500]);
    }
    
    /**
* Display existing Account with offset and limit
* @return [List<Account>]
*/
    public List<Account> getAccounts( ) {
        System.debug('The account Name is ' + accountName);
        List<Account> accounts;
        if ( accountName != '' ) {            String accName = '%' + accountName + '%';            accounts = [ SELECT Id, Name, Brand__c, BillingCity, BillingState, BillingStreet, Type, Owner.Name, Count_of_Won_Opportunities__c, LastViewedDate  FROM Account WHERE name like : accName  ORDER BY LastViewedDate DESC NULLS LAST LIMIT : LimitSize OFFSET : OffsetSize ];
                                 } else {
                                     accounts = [ SELECT Id, Name, Brand__c, BillingCity, BillingState, BillingStreet, Type, Owner.Name, Count_of_Won_Opportunities__c, LastViewedDate  FROM Account ORDER BY LastViewedDate DESC NULLS LAST LIMIT : LimitSize OFFSET : OffsetSize ];
                                 }
        if ( exhibitorPaidAcc != '' ) {            accounts = [ SELECT Id, Name, Brand__c, BillingCity, BillingState, BillingStreet, Type, Owner.Name, Count_of_Won_Opportunities__c, LastViewedDate  FROM Account where id = : exhibitorPaidAcc  ORDER BY LastViewedDate DESC NULLS LAST LIMIT : LimitSize OFFSET : OffsetSize ];
                                      }
        return accounts;
    }
    
    /**
* Counts existing Account no.
* @return [totalRecs]
*/
    public integer getTotalAccounts( ) {
        List <Account> accList = new List <Account> ( );
        if ( accountName != '' ) {
            String accName = '%' + accountName + '%';            accList = [ SELECT Id FROM Account WHERE name like : accName ORDER BY LastViewedDate DESC LIMIT 2000 ];
        } else {
            accList = [ SELECT Id FROM Account ORDER BY LastViewedDate DESC LIMIT 2000 ];
        }
        
        if ( exhibitorPaidAcc != '' ) {            accList = [ SELECT Id FROM Account WHERE id = : exhibitorPaidAcc ];
                                      }
        
        totalRecs = accList.size();
        system.debug('total rec ' + totalRecs);
        return totalRecs;
    }
    
    
    public void firstPage( ) {
        OffsetSize = 0;
        pageNumber = 1;
    }
    public void previous( ) {
        OffsetSize = OffsetSize - LimitSize;
        pageNumber -= 1;
    }
    public void next( ) {
        OffsetSize = OffsetSize + LimitSize;
        pageNumber += 1;
        if ( OffsetSize >= 2000 ) {            OffsetSize = 2000 - 10;
                                  }
    }
    public void lastPage( ) {
        OffsetSize = totalrecs - math.mod( totalRecs, LimitSize );
        if ( math.mod( totalRecs, LimitSize ) > 0 ) {
            pageNumber = ( integer ) totalRecs / LimitSize + 1;
        }
        else {
            pageNumber = ( integer ) totalRecs / LimitSize;
        }
        if ( OffsetSize >= 2000 ) {            OffsetSize = 2000 - 10;
                                  }
    }
    public boolean getprev( ) {
        if ( OffsetSize == 0 ) return true;        else return false;
    }
    public boolean getnxt( ) {
        if ( OffsetSize >= 1990 ||  ( OffsetSize + LimitSize ) >= totalRecs )  return true;
        //if( ( OffsetSize + LimitSize ) > totalRecs ) return true;
        else return false;
    }
    
    /**
* Redirect to Expocad Floor Plan Page.
* @return pageReference
*/
    public pageReference viewFloorPlan() {
        shouldRedirect = true;
        
        
        if (oOpportunity.Exhibitor_Paid_by__c != NULL) {
            redirectUrl = sHost + '/apex/ReplaceBooth_extend?id=' + oOpportunity.Id;
        } else {
            redirectUrl = sHost + '/apex/ReplaceBooth?id=' + oOpportunity.Id + '&src=purchaseBooths';
        }
        if (isLightingEnv) {            pageReference pg;            if (oOpportunity.Exhibitor_Paid_by__c != NULL)                pg = new pageReference('/apex/ReplaceBooth_extend?id=' + oOpportunity.Id);
                            else
                                pg = new pageReference('/apex/ReplaceBooth?id=' + oOpportunity.Id + '&src=purchaseBooths');
                            return pg;
                           }
        return null;
    }
    
    /**
* @description The functionality is used to Unrent the booth
* @return pageReference
*/
    public pageReference unRentedbooth() {
        list < ExpocadBooth__c > expoUnrent = new list < ExpocadBooth__c > ();
        system.debug('lstHeldBooth'+lstHeldBooth);
        for (ExpocadBooth__c oEB : lstHeldBooth) {
            if (oEB.Selected__c && oEB.Booth_Number__c != null) {         String sUrlToUnhold = oOpportunity.EventEdition__r.Expocad_API_Url__c + '/booths/unrent?boothNumber=' + oEB.Booth_Number__c + '&databaseName=' + oOpportunity.EventEdition__r.Event_Code__c;
                                                 HttpResponse unholdRes = new ExpocadResponses().request(sUrlToUnhold, 'PUT', '');    
                                                                 system.debug('unholdRes'+unholdRes.getStatusCode());

                                                                 if (unholdRes.getStatusCode() == 200) {
                                                                     oEB.status__c = 'Released';
                                                                     oEB.Selected__c = false;
                                                                     oEB.IsUnrentedByExhibitor__c = true;
                                                                     oEB.IsrentedByExhibitor__c = true;
                                                                     expoUnrent.add(oEB);
                                                                 }
                                                                }
        }
        update expoUnrent;
        shouldRedirect = true;
        redirectUrl = sHost + '/' + oOpportunity.Id;
        system.debug('redirectUrl::::' + redirectUrl);
        if (isLightingEnv) {            pageReference pg = new pageReference('/' + oOpportunity.Id);            return pg;
                           }
        return null;
    }
    
    /**
* @description Creating Account, Contact and Opportunity using new account details
* @return PageReference
*/
    public pageReference createOpptybyNewAccount() {
        //mySavePoint = Database.setSavePoint();
        try {
            if (!String.isBlank(oAccount.Name) && !String.isBlank(oAccount.CurrencyIsoCode)) {
                insert oAccount;
                if (!String.isBlank(oAccount.Id)) {
                    oContact.AccountId = oAccount.Id;
                    insert oContact;
                    if (!String.isBlank(oContact.Id)) {
                        selectedAccountId = oAccount.Id;
                        selectedContactId = oContact.Id;
                        sOpptyName2 = sOpptyName;
                        return this.createRelatedOppty();
                    }
                }
            }
        } catch (Exception ex) {      Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'createOpptybyNewAccount(@Association_EB_Ctrl.Class)');        }        return null;
    }
    
    /**
* @description Creating  Contact and Opportunity using existing account
* @return PageReference
*/
    public pageReference createOpptyNewContact() {
        try {
            if (!String.isBlank(selectedAccountId)) {
                oContact2.AccountId = selectedAccountId;                insert oContact2;                if (!String.isBlank(oContact2.Id)) {                    selectedContactId = oContact2.Id;                    sOpptyName2 = sOpptyName3;
                                                                                                                                             return this.createRelatedOppty();
                                                                                                                                            }
            }
        } catch (Exception ex) {            Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'createOpptyNewContact(@Association_EB_Ctrl.Class)');
                               }
        return null;
    }
    
    /**
* @description Updating displayName to Expocad using API
* @return PageReference
*/
    public pageReference updateDisplayName() {
        try {
            lstHeldBoothtoUpdate = new List < ExpocadBooth__c > ();
            for (ExpocadBooth__c oEB : lstHeldBooth) {
                if (oEB.Selected__c) {
                    String sResult = ExpocadResponses.SyncUpdateDisplay(oEB.Booth_Number__c, oOpportunity.Id, oOpportunity.SBQQ__PrimaryQuote__c, oOpportunity.EventEdition__r.Event_Code__c, oOpportunity.EventEdition__r.Expocad_API_Url__c, sDisplayName);
                    oEB.Display_Name__c = sDisplayName;
                    oEB.Selected__c = false;
                    lstHeldBoothtoUpdate.add(oEB);
                }
            }
            if (!lstHeldBoothtoUpdate.isEmpty()) {
                update lstHeldBoothtoUpdate;            }        } catch (Exception ex) {            Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'updateDisplayName(@Association_EB_Ctrl.Class)');
                                                                                        }
        //mapExistingAccount = new Map < ID, account > ([SELECT Id, Name, Brand__c, BillingCity, BillingState, Type, Owner.Name, Count_of_Won_Opportunities__c, LastViewedDate FROM Account ORDER BY LastViewedDate ASC NULLS LAST LIMIT 2500]);
        return null;
    }
    
    /**
* @description Creating  Opportunity using existing account and Contact
* @return PageReference
*/
    public pageReference createRelatedOppty() {
        try {
            
            List < ExpocadBooth__c > lstHBtoUpdate = new List < ExpocadBooth__c > ();
            List < ExpocadBooth__c > lstHBtoAdd = new List < ExpocadBooth__c > ();
            
            relatedOppty = new opportunity();
            relatedOppty.Name = sOpptyName2;
            relatedOppty.StageName = 'Needs Assessment';
            relatedOppty.accountId = selectedAccountId;
            relatedOppty.CloseDate = oOpportunity.EventEdition__r.Start_Date__c;
            relatedOppty.Parent_Opportunity__c = oOpportunity.id;
            relatedOppty.CurrencyIsoCode = oOpportunity.CurrencyIsoCode;
            relatedOppty.Event_Edition_Currency__c = oOpportunity.Event_Edition_Currency__c;
            System.debug('Currency ISO =>' + oOpportunity.CurrencyIsoCode);
            relatedOppty.Opportunity_Contact__c = selectedContactId;
            // GGCW-2416
            //relatedOppty.Billing_Contact__c = selectedContactId;
            relatedOppty.Event_Series__c = oOpportunity.Event_Series__c;
            relatedOppty.EventEdition__c = oOpportunity.EventEdition__c;
            //GGCW-2424
            relatedOppty.Exhibitor_Paid_By__c = oOpportunity.Exhibitor_Paid_By__c;
            relatedOppty.Agent_s_Opportunity__c = oOpportunity.Agent_s_Opportunity__c;
            insert relatedOppty;
            System.debug('Currency ISO After Insert =>' + oOpportunity.CurrencyIsoCode);
            objQuote = new SBQQ__Quote__c();
            objQuote.SBQQ__Opportunity2__c = relatedOppty.id;
            objQuote.SBQQ__Account__c = relatedOppty.Accountid;
            objQuote.SBQQ__StartDate__c = date.today();
            objQuote.SBQQ__Primary__c = false;
            objQuote.SBQQ__ExpirationDate__c = date.today().adddays(30);
            objQuote.CurrencyIsoCode = relatedOppty.CurrencyIsoCode;
            //objQuote.SBQQ__PrimaryContact__c = relatedOppty.Opportunity_Contact__c;
            objQuote.SBQQ__PrimaryContact__c = selectedContactId;
            // GGCW-2079
            objQuote.Parent_Opp_Primary_Quote_Total__c = oOpportunity.Amount;
            
            insert objQuote;
            System.debug('Currency ISO After Insert Quote =>' + oOpportunity.CurrencyIsoCode);
            
            for (ExpocadBooth__c oEB : lstHeldBooth) {
                system.debug('oEB.Selected__c' + oEB.Selected__c);
                if (oEB.Selected__c) {
                    system.debug('oEB.Selected__c' + oEB.Selected__c);
                    oEB.Selected__c = False;
                    oEB.Related_Opportunity__c = relatedOppty.id;
                    lstHBtoUpdate.add(oEB);
                }
            }
            
            if (!lstHBtoUpdate.isEmpty()) {
                update lstHBtoUpdate;
                List < SBQQ__QuoteLine__c > lstQuoteLine = new List < SBQQ__QuoteLine__c > ();
                List < SBQQ__QuoteLine__c > lstPackageQuoteLine = new List < SBQQ__QuoteLine__c > ();
                
                SBQQ__QuoteLine__c oQuoteLine;
                this.getBoothProducts();
                Integer quoteLineNumber = 1;
                for (ExpocadBooth__c oEB2 : lstHBtoUpdate) {
                    String sPrdNameToAdd;
                    if (oOpportunity.Exhibitor_Paid_By__c == 'Exhibitor Paid by Exhibitor') {
                        ExpocadClasses.Booth oExpoBooth = new ExpocadClasses.Booth();
                        oExpoBooth.BoothType = oEB2.Booth_Type__c;
                        oExpoBooth.ShowInShow = oEB2.ShowInShow__c;
                        oExpoBooth.Pavilion = oEB2.Pavilion__c;
                        if (!String.isBlank(oEB2.Booth_Classes__c)) {
                            oExpoBooth.BoothClasses = oEB2.Booth_Classes__c.split(';;');
                        }
                        oExpoBooth.BoothClass = oEB2.Booth_Product_Type_EE__c;
                        BoothSelectionCtrl.mapProductOptionsId = this.mapProductOptionsId;
                        sPrdNameToAdd = BoothSelectionCtrl.SBPrd(oExpoBooth, oOpportunity, BoothPackageProduct);
                    } else {sPrdNameToAdd = oEB2.Booth_Product_Type__c;                }
                    if (!String.isBlank(sPrdNameToAdd)) {
                        if (mapProductOptions.get(sPrdNameToAdd) != null) {
                            Double quantity = getQuantity(oEB2.Area__c);
                            /* Adding Package Product*/
                            String packageId;
                            oQuoteLine = new SBQQ__QuoteLine__c();
                            oQuoteLine.SBQQ__Quote__c = objQuote.Id;
                            oQuoteLine.SBQQ__Product__c = BoothPackageProduct.Id; //LinearProduct.ID;
                            oQuoteLine.SBQQ__Quantity__c = 1;
                            oQuoteLine.SBQQ__NonDiscountable__c = BoothPackageProduct.SBQQ__NonDiscountable__c;
                            oQuoteLine.SBQQ__Hidden__c = BoothPackageProduct.SBQQ__Hidden__c;
                            oQuoteLine.SBQQ__Number__c = quoteLineNumber;
                            oQuoteLine.Booth_Number__c = oEB2.Booth_Number__c;
                            oQuoteLine.Open_Corners__c = oEB2.Open_Corners__c;                            oQuoteLine.Booth__c = true;                            oQuoteLine.Show_In_Show__c = oEB2.ShowInShow__c;
                            oQuoteLine.Booth_Pavilion__c = oEB2.Pavilion__c;                            oQuoteLine.Booth_Type__c = oEB2.Booth_Type__c;
                            oQuoteLine.Booth_Classes__c = oEB2.Booth_Classes__c;                            oQuoteLine.Booth_Product_Type__c = oEB2.Booth_Product_Type_EE__c;
                            lstPackageQuoteLine.add(oQuoteLine);
                            quoteLineNumber++;
                            
                            SBProductConfiguration oPrdConfiguration = new SBProductConfiguration();
                            SBProductConfiguration.TinyConfigurationModel oPrdConfigurationModel = new SBProductConfiguration.TinyConfigurationModel();
                            System.debug('Id.BoothPackageProduct'+BoothPackageProduct.Id);

                            oPrdConfigurationModel = oPrdConfiguration.getConfigurationAfterFireProductRule(BoothPackageProduct.Id, objQuote.SBQQ__PriceBook__c, mapProductOptions.get(sPrdNameToAdd).Id, mapProductOptions.get(sPrdNameToAdd).SBQQ__OptionalSKU__c, quantity);
                            System.debug('oPrdConfigurationModelt'+oPrdConfigurationModel);

                            if (!oPrdConfigurationModel.optionConfigurations.isEmpty()) {
                                for (SBProductConfiguration.TinyConfigurationModel oTempConfgModel : oPrdConfigurationModel.optionConfigurations) {
                                    if (mapProductOptions.get(CornerProductName) != null && mapProductOptions.get(CornerProductName).SBQQ__OptionalSKU__c != oTempConfgModel.optionData.SBQQ__OptionalSKU__c) {
                                        // Adding Products to quote line item
                                        oQuoteLine = new SBQQ__QuoteLine__c();
                                        oQuoteLine.SBQQ__Quote__c = objQuote.Id;
                                        oQuoteLine.SBQQ__ProductOption__c = oTempConfgModel.optionData.Id;
                                        oQuoteLine.SBQQ__Product__c = oTempConfgModel.optionData.SBQQ__OptionalSKU__c;
                                        oQuoteLine.SBQQ__Quantity__c = oTempConfgModel.optionData.SBQQ__Quantity__c;
                                        oQuoteLine.SBQQ__Number__c = quoteLineNumber;
                                        oQuoteLine.SBQQ__NonDiscountable__c = mapProductOptionsId.get(oTempConfgModel.optionData.Id).SBQQ__OptionalSKU__r.SBQQ__NonDiscountable__c;
                                        oQuoteLine.SBQQ__Hidden__c = mapProductOptionsId.get(oTempConfgModel.optionData.Id).SBQQ__OptionalSKU__r.SBQQ__Hidden__c;
                                        oQuoteLine.SBQQ__PricingMethodEditable__c = True;
                                        oQuoteLine.SBQQ__BundledQuantity__c = oTempConfgModel.optionData.SBQQ__Quantity__c;
                                        // Booth Details
                                        oQuoteLine.Line_Description__c = oEB2.Booth_Number__c + '-' + oEB2.Booth_Type__c;
                                        oQuoteLine.Booth_Number__c = oEB2.Booth_Number__c;                                        oQuoteLine.Open_Corners__c = oEB2.Open_Corners__c;
                                        oQuoteLine.Booth__c = true;                                        oQuoteLine.Show_In_Show__c = oEB2.ShowInShow__c;
                                        oQuoteLine.Booth_Pavilion__c = oEB2.Pavilion__c;                                        oQuoteLine.Booth_Type__c = oEB2.Booth_Type__c;
                                        oQuoteLine.Booth_Classes__c = oEB2.Booth_Classes__c;                                        oQuoteLine.Booth_Product_Type__c = oEB2.Booth_Product_Type_EE__c;
                                        oQuoteLine.SBQQ__OptionType__c = 'Component';                                        oQuoteLine.SBQQ__OptionLevel__c = 1;
                                        lstQuoteLine.add(oQuoteLine);                                        quoteLineNumber++;
                                    }
                                }
                            }
                            // Adding Corner Product
                            System.debug('oEB2.Open_Corners__c'+oEB2.Open_Corners__c);
                            System.debug('CornerProductName.CornerProductName'+CornerProductName);
                            System.debug('mapProductOptions.mapProductOptions'+mapProductOptions);
                            System.debug('mapProductOptions.get(CornerProductName)'+mapProductOptions.get(CornerProductName));

                            if (oEB2.Open_Corners__c != 0 && mapProductOptions.get(CornerProductName) != null) {
                                oQuoteLine = new SBQQ__QuoteLine__c();                                oQuoteLine.SBQQ__Quote__c = objQuote.Id;
                                oQuoteLine.SBQQ__Product__c = mapProductOptions.get(CornerProductName).SBQQ__OptionalSKU__c; //CornerProduct.ID;
                                oQuoteLine.SBQQ__Quantity__c = oEB2.Open_Corners__c;
                                oQuoteLine.SBQQ__Number__c = quoteLineNumber;                                oQuoteLine.SBQQ__NonDiscountable__c = mapProductOptions.get(CornerProductName).SBQQ__OptionalSKU__r.SBQQ__NonDiscountable__c;
                                oQuoteLine.SBQQ__Hidden__c = mapProductOptions.get(CornerProductName).SBQQ__OptionalSKU__r.SBQQ__Hidden__c;
                                oQuoteLine.SBQQ__PricingMethodEditable__c = True;                                oQuoteLine.SBQQ__BundledQuantity__c = oEB2.Open_Corners__c;
                                oQuoteLine.Line_Description__c = oEB2.Booth_Number__c + '-' + oEB2.Booth_Type__c;
                                oQuoteLine.Booth_Number__c = oEB2.Booth_Number__c;                                oQuoteLine.Open_Corners__c = oEB2.Open_Corners__c;
                                oQuoteLine.Booth__c = true;                                oQuoteLine.Show_In_Show__c = oEB2.ShowInShow__c;
                                oQuoteLine.Booth_Pavilion__c = oEB2.Pavilion__c;                                oQuoteLine.Booth_Type__c = oEB2.Booth_Type__c;
                                oQuoteLine.Booth_Classes__c = oEB2.Booth_Classes__c;                                oQuoteLine.Booth_Product_Type__c = oEB2.Booth_Product_Type_EE__c;
                                oQuoteLine.Corner_Premium__c = true;                                oQuoteLine.SBQQ__OptionType__c = 'Component';
                                oQuoteLine.SBQQ__OptionLevel__c = 1;                                oQuoteLine.SBQQ__ProductOption__c = mapProductOptions.get(CornerProductName).Id;
                                lstQuoteLine.add(oQuoteLine);
                                quoteLineNumber++;
                            }
                        }
                    }
                    
                    oEB2.id = null;                    oEB2.Related_Opportunity__c = null;
                    oEB2.IsAssociatedBooth__c = true;                    oEB2.Opportunity__c = relatedOppty.id;
                    oEB2.Quote__c = objQuote.id;                    oEB2.User__c = userinfo.getuserid();
                    oEB2.Last_Action_Date__c = Date.today();                    lstHBtoAdd.add(oEB2);
                }
                //BK-3006
                if (lstQuoteLine.size() > 0 && lstPackageQuoteLine.size() > 0) {                    Map < String, Id > mapPackageprdIds = new Map < String, Id > ();
                                                                                insert lstPackageQuoteLine;                    for (SBQQ__QuoteLine__c oQLI : lstPackageQuoteLine) {                        mapPackageprdIds.put(oQLI.Booth_Number__c, oQLI.id);
                                                                                                                                                                                   }
                                                                                // Not best practice but SB is throwing SOQL 101 error, I'll remove this condition when test class is will be fixed
                                                                                if (!Test.isRunningTest()) {                        insert lstQuoteLine;                    }
                                                                                
                                                                                for (SBQQ__QuoteLine__c oQLI : lstQuoteLine) {                        oQLI.SBQQ__RequiredBy__c = mapPackageprdIds.get(oQLI.Booth_Number__c);
                                                                                                                             }
                                                                                update lstQuoteLine;
                                                                               }   
            }
            if (!lstHBtoAdd.isEmpty()) {                insert lstHBtoAdd;
                                       }
            /*
for(ExpocadBooth__c oEB : lstHBtoAdd){
If(oOpportunity.Exhibitor_Paid_By__c == 'Exhibitor Paid by Exhibitor' || oOpportunity.Exhibitor_Paid_By__c == 'Sub Agent Paid by Sub Agent' || oOpportunity.Exhibitor_Paid_By__c == 'SubAgent Paid by Exhibitor'){
ExpocadResponses.asyncUpdateExhibitorDetails(oEB.Booth_Number__c, oOpportunity.id, relatedOppty.Id, oOpportunity.SBQQ__PrimaryQuote__c, objQuote.Id, oOpportunity.EventEdition__r.Event_Code__c, oOpportunity.EventEdition__r.Expocad_API_Url__c, oEB.Display_Name__c);
}
}
*/
            if (relatedOppty.Id != null) {
                shouldRedirect = true;
                redirectUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + relatedOppty.Id;
            }
        } catch (exception ex) {
            system.debug('Line No::::::'+ex.getLineNumber());
            system.debug('Message::::::'+ex.getMessage());
            Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'createRelatedOppty(@Association_EB_Ctrl.Class)');
        }
        return null;
    }
    
    
    /**
* @description Getting all products for opportunity's event edition.
*/
    public void getBoothProducts() {
        try {
            mapProductOptions = new Map < String, SBQQ__ProductOption__c > ();
            mapProductOptionsId = new Map < Id, SBQQ__ProductOption__c > ();
            String sBoothPackagePrdName;
            BoothPackageProduct = new Product2();
            System.debug('oOpportunity.Event_Series__r.Package_Identifier__c'+oOpportunity.Event_Series__r.Package_Identifier__c);
            System.debug('oOpportunity.EventEdition__r.Booth_Bundle_Type__c'+oOpportunity.EventEdition__r.Booth_Bundle_Type__c);

            if (String.isNotBlank(oOpportunity.Event_Series__r.Package_Identifier__c)) {
                
                /*Changes done by Faisal for BK-23090*/
                if(String.isNotBlank(oOpportunity.EventEdition__r.Booth_Bundle_Type__c)){
                    sBoothPackagePrdName = oOpportunity.EventEdition__r.Booth_Bundle_Type__c+' '+oOpportunity.Event_Series__r.Package_Identifier__c;
                }
                else{
                    sBoothPackagePrdName = 'Booth Package ' + oOpportunity.Event_Series__r.Package_Identifier__c;
                }
                /*Changes done by Faisal for BK-23090*/
            }
            if (String.isNotBlank(sBoothPackagePrdName)) {
                List < Product2 > lstTemp = [SELECT Id, Name, Number_of_Corners__c, Booth_Product_Type__c, SBQQ__NonDiscountable__c, SBQQ__Hidden__c FROM Product2 where Name = : sBoothPackagePrdName AND Event_Edition_Name__c = : oOpportunity.EventEdition__r.Name order by createdDate ASC LIMIT 1];
                if (lstTemp != null && lstTemp.size() > 0) {
                    BoothPackageProduct = lstTemp.get(0);
                }
            }
            
            if (BoothPackageProduct.Id != null) {
                for (SBQQ__ProductOption__c oProductOption : [SELECT Id, SBQQ__OptionalSKU__c, SBQQ__OptionalSKU__r.Name, SBQQ__OptionalSKU__r.Expiry_Date__c, SBQQ__OptionalSKU__r.SBQQ__NonDiscountable__c, SBQQ__OptionalSKU__r.SBQQ__Hidden__c, SBQQ__OptionalSKU__r.Booth_Type__c, SBQQ__OptionalSKU__r.Show_In_Show__c, SBQQ__OptionalSKU__r.Booth_Pavilion__c, SBQQ__OptionalSKU__r.Booth_Class__c, SBQQ__OptionalSKU__r.Booth_Product_Type__c FROM SBQQ__ProductOption__c where SBQQ__ConfiguredSKU__c = : BoothPackageProduct.Id AND SBQQ__OptionalSKU__c != null LIMIT 1000]) {
                    mapProductOptions.put(oProductOption.SBQQ__OptionalSKU__r.Name, oProductOption);
                    mapProductOptionsId.put(oProductOption.Id, oProductOption);
                    if (oProductOption.SBQQ__OptionalSKU__r.Name.toLowerCase().contains('corner booth fee')) {                        CornerProductName = oProductOption.SBQQ__OptionalSKU__r.Name;
                                                                                                             }
                }
            }
        } catch (exception ex) {          Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'getBoothProducts(@Association_EB_Ctrl.Class)');            isShowMsg = True ;            sShowMsg = 'Please contact your system administrator to report this error' + '\n' + 'Debugged Error : ' + ex.getCause();        }
    }
    
    /**
* @description converting String value to double.
* @param sQuantity
* @return Double
*/
    public Double getQuantity(String sQuantity) {
        String sTempQuantity = sQuantity.substringBefore(' ');
        sTempQuantity = sTempQuantity.trim();
        return Double.valueof(sTempQuantity);
    }
    
    /**
* @description creates a dynamic picklist values for BoothProductType, Called by page "Expocad_Booth_Plan" and "Boothselectionlghtn"
* @return List <SelectOption>
*/
    public List < SelectOption > getBoothProductType() {
        List < SelectOption > lstSelectOption = new List < SelectOption > ();
        if (oOpportunity != null) {
            String sBoothType = oOpportunity.EventEdition__r.Booth_Product_Type__c;
            if (!String.isBlank(sBoothType)) {
                List < SelectOption > lstSelectOption2 = new List < SelectOption > ();
                for (String sTemp : sBoothType.split(';')) {
                    lstSelectOption2.add(new SelectOption(sTemp, sTemp));
                }
                lstSelectOption2.sort();
                for (Integer i = lstSelectOption2.size() - 1; i >= 0; i--) {
                    lstSelectOption.add(lstSelectOption2.get(i));                }            } else {                lstSelectOption.add(new SelectOption('No Product Type', 'No Product Type'));
                                                                                                     }
        }
        return lstSelectOption;
    }
    
    /**
* @description This method queries all Contact data according to the passed accountId
* @return PageReference
*/
    public pageReference getContact() {
        mapExistingContact = new Map < ID, Contact > ([SELECT Id, Name, Email, Phone FROM Contact WHERE AccountId = : selectedAccountId AND Inactive__c = false order by LastModifiedDate desc]);
        mapExistingContactSize = mapExistingContact.size();
        return null;
    }
    
    /**
* @description returns to a current Opportunity.
* @return PageReference
*/
    public pageReference returnToPT() {
        pageReference pg = new pageReference('/' + oOpportunity.Id);
        return pg;
    }
    
}