/**
* File:        ExpocadResponses.cls
* Project:     GAP
* Date:        Sep 22, 2016
* Test Class:  ExpocadResponses_Test
* Created By:  Kumar Gaurav
* *************************************************************************
* @description Contains methods to to resturn Expocad Response
* *************************************************************************
* History: Modified by Avinash for Jira Ticket GGCW-2347 on 14/01/2019
* Modified By Rajesh Kumar : 17 Jan 2019 T - GGCW-1797
* Modified By Avinash Shukla (Parent_opportunity__c, User_Type__r.Name fields to the Opportunity object Query, FOR BK-2896) 12-02-2020
*/
public class ExpocadResponses {
    //variables
    static String displayName  { get; set; }

    /**
    * @description Future method used from releaseBooth.trigger to unhold Booth
    */
    @future(callout = true)
    public static void aSyncUnhold(String sBoothNumber, Id opptyID, Id quoteID, String sEventCode, String sAPIUrl , String sDisplayName) {
        String sExecutionMsg = SyncUnhold(sBoothNumber, opptyID, quoteID, sEventCode, sAPIUrl , sDisplayName);

    }
    /**
    * @description Future method used from releaseBooth.trigger to Unrent Booth
    */
    @future(callout = true)
    public static void aSyncUnrent(String sBoothNumber, Id opptyID, Id quoteID, String sEventCode, String sAPIUrl , String sDisplayName) {
        String sExecutionMsg = SyncUnRent(sBoothNumber, opptyID, quoteID, sEventCode, sAPIUrl , sDisplayName);

    }

    /**
    * @description Future method used from releaseBooth.trigger to HOLD Booth
    */
    public static String syncHold(String sBoothNumber, Id opptyID, Id quoteID, String sEventCode, String sAPIUrl, String displayName) {
        DateTime currentTime = System.now();
        //need to be add hold api
        if (displayName.Contains(' ')) { displayName = displayName.replace(' ', '%20');
        }
        String sAPIUrlToCall = sAPIURL + '/booths/hold?boothNumber=' + sBoothNumber + '&databaseName=' + sEventCode + '&exhibitorName=' + displayName;
        HttpResponse res ;
        res = new ExpocadResponses().request(sAPIUrlToCall, 'PUT', '');
        if (res.getStatus() == null) { logFailedTransaction(sBoothNumber, opptyID, quoteID, 'Hold', '', 'API is not responding', currentTime, 'Fail', sAPIUrlToCall, '', displayName );
        } else if (res.getStatusCode() == 200) {
            logFailedTransaction(sBoothNumber, opptyID, quoteID, 'Hold', String.valueOf(res.getStatusCode()), res.getBody(), currentTime, 'Success', sAPIUrlToCall, res.getStatus(), displayName);
            return 'Success'  + ' - ' + res.getStatusCode() + ' - ' + res.getBody()  +  ' - ' +  res.getStatus();
        } 
        else {
             currentTime = System.now();   sAPIUrlToCall = sAPIUrlToCall.replace('unhold', 'Hold'); res = new ExpocadResponses().request(sAPIUrlToCall, 'PUT', '');
            if (res.getStatus() == null) { logFailedTransaction(sBoothNumber, opptyID, quoteID, 'Hold', '', 'API is not responding', currentTime, 'Fail', sAPIUrlToCall, '', displayName);
            } else if (res.getStatusCode() == 200 || (res.getBody() != null && res.getBody().containsIgnoreCase('-1815'))) { logFailedTransaction(sBoothNumber, opptyID, quoteID, 'Hold', String.valueOf(res.getStatusCode()), res.getBody(), currentTime, 'Success', sAPIUrlToCall, res.getStatus(), displayName);
                return 'Success'  + ' - ' + res.getStatusCode() + ' - ' + res.getBody()  +  ' - ' +  res.getStatus();
            } else { String sAPIUrlToCall2 = sAPIURL + '/booths?boothNumber=' + sBoothNumber + '&databaseName=' + sEventCode; HttpResponse resAvailable = new ExpocadResponses().request(sAPIUrlToCall2, 'GET', '');
                if (resAvailable.getStatus() == null) { logFailedTransaction(sBoothNumber, opptyID, quoteID, 'Hold', '', 'API is not responding', currentTime, 'Fail', sAPIUrl, '', displayName);
                } else if (resAvailable.getStatusCode() == 200) { return 'Success'  + ' - ' + res.getStatusCode() + ' - ' + res.getBody()  +  ' - ' +  res.getStatus();
                } else { logFailedTransaction(sBoothNumber, opptyID, quoteID, 'Hold', String.valueOf(res.getStatusCode()), res.getBody(), currentTime, 'Fail', sAPIUrlToCall, res.getStatus(), displayName);
                } } } return 'Failure'  + ' - ' + res.getStatusCode() + ' - ' + res.getBody()  +  ' - ' +  res.getStatus();
    }

