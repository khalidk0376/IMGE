/**
* File:        BoothSelectionHlpr.cls
* Project:     GAP
* Date:        Sep 06, 2016
* Created By:  Kumar Gaurav
* Test Run : BoothSelectionHlpr_Test(85%)
* *************************************************************************
* Description: Helper Controller for BoothSelectionCtrl.
* *************************************************************************
* History:
* Modified By Avinash : GGCKB-154 17/06/2019
* Modified By Avinash : BK-2896 11/02/2020
* Modified By Avinash Shukla (Parent_opportunity__c, User_Type__r.Name fields to the Opportunity object Query, FOR BK-2896) 12-02-2020
*/

Public class BoothSelectionHlpr {


    /**
    * Calling for ExhibitorId
    * @Param sExocadDB, oOpportunity
    * @return Boolean
    */
    Public Boolean ExbIDPresentOrNot(String sBoothNumber, String sExocadDB, Opportunity oOpportunity , String sDisplayNames) {
        return createExibitor(sBoothNumber, sExocadDB, oOpportunity , sDisplayNames);
    }

    /**
    * Checking for ExhibitorId
    * @Param sExocadDB, oOpportunity, BoothNumber
    * @return Boolean
    */
    Public Boolean ExbIDPresent(String sExocadDB, Opportunity oOpportunity, String sDisplayNames) {
        return createExibitor('', sExocadDB, oOpportunity, sDisplayNames);
    }

    /*
    * Calling future class for adding co- exhibitor after create related opportunity
    @param , Expocad booth Number , Event code , related opportunity id , Quote id , Account id and Expocad URL

    */

    @future(callout = true)
    public static void AsyncExhibitor(String sBoothNumber, String sExocadDB, Id oOpportunity , Id oQuote , Id relOppAccId  , String sAPIUrl , String sDisplayNames) {
        String  sExecutionMsg  = createCoExibitor (sBoothNumber, sExocadDB, oOpportunity , oQuote , relOppAccId, sAPIUrl, sDisplayNames);
    }

    @future(callout = true)
    public static void AsyncRemoveExhibitor(String sBoothNumber, String sExocadDB, Id oOpportunity , Id oQuote , Id relOppAccId  , String sAPIUrl) {
        String sExecutionMsg =  RemoveCoExibitor (sBoothNumber, sExocadDB, oOpportunity , oQuote , relOppAccId, sAPIUrl );
    }

    /**
    * Checking for ExhibitorId (i.e. SF AccountId), that is registerd in Expocad or not if not than creating a Exhibitor to Expocad using API
    * @Param sExocadDB, oOpportunity
    * @return Boolean
    */
    public Boolean createExibitor(String sBoothNumber, String sExocadDB, Opportunity oOpportunity , String sDisplayNames) {
        Boolean isExbIDPresent = false;
        String sExhibitorDrawingName = '';
        String sComment2Name = '';
        Boolean isRented = false;
        try {
            //Modified by Avinash GGCKB-154
            List<Opportunity_ExpoCAD_Booth_Mapping__c> oppoExpMap = new List<Opportunity_ExpoCAD_Booth_Mapping__c>();
            oppoExpMap = [Select Id , Account__r.Name , Display_Name__c , Opportunity__r.User_Type__r.Name FROM Opportunity_ExpoCAD_Booth_Mapping__c WHERE Opportunity__c = : oOpportunity.Id LIMIT 1];
            If(!oppoExpMap.isEmpty()) {
                if (!String.isBlank(oppoExpMap[0].Display_Name__c)) {
                    sExhibitorDrawingName = subString(oppoExpMap[0].Display_Name__c, 50);
                } else { sExhibitorDrawingName = subString(oppoExpMap[0].Account__r.Name, 50);
                }
                //Modified By Avinash : BK-2896 11/02/2020
                if (oppoExpMap[0].Opportunity__r.User_Type__r.Name == 'Agent' ) { sComment2Name = oppoExpMap[0].Opportunity__r.User_Type__r.Name;
                }
            }
            else { sExhibitorDrawingName = subString(oOpportunity.Account.Name, 50);
            }
            if (oOpportunity.Parent_Opportunity__c == null && oOpportunity.User_Type__r.Name == 'Agent') { sComment2Name = oOpportunity.User_Type__r.Name;
            }
            //Modified by Avinash GGCKB-154
            String sAPIUrl = oOpportunity.EventEdition__r.Expocad_API_Url__c + '/exhibitors?id=' + oOpportunity.AccountId + '&databaseName=' + sExocadDB;
            DateTime currentTime = System.now();
            HttpResponse res = new ExpocadResponses().request(sAPIUrl, 'GET', '');
            if (res.getStatus() == null && !String.isBlank(sBoothNumber)) { ExpocadResponses.logFailedTransaction(sBoothNumber, oOpportunity.Id, oOpportunity.SBQQ__PrimaryQuote__c, 'Rent', '', 'API is not responding', currentTime, 'Fail', sAPIUrl, '', ''); return isExbIDPresent;
            }
            if (res.getStatusCode() == 200 && res.getBody() != null) {
                isRented = true; RemovedCoExhibitorClosedLost_class.updateDisplayDrawingNameToExibitors(sBoothNumber, sExocadDB, oOpportunity.Id , sExhibitorDrawingName , isRented, sComment2Name);
                isExbIDPresent = true; return isExbIDPresent;
            }
            if (!isExbIDPresent && res.getStatusCode() != 404) { ExpocadResponses.logFailedTransaction(sBoothNumber, oOpportunity.Id, oOpportunity.SBQQ__PrimaryQuote__c, 'Rent', String.valueOf(res.getStatusCode()), res.getBody(), currentTime, 'Fail', sAPIUrl, res.getStatus(), '');
            }
            if (!isExbIDPresent && res.getStatusCode() == 404) {
                ExpocadClasses.Exhibitor oExibitor = new ExpocadClasses.Exhibitor();
                oExibitor.ExhibitorId = oOpportunity.AccountId;
                oExibitor.ExhibitorName = subString(oOpportunity.Account.Name, 50);
                if (oOpportunity.Billing_Contact__c != null) {
                    Contact oCon = [SELECT Name, Phone, MailingStreet, Email, MailingCity, MailingState, MailingPostalCode, MailingCountry FROM Contact WHERE id = : oOpportunity.Billing_Contact__c];
                    if (!String.isBlank(oCon.MailingState)) {
                        oExibitor.State = subString(oCon.MailingState, 10);
                    }
                    if (!String.isBlank(oCon.MailingPostalCode)) {
                        oExibitor.PostalCode = subString(oCon.MailingPostalCode, 10);
                    }

                    if (!String.isBlank(sExhibitorDrawingName)) {
                        oExibitor.DoingBusinessAsDisplayOnDrawing =  subString(sExhibitorDrawingName, 50);
                    }
                    if (!String.isBlank(sComment2Name)) { oExibitor.Comments2 = sComment2Name;
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
                }
                String sExbBody = JSON.serialize(oExibitor);
                sAPIUrl = oOpportunity.EventEdition__r.Expocad_API_Url__c + '/exhibitors/add?databaseName=' + sExocadDB;
                HttpResponse res2 = new ExpocadResponses().request(sAPIUrl, 'POST', sExbBody);
                if (res2.getStatus() == null && !String.isBlank(sBoothNumber)) {
                    ExpocadResponses.logFailedTransaction(sBoothNumber, oOpportunity.Id, oOpportunity.SBQQ__PrimaryQuote__c, 'Rent', '', 'API is not responding', currentTime, 'Fail', sAPIUrl, '', '');
                    return isExbIDPresent;
                }
                if (res2.getStatusCode() == 201 || (res2.getBody() != null && res2.getBody().containsIgnoreCase('-1833'))) {
                    isExbIDPresent = true;
                } else { ExpocadResponses.logFailedTransaction(sBoothNumber, oOpportunity.Id, oOpportunity.SBQQ__PrimaryQuote__c, 'Rent', String.valueOf(res2.getStatusCode()), res2.getBody(), currentTime, 'Fail', sAPIUrl, res2.getStatus(), ''); }
            }
        } catch (exception ex) {
            Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'ExbIDPresent(@BoothSelectionHlpr.Class)');
        }
        return isExbIDPresent;
    }
    /* Added co- exhibitor
    Added By Rajesh Kumar  */
    public static String createCoExibitor(String sBoothNumber, String sExocadDB, Id oOpportunity , Id oQuote , Id relOppAccId , String sAPIUrl , String sDisplayNames) {
        Integer iGetStatusCode ;
        String sGetBody ;
        String sGetstatus;
        Boolean isExbIDPresent = false;
        String jsonMessage = '';
        set<Id> sOpp = new set<id>();
        List<Opportunity> lstOpp = new List<Opportunity>();
        BoothSelectionHlpr oBoothSelectionHlpr = new BoothSelectionHlpr();
        try {
            sOpp.add(oOpportunity);
            lstOpp = EBEnhancementUtil.OpListFromEB(sOpp);
            Opportunity opp = lstOpp[0];
            isExbIDPresent = oBoothSelectionHlpr.ExbIDPresentOrNot(sBoothNumber, sExocadDB, Opp , sDisplayNames);
            if (isExbIDPresent) {
                sAPIUrl = sAPIUrl + '/booths/childExhibitor/add?childExhibitorId=' + relOppAccId + '&boothNumber=' + sBoothNumber + '&databaseName=' + sExocadDB;
                sAPIUrl = sAPIUrl.replace(' ', '%20');
                DateTime currentTime = System.now();
                HttpResponse resDisplay = new ExpocadResponses().request(sAPIUrl, 'PUT', '');
                if (resDisplay.getStatus() == null && !String.isBlank(sBoothNumber)) {
                    ExpocadResponses.logFailedTransaction(sBoothNumber, oOpportunity, oQuote, 'Add Co-Exhibitor', '', 'API is not responding', currentTime, 'Fail', sAPIUrl, '', '');
                } else if (resDisplay.getStatusCode() == 200) { ExpocadResponses.logFailedTransaction(sBoothNumber, oOpportunity, oQuote, 'Add Co-Exhibitor', String.valueOf(resDisplay.getStatusCode()), resDisplay.getBody(), currentTime, 'Success', sAPIUrl, resDisplay.getStatus(), sDisplayNames); return 'Success' + ' - ' + resDisplay.getStatusCode() + ' - ' + resDisplay.getBody() + ' - ' + resDisplay.getStatus();
                } else if (resDisplay.getStatusCode() == 400 || (resDisplay.getBody() != null && resDisplay.getBody().containsIgnoreCase('-1905'))) { ExpocadResponses.logFailedTransaction(sBoothNumber, oOpportunity, oQuote, 'Already Exist Child Co-Exhibitor', String.valueOf(resDisplay.getStatusCode()), resDisplay.getBody(), currentTime, 'Success', sAPIUrl, resDisplay.getStatus(), ''); iGetStatusCode = resDisplay.getStatusCode(); sGetBody = resDisplay.getBody(); sGetstatus = resDisplay.getStatus();
                } else { ExpocadResponses.logFailedTransaction(sBoothNumber, oOpportunity, oQuote, 'Add Co-Exhibitor', String.valueOf(resDisplay.getStatusCode()), resDisplay.getBody(), currentTime, 'Fail', sAPIUrl, resDisplay.getStatus(), ''); }
            }

        } catch (exception ex) { Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'createCoExibitor(@BoothSelectionHlpr.Class)'); }
        return 'Failure' + ' - ' + iGetStatusCode + ' - ' + sGetBody + ' - ' + sGetstatus;
    }

    @future(callout = true)
    public static void AsyncupdateComment2onExbhitor(String sBoothNumber, String sExocadDB, Id oppId) {
        String sExecutionMsg =  updateComment2onExbhitor (sBoothNumber, sExocadDB, oppId );
    }

    //BK-2896 - Start Code : Rajesh Kr - 02/12/2019
    public static string updateComment2onExbhitor(String sBoothNumber, String sExocadDB, Id oppId) {
        try {
            Opportunity oOpportunity = [SELECT Id, Name, EventEdition__r.Expocad_API_Url__c, AccountId, Account.Name, SBQQ__PrimaryQuote__c , User_Type__r.Name FROM Opportunity where Id = : oppId];
            String sAPIUrl = oOpportunity.EventEdition__r.Expocad_API_Url__c + '/exhibitors?id=' + oOpportunity.AccountId + '&databaseName=' + sExocadDB;
            DateTime currentTime = System.now();
            String Comment2 = oOpportunity.User_Type__r.Name;
            HttpResponse res = new ExpocadResponses().request(sAPIUrl, 'GET', '');
            if (res.getStatus() == null && !String.isBlank(sBoothNumber)) { ExpocadResponses.logFailedTransaction(sBoothNumber, oOpportunity.Id, oOpportunity.SBQQ__PrimaryQuote__c, 'Exhibitor Update Comment 2 Name', '', 'API is not responding', currentTime, 'Fail', sAPIUrl, '', '');
            }
            if ((res.getStatusCode() == 200 && res.getBody() != null)) {
                ExpocadClasses.Exhibitor oExibitor = new ExpocadClasses.Exhibitor(); oExibitor.ExhibitorId = oOpportunity.AccountId; oExibitor.ExhibitorName = subString(oOpportunity.Account.Name, 50);
                if (!String.isBlank(Comment2) && Comment2 == 'Agent') { oExibitor.Comments2 = subString(Comment2, 50);
                }
                String sExbBody = JSON.serialize(oExibitor); sAPIUrl = oOpportunity.EventEdition__r.Expocad_API_Url__c + '/exhibitors/update?id=' + oOpportunity.AccountId + '&databaseName=' + sExocadDB;
                HttpResponse res2 = new ExpocadResponses().request(sAPIUrl, 'PUT', sExbBody);

                if (res2.getStatusCode() == 200 && res2.getBody() != null) { ExpocadResponses.logFailedTransaction(sBoothNumber, oOpportunity.Id, oOpportunity.SBQQ__PrimaryQuote__c, 'Exhibitor Update Comment 2 Name', String.valueOf(res2.getStatusCode()), res2.getBody(), currentTime, 'Success', sAPIUrl, res2.getStatus(), '');  return 'Success';
                }
                if (res2.getStatus() == null && !String.isBlank(sBoothNumber)) { ExpocadResponses.logFailedTransaction(sBoothNumber, oOpportunity.Id, oOpportunity.SBQQ__PrimaryQuote__c, 'Exhibitor Update Comment 2 Name', '', 'API is not responding', currentTime, 'Fail', sAPIUrl, '', '');
                }
            }
        } catch (exception ex) { Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'updateDisplayDrawingNameToExibitor Method (@BoothSelectionHlpr.Class)');
        }
        return 'Failure';
    }
    //BK - 2896 - End Code : Rajesh Kr - 02-12-2019



    public static string RemoveCoExibitor(String sBoothNumber, String sExocadDB, Id oOpportunity , Id oQuote , Id relOppAccId , String sAPIUrl) {

        Integer sGetStatusCode ;
        String sGetbody ;
        String sGetstatus;

        try {
            sAPIUrl = sAPIUrl + '/booths/childExhibitor/remove?childExhibitorId=' + relOppAccId + '&boothNumber=' + sBoothNumber + '&databaseName=' + sExocadDB;
            DateTime currentTime = System.now();
            HttpResponse res = new ExpocadResponses().request(sAPIUrl, 'PUT', '');
            sGetStatusCode = res.getStatusCode();
            sGetbody = res.getBody();
            sGetstatus = res.getStatus();

            if (res.getStatus() == null && !String.isBlank(sBoothNumber)) {
                ExpocadResponses.logFailedTransaction(sBoothNumber, oOpportunity, oQuote, 'Remove Co-Exhibitor' , '', 'API is not responding', currentTime, 'Fail', sAPIUrl, '', '');
                return 'Failure' + ' - ' + sGetStatusCode + ' - ' + sGetbody + ' - ' + sGetstatus ;
            } else if (res.getStatusCode() == 200 && res.getBody() != null) { ExpocadResponses.logFailedTransaction(sBoothNumber, oOpportunity, oQuote, 'Remove Co-Exhibitor', String.valueOf(res.getStatusCode()), res.getBody(), currentTime, 'Success', sAPIUrl, res.getStatus(), ''); return 'Success' + ' - ' + res.getStatusCode() + ' - ' + res.getBody() + ' - ' + res.getStatus(); } else { ExpocadResponses.logFailedTransaction(sBoothNumber, oOpportunity, oQuote, 'Remove Co-Exhibitor', String.valueOf(res.getStatusCode()), res.getBody(), currentTime, 'Fail', sAPIUrl, res.getStatus(), '');
            }
        } catch (exception ex) { Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'RemoveCoExibitor(@BoothSelectionHlpr.Class)'); } return 'Failure' + ' - ' + sGetStatusCode + ' - ' + sGetbody + ' - ' + sGetstatus ;
    }

    Public static String subString(String sTemp, Integer iLength) {
        if (sTemp.length() > iLength) { sTemp = sTemp.substring(0, iLength); }
        return sTemp;
    }
}