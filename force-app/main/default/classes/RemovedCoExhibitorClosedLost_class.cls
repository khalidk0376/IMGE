/**
 * File:           RemovedCoExhibitorClosedLost_Class.tgr
 * Project:        GAP
 * Date:           14/12/2018
 * Created By:     Rajesh Kumar
 * Modified Date:  8th March 2019
 * Modified By:    Yash Gupta
 * Test Class:     RemovedCoExhibitorClosedLost_Test
  ************************************************************************
  Description: After udpate this trigger call a  method from  BoothSelectionHlpr class.
  ************************************************************************
 * History: As per ticket no [GGCW-3005]
 *          Modified by Avinash Shukla on 15/04/19 : GGCW-3005
      Modified by Avinash Shukla on 31/07/19 : BK-1221    
 *           MOdified by Avinash for Jira Ticket BK-2085 on 13/08/19  
 * Modified By Abhishek Sharma on 22/02/2023 : EX-154     
 */

public class RemovedCoExhibitorClosedLost_class {

   //variables
    List<Opportunity_ExpoCAD_Booth_Mapping__c> newOppLst             { get; set; }
    Map<Id, Opportunity_ExpoCAD_Booth_Mapping__c> oldOppMap          { get; set; }
    Boolean isInsert                        { get; set; }
    Boolean isupdate                        { get; set; }
    Boolean isBefore                        { get; set; }
    Boolean isAfter                         { get; set; }
    Set<Id> setIds               { get; set; }
    Set<Id> setIdParents          { get; set; }
    List<Opportunity_ExpoCAD_Booth_Mapping__c> listOebmToUdt { get; set; }
    Map<Id, Id> mapOfParentEbm         { get; set; }
    List<Opportunity_ExpoCAD_Booth_Mapping__c> lstExpocadBoothMappingObj { get; set; }
    // BK-1221
    List<Opportunity_ExpoCAD_Booth_Mapping__c> lstExpocadBoothMappingObjRollUp { get; set; }
    Set<Id> setOppIds             { get; set; } 