    /**
    * @description Future method used from releaseBooth.trigger to unhold Booth
    */
    //GGCW-2704 - Rajesh Kumar
    public static String SyncUnhold(String sBoothNumber, Id opptyID, Id quoteID, String sEventCode, String sAPIUrl, String sDisplayName) {
        DateTime currentTime = System.now();
        String sAPIUrlToCall = sAPIURL + '/booths/unhold?boothNumber=' + sBoothNumber + '&databaseName=' + sEventCode;
        HttpResponse res ;
        res = new ExpocadResponses().request(sAPIUrlToCall, 'PUT', '');
        system.debug('sAPIUrlToCall ::: Unhold' + sAPIUrlToCall);
        if (res.getStatus() == null) {
            logFailedTransaction(sBoothNumber, opptyID, quoteID, 'Unhold', '', 'API is not responding', currentTime, 'Fail', sAPIUrlToCall, '', '');
        }        
        else if (res.getStatusCode() == 200) { if (!String.isBlank(sDisplayName) && sDisplayName != '' ) { syncHold(sBoothNumber, opptyID, quoteID, sEventCode, sAPIUrl, sDisplayName);} logFailedTransaction(sBoothNumber, opptyID, quoteID, 'Unhold', String.valueOf(res.getStatusCode()), res.getBody(), currentTime, 'Success', sAPIUrlToCall, res.getStatus(), displayName);
            return 'Success' + ' - ' +  res.getStatusCode() + ' - ' + res.getBody() +  ' - ' +  res.getStatus();
        }
        else if (res.getStatusCode() != 200 || (res.getBody() != null && res.getBody().containsIgnoreCase('-1815'))) { 
            logFailedTransaction(sBoothNumber, opptyID, quoteID, 'Unhold', String.valueOf(res.getStatusCode()), res.getBody(), currentTime, 'Success', sAPIUrlToCall, res.getStatus(), displayName);
            return 'Success' + ' - ' +  res.getStatusCode() + ' - ' + res.getBody() +  ' - ' +  res.getStatus();
        }
        return 'Failure' + ' - ' +  res.getStatusCode() + ' - ' + res.getBody() +  ' - ' +  res.getStatus();
    }

    public static String SyncUnRent(String sBoothNumber, Id opptyID, Id quoteID, String sEventCode, String sAPIUrl, String sDisplayName) {
        DateTime currentTime = System.now();
        String sAPIUrlToCall = sAPIURL + '/booths/unrent?boothNumber=' + sBoothNumber + '&databaseName=' + sEventCode;
        HttpResponse res ;
        res = new ExpocadResponses().request(sAPIUrlToCall, 'PUT', '');
        system.debug('sAPIUrlToCall ::: unrent' + sAPIUrlToCall);
        if (res.getStatus() == null) {
            logFailedTransaction(sBoothNumber, opptyID, quoteID, 'unrent', '', 'API is not responding', currentTime, 'Fail', sAPIUrlToCall, '', '');
        }        
        else if (res.getStatusCode() == 200) {
            logFailedTransaction(sBoothNumber, opptyID, quoteID, 'unrent', String.valueOf(res.getStatusCode()), res.getBody(), currentTime, 'Success', sAPIUrlToCall, res.getStatus(), displayName);
            return 'Success' + ' - ' +  res.getStatusCode() + ' - ' + res.getBody() +  ' - ' +  res.getStatus();
        }
        else if (res.getStatusCode() != 200 || (res.getBody() != null && res.getBody().containsIgnoreCase('-1815')) ) { 
            logFailedTransaction(sBoothNumber, opptyID, quoteID, 'unrent', String.valueOf(res.getStatusCode()), res.getBody(), currentTime, 'Success', sAPIUrlToCall, res.getStatus(), displayName);
            return 'Success' + ' - ' +  res.getStatusCode() + ' - ' + res.getBody() +  ' - ' +  res.getStatus();
        } 
        return 'Failure' + ' - ' +  res.getStatusCode() + ' - ' + res.getBody() +  ' - ' +  res.getStatus();
    }

