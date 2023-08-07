/**
* Project:     GAP
* Date:        Sep 22, 2017
* Created By:  Himanshu Jasuja
* Test Class:  ReplaceBoothCtrl_Test
* *************************************************************************
* Description: Controller to Reselling the Boots to Agent.
* *************************************************************************
* History:
* * Modified By Rajesh Kumar : 17 Jan 2019 T - GGCW-1797
* * Modified By Avinash Shukla for Jira Ticket GGCW-2999 on 01/02/2019
*   Modified By Avinash Shukla (Parent_opportunity__c, User_Type__r.Name fields to the Opportunity object Query, FOR BK-2896) 12-02-2020
*/

public class ReplaceBoothCtrl {

    /**
    * Member variables
    */
    public String sBoothID {get; set;}
    public ExpocadClasses.Booth oExpoBooth {get; set;}
    public Opportunity oOpportunity {get; set;}
    public Boolean isShowMsg {get; set;}
    public String sShowMsg {get; set;}
    public String sHost {get; set;}
    public Id opptyId {get; set;}
    private ApexPages.StandardController stdController;
    public List <SBQQ__QuoteLine__c> lstQLI {get; set;}
    public List <SBQQ__QuoteLine__c> lstRentQLI {get; set;}
    public Boolean shouldRedirect {public get; private set;}
    public String redirectUrl {public get; private set;}
    private Boolean isLightingEnv ;
    public List<ExpocadBooth__c> lstReferencedBN {get; set;}
    public List<ExpocadBooth__c> lstOfRentedBooth {get; set;}
    public List<ExpocadBooth__c> lstOfPavilionBooth {get; set;}
    public Double dTemparea {get; set;}
    public Double dAlreadyRentedArea {get; set;}
    public Double availArea {get; set;}
    public Set<string> setPavilion;
    public boolean boothCheck {get; set;}
    public Boolean isExbIDPresent {get; set;}
    public String lblBoothPavilionmessage {get; set;}
    public String lblBoothAreamessage {get; set;}
    public String lblBoothExhibitormessage {get; set;}
    public String lblBoothNonPavilionmessage {get; set;}
    public Boolean isProfileAccess {get; set;}
    public Boolean checkerror {get; set;}
    API_Detail__mdt apiMappings;
    public String API3EFloorplanToken {get; set;} 

    /**
    * Constructor, Getting required values for this class like, Opportunity.
    */
    public ReplaceBoothCtrl(ApexPages.StandardController controller) {
        this.stdController = controller;
        lstReferencedBN = new list<ExpocadBooth__c>();
        lstOfRentedBooth = new list<ExpocadBooth__c>();
        //lstOfPavilionBooth = new list<ExpocadBooth__c>();
        isShowMsg = isProfileAccess = checkerror =  false;
        shouldRedirect = false;
        lstRentQLI = new list<SBQQ__QuoteLine__c>();
        sHost = URL.getSalesforceBaseUrl().toExternalForm();
        opptyId = apexpages.currentpage().getparameters().get('id');
        isLightingEnv = Utility.isLightning(ApexPages.currentPage().getURL());
        Application_Bypass__c profilePermission = Application_Bypass__c.getInstance();
        if (profilePermission.Pavilion_Booth_Process__c) {
            isProfileAccess = True;
        }
        if (!String.isBlank(opptyId)) {
            List <Opportunity> lstOppo = [SELECT Id, StageName, Parent_opportunity__c, User_Type__r.Name, AccountId, EventEdition__r.Agent_Area_Margin__c, Account.Name, EventEdition__r.X3E_Status__c, EventEdition__r.X3E_Domain__c, EventEdition__r.X3E_API_ID__c, EventEdition__r.Event_Code__c, Billing_Contact__c, Exhibitor_Paid_By__c,  Event_Series__r.Package_Identifier__c, SBQQ__PrimaryQuote__c, EventEdition__r.Expocad_API_Url__c, EventEdition__r.Booth_Product_Type__c, EventEdition__r.Product_Type_Order__c FROM Opportunity WHERE Id = : opptyId];
            apiMappings =  [Select API_End_Point__c,API_Method__c,Password__c from API_Detail__mdt Where API_3rd_Party_Name__c=:Expocad3E_Wrapper.EXPOCAD3E and MasterLabel =:'GetFloorplanApiTokenExpo3E' limit 1];
            if (lstOppo != null && lstOppo.size() > 0) {
                oOpportunity = lstOppo.get(0);
                this.API3EFloorplanToken = apiMappings.Password__c;                    
            }
        }
        for (ExpocadBooth__c rBooth : [SELECT Id, Booth_Number__c, Dimensions__c, Status__c, Area__c, Pavilion__c, IsrentedByExhibitor__c, IsUnrentedByExhibitor__c FROM ExpocadBooth__c WHERE Opportunity__c = : oOpportunity.Id AND Status__c = 'Released' AND IsUnrentedByExhibitor__c = true  LIMIT 1000]) {
            lstReferencedBN.add(rBooth);
        }
    }