    //Constructor
    public RemovedCoExhibitorClosedLost_class( List<Opportunity_ExpoCAD_Booth_Mapping__c> newOppLst, Map<id, Opportunity_ExpoCAD_Booth_Mapping__c> oldOppMap, Boolean isInsert, Boolean isupdate, Boolean isBefore, Boolean isAfter ) {
        this.newOppLst    = newOppLst; 
        this.oldOppMap    = oldOppMap;
        this.isInsert     = isInsert;
        this.isupdate     = isupdate;
        this.isBefore     = isBefore;
        this.isAfter      = isAfter;
        setIds   = new Set<Id>();
        setIdParents   = new Set<Id>();
        listOebmToUdt = new List<Opportunity_ExpoCAD_Booth_Mapping__c>();
        mapOfParentEbm = new Map<Id, Id>();
        lstExpocadBoothMappingObj = new List<Opportunity_ExpoCAD_Booth_Mapping__c>();
        lstExpocadBoothMappingObjRollUp = new List<Opportunity_ExpoCAD_Booth_Mapping__c>(); // BK-1221
        setOppIds = new Set<Id>();
    }  
    public void removedCoExhibitor(){
        if(isAfter && isUpdate) {
            if (newOppLst.size() > 0){
                lstExpocadBoothMappingObj = [SELECT Id, Name, Account__r.Name,Expocad_Booth__c, Booth_Number__c,Opportunity__c, Expocad_Booth__r.Booth_Number__c,Is_Parent_Mapping__c,Expocad_Booth__r.Status__c, Opportunity__r.EventEdition__r.Event_Code__c, Status__c, Event_Code__c,Opportunity__r.SBQQ__PrimaryQuote__c, Opportunity__r.AccountId, Opportunity__r.EventEdition__r.Expocad_API_Url__c, Relation__c, Related_Opportunity__c , Display_Name__c ,Expocad_Booth__r.Display_Name__c , Parent_Opp_EB_Mapping__r.Opportunity__c , Parent_Opp_EB_Mapping__r.Quote__c,Parent_Opp_EB_Mapping__r.Account__c FROM Opportunity_ExpoCAD_Booth_Mapping__c WHERE Id IN : newOppLst];
                if (lstExpocadBoothMappingObj.size() > 0) {
                    for (Opportunity_ExpoCAD_Booth_Mapping__c oEBM1 : lstExpocadBoothMappingObj) {
                        if (oEBM1.Status__c != '0' && oEBM1.Status__c == 'Inactive' && oEBM1.Status__c != oldOppMap.get(oEBM1.Id).Status__c &&  !oEBM1.Is_Parent_Mapping__c){
                            if (String.IsNotBlank(oEBM1.Expocad_Booth__r.Booth_Number__c) && String.IsNotBlank(oEBM1.Opportunity__r.EventEdition__r.Event_Code__c) && String.IsNotBlank(oEBM1.Opportunity__c) && String.IsNotBlank(oEBM1.Opportunity__r.SBQQ__PrimaryQuote__c) && String.IsNotBlank(oEBM1.Opportunity__r.AccountId) && String.IsNotBlank(oEBM1.Opportunity__r.EventEdition__r.Expocad_API_Url__c)) {
                                BoothSelectionHlpr.AsyncRemoveExhibitor(oEBM1.Expocad_Booth__r.Booth_Number__c, oEBM1.Opportunity__r.EventEdition__r.Event_Code__c, oEBM1.Opportunity__c, oEBM1.Opportunity__r.SBQQ__PrimaryQuote__c, oEBM1.Opportunity__r.AccountId, oEBM1.Opportunity__r.EventEdition__r.Expocad_API_Url__c);
                            }
                        }
                        else if (oEBM1.Expocad_Booth__r.Status__c != 'Released' &&  oEBM1.Expocad_Booth__r.Status__c != 'Rented' && oEBM1.Display_Name__c != oldOppMap.get(oEBM1.Id).Display_Name__c && String.IsNotBlank(oEBM1.Display_Name__c)) {
                            //Modified by Abhishek Sharma on 22/02/2023 : EX-154
                            //ExpocadResponses.AsyncUNHOLD(oEBM1.Expocad_Booth__r.Booth_Number__c, oEBM1.Opportunity__c, oEBM1.Opportunity__r.SBQQ__PrimaryQuote__c, oEBM1.Opportunity__r.EventEdition__r.Event_Code__c,oEBM1.Opportunity__r.EventEdition__r.Expocad_API_Url__c , oEBM1.Display_Name__c);
                            
                            ExpocadBooth__c oExpocadBooth = new ExpocadBooth__c(Id=oEBM1.Expocad_Booth__c, 
                                                                                Booth_Number__c= oEBM1.Expocad_Booth__r.Booth_Number__c,
                                                                               	Opportunity__c = oEBM1.Opportunity__c);
                            String transId = Create3EApiSyncRecords.syncBooth(oExpocadBooth, 'Asynchronous', Expocad3E_Wrapper.EXPOCAD_BOOTH_UNHOLD, false, oEBM1.Display_Name__c);
                        }
                        
                        //Modified by Avinash Shukla on 13/08/19 : BK-2085
                        If(oldOppMap.containsKey(oEBM1.Id) && oEBM1.Status__c == 'Active' &&  oEBM1.Expocad_Booth__r.Status__c == 'Rented'){
                            if(oEBM1.Display_Name__c != oldOppMap.get(oEBM1.Id).Display_Name__c){
                                BoothSelectionHlpr oBoothSelectionHlpr = new BoothSelectionHlpr();
                                String DisplayName = '';
                                If(oEBM1.Display_Name__c == NULL){DisplayName = oEBM1.Account__r.Name;
                                                                 }
                                else{
                                    DisplayName = oEBM1.Display_Name__c;
                                }
                                boolean isfalse = false ;
                                If(oEBM1.Opportunity__c != NULL){ updateDisplayDrawingNameToExibitor(oEBM1.Booth_Number__c, oEBM1.Event_Code__c, oEBM1.Opportunity__c , DisplayName ,isfalse , ''); }
                            }
                        }
                        //Modified by Avinash Shukla on 13/08/19 : BK-2085
                    }
                }
            }
        }
    }
    public void mapOfParentEbm(){
        if(isAfter && isUpdate) {
            for (Opportunity_ExpoCAD_Booth_Mapping__c oebm : newOppLst) {
                if (Oebm.Status__c != '0' && Oebm.Status__c == 'Inactive' && Oebm.Status__c != oldOppMap.get(oebm.Id).Status__c &&  !Oebm.Is_Parent_Mapping__c) {
                    if (Oebm.Parent_Opp_EB_Mapping__c != null) {mapOfParentEbm.put(Oebm.Parent_Opp_EB_Mapping__c, Oebm.Id);
                                 
                    }
                }
            }
            
            if (!mapOfParentEbm.isEmpty() ){
                //Modified by Avinash Shukla BK-1221
                //Modified by Avinash Shukla BK-2134
                lstExpocadBoothMappingObj = [SELECT Id, Name, Related_Opportunity__c, Selected_Booth_Product_Type__c, (Select id from Opportunity_ExpoCAD_Booth_Mapping__r WHERE Status__c = 'Active') FROM Opportunity_ExpoCAD_Booth_Mapping__c WHERE Id IN : mapOfParentEbm.keySet()];
                if (lstExpocadBoothMappingObj.size() > 0){
                    for (Opportunity_ExpoCAD_Booth_Mapping__c oEM : lstExpocadBoothMappingObj){
                        //Making required changes : Modified By Avinash
                        if (!mapOfParentEbm.isEmpty() ) {
                            if(mapOfParentEbm.containsKey(OEM.Id)) { 
                                OEM.Related_Opportunity__c = NULL;   
                                //Modified by Avinash Shukla BK-2134                                      
                                OEM.Selected_Booth_Product_Type__c = 'Please Select';
                                //Modified by Avinash Shukla BK-1221
                                If(OEM.Opportunity_ExpoCAD_Booth_Mapping__r.isEmpty()){OEM.Count_Related_Exhibitors__c = 0; }
                                else{ OEM.Count_Related_Exhibitors__c = OEM.Opportunity_ExpoCAD_Booth_Mapping__r.size(); }
                                listOebmToUdt.add(OEM);
                            }
                        }
                    }
                }
            }
    
            if (listOebmToUdt.size() > 0 ){update listOebmToUdt;
             
            }
        }
        //Making required changes : Modified By Avinash
        //Modified by Avinash Shukla BK-1221
        if(isAfter && isInsert){
            Set<Id> parentEbmToUpdateRollUp = new Set<Id>();
                    
                                          
            for (Opportunity_ExpoCAD_Booth_Mapping__c oebm : newOppLst) {
                if (Oebm.Parent_Opp_EB_Mapping__c != null) {
                    parentEbmToUpdateRollUp.add(Oebm.Parent_Opp_EB_Mapping__c);
                                 
                                
                              
                                 
             
           
                }
            }
            if (!parentEbmToUpdateRollUp.isEmpty() ){lstExpocadBoothMappingObjRollUp = [SELECT Id, Name, Related_Opportunity__c, (Select id, Opportunity__c, Opportunity__r.StageName from Opportunity_ExpoCAD_Booth_Mapping__r WHERE Status__c = 'Active') FROM Opportunity_ExpoCAD_Booth_Mapping__c WHERE Id IN : parentEbmToUpdateRollUp];
                if (!lstExpocadBoothMappingObjRollUp.isEmpty()){
                    for (Opportunity_ExpoCAD_Booth_Mapping__c oEM : lstExpocadBoothMappingObjRollUp){If(OEM.Opportunity_ExpoCAD_Booth_Mapping__r.isEmpty()){OEM.Count_Related_Exhibitors__c = 0;
                            }
                            else{OEM.Count_Related_Exhibitors__c = OEM.Opportunity_ExpoCAD_Booth_Mapping__r.size();}listOebmToUdt.add(OEM);
                    }
                }
            }
            if (listOebmToUdt.size() > 0 ){update listOebmToUdt;
            }
        }
    }
  