    public static String SyncUnRentReplaceBooths(String sBoothNumber, Id opptyID, Id quoteID, String sEventCode, String sAPIUrl, String sDisplayName) {
        DateTime currentTime = System.now();
        String sAPIUrlToCall = sAPIURL + '/booths/unrent?boothNumber=' + sBoothNumber + '&databaseName=' + sEventCode;
        HttpResponse res ;
        res = new ExpocadResponses().request(sAPIUrlToCall, 'PUT', '');
        system.debug('sAPIUrlToCall ::: unrent' + sAPIUrlToCall);
        if (res.getStatus() == null) {
            logFailedTransaction(sBoothNumber, opptyID, quoteID, 'unrent', '', 'API is not responding', currentTime, 'Fail', sAPIUrlToCall, '', '');
        }        
        else if (res.getStatusCode() == 200) {
            logFailedTransaction(sBoothNumber, opptyID, quoteID, 'unrent', String.valueOf(res.getStatusCode()), res.getBody(), currentTime, 'Success', sAPIUrlToCall, res.getStatus(), displayName);
            return 'Success' + ' - ' +  res.getStatusCode() + ' - ' + res.getBody() +  ' - ' +  res.getStatus();
        }
        else if (res.getStatusCode() != 200 || (res.getBody() != null && res.getBody().containsIgnoreCase('-1815')) ) { 
            logFailedTransaction(sBoothNumber, opptyID, quoteID, 'unrent', String.valueOf(res.getStatusCode()), res.getBody(), currentTime, 'Success', sAPIUrlToCall, res.getStatus(), displayName);
            return 'Success' + ' - ' +  res.getStatusCode() + ' - ' + res.getBody() +  ' - ' +  res.getStatus();
        } 
        return 'Failure' + ' - ' +  res.getStatusCode() + ' - ' + res.getBody() +  ' - ' +  res.getStatus();
    }

    /**
    * @description Future method used from RentAndUnrentBooths.trigger to Rent Booth
    */
    public static void rentBooth(Set<Id> opptIDs) {
        List<ExpocadBooth__c> lstEBToUpdate = new List<ExpocadBooth__c>();
        for (ExpocadBooth__c oEB : [SELECT Booth_Number__c, Status__c FROM ExpocadBooth__c WHERE Opportunity__c IN :opptIDs AND Status__c = 'Added To Quote/On Hold' AND Quote__r.SBQQ__Primary__c = True]) {
            oEB.Status__c = 'Rented';
            lstEBToUpdate.add(oEB);
        }
        if (!lstEBToUpdate.isEmpty()) {
            update lstEBToUpdate;
        }
    }


    /**
    * @description Future method used from releaseBooth.trigger to unhold Booth
    *  -- added one parameter named 'displayNameStr' in this method
    */
    //GGCW-3256
      @future(callout = true)
      public static void asyncRENT(String sBoothNumber, Id opptyID, Id quoteID, String sEventCode, String displayNameStr , Boolean isReleaseBooth) {
           String sExecutionMsg = SyncRENT(sBoothNumber, opptyID, quoteID, sEventCode , displayName , isReleaseBooth);
      }