    /**
    * to get Expocad booth details, and list all matched products by Area and No. of corner.
    */
    public void checkFloorBooth() {
        try {
            sShowMsg = '';
            isShowMsg = false;
            sBoothID = apexpages.currentpage().getparameters().get('floorBoothId').escapeHtml4();
            String sAPIUrl = oOpportunity.EventEdition__r.Expocad_API_Url__c + '/booths?boothNumber=' + sBoothID.deleteWhitespace() + '&databaseName=' + oOpportunity.EventEdition__r.Event_Code__c;
            sAPIUrl = sAPIUrl.replace(' ', '%20');
            HttpResponse res = new ExpocadResponses().request(sAPIUrl, 'GET', '');
            String sReturn = res.getBody();
            if (res.getStatus() == null) { sShowMsg = System.Label.ExpoCAD_API_Down_Msg; isShowMsg = true;
            } else if (!String.isBlank(sReturn)) {
                oExpoBooth = (ExpocadClasses.Booth) JSON.deserialize(sReturn, ExpocadClasses.Booth.class);
                if (oExpoBooth.IsOnHold) { sShowMsg = System.Label.Booth_Is_Already_Held_Msg; isShowMsg = true;
                } else if (oExpoBooth.IsRented) { sShowMsg = System.Label.Booth_Is_Already_Rent_Msg; isShowMsg = true;
                }
            }
        } catch (exception ex) { Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'checkFloorBooth(@AddOrReplaceBooth.cls)');
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
    * The functionality is used to rent the booth.
    * @return pagereference
    */
    public pagereference rentBooth() {
        try {
            lblBoothAreamessage = System.Label.BoothArea;
            lblBoothExhibitormessage = System.Label.BoothExhibitor;
            if (oExpoBooth != null) { // && oExpoBooth.Pavilion != null
                ExpocadBooth__c oExpocad = new ExpocadBooth__c();
                oExpocad = getEB(oExpoBooth);
                isExbIDPresent = false ;
                dAlreadyRentedArea = 0.0;
                dTemparea = 0.0;
                availArea = 0.0;
                lstRentQLI = [SELECT id, Booth_Number__c, SBQQ__Quantity__c, Booth_Pavilion__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__r.SBQQ__Opportunity2__c = : opptyId and (NOT SBQQ__Product__r.Name like 'Booth Package%') and (NOT SBQQ__Product__r.Name  like 'Corner Booth Fee%' ) and SBQQ__Product__r.ExpoCAD_Product__c = true ];

                for (SBQQ__QuoteLine__c sbLineItem : lstRentQLI) {
                    dTemparea +=  sbLineItem.SBQQ__Quantity__c;
                }
                lstOfRentedBooth = [SELECT Id, Booth_Number__c, Pavilion__c, Status__c, Area__c, IsrentedByExhibitor__c, IsUnrentedByExhibitor__c FROM ExpocadBooth__c WHERE Opportunity__c = : oOpportunity.Id AND Status__c = 'Rented'];
                if (lstOfRentedBooth != null && lstOfRentedBooth.size() > 0 ) {
                    for (ExpocadBooth__c eBooth : lstOfRentedBooth) {
                        dAlreadyRentedArea += getQuantity(eBooth.Area__c);
                    }
                }
                availArea = dTemparea - dAlreadyRentedArea;
                //Modified By Avinash : GGCW-2999
                if (oOpportunity.Exhibitor_Paid_By__c != null) {
                    if (oOpportunity.EventEdition__r.Agent_Area_Margin__c != NULL && oOpportunity.EventEdition__r.Agent_Area_Margin__c > 0) {
                        //Modified By Avinash : GGCW-2999 : Adding area margin allowed from event edition.
                        availArea = availArea + oOpportunity.EventEdition__r.Agent_Area_Margin__c;
                        system.debug('oExpocad.Area__c'+oExpocad.Area__c);
                        system.debug('availArea'+availArea);
                        if (getQuantity(oExpocad.Area__c) > availArea) {
                            
                            checkerror = true; ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, lblBoothAreamessage)); return null;
                        }
                    } else {
                        if (getQuantity(oExpocad.Area__c) > availArea) { checkerror = true; ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, lblBoothAreamessage)); return null;
                        }
                    }
                }
				DateTime currentTime = System.now();
                isExbIDPresent = new BoothSelectionHlpr().ExbIDPresent(oOpportunity.EventEdition__r.Event_Code__c, oOpportunity , '');
                system.debug('isExbIDPresent'+isExbIDPresent);
                if (isExbIDPresent) {
                    String sUrlToRatePlan = oOpportunity.EventEdition__r.Expocad_API_Url__c + '/rateplans/default?databaseName=' + oOpportunity.EventEdition__r.Event_Code__c;
                    HttpResponse ratePlanRes = new ExpocadResponses().request(sUrlToRatePlan, 'GET', ''); String sReturn = ratePlanRes.getBody();
                    if (ratePlanRes.getStatus() == null) { sShowMsg = System.Label.ExpoCAD_API_Down_Msg; isShowMsg = true;
                    } else if (ratePlanRes.getStatusCode() == 200 && !String.isBlank(sReturn)) { ExpocadClasses.RatePlan oRentPlan = (ExpocadClasses.RatePlan)JSON.deserialize(sReturn, ExpocadClasses.RatePlan.class);
                        //Modified By Rajesh Kumar : 17 Jan 2019 T - GGCW-1797
                        String sUrlToRent = oOpportunity.EventEdition__r.Expocad_API_Url__c + '/booths/rent?boothNumber=' + sBoothID + '&exhibitorId=' + oOpportunity.AccountId + '&ratePlan=' + oRentPlan.Name + '&databaseName=' + oOpportunity.EventEdition__r.Event_Code__c + '&comment=' + oOpportunity.Id;
                        sUrlToRent = sUrlToRent.replace(' ', '%20');
                        HttpResponse rentRes = new ExpocadResponses().request(sUrlToRent, 'PUT', '');
                        if (rentRes.getStatus() == null) { 
							sShowMsg = System.Label.ExpoCAD_API_Down_Msg; 
							isShowMsg = true;
							ExpocadResponses.logFailedTransaction(sBoothID, oOpportunity.Id, oOpportunity.SBQQ__PrimaryQuote__c, 'Rent', '', 'API is not responding', currentTime, 'Fail', sUrlToRent, '', '');
                        } else if (rentRes.getStatusCode() == 200) { 
							currentTime = System.now();
							oExpocad.Status__c = 'Rented';
                            oExpocad.IsrentedByExhibitor__c = true;
                            insert oExpocad; return returnToPT();
							ExpocadResponses.logFailedTransaction(sBoothID,oOpportunity.Id, oOpportunity.SBQQ__PrimaryQuote__c, 'Rent', String.valueOf(rentRes.getStatusCode()), rentRes.getBody(), currentTime, 'Success', sUrlToRent, rentRes.getStatus(), '');
                        }
                    }
                } else { sShowMsg = 'Exhibitor is not found/created.'; isShowMsg = true;
                }
            } else { ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, lblBoothExhibitormessage));
            }
        } catch (exception ex) { Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'CheckFloorBooth(@ReplaceBoothCtrl.cls)');
        }
        return null;
    }

    /**
    * Type Casting Booth Details parameter in ExpocadBooth__c Object.
    * @param  oExpoBooth [ExpocadClasses.Booth ref]
    * @param  sPrdName   [Selected Product Name By User]
    * @return ExpocadBooth__c
    */
    public ExpocadBooth__c getEB(ExpocadClasses.Booth oExpoBooth) {
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
        oExpocad.Quote__c = oOpportunity.SBQQ__PrimaryQuote__c;
        oExpocad.Opportunity__c = oOpportunity.Id;
        oExpocad.ShowInShow__c = oExpoBooth.ShowInShow;
        oExpocad.Pavilion__c = oExpoBooth.Pavilion;
        oExpocad.Booth_Classes__c = string.join(oExpoBooth.BoothClasses, ';;');
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
}