  //Added by Avinash Shukla on 13/08/19 : BK-2085 // Update Code Rajesh : BK-2550
    @future (callout=true)
    public static void updateDisplayDrawingNameToExibitor(String sBoothNumber, String sExocadDB, Id oppId, String sDisplayNames , boolean flags, String sComment2Name) {
        flags = false;
        updateDisplayDrawingNameToExibitors (sBoothNumber, sExocadDB, oppId, sDisplayNames , flags, '' );
    }
    
    public static string updateDisplayDrawingNameToExibitors(String sBoothNumber, String sExocadDB, Id oppId, String sDisplayNames ,  boolean rentflags , String sComment2Name) {
        try {
            Opportunity oOpportunity = [SELECT Id, Name, EventEdition__r.Expocad_API_Url__c, AccountId, Account.Name, SBQQ__PrimaryQuote__c FROM Opportunity where Id =: oppId];
			DateTime currentTime = System.now();
			String sAPIUrl = '';
			ExpocadClasses.Exhibitor oExibitor = new ExpocadClasses.Exhibitor(); 
			oExibitor.ExhibitorId = oOpportunity.AccountId;  
			oExibitor.ExhibitorName = subString(oOpportunity.Account.Name, 50);
			if (!String.isBlank(sDisplayNames)) {
				oExibitor.DoingBusinessAsDisplayOnDrawing = subString(sDisplayNames, 50);        
			}
			if (!String.isBlank(sComment2Name) && sComment2Name == 'Agent'){
				oExibitor.Comments2 = subString(sComment2Name, 50);
			}        
			String sExbBody = JSON.serialize(oExibitor);
			sAPIUrl = oOpportunity.EventEdition__r.Expocad_API_Url__c + '/exhibitors/update?id=' + oOpportunity.AccountId + '&databaseName=' + sExocadDB;
			HttpResponse res = new ExpocadResponses().request(sAPIUrl, 'PUT', sExbBody);
			if (res.getStatusCode() == 200 && res.getBody() != null) {   
				if (!rentflags){
					ExpocadResponses.logFailedTransaction(sBoothNumber, oOpportunity.Id, oOpportunity.SBQQ__PrimaryQuote__c, 'Exhibitor Display Name', String.valueOf(res.getStatusCode()), res.getBody(), currentTime, 'Success', sAPIUrl, res.getStatus(), sDisplayNames);  
				}
				return 'Success'; 
			}
			if (res.getStatus() == null && !String.isBlank(sBoothNumber)) { ExpocadResponses.logFailedTransaction(sBoothNumber, oOpportunity.Id, oOpportunity.SBQQ__PrimaryQuote__c, 'Exhibitor Display Name', '', 'API is not responding', currentTime, 'Fail', sAPIUrl, '', sDisplayNames);
			}
        } catch (exception ex) {Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'updateDisplayDrawingNameToExibitor Method (@BoothSelectionHlpr.Class)');  System.debug('Exception : ' + Ex);  
        }
        return 'Failure';
    }
    
    public static String subString(String sTemp, Integer iLength) {
        if (sTemp.length() > iLength) {  sTemp = sTemp.substring(0, iLength);
        }
        return sTemp;
    }
}