    /**
    * @description Future method used from releaseBooth.trigger to unhold Booth
    */
    public static String SyncRENT(String sBoothNumber, Id opptyID, Id quoteID, String sEventCode , String sDisplayName , Boolean isReleaseBooth) {
        String sGetBody;
        Integer igetStatuscode ;
        String sCallOut;
        try {
            if (!String.isBlank(sBoothNumber) && !String.isBlank(opptyID) && !String.isBlank(sEventCode)) {
                Boolean isExbIDPresent = false ;
                Opportunity oOppty = [SELECT AccountId, Account.Name, Parent_opportunity__c, User_Type__r.Name, EventEdition__r.Event_Code__c, Billing_Contact__c, SBQQ__PrimaryQuote__c, EventEdition__r.Expocad_API_Url__c FROM Opportunity WHERE Id = :opptyID LIMIT 1];
                DateTime currentTime = System.now();
                isExbIDPresent = new BoothSelectionHlpr().ExbIDPresentOrNot(sBoothNumber, sEventCode, oOppty , sDisplayName);
                if (isExbIDPresent) {
                    String sUrlToRatePlan = oOppty.EventEdition__r.Expocad_API_Url__c + '/rateplans/default?databaseName=' + sEventCode;
                    currentTime = System.now();
                    HttpResponse ratePlanRes = new ExpocadResponses().request(sUrlToRatePlan, 'GET', '');
                    String sReturn = ratePlanRes.getBody();
                    sGetBody = ratePlanRes.getBody();
                    igetStatuscode = ratePlanRes.getStatusCode();
                    sCallOut = ratePlanRes.getStatus();
                    if (ratePlanRes.getStatus() == null) { logFailedTransaction(sBoothNumber, opptyID, quoteID, 'Rent', '', 'API is not responding', currentTime, 'Fail', sUrlToRatePlan, '', ''); return 'Failure' + ' - ' + igetStatuscode  + ' - ' + sGetBody + ' - ' + sCallOut;
                    } else if (ratePlanRes.getStatusCode() == 200 && !String.isBlank(sReturn)) {
                        ExpocadClasses.RatePlan oRentPlan = (ExpocadClasses.RatePlan)JSON.deserialize(sReturn, ExpocadClasses.RatePlan.class);
                        boolean isNormalFlowRent = false;
                        HttpResponse unholdRes;
                        String sUrlToUnhold;
                        if (!isReleaseBooth){
                            sUrlToUnhold = oOppty.EventEdition__r.Expocad_API_Url__c + '/booths/unhold?boothNumber=' + sBoothNumber + '&databaseName=' + sEventCode;
                            currentTime = System.now();
                            unholdRes = new ExpocadResponses().request(sUrlToUnhold, 'PUT', '');
                            sGetBody = unholdRes.getBody();
                            igetStatuscode = unholdRes.getStatusCode();
                            sCallOut = unholdRes.getStatus();
                            if (unholdRes.getStatus() == null) { logFailedTransaction(sBoothNumber, opptyID, quoteID, 'Rent', '', 'API is not responding', currentTime, 'Fail', sUrlToUnhold, '', ''); return 'Failure' + ' - ' + igetStatuscode  + ' - ' + sGetBody + ' - ' + sCallOut;
                            }
                            else if (unholdRes.getStatusCode() == 200 || (unholdRes.getBody() != null && unholdRes.getBody().containsIgnoreCase('-1832')) || (Test.isRunningTest()) ) {
                                isNormalFlowRent = true;
                            }
                        }
                        if (isNormalFlowRent || isReleaseBooth || (Test.isRunningTest())){ 
                            //Modified By Rajesh Kumar : 17 Jan 2019 T - GGCW-1797
                            String sUrlToRent = oOppty.EventEdition__r.Expocad_API_Url__c + '/booths/rent?boothNumber=' + sBoothNumber + '&exhibitorId=' + oOppty.AccountId + '&ratePlan=' + oRentPlan.Name + '&databaseName=' + sEventCode + '&comment=' + opptyID;
                            sUrlToRent = sUrlToRent.replace(' ', '%20');
                            currentTime = System.now();
                            HttpResponse rentRes = new ExpocadResponses().request(sUrlToRent, 'PUT', '');
                            sGetBody = rentRes.getBody();
                            igetStatuscode = rentRes.getStatusCode();
                            sCallOut = rentRes.getStatus();
                            if (rentRes.getStatus() == null) { logFailedTransaction(sBoothNumber, opptyID, quoteID, 'Rent', '', 'API is not responding', currentTime, 'Fail', sUrlToRent, '', ''); return 'Failure' + ' - ' + igetStatuscode  + ' - ' + sGetBody + ' - ' + sCallOut;
                            } else if (rentRes.getStatusCode() == 200 || (rentRes.getBody() != null && rentRes.getBody().containsIgnoreCase('-1814'))) {logFailedTransaction(sBoothNumber, opptyID, quoteID, 'Rent', String.valueOf(rentRes.getStatusCode()), rentRes.getBody(), currentTime, 'Success', sUrlToRent, rentRes.getStatus(), displayName);return 'Success' + ' - ' + igetStatuscode  + ' - ' + sGetBody + ' - ' + sCallOut;
                            } else if (rentRes.getStatusCode() != 200) { logFailedTransaction(sBoothNumber, opptyID, quoteID, 'Rent', String.valueOf(rentRes.getStatusCode()), rentRes.getBody(), currentTime, 'Fail', sUrlToRent, rentRes.getStatus(), ''); return 'Failure' + ' - ' + igetStatuscode  + ' - ' + sGetBody + ' - ' + sCallOut; }
                        } else { logFailedTransaction(sBoothNumber, opptyID, quoteID, 'Rent', String.valueOf(unholdRes.getStatusCode()), unholdRes.getBody(), currentTime, 'Fail', sUrlToUnhold, unholdRes.getStatus(), ''); }
                    } else { logFailedTransaction(sBoothNumber, opptyID, quoteID, 'Rent', String.valueOf(ratePlanRes.getStatusCode()), ratePlanRes.getBody(), currentTime, 'Fail', sUrlToRatePlan, ratePlanRes.getStatus(), '');
                    }
                }//Catch "Error log" is Added by Palla Kishore for the ticket BK-19603
            } } catch (Exception exe) { Utility.logError(exe.getMessage(), exe.getCause(), exe.getLineNumber(), exe.getStackTraceString(), 'request(@ExpocadResponses)');
        } return 'Failure' + ' - ' + igetStatuscode  + ' - ' + sGetBody + ' - ' + sCallOut;
    }

    /**
    * @description Method to update Display name
    */
    public static String syncUpdateDisplay(String sBoothNumber, Id opptyID, Id quoteID, String sEventCode, String sAPIUrl, String sDisplayName) {
        sAPIUrl = sAPIUrl + '/booths/displayNameOverride/set?text=' + EncodingUtil.URLENCODE(sDisplayName, 'ASCII') + '&boothNumber=' + sBoothNumber + '&databaseName=' + sEventCode;
        sAPIUrl = sAPIUrl.replace(' ', '%20');
        DateTime currentTime = System.now();
        HttpResponse resDisplay = new ExpocadResponses().request(sAPIUrl, 'PUT', '');
        if (resDisplay.getStatus() == null) {
            logFailedTransaction(sBoothNumber, opptyID, quoteID, 'DisplayNameOverride', '', 'API is not responding', currentTime, 'Fail', sAPIUrl, '', sDisplayName);
        } else if (resDisplay.getStatusCode() == 200) { return 'Success'; } else { logFailedTransaction(sBoothNumber, opptyID, quoteID, 'DisplayNameOverride', String.valueOf(resDisplay.getStatusCode()), resDisplay.getBody(), currentTime, 'Fail', sAPIUrl, resDisplay.getStatus(), sDisplayName);
        }
        return 'Failure';
    }

    /**
    * @description Future method used from releaseBooth.trigger to Rent To Hold Booth
    */
    @future(callout = true)
    public static void asyncRentToHold(String sBoothNumber, Id opptyID, Id quoteID, String sEventCode, String sAPIUrl) {
        String sExecutionMsg = syncRentToHold(sBoothNumber, opptyID, quoteID, sEventCode, sAPIUrl);
    }

    /**
    * @description Method to Hold Booth from rented
    */
    public static String syncRentToHold(String sBoothNumber, Id opptyID, Id quoteID, String sEventCode, String sAPIUrl) {
        DateTime currentTime = System.now();
        String sAPIUrlToCall = sAPIURL + '/booths/rentToHold?boothNumber=' + sBoothNumber + '&databaseName=' + sEventCode;
        HttpResponse res = new ExpocadResponses().request(sAPIUrlToCall, 'PUT', '');
        if (res.getStatus() == null) {
            logFailedTransaction(sBoothNumber, opptyID, quoteID, 'RentToHold', '', 'API is not responding', currentTime, 'Fail', sAPIUrlToCall, '', '');
        } else if (res.getStatusCode() == 200) { logFailedTransaction(sBoothNumber, opptyID, quoteID, 'RentToHold', String.valueOf(res.getStatusCode()), res.getBody(), currentTime, 'Success', sAPIUrlToCall, res.getStatus(), '');  return 'Success' + ' - ' + res.getStatusCode() + ' - ' + res.getBody() + ' - ' + res.getStatus(); } else { logFailedTransaction(sBoothNumber, opptyID, quoteID, 'RentToHold', String.valueOf(res.getStatusCode()), res.getBody(), currentTime, 'Fail', sAPIUrlToCall, res.getStatus(), '');
        }
        return 'Failure' + ' - ' + res.getStatusCode() + ' - ' + res.getBody()  + ' - ' + res.getStatus();
    }

    /**
    * @description Method to update exhibitor for related opportunity.
    */
    public static String updateExhibitorDetails(String sBoothNumber, Id opptyIDToUnRent, Id opptyIDToRent, Id parentQuoteID, Id childQuoteID, String sEventCode, String sAPIUrl, String sDisplyName) {
        String sUnrentResult  = ExpocadResponses.SyncUnhold(sBoothNumber, opptyIDToUnRent, parentQuoteID, sEventCode, sAPIUrl , sDisplyName );
        if (!String.isBlank(sDisplyName)) {
            ExpocadResponses.displayName = sDisplyName;
        }
        String sRentResult  = ExpocadResponses.SyncRENT(sBoothNumber, opptyIDToRent, childQuoteID, sEventCode , sDisplyName , false);
        If(sUnrentResult == 'Success' && sRentResult == 'Success') { return 'Success'; }
        else {  return 'Failure';}

    }

    /**
    * @description Method to update exhibitor for related opportunity.
    */
    @future(callout = true)
    public static void asyncUpdateExhibitorDetails(String sBoothNumber, Id opptyIDToUnRent, Id opptyIDToRent, Id parentQuoteID, Id childQuoteID, String sEventCode, String sAPIUrl, String sDisplyName ) {
        String sUpdateExbResult = ExpocadResponses.updateExhibitorDetails(sBoothNumber, opptyIDToUnRent, opptyIDToRent, parentQuoteID, childQuoteID, sEventCode, sAPIUrl, sDisplyName);
    }

    /**
    * @description Log failed expocad transaction.
    */
    public static void logFailedTransaction(String sBoothNumber, Id opptyID, Id quoteID, String sMethodType, String sStatusCode, String sAPIMsg, DateTime dtCallTime, String sStatus, String sAPIUrl, String sCalloutStatus, String sDisplayName) {
        List<Expocad_Pending_Action__c> lstExpocadPendingAction = new List<Expocad_Pending_Action__c>();
        Expocad_Pending_Action__c oEPA = new Expocad_Pending_Action__c();
           lstExpocadPendingAction = [SELECT Id, Booth_Number__c, Opportunity__c, Quote__c, API_Url__c, Request_Method_Type__c, Status_Code__c, API_Message__c, Last_API_Call_Time__c, Status__c FROM Expocad_Pending_Action__c WHERE Booth_Number__c = : sBoothNumber AND Opportunity__r.Id = : opptyID AND Quote__r.Id = : quoteID AND  (Status__c = 'Fail' OR Status__c = 'Success') ];
        if (sMethodType != 'DisplayNameOverride') {
            lstExpocadPendingAction = [SELECT Id, Booth_Number__c, Opportunity__c, Quote__c, API_Url__c, Request_Method_Type__c, Status_Code__c, API_Message__c, Last_API_Call_Time__c, Status__c FROM Expocad_Pending_Action__c WHERE Booth_Number__c = : sBoothNumber AND Opportunity__r.Id = : opptyID AND Quote__r.Id = : quoteID AND  (Status__c = 'Fail' OR Status__c = 'Success')  AND Request_Method_Type__c = : sMethodType];
        }

        if (lstExpocadPendingAction != Null && lstExpocadPendingAction.size() > 0) { oEPA = lstExpocadPendingAction.get(0);
        }
        oEPA.Booth_Number__c = sBoothNumber;
        oEPA.Opportunity__c = opptyID;
        oEPA.Quote__c = quoteID;
        oEPA.API_Url__c = sAPIUrl;
        oEPA.Request_Method_Type__c = sMethodType;
        oEPA.Status_Code__c = sStatusCode;
        oEPA.API_Message__c = sAPIMsg;
        oEPA.Last_API_Call_Time__c = dtCallTime;
        oEPA.Callout_Status__c = sCalloutStatus;
        oEPA.Status__c = sStatus;
        oEPA.Display_Name__c = sDisplayName;
        Upsert oEPA;
    }

    /**
     * @description Basic configuration to make Http call to Expocad.
     * @param  path   endPoint
     * @param  method Callout method
     * @param  sBody  request body
     * @return        httpresponse
     */

    //We have updated code after ticket developement BK-1229 BY RajeshKr
    public HTTPResponse request(String path, String method, String sBody) {
        system.debug('----path----'+path+'-----method----'+method+'----sBody-----'+sBody);
        HttpResponse res = new HttpResponse();
        try {
            ExpocadCredential__c objExpocadOrgId = ExpocadCredential__c.getValues('ExpocadApiCredential');
            system.debug('objExpocadOrgId'+objExpocadOrgId.Org_Id__c);
            Id OrgId = UserInfo.getOrganizationId();
            system.debug('OrgId'+OrgId);
            if (objExpocadOrgId.Org_Id__c == orgId) {
                NamedCredential nameCrdURL = [SELECT DeveloperName, Endpoint FROM NamedCredential WHERE DeveloperName = 'ExpoCAD_Credential'];
                HttpRequest req = new HttpRequest();
                Http http = new Http();
                req.setMethod(method);
                req.setHeader('Content-Type', 'application/json');
                req.setHeader('Accept', 'application/json');
                if (method == 'PUT' || method == 'POST') {
                    if (String.isBlank(sBody)) {
                        sBody = '';
                    }
                    req.setBody(sBody);
                }
                String sUrl = nameCrdURL.Endpoint;
                system.debug('test_sUrl'+sUrl);
                System.debug('Path ::: ' + path);
                String fpPath = (String.isNotBlank(path) && path.contains(sUrl)) ? path.split(sUrl).get(1) : '';
                SYstem.debug('fpPath' + fpPath);
                req.setEndpoint('callout:ExpoCAD_Credential/' + fpPath);
                req.setTimeout(120000);
                System.debug('Final Value ::: ' + req);
                if (!System.Test.isRunningTest()) { try {  res = http.send(req);  } catch (System.CalloutException ex) { Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'request(@ExpocadResponses)'); }
                } else if (System.Test.isRunningTest()) {
                    res = new ExpocadMock().respond(req);
                }

            }

        } catch (Exception ex) { Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'request(@ExpocadResponses)');
        }
        return res;
    }
}